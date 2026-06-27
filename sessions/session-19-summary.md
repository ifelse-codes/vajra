# Session 19 — Varta v0 (the skill)

## Goal
Build Varta — the compact ⚡ machine-language an agent learns at boot and speaks all session — shipped as a **skill** (not a compiler), and convert Vajra's own `.ai/` into one `vajra.varta` as the worked proof.

## Goal achieved?
Yes. The skill teaches the 9-construct ⚡ grammar and the boot ritual (read → internalize → speak); `vajra.varta` carries Vajra's real operating context (rules, limits, locked ADRs, `⚡on` co-pilot loads); a read-back test proves an agent answers the rules from the spec alone. Nothing parses Varta — the agent is the runtime.

## Evidence
- `scripts/verify-session-19.sh` — 10 structural checks, ALL GREEN (all 9 constructs present, `⚡forbid` + `⚡on(compression)` expressed, read-back complete).
- `scripts/demo-session-19.sh` — shows skill + grammar + worked example + read-back, runs clean.
- `varta/READBACK.md` — 6/6 questions answerable from `vajra.varta` alone (forbidden / loads-on-compression / limits / locked decisions / the goal / pre-ship checks).
- No Rust touched — docs/skill-only session, working tree clean.

## What was built
- `varta/SKILL.md` — teaches the ⚡ grammar + boot ritual (modeled on the plain-talk skill).
- `varta/GRAMMAR.varta` — canonical spec, written in Varta itself (dogfood).
- `varta/vajra.varta` — Vajra's `.ai/` rendered in Varta (companion, not replacement).
- `varta/READBACK.md` — the read-back proof.
- `scripts/verify-session-19.sh` + `scripts/demo-session-19.sh`.

## Decisions made
- **Standalone files** in `varta/` for v0; wiring into `vajra init` scaffold deferred (keeps story atomic, no Rust change).
- **Companion, not replacement** — `.ai/*.md` stays source of truth; `.varta` is the agent-facing render.
- **9 constructs, frozen** — no construct #10; anything that doesn't fit goes in a `//` comment.

## Known limitations
- Cold-agent test not yet run (the static `READBACK.md` is self-authored proof; a fresh subagent test is available on request).
- Varta not yet dropped by `vajra init`, and the `⚡on` loads are read by the agent, not yet fired by a runtime (that is Phase 2 item 8).
- Grammar may need 2–3 real sessions to settle before it is locked.

## Commits
1. `47ee4e0` — SKILL.md + GRAMMAR.varta (2 files)
2. `444f2d6` — vajra.varta + READBACK.md (2 files)
3. `d97a735` — verify + demo scripts (2 files)

## Next session
**S20 is a mandatory NO-CODE ground-truth audit** (every 5th session). The 3 options below set the **S21 code direction** the audit should rerank toward.

### A — The co-pilot loader (ROADMAP item 8)
- **Goal:** make `⚡on(x) ⚡include` real — Vajra surfaces the right context mid-session based on what the agent touches.
- **Why pick this:** it is the heart of "co-pilot, not cop" and the whole reason Varta exists; the language now exists to drive it.
- **Key risk:** needs runtime hooks — the hardest item; may not fit one session.

### B — Wire Varta into `vajra init` (deferred S19 follow-up)
- **Goal:** `vajra init` drops the `varta` skill + renders a starter `project.varta` from the scaffolded `.ai/`.
- **Why pick this:** small, mechanical, closes the v0 loop so every new repo gets Varta automatically.
- **Key risk:** low — it is plumbing; the payoff is invisible until the loader (A) lands.

### C — First-run "aha" (ROADMAP item 9)
- **Goal:** `vajra init` → first session delivers a visible win in 2 minutes, using Varta as the felt payoff.
- **Why pick this:** directly fixes the S18 "not worth it" finding; Varta is the natural vehicle for the aha.
- **Key risk:** polish, not the big bet — easy to over-invest for a demo effect.
