# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 127 — CODE: EVERY RECOMMENDATION MUST BE ANSWERED — COMPLETE (between sessions)

- **Verdict: ACCEPT** — independent cold `fidelity-reviewer`, **two passes**. Pass 1 **REJECT**
  (8 SHIPPED · 2 PARTIAL · 2 NOT-BUILT) and it was right; pass 2 **ACCEPT** (10 SHIPPED · 2 PARTIAL
  · 0 NOT-BUILT), both PARTIALs closed after it. Report: `sessions/session-127-summary.md`. Review:
  `sessions/session-127-review.md`. Prompt: `prompts/127-task-answer-every-recommendation.md`.
- **The first gate that CONSUMES a governed handoff.** `src/advice/mod.rs` reads the numbered
  `rec N —` markers out of a session's handoffs, reads its prompt's `## Advice`, and BLOCKS the
  close on any recommendation with no recorded disposition — `obeyed: <sha>` that resolves,
  `refused: <reason>` that is written, `deferred: <path>` that exists. `vajra next --advice NN` /
  `--check-advice NN`, wired into `--advance`. **No 8th command, no new store, no new artifact.**
- **`DECISION-007`'s S116 deferral is LIFTED** in an S127 addendum, out loud, rather than cited
  around — the Architect gate checks that a cited record EXISTS, not that the design obeys it.
- **Dogfooded on itself: 3 roles, 51 numbered recommendations, all answered.** The gate found two
  real defects in its own author mid-build. 360 lib tests · verify 10/10 · demo 13/13.

**🔴 THE RESIDUAL, UNSOFTENED — read it before quoting the 51:** **four `obeyed:` labels in that
ledger were WRONG and passed the gate.** One caught by pass 1, three more by pass 2 from the reflog
alone. *"The count would be identical if the advice had been read and ignored, provided the author
typed three words and pasted any commit from the branch."* **Required ≠ obeyed; answered ≠ obeyed
well.** And run against S126's own handoffs this gate exits 0 — it would not have caught either
drop that motivated it. **One gate of eight consumes handoffs.**

**Next = S128 — CODE: FIRST CONTACT WORKS (founder pick C, taken at the S127 closeout).**
Fix what a stranger actually hits, all four re-confirmed live in an empty directory at the S127
closeout: `vajra --version` does not exist (prints help, exit 0) · an unknown subcommand exits **0**,
so `vajra <typo> && deploy` runs deploy · `vajra check` on a fresh init is **9/11** including
`vajra.varta missing`, a file `init` never creates · `verify-closeout.sh` **crashes** on a fresh
repo under bash 3.2. Plus a `stranger_check` added to the required GT audits, because none of this
was catchable while every instrument measured Vajra governing itself.

**The founder's reasoning, carried because it shapes the work:** candidate B (a stronger `obeyed:`
check) was **rejected on principle** — an agent that reads advice and reports it did something it
did not is a truthfulness problem, and *"we can and should not build a mechanical guardrail to it."*
Candidate A was set aside because it extends a team nobody outside this repo can use yet.
**This UNPARKS the first-contact slice of the S125 reboot backlog; the rest stays parked.**

Full prompt: `prompts/128-task-first-contact-works.md` (**DRAFT** — the Analyst gate blocks until approved).
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
- **New session = new chat** — open a fresh chat for S128.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S126 added none (five roles, zero commands).
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions finish a shippable MVP (S103 pivot). **Current
  direction: FINISH THE SDLC AGENT FLEET (founder, S125 closeout) — *done* landed at S126, and
  S127 made ONE gate consume a role's output. Whether one of eight satisfies *working* is the
  founder's call at the S128 pick.**
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
