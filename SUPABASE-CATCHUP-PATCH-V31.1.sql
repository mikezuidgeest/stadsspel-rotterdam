-- ============================================================
-- SUPABASE-CATCHUP-PATCH-V31.1.sql
-- ============================================================
-- Purpose: replace the V31 AFTER ROW trigger that undercounts
--   `teams.locations_visited` when multiple rows are inserted
--   into `completed_challenges` in a single multi-row INSERT.
--
--   The existing `NOT EXISTS (... WHERE id <> NEW.id)` check
--   doesn't see sibling rows of the same multi-row INSERT
--   reliably (observed 19 Apr 2026 during the refresh-persistence
--   deep test — a 3-row INSERT of locations [7, 7, 12] produced
--   locations_visited=1 where the correct answer is 2).
--
--   This version sidesteps the issue entirely by recomputing
--   both counters from scratch against the full
--   `completed_challenges` table every time the trigger fires.
--   Correct under ANY insert shape (single-row, multi-row,
--   copy, bulk-import, manual SQL). At gameday scale (~400
--   inserts per game) the extra two small SELECTs per INSERT
--   are trivial — sub-millisecond.
--
-- Author:    Mike + Claude (19 Apr 2026)
-- Applies on top of: V31 (which must already be live).
-- Safe to run: idempotent — CREATE OR REPLACE.
-- How to apply: paste into Supabase → SQL Editor → Run.
--   Block A of the reset script is unaffected: TRUNCATE still
--   bypasses row triggers, and `UPDATE teams SET
--   challenges_completed=0, locations_visited=0` still zeros
--   the counters correctly.
--
-- Verification: see the end of this file for a targeted
--   multi-row INSERT test that V31 fails and V31.1 passes.
-- ============================================================

BEGIN;

-- --------------------------------------------------------------
-- Section 1: recompute-from-scratch trigger function
-- --------------------------------------------------------------
-- Semantic guarantees:
--   - challenges_completed = COUNT(*) in completed_challenges for this team
--   - locations_visited    = COUNT(DISTINCT location_id) WHERE location_id >= 0
--     (i.e. sentinel -1 rows from bar-mini challenges are skipped, matching
--      v18.html:2912 client logic)
--   - updated_at is stamped on every trigger fire so the realtime echo
--     reaches every subscribed tab without a follow-up write
--
-- Why the old approach failed: the NOT EXISTS guard inside an AFTER ROW
-- trigger cannot reliably see sibling rows from the same multi-row
-- INSERT (PostgreSQL trigger timing + snapshot semantics). Recomputing
-- from scratch reads the current committed state of the table and is
-- correct regardless of how the insert was shaped.

CREATE OR REPLACE FUNCTION update_team_stats_on_completion()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE teams
     SET challenges_completed = (
           SELECT COUNT(*)::INT
             FROM completed_challenges
            WHERE team_id = NEW.team_id
         ),
         locations_visited    = (
           SELECT COUNT(DISTINCT location_id)::INT
             FROM completed_challenges
            WHERE team_id = NEW.team_id
              AND location_id IS NOT NULL
              AND location_id >= 0
         ),
         updated_at = NOW()
   WHERE id = NEW.team_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger itself is unchanged from V31 — only the function body was wrong.
-- Re-bind defensively so a fresh DB that never saw V31 still ends up
-- correctly wired up.
DROP TRIGGER IF EXISTS trg_update_team_stats ON completed_challenges;
CREATE TRIGGER trg_update_team_stats
  AFTER INSERT ON completed_challenges
  FOR EACH ROW
  EXECUTE FUNCTION update_team_stats_on_completion();

-- --------------------------------------------------------------
-- Section 2: one-time heal of any drifted rows
-- --------------------------------------------------------------
-- If any team already drifted under V31, this pass brings them back in
-- line with the source of truth. Harmless on a clean DB — just re-writes
-- the same value.
UPDATE teams t
   SET challenges_completed = sub.cc_count,
       locations_visited    = sub.loc_count,
       updated_at           = NOW()
  FROM (
    SELECT team_id,
           COUNT(*)::INT                                                AS cc_count,
           COUNT(DISTINCT location_id) FILTER (WHERE location_id >= 0)::INT AS loc_count
      FROM completed_challenges
     GROUP BY team_id
  ) sub
 WHERE t.id = sub.team_id;

-- Teams with no completions at all need to be zeroed out too (the UPDATE above
-- only touches rows that appear in the sub-select).
UPDATE teams
   SET challenges_completed = 0,
       locations_visited    = 0,
       updated_at           = NOW()
 WHERE id NOT IN (SELECT DISTINCT team_id FROM completed_challenges)
   AND (challenges_completed <> 0 OR locations_visited <> 0);

-- --------------------------------------------------------------
-- Section 3: sanity output
-- --------------------------------------------------------------
-- After COMMIT, confirm the function body was replaced and every
-- team's counters match their completed_challenges history.
SELECT 'function check' AS probe,
       proname,
       pg_get_functiondef(oid) LIKE '%COUNT(DISTINCT location_id)%' AS is_v31_1
  FROM pg_proc
 WHERE proname = 'update_team_stats_on_completion';

SELECT 'trigger check' AS probe, tgname, tgenabled
  FROM pg_trigger
 WHERE tgname = 'trg_update_team_stats';

SELECT 'drift check' AS probe,
       t.id,
       t.name,
       t.challenges_completed AS cc_stored,
       COALESCE(sub.cc_count, 0) AS cc_expected,
       t.locations_visited AS lv_stored,
       COALESCE(sub.loc_count, 0) AS lv_expected,
       CASE
         WHEN t.challenges_completed = COALESCE(sub.cc_count, 0)
          AND t.locations_visited    = COALESCE(sub.loc_count, 0)
         THEN 'OK'
         ELSE 'DRIFT'
       END AS status
  FROM teams t
  LEFT JOIN (
    SELECT team_id,
           COUNT(*)::INT AS cc_count,
           COUNT(DISTINCT location_id) FILTER (WHERE location_id >= 0)::INT AS loc_count
      FROM completed_challenges
     GROUP BY team_id
  ) sub ON sub.team_id = t.id
 ORDER BY t.id;

COMMIT;

-- ============================================================
-- Post-apply verification — the multi-row INSERT case V31 failed
-- ============================================================
-- (Run this AFTER the BEGIN...COMMIT block above. This is a
--  destructive test — it inserts test rows then deletes them.)
--
-- -- pick a real team that exists in the DB
-- WITH victim AS (
--   SELECT id FROM teams WHERE spectator = false ORDER BY id LIMIT 1
-- )
-- -- zero it out
-- , reset AS (
--   UPDATE teams SET challenges_completed = 0, locations_visited = 0
--    WHERE id = (SELECT id FROM victim)
-- )
-- -- multi-row insert: 3 rows covering 2 distinct locations
-- INSERT INTO completed_challenges (team_id, challenge_id, location_id, challenge_type, points_earned)
-- VALUES
--   ((SELECT id FROM victim), 'v31_1_test_7_0',  7,  'quiz',  10),
--   ((SELECT id FROM victim), 'v31_1_test_7_1',  7,  'quiz',  10),
--   ((SELECT id FROM victim), 'v31_1_test_12_0', 12, 'photo', 20);
--
-- -- V31 would have set locations_visited=1 here (BUG).
-- -- V31.1 correctly sets locations_visited=2.
-- SELECT id, name, challenges_completed, locations_visited
--   FROM teams
--  WHERE id = (SELECT id FROM teams WHERE spectator = false ORDER BY id LIMIT 1);
--
-- -- Cleanup:
-- DELETE FROM completed_challenges WHERE challenge_id LIKE 'v31_1_test_%';
-- UPDATE teams SET challenges_completed = 0, locations_visited = 0
--  WHERE id = (SELECT id FROM teams WHERE spectator = false ORDER BY id LIMIT 1);
--
-- If the SELECT showed challenges_completed=3 AND locations_visited=2,
-- V31.1 is live and correct.
-- ============================================================
