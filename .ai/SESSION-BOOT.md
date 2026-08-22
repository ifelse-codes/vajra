# Session Boot

## Current Session
- **Number:** 128 — COMPLETE
- **Type:** CODE — first contact works: fix what a stranger actually hits. Founder pick **C** at
  the S127 closeout, in their words: candidate B was *rejected on principle* (a mechanical
  guardrail is the wrong tool for an agent that reports it did something it did not), candidate A
  extends a team nobody outside this repo can use yet, and **C is the only option where a stranger
  notices the difference.**
- **Goal:** make the first ten minutes with Vajra work — a version flag that exists, a front door
  that fails CLOSED on a typo, a health check that is honest on a fresh repo, a closeout script
  that does not crash on the default macOS shell, and an audit that stops the class recurring.
- **Verdict:** **ACCEPT** — independent cold `fidelity-reviewer`, **one pass**, no re-run, no
  renumbering. **14 SHIPPED · 2 PARTIAL · 2 NOT-BUILT · 1 N/A**; both PARTIALs and both NOT-BUILTs
  closed after it read, each named as a post-ACCEPT closure rather than blended in. **The first
  user-reachable change since S108, twenty sessions ago.**
- **What a stranger gets now:** `vajra --version` / `-V` (read from the crate, a FLAG not an 8th
  command) · an unknown subcommand exits **2** and names the word, so `vajra <typo> && deploy`
  cannot run deploy · `--help` and bare `vajra` still exit 0 · `verify-closeout.sh` runs to
  completion on a fresh scaffold under bash 3.2 · `vajra check` on a fresh init is **10/11**, the
  `vajra.varta` demand RETIRED with the drift guard's teeth kept.
- **`stranger_check`** is now a required GT audit (`scripts/stranger-check.sh`: real empty dir,
  real `git init`, real binary, 16 checks), and it is falsifiable — each defect planted back turns
  it RED **through the check that owns it**, while renaming a message leaves it GREEN.
- **The numbers:** verify **9/9** · demo **13/13** · stranger **16/16** · fixture **12/12** ·
  **364** tests · `K of 8` unmoved in derivation and shape · **7 commands**, no 8th.
- **🔴 The residual, unsoftened:** **the front door works; the SCAFFOLD is still a fork.** 66-line
  constitution vs this repo's 183, AND a 7-entry `required_audits` vs this repo's 11 —
  `stranger_check` among the four missing. *The audit invented to protect strangers does not reach
  them*, and **S128 REFUSED to fix that** (reviewer rec 4, refused with a reason). Smaller and also
  unfixed: a stranger's first `vajra check` still exits **1**; `vajra init` still blocks on stdin.
  And **0 stars · 0 forks · 0 issues · 19 downloads**, unchanged.
- **Report:** `sessions/session-128-summary.md` · **Review:** `sessions/session-128-review.md` ·
  **Prompt:** `prompts/128-task-first-contact-works.md`. **Date last updated:** 2026-08-22.
- **Branch:** `session-128-first-contact-works`. S129 starts from a fresh `session-129-*` branch
  and a new chat.

## Previous Session
- **Number:** 127 — COMPLETE
- **Type:** CODE — every recommendation must be ANSWERED (obeyed, refused, or deferred).
- **Verdict:** **ACCEPT** (two passes; pass 1 REJECT and it was right). The first gate that
  CONSUMES a governed handoff as a binding input — `src/advice/mod.rs`.
- **Its residual, still standing:** four `obeyed:` labels in its own 51-answer ledger were
  factually wrong and passed the gate. A disposition certifies a typed word and a resolving sha,
  and nothing else. **S128 used that gate on its own reviewer's eight recommendations** — 7
  obeyed, 1 refused with a reason — and the same caveat applies to that count.
- **Report:** `sessions/session-127-summary.md` · **Review:** `sessions/session-127-review.md`.

## Repo State Snapshot
- `.ai/SESSION` = 128. Branch `session-128-first-contact-works` (PR to open — read git, not this
  line). S129 starts from a fresh `session-129-*` branch.
- **The headline, in one line: the product finally works for someone who is not us — and the thing
  we hand them is still not the thing we run.** Both halves are true and both belong in the same
  sentence.
- **What is new and load-bearing:**
  - `src/main.rs` — the front door fails CLOSED. `Unknown(String)` carries the offending word,
    exits `EXIT_UNKNOWN_COMMAND` = 2. `Version` prints `env!("CARGO_PKG_VERSION")`.
  - `src/cli/check.rs` — **the one evidence contract that MOVED this session, by order.** The varta
    drift guard now separates *absent* from *stale*: absent+untracked PASSES (labelled optional),
    absent+**tracked by git** FAILS, present+different FAILS. `is_tracked_by_git` is the
    discriminator. Declared as a change in the verify suite rather than hidden behind a boundary.
  - `scripts/stranger-check.sh` — the only instrument here that measures the PRODUCT.
  - `scripts/fixture-session-128.sh` — plants each defect back; `plant()` exits 3 when its pattern
    matches nothing, so a silent no-op cannot print green.
  - `scripts/verify-closeout.sh` — bash 3.2 safe. Measured: `${#arr[@]}` is fine on 3.2, the
    EXPANSION is what aborts.
- **Two real defects found while writing the suites, both fixed and both recorded:** matching the
  word `FAIL` caught the `Score: 10/11 — 1 FAILED` tally line (fixed by matching the STATUS COLUMN,
  not by excluding the tally by name — an exclusion list is the hole, S122); and an unescaped
  backtick in a double-quoted disclosure `echo` **command-substituted and ran `vajra init` in this
  repo**, hanging the verify suite for nine minutes on its stdin prompt.
- **The cold reviewer's own limit on its ACCEPT, carried verbatim:** *"my ACCEPT does not certify
  per-commit content"* — it had no shell, so sha→work was verified from reflog subjects and the
  final tree, not from `git show --stat`.

## Next Session
- **Number:** S129 — **CODE: one source for what a stranger gets.** **Founder pick A**, taken at the
  S128 closeout after the three candidates were put to them in plain English.
- **Goal:** make the scaffold a DERIVED artifact of this repo's governance instead of a hand-typed
  copy — for BOTH the constitution and the required-audit list — plus a check that goes RED when
  the two drift.
- **The fork, measured:** `vajra init` writes a **66-line** `AGENTS.md` while this repo runs
  **183**; the scaffolded `required_audits` has **7** entries against this repo's **11**, missing
  `stranger_check`, `dogfood_check`, `pipeline_advance_check` and `dogfood_staleness`. In the S128
  reviewer's words: *"A stranger's ground truth will never run the audit invented to protect
  strangers."*
- **Why A:** it is the same blind spot as all four S128 defects, one level deeper — nobody ever
  looked at what `init` actually hands over. **B** (the small first-contact residuals: a fresh
  `vajra check` exiting 1, `vajra init` blocking on stdin) and **C** (a paid ride-along from a
  fresh scaffold) were not picked and stay on the shelf.
- **The trap, named before it is walked into:** the two files are **not supposed to be identical**.
  This repo's constitution names ADRs, session numbers, hooks and a fleet a stranger's project has
  none of. *"Derive from one source"* may mean writing a real derivation, not an `include_str!` —
  and that decision is the session's load-bearing deliverable, recorded in `## Design` before code.
- **The counter-example that proves it is cheap:** `scripts/verify-closeout.sh` is already
  `include_str!`'d into the scaffold and is byte-identical in both places, which is why S128's
  bash-3.2 fix reached every future scaffold for free.
- **Full prompt:** `prompts/129-task-one-source-scaffold.md` — **APPROVED**.
- **S130 is the mandatory NO-CODE ground truth** — and the first GT that must run `stranger_check`.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S128)
- **Measure the shell; do not reason about it.** On bash 3.2 `${#arr[@]}` is FINE and `"${arr[@]}"`
  is what aborts under `set -u`. The first fix guarded both on a guess. The cold reviewer's
  counter-prediction (`[: too many arguments` at ~100 elements) was ALSO wrong — tested at 102, it
  did not reproduce. Two guesses, two misses, one cheap measurement.
- **An unescaped backtick inside a double-quoted `echo` is a command substitution.** A disclosure
  line executed `vajra init` in this repo. Single-quote any echo that quotes a command.
- **A "nothing else moved" check that greps a hand-typed list measures the boundary its author
  drew.** It also passes if the session shipped nothing. Derive the inventory; declare each change
  with a reason; make a STALE declaration fail too.
- **The scaffold is a fork in more than one file.** Assume any list in this repo has a scaffolded
  twin in `src/cli/init.rs` that has already drifted — the constitution AND `required_audits` both
  had.
- **Match the STATUS COLUMN, not the word.** `grep FAIL` catches the tally line `1 FAILED`. The fix
  is a tighter match, never an exclusion list naming the tally (S122).
- **A refusal is a pass, and it has to be said twice** — once in the disposition, once in the
  summary where a reader will actually see it. Reviewer rec 4 is refused, and item 2 of the
  stranger-still-broken list is that refusal, in plain words.

## Carry-Forwards (NEW from S127)
- **A recorded disposition certifies a typed word and a resolving sha — NOTHING MORE.** Four
  `obeyed:` labels were factually wrong and passed. Never read an advice ledger's count as evidence
  the advice was followed. **Required ≠ obeyed; answered ≠ obeyed well.**
- **A re-run handoff RENUMBERS.** One role writes one handoff, so a second brief replaces the first
  at that path and previously-recorded answers silently re-point at different advice. The orphan
  warning does not fire when the counts happen to match.
- **Fence your examples.** A fenced `## Advice` block inside a prompt was read as the real section
  — found by the gate, on its own author's prompt. Strip fences BEFORE locating a heading.
- **A probe that silently no-ops reports false comfort.** Two falsifiability probes matched nothing
  after `cargo fmt` reflowed the lines, and printed GREEN. Assert the pattern matched.
- **`hook-session-guard.sh` false-arms on PROSE.** Writing STATE.md text that merely *described*
  the advance command tripped the one-session-per-chat block: the guard's quoted-span strip only
  removes shell quotes, and a heredoc body is unquoted. S125's "spelling-bound guards over-block on
  words", recurring inside the enforcement layer. Worth a fix, not a workaround.

## Carry-Forwards (NEW from S125)
- **"Done AND working" is the founder's gate, and *working* is the load-bearing half.** S125
  findings 1–3 say the four roles already built are never reached for, because the shipped scaffold
  never asks and no gate depends on them. Roles 5–9 inherit that unless F1/F2 land — **proving the
  fleet works may BE F2 (the dispatch receipt), not something that follows it.**
- **A role that no gate consumes is decoration.** `fleet::read_handoffs` feeds advisory display and
  Analyst intake only. Before adding role N, ask what blocks without it.
- **Never test the product only in the repo that builds it.** Every bug S125 found was invisible
  for 125 sessions because no required audit ever ran `vajra init` in an empty directory.
- **A block whose reason goes to stdout is invisible to the agent** (`No stderr output`). Exit 2
  stops the action; **stderr is what teaches.**
- **Spelling-bound guards over-block on words and under-block on behaviour** — measured both ways
  in `hook-pre-bash.sh` this session. (The S122 `fixture-right-reason` lesson, recurring inside the
  enforcement layer itself.)
- **The "PR not yet opened" field is stale by construction every session** — the closeout snapshot
  is written before the PR is opened. 2nd sighting (S65 found it at S64). Do not fix by hand again.

## Carry-Forwards (from S124)
- **Never trust a launched/dispatched agent's self-report as evidence its own criteria were met**
  — reconfirmed with a concrete, caught instance.
- **A harness's own documented safety claim needs independent verification too** — "bounded by
  `TIMEOUT_SECS`" was false in practice; the watchdog's kill never reached the child process.
- **`vajra init`'s skip-if-present is file-granularity, not key-granularity** — a new template key
  cannot be merged into an existing target file automatically.
- **Fill the Coder-gate `## Execution` shas before closeout, every single session.**

## Carry-Forwards (from S123)
- **A falsifiability fixture must fail for the RIGHT reason.** Clean the planted defect out of the
  directory before testing the next branch.
- **Expect more than one cold pass.** Every rejection so far has been correct. Budget for it.
- **Do not fix findings after the ACCEPT.** File them into the next prompt instead.
- **Widening an exclusion list is not a fix.**
