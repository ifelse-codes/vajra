# Vajra — Working Roadmap

**Updated:** 2026-07-23 · **Session 98 — CODE (docs): AUTOPILOT-TRUST REPOSITION — DONE.**
The **lead** is now the *outcome*: **the autopilot trust layer — leave your agent working for days,
come back, and trust the result.** The 8-station pipeline stops being the pitch and becomes the
**engine** that earns the trust (`DECISION-005`). Feelings-based release bar → the **falsifiable
Autopilot Ladder** + a **2026-09-15 release backstop**; a **machinery-freeze rule** (a session runs
the ladder or fixes what a run broke — nothing else) kills the 4-GT easy-green gradient by
construction. Docs only — no `src/`.
*Prior: S97 — DOGFOOD (paid, Ladder Rung 1): chitra S08 e2e, $1.2758 authoritative, `--stations 08`
= 2/8, **Coder doubly-blocked** (older scaffold has no marker slots + headless can't approve a
commit → zero shas); agent refused self-commit even under `--dangerously-skip-permissions`; no green
forced. Recs fed this reposition (scaffold marker slots · env-marker commit path · agents write
markers/Vajra verifies).*

**Direction (binding):** the product is **provable agent governance**, shaped as a **governed
multi-agent SDLC pipeline** (`DECISION-001`), sold as **the autopilot trust layer** — pipeline =
engine, not pitch (`DECISION-005`). Fidelity is load-bearing (`DECISION-002`), verdicts attested
(`DECISION-003`), chained tamper-evident (`DECISION-004`).

---

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-07-23 |
| Current phase | **Repositioned to the AUTOPILOT TRUST LAYER (S98, `DECISION-005`)** — pipeline = engine, not pitch. The 8-station governed pipeline is complete and dogfood-proven e2e once (S97, Rung 1, disclosed partial). The next six months = **climb the Autopilot Ladder** (Rung 2 one-day unattended → Rung 3 two–three days, ≥2 repos, merge-without-review), under a **machinery-freeze rule** + a **2026-09-15 release backstop**. Full spine: Analyst · Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer. Receipt authoritative (S92 $0.2713 · S97 $1.2758). Commit obedience ENFORCED (S93); nested-repo blindspot CLOSED (S94). |
| Last closed session | Session 97 — DOGFOOD (paid, Ladder Rung 1): chitra S08 e2e; $1.2758; 2/8, Coder doubly-blocked; voluntary obedience reconfirmed under skip-permissions |
| Active session | Session 98 — CODE (docs): autopilot-trust reposition (DECISION-005 + VISION lead + this ROADMAP) |
| Crate | package `vajractl` · binary `vajra` (rename in scope of the v0.1 release task — current name taken) |

---

## 6-Month Autopilot Plan (S98 · `DECISION-005`)

**Lead = the outcome:** *leave your agent working for days, come back, trust the result.* The
pipeline is the engine. This section is the falsifiable path from "machinery built" to "trust
proven + shipped." Deadline: **≈ 2027-01** (6-month founder proof window).

### The Autopilot Ladder (replaces the feelings-based release bar)

| Rung | Autonomy | Pass condition (ALL required — falsifiable) |
|---|---|---|
| **1** (= S97, DONE) | ~1 task, hours, 1 repo (chitra) | Full station shape recorded · Coder-dark diagnosed |
| **2** | **1 day unattended**, multi-task, chitra | **Zero governance leaks** · **honest receipts** · **fidelity verdicts correct on founder spot-check** |
| **3** | **2–3 days unattended, ≥2 repos** | All of Rung 2 **+ the merge test: founder merges the work WITHOUT line-by-line review** |

- **Guards ON for every ladder run** (`publish_guard`/`commit_guard` armed) — autopilot-trust demos
  need the real teeth; this also retires the audit's "teeth off in own house" finding.
- **Rung 2 design owes to S97:** fix the Coder-dark cause — **agents write the markers, Vajra
  verifies** + an **env-marker commit path** (`VAJRA_ALLOW_COMMIT` shape) so an unattended `-p` run
  can reach a full closeout. chitra's older scaffold needs the marker slots too.

### Release backstop (kills the moving bar)

**v0.1 ships when Rung 3 passes once OR on 2026-09-15 — whichever comes FIRST.** Release =
installable by a stranger: final crate name (rename — current is taken), tagged binaries, a README
**truth-pass** (retire the stale ~8× receipt claim + unverifiable install paths — scheduled INSIDE
this task, **not** S98), a 10-minute quickstart. **Release ≠ launch; no feelings required.**

### Evidence-content machine (weeks ~6–12)

Every ladder run **auto-drafts content from its own artifacts** — the ledger, blocked actions, and
receipts ARE the material. Weekly AI-drafted / founder-edited posts → 2–3 real launches (Show HN,
r/ClaudeAI, X). Publishing becomes an *output of the loop*, routing around the comfort-zone blocker.

### Signal → scale (months 3–6)

Ten named 1:1s (agent-tool builders, agency founders) with the Rung-3 demo. On signal: spend to
**$1k/mo**, more repos, and cross-agent starts with the **cheap middle move** — a **neutral evidence
format** (align ledger/receipts with the open `agent-trace` spec) **before** any second runtime.
Cross-agent = the acquisition-legibility card (a category, not a Claude plugin). Still **0 cross-agent
code today** — sequenced, not claimed.

### Scoreboard

| Checkpoint | Target |
|---|---|
| **Wk 8** | Rung 3 passed once · v0.1 installable by a stranger |
| **Month 4** | 3 launches done · weekly evidence posts running · 10 named 1:1s attempted |
| **Month 6** | ≥1 of — 100+ stars / 5 external repos running it / 1 acquirer-adjacent conversation |

### Two kill signals

- **Kill A (founder's — technical):** the trust loop keeps failing at Rung 2–3 (drift, leaks, gamed
  gates) → thesis broken; stop or rebuild.
- **Kill B (auditor's — market):** the loop HOLDS but the market stays silent after 3 real launches
  → **pivot the fidelity auditor into a standalone agent-PR acceptance checker** (the one component
  with demand outside the full-pipeline bet).

**S100 (next NO-CODE GT) lead lens:** *is the ladder being climbed, or did machinery resume?*

---

## Pipeline Status (8 Stations)

| # | Station | Shipped | What it enforces |
|---|---|---|---|
| 1 | **Analyst** (WHAT) | S61–S62 | Intent → structured prompt + acceptance criteria |
| 2 | **Architect** (DESIGN) | S67 | Recorded design marker + existence-gated ADR reference |
| 3 | **Planner** (HOW) | S64 | `## Plan` steps with `covers: N` markers |
| 4 | **Coder** (EXECUTE) | S68 | `## Execution` shas, existence-gated (`git cat-file -e`) |
| 5 | **QA** | S69 | Verify script re-runs live; stale-green = fail |
| 6 | **Demo-er** | S71 | Demo script runs live |
| 7 | **Releaser** | S72 | Branch merged or attested ACCEPT in ledger |
| 8 | **Reviewer** (fidelity + ledger) | S55–S59 | Independent ACCEPT; `sha256(prompt‖diff)` attested; chain tamper-evident |

**Station counter:** `vajra next --stations NN` → K-of-8 (S74; Releaser durable via ledger S82;
GT-verified S75/S80/S85).

---

## Completed Sessions

| Session | Type | What shipped |
|---|---|---|
| S01–S09 | CODE | Core: `vajra claude` · `init` · `check` · `next --advance` · budget guard · e2e loop |
| S10–S17 | CODE | `vajra estimate` (ADR-0005) · release pipeline (GH Actions, 3 targets) · maturity L1/L2/L3 |
| S18–S24 | CODE | Varta language + co-pilot loader + scaffold propagation + `vajra check --render` |
| S25–S30 | CODE+GT | One-session-per-chat guard · Darshan skill + propagation · S30 GT (second-agent deferred) |
| S31 | DOGFOOD | 3 core breakages found: Darshan unenforced · compression schema · brownfield unguided |
| S32 | CODE | Darshan enforcement (boot hook + `▶ ACK NOW` speak-back) |
| S33 | CODE | Compression schema fix (snake_case envelope; regression test on real payload) |
| S34 | CODE | Brownfield onboarding + auth pre-check in `vajra claude` |
| S35 | GT | Moat architecturally complete; dogfood 🔴 (not live-verified) |
| S36 | DOGFOOD | Real dogfood — enforcement leak (agent shipped 2 PRs unstopped at L3) |
| S37 | CODE | Close enforcement leak (`hook-publish-guard.sh` L2/L3 exit 2) |
| S38 | CODE | Propagate publish-guard into `vajra init` |
| S39 | CODE | Harden guards (unquoted-only; session-guard fires on `--advance`) |
| S40 | GT | Harm closed, proof not; jq fail-open + git-level hooks gaps found |
| S41 | CODE | Fix compression fail-gate (`preserves_failure_signal()` trait; git family folds) |
| S42 | CODE | `jq`-preflight fail-closed in all 5 hooks |
| S43 | CODE | Git-level `.githooks/pre-commit` + `pre-push` scaffolding into `vajra init` |
| S44 | CODE | `.claude/settings.json` additive merge on `vajra init` (brownfield gap closed) |
| S45 | GT | Moat complete + paper-sound; dogfood 🔴 4th consecutive GT |
| S46 | DOGFOOD | Live re-dogfood — moat 🟢 VERIFIED (4 paid runs ~$3.84) · pivot to direction B |
| S47 | CODE | Mid-run co-pilot murmur (`UserPromptSubmit` hook) |
| S48 | CODE | Obedience metric (`vajra meter` → `obedience %`) |
| S49 | CODE | Obedience baseline (`vajra meter --all` → ranked table, median 98.9%) |
| S50 | GT | Paper moat aging; value UNMEASURED |
| S51 | DOGFOOD (PAID ~$1.52) | Value gap A/B n=1 — null; receipt 9× overstatement found |
| S52 | DOGFOOD (PAID ~$4.95) | Value gap harder task n=2 — null; direction B UNPROVEN |
| S53 | NO-CODE | Reframe: governance-as-product + governed SDLC pipeline north-star |
| S54 | CODE | Analyst stage v0 — cold review REJECT (fidelity gap: 1-of-5 delivered) |
| S55 | GT | Cold subagent re-REJECTED S54 unaided (fidelity brain) |
| S56 | CODE | Fidelity gate: `verify-closeout.sh` blocks without independent ACCEPT review |
| S57 | CODE | Propagate fidelity gate + `VAJRA_CLOSEOUT_WAIVER` into `vajra init` scaffold |
| S58 | CODE | Attestation: recompute `sha256(prompt‖diff)`; blocks forged/stale/recycled hashes |
| S59 | CODE | Ledger: `--ledger/--ledger-verify` chains attested verdicts (tamper-evident) |
| S60 | GT | Scope creep: gate arc outran pipeline; meta-check WIN; dogfood 🟡→🔴 |
| S61 | CODE | Analyst 1-of-5 → 3-of-5 |
| S62 | CODE | Analyst COMPLETE (5-of-5; Intake + Options) |
| S63 | DOGFOOD (PAID ~$1.27) | Paid dogfood on chitra; `$1.27/run`; receipt overstates 4.71×; compression 0 folds |
| S64 | CODE | Planner station (pipeline station 2; `covers: N` existence-gated) |
| S65 | GT | 3 stations live; receipt 🔴 crossing deferrable→blocking the pitch |
| S66 | CODE | Receipt authoritative (`total_cost_usd` headline; unknown models flagged, not guessed) |
| S67 | CODE | Architect station (design gate; existence-gated ADR references; two-pass review) |
| S68 | CODE | Coder station — **5-station spine COMPLETE** (`## Execution` shas, git-existence-gated) |
| S69 | CODE | QA station — pipeline = 6 stations; verify script re-runs live (stale-green dead) |
| S70 | GT | Machinery without measurement; dogfood deferred by founder decision |
| S71 | CODE | Demo-er station (pipeline station 7) |
| S72 | CODE | Releaser station — **8-station spine COMPLETE** |
| S73 | CODE | Close-path reliability |
| S74 | CODE | Payload counter (`vajra next --stations NN` → derived K-of-8, mandatory GT input) |
| S75 | GT | Counter 1/8 → 8/8 measured; Releaser decay + debt-label drift findings |
| S76 | DOGFOOD (PAID ~$unknown) | Paid ride-along; governance real + VOLUNTARY; receipt 🔴; headless read-only wall hit |
| S77 | CODE | Receipt truth: honest "no authoritative cost available" when no `total_cost_usd` |
| S78 | CODE | Recover true $: tee the `-p` result stream; `$0.0277` live |
| S79 | CODE | Re-price stale opus rate (opus-4-8 = $5/$25 not $15/$75) |
| S80 | GT | Easy-green detour (S76–S79 receipt arc); `check_execution_shas` gap found |
| S81 | CODE | `verify-closeout.sh` gains `check_execution_shas` (blocks `<sha>` placeholders) |
| S82 | CODE | Releaser reads from ledger when branch is pruned (durability fix) |
| S83 | CODE | Warn before headless read-only run (`--dangerously-skip-permissions` missing) |
| S84 | CODE | Typed `CannotEvaluate::{Timeout, SpawnFailure}` (two-pass cold review ACCEPT) |
| S85 | GT | Easy-green detour again (S81–S84); attestation substring-check 🔴 load-bearing |
| S86 | CODE | Harden attestation: recompute-and-compare (16/26 verified live) |
| S87 | CODE (docs) | Fill S76's `## Execution` shas; discovered live-bytes attestation bug |
| S88 | CODE | Fix `canonical_inputs_sha` to hash review-time snapshot; repaired S73+S79 as bonus |
| S89 | CODE (docs) | ROADMAP consolidation: 710→219 lines; fixed stale "Where We Are" table (27 sessions stale) |
| S90 | GT (NO-CODE) | Ground truth: state_drift 🔴 (S76 date error); S89 Reviewer hash mismatch; dogfood 🔴 (13 sessions / 2–3 days); easy-green detour 3rd GT |
| S91 | CODE (B+C) | Fix S89 Reviewer hash mismatch (intermediate-commit attestation); add `--dogfood-age` live git query; 283 tests |
| S92 | DOGFOOD | Paid `vajra claude` on chitra S08 (`release.yml`): $0.2713 authoritative; agent refused autonomous commit (VOLUNTARY); `--stations 92`=3/8; dogfood 🔴→🟢 |
| S93 | CODE | Commit gate voluntary → ENFORCED: L2 `pre-commit` belt + L3 un-forgeable `hook-commit-guard.sh` (`VAJRA_ALLOW_COMMIT==NN`); scaffolded ON; 27/27 verify; ACCEPT |
| S94 | CODE | Repo-identity-aware guards (nested-repo blindspot S52 closed): git facts pinned to own top-level; governed project surfaced; fail-closed when no own repo; two-pass review (pass 1 caught fail-open → fixed); 23/23 verify; ACCEPT |
| S95 | GT (NO-CODE) | Audited S91–S94: 7 🟢 / 3 🟡 / 0 🔴. Enforcement arc complete but **pipeline unadvanced since S72**; **Coder station dark 4-for-4**; 4th consecutive easy-green GT; KNOWLEDGE §6 bloat + stale dogfood backlog item flagged. Founder pick A → S96 pipeline dogfood (re-sequenced: fmt-fix first) |
| S96 | CODE | CI green: `cargo fmt` the 3 rustfmt-1.9.0-drifted files (`next.rs`/`dogfood/mod.rs`/`stations/mod.rs`), **zero logic**; clippy + 286 tests green; CI green **both OS** (#97); cold review ACCEPT (byte-identical `rustfmt(main)==HEAD`); Coder `## Execution` shas filled (first non-dark since S72, trivial-mapping caveat) |
| S97 | DOGFOOD | Paid e2e `vajra claude -p` on chitra S08: $1.2758 authoritative (fable-5, exit 0); `--stations 08`=2/8; **Coder doubly-blocked** — chitra's older scaffold has no `## Execution` slots AND headless can't supply a commit-approval token; agent refused self-commit under `--dangerously-skip-permissions` vs a teeth-less gate (3rd voluntary-obedience reconfirm); no green forced; recs → prompt 98 |
| S98 | CODE (docs) | **Autopilot-trust reposition** (`DECISION-005` + VISION lead + this ROADMAP): pipeline = engine, not pitch; falsifiable Autopilot Ladder replaces the feelings bar; 2026-09-15 release backstop; machinery-freeze rule; scoreboard + 2 kill signals. Docs only, no `src/`; honesty rows preserved |

---

## Active / Upcoming

| Session | Status | Goal |
|---|---|---|
| S90 | Complete | NO-CODE Ground Truth — state_drift 🔴 corrected; S89 Reviewer hash mismatch found; dogfood 🔴 |
| S91 | Complete | CODE (B+C) — S89 Reviewer PASSED + `--dogfood-age` live query; 283 tests |
| S92 | Complete | DOGFOOD — paid ride-along on chitra S08; $0.2713 authoritative; dogfood 🔴→🟢; commit-gate obedience VOLUNTARY (S93 target) |
| S93 | Complete | CODE — commit gate voluntary → ENFORCED (L2 belt + L3 un-forgeable `VAJRA_ALLOW_COMMIT` guard); scaffolded ON |
| S94 | Complete | CODE — repo-identity-aware guards; nested-repo blindspot (S52) closed; fail-closed when no own git repo |
| S95 | Complete | NO-CODE GT — enforcement arc complete but pipeline unadvanced since S72; Coder dark 4-for-4; founder pick A |
| S96 | Complete | **CODE** — CI fmt-fix (rustfmt 1.9.0 drift; `cargo fmt` the 3 files, zero logic); CI green both OS (#97); cold review ACCEPT |
| S97 | Complete | **DOGFOOD (paid)** — chitra S08 e2e; $1.2758; 2/8, Coder doubly-blocked; voluntary obedience reconfirmed under skip-permissions; recs → prompt 98 |
| S98 | In progress | **CODE (docs)** — autopilot-trust reposition: DECISION-005 + VISION lead + ROADMAP 6-month ladder; pipeline = engine not pitch |
| **S99** | **Next** | **DOGFOOD — Autopilot Ladder Rung 2** (one day unattended, multi-task, chitra): zero governance leaks · honest receipts · fidelity verdicts correct on founder spot-check. Guards ON. First move under the machinery-freeze rule |
| S100 | Upcoming | **NO-CODE Ground Truth** — lead lens: is the autopilot ladder being climbed, or did machinery resume? |

---

## What Currently Works

| Component | Status |
|---|---|
| `vajra claude · next · check · init · estimate · meter · hook` | ✅ 7 commands |
| 8-station governed pipeline | ✅ All stations live; `vajra next --stations NN` → K-of-8 |
| Receipt | ✅ Authoritative (`total_cost_usd`); honest null when unavailable; fable-5 + opus-4-8 priced |
| Attestation | ✅ Recompute-and-compare (S86); review-time snapshot (S88); 22/26 historical verified |
| Releaser durability | ✅ Reads ledger when branch is pruned (S82) |
| Fidelity gate | ✅ `verify-closeout.sh` blocks without independent ACCEPT review |
| `cargo test --lib` | ✅ 286 tests |
| CI on `main` (both OS) | ✅ Green (S96) — `fmt --check` + `clippy -D warnings` + `test --lib`; rustfmt pinned 1.9.0-stable |
| `vajra next --dogfood-age` | ✅ Git-derived staleness; never reads STATE.md |

## What Is Weak / Broken

| Item | Severity | Notes |
|---|---|---|
| **Dogfood (launcher)** | 🟢 | Fresh — S92 = 2026-07-21, $0.2713 authoritative (`--dogfood-age` shows S92) |
| **Dogfood (pipeline end-to-end)** | 🟡 | NEVER — S92 was 2/8 (launcher loop only); the stations (Coder/QA/Demo-er/Releaser on a real task) are unmeasured live (S95). S96 targets this |
| **Coder/EXECUTE station dark** | 🟡 | S95: Coder ABSENT 4-for-4 (S91–S94, incl. 2 code-shipping sessions) via `vajra next --stations NN`; `## Execution` shas not populated even by code sessions |
| **Machinery-vs-payload gradient** | 🟡 | 4th consecutive GT (S80/S85/S90/S95); enforcement arc complete, pipeline unchanged since S72; next session must be a pattern-breaker |
| **KNOWLEDGE §6 bloat** | 🟡 | 416 lines / 69 entries / ~85K tokens; header "Reloaded every session" false; flagged since S60, unremediated |
| **Commit gate in THIS repo** | 🟡 | Un-forgeable only at L3, which is `commit_guard: off` here (build-agent exemption); L2 belt is inline-forgeable + `--no-verify` bypasses both. Teeth proven by test + ON in scaffolds (S93 fakest green) |
| ~~Nested-repo guard blindspot~~ | ✅ | CLOSED S94: git facts pinned to own git top-level; fail-closed when no own repo; governed project surfaced. Residual (🟡): own-git **non-session-branch** marker fallthrough left intact (zero-regression); worktree/submodule/symlink shapes fail-closed but untested |
| ~~Repo-wide rustfmt 1.9.0 drift~~ | ✅ | CLOSED S96: `cargo fmt` reformatted the 3 files; `cargo fmt --check` clean crate-wide; CI green both OS. Keep local rustfmt = 1.9.0-stable (CI's `@stable`) to avoid recurrence |
| Compression | 🟡 | 0 folds on real CC (S63 + S76); never claim until measured |
| `full_historical_scan` pass bar | 🟡 | Floor (`verified >= 16`), not strict zero-regression assertion (S88 reviewer note) |
| Signal-death edge case | 🟡 | `gate_run::code_or_conservative` has no dedicated automated test (S84) |
| `wait_or_timeout` Err | 🟡 | Pre-existing (S73) OS-level error classifies as `CannotEvaluate::Timeout` |
| Legacy opus ids (4.0/4.1/4.5) | 🟡 | No confirmed current rate; held at historical $15/$75 conservative estimate |
| `candidate_diffs` intermediate-commit scan | 🟡 | Enumerates all commits in base..p2 per merge (S91B fix); O(n·k) scalability; post-merge-tip case still ABSENT |
| `read_prompt` ambiguous match | 🟡 | Picks first on >1 prompt file match; bash side fails-closed; rare |
| Cross-agent breadth | 🟡 | 0 code; founder-gated (S26/S70) |
| `canonical_inputs_sha` is single-candidate | 🟡 | Can only verify current open session; historical re-verification requires Rust side |
| Ledger: tamper-evident not tamper-proof | 🟡 | `--ledger-verify` opt-in, not in mandatory closeout run |

---

## Backlog (governed by the machinery-freeze rule — S98)

**The active queue is the 6-Month Autopilot Plan above** (Rung 2 → Rung 3 → release backstop). Per
the **machinery-freeze rule** (`DECISION-005`): a session either runs the Autopilot Ladder or fixes
something a ladder run broke — **nothing below gets built on its own merit.** Every item is now
"**only if a ladder run breaks it**", ordered by how likely a run is to force it.

**🧊 Frozen machinery — pull ONLY when a ladder run breaks it:**
- **Coder-marker fix** (S97 — likeliest first pull; Rung 2 will demand it): *agents write the
  `## Execution`/`## Delta` markers, Vajra verifies*; add an **env-marker commit path**
  (`VAJRA_ALLOW_COMMIT` shape) so an unattended `-p` run can reach a full closeout; marker slots
  ride the `vajra init` scaffold (chitra's older scaffold lacks them).
- **KNOWLEDGE §6 prune** (chronic since S60) — 416 lines / 69 entries / ~85K tokens; cut to permanent lessons, move per-session narrative to `sessions/`, fix the false "Reloaded every session" header
- **Compression `cargo`/`npm`/`pytest` exit-code fold gap** (S33/S41) — `exit_code == Some(0)` path; real CC never sends it
- **Guard identity: exotic git shapes** (S94 residual) — worktree / submodule / symlinked-root untested (fail-closed today); own-git non-session-branch marker fallthrough
- **GT tripwire: chronically-absent station** (S95 meta-check) — "any station ABSENT for N consecutive sessions" as an explicit GT flag
- **Hardening bin:** `full_historical_scan` → strict zero-regression bar (S88) · `--ledger-verify` into mandatory closeout · budget cap per-session/kill-mode (S36) · silent-parse-failure signal (S36) · `canonical_inputs_sha` single-candidate limit

**🔒 Owner-gated (unfrozen only by an explicit founder call):**
- Cross-agent (2nd agent) — now **sequenced in the plan**: neutral evidence format (`agent-trace`) first (months 3–6), a second runtime only on signal
- North-star breadth indicator (S25) — RED until ≥2 agents · Crates.io name taken — rename is in the v0.1 release task
- `vajra bench` (S52) · trace-mine `⚡on` advisories (S49-C) · canned workflows / policy enforcement / governed memory — after users exist

---

## Design Rules (from competitive analysis)

| Rule | Why |
|---|---|
| **Max 7 top-level commands** | SuperClaude's 30+ commands confuse users |
| **Context footprint < 5%** | SuperClaude sessions start 32% full — Claude freezes |
| **2–3 agents deep > 10 agents shallow** | GSD supports 10 via prompt templates; deep beats shallow |
| **Enforcement is the wedge** | GSD/SuperClaude are prompt libraries — agents can ignore them |
| **Init must be frictionless** | GSD's `npx` one-liner is why people try it |

---

## Competitive Reference

| Tool | Stars | Mechanism | Vajra's edge |
|---|---|---|---|
| GSD | 64k | Prompt files + `.planning/` state | Enforcement (Rust binary, hooks, fail-closed gates) |
| SuperClaude | 23k | Prompt injection via commands | Vendor-neutral + small footprint (no context bloat) |
| Loop Engineering | small | Scaffolding templates + skills | Runtime enforcement + honest metering |
| AxonFlow | — | Hook-based policies | Local-first, no cloud, no retention cliff |

---

## v1 Command Set (max 7, add sparingly)

| Command | What it does | Status |
|---|---|---|
| `vajra init` | Scaffold `.ai/` + hooks + pointers in any repo | ✅ done |
| `vajra next` | Advance session with context; `--stations NN` → K-of-8 | ✅ done |
| `vajra check` | Drift detection + readiness score | ✅ done |
| `vajra claude` | Launch Claude Code with hooks + meter | ✅ done |
| `vajra estimate` | Predict token spend before a session | ✅ done |
| `vajra meter` | Print receipt for a past session | ✅ done |
| `vajra <agent>` | Launch other agents (Codex, Cursor, etc.) | ⏳ not built |

---

## Rules For This Document

1. Update at every closeout — the "Where We Are" table and session log row are mandatory.
2. `NN % 5 == 0` → mandatory NO-CODE GT. Next = **S100** (lead lens: is the ladder being climbed, or did machinery resume?).
3. Mark items done only when they work in a real session, not just tests.
4. Never exceed 7 top-level commands without explicit user approval.
5. Per-session detail goes in `sessions/session-NN-summary.md`, not here.
6. **Machinery-freeze rule (S98, `DECISION-005`):** a session either **runs the Autopilot Ladder** (the active queue) **or fixes something a ladder run broke.** Nothing else gets built. The Backlog is frozen — every item is "only if a ladder run breaks it." This is the by-construction fix for the 4-GT easy-green gradient (S80/S85/S90/S95).
