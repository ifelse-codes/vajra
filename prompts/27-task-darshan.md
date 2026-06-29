# Session 27 — Darshan: how Vajra *shows* the human, not dumps on them (skill, not renderer)

> CODE/content session. Branch `session-27-darshan` from `main`. Normal loop (BOOT→…→CLOSE).
> Chosen at S26 closeout (founder direction — supersedes the parked "dogfood/verification" session, now backlog). Pairs with Varta: **Varta = the agent talks to itself; Darshan = the user sees.**
> **Name is provisional** — founder confirms/renames at BOOT (Varta was once "VajraSpeak"). Sanskrit *darśana* = "sight, seeing, a glance."

## Why this session
- **The problem (founder, S26):** AI output is a wall — too many words, too dense, too technical. The user has to read line-by-line to understand. That's cognitive overload → AI burnout / "brain rot."
- **The gap:** Vajra built the *agent's* language (Varta) but never the *human's* lane. The whole human side was one line in `VISION.md`: *"Humans just spectate — the `//` comments are the one human-readable lane."* Make it first-class.
- **More than plain-talk:** plain-talk fixes the **words** (simple, spaced). Darshan also fixes the **load** — say more with *fewer* words, carried by **visual structure** (banners, cards, tables, color, diagrams). Same meaning, nothing dropped, far less to read.

## The core idea (locked at S26, confirm at BOOT)
- **Skill, NOT a renderer.** Exactly like Varta: Vajra ships *instructions* the agent internalizes at boot and then speaks all session. Nothing in the Rust binary renders anything. The agent does the drawing with whatever its host supports.
- **Default speaking skill of Vajra to the user.** Governs how *any* agent talks to the human, every reply — not just `vajra` command output.
- **Surface-adaptive — one rule:** *"render the richest visual this surface can handle; always glanceable; never drop meaning."*

| Surface | What Darshan renders |
|---|---|
| Rich chat (Claude desktop/web, Cursor panel) | HTML/SVG widgets — banners, cards, charts, before/after |
| Terminal / TUI (Claude Code CLI) | ANSI color, box-drawing, tables, sparkline/▇ bars, whitespace, unicode icons |
| Plain / no-color (pipes, logs) | structured markdown — short lines, spacing, headers, one idea per line |

## The mechanism (PLAN-time, ≤2 assumptions)
- New `darshan/SKILL.md` (mirrors `varta/SKILL.md`): the boot ritual (read → internalize → speak), the one surface rule, the per-surface tier guide, and **worked before/after examples** for at least the chat tier and the terminal tier (show a wall-of-text vs. the glanceable form).
- **Boot wiring:** Darshan loads at session start as the default human-output skill (decide the lightest mechanism: a pointer from `CLAUDE.md`/`.ai/AGENTS.md`, the same way Varta is taught — do NOT add an 8th command).
- **Portability:** the skill must read as agent-neutral (Claude, Codex, Cursor) — the rule travels; only the richness caps to the surface.
- **Skill-not-renderer guardrail:** no new Rust rendering, no new dep. If you touch `src/`, it's only a doc/pointer.

## Constraints / guardrails
- **Max 7 commands** — no 8th. Darshan rides the boot/skill surface, not a command.
- **≤3 files per atomic commit, max 1 story.** Likely: `darshan/SKILL.md` (new) + a boot pointer (`.ai/AGENTS.md` or `CLAUDE.md`) + one wiring/example file.
- **Scaffold propagation** (emit Darshan from `vajra init`, like S22 did for the co-pilot) — if it pushes past 1 story, **defer to S28** and say so in PLAN.
- **No compromise on content:** Darshan compresses *presentation*, never the actual decision/number/meaning. A glance must carry the same truth as the paragraph.
- **Update `VISION.md`** — add Darshan as the human lane (the counterpart to Varta), like S18 added Varta.

## Definition of done
- `darshan/SKILL.md` exists: boot ritual + the one surface rule + 3-tier guide + before/after examples (chat + terminal).
- Darshan is wired as the **default** human-facing speaking skill at boot (demoed: the agent answers a sample in glanceable form, with a terminal-tier fallback shown).
- `scripts/verify-session-27.sh` exits 0 (asserts: skill exists, has all 3 surface tiers, the "never drop meaning" rule, a terminal fallback, and the boot wiring); `scripts/demo-session-27.sh` shows the wall-of-text → glance transform in both chat and terminal form.
- `cargo test` green; clippy clean (if any `src/` touched).
- Decide + document: does Darshan propagate into `vajra init` now, or is that S28?

## Output
- Working Darshan skill + boot wiring + verify/demo + `sessions/session-27-summary.md` ending in exactly 3 next options (A/B/C).

## Carry-forwards
- **Second agent stays parked** — owner-gated on founder satisfaction with Vajra-on-Claude (memory `vajra-second-agent-gate`). Darshan is part of *making Claude satisfying*, so it's on the right track, not a detour.
- **Dogfood / "verification" session** (use Varta+Darshan on a real project, log friction, fix-or-defer) — moved to backlog; revive once Darshan ships (was `prompts/27-task-varta-dogfood.md`, retired).
- **Recurring low drift:** STATE.md writes PR status as "pending merge" before merge (S15/S20/S25) — at closeout write "open (merge after closeout)".
- **Still open:** `vajra estimate` 3:1 ratio unvalidated; `vajra claude` no auth pre-check before launch (S18 onboarding gap).
