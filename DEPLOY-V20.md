# DEPLOY-V20.md — Human-Logic Audit Team-Allocation Fixes

**Date:** 19 April 2026 (evening)
**Working file:** `stadsspel-rotterdam-v20.html` (SHA256 `6bfb30e3d3c04ca2eadef1efc00363770d7f5629839cce777c220f66412ec466`)
**index.html:** byte-identical to v20.html
**Paired SQL patch:** `SUPABASE-CATCHUP-PATCH-V32.sql` (unpushed — Mike applies via Supabase SQL Editor)
**Live URL:** https://mikezuidgeest.github.io/stadsspel-rotterdam/
**Admin URL:** https://mikezuidgeest.github.io/stadsspel-rotterdam/?admin=vriendvanjorik

---

## What V20 ships

Closes 7 of 10 gaps from `audit-human-logic-team-allocation-20260419.md` (Mike confirmed bundle on 19 Apr). Two principles flipped from ❌ FAIL to ✅ PASS in the audit scorecard (Transparency, Constraint Awareness); Balanced Distribution moved from ❌ FAIL to ⚠️ PARTIAL pending a future join-existing-team UX.

### Code-level (in `stadsspel-rotterdam-v20.html`)

1. **Per-browser session UUID (`ensureSessionId`)** — extends the existing `stadsspel_v12_session` localStorage blob with a stable `crypto.randomUUID()`. Fallback UUID for private-browsing / quota-exceeded environments.
2. **`team_members` write-through + live headcount subscription** — on every `myTeam` change, upsert a row into `team_members` keyed by session UUID. A realtime subscription refreshes `teamMemberCounts` on INSERT/DELETE/UPDATE. Gracefully no-ops when the table is missing (pre-V32 deploys).
3. **Headcount chips** — admin "Team beheer" rows show "📱 N"; TeamSetup starter-pack "Bezet" state shows "Bezet · 📱 N".
4. **Late-join warning banner** — dismissible banner in TeamSetup when `phase >= 1`. Non-blocking per Mike's decision.
5. **Admin team rename** — ✏️ button in Team beheer → `promptAsync` → local case-insensitive check → server-side ilike probe → UPDATE → 23505 mapped to a user-facing "al in gebruik" toast. Teams UPDATE realtime sub propagates.
6. **`moveJorik(origin)` feed prefix** — `'admin'` / `'bar'` / `'start'` paths now emit distinguishable activity_feed lines; `[JORIK] team={id}` marker unchanged.
7. **Kick-reason toasts** — 12h session expiry, phantom-team guard, and admin-deleted-team paths now show distinguishable toasts instead of a blank splash.
8. **Jorik revisit guard** — admin Team chip shows "✅ al bezocht" for teams that already held Jorik; `onMoveJorik` surfaces a confirm dialog before a manual revisit.
9. **23505 handling on team create** — `createFromPack` / `createCustom` map the server-side UNIQUE violation to field-specific error messages.

### DB-level (in `SUPABASE-CATCHUP-PATCH-V32.sql`)

1. `teams_name_lower_unique` partial index on `LOWER(name) WHERE NOT spectator`.
2. `teams_emoji_unique` partial index on `emoji WHERE NOT spectator`.
3. `team_members` table: `(id BIGSERIAL PK, team_id INT REFERENCES teams ON DELETE CASCADE, session_id TEXT UNIQUE, display_name TEXT, joined_at TIMESTAMPTZ)`.
4. RLS "Allow all" policy on `team_members`.
5. Realtime publication membership for `team_members`.
6. Emergency ROLLBACK block at bottom (commented-out — un-comment + run only if needed).

---

## Deploy steps (in order)

### 1. Apply V32 SQL in Supabase

Open https://supabase.com/dashboard/project/kybcndicweuxjxkfzxud → SQL Editor → paste the **entire** `SUPABASE-CATCHUP-PATCH-V32.sql` file → Run. The script is wrapped in `BEGIN…COMMIT` so it's atomic: any failure rolls back cleanly.

**Expected probe output:**
- `teams unique indexes` → 2 rows (`teams_emoji_unique`, `teams_name_lower_unique`).
- `team_members table` → 5 columns (`id`, `team_id`, `session_id`, `display_name`, `joined_at`).
- `team_members policy` → 1 row (`team_members_allow_all`).
- `team_members realtime` → 1 row.

If the pre-flight check in `audit-human-logic-team-allocation-20260419.md` missed a duplicate name/emoji, the UNIQUE index build fails and the whole transaction rolls back — no damage done. Fix the duplicate manually and re-run.

### 2. Verify byte parity (already done locally)

```bash
shasum -a 256 stadsspel-rotterdam-v20.html index.html
# Both should print: 6bfb30e3d3c04ca2eadef1efc00363770d7f5629839cce777c220f66412ec466
```

### 3. Push to GitHub Pages

```bash
cd "Jorik Rotterdam Stadspel"
git add stadsspel-rotterdam-v20.html index.html SUPABASE-CATCHUP-PATCH-V32.sql PROJECT-MEMORY.md DEPLOY-V20.md audit-human-logic-team-allocation-20260419.md
git commit -m "V20: Human-Logic audit team-allocation fixes (see audit-human-logic-team-allocation-20260419.md)"
git push origin main
```

GitHub Pages rebuild is typically under a minute. Visit the live URL and hard-refresh.

### 4. Live verification (after push)

1. **Headcount plumbing:** open the live URL in two browser tabs (or phone + laptop). Pick the same starter pack on the first — confirm "Bezet · 📱 1" appears on the second. Pick a different pack on the second — confirm first shows "Bezet · 📱 1" for the second's team too, and admin view shows both "📱 1".
2. **Admin rename:** go to admin URL → Team beheer → ✏️ on any team → give it a new name. Confirm the name propagates to every phone and that attempting to rename to a taken name triggers "al in gebruik".
3. **UNIQUE server guard:** in the Supabase SQL Editor, try `INSERT INTO teams (name, emoji, color, spectator) VALUES ((SELECT name FROM teams WHERE NOT spectator LIMIT 1), '🆘', '#000', FALSE);` — expect SQLSTATE 23505.
4. **Late-join banner:** start the game (admin → phase 1), then open TeamSetup in an incognito window — banner should show "De wedstrijd is al gestart · Fase: Zoektocht …" and dismiss with "Begrepen".
5. **Jorik revisit warn:** admin chips for teams that already held Jorik show "✅ al bezocht"; clicking one triggers a confirm dialog.
6. **Kick-reason toasts:** in the admin SQL Editor, `DELETE FROM teams WHERE id = {myTeamId}` while a player is on the lobby — the player should see "🗑 Team verwijderd door Game Master — kies opnieuw" and land on splash. Wait 12h (or manually set `updated < now - 12h` in the player's localStorage) and refresh — toast reads "⏱ Sessie van Team X verlopen (12h) — kies opnieuw".

---

## Known non-ships / deferred scope

1. **Soft cap enforcement dialog.** The data plumbing + visibility ship in V20, but the actual "Team is vol — kies een ander team" dialog is not wired. The current UX has no explicit "join existing team" button; `createFromPack` with a taken name hits the Bezet lockout instead. When a join-existing-team flow is added (future work), the soft cap `max(6, ceil(total_players / teams.length) + 1)` can be layered on top.
2. **Two-tab trick** (same phone joining two teams via two tabs). Mike explicitly flagged as not a concern for a phones-only bachelor party.
3. **Player → spectator mid-game.** No UI action for a player to switch to spectator once joined. Current behaviour (they can leave and rejoin as GM if admin) is kept per Mike's decision.

---

## Rollback procedure (if something breaks gameday)

1. **Revert HTML:**
   ```bash
   cd "Jorik Rotterdam Stadspel"
   cp stadsspel-rotterdam-v19.html index.html
   shasum -a 256 stadsspel-rotterdam-v19.html index.html
   # Both should print: cdc57cedf61a5b490f27e8028ab8aa41278541f0cb2eee74f820923203aa9f83
   git add index.html && git commit -m "Revert to V19 (cdc57ced…)" && git push origin main
   ```
2. **Revert SQL (only if the UNIQUE indexes conflict with gameday data):** run the `EMERGENCY ROLLBACK` block from the bottom of `SUPABASE-CATCHUP-PATCH-V32.sql`. Dropping `team_members` does not touch any other table — V19 never read it, so data loss is limited to headcount rows.

V19 is safe as a fallback: it holds the never-twice Jorik rotation (live-verified 19 Apr), all core gameplay, and the V31 + V31.1 trigger stack.

---

## Master Audit Cross-Check status

Per `PROTOCOL-MASTER-AUDIT-CROSSCHECK.md` — pending Step 10 of the V20 plan:
- **Layer A (static):** pending file-by-file grep pass + `diff v19 v20` sanity.
- **Layer B (context):** this file + `PROJECT-MEMORY.md` V20 entry + audit annotations are written; needs a read-through.
- **Layer C (runtime):** requires Mike to apply V32 SQL + push, then the same live probes listed in §4 above.

Full ✅ 3/3 DONE verdict cannot be issued until all three lanes confirm.
