# Session Boot

## Current Session
- **Number:** 127 — COMPLETE
- **Type:** CODE — every recommendation must be ANSWERED (obeyed, refused, or deferred). Founder
  direction at the S126 closeout, rewritten from "a handoff exists" to "the answer is recorded":
  *"the obeying is what all Vajra is — the agent obeys the prompt, and obeys in a deterministic
  way."*
- **Goal:** Make every numbered recommendation in a session's governed handoffs carry a recorded
  disposition, and BLOCK the close of a session that leaves any of them unanswered.
- **Verdict:** **ACCEPT** — independent cold `fidelity-reviewer`, **two passes**. Pass 1 **REJECT**
  (8 SHIPPED · 2 PARTIAL · 2 NOT-BUILT) and it was right; pass 2 **ACCEPT** (10 SHIPPED · 2 PARTIAL
  · 0 NOT-BUILT), both PARTIALs closed after it read. **The first gate that CONSUMES a governed
  handoff as a binding input** (`src/advice/mod.rs`): `obeyed: <sha>` that resolves · `refused:
  <reason>` that is written · `deferred: <path>` that exists. `vajra next --advice NN` /
  `--check-advice NN`, wired into the close path. **No 8th command, no new store, no new artifact
  type.** `DECISION-007`'s S116 deferral **LIFTED** out loud in an S127 addendum. 360 lib tests ·
  verify 10/10 · demo 13/13 · `K of 8` unmoved.
- **Dogfooded on itself:** 3 roles, **51 numbered recommendations, all answered**. The gate found
  two real defects in its own author mid-build (heading-form recs dropped by `handoff_body`; a
  fenced `## Advice` example read as the real section).
- **🔴 The residual, unsoftened:** **four `obeyed:` labels in that 51-answer ledger were WRONG and
  passed the gate** — one caught by pass 1, three by pass 2, from the reflog alone. *"The count
  would be identical if the advice had been read and ignored."* A disposition certifies a typed
  word and a resolving sha, and nothing else. **It forces an ANSWER, never obedience.** And run
  against S126's own handoffs this gate exits 0 — it would not have caught either drop that
  motivated it. **One gate of eight consumes handoffs.**
- **Report:** `sessions/session-127-summary.md` · **Review:** `sessions/session-127-review.md` ·
  **Prompt:** `prompts/127-task-answer-every-recommendation.md`. **Date last updated:** 2026-08-22.
- **Branch:** `session-127-answer-every-recommendation`. S128 starts from a fresh
  `session-128-*` branch and a new chat.

## Previous Session
- **Number:** 126 — COMPLETE
- **Type:** CODE — finish the SDLC agent fleet: the last five roles, in one pass.
- **Verdict:** **ACCEPT** — 7 of 9 SHIPPED, 2 PARTIAL, 0 NOT-BUILT. The roster completed at **nine
  roles**, five added with **zero** new grants of `Bash`, all five dispatched by name from separate
  headless sessions ($4.4482 metered).
- **Its residual, now half-closed:** the roster was complete and nothing depended on it. S127 made
  one gate depend on a role's output.
- **Report:** `sessions/session-126-summary.md` · **Review:** `sessions/session-126-review.md`.

## Repo State Snapshot
- `.ai/SESSION` = 127. Branch `session-127-answer-every-recommendation` (merged via PR — read git,
  not this line). S128 starts from a fresh `session-128-*` branch.
- **The headline, in one line: advice you asked for can no longer be dropped in silence — and the
  session that shipped that gate dropped four pieces of advice in a way the gate could not see.**
  Both halves are true and both belong in the same sentence.
- **What is new and load-bearing:**
  - `src/advice/mod.rs` — the gate. Reads numbered `rec N —` markers out of governed handoffs,
    reads the prompt's `## Advice`, classifies each item answered / unanswered /
    claimed-but-not-real, and BLOCKS on the last two. `Malformed` fails closed; `NoRecommendations`
    WARNs and names its own dodge (`advice::DODGE`, one const).
  - `fleet::handoff_findings_raw` + `Handoff.raw_body` — the region a marker-counter must read.
    `handoff_body` drops every `#` line, which silently under-counted heading-form recommendations.
  - One `RECOMMENDATION_NUMBERING_RULE` rendered into every `ROLES` entry, so a tenth role inherits
    the contract with no edit; asserted per role and round-tripped through the real parser.
- **The numbers:** 360 lib tests · verify **10/10** (9 execute-based · 1 behavioral, labelled) ·
  demo **13/13** (all execute-based) · `K of 8` = 8 of 8 at S126, unmoved · 7 commands, no 8th.
- **The falsifiability fixture has four states** and was probed live: deleting the answer
  classification, deleting the recommendation parser, turning the disclosed dodge into a block,
  silencing it, and collapsing `NoRecommendations` into `NoHandoffs` each turn it RED; renaming
  every gate message leaves it GREEN.
- **Two cold passes, two real catches.** Pass 1: a stub the advice said to delete, still in the
  file, recorded `obeyed:`. Pass 2: three more mis-certified dispositions, found from the reflog.
  Every rejection so far in this project's history has been correct; that record holds.

## Next Session
- **Number:** S128 — **founder pick pending.** Exactly three ranked candidates, in
  `sessions/session-127-summary.md`:
  - **A (recommended) — make a SECOND gate consume its role's handoff.** QA or Demo-er, both of
    which already re-run live. *Why:* the honest headline is still "one of eight"; the second
    consumer is where "the fleet works" becomes a claim about the fleet rather than about a gate.
    *Risk:* a second consumer nothing reaches for is a second decoration — pick the station whose
    role is actually dispatched.
  - **B — close the `obeyed:` hole.** Bind the disposition to the diff (the sha must be an ancestor
    of HEAD and not on `main`, or must touch a file the recommendation names). *Why:* it is S127's
    disclosed fakest green, with four live specimens. *Risk:* the honest ceiling is low and easy to
    oversell — "touches a file the advice mentions" is still not "implements the advice".
  - **C — unpark the S125 reboot backlog.** The 55-line scaffolded constitution,
    `verify-closeout.sh` crashing on a fresh `vajra init`, unknown subcommands exiting 0. *Why:*
    the only items a stranger would ever notice; adoption is flat. *Risk:* it is the founder's call
    whether one consuming gate satisfies *working*.
- **The prompt is scaffolded DRAFT** and the Analyst gate blocks the advance until the founder
  flips it to APPROVED — that gate is deliberately the place this decision is recorded.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

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
