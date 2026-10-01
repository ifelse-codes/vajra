# Session 182 — finish S181's own gaps: ship the controls into existing projects

> **Status:** APPROVED — the founder ran `vajra approve 182` in his own terminal (record: the approvals folder, `session-182.json`). The gate reads that record, not this line.

## Type
session_type: CODE
- **CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.

## Evidence
`sessions/session-181-review.md` (pass 2 recs 1–3 and the disclosed limits), `sessions/session-181-summary.md`, `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md`.

## Goal
S181 made the founder's controls hard for the agent to type in Vajra's own repo. A project that already uses Vajra (rudra) gets none of it: `--sync-fleet` never edits its settings and does not ship the approvals hooks. Close that, fix S181's two carried test gaps and the guard's false blocks, and prove it by upgrading rudra itself.

## Deliverables
1. `scripts/verify-session-181.sh:75`: replace the whole-suite check with a positive assertion (at least one `test result: ok`, no `FAILED`, non-zero cargo exit fails).
2. A gate-level obeyed-handoff test in `tests/stamp_gate.rs` (edit the findings, run `vajra next --check-obeyed`).
3. Ship the Write/Bash approvals guards to scaffolded projects (`.ai/hooks/`, stamped, so `--sync-fleet` upgrades them).
4. `vajra init --sync-fleet` reports (never edits) a project whose `.ai/CONSTRAINTS.yaml` has no `session_rules_from`, naming the exact line to add and the session to use (the next session not yet started).
5. Tie the `--allow-all` record to one session number (the branch it was launched on, or the session named at launch).
6. Fix the approvals guard's false blocks (found live twice at S182 start): `scripts/hook-pre-bash.sh:35` blocks any command that names the approvals folder AND contains a write-looking token anywhere — so `cat <folder>/x 2>&1` and an unrelated `python3` heredoc that merely mentions the folder were both blocked. A plain read must pass; a real write into the folder must still block (guard changes only add — S173).
7. Upgrade rudra for real (founder yes, 2026-10-01): run `vajra init --sync-fleet` in rudra, add `session_rules_from: N` as the report says, and show the approvals guard blocking an agent write there. Do not commit in rudra — the founder commits there.

## Acceptance
1. The whole-suite verify check fails when the test suite does not compile (fixture proves it).
2. Editing an obeyed-handoff's findings makes `--check-obeyed` block, end to end.
3. A freshly scaffolded project blocks an agent Write/Bash into its approvals folder; an old project gets the hook through `--sync-fleet` — the file AND its entry in `.claude/settings.json`, listed exactly once (a hook nobody runs is not a guard, S129).
4. `--sync-fleet` on a project without `session_rules_from` prints the line to add and writes nothing to its `.ai/CONSTRAINTS.yaml`.
5. An `--allow-all` record for session A does not approve session B.
6. Every check runs the real thing (no source greps); `verify-closeout.sh` exits 0 on the branch before merge.
7. A read of the approvals folder with `2>&1` passes the guard; a redirect into the folder (`> <folder>/x`, also after a `2>&1`) still blocks (fixture proves both).
8. In rudra after the upgrade: the approvals hook file is present and registered in its `.claude/settings.json`, its `.ai/CONSTRAINTS.yaml` names `session_rules_from`, and a hook call simulating an agent write into its approvals folder exits 2 (live output recorded in the summary).

## Design
design-significant: yes

A new hook shipped to every project, `--sync-fleet` now adding Vajra's hook entries to a project's `.claude/settings.json`, a changed `--allow-all` flag, and a new field in the allow-all record.

- **Follows** `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md`: closes its Limit "scaffolded projects do not yet get the Write/Bash hooks" and narrows decision 2 (`--allow-all` approves one named session). Recorded as an S182 addendum there.
- **Deviates from** `docs/decisions/DECISION-007-agent-fleet.md` (S136 addendum: `--sync-fleet` touches rendered files only). `--sync-fleet` now also adds Vajra's hook groups to `.claude/settings.json` through the same add-only merge `vajra init` has used since S44 — keeps every user key, follows `--dry-run`.
- **Part 3 — one guard, one source.** New `scripts/hook-approvals-guard.sh` checks Bash commands and Edit/Write/MultiEdit/NotebookEdit paths; built in with `include_str!`, shipped stamped as `.ai/hooks/hook-approvals-guard.sh`, its own PreToolUse group. Vajra's own `hook-pre-bash.sh`/`hook-pre-write.sh` call the same file.
- **Part 4 — report, never edit.** No `session_rules_from:` in `.ai/CONSTRAINTS.yaml` → print the line with N = the next session not yet started. Never written: the founder's policy call.
- **Part 5 — the session is named at launch.** `vajra claude --allow-all=NN`; the record stores `session` next to `pid`; a bare `--allow-all` refuses before Claude starts. Not the branch name (agent-typeable; `main` has none).
- **Part 6 — block by where the write lands.** Block a redirect (`>`, `>>`, `>|`, `&>`, `N>`) into the folder (`N>&M`/`>&N` are not writes); a file-writing command (tee, cp, mv, rm, touch, sed -i, dd, install, ln, truncate) naming it; a `cd` into it plus any write word; an interpreter (python3, perl, node, ruby) naming it — fail closed, message names `cat`/`ls`/`jq`. Disclosed gap: a path hidden in a shell variable gets through (bar-raising, not tamper-proof).

## Plan
1. Part 6: new `scripts/hook-approvals-guard.sh` blocks by where a write lands (Bash + Write-type tools); `hook-pre-bash.sh` and `hook-pre-write.sh` call it; `tests/approvals_guard.rs` drives it with real JSON payloads — `cat <folder>/x 2>&1` passes; `>`, `>>`, `2>`, `2>&1 > <folder>/x`, `tee`, `cp`, `cd`-into, `python3` all block (covers: 7)
2. Part 1: `scripts/verify-session-181.sh` whole-suite check becomes positive (a `test result: ok`, no `FAILED`, non-zero cargo exit fails); a stub `cargo` on PATH that fails to compile proves it goes red for that reason (covers: 1)
3. Part 2: gate-level obeyed-handoff test in `tests/stamp_gate.rs` — a valid obeyed handoff passes `vajra next --check-obeyed`, edit its findings, the same command blocks (covers: 2)
4. Part 3a: the scaffold ships `.ai/hooks/hook-approvals-guard.sh` (stamped, `include_str!` of the step-1 file) and registers it as its own PreToolUse group; a test scaffolds a scratch project and its hook blocks an agent Write and Bash into the approvals folder (covers: 3)
5. Part 3b: `vajra init --sync-fleet` adds the hook file and merges its group into an old project's `.claude/settings.json` (add-only, `--dry-run` honoured); a fixture asserts every `.ai/hooks/*.sh` is listed exactly once after the merge (covers: 3)
6. Part 4: `--sync-fleet` on a project with no `session_rules_from` prints the exact line and N; `.ai/CONSTRAINTS.yaml` bytes are unchanged before and after (covers: 4)
7. Part 7: build vajra from this branch; in rudra record `git log -1`, run `<branch-build>/vajra init --sync-fleet`, add `session_rules_from: N` as reported, drive rudra's registered approvals hook with a simulated agent write → exit 2; rudra HEAD unchanged; no commit in rudra (covers: 8)
   --- CUT LINE: if the ~2h cap bites, step 8 is carried to S183 in writing (Deliverable 5 / Acceptance 5 marked carried before the cold review) ---
8. Part 5: `vajra claude --allow-all=NN` stores `session`; a record for session A does not approve session B; a bare `--allow-all` refuses (`src/approval/mod.rs`, `src/cli/launch.rs`, test) (covers: 5)
9. `scripts/verify-session-182.sh` re-runs the real things (the tests by name, the stub-cargo fixture) with no source greps; the rudra check prints SKIPPED, never PASS, when rudra is absent; `scripts/demo-session-182.sh` shows a read passing, a write blocked, and the `--sync-fleet` report (covers: 6)
10. Close: summary records the rudra command, report, hook exit-2 output and HEAD before/after; DECISION-011 S182 addendum; a fresh cold fidelity review with `--inputs-sha 182`; `scripts/verify-closeout.sh` exits 0 on the branch before merge (covers: 6, 8)

## Execution
- step 1 — done: 71f7c68 (tests a74d886; fmt 20d50ce; backtick case 540db79; review fixes 4449ebb)
- step 2 — done: 8aed970 (follow-up 91b7380: cargo's own FAILED lines only — a test prints the word)
- step 3 — done: 3fce2eb
- step 4 — done: 86499ec
- step 5 — done: 3a2a02e (partly wired group fix 2967453; key order 293796b)
- step 6 — done: 3a2a02e
- step 7 — done: 57542bb (the rudra work is uncommitted in rudra by design; this commit's verify P7 re-checks it live, and the summary records the run)
- step 8 — done: 233e669 (CLI tests 198d22c)
- step 9 — done: 57542bb
- step 10 — done: 4d4839e (summary + DECISION-011 addendum; review pass 1 recorded ec77bf8; pass 2, attestation and the closeout run land in the closeout commits)

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` and `plan-advisor` (required by the tech-lead), `fidelity-reviewer` (required; the cold close review, and the independent judge of the `obeyed:` lines below).

**tech-lead** (`.ai/handoffs/session-182-tech-lead.md`):
- tech-lead rec 1 — obeyed: 71f7c68 (the guard fix landed as step 1, before the scaffold shipped it in 86499ec)
- tech-lead rec 2 — obeyed: 4449ebb (first built in 71f7c68; the review-found `>&1/…` spelling closed here; a read with `2>&1` passes; interpreters naming the folder still block, with a message naming cat/ls/jq and the Edit tool)
- tech-lead rec 3 — obeyed: 233e669 (order 6 → 1 → 2 → 3 → 4 → 7 → 5 kept; the cut line was not needed — Part 5 is this commit)
- tech-lead rec 4 — obeyed: 4d4839e (the summary records the branch-build command, the report, the exit-2 output, and rudra HEAD 5ab6e83 before and after)
- tech-lead rec 5 — deferred: sessions/session-182-review.md

**design-advisor** (`.ai/handoffs/session-182-design-advisor.md`):
- design-advisor rec 1 — obeyed: 4d4839e (`design-significant: yes` in 616ae71; the S182 addendum and the rewritten Limit line in DECISION-011 here)
- design-advisor rec 2 — obeyed: 86499ec (one `scripts/hook-approvals-guard.sh`, `include_str!` into `SYNC_HOOKS`; Vajra's own two hooks call it since 71f7c68)
- design-advisor rec 3 — obeyed: 3a2a02e (`--sync-fleet` merges the missing groups through `merge_claude_settings`, its own PreToolUse group, `--dry-run` honoured)
- design-advisor rec 4 — obeyed: 616ae71 (Deliverable 4 and Acceptance 4/8 now name `.ai/CONSTRAINTS.yaml`)
- design-advisor rec 5 — obeyed: 3a2a02e (report only; N = `.ai/SESSION` + 1)
- design-advisor rec 6 — obeyed: 233e669 (`--allow-all=NN`, `session` stored next to `pid`, bare form refused before launch)
- design-advisor rec 7 — obeyed: 4449ebb (first built in 71f7c68; fd-dup strip anchored, case + quotes here; deviation, stricter: instead of parsing redirect targets, ANY redirect left after the provable non-writes blocks when the folder is named — target parsing would have let `> "$D"/x` through where S181 blocked it; `cd`-into case and interpreters kept; run-time-path gap disclosed in DECISION-011)
- design-advisor rec 8 — obeyed: 2967453 (pass 1 judged 3a2a02e a mismatch — the fixture never had a partly wired group; now a pre-S93 Bash group gets only its missing hook and `sync_fleet_never_lists_a_hook_twice_in_a_pre_s93_project` checks every tool runs exactly the hooks a fresh scaffold runs)

**plan-advisor** (`.ai/handoffs/session-182-plan-advisor.md`):
- plan-advisor rec 1 — obeyed: 616ae71 (the 10-step plan and cut line, recorded in `## Plan`)
- plan-advisor rec 2 — refused: the rec applies only if the cut line is used; it was not — Part 5 was built in 233e669, so nothing was carried and Acceptance 5 is covered by a built step
- plan-advisor rec 3 — obeyed: 86499ec (the scaffold's guard is `include_str!` of the same file Vajra runs)
- plan-advisor rec 4 — obeyed: 3a2a02e (`.claude/settings.json` registers the hook; the scaffold tests and verify P7 run the command as the settings spell it)
- plan-advisor rec 5 — obeyed: 57542bb (verify-182 P1 uses a stub `cargo` on PATH; the real build is never broken)
- plan-advisor rec 6 — obeyed: a74d886 (`2>`, `2>&1 >`, `>>`, `tee`, `cp` into the folder all block; `cat <folder>/x 2>&1` passes)
- plan-advisor rec 7 — obeyed: 57542bb (verify P7 prints SKIPPED, never PASS, when rudra is absent)
- plan-advisor rec 8 — obeyed: 4d4839e (the summary names the absolute branch-build path and rudra HEAD before/after)

**fidelity-reviewer** (`.ai/handoffs/session-182-fidelity-reviewer.md`, pass 2, ACCEPT 14/15; pass 1 in `sessions/session-182-review.md`):
- fidelity-reviewer rec 1 — deferred: .ai/ROADMAP.md
- fidelity-reviewer rec 2 — deferred: .ai/ROADMAP.md
- fidelity-reviewer rec 3 — deferred: sessions/session-182-summary.md
- fidelity-reviewer rec 4 — deferred: sessions/session-182-review.md
- fidelity-reviewer rec 5 — deferred: .ai/ROADMAP.md

Why each fidelity-reviewer `deferred:` line points where it does: recs 1, 2 and 5 are loopholes and edge cases in a guard that is bar-raising by design. Changing the guard or the merge after the second ACCEPT would need a third review. The founder's standing rule (2026-09-15, "no more policing") is to park loopholes, so all three are written into the S182 row of `.ai/ROADMAP.md` as backlog for the S185 ground-truth checklist. Rec 3 (rudra's real output and the re-syncs) is pasted in the summary. Rec 4 (closeout on the branch before merge, attested `--inputs-sha 182`) lands in the review file.

Why the one tech-lead `deferred:` line points where it does: tech-lead rec 5 asks for `verify-closeout.sh` on the branch before merge and the review recorded with `--inputs-sha 182` — both happen at close and land in the review file. Its third ask (scaffold probes in a scratch repo, not Vajra's tree) is met by `tests/approvals_scaffold.rs`, which scaffolds into temp dirs.

## Guardrails
- No autonomous commits: the founder runs them, or launches with `VAJRA_ALLOW_COMMIT=182`. The agent never sets it.
- ≤3 files per commit; ≤2 assumptions; ≤2 retries. A fresh cold fidelity review at close (F81).
- Guard changes only add (S173). No new ceremony; nothing that polices Vajra's own paperwork.
- Parked, NOT this session: other coding tools (OpenCode first), F67 receipt pricing, release/publish.

## Delta
- `+` approvals hooks shipped to scaffolded projects; `--sync-fleet` report for a missing `session_rules_from`; `--allow-all` tied to a session; obeyed-gate stamp test; rudra upgraded live
- `~` `scripts/verify-session-181.sh` whole-suite check; the approvals guard stops blocking plain reads
- `-` nothing removed
