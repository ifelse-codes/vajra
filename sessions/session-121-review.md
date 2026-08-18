# Session 121 — Independent Cold Fidelity Review

**Reviewer:** `fidelity-reviewer` subagent (fleet role 2), dispatched by name inside this session.
**Cold inputs (the only two):** `prompts/121-task-qa-specialist-agent.md` and a diff of this branch
vs `main` (4 files, 595 insertions), captured at
`sessions/session-121-artifacts/review-input.diff`. No summary, no `.ai/STATE.md`, no builder
narrative. The reviewer did not build the delivery and ran nothing.

## Per-requirement verdicts

| # | Acceptance criterion | Verdict | Evidence in the diff |
|---|---|---|---|
| 1 | `qa-specialist` registered in `src/fleet/mod.rs` with `Bash, Read, Write, Edit, Grep, Glob` | SHIPPED | `Role { name: "qa-specialist", … tools: "Bash, Read, Write, Edit, Grep, Glob" }` + `QA_SPECIALIST_SYSTEM_PROMPT` carrying all four contract clauses. Pinned by `qa_specialist_is_registered_with_a_non_colliding_key_and_the_execution_grant` (asserts `resolve_role("qa").is_none()`, `handoff_rel(121)`, 7 prompt substrings — each checked to sit UNBROKEN on one source line, so the S114 `\`-continuation trap does not make them vacuous) and by `tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone` (`ROLES.iter().filter(Bash).count() == 1`). |
| 2 | `vajra init` scaffolds 4 agent files; `qa-specialist.md` carries the Bash grant | SHIPPED | `init-scaffolds-four-roles` RUNS the real binary into a temp git repo: exactly 4 `*.md`, all four named, `NEXEC == 1` roles grant Bash, the other three re-asserted `Read, Grep, Glob`, `NotebookEdit` forbidden, `diff -u` against every repo copy, and repo agent set == rendered set. No `src/cli/init.rs` change — the zero-new-machinery claim proven by execution, not asserted. |
| 3 | `vajra next --role qa-specialist --from <file>` governs a handoff; fail-closed on bad inputs | SHIPPED | `e2e-four-governed-handoffs` runs the binary end-to-end: rejects `--role qa` (collision word), missing `--from`, empty findings, missing file; then verifies `role: qa-specialist`, a `source-sha` INDEPENDENTLY recomputed against the trimmed body, a delta naming the producing role, `fleet: 4 governed handoff(s)`, byte-identity of the rest of `--stations`, and the malformed-fourth case degrading to `fleet: 3`. Minor gap named: fail-closed is graded on exit code only — nothing asserts `.ai/handoffs/` stayed clean after the four rejected calls. |
| 4 | `DECISION-007` S121 addendum: key, Bash rationale, ≥2 rejected alternatives | SHIPPED | 79-line addendum: the key decision, the load-bearing-Bash rationale tied to the S118/S120 measurement, THREE `- **Rejected` alternatives (read-only QA agent; Bash-only; widen `fidelity-reviewer` instead), and a "residual risk, stated plainly" paragraph conceding Write/Edit are broader than the prompt-level rule that governs them. |
| 5 | All `verify-session-121.sh` checks green; `no_eighth_command` holds | PARTIAL | The script is real and covers all eight named checks plus a guard-on-the-guard and two role-count-agnostic regression re-runs. Two reasons it is not SHIPPED: (a) greenness is unevidenced IN THE REVIEWER'S INPUTS — no run log was in the diff, so "all green" was a claim the cold pass declined to take on trust; (b) the check the criterion names, `no-eighth-command`, greps a hardcoded usage banner an 8th command need not touch, and was labelled `exec`. |
| 6 | Cold `fidelity-reviewer` ACCEPT | SHIPPED | This pass: fresh context, exactly the two contract inputs, by a reviewer that did not build the delivery. The diff correctly contains no `sessions/session-121-review.md` — that record is written after, and not by the reviewer. Graded on independence of process; the circularity of grading its own verdict is noted rather than hidden. |

**5 of 6 SHIPPED** (1 PARTIAL, 0 NOT-BUILT).

**Verdict:** ACCEPT

## THE FAKEST GREEN (quoted verbatim from the cold pass, per its landing condition)

**The check-classification tally — `CHECK CLASSES — execute-based: N · structural grep: N ·
behavioral source grep: 0`.**

This is the session's marquee output, the thing the whole role exists to produce, and it is **a
literal the author typed**. The class is the second positional argument to `run_check`; nothing in
the script, and no Rust test, ever checks that a check labeled `exec` executes anything. Relabel
every check `exec` and the summary still prints `behavioral source grep: 0`, and `set -uo pipefail`
never notices. The script even installs a `NOTE:` branch for `BEHAV_N -ne 0` that is dead code by
construction — it can only fire if the author volunteers against himself.

Worse, the zero is already arguably false by the script's own taxonomy. `no-eighth-command` runs
the binary but asserts on a hardcoded help *banner string* — the feature could grow an 8th command
with the banner untouched and the check stays green. It is labeled `exec`. So the one number this
session shipped to prove it has cured hollow greens is a self-assigned digit-tag of exactly the S64
"coverage is a self-asserted marker" class. **Do not quote `behavioral source grep: 0` as a
measurement in STATE, KNOWLEDGE, or the GT. It is a declaration.**

**Runner-up.** "The first fleet agent that can actually execute" is, in this delivery, one string —
`tools: Bash, Read, Write, Edit, Grep, Glob` — in a markdown frontmatter that nothing in this
session ever dispatched. Dispatch is an explicit non-goal (S122's job), so it costs no grade; but
until S122 produces a live run, the executor thesis ("it cannot physically fake a pass") is
untested product copy, not a measured property.

## What changed AFTER the cold pass (disclosed, not hidden)

The cold pass ran against commit `2ef285f`. One commit landed after it, `05a9ad5`, doing exactly
what the review's landing conditions asked and nothing else:

1. **`no-eighth-command` reclassified `exec` → `behav`.** Running the product is not enough to earn
   `exec`; the assertion has to bind to the behaviour. The tally is now the honest **13 execute-based
   · 3 structural · 1 behavioral**, and the `NOTE:` branch the review called dead code now FIRES on
   every run — the disclosure is machine-emitted, not volunteered in prose.
2. **Both `vajra init` calls made stdin-safe (`</dev/null`).** Found live: a background run of this
   script hung for 10 minutes inside `verify-session-113.sh` because `vajra init` blocks forever
   waiting on stdin when its runner never sends EOF.

The fakest-green finding is NOT retired by (1). The tally is still a self-assigned label. What (1)
buys is that the label now tells the truth about the one check the review caught mislabelled.

## Other findings the record carries

- **Deliberate regression, disclosed only in a comment.** Renaming
  `every_role_is_read_only_and_renders_its_own_tools` → `tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone`,
  plus the fleet growing to four, turns `verify-session-116.sh` red by construction. The new script
  discloses this in a header comment and re-runs only the count-agnostic suites. The
  rename-not-loosen choice is right, but prose in a comment is not a gate: nothing would catch the
  next author quietly loosening the invariant instead of renaming it. Fourth session of
  per-session-snapshot decay.
- **`one_source_of_role_text` excludes `./.claude/agents/`** — precisely where a boot-loadable second
  source would hide. It only holds because `init-scaffolds-four-roles` separately enforces
  render-byte-identity AND set-equality of the agents directory. The two checks are load-bearing
  TOGETHER; a future session that "simplifies" either one hollows the guardrail.
- **Attestation hazard, acted on.** The `## Execution` shas were placeholders when the reviewer read
  the prompt. `Review-Inputs-SHA` below was computed strictly after those shas were committed, with
  two consecutive `verify-closeout.sh --inputs-sha 121` runs agreeing.

## Evidence

- Full verify run (exit 0, 17/17): `sessions/session-121-artifacts/verify-run.log`
- Cold-review input diff: `sessions/session-121-artifacts/review-input.diff`
- Verify artifacts: `.ai/verify/session-121/latest/`

**Review-Inputs-SHA:** c92a2dad3377f48980458e8a71252b8267948e54badf3b3c6e32683ece48e7a9
