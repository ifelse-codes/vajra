# Session 181 — small fixes, a smart ground-truth cadence, and controls the agent cannot fake

> **Status:** DRAFT — the founder said in the S180 chat (2026-09-29): "all of this in session 181 one
> by one". Left DRAFT on purpose (F77): the founder writes APPROVED, not the agent.
> Written on `session-180-closeout`; commit it on the S181 branch.

## Type
- **CODE**, interactive. Founder-directed **exception to "1 story per session / ~2h"**: five parts, done one at a
  time, in order. **Each part ends green and committed before the next starts; the founder can stop after any
  part.** A part that is not green at the end of the session is carried, not rushed.
- Not a ground-truth session (S180 was; the next one is decided by Part 2's rule).

## Evidence
`sessions/session-180-ground-truth.md` — findings N1, N5, N6, F84, F85, F92; Goal 0 design table; the founder's
rulings at its end.

## Part 1 — the small S179 fixes (review recs 5 and 6)
1. The top-level `vajra --help` line "<command> --help  Print that command's help and run nothing" (`src/main.rs`)
   has no exception for `claude`. Reword it so it does not overclaim.
2. `tests/cli_front_door.rs` `init_sync_fleet_dry_run_still_works` cannot fail (the scaffold is not committed before
   the dry run). Make it able to fail. Add `--help` probes after other args: `next --advance --help`,
   `init --sync-fleet --help`, `--sync-fleet --overwrite-drifted --help`.

## Part 2 — the smart cadence (N1; the founder's rule, not a number)
**Founder ruling:** never a hardcoded "185". Default = a review-only session every 5th. `ground_truth_next_session`
is a one-time override that counts only until that session has **happened or been passed**, then the next 5th applies
on its own and the founder is told/asked.
- Build **one shared helper** (S175 rec 1: six copies, no shared lib) that answers "is session N a ground truth?" from:
  the override (only while `N <= key` and no `sessions/session-KEY-ground-truth.md` exists), else `N % 5 == 0`.
  Past a passed override with no report → say so, roll to the next multiple of 5 above the key.
- All 6 sites read the helper: `hook-session-start.sh`, `verify-closeout.sh`, `hook-pre-bash.sh`,
  `hook-pre-write.sh`, `hook-prompt-submit.sh`, `hook-stop.sh`. Plus the scaffold's twin
  (`scripts/verify-closeout-scaffold.sh` and its `build.rs`/`init` copy).
- After this part `.ai/CONSTRAINTS.yaml` `ground_truth_next_session: 180` needs **no edit** (proof: session 181
  is not treated as ground truth, session 185 is).

## Part 3 — `session_type` (N6, S177)
One field in a brief's header: `session_type: CODE | DOCUMENT | GROUND_TRUTH | INTERACTIVE`. **Missing or unknown →
the close gate fails closed** with a message naming the fix. No searching the brief's prose for `**CODE**` (the
no-text-guessing rule). Move Vajra's own gate and the scaffold gate together. Old briefs (S1–S180) keep working by
a named, dated fallback, printed loudly when used — never silent.

## Part 4 — the human's yes that the agent cannot type (F77, F85, F92)
**Founder direction:** either the founder approves, or a launch-time "dangerously allow all" flag he sets; the agent
can do neither mid-session. Start from the S180 sketch; **brainstorm the exact mechanism with the founder before
building**. Sketch: Vajra marks every process it launches; `vajra approve NN` refuses when the mark is present (works
only from the founder's own unmarked terminal); `vajra claude --allow-all` set at launch, logged "human chose at
start". The gate reads the approval record, never the brief's words. **Disclose as bar-raising, not tamper-proof**
(an agent could strip the mark). Check first: the existing `VAJRA_ALLOW_COMMIT` guard already refuses an
agent-set variable — reuse that pattern, do not invent a second one.

## Part 5 — named waivers and stamps (F92, F84, F78)
1. A waiver skips only the checks it names (`VAJRA_WAIVE=check-a,check-b`), with a **required reason**, logged as
   "launch-time" or "set later". One waiver never means ~20 checks (today's `VAJRA_CLOSEOUT_WAIVER=N`).
2. F84: a helper's "verified" stamp is bound to a hash of the record's text at capture; editing the text kills it.
3. Keep `VAJRA_CLOSEOUT_WAIVER=N` working, with a printed warning, until the founder says remove it.

## Design
design-significant: _to be decided by the design-advisor_ (Parts 3–5 change gates; cite the existing ADR/DECISION each
one deviates from).

## Acceptance
1. Part 1: the `claude` exception is in `--help`; the dry-run test can fail (fails when the scaffold is uncommitted)
   and the three new `--help` probes pass.
2. Part 2: one shared helper; all 6 sites + the scaffold use it; a fixture proves S181 is not ground truth and S185
   is, with `ground_truth_next_session: 180` unchanged; a fixture proves a passed override with no report rolls forward
   and says so.
3. Part 3: a brief with no/unknown `session_type` fails the close gate; each valid value is honoured; the fallback for
   old briefs prints a loud line; the same holds in the scaffold gate.
4. Part 4: `vajra approve NN` is refused when run from an agent-marked process and works from an unmarked one; the
   gate ignores an "APPROVED" typed into a brief; the allow-all flag is recorded as launch-time. The limitation is
   written where a reader will see it.
5. Part 5: a waiver naming one check passes only that check; a waiver with no reason is refused; a stamp dies when
   the record's text changes.
6. Every part: its own verify checks execute the real thing (no source greps), and `verify-closeout.sh` exits 0 on the
   branch before merge.

## Plan
_(the agent writes this with the plan-advisor; every step cites `covers: N`.)_

## Execution
_(step N — done: <sha> as work lands.)_

## Guardrails
- No autonomous commits: the founder runs them, or launches with `VAJRA_ALLOW_COMMIT=181`. The agent never sets it.
- ≤3 files per commit; ≤2 assumptions; ≤2 retries. A fresh cold fidelity review at close (F81: code after an ACCEPT
  needs a new review).
- Guard changes only add (S173): never hide text from a guard.
- Parked, NOT this session: F91/F94/F95/F80 (other coding tools — later, one tool at a time: OpenCode, then omp, then
  a third the founder named), F67 receipt pricing, release/publish (founder: not until he trusts it).

## Delta
- `+` `scripts/` shared ground-truth helper; `session_type` gate; `vajra approve`; named waivers; stamp-to-text binding
- `~` the 6 cadence sites and the scaffold gate; `vajra --help` wording; `tests/cli_front_door.rs`
- `-` the hardcoded reliance on a single-integer override; the `**CODE**` prose search as the only session-type source
