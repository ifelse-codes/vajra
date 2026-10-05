# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions. S187 (CODE: the guard message and the S190 leftovers) is closed on `session-187-guard-message-and-leftovers` (PR open; the founder merges — a merge commit, not a squash). S186 merged (#223). Next: S188 — the founder's pick from `sessions/session-187-summary.md`; rudra S18 waits for rudra's data API.**

## What was done this session (S187 — CODE: the guard message and the S190 leftovers)

- **Rewritten with the founder at the start:** rudra S18 waits for rudra's data API, so S187 became the guard fix (founder pick C — a clearer message, what blocks unchanged; A = Claude Code's own sandbox locking the folder was found and offered, recorded for S190) + every S185 leftover. N2 moved to S188 (founder, 2026-10-05).
- **F110 class, fix C:** the approvals guard's writer / interpreter / program blocks now say "run the read (cat, ls, jq) as its own command" and name `git commit -F`; every corpus command exits the same at 0071dca and now (`s187_blocks_exactly_what_0071dca_blocked`).
- **N4:** `vajra next --steps` shows "the founder has approved this session" (✗ with `vajra approve NN` / ✓) from `session_rules_from` on.
- **F97 FIXED:** `--sync-fleet` adds a project's missing ground-truth audits (in canonical place, on the one `required_audits:` line) and whole question blocks inside `ground_truth:`; refuses — and prints what to add — any shape it cannot read exactly (quoted names, a key with text after its colon, items at two spaces, a blank line inside a block, an empty block). DECISION-007 S187 addendum narrows S142/S143; DECISION-011 S182 §4 / S183 §3 corrected. An audit a project removed on purpose comes back (said in the output).
- **verify-133 green (15/15):** three checks re-pointed (S181's text-sha, S181's `reverify_handoff`, S168's `complete` demo element). **N6:** ROADMAP's header is a pointer. **N7:** `scripts/lib-old-checkout.sh` (verify-184/186/187, demo-187). **N5:** `--dogfood-age` says "THIS repo only" — named, not closed.
- Review: one cold pass ACCEPT (10/13 · 3 PARTIAL); its recs 1–6 fixed in-session, rec 7 already covered. Verify 14/14 · 573 lib tests · verify-186 35/35 · verify-184 14/14.

## Previous session (S186 — CODE: the fixes from the S185 ground truth, merged #223)

- **F113:** `obeyed_blocks_from: N` in `.ai/CONSTRAINTS.yaml` replaces `OBEYED_JUDGMENT_FROM_SESSION`; only Vajra's file sets it (132). No key → unchecked `obeyed:` claims WARN and say why; empty / non-number / twice / unreadable → a blocking reason naming the line. The design-advisor exemption stops printing 133. DECISION-007 S186 addendum (deviates from S133 §6, reverses S134's marker rejection for this gate).
- **F110 (b) SPLIT OUT by the founder (2026-10-04)** after two cold-review REJECTs (P1–P7: writes into the folder the target-reading guard let through and the S182 rule blocks). The S182 redirect rule is restored (fb467a0); the block names `git commit -F`. **S182 recs 1/2/5 shipped, add-only:** `..` and a `cwd` inside the folder count as naming it; new writers/shells/awk-like programs at command position (with or without a path); the S182 lists also read the de-quoted copy; `--sync-fleet` adds no hook wired under a covering matcher. DECISION-011 S186 addendum records the (b) design and P1–P7.
- **F114** fresh project `--ledger` / `--ledger-verify` exit 0 · **F115** verify-132 13/13 (first time since S135; demo-132 case 7 fixed too) · **N1** hook block reasons on stderr.
- Reviews: pass 1 REJECT → fixes → pass 2 REJECT → founder split (b) → pass 3 REJECT (the backslash-newline join broke add-only; fixed 33235cd) → pass 4 REJECT (large commands: `printf | grep -q` fails open under pipefail — the S182 guard on main lets ~60 KB through; founder: fix, pipe-free checks) → pass 5. 569 lib tests; guard tests on bash 3.2 and 5.
- **🔴→🟢 found and fixed:** the approvals guard on main (and in rudra) lets a ~60 KB command that writes into `.ai/approvals` through (SIGPIPE under pipefail). Fixed here; rudra gets it with `--sync-fleet`.

## Previous session (S185 — NO-CODE ground truth, 🟡 PARTIAL PASS)

- `sessions/session-185-ground-truth.md`. Picked F113 → key, F110 → (b), F114/F115/N1 → S186. N2–N8 recorded. Merged #222.

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
- **🟡 S181/S182 disclosed (DECISION-011):** all bar-raising, not tamper-proof — the agent can strip the mark, fake a terminal, or re-record its own text through `vajra next --role`; `--allow-all=NN` relies on pid liveness. The approvals guard reads command TEXT: a run-time path, a glob, `..` segments (`.ai/hooks/../approvals/x`), or an unlisted write command (`find -delete`, `git checkout --`, `rsync`, `curl -o`) gets past; it over-blocks a command naming the folder that redirects anywhere, and commit-message text naming it. `merge_claude_settings` still appends a whole template group when it is partly present with no same-matcher group (`src/cli/init.rs:980`). These three S182 pass-2 recs were FIXED in S186, add-only (`..` and a cwd inside the folder, more writers/shells, the merge respects covering matchers); the redirect over-block (F110) stays. `scripts/verify-session-175.sh` has 2 stale checks superseded by S181 Part 2 (left as history).
- **🟡 `.ai/ROADMAP.md`'s "NN % 5 == 0 → mandatory NO-CODE GT" pointer line had gone stale for many cycles** (last hand-updated at S120/S125, corrected at S175 to S170/S180) — a reminder that a hand-maintained "next X" pointer drifts unless something derives it.
- **🟢 F97 FIXED S187 (was 🟡, S179):** `--sync-fleet` now adds a project's missing ground-truth audits and question blocks (DECISION-007 S187 addendum). Limit: an audit removed on purpose comes back; an opt-out key → S188/backlog. Other subcommands still swallow unknown flags (read-only).
- **🔴 Non-Claude agents (S179, PARKED until after S180 by the founder):** F91 the git guards cannot tell OpenCode's agent from the founder (37 unchecked commits, a push straight to rudra's main) · F94 one chat for two sessions · F95 OpenCode helpers matched to unrelated Claude Code records. F92 (a waiver labelled "founder" he did not give; the waiver passes ~20 checks at once) → S180 Goal 0.
- **🟢 F113 FIXED S186 (was 🔴):** the obeyed threshold (`OBEYED_JUDGMENT_FROM_SESSION = 132`) counts a PROJECT's sessions in Vajra's numbering, so a project's own session 132 starts BLOCKING unchecked `obeyed:` claims, against the 2026-10-03 "not a blocking gate for projects". The warning now says "in this session" so it promises nothing more. The design-advisor threshold has the same units (DECISION-007 S134 addendum).
- **🟡 F110 STILL OPEN — (b) built in S186, split out by the founder after two REJECTs; the block now names `git commit -F`; (b) → backlog (S190 checklist). The defect:** the approvals guard false-blocks a command whose TEXT names the approvals folder next to a redirect (a heredoc, a `<…>` in a commit sign-off) — hit 3× on 2026-10-04. Workaround: put the text in a file, or `git commit -F`.
- **🟡 S184 disclosed:** F103's 10 s is a guess (a feeder slower than 10 s per answer gets defaults, printed); `scripts/verify-session-132.sh` `advance-really-binds-on-an-unjudged-obeyed` was red since S135 — FIXED S186 (F115: the fixture records a real tech-lead; 13/13).
- **🟢 F114 FIXED S186. Was:** in a fresh `vajra init` project with no review files, `scripts/verify-closeout.sh --ledger` prints nothing and exits 1 — a first-run defect, old.
- **🟡 S183 disclosed:** F104 is a WARN, not a block — below session 132 a project's `obeyed:` still needs nobody's check. `lint_command: true`/`none` passes (only the diff shows it); "matches CI" = matches the pinned version; `#[allow]` silences a lint. Release's `rustup toolchain install && rustup target add` runs only on a tag — not tried. A Rust bump is now a deliberate edit to `rust-toolchain.toml` (and a local `rustup toolchain install`).
- **🟢 verify-session-133.sh green again (S187, 15/15):** three checks re-pointed to today's behaviour, none deleted.
- **🟡 S185 new (N1–N9):** N1 FIXED S186 · N1 was: the ground-truth `[HOOK BLOCK]` lines (`hook-pre-bash.sh:39,77`, `hook-pre-write.sh:38,72`) print to stdout, so the agent sees "No stderr output" (→ S186) · N2 the GT guards block a commit in a throwaway repo and writes to the agent's scratch folder (F56 class) · N3 = F115's lesson · N4 `vajra next --steps` never names a missing approval record · N5 `--dogfood-age` still blind to rudra (S180 N3) · N6 ROADMAP header still "Session 166" (S180 N4) · N7 verify scripts leave old-version checkouts when killed (11 removed 2026-10-04). · N8 a GT prompt has no Deliverables/Acceptance, so `--advance` refuses it; S180 hand-typed .ai/SESSION, S185 added the two sections (restating the Goal) and advanced normally.
- **🟡 S187 found / disclosed:** `vajra next --advance` still rewrites SESSION-BOOT by number swap (S170's bug): it turned "186" into "187" across old text; S187's closeout rebuilt it by hand · the session guard reads a session number in an edit's TEXT as starting that session (blocked S187's own TASK.md edit; the way past: put the text in a file) · the approvals guard blocked S187's own work four times (one retry each) — F110 stays open; the guard's block now says how · N5 named, not closed · the rest of N7 (verify-176/178/179, demo-176/178/179/184/186) → backlog, S190 checklist.
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S187 closed on `session-187-guard-message-and-leftovers`; PR open (founder merges). S188 waits on the founder's pick.

## Active PRs

- S187's PR (open). S186 merged as #223, S185 as #222.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S187 | $0 | No paid run. 4 fleet dispatches (tech-lead, design-advisor, fidelity-reviewer — one pass, release-coordinator as the judge of all 22 obeyed answers) |
| S186 | $0 | No paid run. 5 fleet dispatches (tech-lead, design-advisor, fidelity-reviewer ×2, release-coordinator as the judge of every obeyed answer) |
| S185 | $0 | No paid run. 3 fleet dispatches (tech-lead, design-advisor, release-coordinator; ~113k subagent tokens). NO-CODE ground truth |
| S184 | $0 | No paid run in this repo; the founder's rudra S17 receipt read ~$110.63 (F67-overstated ~5×). 6 fleet dispatches (tech-lead, design-advisor, plan-advisor, fidelity-reviewer ×2 — review + judge, release-coordinator as the recorded judge of all 16 obeyed answers) |
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
