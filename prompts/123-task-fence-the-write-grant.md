# Session 123 — CODE: fence the `Write`/`Edit` grant

> **Status:** APPROVED (founder blanket approval at the S122 close; option A of three).
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**.
> Do NOT soften them. No release until reality meets them.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap, new chat.
Branch: `session-123-fence-the-write-grant`.

## Why this session

`qa-specialist` is the fleet's only executing role. It holds `Bash, Read, Write, Edit, Grep, Glob`
and its prompt tells it not to touch the product under test. On both live runs the working tree was
byte-identical before and after — **verified, not trusted.** But in the agent's own words at S121:
*"that constraint held because I chose to hold it, which is not a control."*

That is the last self-granted jurisdiction in the fleet. A role that can edit the code it is
judging can, in principle, repair a check and then report it green. Nothing structurally stops it.

**Do not soften, and repeat wherever the QA role is described:** the S121 executor thesis — *an
executor cannot fake a pass* — is **UNPROVEN**, and `DECISION-007`'s S122 addendum retracts it.
Across two live runs the role found seven real defects and every one came from independent READING.
What is evidenced is INDEPENDENCE, not execution. **This session does not prove the thesis either.**
It removes one specific way the role could cheat; it does not establish that it cannot.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Clear this session's own debt first** (the S122 fakest green, cheap and certain). Two fixtures
   end on a "fail-closed" tooth that cannot fail: `read_only_guard_has_teeth` writes its
   `tools:`-less `mystery.md` into the directory that still holds the planted `Write` leak, and
   `execution_policy_guard_has_teeth` runs its fail-closed case against a copy still carrying
   planted drift 3. Both must be shown RED for the RIGHT reason — delete the fail-closed branch and
   the assertion must go green→red. `covers: 1`
2. **Bind the duplicated tally.** `print_tally()` and `tally_discloses_nesting()` are byte-duplicated
   across `verify-session-121.sh` and `verify-session-122.sh` with nothing binding them — S122
   fixed drift-by-copy for the execution policy and created it for the tally in the same diff.
   One source, or a check that fails when the copies diverge. `covers: 2`
3. **Decide the fence, in writing, BEFORE building it.** Two candidate mechanisms, and the choice is
   a real design decision that belongs in a `DECISION-007` S123 addendum with the rejected
   alternative and the residual risk: (a) **narrow the grant** — drop `Write`/`Edit` and give the
   role a scratch path it can write through some other means; (b) **ride the existing L3 surface** —
   keep the grant and make `scripts/hook-pre-write.sh` block writes to tracked source while a QA
   run is in flight. Name which, and why the other was rejected. `covers: 3`
4. **Build it.** `covers: 4`
5. **`scripts/verify-session-123.sh` + `scripts/demo-session-123.sh`**, each classifying its own
   checks and disclosing nesting in the S122 shape. **The load-bearing fixture: a synthetic agent
   that ATTEMPTS the forbidden write must be shown failing.** A fence never seen to stop anything is
   not a fence — it is the S122 lesson applied to the S123 payload. `covers: 5`
6. **Dispatch `qa-specialist` by name against this session's own suite**, then a cold
   `fidelity-reviewer` pass by name; summary with the per-requirement fidelity map + the fakest
   green. `covers: 6`

## Acceptance criteria

1. Both S122 fixtures fail for the right reason, proven by removing the guarded branch and showing
   the assertion flip.
2. The tally implementation is one source across both suites, or divergence between the copies turns
   a check RED.
3. The fence mechanism is chosen in writing in a `DECISION-007` S123 addendum, with the rejected
   alternative and the residual risk stated plainly.
4. The fence exists in code and is reachable on the real path the QA role runs through.
5. `verify-session-123.sh` exits 0 with its own tally; the fence is proven by a fixture in which a
   forbidden write is ATTEMPTED and BLOCKED — not by asserting the fence's own source text exists.
6. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark (the S119 defect S120 filed, hit again at S122 until it was corrected).

## Design
- design-significant: **yes** — step 3 picks between narrowing a recorded tool grant and extending
  the L3 hook surface. Either changes the fleet's security posture. `docs/decisions/DECISION-007-agent-fleet.md`
  is the spine record; the S123 addendum must exist before step 4 lands.

## Non-goals (not built this session)

- **Proving the executor thesis.** Fencing removes one way to cheat; it does not establish that an
  executor cannot fake a pass. Never restate the S121 claim as measured.
- **Making the check-class label EARNED** — the four-times-disclosed fakest green (S64, S67, S121,
  S122). Standing backlog, still unpicked, still not this session.
- The `no-eighth-command` banner grep. Still hollow, still labelled honestly, still unfixed.
- A fifth fleet role, parallel dispatch, multi-stage orchestration.
- No 8th top-level command.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Approval token required before any commit (`VAJRA_ALLOW_COMMIT=123 git commit …`).
- **Every fix needs a falsifiability fixture**, and after S122 the bar is higher: the fixture must
  fail for the RIGHT reason. Clean the planted defect out of the directory before testing the next
  branch, or the tooth is glued on.
- **`vajra init` blocks forever on stdin without EOF** — any caller needs `</dev/null`. This defect
  cost 10 minutes at S121 and 20 at S122. `verify-session-113.sh` is fixed; older scripts are not.
- **Attest LAST**: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff); compute strictly after the
  `## Execution` shas are committed; two consecutive `verify-closeout.sh --inputs-sha 123` runs must
  agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**, and the canonical
  `**Verdict:** ACCEPT` must be its own bare line, never inside a table cell.
- **Expect more than one cold pass.** S122 needed four (REJECT → ACCEPT-with-findings → REJECT →
  ACCEPT) and every rejection was correct. Budget for it; do not treat pass 1 as a formality.
