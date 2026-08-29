---
role: design-advisor
session: 137
agent: claude-code-subagent (verified: toolu_01TxuDXap3dNe4u1KQ4wF6wR)
source-sha: 60fe9e616d5f5bca2c99059da20912a8c7c85b06b6c4457755c13b05532b1554
captured: 2026-08-29T12:24:48Z
cost_usd: null
---

# Design-advisor handoff — session 137

# Design-advisor — S137 scatter lock (proposal, founder-locked)

design-significant: yes — the significance lives in CHITRA: this authors a NEW locked contract
(`### LOCKED: scatter chart — session 17 design` in chitra's README) and DEVIATES from the current
scatter.ts (rainbow `theme.colors[i%n]` → accent-once + grey ramp; bare `└─` axis → dashed panel +
eyebrow + `+`/`│` guides + summary footer). On the Vajra side it is a dogfood with no new interface.

rec 1 — accent-point rule: spend the one accent hue on the primary series' MAX-Y point, rendered as
an accent-lit braille cell at that point's own cell; ties resolve to the first max-y point in data
order (deterministic). Every locked sibling spends the accent on a max (pie largest slice, area/line
peak cap, bar global-highest); max-y is the faithful scatter analog. Rejected: last-point (no
inherent x-order), centroid (lands in empty space), outlier (needs a non-deterministic threshold).
Optional `highlight` index overrides. Cited: chitra README LOCKED blocks at pie/donut (line 110),
area (132), line (151), bar (188) — all verified present; no LOCKED: scatter block exists yet.

rec 2 — summary footer: `n <count> · x <min>..<max> · y <min>..<max> · peak (<x>, <y>)`, peak in
accent, mirroring the bar/line `·`-separated footer. NO Pearson r by default — dishonest for
non-linear, multi-series, or zero-variance clouds, and undefined when all x or all y are equal.
x-range/y-range/n are true for arbitrary point data.

Founder locked this proposal as-is at the design gate ("seen, not read" on the rendered chart).

## Handoff Delta
- `+` new: first design-advisor handoff for this session (1610 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
