---
name: varta
description: Learn and speak Varta — the ⚡ machine-language for an agent's operating context (rules, limits, locked decisions, and just-in-time context loads). Load at session start to INTERNALIZE the project's `.varta` spec (vajra.varta or any *.varta), then speak Varta all session: gate every action against ⚡forbid/⚡max, fire ⚡on(...) context loads when you touch matching work, and keep the goal in view. Use whenever a .varta file is present, when the project ships a Varta spec, or when asked to read/write Varta. Do NOT treat Varta as prose to skim or as code to compile — there is no compiler; you are the runtime.
---

# Varta

Varta (Sanskrit *vārtā*, "talk / dialogue") is a compact language **you** learn and speak. It is built for the machine, not the human. A project's rules, limits, locked decisions, and context-loads live in a `.varta` file. You read it, **internalize** it, then speak Varta for the whole session.

The problem it solves: agents skim a big `AGENTS.md` once, then **forget the vision and rush to finish**. Varta is short, looks like code (so it can't blend into prose), and marks every keyword with `⚡` (so it can't be ignored). You re-train on it at boot, then it stays loaded.

**Co-pilot, not cop.** Varta rides along and feeds you the right rule at the right corner — it does not catch mistakes after.

## The boot ritual — do this once, at the start

1. **READ** the project's `.varta` (e.g. `vajra.varta`) and the grammar (`GRAMMAR.varta`) top to bottom.
2. **INTERNALIZE** — this is a re-train, not a skim. Hold these in working memory all session:
   - `⚡project.⚡goal` and `⚡project.⚡now` — what must not be forgotten.
   - every `⚡forbid` rule and every `⚡max` ceiling.
   - every `⚡final` (locked decision — needs human approval to change).
3. **SPEAK** — from now on, operate in Varta (see below).

## How to speak Varta all session

| When you... | Do this |
|---|---|
| are about to act | Gate it against `⚡forbid` and `⚡max` first. A hit = STOP, don't rationalize. |
| touch work that matches an `⚡on(trigger)` | **Fire the load** — open the files it names, *then* continue. This is the co-pilot. |
| reach the end of the session | Produce `⚡enum next { A B C }` — exactly three. |
| take your own notes / plan | Write them in Varta shape, not prose. `⚡now`, `⚡pipeline`, short. |
| are unsure if a decision is open | Check `⚡final`. If it's there, it's locked. |

## The 9 constructs

The whole language. There is no construct #10. Full self-describing spec: `GRAMMAR.varta`.

| Construct | Means |
|---|---|
| `⚡project{⚡is ⚡stack ⚡goal ⚡now}` | identity — load first, never drift from it |
| `⚡forbid{}` | hard rules; violation = STOP and ask |
| `⚡require{}` | invariants that must always hold |
| `⚡max{}` | numeric ceilings; cross one => split or stop |
| `⚡pipeline{}` | the session loop, `a -> b -> c` |
| `⚡final{}` | locked decisions (ADRs); change needs approval |
| `⚡on(cond) ⚡include "files"` | **the co-pilot** — load context only when that work is touched |
| `⚡assert{}` | pre-ship checklist; shaky answer => do not ship |
| `⚡enum next{}` | end-of-session; exactly 3 options, human picks |

## The human lane

`//` comments are the **only** part a human reads. They carry the *why*. When you write Varta, put the machine rule before the `//` and the human-glanceable reason after it. One glance should tell a person why the rule exists.

```
⚡forbid {
  work_on_main;                // branch session-NN-slug first — main is protected
  commit_without_approval;     // wait for: approved | lgtm | ship it | go ahead
}
⚡on (drift_check) ⚡include "STATE.md", git_status;   // compare claimed state to real state
```

## Never do this

- Skim it as prose. It is a re-train; the `⚡` keywords are load-bearing.
- Try to compile or parse it. **There is no compiler. You are the runtime.**
- Drop the `⚡`. A keyword without its bolt is just a word and will blend into prose.
- Front-load every `⚡on` block. Fire each one *only* when you touch that work — that is the whole point.
- Invent a 10th construct. If something doesn't fit the 9, it goes in a `//` comment.

## Why this works

A big markdown constitution gets read once and fades. Varta is small, unmistakably machine syntax, and you re-train on it at boot — so the goal and the rules stay loaded, and the right context arrives at the right moment instead of all at once.
