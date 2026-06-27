# Session 19 — Varta v0 (the skill)

## Goal
Build Varta — the compact ⚡ machine-language an agent learns at boot and speaks all session — shipped as a **skill** (not a compiler), proven against Vajra's own `.ai/`.

## Goal achieved?
Yes — with a scope correction mid-session. The skill teaches the 9-construct ⚡ grammar and the boot ritual (read → internalize → speak); the agent speaks Varta from the **live `.ai/`**. The first pass also shipped a hand-written `vajra.varta` companion + static read-back; on review these were **dropped** — a second copy of the rules drifts from `.ai/` and silently loses config. Varta is a *language spoken from source*, not a persisted file. Nothing parses it — the agent is the runtime.

## Evidence
- `scripts/verify-session-19.sh` — 9 structural checks, ALL GREEN (skill + frontmatter, GRAMMAR.varta has all 9 constructs, co-pilot + human-lane present, **and a guard that no hand-kept companion exists**).
- `scripts/demo-session-19.sh` — shows the skill, the grammar, and a **live read-back** that reads real `.ai/CONSTRAINTS.yaml` values and speaks them as Varta (so the proof reads from source and cannot drift). Surfaces `budget_usd=5.00` + `maturity=L2` — the config the hand-copy had dropped.
- No Rust touched — docs/skill-only session, working tree clean.

## What was built (final state)
- `varta/SKILL.md` — teaches the ⚡ grammar + boot ritual; states the core rule "Varta is a language, not a file."
- `varta/GRAMMAR.varta` — canonical spec, written in Varta itself (dogfood).
- `scripts/verify-session-19.sh` + `scripts/demo-session-19.sh`.
- *Built then deliberately removed:* `varta/vajra.varta` + `varta/READBACK.md` (drift-prone hand-copies — see Decisions).

## Decisions made
- **Varta is a language, not a file** — the agent speaks it from the live `.ai/`; no second copy is maintained.
- **No hand-kept `.varta`** — a persisted `.varta` returns only when it can be **generated** from `.ai/` (one-way render; doesn't break skill-not-compiler). Encoded as a verify guard.
- **9 constructs, frozen** — anything that doesn't fit goes in a `//` comment.

## Known limitations
- No persisted/generated `.varta` yet — the renderer (`.ai/` → `.varta`, drift-free) is a follow-up, as is wiring Varta into `vajra init`.
- `⚡on(...)` loads are read by the agent, not yet fired by a runtime (that is the S21 co-pilot loader).
- Grammar may need 2–3 real sessions to settle before it is locked for good.

## Commits
On `session-19-varta-skill` (see `git log`): skill + grammar → vajra.varta + read-back → verify/demo → closeout → **scope correction** (drop companion, re-point verify/demo, re-sync docs).

## Next session
**S20 is a mandatory NO-CODE ground-truth audit** (every 5th session). The 3 options below set the **S21 code direction** — **picked: A, the co-pilot loader.**

### A — The co-pilot loader (ROADMAP item 8) — PICKED
- **Goal:** make `⚡on(x) ⚡include` real — Vajra surfaces the right context mid-session based on what the agent touches.
- **Why pick this:** it is the heart of "co-pilot, not cop" and the whole reason Varta exists; the language now exists to drive it.
- **Key risk:** needs runtime hooks — the hardest item; may not fit one session.

### B — Generate `.varta` from `.ai/` (S19 follow-up)
- **Goal:** `vajra` renders a drift-free `project.varta` from `.ai/` (CONSTRAINTS + ADRs); wire into `init`/`check`.
- **Why pick this:** closes the exact gap found this session — a persisted spec that cannot drift or lose config.
- **Key risk:** prose-derived rules (AGENTS.md) are harder to render than structured YAML.

### C — First-run "aha" (ROADMAP item 9)
- **Goal:** `vajra init` → first session delivers a visible win in 2 minutes, using Varta as the felt payoff.
- **Why pick this:** directly fixes the S18 "not worth it" finding.
- **Key risk:** polish, not the big bet.
