# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-172-keep-testing` — S172 complete; PR open at close.**

## What was done this session (S172 - interactive, the founder's own rudra session 03)

- He ran his own project's session 03 end to end under Vajra and pasted the run. Nine findings, F35-F44, recorded with severities in `prompts/172-task-keep-testing.md` BEFORE anything was fixed.
- **F39, the structural one:** the advance step re-graded the session it closes, but it runs AFTER that session merged - in rudra it made him rewrite session 02's paperwork days after it shipped. `releaser::shipped_close()` now asks git whether `sessions/session-NN-summary.md` is on main; if it is, the closing gates REPORT and the live QA/demo re-runs are skipped. The teeth moved earlier: `check_live_gate` in `scripts/verify-closeout.sh` + the scaffold copy runs the advice, verify and (projects) demo checks before the merge. DECISION-007, S172 addendum.
- **F35:** `src/architect` reads `docs/ADR/` and `ADR-010-title.md` names - rudra's ten real ADRs were invisible, so the citation check silently waived itself.
- F40 (demo "before" = the session's start commit, never main) - F41 (three messages say how: the advance confirmation with no keyboard, the `crew <role> - ...` line format, the review-hash order) - F36 (the reading pause names only unread files, read from the transcript) - F38 (boot warns when the handover names a prompt file that does not exist) - F42 (plain words demanded at boot + `darshan/SKILL.md`) - F43 (unpushed commits listed by name).
- **Carried S171 rec 7 built:** `tests/commit_belt.rs` - 6 tests over the qa-specialist's 11 cases, driving the real `.githooks` files; disabling agent detection turns 3 red. The same role found `verify-session-93.sh` was passing only because it ran inside an agent shell.
- **F31 did not recur** - rudra's session 03 dispatched the tech-lead before any planning. No gate built (founder's call, untaken).
- Verify 28/0 - demo 14 live checks - 527 lib tests + the belt suite.

## Previous session (S171 - interactive, the founder's own first-run test)

- 34 findings, five groups, all fixed; receipt 2.3x high -> 1.6%. Light close by founder's choice (no verify/demo/crew handoffs). `sessions/session-171-summary.md`.

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
- **🟢 F31 did not recur (S172):** rudra session 03 dispatched the tech-lead first. One clean run after two failures; watch it again rather than calling it closed.
- **🟢 FIXED S172:** the commit/push belt split is executable (`tests/commit_belt.rs`, 6 tests over 11 cases, red when agent detection is removed).
- **🔴 The backstop is gone (S172, disclosed):** a skipped `verify-closeout.sh` used to be caught at the next session's start; it is caught nowhere now. Running the close check on the branch before the merge is the whole enforcement story, and it is a text rule. DECISION-007 S172 addendum.
- **🟡 `shipped_close()` keys on one file** — landing a summary on main early downgrades the closing gates to reporting while a session is live (self-granted jurisdiction, disclosed).
- **🟡 F44 (S172, open):** the session guard reads a command's PROSE — a closeout note quoting the advance command in backticks armed the boundary and blocked the write. Quoted text is stripped; backticked text is not.
- **🟡 Open question, put to the founder twice and unanswered:** an agent may commit without approval on a branch not named `session-NN-...`.
- **🟡 Unexplained mid-session changes (S172):** `.claude/settings.json`, `.gitignore` and a stray `.ai/hooks/` appeared in this repo, consistent with a scaffold run inside Vajra itself; not reproduced by the suite or `verify-session-93.sh`. Kept in `git stash` + the scratch dir, not deleted.
- **🟡 `--sync-fleet` cannot upgrade a belt installed from an arbitrary main commit** (only release-tag renders are listed) — such a project needs `--overwrite-drifted`.
- **🟡 `vajra next --advance` into S168 AND S169 used `VAJRA_SKIP_CODER_GATE=1`** (a pending release step). S169's plan has no post-merge step, so S170's advance should need none.
- **🟡 Old records under new rules:** closed S167/S168 prompts fail `--check-exec-shas`; `verify-session-166.sh` AC3 is red (non-git fixture). Old sessions are never re-graded; nothing re-runs old verify scripts.
- **🟡 S166 + S167 never passed `verify-closeout.sh`**; S168 fakest green (`dk_check "x" true`) stands; S168 review recs 1–3 → S171.
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S172 closes with a PR; the next brief gets written from the founder's pick of its three candidates.

## Active PRs

- S172's PR, opened at this close. S171 merged as #207.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S172 | $0 | No paid run; the founder's own rudra run supplied the findings. 4 fleet dispatches (tech-lead, qa-specialist, design-advisor, fidelity-reviewer) |
| S169 | $0 | No paid run; bash gate + scripts + fleet subagents only |
| S168 | $0 | No paid run; code + scripts + fleet subagents only |
| S167 | $0 | No paid run; code + scripts + fleet subagents only |
| S166 | $0 | No paid run; bash scripting + verify + demo scripts only |
| S161 (Part 2 — D2 dogfood) | null | `total_cost_usd` not in JSONL; token estimate ~$14.15 (not authoritative) |

## Direction (governance is the product)

- **Product = provable agent governance** (`DECISION-001`). Direction (2026-09-15): **no more policing — reach a real user.** Founder tests Vajra himself; sessions are interactive from S171.
- **Founder priorities (S140/S160):** (1) fresh-user experience + release; (2) prove it works, then cut cost; (3) self-driving unattended close / Rung 2–3; (4) external adoption.
