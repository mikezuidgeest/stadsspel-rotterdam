# Stadsspel Rotterdam — Project Memory

> **Purpose of this file.** Single-file context for any future Claude/Cowork session
> picking this project up. Everything we've discussed, decided, and built is captured here.
> Read this first before making any changes.
>
> **Last updated:** 19 April 2026 (V31 SQL-only catchup patch — **APPLIED + LIVE-VERIFIED ✅ 3/3 DONE** via supabase-js round-trip on the admin tab. All 8 post-apply verification steps green: trigger fires on every `completed_challenges` INSERT with correct `challenges_completed`-unconditional / `locations_visited`-first-per-location / sentinel -1 skip semantics; `teams.members TEXT[]` accepts + persists arrays; `completed_challenges` now 7 cols / `photo_reviews` now 18 cols after orphan drops; Block A reset still zeros cleanly post-patch. Fixes the 3 medium-severity bugs surfaced by the 19 Apr compressed-full-coverage smoke test — see `smoke-test-v30-20260419.md`. Adds (1) `AFTER INSERT ON completed_challenges` trigger that increments `teams.challenges_completed` unconditionally and `teams.locations_visited` on first-completion-per-location (with sentinel `-1` skip) — closes BUG-SIM-005 + 005b; (2) `ALTER TABLE teams ADD COLUMN IF NOT EXISTS members TEXT[]` — closes BUG-SIM-001 now that the client's existing graceful retry path becomes a no-op; (3) `ALTER TABLE … DROP COLUMN IF EXISTS` sweep over the V14→V30 orphan columns on `completed_challenges` (`first_to_complete`, `is_first`, `photo_data`, `photo`, `points`, `first_bonus`, `loc_id`) and `photo_reviews` (`photo`) — closes BUG-SIM-002. Layer A + B green; Layer C pending Mike's paste. No HTML push needed; V30.1 client stays on GitHub Pages unchanged. 18 April 2026 (V30 "Less-is-More" UX simplification pass — Phases 1-8 CODE COMPLETE + byte-synced + Babel validator clean; user push + Layer C runtime verification + Supabase DB migration still pending. Eight phases collapse surface area so the game reads at bachelor-pace: (P1) deleted Ghost Mode + hot-streak multiplier + 40-minute streak timer machinery now that they confused more than they helped; (P2) deleted the narrative story modal + chapter ticker + PROLOOG auto-opens — the ring story was cute but nobody read it mid-walk; (P3) removed the 10-minute Hot Target with its expiry activity-feed misses that V27 fought with `expiredHotRef`; simpler to just not have the mechanic; (P4) level-up modal collapsed to a single inline toast (`lastLevelSeenRef` from V29 kept the latch); (P5) Ranking tab is now a pure scoreboard — TaskList moved onto the Kaart tab in a fixed-height map + scrollable task list layout so one tab = one mental model; (P6) bar breaks are one shared group moment per bar (`BAR_MOMENT` constant: 🍻 "Groepsfoto + proost", 40 pts) — no more three mini-games competing on the same patio; (P7) feed-row emoji reactions are now real cross-device Supabase state via the new `feed_reactions` table (composite text `feed_key = created_at|team_id|message` + per-device uuid in localStorage + REPLICA IDENTITY FULL + realtime publication) so taps on 🔥👏💀😂🍻 actually broadcast; (P8) every challenge card now carries a single scoring-clarity line: "✅ 1× per team · eerste team +X bonus" / "♻️ Zo vaak je wilt · elke keer +X pts" / "✅ 1× per team deze break". V30 base SHA256 = `b894815a…657f`, 319,484 B. **V30.1 amendment (same day, post-Layer-C):** realtime `postgres_changes` DELETE events turned out to stream only `{id}` in the old-row payload even with `REPLICA IDENTITY FULL` confirmed in pg_class and the table re-added to the publication — a Supabase metadata-cache quirk. Client-side workaround: `reactionRowsRef` map (id → {feed_key, emoji, device_id}) populated on the initial select + every INSERT and consulted on DELETE. Self-heals on every tab mount. Final V30.1 SHA256 = `925b6a07a345da5df7ff79ae78adaa10e919b048ec522bb423f92c94492ff113`, 321,139 B, 5,082 lines. `index.html` byte-identical. Babel transform clean (output 311,742 B). **V30 is SHIPPED ✅ 3/3 DONE** — live-verified on `mikezuidgeest.github.io/stadsspel-rotterdam/` via Chrome MCP: byte-parity match (321,139 B), 3-tab V30 UI mounts cleanly, Kaart = map+tasks, Feed reactions render, bar moment is a single card, scoring-clarity labels on challenge cards, and the V30.1 `reactionRowsRef` workaround is live in the served bundle. In-page supabase-js round-trip confirmed the platform quirk (DELETE payload `{id}`-only despite REPLICA IDENTITY FULL + publication membership) — exactly what reactionRowsRef handles.)
>
> **Standing protocol:** every delivery in this project must pass the
> **Master Audit Cross-Check Multi-Agent Tree Layer Validation** before being
> reported as done. See `PROTOCOL-MASTER-AUDIT-CROSSCHECK.md` for the full rules.
> Three independent lanes (code / context / runtime) must all confirm before ✅ DONE.

---

## 1. What this project is

A **real-time multiplayer GPS-based city scavenger-hunt game** built for **Jorik's
bachelor party on 6 June 2026** (his wedding is 14 June 2026). The game runs in Rotterdam,
covers 102 verified landmarks, and is played by ~4 teams (16–20 people total) over roughly
4 hours of daytime play ending in a group dinner at Markthal/Bokaal area at 19:30.

**Live URL:** `https://mikezuidgeest.github.io/stadsspel-rotterdam/`
**Admin mode:** append `?admin=true` to the URL for game-master controls
**Start location:** Maritiem Museum, Leuvehaven (51.9179, 4.4822), 14:00 on game day
**End zone:** Markthal / Bokaal area (51.9206, 4.4868, 400m radius), 19:30

**Owner:** Mike Zuidgeest — `m.h.zuidgeest@gmail.com` — GitHub `mikezuidgeest`
**For:** Jorik (the groom — friend of Mike)

---

## 2. Version history (what was built)

### V1 — original prototype
Path: `stadsspel-rotterdam-v1.html` (~1500 lines)
- 50 locations, basic mechanics, single-file HTML

### V2 — second iteration
Path: `stadsspel-rotterdam-v2.html` (~1061 lines)
- 90 locations, basic mechanics
- Bug: some locations had unverified / wrong coordinates

### V3 — premium styling pass
Path: `stadsspel-rotterdam-v3.html` (2145 lines)
- Full 102 verified Rotterdam locations
- Premium dark-theme glassmorphism UI, animations, neon accents
- Still single-player, no multiplayer infrastructure

### V4 — multiplayer architecture
Path: `stadsspel-rotterdam-v4.html` (945 lines, compressed data format)
- Major architecture shift: Supabase (Postgres + WebSocket subscriptions)
- **Leaderboard-first UI** (3 tabs: Leaderboard / Map / Activity)
- Team setup (16 emojis × 8 colors × name)
- Real-time sync between team phones
- Nearby challenge system (3 within 500m)
- Photo-gates-quiz mechanic (quiz locked until a photo/video/creative at same location is done)
- 4 phases + 3 beer breaks + dinner endgame
- Ghost Mode (StukTV-style) — 5 min invisibility, max 3 uses
- Wedding video mission — only shows when Jorik is NOT in your team (surprise for the wedding)
- First-to-complete bonus at each location (+10 pts)
- Offline fallback if Supabase not configured
- Mobile-first, single HTML file, all CDN deps

### V5 — initial multiplayer + V5 strategy features
Path: `stadsspel-rotterdam-v5.html` (1466 lines)
Branding: **"V5 · DE VERLOREN RING"** ("The Lost Ring")
All 6 must-do items from the V5 Strategy doc shipped:
1. **Narrative frame** — "Jorik's verloren trouwring" intro modal at game start, chapter modals auto-appearing on phase transitions, tappable ticker on the leaderboard. Chapters: PROLOOG → FASE 1 DE ZOEKTOCHT BEGINT → FASE 2 STEMMEN UIT DE STAD → FASE 3 DE CIRKEL SLUIT → FASE 4 DE FINALE → EINDSPEL. All copy in Dutch.
2. **Live photo-grid feed** — photos auto-compressed to ~30KB thumbnails via canvas, 3×3 grid preview of recent submissions, lightbox on tap, filter pills (All / Photos / My team). Videos supported (shown inline if <600KB).
3. **Dynamic quiz rotation** — `pickQuiz()` in code; after a location's built-in quizzes are exhausted, a bonus Rotterdam-trivia pool (6 questions) unlocks for extra points. Session-token-style dedup via `seenQuizzes` Set — no repeats.
4. **Starter packs** — 6 one-tap preset teams (De Maffiosi / Haven Helden / Rotterdam Rakkers / De Kubus Kids / Erasmus Elite / Markthal Monsters), each with unique emoji+color. Toggle between "⚡ Snel" and "✏️ Eigen" modes.
5. **GPS drift mitigation** — 5-sample weighted moving average + auto-snap to nearest POI within 30m. Status pill shown on the map: "GPS goed / zwak / slaapt · op [POI name]".
6. **Battery-aware polling** — DeviceMotion-gated GPS. After 30s without motion (checked via accelerometer magnitude), GPS `watchPosition` is cleared. On motion detection, GPS resumes. Fallback: if DeviceMotion unavailable, GPS stays always-on (same as V4).

### V5.1 — iOS GPS sleep hotfix
Same `stadsspel-rotterdam-v5.html` file (V5.1 added in-place; V6 is the next versioned file).
Branding: **"V5.1 · DE VERLOREN RING"** in splash.
Bug fixed: on iOS, `DeviceMotionEvent` requires explicit user permission. V5 didn't request it, so accelerometer events never fired and the battery-aware GPS sleep logic would put GPS to sleep forever (map froze 30s after game start).
Fix shipped:
- New constants `IS_IOS` (UA detect) + `MOTION_AVAILABLE` (only true when DeviceMotion can fire without permission).
- The motion-based sleep `setInterval` is only created when `MOTION_AVAILABLE`. On iOS / browsers without motion the GPS stays always-on like V4.
- `gpsCtrlRef` exposes `start`/`stop` callbacks; new `wakeGps()` callback wired to the GPS pill so any user can tap to force-wake on any platform.
- Pill copy changed: "GPS slaapt" → "GPS rust" (less alarming) plus a "tik om te wekken" hint when sleeping.

### V6 — photo validation (GPS gate + admin review queue)
Path: `stadsspel-rotterdam-v6.html` (1707 lines, 102 KB)
Branding: **"V6 · DE VERLOREN RING"**
Purpose: stop honor-system cheating. Mike asked: "currently I can add whatever I want and still get points, this doesn't seem very logical."
Decision (Mike picked option A): **GPS gate + admin review** — no Gemini AI yet (deferred or droppable).

Features shipped in V6:
- **GPS gate** on photo/video/creative challenges. Camera button is replaced with `📍 Loop dichterbij om de foto te maken · -142m` when distance > `PHOTO_GATE_RADIUS+PHOTO_GATE_GRACE` (50+20=70m total). Live updates as the user walks. Quizzes are NOT gated. Admin (`?admin=true`) bypasses the gate but sees a `⚠️ Admin override` warning.
- When in range: green confirmation `✓ Je bent op locatie (38m)`.
- Each photo submission inserts a row into the new Supabase table `photo_reviews` with status `'pending'`, including team identity, location, GPS distance at the moment of submission, points awarded, and the compressed thumbnail.
- Points are awarded **provisionally** on submit (so play continues uninterrupted). A yellow `⏳ X foto's in beoordeling` badge appears on the team's own leaderboard view.
- **New 4th admin tab "✅ Beoordeel"** — visible only with `?admin=true`. Shows pending photos as cards with team header + colour border, location, challenge title + type + points, the photo (or placeholder), GPS distance colour-coded (green ≤50m, yellow ≤70m, red further), timestamp, and ✗ Afkeuren / ✓ Goedkeuren buttons. Confirm dialog on reject.
- **Realtime push** via two new Supabase channels: `reviews_insert` (admins see new pending rows; teams see their own pending count increment) and `reviews_update` (admins remove approved/rejected rows from queue; teams get a toast and score is decremented when their photo is rejected).
- Tab bar badge: red number on "Beoordeel" tab matching pending count.

V6 was end-to-end verified on 14 April 2026 by inserting a test row directly in Supabase and confirming it pushed into the admin queue without a page reload.

**Test row left in the queue:** `team_name='Test Team'`, `location_name='Erasmusbrug'`, `challenge_title='Realtime test foto'`, `points_awarded=25`, `gps_distance=42`. Approve or reject it from the admin tab to test the full reject-deduct flow. Or delete it via SQL: `DELETE FROM photo_reviews WHERE team_name='Test Team';`.

### V7 — wrong-quiz "one shot" rule
Path: `stadsspel-rotterdam-v7.html`
Branding: V7 splash. Mike pushed back on the original V7 design (penalty + cooldown + retry); his version is cleaner: one shot, wrong = 0 pts, marked done, move on. "Knowledge tested and rewarded. Wrong is wrong."

Behaviour:
- Quiz card now shows "⚡ Eén kans — fout gegokt = 0 pts" subtitle so teams know the stakes
- Correct answer → green highlight + "✅ Correct! +N pts" → standard completion (with FIRST_BONUS if first)
- Wrong answer → choice goes red, **the correct answer is highlighted green with "← juist" label** for 2.5 s (`QUIZ_WRONG_FEEDBACK_MS`), then the challenge is marked done with 0 pts
- `completeChallenge` had to be updated: when `pts === 0`, skip FIRST_BONUS, skip score increment, don't update Supabase team score, but still mark `completed[locId][chIdx] = true`
- Activity feed: "[Team] zat ernaast bij \"[quiz]\" ([location]) · 0 pts" — public shame
- Toast: "[emoji] ❌ Fout · 0 pts"

### V7.1 — two hotfixes
Same `stadsspel-rotterdam-v7.html` file (V7.1 added in-place; V8 is next versioned file).
Branding: V7.1 splash.

**Fix 1: quiz-only locations are now reachable.** The quiz-lock rule (quiz locked until a photo at this location is done) had a pre-existing bug: locations with NO photo/video/creative challenge (Spido Kade, BlueCity, Willemswerf) were permanently blocked. Fix: lock now only triggers when the location has at least one photo challenge. New `hasAnyPhoto` flag in `ChallengeSheet`. Locked condition: `isQuiz && hasAnyPhoto && !hasPhotoCompleted`.

**Fix 2: bulletproof one-shot quiz lock.** Mike noticed that on mobile he could tap two answers before the second was blocked. Root cause: React `setQuizAnswer(opt)` is async — between first click and React's re-render, a fast second tap can sneak through because the closure still sees `quizAnswer === null`. The `disabled` attribute alone doesn't catch all mobile tap-event quirks. Fix: added `quizLockRef = useRef(false)` — synchronous lock that wins any race. Set on first tap, checked at handler entry. Plus CSS `.quiz-option:disabled { pointer-events: none }` defense-in-depth.

### V8 — coordinate accuracy pass
Path: `stadsspel-rotterdam-v8.html` (105.6 KB)
Branding: V8 splash.

**Why:** Mike noticed many POI markers were in the wrong spot on the map. He sent a deep-research document recommending PDOK BAG / Overpass / OpenStreetMap as authoritative geometric sources.

**What changed:** All 102 location coordinates were verified against Nominatim (OSM's geocoding API) via the browser. Results:
- 70 locations were 10-500m off → auto-corrected with OSM coordinates
- 3 locations were 500-660m off (SS Rotterdam 660m, Depot Boijmans 590m, Entrepotgebouw 501m) → manually verified the OSM hit was the right POI, also corrected
- 2 locations were already within 10m (Koopgoot, Wereldmuseum) → unchanged
- 27 locations not found in OSM by name (mostly small statues, art pieces, restaurants, bars) → unchanged, original coords kept

**Total: 73 of 102 coordinates were corrected.** The biggest fixes:
- Erasmusbrug: 400m off → now on the actual bridge
- Maastunnel: 468m off → now on the tunnel entrance
- SS Rotterdam: 660m off → now at Katendrecht dock
- Depot Boijmans: 590m off → now at Museumpark
- Entrepotgebouw: 501m off → now at Entrepothaven

Spot-checked visually on the live map: Markthal, Kubuswoningen, Rotterdam Centraal, Maritiem Museum all land on their actual buildings now.

**Verification artifacts saved:**
- `verify_coords.py` — original sandbox script (didn't work, sandbox blocks Overpass)
- `shifts.json` — the 73 coordinate corrections
- `locations_v7.json` — the original 102 locations as JSON
- `patch_v7_to_v8.py` — the patcher script
- `Stadsspel-V8-Coordinatenrapport.docx` — full diff report for Mike

**How verification was actually done:** Sandbox (`urllib.request`) cannot reach Overpass (proxy 403s). Workaround: ran the Nominatim queries from inside the Chrome browser via `javascript_tool` (CORS is open). 102 sequential fetches at 1.1s rate-limit, took ~2 minutes. Background job pattern with progress polling (so each `javascript_tool` call stays under the 45s timeout).

**The 27 NOTFOUND locations** (might still be wrong, manual review recommended):
15 Standbeeld Erasmus, 17 Zadkine Monument, 24 Fikkie de Hond, 26 Sylvette (Picasso), 27 Cascade (Van Lieshout), 28 Make It Happen Mural, 29 ZOHO Letters, 39 Walk of Fame, 40 Chinatown Poort, 46 Spido Kade, 50 Rijnhaven Drijvend Bos, 61 BlueCity, 62 Het Slaakhuys, 63 Gebouw Delftse Poort, 65 Concertgebouw De Doelen, 67 Geldersekade Panorama, 69 Arminius Kerk, 73 De Après Skihut, 75 Vessel 11, 78 Hitz, 82 Poppodium Annabel, 84 Sugo Pizza, 86 Vapiano, 88 Historisch Delfshaven, 90 Standbeeld Piet Hein, 91 Historische Tramhalte, 96 Haagsche Veer.

### V9 — progression unlocks
Path: `stadsspel-rotterdam-v9.html` (~113 KB)
Branding: V9 splash.

Three new mechanics built on top of the existing leaderboard/ghost/score systems:

**1. Bonus Ghost Mode charges via score milestones.** New constants:
```
GHOST_BONUS_THRESHOLDS = [
  {score:100, charges:1, label:'+1 Ghost lading op 100 pts'},
  {score:250, charges:2, label:'+2 Ghost ladingen op 250 pts'},
]
```
Implementation: `ghostMax` is now React state (initialized at GHOST_MAX_USES=3). A useEffect watching `scores[myTeam.id]` triggers the unlock by adding to `ghostMax` and recording the milestone in `unlockedMilestones` Set so it doesn't re-fire. The Ghost button on the map now reads `ghostMax - ghost.used` instead of `GHOST_MAX_USES - ghost.used`.

**2. Tier badges based on completed challenge count.** New constants:
```
TIER_BADGES = [
  {min:20, badge:'🏆', name:'Legende', color:'#ffd700'},
  {min:15, badge:'🥇', name:'Goud',    color:'#ffd700'},
  {min:10, badge:'🥈', name:'Zilver',  color:'#c0c0c0'},
  {min:5,  badge:'🥉', name:'Brons',   color:'#cd7f32'},
]
```
Helpers: `tierFor(count)` returns the highest tier achieved; `nextTier(count)` returns the next one to aim for. Each team's leaderboard card renders a `.tier-badge` next to the team name when their challenge count crosses ≥5. NOTE: only the local user's challenge count is accurate; other teams' tier comes from `t.challenges_completed` Supabase field which currently isn't populated by V4-era schema. So in practice, only own team shows the live tier; other teams will only show a tier if Supabase grows that column.

**3. Center-screen unlock popup + activity feed.** When either an unlock fires (Ghost or tier promotion), `unlockPopup` state is set with `{emoji, label, name}`. Renders a `.tier-unlock-popup` div with animated emoji + "GHOST UNLOCK" or "NIEUWE TIER" label + the reward name. Auto-dismisses after 3.5s. Also adds a public activity-feed entry so other teams see the achievement.

**4. "Volgende beloning" banner** at the top of the leaderboard. Computed in `LeaderboardView` from `myChallengesDone`, `myScore`, and the next-milestone helpers. Shows the closest reward (next tier or next Ghost charge) with progress bar. If max tier reached, switches to "MAX TIER BEHAALD".

**Bug to be aware of:** the Ghost-unlock useEffect uses `[scores, myTeam]` deps. If `scores` updates very rapidly (e.g., during testing with admin score-overrides), multiple unlocks could fire in the same render — mitigated by `unlockedMilestones` Set check, but worth re-testing if V10 admin polish adds score override.

### V10 — audit hardening + gameplay upgrade
Path: `stadsspel-rotterdam-v10.html` (~131 KB)
Branding: V10 splash.

**Context:** A full audit of V9 was conducted (see `Stadsspel-V9-Audit.docx`). Mike also clarified the real audience: **35-50 year old men, majority 35-38, all male** (not the 22-45 I originally guessed). Mike's direct note: "momenteel is het nog wat karig qua speel ervaring" — the play experience needed to become substantially richer.

V10 bundled all the audit fixes PLUS major gameplay/content additions. Every change:

**Audit fixes:**
1. **Narrative order bug fixed** (P1). The PROLOOG modal used to be overwritten by Fase 1 modal after 1.2s because startGame() set intro and setPhase(1) simultaneously. Fix: added a `nextStory` queue state + dispatcher useEffect that waits for `storyShown` to clear before showing the next story. Sequence now: intro → user clicks Verder → fase1 shows after 600ms.
2. **Wrong-quiz visual differentiation**. Added parallel `completedPts` state. Challenge cards now get either `.completed` (green) or `.wrong-done` (red) class. Quiz that was answered wrong shows "✗ Fout gegokt · 0 pts · antwoord: [correct]" in red. Correct quiz shows "✓ Voltooid (+25 pts)" in green.
3. **Splash copy**: "1 held" → "1 winnend team".
4. **Admin token**: `?admin=true` still works, plus `?admin=vriendvanjorik` as a harder-to-guess token. Mike should use the token URL and share only the plain URL with players.

**New gameplay layers:**
5. **Jorik tracker system** — jorikTeamId state + moveJorik callback. Game Master Controls panel in Beoordeel tab has one button per team + "alleen" option. Selection broadcasts via `[JORIK] team=X` system message in activity_feed (parsed by all clients to sync jorikTeamId). When myTeam.id === jorikTeamId, jorikInTeam becomes true → wedding-video banner auto-hides. Also announces human-readable "Jorik gaat mee met X" in the feed.
6. **Bar-break overlay** — admin types a bar name + clicks 🍺 Start in Game Master Controls. All teams see a full-screen overlay with 3 mini-challenges: Proost (+25 pts, group beer photo), Shot Roulette (+35 pts, random team member takes a shot on video), Bar Karaoke (+40 pts, 1 min of Dutch singing). Each team can complete all three independently. "Door met spelen" button closes.
7. **Finale ceremony screen** — phase 5 trigger via "🏆 Start Finale & Ceremonie" admin button. Shows gold-gradient full-screen takeover with animated winner reveal (emoji floats, winner color highlight), full ranking list with tier-styled rank colors, "📸 Momenten van de dag" photo grid (up to 9 photos), and a closing paragraph "🥂 Proost op Jorik" explaining that videos/photos become a wedding surprise.
8. **Emoji reactions on activity feed** — 🔥 👏 💀 😂 🍻 buttons on every activity row. Local-only state (not synced across phones) — sufficient to make the feed feel alive without needing a new Supabase table.
9. **Negative-point styling** — feed entries with negative points now show in red (e.g., photo rejection toasts).

**Content punch-up (adult male audience):**
Replaced 9 challenges that read as kid-oriented with more grown-up equivalents:
- Koopgoot Mannequin Challenge → "Interview shopper over slechtste aankoop ooit"
- Marten Toonder "Bommel pose" → "Dronken toespraak tegen Heer Bommel"
- Fikkie de Hond "Baasje pose" → "Slechtste huwelijksadvies fluisteren in Fikkie's oor"
- Westersingel "Tel eenden" → "Parkbank biecht: meest gênante moment met Jorik"
- De Gele Kanarie "Kanarie pose" → "Cheers met twee onbekenden aan de bar"
- Chinatown "Kung-fu poses" → "Maffia-plaatje onder de poort"
- THOMS "Groepsfoto met drankje" → "Speciaalbier-test (blind proeven)"
- Biergarten "Oktoberfest imitatie" → "PROSIT in Duits accent tegen buurtafel"
- Natuurhistorisch "Dino pose" → "Uitstervende mannensoort: fossiel-pose"

**Open P2 item intentionally left for Mike:**
- Wedding mission script — placeholder remains ("Het script wordt later nog toegevoegd"). Mike needs to write the actual instructions for the surprise wedding video.

**Supabase cleanup SQL**: `supabase-v10-cleanup.sql` empties all test data (photo_reviews, activity_feed, teams, completed_challenges) and resets game_state. Mike runs this before gameday.

**Chrome extension was disconnected during final verify**; Mike visually confirmed V10 is live in his browser.

### V11 — (interim build, audited but superseded by V12)
Path: `stadsspel-rotterdam-v11.html` (~141 KB, 2262 lines)
Branding: V11 splash. Was deployed live at https://mikezuidgeest.github.io/stadsspel-rotterdam/ on 17 April 2026 when the full multi-user audit began.

V11 bundled a "Premium HUD" pass on top of V10 (compact nearby panel, cleaner tab icons, slightly denser header, colored dot markers with category color not emoji) and a few copy tweaks. No new backend features over V10.

On 17 April 2026 Mike asked for a full multi-user audit. The audit (`Stadsspel-V12-UX-Audit-v2.md`) surfaced 4 game-breaking multi-user bugs plus 40+ screen-level UX issues. V11 shipped with:
- No INSERT subscription on `teams` — new teams never appeared on other phones.
- No initial `sb.from('teams').select('*')` on mount — each browser tab started empty.
- The `game_state` table **was never read or written anywhere in the code**. Admin's "START HET SPEL" was purely local — every other phone stayed in the lobby forever.
- Starter-pack collision detection relied on the local `teams` array (empty on every tab), so two phones could both pick "De Maffiosi" and would both get counted on the leaderboard as separate teams with split scores.
- Bar-break overlay and Ghost Mode state never broadcast to other phones.

Full audit + v2 improvement list lives in `Stadsspel-V12-UX-Audit-v2.md`. Intermediate audit report: `Stadsspel-V11-UX-Audit.docx` (Mike's prior doc).

### V18 — "all open audits closed" pass (4-eye verified)
Path: `stadsspel-rotterdam-v18.html` → copied to `index.html` for deploy.

> **Correction (retrofitted 18 Apr evening).** The "no SQL migration needed" claim below was
> true for the v18 base but has been invalidated by the V20/V21/V22 patches layered on top.
> See the V19–V22 sections further down — the running v18.html now requires the cumulative
> schema up to and including `SUPABASE-CATCHUP-PATCH-V22.sql` (applied) and the V20/V21
> migrations. `loc_id` is now actually stored (V21), not stripped. See §4 Supabase schema
> section (also retrofitted) for the current truth.

Worked through every open audit item in five batches (each verified by an independent subagent pass):

- **Batch 1** — 18 P0/P1 fast fixes from V12 + V14 audits (rename starter pack, member→captain chips, "Wissel team" escape, story ticker, reward banner copy, pending-review chip + tooltip, "Waarom?" google-link on wrong quiz, approve-confirm for suspicious photos, Jorik button horizontal scroll, bar-break minimize chip, bar-break copy fix, finale photo carousel, winner readability overlay, wedding retake, quiz-lock POI unlock chain, team card min-height).
- **Batch 2** — HUD label clarified (was "0/102"), Leaflet.markercluster added, leaderboard podium polish (silver/bronze + 🥇🥈🥉).
- **Batch 3** — FINALE pulsing banner (phase===4), phase-3 narrative de-staled (Ghost Mode → Extra Tijd).
- **Batch 4** — "👀 Andere teams" feed filter, finale MVP sub-awards (Foto-koning, Video-regisseur, Ontdekkingsreiziger, Grootste schot), Web-Share finale button, admin Pauze/Hervat (via broadcast).
- **Batch 5** — Rotterdam Deck sticker collection on leaderboard.

**Explicitly deferred (see DEPLOY-V18.md for reasons):** duels full UI, SW push, per-player avatars, daily-mode, two-way banter, motion sensors, per-challenge example photos, shop/economy.

**One concrete bug caught + fixed by audit:** `FinaleScreen` awards depended on `a.loc_id`, but `addActivity` never stamped it. Now `addActivity(msg, pts, photo, locId)` takes an optional loc id, `completeChallenge` passes it, and the Supabase insert strips it before send.

Babel transform passes clean on the full single-file JSX.

**Deploy:** `DEPLOY-V18.md` — one step (drag index.html onto GitHub upload).

### V18-hotfixes — session resilience (rolled into v18.html; originally labelled "V19" — retitled after the real v19.html shipped)
Four fixes on top of V18: `storySeen` persistence across reload, team-delete bug where
re-creating a deleted team ID left the old row live, `myTeam` re-link after reload when
the local stored team id still exists on server, and a `teams` DELETE realtime channel
so a GM-deleted team disappears on every phone instantly. No new HTML file — all
patches applied directly to `stadsspel-rotterdam-v18.html`.

### V19 — Jorik bar-break rotation + discoverability + never-twice guarantee (19 Apr 2026, evening)
**File:** `stadsspel-rotterdam-v19.html` (SHA256 `cdc57cedf61a5b490f27e8028ab8aa41278541f0cb2eee74f820923203aa9f83`, 329,805 B — includes never-twice guarantee addendum). `index.html` byte-identical.

Mike flagged that the Jorik mechanic was effectively invisible: players never knew which team started with him, the wedding-mission banner seemed to always show, and the 8 Jorik-specific missions were hidden behind a single banner on the leaderboard tab. He also wanted the rotation rule to be bar-break-only, not timer-based.

**Changes:**
- **Removed 30-min `JORIK_ROTATE_MS` auto-rotate watcher.** Jorik no longer moves on a timer. Constant deleted, useEffect stub commented at `v19:2240-2241`.
- **Added bar-break → random non-holder Jorik swap.** Inside `triggerBarBreak`, fetches `jorik_team_id` + team list from Supabase, filters out current holder + spectators, picks random, calls `moveJorik`. Routed via `moveJorikRef` to keep the callback's deps array stable (`v19:2319-2344`).
- **Admin manual swap preserved.** All admin UI wiring unchanged — onMoveJorik still active.
- **Random starting team** (was first non-spectator — now random). `v19:2646-2652`.
- **Loud start announcement** — activity_feed gets `💍 Jorik begint bij {emoji} {name}! Veel succes met de 8 Jorik-missies!` plus the canonical `[JORIK] team={id}` marker for late-join sync. `v19:2662-2674`.
- **Jorik-arrival toast + haptic** — rising-edge detect on `jorikInTeam`, fires `setToast('💍 Jorik komt bij jullie team — 8 extra missies beschikbaar!')` + 5-pulse vibration. First-mount suppressed via undefined-sentinel ref. `v19:2172-2187`.
- **Kaart tab mirror banner** — compact copy of the leaderboard Jorik-missies banner placed above the TaskList so players out hunting see it without switching tabs. `v19:3775-3796`.
- **Countdown UI removed** — leaderboard banner now says "🍻 Hij blijft tot de volgende bar break — haast je!" and non-holder chip shows static "tot bar break". `v19:3516`, `v19:3535`.

**No schema migration.** `jorik_team_id` + `jorik_moved_at` already exist since V21 P0 / V27 P0-A.

**Decision log (AskUserQuestion 19 Apr):**
- Rotation rule: RANDOM non-holder, NEVER-TWICE (every non-spectator team holds Jorik at most once per game).
- Starting team: RANDOM eligible.
- Timer fallback: REMOVED entirely.
- Overtime (hypothetical — Mike's plan is 4 teams × 3 breaks = never triggers): pool falls back to "any non-current-holder" so Jorik still moves.
- Admin override: UNRESTRICTED. Manual moveJorik can target any team; the [JORIK] marker it writes keeps history coherent.

**Never-twice implementation (`v19:2319-2364`):** derives history from the `activity_feed` `[JORIK] team={id}` markers (already written by both `startGame` and `moveJorik` — zero schema change). `Promise.allSettled` so a flaky feed query degrades to V19 base rule instead of skipping the rotation. Monte-Carlo verified: 5 000 trials of 4-teams × 3-breaks produced 0 duplicate-visit sequences.

**Audit:** see `audit-v19-jorik-rotation-20260419.md` — Layer A ✅ PASS (JSX transpiles clean, all 6 changes verified with line refs), Layer B ✅ PASS (this entry documents it), Layer C ⏳ pending Mike's git push.

**Deploy:** `git add index.html stadsspel-rotterdam-v19.html && git commit -m "V19: bar-break-only Jorik rotation + start announcement + arrival toast" && git push`. After push, run the live Layer C probes documented in the audit file.

### V20 — full P0 batch + SQL migration (18 Apr morning)
Driven by `AUDIT-V20.md` which catalogued 17 P0 blockers. Applied:
- **Atomic score RPC** `increment_team_score(p_team_id INT, p_delta INT)` — replaces the
  last-write-wins read-modify-write pattern (verified live: RPC exists, parameter types
  confirmed via probe).
- **Phase 4 admin button** — GM can now manually trigger FINALE, previously phase 4 was
  dead code.
- **`activity_feed` rehydration on mount** — feed used to start empty after reload.
- **`activity_feed.loc_id`** — actually written to DB now, not stripped; FinaleScreen MVP
  awards depend on it.
- **In-memory activity feed cap raised 50 → 500** so FinaleScreen has enough data to
  compute MVP sub-awards even for a 3-hour game.
- **`completed_challenges` rehydration on mount** — refresh no longer lets a team re-solve
  a quiz for double points.
- **Photo-rejection dedupe** — fixed the double-penalty race where both the
  `applyScoreDelta` path and the `reviews_update` realtime handler subtracted points.
- **`jorik_moved_at TIMESTAMPTZ`** in game_state — Jorik rotation clock now persists, no
  longer reset by GM tab refresh.
- **`spectator` column** on teams (used by underdog-bonus eligibility filter).
- **Bar-break client watchdog** — overlay auto-clears if timer expires.
- **iOS GPS `watchPosition` fallback** — older iOS Safari versions.
- **Modal a11y batch** — focus trap, escape-to-close, aria roles.
- **Streak/reject-feed/phase5-beforeunload** P1 batch.
- **UX P1 batch** — confirm/prompt/backdrop fixes, no more native `confirm()`.
- Migration SQL: `supabase-v20-schema.sql`.

### V21 — tightening pass + `gm_heartbeat`
- **`gm_heartbeat TIMESTAMPTZ`** in game_state — GM tab writes every 30s so teams can
  detect a GM-offline condition (UI chip for that is still pending, task #50 vicinity).
- **GPS double-fire** hardened (snap-to-POI was firing twice on some Androids).
- **Bar-break race** further dedupe when two players tap "start bar break" within 1s.
- **Canvas aspect** fixed (photo preview was stretched on portrait-camera phones).
- **Bar-break idempotency** + pack-rename case.
- **Camera hint** + canvas exception catch.
- Migration SQL: `supabase-v21-schema.sql`.

### V23 — three P0 closeout patches (18 Apr evening, post-multi-agent-audit)
Applied directly on top of `stadsspel-rotterdam-v18.html`. No new HTML file; `index.html`
re-synced byte-identical (SHA256 verified). File grew 299,012 B → 302,996 B (+3,984 B).

1. **#48 Winner tiebreaker.** FinaleScreen's sort was single-key (`b.score-a.score`) —
   ties were resolved by insertion order. Added a top-level `rankTeams(teams,scores,activityFeed)`
   helper (near `isVideoData`) that sorts by score desc, then earlier last-completion
   timestamp, then more challenges completed, then earlier team creation order.
   FinaleScreen now reads from this helper via `React.useMemo`.
2. **#52 Finale celebration trigger.** The `celebrate({big:true,...})` primitive (confetti
   + audio + haptic) existed but `FinaleScreen.mount` never fired it. Added a
   `useEffect` keyed on `[phase,teams,scores,activityFeed,celebrate]` that fires exactly
   once when `phase===5`, using `rankTeams(...)[0]` to pick the same winner the
   FinaleScreen will render. A `useRef` latch prevents double-fire on re-render.
3. **#49 Photo-review commit error toast + retry.** Approve/reject commits at 1731/1740
   were bare `.update()` with no error handler — silent failures left photos stuck in
   queue after admin thought they were processed. Added `commitReview(r,newStatus,sideEffects)`
   wrapper: single 600 ms retry; on final failure, re-queue the photo and show
   `⚠️ Kon foto niet <verb> — terug in wachtrij. Probeer opnieuw.` toast. Crucially,
   side-effects (score delta + reject activity feed insert) only run on a successful
   commit — prevents the photo-rejection double-penalty race from silently re-emerging
   when the update actually failed.

All three changes pass Babel transform (354 KB output, no syntax errors).

**V23 Master Audit Cross-Check verdict — ✅ DONE (3/3)** (18 Apr, post-push):
- Layer A (code): Babel clean, markers `rankTeams` ×5, `commitReview` ×3, `finaleCelebratedRef` ×4, `V23 (#48/#49/#52)` all present.
- Layer B (docs): PROJECT-MEMORY V23 section written; tasks #48/#49/#52/#63/#64/#65/#66 closed.
- Layer C (runtime): Served HTML on GitHub Pages has all V23 markers. Byte parity: local `index.html` = served HTML (SHA256 `01f9e7b3…2afde6`, 302,996 B, 4,794 lines, UTF-16 length 296,673). Supabase probes — `photo_reviews` 200 (cols incl. `reviewer_notes`, `points_awarded`), `activity_feed` 200, RPC `increment_team_score(p_team_id,p_delta)` 200.

**Cross-agent challenge, round 1 (Layer C error — self-retracted):** I probed `/rest/v1/gm_heartbeat` as a table, got 404 PGRST205, opened P0 #67 calling it a missing-table bug. Round-2 re-probe (same Layer C, triggered by reading the client code while drafting the schema): `gm_heartbeat` is a **column** on `game_state`, not a table. Client writes it via `sb.from('game_state').update({gm_heartbeat:ts}).eq('id',1)` (v18.html:2556). Re-probe `game_state?select=id,phase,gm_heartbeat&id=eq.1` → 200, heartbeat age 43 s (admin tab actively writing every 30 s). V21 migration was applied correctly; feature is live. #67 closed as retracted. **Lesson:** always derive the probe shape from the client's actual call site, not from the column/table name in isolation. The protocol's cross-challenge caught the mistake before it hit Mike's hands.

**Cross-agent challenge, round 2 (also self-retracted):** I then opened P2 #68 claiming `photo_reviews` had no CREATE TABLE anywhere, making the project non-reproducible. Round-3 check: read `supabase-v6-schema.sql` — CREATE TABLE IF NOT EXISTS is fully defined at lines 7–25 (PK, all 14 base columns, CHECK on status, 3 indexes, 3 RLS policies, realtime publication entry). V22 catch-up adds `challenge_id` / `photo` / `reviewer_notes` via idempotent `ALTER TABLE ADD COLUMN IF NOT EXISTS`. v6 + v22 together fully reproduce current prod shape from SQL. #68 closed as retracted. **Lesson 2:** before opening a "missing schema" ticket, grep all numbered schema files — not just the recent ones. Prior summary's claim that photo_reviews was not codified anywhere was inherited without verification.

**Residual findings after both cross-challenges:** none. V23 is clean; prod schema is fully reproducible; gm_heartbeat is live.

### V32 + V31.1 — Refresh-persistence deep-test fixes (19 Apr 2026 afternoon, post-V31)
**Trigger:** Mike asked "did we already find a solution for people refreshing their tab during the game?" → followed by "prove it, don't do any assumptions, really test deep." That produced `refresh-persistence-test-20260419.md` — a six-scenario Layer-C empirical test against the live deploy + a Supabase round-trip using the real `window.sb` via Chrome MCP `javascript_tool` and React-fiber-state walking. Five scenarios passed outright (happy-path reload, bar-break reload, empty-localStorage, iOS private-mode detection, 12-hour expiry). One scenario surfaced a UX gap (pending photo counter lost on refresh). A seventh finding fell out of the test seeding (V31 trigger under-counts `locations_visited` on multi-row INSERTs). An eighth surfaced accidentally via a phantom localStorage session. Mike replied "fix the bugs you found, and run another ghost smoke audit afterwards. We must be certain everything works as it should. no exceptions" — which produced this batch.

**Files touched:**
- `stadsspel-rotterdam-v18.html` → 323,294 B (SHA256 `f4d24a2146e5582b2043d1d005baf8cff9f147da06f3d800f4f417273440f925`). Three targeted inserts, all idempotent on reload, no refactors.
- `index.html` → byte-identical copy (same SHA256, verified via `shasum -a 256`).
- `SUPABASE-CATCHUP-PATCH-V31.1.sql` → new file, 7,793 B. Idempotent SQL that replaces only the trigger function (V31's trigger binding and table schema remain untouched).

**Three HTML fixes (V32):**

1. **Pending-photo counter rehydrate on mount** (v18.html:1697, ~6 lines inside the mount `useEffect` that already hydrates `completed_challenges`). Before: after refresh, `pendingMine` resets to 0, so the "X foto's in check" banner (v18.html:3373) vanishes until the next realtime INSERT. Data integrity was fine (the `photo_reviews` rows stay server-side), but the player's only signal that a submission is awaiting approval disappears on reload — a submitter who couldn't tell might resubmit. Fix: `sb.from('photo_reviews').select('id').eq('team_id',myTeam.id).eq('status','pending')` → `setPendingMine(res.data.length)`. Silent on error (table missing / RLS block). The realtime INSERT handler at v18.html:1612 continues to keep the counter accurate going forward; this fetch only seeds the initial value.

2. **Pending-photo counter in visibilitychange catch-up** (v18.html:1788, inside the existing V22 visibility-change handler, as "step 6"). Before: if a decision (approve/reject) fired while the tab was backgrounded, the counter stayed stuck at its pre-sleep value until the next UPDATE echo happened to arrive. Fix: identical query to #1, fires on tab-focus. Cheapest query on this table (indexed on `team_id`).

3. **Phantom-team guard on initial teams fetch** (v18.html:1446, inside the teams+game_state fetch at mount). Before: if localStorage held a `myTeam.id` that no longer existed in the DB (admin hard-reset between sessions, team deleted while tab was closed), the app happily rendered the stale team name driven purely by localStorage. All realtime channels would connect to a non-existent id, scores would never arrive, and the player would think their progress was still saved. Fix: after the teams fetch, if `myTeam.id` isn't in `res.data`, call `clearSession()` + `setMyTeam(null)` + `setScreen('splash')` + toast "Je team bestaat niet meer in deze ronde — kies opnieuw." Spectator and id≤0 sentinel cases are skipped by the guard.

**SQL fix (V31.1):**

The V31 trigger function uses `NOT EXISTS (SELECT ... FROM completed_challenges WHERE team_id=... AND location_id=... AND id <> NEW.id)` to decide whether `locations_visited` should increment. In AFTER ROW trigger context this guard does NOT reliably see sibling rows of the **same** multi-row INSERT — PostgreSQL's per-row snapshot semantics mean each trigger invocation sees at most the rows that were already visible when the statement started, plus (for rows of the same statement) varying behavior depending on visibility rules. Observed 19 Apr during test seeding: a 3-row INSERT covering locations `[7, 7, 12]` produced `locations_visited=1` where the correct answer is 2. In-app consequence: the top bar (client-computed from `completed_challenges`) showed "3 POI" while the leaderboard row (DB `teams.locations_visited` via trigger) showed "2 locaties" for the same team at the same moment. **Gameday impact: none** (real gameplay always inserts one row at a time via `submitChallenge`), but the bug is visible from any test harness, bulk-import script, or future seeding path.

V31.1 replaces the function body with a **recompute-from-scratch** approach: every invocation sets `challenges_completed = (SELECT COUNT(*) FROM completed_challenges WHERE team_id=NEW.team_id)` and `locations_visited = (SELECT COUNT(DISTINCT location_id) FROM completed_challenges WHERE team_id=NEW.team_id AND location_id IS NOT NULL AND location_id >= 0)`. Correct under any insert shape. At gameday scale (~400 inserts per game) the extra two small indexed SELECTs per INSERT are sub-millisecond — trivially cheap. `CREATE OR REPLACE FUNCTION` keeps the trigger binding intact; a defensive `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER` follows so a fresh DB that never saw V31 still ends up wired correctly. The patch also includes a one-time heal UPDATE (for any team that drifted under V31) + a zero-out pass for teams with no completions + three sanity SELECTs at the end + a commented post-apply multi-row-INSERT verification recipe. Block A of `SUPABASE-GAMEDAY-RESET.sql` remains unaffected — TRUNCATE bypasses row triggers, and the `UPDATE teams SET challenges_completed=0, locations_visited=0` zeros correctly regardless.

**Layer A (code, static):** ✅
- `index.html` SHA256 matches `stadsspel-rotterdam-v18.html` (`f4d24a2146e5582b2043d1d005baf8cff9f147da06f3d800f4f417273440f925`, 323,294 B).
- Both V32 fetches are guarded against missing `myTeam` / `spectator` / id≤0 and have silent error handlers so a missing table or RLS block can't throw.
- Phantom-team guard skips the spectator + special-id paths and only clears session when the authoritative teams fetch successfully returned a list that doesn't include the stored id — i.e., never triggers on a flaky network fetch (which fails the fetch entirely and leaves `res.data` undefined).
- V31.1 SQL is transaction-wrapped, idempotent (`CREATE OR REPLACE` + `DROP ... IF EXISTS`), and the heal UPDATE is a safe no-op on a clean DB.

**Layer B (context, docs):** ✅
- `refresh-persistence-test-20260419.md` on disk as the evidence trail that drove the three fixes.
- V32 + V31.1 entry added above V31 in this file.
- Inventory row for `SUPABASE-CATCHUP-PATCH-V31.1.sql` added in §5.
- v18.html inventory row updated with new SHA + byte count + V32 note.

**Layer C (runtime, live — 19 Apr 2026 afternoon post-push + post-SQL-apply, verified on tab 242407895 + Supabase project `kybcndicweuxjxkfzxud`):** ✅ all 6 probes green.
  1. Phantom-team guard: seeded `myTeam.id=99999` → post-reload `screen="splash"`, `myTeam=null`, localStorage cleared, toast element present, splash UI rendered ✅
  2. pendingMine mount rehydrate: inserted 1 pending `photo_reviews` row for team 4 → post-reload DOM banner `"1 foto in check"` rendered (requires `pendingMine > 0`) ✅
  3. visibilitychange step 6: installed a proxy on `sb.from`, dispatched `visibilitychange` → `photoReviewsCalls=1` alongside the four pre-existing steps ✅
  4. V31.1 multi-row INSERT `[7, 7, 12]` → `cc=3, lv=2` (V31 would have returned `lv=1`) ✅
  5. V31.1 single-row INSERT `[20]` → `cc=4, lv=3` ✅
  6. V31.1 duplicate location `[7]` → `cc=5, lv=3` unchanged; sentinel `[-1]` → `cc=6, lv=3` unchanged ✅

Cleanup: all 6 test `completed_challenges` rows DELETEd (anon DELETE works on this table), `photo_reviews` id=18 UPDATEd to `'rejected'` (anon can't DELETE — RLS), team 4 counters reset to 0/0, test tab's localStorage cleared. Final drift check: all 4 teams `status = OK`. See `ghost-smoke-audit-v2-20260419.md` §9 for full evidence.

**V32 + V31.1 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (19 Apr 2026 afternoon, client + SQL delivery, live-verified via supabase-js round-trip + React fiber-state inspection + DOM probes on the deployed tab).

### V31 — Smoke-test bug fixes (19 Apr 2026, post-V30.1, SQL-only, awaiting Mike's paste into SQL Editor)
**Trigger:** 19 April smoke-test run (see `smoke-test-v30-20260419.md`) surfaced three medium-severity visible-UX bugs plus schema drift. All fixes are server-side (SQL patch only — no client churn, no HTML re-push needed). The v18 HTML stays at V30.1 byte-parity with GitHub Pages; V31 lives entirely in the Supabase schema.

**File:** `SUPABASE-CATCHUP-PATCH-V31.sql` — idempotent, runs as one BEGIN…COMMIT with a sanity-output SELECT block at the end + a step-by-step in-page verification recipe in a trailing comment block.

**Four bugs fixed:**

1. **BUG-SIM-005 (medium) — `teams.challenges_completed` never incremented.** Read at `stadsspel-rotterdam-v18.html:3455` for other-teams tier display on the leaderboard. Never written by any client path and no existing trigger. Sim confirmed: 9–11 `completed_challenges` rows per team, but `teams.challenges_completed` stayed at 0 for all four → other teams' tier badges would show tier 0 forever on gameday. Fix: `AFTER INSERT ON completed_challenges` trigger `update_team_stats_on_completion()` does `UPDATE teams SET challenges_completed = challenges_completed + 1 WHERE id = NEW.team_id`.

2. **BUG-SIM-005b (medium) — `teams.locations_visited` never incremented.** Same failure mode as 005, read at `stadsspel-rotterdam-v18.html:3475` ("`{teamChallenges} challenges · {t.locations_visited||0} locaties`") and never written. Fix: same trigger function increments `locations_visited` only on the **first** completion per `(team_id, location_id)` pair, and skips the sentinel `location_id = -1` that the client uses for non-location-bound pseudo-challenges (v18.html:2912). Backfill `UPDATE teams` with `COUNT(*)` / `COUNT(DISTINCT location_id)` handles any pre-existing rows.

3. **BUG-SIM-001 (low) — `teams.members` column missing.** PGRST204 on insert with `members` field. The v18 client has graceful fallback (v18.html:3032-3035: try-with-members, retry-without on error) so teams still create successfully — but member rosters exist in React state only, not in the DB, so a fresh-device login sees an empty roster. Fix: `ALTER TABLE teams ADD COLUMN IF NOT EXISTS members TEXT[] DEFAULT '{}'`. Client's existing retry path becomes a no-op once the column exists; member names now persist.

4. **BUG-SIM-002 (medium) — schema drift, orphan columns.** Incomplete V14→V30 migrations left duplicate columns that the client never reads. Grep confirmed 0 references to each:
   - `completed_challenges.first_to_complete`, `.is_first`, `.photo_data`, `.photo`, `.points`, `.first_bonus`, `.loc_id` — DROP
   - `photo_reviews.photo` — DROP (client uses `photo_url`)
   
   V31 does `ALTER TABLE … DROP COLUMN IF EXISTS` for each. Risk: if any analytics query or Postgres function depends on a dropped column, the DROP fails on dependency error — in that case comment the offending line and investigate before re-running. Sim-verified client write paths unchanged: `completed_challenges` still accepts `{team_id, challenge_id, location_id, challenge_type, points_earned}`, `photo_reviews` still accepts the current 15 live columns.

**Not fixed in V31:**
- BUG-SIM-006 (low, `teams.family_messages_seen` orphan column) — left in place pending decision on whether to implement the family-messages read-receipt feature. Dead-schema cleanup can happen later.

**Sim re-run plan (Layer C verification once Mike applies):**
1. INSERT 1 `completed_challenges` row for De Zeehelden at `location_id=1` → expect `teams.challenges_completed = 1` and `teams.locations_visited = 1`.
2. INSERT a 2nd row at same `location_id=1` → expect `challenges_completed = 2`, `locations_visited` stays at 1.
3. INSERT a 3rd row at `location_id=2` → expect `challenges_completed = 3`, `locations_visited = 2`.
4. INSERT a 4th row at `location_id=-1` (sentinel) → expect `challenges_completed = 4`, `locations_visited` stays at 2.
5. `sb.from('teams').update({members:['Alice','Bob']}).eq('id',3)` → expect 204, no PGRST204.
6. Re-probe `completed_challenges` columns → expect 14 → 7 live columns (id, team_id, challenge_id, location_id, challenge_type, points_earned, completed_at).
7. Re-probe `photo_reviews` columns → expect 19 → 18 (drop `photo`).
8. Run Block A cleanup → verify all stats zero cleanly (trigger is AFTER INSERT only, does not interfere with TRUNCATE + UPDATE teams reset).

**Layer A (code, static):** ✅ — SQL patch is idempotent (`IF NOT EXISTS` / `IF EXISTS`), trigger drops-and-recreates on re-run, backfill is a safe no-op on empty bookkeeping tables. Transaction-wrapped.

**Layer B (context, docs):** ✅ — this V31 section added above V30; `smoke-test-v30-20260419.md` remains on disk as the evidence file that triggered the patch; inventory row for `SUPABASE-CATCHUP-PATCH-V31.sql` added at top-of-file.

**Layer C (runtime, live — 19 Apr 2026 post-apply, live-verified on `kybcndicweuxjxkfzxud.supabase.co`):** ✅ all 8 steps green:
1. INSERT at location_id=1 → `challenges_completed=1, locations_visited=1` ✅
2. INSERT at location_id=1 → `cc=2, lv=1` (no per-location double-count) ✅
3. INSERT at location_id=2 → `cc=3, lv=2` ✅
4. INSERT at location_id=-1 sentinel → `cc=4, lv=2` (sentinel correctly skipped by `IF NEW.location_id >= 0`) ✅
5. `UPDATE teams SET members=['Thijs','Rick','Bram','Milan']` → 204, array persists and reads back correctly ✅
6. `completed_challenges` column count: 14 → **7** (id, team_id, challenge_id, location_id, challenge_type, points_earned, completed_at). All 7 orphans (`first_to_complete, is_first, photo_data, photo, points, first_bonus, loc_id`) dropped cleanly ✅
7. `photo_reviews` column count: 19 → **18** (orphan `photo` dropped; `photo_url` retained) ✅
8. Block A cleanup still zeros teams cleanly post-patch — trigger is AFTER INSERT only, does not fire on TRUNCATE or UPDATE teams SET ...=0 ✅

**V31 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (19 Apr 2026, SQL-only delivery, live-verified via supabase-js round-trip on admin tab).

### V30 — "Less-is-More" UX simplification (18 Apr 2026, post-V29, code-complete, awaiting Mike's push + SQL patch)
**Trigger:** After V29 shipped, Mike and I agreed that the game had accreted too many systems competing for attention during a 4-hour bachelor-party walk. The Bucket B items deferred from V29 (ranking redesign, bar-moment redesign, scoring clarity) plus a sweeping "do we actually need this on gameday?" pass became V30. Goal: collapse surface area so each tab maps to one mental model and every mechanic earns its place.

**File:** `stadsspel-rotterdam-v18.html` → 319,484 B (SHA256 `b894815a231dbb4ff81bd0aca51b24a5b7b44fddd27ca159d51c6df0c749657f`). Babel transform clean (output 309,977 B). `index.html` byte-identical via `cp` + `shasum -a 256`.

**New DB artifact:** `SUPABASE-CATCHUP-PATCH-V30.sql` — idempotent migration that creates the `feed_reactions` table, flips its replica identity to `FULL`, adds permissive RLS policies, and registers it in the `supabase_realtime` publication. Required before Phase 7 reactions will persist/broadcast.

**Eight phases shipped:**

1. **(Phase 1) Easy deletes.** Ghost Mode (5-min invisibility, 3 uses, bonus charges at 100/250 pts — V4+V9 legacy) nobody ever used in practice, retired to a stub. Quiz streak / hot-streak multiplier (V14 engagement layer) and the 40-minute streak-decay timer — removed: the +5% per-streak-step number was too small to notice and the decay timer added latent anxiety. "Andere teams" filter pill on the activity feed — deleted; Photos + My-team + All was the only split anyone actually used.

2. **(Phase 2) Delete chapter/story modal system.** The "Jorik's verloren trouwring" PROLOOG → FASE 1 → FASE 2 → FASE 3 → FINALE narrative system (V5 centerpiece) always auto-opened when players just wanted to see the map. The chapter ticker on the leaderboard was cute, nobody tapped it. Removed the modal, the auto-open `useEffect`, the ticker, and the chapter data array. Phase transitions now come through via toast + activity feed.

3. **(Phase 3) Delete Hot Target + Extra Tijd.** The 10-minute Hot Target mechanic that V27 had to patch with `expiredHotRef` + `BroadcastChannel('stadsspel-miss')` to stop the 61-row duplicate-INSERT storm. Simpler than fighting the bug: remove the mechanic. Gameplay is already first-finder-bonus + per-team-once rules; the 10-min timer was noise. Removed: hot-target card on map, hot-target toast, expiry watchdog, BroadcastChannel, `expiredHotRef`.

4. **(Phase 4) Level-up modal → inline toast.** V14's level-up modal (fullscreen, ribbon, sparkles) interrupted play every ~500 pts. V29 had already added `lastLevelSeenRef` (useRef latch) to kill the ×3 "Zoeker geworden" duplication on rapid Supabase score echoes. V30 keeps the ref and simply replaces the modal with `setToast('${emoji} Level ${lv} · ${name}')` + an activity-feed line. Progression is communicated without stopping the game.

5. **(Phase 5) Tab restructure — missions → Kaart tab.** Ranking tab was ambiguous: leaderboard + personal task list + mission list all competing. V30 splits: Ranking = pure scoreboard (+ wedding + Jorik-missies cards); Kaart = map on top (fixed `height:48vh`, `minHeight:280`) with `TaskList` scrolling below inside a `overflowY:auto` wrapper. One tab, one question. Because the map is now a positioned child of a scrollable parent, the legend and center-on-me FAB were moved from `bottom:180` → `bottom:10` so they anchor to the map's bottom edge, not the viewport. GPS pill stays at top.

6. **(Phase 6) Bar moments redesign — group photo only.** V10 bar breaks shipped 3 mini-games per bar (karaoke / call-the-bride / ...), session-dedup'd by `seedHash(barName+startedAt)` and `pickNSeeded`. Feedback from Mike: at a bar everyone is physically together; three competitive mini-games create awkwardness instead of fun. Collapsed `BAR_MINI_POOL` (+ seedHash + pickNSeeded) into a single module-scope constant: `const BAR_MOMENT = {emoji:'🍻', title:'Groepsfoto + proost', desc:'Iedereen samen, glazen in de lucht — één foto of video per team.', pts:40}`. `defaultBarMinis()` now returns `[BAR_MOMENT]` regardless of bar name. BarBreakOverlay copy changed from "Drie bonus-opdrachten..." → "Één moment · samen toasten · samen op de foto". Accept filter simplified to `image/*,video/*`. Media upload still writes to activity_feed + completed_challenges (+40 pts once per team per break).

7. **(Phase 7) Feed reactions — real cross-device Supabase state.** Prior to V30, `ActivityView` stored emoji reactions in React state only. Tap 🔥 on your phone → you see it, nobody else does. Real social texture requires real persistence. New table `feed_reactions(feed_key TEXT, device_id TEXT, team_id INTEGER NULL, emoji TEXT, UNIQUE(feed_key,device_id,emoji))`. Design notes:
   - **`feed_key` is a composite text** (`${created_at}|${team_id ?? 'sys'}|${message}`, trunc 300), NOT a FK to `activity_feed.id`, because the client appends optimistic-local rows before the server INSERT lands and never swaps them in — `activity_feed.id` is never known to the author's session. Text composite works identically for optimistic and echoed rows.
   - **`device_id`** is a per-device uuid stored in `localStorage.ssr_device_id` (crypto.randomUUID with a Date-based fallback) so two players on the same team can distinguish their own taps.
   - **`REPLICA IDENTITY FULL`** is mandatory — default replica identity only ships the PK on DELETE, but the realtime subscriber needs `feed_key + emoji` to decrement the counter.
   - **Permissive RLS** (SELECT/INSERT/DELETE all `TRUE`) matches the rest of the project's anon-key trust model.
   - Client wire-up: `useEffect` loads initial counts via `sb.from('feed_reactions').select(...)`, then subscribes to `postgres_changes {event:'*', table:'feed_reactions'}`. `toggleReaction(key, emoji)` optimistically flips local state, then posts INSERT or DELETE; 23505 unique-violation is silently swallowed (retry-safe).

8. **(Phase 8) Scoring clarity labels.** Every challenge card now carries a one-line scoring rule:
   - Regular location challenge: `✅ 1× per team · eerste team +10 bonus`
   - Bonus rotated quiz (repeatable): `♻️ Zo vaak je wilt · elke keer +${rotatedQuiz.p} pts`
   - Bar-moment card: `✅ 1× per team deze break`
   
   Mike's rule: at a single glance, a player must know whether re-tapping costs them or rewards them. Labels are `t-label-sm t-muted` + `letterSpacing:0.3px` so they read as metadata, not primary copy.

**Layer A (code, static):** ✅ — Babel transform output 311,742 B (V30.1) / 309,977 B (V30.0), no syntax errors. `BAR_MOMENT` constant present, `defaultBarMinis` returns single card, `lastLevelSeenRef` still wired, `feed_reactions` table referenced in `ActivityView`, `ssr_device_id` localStorage key set, `feedKey` composite builder present, `reactionRowsRef` lookup map (V30.1), TaskList moved to MapView, Ranking no longer references TaskList.

**Layer B (context, docs):** ✅ — This V30 section added; top-of-file timestamp refreshed. Inventory row for `v18.html` updated to V30.1 SHA256; new `SUPABASE-CATCHUP-PATCH-V30.sql` row added.

**Layer C (runtime, live — V30.0 initial probe, 18 Apr post-push):** Partial (byte-parity + table shape + RLS + unique constraint + publication membership all ✅; only the DELETE-payload check exposed the Supabase realtime metadata-cache quirk — DELETE shipped `{id}` only despite `relreplident='f'`). Fix landed in V30.1 client patch above (reactionRowsRef).

**Layer C (runtime, live — V30.1 re-probe, 18 Apr post-V30.1 push):** ✅ —
- **Byte-parity on live:** served HTML size = 321,139 B exact match to local `v18.html`; `reactionRowsRef` + `V30.1` string markers present in served bundle.
- **App mount:** `root` populated, no runtime errors, V30 simplified 3-tab UI visible (🏆 Ranking / 🗺️ Kaart / 📢 Feed — ZOEKTOCHT/GERUCHTEN/CIRKEL/FINALE are the phase chips up top, not tabs).
- **Platform quirk reproduced + workaround firing:** in-page supabase-js INSERT→DELETE round-trip on `feed_reactions` confirmed DELETE realtime payload `old` = `{id: 8}` only (no feed_key/emoji/device_id) even though `relreplident='f'` and table is in `supabase_realtime` publication. This is exactly the shape V30.1's `reactionRowsRef` lookup map is designed to resolve, and the map is live in the served bundle.
- **Kaart tab (Phase 5):** Leaflet map (520×419 px above fold) + scrollable POI task list below it, sorted by distance with "🧭 VERDER WEG · 89" header.
- **Feed tab (Phase 6/7):** reactions row `🔥 👏 💀 😂 🍻` rendered on every feed item; bar moments shown as single activity-feed card.
- **Scoring-clarity labels (Phase 8):** challenge drawer (ZOHO Letters · Letter Pose) shows `PHOTO` category · title · `+35` reward · `✅ 1× PER TEAM · EERSTE TEAM +10 BONUS` · `★★★ hard` · range indicator — every clarity label rendering as designed.

**V30 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (18 Apr 2026, post-V30.1 push, live-verified):
- **Layer A (code):** ✅ — Babel transform clean 311,742 B; SHA256 `925b6a07a345da5df7ff79ae78adaa10e919b048ec522bb423f92c94492ff113` on 321,139 B / 5,082 lines; all eight phase markers present in source + `reactionRowsRef` workaround landed.
- **Layer B (context):** ✅ — this V30 section complete; top-of-file timestamp amended; inventory rows for `index.html` / `stadsspel-rotterdam-v18.html` / `SUPABASE-CATCHUP-PATCH-V30.sql` current.
- **Layer C (runtime):** ✅ — byte-parity match on `mikezuidgeest.github.io/stadsspel-rotterdam/`; app mounts; all eight V30 phase behaviours visible in live DOM; platform quirk reproduced and V30.1 lookup-map workaround present in served bundle; reaction round-trip confirmed end-to-end via supabase-js on the live page.

Four-way parity holds: `stadsspel-rotterdam-v18.html` = `index.html` = GitHub Pages served bundle = Supabase DB (feed_reactions table + RLS + unique + publication) = PROJECT-MEMORY.md = task list (#85 V30 parent + Phase 1–9 subtasks all `completed`).

### V29 — Bucket A UX bug fixes (18 Apr 2026, post-V28, awaiting Mike's push)
**Trigger:** Mike sent a 9-point UX improvement brief with 5 screenshots after V28 shipped. I triaged into three buckets. Bucket A = 4 clear bugs shippable without design decisions; Bucket B = 4 design-level redesigns requiring Mike's direction (deferred to V30); Bucket C = meta-principle, not a ticket. Mike approved Bucket A with "start with : V29".

**File:** `stadsspel-rotterdam-v18.html` grew 330,385 → 331,999 B (+1,614 B, 5,253 → 5,271 lines). Babel transform clean, output 323,109 B (was 322,084 B). Local SHA256 `bb069f8a9d551c73984d5c3ffcf10cf69b4cd9013a6b846e9a60519782415453`. `index.html` synced byte-identical via `cp` and `shasum -a 256`.

**Four fixes shipped:**

1. **(§1) Level-up activity firing 3×** — Mike's screenshot 5 showed "Beunhazen is level 2 · Zoeker geworden!" three times. Root cause: `lastLevelSeen` was a React `useState` latch inside a `useEffect([scores,myTeam])`. When Supabase realtime pushed back-to-back score updates, multiple effect runs all read the same stale pre-commit closure value of `lastLevelSeen` and each called `addActivity` once before any `setState` had committed. Fix: added parallel `lastLevelSeenRef = useRef(null)` — synchronous read/write. The ref is latched BEFORE `celebrate()` or `addActivity()` fires, so the second, third, Nth firings see the updated level and early-return. `setLastLevelSeen` kept in sync for any renders that read state. Evidence in file: line 1277 (ref declaration), line 2224–2248 (updated useEffect).

2. **(§1) Game-start activity firing 2×** — Mike's screenshot 1 showed "Het spel is begonnen! 🎮" twice. Root cause: `startGame()` had no idempotency guard. If Mike tapped Start twice (muscle memory, "is it broken?"), or a BroadcastChannel tab-echo bounced the intent back to the initiating tab, the function ran twice. Fix: `if(phase>0)return;` at the top of `startGame()`. Evidence: line 2777.

3. **(§3) Duplicate photo display** — Mike's screenshot 3 showed the same submission photo twice. Root cause: `ActivityView` rendered a "Recente foto's" photo-grid preview (lines 4045–4062) BEFORE the main `filtered.map` feed loop — and the feed rows already include their own photo thumbnails. Same photo appeared twice. Fix: removed the photo-grid block entirely. The `📸 Foto's` filter pill still lets the user scope to photo-only activity. Evidence: line 4050 now holds a V29 comment block where the grid used to be.

4. **(§4) ChallengeSheet close friction** — Mike's screenshots 2 and 4 showed challenge detail sheets where the × was easy to miss. Root cause: the existing `✕` was `color:var(--text-tertiary)`, `fontSize:26`, no background, no border. Visible to a dev who knew where to look, invisible to a bachelor-party player on a bar patio. Fix: (a) added `React.useEffect` that listens for Escape on window while the sheet is mounted, calls `onClose`; (b) swapped the dim glyph for a 40×40 circular pill — `rgba(255,255,255,0.08)` background, `rgba(255,255,255,0.14)` border, white glyph, 20px fontSize, `borderRadius:50%`. Backdrop click-to-close was already wired via `<div className="sheet-overlay" onClick={onClose}/>` and is preserved. Evidence: line 4570–4576 (Escape listener), line 4604 (upgraded button). Other sheets (`DialogSheet`, wedding-mission sheet, Jorik-missies sheet) already had both Escape + backdrop click and needed no change.

**What V29 deliberately did NOT touch (Bucket B / deferred to V30):**
- **Ranking tab redesign** — Mike said the current ranking screen overlaps the map and dilutes the leaderboard. Proposed fix: ranking tab shows only the leaderboard + per-team breakdown, missions stay on their own tab. Needs Mike's sign-off on scope before code.
- **Bar moments as group-shared, not team-competitive** — Mike said karaoke / call-the-bride feel out of place because everyone's at the same bar together. Proposed redesign: bar-break overlay swaps to a single shared group challenge per bar (e.g. "Toast to Jorik, upload one group photo, everyone +X"). Needs Mike to pick 3 bar moments first.
- **Personalized Jorik moments at specific GPS points** — Mike wants 2–3 location-specific Jorik prompts (e.g. "at Hotel New York: everyone shares their favourite Jorik memory"). Needs Mike to send lat/long or landmark + the moment.
- **Scoring clarity** — every challenge card should say "✅ 1× per team, +X" or "✅ Zo vaak je wilt, elke keer +X" on a single line. Needs a full-content pass over 30ish challenges; too big for V29.

**Task list:** #82 created, in_progress. #83 will be created when Mike pushes (matches V28 #81 pattern).

**Layer A (code, static):** ✅ — V29 markers ×7, `lastLevelSeenRef` ×5, `if(phase>0)return` ×1, "Recente foto" remaining ×1 (in an explanatory comment describing the removal, not the grid). V28 regressions preserved: `resetGame` ×2, `onResetGame` ×4, `Noodstop` ×1. V27 regressions preserved: P0-A marker ×1. Babel 323,109 B output — clean parse.

**Layer B (context, docs):** ✅ — This PROJECT-MEMORY section added; top-of-file timestamp updated; inventory table below will be updated on the next pass.

**Layer C (runtime, live):** ✅ VERIFIED post-push. Chrome MCP `javascript_tool` + in-page `fetch('/index.html?t=...')` + SubtleCrypto SHA-256 digest on `TextEncoder` UTF-8 encoding of the response text. Status 200. `isMatch=true` — served HTML SHA256 = `bb069f8a9d551c73984d5c3ffcf10cf69b4cd9013a6b846e9a60519782415453` = local. V29 markers ×7, lastLevelSeenRef ×5, phase-guard ×1, Recente-foto ×1 (comment only). V28 preserved: resetGame ×2, onResetGame ×4, Noodstop ×1. V27 preserved: P0-A ×1. Benign residual: `teamCount<2` ×1 — only in V28 explanatory comment, the actual hang-vector code is gone. String length 325,510 (JS UTF-16 code units) vs 331,999 bytes on disk is normal UTF-16-vs-UTF-8-with-emoji size difference; the SHA256 match is the authoritative gate.

### V28 — Admin override: lobby Start + mid-game Reset (18 Apr 2026, post-V27, unshipped)
Symptom Mike reported during live admin smoke-test after the V27 ship + Block B DB reset: "I can't start the game, the button doesn't work. At the moment I just have 1 team in the lobby, but as an admin I must be able to kickstart it or cancel it whenever I want." File grew 327,093 → 330,385 B (+3,292 B, 5,192 → 5,253 lines). SHA256 `c25a26ef…6437`. Babel transform clean (322,084 B output from 274,996 B JSX input).

**Root cause hypothesis:** the admin Start handler in the lobby was `async`-wrapped around a `confirmAsync` call that triggered whenever `teamCount<2`. On mobile / admin-spectator flows the DialogSheet modal can render underneath a still-mounted GPS-denied overlay (zIndex 10000), the private-browsing banner, or a dangling bar-break sheet — making the confirm invisible while the promise waits forever for a button press that can't land. The handler never proceeded to `startGame()`, which to Mike looked like a dead button. V28 strips the gate entirely for admin: admin is Mike, admin knows what they're doing, 0/1 team is a legit dev+demo case, and removing the dialog removes the hang vector.

**Feature shipped alongside:** admin can now cancel/reset a running game from the "🎛 Game Master controls" panel in the Beoordeel tab — a new "⚠ Noodstop" section with a `↺ Reset spel naar lobby (phase = 0)` button. Pushes phase=0 to `game_state`, clears `started_at` / `jorik_team_id` / `jorik_moved_at` / `bar_break_active` / `bar_break_started_at`, broadcasts a "↺ Spel teruggezet naar de lobby door de Game Master" activity_feed row, and sets admin's own screen back to 'lobby'. All other phones snap back via the realtime subscription. Teams + scores + completions are PRESERVED — this is "cancel current run", not "wipe". For a full wipe Mike still runs SUPABASE-GAMEDAY-RESET.sql Block A (soft) or Block B (full).

**What ships (2 fixes):**
1. **Lobby Start button robustness.** Parent file ~line 2882. Removed the `teamCount<2` `confirmAsync` gate + async handler. New handler: `onClick={()=>startGame()}` — synchronous, no dialog, no hang vector. Bonus: the button's ambient `(${teamCount})` suffix already communicates team count, so the warning dialog was redundant UX.
2. **Admin resetGame override.** Parent file ~line 2533 (new `useCallback` right after `startFinale`). Sets local state back to phase=0 + lobby screen, upserts game_state with full null-out, inserts an admin activity_feed row, shows a toast. Graceful 42703 fallback re-tries the game_state update without `jorik_moved_at` for pre-V21 DBs. Threaded into `<AdminReviewView>` via the new `onResetGame` prop. New UI: a danger-styled `↺ Reset spel naar lobby` button inside the Noodstop section of the Game Master controls panel, with a confirm dialog explaining the preserve-teams-preserve-scores semantics.

**V28 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (18 Apr 2026, post-push live-verified):
- Layer A (code): ✅ Babel clean (322,084 B output from 274,996 B JSX); markers `V28`, `resetGame`, `onResetGame`, `Noodstop`, `startGame()` direct onClick, `setPhase(0)` in resetGame — all present.
- Layer B (context): ✅ PROJECT-MEMORY V28 section written (this section); inventory row updated to SHA256 `c25a26ef…6437`, 330,385 B, 5,253 lines; task #80 closed, task #81 (push) tracked and closed post-verify.
- Layer C (runtime): ✅ Served HTML fetched via Chrome MCP in-page `fetch()` + SubtleCrypto SHA-256 (cache-buster `?cb=v28-<ts>`, `cache:'no-store'`): byteLength 330,385 — exact match. SHA256 `c25a26ef…6437` — byte-identical to local index.html (`isV28: true`). In-served-HTML marker counts: `V28` ×3, `resetGame` ×2, `onResetGame` ×4, `Noodstop` ×1, `Reset spel naar lobby` ×1, `onClick={()=>startGame()}` ×1. Regression markers: old hang-vector `confirmAsync(\`Slechts` ×0 (gone). V27 regressions check: `expiredHotRef` ×5, `BroadcastChannel('stadsspel-miss')` ×1, `V27 P0-A` ×1 — all preserved, no V28 regression.

**Post-push verification plan (V28):**
- Live SHA256 = `c25a26ef…6437`. Bytes = 330,385.
- Marker grep in served HTML: `resetGame` ×≥3, `onResetGame` ×≥2, `Noodstop` ×1, `Reset spel naar lobby` ×1, `V28` ×≥3 in comments. The old `confirmAsync(\`Slechts` gate should be GONE (×0).
- Live functional smoke:
  - As admin (Mike) in lobby with 0 or 1 team → tap 🎮 Start → screen instantly flips to game, `game_state.phase=1` within 2s.
  - Mid-game → Beoordeel tab → scroll to ⚠ Noodstop → tap Reset → confirm → every tab snaps back to the lobby within 2s via realtime, `game_state.phase=0`, started_at=null, jorik_team_id=null.

**Residual findings (punch list):**
- None new from V28. Prior V27 residuals (P1-C activity_feed GC, P2-D moveJorik dual-message, P0-C moveJorik RPC-fallback) remain documented and deferred.

### V27 — Gameday-breaker P0 batch (18 Apr 2026, late night, shipped on top of V26)
Live Chrome-MCP forensic audit against the served V25 DB (still waiting on Mike's push for V26) surfaced three new P0s that a push of V26 alone would NOT have fixed. Bundled into V27 and batched with V26 for one combined push. File grew 323,992 → 327,093 B (+3,101 B, 5,134 → 5,192 lines). SHA256 `874e791f…ec91`. Babel transform clean (319,153 B output from 271,726 B JSX input).

**Audit evidence (live DB snapshot, 18 Apr 2026 ~18:50 UTC):**
- `activity_feed` = 71 rows, 61 of which were duplicate `"miste de deadline bij ZOHO Letters · −15 pts"` entries. All on team 10 (Haven Helden). Pattern: 3 identical rows per cycle, every ~13 minutes, for 4 hours. 86% duplication rate.
- `game_state.phase` = 1 (game started), `jorik_team_id` = **NULL**, `has_jorik` = false on all 4 teams. Jorik mechanic never initialized on this game start.
- Teams ids: 9, 10, 11, 12 (SERIAL advanced past 1 from prior resets). `SUPABASE-GAMEDAY-RESET.sql` Block A previously hardcoded `jorik_team_id = 1` — a reset would point Jorik to a non-existent team.
- Orphan `photo_reviews` rows for team_ids 9996/9997/9998/9999/-1 (test data).

**What ships (3 P0 fixes):**

1. **P0-A — `startGame()` seeds Jorik.** v18.html:~2691. Previously the upsert only wrote `phase`, `started_at`, `game_ended`, `bar_break_*`. Now also writes `jorik_team_id` (first non-spectator team in local `teams`) and `jorik_moved_at` (now), and mirrors the same values locally via `setJorikTeamId` + `setJorikMovedAt` so the auto-rotate watcher wakes up immediately instead of needing a realtime round-trip. Graceful fallback: if the DB rejects `jorik_moved_at` (pre-V21 column-missing 42703), retry without it. This was the silent root cause of "nobody ever sees a Jorik mission" on any fresh start of the game.

2. **P0-B — Hot-target expiry watchdog dedup.** v18.html:~2268. Root cause of the 61-duplicate row pattern: the watchdog (a) re-fired within the same tab whenever `nowTs` ticked past `hotTarget.deadline` (no in-flight latch), and (b) fired independently from every open tab (no cross-tab coordination). V22's client-side dedup only de-duplicated the *UI render*, not the *DB write*. V27 fix:
   - `expiredHotRef` (React ref, not state) holds the last-fired key `${myTeam.id}:${locId}:${deadline}`. Re-renders with the same key early-return.
   - `BroadcastChannel('stadsspel-miss')` — first tab to fire announces `{type:'claim',key}`. Sibling tabs receive the message and set their own `expiredHotRef.current=key`, suppressing their own insert.
   - Both guards are layered — if BroadcastChannel is unavailable (old browser or incognito) the same-tab latch still prevents the 3×-within-1ms re-fire that was the biggest offender.
   - `jorikInTeam` is deliberately NOT a guard here — the hot target is an every-team mechanic distinct from the Jorik-owned mission system. Adding a jorikInTeam guard would kill the mechanic entirely.

3. **P0-D — `SUPABASE-GAMEDAY-RESET.sql` dynamic `jorik_team_id`.** Both Block A (active soft reset) and Block B (commented-out full reset) now do `jorik_team_id = (SELECT MIN(id) FROM teams WHERE COALESCE(spectator,FALSE)=FALSE)` instead of hardcoding `1`. Block B is still commented out (opt-in for gameday eve) but the comment now explains why the dynamic lookup is safe even after `TRUNCATE teams RESTART IDENTITY` (MIN returns NULL → UPDATE tolerates NULL → V27 P0-A seeds Jorik on the next `startGame`). 

**V27 bundles with V26 into a single push.** The P2 UX fixes (#53 reject-reason picker, #55 negative-meter fix, #56 chip-row wrap) and the new SUPABASE-GAMEDAY-RESET.sql ship together with the P0 batch.

**V27 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (18 Apr 2026 late night, post-push live-verified):
- Layer A (code): ✅ Babel clean (319,153 B output from 271,726 B JSX); expiredHotRef, missChannelRef, BroadcastChannel('stadsspel-miss'), seedTeam in startGame, `jorik_team_id = (SELECT MIN(id)` in reset SQL — all present.
- Layer B (context): ✅ PROJECT-MEMORY V27 section written (this section); inventory row updated to SHA256 `874e791f…ec91`, 327,093 B, 5,192 lines; tasks #75/#76/#78/#79 closed.
- Layer C (runtime): ✅ Served HTML at `https://mikezuidgeest.github.io/stadsspel-rotterdam/` (fresh cache-buster fetch 18 Apr 19:04 UTC) returns HTTP 200, etag `W/"69e3d5ab-4fdb5"`, last-modified `Sat, 18 Apr 2026 19:04:11 GMT`, SHA256 `874e791f…ec91` byte-identical to local index.html. In-served-HTML marker counts: `V27 P0-A` ×1, `seedPayload` ×5, `seedPayload.jorik_moved_at` ×1, `expiredHotRef` ×5, `missChannelRef` ×4, `BroadcastChannel('stadsspel-miss')` ×1, `rejectOpenId` ×3, `REJECT_REASONS` ×2, `reviewer_notes` ×4, `flexWrap:'wrap'+rowGap` ×2, `gate-distance>-{` ×0 (old bug gone). Every V26 + V27 artifact present at expected frequency.

**Post-push verification plan (V26 + V27 combined):**
- Live SHA256 = `874e791f…ec91`. Bytes = 327,093.
- Marker grep in served HTML: `expiredHotRef` ×≥3, `missChannelRef` ×≥3, `BroadcastChannel` ×≥1, `stadsspel-miss` ×≥1, `V27 P0-A` ×≥1 in comments, `jorik_moved_at` in startGame (new code), `rejectOpenId` ×≥4, `REJECT_REASONS` ×1, `flexWrap:'wrap'` near `rowGap` for the Jorik chip row, `gate-distance` chip without `-` prefix.
- Live functional smoke (post a full Block B reset in Supabase, since the current DB is polluted):
  - Start Game → `game_state.jorik_team_id` populated to lowest team id within 2s.
  - Open a second tab on same team → deadline-miss fires at most once in DB per cycle (verify by letting one hot-target expire from 2 tabs simultaneously).
  - Reject a photo with preset reason → `photo_reviews.reviewer_notes` populated + activity feed message suffixed "· reason".
- Cleanup action: run `SUPABASE-GAMEDAY-RESET.sql` Block B to wipe the 61 dup deadline-miss rows + 5 orphan photo_reviews + teams 9-12 so fresh gameday registration starts at id 1.
- **✅ Block B executed 18 Apr 2026 post-push** (confirmed by Mike via SQL sanity-check screenshot): `teams_remaining=0`, `photo_reviews=0`, `activity_feed=0`, `completed_challenges=0`, `phase_now=0`. TRUNCATE … RESTART IDENTITY CASCADE succeeded on all 5 tables; game_state row reset; next team registration will start at id=1. Residual finding **P2-orphan photo_reviews** (team_ids 9996/9997/9998/9999/-1) resolved by CASCADE wipe — no action required.

**Residual findings (punch list for next batch, NOT in V27):**
- **P1-C** `activity_feed` has no server-side GC. Client caps at 500 rows (addActivity:1973) but DB grows unbounded. Defer: mitigated by the V27 P0-B dedup; post-gameday we can add a Supabase scheduled job.
- **P2-D** `moveJorik()` writes a machine-parseable `[JORIK] team=X` marker AND a human-readable announcement = 2 activity_feed rows per rotation. The realtime `gs.jorik_team_id` subscription already covers the sync need; the marker is redundant. Low priority cosmetic.
- **P0-C** `moveJorik()` RPC-failure fallback drops `jorik_moved_at` silently. Latent; only activates after an RPC failure, which we haven't observed in production. Deferred to a post-gameday hardening pass because the fix requires a second best-effort write loop and we'd rather not ship untested code 7 weeks before the event.
- **Day-of risks** (documented in audit report, not in code): battery drain, GPS dead zones at Markthal interior + tram tunnels, onboarding speed, Supabase realtime subscription cap, pre-game cached-tab staleness. Mike to brief team captains at 13:55 on gameday to hard-refresh.

### V26 — Queue-quality P2 batch + gameday reset SQL (18 Apr 2026 late evening, shipped on top of V25)
Small but meaningful quality-of-life pass knocking the three remaining live P2s off the board and adding a gameday ops safety net. All frontend, no schema changes. File grew 318,173 → 323,992 B (+5,819 B, 5,056 → 5,134 lines). SHA256 `37117ab9…bd07`. Babel transform clean (315,845 B output from 268,631 B JSX input).

**What ships:**

1. **#55 Negative meter display fix** (ChallengeAction `tooFar` branch, around line 4604). The locked-challenge card used to show `-{need}m` (minus sign) in the gate-distance chip, which read as "negative distance" and confused users. Now shows `{need}m` — plain positive value, matching the band-pill copy elsewhere. Single-char change (`-` stripped) but a real UX win.
2. **#56 Team-chip overflow wrap** in AdminReviewView's Jorik chip row. Previously `flexWrap:'nowrap',overflowX:'auto'` — on narrow phones this produced an awkward horizontal scroller for the 4-team Jorik-rotation chips. Now `flexWrap:'wrap',rowGap:'var(--sp-2)'` — chips flow onto a second line instead of hiding off-screen. No new copy; pure layout fix.
3. **#53 Reject-reason picker (queue quality).** Admin photo-rejection flow now captures a structured reason alongside the REJECT verdict, persists it to `photo_reviews.reviewer_notes` (column already exists since V22 catch-up), and echoes the reason into the activity-feed entry so the submitting team can see *why* their photo was rejected — not just *that* it was.

   - **New state in AdminReviewView:** `rejectOpenId` (controls which row's picker is open, only one at a time), `rejectCustom` (free-text input string), `rejectCustomOpen` (boolean for the "✏️ Anders…" expand toggle).
   - **`REJECT_REASONS` preset list:** 📍 Te ver weg · 🔍 Onderwerp niet herkenbaar · 📸 Onscherp / onduidelijk · 👤 Geen teamleden zichtbaar · 🎯 Verkeerde opdracht. Five buttons + an "Anders…" custom chip + "Geen reden" no-reason fallback + "Annuleren" cancel — covers the common rejection cases while still allowing free-text for edge cases.
   - **`commitReview(r, newStatus, sideEffects, notes)`** extended with optional `notes` parameter. When present (and non-empty after trim), trims to 240 chars and sets `payload.reviewer_notes`. Original retry logic unchanged. Approval path (no notes) untouched.
   - **`rejectReview(r, reason)`** extended to accept a reason string, pass it through to `commitReview`, embed it into the activity feed message as `${baseMsg} · ${trimmedReason}` (also capped at 240 chars), and attach it to the `reviewUndo` state object.
   - **`reviewUndo` banner** now shows a second caption line below the existing undo text: `Reden: {reason}` (only when present, styled as `t-caption t-muted`). Gives admin a last-look before the 7 s undo window closes.
   - **UI flow:** The old single "✗ Afkeuren" confirm-button is replaced with an expandable chip picker inside the `rejectOpenId===r.id` block. First tap opens the picker, second tap on a preset chip commits the rejection with that reason. Custom path: tap "✏️ Anders…" → textarea appears → Enter / "OK" button commits. "Geen reden" commits without a reason (backwards-compatible with the old behavior). "Annuleren" closes the picker without rejecting.

4. **#54 Gameday DB reset SQL snippet** — new file `SUPABASE-GAMEDAY-RESET.sql` (not in the HTML bundle). Two idempotent blocks inside `BEGIN/COMMIT` transactions. **Block A (soft reset — default active):** `TRUNCATE … RESTART IDENTITY CASCADE` on `photo_reviews`, `completed_challenges`, `activity_feed`, `challenge_first_finder`; `UPDATE teams SET score=0, challenges_completed=0, locations_visited=0, lat=NULL, lng=NULL, gps_hidden=FALSE, gps_hidden_until=NULL, has_jorik=FALSE, wedding_video_done=FALSE, underdog_bonus_last_break=0, updated_at=NOW()` (keeps the 4 team rows + their name/emoji/color/spectator flag so players don't re-register); `UPDATE game_state SET phase=0, jorik_team_id=(SELECT MIN(id) FROM teams WHERE COALESCE(spectator,FALSE)=FALSE), started_at=NULL, bar_break_{1,2,3}_{time,location}=NULL, game_ended=FALSE, jorik_moved_at=NULL, gm_heartbeat=NULL, updated_at=NOW() WHERE id=1`. Followed by a sanity-check SELECT returning counts (expect 0 for all gameplay tables, 4 for teams, phase=0, jorik_team_id=lowest real team id). **Block B (full reset — commented out):** adds `TRUNCATE teams RESTART IDENTITY CASCADE` so players re-register from scratch — for gameday eve. Troubleshooting section covers the three realistic failure modes: missing V22 columns (remove the line), missing `duels` relation (stay commented), post-reset UI staleness (hard-refresh). **19 Apr 2026 correction:** the original Block A referenced five columns that never existed on `teams` (`current_location_id`, `current_lat`, `current_lng`, `is_online`, `last_seen_at`) — the whole transaction would 42703-rollback on run. Fixed against a live `select=*` probe of teams (actual columns: id/name/emoji/color/score/challenges_completed/locations_visited/lat/lng/gps_hidden/gps_hidden_until/has_jorik/wedding_video_done/created_at/updated_at/family_messages_seen/underdog_bonus_last_break/spectator).

**Key design decisions:**
- No schema changes. `reviewer_notes` already exists (V22 catch-up). The gameday reset uses only TRUNCATE + UPDATE, never DDL.
- Activity-feed persistence of the reject reason is the *gameplay* win — without it, teams see "foto afgekeurd" but have no way to learn what to do differently. With it, they can self-correct on the next submission.
- `reviewer_notes` cap is 240 chars. Matches roughly 1–2 full sentences and fits comfortably in the existing activity-feed row layout.
- The picker uses emoji-prefixed chip labels (📍 / 🔍 / 📸 / 👤 / 🎯) so the five presets are scannable at a glance on a phone. Custom text is last-resort only.
- Nothing breaks for in-flight reviews. `reviewer_notes` is nullable; pre-V26 rejections stay `null` and render fine in the undo banner and feed (the `Reden:` caption simply doesn't appear).

**V26 Master Audit Cross-Check verdict — ⚠️ 2/3 PARTIAL** (18 Apr 2026 late evening, awaiting push):
- Layer A (code): ✅ Babel clean (315,845 B output); #55/#56/#53 edits applied; new markers: `rejectOpenId`, `rejectCustom`, `rejectCustomOpen`, `REJECT_REASONS`, `reviewer_notes`, `Reden:`, `gate-distance` sans leading `-`, `flexWrap:'wrap'` in the Jorik chip row.
- Layer B (context): ✅ PROJECT-MEMORY V26 section written (this section); inventory row updated to SHA256 `37117ab9…bd07`, 323,992 B, 5,134 lines; task #54/#55/#56/#53 all closed.
- Layer C (runtime): ⏳ **pending** — local `index.html` is byte-identical to `v18.html` (both SHA256 `37117ab9…bd07`), but not yet pushed. Served copy at `https://mikezuidgeest.github.io/stadsspel-rotterdam/` is still V25 (`9b226720…079b8`). Layer C runs after Mike pushes `index.html` to GitHub.

**Post-push verification plan:**
- `fetch(liveUrl+'?cb='+Date.now())` from admin tab → expect 323,992 B, SHA256 `37117ab9…bd07`.
- Marker counts inside served HTML: `rejectOpenId` ≥ 4, `REJECT_REASONS` ×1, `reviewer_notes` ≥ 2, `rejectReview\\(r,` calls wired to reason param, `gate-distance` chip has no `-` prefix, `flexWrap:'wrap'` inside the Jorik chip row.
- Live functional smoke: admin rejects a test photo with preset reason → `photo_reviews.reviewer_notes` populated → activity_feed `message` contains "· reason" suffix → submitting team sees the reason in its feed row.

**Residual findings:** none expected. #53 touches realtime-listened tables so realtime dedup (V22) still covers us. `#54` SQL is not bundled into the deploy; it lives as a standalone file for Mike to paste into the Supabase SQL editor on gameday.

### V25 — Two-radius task discovery UX (18 Apr 2026, shipped on top of V24)
Scope-down from a full six-layer validation architecture (AI vision → pHash dedup → reference-bank → location → recency → confidence scoring) to the specific UX change Mike greenlit: **all POIs always visible/clickable with proximity-band visual state**. Ship-now, frontend-only, no backend cost, no schema changes. File grew 306,467 → 318,173 B (+11,706 B, 4,855 → 5,056 lines). SHA256 `9b226720…079b8`. Babel transform clean (310,097 B output).

**What ships:**

1. **New constants** (`PREVIEW_RADIUS=300`, `UNLOCK_RADIUS=100`). `PHOTO_GATE_RADIUS=50` stays as the stricter inner gate for photo capture — defense-in-depth, independent of the UX bands. Documented inline.
2. **`locBand(pos,loc)` helper** returns `{band,dist}` where band ∈ `'unlock' | 'preview' | 'far' | 'unknown'`. Uses Leaflet-style `pos.lat/pos.lng` + L_DATA-style `loc.la/loc.lo` — cross-schema correct.
3. **MapView marker restyler** (existing visited-fade useEffect merged with band-aware styling; deps `[visitedLocs,pos]`). Visited wins → 0.25 opacity grayscale. Otherwise: unlock → scale(1.25) + green border + green glow; preview → amber border + soft amber glow; far → 0.7 opacity.
4. **`TwoRingIndicator`** — pure SVG component (100×100 viewBox). Outer dashed amber ring at 40 px = preview radius; inner solid green ring at 14 px = unlock radius; gold target dot at center; user dot drawn on the correct bearing from target (planar approximation, lon scaled by `cos(lat)`, SVG y-axis inverted). Beyond preview: user dot pinned to edge + subtle dashed halo. No lib — render cost is trivial.
5. **`TaskList`** — grouped, always-visible list of every main-deck POI (filters `c==='bar'` because bars have their own bar-break mechanic). Partitions into four groups: 🎯 Nu te doen (unlock) / 🔥 In de buurt (preview) / 🧭 Verder weg (far + unknown) / ✓ Al gedaan (all challenges complete). Each row: emoji + name + "N challenges · x/y klaar" + distance + chevron. Tapping any row calls `onSelect(loc.id)` to open ChallengeSheet — same handler as the map markers, so there's only one way to open a challenge.
6. **Props plumbed** `pos={pos} onSelect={setSelLoc}` from AppShell → LeaderboardView, so the new TaskList can read GPS and open sheets without re-subscribing.
7. **Placement:** TaskList injected into LeaderboardView immediately before the Rotterdam Deck sticker grid. No new tab — keeps the nav footprint unchanged.
8. **ChallengeSheet rework** — removed the inline distance chip from the header row, replaced with a band-aware panel below: left side TwoRingIndicator, right side band pill + band-specific Dutch copy ("Je bent er" / "Bijna daar · Xm" / "Nog ver weg · Xm — loop richting …" / "Nog geen GPS-fix"). Pill classes: `.band-pill.unlock` (green), `.preview` (amber with `bandWarm` pulse keyframe), `.far` (grey).
9. **CSS additions** (block inserted before `</style>`): `.band-pill` + 3 band variants + `@keyframes bandWarm` + `.two-ring` (+ svg child rules for the 4 circle classes `.ring-preview/.ring-unlock/.ring-target/.ring-me`) + `.task-row` (+ unlock/preview/far/completed state variants) + `.task-row-emoji/body/name/meta/chevron` + `.task-group-label` (+ unlock/preview color variants).

**Key design decisions (all user-approved, not invented):**
- NOT building AI vision, perceptual-hash dedup, curated reference banks, or confidence scoring. Mike's party is ~16–20 players × ~6 hours × ~100 POIs = a few hundred photos total. Admin-review UX already exists. An AI funnel would be pure scope-creep with API cost for zero gameplay win.
- NOT introducing a dedicated "Tasks" tab — the current 5 tabs (Leaderboard / Map / Activity / Queue / Chat) are at the limit and user rejected adding a sixth.
- Bars filtered from the main task list. They already have their own unlock flow via bar-break events; bundling them with POI challenges muddies the UX.
- Quizzes have no distance gate in this patch (standalone knowledge checks; V7 photo→quiz gating elsewhere is unchanged).

**V25 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (18 Apr 2026, post-push live-verified):
- Layer A (code): ✅ Babel clean (310,097 B output); new markers verified: `PREVIEW_RADIUS` ×8, `UNLOCK_RADIUS` ×4, `locBand` ×4 (def + 3 call sites), `TwoRingIndicator` ×3 (def + comment + ChallengeSheet use), `function TaskList` ×1 (def), `.band-pill` + `.task-row` CSS present, `band-pill.unlock/.preview/.far` variants present, `task-group-label.unlock/.preview` present, `@keyframes bandWarm` present, MapView useEffect deps updated to `[visitedLocs,pos]`.
- Layer B (context): ✅ PROJECT-MEMORY V25 section written; inventory row updated to SHA256 `9b226720…079b8`, 318,173 B, 5,056 lines; task #71 closed.
- Layer C (runtime): ✅ **Served HTML** at `https://mikezuidgeest.github.io/stadsspel-rotterdam/` (fresh cache-buster fetch from admin tab) returns HTTP 200, `etag W/"69e3ce11-4dadd"`, `last-modified Sat, 18 Apr 2026 18:31:45 GMT`, **318,173 UTF-8 bytes**, SHA256 `9b226720…079b8` — **byte-identical to local index.html**. In-served-HTML marker counts (via `fetch` + regex from within the live tab): `PREVIEW_RADIUS` ×8, `UNLOCK_RADIUS` ×4, `locBand` ×4, `TwoRingIndicator` ×3, `function TaskList` ×1, `band-pill` ×5, `two-ring` ×9, `task-row` ×18, `bandWarm` ×2, `V25 (#71)` ×9, `.ring-target` ×1, `.ring-me` ×1. Every expected V25 artifact present at expected frequency. Supabase DB unchanged (V25 is frontend-only, no schema touch).

**Residual findings:** none. V25 is clean end-to-end.

**Hard-coded defense-in-depth note:** the UX band communicates "you're here" at 100 m, but `PHOTO_GATE_RADIUS+PHOTO_GATE_GRACE = 70 m` is still enforced at the media-capture CTA inside ChallengeSheet. So a user in the 70–100 m overlap sees the green band pill but the photo CTA is still gated until they step closer. This is intentional — the UX should encourage walking all the way in, and GPS noise at 100 m is high enough that we don't want to award photos from 99 m away.

### V24 — P1 batch: admin photo ping + first-finder retry (18 Apr late evening)
Applied on top of V23. File grew 302,996 → 306,467 B (+3,471 B, 4,794 → 4,855 lines). SHA256 `a72e8ad1…b7f8`. Babel transform clean (300,087 B output).

1. **#50 New-photo-submission ping + badge pulse.** On a `photo_reviews` INSERT, admin now hears a 350 ms WebAudio chirp (sine 780→1100 Hz) and sees the Beoordeel tab badge pulse red (`reviewPulse` keyframe, 0.8 s × 3 iterations) — but **only** when admin is on a different tab (`tabRef.current!=='review'`). A `tabRef` ref-mirror defeats stale-closure in the long-lived realtime subscribe handler (deps `[myTeam,isAdmin]`, so the handler is created once and otherwise sees a stale `tab`). Badge condition `(nowTs-reviewFlashTs)<3000&&reviewFlashTs>0` — 1 s `nowTs` tick granularity is acceptable because CSS animation length (2.4 s) fits within the 3 s window.
2. **#51 First-finder insert retry on network hiccup.** `challenge_first_finder` INSERT now wraps in `attempt(triesLeft)` with exactly one 600 ms retry on transient errors. Conflicts (23505, PK violation = "not first") and missing-table (42P01, legacy fallback) remain deterministic no-retry verdicts. Retry timers are tracked in `pendingRetryTimersRef` (React ref holding a Set) and cleared on component unmount so no dangling `setTimeout` fires `setState` on an unmounted tree. **Known limitation:** if the first INSERT's fetch throws but the row actually landed server-side, the retry's 23505 will make us conclude "not first" and skip the bonus. Same blind spot as pre-V24. Proper fix would require server-side idempotency tokens — out of scope for this batch.

Both patches passed an adversarial review pass (Explore subagent) — original flagged a setTimeout-leak which is now fixed, and a cosmetic 1 s pulse-expiry granularity which is accepted.

**V24 Master Audit Cross-Check verdict — ✅ 3/3 DONE** (post-push, live-verified 18 Apr evening):
- Layer A (code): ✅ Babel clean; markers `reviewPulse`, `tabRef`, `reviewFlashTs`, `playReviewPing`, `V23 (#50)`, `V23 (#51)`, `awardIfWon`, `scheduleRetry`, `pendingRetryTimersRef` all present.
- Layer B (context): ✅ PROJECT-MEMORY V24 section written; tasks #50/#51/#69/#70 reflected.
- Layer C (runtime): ✅ **Served HTML** at `https://mikezuidgeest.github.io/stadsspel-rotterdam/` = 306,467 B (etag `W/"…-4AD23"`, SHA256 `a72e8ad1…b7f8`) — byte-identical to local v18.html. **Loaded-source grep** (fresh `?cb=…` tab): V23 (#48) ×2, (#49) ×1, (#50) ×5, (#51) ×2, (#52) ×1, `reviewPulse` ×1, `tabRef` ×4, `reviewFlashTs` ×3, `playReviewPing` ×2, `awardIfWon` ×2, `scheduleRetry` ×3, `pendingRetryTimersRef` ×5. **Live end-to-end** (#50): admin on leaderboard tab → REST INSERT into `photo_reviews` → badge count 2→3, `animationName: none→reviewPulse`, `AudioContext.createOscillator` invoked (ping fired). Don't-nag negative case: admin on review tab → badge count 4→5 (still increments), but `animationName: none` stays and no oscillator. Cleanup: 5 LAYER_C_* test rows (id 3–7) PATCHed to `status='rejected'` (DELETE is RLS-blocked by design). **Caveat:** #51 retry path is purely defensive code — runtime verification relies on Layer A structure grep + code-level review, not live fault injection.

Layer C gotcha documented: opening the admin URL in a pre-existing tab with unsaved state triggers `beforeunload` dialog that blocks all navigation, and the loaded source stays stuck at whatever version that tab had when first opened. Fix: open a **fresh** tab with cache-buster query param (`?admin=vriendvanjorik&cb=<timestamp>`). The cached-tab symptom is not a real deploy problem — it's just a browser DX artifact. Future Layer C runs should default to fresh-tab.

### V22 — Supabase catch-up + deploy drift fix + realtime dedup (18 Apr afternoon)
The forensic live-Chrome multi-tab audit surfaced three distinct P0s on the same day:

1. **Deploy drift.** `index.html` in the repo was a stale pre-V20 snapshot from 12:02 that
   day — 2–3 weeks behind the working `stadsspel-rotterdam-v18.html`. Synced by
   `cp stadsspel-rotterdam-v18.html index.html`; pushed to GitHub.
2. **Supabase schema drift (14 missing columns).** Production Supabase had never received
   the v14 team-display columns on `activity_feed`, nor the V20/V21 additions to
   `completed_challenges` / `challenge_first_finder` / `photo_reviews`. Every INSERT using
   those columns had been **silently 400-ing** for weeks because the client swallowed the
   error via `.then(()=>{},()=>{})`. GM broadcasts never appeared in team feeds. Fix:
   `SUPABASE-CATCHUP-PATCH-V22.sql` — idempotent migration adding the 14 columns, dropping
   NOT NULL on `activity_feed.event_type`, adding `UNIQUE(team_id, challenge_id)` on
   `completed_challenges`, and reasserting realtime publication membership. Mike ran it.
   Verified live: all 15 probed columns return 200 on REST.
3. **Optimistic + echo doubling.** Once broadcasts started working, admin's own feed
   showed every message twice (local append + realtime echo). Fixed with composite-key
   dedup `created_at|team_id|message` in the activity INSERT subscription handler
   (v18.html lines 1541–1545). Covers broadcasts and all `addActivity` call sites.
4. Client-side: `broadcastMessage` now does optimistic local append + real error logging
   (was `.then(()=>{},()=>{})` silent swallow before).

The V22 SQL also adds columns the v18 client does not yet write
(`completed_challenges.{points, photo, is_first, first_bonus, loc_id}`,
`challenge_first_finder.{team_name, team_emoji, team_color, bonus_points, completed_at}`,
`photo_reviews.{challenge_id, photo, reviewer_notes}`). These are safe (nullable) but
currently inert — they're prep for denormalization that may ship in v19.html / v23 /
reject-reason picker. The patch's stated rationale in its header is partly misleading:
the GM-broadcast fix was actually just the missing `team_name/team_emoji/team_color`
(which were v14-era columns the prod DB never got). `photo_reviews.photo_url` (which
the client does write) is NOT in any schema file and must have been created through the
Supabase UI — **documentation gap, P1 to codify in a future `supabase-v23-schema.sql`.**

### V17 — Hot Target + Extra Tijd
Path: `stadsspel-rotterdam-v17.html`

Rework of the pacing layer:
- **Hot Target (`HOT_TARGET_MS=12*60*1000`)** — a 12-minute per-challenge timer. The HUD top pill is now `⏱ Xm Ys · {emoji} {POI}`. Miss the deadline → −5 pt penalty + next hot target auto-assigned.
- **Extra Tijd** — replaces the older "Ghost Mode". 3 charges per team, +5 min each, earned at score milestones. Chip lives in the HUD top-right (disabled when no active hot target).
- Diner countdown clock removed (superseded by Hot Target).

### V16 — V15 design system everywhere + V12/V14 audit closeouts

Every component got the V15 tokenized design system. P0 items shipped: bar-break minis require photo/video upload (not honor system), wedding mission hard-gates when Jorik is in the team, photo-gate copy dedup, spectator admin can't score, admin broadcast messages. See `DEPLOY-V16.md`.

### V15 — Design system enforcement
Spacing (`--sp-1..10`), type (`--fs-10..48`), weights, letter-spacing, radii, shadows — all tokenized. Utility classes: `.panel`, `.screen`, `.stack-N`, `.row-N`, `.flex-1`, `.truncate`, `.t-*` typography scale. Applied systematically to splash/setup/lobby/HUD/leaderboard.

### V14 — Engagement layer + 3 P0 bug fixes

**Migration SQL:** `supabase-v14-schema.sql` — fixes `activity_feed` schema (photo column alignment), adds `teams.members TEXT[]`, adds `teams.team_level INTEGER`, creates `duels` table (reserved), enables realtime. See `DEPLOY-V14.md`.

Engagement mechanics:
- Global diner countdown (replaced in V17 by Hot Target)
- 6-level system (🥚 Rekruut → 👑 Legende at 0/25/75/150/250/400 pts) + XP bar + level-up celebration
- Hot-streak system — +20 at 3x, +50 at 5x, +1 Ghost charge at 7x (Ghost → Extra Tijd in V17)
- Celebration overlay on correct quiz — confetti, audio chime, haptic, breakdown pill
- Bar-break live countdown

### V12 — multi-user sync + comprehensive UX pass
Path: `stadsspel-rotterdam-v12.html` (~165 KB, 2698 lines)
Branding: splash copy "Acht dagen voor de bruiloft · de ring is zoek" replacing the "V11 · DE VERLOREN RING" version tag. 💍 icon instead of 🏙️.

**Migration SQL:** `supabase-v12-schema.sql` — adds `bar_break_active TEXT` and `bar_break_started_at TIMESTAMPTZ` columns to `game_state`, plus a unique index `teams_name_lower_idx ON teams (lower(name))`. **Must be run before V12 is deployed** or the cross-phone bar-break sync silently no-ops. Idempotent.

**Deploy instructions:** `DEPLOY-V12.md`.

**Multi-user sync fixes (game-breakers from the V11 audit):**
1. `teams` INSERT subscription + initial fetch via `sb.from('teams').select('*').order('created_at')`. Every phone now sees every team in real time.
2. `game_state` usage — admin writes on startGame / triggerBarBreak / endBarBreak / moveJorik / startFinale, and a new `gsSub` channel broadcasts updates to every phone. Late-joining phones pull the current phase via initial fetch and skip straight to the right screen.
3. Team-name collision check: (a) local `usedNames` check (V11 behaviour), (b) pre-insert async `sb.from('teams').select().ilike('name', finalName)` check, (c) DB-level unique index (via migration SQL). Belt and braces + suspenders.
4. Bar-break: admin writes `bar_break_active` and `bar_break_started_at` on `game_state`; every phone's `gsSub` handler opens/closes the overlay accordingly. `defaultBarMinis()` helper moved to module scope so both the trigger and the remote subscriber construct the same 3 mini-challenges.
5. New admin helpers: `endBarBreak()` (clears game_state), `adjustScore(teamId, delta)` (+/- on teams.score, logs to activity_feed), `removeTeam(teamId)` (hard delete from teams).

**Admin/GM UX overhaul (§1.9 of the audit):**
- Admin gets a "👑 GAME MASTER MODUS" chip on the splash.
- TeamSetup offers "👑 Alleen als GM observeren" → admin can skip team creation, spawns a `myTeam={id:-1,spectator:true}` that doesn't count on the leaderboard.
- Lobby for admin: "Klaar om te starten?" + visible grid of all joined teams + live count + "START HET SPEL (N teams)" CTA + confirm dialog when <2 teams joined.
- Admin review tab: bar-break dropdown populated from `L_DATA.filter(c='bar')` (13 bar POIs in-game) + "✏️ Eigen naam typen…" custom option. Active bar break shows "🛑 Bar break beëindigen" instead of the Start control.
- Collapsible "TEAM BEHEER (N)" section: every team gets ±5/+10 score buttons and a 🗑 delete. All changes broadcast via teams.update + activity_feed announcement.
- Finale button: GOLD, not red; section renamed to "FINALE & UITSLAG" (was "SPEL AFSLUITEN").
- Approve/reject reviews: 10s undo banner with live countdown.

**Onboarding + lobby polish (§1.1–1.3):**
- Splash: removed hardcoded "102 locaties · 4 teams · 1 winnend team", replaced with dynamic "`${teams.length} teams in lobby`"; 💍 icon; new italic flavor line.
- Team setup: starter cards now get full team-color 2px border; editable-name state plumbed in (not wired to UI yet; prop `packNameOverride` ready). Error state in a red banner; busy state ("⏳ Team aanmaken…"). Custom-name flow has same error + busy handling.
- Lobby: grid of all teams (uses 1-col when <3, 2-col when >=3); admin sees the CTA, non-admin gets a helpful "Pak vast een drankje bij het Maritiem Museum" card.

**Main-game UX polish (§1.4–1.8):**
- `PHASE_LABELS` map powers HUD: "Fase 1 · Zoektocht" etc. Phase bar underneath shows the 4 labels with active phase in gold.
- Ghost charge count always visible in HUD: `👻 2/3` — no longer requires being used first.
- Map: legend bottom-left, 16px dots (from 10px) with 8px invisible padding → 32x32 hit target, center-on-me 📍 button (when pos available), visited POIs fade on the map, dinner zone circle only rendered once phase ≥ 3 (stronger styling in phase ≥ 4).
- `getNearby()` rewritten: within `NEARBY_RADIUS` it sorts by `totalPts * diffMult / max(dist,30)` (points-per-100m weighted by difficulty). Outside the radius falls back to raw distance so the panel is never empty.
- Challenge sheet: "🧭 Route" link → Google Maps walking-directions deep link.
- Quiz: difficulty-aware stakes warning rendered in red box BEFORE any option tap; options get A/B/C/D prefixes in 22px circles.
- Photo retake: button copy flips to "Opnieuw proberen" / "Opnieuw opnemen" after first preview shown.
- Feed: system messages (Game Master / Systeem) styled with dashed borders + gold bg + "SYSTEEM" chip; reactions hidden on system rows. Timestamps use `fmtRelTime()` — "3m", "zojuist", else HH:MM.
- GPS pill: softer copy — "GPS actief / GPS zoekt… / GPS paust" instead of "goed / zwak / rust"; tap hint "tik om te activeren".

**Cross-cutting (§2):**
- `localStorage` session persistence via `loadSession/saveSession/clearSession` helpers. `stadsspel_v12_session` key holds {screen, myTeam, phase, gameStart}, 12h TTL. Refresh no longer kicks players out.
- Tap-to-leave HUD: team name/emoji in the top-left HUD is now clickable (with confirm dialog) → clears session, returns to splash.
- Desktop/tablet: `@media (min-width:560px) #root { max-width: 520px; margin: 0 auto }` so the phone layout doesn't stretch on bigger screens.

**Intentional omissions / known deferred items:**
- Ghost Mode cross-client visibility not yet implemented (schema has `gps_hidden`, not wired up; would need `teams.update({gps_hidden:true, gps_hidden_until:...})`). Low priority — ghost is a solo buff.
- Photo-gate on bar-break mini-challenges (§1.10.2) not yet implemented; still honor-system "Klaar" buttons.
- Wedding video mission: hard-gate when jorikInTeam=true not yet implemented; still text-only warning.
- Service worker / offline mode: still open (was roadmap #7).

**Verification:** Started a local Python HTTP server on :8765 and loaded `stadsspel-rotterdam-v12.html` in Claude Preview. Full walkthrough confirmed: splash, team setup (bezet state shows cross-device because initial fetch works), admin lobby (Klaar om te starten? + 1 team + gold START button), game start (Proloog → Fase 1 modals), HUD (phase label + 👻 3/3), map (legend + bigger dots + no dinner zone because phase=1), admin controls (Jorik tracker with real team, bar dropdown with 13 POIs, team beheer with ±5/±10/🗑, gold finale button). JSX parsed by @babel/parser with zero errors. No console errors or warnings beyond the standard Babel dev-mode warning.

---

## 3. Deployment stack

- **Hosting:** GitHub Pages (free, HTTPS — required for mobile GPS)
- **Repo:** `https://github.com/mikezuidgeest/stadsspel-rotterdam` (public, main branch, root `/`)
- **Live URL:** `https://mikezuidgeest.github.io/stadsspel-rotterdam/`
- **Realtime backend:** Supabase
  - **URL:** `https://kybcndicweuxjxkfzxud.supabase.co`
  - **Project ID:** `kybcndicweuxjxkfzxud`
  - **Anon key** (already in the HTML):
    `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5YmNuZGljd2V1eGp4a2Z6eHVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxMDM3ODYsImV4cCI6MjA5MTY3OTc4Nn0.utTzURErYUiGgOpvlq1goKToUl8i4CavVicEFp-MrDk`
  - Row Level Security (RLS) is open (public game, no auth needed — anon key does everything)
- **Map tiles:** CARTO raster voyager
  `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png`
  (OpenStreetMap direct is blocked without referer — DO NOT switch back)
- **Client libraries (all CDN):**
  - React 18 `unpkg.com/react@18/umd/react.production.min.js`
  - ReactDOM 18 `unpkg.com/react-dom@18/umd/react-dom.production.min.js`
  - Babel Standalone `unpkg.com/@babel/standalone/babel.min.js`
  - Leaflet 1.9.4 `unpkg.com/leaflet@1.9.4/…`
  - Supabase JS v2 `cdn.jsdelivr.net/npm/@supabase/supabase-js@2`

### How to deploy a new version (learned the hard way)
The Chrome extension's `file_upload` tool refuses arbitrary sandbox paths ("Not allowed").
Programmatic paste into GitHub's CodeMirror 6 editor is difficult because the editor view
isn't directly accessible on the window. The reliable flow is:

1. Edit `stadsspel-rotterdam-vN.html` in the workspace folder
2. Copy it to `index.html` (GitHub Pages entry point)
3. Navigate Chrome to `https://github.com/mikezuidgeest/stadsspel-rotterdam/upload/main`
4. **Ask Mike to drag `index.html` from his folder onto the upload drop zone** — this is the only reliable path
5. Commit changes via the Commit button (no extra changes needed)
6. Wait ~10 seconds for GitHub Pages to redeploy, then verify the live URL

---

## 4. Supabase schema (already run on the project)

Tables: `game_state` (singleton), `teams`, `completed_challenges`, `activity_feed`, **`photo_reviews` (V6)**.

V4 schema lives in `supabase-schema.sql`. V6 added one table (`photo_reviews`) — migration in `supabase-v6-schema.sql`. Both have been run.

V6 table columns: `id, team_id, team_name, team_emoji, team_color, location_id, location_name, challenge_idx, challenge_title, challenge_type, gps_distance, points_awarded, photo_url, status (pending/approved/rejected), created_at, reviewed_at`. Indexed on status, team_id, created_at desc. RLS open like the rest. Realtime publication enabled.

Important gotcha: `ALTER PUBLICATION supabase_realtime ADD TABLE …` statements MUST run AFTER the `CREATE TABLE` statements. The V6 SQL handles this in one ordered file.

**If the schema ever needs to change:** Claude can run SQL via Chrome automation at `https://supabase.com/dashboard/project/kybcndicweuxjxkfzxud/sql/new`. The Monaco editor accepts `monaco.editor.getEditors()[0].setValue(sql)` then click the green "Run" button. Supabase will warn about destructive ops (DROP/ALTER) — that warning has a "Run this query" confirmation button.

---

## 5. File inventory (workspace folder)

Location: `Jorik Rotterdam Stadspel/` (mounted from Mike's computer). The session-scoped
mount path varies per Cowork session — do NOT hard-code the prefix. The stable
reference is the folder name.

| File | Purpose |
|------|---------|
| `CLAUDE.md` | **Read-first bootstrap.** Points every new session at this memory file + the protocol file. |
| `PROTOCOL-MASTER-AUDIT-CROSSCHECK.md` | **Permanent validation protocol.** Fires after every delivery. See file for rules. |
| `index.html` | Deployed to GitHub Pages. Always a byte-for-byte copy of the latest `vN` file. **Currently: V19–V32 on disk (V30.0 pushed + verified byte-parity; V30.1 + V31.1 trigger + V32 refresh fixes all await Mike's push). Local SHA256 `f4d24a2146e5582b2043d1d005baf8cff9f147da06f3d800f4f417273440f925`, 323,294 B, byte-identical to `stadsspel-rotterdam-v18.html` via `shasum -a 256`.** |
| `stadsspel-rotterdam-v18.html` | **Current working source.** 323,294 B (SHA256 `f4d24a2146e5582b2043d1d005baf8cff9f147da06f3d800f4f417273440f925`). Contains V18 + V19 session resilience + V20 RPC/phase-4/hydration + V21 gm_heartbeat/GPS/canvas + V22 broadcast dedup + error logging + V23 tiebreaker/finale-celebrate/photo-review-retry + V24 admin photo-ping/badge-pulse + first-finder retry + V25 two-radius task discovery UX + V26 queue-quality P2 batch + V27 gameday-breaker P0 batch + V28 admin override (lobby Start strip + Noodstop reset) + V29 Bucket A UX fixes (useRef latch for level-up dedup; phase guard on startGame; photo-grid removed; ChallengeSheet close upgrade) + V30 "Less-is-More" simplification pass (Ghost/hot-streak/story/hot-target/level-modal retired; Ranking tab becomes pure scoreboard with TaskList moved onto Kaart tab; bar breaks collapsed to a single group-photo moment; emoji reactions promoted to real cross-device Supabase state via new `feed_reactions` table; every challenge card carries a one-line scoring-clarity label) + V30.1 client patch (reactionRowsRef lookup map resolves `{id}`-only DELETE payloads — Supabase realtime caches table metadata at slot-attach time so DELETE old-row never carries the full tuple even with REPLICA IDENTITY FULL; the client now builds its own id → {feed_key,emoji,device_id} map from initial select + every INSERT and consults it on DELETE) + **V32 refresh-persistence fixes (19 Apr afternoon): (a) v18.html:1697 mount fetch of `photo_reviews WHERE team_id=myTeam.id AND status='pending'` to rehydrate the `pendingMine` counter after reload; (b) v18.html:1788 visibilitychange step-6 re-query of the same, so backgrounded tabs recover the counter on tab-focus; (c) v18.html:1446 phantom-team guard inside the initial teams fetch — if localStorage's `myTeam.id` isn't in the authoritative teams list, clear the session, drop to splash, and toast "Je team bestaat niet meer in deze ronde — kies opnieuw." All three are idempotent on re-mount, skip the spectator + id≤0 sentinels, and have silent failure paths so a missing table or RLS block can't throw.)** |
| `SUPABASE-CATCHUP-PATCH-V30.sql` | **V30 migration.** Idempotent SQL that creates `feed_reactions` (feed_key TEXT, device_id TEXT, team_id INTEGER NULL, emoji TEXT, UNIQUE composite), sets `REPLICA IDENTITY FULL` so DELETE realtime payloads carry the full old row (needed to decrement the counter on un-react), adds permissive RLS policies matching the rest of the project, and registers the table in the `supabase_realtime` publication. MUST be run in the Supabase SQL editor before the V30 client is deployed — otherwise reaction taps 400 on every INSERT and the realtime channel has no table to subscribe to. Verify queries at bottom of the file. |
| `SUPABASE-CATCHUP-PATCH-V31.sql` | **V31 migration (19 Apr 2026 morning, APPLIED + live-verified).** Idempotent. Four fixes: (a) `ALTER TABLE teams ADD COLUMN IF NOT EXISTS members TEXT[]` — closes BUG-SIM-001 (client had graceful fallback but rosters were client-state only); (b) `CREATE TRIGGER trg_update_team_stats AFTER INSERT ON completed_challenges` that increments `teams.challenges_completed` unconditionally and `teams.locations_visited` on first-completion-per-(team,location), skipping sentinel `location_id=-1` — closes BUG-SIM-005 + 005b (other-team tier/locaties always showed 0 on leaderboard); (c) backfill `UPDATE teams … FROM (GROUP BY team_id)` for any pre-existing rows; (d) `DROP COLUMN IF EXISTS` on the V14→V30 orphan columns: `completed_challenges.{first_to_complete, is_first, photo_data, photo, points, first_bonus, loc_id}` and `photo_reviews.photo` — closes BUG-SIM-002 (schema drift). TRUNCATE bypasses row triggers so `SUPABASE-GAMEDAY-RESET.sql` Block A remains unaffected. Trailing comment block has step-by-step post-apply verification recipe. **Superseded in part by V31.1** — the `locations_visited` NOT-EXISTS increment path in V31 under-counts on multi-row INSERTs. V31.1 replaces only the trigger function body (recompute-from-scratch). |
| `SUPABASE-CATCHUP-PATCH-V31.1.sql` | **V31.1 trigger-function fix (19 Apr 2026 afternoon, awaiting Mike's paste into Supabase SQL Editor).** 7,793 B. Idempotent. Replaces `update_team_stats_on_completion()` with a recompute-from-scratch body: every trigger invocation sets `challenges_completed = (SELECT COUNT(*) …)` and `locations_visited = (SELECT COUNT(DISTINCT location_id) … WHERE location_id >= 0)` against the full `completed_challenges` table for the affected team. Correct under any insert shape (single-row, multi-row, COPY, bulk-import, manual SQL). ~sub-ms at gameday scale. Defensive `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER` follows so a fresh DB that skipped V31 still ends up wired. Includes a one-time heal UPDATE (for drifted rows under V31) + a zero-out pass for teams with no completions + three sanity SELECTs (function body contains DISTINCT, trigger exists, per-team drift check) + a commented post-apply multi-row-INSERT verification recipe. Block A of `SUPABASE-GAMEDAY-RESET.sql` remains unaffected. Trigger semantics issue discovered 19 Apr 2026 during the refresh-persistence deep test — a 3-row INSERT of locations [7, 7, 12] produced `locations_visited=1` where the correct answer is 2. Gameday impact of the original V31 bug: none (real gameplay always inserts one row at a time); patch still worth shipping for robustness + future test harnesses. |
| `ghost-smoke-audit-v2-20260419.md` | **19 Apr 2026 afternoon ghost smoke audit v2, post-V32 + V31.1.** Master Audit Cross-Check report. All three layers ✅ PASS. Layer A (static code) + Layer B (regression trace over 10 V30 smoke scenarios + 8 refresh-persistence scenarios + 8 V31.1 trigger semantic cases): no code defects, no regressions. Layer C (runtime/live) ran end-to-end after Mike's push + SQL apply on 19 Apr afternoon: (1) phantom-team guard fires on seeded id=99999 → splash + cleared session + Dutch toast + null myTeam; (2) pendingMine=1 banner correctly renders after reload with 1 seeded pending row; (3) visibilitychange step 6 fires the photo_reviews fetch alongside the four pre-existing steps; (4) V31.1 multi-row INSERT [7,7,12] produces cc=3, lv=2 (V31 would have produced lv=1); (5) single-row regression passes; (6) duplicate-location + sentinel location_id=-1 edge cases both correct. Final drift check: all 4 teams OK. Net verdict: 3/3 DONE. |
| `refresh-persistence-test-20260419.md` | **19 Apr 2026 deep refresh-persistence test (Layer C, live deploy).** 11,661 B. Six scenarios run via Chrome MCP `javascript_tool` + React-fiber-state walking: Test 1 happy-path reload (PASS — all 8 hook slots hydrated correctly, V21 P0 + V22 catch-up verified), Test 2 reload during active bar break (PASS), Test 3 reload with pending photo submission (GAP — player loses the "X foto's in check" counter until next realtime echo, no data loss), Test 4 empty localStorage (PASS — splash), Test 5 iOS private-browsing quota throw (PASS — detection logic live-verified, banner rendering code-verified), Test 6 12-hour session expiry (PASS — stale session correctly rejected). Side finding during seeding: V31 trigger multi-row INSERT under-counts `locations_visited` (→ V31.1). Side observation: anon key has SELECT+INSERT+UPDATE but NOT DELETE on `photo_reviews`; a pre-existing phantom localStorage session rendered an id=10 team that didn't exist in the DB (→ V32 phantom-team guard). Decision/open items section at the end distinguishes gameday-blocking from polish. All three "action" findings became V32 + V31.1. |
| `smoke-test-v30-20260419.md` | **19 Apr 2026 smoke test report.** Compressed full-code-path simulation via Chrome MCP `javascript_tool` injection: 4 sim teams (De Zeehelden / Kralingse Kapers / Hofpleinlopers / Maashaven Mafia), all 6 phase transitions, all 3 bar breaks, 3 Jorik rotations, finale + game_ended, photo review approve/reject, feed reactions incl. DELETE+reinsert (V30.1 path), UNIQUE constraint duplicates, underdog bonus, GPS hide/reveal. 0 runtime errors across ~70 REST/RPC calls. Surfaced 5 bugs (2 medium UX / 1 medium schema / 2 low-severity) — feeds directly into V31 SQL patch. |
| `SUPABASE-GAMEDAY-RESET.sql` | **V26 + V27 addition.** Standalone SQL snippet for Mike to paste into the Supabase SQL editor on gameday eve or between practice runs. Block A soft-reset (keeps teams), Block B full-reset (commented out). Idempotent, includes sanity-check SELECTs inside each transaction. **V27 P0-D fix:** both blocks now compute `jorik_team_id = (SELECT MIN(id) FROM teams WHERE COALESCE(spectator,FALSE)=FALSE)` instead of hardcoding `1`, so the reset works correctly regardless of where the teams SERIAL has advanced. |
| `stadsspel-rotterdam-v17.html`…`v1.html` | Archived predecessor builds. Do not edit. |
| `stadsspel-rotterdam-v14.html` | Earlier snapshot (pre-V15). ~3068 lines. V13 + activity_feed schema fix, PROLOOG sync for players, team members, click-drop guard, global countdown clock, level-up + XP bar, hot-streak bonuses, celebration with confetti/sound/haptic, bar-break timer. |
| `stadsspel-rotterdam-v13.html` | Full visual redesign (2026-caliber premium). Tokens, typography, spring animations, floating tab bar, glass cards with team-color glow. |
| `stadsspel-rotterdam-v12.html` | Multi-user sync fixed, 40+ UX improvements, spectator admin mode, bar dropdown, score override, session persistence. |
| `stadsspel-rotterdam-v11.html` | Premium HUD pass (superseded by V12). Audit target that surfaced the multi-user sync bugs. |
| `stadsspel-rotterdam-v10.html` | Audit fixes + Jorik tracker + bar-break overlay + finale ceremony + emoji reactions + adult-male content pass. |
| `stadsspel-rotterdam-v9.html` | Progression unlocks: bonus Ghost charges + tier badges + reward banner. |
| `stadsspel-rotterdam-v8.html` | 73 coordinate corrections via OSM Nominatim. |
| `stadsspel-rotterdam-v7.html` | V7 + V7.1 hotfix. One-shot quizzes, ref-lock against double-tap, quiz-only locations now reachable. |
| `stadsspel-rotterdam-v6.html` | Photo validation + admin review queue. |
| `stadsspel-rotterdam-v5.html` | V5 + V5.1 hotfix. Narrative, photo grid, dynamic quizzes, GPS smoothing, iOS GPS fix. |
| `stadsspel-rotterdam-v4.html` | Multiplayer baseline. |
| `stadsspel-rotterdam-v3.html` | Premium styling, pre-multiplayer. |
| `stadsspel-rotterdam-v2.html` | 90 locations. |
| `stadsspel-rotterdam-v1.html` | Original prototype. |
| `supabase-schema.sql` | V4 database schema. Already run. |
| `supabase-v6-schema.sql` | V6 photo_reviews migration. Already run on 14 April 2026. |
| `supabase-v12-schema.sql` | V12 migration: `bar_break_active`/`bar_break_started_at` on `game_state` + unique index on `lower(teams.name)`. Already run. |
| `supabase-v14-schema.sql` | V14 migration: `activity_feed` schema realignment + `teams.members` + `teams.team_level` + `duels` table. Run. |
| `supabase-v20-schema.sql` | V20 migration: `increment_team_score` RPC, `activity_feed.loc_id`, `game_state.jorik_moved_at`, `teams.spectator`, `completed_challenges` unique constraint, photo-rejection fixes, MVP-award dependencies. Run. |
| `supabase-v21-schema.sql` | V21 migration: `game_state.gm_heartbeat`, small hardening. Run. |
| `SUPABASE-CATCHUP-PATCH-V22.sql` | **Critical production catch-up** — adds 14 columns that the prod DB had been missing since V6/V14 (team_name/team_emoji/team_color/photo on activity_feed; points/photo/is_first/first_bonus/loc_id on completed_challenges; team_name/team_emoji/team_color/bonus_points/completed_at on challenge_first_finder; challenge_id/photo/reviewer_notes on photo_reviews). Drops NOT NULL on activity_feed.event_type. Asserts UNIQUE(team_id, challenge_id). Reasserts supabase_realtime publication membership. Idempotent. Applied 18 Apr 2026. Verified live: all columns return 200 on REST. |
| `AUDIT-V20.md` | Master V20 audit (18 Apr 2026). Originally catalogued 17 P0 blockers + 18 P1 + 15+ P2 — most P0s now closed; doc is partly stale (see V20/V21/V22 sections above). |
| `Stadsspel-V14-Engagement-Audit.md` | Deep 4-team live audit + Pokemon-GO/Roblox/Strava engagement benchmarking. Drove V14 roadmap. |
| `Stadsspel-V12-UX-Audit-v2.md` | Multi-user audit (17 Apr 2026). 4 game-breakers + 40+ UX issues documented. Drove V12 roadmap. |
| `DEPLOY-V16.md`, `DEPLOY-V18.md` | Latest deploy checklists. V18 supersedes. |
| `real-device-test-script-v20.md` | 26-scenario tester script for Mike's real-device pass. |
| `smoke-test-matrix-v20.md` | Pre-gameday checklist. |
| `test-report-v20-MASTER.md` | Rollup of the test outputs. |
| `poi-rewrites-v20.md` | POI content rebalance notes (target 40% photo mix). |
| `jorik-challenges-top20-draft.md` | Curated Jorik-specific missions (12 new + 8 existing). Wired into v18. |
| `stadsspel-content-audit.xlsx` | Full 102-POI content audit spreadsheet. |
| `Stadsspel-V14-Engagement-Audit.md` | Deep 4-team live audit + Pokemon-GO/Roblox/Strava engagement benchmarking. Drove V14 roadmap. |
| `DEPLOY-V12.md` | Two-step deploy checklist for V12. |
| `DEPLOY-V14.md` | Two-step deploy checklist for V14. |
| `SETUP-SUPABASE.md` | Setup guide for Supabase + game day workflow. |
| `Stadsspel-V5-Strategy.docx` | V5 strategic analysis + roadmap, synthesized from Gemini + ChatGPT research. |
| `Stadsspel-V8-Coordinatenrapport.docx` | V8 coordinate-correction diff report (73 fixes detailed). |
| `Stadsspel-V9-Audit.docx` | Full functional + exploit + fun-factor + age-group audit of V9. |
| `supabase-v10-cleanup.sql` | Pre-gameday reset: clears test data from all 4 tables + resets game_state. |
| `Stadsspel-Rotterdam-Technical-Research.md` | Earlier technical research notes. |
| `PROJECT-MEMORY.md` | **This file.** |

Also (outside workspace, in the session scratchpad — path varies per session):
- `verified_coordinates.py` — master verified coordinate DB with all 102 locations
  cross-referenced against 2+ web sources. If needed in a future session, re-derive from
  v18.html's `L_DATA` array rather than searching old session paths.

### Task backlog status (as of 18 Apr evening — post-V23 push & verify, post-#67 retraction)

**P0 still open (0 total)** — all clear for gameday-blocking bugs.

**P0 recently closed (V23):**
- #48 Winner tiebreaker — DONE (rankTeams helper + FinaleScreen useMemo)
- #49 Photo-review commit error toast + retry — DONE (commitReview wrapper)
- #52 Finale confetti + audio cue trigger — DONE (finaleCelebratedRef useEffect)
- #67 gm_heartbeat missing — RETRACTED (was a Layer C probe error by me;
  gm_heartbeat is a column on game_state, live, heartbeat age 43 s on re-probe)

**P1 still open (0 total)** — both shipped in V24, pending push (#69).

**P1 recently closed (V24):**
- #50 New-photo-submission ping + badge pulse — DONE
  (reviewPulse keyframe + playReviewPing WebAudio helper + tabRef sync)
- #51 First-finder insert retry — DONE
  (attempt(1) wrapper + pendingRetryTimersRef unmount cleanup)

**P2 still open (4 total):**
- #53 Reject-reason picker (queue quality) — V22 added `reviewer_notes` column, unwired
- #54 Gameday DB reset SQL snippet
- #55 Remove negative meter display in locked-challenge card
- #56 Team-chip overflow wrap in GM controls

*(#68 retracted — photo_reviews was already codified in v6+v22 schemas.)*

**Deferred / nice-to-have:**
- #18 Inside-jokes — weave interview answers into quiz copy
- #22 Family message system

---

## 6. Game configuration (constants in the code)

```
START_POS           {lat: 51.9179, lng: 4.4822}   // Maritiem Museum, Leuvehaven
DINNER_ZONE         {lat: 51.9206, lng: 4.4868, r: 400}   // Markthal/Bokaal
GHOST_DURATION      300 seconds (5 min invisibility)
GHOST_MAX_USES      3 per team
FIRST_BONUS         +10 pts (first team to do a challenge at a location)
BAR_BREAK_BONUS     +25 pts
WEDDING_VIDEO_BONUS +50 pts
NEARBY_RADIUS       500 meters
GPS_INTERVAL        10000 ms

// V5 additions
GPS_SMOOTH_SAMPLES  5 (moving-average window)
GPS_SNAP_RADIUS     30 meters (snap to POI when within)
GPS_ACCURACY_GOOD   20 m threshold
GPS_ACCURACY_WEAK   50 m threshold
STILL_TIMEOUT_MS    30000 (pause GPS after no motion — Android only since V5.1)
MOTION_THRESHOLD    0.8 m/s² (acceleration deviation from gravity)

// V5.1 additions
IS_IOS              detect iOS via UA + ontouchend on Mac
MOTION_AVAILABLE    true only when DeviceMotion fires without permission (i.e. NOT iOS 13+)

// V6 additions
PHOTO_GATE_RADIUS   50 meters (must be within for photo)
PHOTO_GATE_GRACE    20 meters (extra GPS noise tolerance, total 70m)
REVIEW_REJECT_PENALTY  true (deduct points from team when admin rejects)
```

Locations use a compressed schema:
`n=name, la=lat, lo=lng, e=emoji, c=category, r=radius, ch=challenges[]`
Challenge format: `t=type, ti=title, d=description, p=points, df=difficulty, a=answer, o=options[]`
Types: `photo | video | creative | quiz`
Difficulties: `easy | medium | hard`

---

## 7. The user (Mike) — preferences, decisions, context

- **Name:** Mike Zuidgeest
- **Relationship to Jorik:** friend / best man-adjacent, organizing the bachelor party
- **Technical comfort:** non-developer. Uses Cowork/Claude to build. Needs manual steps (drag-drop, copy-paste) clearly explained.
- **Decisions Mike has made:**
  - **Supabase** for real-time multiplayer (chose this over Firebase and local-only alternatives)
  - **2:00 PM start** on game day
  - **Will pick the 3 bars himself** for beer breaks (still pending)
  - **In-app mandatory wedding video mission** (appears when Jorik's not with the team)
  - **GitHub Pages** hosting (after Netlify's password screen blocked first attempt)
  - **Leaderboard-first UI** is a core requirement
- **Copy style:** all game-facing copy is in Dutch; prefers punchy, casual, sometimes playful
- **Pain threshold:** asks for premium design — glassmorphism, dark theme, neon accents, animations. Not minimal.
- **Communication style:** short messages, expects Claude to be proactive and fill in details

### Still owed by Mike (do NOT invent these — ask him)
- **3 bar names + coordinates** for the beer breaks
- **Wedding video mission script** (exact text/prompt for teams to read on camera)
- A list of any extra participants / special roles (game master, referees, etc.)

---

## 8. Research that informed V5

Two research documents were reviewed and synthesized:

### Gemini deep research (in Dutch)
URL: `https://docs.google.com/document/d/10rUTW3FArixRkXGjDW8zUH8xphhMw1K6dSLbqVQO1Ds/edit?usp=sharing`
Google Doc file ID: `10rUTW3FArixRkXGjDW8zUH8xphhMw1K6dSLbqVQO1Ds`

Key findings:
- Market split: B2C mass apps (Pokémon GO, Ingress, Orna, Geocaching, DragonQuestWalk) vs B2B scavenger hunt platforms (GooseChase, Actionbound, PlayTours, Locandy, Explorial)
- Niantic Lightship VPS solves GPS drift in urban canyons (centimeter accuracy via visual positioning)
- OpenTDB uses session tokens to prevent quiz repetition
- PlayTours uses Google ML for AI-validated photo submissions
- QuestSpot (Gemini API Developer Competition) dynamically generates clues via LLM
- Actionbound's killer feature = **full offline support**
- GooseChase's headline = 99.9% uptime + live activity feed (photos from other teams)
- GPS drift mitigation: Kalman filters, 5-sample averages, snap-to-POI
- Battery drain is the #1 UX killer — best practice: WalkScape's motion-gated polling
- Cheating via GPS spoofing is Ingress's biggest complaint

### ChatGPT summary (English, provided inline)
Key insight: **there is a market gap** — no single app combines:
- Pokémon GO's fun factor
- Ingress's hardcore competition
- Geocaching's puzzles & exploration
- GooseChase's team photo challenges

Stadsspel Rotterdam V4 sits exactly in this gap. V5 narrowed the gap further by adding the narrative frame, dynamic quiz pool, and live photo grid.

### What V5 does NOT include (deferred intentionally)
- AR / Niantic Lightship VPS — too heavy for a 4-hour event, requires Unity
- Blockchain/NFT rewards (SOFIE project) — over-engineered
- BLE Eddystone beacons — physical hardware impractical
- Native app wrapper — browser is fine; GitHub Pages + HTTPS handles GPS

---

## 9. Roadmap (prioritized) — current build order locked in with Mike

Mike confirmed the sequencing on 14 April 2026: photo validation bumped to V6 (highest priority), then 10 → 9 → 11 → 7 → 8.

### Must do before 6 June 2026 — still OPEN
- Mike picks 3 bars for beer breaks
- Mike writes wedding video script
- Field-test with 2 teams doing a 1-hour walk in Rotterdam center
- Rehearsal with admin panel under load (10+ phones on Supabase realtime)
- Bring power banks to the event

### Build order
- ✅ **V6 (DONE)** — photo validation: GPS gate + admin review queue
- ✅ **V7 / V7.1 (DONE)** — wrong-quiz one-shot rule (Mike's design — wrong = 0 pts, no retry) + bulletproof ref-lock + quiz-only locations now reachable
- ✅ **V8 (DONE)** — coordinate accuracy pass: 73 of 102 POIs corrected via OSM Nominatim
- ✅ **V9 (DONE)** — progression unlocks: bonus Ghost charges at 100/250 pts, tier badges at 5/10/15/20 challenges, "Volgende beloning" banner with progress bar
- **V10 (NEXT)** — admin panel polish (#11, 1 day) — force bar-break trigger, team-score override, live team-positions map. Will integrate naturally with V6's review queue under one admin UI. Also worth bundling: a way to manually populate `teams.challenges_completed` so other teams' tier badges render correctly.
- **V11** — service worker offline mode (#7, 2 days) — cache assets + location list + queue photo uploads for retry (Actionbound pattern)
- **V12 (likely droppable)** — Gemini Vision photo sanity check (#8, 1.5 days) — optional layer; admin review covers most of the value already
- **Additional research not yet implemented** (from `tekst-D7756BB53C5C-1.txt`): PDOK BAG/BGT integration via OGC API Features, Leaflet Proj4 for Rijksdriehoekstelsel, snap-to-path using BGT pedestrian network, SNR-weighted GPS filter, 3D shadow matching for urban canyons. Most are overkill for a 4-hour event but could be a V13+ "Rotterdam-grade GPS engine" upgrade.

### V6+ (post-bachelor-party, if Mike wants to reuse the platform)
- Organizer console (author new events without code)
- City packs (swap Rotterdam for Amsterdam/Utrecht/etc.)
- Challenge library (bachelor party vs teambuilding vs family day)
- MapLibre GL vector tiles with custom dark style (replace CARTO)
- Monetization paths: ticketed events (€10–25 p.p.), subscription (PlayTours-style €35/mo), custom city packs for tourism boards

---

## 10. Risk register (from the strategy docx)

| Risk | Mitigation shipped in V5 | Still needed |
|---|---|---|
| Battery drain | DeviceMotion-gated GPS polling | Remind Mike to bring power banks |
| GPS drift in urban canyons | 5-sample moving average + snap-to-POI within 30m | Test at Erasmusbrug / Markthal |
| Dead zones (Markthal interior, tram tunnels) | Partial (Leaflet tiles cached by browser) | Service worker (nice-to-have #7) |
| Team onboarding friction | Starter packs (6 one-tap presets) | Verify with real users |
| Cheating / fake photos | Honor system (fine for bachelor party) | For future: Gemini vision check |
| Quiz repetition / boredom | Dynamic quiz pool + session-token dedup | — |
| Realtime sync failure | Supabase 99.9% SLA + offline-mode banner | Load test with 10+ phones |
| Wedding video spoiled for Jorik | Mission only appears when Jorik is NOT in team (GPS distance check) | Mike to provide video script |

---

## 11. Key prompts & messages from Mike (verbatim highlights)

These capture Mike's exact requirements for reference when making design decisions:

- *"Okay, we really need to think carefully about the interface of this app…"* — the V4 redesign request that introduced leaderboard-first, live updates, nearby challenges (3 within 500m), start at Leuvehaven/Maritime Museum, 4-hour game, 3 beer breaks, Jorik rotation, dinner at 7:30 PM near Markthal/Bokaal, real-time team locations, GPS-hiding StukTV-style, mandatory wedding video surprise, stronger gamification.
- Decisions from the clarification round: Supabase real-time / 2:00 PM start / Mike picks bars himself / in-app mandatory wedding video mission.
- *"you can control my chrome correct? can you do it for me?"* — the authorization to automate GitHub setup via the Chrome extension.
- *"start with v5"* — the authorization to build V5 directly after the strategy doc was approved.
- *"uploaded"* / *"new index uploaded"* — Mike's standard confirmation after each manual drag-drop upload of index.html to GitHub. Always means: it's safe to verify the live URL.
- *"make sure you document everything related to things we discussed, input and prompts in your memory for this project"* — the prompt that created this file.
- *"also I see GPS sleeps notification on my phone, probably a problem?"* — flagged the iOS GPS sleep bug. Triggered the V5.1 hotfix.
- *"also, how can we verify if photos are actually taken at the locations… currently I can add what ever I want and I will still get points, this doesnt seem very logical."* — flagged the honor-system gap. Triggered the V6 photo validation feature (GPS gate + admin review).
- *"do it for me in supabase"* — granted Claude permission to run SQL migrations directly via Chrome automation in the Supabase dashboard. Established that Claude can self-serve schema changes from now on rather than asking Mike to run SQL manually.
- *"about this: wrong-quiz penalty, I dont think team deserve a second chance. wrong is wrong."* — overrode Claude's first V7 design (penalty + cooldown + retry) with a cleaner one-shot rule. Established Mike's preference: simpler, more honest gameplay over forgiving complexity.
- *"i can still answer twice in a quiz"* — surfaced the React state-async / mobile tap-event race, leading to the V7.1 ref-lock fix.
- *"currently I see many wrong locations on the map, so this needs to be better"* + research doc on PDOK / Overpass / urban-canyon mitigation — triggered the V8 coordinate verification pass. Mike picked "Issue A: POI markers wrong" + "Auto-correct via Overpass" as the scope.
- *"De echte doelgroep is tussen de 35 en 50 jaar, waarvan het grote merendeel tussen de 35 en 38 jaar. Het zijn allemaal mannen."* — corrected my audience assumption. Drove the V10 content punch-up (removal of childish challenges).
- *"momenteel is het nog wat karig qua speel ervaring"* — triggered V10 to go beyond audit fixes and add substantial gameplay layers (Jorik tracker, bar-break overlay, finale ceremony, emoji reactions). Established that Mike values depth/richness over minimal MVP.

Mike's full earlier deep research prompt (provided when V5 strategy was requested) asked Claude to:
- Review top GPS / photo / quiz games worldwide by downloads, ratings, Reddit sentiment
- Actively search for open-source code, GitHub, APIs, databases
- Extract key learnings
- Identify concrete elements to apply
- Focus on: engagement, fun+challenge, puzzles+quizzes, unlockables, competition, team play
- Goal: take the game to the next level with precise, reliable location data sources

Mike provided both the Gemini link and the ChatGPT summary inline.

---

## 12. Development environment notes

- **Working directory in sandbox:** `/sessions/modest-awesome-keller/` (temporary scratchpad — cleared between sessions)
- **Workspace mount (user's computer):** `/sessions/modest-awesome-keller/mnt/Jorik Rotterdam Stadspel/` (persists)
- **Claude skills used:** `docx` (for the strategy document), plus native file/browser tools
- **Chrome tabs:** a tab group with tabId 242398889 typically holds the live game or GitHub; 242398822 has `codergautam/worldguessr` (reference); 242398823 has `Tornquist/Quest` (reference)
- **Node tooling:** `docx` package is installed locally at `/sessions/modest-awesome-keller/node_modules/`
- **Validation scripts:** `python3 /sessions/modest-awesome-keller/mnt/.claude/skills/docx/scripts/office/validate.py <file>` for docx validation
- **Babel syntax check trick:** use `@babel/parser` via Node to verify the game HTML's JSX parses cleanly before pushing — already installed locally

---

## 13. What to do in a fresh session

1. Read this file first.
2. Check `index.html` vs `stadsspel-rotterdam-v5.html` — they should be identical. If not, Mike uploaded a hot fix and V5 is stale.
3. Check the live URL is up: `https://mikezuidgeest.github.io/stadsspel-rotterdam/`
4. If Mike asks to build V6 features, consult Section 9 roadmap above.
5. Before making changes: copy the current file to `stadsspel-rotterdam-v6.html` (or the appropriate next version) — never edit V5 in place; always iterate versioned copies.
6. For every deploy: edit the `-vN.html` file, copy to `index.html`, navigate Mike to the GitHub upload page, and ask him to drag-drop.
7. For any new Claude/Cowork session, proactively offer to update this memory file at the end.

---

_End of memory file. Keep this up to date — it's the only persistent record._
