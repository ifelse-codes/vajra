# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 129 — CODE: ONE SOURCE FOR WHAT A STRANGER GETS — COMPLETE (between sessions)

- **Verdict: ACCEPT on TWO independent cold passes.** The second was run because the work done
  after pass 1 was substantive — shipping pass 1's verdict over changed code would have been
  dishonest. Pass 2: **14 SHIPPED · 2 PARTIAL · 0 NOT-BUILT**. **17 recommendations across both
  passes: 16 obeyed, 1 REFUSED with a reason.** Report: `sessions/session-129-summary.md`.
  Both reviews: `sessions/session-129-review.md`. Prompt: `prompts/129-task-one-source-scaffold.md`.
- **What a stranger is governed by now:** **13 of 13** binding rules (was 8, two renamed so equality
  was never checkable) · **10 of 12** ground-truth audits (was 7) · **7 of 7** drift axes (was 6,
  and nobody knew) — all DERIVED at build time by `build.rs`. **The DEFAULT is CARRIED**; deviation
  needs a declared reason that **ships into the stranger's own file**; **a stale declaration panics
  the build.** `scripts/scaffold-drift.sh` is the guard (17/17) and `scaffold_drift_check` is the
  12th required GT audit.
- verify **12/12** · demo **15/15** · drift **17/17** · stranger **21/21** · fixture **18/18**
  (7 plants + a control) · **365** tests · `K of 8` unmoved · **7 commands**.

**🔴 THE RESIDUAL, UNSOFTENED — THE FOURTH FORK, REFUSED.** `TPL_CONSTRAINTS` in `src/cli/init.rs`
still hand-types a family of twins of live `.ai/CONSTRAINTS.yaml` keys, **and two are already WRONG
in a stranger's file**: `communication.forbid` ships **4 of our 5**, and
**`commit.forbid_skip_hooks` is absent while `src/varta/render.rs:84` reads it**. Also absent:
`commit.forbid_force_push_to`, `self_review_questions`, the whole `end_of_session` block. Plus the
scaffolded load order (8 vs 9) and session loop (9 vs 10) — sections the live file labels
*Mandatory*. **Refused because it needs a KEY-SET inventory, not a fourth list comparison**, and
hand-patching would put fresh hand-typed content into the session that removed it. Named in four
places including the drift check's own GREEN output. **It is S131's candidate A.**

**🔴 UNPLANNED FIND, and the general lesson to carry:** running `vajra next --check-plan` at close
showed it had been **mis-parsing every prompt** since the heading changed — a `K of 8` station was
reporting PASSED off a parser that mis-read the prompt. **A registered gate nobody executes is not
a gate.**

**Next = S130 — the MANDATORY NO-CODE GROUND TRUTH** (`130 % 5 == 0`), auditing S126–S129, and
**the first GT that must RUN both product-facing audits** (`stranger_check`, `scaffold_drift_check`).
Its lenses: is nine roles a fleet or a roster · is one-cold-pass-at-close the right review shape.
**Prompt: `prompts/130-task-ground-truth.md`.** Three ranked S131 candidates are carried there and
in the summary; the founder picks at the S130 closeout.

**New chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **A GT session (`NN % 5 == 0`) cannot commit on its own branch** — the hook blocks it. Closeout
  commits ride a `session-NN-closeout` branch (the exempt suffix).
- **Attest LAST (S69):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), recomputed strictly after
  the prompt's Execution shas are committed; two consecutive `verify-closeout.sh --inputs-sha NN`
  runs must agree before embedding.
- **Fill the Coder-gate `## Execution` shas before closeout, every session (S124).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).**
- **Never trust a launched/dispatched agent's own self-report as evidence its criteria were met
  (S124).**
- **Never test the product only in the repo that builds it (S125).** Every bug S125 found was
  invisible for 125 sessions because no audit ever ran `vajra init` in an empty directory.
  **S128 built the instrument** — `scripts/stranger-check.sh`, a required GT audit — but it is
  REGISTERED, not RUN: nothing forces a GT session to execute it.
- **Measure the shell, do not reason about it (S128).** On bash 3.2 `${#arr[@]}` is FINE; the
  EXPANSION `"${arr[@]}"` is what aborts under `set -u`. The first fix guarded both on a guess, and
  the cold reviewer's counter-prediction was wrong too — tested at 102 elements, it did not
  reproduce.
- **An unescaped backtick inside a double-quoted `echo` is a COMMAND SUBSTITUTION (S128).** A
  disclosure line ran `vajra init` in this repo and hung the verify suite for nine minutes on its
  stdin prompt. Single-quote any echo that quotes a command.
- **A "nothing else moved" check that greps a HAND-TYPED list measures the boundary its author drew
  (S128, the session's fakest green).** Derive the inventory, declare each change with a reason, and
  make a STALE declaration fail too.
- **The scaffold is a FORK in more than one file (S128).** The 66-vs-183 constitution AND
  `src/cli/init.rs`'s 7-vs-11 `required_audits`. Assume any list in this repo has a scaffolded twin
  that has already drifted.
- **A role no gate consumes is decoration (S125).** Before adding role N, ask what blocks without it.
- **A block whose reason goes to stdout is invisible to the agent (S125).** Exit 2 stops the action;
  **stderr is what teaches.**
- **The "PR not yet opened" field is stale by construction every session (S125, 2nd sighting).**
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`.
- **Running the product is not enough to call a check execute-based (S121).** The ASSERTION has to
  bind to the behaviour.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S130.
- **A registered gate nobody executes is not a gate (S129).** `vajra next --check-plan` had been
  mis-parsing EVERY prompt since the heading `## Plan (ordered — cite the acceptance criteria each
  step covers)` was adopted — the acceptance parser matched on `contains("acceptance")`, so plan
  steps were counted as criteria, and the Planner station in `K of 8` reported PASSED off it. It
  surfaced only because one session's plan had more steps than criteria. **Run your gates.**
- **A derived artifact's DEFAULT decides whether it drifts; the check only tells you afterwards
  (S129).** Prefer moving the default to *carried*; add the check as the second opinion, never as
  the mechanism. And **a declaration that cannot go stale** — one that fails the BUILD — is the fix
  for S128's hand-typed-list class.
- **A branch that never runs is not a check (S129).** Plant a fixture that exercises it, or label it
  a STRUCTURAL NO-OP in the printed tally. Both were done this session.
- **Names are the identity; DETAILS are a silent channel (S129).** If you compare on identity, also
  compare the payload — and make a rewrite declare itself, with a reason, in the artifact the reader
  receives.
- **`.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` are COMPILE INPUTS now (S129)** and ship inside the
  published crate. A stray `{`, an emptied list or a parse failure in either **breaks a stranger's
  build**.
- **Assume any list in this repo has a scaffolded twin that has already drifted (S128, twice
  re-proved at S129).** Two cold readers each found one the builder had missed, both inside the
  blast radius of the fix. Three lists are derived; the fourth fork is named and open.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S126 added none; S128 added none — `--version` is a FLAG, and the verify
  suite drives eight candidate command words through the real binary to prove there is no 8th.
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions finish a shippable MVP (S103 pivot). **Current
  direction, as of the S127 closeout: the founder picked **first contact** over more fleet work —
  S128 fixed what a stranger actually hits, UNPARKING that slice of the S125 reboot backlog. The
  fleet stands at nine roles with ONE gate consuming a handoff; the rest of the reboot backlog
  stays parked.**
- **A recorded disposition certifies a typed word and a resolving sha — NOTHING MORE (S127).**
  Four `obeyed:` labels were factually wrong and passed the gate; only cold readers caught them.
  Never read an advice ledger's count as evidence the advice was followed.
- **A re-run handoff RENUMBERS (S127).** One role writes one handoff, so a second brief replaces
  the first at that path and previously-recorded answers silently re-point at different advice.
  The orphan warning does not fire when the counts happen to match.
- **Fence your examples (S127).** A fenced `## Advice` block inside a prompt was read as the real
  section — the gate found it on its own author's prompt. Strip fences BEFORE locating a heading,
  not merely before parsing its lines.
- **`handoff_body` drops every `#` line** — a marker-counter must read `handoff_findings_raw` (S127).
- **A probe that silently no-ops reports false comfort (S127).** Two falsifiability probes matched
  nothing after `cargo fmt` reflowed the lines and printed GREEN. Assert the pattern matched.
- **A role that PROPOSES never authors the marker its station parses (S126, nine times over).**
- **STATION ≠ ROLE:** the station governs the process (`src/qa/mod.rs`); the role does the work
  (`qa-specialist`). Same pattern for Reviewer/`fidelity-reviewer` and Planner/`plan-advisor` — a
  new role must take a distinct key, never the station's name.
