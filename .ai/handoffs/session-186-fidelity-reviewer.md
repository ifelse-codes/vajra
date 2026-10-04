---
role: fidelity-reviewer
session: 186
agent: claude-code-subagent (verified: toolu_01YEtPuUjswDCoVzc5WWNT2v; text-sha: cd39f65fc96b25e6fe143364f4827e0b42e73bc5a3777d2c129d7234d9536667)
source-sha: 2a969f135d466a43484295c2a05ecebdf1e483a4f35cf9a2993a44b46b0eb8dd
captured: 2026-10-04T11:06:00Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 186

(condensed) — the builder recorded this from the subagent's report: the verdict, grades, the SIGPIPE finding and recs 1–10 are as given; evidence cells and reasoning are shortened.

## Fidelity review: Session 186, pass 4 (cold, add-only focus)

**Verdict:** REJECT

11 of 14 SHIPPED · 2 PARTIAL (AC2 by founder split, AC3) · 1 NOT-BUILT (D2, founder split). Read only.

Text comparison: every S182 check is present and reads the original lines; the joined copy is appended; R1 and R3 closed; no exit other than 0 or 2 on the set -e paths.

Counterexample (reasoned): every check is `printf '%s' "$X" | grep -q…` under `set -o pipefail`. grep -q exits on its first match; printf with unwritten bytes dies of SIGPIPE; the pipeline counts as failed; the `if` goes false. The join doubles the bytes piped, so a ~50 KB command (`cp /tmp/forged .ai/approvals/187.json; true \<NL>` + padding) leaves NAMES=0 and exits 0. S182 already fails open the same way on larger commands; S186 halves the size.

| # | Verdict | Evidence (condensed) |
|---|---|---|
| D1 | SHIPPED | `src/obeyed/mod.rs:84`, gate `:485-545`, `.ai/CONSTRAINTS.yaml:22`, `mandate/mod.rs:428` |
| D2 | NOT-BUILT | founder split; S182 rule `:107`; (a)'s message only |
| D3 | SHIPPED | `..` `:51`, `:85-87`; writers/shells `:129-142`; merge proven by AC5 |
| D4 | SHIPPED | both close scripts |
| D5 | SHIPPED | verify-132 `:329`, `:369-375` |
| D6 | SHIPPED | four lines `>&2`; no scaffold copy |
| AC1 | SHIPPED | verify-186 `:32-51` |
| AC2 | PARTIAL | six blocks covered; the three passes still block (founder) |
| AC3 | PARTIAL | the SIGPIPE path lets a large command exit 0 where S182 exits 2 |
| AC4–AC8 | SHIPPED | verify-186 rows |

Fakest green: `a_linked_target_or_a_missing_cwd_is_not_provable` names logic the split deleted; stale comments `tests/approvals_guard.rs:22`, verify-186 `:2-3`; AC3's "can only match more" true of greps, untested for exit status.
Records: the prompt's `## Delta` still claims a target-reading guard; design rec 15's text describes the withdrawn §2 amendment; STATE.md:13 leaves out pass 3's REJECT.

rec 1–5 — pass 3's, carried with the same meaning (already answered).
rec 6 — Replace every `printf '%s' "$X" | grep -q…` in the guard with a pipe-free test (`grep -q… <<<"$X"`); add ~20 KB and ~70 KB backslash-newline commands that name the folder on line 1 to `s186_writes()`.
rec 7 — Time line 61's `${CMD//"$_BSNL"/}` under `/bin/bash` 3.2 on a 60 KB backslash-heavy command; if it nears the hook timeout, join with sed/awk.
rec 8 — Fix the prompt's `## Delta` line claiming a target-reading guard.
rec 9 — Update design-advisor rec 15's disposition: the §2 amendment and over-block reversal were withdrawn with the split.
rec 10 — Rename or delete `a_linked_target_or_a_missing_cwd_is_not_provable` and fix the stale comments (`tests/approvals_guard.rs:22`, `scripts/verify-session-186.sh:2-3`, STATE.md:13).

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (2945 bytes now vs 2965 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
