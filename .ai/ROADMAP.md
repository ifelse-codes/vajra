# Vajra — Working Roadmap

**Updated:** 2026-07-21 · **Session 90 — NO-CODE Ground Truth — DONE.**
Key findings: state_drift 🔴 (S76 date error corrected); S89 = 5/8 (Reviewer hash mismatch); dogfood 🔴.
**Next = S91, CODE (B+C): fix S89 Reviewer hash + add `--dogfood-age` live query.**

**Direction (binding):** the product is **provable agent governance**, shaped as a **governed
multi-agent SDLC pipeline** (`DECISION-001`). Fidelity is load-bearing (`DECISION-002`), verdicts
attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).

---

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-07-21 |
| Current phase | **8-station governed pipeline complete.** Full spine: Analyst · Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt is authoritative. Dogfood 🔴 (13 sessions / 2–3 days stale since S76 = 2026-07-18). S89 Reviewer hash mismatch = S91 target. |
| Last closed session | Session 90 — NO-CODE Ground Truth (`90 % 5 == 0`) |
| Active session | None — between sessions (S90 complete, S91 not yet started) |
| Crate | package `vajractl` · binary `vajra` |

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

---

## Active / Upcoming

| Session | Status | Goal |
|---|---|---|
| S90 | Complete | NO-CODE Ground Truth — state_drift 🔴 corrected; S89 Reviewer hash mismatch found; dogfood 🔴 |
| **S91** | **Next** | CODE (B+C): fix S89 Reviewer hash mismatch + add `--dogfood-age` live query |

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
| `cargo test --lib` | ✅ 271 tests |

## What Is Weak / Broken

| Item | Severity | Notes |
|---|---|---|
| **Dogfood** | 🔴 | 12 sessions (S77–S88) / 19+ days stale since S76; founder-un-parkable; S90 GT's likely top finding |
| Compression | 🟡 | 0 folds on real CC (S63 + S76); never claim until measured |
| `full_historical_scan` pass bar | 🟡 | Floor (`verified >= 16`), not strict zero-regression assertion (S88 reviewer note) |
| Signal-death edge case | 🟡 | `gate_run::code_or_conservative` has no dedicated automated test (S84) |
| `wait_or_timeout` Err | 🟡 | Pre-existing (S73) OS-level error classifies as `CannotEvaluate::Timeout` |
| Legacy opus ids (4.0/4.1/4.5) | 🟡 | No confirmed current rate; held at historical $15/$75 conservative estimate |
| `candidate_diffs` full-rescan | 🟡 | Rescans all merge commits per query (~2s today, O(n) scalability note) |
| `read_prompt` ambiguous match | 🟡 | Picks first on >1 prompt file match; bash side fails-closed; rare |
| Cross-agent breadth | 🟡 | 0 code; founder-gated (S26/S70) |
| `canonical_inputs_sha` is single-candidate | 🟡 | Can only verify current open session; historical re-verification requires Rust side |
| Ledger: tamper-evident not tamper-proof | 🟡 | `--ledger-verify` opt-in, not in mandatory closeout run |

---

## Backlog (parked — not yet scheduled)

Priority order within each tier:

**High (near-term picks):**
- 🔴 **S91 (picked):** fix S89 Reviewer hash mismatch + add `--dogfood-age` live query
- 🔴 **Dogfood refresh** — measure the full 8-station pipeline live against a real task; overdue since S76 (2026-07-18)
- 🟡 **Compression: `cargo`/`npm`/`pytest` exit-code fold gap** (S33/S41) — `exit_code == Some(0)` path; real CC never sends it; those 3 still won't fold typical output
- 🟡 **Guard nested-repo blindspot** (S52) — session-guard / copilot-loader can't distinguish Vajra's `session-NN` branches from a subject repo's own

**Medium (known gaps, lower blast radius):**
- `full_historical_scan` pass bar → strict zero-regression assertion (S88 reviewer note)
- `--ledger-verify` added to mandatory closeout run (currently opt-in)
- Budget cap reconsider (S36) — per-session vs cumulative; kill-mode; cap never fired live
- Silent-parse-failure blindness (S36) — compression hook fails open with no signal on parse failure
- `canonical_inputs_sha` / `--attest-only` single-candidate limitation — historical re-verification is Rust's job

**Parked (owner-gated or low-priority):**
- Cross-agent (2nd agent) — moat-proving; returns when founder declares Claude experience satisfying
- North-star breadth indicator (S25 meta-finding) — RED until ≥2 agents
- Crates.io name taken — install path is `cargo install --path` or crate rename
- Trace-mine missing `⚡on` advisories (S49-C) — look-only detector proposing new copilot rules
- `vajra bench` — codify the A/B value-gap harness into a repeatable script (S52 candidate B)
- Canned workflow patterns, additional agents, policy enforcement, governed memory — after core loop proven and users exist

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
2. `NN % 5 == 0` → mandatory NO-CODE GT. Next = **S90**.
3. Mark items done only when they work in a real session, not just tests.
4. Never exceed 7 top-level commands without explicit user approval.
5. Per-session detail goes in `sessions/session-NN-summary.md`, not here.
