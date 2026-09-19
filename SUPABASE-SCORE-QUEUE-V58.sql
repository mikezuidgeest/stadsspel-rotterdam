-- ════════════════════════════════════════════════════════════════════════════
-- SUPABASE-SCORE-QUEUE-V58.sql
-- Hoort bij de V58 schrijfwachtrij in index.html.
--
-- Waarom: V57 maakte media onverliesbaar door een mislukte upload lokaal te
-- parkeren en later opnieuw te proberen. Voor punten kon dat niet zomaar —
-- `increment_team_score` is niet idempotent, dus twee keer versturen telt twee
-- keer. Deze patch geeft de client een variant met een idempotentiesleutel:
-- de eerste keer telt de delta, elke herhaling geeft alleen de stand terug.
--
-- Zonder deze patch blijft de app werken: hij merkt dat de functie ontbreekt en
-- valt terug op de oude RPC, maar probeert die dan bewust maar één keer — liever
-- een delta die een keer mist dan een die dubbel telt.
--
-- Veilig om meerdere keren te draaien. Draaien via Supabase → SQL Editor.
-- Rollback staat onderaan (uitgecommentarieerd).
-- ════════════════════════════════════════════════════════════════════════════

-- ── 1. Logboek van toegepaste delta's ───────────────────────────────────────
-- client_id is de primaire sleutel: dát maakt het exactly-once. De telefoon
-- genereert hem vóór het eerste versturen en hergebruikt hem bij elke poging,
-- ook na een crash of herstart.
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
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'score_deltas' AND policyname = 'score_deltas_allow_all'
  ) THEN
    CREATE POLICY score_deltas_allow_all
      ON score_deltas FOR ALL
      USING (true) WITH CHECK (true);
  END IF;
END $$;

-- ── 2. De idempotente RPC ───────────────────────────────────────────────────
-- Eén transactie. De INSERT ... ON CONFLICT DO NOTHING is de poort: slaagt hij,
-- dan is dit de eerste keer en wordt de score bijgewerkt. Slaagt hij niet, dan
-- is deze delta al verwerkt en geven we alleen de huidige stand terug.
--
-- Dezelfde ondergrens van 0 als de client (Math.max(0, ...)), zodat een
-- strafpunt de stand niet negatief kan trekken.
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

  INSERT INTO score_deltas (client_id, team_id, delta)
  VALUES (p_client_id, p_team_id, p_delta)
  ON CONFLICT (client_id) DO NOTHING;

  -- ROW_COUNT is een integer, niet een boolean: 1 als de INSERT doorging,
  -- 0 als ON CONFLICT hem heeft laten liggen.
  GET DIAGNOSTICS v_rows = ROW_COUNT;

  IF v_rows > 0 THEN
    UPDATE teams
       SET score = GREATEST(0, COALESCE(score, 0) + p_delta)
     WHERE id = p_team_id
    RETURNING score INTO v_score;
  ELSE
    -- Al eerder toegepast (replay na een crash of een dubbele flush).
    SELECT score INTO v_score FROM teams WHERE id = p_team_id;
  END IF;

  RETURN COALESCE(v_score, 0);
END $$;

-- De rollen anon/authenticated bestaan altijd in een Supabase-project, maar niet
-- in een kale Postgres (bv. een lokale test). Sla ze dan over in plaats van de
-- hele patch te laten klappen.
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

-- ── 3. Controles ────────────────────────────────────────────────────────────
SELECT 'functie' AS probe, proname, pg_get_function_identity_arguments(oid) AS args
  FROM pg_proc WHERE proname = 'increment_team_score_idem';

SELECT 'tabel' AS probe, COUNT(*) AS toegepaste_deltas FROM score_deltas;

-- Rooktest: twee keer dezelfde sleutel moet één keer tellen.
-- Vervang 1 door een bestaand team_id en draai de drie regels samen.
--   SELECT increment_team_score_idem(1, 5, 'rooktest-v58');
--   SELECT increment_team_score_idem(1, 5, 'rooktest-v58');   -- zelfde uitkomst
--   DELETE FROM score_deltas WHERE client_id = 'rooktest-v58';
--   -- en draai de score daarna handmatig 5 terug

-- ── ROLLBACK (alleen uitvoeren als je terug moet) ───────────────────────────
-- DROP FUNCTION IF EXISTS increment_team_score_idem(INTEGER, INTEGER, TEXT);
-- DROP TABLE IF EXISTS score_deltas;
