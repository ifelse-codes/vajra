# Session 32 — Darshan enforcement: move it from *advised* → *enforced* (CODE)

> **The S31 dogfood made this #1.** Ran the real `vajra claude` loop against an existing codebase and the agent **dumped walls of dense text** — Darshan (S27), the skill that exists to kill exactly that daily load, **was not obeyed.** Root cause: Darshan is wired only as a prose pointer in `.ai/AGENTS.md`; the `SessionStart` boot hook never surfaces `darshan/SKILL.md`; it is not a registered Claude Code skill. Nothing makes the agent load or follow it. This is the most-felt of the three S31 findings (felt every reply) and one of two that prove **Vajra violates its own "enforcement, not prompts" wedge.**

## Goal (one story)

Make the agent **actually load and follow** `darshan/SKILL.md` in a real `vajra claude` session — move Darshan from *advised* to *enforced*, the same arc the co-pilot loader walked (S19 language → S21 enforce).

## What to actually do

1. **Minimum (must-have): surface Darshan at boot.** Make the `SessionStart` boot packet (`scripts/hook-session-start.sh`) include `darshan/SKILL.md` (or a pointer the agent reliably opens) so it is loaded into context every session, not buried in an AGENTS.md table the agent may skip. Verify it actually appears in the real boot output.
2. **Design the stronger enforcement** — a hook *cannot* read the agent's prose, so true enforcement is a design problem. Pick and justify ONE pragmatic mechanism (e.g. a boot-packet directive the agent must acknowledge; a stop/output hook heuristic; a Darshan "speak-back" at boot like Varta's read→internalize→speak ritual). Don't over-build — the minimum (load it every session) may be 80% of the win; document the rest as follow-on.
3. **Dogfood it:** confirm in a real session that the agent's output is now glanceable (tiers per the surface), not a wall of text.
4. **Propagate** the boot-surfacing into `vajra init`'s scaffolded `hook-session-start.sh` so every project inherits it (the S22/S28/S29 `include_str!` one-source-of-truth pattern).

## Guardrails

- One story (Darshan enforcement). ≤3 files/commit, ~2h cap, branch `session-32-<slug>` from `main`. No `main`/autonomous commits.
- **Skill, not renderer** stays intact — nothing in the binary draws Darshan; you only change *when/whether the agent loads the skill*, not add a renderer.
- `verify-session-32.sh` green before closeout; `scripts/verify-closeout.sh` exits 0.
- No 8th top-level command.

## Carry-forwards into S32

- **Compression schema fix is pre-pinned for a later session** (S31 finding #2): remove `rename_all="camelCase"` from `HookInput` only; keep it on `HookToolResponse`; regression test from a verbatim captured real CC payload (`.ai/KNOWLEDGE.md` S31). Do NOT fold it into S32 (1-story discipline).
- **Brownfield onboarding** (S31 finding #3) is the session after.
- **Second agent stays parked** until the core (these 3) is fixed.
- **Meta-rule:** every fix moves a feature from *advised* → *enforced*.
