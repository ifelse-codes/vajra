# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-179-keep-testing` — S179 complete on its branch; PR to open (the founder merges).**

## What was done this session (S179 - interactive, F89 + the founder's rudra sessions 14–15)

- **F89 fixed:** `vajra <cmd> --help`/`-h` prints that command's help and runs nothing (`init --help` wrote 11 files; rudra's agent hit `next --help` live). `claude` stays a pass-through.
- **F90 fixed:** `vajra init` refuses a word it does not know before writing anything (`init --dry-run` did a full setup).
- **F93 fixed (founder yes):** a project's ground truth leads with vision → roadmap → the new `delivery_progress`; `dogfood_check`/`dogfood_staleness` withheld from projects with declared reasons. rudra's copy updated by hand (uncommitted there).
- **rudra S14/S15 (OpenCode, one chat):** close runs ~30 → ~5 (S178's F86 note worked). Findings F91–F97; non-Claude ones parked until after S180 (founder); F92 → S180 Goal 0. S178's wrong record corrected (summary + PR #215 comment).
- Verify 37/37 · demo 6/6 · 551 lib tests · review: see `sessions/session-179-review.md`.

## Previous session (S178 - interactive, the founder's rudra sessions 10–13)

- F83/F86/F87 wording fixes; F77–F80, F84, F85 → S180 Goal 0. `sessions/session-178-summary.md`.

## What Currently Works

- The close gate refuses made-up evidence: prose/malformed/non-existent `done:` shas, unlanded plan steps, unbacked verdict claims, a CODE session with no tech-lead (S169).
- A demo that cannot be faked: command-backed checks, Vajra-filled numbers, gate re-derives facts at close (S168).
- Terminal demo deck for every Vajra project: `scripts/demo-kit.sh` + the seven-section template (S167).
- `vajra init --sync-fleet` upgrades fleet roles + hooks + constitution + close gate + demo template + kit.
- 10-role fleet, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`); 8 stations + closeout gate (19+ checks); tamper-evident ledger; receipts.
- **The ground-truth cadence is config-driven (S175):** `.ai/CONSTRAINTS.yaml#ground_truth_next_session` overrides the every-5th default in all 6 sites that read it; absent behaves byte-for-byte as before.
- **The scaffold close gate honours a moved ground truth and `**CODE.**` briefs (S177):** a project's CODE session gets its full close checks after the founder moves the next GT.
- **The Planner checks `covers: N` both ways (S176):** a plan citing acceptance items the brief lacks blocks; `| ACn |` tables are read.
- **`vajra <cmd> --help` runs nothing; `vajra init` refuses unknown words (S179, F89/F90).**
- **A project's ground truth leads with the project (S179, F93):** vision → roadmap → `delivery_progress`; Vajra's two self-usage audits are withheld from projects (`build.rs` `OMIT_AUDITS`).
- **`VAJRA_ALLOW_PUBLISH=1` no longer covers merge (S175):** `gh pr merge`/`glab mr merge` always fall to the founder, matching the boundary `VAJRA_ALLOW_COMMIT` (F55) already held.

## What Is Broken / Weak / Disclosed

- **🟡 Release 0.2.0 half done** — tag `v0.2.0` + GitHub release out; **crates.io still 0.1.0** (founder types `cargo publish`); brew tap formula is at 0.2.0 but install-smoke not run (ROADMAP `S168-release`). A stranger's `cargo install` gets none of S167–S175. Founder's own installed `vajra` is 0.2.0 (reinstalled for S174's fixes, 2026-09-22 — not yet rebuilt with S175's bash-only changes, which need no rebuild since nothing in `src/` moved).
- **🟡 S169 fakest green:** the claim match is words only; claimed-evidence proves files exist, not that they are real; a made-up `done:` sha is still waivable; `git cat-file -e` accepts any old commit → **parked — policing** (ROADMAP `S171-parked`).
- **🟢 F31 clean nine times (S171–S177, incl. rudra S07–S09).**
- **🔴 The backstop is gone (S172, disclosed):** a skipped `verify-closeout.sh` used to be caught at the next session's start; it is caught nowhere now. Running the close check on the branch before the merge is the whole enforcement story, and it is a text rule. DECISION-007 S172 addendum.
- **🟡 `shipped_close()` keys on one file** — landing a summary on main early downgrades the closing gates to reporting while a session is live (self-granted jurisdiction, disclosed).
- **🟡 F50/F44 — not fixed in code (S173, by decision):** a commit message that mentions a guarded command still blocks; the block names `git commit -F <file>` / `--body-file`.
- **🟡 F55's `cwd` assumption:** still unverified live — no rudra session has used a worktree yet (S06 didn't either).
- **🟡 The guards' old-vs-new check is a list (S173):** named shapes × triggers; a spelling nobody listed is not covered.
- **🟡 Parked LOW (S173):** F47 copied jargon · F56 the session guard cannot tell a command runs in another project · F57 the Coder check reads only `1. …` plan steps.
- **🔴 F67 (S176, PARKED by founder, 3rd time S177):** the receipt prices `claude-opus-5-5` at the unknown-model ceiling — rudra S07/S08/S09 read ~$48.68/~$62.71/~$118.69, ~5× over. Founder: no new price rows; fix permanently by reading the tool's own cost for interactive runs.
- **🟡 F70-residual (S176, disclosed):** nothing at close re-runs the Planner — a mid-session brief wipe is caught only when someone runs `--check-plan`/`--steps`/`--stations`; deleting the `covers:` markers or the whole `## Plan` still passes (S68 class). A close re-run needs the founder's yes.
- **🟡 S177 disclosed:** Vajra's OWN close gate still matches only `**CODE**` (own paperwork, not changed); `ground_truth_next_session` is agent-writable and unguarded (a key = N session loses its CODE checks); the key is read as the first digits on its line (LOW).
- **🟡 F75 (S177, LOW):** the design-advisor proposed a 4-file commit no agent can make (≤3-file hook); the plan-advisor overruled it.
- **🟡 F71 (S176, PARKED; recurred S177):** a GitHub-button merge leaves the remote session branch; the release check's `pruned` looks at locals only.
- **🟡 F73 (S176, LOW):** `1)`, `**1.**`, numeric tables, `- AC1:` are not read as criteria (a plan citing them now blocks with the right message); `covers:` u32 overflow is dropped.
- **🟡 F66 (S175, disclosed, not fixed):** `--check-crew`/`read_handoff` checks a handoff file's presence on disk, never that it's git-tracked — a session's required crew can close with real handoffs left uncommitted. Same bug family as F60 (Vajra's own sync files), different target. No new gate on Vajra's own paperwork without the founder's explicit yes (Guardrails).
- **🟡 `scripts/verify-closeout-scaffold.sh` (the `vajra init` template) does not carry the S175 cadence-config fix** — deliberate, disclosed (DECISION-007 S175 addendum): a new project has no reason to move its first ground truth on day one, and this file already lags the live gate on other counts (S154's execution-sha tightening, cargo-fmt).
- **🟡 `.ai/ROADMAP.md`'s "NN % 5 == 0 → mandatory NO-CODE GT" pointer line had gone stale for many cycles** (last hand-updated at S120/S125, corrected at S175 to S170/S180) — a reminder that a hand-maintained "next X" pointer drifts unless something derives it.
- **🟡 F97 (S179):** `vajra init --sync-fleet` never touches a project's `CONSTRAINTS.yaml`, so existing projects keep the old ground-truth list (rudra updated by hand). Other subcommands still swallow unknown flags (read-only).
- **🔴 Non-Claude agents (S179, PARKED until after S180 by the founder):** F91 the git guards cannot tell OpenCode's agent from the founder (37 unchecked commits, a push straight to rudra's main) · F94 one chat for two sessions · F95 OpenCode helpers matched to unrelated Claude Code records. F92 (a waiver labelled "founder" he did not give; the waiver passes ~20 checks at once) → S180 Goal 0.
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S179 closed on its branch; PR to open. S180 = ground truth, Goal 0 first (`prompts/180-task-ground-truth.md`).

## Active PRs

- S179's, once opened. S178 merged as #215.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S179 | $0 | No paid run in this repo; the founder's rudra S14/S15 ran under OpenCode ($1.93 by OpenCode, no Vajra receipt). 2 fleet dispatches (tech-lead, fidelity-reviewer — also the judge of the tech-lead's obeyed lines) |
| S178 | $0 | No paid run in this repo; the founder's rudra S10 (~$147) and S12 (~$161.45) receipts are F67-overstated ~5×; S11/S13 ran outside `vajra claude` (no receipt). 4 fleet dispatches (tech-lead, fidelity-reviewer ×2, release-coordinator as judge) |
| S177 | $0 | No paid run in this repo; the founder's rudra S09 run supplied the findings (its receipt ~$118.69 is F67-overstated ~5×). 3 fleet dispatches (tech-lead, fidelity-reviewer, release-coordinator as judge) |
| S176 | $0 | No paid run in this repo; the founder's rudra S07/S08 runs supplied the findings (their receipts ~$48.68/~$62.71 are F67-overstated ~5×). 5 fleet dispatches (tech-lead, design-advisor, qa-specialist, fidelity-reviewer, release-coordinator as judge) |
| S175 | $0 | No paid run in this repo; the founder's own rudra run supplied the findings. 4 fleet dispatches (tech-lead, qa-specialist, fidelity-reviewer, release-coordinator as judge) |
| S174 | $0 | No paid run; the founder's own rudra run supplied the findings. |
| S173 | $0 | No paid run; the founder's own rudra run supplied the findings. 11 fleet dispatches (tech-lead, design-advisor, 9 fidelity-reviewer passes) |
| S172 | $0 | No paid run; the founder's own rudra run supplied the findings. 4 fleet dispatches (tech-lead, qa-specialist, design-advisor, fidelity-reviewer) |
| S169 | $0 | No paid run; bash gate + scripts + fleet subagents only |
| S168 | $0 | No paid run; code + scripts + fleet subagents only |
| S167 | $0 | No paid run; code + scripts + fleet subagents only |
| S166 | $0 | No paid run; bash scripting + verify + demo scripts only |
| S161 (Part 2 — D2 dogfood) | null | `total_cost_usd` not in JSONL; token estimate ~$14.15 (not authoritative) |

## Direction (governance is the product)

- **Product = provable agent governance** (`DECISION-001`). Direction (2026-09-15): **no more policing — reach a real user.** Founder tests Vajra himself; sessions are interactive from S171.
- **Founder priorities (S140/S160):** (1) fresh-user experience + release; (2) prove it works, then cut cost; (3) self-driving unattended close / Rung 2–3; (4) external adoption.
