# DECISION-009 — The Terminal Demo Is the Human Demo

**Status:** Accepted
**Date:** 2026-09-14
**Session:** S167
**Rests on:** DECISION-007 (agent fleet) — its S136 (`--sync-fleet`), S141 (render stamp), S142 (stamped shell scripts in `SYNC_HOOKS`) and S143 (constitution body) addenda · DECISION-008 (session-type detection; the `check_demo_markers` demo enforcement it documents)
**Names:** S168 (Vajra fills in the number tiles + scorecard itself)

---

## Context

Coding agents asked for a session demo in chitra (a project governed by Vajra) made HTML slide
decks (`chitra/design-reference/session-21/22/25-demo.html`). The founder liked their *outline* —
headline + number tiles + a one-breath verdict · the story · real before → after · the rule in
plain words · odd-input cases · a scorecard with honest notes · what's next · a small-words
helper — and wanted that richness **in the terminal, produced by the demo itself**, for every
project that uses Vajra.

Root cause: Vajra's own rules split the demo in two. The template note, `.ai/AGENTS.md` step 5
and `.ai/CONSTRAINTS.yaml#demo` (`presentation: interactive_html` + `presentation_rules`) said
"this bash script is for CI/verify; when the user asks, present an interactive HTML slide deck."
So the script the Demo-er gate re-runs was never the thing a human watched, and each agent drew
its own deck — or none. Drawing aligned boxes by hand in bash is also hard (bash 3.2 counts
bytes, not characters, unless the locale is UTF-8), so the plain template stayed thin.

## Decision

1. **The terminal demo is the human demo.** `scripts/demo-session-NN.sh` is the one demo. Run in a
   terminal it plays as a slide deck; piped (CI, the Demo-er gate) it prints every slide in order
   with the `demo:<element>` markers. The `interactive_html` rule is retired everywhere it lived.
2. **The kit is a scaffolded helper the demo script calls — not a Darshan renderer.**
   `scripts/demo-kit.sh` (bash 3.2 safe, no dependencies) draws headline, tiles, verdict boxes,
   before/after panels, tables, the scorecard and the deck pager, in three looks (deck · stream ·
   plain/no-color). Darshan stays a skill (how the agent talks); the kit is code the agent's demo
   calls. Nothing inside the `vajra` binary draws a slide.
3. **The template is the rich outline, and an unfilled outline fails.** Seven sections
   (`headline story before_after rule cases scorecard next`). Each ships as a `dk_todo` that fails
   the demo by name; `dk_finish` also fails when a section never rendered, no live check ran, or a
   live check failed. A pretty empty deck would be a worse hollow green than a plain log.
4. **The gate does not change.** The four `demo:` elements and `demoer::missing_elements` stay as
   DECISION-008 left them (header comment only). `dk_section` prints each marker where its section
   really renders — headline→`header`, `before_after`, `cases`, scorecard→`summary_table` — and
   only when not in a terminal, which is how the gate runs a demo. Deck mode needs stdin AND
   stdout to be terminals, so the gate can never hang; `DEMO_MODE=stream` forces the plain run.
5. **Both files join `SYNC_HOOKS`** (DECISION-007 S142 shape): scaffolded stamped with the
   shell-comment `vajra-render-sha:` line, upgraded by `vajra init --sync-fleet` through the same
   four states. No new sync machinery, no new file state, no 8th command, no new dependency.

## The open question — decided: a frozen list of shipped template bytes

Every existing project's `scripts/demo-session-template.sh` was scaffolded **unstamped** (plain
`fx`), so under S141/S142 it classifies `Drifted` and needs `--overwrite-drifted` — which also
overwrites any *other* drifted file the user customised.

**Decision:** for this one target only, an unstamped file whose sha256 exactly equals a template
version Vajra itself shipped counts as a provable older render → `StaleRender` (auto-upgrade).
Anything else stays `Drifted`, exactly as today.

- **Why it is safe:** identical bytes mean nothing was customised, so the upgrade destroys nothing.
  The template carries no fill placeholders, so every install received the same bytes. A copy not
  on the list falls back to today's behaviour — the list can be incomplete, never wrong.
- **Why not "accept and disclose":** telling every adopter to run `--overwrite-drifted` for a file
  they never touched puts their customised hooks at risk.
- **Not invented provenance (S136):** S136 rejected git blame, commit messages and timestamps,
  which only correlate with "Vajra wrote this". An exact byte match is a pure function of the bytes.
- **Not a hand-typed copy of a live value** (the "derive the default" rule): the list is closed
  history. Every render from S167 on is stamped, so it can never need to grow.
- **This departs from the S141/S142 limit** "smooth going forward, never retroactively" — on
  purpose, for one target, for the reasons above. The kit is new, so it needs no list.

The list was derived once from git history, before S167 changed the file:

```bash
for c in $(git log --format=%h -- scripts/demo-session-template.sh); do
  git show "$c:scripts/demo-session-template.sh" | shasum -a 256
done
# a78e07e  a4fd31c57b2a795971501417873c7ba84e6bc76a58115344bcf3d1747704430b  (the only shipped version)
```

A test re-derives the hashes from git when `.git` exists, so the list cannot silently disagree
with history.

## Rejected alternatives

| Alternative | Why rejected |
|---|---|
| Keep agent-made HTML decks | That split is the root cause: the gate re-runs a script the human never sees, and every project gets a different deck, or none. |
| A renderer inside the binary | An 8th command or a new dependency, and a second source apart from the script the gate re-runs; projects on an older `vajra` would lose their demo. |
| Vajra-built slides now | Changes the Demo-er gate's logic, which is out of scope here. Filling the tiles and scorecard from checks Vajra already runs is **S168**. |

## Honest limits

- A lazy agent can still fill every section thinly and pass — the markers and `dk_todo` prove the
  outline was *filled*, not that it *shows* anything. S168 moves the numbers and the scorecard
  into checks Vajra runs itself.
- crates.io and Homebrew users get the kit only by upgrading `vajra`, then running
  `vajra init --sync-fleet`.
- Not tested: Windows, light-background terminals.
