# Vajra — Crystal Clear

> Status: target product vision. The current repo only implements part of this today.

## One sentence

**Vajra is one command-line tool that guides any AI coding agent (Claude Code, Kimi, Kilo) through your project step-by-step — keeping it on track, in context, and in order — while the agent does the actual coding.**

## The simple picture

- **The AI agent** = the driver (writes code, makes branches, creates files)
- **Vajra** = the co-pilot (calls the next move, feeds the right rule at the right moment — never drives itself)
- **You** = the team principal (you say `vajra next`, the co-pilot moves the driver forward)

**Co-pilot, not cop.** Vajra does not wait for the agent to crash and then write a ticket. It rides along and guides — like ADAS guides a car, or a race engineer guides an F1 driver through each corner.

## What it does

| # | Job | Plain meaning |
|---|---|---|
| 1 | **Guides the workflow** | Tells the agent the right step, the right order, start to finish |
| 2 | **Keeps memory** | Feeds the agent what the product is, the roadmap, the rules — so it never forgets between chats |
| 3 | **Enforces discipline** | One branch per step, one step at a time — no drift, no chaos |
| 4 | **Saves a few tokens** *(bonus)* | Trims long successful output before the agent sees it; failures pass through untouched |

## How you use it

| You type | What happens |
|---|---|
| `vajra claude` *(new project)* | Asks a few questions, then has the agent set up the workflow — once |
| `vajra claude` *(existing project)* | Loads the memory, points the agent at the current step |
| `vajra next` | "Step done — here's the next one + all its context." Agent continues. |

## The problem we are really solving

- Agents (Claude, Kimi, Codex) **forget the vision** and rush to finish the task fast.
- The big idea drifts away mid-session. The rules stop being followed.
- Front-loading a giant `AGENTS.md` does not stick — the agent skims it once and moves on.

## The next leap — Varta (the agent's language)

**Varta** *(Sanskrit: "talk / dialogue")* is a compact language the agent learns and speaks — built for machines, not humans.

- **Looks like code** (C / Java style), so it can never blend into prose. Keywords carry a `⚡` mark.
- **Delivered as a skill** — not a compiler. The agent loads it at the start, *internalizes* the rules (a re-train before work), then speaks Varta all session to manage its own notes and the `.ai/` files.
- **The co-pilot lives here.** `⚡on(compression) ⚡include "src/engine/*"` means: pull that context *only* when the agent touches that work. Right rule, right corner — not everything up front.
- **Humans get their own lane — Darshan** (below). Inside Varta, the `//` comments carry the *why*; everything the user *sees* is rendered by Darshan.

A taste:

```
⚡forbid {
  work_on_main;              // branch session-NN-slug first
  commit_without_approval;   // wait: approved | lgtm | ship it
}
⚡on (drift_check) ⚡include "STATE.md", git_status;
```

## The human's lane — Darshan (how you *see*)

**Darshan** *(Sanskrit: "sight, seeing, a glance")* is the counterpart to Varta. **Varta is how the agent talks to itself; Darshan is how the user sees.**

- **Fixes the wall of text.** AI output is too many words, too dense — you have to grind it line-by-line. Darshan says *more with fewer words*, carried by visual structure (banners, cards, tables, color, bars).
- **More than plain words.** Plain-talk fixes the *words*; Darshan also fixes the *load* — same meaning, nothing dropped, far less to read.
- **Delivered as a skill** — not a renderer. The agent internalizes one rule at boot and draws with whatever its screen supports: rich chat (HTML/SVG), terminal (color + box-drawing), or plain markdown.
- **One rule:** *render the richest visual this surface can handle; always glanceable; never drop meaning.*

A taste — the same status, glanceable:

```
┌─ Session done ─────────────── ✓ ─┐
│  verify   9/9 pass  ▕████████▏    │
│  PR       ⚠ open                  │
└───────────────────────────────────┘
```

## What makes it different

- **Works with any agent** — Claude, Kimi, Kilo, others
- **One button: `vajra next`** — advances the whole loop with a single command
- **Co-pilot, not cop** — guides the agent in real time, instead of catching mistakes after
- **Varta** — a machine language that keeps the vision loaded and the rules followed
- **Honest** — modest token savings, no hype

## Rules

- Vajra **guides**, the agent **does the work** — Vajra never touches code itself
- It is **not done until it runs** on your machine — never trust code that only *looks* done
- `vajra next` working end-to-end is the **make-or-break** — prove that first, everything else is decoration

## Honest truth

- Every piece exists elsewhere (GSD, SuperClaude, Headroom)
- The edge is the combination + the shape: one cross-agent binary, one `vajra next` button, honestly built
- This is a strong learning-and-shipping project with a real, clear shape

## In one breath

*Vajra is the coach that makes any AI coding agent do the right work, in the right order, with the right context — driven by one command, `vajra next`.*
