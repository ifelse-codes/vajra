# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 131 — CODE (fidelity-reviewer mandatory + provable) — COMPLETE (between sessions)

- **Goal achieved.** A session can no longer close with zero `fidelity-reviewer` handoffs — the
  exact falling-usage failure S130's ground truth measured (S126 5 → S127 3 → S128 1 → S129 **0**).
  New `--check-fidelity-handoff` gate (own command) BLOCKS at L2/L3 on absence, malformation, or
  unverifiable provenance, no legacy WARN escape; wired into `--advance`. `src/dispatch/mod.rs`
  derives + independently re-verifies the `agent:` provenance field from real Claude Code dispatch
  evidence (parent transcript ↔ subagent `meta.json`, bound to the session via the subagent's own
  recorded `gitBranch`) — replacing the hardcoded `"claude-code-subagent"` literal.
- **Independent cold review: ACCEPT, 7/8 SHIPPED**, attested. 4 recommendations, all answered — 3
  obeyed, 1 (bind a dispatch's own content to the specific `--from` findings file it stamps)
  deferred to `.ai/ROADMAP.md` F2, a real design decision correctly kept out of this session's
  locked one-story scope.
- **The fakest green, named plainly:** dispatch evidence is unsigned and forgeable by anyone with
  shell access to this machine — this session's own fixtures prove it in three `printf` calls.
  "Provable" raises the forgery bar over a hardcoded string; it is not tamper-proof, and the
  DECISION-007 addendum says so in exactly those words now.
- **Live evidence:** `verify-session-131.sh` **10/10 GREEN**, `demo-session-131.sh` **8/8 GREEN**,
  both driving the real release binary against throwaway repos. `K of 8` and the 7-command floor
  unchanged, confirmed live — S131's gate is a fleet gate, not a 9th station.
- Reports: `sessions/session-131-summary.md`, `sessions/session-131-review.md`.

**Next: Session 132.** Prompt: `prompts/132-task-verify-advice-obeyed.md`. Locked at the S130
closeout: verify a recorded `obeyed:` disposition is actually TRUE, not merely a resolving sha —
closing the S127 residual (`implementation-advisor` rec 9, `obeyed: 8cd3bea`, stub still present,
caught only by a cold reader). Two open design questions left explicit in the prompt for S132 to
resolve. Planner + Architect gates both report READY on it already.

**New chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **A GT session (`NN % 5 == 0`) cannot commit on its own branch** — the hook blocks it. Closeout
  commits ride a `session-NN-closeout` branch (the exempt suffix).
- **Attest LAST (S69), and hash the LIVE PROMPT, not just the diff (S131 sharpening):**
  `Review-Inputs-SHA` = sha256(`HEAD:prompt` ‖ diff) — the prompt file's OWN bytes are hashed
  directly, not only through the (prompts-excluded) diff half. Filling `## Execution`/`## Advice`/
  `## Design` in the prompt AFTER a first `--inputs-sha` run silently invalidates it. Recompute
  AFTER every edit to the prompt, not just after the code diff stabilises; two consecutive
  `verify-closeout.sh --inputs-sha NN` runs must agree before embedding.
- **`cargo test` accepts exactly ONE `TESTNAME` filter (S131).** Two module paths in one invocation
  silently errors as "unexpected argument," not a multi-filter — two separate invocations, `&&`'d
  if both must pass.
- **A Claude Code subagent transcript's FIRST JSONL line carries `gitBranch` (S131, measured).**
  Free, forger-independent-of-clock evidence for binding a dispatch to the session that made it.
  `agent-<id>.meta.json` does NOT carry it — read the sibling `.jsonl`'s first line separately.
- **Dispatch evidence (`agent-*.meta.json` / `.jsonl`) is UNSIGNED and hand-fabricable by anyone
  with shell access to this machine (S131).** "Provable provenance" raises a forgery bar; it is not
  tamper-proof. Say so in those words, not "local-machine-only" (which undersells the limit).
- **A recorded claim and a verified one are not the same thing, and this repo keeps re-discovering
  it one layer down (S131).** S127: an `obeyed:` sha resolves ≠ the commit does what it claims.
  S131: a real dispatch occurred ≠ its findings are what got ingested (rec 4, deferred). Assume the
  next layer has the same gap until something actually checks it.
- **Fill the Coder-gate `## Execution` shas before closeout, every session (S124).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).** A unit test that asserts on
  exact error-message TEXT makes the "renaming must stay GREEN" direction impossible to satisfy
  honestly (S131 hit this live, fixed by asserting behavior/`Err`-ness, not wording, in the three
  affected tests).
- **Never trust a launched/dispatched agent's own self-report as evidence its criteria were met
  (S124).**
- **Never test the product only in the repo that builds it (S125).** Every bug S125 found was
  invisible for 125 sessions because no audit ever ran `vajra init` in an empty directory.
- **Measure the shell, do not reason about it (S128).**
- **An unescaped backtick inside a double-quoted `echo` is a COMMAND SUBSTITUTION (S128).**
- **A "nothing else moved" check that greps a HAND-TYPED list measures the boundary its author drew
  (S128).** Derive the inventory; make a STALE declaration fail the build.
- **The scaffold is a FORK in more than one file (S128).** Assume any list in this repo has a
  scaffolded twin that has already drifted.
- **A role no gate consumes is decoration (S125).** Before adding role N, ask what blocks without it.
- **A block whose reason goes to stdout is invisible to the agent (S125).** Exit 2 stops the action;
  **stderr is what teaches.**
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`.
- **Running the product is not enough to call a check execute-based (S121).** The ASSERTION has to
  bind to the behaviour.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S132.
- **A registered gate nobody executes is not a gate (S129).** Run your gates.
- **A derived artifact's DEFAULT decides whether it drifts (S129).** Prefer moving the default to
  *carried*; add the check as the second opinion.
- **A branch that never runs is not a check (S129).**
- **Names are the identity; DETAILS are a silent channel (S129).**
- **`.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` are COMPILE INPUTS now (S129)**, ship inside the
  published crate.
- **Assume any list in this repo has a scaffolded twin that has already drifted (S128, S129).**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S131 added none (`--check-fidelity-handoff` rides `vajra next`).
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions finish a shippable MVP (S103 pivot). **The fleet stands
  at nine roles with ONE now mandatory (S131) — the rest of the reboot backlog stays parked.**
- **A recorded disposition certifies a typed word and a resolving sha — NOTHING MORE (S127).**
  S132's whole job is closing this for `obeyed:` specifically.
- **A re-run handoff RENUMBERS (S127).**
- **Fence your examples (S127).**
- **`handoff_body` drops every `#` line** — a marker-counter must read `handoff_findings_raw` (S127).
- **A probe that silently no-ops reports false comfort (S127).** Assert the pattern matched.
- **A role that PROPOSES never authors the marker its station parses (S126).**
- **STATION ≠ ROLE:** a fleet role must take a distinct key from any station beside it (S114, S116,
  S121, and now S131's own gate command choice follows the same reasoning).
