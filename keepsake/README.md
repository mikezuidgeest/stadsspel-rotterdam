# Offline aandenken

Eén map die het Stadsspel bewaart zonder internet, zonder server en zonder dat er
nog iets draait. Dubbelklik `index.html` en het opent — nu, en over tien jaar.

## Waarom niet gewoon index.html bewaren

De speel-app haalt React, Babel, Leaflet en de Supabase-client van unpkg en
jsdelivr, de fonts van Google, en alle data live uit Supabase. Zet je `index.html`
op een USB-stick, dan opent er een leeg scherm. De keepsake heeft geen van die
afhankelijkheden: alle data zit als JSON in de pagina zelf, de media staan als
gewone bestanden ernaast, en de opmaak is één blok CSS in hetzelfde bestand.

## Bouwen

```bash
python3 archief/export-archief.py                # 1. data + media uit Supabase
python3 keepsake/build-keepsake.py               # 2. pakt de nieuwste export
```

Of expliciet:

```bash
python3 keepsake/build-keepsake.py \
  --export archief/export-20260919-142530 \
  --out ~/Dropbox/stadsspel-aandenken
```

Alleen Python 3 nodig, geen `pip install`.

## Resultaat

```
stadsspel-aandenken/
  index.html      alles in één bestand — data inline, want file:// blokkeert fetch
  media/          de foto's en video's als gewone bestanden
```

Drie tabbladen: **Eindstand** (met de kerncijfers van de dag), **Galerij** (alle
inzendingen, te filteren per team, tik voor groot met video-afspeler) en
**Tijdlijn** (de feed chronologisch, met thumbnails).

## Zonder echte export bekijken

```bash
python3 test/keepsake-fixture.py --out /tmp/demo-export
python3 keepsake/build-keepsake.py --export /tmp/demo-export --out /tmp/demo-keepsake
open /tmp/demo-keepsake/index.html
```

De fixture maakt vier teams, twintig inzendingen en een handvol echte
PNG-bestanden. Eén inzending zit er bewust zonder media in, om te laten zien hoe
de galerij dat toont.

## Inzendingen zonder media

Die krijgen een tegel met "media niet doorgekomen" in plaats van dat ze worden
weggelaten. Dat is een bewuste keuze: dit zijn de opdrachten die op de speeldag
zijn gesneuveld door de bugs die V57 repareert (zie `MEDIA-FIX-V57.md`), en het
is eerlijker om te laten zien dát er iets mist dan om het gat te verbergen. De
teller onderaan de pagina noemt het aantal.

## Aannames

- `manifest.json` uit de export koppelt de Supabase-URL's aan de lokale
  bestanden. Ontbreekt het manifest, dan vindt de builder de media niet en krijgt
  alles een lege tegel. Draai in dat geval de export opnieuw.
- Spectator-teams (de Game Master) blijven uit de eindstand.
- Video's spelen met de ingebouwde speler van de browser. Bestanden die de
  export als `.heic` heeft binnengehaald opent Safari en Preview wel, maar oudere
  Windows-machines niet — converteer die desnoods eenmalig naar JPEG.
