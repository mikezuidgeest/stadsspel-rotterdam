# V57 — waarom foto's en video's niet doorkwamen, en wat er nu anders is

**Aanleiding:** Mike, na de echte speeldag (6 juni 2026): *"veel video's en foto's
zijn niet doorgekomen."*

Dit was geen netwerkpech. Er zaten vier onafhankelijke plekken in de client die
media stilletjes weggooiden, en in elk geval ging de opdracht daarna gewoon als
voltooid de lijst in — de speler zag een vinkje en nam aan dat het gelukt was.

---

## De vier oorzaken

### 1. Elke payload boven 600 kB werd verwijderd vóór de insert

In `addActivity` stond:

```js
if(shareable.photo&&shareable.photo.length>600000){delete shareable.photo}
```

Op zichzelf redelijk bedoeld — media leefde ooit inline in een Postgres-rij. Maar
het Jorik-missiepad stuurde ruwe base64 rechtstreeks deze functie in, en een
video is **altijd** groter dan 600 kB. Netto: **100% van de Jorik-missievideo
werd op de telefoon weggegooid.** Dat was precies het materiaal dat voor de
bruiloftsedit werd verzameld. Ook een gecomprimeerde foto van 650 kB sneuvelde.

### 2. Foto's die niet klein genoeg werden, werden bewust gedropt

`compressPhotoAdaptive` eindigde met:

```js
if((out?.length||0)>COMPRESS_HARD_CAP_BYTES){   // 500 kB
  console.warn('photo still too large after 3 compression tiers — dropping thumbnail');
  return null;
}
```

Die grens bestond omdat media in een databaserij moest passen. Sinds V41.11 gaat
media naar Supabase Storage, waar een JPEG van 4 MB geen enkel probleem is — maar
de drop is nooit weggehaald. Gevolg: `photo_url` werd `null`, de opdracht telde
mee, de foto bestond niet meer.

Dit raakte vooral foto's die de browser niet kon decoderen (HEIC op sommige
toestellen, panorama's): `img.onerror` gaf het ongewijzigde origineel terug, alle
drie de tiers leverden hetzelfde te grote bestand op, en dan viel het weg.

### 3. Video's werden eerst naar base64 omgezet — op de telefoon

Het challenge-pad deed `FileReader.readAsDataURL` → `atob` → een byte-voor-byte
lus naar een `Uint8Array`. Voor een iPhone-clip van 100 MB is dat ongeveer 350 MB
piekgeheugen en 100 miljoen lusiteraties. iOS Safari sluit het tabblad af. Geen
upload, geen foutmelding, geen video.

(Het bruiloftsmissiepad gaf de `File` al wél direct aan Storage — het
challenge-pad had die fix simpelweg nooit gekregen.)

### 4. Alles faalde stil

De insert in `addActivity` slikte fouten (`.then(()=>{},()=>{})`), de 600 kB-delete
zei niets, en de `null` uit de compressie was een `console.warn`. Er was geen
enkele plek waar een speler kon zien dat zijn video niet was aangekomen.

Daar kwam bij: er was **geen retry**. Eén 4G-dip tussen twee kroegen en de
inzending was definitief weg.

---

## Wat er nu staat

Eén pipeline, gebruikt door alle drie de opnamepaden (challenge, Jorik-missie,
bruiloftsmissie). In `index.html` tussen de markers `MEDIA-PIPELINE-START` en
`MEDIA-PIPELINE-END`.

```
opname (File)
  → compressPhotoBlob   alleen foto's; bij ELKE fout gaat het origineel door
  → uploadMedia         ruwe Blob naar Storage, 4 pogingen, oplopende wachttijd
  → writeSubmissionRows rij met de URL erin
elke stap faalt → MediaQueue.add(Blob + rij) → flushMediaQueue probeert later
```

De regel die alles stuurt: **media wordt nooit weggegooid om een rij te redden.**
Een bestand komt in Storage terecht, óf het staat geparkeerd in IndexedDB tot dat
lukt — over herlaadbeurten, gecrashte tabbladen en dode hoeken heen.

Concreet veranderd:

| | Vóór | Nu |
|---|---|---|
| Video naar Storage | via base64 (×1.37 geheugen, tab-crash) | `File` direct als Blob |
| Jorik-missievideo | nooit naar Storage, altijd gedropt | zelfde pipeline als de rest |
| Foto > 500 kB | weggegooid | geüpload, tot 1600px / q0.82 |
| Compressie faalt | `null` → foto weg | origineel gaat door |
| Upload faalt | inzending weg | IndexedDB-wachtrij + automatische retry |
| Offline opname | geweigerd | bewaard, gaat later vanzelf door |
| Speler ziet | niets | 📤-chip met het aantal wachtende items |
| Tab sluiten met werk in de rij | stil verlies | waarschuwing |

Retry vindt plaats bij `online`, bij terugkeren naar de voorgrond, elke 45
seconden, en bij het opstarten van de app. De chip boven de tabbalk is aantikbaar
om meteen te flushen.

### Idempotentie

Een geparkeerde inzending wordt na een crash opnieuw aangeboden, dus de inserts
moeten dubbel-bestand zijn. Elke inzending krijgt een `client_id` met een UNIQUE
index (`SUPABASE-MEDIA-FIX-V57.sql`); een replay levert 23505 op en telt als
"stond er al". Draait de patch niet, dan valt de code terug op een insert zonder
die kolom, zodat een niet-gepatcht project blijft werken zoals het was.

---

## Wat je moet doen om dit live te krijgen

1. **`SUPABASE-MEDIA-FIX-V57.sql` draaien** in Supabase → SQL Editor.
   Voegt `client_id` toe aan `photo_reviews` en `activity_feed`, en zet de
   bucketlimiet omhoog. Veilig om meerdere keren te draaien.
2. **Controleer de echte bucketlimiet** in Storage → media → Configuration. Het
   gratis plan kan een lagere harde grens afdwingen dan wat de SQL vraagt.
3. **`index.html` en `sw.js` deployen.** De service-worker-cache is gebumpt naar
   `stadsspel-v57`, dus telefoons die het spel eerder openden halen de nieuwe
   versie op in plaats van de oude uit hun cache.
4. **Test vóór de speeldag één lange video** (minstens een minuut, 4K) op een
   echte iPhone, met vliegtuigmodus halverwege aan en weer uit. Dat is precies
   het scenario dat eerder stilletjes faalde.

---

## Testen

```bash
npm install          # alleen fake-indexeddb
npm test
```

`test/media-pipeline.test.mjs` knipt het pipelineblok uit `index.html` en draait
het in Node met stubs voor Supabase, IndexedDB en de browser. Dertien tests, elk
gekoppeld aan één van de oorzaken hierboven:

- video gaat 1:1 als Blob naar Storage (niet base64-opgeblazen)
- een foto die niet kleiner wordt, wordt alsnog geüpload
- `compressPhotoBlob` geeft nooit `null` terug, ook niet met een kapotte canvas
- mislukte upload → wachtrij → later alsnog geland
- offline opname wordt bewaard, niet geweigerd
- bestand boven de serverlimiet blijft bewaard
- rij faalt na een geslaagde upload → geen tweede upload bij de retry
- replay na crash geeft geen dubbele rij
- database zonder `client_id` blijft werken
- patch-modus vult de feedregel bij zodra de upload landt
- een blijvend falende upload blijft in de rij staan (met teller en reden)
- netwerkfout wordt opnieuw geprobeerd, een 413 niet
- extensie volgt het contentType, zodat `.mov` niet als foto eindigt

---

## Over het materiaal van 6 juni

Dit repareert de code, niet het verleden. Wat toen is gedropt, is nooit de server
op gegaan — er is server-side niets te herstellen. Eén lichtpunt: het dropte
altijd ná de opname, dus **de originelen staan nog gewoon in de camerarol van de
telefoons van de spelers.** Wil je de bruiloftsedit alsnog compleet krijgen, dan
is de groepsapp de plek, niet de database.

Wat wél op de server staat, haal je binnen met `archief/export-archief.py`. De
SQL-patch bevat twee controlequery's die tellen hoeveel inzendingen en feedregels
zonder media zijn blijven staan — dat is de omvang van wat er destijds is misgegaan.

---

## Die ene beperking is inmiddels ook gesloten

Bij een opname zonder verbinding werd de score lokaal opgeteld terwijl de
`increment_team_score`-RPC faalde; de telefoon liep dan voor op de server tot de
volgende sync het lokale getal overschreef. Dezelfde klasse fout, andere
schrijfactie. **V58 doet daar hetzelfde als V57 voor media** — zie
`SCORE-QUEUE-V58.md` en `SUPABASE-SCORE-QUEUE-V58.sql`. Het lastige deel daar was
exactly-once: een delta opnieuw versturen mag niet dubbel tellen.
