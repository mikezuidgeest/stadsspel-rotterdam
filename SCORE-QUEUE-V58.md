# V58 — punten en voltooiingen overleven een dode hoek

**Vervolg op** `MEDIA-FIX-V57.md`. Dat document beschrijft de bekende beperking
die hier wordt gesloten:

> Bij een opname zonder verbinding wordt de score lokaal opgeteld terwijl de
> `increment_team_score`-RPC faalt; de telefoon loopt dan voor op de server tot
> de volgende geslaagde sync.

---

## Het probleem

Dezelfde klasse fout als het media-verlies: **lokaal geslaagd, server weet van
niets, niemand die het ziet.** Twee schrijfacties waren fire-and-forget:

```js
sb.rpc('increment_team_score',{...}).then(...)           // punten
sb.from('completed_challenges').insert({...}).then(...)  // voltooiing
```

Bij een 4G-dip tussen twee kroegen telde de telefoon de punten lokaal op, faalde
de RPC, en liep dat toestel vanaf dat moment vóór op de server — tot de
eerstvolgende realtime-sync het lokale getal overschreef en de punten stilletjes
verdwenen. De opdracht stond intussen wél met een vinkje op het scherm.

Voor `completed_challenges` gold hetzelfde: de server leerde nooit dat de
opdracht gedaan was, terwijl de speler 'm als voltooid zag staan.

## Waarom dit lastiger was dan media

Een mislukte upload opnieuw proberen is gratis — dezelfde bytes nog eens
versturen levert hetzelfde bestand op. Een score-delta niet: `increment_team_score`
is niet idempotent, dus twee keer afvuren telt twee keer. Een naïeve wachtrij zou
punten gaan verzinnen, wat erger is dan punten verliezen.

Daarom krijgt elke delta een door de client gegenereerde sleutel, en gaat hij via
`increment_team_score_idem` (`SUPABASE-SCORE-QUEUE-V58.sql`):

```sql
INSERT INTO score_deltas (client_id, team_id, delta)
VALUES (p_client_id, p_team_id, p_delta)
ON CONFLICT (client_id) DO NOTHING;

GET DIAGNOSTICS v_rows = ROW_COUNT;
IF v_rows > 0 THEN  -- eerste keer: tel mee
ELSE                -- replay: geef alleen de stand terug
```

De INSERT is de poort. Eén transactie, exactly-once, ook als de telefoon crasht
tussen versturen en antwoord — het klassieke geval waarin de server de delta wél
heeft verwerkt maar de client het antwoord nooit zag.

Wordt de patch niet gedraaid, dan merkt de app dat de functie ontbreekt en valt
hij terug op de oude RPC — maar probeert die dan bewust maar **één** keer. Liever
een delta die een keer mist dan een die dubbel telt.

## Wat er nu gebeurt

| | Vóór | Nu |
|---|---|---|
| Score-RPC faalt | lokaal +punten, server niets, stil verloren bij de volgende sync | in de wachtrij, exactly-once opnieuw |
| `completed_challenges` faalt | server weet niet dat de opdracht gedaan is | in de wachtrij (was al idempotent via de unique constraint) |
| Score landt later | lokale stand blijft op het optimistische getal | reconciler trekt bij naar de serverstand |
| Volgorde | n.v.t. | punten landen in de volgorde waarin ze zijn verdiend |
| Speler ziet | niets | de 📤-chip noemt nu ook wachtende punt-updates |

Opnieuw proberen gebeurt bij `online`, bij terugkeer naar de voorgrond, elke 30
seconden en bij het opstarten. Faalt een item op een netwerkfout, dan stopt de
ronde daar: één dode verbinding betekent dat de rest ook faalt, en zo blijft de
volgorde intact zonder de batterij leeg te trekken.

## Bewust NIET in de wachtrij

**`challenge_first_finder`.** Dat is een race — wie het eerst is, wint. Een insert
die twintig minuten later alsnog uit een dode hoek komt, zou "eerste" toekennen
aan een team dat dat niet was. Daar hoort de bestaande ene-retry-na-600ms bij,
niet oneindig opnieuw proberen.

**De inhaalbonus en de meeste-opdrachten-bonus.** Beide draaien op één toestel
direct na een geslaagde `SELECT` (dus aantoonbaar online) en worden server-side
gegate tegen dubbel uitbetalen. Ze in de wachtrij zetten zou die gate omzeilen.

**De Jorik-claim** blijft OPEN falen zoals in V56: een dode hoek mag Jorik zijn
punten niet kosten. Nieuw is dat de claim daarna wél in de wachtrij blijft staan,
zodat de server het alsnog registreert in plaats van er nooit van te horen.

## Wat je moet doen

1. **`SUPABASE-SCORE-QUEUE-V58.sql` draaien** in Supabase → SQL Editor. Maakt
   `score_deltas` + `increment_team_score_idem`. Veilig om meerdere keren te
   draaien.
2. **`index.html` deployen.** De service-worker-cache staat al op `stadsspel-v57`;
   bump hem opnieuw als je tussendoor niet hebt gedeployed.

De patch raakt geen bestaande data en `increment_team_score` blijft gewoon staan,
dus terugrollen naar de vorige `index.html` werkt zonder de SQL terug te draaien.

## Testen

```bash
npm test
```

`test/write-queue.test.mjs` (14 tests) knipt de wachtrij uit `index.html` en
draait 'm tegen een Supabase-stub die de SQL-semantiek nabootst:

- delta landt direct en trekt de lokale stand bij
- mislukte delta → wachtrij → later alsnog geland
- dezelfde delta drie keer versturen telt één keer
- crash tussen versturen en antwoord telt niet dubbel
- zonder de idempotente RPC: één keer legacy, daarna stoppen
- offline delta wordt bewaard zonder te proberen
- duplicaat-insert (23505) en geheimhoudingstrigger (23514) blijven niet hangen
- netwerkfout bij een insert → wachtrij → later geschreven
- de wachtrij landt in de volgorde waarin de punten zijn verdiend
- een dode verbinding stopt de ronde in plaats van de rij af te branden

**De SQL is apart tegen een echte PostgreSQL 16 gedraaid**, niet alleen tegen een
stub: drie pogingen met dezelfde sleutel geven 125 / 125 / 125, een nieuwe sleutel
telt door, strafpunten klemmen op 0, vijf parallelle replays van één sleutel
leveren één rij en één optelling op, en de patch loopt twee keer achter elkaar
schoon door.

De app is daarnaast in Chromium opgestart met een gestubde Supabase: hij rendert
zonder fouten en maakt de IndexedDB-database aan op versie 2 met beide stores
(`pending` voor media, `writes` voor punten).
