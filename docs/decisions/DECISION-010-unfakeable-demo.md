# DECISION-010 — A Demo That Cannot Be Faked

**Status:** Accepted
**Date:** 2026-09-14
**Session:** S168
**Overturns:** DECISION-009 §4 ("The gate does not change")
**Rests on:** DECISION-009 (the terminal demo is the human demo; the kit is a scaffolded helper) · DECISION-008 (a check fires only on a marker that is present) · DECISION-007 S141/S142 (the kit and template are stamped `SYNC_HOOKS` targets)
**Design advice:** `.ai/handoffs/session-168-design-advisor.md` (recs 1–7)

---

## Context

S167 made every demo a terminal deck, but its cold review named the fakest green: `dk_check`
accepted the literal word `PASS`, so `dk_check "anything" PASS` was a live check that could not
fail. Number tiles were free text too — a demo could type `STATIONS|8|of 8` whatever the truth.
The Demo-er gate only checked exit 0 plus four `demo:` markers, so it could not tell.

## Decision

1. **`dk_check` runs a command.** `dk_check [-q] "label" <command…>` runs the command (through
   `dk_run_v`, so `_DK_OUT` keeps its output) and records its real exit code. A bare `PASS`, `FAIL`
   or digit is refused by name, counted as a failure, and the demo exits non-zero. `-q` keeps a
   check off-screen but still counted.
2. **`dk_finish` prints `demo:complete`** (outside a terminal) only when the whole outline passed.
3. **Vajra fills in the numbers.** `vajra next --demo-facts NN` (a flag, not an 8th command) prints
   the session's derived facts, one `key=value` per line, in a closed, stable order:
   `session · stations_passed · stations_total · stations_names · review · recs_answered ·
   recs_total · crew_handoffs · crew_roles`. It reads only — it runs no verify or demo script, so a
   demo calling it during its own gate re-run cannot recurse. An absent fact prints `none` (or `0`).
   `dk_vajra_tiles NN` / `dk_vajra_scorecard NN` draw these, labelled "filled in by Vajra", and print
   one `demo:fact key=value` line per fact.
4. **The gate proves it.** A demo is **kit-built** when its script text sources `demo-kit.sh` OR its
   live output carries any `demo:kit`, `demo:complete` or `demo:fact` line (any one sign is enough —
   a faker must remove all of them). For a kit-built demo the gate also requires `demo:complete` and
   the full fact set for the closing session, and compares every `demo:fact` line to the facts it
   derives itself — exact `key=value`, color codes stripped, closed key list. An unknown key, a key
   printed twice with different values, or any differing value BLOCKS, naming the mismatch.
5. **No skew, no race.** The gate derives facts from the folder the demo ran in (the clean room
   when enabled), right after the run, and sets `VAJRA_BIN` to its own executable for the run; the
   kit calls `${VAJRA_BIN:-vajra}`. The gate writes nothing between the run and the comparison.
6. **`complete` joins `demo.required_elements`** in this repo's `CONSTRAINTS.yaml` and in the
   `vajra init` scaffold (a new project's first demo comes from the kit template, so it has no legacy
   demo to break). The built-in default (`DEFAULT_REQUIRED_ELEMENTS`) stays four elements, so no
   existing project turns red at once. `fact` does not join the list: fact checking is triggered by
   kit-built detection.

## What existing projects get, and when

- `CONSTRAINTS.yaml` is never synced. A project that already exists keeps its recorded element list.
- After upgrading `vajra` and running `vajra init --sync-fleet`, it gets the new kit and template.
  Its kit-built demos then get the `demo:complete` + fact checks automatically (detection is in the
  binary). A demo that does not source the kit falls back to the old four-marker rule with a warning
  naming the downgrade — until the project adds `complete` to its `required_elements`. Kit-sign
  detection is a substring scan, the same test that credits an element, so any output that earns
  `complete` (even an indented ` demo:complete`) is kit-built and owes every fact (S168 cold review
  rec 1; `an_indented_complete_marker_cannot_dodge_the_kit_rules`).
- The new `dk_check` breaks demos that used `dk_check "label" 0` / `"$_DK_RC"` / `PASS`: they turn
  red with a message naming the new form. That is intended — those checks proved nothing.
- The gate binds only on the session being closed; old demos are never re-graded at close.

## Rejected alternatives

| Alternative | Why rejected |
|---|---|
| Detect the kit by script text only | Skipped by writing the demo without sourcing the kit. |
| Detect by a `demo:kit` marker only | Skipped by deleting one line. |
| A new `kit_required_from: NN` key | A second setting that can drift; `required_elements` already does the job. |
| Let the demo choose which facts to show | Skippable — a faker would not call `dk_vajra_tiles`. |
| Loose number matching ("5 of 8" vs "5/8") | The gate would guess at meaning, which it never does. |
| An addendum to DECISION-009 | It would quietly overturn §4. |

## Honest limits

- A hand-typed `echo demo:complete` still satisfies the `complete` element — but it makes the demo
  kit-built, so it must then print every fact, each true. A hand-typed `demo:fact` line with the
  RIGHT value passes: the gate proves the value, not who drew it.
- `dk_check "x" true` still passes: a real command is not a meaningful one.
- A demo can draw hand-typed tiles beside the Vajra-filled ones; the gate checks the facts, not
  every number on screen.
- A demo that removes every kit sign in a project whose `required_elements` lacks `complete` falls
  back to the old rule (warned by name) — the self-granted-jurisdiction class, disclosed.
- Not tested: Windows.
