# Session 18 — Product Review + Vision Building

## Goal
Walk through every Vajra command hands-on, collect founder feedback, brainstorm what's next, and crystallize the product vision + roadmap. INTERACTIVE — no feature code.

## Goal achieved?
Yes. Ran the full walkthrough, surfaced the core gap, reframed the product (co-pilot, not cop), and designed a new language — **Varta** — now written into `VISION.md` and `ROADMAP.md`.

## Hands-on walkthrough (founder ran each in `/tmp/vajra-demo`)
- `vajra init` — scaffolded 16 files. Works.
- `vajra check` — 9/10, correctly failed on `main`. Works.
- `vajra next` — full handoff packet printed. Works.
- `vajra estimate` — `~$0.24` prediction. Works.
- `vajra claude` — launched Claude Code; hit `/login` (unauthenticated). Surfaced an onboarding gap.

## The key finding (founder's words)
- "It all looks fine, not worth it — I didn't understand what I'm doing."
- Running the commands produces **files, not a feeling**. The first-run payoff is invisible.
- Deeper pain from 2 months of `.ai/` use across projects: **agents forget the vision and drift toward finishing the task fast.** Front-loading a big `AGENTS.md` does not stick.

## The reframe
- **Co-pilot, not cop.** Vajra should guide the agent in real time — like ADAS guides a car or an F1 race engineer guides the driver — not catch mistakes after the fact.
- Guidance goes **both ways**: whisper to the agent (auto-feed context) *and* show the human (so they can steer).

## The design — Varta (named by founder; Sanskrit "talk/dialogue")
A compact, machine-only context language. Designed live by iterating through rejected options:
1. Pure symbols → rejected (LLM must decode).
2. Small common words → rejected (blend into prose, get confused).
3. Glyph + word → closer.
4. **C/C++/Java-inspired syntax + `⚡` keyword prefix → locked.** LLMs are trained on a mountain of C/Java; braces + keywords parse unambiguously, and `forbid`/`final`/`assert`/`enum` already mean what we want. `⚡` marks keywords as machine syntax that can never blend into prose.

**Mechanism = skill, NOT compiler.** Like the plain-talk skill: the agent loads Varta at session start, *internalizes* it (a re-train before work), then speaks it all session to manage its own notes + the `.ai/` files, firing `⚡on(...)` loads. Vajra ships the skill; nothing parses it but the agent. Humans only spectate the `//` comments.

**The discovery:** the pattern already existed in the founder's own repos — `kreeda/.ai/KREEDA-BOOT.yaml` had a compact dialect (`key=value|...`, `NEVER/ALWAYS`, `load-on:`). Varta formalizes it.

## Varta sample
```
⚡forbid {
  work_on_main;              // branch session-NN-slug first
  commit_without_approval;   // wait: approved | lgtm | ship it
  files_per_commit > 3;
}
⚡on (compression)   ⚡include "src/engine/*";
⚡on (drift_check)   ⚡include "STATE.md", git_status;
⚡enum next { A="second agent"; B="write spec"; C="co-pilot drift watch"; }
```

## Decisions locked (S18)
- Product reframe: **co-pilot, not cop.**
- New direction: **Varta** — ⚡ C-inspired machine language, delivered as a **skill**.
- Name: **Varta** (was working-named "VajraSpeak").
- Next build: **Varta v0 — the skill** (Phase 2, item 7).

## Outputs this session
- `VISION.md` — added "the problem we're really solving", "the next leap — Varta", co-pilot framing.
- `.ai/ROADMAP.md` — Phase 2 rewritten as the Varta direction with 3 ranked builds.
- Memory: `vajra-varta` saved.

## Next options (A/B/C) — picked: A
| | Build | Goal | Why | Risk |
|---|---|---|---|---|
| **A** *(picked)* | Varta v0 — the skill | Write the Varta skill + convert Vajra's `.ai/` to one `.varta`; prove an agent learns and speaks it | Heart of the new vision; attacks drift directly | Language may need 2–3 sessions to settle |
| B | Co-pilot loader | Make `⚡on(x) include` real — surface context mid-session | The race-engineer magic; nobody else has it | Needs runtime hooks; build after A |
| C | First-run "aha" | `init` → visible win in 2 min | Fixes the "not worth it" feeling | Polish, not the big bet |

## Carry-forwards
- Build S19 = Varta v0 (the skill + Vajra's own `.varta`).
- `vajra claude` onboarding gap: no auth pre-check before launch (relates to build C).
- Validate Varta over 2–3 real sessions before building the runtime co-pilot (B).
