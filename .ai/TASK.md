# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 133 — CODE (the design-advisor becomes mandatory) — COMPLETE

- **Goal achieved.** A session cannot reach its close without either a real `design-advisor`
  governed handoff or a RECORDED, substantive, VISIBLE reason why it did not need one.
  `src/mandate/mod.rs` holds a six-rung ladder, generic over a `fleet::Role`;
  `vajra next --check-design-handoff NN` binds at the closing advance AND at
  `scripts/verify-closeout.sh`.
- **The reasoned skip:** `<role-name>: skipped — <reason>` in the session's own prompt —
  line-anchored, fence-skipping (both kinds), gated by `advice::substantive_reason` verbatim, and
  keyed on the ROLE NAME so S134 inherits the grammar with no new parser. **No
  `VAJRA_SKIP_DESIGN_ADVISOR_GATE`**, and twelve environment variables are driven live to prove it.
- **Rung 1 beats rung 3, decided not discovered:** a recorded reason does not launder a forged or
  malformed handoff.
- **Threshold 133 governs SILENCE only**, and the scaffold carries the marker so a fresh project
  blocks at session 1 rather than being exempt for 132 sessions.
- **Three independent dispatches:** `design-advisor` FIRST before any code, a cold
  `fidelity-reviewer` pass (**ACCEPT**), and `implementation-advisor` as the JUDGE of all 22
  `obeyed:` claims.
- **Live evidence:** `verify-session-133.sh` **15/15 GREEN**, `demo-session-133.sh` **9/9 GREEN**,
  428 lib tests, clippy + fmt clean, fixture RED on 7 bypasses and GREEN on renaming all 11
  messages, `K of 8` pinned to its baseline and unchanged.
- Reports: `sessions/session-133-summary.md`, `sessions/session-133-review.md`.

**Next: Session 134 — the PAID DOGFOOD, re-picked by the founder after the S133 close.** Prompt:
`prompts/134-task-dogfood-chitra-mudra-review.md`. One real paid session runs in
`/Users/suman/playground/chitra` through `vajra claude`, reviewing every chart chitra has locked to
the mudra reference language — **seen, not just read** — and reporting two things: the design
verdict the founder asked for (impressive or not; if not what to fix; if yes why and what was made
good) and what Vajra's governance actually did during a real piece of outside work.

**Why this and not the third mandatory role:** nine sessions since the last paid run (S124,
`$3.2985`, 2026-08-20), and S133 just shipped a gate that blocks a brand-new project's first
session — tested only by fixtures this repo wrote. **`implementation-advisor` mandatory is
deferred, not dropped**; its full brief survives in the new prompt's Non-goals.

**The guardrail that matters:** chitra is mid-session-16 with uncommitted work. S134 must not
disturb it — baseline `git status --short` before, diff after, and obey chitra's own constitution
inside chitra.

**New chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`. Max 3 files per commit, hook-enforced.
- **A GT session (`NN % 5 == 0`) cannot commit on its own branch** — closeout commits ride a
  `session-NN-closeout` branch (the exempt suffix).
- **Attest LAST (S69), hashing the LIVE PROMPT (S131):** recompute `--inputs-sha NN` after every
  edit to the prompt, and run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
- **The judge may not be the graded advisor's role (S132).** S133 used `implementation-advisor` to
  judge both `design-advisor` and `fidelity-reviewer`; when S134 makes `implementation-advisor`
  mandatory, the judge for ITS advice must be a third role again.
- **Land every commit an `obeyed:` will cite BEFORE the judging dispatch (S132)** — one pass then
  grades them all and no regress restarts.
- **A wrapped prose line that BEGINS with a code fence hides every `rec N` after it (S133).** It
  happened to S133's own cold-review handoff; the Advice gate reported ten ORPHAN answers and was
  right. When a brief discusses fence syntax, never let a line start with the fence characters.
- **A guard bound to a spelling fires on prose ABOUT the spelling (S132, hit again at S133).** The
  session-guard blocked a `python3` heredoc that merely quoted the advance command inside
  backticks — `SCAN` strips quoted spans, not backticked ones. Write such docs with a dedicated
  file-write tool, or use a placeholder and `sed` it afterwards.
- **A skip must cost a sentence (S133).** `<role-name>: skipped — <reason>` in the prompt. There is
  no environment variable for the Mandate gate, on purpose — the escape has to leave a trace.
- **A worktree under `$TMPDIR` is pathologically slow to build here (S132):** ~12s inside the repo's
  gitignored `target/`, >10 minutes under `$TMPDIR`. `vajra next --stations` costs ~30s per call
  and >10 minutes inside ANY worktree. Keep the suite under `verify.timeout_secs` (600).
- **The closing advance blocks on stdin** — non-interactive callers need `</dev/null`.
- **An unrecognised `vajra next` flag falls through to `run_dump()` and exits 0 (S132)** — require
  the gate's own header string, never just the exit code.
- **A recorded claim and a verified one are not the same thing, and this repo keeps re-discovering
  it one layer down.** S127: an `obeyed:` sha resolves ≠ the commit does what it claims (closed at
  S132). S131: a real dispatch occurred ≠ its findings are what got ingested (open, F2). S132: an
  independent judge graded it ≠ the judge read the diff (open). **S133: a role was dispatched ≠ its
  advice reached the design (open, F2f).**
- **`cargo test` accepts exactly ONE `TESTNAME` filter (S131).**
- **`grep -F` with a MULTI-LINE pattern is an alternation of its LINES, not one literal (S133).**
- **Dispatch evidence is UNSIGNED and hand-fabricable by anyone with shell access (S131).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**; the overall verdict must
  be a bare `**Verdict:** ACCEPT` line.
- **A falsifiability fixture must fail for the RIGHT reason (S122), a probe must assert its own
  pattern matched (S127) including the positive control (S132), and a rename control is meaningless
  unless the unit tests bind to VALUES rather than to message text (S133).**
- **Never test the product only in the repo that builds it (S125).**
- **A role no gate consumes is decoration (S125); a registered gate nobody executes is not a gate
  (S129); a check that cannot evaluate FAILS (S69).**
- **Max 7 top-level commands.** S133 added none — `--check-design-handoff` rides `vajra next`.
- **Direction:** product = **provable agent governance** (`DECISION-001`). The fleet stands at nine
  roles with **TWO mandatory** — `fidelity-reviewer` (S131, grades finished work) and
  `design-advisor` (S133, must be consulted or the skip must cost a recorded sentence).
