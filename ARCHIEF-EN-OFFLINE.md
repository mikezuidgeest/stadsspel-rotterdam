# Domein offline halen & repo-zichtbaarheid

**Opgesteld:** 19 september 2026
**Aanleiding:** `jorikhethaasje.nl` wordt opgezegd. Vraag: wat is de impact op het
spel, en moet de repo public blijven?
**Spel:** Jorik's Bachelor Party, 6 juni 2026 — het evenement is geweest, dit gaat
dus over het bewaren van de nasleep (foto's, video's, scores, verhaallijn).

---

## 1. Korte antwoord

**Het domein bevat niets.** `jorikhethaasje.nl` is puur een adres: het
`CNAME`-bestand in de repo-root wijst de naam naar GitHub Pages. Alle inhoud
staat op twee andere plekken — GitHub (de code) en Supabase (de data en de
media). Het domein opzeggen verliest op zichzelf geen enkel bestand.

**Het echte risico zit bij Supabase, niet bij het domein.** Daar staan de foto's,
video's, scores en de hele activity feed, en een gratis Supabase-project pauzeert
na inactiviteit en kan daarna worden opgeruimd. De laatste push was 5 juni, het
spel was 6 juni — het project staat vrijwel zeker al gepauzeerd. Dát is wat je
als eerste veilig moet stellen, los van welk besluit dan ook over het domein.

Daarvoor staat nu klaar: **`archief/export-archief.py`** — haalt alle tabellen én
alle media in één run binnen.

---

## 2. Waar staat wat

| Wat | Waar | Raakt het domein dit? |
|---|---|---|
| Code, alle versies (v4/v18/v19/v20, `index.html`) | git / GitHub | nee |
| `PROJECT-MEMORY.md`, audits, deploy-notities | git / GitHub | nee |
| Teams, scores, activity feed, voltooide challenges, foto-reviews | Supabase Postgres, project `kybcndicweuxjxkfzxud` | nee |
| Foto's & video's van de spelers | Supabase Storage, publieke bucket `media` — plus inline base64 in de rijen als de upload faalde (`index.html:1370-1420`) | nee |
| Het webadres waarop de app draait | DNS + `CNAME` → GitHub Pages | **ja** |

---

## 3. Wat er wél breekt als het domein weggaat

**a. De app is niet meer te openen op `https://jorikhethaasje.nl`.** Verwacht.

**b. De valkuil: ook de fallback-URL gaat mee.** Zolang `CNAME` in de repo staat,
stuurt GitHub Pages `https://mikezuidgeest.github.io/stadsspel-rotterdam/`
automatisch door naar het custom domain. Valt het domein weg en blijft `CNAME`
staan, dan is de app via **geen enkele** URL meer bereikbaar — ook niet via de
github.io-URL die in `DEPLOY-V20.md` als live-adres staat. Verwijder daarom
`CNAME` uit de repo én maak het custom-domainveld leeg in *Settings → Pages*.

**c. Dangling-domain overname.** Blijft `CNAME` staan nadat de registratie is
vrijgegeven, dan kan iemand die `jorikhethaasje.nl` later registreert die naam
op GitHub Pages claimen en er zijn eigen site onder hangen. Kost niets om te
voorkomen: `CNAME` weghalen is de hele fix.

**d. Telefoons met een service worker.** `sw.js` cachet de app per origin. Een
telefoon die het spel ooit op `jorikhethaasje.nl` heeft geopend blijft de
gecachete versie nog een tijd serveren, ook als DNS al dood is — die cache hangt
aan de oude origin en verhuist niet mee naar de github.io-URL. Leuk als
nasleep, maar niet iets om op te bouwen: browsers ruimen dit op eigen houtje op.

**e. Oude links.** Alles wat in de groepsapp, uitnodigingen of QR-codes naar het
domein wijst, wordt een dood adres.

---

## 4. Repo public of private?

Public is **niet** nodig, met één koppeling die je moet kennen:

> **GitHub Pages op een private repo vereist een betaald plan** (Pro / Team /
> Enterprise). Op een gratis account betekent repo private zetten: site offline.

Dat is geen probleem als je de site toch uitzet — dan valt het samen. Wil je de
github.io-URL als aandenken online houden, dan moet de repo public blijven (of je
neemt Pro).

Los daarvan pleit de inhoud vóór private. De repo bevat nu in platte tekst:

- `index.html:913` — admin-login: e-mailadres + wachtwoord `vriendvanjorik`
- `index.html:1841` — admin-unlock via `?admin=vriendvanjorik`
- `index.html:748` — de Supabase anon key

Met RLS "allow all" op alle tabellen (`SUPABASE-CATCHUP-PATCH-V32.sql:107-111`)
geeft die anon key lees- én schrijfrechten op alles, en de media-bucket is
publiek. Foto's van de gasten zijn daarmee publiek benaderbaar.

**Private zetten repareert dat niet.** Zolang de site live staat, serveert
`index.html` diezelfde key aan iedere bezoeker, en de git-historie houdt hem
sowieso vast. Private helpt alleen tegen toevallig vinden via GitHub-search —
nuttig, maar niet de oplossing. De oplossing is het Supabase-project stoppen of
verwijderen zodra de export binnen is.

**Advies:** repo op private, na de export. Het is een privé-feestje met foto's
van herkenbare mensen; er is geen reden om dat publiek te laten staan. Verlies
je Pages daarmee en wil je dat niet, zet Pages dan expliciet uit en laat de repo
public — maar doe dan in elk geval het Supabase-deel.

---

## 5. Volgorde (zo gaat er niets verloren)

1. **Supabase wakker maken.** app.supabase.com → project `kybcndicweuxjxkfzxud` →
   *Resume* als het gepauzeerd is. Zonder dit levert de export niets op.
2. **Exporteren:**
   ```bash
   python3 archief/export-archief.py
   ```
   Draait op kale Python 3, geen installatie nodig. Doelmap kiezen kan met
   `--out ~/Dropbox/stadsspel-archief`.
3. **Controleer `manifest.json`** in de exportmap: `rijen_per_tabel` en
   `media_totaal` moeten kloppen met wat je verwacht, en `fouten` hoort leeg te
   zijn. Open een paar bestanden uit `media/` om te zien dat het echte foto's
   zijn.
4. **Zet de exportmap ergens buiten GitHub en Supabase** — Drive, Dropbox,
   externe schijf. Maak ook een zip of kloon van de repo zelf, zodat de code en
   `PROJECT-MEMORY.md` niet alleen op GitHub leven.
5. **Pas nu:** domein opzeggen.
6. **`CNAME` verwijderen** uit de repo + custom domain leegmaken in
   *Settings → Pages* (punt 3b en 3c hierboven).
7. **Repo op private** — daarmee gaat Pages op een gratis account uit.
8. **Supabase-project verwijderen of gepauzeerd laten**, zodra je zeker weet dat
   de export compleet is.
9. Gebruik het wachtwoord `vriendvanjorik` nergens anders meer.

---

## 6. Wat de export precies bewaart

`archief/export-archief.py` schrijft naar `archief/export-<datum-tijd>/`:

```
tabellen/  teams, team_members, game_state, activity_feed,
           completed_challenges, photo_reviews, feed_reactions,
           challenge_first_finder  — elk als .json (volledig) + .csv (leesbaar)
media/     alle foto's en video's als echte .jpg/.mp4/.mov-bestanden
manifest.json  aantallen, herkomst per bestand, en eventuele fouten
```

Twee dingen die het bewust dubbel doet:

- **Media uit twee bronnen.** De app schrijft media als Storage-URL, maar valt
  terug op inline base64 in de rij als de upload faalde (`index.html:1370-1420`).
  Het script pakt beide uit, dus ook de foto's die nooit in de bucket zijn beland.
- **Bucket én tabellen.** Naast de URL's die in de rijen voorkomen, probeert het
  de bucket zelf uit te lezen. Dat vangt weesbestanden van inzendingen die later
  zijn verwijderd. Lukt die listing niet, dan zegt het dat en gaat het door op de
  URL's uit de tabellen.

---

## 7. Optioneel: een offline keepsake

De app draait nu op externe CDN's (unpkg, jsdelivr, Google Fonts) en op een live
Supabase. Ook met de export in handen is `index.html` op een USB-stick dus niet
speelbaar. Wil je een versie die over vijf jaar nog opent — één map, dubbelklik,
eindstand en fotogalerij erin gebakken, zonder internet — dan is dat een losse
klus: libraries meeleveren en de geëxporteerde data in de pagina bakken. Zeg het
als je dat wilt, dan bouw ik die.

---

## 8. Niet geverifieerd

Deze sessie kon het internet niet op (egress geblokkeerd), dus of
`jorikhethaasje.nl`, de github.io-URL en het Supabase-project op dit moment nog
reageren, is niet gecontroleerd. Alles hierboven komt uit de repo-configuratie
(`CNAME`, `sw.js`, `index.html`, de SQL-patches) en uit de GitHub API, die de
repo als **public** met **Pages ingeschakeld** rapporteert, laatste push
5 juni 2026. Het vermoeden dat Supabase al gepauzeerd staat is een gevolgtrekking
uit die datum — stap 1 hierboven maakt dat vanzelf duidelijk.
