# Session 137 — Cold Fidelity Review

**Reviewer:** independent `fidelity-reviewer` (not one of the six advisors — S132).
**Method:** graded from the prompt + delivery, NOT the builder's summary. Because chitra rests on
`session-16`, the reviewer read the LOCKED code from the committed verify render logs under
`.ai/verify/session-137/` and via `git show session-17-scatter-lock:…`, never the working tree.
The discriminating proof it relied on: the pre-lock run logged `accent=0 grey=0 other=8` (rainbow,
no accent); the final run logs `accent=1 grey=7 other=0` — the check goes red when the feature is
absent, green when present. A real falsifiable check, not a typed marker.

## Verdict

| # | Acceptance criterion | Verdict |
|---|----------------------|---------|
| 1 | Rendered scatter carries the panel language (frame · eyebrow · one-accent-once + grey ramp · +/│ · footer), raw-RGB verified | SHIPPED |
| 2 | chitra's own pipeline green on the branch + real README `LOCKED: scatter` block | SHIPPED |
| 3 | Founder signs off on the rendered scatter (recorded) | SHIPPED |
| 4 | Authoritative $ (or honest null w/ reason) AND RAW subagent tokens (never new-tokens-only) | SHIPPED |
| 5 | session-16 + all locked charts UNDISTURBED (four ways); only scatter files changed, pre-declared | SHIPPED |

**Verdict:** ACCEPT
**Count (at delivery):** 4 of 5 SHIPPED · 1 PARTIAL · 0 NOT-BUILT — **criterion 2's PARTIAL was
then CLOSED in-session** (see below), landing at **5 of 5 SHIPPED**.

**Review-Inputs-SHA:** 6a1824d0ee436b5b6586eec6463fb2ad402c24177fc8472b833c12e38c3ca29e

## The fakest green — named by the reviewer, and closed

The reviewer rejected the summary's own nomination (check 9's self-grep of `486,695`, which is
hollow but honestly `deferred`) and named a sharper one: **criterion 2's dropped live-vitest.** An
earlier verify iteration had a `chitra-scatter-tests-pass` check that went red (`scatter.test.ts
absent` — it read session-16, where the test does not exist) and it had been **removed** rather than
fixed to run against the branch. So the shipped gate named chitra's 14 falsifiability tests but never
ran them — the S129 *registered ≠ run* pattern. The 14 tests could have been deleted and the gate
stayed green.

**Closed in-session:** `verify-session-137.sh` gained check `chitra-own-scatter-tests-run-live`,
which runs the committed `scatter.test.ts` against a `session-17-scatter-lock` worktree via chitra's
own vitest (node_modules symlinked; core renders zero-dep). Live result: **14/14**, and the full
suite is now **10 of 10 green** (6 EXEC · 3 STRUCT · 1 BEHAV). Criterion 2 is therefore SHIPPED, not
partial.

## Judgment on the `obeyed:` code claims (the independent judge)

Spot-checked against the locked render logs, the sign-off HTML, and the edge-case EXEC assertions:

- **design-advisor rec 1/2** — implemented (accent = primary-series max-y once; footer with no r).
- **implementation-advisor rec 1** — implemented (accent = ONE cell, not a 3-wide cap: `accent=1`).
- **implementation-advisor rec 2** — implemented (`other=0` on both paths — zero rainbow leak).
- **implementation-advisor rec 3** — implemented, inferred from outcome (blocks path `accent=1
  other=0`; the reviewer could not read the paint-order source directly but the observable result
  matches the claim).

**No obeyed claim is a live mismatch.**

## Reviewer recommendations (carried)

1. **Restore the live chitra vitest check** — DONE this session (the fakest green above).
2. **Make the RAW-token receipt check recompute rather than self-grep** — carried; it needs the
   local-only transcripts (S126), so it stays disclosed-weak for now (summary next-candidate 2).
3. **Land the repo-aware Coder gate** (per-step `repo:` annotation) before the next dogfood — this
   session's own next-candidate 1; the single-repo `git cat-file -e` assumption is the real gap.
