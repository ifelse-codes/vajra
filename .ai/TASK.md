# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 128 — CODE: FIRST CONTACT WORKS — COMPLETE (between sessions)

- **Verdict: ACCEPT** — independent cold `fidelity-reviewer`, **one pass**, 14 SHIPPED · 2 PARTIAL
  · 2 NOT-BUILT · 1 N/A. Both PARTIALs and both NOT-BUILTs closed after it read, each named as a
  post-ACCEPT closure rather than blended in. Report: `sessions/session-128-summary.md`. Review:
  `sessions/session-128-review.md`. Prompt: `prompts/128-task-first-contact-works.md`.
- **The first user-reachable change since S108 (2026-08-01, 20 sessions).** `vajra --version` /
  `-V` exists, read from the crate, a FLAG not an 8th command · an unknown subcommand exits **2**
  and names the word, so `vajra <typo> && deploy` cannot run deploy · `--help` and bare `vajra`
  still exit 0 · `verify-closeout.sh` runs to completion on a fresh scaffold under bash 3.2 ·
  `vajra check` on a fresh init is **10/11**, the `vajra.varta` demand RETIRED with the drift
  guard's teeth kept (absent+tracked FAILS, stale FAILS).
- **`stranger_check` is a required GT audit** — `scripts/stranger-check.sh`, a real empty dir, a
  real `git init`, the real binary, 16 checks. Falsifiable: each defect planted back turns it RED
  **through the check that owns it**; renaming a message leaves it GREEN.
- verify **9/9** · demo **13/13** · stranger **16/16** · fixture **12/12** · **364** tests ·
  `K of 8` unmoved · **7 commands**, no 8th.

**🔴 THE RESIDUAL, UNSOFTENED:** **the front door works; the SCAFFOLD is still a fork.** A stranger
gets a **66-line** constitution against this repo's **183**, and a **7-entry** `required_audits`
against this repo's **11** — `stranger_check` among the four missing. **The audit invented to
protect strangers does not reach them, and S128 REFUSED to fix that** (reviewer rec 4), because
registering a script the scaffold does not ship would make every stranger's GT fail a check it
cannot run. Two smaller residuals in the same place: a stranger's first `vajra check` still exits
**1**, and `vajra init` still blocks on stdin without EOF. And **0 stars · 0 forks · 0 issues ·
19 downloads** are unchanged — a working front door is a precondition for adoption, never evidence
of it.

**Next = S129 — the founder's pick from the three ranked candidates in
`sessions/session-128-summary.md`:**
- **A (recommended) — one source for what a stranger gets.** Kill the scaffold fork: same
  constitution, same required-audit list, derived, with a check that fails when the two drift.
- **B — decide the first-contact exit codes, and unblock `vajra init`.** Is a fresh `vajra check`
  exiting 1 right? Make `init` work without a TTY.
- **C — a paid dogfood ride-along through the new front door**, from a freshly scaffolded repo.

**S130 is the mandatory NO-CODE ground truth**, and the first one that must run `stranger_check`.

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
- **New session = new chat** — open a fresh chat for S129.
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
