# Refresh Persistence — Deep Test (19 April 2026)

**Scope:** Prove what happens when a player refreshes / reloads their tab mid-game on
the live deploy. No assumptions — every claim verified by direct DB read, direct
localStorage read, and direct React fiber-state inspection.

**Environment**
- URL: https://mikezuidgeest.github.io/stadsspel-rotterdam/
- Supabase project: `kybcndicweuxjxkfzxud`
- Patch level: V31 (applied + verified live earlier today)
- Test tab: player (non-admin) tabId 242407895
- Seed team: team 4 "Kralingse Kapers"
- Test harness: Chrome MCP `javascript_tool` calling the page's real `window.sb`

## Summary

**Refresh persistence works as designed for the happy path.** V12 localStorage session
+ V21 P0 `completed_challenges` rehydrate + V22 visibility-change catch-up together keep
every piece of gameday-critical state intact across a full page reload.

**One UX gap found:** pending (unapproved) photo submissions are not recovered for the
submitting player on refresh — the challenge appears "not started" until admin approves.
Data integrity is safe (UNIQUE constraint prevents double-scoring), but the player may
resubmit and create duplicate admin queue entries.

**One unrelated bug surfaced by the test harness:** V31 trigger's `locations_visited`
increment undercounts when multiple rows are inserted into `completed_challenges` in a
single multi-row `INSERT`. Does NOT happen in normal gameplay (which always inserts one
row at a time) — test-harness-only concern, but confirmed visible in the leaderboard when
it occurs.

---

## Test 1 — Happy-path refresh (mid-game with points and completions)

**Setup** (via direct DB writes):
- `game_state`: phase=1, started_at=now
- `teams[id=4]`: score=45
- `completed_challenges` (team 4): 4 rows covering 3 distinct locations
  - (7, "7_0", quiz, 10pts)
  - (7, "7_1", quiz, 10pts)
  - (12, "12_0", photo, 20pts)
  - (20, "20_0", quiz, 5pts)
- `localStorage` seeded with valid session → team 4, screen=game, phase=1

**Action:** navigate to root (`location.reload()` equivalent) → wait 2.5s for mount + rehydrate.

**Result — direct React fiber inspection:**
```
screen          = "game"                                  ✓
myTeam.id       = 4                                       ✓
myTeam.name     = "Kralingse Kapers"                      ✓
teams           = 4 teams loaded                          ✓
scores          = {3:0, 4:45, 5:0, 6:0}                   ✓ (exact match to DB)
completed       = {7:{0:T,1:T}, 12:{0:T}, 20:{0:T}}       ✓ (exact match)
completedPts    = {7:{0:10,1:10}, 12:{0:20}, 20:{0:5}}    ✓ (exact match)
visitedLocs     = Set{7, 12, 20}                          ✓
realtime channels after reload = 7                        ✓ (all subs re-established)
```

All eight hook slots hydrated correctly. The V21 P0 fix (v18.html:1645–1680) is doing
exactly what it was written to do.

**Verdict:** PASS.

---

## Test 2 — Refresh during an active bar break

**Setup:** with the Test 1 state live, admin-equivalent DB write:
- `game_state.bar_break_active` = "Café de Unie"
- `bar_break_started_at` = now
- `bar_break_1_time` = now

**Action:** realtime propagation → confirmed bar-break UI appeared → reload page.

**Result — after reload + 2.8s:**
- Hook slot 77 (`barBreakActive`): `{name, mini, started}` object, populated ✓
- DOM shows "Café de Unie" in bar-break widget ✓
- localStorage session still valid ✓
- phase still 1 ✓

Visibility-change path (v18.html:1694–1760) also re-fetches `game_state` on tab-focus,
so backgrounding + foregrounding during a bar break keeps the state fresh via the same
code path.

**Verdict:** PASS.

---

## Test 3 — Refresh with a pending photo submission (⚠ gap found)

**Setup:** a `photo_reviews` row for team 4, challenge '30_0', status='pending', NO
corresponding `completed_challenges` row yet.

**Action:** reload → wait 2.5s → inspect React state + DOM.

**Result:**
- `completed` map correctly does NOT contain "30" → challenge is not marked done ✓
- `visitedLocs` correctly does NOT contain 30 ✓
- **NO state anywhere** carrying "pending" / "awaiting review" for challenge 30_0 ✗
- **NO DOM marker** anywhere on the map or challenge list ✗
- No `localStorage` key tracking pending submissions ✗
- Code confirms: `photo_reviews` is fetched on mount ONLY when `isAdmin` is true
  (v18.html:1640–1642). Player tabs rely on ephemeral in-memory state set at submit
  time, which is lost on refresh.

**Impact**
- Player opens challenge 30_0 after refresh, sees it as not-started, and may resubmit
- Each resubmit creates a new `photo_reviews` row
- Admin queue gets duplicate entries for the same team+challenge
- When admin approves one, a `completed_challenges` row is inserted; if admin approves
  both, the second insert hits UNIQUE(team_id, challenge_id) and is rejected
- Final scoring is correct (one approval = one set of points)
- But the admin has a messy queue and has to visually decide which copy to approve

**Severity**: medium-low. Unlikely to break gameday, but confusing on the day if a
player reloads mid-wait.

**Fix options (not applied — decision item)**
1. **Cheapest**: player tab also fetches `photo_reviews WHERE team_id=myTeam.id AND
   status='pending'` on mount, set a local `myPending[locId][chIdx] = true` map, and
   grey out the submit button on those challenges.
2. **Also cheap**: write the submission to localStorage on submit; clear on
   realtime approval/rejection event.
3. **Heavier**: add UNIQUE(team_id, challenge_id) WHERE status='pending' to prevent
   resubmit entirely — but that breaks legitimate "submitted, rejected, resubmit"
   flows.

Option 1 is the least risky. ~10 lines added to the mount effect in v18.html.

**Verdict:** GAP — recommend V32 fix.

---

## Test 4 — Empty localStorage (first load / manual wipe)

**Setup:** `localStorage.clear()` → reload.

**Result**
- screen = "splash" ✓
- myTeam = null ✓
- Splash UI rendered ✓
- No crashes, no errors

**Verdict:** PASS.

---

## Test 5 — iOS private-browsing (setItem throws)

**Setup:** overrode `Storage.prototype.setItem` to throw `QuotaExceededError` (same
failure mode as iOS Safari private mode). Couldn't force this to apply at page-init time
via the test harness (`navigate()` resets prototype overrides), so verified the two halves
separately:

**Detection works** — manual probe (same logic as `localStorageWorks()`) correctly
caught the throw and returned `false`. Confirmed.

**Banner rendering wired** — v18.html:2727 conditional
`{!OFFLINE && !localStorageWorks() && <div className="offline-banner">⚠︎ Private browsing
actief — voortgang wordt niet bewaard bij tab sluiten</div>}` is present in source.
Code path confirmed; full runtime render test not possible via the browser MCP without
a pre-init injection mechanism.

**Verdict:** PASS (detection logic live-verified; banner rendering code-verified).

**Gameday briefing line:** "Open the link in normal Safari, not a Private Browsing tab."

---

## Test 6 — 12-hour session expiry

**Setup:** wrote a valid session but with `updated` stamped 13 hours ago → reload.

**Result**
- screen = "splash" ✓ (expired session correctly rejected by
  `Date.now()-updated > 12*3600*1000` check at v18.html:1096)
- myTeam = null ✓
- Stale row stays in localStorage until next write (minor, not a bug — next
  `saveSession()` overwrites it)

**Verdict:** PASS.

**Gameday briefing line:** "Open the link on the day, not the night before — leaving
it idle >12h logs you out."

---

## Side finding — V31 trigger undercounts on multi-row INSERT

**How discovered**: while seeding Test 1, a single multi-row INSERT of 3 rows
(location_ids: 7, 7, 12) produced `teams.locations_visited = 1` instead of the
expected 2. A subsequent single-row INSERT at location 20 correctly incremented it
(1 → 2).

**Numbers**
- Expected after 3-row INSERT: `challenges_completed=3, locations_visited=2`
- Actual after 3-row INSERT: `challenges_completed=3, locations_visited=1`
- Then +1 single-row INSERT at loc 20: `challenges_completed=4, locations_visited=2`

**Visible in-app consequence**
- Top bar (client-side Set from `completed_challenges`): "3 POI"
- Leaderboard row (DB `teams.locations_visited` via trigger): "2 locaties"
- Same team, same moment, two different numbers on screen

**Hypothesis**: inside the AFTER ROW trigger, the `NOT EXISTS (SELECT ... FROM
completed_challenges WHERE team_id=... AND location_id=... AND id <> NEW.id)` query
may not see earlier rows from the same multi-row INSERT due to statement-level
snapshot semantics. Needs targeted SQL investigation.

**Gameday impact**: **none** under realistic use — gameplay always inserts rows one at
a time via `submitChallenge`. Only a concern for bulk-seeding, test harnesses, or
future import scripts.

**Recommendation**: either (a) document as "don't bulk-INSERT into completed_challenges"
or (b) rewrite the trigger as a STATEMENT-level trigger that recomputes
`locations_visited = COUNT(DISTINCT location_id) FILTER (WHERE location_id >= 0)` for
each affected team. Option (b) is robust against any insert shape.

---

## Other observations

**RLS posture on anon key**: during cleanup, `DELETE FROM photo_reviews` via the anon
client was silently rejected — the row wasn't deleted, no error was raised. But `UPDATE`
was permitted (I used it to mark the test row as `rejected`). So anon has SELECT + INSERT
+ UPDATE on `photo_reviews`, but not DELETE. Same posture is probably applied to other
tables — worth auditing the exact allowed verbs per table before gameday. For a
4-team private party with trusted guests this is non-blocking.

**Phantom session in localStorage at test start**: the test tab opened with a
`myTeam.id=10` / "Haven Helden" session in localStorage pointing to a team that no
longer exists in the DB (real teams are ids 3–6). The app rendered "Haven Helden" in the
top bar anyway, driven purely by localStorage. If the admin re-seeds teams mid-game, any
already-mounted tab keeps displaying the old team until a manual refresh. Unlikely
in-game, but document: "if you need to re-seed teams, have everyone do a hard reload".

---

## Decisions / open items for Mike

1. **Gameday briefing additions** (2 lines):
   - "Open the link in normal browsing mode, not Private / Incognito."
   - "Open the link on the day — leaving the tab open overnight logs you out."

2. **Pending-photo rehydrate** — recommend: add the ~10-line fetch to v18.html's mount
   effect so players can see their own pending submissions after refresh. Low risk,
   clearly worth it. Will queue as V32 candidate if you agree.

3. **V31 trigger multi-row undercount** — recommend: switch to a statement-level trigger
   that recomputes `locations_visited` from scratch. Fixes the edge case and is
   self-healing even if data gets manually patched. Will queue as V31.1 if you agree.

4. **Phantom / stale session handling** — optional: on mount, if `myTeam.id` doesn't
   exist in the refreshed `teams` fetch, fall back to splash. 1-line addition.

None of these block gameday. All are polish / robustness items.

---

## Cleanup

- Deleted the 4 seeded `completed_challenges` rows (anon DELETE on this table works)
- Reset `teams[id=4]` score / challenges_completed / locations_visited to 0
- Reset `game_state` to phase=0, bar_break cleared
- Marked the stray test photo_review (id=17) as `status='rejected'` with a cleanup note
- Cleared the test tab's `localStorage`
- DB now back to clean pre-test state (matches the post-V31-apply baseline)
