-- ════════════════════════════════════════════════════════════════════════════
-- SUPABASE-MEDIA-FIX-V57.sql
-- Hoort bij de V57 media-pipeline in index.html.
--
-- Waarom: op de speeldag (6 juni 2026) zijn veel foto's en video's niet
-- doorgekomen. De oorzaken zaten in de client (zie het commentaarblok boven
-- MEDIA-PIPELINE-START in index.html). De client parkeert een mislukte upload
-- nu in IndexedDB en probeert het later opnieuw — en dat opnieuw-proberen heeft
-- één ding uit de database nodig: een idempotentiesleutel, zodat een rij die na
-- een crash of herstart nog eens wordt aangeboden niet dubbel landt.
--
-- Veilig om meerdere keren te draaien. Raakt geen bestaande data aan.
-- Draaien via Supabase → SQL Editor. Rollback staat onderaan (uitgecommentarieerd).
-- ════════════════════════════════════════════════════════════════════════════

-- ── 1. client_id op photo_reviews ───────────────────────────────────────────
-- Door de client gegenereerde UUID per inzending. UNIQUE, zodat een replay
-- 23505 oplevert; de client leest dat als "stond er al" en haalt het item uit
-- de wachtrij in plaats van het eindeloos opnieuw te proberen.
ALTER TABLE photo_reviews ADD COLUMN IF NOT EXISTS client_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS photo_reviews_client_id_unique
  ON photo_reviews (client_id)
  WHERE client_id IS NOT NULL;

-- ── 2. client_id op activity_feed ───────────────────────────────────────────
-- Zelfde rol, plus: het Jorik-missiepad schrijft de feedregel meteen (zodat de
-- speler 'm direct ziet) en vult `photo` pas bij zodra de upload is geland.
-- Die UPDATE zoekt de rij op client_id, dus zonder deze kolom komt de video wel
-- in de bucket maar niet in de feed te staan.
ALTER TABLE activity_feed ADD COLUMN IF NOT EXISTS client_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS activity_feed_client_id_unique
  ON activity_feed (client_id)
  WHERE client_id IS NOT NULL;

-- ── 3. Media-bucket ─────────────────────────────────────────────────────────
-- Publiek (de app toont de URL's direct) en met een ruime bestandslimiet.
-- 50 MB is de standaard op het gratis plan; een iPhone-clip van een minuut in
-- 4K zit daar ruim boven. Zet 'm zo hoog als je plan toestaat — de client
-- bewaart een te groot bestand lokaal en uploadt het alsnog zodra deze limiet
-- omhoog gaat, maar hoe hoger hier, hoe minder er in de wachtrij blijft hangen.
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('media', 'media', true, 524288000)          -- 500 MB
ON CONFLICT (id) DO UPDATE
  SET public = true,
      file_size_limit = GREATEST(
        COALESCE(storage.buckets.file_size_limit, 0),
        524288000
      );

-- Let op: op het gratis plan kan Supabase een lagere harde limiet afdwingen dan
-- wat hier staat. Controleer na het draaien in Storage → media → Configuration
-- wat er daadwerkelijk staat, en test één lange video vóór de speeldag.

-- ── 4. RLS op de bucket ─────────────────────────────────────────────────────
-- Past bij de rest van het schema ("allow all" — het spel gebruikt geen auth).
-- LET OP: dit betekent dat iedereen met de anon key uit index.html media kan
-- lezen én schrijven. Prima voor een besloten speeldag, niet voor een site die
-- maanden later nog open staat. Zie ARCHIEF-EN-OFFLINE.md.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects'
      AND policyname = 'media_allow_all'
  ) THEN
    CREATE POLICY media_allow_all
      ON storage.objects FOR ALL
      USING (bucket_id = 'media')
      WITH CHECK (bucket_id = 'media');
  END IF;
END $$;

-- ── 5. Controles ────────────────────────────────────────────────────────────
SELECT 'photo_reviews.client_id' AS probe, column_name, data_type
  FROM information_schema.columns
 WHERE table_name = 'photo_reviews' AND column_name = 'client_id';

SELECT 'activity_feed.client_id' AS probe, column_name, data_type
  FROM information_schema.columns
 WHERE table_name = 'activity_feed' AND column_name = 'client_id';

SELECT 'bucket' AS probe, id, public, file_size_limit
  FROM storage.buckets WHERE id = 'media';

-- Hoeveel inzendingen misten media? Vóór V57 was dit de stille faalmodus:
-- de challenge stond als voltooid in de lijst, maar photo_url was leeg.
SELECT 'inzendingen zonder media' AS probe, COUNT(*) AS n
  FROM photo_reviews WHERE photo_url IS NULL;

SELECT 'feedregels zonder media' AS probe, COUNT(*) AS n
  FROM activity_feed
 WHERE photo IS NULL AND message ILIKE '%Jorik-missie%';

-- ── ROLLBACK (alleen uitvoeren als je terug moet) ───────────────────────────
-- DROP INDEX IF EXISTS photo_reviews_client_id_unique;
-- DROP INDEX IF EXISTS activity_feed_client_id_unique;
-- ALTER TABLE photo_reviews DROP COLUMN IF EXISTS client_id;
-- ALTER TABLE activity_feed DROP COLUMN IF EXISTS client_id;
-- DROP POLICY IF EXISTS media_allow_all ON storage.objects;
