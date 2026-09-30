---
role: design-advisor
session: 181
agent: claude-code-subagent (verified: toolu_0178St2vWT5knTFD1we9xZ3M; text-sha: 244d86cfeea9c81c2e3513385be6b1c861cc55dc42e77c0c610cf249a70d5ef9)
source-sha: de3f36d3626a78d5cb06532bf4debfc03442b283121e80bbcd95ecb4400c0f33
captured: 2026-09-30T02:31:25Z
cost_usd: null
---

# Design-advisor handoff — session 181

The brief has three parts: the numbered recommendations, the `## Design` text to paste, and the two things I could not verify.

rec 1 — Record `design-significant: yes`. Parts 3, 4 and 5 change gates, and Part 2 changes a locked cadence contract.
rec 2 — Cite `docs/decisions/DECISION-008-session-type-detection.md` for Part 3, and say plainly that it deviates from that record.
rec 3 — Cite the S175 addendum inside `docs/decisions/DECISION-007-agent-fleet.md` for Part 2. There is no ADR for the cadence, so the addendum is the record. It carries "NOT claimed" items 2 and 3, which this session reverses.
rec 4 — Do not cite DECISION-005 for Part 4. Its machinery-freeze rule is superseded. Cite the DECISION-007 addendum that documents `VAJRA_ALLOW_COMMIT` (around line 1467), plus DECISION-002 and DECISION-003. Then write a new decision record for the approval mechanism.
rec 5 — Cite the S169 addendum in DECISION-007 and DECISION-003 for Part 5, and say plainly where Part 5 deviates.
rec 6 — Add a new `docs/decisions/DECISION-011-*.md` covering Parts 3–5 before close. Nothing existing covers "the agent cannot type this". The `Status:` lines of DECISION-008 and the S169 addendum also need a superseded note.

Part 2 — shared ground-truth helper and one-time override. Extends docs/decisions/DECISION-007-agent-fleet.md, S175 addendum. It deviates in two ways: that addendum's "NOT claimed" item 2 says the override is one global integer with no "every 5th after" rule (now the override is one-time and the 5th-multiple rule resumes by itself); its item 3 says to extract scripts/lib-ground-truth.sh when another check needs it (this session extracts it now). Rejected: editing the key each time; a hardcoded "185"; leaving six copies.

Part 3 — strict `session_type:` field. Deviates from docs/decisions/DECISION-008-session-type-detection.md, which locks is_code_session() to a fixed-string search for **CODE** in the `## Type` section and rejects a structured field. This session replaces the prose search with one strict field that fails closed, keeping the old search only as a named, dated, loudly printed fallback for S1-S180. Rejected: more keywords; silent fallback.

Part 4 — approval the agent cannot type. Extends docs/decisions/DECISION-007-agent-fleet.md (the VAJRA_ALLOW_COMMIT approval set at launch) and docs/decisions/DECISION-002-fidelity-over-discipline.md (no self-certification). Deviates because today "APPROVED" is words in a brief any agent can type; now the gate reads a separate record written by `vajra approve NN` (refused from a marked process) or a launch-time flag. Needs a NEW decision record before close; it must state the limit: bar-raising, not tamper-proof. Rejected: a second env-var scheme; reading "APPROVED" from the brief; signed approvals.

Part 5 — named waivers and text-bound stamps. Deviates from docs/decisions/DECISION-007-agent-fleet.md S169 addendum (VAJRA_CLOSEOUT_WAIVER=N skips every waivable check) and docs/decisions/DECISION-003-verdict-input-attestation.md. A waiver now names its checks, gives a required reason, and is logged as launch-time or set-later; the old form still works with a warning. The stamp is bound to a hash of the record's text, extending DECISION-003's hash binding to helper stamps (F84). Rejected: removing the old waiver now; a per-session allow-list file.

Part 1 — pure fix. No record applies.

Could not verify: (a) the S169 addendum's "a waiver cannot back a claim" holds for check_claimed_evidence; Part 5 must not reintroduce a waiver path for it. (b) DECISION-007 lines around 1467 describe launch-time VAJRA_ALLOW_COMMIT.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (3646 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
