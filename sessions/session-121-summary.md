# Session 121 — Summary

**Goal:** add `qa-specialist` as the fleet's fourth role — the first with full execution
capability. "All approved" at kickoff. Branch: `session-121-qa-specialist`.

## Goal achieved?

**Yes.** Cold fidelity-reviewer **ACCEPT**, 5 of 6 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.
`verify-session-121.sh` exits 0 — 17 of 17 checks green. 335 lib tests (was 334).

## What shipped

| Piece | Where | What it does |
|---|---|---|
| The role | `src/fleet/mod.rs` — `qa-specialist` | Runs the session's verify script and classifies every check: execute-based vs behavioral source grep (hollow) vs structural grep (fine) |
| The grant | `tools: Bash, Read, Write, Edit, Grep, Glob` | The fleet's FIRST executing role. Every other role stays read-only, enforced as an allowlist of exactly one name |
| Scaffold | `.claude/agents/qa-specialist.md` | Copied byte-for-byte out of a fresh `vajra init`, never hand-written. `src/cli/init.rs` needed zero changes |
| The decision | `DECISION-007` S121 addendum | The key, the Bash rationale, THREE rejected alternatives, and the residual risk stated plainly |
| The suite | `scripts/verify-session-121.sh` | 17 checks that classify THEMSELVES: 13 execute-based · 3 structural · 1 behavioral |

## Fidelity check — every numbered requirement

| # | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | `qa-specialist` registered with `Bash, Read, Write, Edit, Grep, Glob` | SHIPPED | `src/fleet/mod.rs` `ROLES` entry + two named tests, incl. `ROLES.iter().filter(Bash).count() == 1` |
| 2 | `vajra init` scaffolds 4 agent files; the QA one carries Bash | SHIPPED | `init-scaffolds-four-roles` RUNS the binary into a temp repo: 4 files, byte-identical to the repo's copies, exactly one grants Bash |
| 3 | `--role qa-specialist --from <file>` governs a handoff; fail-closed | SHIPPED | `e2e-four-governed-handoffs`: collision word / no `--from` / empty / missing file all rejected; handoff written with a `source-sha` independently recomputed |
| 4 | `DECISION-007` S121 addendum, ≥2 rejected alternatives | SHIPPED | 79-line addendum, three rejected alternatives, residual-risk paragraph |
| 5 | All verify checks green; `no_eighth_command` holds | PARTIAL | Suite exits 0 (log at `sessions/session-121-artifacts/verify-run.log`), but the cold pass could not read greenness out of a diff, and `no-eighth-command` greps a hardcoded banner — now reclassified BEHAVIORAL rather than left labelled `exec` |
| 6 | Cold `fidelity-reviewer` ACCEPT | SHIPPED | `sessions/session-121-review.md`, attested `c92a2dad…` |

**What I did NOT build:** the agent was never dispatched. Nothing in this session ran it. Per the
S111 finding an agent file written mid-session is invisible to that same session, and the prompt
made dispatch an explicit non-goal — it is S122's job.

**The fakest green:** the check-class tally is **a label the author typed**. Nothing verifies that a
check marked `exec` executes anything; relabel them all and the summary still prints
`behavioral source grep: 0`. Quoted in full in the review record. Do not cite that number as a
measurement anywhere. What the cold review did buy: `no-eighth-command` was caught mislabelled and
reclassified, so the honest tally is 13 / 3 / 1 and the `NOTE:` disclosure branch now fires on
every run instead of being dead code.

## Found live, worth carrying

- **`vajra init` hangs forever on stdin** when its runner never sends EOF. A background run of the
  verify suite hung 10 minutes inside `verify-session-113.sh`. Both `init` calls in the new script
  now redirect `</dev/null`; older scripts still have the hazard.
- **`verify-session-116.sh` goes red by construction** against this branch: the fleet grew to four
  and the every-role-is-read-only invariant was deliberately CHANGED (hence the test was renamed,
  not loosened). Fourth session of per-session-snapshot decay — disclosed in a comment, which is
  not a gate.

## Cost

~$0 marginal beyond the session itself: one cold `fidelity-reviewer` subagent pass (≈56k subagent
tokens). No paid dogfood run.

## POST-CLOSE: the first live run happened after all (founder-directed)

After closeout went green and PR #131 opened, the harness registered `qa-specialist` as a
dispatchable agent **inside its own creating session** — contradicting the S111 rule this session's
non-goal and S122's prompt both rest on (second observation; the first was `fidelity-reviewer` at
S114). The founder directed the dispatch on the spot.

**Result:** resolved by name, first try, no workaround. It ran the suite (exit 0, 17/17), classified
all 17 checks independently, and **agreed with every self-assigned label** — the labels survived
scrutiny. It changed nothing: HEAD sha, git index hash and `git status --porcelain` were byte-identical
before and after, checked rather than trusted.

**It then found four defects this session missed** — the tally is not compositional (the nested S113
suite carries a second hollow banner grep, so the true hollow count is 2 not 1); an unanchored
`^tools: Read, Grep, Glob` prefix grep that a leaked `Write`/`Edit` would pass; a booby-trap in
`one_source_of_role_text` (it does not exclude `.ai/handoffs/`, so a future QA report quoting its
probe sentence flips the suite RED for reasons its message won't explain); and a near-tautological
render test (`def.contains(role.system_prompt)` — an empty prompt passes). Full brief:
`sessions/session-121-artifacts/qa-specialist-live-run.md`.

**The honest reading, recorded against this session's own interest:** none of those four needed
Bash. They came from careful independent READING. Execution bought the exit code and `335 passed`.
So the run strongly supports *"an independent agent finds real defects"* and only weakly supports
this session's actual claim, *"an executor cannot fake a pass."* **The executor thesis is still
unproven.** The agent's own words on the residual risk: *"that constraint held because I chose to
hold it, which is not a control."*

**Nothing was fixed here.** The four defects are S122's payload; the reviewed diff (and therefore the
attested `Review-Inputs-SHA`) is untouched — every file changed in this post-close pass is one the
canonical hash excludes by design.


## Next — pick one

**A. Prove the dispatch, and take the first live QA run (recommended).**
*Goal:* a fresh session dispatches `subagent_type: "qa-specialist"` by name, hands it a real
session's verify script, and governs the result through `vajra next --role qa-specialist --from`.
*Why:* it is the exact S114→S115 and S116→S117 pattern, and it is the only thing that converts
"the first agent that can execute" from a frontmatter string into a measured property. It also
tests the one claim this session could not: that an executor cannot fake a pass.
*Risk:* the agent runs the suite and reports a tally as flat as the one the author typed — which
would be a real, useful finding, not a failure.

**B. Give the class tally teeth.**
*Goal:* stop the classification being a self-assigned digit-tag — derive or cross-check the class
from what the check actually does, so a mislabelled `exec` turns the suite red.
*Why:* it kills this session's fakest green at the root, and the same "self-asserted marker" class
has now been disclosed at S64 (`covers:`), S67 (design), and here.
*Risk:* genuinely hard to do honestly; the naive version (grep the check body for `cargo`/`$VAJRA`)
is itself a behavioral source grep — the disease wearing a lab coat.

**C. Retire the house-wide `no-eighth-command` weak check.**
*Goal:* assert the command table, not the printed banner, so an 8th command cannot slip in behind
a stale usage string.
*Why:* flagged for 9+ consecutive CODE sessions and now formally classified hollow by this
session's own taxonomy.
*Risk:* smallest payload of the three; it fixes one check, not the class of defect.
