-- ════════════════════════════════════════════════════════════════════════════
-- SUPABASE-DIAGNOSE.sql — hoeveel is er op 6 juni echt misgegaan?
--
-- Leest alleen, schrijft niets. Plakken in Supabase → SQL Editor → RUN.
--
-- WAAROM DIT BESTAAT: de controletelling onderaan SUPABASE-SETUP.sql was te
-- krap. Die telde `activity_feed` op ILIKE '%Jorik-missie%', maar het
-- Jorik-missiepad schrijft TWEE soorten regels die media dragen:
--
--   index.html:3624  "🎭 Jorik-missie: <titel> · +N pts"        ← werd geteld
--   index.html:3590  "🎭 Jorik ruil 2/4 · <titel> · +N pts"     ← werd NIET geteld
--   index.html:3593  "🏁 Jorik voltooide de hele dag-mission"   ← draagt nooit media
--
-- De ruil-regels van doorlopende missies vielen dus buiten de telling. Het
-- werkelijke aantal gedropte Jorik-clips ligt hoger dan wat die query liet zien.
--
-- En belangrijker: "0 inzendingen zonder media" betekent NIET dat er niets
-- verloren is. Bij bug 3 (de base64-omzetting die het tabblad sloopte) en bij
-- een mislukte insert werd er helemaal GEEN rij geschreven. Die verliezen zijn
-- onzichtbaar in een telling over photo_reviews — je ziet ze alleen door
-- completed_challenges ernaast te leggen. Dat doet vraag 2 hieronder.
-- ════════════════════════════════════════════════════════════════════════════


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 1. Jorik-missies — de regels die bug 1 leegroofde                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Elke rij hier met media_kwijt > 0 is een clip die op de telefoon is gemaakt
-- en die `delete shareable.photo` eraf heeft gehaald vóór de insert.

SELECT
  CASE
    WHEN message LIKE '%Jorik-missie:%' THEN 'Jorik-missie (eenmalig)'
    WHEN message LIKE '%Jorik ruil %'   THEN 'Jorik ruil (doorlopend)'
  END                                                   AS soort,
  COUNT(*)                                              AS regels,
  COUNT(*) FILTER (WHERE photo IS NOT NULL)             AS media_bewaard,
  COUNT(*) FILTER (WHERE photo IS NULL)                 AS media_kwijt
FROM activity_feed
WHERE message LIKE '%Jorik-missie:%' OR message LIKE '%Jorik ruil %'
GROUP BY 1
ORDER BY 1;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 2. De onzichtbare verliezen — voltooid, maar nooit ingeleverd            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Een foto- of video-opdracht die in completed_challenges staat hoort een rij
-- in photo_reviews te hebben. Ontbreekt die, dan is de inzending nooit bij de
-- server aangekomen terwijl het scherm een vinkje toonde. Dit is de
-- vingerafdruk van bug 3 en van elke afgebroken insert.

WITH gedaan AS (
  SELECT
    cc.team_id,
    split_part(cc.challenge_id, '_', 1)::INT AS location_id,
    split_part(cc.challenge_id, '_', 2)::INT AS challenge_idx,
    cc.challenge_type,
    cc.challenge_id
  FROM completed_challenges cc
  WHERE cc.challenge_type IN ('photo', 'video')
    -- alleen echte POI-opdrachten: jorik_* en de -1_0 bruiloftsbonus hebben
    -- een ander sleutelformaat en horen hier niet bij
    AND cc.challenge_id ~ '^[0-9]+_[0-9]+$'
)
SELECT
  g.challenge_type                                        AS soort,
  COUNT(*)                                                AS voltooid,
  COUNT(pr.id)                                            AS met_inzending,
  COUNT(*) - COUNT(pr.id)                                 AS zonder_inzending
FROM gedaan g
LEFT JOIN photo_reviews pr
       ON pr.team_id       = g.team_id
      AND pr.location_id   = g.location_id
      AND pr.challenge_idx = g.challenge_idx
GROUP BY 1
ORDER BY 1;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 3. Foto's versus video's — raakte bug 3 vooral video?                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Bug 3 sloeg toe naarmate het bestand groter was, dus video hoort
-- ondervertegenwoordigd te zijn ten opzichte van wat er is voltooid.

SELECT 'voltooid volgens completed_challenges' AS bron, challenge_type AS soort, COUNT(*) AS aantal
  FROM completed_challenges
 WHERE challenge_type IN ('photo','video')
 GROUP BY 1,2
UNION ALL
SELECT 'daadwerkelijk ingeleverd', challenge_type, COUNT(*)
  FROM photo_reviews
 WHERE challenge_type IN ('photo','video')
   -- location_id -1 is de bruiloftsmissie; die staat in completed_challenges
   -- als 'wedding-bonus' en telt daar niet mee, dus hier ook niet — anders
   -- vergelijk je twee verschillende dingen.
   AND location_id <> -1
 GROUP BY 1,2
ORDER BY soort, bron;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 4. De hele feed — hoeveel scoreregels misten hun plaatje                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

SELECT
  COUNT(*)                                            AS feedregels_met_punten,
  COUNT(*) FILTER (WHERE photo IS NOT NULL)           AS met_media,
  COUNT(*) FILTER (WHERE photo LIKE 'data:%')         AS nog_inline_base64,
  COUNT(*) FILTER (WHERE photo LIKE 'http%')          AS via_storage
FROM activity_feed
WHERE points > 0;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ 5. Wat staat er nog wél — dit haalt de export op                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

SELECT 'inzendingen met media'  AS onderdeel, COUNT(*) AS aantal FROM photo_reviews WHERE photo_url IS NOT NULL
-- LET OP de extensielijst: de uploadcode van 6 juni kapte het mime-type af op
-- 8 tekens, dus elke iPhone-video kreeg ".quicktim". Zonder die term hierin telt
-- je videomateriaal als foto's mee.
UNION ALL SELECT 'waarvan video', COUNT(*) FROM photo_reviews
  WHERE photo_url ~* '\.(mp4|m4v|mov|qt|webm|ogv|quicktim\w*|xm4v|3gpp?)($|[?#])'
UNION ALL SELECT '  waarvan met een onbruikbare naam (.quicktim e.d.)', COUNT(*) FROM photo_reviews
  WHERE photo_url ~* '\.(quicktim\w*|xm4v|3gpp)($|[?#])'
UNION ALL SELECT 'feedregels met media', COUNT(*) FROM activity_feed WHERE photo IS NOT NULL
UNION ALL SELECT 'bruiloftstakes (location_id -1)', COUNT(*) FROM photo_reviews WHERE location_id = -1;


-- ════════════════════════════════════════════════════════════════════════════
-- HOE JE DIT LEEST
--
--   Vraag 1, kolom media_kwijt   → clips die bug 1 heeft weggegooid.
--   Vraag 2, zonder_inzending    → opdrachten die als voltooid op het scherm
--                                  stonden maar de server nooit hebben bereikt.
--                                  Dit is wat je in geen enkele telling over
--                                  photo_reviews terugziet.
--   Vraag 3                      → staat "voltooid" ver boven "ingeleverd" bij
--                                  video, dan was bug 3 de hoofdoorzaak.
--
-- Alles wat hier als kwijt naar voren komt, is de server nooit op gegaan en valt
-- daar dus ook niet te herstellen. De originelen staan nog wel in de camerarol
-- van de spelers — zie MEDIA-FIX-V57.md.
-- ════════════════════════════════════════════════════════════════════════════
