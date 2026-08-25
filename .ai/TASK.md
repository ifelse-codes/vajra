# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 132 — CODE (verify the recorded `obeyed:` is actually true) — COMPLETE

- **Goal achieved.** An `obeyed: <sha>` that does not implement its recommendation can no longer
  pass silently. `obeyed-check [session NN] <role> rec <N> — implemented|mismatch: <sha> — <note>`
  is recorded in a governed handoff; `obeyed::admit` refuses it when the advisor grades its own
  advice, when the sha is not the one the disposition records, when the note is a placeholder, or
  when the judging handoff's provenance does not independently re-verify (S131's chain, reused).
  `vajra next --check-obeyed NN` blocks at `--advance` AND at `verify-closeout.sh`.
- **The S127 residual is CLOSED on the real record:** `--check-obeyed 127` exits 1 reporting
  `implementation-advisor rec 9 — obeyed: 8cd3bea — MISMATCH`, in an independent judge's own words.
- **Migration posture is recorded, not silent:** threshold session 132 — absence WARNs before it
  and BLOCKS from it; a judgment that EXISTS binds at any session, which is what makes a historical
  session re-gradable via the `session NN` qualifier.
- **Two cold passes, both ACCEPT** (`sessions/session-132-review.md`, `…-review-pass1.md`), and a
  THIRD independent dispatch (`implementation-advisor`) as the judge — because pass 2 found that
  the gate structurally refuses `fidelity-reviewer` grading its own recommendations. Resolved on
  the merits; `VAJRA_SKIP_OBEYED_GATE=1` and a closeout waiver were both refused.
- **Live evidence:** `verify-session-132.sh` **13/13 GREEN**, `demo-session-132.sh` **8/8 GREEN**,
  402 lib tests, clippy clean. `K of 8` and the 7-command floor unchanged.
- Reports: `sessions/session-132-summary.md`, `sessions/session-132-review.md`.

**Next: Session 133.** Prompt: `prompts/133-task-compression-keep-or-kill.md`. Locked at the S130
closeout: decide with a measurement whether the compression hook earns its place or is cut.

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
- **The judge may not be the graded advisor's role (S132).** `fidelity-reviewer` is the one role
  every session hears from, so its own recommendations need a DIFFERENT role's dispatch to grade
  them. Dispatch `implementation-advisor` (or another registered role) as the judge; never reach
  for `VAJRA_SKIP_OBEYED_GATE=1`.
- **Land every commit an `obeyed:` will cite BEFORE the judging dispatch (S132)** — one pass then
  grades them all and no regress restarts.
- **A worktree under `$TMPDIR` is pathologically slow to build here (S132):** ~12s inside the repo's
  gitignored `target/`, >10 minutes under `$TMPDIR`. `vajra next --stations` costs ~30s per call
  and >10 minutes inside ANY worktree. Keep the suite under `verify.timeout_secs` (600).
- **`vajra next --advance` blocks on stdin** — non-interactive callers need `</dev/null`.
- **An unrecognised `vajra next` flag falls through to `run_dump()` and exits 0 (S132)** — a check
  that only reads the exit code cannot tell a gate that ran from a gate that does not exist.
- **A recorded claim and a verified one are not the same thing, and this repo keeps re-discovering
  it one layer down.** S127: an `obeyed:` sha resolves ≠ the commit does what it claims (closed at
  S132). S131: a real dispatch occurred ≠ its findings are what got ingested (open, F2). S132: an
  independent judge graded it ≠ the judge read the diff (open, and disclosed).
- **`cargo test` accepts exactly ONE `TESTNAME` filter (S131).**
- **Dispatch evidence is UNSIGNED and hand-fabricable by anyone with shell access (S131).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**; the overall verdict must
  be a bare `**Verdict:** ACCEPT` line.
- **A falsifiability fixture must fail for the RIGHT reason (S122), and a probe must assert its own
  pattern matched (S127) — including the positive control (S132).**
- **Never test the product only in the repo that builds it (S125).**
- **A role no gate consumes is decoration (S125); a registered gate nobody executes is not a gate
  (S129); a check that cannot evaluate FAILS (S69, re-learned at S132).**
- **Max 7 top-level commands.** S132 added none — `--check-obeyed` rides `vajra next`.
- **Direction:** product = **provable agent governance** (`DECISION-001`). The fleet stands at nine
  roles with ONE mandatory (S131); S132 made the fleet's ADVICE consequential rather than merely
  answered.
