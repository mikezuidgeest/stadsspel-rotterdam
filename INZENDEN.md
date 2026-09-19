# Materiaal terughalen van de telefoons

## Waarom dit nodig is

De export is compleet ten opzichte van Supabase. Hij kan niet compleet zijn ten
opzichte van 6 juni. Daar zitten drie lagen tussen:

| laag | waar |
|---|---|
| wat in de media-bucket staat | dat levert `archief/export-*` op |
| wat het spel registreerde als gedaan | `completed_challenges` + `activity_feed` |
| wat er die dag werkelijk is gemaakt | alleen nog op de telefoons |

De sprong van de eerste naar de tweede laag is te meten (`SUPABASE-DIAGNOSE.sql`,
vraag 2). De sprong naar de derde niet: wat de app op de telefoon heeft
weggegooid vóór het verzenden, heeft de server nooit gezien. Er is geen kopie,
geen prullenbak, geen versiegeschiedenis.

En de tweede laag is zelf ook incompleet — vóór V58 verdween bij een dode hoek
ook de `completed_challenges`-rij, dus zelfs "wat het spel registreerde" is een
ondergrens van wat er is gedaan.

**De originelen staan nog wel in de camerarollen.** Dat is de enige echte
herstelroute, en `inzenden.html` maakt die begaanbaar.

## Wat `inzenden.html` is

Een losse pagina, geen onderdeel van het spel. Iemand opent 'm, kiest zijn team
en naam, selecteert alles uit zijn fotoalbum van die middag, en klikt versturen.
Het materiaal gaat rechtstreeks naar dezelfde media-bucket en krijgt een rij in
`photo_reviews` met `location_id = -3`.

Dat sentinel is met opzet gekozen: `-1` is de bruiloftsmissie, `-2` zijn de
Jorik-missies, dus `-3` was vrij. Gevolg: nagestuurd materiaal komt vanzelf mee
in `archief/export-*` en verschijnt in de keepsake, zonder dat daar iets voor
aangepast hoeft te worden.

De pagina draait op de lessen van V57 en V59:

- het bestand gaat **als Blob** naar Storage, niet via base64 — dat was precies
  de fout die op de speeldag hele video's kostte;
- de extensie komt uit de **eerste 16 bytes**, niet uit de bestandsnaam. Een clip
  die via WhatsApp of AirDrop is gelopen heet soms `IMG_4821` zonder extensie en
  meldt zich als `application/octet-stream`; die wordt nu alsnog correct als
  video opgeslagen én als video weggeschreven in de tabel;
- vier pogingen met oplopende wachttijd, en een bestand dat de server weigert
  (413) wordt niet eindeloos herhaald maar eerlijk gemeld;
- niets wordt stil als geslaagd afgevinkt. Mislukt er iets, dan blijft het in de
  lijst staan met de reden erbij en één knop om het opnieuw te proberen;
- een waarschuwing als iemand het tabblad sluit terwijl er nog werk openstaat.

## Hoe je het inzet

1. **Deploy `inzenden.html`** samen met de rest naar GitHub Pages. De link wordt
   dan `https://jorikhethaasje.nl/inzenden.html` (of de github.io-variant).
2. **Zet dat in de groepsapp**, met deze vraag erbij:

   > Er is een fout geweest in de app waardoor een deel van de foto's en video's
   > van 6 juni nooit is aangekomen — vooral video's. Wil je in je fotoalbum
   > kijken bij **6 juni 2026, tussen 14:00 en 19:30**, en alles van die middag
   > hier uploaden? Dubbel is geen probleem, ontbreken wel.
   >
   > <link>

   De datum-en-tijdvraag werkt beter dan vragen naar specifieke opdrachten:
   iedereen kan in zijn fotoalbum op datum filteren, en niemand hoeft zich te
   herinneren welke missie waar was.
3. **Draai de export opnieuw** als het materiaal binnen is
   (`archief/export-in-browser.html`), en daarna de keepsake. Het nagestuurde
   materiaal zit er dan gewoon bij.

## Volgorde ten opzichte van het domein

Dit moet **vóór** je `jorikhethaasje.nl` opzegt. Zodra die naam niet meer
resolvet is de link dood, en dan moet je iedereen opnieuw benaderen met een
github.io-adres. Zie `ARCHIEF-EN-OFFLINE.md`: de volgorde daar wordt dus eerst
inzamelen, dan exporteren, dan pas het domein en de repo opruimen.

## Let op

- **De bucketlimiet is óók door je abonnement begrensd.** `SUPABASE-SETUP.sql`
  zet `storage.buckets.file_size_limit` op 500 MB, maar Supabase hanteert
  daarnaast een harde maximale uploadgrootte per plan — op het gratis plan
  doorgaans 50 MB. De effectieve grens is de laagste van die twee, en wat in
  *Storage → media → Configuration* staat is wat geldt. Een SQL-regel kan een
  planlimiet niet omzeilen; daarvoor moet je upgraden.

  De pagina houdt daar rekening mee: bestanden boven `MAX_MB` (bovenin het
  bestand, standaard 50) worden bij het kiezen al gemarkeerd, met het advies om
  ze los via WeTransfer of AirDrop te sturen. Ga je naar een hoger plan, zet dan
  dat getal mee omhoog.
- **De pagina schrijft met de publieke anon-key**, net als het spel zelf. Zolang
  de link in de groepsapp staat kan in principe iedereen met die link uploaden.
  Voor een besloten feest is dat prima; haal de pagina weg als je klaar bent met
  inzamelen.
- **Het spel zelf hoeft hier niet voor te draaien.** `inzenden.html` staat volledig
  los van `index.html`.
