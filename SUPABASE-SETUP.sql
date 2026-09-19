-- ════════════════════════════════════════════════════════════════════════════
-- SUPABASE-SETUP.sql — V57 + V58 in één keer
--
-- Dit bestand bundelt SUPABASE-MEDIA-FIX-V57.sql en SUPABASE-SCORE-QUEUE-V58.sql
-- zodat het één plak-actie is in plaats van twee.
--
-- HOE:
--   1. Open https://supabase.com/dashboard  →  project kybcndicweuxjxkfzxud
--      (staat hij op pauze? Klik eerst "Resume project" en wacht tot hij groen is)
--   2. Linkermenu → SQL Editor → New query
--   3. Plak dit hele bestand, klik RUN
--   4. Onderaan verschijnt een checklist. Alles moet "OK" zeggen.
--
-- Veilig om meerdere keren te draaien. Raakt geen bestaande data aan.
-- De losse bestanden blijven bestaan met de volledige uitleg erbij.
-- ════════════════════════════════════════════════════════════════════════════


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ DEEL A — V57: media-pipeline                                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- De client parkeert een mislukte upload in IndexedDB en probeert het later
-- opnieuw. Dat opnieuw-proberen heeft één ding uit de database nodig: een
-- idempotentiesleutel, zodat een rij die na een crash nog eens wordt aangeboden
-- niet dubbel landt.

ALTER TABLE photo_reviews ADD COLUMN IF NOT EXISTS client_id TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS photo_reviews_client_id_unique
  ON photo_reviews (client_id) WHERE client_id IS NOT NULL;

ALTER TABLE activity_feed ADD COLUMN IF NOT EXISTS client_id TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS activity_feed_client_id_unique
  ON activity_feed (client_id) WHERE client_id IS NOT NULL;

-- Media-bucket: publiek, met een ruime bestandslimiet. Een iPhone-clip van een
-- minuut in 4K gaat ruim over de standaard 50 MB heen.
-- Het storage-schema bestaat alleen in een echt Supabase-project; in een kale
-- Postgres (bv. een lokale test) slaan we dit blok over.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
              WHERE table_schema = 'storage' AND table_name = 'buckets') THEN

    INSERT INTO storage.buckets (id, name, public, file_size_limit)
    VALUES ('media', 'media', true, 524288000)                    -- 500 MB
    ON CONFLICT (id) DO UPDATE
      SET public = true,
          file_size_limit = GREATEST(COALESCE(storage.buckets.file_size_limit, 0), 524288000);

    IF NOT EXISTS (SELECT 1 FROM pg_policies
                    WHERE schemaname = 'storage' AND tablename = 'objects'
                      AND policyname = 'media_allow_all') THEN
      CREATE POLICY media_allow_all ON storage.objects FOR ALL
        USING (bucket_id = 'media') WITH CHECK (bucket_id = 'media');
    END IF;

  END IF;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ DEEL B — V58: schrijfwachtrij voor punten                                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- increment_team_score is niet idempotent, dus een wachtrij die 'm opnieuw
-- afvuurt zou punten verzinnen. Deze variant neemt een client-sleutel: de
-- eerste keer telt de delta, elke herhaling geeft alleen de stand terug.

CREATE TABLE IF NOT EXISTS score_deltas (
  client_id   TEXT PRIMARY KEY,
  team_id     INTEGER NOT NULL,
  delta       INTEGER NOT NULL,
  applied_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS score_deltas_team_idx ON score_deltas (team_id, applied_at);

ALTER TABLE score_deltas ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
                  WHERE tablename = 'score_deltas' AND policyname = 'score_deltas_allow_all') THEN
    CREATE POLICY score_deltas_allow_all ON score_deltas FOR ALL
      USING (true) WITH CHECK (true);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION increment_team_score_idem(
  p_team_id   INTEGER,
  p_delta     INTEGER,
  p_client_id TEXT
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rows  INTEGER := 0;
  v_score INTEGER;
BEGIN
  IF p_client_id IS NULL OR length(p_client_id) = 0 THEN
    RAISE EXCEPTION 'client_id is verplicht voor een idempotente score-delta';
  END IF;

  -- Deze INSERT is de poort: slaagt hij, dan is dit de eerste keer.
  INSERT INTO score_deltas (client_id, team_id, delta)
  VALUES (p_client_id, p_team_id, p_delta)
  ON CONFLICT (client_id) DO NOTHING;

  GET DIAGNOSTICS v_rows = ROW_COUNT;

  IF v_rows > 0 THEN
    UPDATE teams SET score = GREATEST(0, COALESCE(score, 0) + p_delta)
     WHERE id = p_team_id
    RETURNING score INTO v_score;
  ELSE
    SELECT score INTO v_score FROM teams WHERE id = p_team_id;
  END IF;

  RETURN COALESCE(v_score, 0);
END $$;

DO $$
DECLARE r TEXT;
BEGIN
  FOREACH r IN ARRAY ARRAY['anon','authenticated'] LOOP
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
      EXECUTE format(
        'GRANT EXECUTE ON FUNCTION increment_team_score_idem(INTEGER, INTEGER, TEXT) TO %I', r);
    END IF;
  END LOOP;
END $$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ DEEL C — Controle                                                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Alles hieronder hoort "OK" te zeggen. Staat er ergens ONTBREEKT, dan is dat
-- deel niet aangekomen — scroll omhoog in de output voor de foutmelding.

SELECT * FROM (
  SELECT 1 AS n, 'photo_reviews.client_id' AS onderdeel,
         CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_name='photo_reviews' AND column_name='client_id')
              THEN 'OK' ELSE 'ONTBREEKT' END AS status
  UNION ALL SELECT 2, 'activity_feed.client_id',
         CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns
                            WHERE table_name='activity_feed' AND column_name='client_id')
              THEN 'OK' ELSE 'ONTBREEKT' END
  UNION ALL SELECT 3, 'unieke index photo_reviews',
         CASE WHEN EXISTS (SELECT 1 FROM pg_indexes
                            WHERE indexname='photo_reviews_client_id_unique')
              THEN 'OK' ELSE 'ONTBREEKT' END
  UNION ALL SELECT 4, 'unieke index activity_feed',
         CASE WHEN EXISTS (SELECT 1 FROM pg_indexes
                            WHERE indexname='activity_feed_client_id_unique')
              THEN 'OK' ELSE 'ONTBREEKT' END
  UNION ALL SELECT 5, 'tabel score_deltas',
         CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables
                            WHERE table_name='score_deltas')
              THEN 'OK' ELSE 'ONTBREEKT' END
  UNION ALL SELECT 6, 'functie increment_team_score_idem',
         CASE WHEN EXISTS (SELECT 1 FROM pg_proc
                            WHERE proname='increment_team_score_idem')
              THEN 'OK' ELSE 'ONTBREEKT' END
  UNION ALL SELECT 7, 'media-bucket publiek',
         COALESCE((SELECT CASE WHEN public THEN 'OK' ELSE 'NIET PUBLIEK' END
                     FROM storage.buckets WHERE id='media'), 'ONTBREEKT')
  UNION ALL SELECT 8, 'media-bucket limiet (MB)',
         COALESCE((SELECT (file_size_limit/1048576)::TEXT || ' MB'
                     FROM storage.buckets WHERE id='media'), 'ONTBREEKT')
) t ORDER BY n;

-- Ruwe indicatie van wat er destijds is misgegaan. LET OP: dit is met opzet
-- grofmazig en telt te weinig — het mist de "Jorik ruil"-regels, en een
-- inzending die het tabblad heeft gesloopt kreeg helemaal geen rij en is hier
-- dus onzichtbaar. Draai SUPABASE-DIAGNOSE.sql voor het echte beeld.
SELECT 'inzendingen zonder media' AS meting, COUNT(*) AS aantal FROM photo_reviews WHERE photo_url IS NULL
UNION ALL
SELECT 'Jorik-feedregels zonder media (ondergrens)', COUNT(*) FROM activity_feed
 WHERE photo IS NULL AND message ILIKE '%Jorik-missie%';


-- ════════════════════════════════════════════════════════════════════════════
-- NA HET DRAAIEN
--
--   1. Storage → media → Configuration: controleer de ECHTE bestandslimiet.
--      Het gratis plan kan een lagere harde grens afdwingen dan de 500 MB
--      hierboven. Wat daar staat, is wat geldt.
--   2. Deploy index.html + sw.js (branch claude/serene-feynman-4ni9cc).
--   3. Test vóór een volgende speeldag één lange 4K-video op een echte iPhone,
--      met vliegtuigmodus halverwege aan en weer uit. Dat is precies het
--      scenario dat eerder stil faalde.
--
-- ROLLBACK (alleen als je terug moet):
--   DROP FUNCTION IF EXISTS increment_team_score_idem(INTEGER, INTEGER, TEXT);
--   DROP TABLE IF EXISTS score_deltas;
--   DROP INDEX IF EXISTS photo_reviews_client_id_unique;
--   DROP INDEX IF EXISTS activity_feed_client_id_unique;
--   ALTER TABLE photo_reviews DROP COLUMN IF EXISTS client_id;
--   ALTER TABLE activity_feed DROP COLUMN IF EXISTS client_id;
--   DROP POLICY IF EXISTS media_allow_all ON storage.objects;
-- ════════════════════════════════════════════════════════════════════════════
