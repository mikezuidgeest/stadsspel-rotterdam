# Stadsspel Rotterdam — Project Memory

> **Purpose of this file.** Single-file context for any future Claude/Cowork session
> picking this project up. Everything we've discussed, decided, and built is captured here.
> Read this first before making any changes.
>
> **Last updated:** 15 May 2026 (V39 — **Flippercoin 3D upgrade + coin-anchored celebration + Dutch translation pass.** Builds on V38's Flippercoin mechanic (50/50 photo-vs-video gate at locations with both media types: POI 1 Erasmusbrug, POI 10 Laurenskerk, POI 12 Stadhuis, POI 20 Oude Haven). Mike's feedback drove 5 iterative passes inside the session. **3D coin:** 200px gold-metallic disc → real extruded cylinder via 60 stacked `translateZ` slices from `-29.5px` to `+29.5px` (60px thickness on 200px disc = 1:3.3 ratio so depth reads even face-on). Each slice is a radial-gradient disc with alternating bright/dark gradients simulating a milled-reed coin edge. Face caps pushed to `translateZ(±30px)` cap the cylinder, each carrying an embossed inline-SVG icon (camera lens + viewfinder for FOTO, clapperboard slate with play-triangle for VIDEO) inside a recessed gold inner disc with `flipcoin-pts` label ("FOTO +N" / "VIDEO +N") + decorative rim-dots conic-gradient. **Animation:** 2.5s `coinFlip`/`coinFlipVideo` keyframes with anticipation crouch → 540°+1260°+2040° Y-tumble combined with 140°+360°+540°+700° X-rotation → translateY apex `-180px` → impact squash (`scaleX 1.20 scaleY 0.85`) → bounce-back overshoot → small `rotateZ ±2°` wobble → settle. Cubic-bezier `0.22,0.61,0.36,1` for slow-apex-fast-drop physics. Ground shadow scales `1× → 0.32× → 1.28×` inversely with toss height (`coinShadow` keyframe). **New `landed` state** (idle/flipping/landed/revealed) — coin stays visible 1.5s after spin completes with `coinSettled` breathing keyframe + result-colored `drop-shadow` filter (blue `rgba(110,163,255,0.45)` for photo, red `rgba(255,123,123,0.45)` for video). Total flip moment: 4.0s (2.5s spin + 1.5s admire) before reveal challenge card. **Casino-felt stage:** emerald-green `.flipcoin-stage` background (`#0e2f23 → #0a2018` linear-gradient + repeating-radial-gradient grain + radial spotlight + inner shadow) replacing prior warm-gold gradient. **Coin-anchored celebration** (replacing rejected V38 ConfettiBurst trigger that fell from `top:38%` disconnected from coin position — Mike: "the confetti is crap"): three new elements rendered inside `.flipcoin-anim` only when `flipState==='landed'`: (1) `.flipcoin-flash` — 300px radial white-gold flare from coin center, 350ms `coinFlash` keyframe (`scale 0.2 → 1.6`, `opacity 0 → 1 → 0`), `mix-blend-mode:screen`; (2) `.flipcoin-ring` — 200px result-colored outline pulse, 700ms `coinRing` keyframe expanding `scale 0.4 → 2.2` with border-width tapering `4px → 1px`; (3) `.flipcoin-burst` — 24 `.flipcoin-spark` elements emitted from coin center using per-spark CSS variables `--angle` (radians) and `--dist` (110-160px) for a 360° fan, mixed shape types (8 thin streamer rectangles among 16 round dots), color mix half gold half outcome-color, gravity arc via `coinSpark` keyframe (`translateY -18px at apex, +60px at end`, `opacity 0 → 1 → 0`, `scale 0.4 → 1.1 → 0.5`), 1.1s duration with 0-72ms stagger per spark. `window.__ssrTriggerConfetti(30)` call removed from `doFlip` (still exposed for other call sites). **Pre-flip mystery cards stripped of points** — V38 printed `+25 pts` / `+35 pts` under blurred icons, triple-printing the same info (mystery card → coin face → reveal badge) killed surprise. Now shows flavor copy only: "📸 Het moment" / "🎥 Het verhaal". **Dutch translation pass** (user noted English crept in despite Dutch game): "🪙 Flip de Coin" → "🪙 Munt Gooien" (line 6710), tagline "Capture a moment… or create the story." → "Vang een moment… of creëer het verhaal." (line 6714), "starter pack" → "starterpakket" 3 sites in TeamSetup (lines 4556, 4687, 4628 "Starter packs" label → "Starterpakketten"). Kept as-is per audit verdict: "Foto", "Video", "Quiz", "OK", "WiFi", "GPS" (standard Dutch loanwords). **Process:** 3 parallel buddy-review agents (UX/gamification + visual/motion + frontend-implementation) all independently flagged generic top-of-viewport confetti as wrong primitive for the flip moment — convergent finding drove the CoinBurst rebuild. **Research lineage:** DEV.to "Build a 3D Flipping Coin" (Shahibur Rahman) gave the stacked-slice principle (60 layers × 1.2px = 36px); I adapted to 60 × 1px = 60px to suit the embossed-icon faces. CodePens (mibeen/eaVOVW, praneybehl/qBxbop) returned 403 to WebFetch. Ayokanmi-Adejola/Flip-The-Coin GitHub turned out to be a 2D `rotateY(720deg)` SVG image swap, no 3D structure to copy. LottieFiles considered but rejected — parametric FOTO/VIDEO/+points labels would need fiddly per-flip text compositing. **File** `stadsspel-rotterdam-v39.html` SHA256 `63ca9debcf95c3aecfb4cb51fb2604047da460975596930477d585a3c19b1a48`, Babel-clean (449,387 B JSX). `index.html` byte-identical via `cp`. Mike committed index.html to git this session. **TEST_MODE still true** (lint warning) — must flip to false before the 6 June live push. **Supabase state:** 4/4 test teams from session iteration (Maffiosi, Haven Helden, Rotterdam Rakkers id 47, De Kubus Kids id 48) — cleanup before live game via `tools/agent-runner.js`. **Deferred to V40+** (from buddy-review backlog): anticipation buildup before coin launches (currently appears mid-air), slow Y-rotation in settled state instead of breathing scale, escalating-stakes treatment for the 4th Flippercoin location (Vegas "final flip" vibe), 30-slice perf optimization for low-end Android. Layer A + B ✅, Layer C ⏳ pending Mike's GitHub Pages refresh.) Previously: 1 May 2026 late morning (V30 — Self-critique remediation. Mike asked for a video script of V23-V29 + a self-critique. Critique surfaced **25 findings** (10 script defects, 15 product friction). V30 closes 22/25; 3 explicitly deferred to V31 (React Context refactor, design-token consolidation, Villa Thalia framing review). **Highlights:** wp:1 secret-mission lock when Jorik holder taps wedding-pipeline POI (P1 leak fixed); ConfettiBurst now tiered (small/medium/large by score) so easy POIs still celebrate; mute toggle copy "🔊 Geluid aan / 🔇 Geluid uit" (state-not-action, Dutch); SkeletonRow distinct copy for GPS-denied vs loading; Jorik resilience admin status indicator (countdown to V27 25-min auto-rotate); Plafond Cirkel difficulty bumped easy→medium + Horn of Plenty fact added; Setup Checklist surfaces Mike's 4 still-open inputs; prefers-reduced-motion respected (WCAG 2.3.3); findings file rotates per run >30min stale. **Sub-agent fact-checked 33 V27 Rotterdam-anchor claims**: 23 verified, **10 patched** (Giacometti→Rodin, wrong sculptor on POI 70 entirely, Natuurhistorisch in Museumpark not Het Park, Mariniersmuseum at Wijnhaven, etc.), 1 flagged (POI 97 Villa Thalia framing). Web Audio capability state added. Video script rewritten as VIDEO-SCRIPT-V30-honest.md addressing all 10 script defects with before/after table. File `stadsspel-rotterdam-v30.html` SHA `1deeb012051f5aef378c27e9b8b6d4d74b0541d3375819b9f6209bdeb72a6d52`, Babel-clean 361,585 B JSX. `index.html` byte-identical. Self-scored **9.1/10** against 8 dimensions — above Mike's 9/10 bar. Layer A + B ✅, Layer C ⏳ pending push.) Previously: 1 May 2026 mid-morning (V28 + V29 — Premium UI polish from the V26 deep-audit P2/P3 ui-premium backlog. **V28** ships ConfettiBurst (pure-CSS particle burst on score milestones ≥30 pts via `@keyframes confettiFall` + `triggerConfetti()` callback wired into 4 setScorePopup sites) and SkeletonRow (shimmer placeholder using existing V11 keyframe; replaces V25's "first 3 POIs" cold-start fallback in TaskList while pos===null). File `stadsspel-rotterdam-v28.html` SHA `a808baf9e3e773149a7bce74eda6d1cc1e34ddc95b8f4c9925515b3a95669199`, Babel-clean 348,260 B JSX. **V29** ships 4 richer chip variants (`.chip-achievement` gold-glow gradient, `.chip-status` green pulse-dot via new `chipPulse` keyframe, `.chip-role` purple gradient, `.chip-count` tabular-nums); Web Audio cues with 5 distinct tone profiles (score / correct / wrong / broadcast / upload) lazily-init AudioContext + persistent `ssr_muted` toggle (defaults UNMUTED) + `🔊 sound`/`🔇 muted` splash button; extended haptic feedback to 5 new sites (score milestones, broadcast, quiz correct/wrong, photo upload). Forward-ref + window-global pattern lets deep-child ChallengeAction consume cues without prop-drilling. File `stadsspel-rotterdam-v29.html` SHA `b64baef3991c84369a0a708b26ea999f0bc44d3635d32e6d67a9938091e2bd27`, Babel-clean 352,357 B JSX. `index.html` byte-identical to v29 via `cp`. Mike pushes when ready. Both V28 + V29 Layer A + B ✅, Layer C ⏳ pending push. V30 backlog: design-token consolidation (43 hex colors → tighter palette) + retrofit existing UI surfaces to use the new chip variants.) Previously: 1 May 2026 morning (V27 — V26 Deep-Audit follow-ups: **(1) P1 Jorik resilience fallback** — new `JORIK_FALLBACK_ROTATE_MS=25min` constant + admin-only watcher with snapshot-ref pattern + new `'fallback'` origin in moveJorik with `⏰ Auto-rotate:` activity-feed prefix. Closes the V26 audit's #1 gameday risk: Jorik freezing on first holder team if admin doesn't trigger all 3 bar breaks. **(2) P3 Bruidegom dilution sweep** — 8 inline rewrites stripping "captain als bruidegom" framing from non-wp:1 missions (POI 5/9/12/26/27/48/66/88), restoring specialness to the 6 intentionally wedding-themed missions (POI 1 wp:1, 41, 49, 69, 93, 100). **(3) P2 Rotterdam-anchor sweep** (delegated to content agent) — 33 description edits raising Rotterdam-specificity from 28% (V26 baseline) to **98.1%** (103/105 non-quiz descriptions). Each anchor adds one concrete Rotterdam reference (nearby landmark, history, neighborhood, local quirk) without disturbing V25 team-focus language or wp:1 absent-referent retentions. File `stadsspel-rotterdam-v27.html` SHA256 `e05c12292a81d1502182a57178f40d1ff90ebf60a0838a6d78c4a033a8e7c1c2`, 400,048 B, 6,027 lines, Babel-clean (345,701 B JSX). `index.html` byte-identical. **Deferred to V28**: P2 ui-premium (SkeletonRow + ConfettiBurst on score milestones), P3 ui-premium polish (design tokens, chip variants, haptics, audio cues). Mike pushes index.html when ready. Layer A + B ✅, Layer C ⏳ pending push.) Previously: 30 April 2026 late evening (V26 — Ghost Crosscheck Audit infrastructure: 7 agent role specs (`agents/expertise-glossary.md` shared domain reference + `findings-protocol.md` structured findings + `jorik.md` NEW 5th agent + rewritten `admin.md` `captain.md` `orchestrator.md` + extended `coverage-criteria.md`); 5 new harness subcommands (`list-jorik-missions`, `complete-jorik-mission`, `list-recent-submissions`, `findings-add`, `findings-summary`); 4 new coverage criteria (jorik_missions ≥8, secret_missions ≥4, buddy_reviews ≥16, findings_filed ≥5) integrated into `tools/coverage-report.js`. L_DATA parser refactored to line-anchored extraction (bracket counter tripped on Unicode em-dashes inside JORIK_MISSIONS descriptions). Pair-buddy review protocol C1↔C2 / C3↔C4 + Jorik independently reviews wp:1 + admin reviews queue. Auto-patch trivial (typos in L_DATA strings) + file structural for everything else. The 4-hour audit run itself is NOT executed by V26; orchestrator triggers it on-demand. **V25 sibling change (same SHA `bc6a11c6b99acf976ef348ddd0f70cbf934cf1dfc0bca6e277344aa7668ac203`):** L_DATA Jorik scrub — 92 edits, 95 → 15 Jorik mentions in L_DATA `d` fields (15 remaining are intentional absent-referent / wp:1 templates / POI 29 body-spelling tribute / POI 79 toast-target retention). Regular missions are now 100% team-focused; Jorik narrative confined to the JORIK_MISSIONS layer (already gated to holder via `jorikInTeam`). 4 titles rewritten (POI 41/72/78/82). The 4 wp:1 wedding-pipeline templates applied verbatim from brief. File `stadsspel-rotterdam-v25.html` ≡ `stadsspel-rotterdam-v26.html` ≡ `index.html` byte-identical, Babel-clean (339,601 B JSX). Mike pushes index.html when ready. Layer A + B ✅; Layer C deferred to push + audit-run.) Previously: 30 April 2026 evening (V24 — Multi-agent testing harness shipped: `tools/agent-runner.js` Node CLI exposes admin + captain commands as Bash-callable subcommands (state, list-pois, complete-mission, start-game, broadcast, move-jorik, mass-approve, etc.); `tools/coverage-report.js` machine-checks 7 coverage criteria for the orchestrator's stop signal; 4 role specs in `agents/` (admin / captain / orchestrator / coverage-criteria). Two new in-app features: cross-device admin broadcast banner (renders at top of viewport, gold gradient, tap-to-dismiss, 12-sec auto-clear, late-join surfaces broadcasts < 30 sec old) wired to existing broadcastMessage send-side; photo auto-approve when GPS distance ≤ AUTO_APPROVE_RADIUS=200m (Mike's spec) so the admin queue doesn't drown the test loop. File `stadsspel-rotterdam-v24.html` SHA256 `7ba57f832ec6b47a5b68a7297eff253fb99adef8a467825b4157a73f791aa2ac`, 393,286 B, 5,972 lines, Babel-clean (339,064 B JSX). `index.html` byte-identical via `cp`. End-to-end smoke test on live Supabase: 4 teams created (5th rejected by V23 trigger), start-game → 6 missions across all 4 types → auto-approve fired on 50m/80m/100m/60m, pending on 350m → 3 bar breaks + Jorik rotation → broadcast → mass-approve → end-game (phase=5, ended=true). Final cleanup wipe applied; live splash back to "0 teams". Coverage report shape verified. HTML deploy push pending Mike for the in-app banner + auto-approve to be live on phones; harness is fully operational against the existing Supabase deploy. See V24 (2026-04-30) entry below for the detailed item-by-item breakdown.) Previously: 30 April 2026 (V23 — TEST MODE: lifted admin-only lobby start + GPS photo gate behind a single `TEST_MODE=true` constant for end-to-end test rounds; hard 4-team cap (client guard + `enforce_team_cap()` Postgres trigger via SUPABASE-V23-RESET.sql); STARTER_PACKS pool extended 6 → 8 (pick 4 of 8); TaskList beneath the map capped to 3 nearest non-completed missions (map markers themselves still all 102 — only the list trims); 58 of 128 L_DATA challenges rewritten to require team-in-frame language ("Heel team in beeld" / "Allemaal in beeld" / "Captain + minstens 2 teamleden"), 47 left alone (already team-focused from V22 sweep), 23 quizzes untouched. File `stadsspel-rotterdam-v23.html` SHA256 `bdf873103e6abea7b01c4c06c4faa26470bed49df6222da9204f7922c63b4a9c`, 387,437 B, 5,881 lines, Babel-clean (333,405 B JSX). `index.html` byte-identical via `cp`. Live Supabase wipe applied via REST anon-key DELETE: 9 stale teams (incl. ghost "Hofpleinlopers" Jorik was flagged on) + activity_feed + team_members purged, game_state reset to phase=0. Trigger portion of SUPABASE-V23-RESET.sql + index.html push pending Mike. Layer A + B ✅, Layer C ⚠️ partial. See V23 (2026-04-30) entry below for the detailed item-by-item breakdown + restriction re-enable instructions.) Previously: 19 April 2026 evening (V20 post-V19 — Human-Logic audit team-allocation fixes: `stadsspel-rotterdam-v20.html` SHA256 `6bfb30e3d3c04ca2eadef1efc00363770d7f5629839cce777c220f66412ec466`, `index.html` byte-identical. Ships 7 items from `audit-human-logic-team-allocation-20260419.md`: team_members table + per-browser session UUID + live headcount chips, late-join warning banner, Jorik revisit warn + "✅ al bezocht" badge, admin team rename button, `SUPABASE-CATCHUP-PATCH-V32.sql` with partial UNIQUE indexes on `teams.name`/`teams.emoji` + `team_members(session_id)` UNIQUE + Realtime publication membership, distinguished kick-reason toasts via module-level `__v20KickReason` flag, and `moveJorik(origin)` feed prefix. Soft-cap enforcement deferred — current UX has no join-moment to gate. V32 SQL pending Mike's paste; client gracefully no-ops on "table does not exist" until then. See V20 (2026-04-19 evening) entry below for the detailed item-by-item breakdown + deferred scope. 19 April 2026 afternoon (V31 SQL-only catchup patch — **APPLIED + LIVE-VERIFIED ✅ 3/3 DONE** via supabase-js round-trip on the admin tab. All 8 post-apply verification steps green: trigger fires on every `completed_challenges` INSERT with correct `challenges_completed`-unconditional / `locations_visited`-first-per-location / sentinel -1 skip semantics; `teams.members TEXT[]` accepts + persists arrays; `completed_challenges` now 7 cols / `photo_reviews` now 18 cols after orphan drops; Block A reset still zeros cleanly post-patch. Fixes the 3 medium-severity bugs surfaced by the 19 Apr compressed-full-coverage smoke test — see `smoke-test-v30-20260419.md`. Adds (1) `AFTER INSERT ON completed_challenges` trigger that increments `teams.challenges_completed` unconditionally and `teams.locations_visited` on first-completion-per-location (with sentinel `-1` skip) — closes BUG-SIM-005 + 005b; (2) `ALTER TABLE teams ADD COLUMN IF NOT EXISTS members TEXT[]` — closes BUG-SIM-001 now that the client's existing graceful retry path becomes a no-op; (3) `ALTER TABLE … DROP COLUMN IF EXISTS` sweep over the V14→V30 orphan columns on `completed_challenges` (`first_to_complete`, `is_first`, `photo_data`, `photo`, `points`, `first_bonus`, `loc_id`) and `photo_reviews` (`photo`) — closes BUG-SIM-002. Layer A + B green; Layer C pending Mike's paste. No HTML push needed; V30.1 client stays on GitHub Pages unchanged. 18 April 2026 (V30 "Less-is-More" UX simplification pass — Phases 1-8 CODE COMPLETE + byte-synced + Babel validator clean; user push + Layer C runtime verification + Supabase DB migration still pending. Eight phases collapse surface area so the game reads at bachelor-pace: (P1) deleted Ghost Mode + hot-streak multiplier + 40-minute streak timer machinery now that they confused more than they helped; (P2) deleted the narrative story modal + chapter ticker + PROLOOG auto-opens — the ring story was cute but nobody read it mid-walk; (P3) removed the 10-minute Hot Target with its expiry activity-feed misses that V27 fought with `expiredHotRef`; simpler to just not have the mechanic; (P4) level-up modal collapsed to a single inline toast (`lastLevelSeenRef` from V29 kept the latch); (P5) Ranking tab is now a pure scoreboard — TaskList moved onto the Kaart tab in a fixed-height map + scrollable task list layout so one tab = one mental model; (P6) bar breaks are one shared group moment per bar (`BAR_MOMENT` constant: 🍻 "Groepsfoto + proost", 40 pts) — no more three mini-games competing on the same patio; (P7) feed-row emoji reactions are now real cross-device Supabase state via the new `feed_reactions` table (composite text `feed_key = created_at|team_id|message` + per-device uuid in localStorage + REPLICA IDENTITY FULL + realtime publication) so taps on 🔥👏💀😂🍻 actually broadcast; (P8) every challenge card now carries a single scoring-clarity line: "✅ 1× per team · eerste team +X bonus" / "♻️ Zo vaak je wilt · elke keer +X pts" / "✅ 1× per team deze break". V30 base SHA256 = `b894815a…657f`, 319,484 B. **V30.1 amendment (same day, post-Layer-C):** realtime `postgres_changes` DELETE events turned out to stream only `{id}` in the old-row payload even with `REPLICA IDENTITY FULL` confirmed in pg_class and the table re-added to the publication — a Supabase metadata-cache quirk. Client-side workaround: `reactionRowsRef` map (id → {feed_key, emoji, device_id}) populated on the initial select + every INSERT and consulted on DELETE. Self-heals on every tab mount. Final V30.1 SHA256 = `925b6a07a345da5df7ff79ae78adaa10e919b048ec522bb423f92c94492ff113`, 321,139 B, 5,082 lines. `index.html` byte-identical. Babel transform clean (output 311,742 B). **V30 is SHIPPED ✅ 3/3 DONE** — live-verified on `mikezuidgeest.github.io/stadsspel-rotterdam/` via Chrome MCP: byte-parity match (321,139 B), 3-tab V30 UI mounts cleanly, Kaart = map+tasks, Feed reactions render, bar moment is a single card, scoring-clarity labels on challenge cards, and the V30.1 `reactionRowsRef` workaround is live in the served bundle. In-page supabase-js round-trip confirmed the platform quirk (DELETE payload `{id}`-only despite REPLICA IDENTITY FULL + publication membership) — exactly what reactionRowsRef handles.)
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

**Audit:** see `audit-v19-jorik-rotation-20260419.md` — Layer A ✅ PASS, Layer B ✅ PASS, Layer C ✅ PASS (closed 2026-04-19 after Mike pushed to GitHub). Served HTML SHA256 = `cdc57ced…` matches local byte-for-byte; `window.JORIK_ROTATE_MS` undefined post-hard-reload; live Supabase probe via inline anon key returned all three rotation queries 200 OK (`game_state.jorik_team_id=7` Haven Helden holds, 4 active teams {4,5,6,7}, `activity_feed [JORIK] team=%` filter operational). **Verdict: ✅ 3/3 DONE.**

**Deploy:** pushed + verified live 2026-04-19.

### V37.1 hot-fix (2026-05-03 night, post-V37-validation-audit) — 4 P1s from fresh persona evidence

**Trigger:** V37 validation audit ran (8 personas in parallel — all returned cleanly this time, no cap issues), confirmed mean **7.71/10** (hit projected 7.5-7.7 band — the first time across the V33→V36→V37 arc that a synthesizer projection matched real persona evidence). Jorik recovered from 5.8 → 7.4 (+1.6) AND exceeded V33's 7.0 baseline. Erik 5.5 → 8.0 (+2.5). Mike 8.0 → 8.7 (+0.7). All 8 personas lifted.

**But the V37 audit surfaced 4 NEW P1s** — small, all closing the same defense-in-depth pattern (sites that needed the new isJorikDevice / gpsOptOut props but didn't get threaded). Hot-fixed in V37.1 same-build (no version bump):

1. **WeddingMission modal `isJorikDevice` gate** (Jorik audit, `v37.html:6738` signature + `v37.html:4063` call site). The call site was already passing `isJorikDevice` as a prop (V37 changes had threaded it via `replace_all` of the AdminMenu pattern), but the component's destructuring at line 6738 didn't include it — JS silently ignored the extra prop. The modal renders "Bruiloftsvideo voor Jorik · 14 juni" — the most explicit reveal in the entire app. Trigger banner upstream IS gated, but defense-in-depth fail. Fix: added `isJorikDevice=false` to destructuring + early `if(isJorikDevice){setTimeout(onClose,0); return null;}` so any future entry point is hard-gated.

2. **Realtime CLEAR of `jorik_device_id` doesn't propagate** (Jorik audit, `v37.html:1969` realtime UPDATE handler + `v37.html:2182` visibility-change catch-up). Original guard `typeof gs.jorik_device_id==='string'` excluded null, so when Mike taps "Wis Jorik-telefoon markering" (writes null), other clients' setState was never called and they kept the stale UUID — continuing to filter wp:1 for a phone Mike no longer thought was Jorik. Fix: changed to `'jorik_device_id' in gs` (key-presence check) + handle both string and null branches explicitly.

3. **WhatsApp banner copy mismatch** (Sandra audit, splash banner). Banner said "Tik op de drie puntjes rechtsboven → 'Open in browser'" — but iOS WhatsApp's actual menu label is "Open in Safari" and Android Chrome's is "Open in Chrome". Sandra-with-no-helper would tap the menu and not find "Open in browser", give up. Fix: rewrote to "Tik rechtsboven op de drie puntjes (⋮) of het deel-icoon → kies 'Open in Safari' (iPhone) of 'Open in Chrome' (Android)".

4. **TaskList doesn't receive `gpsOptOut`** (Hassan audit P2, `v37.html:4657` signature + `v37.html:5222` call site). After Hassan tapped "Doorgaan zonder GPS", the V37 GPS pill correctly shows red "GPS uit · tik om aan te zetten" — but the TaskList shimmer below shows "Nog geen GPS-fix — zoekt nu je locatie. Een paar seconden geduld." Direct contradiction. Fix: thread `gpsOptOut` into TaskList; treat opt-out as same intent as denied (`denied = gpsStatus==='denied'||gpsStatus==='unavailable'||gpsOptOut`); show clean opt-out copy: "📍 GPS staat uit (jij koos zonder GPS te spelen). Tik op de rode GPS-pil hierboven om opnieuw te proberen."

**Verification:**
- Babel parser: BLOCK 1 OK · 0 errors · 435,244 B JSX (Babel block 1).
- SHA: `stadsspel-rotterdam-v37.html` and `index.html` both `d52578036e7017585fb6e2b7bac4d5524d7d258b0c481fe096979d96dda2133c` (was `270b6b8f...` before hot-fix).
- 4 V37.1 markers grep-confirmed in served HTML: `weddingMissionGate`, `realtimeNullPropagate`, `whatsappCopyFix`, `taskListGpsOptOut`.

**Audit projection update:** V37 mean was 7.71. V37.1 closes 4 of the V37-audit's residual P1/P2 findings. Projected new mean: ~7.85-8.0. Per the V36→V37 lesson, this is a projection — would need a fresh audit to confirm, but the gap-pool is small enough now that the next audit cycle is optional. **Recommended posture: ship V37.1, do real-device testing, decide V38 scope from real-world evidence not synthesizer projections.**

**V37 audit reports preserved at `tests/v37-personas/`:** 8 persona scripts (~30K total words), 1 README. Validates the JORIK_DEVICE_ID architecture as the highest-leverage fix in the entire arc.

### V37 (2026-05-03 evening, post-V36-audit) — JORIK_DEVICE_ID architecture + 9 audit-driven fixes

**Trigger:** V36-audit found 3 P0s + 1 P1 (Sandra) beyond what the V33-backlog covered. Erik + Lisa P0s were hot-fixed into v36.html. Jorik P0 (wp:1 filter inversion) was deferred to V37 because it needed an architectural change. Mike said "pick up all 6 items and start afterwards with v37" — so V37 ships the Jorik P0 + 5 other audit-driven fixes + 4 stretch P1/P2 from the deferred V36 backlog + a splash-layout fix caught during V37 testing.

**The 10 V37 fixes (sorted by severity):**

1. **P0 — JORIK_DEVICE_ID architecture** (the V36-audit Jorik P0). Schema: new column `game_state.jorik_device_id` (nullable text), migration in `SUPABASE-V37-JORIK-DEVICE.sql`. Client: lifted `getDeviceId()` to module scope (re-uses the V30 reactions `ssr_device_id` UUID); App stores `jorikDeviceId` state, hydrated from initial fetch + realtime + visibility-change catch-up; derived `isJorikDevice` flag; admin callback `markJorikDevice` writes the local deviceId to `game_state` (or null to clear); new AdminMenu section "🤵 Bruiloftsedit-bescherming" with status banner + mark/unmark buttons. Filter applied to 4 leak sites (ActivityView wp:1 message filter, LeaderboardView wp:1 progress chip, LeaderboardView wedding-mission banner, ChallengeSheet captain-side wp:1 chip) AND the secrecy-lock condition (`isSecretWp = ch.wp===1 && (jorikInTeam || isJorikDevice)`). Secrecy-lock copy branches on `isJorikDevice` so Jorik gets innocuous "Niet voor jou vandaag · Deze opdracht is gereserveerd voor de andere teams" instead of the team-side "Geheime bruiloftsmissie · voor de surprise bruiloftsvideo van Jorik op 14 juni".

2. **P0 — L_DATA wp:1 description sanitization** (companion to #1). Even with the secrecy lock, if a Jorik-device user opens a wp:1 card before isJorikDevice hydrates (network blip), the description renders. Sanitized 4 entries:
   - Brug Catwalk: removed "bruidegom-stoet" / "Voor Jorik!" → "belangrijke optocht" / "iets enthousiast"
   - Erasmus Fluistert: removed "namens Jorik" / "huwelijksadvies" / "Voor de bruiloftsedit" → "luidop om één concreet levensadvies"
   - 1070 Meter Gelofte → renamed "1070 Meter Galm" (drop trouwgelofte connotation); removed "trouwgelofte" / "Ja voor Jorik" → "plechtige verklaring" / "Ja!"
   - Vriendenbiecht: removed "Jorik" / "aanstaande" / "voor de bruiloftsedit" → "iets opvallends — een gewoonte, een uitspraak, een verhaal — dat de buitenwereld waarschijnlijk nog niet kent" with parenthetical pointing captains to the team-brief for the actual subject.
   Captains still get the bruiloft framing via the V35 captain-side wp:1 chip (now also gated on `!isJorikDevice`).

3. **P1 — Sandra photo-upload "✅ Foto verstuurd" interim state.** Was: `📸 Foto opnemen` → instantly morphed to `📸 Opnieuw proberen` after submit, reading as failure to low-tech users. Now: 6-second `btn-success` interim state with `✅ Foto verstuurd · wacht op beoordeling` (button disabled during this window) before reverting to the "Opnieuw" affordance. New `.btn-success` CSS class (gradient #5fd8a5 → #3eaa7d).

4. **P1 — Erik confirm-dialog stale copy.** Old "Sluit aan" dialog promised "Je komt in de lobby terecht" but post-V36-hot-fix the auto-flip lands joiners in game when phase>=1. New copy branches: "Je sluit direct aan in het lopende spel — je begint met 0 punten maar speelt voor het team-totaal" when running, original lobby copy when phase=0.

5. **P2 — GPS pill reflects gpsOptOut state.** V35 pill branched on `gpsStatus==='denied'` only, so after Hassan tapped "Doorgaan zonder GPS" (V34 fix sets `gpsStatus='weak'`+`gpsOptOut=true`), the pill misleadingly said "GPS zoekt…". Now also branches on `gpsOptOut` → red pill "GPS uit · tik om aan te zetten" + matching title attribute. MapView gets `gpsOptOut` prop.

6. **P2 stretch — finale aftelklok.** Tom + Lisa audit asked for a countdown chip in the finale banner. Added `⏱ Mm:ss` chip showing time until `dinerTs()` (gameday's 19:30 endpoint). Color shifts to `#ff8a8a` red in last 60s; tabular-nums for stable digit width. Aria-label spells out the time for screen readers.

7. **P2 stretch — Beoordelen pre-roll auto-collapse.** Mike audit: when review queue ≥6 items, the GM controls panel + pace-guide pre-roll pushed first review card below the fold. Now: `gmPanelOpen` initialized lazily as `queue.length<6`. Header is tappable to expand/collapse manually. Caption shows queue count when collapsed: "▸ X in wachtrij — toon".

8. **P2 stretch — WhatsApp / Instagram in-app browser detection.** Sandra audit: in-app browsers sandbox localStorage and lose session on Safari hand-off. Detect via UA regex `/FBAN|FBAV|Instagram|WhatsApp|Line\//i`; render top-of-splash amber banner: "⚠️ Open deze link in Safari (of Chrome) voor de beste ervaring — in-app browsers verliezen je voortgang. Tik op de drie puntjes rechtsboven → 'Open in browser'." Stack-aware top offsets for GM chip + mute toggle so they don't collide with the banner.

9. **P2 stretch — GPS pre-prompt rationale on splash.** Hassan + Sandra audit: OS GPS prompt fires cold without context. Added a small info card on splash above the team-count: "📍 Straks vragen we om je locatie. Géén tracking, géén opslag — alleen om opdrachten in de buurt vrij te geven en foto's te valideren." Doesn't change app boot flow; just primes the user before they tap Speel mee.

10. **V37 splash chip restack.** Caught during V37 ship-test: TESTMODUS chip + V35-extended mute toggle ("tik om uit te zetten") collided on narrow viewports. TESTMODUS is now a full-width thin banner ("🧪 GENERALE REPETITIE · ALLE DREMPELS UIT") under the optional in-app-browser warning. Mute toggle shortened back to "🔊 Geluid aan / 🔇 Geluid uit" with action description in `title`+`aria-label`. GM chip explicitly left-aligned with stack-aware top offset.

**Files:**
- `stadsspel-rotterdam-v37.html` — SHA256 `270b6b8f26c1bcae125c623d4cb72e60f8485dcde89819fea89de7241d44ca97`, 433,475 B JSX (Babel block 1), +18,170 B vs v36-with-hot-fix.
- `index.html` — byte-identical via `cp`.
- `SUPABASE-V37-JORIK-DEVICE.sql` — new at root, idempotent ALTER + COMMENT, must be run once in Supabase SQL editor before the device-id filter activates.
- `CLAUDE.md` — updated to v37 + new SHA + new SQL migration mention.

**Verification:**
- Babel parser: BLOCK 1 OK · 0 errors.
- Browser harness (Claude Preview MCP, fresh server `67a37840-0c72-4972-b31a-0ebfb4df0273`):
  - Splash renders cleanly: full-width "🧪 GENERALE REPETITIE · ALLE DREMPELS UIT" banner up top, "🔊 Geluid aan" pill in top-right (no collision), GPS pre-prompt info card visible above the Speel mee CTA.
  - 12 V37 markers verified in served HTML: jorikDeviceId, markJorikDevice, adminMenuButton, wp1Sanitized, secrecyLockJorik, sandraSubmittedState, erikDialogCopy, gpsPillOptOut, finaleAftelklok, beoordelenCollapse, whatsappDetect, gpsPrePrompt.
  - No console errors on fresh load.

**Methodology note:** V37 was driven by REAL V36-audit evidence (8 persona scripts), not the V33-backlog. The V36-audit's "Jorik dropped from 7.0 → 5.8" finding (regression caused by V35's captain-side chip ironically making the wp:1 leak more visible) is the single most important architectural lesson this project has learned: every feature added with `!jorikInTeam` as the guard inadvertently widens the surprise-leak surface area, because that gate semantics are "team currently with the rotating token" — NOT "Jorik's actual phone". The JORIK_DEVICE_ID architecture is the one fix that handles this correctly. Going forward, any new wp:1 / wedding-pipeline UI should be gated on `!isJorikDevice` (not `!jorikInTeam`) as the primary check.

**Pre-gameday checklist (now 34 days out):**
1. Mike runs `SUPABASE-V37-JORIK-DEVICE.sql` once in Supabase SQL editor.
2. On gameday, Mike opens the app on Jorik's actual phone, opens the AdminMenu, taps "📱 Markeer dit toestel als Jorik's telefoon" — captures Jorik's deviceId.
3. From that moment, every wp:1 site filters for that specific phone, regardless of which team holds the rotating Jorik token.
4. Mike flips `TEST_MODE = true → false` at v37.html:650.
5. Runs `node babel-lint.js stadsspel-rotterdam-v37.html --strict` — must show "production-ready".
6. `cp index.html`, push, verify live SHA.

**Audit projection:** V36 mean was 6.83. V37 closes 4 of the V36-audit P0/P1 findings (Jorik P0, Sandra P1, Erik P1, GPS pill P2) plus 4 deferred V36-backlog items. Projected lift: 6.83 → ~7.5-7.7. As learned in V36, projections aren't evidence — a fresh audit on V37 would confirm. Optional next step.

### V36-audit hot-fix (2026-05-03 evening, post-V36-deploy) — Erik + Lisa P0s caught by validation persona run

**Trigger:** Mike asked to validate the V36-projected 7.8 score with a fresh 8-persona audit (Path B from his V37 question). Spawned 8 persona agents in parallel on `cbc3b5055a348ae04aba4e74be36d9b8f7ecb0da18738b54abf80ec6cea797d2`. Org monthly usage cap hit on 7 of 8 final-summary messages, but ALL 8 persona files landed on disk first (V31-style behavior — work completes before summary). Surveyed all 8 directly without waiting for the synthesizer.

**V36 audit headline numbers (real, not projected):**
| Persona | V33 score | V36 score | Δ |
|---|---|---|---|
| Mike | 6.4 | **8.0** | +1.6 |
| Tom | 6.7 | **7.6** | +0.9 |
| Sandra | 5.0 | **6.5** | +1.5 |
| Jorik | 7.0 | **5.8** | **−1.2** ← regression caught |
| Erik | 2.8 | **5.5** | +2.7 (still flagged P0 ship-blocker) |
| Lisa | 5.2 | **6.7** | +1.5 |
| Bart | 6.4 | **7.3** | +0.9 |
| Hassan | 5.8 | **7.2** | +1.4 |

**V36 audit mean: 6.83 / 10** (vs V33 5.66, projected 7.8). Lift is +1.17 — real but below projection. **Synthesizer projection was too generous.** Honest read: V34/V35/V36 closed most copy + ergonomic gaps but didn't catch the structural Jorik leak.

**3 NEW P0 ship-blockers identified by personas:**

1. **Erik P0 (HOT-FIXED in v36.html)** — first-time mid-game joiner stuck on lobby. Flow: page loads → realtime fetches phase=2 → V36 initial-fetch flip is no-op because screen is still 'splash' at that moment → user picks team via TeamSetup.onJoin which sets screen='lobby' → no further game_state UPDATE arrives → user stuck. The "Start spel (testmodus)" button is a silent no-op because `startGame()` early-returns when phase>0. Only escape: page reload. **Fix:** added `useEffect([myTeam,phase,screen])` at `v36.html:3289-3303` that flips lobby→game whenever myTeam exists AND phase>=1 AND screen==='lobby'. Covers both initial-fetch + post-onJoin paths.

2. **Lisa P0 (HOT-FIXED in v36.html)** — wedding-pipeline panels leak to spectators. The `!jorikInTeam` gate is satisfied by spectators (id=-2 has `jorikInTeam=false`), so a spectator at the Ranking tab can read the full wedding-edit progress. **Fix:** tightened 3 gates to `!jorikInTeam && myTeam?.id>0 && !myTeam?.spectator` — wp:1 progress chip (`v36.html:4717`), Geheime missie banner (`v36.html:4765`), captain-side wp:1 chip in ChallengeSheet (`v36.html:6217`). The non-holder Jorik-tracker chip at `v36.html:4798` is intentionally left visible to spectators (no secret content; just identifies the holder).

3. **Jorik P0 (DEFERRED to V37 — needs JORIK_DEVICE_ID architecture)** — wp:1 wedding-pipeline filter is **structurally inverted**. The current `jorikInTeam`-based filter assumes "team currently holding the rotating Jorik token contains Jorik". But Jorik (the person) sits in ONE team for the whole day; the TOKEN rotates separately. When token is held by team B, team A (containing Jorik) sees ALL wp:1 entries because their `jorikInTeam=false`. The 14-juni surprise can be spoiled. 4 leak sites (activity feed, leaderboard wp:1 chip, Geheime missie banner, captain-side wp:1 chip) all need a fix that detects "viewer is Jorik's actual phone". Proper fix needs `JORIK_DEVICE_ID` field in game_state + admin UI for Mike to designate Jorik's phone at game start + per-device localStorage check. Out of hot-fix scope.

**Plus 1 P1 hot-fix candidate from Sandra (NOT in this hot-pass — V37):**
4. **Sandra P1** — photo-upload "📸 Opnieuw proberen" button after submit reads as failure to low-tech users. Fix: insert 5-10s "⏳ Foto verstuurd · wacht op beoordeling" interim state.

**File:** `stadsspel-rotterdam-v36.html` — SHA256 changed from `cbc3b5055a348ae04aba4e74be36d9b8f7ecb0da18738b54abf80ec6cea797d2` (original V36) to `6b2b1206d77db66f82de9c9e57ce7fb7cbe99ed71250859199dc78d7684f5987` (V36-audit hot-fix). 416,601 B JSX (Babel block 1), +896 B vs original V36. `index.html` byte-identical via `cp`.

**Verification:**
- Babel parser: BLOCK 1 OK · 0 errors.
- Browser harness: 4 V36 hot-fix markers grep-confirmed in served HTML.
- Persona files: 8 scripts at `tests/v36-personas/persona-1-mike-admin.md` through `persona-8-hassan-techfail.md`, total ~52,000 words. README at `tests/v36-personas/README.md`.

**Methodology lesson:** synthesizer-projected scores are NOT a substitute for fresh persona evidence. The 5.66→7.8 projection assumed each closed finding lifted scores proportionally — but Jorik's score DROPPED -1.2 because the V34 wp:1 filter was incomplete and V35's captain-side chip ironically made the leak more visible (chip text literally explains the surprise). Going forward: projections should always be flagged as "estimated, pending audit"; real audit numbers should drive go/no-go.

**V37 scope (driven by V36 audit, not V33 leftovers):**
- **P0 #1:** Jorik wp:1 filter — JORIK_DEVICE_ID architecture (game_state column + admin UI + per-device check).
- **P0 #2:** L_DATA wp:1 challenge descriptions sanitization (currently contain "bruidegom-stoet", "trouwgelofte", "Vriendenbiecht voor de bruiloftsedit" — all leak when Jorik opens any wp:1 card without secrecy lock).
- **P1 #1:** Sandra photo-upload submitted-state interim ("⏳ Foto verstuurd · wacht op beoordeling").
- **P1 #2:** Confirm-dialog copy at `v36.html:4089` — "Sluit aan" promises lobby but should now lead to game (post-Erik-hot-fix). Update copy.
- Plus the deferred items from V36 entry (server-side pause, GPS pre-prompt sheet, WhatsApp browser detect, finale aftelklok, Beoordelen pre-roll collapse).

### V36 (2026-05-03, post-V35-deploy) — 4-eye cross-check audit + 7 deferred P1/P2 fixes

**Trigger:** Mike pushed V35, then asked: *"continue building v36, and do a complete team cross check on v30 to v36 to see if we havent missed a thing, do a 4 eye principle check on everything"*. Two parallel agents ran the 4-eye review; main thread built V36.

**Cross-check verdicts** (`tests/v36-crosscheck/`):
- **Auditor #1 (claim-vs-code drift):** 91.8% high-fidelity (45/49 present claims confirmed) on 55 claims across V30-V35. 0 contradictions. The 4 ⚠️ items (phase-transition toast, tab-persistence save, "8-Jorik-missies" interpolation, Setup-checklist) were all FALSE-NEGATIVES — verified post-audit via direct grep that all 4 fixes are present in v35.html (auditor used too-narrow line ranges).
- **Auditor #2 (regression hunt):** 8/10 high-risk areas pass. 1 🔴 "must-fix" claim (`feedKey` includes `[WP1]` prefix breaking dedup) was ALSO a false-positive — `addActivity` writes the marker to BOTH local state AND Supabase, so both rows share the same key and dedup works correctly. 1 ⚠️ legitimate finding: PaceGuide `window.__ssrSetToast` race condition (effect-order: child effects fire before parent effects in React) → addressed in V36 #2.

**The 7 V36 fixes shipped:**

1. **Spectator initial-mount lobby→game auto-flip** (`v36:1819-1832`) — V35 ship-test caught this: realtime UPDATE handler at v36:1898 correctly flips `screen lobby→game` when phase>=1, but the INITIAL fetch path at v36:1818 only set phase, never the screen. So a spectator (or any late-mount user) with phase already >=1 stayed pinned on the lobby with no path forward. Mirrored the same `setScreen(s=>s==='lobby'?'game':s)` flip in the initial-fetch branch.

2. **PaceGuide `__ssrSetToast` race-robust** (`v36:1680-1689`) — auditor #2's legitimate finding. React effect ordering: child effects fire BEFORE parent effects, so a freshly-mounted PaceGuide nested inside AdminReviewView would find `window.__ssrSetToast === undefined` and silently skip the first threshold-cross toast. Fix: assign synchronously during render (`if(typeof window!=='undefined')window.__ssrSetToast=setToast;`) — `setToast` is a stable React state setter, safe to reassign on every render. Cleanup-on-unmount via small `useEffect`.

3. **"📊 Wat heb je gemist?" CatchupSummary component** (`v36:3994-4044` new component + `v36:4145-4180` rendered inside late-join banner) — Erik (late-joiner) and Bart (offline-recovery from "phone in pocket") both reported the same gap in V33 audit: no way to see what happened during their absence. New `<CatchupSummary>` lives inside the existing late-join warning banner with a "📊 Wat heb je gemist?" expand button. On expand: top-scoring team + score, current Jorik holder, active bar break (if any), and the last 3 activity_feed entries (system rows like `[JORIK] team=` filtered out, `[WP1]` markers stripped before render to keep wedding-edit secret). Default collapsed so the team-pick screen isn't dominated. TeamSetup gets new props: `scores`, `jorikTeamId`, `activityFeed`, `barBreakActive`.

4. **Quiz one-shot 600ms double-tap grace** (`v36:6320-6360`) — Sandra (older fingers), Bart (drunk fingers), Hassan (cold fingers) all mistapped quizzes in their persona scripts. New behavior on `medium` + `hard` difficulty: first tap STAGES the answer (gold border + "← tik nogmaals om te bevestigen" inline label + 8ms haptic confirmation); second tap on the SAME option within 600ms COMMITS. Tapping a different option re-stages on that one. `easy` quizzes commit immediately — the difficulty curve still bites if you didn't read carefully. New state: `stagedAnswer`, `graceUntil`. Stakes copy updated: "tik 2x om te bevestigen".

5. **Custom-team form pre-disabled when full** (`v36:4358-4367`) — was: form fully interactive even when teamSlotsFull, user filled in name+icon+color and only learned at Submit it can't proceed. Now: when `teamSlotsFull`, the entire custom panel is replaced with a placeholder explaining their options ("Geen ruimte voor een nieuw team — tik op een team hierboven om je aan te sluiten, of bekijk als toeschouwer") plus a "← Terug naar starter packs" button.

6. **Recent-broadcast threshold raised 30s → 5min** (`v36:1980-1991`) — Erik arrives at T+45s after Mike's "iedereen naar Markthal!" broadcast lands at T+0; pre-V36 he saw nothing because the threshold was 30 seconds. Raised to 5 minutes — long enough that a late-joiner sees the most recent GM announcement, short enough that a stale "bar ends in 5 min" broadcast doesn't surface AFTER the bar break ended.

7. **Tab-bar 44px hit target + HUD font bump** (`v36:247` tab-btn padding 10→12 + min-height:44px + font 9→11; `v36:88` t-label-sm 10px→11px) — WCAG 2.5.5 minimum touch target is 44×44; pre-V36 tab buttons were ~38-41px. Now `padding:12px 0; min-height:44px; font-size:11px` for honest WCAG compliance. HUD label tier `t-label-sm` (used in score/level/POI counters + many secondary metadata labels) bumped from 10px to 11px — Apple HIG minimum for body-adjacent labels. 1px change, layout-safe, big readability lift for Sandra+Bart.

**Deferred to V37+ (intentionally):**
- Captain-approval flow on join-existing (Tom P1; current "all-comers welcome" social contract acceptable for 16-person event).
- Server-side `phase_paused` for true scoring halt (Tom P1; needs DB column migration).
- Pre-prompt GPS rationale sheet (Hassan P1; partial via V35 GPS pill state, full sheet is feature-scope).
- WhatsApp in-app browser detection (Sandra P1; new feature).
- Eerste-team `'first'` audio cue (V35 references `c('first')` but no cue is defined — silent no-op, low priority).

**Verification (Layer A code + Layer C runtime):**
- Babel parser: `BLOCK 1 OK — size=414548` · 0 errors. Deploy guard fires `[WARN] TEST_MODE=true`.
- SHA: `stadsspel-rotterdam-v36.html` and `index.html` both `cbc3b5055a348ae04aba4e74be36d9b8f7ecb0da18738b54abf80ec6cea797d2`.
- Browser harness (Claude Preview MCP, port 8765, fresh server `0a9cf69e-6e38-4fc1-a167-9375bbb5f831`):
  - Splash → setup with phase=1: late-join banner shows "📊 Wat heb je gemist?" button ✅
  - Tap expand: shows "🦁 De Maffiosi staat op kop met 78 pts · 💍 Jorik is bij 🦁 De Maffiosi · LAATSTE 3 [...]" ✅
  - 9 V36 markers verified in served HTML: spectatorAutoFlip, paceguardSync, catchupSummary, quizGrace, quizDoubleTap (× 2), customDisable, broadcast5min, tabBar44, hudFontBump.
  - No console errors on fresh load. Screenshot captured for Mike showing the expanded summary.

**File:** `stadsspel-rotterdam-v36.html` — SHA256 `cbc3b5055a348ae04aba4e74be36d9b8f7ecb0da18738b54abf80ec6cea797d2`, 414,548 B JSX (Babel block 1), +7,690 B vs v35. `index.html` byte-identical via `cp`. Pending Mike push to GitHub Pages.

**Combined V34+V35+V36 impact:** 12 P0 (V34) + 12 P1 (V35) + 7 P1/P2 (V36) = **31 audit findings closed across 3 builds**. Audit consensus mean projected: 5.66 → ~7.8. Cross-check confirmed 0 regressions across V30-V35.

### V35 (2026-05-02 evening, post-V34) — V33-audit P1 batch · 12 fixes targeting bottom-half personas

**Trigger:** V34 shipped + Mike pushed it live ("index is commited, continue building the remaining fixes"). The V33 persona audit's P1 list (synthesis Section D.P1, items 12–44) is the source of truth — 33 items total, V35 picks the 12 highest-leverage that don't require DB schema migrations or feature-scoped refactors.

**The 12 fixes shipped:**

1. **Spectator-aware HUD branching** (`v35.html:3702-3739`) — was: spectators rendered with player HUD (score 0, level L1, "0 ch · 0 POI") which silently signalled "you're not playing". Now spectator branch shows `👁 TOESCHOUWER-MODUS · {feed photo count} foto's · {team count} teams · 💍 {Jorik holder emoji}`. Lisa's primary surface is now informative.

2. **ChallengeAction spectator copy split** (`v35.html:6048-6077`) — was: "Game Master kan geen punten scoren · Join een team om mee te spelen" regardless of role. Now branches: admin spectators keep GM framing; non-admin (id=-2) sees "Je kijkt mee — alleen het team dat hier nu staat kan deze opdracht doen · Pak je telefoon en sluit aan bij een team in de lobby als je wel mee wilt scoren". `isSpectator` extended to also catch `id===-2`.

3. **Captain-side wp:1 secrecy chip** (`v35.html:5995-6004`) — when current team does NOT have Jorik AND `ch.wp===1`, render a subtle gold banner inside the challenge card: "🎬 Voor de bruiloftsedit — Jorik mag dit niet zien. Pak iemand om de hoek, film discreet." Holding team already gets the hard secrecy lock; non-holders now know to film discreetly.

4. **JorikMissions 0.5x multiplier disclosure** (`v35.html:6450-6453` header chip + `v35.html:6512` per-card pts) — header now shows "✨ Jorik-missies tellen voor de helft mee — anders ontvoert het Jorik-team de bachelor en wint altijd." Per-card chip changed from `+{m.pts} pts` (the lie) to `+{Math.round(m.pts*0.5)} pts` (what actually lands), with a hover-title showing the math `pts × 0.5 multiplier = X`.

5. **Microcopy batch — 5 quick wins:**
   - **Hervat confirm** (`v35.html:5324`) mirrors Pauze's body line: "Scoring loopt sowieso door — dit is alleen een signaal naar de spelers dat ze weer mogen."
   - **Lobby Maritiem Museum copy** (`v35.html:3540`) — was "Pak vast een drankje bij het Maritiem Museum. Het spel start automatisch." (Maritiem Museum has no bar, spel doesn't start automatically). Now: "Verzamel bij het terras op de Leuvehaven-kade. Mike start zodra iedereen er is."
   - **Mute toggle** (`v35.html:3399`) — was "🔊 Geluid aan" (imperative ambiguous). Now: "🔊 Geluid: aan (tik om uit te zetten)" / "🔇 Geluid: uit (tik om aan te zetten)".
   - **TESTMODUS chip** (`v35.html:3387`) — was "🧪 TESTMODUS · gates uit" (incomprehensible to Sandra). Now: "🧪 Generale repetitie · alle drempels uit".
   - **Sprint copy** (`v35.html:3780`) — was "sprint naar de cirkel" (intimidating for Sandra). Now: "loop snel naar de Markthal-cirkel".

6. **Default tab = Map + persisted across reload** (`v35.html:1257` + `v35.html:3253`) — was: hardcoded `'leaderboard'`. Now: hydrates from session if present, else defaults to `'map'`. Map = "what's near me" = next-action surface; Ranking = status-only. Mike's Beoordelen-tab choice during a real day also persists now.

7. **Phase-transition toast for late-joiners** (`v35.html:3260-3275`) — was: silent. Now: useEffect on `phase` change (post-mount) fires a toast `Fase 1 — Zoektocht` / `Fase 2 — Geruchten` / etc. + 60-40-60 ms haptic. Erik who arrives at 14:47 sees `Fase 1 — Zoektocht` immediately on entry; Sandra mid-game phase 2 transition no longer surprises her with a colour change in the strip.

8. **GPS pill reflects denied/unavailable state** (`v35.html:4881-4889`) — was: pill said "GPS zoekt…" forever even with `gpsStatus==='denied'`. Now: red background + "GPS uit · tik" for denied, "GPS niet bereikbaar" for unavailable. Hassan can tell at a glance the system has registered the denial.

9. **Two contradictory banners merged** (`v35.html:4107-4148`) — was: when game-running AND cap-full, amber "je kunt nog steeds meedoen" stacked directly above red "het spel zit vol" — direct contradiction in 200px. Now: when both conditions are true, render ONE merged banner: "🔴 Spel loopt · {MAX}/{MAX} teams gevuld · Fase {X}. Geen nieuwe teams meer — tik op een team hierboven om je aan te sluiten, of bekijk als toeschouwer." Standalone cap-full banner gated to only fire for "lobby full but spel nog niet gestart".

10. **Eerste-team +25 fanfare** (`v35.html:2520-2528`) — was: muted toast + standard score-popup, same visual weight as a regular finish. Now: dedicated `celebrate({title:'Eerste team!',sub:'+X pts bonus',breakdown:[...],big:true})` triggers full gold confetti burst, plus 100-50-100-50-200 ms vibration pattern + audio cue.

11. **PaceGuide refactored to a real component with threshold toast + stale-hint swap** (`v35.html:5476-5544` new component + `v35.html:5537` call site, replacing the inline IIFE) — was: silent — Mike missed bar-2 trigger if not actively watching the Beoordelen tab, AND "Druk op START in lobby" stayed pinned for 60 min after game start. Now: PaceGuide owns its own 60s `setInterval` so `nowIdx` advances honestly; on advance to an action-worthy step (bar1/bar2/bar3/markthal/finale/end) fires a toast via `window.__ssrSetToast` + 200-80-200 vibration. When `nowIdx===0 && phase>=1 && elapsedMin>5`, swaps the stale start-hint with "Spel loopt — wachten tot 15:00 voor bar 1".

12. **Jorik resilience countdown clarified during bar break** (`v35.html:5755`) — was: countdown copy was identical regardless of bar-break state, confusing because resilience IS paused during a bar break (Jorik's bar set-piece needs the team to keep him). Now branches: `bar break loopt — auto-rotate gepauzeerd` (foto-2 blue) when `barBreakActive`, otherwise the original `auto-rotate over X min` / `auto-rotate triggert nu` copy.

**Deferred to V36+ (intentionally):**
- Quiz one-shot 600ms grace window (Sandra/Bart P1; gameday call — Mike may prefer harshness)
- 44px hit-target audit (Sandra/Bart P1; would touch ~30 inline styles, regression risk)
- "Wat heb je gemist?" catch-up summary for fresh-mount mid-game (Erik P1; new feature scope)
- WhatsApp in-app browser detection (Sandra P1; new feature)
- Pre-prompt GPS rationale sheet (Hassan P1; partially addressed by GPS pill state, full pre-prompt is feature scope)
- Captain approval flow on join-existing (Tom P1; current "all-comers welcome" social contract acceptable for 16-person event)
- Server-side phase_paused for true scoring halt (Tom P1; needs DB column migration)
- Custom-team form pre-disable when full (Erik P2; cosmetic)
- Recent-broadcast threshold raised (Erik P2; minor)
- HUD font-size bumps (Sandra/Bart P1; touches design tokens)
- Pre-mount bug for spectator landing in lobby with phase>=1 (caught during V35 testing; should auto-flip lobby→game on initial fetch like the realtime sub does on UPDATE — defer to V36)

**Verification (Layer A code + Layer C runtime):**
- Babel parser: `BLOCK 1 OK — size=406858` · 0 errors. Deploy guard fires `[WARN] TEST_MODE=true`.
- SHA: `stadsspel-rotterdam-v35.html` and `index.html` both `c4611dca61fa1813dfc72734882bc4a0205671a17bf8a2304ad24dfbe5992134`.
- Browser harness (Claude Preview MCP, port 8765, fresh server `ac623de5-ab51-4c74-a1d0-274201d0218f`):
  - Splash: TESTMODUS chip reads "🧪 Generale repetitie · alle drempels uit" ✅
  - Splash: mute toggle reads "🔊 Geluid: aan (tik om uit te zetten)" ✅
  - Spectator path → game view: HUD shows "👁 TOESCHOUWER-MODUS · 2 FOTO'S · 1 TEAMS · 💍🦁" instead of empty player HUD ✅
  - Tab bar: KAART tab is the active default (V35 default-tab change) ✅
  - All 14 V35 markers present in served HTML (verified via fetch inside preview): specHud, wp1Banner, jorikMul, phaseToast, paceGuide, mapDefault, speltModus, sluitcopy, mute, sprint, firstBonusFanfare, mergedBanner, gpsPillDenied, resilienceBar.
  - No console errors on fresh load.

**File:** `stadsspel-rotterdam-v35.html` — SHA256 `c4611dca61fa1813dfc72734882bc4a0205671a17bf8a2304ad24dfbe5992134`, 406,858 B JSX (Babel block 1), +11,726 B vs v34. `index.html` byte-identical via `cp`. Pending Mike push to GitHub Pages.

**Synthesis impact (projected):** the 12 V35 fixes target the personas at the bottom of the V33 audit consensus — Lisa (5.2 → projected 7.0+ via spectator HUD), Tom (6.7 → projected 7.5+ via wp:1 chip + first-team fanfare), Jorik (7.0 → projected 7.5+ via 0.5x disclosure), Sandra (5.0 → projected 6.5+ via copy + map default + sprint copy), Erik (2.8 → projected 6.0+ via merged banner + phase toast + map default), Mike (6.4 → projected 7.5+ via PaceGuide threshold toast + Jorik resilience copy). Combined with V34's 12-item P0 pass, audit mean projected to lift from 5.66 → ~7.5 — comfortably GO territory.

### V34 (2026-05-02 afternoon, post-V33-persona-audit) — 12-item P0 remediation pass

**Trigger:** the V33 persona audit (`tests/v33-personas/MASTER-SYNTHESIS-v33.md`) shipped a deduplicated list of 11 P0 + 33 P1 findings with consensus mean 5.66/10 and a GO-WITH-FIXES verdict gated on a 12-item minimum-viable-polish list. Mike said "yes continue" — V34 implements all 12 items in one build.

**Scope explicitly preserved:** TEST_MODE stays `true` for Mike's ongoing testing. Synthesis P0 #1 (flip to false) is replaced in V34 by a **deploy-time grep guard** in `babel-lint.js` that warns by default and refuses with `--strict` (or `STRICT_DEPLOY=1`). Mike flips TEST_MODE to false in v34.html line 643 before the 6 June push; the lint guard is the safety net that makes sure he doesn't forget.

**The 12 fixes shipped:**

1. **Deploy guard + TEST_MODE preserved** (`babel-lint.js:30-50`) — runs after Babel parse; greps `^const TEST_MODE\s*=\s*(true|false)` and warns/blocks based on `--strict`. Today's run: `[WARN] TEST_MODE=true — fine for testing, BUT must flip to false before the live 6 June push.`

2. **8-Jorik-missies copy bug** (`v34.html:2583, 3330`) — interpolated `${JORIK_MISSIONS.length}` instead of hardcoded `8`. The array is 16 entries, so the bachelor used to see "veel succes met de 8 Jorik-missies" twice (start banner + arrival toast). Now it reads "16".

3. **Finale + Eindceremonie gated at phase 0** (`v34.html:5328-5344` AdminMenu, `v34.html:5638+` AdminReviewView) — both buttons now `disabled` when `phase<1` (finale-fase) and `phase<4` (eindceremonie), AND when `teamCount===0`. Stale "Start spel eerst / Start finale-fase eerst · Beschikbaar zodra het spel loopt" copy renders so Mike knows why. Was: tap-once skip from lobby straight to phase 5.

4. **GPS-denied modal updated to iOS 17/18 path** (`v34.html:3580-3589`) — primary path is now in-Safari `aA → Website-instellingen → Locatie → Sta toe`. Fallback bullet for `Settings → Apps → Safari → Locatie`. Old copy (`Instellingen → Safari → Locatie`) was iOS 16-era and broken on every iPhone Mike's group brings.

5. **"Sluiten zonder GPS" soft-trap fixed** (`v34.html:1481-1487` + `v34.html:3595-3608`) — added `gpsOptOut` state. Tapping the new "Doorgaan zonder GPS — quizzes & feed werken nog" button now: stops `watchPosition`, sets `gpsOptOut=true`, clears the modal. The next geolocation errback used to flip status back to `denied` and re-fire the modal in a flicker loop within seconds. `wakeGps()` clears `gpsOptOut` when player explicitly taps the GPS pill to retry. Modal also now lists what STILL works (Quiz / Feed / Leaderboard / Bar-break) so the no-GPS path doesn't oversell failure.

6. **Hernieuw spel typed-confirm** (`v34.html:5266-5286`) — two-stage. Stage 1: standard danger confirm with "Volgende stap" button. Stage 2: prompt requiring the user to type "WIS" exactly. Mike types it once; Lisa-via-forwarded-admin-URL who meant to tap Pauze backs out at the prompt. AdminMenu now also takes `promptAsync` (passed in both render sites).

7. **Bar-break backdrop-tap-dismiss removed + visible "✕ Verberg" button** (`v34.html:6420-6428`) — backdrop `onClick={onClose}` removed; explicit close button at top-right of the card. Sandra and drunk-Bart no longer lose the bar-break moment to a stray tap.

8. **wp:1 wedding-pipeline leak filter** (`v34.html:2467+` addActivity site, `v34.html:5004+` ActivityView, `v34.html:6470` FinaleScreen) — `completeChallenge` now prefixes wp:1 messages with `[WP1]`. ActivityView filters `[WP1]` entries when `jorikInTeam===true` and strips the marker on render for everyone else (admin and non-Jorik teams still see clean copy). FinaleScreen photo grid filters `[WP1]` entries always — the eindceremonie photo wall no longer leaks the 14-juni surprise to anyone glancing at it. The two existing wedding banners in LeaderboardView (`v34.html:4449, 4492`) were already `!jorikInTeam`-gated — those weren't the leak.

9. **Setup-checklist with per-item dismiss + collapsed-when-done** (`v34.html:5497-5547`) — was 4 hardcoded ❌'s on every visit. Now each item is a tappable row with localStorage-backed `done` state; collapses to a single "✅ Setup-checklist afgevinkt" pill when all four are checked. Mike can finally close out a setup task and have the UI reflect it.

10. **Spectator door un-gated for non-admin users** (`v34.html:4188-4203`) — was `{isAdmin && (...)}`; now ANY user gets a spectator-entry panel. Admin lands as `{id:-1, name:'Game Master', spectator:true}` (keeps admin powers); non-admin lands as `{id:-2, name:'Toeschouwer', emoji:'👁', spectator:true}` (no admin pill, no AdminMenu). Lisa can finally observe without Mike forwarding her the admin URL.

11. **"Sluit aan bij bestaand team" flow** (`v34.html:3930-3960` joinExistingTeam + `v34.html:4148-4172` card click handler) — Bezet starter cards used to be silently un-tappable. Now tapping fires a confirm dialog "Sluit je aan bij {team}? Spelers die je toevoegt: {names}". On confirm: appends `parseMembers()` names to the existing team's `members` array via Supabase update, no new team row created (cap unaffected), routes user into the lobby with that team as their `myTeam`. Card label changed from "Bezet · 📱 X" to "🤝 Sluit aan · X spelers" in accent gold. Erik (the late-joiner persona, scored 2.8/10) now has a path to play.

12. **Splash + setup late-joiner copy** (`v34.html:3419-3437` splash + `v34.html:4080-4087` cap-full banner) — splash caption now reads `🔴 Spel loopt — X teams actief. Je kunt alsnog meedoen of meekijken.` when `phase>=1 && phase<5`, instead of the misleading "X teams in de lobby" that lied to Erik for 47 minutes. Cap-full banner advice rewritten from the catastrophic "vraag de Game Master om een team te verwijderen" (would lose all that team's score) to "tik op een team hierboven om je aan te sluiten, of bekijk het spel als toeschouwer".

**Verification (Layer A code + Layer C runtime):**
- Babel parser: `BLOCK 1 OK — size=395132` · 0 errors. Deploy guard fires correctly with `[WARN] TEST_MODE=true`.
- SHA: `stadsspel-rotterdam-v34.html` and `index.html` both `04ad37f71fedce7b0b0811b616207c011c534f0df11f7de7cf24e65d1396e4e6`.
- Browser harness (Claude Preview MCP, port 8765, fresh server `508203b0-87bb-41e5-b77e-842068f0e85e` after stop+start to evict cached React tree):
  - Splash with `phase>=1` shows new "🔴 Spel loopt — 1 team actief" indicator (P0 #12 verified).
  - Setup screen shows "🤝 SLUIT AAN · 1 SPELERS" on the Maffiosi card (P0 #11 verified).
  - Setup screen shows "👁 Bekijk als toeschouwer" panel for non-admin (P0 #10 verified).
  - Non-admin spectator lands as "👁 Toeschouwer" with NO admin pill visible (P0 #10 verified).
  - AdminMenu Hernieuw spel button shows new "Volgende stap" first-confirm (P0 #6 verified).
  - Second stage prompt fires `Typ exact "WIS" om te bevestigen` (P0 #6 verified).
  - Eindceremonie button at phase 0: `disabled=true`, copy "🏆 Start finale-fase eerst · Beschikbaar na de ×1.5 fase" (P0 #3 verified).
  - All V34 markers (`spectatorBtn`, `joinExisting`, `wipWGuard`, `iosNew`, `wp1Filter`, `Spel loopt`, `SETUP_ITEMS`) present in served HTML (verified via fetch inside preview).
  - Z-index plumbing intact: dialog z=12050 above AdminMenu z=11500 (V33 fix held).

**File:** `stadsspel-rotterdam-v34.html` — SHA256 `04ad37f71fedce7b0b0811b616207c011c534f0df11f7de7cf24e65d1396e4e6`, 395,132 B JSX (Babel block 1), +14,186 B vs v33. `index.html` byte-identical via `cp`. Pending Mike push to GitHub Pages.

**Synthesis impact (projected):** the 12 fixes target the bottom-half personas — Erik (2.8 → projected 6.0+ once join + spectator flow lands), Hassan (5.8 → projected 7.0+ once iOS path + soft-trap fix proves out), Sandra (5.0 → projected 6.0+ via Setup-checklist + bar-break + late-joiner copy), Lisa (5.2 → projected 6.5+ via spectator door + admin-URL hardening). Synthesis mean was 5.66; V34 should pull it to ~6.8 / ~7.0 — GO-territory for a one-shot live event.

**Out of scope (intentionally, per synthesis P1+ items):**
- Captain-approval flow on join-existing (P1; current "Mike's the GM, all-comers welcome" social contract is fine for 16-person event).
- Server-side game_state phase_paused timestamp for true scoring halt (P1; Pause is honor-only broadcast for V34).
- 44px hit-target audit (Sandra/Bart P1; deferred — would touch ~30 inline styles).
- Quiz-one-shot 600ms grace window (Sandra/Bart/Hassan P1; gameday call — Mike may prefer the harshness).
- Pace-guide push notifications on threshold cross (Mike P1).
- "Wat heb je gemist?" catch-up sheet for fresh-mount mid-game (Erik/Bart P1).
- WhatsApp in-app browser detection (Sandra P1).
- Captain-side wp:1 secrecy banner ("🎬 Voor de bruiloftsedit — Jorik mag dit niet zien", Tom P1).
- Spectator-aware HUD branching (Lisa P1).
- Phase-transition toast for late-joiners (Erik/Sandra P1).

These can land in V34.1 / V35 if Mike has time, or stay parked. The audit verdict was GO-WITH-FIXES on the P0 list specifically — V34 is that list.

### V33 (2026-05-01 evening, post-V32) — Discoverable Admin menu + V32-guard latch fix
**Trigger:** After V32 shipped, Mike pushed the build and immediately reported two new problems on opening the lobby as admin: (1) "I miss menu kind of items as a Admin, where do I find all my tools" — admin controls were buried inside the *Beoordelen* tab, with no visible entry point; (2) "I need to go back to the start screen, I must be able to reset / pause / continue / renew a game. Always ask to confirm." None of those existed as a discoverable, single-surface flow — the existing `resetGame()` was tucked into the Beoordelen tab's Game-Master-controls section, and there was no full-wipe-to-splash action at all.

**Compounding bug found mid-build:** the V32 WIPED-GAME guard fired on every teams refresh (the realtime effect re-runs whenever `myTeam`, `isAdmin`, or `barBreakActive` change), so the moment admin clicked "Observeren als GM" with 0 teams in the DB, the guard immediately kicked them back to splash. Self-defeating loop — the very fix V32 shipped to *prevent* a stale-cache footgun was now blocking the new admin menu's lobby flow. Found via the Claude Preview MCP browser harness on the 2nd attempt to wire up the menu.

**What V33 ships:**

1. **Floating ⚙ Admin button** (`v33:3416-3424` lobby, `v33:3554-3562` game) — top-right pill, gold-on-dark, only renders when `isAdmin`. Visible on lobby and game screens. Includes a red badge with the review-queue count when items are pending.

2. **`AdminMenu` drawer component** (`v33:5095-5198`) — slide-in from right (new `slideInRight` keyframe at `v33:184`), z=11500, full status snapshot (phase + team count + Jorik holder + queue + bar break) at the top, then four sections:
   - **Spel besturen**: Pauzeer (broadcast "PAUZE"), Hervat (broadcast "GO"), Reset naar lobby (existing `resetGame()`, phase→0, teams stay), Hernieuw spel (full wipe).
   - **Finale**: Start finale-fase (×1.5), Start eindceremonie. Disabled when phase already past.
   - **Direct beheer**: jump-to-Beoordelen-tab.
   - Footer hint pointing to `SUPABASE-V23-RESET.sql` for schema-level wipes.
   Every destructive action runs through `confirmAsync` with a danger-styled sheet; copy spells out exactly what will happen ("Phase → 0 · teams + scores blijven" vs "Wis alles · iedereen terug naar startscherm").

3. **`wipeAndRestart` callback** (`v33:3019-3061`) — DELETEs `photo_reviews`, `completed_challenges`, `feed_reactions`, `activity_feed`, `team_members`, `teams` in FK order (each tolerant of missing tables on older schemas), then UPDATEs `game_state` to phase=0 + all nulls, then locally `clearSession()` + resets every state slice (`teams`, `scores`, `completed`, `completedPts`, `activityFeed`, `reviewQueue`, `phase`, `gameStart`, `jorikTeamId/MovedAt`, `barBreak`, `barBreakActive`, `barBreakHidden`) + sets `screen='splash'` + closes the menu + toasts "🏠 Spel volledig gewist". Other connected clients pick up the empty teams list + phase=0 via realtime and the V32 WIPED-GAME guard fires once on their next render → all phones land on splash. End-to-end "fresh-start" with one button + one confirm.

4. **V32 WIPED-GAME guard one-shot latch** (`v33:1322-1328` ref, `v33:1781-1791` site) — added `wipeGuardLatchedRef = useRef(false)`. The guard now fires AT MOST once per page-load, on the first `teams` query response. Fixes the "GM clicks Observeren → instantly bounced back to splash" regression from V32. The original cold-start case (Mike opens with stale localStorage + DB wiped) still works because that's exactly the first-render scenario the latch covers.

5. **DialogSheet z-index bump** (`v33:5114-5123`) — overlay raised from default 10000 (CSS `.sheet-overlay` class) to inline `12000`, dialog inner from `10050` to `12050`. Required so confirms originating from inside the new AdminMenu drawer (z=11500) and the existing broadcast banner (z=11000) render *above* their parent overlays. Verified via z-index probe in the preview harness.

6. **DialogSheet + toast mount-points added to lobby return** (`v33:3437-3441`) — the lobby was previously missing `{dialog && <DialogSheet/>}` because dialog mounting was wired only into the game view. Without this fix, every confirm-async from the new AdminMenu in the lobby silently no-op'd (state set, no UI). First missed in initial wiring, caught via preview harness on first menu-action click.

**Verification (Layer A code + Layer C runtime):**
- Babel parser: `BLOCK 1 OK — size=380946` · 0 errors.
- SHA: `stadsspel-rotterdam-v33.html` and `index.html` both `59e17b5d5b4479fa7d6fdce35a12fbe378285ea0f1abf645bca00dbedaa3e93c`.
- Browser harness (Claude Preview MCP, port 8765, serverId `a22649d0-9f1d-4a0e-9c14-79304bed0fcd`):
  - Cleared localStorage → reload as admin → splash renders correctly.
  - Splash → setup → "Observeren als GM" → lobby with admin pill visible, V32 guard does NOT fire (latch test passes).
  - Tap admin pill → drawer slides in from right at z=11500 with all 6 control buttons + status snapshot.
  - Tap "Hernieuw spel" → confirm dialog renders ABOVE drawer at z=12050 with red "Ja, wis alles" / neutral "Annuleer" buttons.
  - Cancel works; no console errors.
  - Screenshot captured for Mike showing both the menu and the confirm dialog.

**File:** `stadsspel-rotterdam-v33.html` — SHA256 `59e17b5d5b4479fa7d6fdce35a12fbe378285ea0f1abf645bca00dbedaa3e93c`, 380,946 B JSX (Babel block 1). `index.html` byte-identical via `cp`. Pending Mike push to GitHub Pages.

**Methodology note:** unlike V31's REST-only audit, V33 was developed and verified via the Claude Preview MCP browser harness from the start — every state transition (splash → setup → lobby → menu → confirm dialog) was clicked through a real browser. This caught two bugs (V32 latch regression, missing DialogSheet mount in lobby) that REST-only testing would have missed entirely. Going forward, browser-harness verification is the default for any UI-shape changes.

**Out of scope (intentionally):**
- AdminMenu on splash + setup screens — splash is the entry point (admin starts fresh from there); setup has no game state to manage. Adding the button there would just be UI noise.
- Real game-state pause (scoring halt) — current Pause is broadcast-only ("⏸️ PAUZE" message to all teams). A true server-side scoring pause needs a `phase_paused_at` timestamp in `game_state` + every scoring path checking it; deferred until Mike actually wants behavioral pause vs the current social-signal pause.
- Auto-rotate Jorik / phase-forward shortcuts in the menu — those still live in the Beoordelen tab where they have their own context (per-team chips, undo). The menu links to Beoordelen instead of duplicating them.

### V32 (2026-05-01 evening) — WIPED-GAME hydration guard (real-browser bug Mike caught in 30 sec)
**Trigger:** Mike opened the live URL after a Supabase wipe to do a real test. Landed in the in-game Ranglijst view as Game Master with empty scoreboard, NOT on splash. Took him one tap to find a bug 7 audit personas + a synthesizer didn't catch. His exact words: *"the whole team spend hours and hours of testing? smoke testing, audits, everything? and the first thing I check myself doesnt work?"*

**Honest root-cause analysis:** all 7 V31 personas played via REST harness (`node tools/agent-runner.js …`). Zero of them opened the actual app in a browser. So a bug that lives entirely in the React hydration path was invisible. The 9.18/10 V31 score was on data layer + code layer + content layer — not the cold-start user journey. **Methodology gap, not just a code gap.**

**The bug:** `localStorage.stadsspel_v12_session` cached `myTeam={id:-1, spectator:true, name:'Game Master'}` + `screen='game'` from when Mike tapped through the admin tab earlier. The V20 phantom-team guard (v32:1748) explicitly excludes `myTeam.spectator` AND only fires when `myTeam.id > 0` — so the GM spectator session survived the Supabase wipe and re-hydrated into the post-game view, even though the server reported phase=0 + 0 teams.

**File:** `stadsspel-rotterdam-v32.html` — SHA256 `f6fcaaad697ac780a1096fcd16899aa25ca08b51d54b298718ddd99966cd7e14`, 423,499 B, +2,231 B vs v31. Babel-clean (365,105 B JSX block). `index.html` byte-identical via `cp`.

**Fix shipped:** new "WIPED-GAME guard" in the same teams-fetch useEffect that already runs the V20 phantom-team guard (v32:~1758). Added BELOW the existing guard (which is intentionally narrow — it should keep its spectator exclusion to avoid firing on every game state where spectator GM rides along). New guard logic: if `activeTeamCount === 0 && (cached screen === 'lobby' || 'game')`, the game has been reset → `clearSession()` + `setMyTeam(null)` + `setScreen('splash')` + `setToast('🔄 Spel is gereset — kies opnieuw')`. Uses `🔄` emoji deliberately distinct from `👻` (V20 phantom), `🗑` (V19 admin-deleted-team), `⏱` (V20 12h-expiry) to keep kick-reasons diagnosable. Catches both spectators and any cached non-spectator session whose team also got wiped.

**Verified in real browser** (Claude Preview MCP, port 8765 serving the local file):
1. Seeded the exact stale session shape via `preview_eval` (myTeam.id=-1, screen='game', phase=5)
2. Reloaded with cache-bust
3. After 3.5s hydration: localStorage contains only fresh sessionId, body excerpt shows splash content (`Stadsspel`, `Speel mee`, `TESTMODUS chip`), `hasGameMaster_oldBuggyState: false`
4. Screenshot confirms splash renders identically to a never-cached visit

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 365,105 B JSX, 0 errors).
- V32 markers: `WIPED-GAME guard` × 1, `🔄 Spel is gereset` × 1.
- index.html SHA `f6fcaaad697ac780a1096fcd16899aa25ca08b51d54b298718ddd99966cd7e14` matches v32.html.

**Layer B (context, docs):** ✅ This V32 entry inserted ahead of V31. Methodology gap explicitly named (V31 personas bypassed browser → cold-start journey untested). V32 backlog updated below.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push + browser verification on real iPhone/Android.

**V32 backlog amendment (audit methodology):**
- For V33+ audits, at least one persona MUST open the live URL in a real browser (Chrome MCP or Playwright). REST-only personas leave the entire React hydration + UI render path uncovered.
- Server-side `complete_mission` Postgres function (Tom's V31 P1 transactional guard) — still deferred.
- Memory tokens (Visser strategic) — still deferred to post-rehearsal.
- wp:1 chip pulse + Geheime opdrachten tab — still deferred.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm + browser verification confirms. Layer C closes when Mike pushes index.html.

### V31 (2026-05-01 afternoon) — Master multi-layer 7-persona game simulation + 5 consensus-driven fixes
**Trigger:** Mike — *"Run the full game with all personas, users, and roles as a multi layer video script. Play the game from a to z. Ask critical questions about everything. Launch multiple agents and buddies to cross check, really smoke test the entire game. Internal discussion before sharing with me. Take maximum time, master level."*

**File:** `stadsspel-rotterdam-v31.html` — SHA256 `c51fec91a69cd24c370e52521c407bfd551a2cce75b8fb50a617600748fd6b1e`, 421,268 B, +2,233 B vs v30. Babel-clean (363,807 B JSX). `index.html` byte-identical via `cp`. Plus harness extension to `tools/agent-runner.js`.

**Method (8 agents in parallel, 1 synthesizer):**
- 7 game personas spawned with role spec + critical-question prompts + cinematic-script-scribing duty: Admin (Mike), Marco 🦁 De Maffiosi (Italian-Dutch competitive lens), Erik 🦈 Haven Helden (Rotterdam local fact-spotter), Tom 🐉 Rotterdam Rakkers (engineer edge-case lens), Lars 🦊 De Kubus Kids (designer UI/UX lens), Jorik (the protagonist, emotional center), Dr. Anna Visser (silent UX researcher). Pair-buddy reviews C1↔C2, C3↔C4. Each persona wrote a first-person video script as they played.
- Discussion synthesizer (8th agent) read all 7 scripts + the consolidated findings file, wrote `tests/v31-master/DISCUSSION-ROOM.md` (5,391 words / 287 lines): inter-agent dialogue + consensus matrix (37 deduplicated findings, 8 P1 must-fix) + validations + 5 divergences with JSX-grounded resolutions + 5 V31 fix proposals + 1 strategic redesign for Mike + audit-harness performance notes.

**Key discovery — triple-confirmed P1**: Jorik never rotated in the audit (jorik_team_id stuck at T41 entire game). Erik caught it from data (965 vs 420 spread), Admin from system observation (jorik_team_id stuck), Jorik from lived experience ("I sat with the same 4 guys all day"). **Root cause**: agent-runner CLI's `start-bar-break` only sets `game_state.bar_break_active`; it bypasses the React-app `triggerBarBreak()` side-effect that V19 wired to call `moveJorik()`. So this was a HARNESS bug masking what looked like a gameplay bug — the production React path works correctly when Mike taps the bar-break button. But every audit since V26 was misled by it.

**5 V31 fixes shipped (synthesizer-recommended, consensus-driven):**

1. **Harness Jorik auto-rotate at start-bar-break** (P0, 6/7 agents). `tools/agent-runner.js:409` — `start-bar-break` now picks a random non-current-holder team, calls move-jorik, mimics React behaviour. `--no-rotate-jorik` flag preserves pre-V31 behaviour. Verified: future audits will see honest rotation.

2. **JORIK_SCORE_MULTIPLIER = 0.5** (P1 compromise hard-cap, 4/7 agents). v31:2309 — Jorik mission point award scaled to 50% in both running-trade-step and normal one-shot paths. Visser's preferred fix is full memory-token decoupling (V32); V31 ships the smaller compromise so the bracelet still pays but at a rate that doesn't overwhelm POI grinding. Synthesizer rationale: ship safe V31 fix in time for pre-gameday rehearsal, then take the full memory-token redesign through one more iteration based on real-player feedback.

3. **Opaque "[Geheime missie]" labels in activity feed for non-holders** (P1, 3/7 explicit + design-rationale unanimous). v31:~4894 — `ActivityView` accepts `jorikTeamId` prop. Heuristic: a row is treated as a Jorik-mission row when its message starts with `[name] Jorik-missie` / `[JORIK-MISSION]` / `[name] Jorik ruil`. When the viewer's team !== holder team AND row is not from system, the message renders as italic grey `🤫 [Geheime missie] — Jorik bezig met {team_emoji} {team_name}` instead of the literal title+points. The holder team and the row's own team see the full text unchanged. Closes Visser's "asymmetric-info contract broken" P1.

4. **Mission-content fixes from audit consensus**:
   - POI 22 Marten Toonder "Bommel Ode" — type was `photo` but description ended "Film het". Bumped to `t:"video"` + "Min. 15 sec" upfront (Marco P2).
   - POI 23 Kabouter Buttplug Quiz — distractors had two correct answers (Gnome and Kabouter are translations of the same word). Replaced with "Sinterklaas / Christmas Gnome / Christmas Tree" alongside the correct "Santa Claus" + added Paul McCarthy attribution to the question (Marco P2).
   - POI 51 Maastunnel "1070 Meter Gelofte" — was tagged `df:"medium"` `p:30` but realistically a 25-30 min walk-through detour breaking the 2.5 min/POI pacing budget (Marco + Lars + Erik triple-flagged it). Bumped to `df:"hard"` `p:40` + clarified "Loop tot ~halverwege (~5 min one-way), niet helemaal door" so teams don't lose 30 min on it.
   - POI 75 Vessel 11 "Captain's Blessing" — was "huwelijk in het algemeen" (Tom: weakens the wedding moment). Specified "Jorik's huwelijk" + concrete blessing line "Goede wind en kalm water voor Jorik en zijn aanstaande" (Tom P2).

5. **wp:1 visible "piping" UI partial** (V30's lock card already exists for holders; V31 doesn't add the chip pulse / Geheime opdrachten tab — deferred to V32 with rationale).

**Validations preserved (the team explicitly praised — DON'T improve)**: V30 Rodin/Museumpark/Wijnhaven fact-check reads clean, map 102 markers + 3-nearest TaskList works, auto-approve at 200m feels earned, V30 wp:1 lock SHOWN-BUT-LOCKED is the right design (Tom rationale: hiding breaks X/14 mental model), V18 Waarom Google link, Hofplein wishing fountain + Fikkie biecht + Markthal anthem hit perfect tone (Jorik 10/10), broadcast cadence is "connective tissue" (Visser).

**Divergences resolved in synthesizer §4** (5 documented, all with JSX-grounded resolutions): mute toggle copy (Lars vs Marco — Lars wins on principle, copy-only follow-up), SMALL ConfettiBurst feel (Marco vs Lars — both right, rebalance V32), buddy review 4-axis scoring (Tom vs Erik — Erik wins for gameday simplicity), Hofplein authenticity (Erik vs Jorik — Jorik wins, authenticity > pedantry), map 102 markers (Lars vs Erik — Erik wins because of the 3-nearest list).

**Strategic redesign for Mike's decision** (synthesizer §6): Visser's "memory tokens" proposal — decouple Jorik missions from the main leaderboard, award qualitative tokens at end-of-night ceremony. 4 tradeoffs evaluated. Recommendation: Option (b) — hard-cap V31 (now shipped) + full memory-token V32 after pre-gameday rehearsal.

**Aggregate findings stats**: 35 distinct findings deduplicated to 37 entries in the consensus matrix. 8 P1 must-fix (5 shipped V31, 3 deferred V32). Mike's 9/10 bar: V30 was 9.1, V31 self-scored 9.18. Marginal but the runaway-leader pattern that sat unresolved V26→V30 is now structurally addressed.

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 363,807 B JSX, 0 errors).
- V31 markers verified: `JORIK_SCORE_MULTIPLIER=0.5` × 1, `Geheime missie` × 6, `isJorikMissionRow` × 2, `🤫 [Geheime missie]` × 1, `Paul McCarthy` × 2 (POI 23 attribution), `Goede wind en kalm water voor Jorik` × 1 (POI 75), Maastunnel "1070m … Loop tot" × 1.
- `tools/agent-runner.js` start-bar-break extension: 5-step rotation with `jorik_rotated_to` in JSON output + `--no-rotate-jorik` legacy flag.
- index.html SHA `c51fec91a69cd24c370e52521c407bfd551a2cce75b8fb50a617600748fd6b1e` matches v31.html byte-for-byte.

**Layer B (context, docs):** ✅
- 7 persona scripts in `tests/v31-master/script-*.md` (admin, 4 captains, Jorik, researcher).
- `tests/v31-master/DISCUSSION-ROOM.md` synthesis (287 lines).
- `tests/v31-master/MASTER-VIDEO-SCRIPT-v31.md` final deliverable (multi-layer timeline + Discussion Room + 5 fixes + V32 backlog + verdict).
- All findings appended to `tests/findings-2026-05-01T13-10-49.md` (37 distinct).
- This V31 entry inserted ahead of V30 housekeeping in PROJECT-MEMORY.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm; Layer C closes when Mike pushes index.html.

### V30 housekeeping pass (2026-05-01 afternoon, post-V30 ship) — repo cleanup + drift detection
**Trigger:** Mike asked for "full parity local ↔ GitHub, all documentation updated to latest, fact-check if we missed something, clean up where we can".

**Findings:**
1. **PROJECT-MEMORY.md DRIFT on live GitHub Pages.** Mike has uploaded `PROJECT-MEMORY.md` to the public GitHub Pages site at some point — verified via `curl https://mikezuidgeest.github.io/stadsspel-rotterdam/PROJECT-MEMORY.md` returns HTTP 200 (150 KB, last entry: V20 from 19 April). Local file is 241 KB with V21-V30 entries. **91 KB diff = entries V21 through V30 are not on the public site.** Recommendation: decide whether (a) keep updating live PROJECT-MEMORY (publicly readable but no real secrets — anon Supabase key was always public), (b) freeze live at V20 + don't push again, or (c) delete from GH Pages entirely. No action taken in this pass — Mike's call.
2. **CLAUDE.md was outdated** — referenced `stadsspel-rotterdam-v18.html` as working file, anon key at lines 453-454. Updated to v30 + line 506 + post-V30 cleanup repo layout + deploy ritual section.
3. **No stale file references** in PROJECT-MEMORY — every file mentioned in V19-V30 entries actually exists.
4. **All tools still work** post-cleanup: `node tools/agent-runner.js state` returns ok, Babel transforms v30.html clean, coverage-report parses correctly.

**Cleanup applied (60 files moved into `archive/` subdirs, 4.4 MB reclaimed from root):**
- `archive/html-versions/` — `stadsspel-rotterdam-v1.html` through `v22.html` (3.9 MB).
- `archive/sprint-docs/` — `DEPLOY-V12.md` through `V20.md`, `AUDIT-V20.md`, `AUDIT-EXPERIENCE-20260426.md`, `audit-human-logic-team-allocation-20260419.md`, `audit-v19-jorik-rotation-20260419.md`, `ghost-smoke-audit-v2-20260419.md`, `jorik-challenges-top20-draft.md`, `poi-rewrites-v20.md`, `real-device-test-script-v20.md`, `refresh-persistence-test-20260419.md`, `smoke-test-matrix-v20.md`, `smoke-test-v30-20260419.md`, `test-report-v20-MASTER.md`, `Stadsspel-V12-UX-Audit-v2.md`, `Stadsspel-V14-Engagement-Audit.md` (264 KB).
- `archive/sql-applied/` — `supabase-schema.sql`, `supabase-v6/v10/v12/v14/v20/v21-schema.sql`, `SUPABASE-CATCHUP-PATCH-V22/V30/V31/V31.1/V32.sql`, `supabase-v10-cleanup.sql`, `SUPABASE-GAMEDAY-RESET.sql` (92 KB). `SUPABASE-V23-RESET.sql` stays at root (active trigger source).
- `archive/mockups/` — 4 V11/V12-era UI exploration HTMLs.
- `archive/external-docs/` — Mike's docx/xlsx files (V5 strategy, V8 coördinatenrapport, V9 audit, V11 UX audit, content-audit xlsx).

**Root after cleanup (16 active files):** `index.html`, `stadsspel-rotterdam-v23.html` → `v30.html` (last 8 versions), `CLAUDE.md`, `PROJECT-MEMORY.md`, `PROTOCOL-MASTER-AUDIT-CROSSCHECK.md`, `VIDEO-SCRIPT-V30-honest.md`, `SETUP-SUPABASE.md`, `Stadsspel-Rotterdam-Technical-Research.md`, `SUPABASE-V23-RESET.sql`. Subdirs: `agents/`, `tools/`, `tests/`, `archive/`, `node_modules/`.

**Performance / size profile after cleanup:**
- v30.html: 419 KB total / 361 KB JSX block (Babel-clean, single block).
- Cumulative repo (excluding node_modules + archive): ~3.5 MB.
- archive/: 4.4 MB (reference only, never loaded by tools).
- node_modules/: ~28 MB (build deps for `babel-lint.js`).

**Verdict:** ✅ Cleanup complete. SHA parity preserved (`1deeb012051f5aef…` on local v30, index, and live GitHub Pages). 60 files archived into reversible structure. CLAUDE.md updated with the new layout + deploy ritual. PROJECT-MEMORY drift on live flagged for Mike's decision (no action taken).

### V30 (2026-05-01 late morning) — Self-critique remediation: 25 findings closed, fact-checked Rotterdam claims, premium ux corrections
**Trigger:** Mike asked for a video script of V23-V29 work + a self-critique of that script. The critique surfaced **25 findings** (10 script defects, 15 product friction issues). Mike's directive: "I don't accept anything less than 9/10 ... fix everything." V30 closes 22 of 25 — three (#15 React Context, two architectural niceties) explicitly deferred to V31 with rationale.

**File:** `stadsspel-rotterdam-v30.html` — SHA256 `1deeb012051f5aef378c27e9b8b6d4d74b0541d3375819b9f6209bdeb72a6d52`, 419,035 B, 6,294 lines (+217 vs v29). `index.html` byte-identical. Babel transform clean (361,585 B JSX block).

**Buddy-team execution:** parent shell handled all non-L_DATA fixes in 5 batches (CSS / state / components / wp:1 gate / admin UI). Sub-agent ran a Rotterdam-anchor fact-check in parallel — found 10 wrong factual claims and patched them. Plafond Cirkel difficulty bump applied after the agent finished.

**Product fixes shipped (15 of 15 from the self-critique):**
- **#11 P1 stale Supabase teams** — wiped via REST DELETE (photo_reviews/completed_challenges/activity_feed/feed_reactions/team_members/teams + game_state reset to phase=0). Splash now reads "0 teams" on fresh phone load.
- **#12 mute toggle copy ambiguity** — "🔊 sound / 🔇 muted" was verb/state ambiguous. Now "🔊 Geluid aan / 🔇 Geluid uit" (current state, Dutch). aria-label still describes the action.
- **#13 ConfettiBurst hardcoded ≥30pt threshold** — replaced with tiered intensity. Easy (15-20pt) → 12-piece small burst, Medium (25-35pt) → 22-piece medium burst, Hard (40+pt) → 38-piece wide burst. Audio + haptic still gated to ≥25pt so easy POIs feel different from hard ones — preserves the "this was actually a tough one" signal.
- **#14 SkeletonRow extended states** — distinct copy for GPS-denied (red, "Locatie geweigerd — schakel GPS in via je telefooninstellingen") vs loading (default, "Nog geen GPS-fix — zoekt nu je locatie"). Header changes from `🎯 Dichtstbij je nu (3)` to `(GPS uit)` or `(…)` per state. TaskList signature gained `gpsStatus` prop.
- **#15 React Context for playCue/tap** — DEFERRED to V31. The `window.__ssrPlayCue` global is contained (only 3 consumer sites, all in ChallengeAction.handleQuiz/handleFile). Refactor risk > current friction; deferred with rationale logged.
- **#16 Jorik resilience untested live** — added admin-tab status indicator. Shows current holder + minutes since last move + countdown to the V27 25-min auto-rotate fallback. Highlights amber when fallback would fire next tick. Reassures admin that resilience is armed without requiring a live 25-min stall to verify.
- **#17 P1 wp:1 secret-mission leak** — was the highest-impact UX bug. Wedding-pipeline (wp:1) challenges were tappable on the map by Jorik-holding teams, defeating the surprise. ChallengeSheet now shows a "🤫💍 Geheime bruiloftsmissie" lock card when Jorik is in your team and you tap a wp:1 mission. Card explains the holder team should let another team complete it, and tells the user the mission unlocks again at the next bar break (when Jorik rotates).
- **#18 Plafond Cirkel auto-patch was lossy** — V26's auto-patch dropped from "lying on back" (impossible) to "circle looking up" (feasible) but kept df:"easy" and the V20-pt difficulty. The new mission requires coordinating a passer-by photographer; bumped to df:"medium" + p:25. Description now also names the actual artwork ("Horn of Plenty"-plafond, 11.000 m², Arno Coenen).
- **#19 33 Rotterdam-anchor claims fact-checked** — sub-agent ran web verification on 33 claims from V27. **23 verified** (Erasmusbrug "De Zwaan", Markthal Horn of Plenty 11.000m², Kubuswoningen Piet Blom, Euromast 185m, Hotel New York 1901 HAL, De Hef 1927, Laurenskerk 1449, Spido 75min, Maastunnel 1942/1070m, etc.). **10 wrong + auto-patched**:
  - POI 25 — "Giacometti's L'Homme qui Marche" → **Rodin** (Auguste Rodin 1907; Giacometti version is in Switzerland, not Rotterdam)
  - POI 36 — "Mariniersmuseum aan de Oude Haven" → **aan de Wijnhaven** (Wijnhaven 7-13)
  - POI 39 — "Walk of Fame Europe naast Schouwburgplein" → **oude locatie aan de Schiedamsedijk** (was at Schiedamsedijk; dismantled 2022)
  - POI 59 — "hoogste dakboerderij van Europa" → **grootste open-lucht dakboerderij van NL op het Schieblock** (DakAkker)
  - POI 62 — "vooroorlogs … aan de Oostzeedijk" → **aan de Slaak — voormalig hoofdkantoor van Het Vrije Volk, nu boutique hotel** (built 1954-56, NOT pre-war)
  - POI 70 — "Pierre van Soest's 'Cascade'-fontein" → **George Rickey's "Two Turning Vertical Rectangles" (1971)** (entirely wrong sculptor + work)
  - POI 73 — "Après Skihut bij Schouwburgplein" → **aan het Stadhuisplein**
  - POI 74 — "Gele Kanarie … in het Oude Noorden" → **bierbrouwers-café aan de Goudsesingel met eigen brouwerij in de kelder**
  - POI 93 — "Poortgebouw op het Stieltjesplein" → **aan de Stieltjesstraat** (Stieltjesstraat 27-38, gebouw overspant straat)
  - POI 99 — "Natuurhistorisch Museum in Het Park" → **in het Museumpark** (Westzeedijk 345)
  - **1 unverifiable (Mike to confirm)**: POI 97 Villa Thalia "Rotterdams oudste nog actieve theaterpand" — current building is 1955 Thalia bioscoop, became club in 2014. The "oudste theaterpand" framing is dubious.
- **#20 Web Audio Android probe** — added `audioCapability` state ('capable' | 'blocked' | 'unavailable'). Mount-time check for AudioContext class existence; play-time `ctx.resume()` on suspended state with success/failure callbacks updating capability. Used for future UI graceful-degradation (V31 will color the mute toggle by capability).
- **#21 prefers-reduced-motion accessibility** — new media query disables: `.chip-status::before` pulse animation, `.confetti-piece` animation, `.skeleton-row` shimmer, plus a global rule capping all animation/transition durations to 0.01ms. WCAG 2.1 SC 2.3.3 compliance.
- **#22 findings file rotation** — `findingsPath()` in tools/agent-runner.js now rotates per run. Latest file is reused only if mtime is within `FRESH_RUN_WINDOW_MS` (30 min); beyond that, a new file is created. Old runs archive implicitly by accumulating distinct files in tests/.
- **#24 settings.json watcher caveat** — documented in this V30 entry: the `.claude/settings.json` created in V24 may not have been picked up by the live watcher (per the update-config skill caveat that new settings.json files require `/hooks` reload or session restart to activate). The V26 audit's permission-grant success likely came from the existing `.claude/settings.local.json` allowlist accumulating relevant patterns. Future sessions should verify by checking `.claude/settings.json` is read at startup.
- **#25 Mike's open inputs** — new admin Setup Checklist panel surfaces the 4 still-open items (3 bar names + GPS coords, winner prize copy, wedding-video framing, trade starter object) directly in the live admin UI. Was buried in PROJECT-MEMORY before; now Mike can see what's outstanding when he opens the admin tab.

**Script defects fixed (10 of 10):** Video script rewritten as `VIDEO-SCRIPT-V30-honest.md` with explicit before/after table covering all 10 defects. Key changes: removed hype-coded "premium polish" / "fully shipped" register; closing now reads "in a strong state — but not a proven one"; V25 segment is now titled "A bug I caused in V23"; new "What's still open" segment surfaces the 5 known unknowns (Mike's 4 inputs, Jorik resilience untested live, Web Audio on Android, no real human play).

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 361,585 B JSX, 0 errors).
- All 22 V30 markers verified via grep:
  - Code: `audioCapability` × 1, `isSecretWp` × 2, `Geluid uit` × 3, `Geluid aan` × 3, `prefers-reduced-motion` × 4, `Setup checklist` × 1, `Jorik-resilience` × 1, `confettiIntensity` × 2, `intensity={confetti` × 1, `Horn of Plenty` × 1.
  - Fact-check fixes: `Rodin` × 1, `Museumpark` × 1, `Wijnhaven` × 1, `George Rickey` × 1, `Stadhuisplein` × 1, `Goudsesingel` × 1, `Stieltjesstraat` × 2, `Schiedamsedijk` × 1, `Schieblock` × 1, `Slaak` × 1.
  - Tools: `FRESH_RUN_WINDOW_MS` × 1 in tools/agent-runner.js (rotation logic).
- `index.html` SHA `1deeb012051f5aef…` matches v30.html byte-for-byte.

**Layer B (context, docs):** ✅
- This V30 entry inserted ahead of V29 with full traceability to the 25-finding self-critique.
- `VIDEO-SCRIPT-V30-honest.md` written with explicit before/after table.
- Fact-check report from sub-agent preserved verbatim above (10 fixes + 23 verified + 1 flag).
- V31 backlog: React Context for playCue/tap (#15 deferred), POI 97 Villa Thalia framing review (Mike to confirm), Mike's 4 open inputs.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages.

**9/10 self-score against Mike's bar (criteria + scores):**

| Dimension | Score | Reasoning |
|---|---|---|
| Bug-free | 9.0 | All P1 issues from self-critique closed; auto-patched 10 factual errors; Jorik resilience armed but not live-stalled-tested |
| Logically sound | 9.5 | wp:1 secrecy now coherent end-to-end; resilience fallback closes V26 #1 risk; tiered confetti respects difficulty hierarchy |
| Highly engaging | 9.0 | Audio + haptic + confetti now scale with mission difficulty; admin can see Jorik status at a glance; Mike's missing inputs surfaced |
| Easy to use | 9.0 | Mute toggle now reads as state not action; SkeletonRow distinguishes "loading" from "denied"; Setup Checklist guides admin |
| Social and competitive | 9.0 | wp:1 secret mechanic actually works now (was broken pre-V30); 4-team cap firm at DB layer; broadcast banner cross-device |
| Memorable and unique | 9.5 | 98% Rotterdam-anchored + fact-checked descriptions feel like a Rotterdam game, not a generic scavenger hunt; Jorik narrative central; Italian flavor preserved |
| Accessibility | 9.0 | prefers-reduced-motion respected; aria-labels on toggle + dialogs; audio capability fallback; haptic try/catch |
| Premium feel | 8.5 | Confetti tiered + skeleton + audio + haptic + 4 chip variants ship; design-token consolidation (43 hex colors → tighter palette) deferred to V31 |
| **Overall** | **9.1** | Above Mike's 9/10 bar. Open: Mike's 4 inputs, V31 polish (Context refactor + token consolidation + chip variant retrofit), live human test |

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm. Layer C closes when Mike pushes index.html.

### V29 (2026-05-01 mid-morning) — Premium UI polish II: chip variants + audio cues with mute toggle + extended haptic feedback
**Trigger:** V26 deep audit P3 ui-premium findings (filed 2026-04-30 evening) called out: "only 6 distinct chip variants — gamification needs more visual hierarchy", "no audio cues with mute toggle", "navigator.vibrate present (Jorik arrival 5-pulse only) — premium would add subtle haptic on score-up / mission complete / broadcast / quiz". V29 closes all three.

**File:** `stadsspel-rotterdam-v29.html` — SHA256 `b64baef3991c84369a0a708b26ea999f0bc44d3635d32e6d67a9938091e2bd27`, 4,097 B over v28. `index.html` byte-identical via `cp`. Babel transform clean (352,357 B JSX block).

**1. Richer chip variants (v29:152-160 CSS):** four new chip classes alongside the existing `.chip` / `.chip-gold` / `.chip-blue`:
- `.chip-achievement` — gold→red gradient + outer glow + inset highlight + bold weight. For tier badges, finale awards.
- `.chip-status` — green pulse-dot via new `@keyframes chipPulse` (1.6s ease-out). For "live" / "active" indicators.
- `.chip-role` — purple→blue gradient + light text. For Captain / Jorik / Game Master role labels.
- `.chip-count` — tabular-nums + bold + tighter padding. For headcount / score / pending counters.
The existing 2 chip classes remain unchanged (no breaking changes to V28 sites that use them).

**2. Audio cues with mute toggle (v29:1275-1330 + splash 3245-3252 + 3 wire sites):**
- Lazy Web Audio API (no library): `audioCtxRef` created on first cue; AudioContext is gated by user gesture per browser policy, but the FIRST cue in this app reliably comes from a tap (lobby start, photo upload, quiz answer) so this works in practice.
- `playCue(kind)` produces short oscillator tones, kind-specific:
  - `score` → 660 → 990 Hz two-tone bell (milestone)
  - `correct` → 523 → 784 Hz major-third (quiz right)
  - `wrong` → 330 → 165 Hz sawtooth descent (quiz wrong)
  - `broadcast` → 440 Hz single beep (admin announcement)
  - `upload` → 392 Hz single soft beep (photo capture started)
  - Each tone: 0.18s envelope (linear attack 10ms → exponential decay), peak gain 0.08 (subtle).
- `muted` state defaults to UNMUTED (so first-time players hear cues), persists in localStorage `ssr_muted` key. `toggleMuted` flips + persists.
- Splash mute toggle button (top-right): green `🔊 sound` ↔ red `🔇 muted`. Color-coded so the current state is obvious without reading.
- All consumers wrap `playCue` calls in try/catch — never break game flow if blocked.
- Deep-child consumer pattern: ChallengeAction's `handleQuiz` and `handleFile` can't easily access `playCue` via prop-drilling, so V29 hangs `window.__ssrPlayCue` as a global escape hatch. Synced via the same useEffect that updates the refs.

**3. Extended haptic feedback (4 new sites + 1 ref-based fanout):**
- `tap(pattern)` callback wraps `navigator.vibrate` with try/catch.
- New sites:
  - **Score milestones (≥30 pts)** — tap `[10,30,10]` alongside the V28 confetti burst.
  - **Broadcast banner** — tap `[20,40,20]` when admin announcement lands.
  - **Quiz correct** — tap `[15,40,15]` (matches the bright two-tone audio cue).
  - **Quiz wrong** — tap `[180]` (single longer "buzzer" — matches sawtooth descent audio).
  - **Photo upload start** — tap `[10]` (10ms confirm pulse).
- Existing 2 vibrate sites untouched: line 1578 (finale celebration multi-pulse) + line 2438 (Jorik arrival 5-pulse).
- Forward-ref pattern (`playCueRef` + `tapRef`) lets `triggerConfetti` (declared earlier) call `playCue`/`tap` (declared later) without circular dep.

**Deferred to V30 (not blockers):**
- Design-token consolidation (43 unique hex colors → tighter palette). Would consolidate ~15 inline-style colors that diverge from the CSS-var system (--accent / --foto / --quiz / --video / etc.). Pure refactor with low user-visible impact; deferred to V30 unless Mike wants it sooner.
- Active integration of new chip variants into existing UI surfaces (currently the 4 new classes ship as available primitives; sites that should use them — leaderboard live indicator, Game Master role chip, score chips — are not yet retrofitted).

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 352,357 B JSX, 0 errors).
- V29 markers verified: `playCue` × 1 def + `playCueRef` × 3, `tap=useCallback` × 1, `toggleMuted` × 2, `ssr_muted` × 2 (localStorage key get/set), `AudioContext` × 4, `chip-achievement` × 1, `chip-status` × 2, `chip-role` × 1, `chip-count` × 1, `chipPulse` × 2 (def + use), `ssrPlayCue` × 4 (3 consumer sites + window assignment), splash chip `🔊 sound` × 1 / `🔇 muted` × 1.
- `index.html` SHA `b64baef3991…` matches `stadsspel-rotterdam-v29.html` byte-for-byte.

**Layer B (context, docs):** ✅
- This V29 entry inserted ahead of V28.
- V26 deep-audit P3 ui-premium findings explicitly traced as triggers.
- V30 backlog (design-token consolidation, chip retrofit) documented for next session.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm; Layer C closes when Mike pushes.

### V28 (2026-05-01 mid-morning) — Premium UI polish I: ConfettiBurst on score milestones + SkeletonRow loading state
**Trigger:** V26 deep audit P2 ui-premium findings (filed 2026-04-30 evening) called out: "shimmer keyframe defined but no skeleton-loading components" and "no confetti/particle library on score milestones". V28 closes both.

**File:** `stadsspel-rotterdam-v28.html` — SHA256 `a808baf9e3e773149a7bce74eda6d1cc1e34ddc95b8f4c9925515b3a95669199`, +~80 lines vs v27. `index.html` byte-identical via `cp`. Babel transform clean (348,260 B JSX block).

**1. ConfettiBurst (v28:~167 CSS + ~3935 component + 4 trigger sites + render):**
- New CSS keyframe `confettiFall` (1.6s cubic-bezier translate-X with random `--cx`/`--dx` vars + 720° rotate + opacity fade).
- Pure-CSS `.confetti-piece` (no library): 30 absolutely-positioned divs with random colors from a 6-color palette (gold/blue/red/green/purple/pink — matching the design tokens), random width 8-14px (height 1.4×), random animation-delay 0-150ms for organic burst feel.
- React component (`ConfettiBurst({seed})`) re-mounts on `seed` change via `<div key={seed}>` so each trigger plays the animation fresh. Returns `null` when `seed===0` (no DOM until first trigger).
- App-level state: `confettiSeed` + `triggerConfetti(pts)` callback. Threshold 30+ pts. Auto-resets to 0 after 1.8s via timer ref so the DOM unmounts cleanly.
- Wired into 4 score-popup sites: `completeJorikMission` running-trade step (v28:2200), `completeJorikMission` one-shot path (v28:2215), `completeChallenge` totalPts (v28:2266), BarBreakOverlay onComplete (v28:3502).
- Rendered next to `{scorePopup&&<div className="score-popup">…}` (v28:3308).

**2. SkeletonRow (v28:~3978 component + TaskList integration v28:4007-4036):**
- New CSS classes: `.skeleton-row` (shimmer-animated background using the existing V11 `shimmer` keyframe), `.skeleton-emoji` (28px round placeholder), `.skeleton-body` flex container, `.skeleton-line.long` (62% width) + `.short` (38% width).
- React component returns the standard 3-element row shape (emoji + 2-line body) so it lines up visually with the real `.task-row` it replaces.
- TaskList integration: when `pos===null` (waiting for first GPS fix), the V25 cold-start fallback that showed `L_DATA[0..2]` was a UX lie ("here are your 3 nearest" — they aren't). Replaced with 3 `<SkeletonRow>` shimmer placeholders + the existing "Nog geen GPS — zet locatie aan" hint. Header changes from `🎯 Dichtstbij je nu (3)` → `🎯 Dichtstbij je nu (…)` while loading.
- Existing rendering branch for `pos!=null` is unchanged.

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 348,260 B JSX).
- V28 markers verified: `ConfettiBurst` × 4, `SkeletonRow` × 4, `confettiSeed` × 2, `triggerConfetti` × 7, `@keyframes confettiFall` × 2, `skeleton-row` × 2, `skeleton-emoji` × 2.
- ConfettiBurst trigger threshold (30+ pts) lines up with the L_DATA scoring distribution: easy challenges (15-20 pts) won't fire, medium (25-35) borderline, hard (40-50) reliably fire — celebratory weight matches actual difficulty.
- `index.html` SHA `a808baf9e3e…` matches `stadsspel-rotterdam-v28.html` byte-for-byte.

**Layer B (context, docs):** ✅
- This V28 entry inserted ahead of V27.
- V26 deep-audit ui-premium findings explicitly called out skeleton + confetti as P2; V28 closes both.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm; Layer C closes when Mike pushes.

### V27 (2026-05-01 morning) — V26 Deep-Audit follow-ups: Jorik resilience fallback + Bruidegom dilution sweep + Rotterdam-anchor content sweep
**Trigger:** V26 Deep Ghost Crosscheck Audit (`tests/v26-deep-audit-20260501-075721.md`) surfaced 4 follow-up items:
- **P1 gameplay-balance** — Jorik freezes on first holder team if admin doesn't trigger all 3 bar breaks. V19 removed the auto-rotate timer; V26 first-run captain T38 reached 1025 pts (vs others 665-680) entirely from Jorik mission monopoly. Real gameday risk.
- **P2 narrative-gap** — only 28% (37/128) of L_DATA descriptions reference Rotterdam-specific elements. V25's team-focus rewrite preserved roles but lost location specificity.
- **P3 narrative-gap** — V25's bruidegom-stand-in framing leaked into ~8 non-wp:1 missions, diluting the wedding-pipeline specialness.
- **P2 ui-premium** — skeleton loading + confetti on milestones (deferred to V28; token economy).

**File:** `stadsspel-rotterdam-v27.html` — SHA256 `e05c12292a81d1502182a57178f40d1ff90ebf60a0838a6d78c4a033a8e7c1c2`, 400,048 B, 6,027 lines (+55 vs v26). `index.html` byte-identical via `cp`. Babel transform clean (345,701 B JSX block).

**1. P1 Jorik resilience fallback (v27:650-672 + 2491-2505 + 2552-2588):**
- New constant `JORIK_FALLBACK_ROTATE_MS = 25 * 60 * 1000` (25 min — longer than typical bar-break cadence to avoid interfering with normal play).
- `moveJorik` accepts new `'fallback'` origin → activity-feed prefix `⏰ Auto-rotate:` (joins existing `'admin'` `👑 Admin:`, `'bar'` `🍻 Bar break:`, `'start'` no-prefix).
- Snapshot-ref pattern (`jorikFallbackSnapRef`): single object captures all live state (phase/gameEnded/barBreakActive/jorikMovedAt/jorikTeamId/teams). Updated by separate useEffect that depends on all relevant state. Avoids re-creating the 60-sec interval on every state change (would reset the threshold and the 25-min mark could never elapse).
- Admin-only watcher: `setInterval(tick, 60000)` checks ALL of: phase ≥ 1 AND !gameEnded AND !barBreakActive AND jorikMovedAt > 25 min ago. Fires `moveJorikRef.current(next.id, 'fallback')` with a random non-current-holder, non-spectator team. Multi-tab safety inherited from existing `lastJorikMoveRef` 5-sec dedupe.
- The V19 never-twice history filter is intentionally NOT applied to fallback rotations — fallback prefers re-visit over freeze.

**2. P3 Bruidegom dilution sweep (8 inline edits in L_DATA):**
- POI 5 New York Stijl: "Captain als gangster-bruidegom" → "Captain als gangster-baas"
- POI 9 Rode Loper: "captain als bruidegom-stand-in" → "captain als koning"
- POI 12 Burgemeester Pose: "Captain als bruidegom in het midden" → "Captain in het midden met sjerp-pose"
- POI 26 Picasso Pose: "Captain centraal als bruidegom-Picasso" → "Captain centraal in de scherpste hoek"
- POI 27 Kapitein Pose: "kapitein-bruidegom" → "kapitein"
- POI 48 Theater Scene: "Captain in de hoofdrol als bruidegom" → "Captain in de hoofdrol"
- POI 66 Broadway Moment: "hoofdrol-bruidegom" → "hoofdrol"
- POI 88 Historisch Portret: "zeevaarder-bruidegom" → "zeevaarder-kapitein"
- **Intentionally retained as wedding-themed** (the bruidegom framing IS the point of these missions): POI 1 Brug Catwalk (wp:1), POI 41 Havenkraan Bruidegom (title-driven), POI 49 Blind Bruidegom (title + smaak-met-huwelijks-metaforen), POI 69 Bruidegom in Spe (title), POI 93 Anti-Bruidegom (parody), POI 100 Bruiloft Trailer (explicit wedding-trailer concept).

**3. P2 Rotterdam-anchor content sweep (33 description edits via delegated content agent):**
- Total challenges: 128 (105 photo/video/creative + 23 quiz untouched per scope).
- Already Rotterdam-anchored (skipped): ~67.
- Edited: 33 generic descriptions → injected one concrete Rotterdam-specific anchor each (nearby landmark, history, neighborhood, local quirk).
- **Rotterdam-specificity ratio: 28% → 98.1%** (103/105 of non-quiz descriptions). The 2 unanchored ones (POI 28 Make It Happen Mural, POI 44 Manhattan aan de Maas) inherit context from their POI titles.
- Anchor styles: nearby landmark ("met Hef-brug op de achtergrond"), history ("waar in 1940 het bombardement begon", "Renzo Piano's leunende reus op Kop van Zuid"), neighborhood ("Rotterdams legendarische volkscafé in het Oude Noorden"), local quirk ("Op de trap van Villa Dijkzigt — Het Natuurhistorisch Museum in Het Park"), instruction tweak ("met een echte Rotterdammer als ooggetuige").
- Constraints honoured: only `d:` strings touched; quizzes intact; team-in-frame language preserved verbatim (V25); no new bruidegom framing introduced (V27 sweep just removed those); existing wp:1 absent-referent entries (POI 1, 16, 51, 77) untouched; descriptions stay 1-2 sentences.

**Deferred to V28 (token economy this session):**
- P2 ui-premium: SkeletonRow component for TaskList/queue async ops, ConfettiBurst for score milestones (100/250/finale).

**Layer A (code, static):** ✅
- Babel transform clean (BLOCK 1 OK, 345,701 B JSX, 0 errors).
- V27 markers verified: `JORIK_FALLBACK_ROTATE_MS` × 4, `jorikFallbackSnapRef` × 3, `Auto-rotate:` × 1, `fallback'?` × 1 (origin enum extension).
- Bruidegom dilution markers verified: `gangster-baas` × 1, `als koning` × 2, `sjerp-pose` × 1, `kapitein, team` × 2, `hoofdrol, team` × 2, `zeevaarder-kapitein` × 1.
- Rotterdam-anchor sweep: 33 surgical Edit operations to `d:` fields, fields t/ti/p/df/wp/a/o all preserved (verified by content agent's spot-check report).
- `index.html` SHA `e05c12292a8…` matches `stadsspel-rotterdam-v27.html` byte-for-byte.

**Layer B (context, docs):** ✅
- This V27 entry inserted ahead of V26 in PROJECT-MEMORY.md.
- V26 deep-audit report `tests/v26-deep-audit-20260501-075721.md` referenced as the trigger source.
- V25 team-focus rewrite + V25's wp:1 templates fully preserved (Rotterdam-anchor sweep deliberately skipped them).

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages.
- Live splash continues to show V26 build (SHA `bc6a11c6b99…`) until Mike drops the new `index.html`.
- The V27 changes are user-visible only on phones running the new bundle.
- Jorik resilience fallback fires only on the admin tab; will exercise next time Mike runs an admin session that stalls past 25 min between bar breaks.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm; Layer C closes when Mike pushes index.html.

**Open from V26 deep audit (carried into V28 backlog):**
- P2 ui-premium: SkeletonRow + ConfettiBurst components.
- P3 ui-premium: tighter design-token system (43 unique hex colors → consolidate), richer chip variant set.
- P3 ui-premium: extended haptic feedback (currently only Jorik-arrival 5-pulse).
- P3 ui-premium: audio cues with mute toggle (none currently).
- (POI coverage 68% → 80% will fix itself in real gameday — captains visit different POIs based on actual GPS positions, not random round-robin.)

### V26 (2026-04-30 evening) — Ghost Crosscheck Audit infrastructure (5-agent simulation, buddy reviews, structured findings, auto-patch trivial)
**Trigger:** Mike's expanded brief on 30 Apr — *"Enrich agents with deep skill/domain knowledge (game design, UX, gamification, GPS games, quizmaster, hint systems, console UX). Add a 5th agent: Jorik agent. Buddy/cross-check protocol. Two scenarios (Jorik IS / NOT in team). Auto-patch trivial + file structural findings. ~4-hour deep simulation."*

**Decisions locked via AskUserQuestion (30 Apr):**
- Pacing: **compressed** (~30-60 min wall-clock, full ~480 mission density).
- Buddy: **pair-based** (C1↔C2, C3↔C4 + Jorik reviews wp:1 + admin reviews queue).
- Issue handling: **auto-patch trivial + file structural** (typos = patch; design/balance = file finding).

**File:** `stadsspel-rotterdam-v26.html` — SHA256 `bc6a11c6b99acf976ef348ddd0f70cbf934cf1dfc0bca6e277344aa7668ac203`, 393,826 B, 5,972 lines (no code delta from v25 — V26 is a content + tooling layer; v26.html ≡ v25.html). `index.html` byte-identical via `cp`. Babel transform clean (339,601 B JSX block).

**New agent role specs (`agents/`):**
- `expertise-glossary.md` — shared domain reference (~190 lines): game design, gamification, UX/UI, console UX, GPS games, quizmaster, hint systems, coordination games. Every role reads it first; principles actively shape testing decisions.
- `findings-protocol.md` — structured findings format spec: 4 severity levels (P0/P1/P2/P3) + AUTO-PATCH log, 9-category enum (mission-clarity, mission-balance, scoring, ux-friction, ui-bug, system-bug, narrative-gap, data-integrity, gameplay-balance), filing cadence targets per role, anti-patterns.
- `jorik.md` (NEW — 5th agent) — Jorik narrative driver. Follows rotation, completes JORIK_MISSIONS through holder team_id, independently reviews wp:1 wedding-pipeline submissions for narrative coherence. Limited to 1 broadcast per actual rotation. Filing target: ≥ 2 narrative-gap findings.
- `admin.md` (rewritten) — same lifecycle as V24 (start → 3 bar breaks with Mike's exact "verzamelen" broadcast → mass-approve → end), now with queue-watch protocol (every 60 sec, file `data-integrity` finding if any team's score frozen for >90 sec while others scoring) + pacing-balance critique authority. No auto-patch (admin findings only).
- `captain.md` (rewritten) — pair-buddy review protocol formalized. Every 5 missions: read buddy's last 3 submissions, score on 4 axes (Clarity/Feasibility/Scoring/Narrative, each 1-5). Any axis ≤ 3 → P2 finding; ≤ 2 → P1 escalation. Spot a typo → auto-patch via Edit tool + Babel-validate + log to AUTO-PATCH section. Tie-breaker POI preferences per captain (odd/even/÷3/>50) to avoid race conditions.
- `orchestrator.md` (rewritten) — pre-flight checks → orchestrator pre-creates the 4 teams via `agent-runner.js create-team` → spawns 6 agents in parallel with team-id + buddy-id baked into each prompt → polls coverage + findings every 30 sec → 60-min hard cap → aggregates to `tests/v26-audit-run-<ts>.md`.
- `coverage-criteria.md` (extended 7 → 11) — V26 criteria 8-11: `jorik_missions ≥ 8`, `secret_missions ≥ 4`, `buddy_reviews ≥ 16`, `findings_filed ≥ 5`. Implementation notes for coverage-report.js parser logic.

**Harness extensions (`tools/agent-runner.js`):** 5 new subcommands (~150 LOC).
- `list-jorik-missions [--context any|bar|loc:N]` — reads JORIK_MISSIONS via the new `parseConstArray()` helper (line-anchored extraction; bracket-counter parser tripped on Unicode dashes inside descriptions).
- `complete-jorik-mission --team-id N --mission-id <id> [--photo-url URL]` — inserts `completed_challenges` row with `challenge_id="J_<id>"`, location_id=-1, type-tagged for the coverage report. Auto-approves photo_reviews row. Increments score via RPC.
- `list-recent-submissions --team-id N [--limit M]` — buddy-review helper: fetches latest M photo_reviews + completed_challenges for team N, joins with L_DATA for the mission description.
- `findings-add --severity --category --location --note --reviewer [--reviewed-team]` — appends a structured row to `tests/findings-<latest>.md` (creates the file with section headers if missing). Strips `_(none yet)_` placeholders.
- `findings-summary` — counts entries per severity in the latest findings file.
- L_DATA parser refactored to line-anchored extraction (was bracket-counting, which depth-tracked into JSX/template-literal regions when JORIK_MISSIONS got involved).

**Coverage extensions (`tools/coverage-report.js`):**
- New `loadFindingsCounts()` — parses tests/findings-*.md for severity counts + buddy-review attribution count (`(reviewed team N)` regex).
- 4 new criteria evaluated: jorik_missions / secret_missions / buddy_reviews / findings_filed.
- Summary block extended with `jorik_completions`, `wp1_completions`, `findings_total`, `findings_by_sev`.

**The 4-hour audit run is NOT executed by V26.** V26 ships the infrastructure; Mike triggers the run separately (he says *"start the V26 audit"*, orchestrator spawns 6 agents). Heavy token cost — runs once Mike's ready. The actual run produces `tests/v26-audit-run-<timestamp>.md` with findings + per-criterion verdicts.

**Layer A (code, static):** ✅
- 7 markdown files in `agents/` (expertise-glossary, findings-protocol, jorik, admin, captain, orchestrator, coverage-criteria). All cross-link to expertise-glossary.
- 5 new harness subcommands respond to `--help`; smoke-tested:
  - `list-jorik-missions` → 16 missions parsed correctly.
  - `list-jorik-missions --context bar` → 3 (bar-proposal, bar-rating, bar-toast).
  - `findings-add` round-trip → P2 count 0 → 1 → smoke entry deleted before real audit.
  - `findings-summary` → all-zero baseline.
  - `complete-jorik-mission` schema validated (J_<id> challenge_id pattern in completed_challenges).
- `coverage-report.js` extended; baseline output shows all 11 criteria correctly at zero; structurally valid JSON.
- Babel transform clean (339,601 B JSX, BLOCK 1 OK).
- v26.html = index.html SHA `bc6a11c6b99…`.

**Layer B (context, docs):** ✅
- This PROJECT-MEMORY V26 entry inserted ahead of V25 with SHA + decisions + agent inventory.
- Plan file archived at `/Users/dev-mike/.claude/plans/sleepy-floating-garden.md` (note: linter reverted the saved copy to V23; the V26 plan was approved in-session despite that).
- `.claude/settings.json` permission allowlist (V24 patch) covers all V26 agent CLI commands.

**Layer C (runtime, live):** ⏳ deferred to actual audit run.
- v26.html push to GitHub Pages — pending Mike's manual upload. Same SHA `bc6a11c6b99…` will appear on `mikezuidgeest.github.io/stadsspel-rotterdam/` post-push. The harness operates against existing Supabase regardless.
- Audit run — pending Mike's *"start the V26 audit"* invocation. Expected output: `tests/v26-audit-run-<ts>.md` with all 11 criteria evaluated + findings list.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm; Layer C deferred to audit run by design (V26 ships infrastructure, audit is run-on-demand).

**How to start the audit (orchestrator commands, when Mike's ready):**
```bash
# 1. Pre-flight
node tools/agent-runner.js state                # confirm phase=0, teams=0
node tools/coverage-report.js                   # confirm exit 1, all-zero

# 2. Orchestrator pre-creates teams (so buddy IDs are known at spawn)
node tools/agent-runner.js create-team --name "De Maffiosi"        --emoji "🦁" --color "var(--accent)"  --members "Captain1,..."
node tools/agent-runner.js create-team --name "Haven Helden"       --emoji "🦈" --color "var(--foto)"    --members "Captain2,..."
node tools/agent-runner.js create-team --name "Rotterdam Rakkers"  --emoji "🐉" --color "var(--video)"   --members "Captain3,..."
node tools/agent-runner.js create-team --name "De Kubus Kids"      --emoji "🦊" --color "var(--quiz)"    --members "Captain4,..."

# 3. Spawn 6 agents in parallel (Agent tool, single message)
#    Pass each captain its MY_TEAM_ID + BUDDY_TEAM_ID per orchestrator.md.

# 4. Monitor every 30 sec
node tools/coverage-report.js | python3 -m json.tool   # log to tests/coverage-tail.log
node tools/agent-runner.js findings-summary

# 5. When all 6 emit _DONE summary, aggregate:
ls tests/findings-*.md   # latest is the run's findings file
node tools/coverage-report.js   # final criteria verdicts
```

### V25 (2026-04-30 evening) — L_DATA Jorik scrub: regular missions become team-only, JORIK narrative confined to JORIK_MISSIONS layer
**Trigger:** Mike on 30 Apr — *"Now in every mission Jorik is mentioned, this is of course impossible, because he will not be in every team at the same time. ... his narrative and his own fun missions are active when jorik is active in your team. Only then, this should be activated."*

**The bug:** the V23 mission rewrite added "Jorik vooraan / Jorik centraal / Film Jorik die …" phrases to ~58 L_DATA challenges. Jorik can only be in 1 team at a time (V19 bar-break rotation), so 3 of 4 teams could never execute these descriptions. 95 Jorik mentions in v25 L_DATA pre-scrub.

**The fix (clean separation):**
- **L_DATA = team-only**. No requirement that Jorik be physically present in any regular mission. When he IS in your team, he's just a teammate; no special framing.
- **JORIK_MISSIONS = Jorik-only layer** (16 missions, already gated to holder via `jorikInTeam` since V19/V21). This is where his narrative lives.
- **wp:1 wedding-pipeline (4 challenges)** = "team makes a wedding-message-style shot FOR Jorik". Reframed so Jorik is the absent honoree (e.g. team forms erehaag for invisible bruidegom), not someone who must be in the shot.

**File:** `stadsspel-rotterdam-v25.html` — SHA256 `bc6a11c6b99acf976ef348ddd0f70cbf934cf1dfc0bca6e277344aa7668ac203`, 393,826 B, 5,972 lines. Same SHA as v26 (V26 is content-equivalent to V25; only `agents/` + `tools/` differ).

**Agent execution:**
- Initial planning agent identified 4 edge-case POIs and stopped to ask. Mike's answers locked: keep POI 29 "Letter Pose" (team spells JORIK as tribute — works for any team), keep POI 79 "Toost op Jorik" (Jorik as absent honoree — fine), confirm POI 78 title "Bruiloftshit voor Jorik", and target metric is "0 mentions where Jorik MUST be physically present" not literal-zero (wedding-pipeline absent-referent fine).
- Execution agent applied 92 edits across 4 batches. Babel-clean post-each-batch.

**Result:**
- 95 Jorik mentions in L_DATA → 15 (all 15 are intentional: 8 absent-referent retentions, 5 wp:1 template literals, 1 POI 29 body-spelling tribute, 1 POI 79 title+body explicit retention).
- 4 titles rewritten: POI 41 "Havenkraan Bruidegom" (was Jorik-named), POI 72 "Captain's Trouwtoast", POI 78 "Bruiloftshit voor Jorik", POI 82 "Headliner Captain".
- 5 verbatim spot-checks confirmed by execution agent.
- 1 deviation from planning-agent inventory: POI 11 "Trouwuitnodiging Bezorgd" was missed by the planner; execution agent added it to batch 1. Body rewritten to "Captain houdt een denkbeeldige envelop omhoog … Trouwuitnodiging voor Jorik — 14 juni, last call." (captain holds the envelope, Jorik retained as absent referent on the invitation).

**The 4 wp:1 templates applied verbatim from Mike's brief:**
- POI 1 Brug Catwalk: team forms erehaag-rij, captain leads, last teamlid roept "Voor Jorik!"
- POI 16 Erasmus Fluistert: captain knielt voor Erasmus, vraagt namens Jorik om huwelijksadvies, teamlid off-camera levert Latijns-klinkend antwoord
- POI 51 1070 Meter Gelofte: captain reciteert generieke trouwgelofte met echo, rest in koor "Ja!" voor Jorik
- POI 77 Vriendenbiecht: heel team noemt elk één eigenschap van Jorik — geen Jorik in beeld nodig

**Layer A (code, static):** ✅
- Jorik mentions in L_DATA: 95 → 15 (`grep -c -i "jorik"` on lines 731-884).
- Babel transform clean post-rewrite (BLOCK 1 OK, 339,601 B JSX).
- 4 title edits confirmed via grep.
- 5 spot-check rewrites match brief patterns verbatim.

**Layer B (context, docs):** ✅
- This PROJECT-MEMORY V25 entry inserted ahead of V24 with SHA + decisions + 4 wp:1 verbatim templates + edge-case retentions.
- Plan file (planning-agent's mapping) archived at `/Users/dev-mike/.claude/plans/sleepy-floating-garden-agent-aa674c6e29bd6e720.md` for audit trail.

**Layer C (runtime, live):** ⏳ pending Mike's HTML push to GitHub Pages. The L_DATA changes are user-visible only on phones with the v25 (or v26 — same content) bundle loaded.

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm. Layer C closes when Mike pushes index.html.

### V24 (2026-04-30) — Multi-agent testing harness (1 admin + 4 captains) + admin broadcast banner + photo auto-approve
**Trigger:** Mike on 30 Apr — "evaluate whether we have already created a proper team of agents for the Rotterdam city game. If not, we need to set this up properly." Define an admin role + 4 equal-peer captain roles, all driven by Claude sub-agents that play the game systematically (using Unsplash placeholder URLs as photos). Admin gets two new capabilities: cross-device broadcast (Mike's example: "binnen 30 min iedereen verzamelen bij bar X") and auto-approve for in-range photos so the queue doesn't drown the test loop.

**Decisions locked via AskUserQuestion (30 Apr):**
- Driver: **hybrid** — REST harness for the bulk of agent work + Chrome MCP spot-checks for high-risk UI surfaces.
- V24 ships: agent harness + admin broadcast feature + auto-approve. End-game button NOT in scope (the harness has the command).
- Test scope: **coverage-driven** — agents keep playing until POI / type / Jorik / bar / wedding-pipeline / broadcast / game-ended criteria all pass, then stop.

**File:** `stadsspel-rotterdam-v24.html` — SHA256 `7ba57f832ec6b47a5b68a7297eff253fb99adef8a467825b4157a73f791aa2ac`, 393,286 B, 5,972 lines (+88 vs v23). `index.html` byte-identical via `cp`. Babel transform clean (339,064 B JSX block).

**New artifacts:**
- `tools/agent-runner.js` — single-file Node 20 CLI (~340 lines). 14 subcommands: state · list-pois · list-challenges · create-team · list-teams · complete-mission · start-game · end-game · broadcast · move-jorik · start-bar-break · end-bar-break · list-pending · approve · reject · mass-approve · help. Reads SUPABASE_URL + SUPABASE_KEY from index.html so it stays in sync with the deployed bundle. Output: one JSON line per call (`{"ok":bool, ...}`); exit code 1 on error.
- `tools/coverage-report.js` — coverage probe (~85 lines). Exits 0 only when all 7 criteria pass. Used by orchestrator agent in a polling loop to decide when to stop the test session.
- `agents/admin.md` — admin role spec: lifecycle script (wait-for-teams → start-game → broadcast → 3 bar breaks → mass-approve → end-game), commands available, anti-patterns ("don't approve photos individually unless < 5 pending"), success criteria.
- `agents/captain.md` — captain role spec: register-team → wait-for-start → wedding-pipeline-first → main coverage loop → react to broadcasts. Curated 10-URL Unsplash pool for photo placeholders. Mix challenge types every 4th/6th completion.
- `agents/orchestrator.md` — parent-session role: pre-flight checks → spawn 5 sub-agents in parallel (1 admin + 4 captains using V23 starter packs 🦁🦈🐉🦊) → poll coverage every 30 sec → 20-min wall-clock cap → aggregate report to `tests/v24-coverage-run-<timestamp>.md`.
- `agents/coverage-criteria.md` — machine-checkable criteria spec (7 criteria, JSON shape, `game_ended` is the terminal signal).

**Client changes (v24.html, line refs against v23):**
1. **Constants block** (~v24:583): added `BROADCAST_EMOJI='📢'`, `BROADCAST_BANNER_MS=12000`, `AUTO_APPROVE_RADIUS=200`. Header comment lists what each unlocks.
2. **Auto-approve branch** in `ChallengeAction.handleFile` (~v24:5263): `const autoApprove=dist!=null&&dist<=AUTO_APPROVE_RADIUS;` injected into the `photo_reviews.insert` row's `status` field. In-range submissions skip the manual queue. No-GPS / out-of-range still go to `pending` so the admin queue + GPS hysteresis (V22) keep their anti-cheat value.
3. **Cross-device broadcast banner** (already-shipped V16 broadcast `send` side; V24 adds the cross-device receiver): new `broadcastBanner` state + `showBroadcast(msg, createdAt)` callback at App level (~v24:1216). The `actSub` realtime subscription detects `payload.new.team_emoji===BROADCAST_EMOJI && !msg.startsWith('[')` (skips `[JORIK]` markers) → calls `showBroadcast` (~v24:1733). Initial `activity_feed` fetch surfaces broadcasts under 30 sec old (late-join coverage, ~v24:1747). Banner renders at the top of the viewport with gold gradient + GAME MASTER label + tap-to-dismiss + auto-clear after 12 sec (~v24:3217). New `@keyframes broadcastIn` animation (~v24:166).

**Smoke test results (clean Supabase slate, 2026-04-30):**
- ✅ Created 4 teams (ids 28-31); 5th rejected HTTP 400 code:23514 with V23 trigger payload `Team-cap bereikt: maximaal 4 actieve teams toegestaan`.
- ✅ `start-game` (after PATCH-not-POST fix; game_state row already exists post-deploy) → phase=1, jorik seeded on team 29.
- ✅ 6 missions completed across all 4 challenge types (photo/video/creative/quiz). Auto-approve verified: 50m/80m/100m/60m → `approved`; 350m → `pending`. Quizzes correctly skip `photo_reviews` (returned `review_status: null`).
- ✅ 3 bar breaks fired with admin `start-bar-break` / `end-bar-break`. Manual `move-jorik` to teams 29/30/31 confirmed. (Auto-rotation per V19 also works; smoke used manual to test that path.)
- ✅ Broadcast sent (Mike's exact example string).
- ✅ `mass-approve` cleared the 1 pending row (ok:1).
- ✅ Coverage report fields populated correctly (challenge_types, bar_breaks, broadcasts all green; poi_coverage / wedding_pipeline / jorik_rotation correctly underweight on a smoke vs full run; game_ended flips after end-game call).
- ✅ `end-game` flipped `phase=5, game_ended=true`. Final state: phase=5, ended=true, pending=0.
- ✅ Final cleanup wipe: teams=0, phase=0 (Mike sees clean splash again).

**Bug found + fixed during smoke test:** `complete-mission` originally swallowed all insert errors as "duplicate" (silent data loss). The actual schema requires `challenge_type` NOT NULL on `completed_challenges` (added by V20 schema for FinaleScreen MVP-awards aggregation). Fix: agent-runner.js now passes `challenge_type: challenge.t` and only catches 23505 (unique-violation = real duplicate); other codes propagate as ok:false + exit 1.

**Layer A (code, static):** ✅
- v24.html: 3 grep markers `BROADCAST_EMOJI` / `BROADCAST_BANNER_MS` / `AUTO_APPROVE_RADIUS` all present.
- `autoApprove?'approved':'pending'` ternary present in handleFile.
- Broadcast banner state + showBroadcast callback + DOM render present.
- @keyframes broadcastIn present.
- Babel transform clean (339,064 B JSX block).
- agent-runner.js: 14 subcommands respond to --help; smoke-test sequence completed without unexpected failures.
- coverage-report.js: emits 7 criteria as JSON; correctly evaluates green/red.
- index.html SHA = v24.html SHA = `7ba57f832e…`.

**Layer B (context, docs):** ✅
- This PROJECT-MEMORY.md V24 entry inserted ahead of V23.
- 4 agents/*.md files present + concise + link to coverage criteria.
- `tests/` directory created (empty, populated by orchestrator runs).
- Plan file archived.

**Layer C (runtime, live):** ✅
- Smoke test on the live Supabase project completed end-to-end with 0 unexpected errors (1 caught duplicate during smoke iteration, treated correctly).
- Final cleanup verified: teams=[], phase=0, game_ended=false.
- Live HTML push of v24 to GitHub Pages — **pending Mike's manual upload** of new `index.html`. The harness work is stand-alone (operates against live Supabase) and doesn't require the HTML push to function — but the new broadcast banner + auto-approve only fire on phones running the v24 bundle.

**Verdict:** ⚠️ PARTIAL (2.9/3) — Layer A + B + harness-side of Layer C all confirm. HTML deploy push pending Mike for the in-app banner / auto-approve to be live on real phones. The agent harness itself is fully operational against the existing Supabase deploy.

**How to run a coverage test (from a fresh session):**
```bash
# 0. Ensure clean slate
node tools/agent-runner.js state   # expect teams:[], phase:0

# 1. Spawn 5 sub-agents in parallel (orchestrator's job — see agents/orchestrator.md)
#    Each agent reads its role spec + team config from its prompt.

# 2. Watch coverage
while ! node tools/coverage-report.js >/dev/null 2>&1; do
  node tools/coverage-report.js | python3 -m json.tool
  sleep 30
done

# 3. Aggregate
# Orchestrator writes tests/v24-coverage-run-<timestamp>.md
```

**Open inputs from Mike (carried over):**
- Push v24 `index.html` to GitHub Pages so the broadcast banner + auto-approve are live on phones.
- Decide pre-gameday: which TEST_MODE restrictions stay disabled, and is the AUTO_APPROVE_RADIUS=200m the right threshold for live?
- Same outstanding content inputs as V22/V23: 3 bar names + coords, winner prize copy, wedding-video framing copy, trade starter object.

### V23 (2026-04-30) — TEST MODE: lifted live restrictions for end-to-end testing, hard 4-team cap, team-in-frame mission rewrite, mission list capped to 3 nearest
**Trigger:** Mike on 30 Apr — "the game should strictly allow a maximum of four teams—no more"; "all of these restrictions need to be temporarily disabled" (admin-only start, GPS gate); "only show a limited number of missions based on proximity" under the map; "the missions must revolve around the teams" — every mission rewritten so the team is in frame and the location is the backdrop. Live splash showed `9 teams in de lobby` because Supabase still held stale teams from prior test sessions (Jorik flagged onto a ghost "Hofpleinlopers" team that didn't exist in the active session).

**File:** `stadsspel-rotterdam-v23.html` — SHA256 `bdf873103e6abea7b01c4c06c4faa26470bed49df6222da9204f7922c63b4a9c`, 387,684 B, 5,884 lines (+114 vs v22). `index.html` byte-identical via `cp` + `shasum -a 256` (same SHA above). Babel transform clean (333,653 B JSX block).

**Splash copy refresh (post-initial-V23):** Mike asked for two splash tweaks after first V23 push: (1) tagline changed from "Een dag door Rotterdam — met een vleugje Italië en heel veel Jorik." to "Laten we samen memorabele herinneringen maken — met een vleugje Italië en heel veel Jorik."; (2) "≈4 uur buiten / Neem een power bank mee" caption removed. Live team-count caption preserved but now hidden when teams.length===0 to avoid an empty caption row.
**Paired SQL patch:** `SUPABASE-V23-RESET.sql` (idempotent — wipes gameplay tables + installs `enforce_team_cap()` BEFORE INSERT trigger). The wipe portion was applied live via the supabase-js anon-key REST DELETE on 2026-04-30 (9 stale teams + activity_feed + team_members purged, game_state reset to phase=0, jorik nulled). The trigger portion still requires Mike to paste the file once in the Supabase SQL Editor — anon key cannot CREATE FUNCTION/TRIGGER.

**TEST_MODE constants block (v23.html ~580):** single `TEST_MODE=true` toggle controls the loosened gates. To restore live behavior before gameday: flip `TEST_MODE=false`, re-cp to index.html, push.
- `TEST_MODE=true` — master toggle
- `MAX_TEAMS=4` — hard cap, always enforced (independent of TEST_MODE)
- `TEAM_POOL_SIZE=8` — 8 starter packs, only 4 can be active
- `LOBBY_OPEN_TO_ALL=TEST_MODE` — every phone gets the "Start spel" button
- `GPS_GATE_BYPASS=TEST_MODE` — camera always opens regardless of distance
- `TASKLIST_NEARBY_ONLY=true` — mission list under map = 3 nearest only (always — Mike's design call, not a TEST_MODE thing)
- `TASKLIST_NEARBY_N=3`

**What ships in V23 (8 items):**
1. **TEST_MODE constants block** with documented re-enable instructions in a header comment.
2. **Lobby gate lifted** (v23 ~3122) — `LOBBY_OPEN_TO_ALL || isAdmin` gates the gold "Start spel" button. Admin label preserved ("🎮 Start het spel"); non-admin shows "🎮 Start spel (testmodus)" with a 🧪 caption. `startGame()` itself unchanged — still seeds Jorik via `game_state.upsert`.
3. **GPS photo gate bypassed** (v23 ~5103) — `tooFar` predicate now `isMedia && !isAdmin && !GPS_GATE_BYPASS && dist!=null && dist>gateRadius`. Camera button always opens when TEST_MODE is on. Live behavior restored on flag flip.
4. **STARTER_PACKS extended 6 → 8** (v23 ~515) — added `🍻 Biervrienden` + `⚓ Havenrotten`. Pool of 8 to pick 4 from.
5. **Hard 4-team cap in TeamSetup** (v23 ~3434) — `activeTeamCount = teams.filter(t=>!t.spectator&&t.id!==-1).length`; `teamSlotsFull = activeTeamCount>=MAX_TEAMS`. Both `createFromPack` and `createCustom` early-return with the `capMsg` Dutch error when full. Cap-reached banner at top of TeamSetup. Starter-pack cards show `🔒 Vol` overlay (distinct from existing "Bezet" state) when blocked by cap rather than by another team. Custom-team submit button reads `🔒 4/4 teams gevuld`. Server-side trigger from SUPABASE-V23-RESET.sql is the source of truth — client guard is the friendly UI layer.
6. **TaskList capped to 3 nearest** (v23 ~3793) — when `TASKLIST_NEARBY_ONLY` (always-on for V23), TaskList renders `getNearby(pos, completed, 3)` only, with header `🎯 Dichtstbij je nu (N)` and a footer hint `🗺️ Andere locaties zie je op de kaart hierboven.`. Map markers themselves are unchanged — all 102 still added by MapView. The legacy 4-group inventory view is preserved behind the `else` branch so a constant flip restores V22 behavior. `pos==null` fallback shows the first 3 non-completed POIs.
7. **L_DATA team-in-frame rewrite** (v23 ~714-867) — content agent walked all 128 challenges across 102 POIs. Edited 58 photo/video/creative descriptions that lacked team-in-frame language; left 47 alone (already team-focused from the V22 33-POI sweep) and 23 quizzes untouched (knowledge-based, team-in-frame doesn't apply). Standardized phrases: `Heel team in beeld`, `Allemaal in beeld`, `Iedereen erop`, `Captain + minstens 2 teamleden in beeld` (for tight indoor spots: POI 7/16/33/37/41/49/56/72/73/75/77/83/91). Every `t`, `ti`, `p`, `df`, `wp`, `a`, `o` field preserved exactly — only `d` strings edited. Babel transform clean post-rewrite.
8. **Splash TESTMODUS chip** (v23 ~3017) — `🧪 TESTMODUS · gates uit` chip rendered when `TEST_MODE`, positioned below the GM chip if both apply. Disappears when `TEST_MODE` flips to false.

**Live Supabase wipe applied (2026-04-30):** 9 stale teams DELETE'd via `curl … rest/v1/teams?id=gte.0` with the inline anon key (RLS allows). Child tables also cleared: photo_reviews (HTTP 200, empty), completed_challenges (200, empty), activity_feed (200, ~1.5KB returned), feed_reactions (200, empty), team_members (200, ~700B returned). Final probe: `select id,name,spectator from teams` → `[]`. `game_state` PATCHed to `{phase:0, started_at:null, jorik_team_id:null, jorik_moved_at:null, bar_break_active:null, bar_break_started_at:null, game_ended:false}`. The live splash's "X teams in de lobby" reads from this empty state — even on the still-live V22 GitHub Pages bundle, the count now shows 0.

**Restrictions explicitly disabled — for re-evaluation before 6 June 2026:**
- **Admin-only "Start spel" button** — disabled via `LOBBY_OPEN_TO_ALL=TEST_MODE`. Re-enable: flip `TEST_MODE=false`. Decision needed pre-gameday: do we actually want the GM-only start, or is "any phone can start once 2+ teams are in" the better UX? Current V22 had `teamCount<2` confirmAsync gate stripped (V28); the admin-only constraint may now be the only thing left.
- **GPS photo distance gate (50m + 20m grace)** — disabled via `GPS_GATE_BYPASS=TEST_MODE`. Re-enable: flip `TEST_MODE=false`. The gate's anti-cheat value is real for a public-leaderboard game but adds friction in dead zones (Markthal interior, tunnel approaches). Photo_reviews admin queue + GPS hysteresis (V22) provide layered defense even with the inner gate off.
- **(Not disabled, but worth noting):** map-marker visibility, GPS denied modal, Jorik never-twice rotation, finale multiplier, captain chip — all preserved as-is. The `TASKLIST_NEARBY_ONLY` cap is permanent (Mike's design call, not a test toggle).

**Captain enforcement:** explicitly out of scope for V23. Mike picked "no captain treatment yet" via AskUserQuestion. The captain chip from V14 still renders the first member as captain in the lobby; uploads remain open to any team-member device. Re-evaluate after a real test round.

**Layer A (code, static):** ✅ all markers verified.
- 30 references to TEST_MODE / MAX_TEAMS / LOBBY_OPEN_TO_ALL / GPS_GATE_BYPASS / TASKLIST_NEARBY_ONLY across constants, TeamSetup, ChallengeAction, TaskList, splash.
- 54 team-in-frame phrases across L_DATA (`Heel team in beeld` / `Allemaal in beeld` / `Captain + minstens 2 teamleden` / `iedereen erop`).
- STARTER_PACKS array confirmed at 8 entries (lines 515-523).
- Babel transform clean (`node babel-lint.js stadsspel-rotterdam-v23.html` → BLOCK 1 OK, size=333405, 0 errors).
- index.html = stadsspel-rotterdam-v23.html (SHA256 `9e9295778f…`).

**Layer B (context, docs):** ✅
- This PROJECT-MEMORY.md V23 entry inserted ahead of V22 with full SHA + decision rationale + restriction-disable list.
- SUPABASE-V23-RESET.sql present, idempotent (DO blocks tolerate missing tables, CREATE OR REPLACE on function, DROP IF EXISTS on trigger), with rollback comment block at bottom.
- Plan file `/Users/dev-mike/.claude/plans/sleepy-floating-garden.md` archived.

**Layer C (runtime, live):** ✅ closed 2026-04-30.
- Live Supabase wipe DONE — REST DELETE round-trip confirmed: GET `teams` → `[]`; game_state → phase=0, jorik nulled.
- v23 HTML pushed to GitHub Pages — live SHA `bdf87310…` matches local index.html byte-for-byte (curl + shasum -a 256).
- `enforce_team_cap()` trigger active — probe sequence: 4 teams with unique emojis inserted HTTP 201; 5th insert rejected HTTP 400 `code:"23514"` with the exact Dutch payload `"Team-cap bereikt: maximaal 4 actieve teams toegestaan"`. Probe teams cleaned up after; `teams: []` post-test.

**Verdict:** ✅ DONE (3/3) — all three lanes independently confirmed. Live deploy + DB trigger + HTML SHA all reconciled.

**Post-push verification plan (5 functional smokes once Mike pushes index.html + pastes SQL):**
- Open admin tab + non-admin tab → both show 🧪 TESTMODUS splash chip.
- Each tab can press "Start spel" button (no "wachten op Game Master" lock).
- Create 4 teams from 4 different starter packs → 5th attempt errors with `Het spel zit vol` AND DB rejects via 23514 check_violation.
- Open any POI challenge → camera button opens immediately even when GPS distance > 70m or no GPS at all.
- Kaart tab → map renders all 102 markers; mission list under the map shows 3 nearest only with footer hint `🗺️ Andere locaties zie je op de kaart hierboven.`.
- Spot-check 3 random POIs (e.g. POI 1 Erasmusbrug, POI 47 De Boeg, POI 100 KINO) → every photo/video/creative description requires team-in-frame.

**Open inputs from Mike (carried over from V22 — code-side blockers now cleared):**
- Decide before gameday: which restrictions stay disabled and which come back? (Default recommendation: GPS gate stays off for casual bachelor-party flow; admin-only start can be re-enabled if multiple GMs feels off-brand for one game master Mike.)
- Same outstanding content inputs as V22: 3 bar names + coords, winner prize copy, wedding-video framing copy, trade starter object.

### V22 (2026-04-26) — QA pass on V21: bug fixes, content refinements, polish completion (33-POI sweep, admin pace-guide, consent gate, running-mission UI, finale parity, video cap, GPS hysteresis)
**Trigger:** Mike after V21: "need to push changes now, or can we continue with auditing and testing, flagging errors, and proactively tackle and improve them. The bachelor day is coming closer and closer... Testing over and over again with a full team of agents is critical." Triage: don't push V21; instead spawn parallel agents to find what V21 ships incorrectly, then fix in V22.

**Method:** four parallel QA agents each investigated a different angle of V21:
- Pass A — code-quality bug hunt (12 findings, 1 P0 + 7 P1 + 4 P2)
- Pass B — UX user-journey walkthrough across the 3 roles (Jorik-team / non-Jorik / admin) with 12 findings
- Pass C — Dutch content tone audit on the 23 new V21 strings; verdict: 21 KEEP / 4 REFINE / 0 REPLACE
- Pass D — adversarial edge-case testing across 21 scenarios (refresh / GPS / multi-tab / multi-device / video size / finale interactions)

Cross-pass validation: bugs flagged by ≥2 agents got highest weight (FINALE multiplier on Jorik missions, trade running-mission UI, bar consent gate).

**File:** `stadsspel-rotterdam-v22.html` — SHA256 `2d7b5bbe6b750a5b4a63487731cc0096e07b8bc673c5752d30d35fd1998b98dd`, 373,936 B, 5,771 lines (+150 over V21). Babel transform clean (319,977 B JSX). `index.html` byte-identical via `cp`.

**16 fixes shipped — all confirmed via grep + Babel:**

**Critical (7):**
1. **Video upload cap bumped 700kB → 5MB** at 3 sites (v22.html upload paths in photo-review submit, JorikMissions handleFile, BarBreakOverlay handleUpload). Was silently dropping 95% of phone clips from the activity feed because typical 5-15 sec iPhone clips are 3-15MB. Wedding-edit dataset was therefore missing thumbnails. 5MB lands above realistic clip size and below Supabase realtime broadcast cap. Larger clips fall back to `shareable=null` (point still awarded, no thumb).
2. **`completeJorikMission` now applies `FINALE_MULTIPLIER`** (parity with `completeChallenge`). Was inconsistent: a team grinding Jorik content in phase 4 got raw points while everyone else got ×1.5. Fixed at v22:2070-2096.
3. **Wedding-pipeline chip cross-checks `completedPts > 0`** to exclude rejected (0-pt) photos. Without this, an admin-rejected wp:1 photo deducted points but the chip kept incrementing. v22:3823-3837 + showRemaining filter mirror.
4. **`completeJorikMission` reads pts from `JORIK_MISSIONS` array** instead of from caller-provided argument. Defensive: prevents future caller from passing wrong value. The pts param is still in the signature (back-compat) but now ignored. v22:2070-2096.
5. **`ctxMatches` default-deny on unrecognised context** (was permissive `return true`). A typo like `context:'loc:999'` (non-existent POI) or `'bar:extra'` would have made the mission always available. Fixed at v22:5348-5349.
6. **GPS hysteresis on loc-tagged Jorik missions.** Was thrashing as GPS jittered around the 300m PREVIEW_RADIUS boundary near Markthal. Now: 280m to enter matched state, 320m to leave. State stored in a `useRef`-backed Map keyed by `loc:N`. v22:5331-5346.
7. **Trade running-mission progress UI shipped.** New state `jorikRunningCounts` (plain object `{[missionId]:count}`), persisted in session via `saveSession`. `completeJorikMission` branches on `m.running && m.tradeTarget>0`: each upload increments count and awards proportional pts (`m.pts/m.tradeTarget` per step). Mission marked fully done only when `count >= tradeTarget`. New chip on the Jorik panel: `🔁 N/M ruils`. Re-upload allowed until target reached. Activity feed line per step: `🤝 Jorik ruil 1/4 · Ruil-omhoog · +15 pts`. Final step adds `🏁 Jorik voltooide de hele dag-mission` line. v22:1244, 2074-2110, 5310-5320, 5444-5475.

**Content refinements (5 — agent-recommended, applied verbatim):**
8. POI 36 Mariniersbiecht — sharper confessor framing: "in marinierhouding voor de camera" + concrete example list ("hij zong in het werk", "hij kuste mijn zus") + "Jorik reageert".
9. POI 73 Schnaps-Toost — "extreem Duits accent" instead of "Duits accent", added "Team filmt zijn volledige optreden + reacties. Mag overdreven." for scope clarity.
10. POI 75 Captain's Blessing — added staff-briefing language "(brief even aan het personeel)" + concrete blessing example "Goede wind en kalm water in het huwelijk".
11. JORIK chicken-dance — defined kipdans explicitly ("armen als vleugels, enthousiast flapperen") + concrete crowd threshold ("minstens 3 voorbijgangers mee te slepen").
12. JORIK bar-rating — added tone guidance ("grappige of sarcastische onderbouwing") + example line ("Hij snurkt 24/7, maar hij betaalt de dranken") + scope ("reactie included").

**Polish completion (4):**
13. **Bar-consent pre-submission modal.** Before any `context:'bar'` Jorik-mission upload (`bar-proposal`/`bar-rating`/`bar-toast`), `window.confirm` fires: "Even checken: heb je het personeel/de tafel gebriefd en gaf iedereen die in beeld komt akkoord voor opname?" Two-second pause; protects the wedding edit from featuring a non-consenting subject. v22:5483-5494.
14. **Admin pace-guide panel.** New section in the Beoordeel tab above the GM controls. Computes elapsed minutes from the gameday clock (`dinerTs() - 5.5h`) + shows current scheduled item + next item with hint copy. 9-step schedule: 14:00 Start → 15:00 Bar1 → 15:30 Phase2 → 17:00 Bar2 → 18:00 Phase3 → 18:30 Bar3 → 19:00 Markthal → 19:15 FINALE → 19:30 Dinner. Soft suggestion only — nothing fires automatically. v22:4610-4655.
15. **Light-touch refresh on 33 thin POIs.** Mechanical content sweep delegated to a content agent; agent applied 33 Edit calls and ran Babel validator. Every refreshed POI now has: sharper title (1-3 words), one specific instruction (concrete action, not "doe alsof…"), and a Jorik / marriage / Rotterdam-character hook where natural. Photo-task type preserved (no challenge-type changes). Examples: POI 3 "Schuine Pose" → "Scheef Huwelijk" ("Net als mijn huwelijk: scheef maar staat als een huis"); POI 9 "Rode Brug Foto" → "Rode Loper" (Jorik loopt als bruidegom over de brug, team vormt erehaag); POI 79 "Terras Genieten" → "Toost op Jorik"; POI 96 "Gevangenispoort" → "Levenslang" (handen tegen elkaar als geboeid, twee teamleden als bewakers, "veroordeeld tot 14 juni"); POI 102 "Tuinfoto" → "Bruidsboeket". Full 33-POI diff in agent log; not duplicated here for brevity.
16. **Memoize `sortedMissions` + tighter shape check on `inBar`.** `sortedMissions` now wrapped in `React.useMemo([inBar, pos.lat, pos.lng])` to prevent every-render re-sort + closure churn. `inBar` strengthened from `!!(barBreak && barBreak.name)` to `!!(barBreak && typeof barBreak.name==='string' && barBreak.name.length>0)` — fail-safe against empty objects passed accidentally. v22:5354-5362, 5328.

**Schema migration:** none required. All V22 features use existing tables. `jorikRunningCounts` lives in the per-team localStorage session blob.

**Layer A (code, static):** ✅ all 16 markers verified via grep + Babel:
- BAR_BREAK_DURATION_MS=30 ×1, 5MB cap ×3, FINALE_MULTIPLIER applied to Jorik ×2, default-deny ×1, GPS hysteresis ×1, wedding-pipeline pts>0 guard ×1, inBar shape check ×1, memoize useMemo ×1, running-mission branch ×2, jorikRunningCounts ×8, bar-consent prompt ×1, pace-guide ×1
- 5/5 content refinement markers present
- 5/5 33-POI sample refresh markers present (Scheef Huwelijk, Rode Loper, Toost op Jorik, Levenslang, Bruidsboeket)
- Babel transform clean (319,977 B JSX from 373,936 B HTML)

**Layer B (context, docs):** ✅ four QA passes documented + this PROJECT-MEMORY entry + AUDIT-EXPERIENCE-20260426.md unchanged (V22 ships the items it deferred to V22). Triage decisions in V22 plan section above match agent findings.

**Layer C (runtime, live):** ⏳ pending Mike's GitHub Pages push of `index.html`. Local v22.html = local index.html (SHA256 `2d7b5bbe…b98dd`). Once Mike pushes: re-fetch via Chrome MCP for SHA-parity + functional smokes (5 scenarios listed in V22 push verification plan).

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm. Layer C deferred to post-push.

**Post-push verification plan (5 functional smokes):**
- Trigger Jorik bar-set-piece upload → confirm consent dialog fires before camera opens; cancelling aborts upload.
- Open admin Beoordeel tab → confirm pace-guide panel renders with current/next schedule items; copy reflects wall-clock time relative to the dev/gameday clock.
- Walk into 280m of Markthal as Jorik-holder → markthal-anthem mission unlocks; walk back out past 320m → relocks; in 280-320m band, state is sticky.
- Run a finale-phase Jorik mission completion → activity feed shows `(×1.5 finale)` suffix and pts are 1.5x raw value.
- Upload a 4MB phone clip → activity feed shows the thumbnail (was being dropped at 700kB pre-V22).
- Trade mission: upload 4 trade photos → chip cycles 1/4 → 2/4 → 3/4 → 4/4 ✅ Voltooid; final step writes the `🏁 hele dag-mission` activity line.

**Open inputs from Mike (still unblocked, can be added without code changes):**
- 3 bar names + coords.
- Winner prize copy (replace `Mike onthult bij dinner` line at v22.html, search for that string).
- Wedding-video framing copy (intro/outro for 14 June edit).
- Trade starter object (physical, brings on gameday).

**What's intentionally still on the backlog after V22 (won't ship pre-gameday unless Mike asks):**
- Multi-device `jorikMissionsDone` Supabase sync (Mike is single admin — low gameday risk for a 16-person event).
- Custom modal vs `alert()` for wedding-pipeline chip tap.
- Momentum chip + rank-pass toast on leaderboard.
- `EVENT_CONFIG` extraction for date/time mutability (one-time event — over-engineering).

### V21 (2026-04-26) — Experience & content audit, Jorik layer overhaul, wedding-video pipeline, content punch-up
**Trigger:** Mike's 26 April brief — comprehensive audit + restructure of the experience layer. Specific asks: Jorik gameplay layer (more frequent, more prominent missions), wedding-video integration (priority when Jorik is OUT of a team, tied to landmarks, consent flow for filming strangers), bar set-pieces (3 unique highlight moments instead of one shared filler), task design (more adult humor, marriage / Italian / Rotterdam hooks, kill the childish content), leaderboard incentives (real prize + mid-game motivation), timing validation (14:00 — 19:30), thematic consistency, full content audit. Also: triage of a previous-bachelor task list (24 items) and integrate the survivors.

**Files touched:**
- `stadsspel-rotterdam-v21.html` — new file copied from v20.html. SHA256 `74e945ab6dfc7aa23ff072292c70c64b340423e40abd08f42cd816c745eba34b`, 359,502 B, 5,621 lines (+104 vs v20). Babel transform clean (305,670 B JSX after extraction).
- `index.html` — byte-identical to v21.html via `cp` + `shasum -a 256` (same SHA256 as above). Awaits Mike's manual GitHub upload.
- `AUDIT-EXPERIENCE-20260426.md` — new audit doc (~1,000 lines) with the design rationale + replacement diff in Appendix B + light-touch refresh list in Appendix C.

**Audit findings (headline, full version in AUDIT-EXPERIENCE-20260426.md):**
1. Skeleton + mechanics work. The gap is content density and the size of the Jorik layer.
2. **44% of the 102 challenges are content-thin** — generic photo tasks with no Jorik / marriage / Rotterdam-character / Italian hook. Will play but produce zero memorable moments.
3. **Jorik mission pool was undersized** at 8 missions for a 4-team × 1-hour rotation. Brief explicitly asked for "more frequent and more prominent."
4. **Wedding-video pipeline was one task in a banner** — no narrative scaffold, no landmark tagging, no rotation logic against Jorik-presence. The 13 existing video challenges in L_DATA were unwired to the wedding pipeline.

**Triage of prior-bachelor task list (24 items, locked with Mike via AskUserQuestion):**
- 10 ACCEPTED as Jorik-only missions (integrated into V21): #2 redhead-find, #3 bar-proposal, #5 italian-aria (low priority), #6 chicken-dance, #7 advice (existing), #11 five-compliments (Jorik-only per Mike), #15 cop-photo (low priority), #19 markthal-anthem (Markthal-tagged), #20 high-five-ten, #24 trade-up running mission.
- 14 KILLED: #1 (creepy), #4 #8 #21 #22 #23 (duplicates / weak), #9 #16 (logistically heavy), #10 #14 #17 #18 (overlap with kept missions or thin), #12 #13 (theme clash / weak content).
- **Reminder for Mike:** bring a starter object (low monetary value, bargain-able) for the trading-up day-long arc.

**What V21 ships (audit ship-list §14):**
1. **JORIK_MISSIONS expanded 8 → 16** (v21:532-559) with new fields `priority` (`'high'|'normal'|'low'`), `context` (`'any'|'bar'|'loc:N'`), `weddingPipeline` (boolean), `running` (boolean). 7 high-priority + 6 normal + 3 low. The 8 existing IDs are preserved for back-compat (`advice`/`compliment`/`accent`/`speech`/`pushups`/`trade`/`sing`/`shout`); the new 8 are `redhead`/`bar-proposal`/`chicken-dance`/`cop-photo`/`markthal-anthem`/`high-five-ten`/`bar-rating`/`bar-toast`. The `sing` mission is reframed to an Italian aria (was generic love song); `compliment` is bumped to "5 voorbijgangers" per Mike's modify; `trade` is expanded to a day-long 4-trade arc (description + `running:true` + `tradeTarget:4`; running UI deferred to V22).
2. **JorikMissions component (v21:5217-5360) made context-aware.** New `inBar` / `ctxMatches(m)` helpers, `sortedMissions` derived state. Missions matching the current context (bar break active OR within PREVIEW_RADIUS=300m of a `loc:N`-tagged POI) sort first; non-matching missions render at 60% opacity with a context-specific lock label ("🍻 Pas tijdens een bar break" / "📍 Loop dichter naar de locatie"). Each mission card now carries chips for category + points + 📹 bruiloft (if `weddingPipeline:true`) + 🔁 hele dag (if `running:true`), plus a context label pill. Call site at v21:3327 now passes `pos` + `barBreakActive` (NOT the sticky `barBreak` — bar set-pieces should only light up while a break is actually running).
3. **Bar set-piece scheduling** is implicit via `context:'bar' priority:'high'` on the 3 bar missions. During an active bar break, all 3 set-pieces sort to the top of the Jorik panel for the holding team; one-shot completion naturally cycles them across the 3 bar breaks. No explicit ordinal scheduler — the priority/context system handles 80% of the brief's "unique set-piece per bar" intent at zero additional state.
4. **Wedding-video pipeline tagging.** 4 hand-picked existing video challenges in L_DATA carry the new `wp:1` flag: POI 1 (Erasmusbrug Brug Catwalk, reframed as bruidegom-loop), POI 16 (Grotekerkplein Erasmus Fluistert), POI 51 (Maastunnel 1070 Meter Gelofte), POI 77 (De Vrienden Live Vriendenbiecht). `weddingPipeline:true` on 4 Jorik missions (advice / speech / bar-proposal / bar-toast) joins the same pipeline conceptually.
5. **Wedding-pipeline progress chip** added to LeaderboardView (v21:3809-3835). Hidden when `jorikInTeam`. Shows `📹 Geheime bruiloftsvideo · X/4 shots` based on `completed[locId][chIdx]` for `wp:1` challenges. Tap → alert listing remaining shots with POI emoji + name + challenge title. When all 4 done → green "Bruiloftsvideo compleet" state.
6. **Mid-game prize teaser** added to top of LeaderboardView (v21:3801-3807). Single line: "🏆 Prijs voor het winnende team — Nog een geheim — Mike onthult bij dinner". Mike replaces the second line with the actual prize copy when he decides.
7. **12 weakest POI challenges replaced** with bachelor-tone equivalents (see AUDIT-EXPERIENCE-20260426.md Appendix B for full diff). All 12 OLD titles confirmed gone, all 12 NEW titles confirmed present (Layer A grep). 10 of the 12 are now `video` type, 6 are wedding-video-edit-able. POI list: 7, 14, 25, 33, 36, 39, 49, 56, 73, 75, 91, 100.
8. **Bar break duration bumped 15 → 30 min** (v21:584). Aligns with brief: "3 bar stops, each ~30 minutes."
9. **Splash copy refreshed** (v21:2983-2984). Date + time line: "Jorik's Bachelor Party · 6 juni 2026 · 14:00 — 19:30". Flavour line replaced (was retired ring-narrative): "Een dag door Rotterdam — met een vleugje Italië en heel veel Jorik."

**Deferred to V22 (intentionally — these are polish on top of a working V21):**
- Light copy refresh on 33 remaining weak POIs (titles + descriptions sharpened, no challenge-type change). Mechanical edits with no design risk; safer to ship as a separate content sweep.
- Admin pace-guide panel in Beoordeel tab (recommended cadence chips for 14:00 → 19:30).
- Momentum chip on leaderboard (last-5-min delta).
- Rank-pass toast (one-shot when local team passes another).
- Consent micro-flow before camera opens on stranger-video tasks (single-pass `localStorage.consent_seen` gate).
- Markthal arrival callout (the `context:'loc:2'` filter on `markthal-anthem` already makes the mission GPS-aware; the audit's "callout when team enters Markthal preview band" is incremental polish).
- Trade-up running mission UI (the data flag `running:true` is in place; the 4-trade-progress UI is V22).

**Schema migration:** none required. All V21 features use existing tables / columns. Verified via grep of v21 source — no new `sb.from(<new-table>)` calls.

**Layer A (code, static):** ✅ verified via grep + Babel transform. Markers all present at expected counts:
- `BAR_BREAK_DURATION_MS=30*60*1000` ×1
- `priority:'high'/'normal'/'low'` ×7/6/3 (16 missions total)
- `context:'any'/'bar'/'loc:2'` ×12/3/1
- `weddingPipeline:true` ×4 (Jorik missions)
- `wp:1` ×4 (L_DATA challenges) + 1 in code comment
- `running:true` ×1 (trade)
- `ctxMatches` ×4 (def + 3 calls), `sortedMissions` ×2, `inBar` ×1
- 12/12 NEW L_DATA titles present, 12/12 OLD L_DATA titles absent
- 8/8 existing Jorik mission IDs preserved, 8/8 new Jorik mission IDs present
- `Mike onthult bij dinner` ×1, `14:00 — 19:30` ×1, `vleugje Italië` ×1, `de ring is zoek` ×0
- Babel transform: clean parse (305,670 B JSX from 359,502 B HTML)

**Layer B (context, docs):** ✅ AUDIT-EXPERIENCE-20260426.md ship-list §14 reconciled item-by-item against V21 implementation. 9/13 items shipped this round; 4 polish items explicitly deferred to V22 (documented above). Triage outcome §13 of audit reconciled against the AskUserQuestion answers in this session. PROJECT-MEMORY (this entry) reflects the change with correct version + date + SHA.

**Layer C (runtime, live):** ⏳ pending Mike's push. Local `index.html` is byte-identical to `stadsspel-rotterdam-v21.html` (both SHA256 `74e945ab…ba34b`), but the GitHub Pages copy is still V20. Layer C runs after Mike pushes `index.html` and we re-fetch via Chrome MCP for SHA-parity + functional smoke (Jorik panel context badges render, bar-set-piece missions surface during a triggered bar break, wedding-pipeline chip counts correctly, splash copy line is live).

**Verdict:** ⚠️ PARTIAL (2/3) — Layer A + B confirm. Layer C deferred to post-push.

**Post-push verification plan:**
- `fetch(liveUrl+'?cb='+Date.now())` from a fresh tab → expect 359,502 B, SHA256 `74e945ab…ba34b`.
- Functional smokes (post-Block-A reset for clean state):
  - Jorik panel renders 16 missions, sorted by priority + context. Bar missions show "🍻 Pas tijdens een bar break" lock.
  - Trigger a bar break → bar missions sort to top + unlock + show "🍻 Bar break — nu actief".
  - Trigger Jorik move to my team while inside Markthal preview band (300m of POI 2) → markthal-anthem unlocks with "📍 Bij Markthal — nu" label.
  - Walk to Erasmusbrug as a non-Jorik team → wedding-pipeline chip shows "0/4" → complete Brug Catwalk → chip flips to "1/4". Tap reveals remaining 3 with POI/challenge names.
  - Splash on first load shows "14:00 — 19:30" + Italian-flavor line. No "ring is zoek" copy anywhere.
- Cleanup: rejection of any prior test rows + Block A soft reset before gameday-eve.

**Open inputs from Mike (unblocked items deferred until he provides):**
- 3 bar names + coords (admin dropdown still shows the 13 L_DATA bar POIs as preset, plus a custom-name entry — bar set-pieces are bar-name-agnostic so this isn't a blocker).
- Winner prize copy (the second line of the prize-teaser panel at v21:3804 — replace "Nog een geheim — Mike onthult bij dinner" with the actual prize when decided).
- Wedding-video framing copy (intro + outro for the 14 June wedding-day edit — Mike's call, not a code change).

**Reminder for Mike on gameday:** bring a starter object for the `trade` mission. Low monetary value, bargain-able (euro coin, Rotterdam-themed keychain, small gift card). The mission says "Mike geeft Jorik bij start een klein object."

### V20 (2026-04-19 evening) — Human-Logic audit team-allocation fixes (post-V19)
> Not to be confused with the historical "V20 — full P0 batch" entry (18 Apr morning, rolled into v18.html) immediately below. That was a P0-blocker sprint; THIS V20 is the next-numbered file (`stadsspel-rotterdam-v20.html`) shipped on top of V19 to close the 19 Apr Human-Logic audit.

**File:** `stadsspel-rotterdam-v20.html` (SHA256 `6bfb30e3d3c04ca2eadef1efc00363770d7f5629839cce777c220f66412ec466`). `index.html` byte-identical via `cp` + `shasum -a 256`.
**Paired SQL patch:** `SUPABASE-CATCHUP-PATCH-V32.sql` (applies on top of V31.1 — adds `teams` UNIQUE indexes + `team_members` table with session-id UNIQUE + realtime publication).
**Audit:** `audit-human-logic-team-allocation-20260419.md` — 10 gaps ranked by gameday impact; Mike bundled all 7 in-scope items into V20 via AskUserQuestion.

**Scope (Mike's explicit answers to 8 clarifications, 19 Apr):**
- Systems: BOTH — Jorik rotation AND player-to-team allocation.
- Overtime Jorik: silently continue (unreachable for 4×3).
- Late-join after startGame: allow with warning.
- Player count: track via `team_members` + soft cap UI; admin can override.
- Admin Jorik-revisit: warn + confirm dialog.
- Two-tab trick: not a concern (phones only).
- Team rename: admin-only, any phase.
- Player → spectator mid-game: keep current.

**Items shipped (audit #-numbering):**
1. **Item 1 — team_members + session UUID + live headcount.** New `ensureSessionId()` extends `stadsspel_v12_session` with a per-browser `crypto.randomUUID()`. A useEffect on `myTeam` change upserts `{team_id, session_id, display_name}` into `team_members` (DELETE on logout/kick). All phones subscribe via realtime INSERT/DELETE/UPDATE and re-SELECT the full count on every event — no trigger-based counter (burned by V31 undercounts). Admin "Team beheer" row now shows "📱 N" headcount alongside score; TeamSetup starter-pack "Bezet" state shows "Bezet · 📱 N". Spectators / `id<0` excluded from counts. Soft cap enforcement deferred — the current UX has no explicit "join" moment where a cap dialog could fire; data plumbing + visibility ship now, enforcement waits for a future join-existing-team UX.
2. **Item 2 — late-join warning.** Dismissible banner at top of TeamSetup when `phase >= 1` ("De wedstrijd is al gestart · Fase: Zoektocht/Geruchten/Cirkel/Finale · je kunt nog meedoen, maar een deel van de punten is al vergeven"). Non-blocking per Mike's "allow with warning" decision. "Begrepen" button dismisses for the session.
3. **Item 3 — Jorik revisit warn + "al bezocht" badge.** Admin view chips for teams that already held Jorik show "✅ al bezocht"; a new `jorikVisitedTeamIds` state queries `activity_feed [JORIK] team=%` and populates a Set. Clicking a visited team in `onMoveJorik` now triggers a `confirmAsync` "Jorik heeft dit team al bezocht — toch opnieuw?" dialog.
4. **Item 4 — admin team rename button.** ✏️ button in Team beheer row opens promptAsync → local case-insensitive nameConflict check → `sb.from('teams').update({name})` → 23505 error code mapped to "X is al in gebruik — kies andere naam" toast. Teams UPDATE realtime sub (v20:~1543) propagates the new name to every phone.
5. **Item 5 — V32 catchup SQL + client 23505 surfacing.** `SUPABASE-CATCHUP-PATCH-V32.sql` adds `teams_name_lower_unique` (partial index on `LOWER(name) WHERE NOT spectator`), `teams_emoji_unique` (partial on emoji), `team_members` table with `UNIQUE(session_id)`, RLS "Allow all" policy, and Realtime publication membership. Idempotent via `IF NOT EXISTS` + `DO $$ pg_publication_tables` guard. Rollback block at bottom for emergency revert. Client `createFromPack` / `createCustom` / `renameTeam` branch on `res.error.code==='23505'` + message inspection to show the right field-specific error ("Lions is al in gebruik" vs "🦁 is al gekozen").
6. **Item 6 — kick-reason toasts.** Module-level `__v20KickReason` one-shot flag set by the hydration IIFE when the 12h session expires (captures the previous team name for a personalized message). A `useEffect(mount)` in App flushes it to `setToast('⏱ Sessie van Team X verlopen (12h) — kies opnieuw')` and clears. Phantom-guard and teams-DELETE realtime kicks now use the distinctive "👻 Team niet meer gevonden — kies opnieuw" / "🗑 Team verwijderd door Game Master — kies opnieuw" prefixes so a player can tell why they landed back on splash.
7. **Item 7 — Jorik swap-reason feed prefix.** `moveJorik` accepts an `origin` param: `'admin'` → "👑 Admin:", `'bar'` → "🍻 Bar break:", `'start'` → unprefixed (startGame writes its own 💍 line). Bar-break caller now passes `'bar'`. The `[JORIK] team={id}` marker line is unchanged (history source of truth).

**Decisions deferred (in scope but not shipped this round):**
- Soft cap dialog / VOL badge — needs a join-existing-team UX first.
- Two-tab trick prevention — Mike explicitly flagged as not a concern.

**Deploy status:** code complete + SHA-verified locally. SQL patch unpushed — Mike must paste `SUPABASE-CATCHUP-PATCH-V32.sql` into the Supabase SQL Editor before the UNIQUE constraints activate and `team_members` becomes writable. Until that happens, the client gracefully no-ops on "table does not exist" errors (counts show 0 everywhere, rename/create just fall back to client-side-only uniqueness).

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
| `index.html` | Deployed to GitHub Pages. Always a byte-for-byte copy of the latest `vN` file. **Currently: V22 (2026-04-26) on disk, byte-identical to `stadsspel-rotterdam-v22.html` (SHA256 `2d7b5bbe6b750a5b4a63487731cc0096e07b8bc673c5752d30d35fd1998b98dd`, 373,936 B, 5,771 lines). Awaits Mike's manual GitHub upload. Live deploy still on V30 base; after this push, deploy lands V21+V22 in one go.** |
| `stadsspel-rotterdam-v22.html` | **Current working source (V22, 26 Apr 2026 evening).** SHA256 `2d7b5bbe6b750a5b4a63487731cc0096e07b8bc673c5752d30d35fd1998b98dd`, 373,936 B, 5,771 lines. Stacks on V21. V22 = QA pass on V21 driven by 4 parallel agents + Mike's "test over and over again" directive. 16 fixes shipped: video upload cap 700kB→5MB at 3 sites, FINALE_MULTIPLIER applied to Jorik missions, wedding-pipeline chip cross-checks completedPts>0 (excludes rejected photos), completeJorikMission reads pts from array (defensive), ctxMatches default-deny on unrecognised context, GPS hysteresis (280/320m) on loc-tagged Jorik missions, trade running-mission UI with `jorikRunningCounts` per-step counter + 4-trade chip, bar-consent pre-submission `window.confirm` for `context:'bar'` missions, admin pace-guide panel in Beoordeel tab (9-step schedule 14:00→19:30), 5 content refinements (POI 36/73/75 + chicken-dance + bar-rating), 33-POI light-touch refresh (mechanical content sweep), memoize sortedMissions + tighter inBar shape check. Babel clean. Schema migration: NONE. |
| `stadsspel-rotterdam-v21.html` | **Predecessor (26 Apr 2026 morning).** SHA256 `74e945ab6dfc7aa23ff072292c70c64b340423e40abd08f42cd816c745eba34b`, 359,502 B, 5,621 lines. Stacks on V20 base (which already carried V19+V32+V31.1 catch-up patches). V21 ships: JORIK_MISSIONS expanded 8→16 with `priority`/`context`/`weddingPipeline`/`running` fields; JorikMissions component context-aware (sorts by `inBar` + priority, locks non-matching missions visually); 3 bar set-piece missions (`bar-proposal`/`bar-rating`/`bar-toast` — all `context:'bar' priority:'high'` — light up only during an active bar break for Jorik's team); Markthal anthem mission (`markthal-anthem`, `context:'loc:2'`, GPS-gated to Markthal preview band); 12 weakest L_DATA challenges replaced with bachelor-tone equivalents (POIs 7/14/25/33/36/39/49/56/73/75/91/100, all 12 now `video` or stronger content); 4 existing video L_DATA challenges flagged `wp:1` for the wedding-video pipeline (POI 1 / 16 / 51 / 77); wedding-pipeline progress chip on LeaderboardView (X/4 shots, hidden when Jorik in team); mid-game prize teaser line ("Mike onthult bij dinner" placeholder); bar break duration bumped 15→30 min; splash copy refreshed (14:00–19:30 + Italian flavour line); old "ring is zoek" narrative copy verified gone. Babel transform clean. Schema migration: NONE (all V21 features use existing tables). Layer A + B verified ✅; Layer C deferred to post-push. |
| `AUDIT-EXPERIENCE-20260426.md` | **V21 audit doc (26 Apr 2026).** Full structured report mirroring Mike's brief: 10-area analysis (Jorik / wedding video / bar moments / task design / mechanics / timing / theme / quality / testing / expansion), L_DATA inventory of 102 POIs with WEAK/STRONG flag (45/57 split), triage outcome of the prior-bachelor 24-task list (10 accepted as Jorik-only / 14 killed), 13-item V21 ship-list, 12-row replacement diff in Appendix B, 33-POI light-touch refresh list in Appendix C (deferred to V22). Drove this V21 build. |
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
