/**
 * Regressietest voor de V58 schrijfwachtrij in index.html.
 *
 * Waarvoor: vóór V58 waren de score-RPC en de completed_challenges-insert
 * fire-and-forget. Bij een 4G-dip telde de telefoon de punten lokaal op, wist de
 * server van niets, en overschreef de eerstvolgende realtime-sync het lokale
 * getal — de punten verdwenen zonder dat iemand het zag, terwijl het scherm een
 * vinkje toonde.
 *
 * Het lastige deel is exactly-once: een score-delta opnieuw versturen mag niet
 * dubbel tellen. De stubs hieronder bootsen `increment_team_score_idem` na zoals
 * SUPABASE-SCORE-QUEUE-V58.sql hem implementeert (die kant is apart tegen een
 * echte PostgreSQL 16 getest).
 *
 * Draaien:  npm test
 */
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const INDEX = path.join(HERE, '..', 'index.html');

import 'fake-indexeddb/auto';

let online = true;
Object.defineProperty(globalThis, 'navigator', {
  configurable: true,
  get: () => ({ onLine: online }),
});
globalThis.document = undefined;

function slice(html, startMark, endMark) {
  const a = html.indexOf(startMark);
  const b = html.indexOf(endMark);
  assert.ok(a > 0 && b > a, `markers ${startMark} niet gevonden`);
  return html.slice(a, b);
}

async function loadQueues() {
  const html = fs.readFileSync(INDEX, 'utf8');
  // De schrijfwachtrij leunt op queueOpen/newClientId/mediaLog uit de
  // media-pipeline, dus beide blokken gaan mee.
  let code = slice(html, '// ══ MEDIA-PIPELINE-START ══', '// ══ MEDIA-PIPELINE-END ══')
           + slice(html, '// ══ WRITE-QUEUE-START ══', '// ══ WRITE-QUEUE-END ══');
  code = code.replace(/const WRITE_ATTEMPT_BACKOFF_MS=\[[^\]]*\];/, 'const WRITE_ATTEMPT_BACKOFF_MS=[0,1,2,3];');

  const names = ['WriteQueue', 'submitScoreDelta', 'submitInsert', 'flushWriteQueue',
                 'runWrite', 'setScoreReconciler', 'isTerminalError', 'isNetworkError', 'queueOpen'];
  const tmp = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'ssr-wq-')), 'q.mjs');
  fs.writeFileSync(tmp, `${code}\nexport { ${names.join(', ')} };\n`);
  return import(tmp);
}

const Q = await loadQueues();

/**
 * Supabase-stub. De RPC bootst de echte SQL na: een client_id dat al in
 * `applied` staat telt niet nog een keer mee.
 */
function makeSb(opts = {}) {
  const applied = new Map();       // client_id -> delta
  const scores = Object.assign({ 1: 100, 2: 0 }, opts.scores);
  const rpcCalls = [];
  const inserts = [];
  let rpcN = 0, insN = 0;

  return {
    applied, scores, rpcCalls, inserts,
    async rpc(fn, args) {
      rpcN++;
      rpcCalls.push({ fn, args });
      const fail = typeof opts.failRpc === 'function' ? opts.failRpc(fn, rpcN) : opts.failRpc;
      if (fail) return { data: null, error: fail === true ? new Error('Failed to fetch') : fail };
      if (fn === 'increment_team_score_idem') {
        if (!applied.has(args.p_client_id)) {
          applied.set(args.p_client_id, args.p_delta);
          scores[args.p_team_id] = Math.max(0, (scores[args.p_team_id] || 0) + args.p_delta);
        }
        return { data: scores[args.p_team_id], error: null };
      }
      if (fn === 'increment_team_score') {   // legacy: NIET idempotent
        scores[args.p_team_id] = Math.max(0, (scores[args.p_team_id] || 0) + args.p_delta);
        return { data: scores[args.p_team_id], error: null };
      }
      return { data: null, error: { code: '42883', message: 'function does not exist' } };
    },
    from(table) {
      return {
        async insert(row) {
          insN++;
          const err = opts.failInsert && opts.failInsert(table, row, insN, inserts);
          if (err) return { error: err };
          inserts.push({ table, row });
          return { error: null };
        },
      };
    },
  };
}

async function clearWrites() {
  for (const rec of await Q.WriteQueue.all()) await Q.WriteQueue.remove(rec.id);
}

test.beforeEach(async () => { online = true; Q.setScoreReconciler(null); await clearWrites(); });

// ─────────────────────────────────────────────────────────────────────────────

test('IndexedDB draagt beide wachtrijen', async () => {
  const db = await Q.queueOpen();
  assert.ok(db.objectStoreNames.contains('pending'), 'media-wachtrij');
  assert.ok(db.objectStoreNames.contains('writes'), 'schrijfwachtrij');
});

test('score-delta landt direct en trekt de lokale stand bij', async () => {
  const sb = makeSb();
  let reconciled = null;
  Q.setScoreReconciler((teamId, score) => { reconciled = { teamId, score }; });

  const res = await Q.submitScoreDelta(sb, 1, 25);
  assert.equal(res.queued, false);
  assert.equal(sb.scores[1], 125);
  assert.equal(sb.rpcCalls[0].fn, 'increment_team_score_idem');
  assert.ok(sb.rpcCalls[0].args.p_client_id, 'zonder sleutel is een replay niet veilig');
  assert.deepEqual(reconciled, { teamId: 1, score: 125 });
});

test('mislukte delta gaat in de rij en landt later alsnog', async () => {
  // Dit is precies het gat dat de speler zag: lokaal +25, server 100, en na de
  // volgende sync stond hij weer op 100.
  const dood = makeSb({ failRpc: true });
  const res = await Q.submitScoreDelta(dood, 1, 25);
  assert.equal(res.queued, true);
  assert.equal(dood.scores[1], 100, 'server is niet bijgewerkt');

  const q = await Q.WriteQueue.all();
  assert.equal(q.length, 1);
  assert.equal(q[0].kind, 'score');
  assert.equal(q[0].delta, 25);

  const sb = makeSb();
  let reconciled = null;
  Q.setScoreReconciler((teamId, score) => { reconciled = { teamId, score }; });
  const flushed = await Q.flushWriteQueue(sb);
  assert.equal(flushed.applied, 1);
  assert.equal(flushed.remaining, 0);
  assert.equal(sb.scores[1], 125);
  assert.deepEqual(reconciled, { teamId: 1, score: 125 });
});

test('een delta die twee keer wordt verstuurd telt één keer', async () => {
  // De kern van V58: zonder idempotentiesleutel zou de wachtrij punten verzinnen.
  const sb = makeSb();
  const rec = { id: 'vaste-sleutel', kind: 'score', teamId: 1, delta: 40 };
  assert.equal((await Q.runWrite(sb, rec)).ok, true);
  assert.equal((await Q.runWrite(sb, rec)).ok, true);
  assert.equal((await Q.runWrite(sb, rec)).ok, true);
  assert.equal(sb.scores[1], 140, 'drie pogingen, één keer geteld');
  assert.equal(sb.applied.size, 1);
});

test('crash tussen versturen en antwoord telt niet dubbel', async () => {
  // De server past de delta toe, daarna sterft de verbinding vóór het antwoord.
  // De telefoon weet niet beter en probeert het opnieuw — met dezelfde sleutel.
  const sb = makeSb();
  let n = 0;
  const flaky = {
    ...sb,
    async rpc(fn, args) {
      n++;
      const out = await sb.rpc(fn, args);
      if (n === 1) return { data: null, error: new Error('Failed to fetch') };  // wel toegepast
      return out;
    },
  };
  const res = await Q.submitScoreDelta(flaky, 1, 30);
  assert.equal(res.queued, true, 'de telefoon denkt dat het misging');
  assert.equal(sb.scores[1], 130, 'de server heeft hem wél verwerkt');

  await Q.flushWriteQueue(flaky);
  assert.equal(sb.scores[1], 130, 'de retry telt niet nog eens mee');
  assert.equal((await Q.WriteQueue.all()).length, 0);
});

test('zonder de idempotente RPC: één keer legacy, daarna stoppen', async () => {
  // Patch niet gedraaid. Liever een delta die een keer mist dan een die dubbel
  // telt — de legacy-RPC heeft geen sleutel, dus blind herhalen is gevaarlijk.
  const sb = makeSb({
    failRpc: (fn) => (fn === 'increment_team_score_idem'
      ? { code: '42883', message: 'function increment_team_score_idem does not exist' }
      : false),
  });
  const rec = { id: 'geen-idem', kind: 'score', teamId: 1, delta: 20 };
  await Q.WriteQueue.add(rec);

  const first = await Q.runWrite(sb, { ...rec });
  assert.equal(first.ok, true);
  assert.equal(sb.scores[1], 120, 'legacy heeft geteld');

  const stored = (await Q.WriteQueue.all())[0];
  assert.equal(stored.legacyTried, true, 'gemarkeerd zodat een tweede ronde stopt');

  const second = await Q.runWrite(sb, stored);
  assert.equal(second.gaveUp, true);
  assert.equal(sb.scores[1], 120, 'niet nog eens geteld');
});

test('offline delta wordt bewaard zonder te proberen', async () => {
  online = false;
  const sb = makeSb();
  const res = await Q.submitScoreDelta(sb, 1, 15);
  assert.equal(res.queued, true);
  assert.equal(sb.rpcCalls.length, 0);

  online = true;
  await Q.flushWriteQueue(sb);
  assert.equal(sb.scores[1], 115);
});

test('delta van 0 doet niets', async () => {
  const sb = makeSb();
  await Q.submitScoreDelta(sb, 1, 0);
  assert.equal(sb.rpcCalls.length, 0);
  assert.equal((await Q.WriteQueue.all()).length, 0);
});

test('duplicaat-insert is afgehandeld, geen eeuwige retry', async () => {
  const sb = makeSb({ failInsert: () => ({ code: '23505', message: 'duplicate key' }) });
  let terminal = null;
  const res = await Q.submitInsert(sb, 'completed_challenges',
    { team_id: 1, challenge_id: '5_0' }, { onTerminal: (c) => { terminal = c; } });

  assert.equal(res.queued, false, 'een teamgenoot was ons voor — dat is klaar, niet mislukt');
  assert.equal(terminal, '23505', 'de toast hangt hieraan');
  assert.equal((await Q.WriteQueue.all()).length, 0);
});

test('geheimhoudingstrigger (23514) blijft niet hangen', async () => {
  const sb = makeSb({ failInsert: () => ({ code: '23514', message: 'secrecy check' }) });
  const res = await Q.submitInsert(sb, 'completed_challenges', { team_id: 1, challenge_id: '9_0' });
  assert.equal(res.queued, false);
  assert.equal(res.terminal, '23514');
  assert.equal((await Q.WriteQueue.all()).length, 0);
});

test('netwerkfout bij een insert: in de rij, later alsnog geschreven', async () => {
  const dood = makeSb({ failInsert: () => ({ message: 'Failed to fetch' }) });
  const res = await Q.submitInsert(dood, 'completed_challenges', { team_id: 1, challenge_id: '3_1' });
  assert.equal(res.queued, true);

  const sb = makeSb();
  const flushed = await Q.flushWriteQueue(sb);
  assert.equal(flushed.applied, 1);
  assert.equal(sb.inserts.length, 1);
  assert.equal(sb.inserts[0].row.challenge_id, '3_1');
});

test('de wachtrij landt in de volgorde waarin de punten zijn verdiend', async () => {
  const dood = makeSb({ failRpc: true });
  for (const d of [10, 20, 30]) {
    await Q.submitScoreDelta(dood, 1, d);
    await new Promise(r => setTimeout(r, 2));   // aparte createdAt
  }
  const sb = makeSb();
  await Q.flushWriteQueue(sb);
  assert.deepEqual(sb.rpcCalls.map(c => c.args.p_delta), [10, 20, 30]);
  assert.equal(sb.scores[1], 160);
});

test('een dode verbinding stopt de ronde in plaats van de rij af te branden', async () => {
  const dood = makeSb({ failRpc: true });
  for (const d of [10, 20, 30]) {
    await Q.submitScoreDelta(dood, 1, d);
    await new Promise(r => setTimeout(r, 2));
  }
  const nogSteedsDood = makeSb({ failRpc: true });
  const flushed = await Q.flushWriteQueue(nogSteedsDood);
  assert.equal(flushed.applied, 0);
  assert.equal(flushed.remaining, 3, 'alles blijft staan');
  assert.equal(nogSteedsDood.rpcCalls.length, 1, 'na de eerste mislukking stoppen we');
});

test('foutclassificatie', () => {
  assert.equal(Q.isTerminalError({ code: '23505' }), true);
  assert.equal(Q.isTerminalError({ code: '23514' }), true);
  assert.equal(Q.isTerminalError({ code: '42P01' }), true);
  assert.equal(Q.isTerminalError({ message: 'duplicate key value' }), true);
  assert.equal(Q.isTerminalError({ message: 'Failed to fetch' }), false);
  assert.equal(Q.isNetworkError(new Error('Failed to fetch')), true);
  assert.equal(Q.isNetworkError(new Error('NetworkError when attempting')), true);
  assert.equal(Q.isNetworkError({ code: '23505' }), false);
});
