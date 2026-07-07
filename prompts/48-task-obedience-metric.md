# Session 48 — The obedience metric: prove (or disprove) that the co-pilot helps (direction B)

> **Founder pick at S47 close (A):** measure before building more. S47 shipped the mid-run murmur but
> left an honest gap — *mechanism verified, value unmeasured.* This session builds the number that
> tells us whether Vajra's guidance actually changes the agent's behaviour.

## Why this session (the S47 gap, one paragraph)
The co-pilot now has two halves — the murmur (proactive, advisory) and the loader/guards (reactive,
blocking). We can see them fire, but we cannot yet say they make the AI do **better work**. Direction B
warns against building guidance on faith (the guard-era trap). The cheapest falsification is a single
number mined from the session trace: **obedience % = clean ÷ (clean + blocked/retried)** — how often the
agent proceeds cleanly vs. gets stopped and has to re-do. It closes the S30/S31 "no metric measures
usage" gap and gives every future co-pilot change a before/after it can be judged against.

## Goal (single story)
Compute and surface an **obedience metric** for a Vajra session: read the session trace (and/or the
hooks' own block records) and report `clean`, `blocked/retried`, and `obedience %` as an honest receipt.
Instrumentation only — this session **measures**, it does not add guidance.

## Recommended slice (founder splits at BOOT if needed — `max_stories: 1`)
- **PRIMARY — the metric:** define "clean" vs "blocked/retried" precisely from an available signal
  (candidates: hook exit-2 events, the session JSONL the meter already parses per ADR-0004, or the
  co-pilot debounce markers), count them, and print `obedience %` on an existing surface. **No 8th
  command** — ride `vajra meter` (the receipt lane) or `vajra check`, whichever fits the data.
- **PAIRED FOLLOW-ON (document, likely S49) — a baseline read:** run the metric across a couple of past
  sessions so the number has context (what's a "good" obedience %?). Its own story if it needs real runs.

## Method
1. **Pick the signal first (this is the design call).** The trace-based options each have a cost:
   - Hook exit-2 events = the truest "blocked" signal, but they're not currently logged anywhere durable
     — you'd add a lightweight append (a JSONL line per block) without turning the guards into a metric.
   - The session JSONL (meter already parses it) shows tool calls + results but not *why* a retry happened.
   - Debounce markers show *what fired*, not *whether it changed behaviour*.
   State the choice + its blind spot plainly (the S47 honesty bar).
2. **Keep it honest about what it proves.** Obedience % measures whether the agent obeyed the rails, not
   whether the *output was better*. Say so — it's a proxy, the first rung of the obedience ladder, not the
   whole answer. (Work-quality is a later, harder measurement.)
3. Advisory/reporting only — no blocking, no new dependency (bash + hand-parse / existing Rust meter),
   skill-not-renderer holds.

## What counts as done (success criteria)
- On a real (or replayed) session, the metric prints `clean`, `blocked/retried`, and `obedience %` with
  the counts traceable to their source.
- `verify-session-48.sh` green; `cargo test` unchanged/green; clippy + fmt clean.
- **Honest check:** state plainly what obedience % does and does NOT prove, and name the one blind spot in
  the signal you chose.

## Guardrails
- Branch `session-48-<slug>` off `main` (**new chat**). Max 1 story, ≤3 files/commit, max 2 assumptions, ~2h.
- Measure, do not guide — this session adds no new advisory/blocking behaviour.
- No 8th top-level command. No new dependency (the S21 rule). Skill-not-renderer holds.
- Self-review before ship: what can break · hidden assumptions · production-ready · repro-evidence only ·
  scope intact.

## Output
- `sessions/session-48-summary.md`: goal achieved? evidence (the metric on a real/replayed session); the
  honest "what it proves / doesn't" read; exactly 3 next options A/B/C.
- Update ROADMAP (obedience-metric backlog item → this slice done) + STATE + KNOWLEDGE.

> Next mandatory NO-CODE ground-truth = **S50** (every 5th; last = S45).
