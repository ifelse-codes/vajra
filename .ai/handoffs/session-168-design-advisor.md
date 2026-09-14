---
role: design-advisor
session: 168
agent: claude-code-subagent (verified: toolu_01NBABWbAPcYtWSssmtjaDGR)
source-sha: 3edb8280c644c2c6f8ce537e4b3eb9dadfcae0b5a8e16e8eefb7bdd340b1f5e4
captured: 2026-09-14T13:20:35Z
cost_usd: null
---

# Design-advisor handoff — session 168

# Design-advisor handoff — session 168

**Brief:** Design ruling for S168 (a demo that cannot be faked). design-significant: yes. New record DECISION-010 (overturns DECISION-009 §4 "The gate does not change"), with a pointer line in DECISION-009. AC5 decided: kit-built = script sources `demo-kit.sh` OR output carries any `demo:kit` / `demo:complete` / `demo:fact` line; Vajra's own `required_elements` gains `complete` (not `fact`).

**Marker: `design-significant: yes`.** This session changes the Demo-er gate's logic, adds a new read-only command (`vajra next --demo-facts NN`) and breaks the `dk_check` call shape that `--sync-fleet` pushes to every project. It also reverses a locked decision: DECISION-009 §4 says "The gate does not change".

**Record: write a new DECISION-010**, with one pointer line added to DECISION-009. There is no `DECISION-01*` file yet. An addendum is the wrong fit: DECISION-007 used addenda to *extend* a decision, but this *overturns* a numbered point. Cite DECISION-009 §4 (the point being overturned) and DECISION-008 (the "fire only on a marker that is present" rule).

Recommendations:
1. rec 1 — Treat a demo as kit-built if **either** its script text sources `demo-kit.sh` **or** its live output has any `demo:kit`, `demo:complete` or `demo:fact` line. Any one sign is enough. A faker has to remove every sign, and then the gate falls back to the old four-marker rule and warns by name that the demo was downgraded. That is the "self-granted jurisdiction" hole again, and the record must say so. A warning alone does not close it; rec 2 does, for new sessions.
2. rec 2 — Add `complete` to `demo.required_elements` in Vajra's own CONSTRAINTS.yaml. Do not add `fact`. This makes the new checks unavoidable for any session closed from S168 on, with no new config key. The gate only re-runs the closing session's demo, so old S71–S166 scripts are not re-graded at close. Before relying on that, check two things: whether `cumulative: true` or `vajra next --check-demo <old NN>` re-runs old demos, and whether the S167 demo prints `demo:complete`. Other projects keep the four-marker default (`DEFAULT_REQUIRED_ELEMENTS`) until they edit CONSTRAINTS.yaml. Sync never touches that file, and they only get the kit once they upgrade `vajra` and run `--sync-fleet`. Record this as a limit. Do not change the built-in default: that would turn old demos red in every project at once.
3. rec 3 — Compare facts on an exact `key=value` match from a closed list of keys, after stripping color codes. Block on an unknown key, on the same key printed twice with different values, and on any value that differs. The kit wraps marker lines in color codes when `DEMO_COLOR=1` (`dk_marker` uses `C_D`). The old check (`missing_elements`) searches for a substring, so those codes never mattered. An exact value match does care, so strip them first.
4. rec 4 — A kit-built demo must print **all** derived facts, not just the ones it picks. If the demo could choose, a faker would simply not call `dk_vajra_tiles`, and Vajra would no longer fill in the numbers as DECISION-009 promised. When a fact can't be worked out yet (for example, no review verdict), both sides print the same word, such as `none`, so nothing drifts.
5. rec 5 — Close the two real sources of mismatch. Clean room vs working tree: when the clean room is on, the demo runs in a fresh checkout of HEAD; the gate must work out facts from the same folder the demo ran in, right after the run. Version skew: the demo calls whatever `vajra` is on PATH; the gate should set `VAJRA_BIN` to its own executable, and the kit should call `${VAJRA_BIN:-vajra}`. With both fixed, no other race is left: the gate writes nothing between the run and the comparison.
6. rec 6 — Record that the new `dk_check` breaks existing kit demos when it is synced in. Demos that use `dk_check "label" 0` or `"label" $_DK_RC` will turn red. Have the refusal print a message naming the new form. Have `dk_check` run the command itself through `dk_run_v` and keep `_DK_OUT`, so a before/after panel can reuse the real output. Honest limit: `dk_check "x" true` still passes. A real command is not the same as a meaningful one.
7. rec 7 — Say plainly that a hand-typed `echo demo:complete` still gets past rec 2. Only the facts check is unforgeable. `demo:complete` proves the marker was printed, not that the outline passed.

Rejected options (condensed): script-text-only detection (skipped by not sourcing the kit) · `demo:kit` marker only (skipped by deleting one line) · a new `kit_required_from: NN` key (a second setting that drifts) · demo-chosen facts (skippable) · loose number matching (the gate would guess at meaning) · an addendum to DECISION-009 (would quietly overturn §4).

Design bullets (condensed):
- design-significant: yes. The Demo-er gate changes, reversing DECISION-009 §4. New record DECISION-010; DECISION-009 gets a pointer. Detection follows DECISION-008's fire-only-on-a-present-marker rule.
- Kit-built = sources `demo-kit.sh` or output has any `demo:kit`/`demo:complete`/`demo:fact`; with none, the old four-marker rule with a named downgrade warning.
- Vajra's own `required_elements` gains `complete`; other projects only after editing CONSTRAINTS.yaml.
- Facts derived from the folder the demo ran in, right after the run, with the gate's own binary via `VAJRA_BIN`; every fact printed, exact match on a closed key list, color codes stripped.
- Limits: a hand-echoed `demo:complete` and `dk_check "x" true` still pass.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (5538 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
