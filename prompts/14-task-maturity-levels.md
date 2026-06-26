# Session 14 — Maturity Levels (L1/L2/L3)

## Goal
Add tiered enforcement maturity to CONSTRAINTS.yaml so users can grow from report-only to auto-advance.

## Context
- All core commands work (`init`, `next`, `check`, `claude`, `meter`).
- Installer and CI pipeline shipped (S13).
- Enforcement is Vajra's wedge — maturity levels make it adoptable by teams at different trust stages.

## Deliverables
1. `maturity` field in CONSTRAINTS.yaml with L1/L2/L3 semantics
2. `vajra check` reads maturity level and adjusts enforcement behavior
3. `vajra init` lets the user pick a maturity level during scaffolding
4. Hook scripts respect maturity level (L1 = warn-only, L2 = gated, L3 = auto)
5. Documentation in KNOWLEDGE.md for the maturity model

## Maturity Levels
| Level | Name | Behavior |
|---|---|---|
| L1 | Report | Hooks log violations but never block. `vajra check` prints warnings. |
| L2 | Gated | Hooks can reject. Human approval required for advances. Default. |
| L3 | Auto | `vajra next --advance` can proceed without interactive confirm. Hooks enforce strictly. |

## Constraints
- Max 1 story
- Max 3 files per atomic commit
- Branch: `session-14-maturity-levels`
- S15 is a NO-CODE ground truth — keep scope tight
