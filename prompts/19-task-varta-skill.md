# Session 19 — Varta v0 (the skill)

## Goal
Build the first version of **Varta** — the compact ⚡ machine-language the agent learns at boot and speaks all session. Ship it as a **skill** (not a compiler), and convert Vajra's own `.ai/` workflow into one `.varta` spec as the proof.

## Type
CODE.

## Background (from S18)
- Founder pain: agents forget the vision and rush to finish; front-loading a big `AGENTS.md` doesn't stick.
- Reframe: **co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer).
- Varta is the answer: looks like code (C/Java) so it never blends into prose; `⚡` marks every keyword as machine syntax; the agent *internalizes* it at boot, then uses it all session.
- Mechanism = **skill**, like the plain-talk skill. Nothing parses Varta but the agent.
- Pattern was discovered in `kreeda/.ai/KREEDA-BOOT.yaml`. Full design in `VISION.md`, `.ai/ROADMAP.md` Phase 2, and memory `vajra-varta`.

## Varta language (locked S18)
C/Java-inspired syntax + `⚡` keyword prefix. Constructs:
`⚡project{⚡is ⚡stack ⚡goal ⚡now}` · `⚡forbid{}` (hard rules) · `⚡require{}` (invariants) · `⚡max{}` (limits) · `⚡pipeline{}` (loop, `a->b->c`) · `⚡final{}` (locked decisions) · `⚡on(cond) ⚡include "files"` (the co-pilot) · `⚡assert{}` (pre-ship review) · `⚡enum next{}` (A/B/C). `//` comments = human-glanceable *why*.

## Deliverables
1. **The Varta skill** — a `SKILL.md` (+ supporting files) that teaches an agent the ⚡ grammar and instructs it to learn-then-speak Varta for the session. Decide location: ship inside `vajra init` scaffold and/or as a standalone skill.
2. **`vajra.varta`** — Vajra's own `.ai/` operating context expressed in Varta, as the worked example.
3. **A short test** — evidence that an agent, given the skill + `vajra.varta`, correctly reads the rules and can answer "what's forbidden / what loads when I touch compression."

## Open questions to resolve early
- Does `vajra init` drop the skill, or is Varta a separate install? (Pick one for v0.)
- Is `.varta` a replacement for the `.ai/` markdown, or a generated companion? (v0 recommendation: companion — keep markdown as source, render `.varta` for the agent.)
- Minimum viable grammar — ship the 9 constructs above, nothing more.

## Exit Criteria
- `scripts/verify-session-19.sh` exits 0.
- `scripts/demo-session-19.sh` shows the skill + `vajra.varta` + the read-back test.
- Session summary with exactly 3 next options (A/B/C).

## Constraints
- Branch: `session-19-varta-skill`.
- Max 1 story, ≤3 files per commit, max 2 assumptions.
- Keep it small — v0 is "the language + the skill that drills it in", not the runtime co-pilot (that's Phase 2 item 8).
