/**
 * Regressietest voor de V57 media-pipeline in index.html.
 *
 * Waarom dit bestaat: op de echte speeldag (6 juni 2026) zijn veel foto's en
 * video's niet doorgekomen. De oorzaken zaten allemaal in de client en waren
 * allemaal stil. Elke test hieronder legt één van die oorzaken vast, zodat ze
 * niet terug kunnen sluipen.
 *
 * Aanpak: het blok tussen de MEDIA-PIPELINE-markers wordt uit index.html
 * geknipt en in Node geladen met stubs voor Supabase, IndexedDB en de browser.
 * De pipeline is bewust vrij van React en DOM, juist zodat dit kan.
 *
 * Draaien:
 *   npm i --no-save fake-indexeddb
 *   node --test test/media-pipeline.test.mjs
 */
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const INDEX = path.join(HERE, '..', 'index.html');

// ── Browser-stubs ────────────────────────────────────────────────────────────
import 'fake-indexeddb/auto';

let online = true;
Object.defineProperty(globalThis, 'navigator', {
  configurable: true,
  get: () => ({ onLine: online }),
});
// compressPhotoBlob bails out to the original file when there is no document,
// which is exactly what we want for the upload tests: geen canvas in Node.
globalThis.document = undefined;

// ── Pipeline uit index.html knippen ──────────────────────────────────────────
async function loadPipeline() {
  const html = fs.readFileSync(INDEX, 'utf8');
  const start = html.indexOf('// ══ MEDIA-PIPELINE-START ══');
  const end = html.indexOf('// ══ MEDIA-PIPELINE-END ══');
  assert.ok(start > 0 && end > start, 'pipeline-markers niet gevonden in index.html');
  let code = html.slice(start, end);

  // Enige testinstrumentatie: de echte backoff is 0/1.5/4/9s — dat maakt de
  // suite onnodig traag. Gedrag verandert niet, alleen de wachttijd.
  code = code.replace(
    /const UPLOAD_BACKOFF_MS=\[[^\]]*\];/,
    'const UPLOAD_BACKOFF_MS=[0,1,2,3];'
  );

  const exports = [
    'compressPhotoBlob', 'uploadMedia', 'submitMedia', 'flushMediaQueue',
    'MediaQueue', 'insertRow', 'isVideoFile', 'extForType', 'newClientId',
    'MEDIA_HARD_LIMIT_BYTES',
  ];
  const mod = `${code}\nexport { ${exports.join(', ')} };\n`;
  const tmp = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'ssr-')), 'pipeline.mjs');
  fs.writeFileSync(tmp, mod);
  return import(tmp);
}

const P = await loadPipeline();

// ── Supabase-stub ────────────────────────────────────────────────────────────
// Legt vast wat er precies naar Storage en naar de tabellen gaat, zodat een
// test kan controleren dát de bytes aankomen — niet alleen dat er niets crasht.
function makeSb(opts = {}) {
  const uploads = [];
  const rows = { photo_reviews: [], activity_feed: [] };
  const updates = [];
  let uploadCalls = 0;
  return {
    uploads, rows, updates,
    get uploadCalls() { return uploadCalls; },
    storage: {
      from() {
        return {
          async upload(name, blob, cfg) {
            uploadCalls++;
            const fail = typeof opts.failUploads === 'function'
              ? opts.failUploads(uploadCalls)
              : opts.failUploads;
            if (fail) return { data: null, error: fail === true ? new Error('Failed to fetch') : fail };
            uploads.push({ name, blob, cfg, size: blob.size, type: blob.type });
            return { data: { path: name }, error: null };
          },
          getPublicUrl(p) {
            return { data: { publicUrl: `https://stub.supabase.co/storage/v1/object/public/media/${p}` } };
          },
        };
      },
    },
    from(table) {
      return {
        async insert(row) {
          const err = opts.insertError && opts.insertError(table, row, rows);
          if (err) return { error: err };
          rows[table].push(row);
          return { error: null };
        },
        update(patch) {
          return {
            async eq(col, val) {
              updates.push({ table, patch, col, val });
              return { error: opts.updateError || null };
            },
          };
        },
      };
    },
  };
}

async function clearQueue() {
  for (const rec of await P.MediaQueue.all()) await P.MediaQueue.remove(rec.id);
}

const videoFile = (mb = 5) =>
  new File([new Uint8Array(mb * 1024 * 1024)], 'IMG_0042.mov', { type: 'video/quicktime' });
const photoFile = (kb = 900) =>
  new File([new Uint8Array(kb * 1024)], 'IMG_0043.jpg', { type: 'image/jpeg' });

test.beforeEach(async () => { online = true; await clearQueue(); });

// ─────────────────────────────────────────────────────────────────────────────

test('video gaat als Blob naar Storage, niet als base64', async () => {
  const sb = makeSb();
  const res = await P.submitMedia(sb, {
    file: videoFile(5),
    prefix: 'jorik_test',
    reviewRow: { team_id: 1, challenge_title: 'Jorik-missie' },
  });

  assert.equal(res.ok, true);
  assert.equal(res.queued, false, 'had direct moeten uploaden');
  assert.equal(sb.uploads.length, 1);

  const up = sb.uploads[0];
  // De kern van bug 3: de oude code maakte hier een base64-string van ~6.8 MB.
  assert.equal(up.size, 5 * 1024 * 1024, 'bytes moeten 1:1 doorgaan, niet base64-opgeblazen');
  assert.ok(up.name.endsWith('.mov'), `extensie uit contentType, kreeg ${up.name}`);
  assert.equal(up.type, 'video/quicktime');

  // En de rij draagt de URL, niet de media zelf.
  assert.equal(sb.rows.photo_reviews.length, 1);
  assert.equal(sb.rows.photo_reviews[0].photo_url, res.url);
  assert.ok(!String(sb.rows.photo_reviews[0].photo_url).startsWith('data:'));
});

test('een foto die niet kleiner te krijgen is wordt alsnog geüpload', async () => {
  // Bug 2: compressPhotoAdaptive gaf null terug boven 500 kB, waarna photo_url
  // als null in de rij landde en de foto weg was. Zonder document valt
  // compressPhotoBlob terug op het origineel — dat moet gewoon uploaden.
  const sb = makeSb();
  const res = await P.submitMedia(sb, {
    file: photoFile(3000),
    prefix: 't1_l5_c0',
    reviewRow: { team_id: 1, location_id: 5 },
  });

  assert.equal(res.queued, false);
  assert.ok(res.url, 'URL verwacht, geen null');
  assert.equal(sb.uploads[0].size, 3000 * 1024, 'origineel moet doorgaan, niet gedropt');
  assert.equal(sb.rows.photo_reviews[0].photo_url, res.url);
});

test('compressPhotoBlob geeft nooit null terug, ook niet als alles faalt', async () => {
  // De contractregel die bug 2 onmogelijk maakt.
  const f = photoFile(800);
  globalThis.document = {
    createElement() {
      return {
        width: 0, height: 0,
        getContext() { return { drawImage() { throw new Error('canvas kapot'); } }; },
        toBlob(cb) { cb(null); },
      };
    },
  };
  globalThis.createImageBitmap = async () => ({ width: 4000, height: 3000, close() {} });
  try {
    const out = await P.compressPhotoBlob(f);
    assert.ok(out, 'moet een Blob teruggeven');
    assert.equal(out.size, f.size, 'bij een kapotte canvas het origineel');
  } finally {
    globalThis.document = undefined;
    delete globalThis.createImageBitmap;
  }
});

test('mislukte upload belandt in de wachtrij en gaat later alsnog door', async () => {
  // Bug 4 + het ontbreken van een retry: een 4G-dip betekende permanent verlies.
  const failing = makeSb({ failUploads: true });
  const res = await P.submitMedia(failing, {
    file: videoFile(2),
    prefix: 't2_l9_c1',
    reviewRow: { team_id: 2, location_id: 9 },
  });

  assert.equal(res.ok, true, 'de speler mag dit niet als fout zien — de media is veilig');
  assert.equal(res.queued, true);
  assert.equal(failing.rows.photo_reviews.length, 0, 'nog geen rij zonder media');

  const queued = await P.MediaQueue.all();
  assert.equal(queued.length, 1);
  assert.equal(queued[0].blob.size, 2 * 1024 * 1024, 'de echte bytes staan geparkeerd');

  // Later, met bereik: de flush maakt het af.
  const ok = makeSb();
  const flushed = await P.flushMediaQueue(ok);
  assert.equal(flushed.uploaded, 1);
  assert.equal(flushed.remaining, 0, 'wachtrij leeg na succes');
  assert.equal(ok.uploads[0].size, 2 * 1024 * 1024);
  assert.equal(ok.rows.photo_reviews.length, 1);
  assert.ok(ok.rows.photo_reviews[0].photo_url.startsWith('https://'));
});

test('offline capture wordt bewaard in plaats van geweigerd', async () => {
  online = false;
  const sb = makeSb();
  const res = await P.submitMedia(sb, {
    file: photoFile(500), prefix: 't3', reviewRow: { team_id: 3 },
  });
  assert.equal(res.queued, true);
  assert.equal(sb.uploadCalls, 0, 'niet eens proberen zonder netwerk');
  assert.equal((await P.MediaQueue.all()).length, 1);

  online = true;
  const flushed = await P.flushMediaQueue(sb);
  assert.equal(flushed.uploaded, 1);
});

test('bestand boven de serverlimiet wordt bewaard, niet weggegooid', async () => {
  const sb = makeSb();
  const huge = new File([new Uint8Array(P.MEDIA_HARD_LIMIT_BYTES + 1024)], 'big.mov', { type: 'video/quicktime' });
  const res = await P.submitMedia(sb, { file: huge, prefix: 't4', reviewRow: { team_id: 4 } });

  assert.equal(res.ok, true);
  assert.equal(res.queued, true);
  assert.match(res.error.message, /MB/, 'speler moet horen waarom het wacht');
  assert.equal(sb.uploadCalls, 0);
  assert.equal((await P.MediaQueue.all()).length, 1, 'blijft staan tot de bucketlimiet omhoog gaat');
});

test('upload lukt maar de rij faalt: geen tweede upload bij de retry', async () => {
  let allowInsert = false;
  const sb = makeSb({ insertError: () => (allowInsert ? null : { message: 'Failed to fetch' }) });
  const res = await P.submitMedia(sb, {
    file: videoFile(1), prefix: 't5', reviewRow: { team_id: 5 },
  });
  assert.equal(res.queued, true);
  assert.ok(res.url, 'de media zit al in Storage');
  assert.equal(sb.uploadCalls, 1);

  allowInsert = true;
  await P.flushMediaQueue(sb);
  assert.equal(sb.uploadCalls, 1, 'de bytes mogen niet nog eens de lucht in');
  assert.equal(sb.rows.photo_reviews.length, 1);
});

test('replay na crash levert geen dubbele rij op', async () => {
  // client_id is UNIQUE (SUPABASE-MEDIA-FIX-V57.sql); 23505 betekent
  // "stond er al", niet "mislukt" — anders blijft het item eeuwig in de rij.
  const sb = makeSb({
    insertError: (table, row, rows) =>
      rows[table].some(r => r.client_id === row.client_id) ? { code: '23505' } : null,
  });
  const row = { team_id: 6, client_id: 'vast-id' };
  assert.equal((await P.insertRow(sb, 'photo_reviews', row)).ok, true);
  assert.equal((await P.insertRow(sb, 'photo_reviews', row)).ok, true, '23505 telt als geslaagd');
  assert.equal(sb.rows.photo_reviews.length, 1);
});

test('oude database zonder client_id blijft werken', async () => {
  const sb = makeSb({
    insertError: (t, row) => (row.client_id !== undefined ? { code: '42703', message: 'column "client_id" does not exist' } : null),
  });
  const res = await P.insertRow(sb, 'photo_reviews', { team_id: 7, client_id: 'x' });
  assert.equal(res.ok, true);
  assert.equal(sb.rows.photo_reviews[0].client_id, undefined, 'kolom eraf gelaten en opnieuw geprobeerd');
});

test('patch-modus vult de feedregel aan zodra de upload landt', async () => {
  // Het Jorik-missiepad: de feedregel staat er meteen, de video komt erachteraan.
  const failing = makeSb({ failUploads: true });
  const cid = 'jorik-cid';
  const res = await P.submitMedia(failing, {
    file: videoFile(3), prefix: 'jorik_12', clientId: cid,
    patch: { table: 'activity_feed', column: 'photo', clientId: cid + '_a' },
  });
  assert.equal(res.queued, true);

  const sb = makeSb();
  await P.flushMediaQueue(sb);
  assert.equal(sb.updates.length, 1);
  assert.equal(sb.updates[0].table, 'activity_feed');
  assert.equal(sb.updates[0].col, 'client_id');
  assert.equal(sb.updates[0].val, cid + '_a');
  assert.ok(sb.updates[0].patch.photo.startsWith('https://'), 'de URL wordt bijgeschreven');
  assert.equal((await P.MediaQueue.all()).length, 0);
});

test('een blijvend falende upload blijft in de rij staan', async () => {
  const sb = makeSb({ failUploads: true });
  await P.submitMedia(sb, { file: photoFile(100), prefix: 't8', reviewRow: { team_id: 8 } });
  await P.flushMediaQueue(sb);
  await P.flushMediaQueue(sb);
  const q = await P.MediaQueue.all();
  assert.equal(q.length, 1, 'nooit stilletjes opgeruimd');
  assert.ok(q[0].attempts >= 2, `pogingen worden geteld, was ${q[0].attempts}`);
  assert.ok(q[0].lastError, 'en de reden wordt bewaard');
});

test('netwerkfout wordt opnieuw geprobeerd, een 413 niet', async () => {
  const flaky = makeSb({ failUploads: (n) => (n < 3 ? true : false) });
  const res = await P.submitMedia(flaky, { file: photoFile(50), prefix: 't9', reviewRow: { team_id: 9 } });
  assert.equal(res.queued, false, 'derde poging slaagt');
  assert.equal(flaky.uploadCalls, 3);

  const tooBig = makeSb({ failUploads: () => ({ statusCode: '413', message: 'Payload too large' }) });
  const res2 = await P.submitMedia(tooBig, { file: photoFile(50), prefix: 't10', reviewRow: { team_id: 10 } });
  assert.equal(res2.queued, true);
  assert.equal(tooBig.uploadCalls, 1, 'een geweigerd bestand niet 4x opsturen');
});

test('extensie volgt het contentType, zodat .mov niet als foto eindigt', () => {
  assert.equal(P.extForType('video/quicktime'), 'mov');
  assert.equal(P.extForType('video/mp4'), 'mp4');
  assert.equal(P.extForType('image/jpeg'), 'jpg');
  assert.equal(P.extForType('image/heic'), 'heic');
  assert.equal(P.isVideoFile(videoFile(1)), true);
  assert.equal(P.isVideoFile(photoFile(1)), false);
  assert.equal(P.isVideoFile(new File([1], 'clip.MP4', { type: '' })), true, 'val terug op de bestandsnaam');
});
