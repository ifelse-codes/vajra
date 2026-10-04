# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions. S184 is closed on `session-184-rudra-s17-new-rules` (PR open; the founder merges). S183 merged (#220). Next: S185 — the ground truth (NO-CODE), F113 and F110 first (founder's pick; `prompts/185-task-ground-truth.md`).**

## What was done this session (S184 — INTERACTIVE: rudra S17 under the new rules, plus F103 / F107 / F108)

- **F103:** `vajra init` on a non-terminal stdin reads answers through one shared thread; each waits at most 10 s; the first silence or end of input gives that question and every later one its default, named on stderr; a late line is dropped. A terminal is read exactly as before. Design in the brief's `## Design` (DECISION-007 S134 addendum cited; no new record).
- **F107:** the unchecked-`obeyed:` warning names no Vajra session number and says "does not block on them in this session". Behaviour unchanged. **F108:** `--ledger`/`--ledger-verify` leave no empty dated folder (both close scripts).
- **From rudra S17 (founder ran it):** GREEN with 2 honest WARN (lint, unchecked claims), 0 WAIVED, 8/8 stations for the first time, 1 false guard block. Founder calls: F109 (agent's early download), F111 (rudra lint fails), F112 (slow verify) are rudra's own; F110 (guard false block, hit 3×) and F113 (a project's session 132 starts blocking) → S185, then fixed; Vajra's close does not run `cargo test`.
- Verify 14/14 · demo 7/7 · all cargo test suites · ci-lint clean.

## Previous session (S183 — INTERACTIVE: rudra S16 under the new rules, and F101)

- One pinned toolchain + one lint script for CI and the close (F101); main's red CI fixed (F102); unchecked `obeyed:` claims WARN with the count (F104); session type named at the start (F105); no empty `--inputs-sha` folder (F106). Merged #220.

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
- **`vajra init` never hangs on a silent pipe (S184, F103):** 10 s per answer, then defaults, named on stderr; piped answers and a terminal work as before.
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
- **🔴 F113 (S184, founder: an issue — fix after S185):** the obeyed threshold (`OBEYED_JUDGMENT_FROM_SESSION = 132`) counts a PROJECT's sessions in Vajra's numbering, so a project's own session 132 starts BLOCKING unchecked `obeyed:` claims, against the 2026-10-03 "not a blocking gate for projects". The warning now says "in this session" so it promises nothing more. The design-advisor threshold has the same units (DECISION-007 S134 addendum).
- **🟡 F110 (S184, founder: fix — S185 list):** the approvals guard false-blocks a command whose TEXT names the approvals folder next to a redirect (a heredoc, a `<…>` in a commit sign-off) — hit 3× on 2026-10-04. Workaround: put the text in a file, or `git commit -F`.
- **🟡 S184 disclosed:** F103's 10 s is a guess (a feeder slower than 10 s per answer gets defaults, printed); `scripts/verify-session-132.sh` `advance-really-binds-on-an-unjudged-obeyed` is red at e1c348e and after — not caused by S184, not yet explained (F115 → S185).
- **🟡 F114 (S184 cold review, founder: fix later → S185 list):** in a fresh `vajra init` project with no review files, `scripts/verify-closeout.sh --ledger` prints nothing and exits 1 — a first-run defect, old.
- **🟡 S183 disclosed:** F104 is a WARN, not a block — below session 132 a project's `obeyed:` still needs nobody's check. `lint_command: true`/`none` passes (only the diff shows it); "matches CI" = matches the pinned version; `#[allow]` silences a lint. Release's `rustup toolchain install && rustup target add` runs only on a tag — not tried. A Rust bump is now a deliberate edit to `rust-toolchain.toml` (and a local `rustup toolchain install`).
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S184 closed on its branch; PR open (founder merges). S185 drafted from the founder's pick; he approves with `vajra approve 185`.

## Active PRs

- S184's PR (open). S183 merged as #220, S182 as #219.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S184 | $0 | No paid run in this repo; the founder's rudra S17 receipt read ~$110.63 (F67-overstated ~5×). 4 fleet dispatches (tech-lead, design-advisor, plan-advisor, fidelity-reviewer) |
| S183 | $0 | No paid run in this repo; the founder's rudra S16 receipt read ~$83.54 (F67-overstated ~5×; ~55 min of work). 7 fleet dispatches (tech-lead, design-advisor, plan-advisor, fidelity-reviewer ×2, release-coordinator as the judge of the reviewer's recs) |
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
