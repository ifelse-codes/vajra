---
role: design-advisor
session: 141
agent: claude-code-subagent (verified: toolu_01AuYT6avoEX3QG4u6v2u8Cx)
source-sha: eaa2ddb12517a2719c12ddf18c09c8355d2bed84d55c180b319dd74aafaba487
captured: 2026-09-02T13:41:35Z
cost_usd: null
---

# Design-advisor handoff — session 141

Design Advisor findings — Session 141 (render stamp + fourth FleetFileState).

The citation resolves: docs/decisions/DECISION-007-agent-fleet.md EXISTS and its S136 addendum
pre-declares this exact fix as a future session ("stamp each rendered file with the render's own
content hash … earns its own session"). S141 is the named, scoped cash-in. The FleetFileState "only
three because there can only be three" doc comment is the second locked statement superseded. Citing
DECISION-007 passes the Architect gate's FORM check; the design SUPERSEDES what it cites, made
legitimate only because the S141 addendum lands and says so. design-significant: yes is correct.

The honest-version claim holds: S136 rejected INFERRING provenance from signals written for other
purposes (git blame, timestamps); S141 RECORDS a dedicated signal at render time and reads it back as
a pure deterministic function of the on-disk bytes. Recorded-at-source vs inferred-after-the-fact is a
real distinction, not a walk-back — provided two limits stay disclosed: legacy unstamped files stay
Drifted (no retroactive provenance), AND this is a content hash, not a keyed signature.

Placement: the stamp belongs in the YAML frontmatter as an unknown key, on the last line before the
closing `---`. Claude Code's subagent loader reads only known keys (name/description/tools/model) and
strips frontmatter before handing the body to the model — so the stamp is doubly inert (ignored by the
loader, never a prompt token). A body HTML comment would survive into the model's prompt — strictly worse.

rec 1 — KEEP design-significant: yes. It clears three independent bars: a changed interface (new FleetFileState::StaleRender variant + new sync_fleet behavior), a new persisted on-disk format (the stamp line), and a deviation from a LOCKED record (reverses the S136 "not derivable" floor + the "only three states" doc comment). A pure fix would be no; this is none of those.
rec 2 — CONFIRM the core distinction as the honest version, and complete it with ONE added disclosure: the stamp is a content hash, not a keyed signature. Re-hashing body-minus-stamp proves the bytes are a fixed point of Vajra's own render+hash function — which any identical render reproduces and which a user could in principle forge by hand (no secret key). The honest claim is "auto-upgrade-safe for the untouched-render case," not "cryptographic provenance." Same tamper-EVIDENT-not-tamper-PROOF posture as the DECISION-004 ledger. State it or a reviewer reads "provenance" as stronger than it is.
rec 3 — The four rejected alternatives in the ## Design are SOUND. ADD TWO a reader will otherwise ask: (a) a version/session LABEL (vajra-render: 0.x / rendered-by-S141) vs a content HASH — reject the label: it records a claim about the bytes that a hand-edit does not invalidate (edit the body, the label still says S141), so it cannot tell an untouched render from an edited one; the hash verifies the actual bytes. (b) stamp in a BODY COMMENT vs a FRONTMATTER KEY (see rec 4) — a real losing option with a real reason, belongs in the decision, not only in acceptance 1.
rec 4 — Put the stamp as a frontmatter key `vajra-render-sha: <hex>` on the LAST line of the frontmatter block (after tools:, before the closing ---), NOT a body comment. Inert to Claude Code twice: the loader ignores an unknown key, and frontmatter is stripped before the body is handed to the model. Dispatch-by-name rides name:, which does not move. ASSERT placement (a stamped file still resolves subagent_type by name), per acceptance 1 — not merely that the stamp is present.
rec 5 — Propose the DECISION-007 S141 addendum text (append after the S136 addendum): status ACCEPTED; it extends the scaffold contract this record already locks (not a DECISION-008); what reverses (the S136 not-derivable floor + the only-three doc comment, superseded because provenance is now RECORDED); the fourth state (StaleRender auto-upgraded, Drifted keeps the refuse path); and why it does NOT reopen the rejected classifier (writes a dedicated signal, no clock/git/heuristic), with both honest limits disclosed (legacy unstamped stays Drifted; content hash not keyed signature, tamper-evident not tamper-proof).
rec 6 — RECORD in the ## Design that this session DEVIATES FROM / SUPERSEDES the record it cites. The Architect gate confirms DECISION-007 resolves to a file; it does NOT check the design obeys it (S127 lesson). One line in the ## Design body: "supersedes the S136 'not derivable' floor; see the S141 addendum," so the reversal is on the record where a reader finds it.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (4625 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
