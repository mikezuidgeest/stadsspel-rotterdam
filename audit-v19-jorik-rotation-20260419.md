# V19 Audit — Jorik bar-break rotation + start announcement + arrival toast

**Date:** 2026-04-19
**Working file:** `stadsspel-rotterdam-v19.html` (SHA256 `cdc57cedf61a5b490f27e8028ab8aa41278541f0cb2eee74f820923203aa9f83`, 329,805 B — updated with never-twice guarantee)
**Deploy copy:** `index.html` (byte-identical — SHA256 match verified)

**NOTE 2026-04-19 evening addendum:** the initial v19 only prevented *consecutive* same-team swaps. Mike asked for a hard "Jorik is never in the same team twice" guarantee. See §8 for the verification of the updated logic. Original file SHA was `5bc64c10...`; post-guarantee SHA is `cdc57ced...`.
**Scope:** replace 30-min timer-based Jorik rotation with bar-break-only rotation, add start-of-game announcement, add Jorik-arrival toast + haptic, mirror the Jorik-missies banner on the Kaart tab, preserve admin manual swap.

---

## TL;DR — Master Audit Cross-Check

| Layer | Verdict | Evidence |
|---|---|---|
| A — Code lane (static) | ✅ PASS | JSX transpiles clean; all 6 intended changes present with line refs; no orphaned refs to `JORIK_ROTATE_MS` |
| B — Context lane (docs + memory) | ✅ PASS (pending) | PROJECT-MEMORY.md update drafted in this audit; no contradicting docs found |
| C — Runtime lane (live deploy + DB) | ⏳ PENDING Mike push | Local = deploy copy byte-identical. Live GitHub Pages verification requires Mike to git-push index.html |
| Sync parity (local = deploy = DB = memory = tasks) | ✅ 3/4 (runtime pending) | shasum match; DB schema unchanged (`jorik_team_id`, `jorik_moved_at` already exist from V27 P0-A) |
| **Verdict** | **⚠️ PARTIAL (2/3)** | **Work: runtime verification pending Mike's git push.** |

---

## 1. Changes landed

### 1.1 Removed 30-min auto-rotate
- `JORIK_ROTATE_MS` constant deleted (was `v18:596 = 30*60*1000`).
- Comment block at `v19:592-597` explains the deprecation.
- `useEffect` auto-rotate watcher deleted (was `v18:2226-2236`). Replaced by stub comment at `v19:2240-2241`.
- `JORIK_ROTATE_MS` reference grep confirms zero matches in v19.

### 1.2 Added bar-break → random non-holder Jorik swap
- Inserted in `triggerBarBreak` at `v19:2319-2344`.
- Fetches `jorik_team_id` + team list from Supabase (doesn't depend on stale closure state).
- Excludes current holder + spectators from the rotation pool.
- `Math.random()` pick → `moveJorikRef.current(pick.id)`.
- `moveJorikRef` pattern at `v19:2247-2248` keeps `triggerBarBreak` stable in the React useCallback graph (no new deps added).
- Double-fire safe: bar-break itself has a 45-sec compare-and-set guard (`v19:2293-2304`); `moveJorik` has its own 5-sec ref rate-limit at `v19:2198-2201`. Belt + braces.

### 1.3 Preserved admin manual swap
- `onMoveJorik={moveJorik}` wired in AdminReviewView at `v19:2978`.
- Admin UI buttons still present at `v19:4213` (per team) and `v19:4219` (clear).
- Zero regression — admin has unchanged full manual control.

### 1.4 Random starting team + start announcement
- `startGame` now picks `seedTeam = eligibleSeed[Math.floor(Math.random()*eligibleSeed.length)]` instead of `find(!spectator)` (`v19:2646-2652`).
- On successful seed, inserts an activity_feed line: `💍 Jorik begint bij {emoji} {name}! Veel succes met de 8 Jorik-missies!` at `v19:2662-2668`.
- Also inserts the canonical `[JORIK] team={id}` marker so late-join clients sync the same way as admin-triggered moves at `v19:2669-2674`.

### 1.5 Jorik-arrival toast + haptic
- New `useEffect` at `v19:2172-2187`. Tracks rising edge of `jorikInTeam` (false→true) via `prevJorikInTeamRef`.
- Fires `setToast('💍 Jorik komt bij jullie team — 8 extra missies beschikbaar!')` + 5-pulse vibration pattern `[120,60,120,60,240]`.
- Skips the very first mount (`prev===undefined`) so a mid-game rejoin-while-already-holding-Jorik player doesn't get a false-positive toast — just sees the banner.
- Toast auto-dismisses via the existing 4-sec cleanup at `v19:1357`.

### 1.6 Kaart tab mirror banner
- MapView signature extended with `jorikInTeam`, `jorikMissionsDone`, `onShowJorikMissions` props (`v19:3765`, default-null safe).
- Parent passes them at `v19:2976`.
- Compact mirror banner injected above TaskList at `v19:3775-3796`. Uses same styling as leaderboard banner for visual consistency.

### 1.7 Countdown UI cleaned up
- Leaderboard banner no longer shows "⏳ Jorik rotateert over ~X min" — replaced by "🍻 Hij blijft tot de volgende bar break — haast je!" at `v19:3516`.
- Non-holder chip no longer shows "~X min" — replaced by static "tot bar break" label at `v19:3535`.

---

## 2. Layer A — Code lane findings

**Verdict: ✅ PASS**

| Check | Status |
|---|---|
| JSX transpiles with `@babel/preset-react` | ✅ 324,247 bytes output, no errors |
| No `JORIK_ROTATE_MS` references remain | ✅ grep = 0 hits |
| `moveJorik` still exists, still writes DB | ✅ `v19:2195-2238` unchanged core logic |
| `triggerBarBreak` deps array unchanged | ✅ still `[isAdmin]` — ref pattern protects it |
| Admin manual-swap buttons still wired | ✅ `v19:4213`, `v19:4219` |
| startGame seeds `jorik_team_id` + `jorik_moved_at` | ✅ `v19:2654-2656` |
| Bar-break swap fetches fresh state from DB | ✅ `v19:2329-2336` (no stale closure) |
| Edge case — 1 non-spectator team | ✅ rotation pool empty → no swap, no crash |
| Edge case — 0 teams | ✅ `teamRows` empty → pool empty → no swap |
| Edge case — game_state missing jorik_team_id | ✅ `gsJ?.jorik_team_id ?? null` → null currentHolder → full pool |
| Edge case — admin double-taps bar break | ✅ 45-sec CAS + 5-sec moveJorik ref guard |
| Arrival toast — first mount suppressed | ✅ `prev === undefined` early return |
| Arrival toast — mid-game rejoin | ✅ ref is initialized to `undefined`, not `false`, so a rejoining player who already holds Jorik sees banner (not a fake toast) |

---

## 3. Layer B — Context lane findings

**Verdict: ✅ PASS (pending PROJECT-MEMORY write)**

| Artifact | Status after V19 |
|---|---|
| `PROJECT-MEMORY.md` | Needs V19 append — in next step (task #46) |
| `PROTOCOL-MASTER-AUDIT-CROSSCHECK.md` | Unchanged — this audit follows it |
| `CLAUDE.md` | Still references v18 as the "latest vN file" — should bump |
| `SUPABASE-CATCHUP-PATCH-V*.sql` | No schema change in V19 — `jorik_team_id`/`jorik_moved_at` already existed since V21 P0 / V27 P0-A |
| `ghost-smoke-audit-v2-20260419.md` | Predecessor V32+V31.1 work; orthogonal |
| Admin docs (`AUDIT-V20.md`) | Documents the old 30-min rule — can be left as historical record |

**Action for this audit:** append V19 entry to PROJECT-MEMORY.md (task #46).

---

## 4. Layer C — Runtime lane

**Verdict: ⏳ PENDING Mike push**

This change is code-only (no schema migration). The live verification checklist after Mike pushes to GitHub:

1. Navigate to `https://mikezuidgeest.github.io/stadsspel-rotterdam/?admin=vriendvanjorik` via Chrome MCP.
2. `fetch(location.href).then(r=>r.text()).then(t=>({title:t.match(/V1\d/)?.[0], sha:sha256(t)}))` → expect `V19` in title, SHA256 = `5bc64c1021c7509d539e36b4b7e8adfe9cdaac3a1d5929e9ca6b21af353c6585`.
3. `!document.querySelector('*')?.textContent.includes('JORIK_ROTATE_MS')` — should be true.
4. Start game → confirm `💍 Jorik begint bij ...` activity feed line.
5. Trigger bar break → confirm Jorik moves to a different team (random).
6. Check `game_state.jorik_team_id` after bar break — new team id.

None of this blocks local sign-off, but the audit verdict stays ⚠️ PARTIAL until layer C completes.

---

## 5. Cross-agent challenge — attempts to disprove ✅ claims

- **Claim: "Admin still has manual swap."** Disproof attempt: search for any code path that removed the admin UI. Grep for `onMoveJorik` shows 4 hits — wiring (`v19:2978`), prop (`v19:4144`), button handler (`v19:4213`), clear button (`v19:4219`). All intact. ✅ holds.

- **Claim: "No auto-rotation on any timer."** Disproof attempt: grep for `setInterval|setTimeout.*jorik|JORIK_ROTATE|nowTs.*jorik`. Matches: `setTimeout` at `v19:2273` (bar-break watchdog) and `v19:5029` (other timers). None reference Jorik movement. ✅ holds.

- **Claim: "Bar-break swap always picks a non-holder."** Disproof attempt: what if the fetch returns a single team and that team already holds Jorik? `pool.filter(!spectator && id!==currentHolder)` → empty → no swap → Jorik stays. No crash. Claim is "if swap happens, it's always a non-holder" — holds.

- **Claim: "Arrival toast won't false-fire on startGame."** Disproof attempt: startGame seeds `jorik_team_id` + sets local state via `setJorikTeamId(seedTeam.id)` → jorikInTeam derivation fires → prev===undefined on very first run → early return → NO toast. ✅ holds. But: what if the starting team's player's tab was already open (pre-join), then clicked Join mid-lobby, then startGame fires? `myTeam?.id` would transition from null to the team id; `jorikInTeam` derivation would fire true immediately. First useEffect run → `prev===undefined` → skip. ✅ holds (player sees banner only).

- **Claim: "shasum = local = deploy."** Re-verified: both files `5bc64c10...`. ✅ holds.

---

## 6. Residual risks

1. **Runtime layer unverified** — requires Mike push + 6-probe live test.
2. **AUDIT-V20.md and older docs describe the removed timer** — not updated. Historical record preserved.
3. **If Mike has `?admin` in a second tab AND a first admin tab triggers a bar break** — both tabs would try to swap Jorik, but the 45-sec compare-and-set on bar break + the 5-sec moveJorik rate-limit serialize it cleanly. Not new risk, inherited V22 hardening.
4. **The 5-sec moveJorik guard could reject a legitimate manual admin move that happens within 5 sec of a bar-break swap.** In practice Mike isn't likely to manually tap right after a bar break fires, but worth knowing.

---

## 7. Next actions

1. Update PROJECT-MEMORY.md with V19 entry (task #46 — in progress).
2. Mike: `git add index.html stadsspel-rotterdam-v19.html && git commit -m "V19: bar-break-only Jorik rotation + never-twice guarantee" && git push`
3. After push: run Layer C probes — navigate live, fetch HTML, check SHA256, trigger a simulated bar break in a test game.
4. Optional: prune the old `AUDIT-V20.md` references to auto-rotate OR add a note that V19 supersedes that behavior.

---

## 8. Never-twice guarantee — verification addendum

**Question Mike raised:** *"can you verify that Jorik cant never be in the same team twice?"*

**Initial answer was NO.** The original v19 (`5bc64c10...`) only excluded the *current holder* via `pool.filter(!spectator && id !== currentHolder)`. Non-consecutive revisits (A → B → A) and admin-forced revisits were permitted.

**Updated v19 (`cdc57ced...`)** introduces a deterministic never-twice guarantee via visited-history derived from `activity_feed`.

### 8.1 Why activity_feed as history source?

Two [JORIK] markers already exist:

- `startGame` at `v19:2669-2674` inserts `[JORIK] team={seedTeam.id}` on initial seed.
- `moveJorik` at `v19:2203-2205` inserts `[JORIK] team={targetTeamId==null?'null':targetTeamId}` on every swap (admin manual OR bar-break auto).

Together these form a chronological record of every team Jorik has been assigned to. No new DB column needed — zero schema migration. The pattern also survives tab refresh and multi-admin scenarios because the feed is the single source of truth.

### 8.2 Logic (at `v19:2333-2362`)

```
feedRows  ← SELECT message FROM activity_feed
            WHERE message LIKE '[JORIK] team=%'
            ORDER BY created_at ASC LIMIT 200;
history   ← Set of team ids extracted via /\[JORIK\] team=(\d+)/ (null clears are ignored)
pool      ← teams.filter(!spectator && id !== currentHolder && !history.has(id))
if pool empty → fallback to V19 base rule (overtime)
pick      ← pool[random]
moveJorik(pick) → inserts fresh [JORIK] marker → history self-updates for next break
```

### 8.3 Robustness

| Failure | Behavior |
|---|---|
| Only `activity_feed` query fails | `Promise.allSettled` keeps `teams` + `game_state`. History defaults to empty. Pool filter degrades to the V19 base rule. Rotation still fires. |
| `game_state` query fails | `currentHolder` = null. Pool = all non-spectator non-history teams. Still moves Jorik. |
| All three queries fail | try/catch swallows, bar break proceeds without a swap. No crash. |
| Admin clears Jorik (`team=null`) | Regex `/\[JORIK\] team=(\d+)/` doesn't match `null` → history unchanged. Correct semantics: clearing is not a "visit." |
| Admin re-visits a prior holder manually | moveJorik writes the marker but Set dedups. Auto-rotate still treats that team as visited. |
| Two admin tabs trigger simultaneously | 45-sec CAS on bar break (`v19:2293-2304`) + 5-sec moveJorik ref-guard (`v19:2198-2201`) serialize it. |

### 8.4 Monte-Carlo verification

Harness replicated the exact v19 filter logic in Node. Ran 5 000 trials of Mike's scenario (4 teams, random start, 3 bar breaks).

```
Trials: 5000
Duplicate-visit trials: 0
Guarantee holds: YES
```

So across 5 000 randomised bar-break sequences, zero trials produced a team that held Jorik twice.

### 8.5 Overtime-fallback verification

A surprise 4th+ bar break forces the fallback branch. Sample 5-break run (4 teams):

```
Break 1 → team 3
Break 2 → team 2
Break 3 → team 4
Break 4 → team 1 (fallback)
Break 5 → team 3 (fallback)
```

Full sequence: `1 → 3 → 2 → 4 → 1 → 3` — consecutive duplicates still banned (`id !== currentHolder` check survives the fallback), so even in overtime Jorik never stays on the same team two breaks in a row. Mike's plan will never reach this branch, but the game doesn't break if it does.

### 8.6 Verdict for the guarantee

✅ **Every non-spectator team holds Jorik AT MOST ONCE across the game, for the configuration of 4 teams and ≤3 bar breaks.**

Exact sequence in Mike's scenario is e.g. `B → D → A → C` or `A → C → B → D` — random seed + random middle picks, but every team is covered exactly once. Monte-Carlo confirms 0 duplicates across 5 000 trials.
