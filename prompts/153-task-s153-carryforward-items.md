# Session 153 — Close the S153 Carry-Forward Items

## Goal

Close the 4 items assigned to S153 in the S152 carry-forward audit. These are small, named,
and bounded. Get them done cleanly so S155 GT does not flag them as outstanding.

## Background

S149 measured 36% hollow advice. S152 added the obedience-skip and carry-forward rules to
AGENTS.md. As part of S152's audit, 4 items were assigned to S153 explicitly. They are:

1. **S147 fidelity-reviewer rec 2** — add a structural check to DOCUMENT-session verify scripts
   asserting that each role section contains a "Brief:" statement (a concrete awk check).

2. **S147 fidelity-reviewer rec 3** — add a note to `.ai/AGENTS.md` stating that when a handoff
   quotes a recommendation in condensed form (not verbatim), the handoff must say so explicitly.
   "Condensed" or "paraphrased" must appear next to the quote.

3. **S148 fidelity-reviewer rec 1** — add a guardrail check to compression-related verify scripts
   (or to `scripts/verify-session-148.sh` as a model) asserting that the cargo-build-fail
   threshold uses `FAIL_PASSTHROUGH_CAP` (not `FAIL_COMPRESS_FLOOR`). The asymmetry is
   load-bearing; a future edit could silently break it.

4. **S152 fidelity-reviewer rec 2 (deferred)** — add a short note to `.ai/AGENTS.md`
   documenting when "closed session + build passing" is an acceptable retirement standard for
   hollow advice items (vs. the original Hollow case). Reviewers need to know the difference.

## Deliverables

1. **AGENTS.md handoff-condensation note** (item 2 + item 4 can be one prose addition to
   the Advisory Protocol section — both are about reviewer transparency).

2. **DOCUMENT-session verify script template or note** — either update `scripts/verify-session-152.sh`
   as a reference pattern with a "Brief:" check added, OR add a protocol note to AGENTS.md
   describing what a DOCUMENT verify script must check. Whichever costs less code.

3. **Cargo-build-fail threshold guardrail** — a new check in a verify script (the appropriate
   home is `scripts/verify-session-148.sh` or a shared compression fixture) that asserts
   `FAIL_PASSTHROUGH_CAP` (not `FAIL_COMPRESS_FLOOR`) governs the cargo-build-fail path.

## Design

design-significant: no

design-advisor: skipped — prose additions to AGENTS.md and small verify-script checks;
no new architecture, no ADR impact.

## Guardrails

- No new top-level commands. Checks ride existing verify scripts or AGENTS.md prose.
- Do NOT redesign the obedience/carry-forward rules added in S152.
- Do NOT add enforcement gates for the AGENTS.md notes — prose only.
- Max scope: the 4 named items. Nothing else.

## Acceptance criteria

1. AGENTS.md contains the handoff-condensation transparency note (item 2).
2. AGENTS.md contains the retirement-standard note (item 4) — when "closed session + build passing"
   is acceptable vs. when it is not.
3. A verify script (new or updated) contains a check for the cargo-build-fail threshold constant
   (`FAIL_PASSTHROUGH_CAP`), and the check is execute-based (not a source-grep).
4. Either a "Brief:" check is added to a verify script, OR a AGENTS.md protocol note documents
   what DOCUMENT-session verify scripts must include (Brief: per role section).
5. `verify-closeout.sh` exits 0.

## Delta

**Why now:** S152 named these items explicitly and assigned them to S153. S155 GT will audit
whether named carry-forward items were addressed. These are small enough to close cleanly in
one session.

**Why not later:** B (cost-cutting) is higher priority than these items but requires a paid
dogfood run. C (re-audit) needs 3–4 more sessions of data first. A is the right call now.

**What S155 GT will check:** whether all 4 items have been addressed and whether the ROADMAP
S153 block has been cleared.
