# Session 12 — End-to-End `vajra next` Proof

## Goal
Run a real multi-step project where `vajra next` drives the loop start to finish. Prove the north-star workflow actually works.

## Context
- `vajra next` (read-only) and `vajra next --advance` both work individually (S04, S09).
- Never been tested as a real loop: init → step 1 → advance → step 2 → advance → done.
- This is the proof that Vajra is a workflow coach, not just a launcher.

## Deliverables
1. Create a small test project (e.g. 2–3 step todo CLI) with `.ai/` scaffolded via `vajra init`
2. Write 2–3 session prompts for that project
3. Walk through the loop: `vajra next` → read context → do work → `vajra next --advance` → repeat
4. Document what works, what breaks, what's missing
5. Fix any bugs found during the proof

## Constraints
- Max 1 story
- Max 3 files per atomic commit
- Branch: `session-12-e2e-next-proof`
- The test project can be trivial — the point is proving the loop, not the project
