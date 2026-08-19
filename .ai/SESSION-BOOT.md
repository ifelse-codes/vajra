# Session Boot

## Current Session
- **Number:** 122 — COMPLETE
- **Type:** CODE. Close the four real holes the S121 live QA run found in S121's own guardrails.
- **Goal:** Anchor the read-only guard, defuse the `one_source_of_role_text` booby-trap, kill the
  near-tautological render test, and make the check-class tally honest about nesting — **each with
  a falsifiability fixture** (a check never seen RED is not evidence).
- **Verdict:** **ACCEPT** — cold `fidelity-reviewer`, **pass 4**. 5 of 6 SHIPPED, 1 PARTIAL
  (procedural), 0 NOT-BUILT. Attested `9998bd3f8f62a6ea7c8b0bdfc5da485ca9e8e93dd51b33ec20c1cc4126eb3daf`.
- **Report:** `sessions/session-122-summary.md` · `sessions/session-122-review.md`.
  Prompt: `prompts/122-task-qa-suite-real-holes.md`. **Date last updated:** 2026-08-19.

## Repo State Snapshot
- `.ai/SESSION` = 122. **PR [#133](https://github.com/ifelse-codes/vajra/pull/133) MERGED
  2026-08-19** (CI green both OS); branch pruned local + remote; `main` synced. S123 starts from a
  fresh `session-123-*` branch.
- **337 lib tests** (was 335); `verify-session-122.sh` **22/22 green, exit 0**;
  `demo-session-122.sh` **9 of 9**; 7 commands, no 8th.
- **The fleet is still FOUR roles** — researcher · fidelity-reviewer · plan-advisor · qa-specialist.
  Exactly one executes. Both halves of the execution policy (forbidden tools AND the allowlist) are
  now bound across all three hand-maintained copies; before this session the Rust list was missing
  `Task`, so a role granted execution-by-proxy passed the unit test and was rejected by both shell
  guards.
- **What S122 changed, in one line each:**
  - `read_only_outside_allowlist()` — token-exact. The old `grep -q "^tools: Read, Grep, Glob"` was
    a PREFIX match and passed `tools: Read, Grep, Glob, Write`.
  - `role_text_carriers()` — excludes `.ai/handoffs/`, names every carrier by path on failure, and
    the exclusion is pinned to the ONE script the check lives in, never a `verify-session-NN.sh`
    wildcard (widening it would license every future script to carry role text).
  - **Three** render-against-its-own-field tautologies removed. `role_prompt_substance()` is ONE
    function shared by the real test and the fixture; the guard's field list is DERIVED from
    `pub struct Role`, so a new content field is policed the day it is added.
  - Fourth check class `nested`. `print_tally()` names each nested suite, states they are not
    counted, and calls the behavioral count a FLOOR — derived, never a hardcoded number.
- **The booby-trap is ARMED in this repo.** A real governed `qa-specialist` handoff quoting the
  probe sentence sits at `.ai/handoffs/session-122-qa-specialist.md`; the S121 suite runs green with
  it there. That is the strongest evidence in the session — defused against the live case, not a mock.
- **Key S122 findings:**
  - **🔴 The fakest green: two of five fixtures end on a "fail-closed" tooth that CANNOT FAIL.**
    `read_only_guard_has_teeth` writes its `tools:`-less `mystery.md` into the directory that still
    holds the planted `Write` leak; `execution_policy_guard_has_teeth` runs its fail-closed case
    against a copy still carrying planted drift 3. Delete the guarded branch and both still print OK.
    **Deliberately UNFIXED** — repairing after the ACCEPT would attest a diff no reviewer saw.
  - **FOUR cold passes were needed: REJECT → ACCEPT-with-findings → REJECT → ACCEPT.** Every
    rejection was correct. The same tautology was found on a THIRD field after two "fixes"; the
    booby-trap was re-armed TWICE inside the session closing it; the anti-hollowness demo was itself
    hollow (six hardcoded `PASS` rows and a case scored by `true`).
  - **The dispatched `qa-specialist` found three more real defects** before any cold pass ran — a
    comment-blind structural grep, a hardcoded "nesting disclosure", and the drifted policy list.
    It changed nothing, checked not trusted.
  - **`vajra init` hung for ~20 minutes** inside `verify-session-113.sh` — second occurrence of the
    same defect (10 minutes at S121). That script now redirects `</dev/null`; older ones do not.
- **🔴 The executor thesis is UNPROVEN, and `DECISION-007` now says so in writing** (S122 addendum
  retracting the S121 claim). Two live QA runs, seven real defects, EVERY ONE from independent
  READING. What is evidenced is INDEPENDENCE, not execution. **No check enforces that correction** —
  it is typed prose in six places and it decays the day someone stops typing it.

## Next Session
- **Number:** 123 — **CODE.** Fence the `Write`/`Edit` grant (founder option A of three).
- **Goal:** Make it structurally impossible for the QA role to edit the code it tests, instead of
  asking it not to. Steps 1–2 clear S122's own debt first (the glued-on teeth, the byte-duplicated
  `print_tally`/`tally_discloses_nesting` across both suites).
- **Full prompt:** `prompts/123-task-fence-the-write-grant.md`.
- **Why:** on both live runs the tree was unchanged only because the agent CHOSE to hold the line —
  *"that constraint held because I chose to hold it, which is not a control."* Last self-granted
  jurisdiction in the fleet.
- **Do not soften:** fencing removes one way to cheat; it does not prove the executor thesis. Say so.
- **Design-significant: YES** — step 3 picks between narrowing the grant and extending the L3
  `hook-pre-write.sh` surface, and the choice needs a `DECISION-007` S123 addendum before code lands.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S122)
- **A falsifiability fixture must fail for the RIGHT reason.** Clean the planted defect out of the
  directory before testing the next branch. Two of S122's five teeth were glued on this exact way.
- **Expect more than one cold pass.** Four were needed at S122 and every rejection was correct.
  Budget for it; pass 1 is not a formality.
- **Do not fix findings after the ACCEPT.** The attestation hashes the reviewed diff; repairing
  afterwards attests something no reviewer saw. File them into the next prompt instead.
- **Widening an exclusion list is not a fix.** S122 twice "solved" a carrier problem by excluding
  the carrier, then reversed it: the demo and the S122 suite use a FRAGMENT so they never carry the
  role text at all. The exclusion list IS the hole.
- **`print_tally()` and `tally_discloses_nesting()` are byte-duplicated** across
  `verify-session-121.sh` and `verify-session-122.sh` with nothing binding them — S122 fixed
  drift-by-copy for the execution policy and created it for the tally in the same diff. S123 step 2.
- **The landed `qa-specialist-run.md` and its handoff describe a suite that no longer exists** —
  they report a check RED that was fixed after. `run-evidence.md` carries the later green run, but a
  reader hitting the handoff first is misled. Left as-is: the handoff is sha-bound and rewriting it
  would break the attestation it exists to provide.
- **Five `def.contains(… role.name …)` instances remain by design** — the join key is exempt from
  the tautology guard, reasoned only in a comment. `assert!(def.contains(role.name))` would pass today.

## Carry-Forwards (from S121)
- **The self-asserted-label class has now been disclosed THREE times:** S64 (`covers:` digit-tag),
  S67 (`design-significant:` marker), S121 (the check-class tally). Option B at the S121 close
  (make the tally machine-derived) is the named, unpicked fix.
- **Running the product is not enough to earn the `exec` label** — the ASSERTION has to bind to the
  behaviour. `no-eighth-command` runs the binary and still greps a banner string.
- **`vajra init` needs `</dev/null`** from any non-interactive caller.
- **Per-session verify snapshots decay** — S114's, S116's now red by construction. They are
  historical snapshots, not living suites; the count-agnostic ones (S113, `fleet-smoke.sh`) are the
  real regressions.
- **The QA STATION (`src/qa/mod.rs`) and the QA ROLE (`qa-specialist`) stay separate** — the station
  governs the process, the role does the work. Third instance of that collision, same resolution.

## Carry-Forwards (from S120 GT)
- **Two classes of source greps:** STRUCTURAL (one-source-of-truth architecture checks — acceptable;
  no better alternative) vs BEHAVIORAL (checks a feature works by finding its message string in
  source — the hollow class; the hollow class is widespread). Name the class explicitly in future
  fakest-green disclosures.
- **QA STATION ≠ QA ROLE:** `src/qa/mod.rs` = the pipeline's QA STATION (governs the process).
  `qa-specialist` = the fleet's QA ROLE (does the work). Same pattern as Reviewer/fidelity-reviewer
  and Planner/plan-advisor. They stay completely separate.
- **First full-execution fleet agent (S121): DONE.** Bash grant recorded in the `DECISION-007` S121
  addendum with three rejected alternatives + the residual risk.
- **Dispatch proof is S122's job** — mid-session dispatch is invisible (S111 finding); same pattern
  as S114→S115 (fidelity-reviewer) and S116→S117 (plan-advisor). **S121 honoured this: the role was
  built and never dispatched.**
- **S119 Coder-dark root cause:** prose in an `## Execution` step breaks `git cat-file`. Legitimate
  non-commit evidence (fidelity-reviewer ACCEPT) is not a sha; needs a different gate path or a
  documentation exception. Filed, not fixed.

## Standing Carry-Forwards (from S119 + prior)
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S122.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name proven for ALL THREE roles** (Researcher S111, Fidelity Reviewer S115, Plan
  Advisor S117). Mid-creating-session dispatch still fails per S111 — do not conflate.
- **Attest LAST:** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), the PROMPT IS AN INPUT.
  Compute strictly after every edit to the prompt file itself and confirm two consecutive
  `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **`vajra next --role X --from file` hashes the TRIMMED body** — strip before sha256 comparison.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3).** A bullet list is BLOCKED.
  A verdict wrapped in a `|`-table row also fails — only a bare `**Verdict:** ACCEPT` line passes.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Background task flagged, not yet acted on:** `task_2162b487` — the Planner-gate
  `is_acceptance_heading` double-counting bug (S117 finding).
- **KNOWLEDGE §6 is at 642 lines, growing** — chronic since S60, still unpruned.
- **Known weak check, house-wide, unfixed:** `no-eighth-command` greps a hardcoded usage banner —
  now formally classified BEHAVIORAL (hollow) at S121. Option C at the S121 close is the fix.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
- **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays founder-gated.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes".
