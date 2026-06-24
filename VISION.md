# Vajra — Crystal Clear

> Status: target product vision. The current repo only implements part of this today.

## One sentence

**Vajra is one command-line tool that guides any AI coding agent (Claude Code, Kimi, Kilo) through your project step-by-step — keeping it on track, in context, and in order — while the agent does the actual coding.**

## The simple picture

- **The AI agent** = the worker (writes code, makes branches, creates files)
- **Vajra** = the coach (tells it what step is next, hands it the context and rules — never codes itself)
- **You** = the boss (you say `vajra next`, the coach moves the worker forward)

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

## What makes it different

- **Works with any agent** — Claude, Kimi, Kilo, others
- **One button: `vajra next`** — advances the whole loop with a single command
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
