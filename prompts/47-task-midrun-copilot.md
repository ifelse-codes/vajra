# Session 47 — The mid-run co-pilot: guide the AI *during* the work (direction B, first value session)

> **Founder pick at S46 close (B):** build the co-pilot that makes the AI do **better work** — guide it
> mid-run, not just block it. This is the first session of direction **B** ("your AI does better work"),
> the return to the north star after the S37→S46 enforcement arc (now DONE + live-verified).

## Why this session (the S46 pivot, one paragraph)
S46 proved the guard holds live — and the founder's read was *"basically all we've done is stop it from
commit/push."* A tool that only says "no" is thin. Vajra's co-pilot today fires **only** at a PreToolUse
tripwire and **only by blocking** (exit 2 until context is surfaced). The missing half is **proactive,
non-blocking guidance mid-run** — feed the right context at the right moment so the AI gets it right the
first time (fewer wrong turns = less re-work = the real "cheaper", since compression saves ~$0). Vajra
ignores the two hooks that make this possible today: `UserPromptSubmit` and `PostToolUse`.

## Goal (single story)
Wire a **mid-run murmur**: on `UserPromptSubmit` (each user turn), the co-pilot surfaces the most relevant
`copilot.on` context for the work in play as an **advisory injection** (exit 0 — guide, do **not** block),
so the agent has the right context *before* it acts — not only after it trips a guard.

## Recommended slice (founder splits at BOOT if needed — `max_stories: 1`)
- **PRIMARY — the murmur (guide):** a `UserPromptSubmit` hook that reads the live `copilot.on` rules
  (same source as `hook-copilot-loader.sh`), picks the rule(s) relevant to the current context, and prints
  a short advisory to stdout (injected into the agent's context). **Non-blocking, exit 0**, tiny (< a few
  lines — honor the <5% footprint rule). Per-session debounce so it murmurs once per rule, not every turn.
- **PAIRED FOLLOW-ON (document, likely S48) — the obedience metric:** measure obedience % =
  clean ÷ (clean + blocked/retried) from the session trace, so we can tell whether the guidance actually
  helps. Instrumentation, not guidance — its own story.

## Method
1. Study `scripts/hook-copilot-loader.sh` (the PreToolUse blocker) — reuse its rule-parsing + debounce, but
   invert the posture: **advise (exit 0), never block.** `UserPromptSubmit` has no `tool_input.command`, so
   relevance keys off the session's recent files / a lightweight "current work" signal, not a Bash command.
2. Wire it into `.claude/settings.json` `UserPromptSubmit` (a hook type Vajra does not use yet) — repo +
   the `vajra init` scaffold (`TPL_CLAUDE_SETTINGS`), byte-identical via `include_str!` (the S22/S29 pattern).
3. Keep it **advisory at every maturity** (guidance, not enforcement — this is the B lane). Maturity may
   tune verbosity, but it must never `exit 2`.

## What counts as done (success criteria)
- On a fresh session, editing/working in an area with a matching `copilot.on` rule, the murmur **surfaces
  the right context proactively** (visible in the boot/turn output) — WITHOUT blocking the agent.
- `vajra init` scaffolds the new hook byte-identical; a real `vajra init` into a temp repo shows it wired.
- `verify-session-47.sh` green; `cargo test` unchanged/green; clippy + fmt clean.
- **Honest check (the founder-flagged risk):** state plainly whether this is guidance we can *show helps*,
  or a helper built on faith. The obedience metric (follow-on) is how we'll actually measure it.

## Guardrails
- Branch `session-47-<slug>` off `main` (**new chat**). Max 1 story, ≤3 files/commit, max 2 assumptions, ~2h.
- **Guide, do NOT block** — this hook must never `exit 2`. If it can't decide, stay quiet (exit 0).
- No 8th top-level command. No new dependency (bash + hand-parse, the S21 rule). Skill-not-renderer holds.
- Self-review before ship: what can break · hidden assumptions · production-ready · repro-evidence only ·
  scope intact.

## Output
- `sessions/session-47-summary.md`: goal achieved? evidence (the murmur firing live, non-blocking); the
  honest "does it help / can we prove it yet" read; exactly 3 next options A/B/C.
- Update ROADMAP (co-pilot backlog item → this slice done) + STATE + KNOWLEDGE.
