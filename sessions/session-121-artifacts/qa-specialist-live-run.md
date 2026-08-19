# S121 — the FIRST live run of the `qa-specialist` role (post-close, founder-directed)

**When:** 2026-08-18, after S121's closeout went green and PR #131 was opened.
**Why it happened here and not at S122:** the harness registered `qa-specialist` as a dispatchable
agent type **inside the session that created it**, contradicting the S111 rule S121's records and
S122's prompt both rest on. The founder directed the dispatch on the spot.

## Dispatch result

- `subagent_type: "qa-specialist"` resolved **by name, first try, no workaround**, in its own
  creating session. Second time this contradiction has been observed (the first was
  `fidelity-reviewer` at S114, recorded as an open question at S115 and never closed).
- Brief given: run `scripts/verify-session-121.sh`, classify every check independently, compare
  against the script's self-assigned labels, report what the suite never exercises. Explicit
  constraints: no edits, no commits.

## The no-edit constraint held — and was CHECKED, not trusted

| Probe | Before | After |
|---|---|---|
| `git rev-parse HEAD` | `01229d05…` | `01229d05…` |
| `git ls-files -s \| shasum -a 256` | `75ce211a…` | `75ce211a…` |
| `git status --porcelain` | 44 lines | identical, byte for byte |

The agent's own disclosure on this: *"that constraint held because I chose to hold it, which is not
a control."* Correct, and it is the S121 residual risk restated by the agent that holds it — the
`Write`/`Edit` grant is documented, not fenced.

## What it ran

`bash scripts/verify-session-121.sh < /dev/null` → **exit 0, 17/17 ALL GREEN.**
Corroborated from the per-check logs: `test result: ok. 335 passed; 0 failed`;
`rejected-alternative bullets inside the S121 addendum: 3`; `scaffolded roles granted Bash: 1`;
nested `s113-counter-still-green` → `ALL GREEN (14 pass, 0 fail)`.

## Its independent classification

It classified all 17 checks from source before comparing, and **agreed with every self-assigned
label — zero disagreements** (13 execute-based · 3 structural · 1 behavioral). It specifically
credited `no-eighth-command` being labelled `behav` when running the real binary would have let it
wear the `exec` costume.

## The four defects it found (NOT fixed here — S122's job)

1. **The tally is not compositional.** `s113-counter-still-green` is one slot hiding 14 checks, and
   `verify-session-113.sh` contains its OWN `no-eighth-command` with the identical hardcoded-banner
   grep. **The true count of hollow checks that executed in this run is 2, not 1.** `fleet-smoke`
   likewise runs twice (directly, and again nested inside S113).
2. **An unanchored grep in the read-only guard.** `init-scaffolds-four-roles` asserts
   `grep -q "^tools: Read, Grep, Glob"` — a PREFIX match, load-bearing because the Researcher's real
   grant is `Read, Grep, Glob, WebSearch, WebFetch`. A leak of `Write` or `Edit` onto a read-only
   role (`tools: Read, Grep, Glob, Write`) **passes this check**: the sibling `NEXEC` count only
   greps `Bash`, and the other guard only covers `NotebookEdit`. Caught only by the unit test
   `fleet::tests::tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone`, whose
   forbidden list does include Write/Edit — covered, but by a different check than the one that
   looks like it covers it.
3. **A live booby-trap in `one_source_of_role_text`.** Its exclusion list does not cover
   `./.ai/handoffs/` — exactly where this role's governed handoff lands. Any future QA report that
   quotes the probe sentence verbatim makes the carrier count 2 and flips the check RED, with a
   failure message that does not point at its cause. The agent dodged it deliberately by
   paraphrasing that sentence throughout its brief.
4. **`test-render-every-role` is near-tautological.** `render_subagent_definition_is_correct_for_every_registered_role`
   asserts `def.contains(role.system_prompt)` — the render checked against the same struct field it
   renders from. An empty `system_prompt` satisfies `contains("")`. It verifies template wiring, not
   content.

Also noted, not defects: `init-scaffolds-four-roles` greps the GENERATED file for the role's
behavioural instructions (proves the text was emitted, not that anything obeys it — same epistemics
as a source grep, kept off the hollow tally because the target is generated output); `cargo-fmt` and
`cargo-clippy` occupy 2 of the 13 `exec` slots while asserting nothing about the feature.

## What it said the green suite never exercises

- **The role was never dispatched by the suite.** Every claim about the QA Specialist *working*
  rests on rendered text, not a booted agent.
- **Nothing proves Claude Code honours the grant** — that `Bash` is actually denied to the three
  read-only roles is the runtime's behaviour and the suite never touches it.
- **No check tests obedience.** Classifying correctly, refusing to repair what it criticises,
  failing closed — all exist only as prompt strings.
- **`verify-session-116.sh` was not run** (red by construction). A suite that was not run is not
  evidence, and nothing replaces what it used to cover.
- **The tally is a typed label** — its own run confirms S121's disclosed fakest green.

## The honest reading (this is the finding that matters)

**None of the four defects required Bash.** They came from independent, careful READING. What
execution bought was the exit code and `335 passed`. So this run is strong evidence for *"an
independent agent finds real defects"* and much weaker evidence for S121's actual claim, *"an
executor cannot fake a pass."* The executor thesis remains unproven; the independence thesis got
stronger. Recorded against the session's own interest, per `DECISION-002`.
