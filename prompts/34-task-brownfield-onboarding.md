# Session 34 — Brownfield onboarding (CODE)

> **S31 finding #3, ranked last of the three core breakages** (lowest daily-satisfaction impact of
> the three, per the S31 dogfood — but still a real gap: `vajra init` was proven on greenfield/near-
> greenfield use; the S31 dogfood run against an existing TS monorepo (`chitra`) found no
> "learn this codebase first" step, and the scaffolded hooks land inside the target project's own
> `scripts/` directory, which is awkward for a project that already has its own `scripts/` package.

## Goal (one story)
Give `vajra init` (or the first session after it) a guided "session 0" on an existing codebase:
read the repo, fill `.ai/KNOWLEDGE.md` + `.ai/STATE.md` with what it learned, before any
feature work starts. Plus the smaller S18-noted gap: `vajra claude` has no auth pre-check
(fails confusingly deep in a session if the agent isn't authenticated, rather than failing fast).

## Suggested shape (confirm/adjust with the founder at BOOT — not pre-pinned like S33)
1. A brownfield-specific onboarding path in `vajra init` (or a new guided prompt/checklist it
   emits) that: scans the existing repo structure, asks a few framing questions, and seeds
   `KNOWLEDGE.md`/`STATE.md` with a real first-pass understanding instead of the empty
   greenfield templates.
2. Revisit hook placement so scaffolded `scripts/hook-*.sh` files don't collide with or crowd a
   project's own `scripts/` package (e.g. a dedicated subdirectory, or documented convention).
3. `vajra claude`: a pre-flight auth check that fails fast with a clear message instead of
   surfacing a confusing failure mid-session.

## Guardrails
- One story, ≤3 files/commit, ~2h cap, branch `session-34-<slug>` from `main`. No `main`/autonomous
  commits.
- **Do NOT touch Darshan (S32) or the compression heuristics (S33 area, or the newly-found
  `exit_code == Some(0)` heuristic gap)** — that gap is a separate future session, not S34.
- `verify-session-34.sh` green before closeout; `scripts/verify-closeout.sh` exits 0.
- Meta-rule: this is the third *advised → enforced* fix (S31 #3) — verify against a real
  brownfield repo, not just green tests (the S30/S31 false-green shape).

## Carry-forwards
- **Second agent stays parked** until all 3 core breakages are fixed — S34 is the last of them.
- **Next ground truth = S35** (NO-CODE) — the first GT after all 3 S31 findings are closed;
  should explicitly verify the "fix the core before breadth" bet paid off, and revisit whether
  the second agent gate can now be cleared.
- **New (S33) carry-forward, not S34's job:** `cargo`/`npm`/`pytest` heuristics key off
  `exit_code == Some(0)` directly rather than the engine's inferred success, and real CC never
  sends `exit_code` for Bash — so those heuristics still won't fold typical output on real CC.
  Worth its own future 1-story session.
