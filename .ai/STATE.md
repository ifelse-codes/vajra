# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-174-keep-testing` — S174 complete on its branch; PR to open (the founder merges).**

## What was done this session (S174 - interactive, the founder's rudra session 05)

- He ran rudra's session 05 under `VAJRA_ALLOW_COMMIT=05 vajra claude` (ACCEPT 7/7, merged as rudra #6; 4h15m, ~3h of it a Claude outage). Findings read from rudra's transcript after it closed; he said "fix all of it".
- **Fixed:** F58 an approved agent's inline-text PR was blocked with "relaunch with VAJRA_ALLOW_PUBLISH" and handed back → the block says "You ARE approved" and names `--body-file` · F59/F62 the to-do list at boot described merged S04 and was never re-read; after S05 merged it re-graded S05 → a merged session hands the list over to the next one's start, and every list says re-run it · F60 Vajra's synced files left uncommitted and nearly reverted → boot proves them Vajra's (body re-hashes to the trailer): commit first, never revert · F61 the 3-file block left files staged → says so · F63 the SESSION/SESSION-BOOT block names the line.
- **No check loosened:** the pre-S174 hooks and today's agree on 593 of 593 listed decisions.
- **F31, fifth watch: clean.** F50 did not bite rudra; it bit S174's own edit script and the "use a file" hint worked first try.
- Verify 20/0 · demo 9 live checks.

## Previous session (S173 - interactive, the founder's rudra session 04)

- F45–F57: eight fixed; the agent may push its own branch and open its PR (F55); F50 not fixed in code. `sessions/session-173-summary.md`.

## What Currently Works

- The close gate refuses made-up evidence: prose/malformed/non-existent `done:` shas, unlanded plan steps, unbacked verdict claims, a CODE session with no tech-lead (S169).
- A demo that cannot be faked: command-backed checks, Vajra-filled numbers, gate re-derives facts at close (S168).
- Terminal demo deck for every Vajra project: `scripts/demo-kit.sh` + the seven-section template (S167).
- `vajra init --sync-fleet` upgrades fleet roles + hooks + constitution + close gate + demo template + kit.
- 10-role fleet, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`); 8 stations + closeout gate (19 checks); tamper-evident ledger; receipts.

## What Is Broken / Weak / Disclosed

- **🟡 Release 0.2.0 half done** — tag `v0.2.0` + GitHub release out; **crates.io still 0.1.0** (founder types `cargo publish`); brew tap formula is at 0.2.0 but install-smoke not run (ROADMAP `S168-release`). A stranger's `cargo install` gets none of S167–S169. Founder's own installed `vajra` is 0.1.0.
- **🟡 S169 fakest green:** the claim match is words only; claimed-evidence proves files exist, not that they are real; a made-up `done:` sha is still waivable; `git cat-file -e` accepts any old commit → **parked — policing** (ROADMAP `S171-parked`).
- **🟢 FIXED S171:** the close gate and the demo facts read the padded session names; `find_summary_for` accepts the unpadded spelling old repos carry.
- **🟢 F31 clean five times (S171–S174):** rudra dispatched the tech-lead first every run.
- **🟢 FIXED S172:** the commit/push belt split is executable (`tests/commit_belt.rs`, 6 tests over 11 cases, red when agent detection is removed).
- **🔴 The backstop is gone (S172, disclosed):** a skipped `verify-closeout.sh` used to be caught at the next session's start; it is caught nowhere now. Running the close check on the branch before the merge is the whole enforcement story, and it is a text rule. DECISION-007 S172 addendum.
- **🟡 `shipped_close()` keys on one file** — landing a summary on main early downgrades the closing gates to reporting while a session is live (self-granted jurisdiction, disclosed).
- **🟡 F50/F44 — not fixed in code (S173, by decision):** a commit message that mentions a guarded command still blocks, as before S173; the block names `git commit -F <file>` / `--body-file`. Every hiding rule tried hid something a shell runs.
- **🟡 F55's `cwd` assumption (S173):** the push permission reads the hook input's `cwd` — still unverified live (rudra S05 never used a worktree).
- **🟡 S174 is text, not a gate:** the list says re-run it, the PR block names the passing shape — whether the agent acts on either is rudra 06's test. F64 (an advice answer switched to pass) watched.
- **🟡 The guards' old-vs-new check is a list (S173):** 30 named shapes × 4 triggers; a spelling nobody listed is not covered. Pre-S173 limits still stand: `git -c … push`, aliases, config/upstream redirects, `gh api …/merge`.
- **🟡 Parked LOW (S173):** F47 copied jargon · F56 the session guard cannot tell a command runs in another project · F57 the Coder check reads only `1. …` plan steps, so this repo's `- step N —` plans pass with nothing to check.
- **🟢 DECIDED 2026-09-21 (founder):** a branch not named `session-NN-…` is ungoverned ad-hoc work, BY DESIGN — the per-session approval does not apply there; the 3-file cap and the ban on `main` still do. DECISION-007, locked by `tests/commit_belt.rs`.
- **🟡 Unexplained mid-session changes (S172):** `.claude/settings.json`, `.gitignore` and a stray `.ai/hooks/` appeared in this repo, consistent with a scaffold run inside Vajra itself; not reproduced by the suite or `verify-session-93.sh`. Kept in `git stash` + the scratch dir, not deleted.
- **🟡 `--sync-fleet` cannot upgrade a belt installed from an arbitrary main commit** (only release-tag renders are listed) — such a project needs `--overwrite-drifted`.
- **🟡 `vajra next --advance` into S168 AND S169 used `VAJRA_SKIP_CODER_GATE=1`** (a pending release step). S169's plan has no post-merge step, so S170's advance should need none.
- **🟡 Old records under new rules:** closed S167/S168 prompts fail `--check-exec-shas`; `verify-session-166.sh` AC3 is red (non-git fixture). Old sessions are never re-graded; nothing re-runs old verify scripts.
- **🟡 S166 + S167 never passed `verify-closeout.sh`**; S168 fakest green (`dk_check "x" true`) stands; S168 review recs 1–3 → S171.
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S174 closed on its branch; PR to open. S175 = mandatory NO-CODE Ground Truth, drafted from candidate 1 (`prompts/175-task-ground-truth.md`, DRAFT) — the founder's pick is pending.

## Active PRs

- S174's, once opened. S173 merged as #210.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
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
