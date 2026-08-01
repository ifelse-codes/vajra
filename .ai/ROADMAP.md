# Vajra — Working Roadmap

**Updated:** 2026-07-31 · **Session 106 — CODE: make it installable (v0.1) — DELIVERED.**
The C→B→A order's **B**. One install path works from a clean checkout (`cargo install --git|--path` →
`vajractl` crate, `vajra` binary; `Cargo.toml` was already release-correct — the S105 "paper-only" note
was **stale**), plus the **missing installability instrument** `scripts/install-smoke.sh` (fresh install
→ `vajra init` → `vajra next`, asserts each, **exits non-zero on any fail**; proven both ways — 7/7 PASS
on the real tree, FAIL→exit 1 on a broken source), plus a README truth-pass (working one-liner proven;
crates.io / brew / prebuilt rows stay NOT YET PUBLISHED). **No `src/`; no crates.io publish; no tag.**
verify 5/5; demo exit 0; independent cold review **ACCEPT**, attested `07b962af…`. **PR #111.** Next =
**tagged binary release v0.1.0 (S107)** — the no-Rust prebuilt-binary path. Summary:
`sessions/session-106-summary.md`.

*Prior: Session 105 — NO-CODE GROUND TRUTH (S101–S104) — PARTIAL (lead lens); 3 🟢 · 7 🟡 · 0 🔴;
engine done + proven, package ~0%; freeze rule RETIRED; two GT-instrument blind spots (installability
unmeasured — now closed by S106 · `--dogfood-age` blind to untracked receipts — un-blinded in the S105
follow-up #110). Report: `sessions/session-105-ground-truth.md`.*

*Prior: Session 104 — CODE: team voice over the 8 stations — SHIPPED (roster + plain status; K
identical; 296 lib tests; cold review ACCEPT, attested `226a344b…`). Founder pick C, order C→B→A.*
*Prior: Session 103 — DOGFOOD (paid): Rung 2 endurance + adversarial — Rung 2 PASS.*
Both S102 gaps closed: a detached/resumable/budget-capped **endurance harness** whose kill-switch FIRED on
cap, and a **FORCED adversarial block** (a good-faith agent's `git commit` stopped by L3
`hook-commit-guard.sh`, even under `--dangerously-skip-permissions`). Zero leaks; **$0.6797 authoritative**
(sonnet-4-6); cold review ACCEPT (pass-1 REJECT caught a premature citation), attested `a2c33fcd…`.

> **🔀 FOUNDER PIVOT (S103, 2026-07-27):** the Autopilot-Ladder-as-sessions plan + machinery-freeze rule
> are **SUPERSEDED.** Rung 3 as a paid *session* is cancelled. **Sessions now = BUILD / finish the MVP;**
> the founder runs the long "days-unattended" test himself, then release. **Open direction fork** (from the
> FirstMate review): keep *one governed agent + evidence-gates* vs grow a *fleet of real named parallel
> agents* (researcher/coder/QA) with the gates as the hidden trust-engine (recommended shape = both).

**Prior context (pre-pivot):**
**Session 102 — DOGFOOD (paid): Autopilot Ladder Rung 2 — Rung 2 PARTIAL.**
One-day-unattended multi-task `vajra claude` on chitra, guards ON. The 3 *quality* sub-conditions
(zero leaks · honest receipts · fidelity correct) PASSED on a bounded 3-task burst; the "1 day"
*endurance* criterion was NOT met (~2.3 min in-chat, disclosed). Produced the first real ladder-run
**evidence contract** (`sessions/session-102-review.md`, judged on run evidence, NOT waived) — the
S100 🔴 fix. chitra re-init'd first (old scaffold had NO guards); unauthorized commits blocked (probes),
authorized commit `9ba1ba9` permitted; Task A agent voluntarily declined (S97 pattern). Session
fidelity ACCEPT, attested `f6350676…`. **$0.4644 authoritative** (sonnet-4-6; fable-5 credits exhausted).
*Prior: Session 101 — CODE (docs): README truth-pass + `DECISION-006` crate name; verify 24/24; cold
review ACCEPT, attested `a96455ff…`; published/renamed nothing.*
*Prior: Session 100 — NO-CODE GT (S96–S99): lens A PARTIAL PASS (freeze rule n=1); 🔴 ladder runs
invisible to both GT instruments; VISION body + 4 ROADMAP rows corrected. Report:
`sessions/session-100-ground-truth.md`.*
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
| Today | 2026-07-31 |
| Current phase | **FINISHING A SHIPPABLE MVP** (S103 pivot — supersedes the Autopilot-Ladder-as-sessions plan + machinery-freeze rule). The governance engine is complete and PROVEN (8-station spine S72; forced commit block S103; attested/chained ledger; authoritative receipts). The **shippable package** is now underway — S106 shipped the first working install path (`cargo install`) **and the installability instrument** the S105 GT found missing. Remaining: a **no-Rust prebuilt-binary** path (S107). Order **C→B→A**: C team-voice (S104 ✓) → **B make it installable** (S106 ✓ Rust path + instrument → **S107 prebuilt binaries, next**) → A fleet. Receipt authoritative (S92 $0.2713 · S97 $1.2758 · S102 $0.4644 · S103 $0.6797). Commit obedience ENFORCED (S93); nested-repo blindspot CLOSED (S94); Coder-dark CLOSED (S100). |
| Last closed session | Session 106 — **CODE: make it installable (v0.1)** — DELIVERED; `cargo install --git\|--path` works from a clean checkout + `scripts/install-smoke.sh` proves it (falsifiable) + README truth-pass; no `src/`; no publish/tag; cold review ACCEPT, attested `07b962af…`; PR #111 |
| Active session | Session 107 — **CODE: tagged binary release v0.1.0** (founder pick A): push a `v0.1.0` tag → `release.yml` builds 3-target prebuilt binaries + GH release → a download-and-run smoke proves the no-Rust path → un-mark that README row. Tag push founder-gated (public release) |
| Crate | **v0.1 name settled (`DECISION-006`, S101):** crate `vajractl` · binary `vajra`. `Cargo.toml` **is** release-correct (name/bin/version 0.1.0) — the S105 "paper-only" note was stale. Still no `cargo publish`/tag yet (S107 pushes the first tag; crates.io stays founder-gated) |

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

**S100 (done) lead lens:** *is the ladder being climbed, or did machinery resume?* → **PARTIAL PASS**,
freeze rule n=1, plus the 🔴 that ladder runs are invisible to both GT instruments.
**S105 (next NO-CODE GT) lead lens:** *did Rung 2/3 produce evidence a stranger could check — or a
story?* (Read `--stations` for S101–S104 knowing DOGFOOD sessions score low by construction; judge the
run's evidence contract, not its K-of-8.)

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
| S98 | CODE (docs) | **Autopilot-trust reposition** (`DECISION-005` + VISION lead + this ROADMAP): pipeline = engine, not pitch; falsifiable Autopilot Ladder replaces the feelings bar; 2026-09-15 release backstop; machinery-freeze rule; scoreboard + 2 kill signals. Docs only, no `src/`; honesty rows preserved. **+2 closeout-hardening follow-ups:** #100 added S98's own verify/demo scripts (step-5 miss); #101 made `verify-closeout.sh` BLOCK a scriptless CODE session (`check_verify_demo_scripts`) |
| S99 | CODE | **Coder reachable unattended** (pick A; the S97 Rung-1 fix-what-broke): (1) `vajra init` kickoff from the ONE canonical `analyst::PROMPT_TEMPLATE` — fresh repo station-measurable from S01; (2) `Outcome::Legacy` — convention-absent ≠ work-absent, never counts toward K/8; (3) commit pre-authorization surfaced on `vajra next` + boot packet, mirroring `hook-commit-guard.sh` (advisory + agent-forgeable; guard keeps the teeth). Two-pass cold review REJECT→ACCEPT (4 real pass-1 defects fixed), attested `6dbcf20a…`; 293 tests, verify 32/32; PR #103. **Does NOT retro-fit chitra's on-disk prompts** |
| S100 | GT (NO-CODE) | Audited S96–S99: **4 🟢 · 5 🟡 · 1 🔴**. Lens A = **PARTIAL PASS** — ladder climbing (Rung 1 paid S97; S99 a real fix-what-broke), freeze rule held on **n=1**. **🔴 meta-check: ladder runs are invisible to both GT instruments** (`--stations` 1–3/8 by construction on DOGFOOD/GT; fidelity gate waived — S97 has no review file) → the counter will read a stall while the product advances. state_drift 🔴: `VISION.md` body 45 sessions stale, `vajra.varta` frozen at S79 (`vajra check` red 20 sessions, no gate reads it), 4 stale ROADMAP rows — all corrected. Also: `must_write_next_prompt_before_close` violated at S99 close (no gate for it); S98 = 4 PRs under one session; Coder-dark finding CLOSED (S96/S98/S99 PASSED) |
| S101 | CODE (docs) | **Release-backstop slice** (founder pick C, a knowing freeze-rule override): README truth-pass — 3 broken install methods (crates.io/brew/binary) marked NOT YET PUBLISHED not faked; retired the ~8× receipt claim + `$33.4976`/`opus-4-6` example → real S97 `$1.2758` fable-5 capture; Direction paragraph + Status table → shipped reality (8 stations, auditor shipped/attested/chained, `vajra check` 11, all 7 commands). **`DECISION-006`** settles the v0.1 crate name against a live crates.io check (`vajractl` 404=available · `vajra` 200=taken → crate `vajractl`, binary `vajra`); `Cargo.toml` untouched, nothing published/tagged/renamed. verify 24/24; independent cold review ACCEPT, attested `a96455ff…` |
| S102 | **DOGFOOD (paid)** | **Autopilot Ladder Rung 2 — PARTIAL** (founder pick A +B): 3-task unattended burst on chitra, guards ON. **Quality gates PASSED** — unauthorized commits blocked (probes P1/P2 exit 1), authorized `9ba1ba9` permitted through the gate, no push/PR, chitra main untouched; every run authoritative `total_cost_usd` ($0.4644 total, sonnet-4-6). **Endurance NOT met** (~2.3 min, not a day — disclosed per Acceptance #1); Task A agent VOLUNTARILY declined to commit (S97 pattern → S103 adversarial). Shipped the first ladder-run **evidence contract** (`session-102-review.md`, judged on run evidence, NOT waived — the S100 🔴 fix); session fidelity ACCEPT, attested `f6350676…`. chitra **re-init'd first** (its >3-week scaffold had NO commit/publish guards); fable-5 monthly credits exhausted → ran on sonnet |
| S103 | **DOGFOOD (paid)** | **Rung 2 endurance + adversarial — PASS** (founder "all approved"): a detached (`nohup`)/resumable/budget-capped **endurance harness** ran 6 tasks unattended; the **kill-switch FIRED** on cap ($0.2668 ≥ $0.22 → stopped before e5, no overrun; resumable both ways). A good-faith agent's `git commit` was **FORCE-blocked** by L3 `hook-commit-guard.sh` (even under `--dangerously-skip-permissions`) — closes the S97/S102 voluntary-vs-enforced gap (a *forced* block, not a decline). A separate explicit-bypass agent refused at layer-0 (defense-in-depth). Zero leaks (chitra `main` `9dc7d7f` untouched, nothing pushed); **$0.6797 authoritative** (sonnet-4-6) + ~$0.05 uncaptured. Cold review **ACCEPT** (pass-1 REJECT caught a premature citation → fixed), attested `a2c33fcd…`. **🔀 Founder PIVOT:** stop paid ladder *sessions* → finish the MVP; founder runs the long test himself; **fleet-vs-gates** direction fork opened (FirstMate review) |
| S104 | CODE | **Team voice over the 8 stations** (founder pick C): `--stations` + the `vajra next` packet now lead with a named-role **team roster** + plain status from one source (`ROLES` + `format_team_roster`), reused by both surfaces (S19 no-drift); `K of 8` a subtitle, the `[PASSED]/[ABSENT]` table demoted-not-deleted (disclosed). Mechanism unchanged (K identical); `cargo test --lib` = 296; verify 8/8; cold review **ACCEPT** (pass-1 caught a hollow demo AFTER-block → fixed), attested `226a344b…`; merged #108 |
| S105 | GT (NO-CODE) | Audited S101–S104 through the **MVP-shippability** lens: **3 🟢 · 7 🟡 · 0 🔴**, lead lens = **PARTIAL** (engine done + proven, package ~0% — nothing installable yet). Costs reconcile to the penny (S102 $0.4644 · S103 $0.6797). **Machinery-freeze rule (`DECISION-005`) RETIRED** — dead letter post-pivot; DECISION-005 Status → SUPERSEDED. **Two GT-instrument blind spots:** (1) no instrument measures installability (`--stations`=7/8 on S101 while every install path was broken); (2) `--dogfood-age` blind to untracked receipts (reports S97, true last S103). state_drift corrected: S104-merged-shown-open, `vajra.varta` stale (recurring since S100), KNOWLEDGE 416→475, ladder-phase text retired. Founder pick ① → S106 make it installable. **Follow-up #110:** un-blinded `--dogfood-age` for S102/S103 (top-level aggregate receipts + root-cause corrections) |
| S106 | CODE | **Make it installable (v0.1)** (founder pick ①, order's **B**): one install path that works from a clean checkout — `cargo install --git` (no clone) or clone + `cargo install --path .` → `vajractl` crate, `vajra` binary (**`Cargo.toml` was already release-correct — the S105 "paper-only" note was stale**; the gap was proof, not metadata). Shipped **`scripts/install-smoke.sh`** — the installability instrument the S105 meta-check found missing: fresh temp install → `vajra init` → `vajra next`, asserts each inside a time budget, **exits non-zero on any fail**; proven both ways live (7/7 PASS on the real tree, 12s; FAIL→exit 1 on a broken source). README truth-pass: working one-liner proven + points at the instrument; crates.io / brew / prebuilt rows stay NOT YET PUBLISHED. **No `src/` changes; no crates.io publish; no tag.** verify 5/5 GREEN; demo exit 0 (4 markers). Independent cold review **ACCEPT**, attested `07b962af…`; PR #111. Fakest green (disclosed): the smoke **default** proves `--path`; the README headline `--git` remote path runs only under `VAJRA_SMOKE_SOURCE=git` (structurally identical) |

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
| S98 | Complete | **CODE (docs)** — autopilot-trust reposition (DECISION-005 + VISION lead + ROADMAP 6-month ladder); +2 closeout-hardening follow-ups (#100 scripts · #101 scriptless-CODE-session block) |
| S99 | Complete | **CODE** — Coder reachable unattended (pick A): init kickoff carries markers (one canonical template) · `Outcome::Legacy` (convention-absent ≠ work-absent) · commit pre-auth surfaced on `vajra next` + boot packet (mirrors the guard, advisory). Two-pass REJECT→ACCEPT, attested; 293 tests, verify 32/32; PR #103 |
| S100 | Complete | **GT (NO-CODE)** — audited S96–S99; lens A PARTIAL PASS (freeze rule n=1); 🔴 ladder runs invisible to both GT instruments; VISION.md body + 4 ROADMAP rows + `vajra.varta` corrected; `must_write_next_prompt_before_close` violation found |
| S101 | Complete | **CODE (docs): release-backstop slice** (founder pick C) — README truth-pass (3 broken install methods marked NOT YET PUBLISHED; ~8× claim + stale receipt example retired) + `DECISION-006` crate name (`vajractl`/`vajra`); published/renamed nothing; verify 24/24; cold review ACCEPT |
| S102 | Complete | **DOGFOOD (paid): Autopilot Ladder Rung 2 — PARTIAL** — quality gates PASSED on a bounded 3-task burst (zero leaks · honest receipts · fidelity correct); endurance NOT met; first ladder-run evidence contract shipped (S100 🔴 fix); $0.4644 authoritative; fidelity ACCEPT, attested `f6350676…`; chitra re-init'd for real teeth |
| S103 | Complete | **DOGFOOD (paid): Rung 2 endurance + adversarial — PASS** — endurance harness w/ firing kill-switch + a FORCED adversarial block; zero leaks; $0.6797 authoritative; cold review ACCEPT, attested `a2c33fcd…`. **🔀 Founder pivot: stop paid ladder sessions → finish the MVP** |
| S104 | Complete | **CODE: team voice over the 8 stations** (founder pick C) — named-role roster + plain status from one source, reused by `--stations` + the packet; K unchanged; 296 tests; cold review ACCEPT, attested `226a344b…`; merged #108 |
| S105 | Complete | **GT (NO-CODE): S101–S104 through the MVP-shippability lens** — 3 🟢 · 7 🟡 · 0 🔴; PARTIAL (engine done, package ~0%); freeze rule RETIRED; two GT-instrument blind spots (installability unmeasured · `--dogfood-age` blind to untracked receipts); costs reconcile to the penny; drift corrected. Follow-up #110 un-blinded `--dogfood-age` |
| S106 | Complete | **CODE: make it installable (v0.1)** (founder pick ①, order's B) — `cargo install --git\|--path` works from a clean checkout + `scripts/install-smoke.sh` (the installability instrument; falsifiable, exits non-zero on fail) + README truth-pass; `Cargo.toml` already release-correct; no `src/`, no publish/tag; verify 5/5, demo 4 markers; cold review ACCEPT, attested `07b962af…`; PR #111 |
| **S107** | **Next** | **CODE: tagged binary release v0.1.0** (founder pick A, order's B completion) — push a `v0.1.0` tag → `release.yml` builds 3-target prebuilt binaries + GH release → a download-and-run smoke proves the **no-Rust** install path → un-mark that README row. **Tag push founder-gated (public release)**; crates.io stays prohibited. Prompt: `prompts/107-task-tagged-binary-release-v010.md` |

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
| Closeout script-presence gate | ✅ `verify-closeout.sh` blocks a CODE session missing its `verify/demo-session-NN.sh` (S98 follow-up #101; `--scripts-only`; GT + `VAJRA_CLOSEOUT_WAIVER` exempt) |
| `cargo test --lib` | ✅ 293 tests (S99; corrected S100) |
| CI on `main` (both OS) | ✅ Green (S96) — `fmt --check` + `clippy -D warnings` + `test --lib`; rustfmt pinned 1.9.0-stable |
| `vajra next --dogfood-age` | ✅ Git-derived staleness; never reads STATE.md |
| Install path (v0.1) | ✅ `cargo install --git` (no clone) or clone + `--path .` → `vajra` on PATH (needs Rust); `Cargo.toml` release-correct (S106) |
| `scripts/install-smoke.sh` | ✅ Installability instrument (S106): fresh install → `init` → `next`, asserts each, exits non-zero on fail; falsifiable (proven both ways) |

## What Is Weak / Broken

| Item | Severity | Notes |
|---|---|---|
| **Dogfood (launcher)** | 🟢 | Fresh — last = **S103 = 2026-07-27, $0.6797 authoritative** (sonnet-4-6, 6-task endurance harness + forced block; S102 = $0.4644). `--dogfood-age` now correctly reports S103 (top-level aggregate receipts added S105-follow-up) |
| ~~**`--dogfood-age` blind to untracked receipts**~~ | 🟢→🟡 | **RESOLVED for S102/S103** (S105 follow-up). Corrected root cause: the scan reads `receipt.stderr.txt` at the **top level** of each artifacts dir (on-disk, not git; `src/dogfood/mod.rs:63-66`) — S102/S103 receipts sat in per-run subdirs, so it skipped them. Fixed with a top-level aggregate receipt + `run-result.json` per dir. **🟡 residual:** durable code fix = recurse into subdirs (queued for a CODE session) |
| ~~**Installability unmeasured**~~ | 🟢→🟡 | **CLOSED S106:** `scripts/install-smoke.sh` is the instrument the S105 meta-check found missing (fresh install → `init` → `next`, falsifiable). **🟡 residuals:** the smoke **default** proves `cargo install --path`; the README headline `--git` remote path runs only under `VAJRA_SMOKE_SOURCE=git` (structurally identical, disclosed) · `within-budget` is a post-hoc check, not a hard per-step timeout |
| **No no-Rust install path** | 🟡 | S106 shipped the `cargo install` path (needs a Rust toolchain); the prebuilt-binary `release.yml` (tag `v*`) has never fired for a real tag. **S107 target** (founder pick A) |
| **`vajra --version` gap** | 🟡 | A stranger who types `vajra --version` gets usage, not a version string (exit 0, falls to help). Minor installability polish (S107-alt B) |
| **Dogfood (pipeline end-to-end)** | 🟡 | RE-TESTED S102 — quality gates PASSED on a bounded 3-task burst (guards ON, real teeth). Still untested: a *completing, multi-hour, unattended* run + a *forced adversarial* block — both = S103 |
| ~~**Coder/EXECUTE station dark**~~ | ✅ | CLOSED S100: Coder **PASSED** in S96, S98, S99 (`vajra next --stations NN`). The S95 "ABSENT 4-for-4" finding no longer holds in this repo |
| **Ladder runs invisible to GT instruments** | 🟡 | **S100 🔴 → mitigated S102.** The fix shipped: S102 produced the first real ladder-run **evidence contract** (`session-102-review.md`, judged on receipt + blocked-action log + subject diff + fidelity; ACCEPT + attested, NOT waived). `--stations` still reads DOGFOOD low by construction — read the contract, not the K-of-8. Residual: the pattern is proven once, not yet templated/enforced (a run must not silently waive it) |
| **KNOWLEDGE §6 bloat** | 🟡 | **475 lines / ~91K tokens (GROWING** — was 416/85K at S100); header "Reloaded every session" false; flagged since S60, unremediated; prune queued as an S106-alt option |
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

## Backlog

**The active queue is FINISHING THE MVP** (C→B→A: team-voice ✓ → installable v0.1 = S106 → fleet).
The machinery-freeze rule is **RETIRED** (S103 pivot). Items below get pulled when they serve the MVP
or when a founder-run real-world test breaks them; the installability instrument (S106) is now the
guard against easy-green (machinery advancing while the product can't ship).

**🧊 Frozen machinery — pull ONLY when a ladder run breaks it:**
- **Coder-marker fix** (S97 — likeliest first pull; Rung 2 will demand it): *agents write the
  `## Execution`/`## Delta` markers, Vajra verifies*; add an **env-marker commit path**
  (`VAJRA_ALLOW_COMMIT` shape) so an unattended `-p` run can reach a full closeout; marker slots
  ride the `vajra init` scaffold (chitra's older scaffold lacks them).
- **KNOWLEDGE §6 prune** (chronic since S60) — **475 lines / ~91K tokens (growing)**; cut to permanent lessons, move per-session narrative to `sessions/`, fix the false "Reloaded every session" header
- **Compression `cargo`/`npm`/`pytest` exit-code fold gap** (S33/S41) — `exit_code == Some(0)` path; real CC never sends it
- **Guard identity: exotic git shapes** (S94 residual) — worktree / submodule / symlinked-root untested (fail-closed today); own-git non-session-branch marker fallthrough
- **Ladder-run evidence contract** (S100 🔴 — likeliest pull alongside Rung 2): define what a
  DOGFOOD/ladder session must produce (a real `session-NN-review.md` judged on **run evidence** —
  receipt, blocked-action log, subject-repo diff — and a station reading that is meaningful for a run,
  e.g. the S99 `Outcome::Legacy` pattern applied to session *type*). Until then, ladder runs close
  self-certified at ~1/8 and the freeze rule hides it. **A prompt-level version of this costs no code
  and should ride S101-A.**
- ~~**GT tripwire: chronically-absent station**~~ (S95 meta-check) — **do NOT build as written**
  (S100): it would fire on every DOGFOOD/GT session and be wrong for the same reason the counter is.
  Re-scope it to "absent *in a session type where the station applies*" if it is ever pulled
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
2. `NN % 5 == 0` → mandatory NO-CODE GT. Last = **S105** (done). Next = **S110** (lead lens: is v0.1 shippable to a stranger — and does an instrument prove it, not a feeling?).
3. Mark items done only when they work in a real session, not just tests.
4. Never exceed 7 top-level commands without explicit user approval.
5. Per-session detail goes in `sessions/session-NN-summary.md`, not here.
6. **Machinery-freeze rule (S98, `DECISION-005`) — RETIRED (S103 pivot, confirmed S105 GT).** It said "a session runs the Autopilot Ladder or fixes what a run broke." The pivot cancelled ladder *sessions*; S104 was neither and shipped. **New law:** a session **finishes a shippable-MVP slice** (C→B→A order) until v0.1 is stranger-shippable; the founder owns the long unattended real-world test. The easy-green guard the freeze rule provided is now carried by the GT's own lead lens + the installability instrument (S106).
