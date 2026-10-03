# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions. S183 is closed on `session-183-rudra-s16-new-rules` (PR #220; the founder merges). S182 merged (#219). Next: S184 — rudra S17 under the new rules + F103/F107/F108 (founder's pick A; `prompts/184-task-rudra-s17-new-rules.md`).**

## What was done this session (S183 — INTERACTIVE: rudra S16 under the new rules, and F101)

- **F101 — the close runs CI's lint on CI's Rust version (not CI's tests, not Linux).** `rust-toolchain.toml` pins Rust 1.99.0, the only place the version is written; CI and Release run `rustup toolchain install` from it. `scripts/ci-lint.sh` is the one lint command: it names rustc/clippy, FAILS when the running rustc is not the pinned one, then runs `cargo clippy --all-targets -- -D warnings`. CI runs it; Vajra's close gate runs it as `cargo-clippy-clean`. A project's close gate runs its declared `lint_command:` (`none` → N/A, missing → a WARN row). The two new rows (`project-lint-clean`, `obeyed-judgments`) show WARN/N/A as themselves; the scaffold's older log-only N/A/WARN paths still record PASS.
- **F102:** `main`'s CI had been red since #219 (S182's no-jq test assumed `/bin` lacks jq; on Linux `/bin` = `/usr/bin`). The test now builds a PATH with every tool but jq and proves jq is gone. PR #220's CI is green on Ubuntu and macOS.
- **From rudra S16 (founder ran it, ~55 min of work):** approval read from the record, 0 guard blocks, no waivers, no stamp refusals, the founder merged. **F104:** 34 unchecked `obeyed:` claims closed under PASS (threshold = Vajra's session 132) → `vajra next --check-obeyed` prints `unjudged: N`, the project gate shows WARN with the count. **F105:** `session_type:` met only at close → `vajra next --steps` names it at the start, read through the shared helper. **F106:** `--inputs-sha` no longer leaves an empty close folder.
- **Asked, not built:** F103, F107, F108 (founder: fix all three in S184). Verify 24/24 · demo 6/6 · all 19 test suites · DECISION-011 S183 addendum.

## Previous session (S182 — CODE, interactive: ship S181's controls into existing projects)

- One approvals guard (writes block, reads pass) shipped to every scaffold and wired by `--sync-fleet`; a missing `session_rules_from` reported, never written; `--allow-all=NN`; S181's two test gaps closed; rudra upgraded live. Pass 2 ACCEPT 14/15. Merged #219 — whose own CI was red (F102, fixed in S183).

## S180 (NO-CODE ground truth, 🟡 PARTIAL)

- `sessions/session-180-ground-truth.md`. Founder rulings: release/reach not a problem yet; cadence must be smart (S181 Part 2); approvals must be un-typeable by the agent (S181 Parts 3–5); other tools one at a time later. `--dogfood-age` is blind to rudra runs. No code changed.

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
- **The controls reach existing projects (S182):** `--sync-fleet` ships and WIRES the approvals guard, reports a missing `session_rules_from`; `--allow-all=NN` is per session. rudra has them (uncommitted there).
- **The founder's controls are hard for the agent to type (S181, DECISION-011):** approval is a record from `vajra approve NN` (or the launch-time yes), a waiver names its checks and a reason, a stamp dies when its text is edited, the type is a strict field, and the next review-only session is derived, not hand-kept. Bar-raising, not tamper-proof.
- **The close runs CI's lint on CI's Rust version (S183, F101; not CI's tests, not Linux):** one pinned toolchain (`rust-toolchain.toml`) and one lint script (`scripts/ci-lint.sh`) for CI and the close gate; projects declare `lint_command:`. Unchecked `obeyed:` claims in a project WARN with the count (F104); `vajra next --steps` names the session type at the start (F105).
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
- **🟡 S181/S182 disclosed (DECISION-011):** all bar-raising, not tamper-proof — the agent can strip the mark, fake a terminal, or re-record its own text through `vajra next --role`; `--allow-all=NN` relies on pid liveness. The approvals guard reads command TEXT: a run-time path, a glob, `..` segments (`.ai/hooks/../approvals/x`), or an unlisted write command (`find -delete`, `git checkout --`, `rsync`, `curl -o`) gets past; it over-blocks a command naming the folder that redirects anywhere, and commit-message text naming it. `merge_claude_settings` still appends a whole template group when it is partly present with no same-matcher group (`src/cli/init.rs:980`). These three S182 pass-2 recs are PARKED for the S185 ground truth (ROADMAP S182 row). `scripts/verify-session-175.sh` has 2 stale checks superseded by S181 Part 2 (left as history).
- **🟡 `.ai/ROADMAP.md`'s "NN % 5 == 0 → mandatory NO-CODE GT" pointer line had gone stale for many cycles** (last hand-updated at S120/S125, corrected at S175 to S170/S180) — a reminder that a hand-maintained "next X" pointer drifts unless something derives it.
- **🟡 F97 (S179):** `vajra init --sync-fleet` never touches a project's `CONSTRAINTS.yaml`, so existing projects keep the old ground-truth list (rudra updated by hand). Other subcommands still swallow unknown flags (read-only).
- **🔴 Non-Claude agents (S179, PARKED until after S180 by the founder):** F91 the git guards cannot tell OpenCode's agent from the founder (37 unchecked commits, a push straight to rudra's main) · F94 one chat for two sessions · F95 OpenCode helpers matched to unrelated Claude Code records. F92 (a waiver labelled "founder" he did not give; the waiver passes ~20 checks at once) → S180 Goal 0.
- **🟡 S183 asked, not built (founder 2026-10-03: fix all three in S184):** F103 `vajra init` waits forever on an open, silent, non-terminal stdin (piped answers are a supported use, so "no terminal → defaults" is not the fix); F107 the obeyed WARN text tells a project "threshold: session 132" (Vajra's numbering); F108 `--ledger`/`--ledger-verify` leave an empty dated close folder.
- **🟡 S183 disclosed:** F104 is a WARN, not a block — below session 132 a project's `obeyed:` still needs nobody's check. `lint_command: true`/`none` passes (only the diff shows it); "matches CI" = matches the pinned version; `#[allow]` silences a lint. Release's `rustup toolchain install && rustup target add` runs only on a tag — not tried. A Rust bump is now a deliberate edit to `rust-toolchain.toml` (and a local `rustup toolchain install`).
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S183 closed on its branch; PR #220 open (founder merges). S184 drafted from the founder's pick (A); he approves with `vajra approve 184`.

## Active PRs

- #220 (S183). S182 merged as #219, S181 as #218.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S183 | $0 | No paid run in this repo; the founder's rudra S16 receipt read ~$83.54 (F67-overstated ~5×; ~55 min of work). 4 fleet dispatches (tech-lead, design-advisor, plan-advisor, fidelity-reviewer) |
| S182 | $0 | No paid run. 5 fleet dispatches (tech-lead, design-advisor, plan-advisor, fidelity-reviewer ×2) |
| S181 | $0 | No paid run. 4 fleet dispatches (tech-lead, design-advisor, fidelity-reviewer ×2) |
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
