# Session 173 — Keep using Vajra in rudra, fix what it finds

> **Status:** DRAFT — the shape is set (S171 and S172's method, repeated, founder's pick 2026-09-21: "we will continue like s171 and 172 and continue using vajra and try in rudra"). The founder's findings fill in the Goal and Acceptance at the start of the chat, as they did before.

## Type
- **CODE**, interactive. He uses Vajra for real in `rudra`, pastes what he hits, each finding is
  recorded with a severity, then fixed → shown → committed on his word. Full close at the end
  (S172: "i want full close out").

## Before he starts (so the run tests TODAY's Vajra, not last week's)
1. `cargo install --path /Users/suman/playground/vajra` — his installed `vajra` predates S172.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — carries S172's fixes in (6 files, all clean
   upgrades on a copy of rudra).
3. Merge rudra's open PR #3 (its session 03) if not already done, so session 04 starts from it.

## What this run should exercise for the first time
- **S172's F39 fix, for real:** rudra session 04's start should REPORT on session 03, not block —
  and session 03 closed with five unanswered tech-lead recommendations, so the report has
  something to say. Does it read as helpful or as noise?
- **The new pre-merge checks** at rudra's close (advice answered, verify live, fidelity handoff,
  demo live) — do they catch problems cheaply, or add another hour?
- **F35:** the design check now sees rudra's `docs/ADR/` records.
- **F36/F38/F42:** fewer reading pauses, the missing-prompt warning, plainer words.

## Carried in
1. **F44 (S172, open):** the session guard reads a command's prose — a note quoting the advance
   command in backticks armed the session boundary and blocked a write. Fix it if rudra hits it;
   otherwise it is still worth a small fix (strip backticked text the way quoted text is stripped).
2. **The unexplained file changes from S172** (`.claude/settings.json`, `.gitignore`, a stray
   `.ai/hooks/` appearing in THIS repo mid-session): if it happens again, find what ran
   `vajra init` inside Vajra.
3. **Watch F31 a fourth time** — the tech-lead dispatched first in rudra S03. One clean run is not
   a trend.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| _ | _ | _ | _ |

## Goal
1. _From the founder's run._

## Deliverables
1. _From the founder's run, plus the carried items above._

## Acceptance
1. _Each item something he can check himself._

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Show each step before the next. Small commits, his word every time.
- Anything not fixed goes in the findings table with a severity, never dropped.
- A branch NOT named `session-NN-…` is ungoverned ad-hoc work BY DESIGN (founder, 2026-09-21,
  DECISION-007) — do not "fix" it.

## Delta
- `+` whatever the founder's rudra session 04 surfaces
- `~` S172's pre-merge enforcement meets a real close for the first time
- `~` F31 watched a fourth time
- `-` nothing removed
