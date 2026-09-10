# DECISION-008 — Session-Type Detection and CODE-Gate Applicability

**Status:** Accepted  
**Date:** 2026-09-10  
**Session:** S161  
**Relates to:** DECISION-002 (fidelity-over-discipline motivation)  
**Peer to:** DECISION-007 (agent fleet)  

---

## Context

S158 shipped `is_code_session()` and `check_demo_markers` in `scripts/verify-closeout.sh`.
`is_code_session()` is a new shared inference contract: every future session-type gate must call
it rather than re-implementing session-type detection.  The S160 Ground Truth assigned a DECISION
record as a mandatory carry-forward (S158-DA-r4) because the function introduces a permanent
interface commitment.

The motivation ancestor is DECISION-002 (fidelity-over-discipline): that decision established an
independent fidelity auditor whose gate fires at closeout.  The auditor must know _which sessions_
it governs.  Without an explicit, centralized type classifier, each gate would implement its own
ad-hoc heuristic — divergence guaranteed as session types proliferate.

---

## Decision

**`is_code_session()` is the canonical session-type classifier.** Any closeout check that is
conditional on session type (CODE vs DOCUMENT vs GROUND-TRUTH) MUST call `is_code_session()`
rather than re-reading the prompt or inventing a local heuristic.

### The affirmative-match contract (exact specification)

`is_code_session()` returns `true` (exit 0) if and only if **both** conditions hold:

1. The session number N satisfies `N % 5 != 0` (not a Ground-Truth slot).
2. The current session's prompt file (`prompts/NN-task-*.md`, first glob match) contains the
   literal eight-character string `**CODE**` **as a substring of any line in the `## Type`
   section**.

**Implementation detail that must be preserved:** the match uses `grep -qF '**CODE**'` — a
fixed-string (not regex) substring search.  This means a Type line reading `**CODE + DOGFOOD**`
(session 161's own type) **is classified as CODE**.  The substring `**CODE**` is what triggers
the gate, not the full Type value.  A reader who sees only "the Type section must contain an
explicit `**CODE**` marker" could wrongly conclude that compound types like `CODE + DOGFOOD` are
exempt.  They are not.

**Absent prompt defaults to CODE** (line 261: `return 0` when the prompts glob is empty).
An in-flight session without a committed prompt file is treated as CODE-governed, not exempt.
This is conservative enforcement: the ambiguous case fires the gate.

### The GT override is structural, not Type-content

`N % 5 == 0` is evaluated via modular arithmetic **before the prompt file is opened** (line 257).
A session numbered at a GT slot cannot opt into CODE treatment by writing `**CODE**` in its
Type section.  This asymmetry is invisible from the prompt alone: an author reading only their
own prompt's `## Type` section cannot determine `is_code_session()`'s return value without also
knowing their session number.  The decision record makes this explicit so future session authors
are not surprised.

### Demo marker enforcement — the first consumer of `is_code_session()`

`check_demo_markers()` (lines 344–398 of `verify-closeout.sh`) is documented here because it is
the gate that first exposed the need for an explicit session-type classifier.  It calls
`is_code_session()` at line 349 to decide whether to enforce the four required demo markers
(`demo:header`, `demo:cases`, `demo:summary_table`, `demo:before_after`).  For non-CODE sessions
the check is N/A.  For CODE sessions it runs the session's demo script live and FAILS closeout if
any marker is absent.

Future gates that are CODE-conditional should follow this same pattern: call `is_code_session()`,
branch on the result, emit N/A for non-CODE.

### This record is the origin of the affirmative-match pattern

The Architect station (S67, `src/architect/mod.rs`) established existence-gating on recorded
markers as the house pattern.  `is_code_session()` applies the same idiom to session types: a
gate fires only when an affirmative marker is explicitly present, not when it is absent from an
exclusion list.  DECISION-008 is the first explicit articulation of affirmative-match as a
session-classification convention.  Future records citing this pattern should cite DECISION-008
as the origin.

---

## Rejected alternatives

**1. YAML or TOML frontmatter for session type** (e.g., `type: CODE` as a structured field).  
Rejected: the prompt IS the spec (DECISION-002 and the AGENTS.md constitution both say so).
Adding a separate metadata format creates a new surface that can drift from the prose `## Type`
section without detection.  Two representations of the same fact will diverge.

**2. Default to non-CODE when the prompt file is absent.**  
Rejected: conservative enforcement means the gate fires in the ambiguous case, not exempts from
it.  A missing prompt is most likely an in-flight session, not a deliberate exemption request.
Defaulting to non-CODE would silently exempt sessions whose prompt file was simply not yet
committed.

**3. Negative-enumeration matching** (enumerate DOCUMENT, NO-CODE, DOGFOOD, GROUND-TRUTH
explicitly and treat everything else as non-CODE).  
Rejected: any new session type introduced in the future would silently be treated as CODE because
it isn't on the exclusion list.  The affirmative-match approach is closed by default: a session
is non-CODE unless `**CODE**` is explicitly present.  New types are exempt until their authors
add `**CODE**` — the right default.

---

## Consequences

- Every future closeout check conditional on session type calls `is_code_session()`.
- A compound Type value like `**CODE + DOGFOOD**` is CODE-governed (substring match).
- GT sessions (N % 5 == 0) are always non-CODE regardless of their Type section content.
- Absent prompt → CODE (conservative: gate fires).
- `check_demo_markers` is N/A for non-CODE sessions; it FAILS closeout for CODE sessions
  missing any of the four required demo markers.
- This record is the canonical citation for the affirmative-match session-classification pattern.
