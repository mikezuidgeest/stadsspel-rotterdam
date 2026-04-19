-- ============================================================
-- SUPABASE-CATCHUP-PATCH-V32.sql
-- ============================================================
-- Purpose: ship the DB half of V20's Human-Logic audit fixes for
--   team allocation (audit-human-logic-team-allocation-20260419.md).
--   Two parts:
--     A) server-side UNIQUE constraints on teams.name (case-
--        insensitive) and teams.emoji — belt-and-braces for the
--        client-side conflict check in createFromPack / createCustom
--        / renameTeam (stadsspel-rotterdam-v20.html).
--     B) new team_members table — the missing backing store for
--        real headcount-per-team (Principle 3 — Balanced Distribution).
--        A per-browser session UUID (ensureSessionId in v20)
--        inserts a row here on join, deletes on leave. The v20 client
--        subscribes for INSERT/DELETE and derives the live count on
--        every phone — no DB trigger needed (we burned ourselves on
--        trigger undercounts in V31).
--
-- Author:    Mike + Claude (19 Apr 2026)
-- Applies on top of: V31.1 (recompute-from-scratch trigger).
-- Safe to run: idempotent — uses IF NOT EXISTS / CREATE OR REPLACE
--   and wraps everything in BEGIN…COMMIT so a mid-way failure rolls
--   back cleanly. A ROLLBACK block is provided below the COMMIT for
--   emergency revert.
-- How to apply: paste into Supabase → SQL Editor → Run.
--
-- Pre-flight: the 19 Apr 2026 DB sanity probe (Task #51) confirmed
--   the live teams table has 4 rows with distinct names + distinct
--   emojis (case-sensitive AND case-insensitive), so the UNIQUE
--   indexes below will build successfully without a cleanup pass.
-- ============================================================

BEGIN;

-- --------------------------------------------------------------
-- Section 1: teams.name — case-insensitive UNIQUE (partial)
-- --------------------------------------------------------------
-- A partial index on LOWER(name) WHERE NOT spectator lets spectator
-- rows keep whatever display name they want (the client filters them
-- out of the join UI) while guaranteeing no two real teams can share
-- a display name — even via "Red Devils" vs "red devils".
--
-- The v20 client (renameTeam / createFromPack / createCustom) does a
-- local + ilike probe first, but this index is the authoritative
-- guard. PostgREST maps the unique_violation to error.code = '23505'
-- which the client surfaces as: "X is al in gebruik — kies andere
-- naam".
CREATE UNIQUE INDEX IF NOT EXISTS teams_name_lower_unique
  ON teams (LOWER(name))
  WHERE COALESCE(spectator, FALSE) = FALSE;

-- --------------------------------------------------------------
-- Section 2: teams.emoji — UNIQUE (partial)
-- --------------------------------------------------------------
-- Same reasoning, exact-match (emojis are atomic codepoints — no
-- "case" to fold). Spectator rows excluded for the same reason.
CREATE UNIQUE INDEX IF NOT EXISTS teams_emoji_unique
  ON teams (emoji)
  WHERE COALESCE(spectator, FALSE) = FALSE;

-- --------------------------------------------------------------
-- Section 3: team_members table (Principle 3 — Balanced Distribution)
-- --------------------------------------------------------------
-- Stadsspel has no real "players" table: team membership was always
-- browser-local (localStorage + stadsspel_v12_session). That means
-- the admin panel can't tell how many people are on each team — so
-- "Balanced Distribution" was failing the audit.
--
-- team_members is the minimal backing store:
--   - session_id: per-browser UUID (v20 ensureSessionId), so a single
--     phone can "join" exactly once per team. Switching teams deletes
--     the old row + inserts a new one.
--   - joined_at: for tie-breaking if two phones race for the last slot.
-- The client subscribes for INSERT/DELETE and derives the per-team
-- count in memory. RLS is "allow all" to match the app's threat
-- model (phones-only, no PII, one-night event — see CLAUDE.md).
CREATE TABLE IF NOT EXISTS team_members (
  id          BIGSERIAL PRIMARY KEY,
  team_id     INTEGER     NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  session_id  TEXT        NOT NULL,
  display_name TEXT,
  joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- One membership per session — moving teams deletes+inserts. This
  -- enforces "a phone is on at most one team at a time" at the DB
  -- level, regardless of any client bug that forgets to delete first.
  CONSTRAINT team_members_session_unique UNIQUE (session_id)
);

-- Fast lookup for the "how many on team X?" aggregate + realtime
-- subscription filter.
CREATE INDEX IF NOT EXISTS team_members_team_id_idx
  ON team_members (team_id);

-- Enable RLS + wide-open policy to match the rest of the schema
-- (teams / activity_feed / photo_reviews all use "Allow all"). Do
-- NOT tighten this here — doing so would silently break live play.
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename  = 'team_members'
       AND policyname = 'team_members_allow_all'
  ) THEN
    CREATE POLICY team_members_allow_all
      ON team_members
      FOR ALL
      USING (true)
      WITH CHECK (true);
  END IF;
END;
$$;

-- Enable Supabase Realtime on the table so the v20 client's
-- INSERT/DELETE subscription actually receives events. Guard with a
-- check — re-running ALTER PUBLICATION ADD TABLE on an already-added
-- table errors out, so we inspect pg_publication_tables first.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
     WHERE pubname    = 'supabase_realtime'
       AND schemaname = 'public'
       AND tablename  = 'team_members'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE team_members;
  END IF;
END;
$$;

-- --------------------------------------------------------------
-- Section 4: sanity output (runs before COMMIT so a probe failure
--            rolls the whole patch back)
-- --------------------------------------------------------------
SELECT 'teams unique indexes' AS probe, indexname, indexdef
  FROM pg_indexes
 WHERE schemaname = 'public'
   AND tablename  = 'teams'
   AND indexname IN ('teams_name_lower_unique','teams_emoji_unique')
 ORDER BY indexname;

SELECT 'team_members table' AS probe, column_name, data_type, is_nullable
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = 'team_members'
 ORDER BY ordinal_position;

SELECT 'team_members policy' AS probe, policyname, cmd
  FROM pg_policies
 WHERE schemaname = 'public'
   AND tablename  = 'team_members';

SELECT 'team_members realtime' AS probe, pubname, tablename
  FROM pg_publication_tables
 WHERE pubname    = 'supabase_realtime'
   AND schemaname = 'public'
   AND tablename  = 'team_members';

COMMIT;

-- ============================================================
-- Post-apply verification (run separately)
-- ============================================================
-- 1) Confirm name uniqueness is enforced:
--    INSERT INTO teams (name, emoji, color, spectator)
--      VALUES (
--        (SELECT name FROM teams WHERE COALESCE(spectator,FALSE)=FALSE ORDER BY id LIMIT 1),
--        '🆘', '#000', FALSE
--      );
--    -- Expect: ERROR duplicate key value violates unique constraint
--    --         "teams_name_lower_unique"  (SQLSTATE 23505)
--
-- 2) Confirm emoji uniqueness is enforced:
--    INSERT INTO teams (name, emoji, color, spectator)
--      VALUES (
--        'v32-probe-unique-name',
--        (SELECT emoji FROM teams WHERE COALESCE(spectator,FALSE)=FALSE ORDER BY id LIMIT 1),
--        '#000', FALSE
--      );
--    -- Expect: ERROR 23505 on teams_emoji_unique
--
-- 3) Confirm team_members round-trip + per-session unique:
--    INSERT INTO team_members (team_id, session_id, display_name)
--      VALUES ((SELECT id FROM teams WHERE COALESCE(spectator,FALSE)=FALSE ORDER BY id LIMIT 1),
--              'v32-probe-session', 'probe');
--    INSERT INTO team_members (team_id, session_id, display_name)
--      VALUES ((SELECT id FROM teams WHERE COALESCE(spectator,FALSE)=FALSE ORDER BY id LIMIT 1),
--              'v32-probe-session', 'probe-dup');
--    -- Expect: ERROR 23505 on team_members_session_unique
--    DELETE FROM team_members WHERE session_id = 'v32-probe-session';
--
-- ============================================================
-- EMERGENCY ROLLBACK — run ONLY if the patch needs to be reverted
-- (e.g. UNIQUE build exposes a duplicate we missed in the pre-flight)
-- ============================================================
-- BEGIN;
-- DROP INDEX IF EXISTS teams_name_lower_unique;
-- DROP INDEX IF EXISTS teams_emoji_unique;
-- -- Realtime: remove the table from the publication before DROP so we
-- -- don't leave an orphan entry (ALTER PUBLICATION on a dropped table
-- -- silently no-ops, but being explicit prevents pg_publication_tables
-- -- drift warnings).
-- DO $$
-- BEGIN
--   IF EXISTS (
--     SELECT 1 FROM pg_publication_tables
--      WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename='team_members'
--   ) THEN
--     ALTER PUBLICATION supabase_realtime DROP TABLE team_members;
--   END IF;
-- END;
-- $$;
-- DROP TABLE IF EXISTS team_members;
-- COMMIT;
-- ============================================================
