---
role: design-advisor
session: 161
agent: claude-code-subagent (toolu_01GYGzk2VeemvrAFaoebEyCJ) — findings confirmed; handoff rewritten from D2-content to S161-content per fidelity-reviewer rec 1
source-sha: null
captured: 2026-09-10T00:00:00Z
cost_usd: null
---

# Design-advisor handoff — session 161

Project: vajra (Rust CLI for AI agent governance)
Session: 161 — close S158 carry-forwards + D2 first-contact dogfood

## Handoff Delta
- `+` new: design-advisor handoff for session 161 (design-significant: yes, DECISION-008)

## design-significant: yes

DECISION-008 establishes `is_code_session()` and `check_demo_markers()` as a named,
citeable interface contract. It is the origin record for the affirmative-match pattern.
Any future session-type gate must cite it.

## Closest existing record

DECISION-002 (fidelity-over-discipline motivation). DECISION-008 is a **peer**, not a
refinement — it governs the enforcement surface (when a gate fires and why), where
DECISION-002 governs the measurement surface (what counts as delivered).

## Key design questions confirmed

**1. Affirmative-match via `grep -qF '**CODE**'` (substring)**
This is the right choice. Substring search means `**CODE + DOGFOOD**` classifies as CODE
without any special-case logic. Rejected alternative: exact-match (would require enumerating
every valid type string and would break on new compound types). DECISION-008 is the origin
record for this pattern.

**2. GT override is structural (N % 5 == 0, evaluated before prompt opens)**
Correct: the GT override beats any `## Type` section content. It is not a type value but
a structural property of the session number. The check order matters: GT first, then Type
section. DECISION-008 documents this explicitly.

**3. Absent prompt defaults to CODE**
Conservative choice — if there is no prompt to read, the gate fires (does not silently skip).
This prevents a missing-prompt from bypassing demo enforcement. Confirmed as correct.

**4. Peer framing relative to DECISION-002**
DECISION-008 does not amend or refine DECISION-002. They govern different things. The
motivation section of DECISION-008 cites DECISION-002 as the origin of the fidelity-first
principle, then establishes the classification-and-enforcement contract independently.

**5. Three rejected alternatives documented**
YAML frontmatter, default-non-CODE-when-absent, and negative enumeration are documented
in DECISION-008 with reasons for rejection. This satisfies the ADR standard for recording
the decision space, not just the decision.

## No new ADR needed beyond DECISION-008

DECISION-008 IS the design record for this session. It does not reference a non-existent
or invented ADR. The existence-gate in the Architect station confirms it exists at
`docs/decisions/DECISION-008-session-type-detection.md`.

## Findings from the subagent review (toolu_01GYGzk2VeemvrAFaoebEyCJ)

The design-advisor subagent independently confirmed all five points above, with particular
emphasis that: (a) the peer framing is required — calling DECISION-008 a "refinement" of
DECISION-002 would conflate measurement and enforcement concerns; (b) the `grep -qF` choice
is the correct house pattern (existence-gating); (c) the GT structural override must appear
in the decision record because callers of `is_code_session()` could otherwise be surprised
by sessions that have `**CODE**` in their Type section but are still non-CODE.
