# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 134 — PAID DOGFOOD (the mudra chart review in chitra) — COMPLETE

- **Goal achieved.** One real paid session ran in `/Users/suman/playground/chitra` through
  `vajra claude` — **`$1.6103385` authoritative**, 25 turns — reviewing every mudra-locked chart by
  **rendering and looking at each one**, and reported both verdicts the founder was owed.
- **Design verdict: IMPRESSIVE**, with two cheap blemishes. Verified at raw-RGB level: one accent
  hue spent exactly once, the literal documented grey ramp everywhere else, across four unrelated
  geometries. Weakest chart `area`; highest-impact fix = un-crush the bar x-axis (`JaFeMaApMaJuJuA`).
  Full deck + review in chitra at `sessions/mudra-chart-review-2026-08-26.md`.
- **The finding this repo could not manufacture — the BROWNFIELD THRESHOLD HOLE.** chitra's session
  16 is actively locking chart families to a design language and the S133 mandate returns
  `verdict: READY`, `handoff: (none)` — it sits below the migration threshold of 133. The threshold
  counts the wrong units. **DECISION-007 S134 addendum**, three fixes named, none picked (n=1).
- **Worse: `--stations 16` reads `0 of 8`** at `maturity: L3`. The governance is installed and unused.
- **The mandate also paid for itself.** Dispatched FIRST; 22 recs; found the brief factually wrong in
  **seven** places (including a locked chart family the brief omitted) before a paid minute was spent.
- **chitra undisturbed, proved four ways** — HEAD, index hash, stash list, branch identical; exactly
  one pre-declared new path.
- **Evidence:** verify **29/29**, demo all-pass, fixture **10/10**. Three dispatches, three different
  roles: design-advisor → fidelity-reviewer (**ACCEPT**) → implementation-advisor as JUDGE of all 34
  `obeyed:` claims (32 implemented, 2 mismatch, plus a fixture bug the cold pass missed — all fixed).
- Reports: `sessions/session-134-summary.md`, `sessions/session-134-review.md`.

**Next: Session 135 — `implementation-advisor` becomes the fleet's THIRD mandatory role**, as a
**CALL SITE** on `mandate` (ROADMAP F2e), never a third copy of the ladder. Locked by the founder at
the S133 closeout. Prompt: `prompts/135-task-implementation-advisor-mandatory.md`.

**What S134 hands it, that it did not have before:** the brownfield threshold hole. S135 inherits
the same `_MANDATE_FROM_SESSION` threshold for a second role and must **either fix the units or
record in writing** why it ships a second mandatory role with a known permanent exemption for every
brownfield adopter. It must also decide **F2e** and probe **F2g** live. And it is the falsification
test for S133's genericity claim: if S135 edits `mandate_gate`, `parse_skip_marker` or
`classify_marker_value`, the genericity was decoration — and that is the session's most interesting
finding.

**New chat.**

## Always-True Reminders

- **A dogfood's most valuable finding is the one the repo could not have written itself (S134).**
  Nine sessions of machinery, all exercised against fixtures this repo wrote. The first time the
  S133 mandate met a real outside project it returned READY on the exact session it exists for.
- **A migration threshold measured in the governed project's session numbers is wrong for every
  brownfield adopter (S134).** For this repo it is a closing window; for a project that adopts at
  its session 40 it is a permanent exemption with nothing to end it.
- **A gate suite can be fully installed and score `0 of 8` (S134).** chitra runs at `maturity: L3`
  and passes zero stations. Installed ≠ used; surfacing calls exit 0 by design and bind only at
  `--advance` and `verify-closeout.sh`, so nobody sees the zero unless they go and ask.
- **A check that greps a literal the agent typed, in a file the agent wrote, is not attestation
  (S134).** `c_binary_recorded` was the fakest green of the session and the builder did not spot it.
  An unexpanded `$(...)` in a "captured" artifact is the tell that it was hand-written.
- **A check that evaluates zero rows is indistinguishable from a deleted check (S134).** Print the
  row count, or declare the tooth dormant in the comment.
- **A fixture's positive control must assert a clean exit 0, not just one green line (S134).**
  S134's sandbox omitted a file the verify script needed, so verify failed on every fixture run and
  the `exit != 0` half of each defect assertion proved nothing. The judge caught it; the cold
  fidelity pass did not.
- **A forward reference is not a number (S134).** The summary said "see review", the review said
  "see summary", and the third figure existed nowhere.
- **Three consecutive judges have had no shell (S133, S134 ×2).** Every "verify N/N" claim in those
  sessions was executed only by the builder. The independent pass reads scripts; it does not run them.
- **When a pre-commitment looks like it came true, check whether it was sidestepped (S134).** The
  advisor predicted an honest-null receipt for an interactive run; the run was made headless, and
  reporting the real cost as the prediction failing would have been spin.

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
