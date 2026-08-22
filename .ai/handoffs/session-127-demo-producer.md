---
role: demo-producer
session: 127
agent: claude-code-subagent
source-sha: f463b69a821b2d6b38f0132ee161c32c150c1f8474dc59fc8a224cbad545b127
captured: 2026-08-22T02:44:38Z
cost_usd: null
---

# Demo-producer handoff — session 127

## Demo brief — Session 127 (`scripts/demo-session-127.sh`)

I propose; the author records. Every case below runs the real binary and prints what it observed.

### demo:header

rec 1 — `demo:header` must name the session, the one story, and the floor in the same breath: advice is now ANSWERED, never OBEYED.

Keep verbatim, because criterion 12 forbids the softer claim: "This forces an ANSWER, not obedience. A reasoned refusal PASSES by design. What became impossible is the silent version — the one that cost S126 twice in its own record."

rec 2 — the header must state, up front, that this is the first gate that reads a governed handoff as a binding input.

That is the design-significant fact (DECISION-007's S116 deferral, lifted). Eight station gates read a marker inside the session's own prompt; this one reads `.ai/handoffs/session-NN-<role>.md` too, and binds the two together.

rec 3 — do not let the header claim the fleet is now "wired in". One gate consumes handoffs; the other seven do not.

S126's demo honestly headlined "the roster is complete, and nothing depends on it". The honest S127 headline is one notch up, not ten.

### demo:cases

rec 4 — case 1: run `vajra next --advice 127` in the REAL repo and show this session's own recommendations with their dispositions, inline.

The session that ships the gate is the first subject of it. Assert on parsed facts, not prose: every item labelled, numbers contiguous, zero unanswered marks. Then run `--check-advice 127` and score its real exit code.

rec 5 — case 2: print the disposition MIX and assert the three counts sum to the total.

`obeyed: N · refused: N · deferred: N`, derived by counting the disposition words in the real output. A non-zero `refused:` count is the visual proof that honest disobedience passes.

rec 6 — case 3: assert `--check-advice 127` reports ZERO orphan warnings.

An orphan is a `## Advice` line answering a recommendation no handoff records — the renumbered-brief failure. Zero orphans is a genuine falsifiable property.

rec 7 — case 4: re-enact S126's real drop live, using VERBATIM S126 text, and show the gate BLOCK where nothing blocked before.

Pull the real sentence out of `.ai/handoffs/session-126-demo-producer.md`, record it through the real writer as `rec 2 — <that verbatim sentence>`, copy the real `prompts/126-task-finish-the-fleet.md` in unchanged (it has no `## Advice` section — the historical truth), and run `--check-advice 126`: expect exit 1. Use real text, never a paraphrase.

rec 8 — case 5: the same subject, answered — exit 0, one line per recommendation.

Rewrite the temp prompt from a single template string, never editing the previous state's file in place (the S122 defect). Two states of one subject, both exit codes scored, is what makes case 4 mean something.

rec 9 — case 6: all three UNREAL evidence kinds block, asserted on exit code and parsed label, never on a message string.

Print the gate's own explanation for the viewer, but do not grep its wording — a demo that binds to message spelling goes green after a rename and red after a refactor (S122).

rec 10 — case 7: a malformed handoff FAILS CLOSED — it must never be read as "absent, nothing to answer".

This is the one variant that only exists because rec 5 of this session's own implementation brief said the four-variant enum could not express it — worth one narrated sentence, since it is the mechanism working on itself.

rec 11 — case 8: the nine-role round trip — what every role is TOLD to write is what the gate READS BACK, proven through the binary, not through a source grep.

For each scaffolded role definition, pull its literal `rec 1 — …` example line, feed it as that role's findings, and confirm the gate reports `<role> rec 1` as an unanswered item. Expect 9 of 9. Do not replace it with a grep — that is the hollow-grep class.

rec 12 — case 9: the gate actually binds the CLOSE path, both ways — refuse, and named override.

A gate no path calls is a command, not a gate. Drive `vajra next --advance` and assert it refuses with the advice reason, then re-run with `VAJRA_SKIP_ADVICE_GATE=1` and assert it advances and says the override was used. If `--advance` cannot be driven cleanly inside a demo repo, say so and score `--check-advice` instead — but state plainly that the wiring is asserted by tests, not shown.

rec 13 — case 10: the honest blind spot, run live — `--check-advice 126` against the REAL repo exits 0 and names the dodge.

S126's five handoffs record zero `rec N —` markers, so the gate shipped this session would NOT have caught either of S126's two drops. Score it as a PASS of a disclosed limit — the most honest thirty seconds in the demo.

rec 14 — case 11: `K of 8` did not move, shown at a NON-degenerate baseline.

S126's own filed finding #4 was that its invariance check ran at a degenerate `0 of 8`. Assert exactly 8 station rows, none named `advice`, and a byte-identical `K of N` line before and after handoffs carrying numbered recommendations land. Also assert the 7-command usage string.

rec 15 — do NOT score the falsifiability fixture in the demo. Narrate it and point at the verify script.

The honest falsifiability experiment is delete-the-consumption-and-watch-it-go-red, which a demo cannot perform on itself without lying.

### demo:before_after

rec 16 — the honest BEFORE for the machinery is "this did not exist at all", and it must be shown from git, not asserted.

`git show <base>:src/advice/mod.rs` fails (no such file) — the cleanest possible before. `--check-advice` occurrences: 0 at the base, non-zero now. Label the class honestly: read from git, not typed, but still a source read.

rec 17 — second contrast, the one that is otherwise invisible: the `## Advice` section did not exist in ANY prompt before this session.

`grep -l '^## Advice' prompts/*.md` at the merge-base → 0 files; on this branch → 1. This is where the viewer sees the new artifact-free contract: no new store, no new file type, one new section inside the prompt that already existed.

rec 18 — third contrast, and the one this session owes S126: the DECISION-007 deferral, before and after — the exact class of change S126's demo dropped.

BEFORE prints "…explicitly deferred as a non-goal." AFTER is the S127 addendum lifting it. Leave it in and let it fail until the deliverable lands; that is precisely the record change a feature demo would otherwise hide, and S126 was told to show its analogue and shipped only the after. Do not repeat that.

rec 19 — fourth contrast, behavioural, as a three-column table over S126's two REAL drops.

Columns: what the advisor recorded | what S126 shipped | what happens now, live. The BEFORE cell must say, in plain words, "no trace anywhere; surfaced by luck in a later cold pass" — not "it failed", because nothing failed.

### demo:summary_table

rec 20 — the house table (CASE · CLASS · RESULT) with the self-assigned-class caveat, plus a second small table: the recommendation ledger.

One row per disposition word with its count and, for `obeyed`, the short sha — rendered from the real output, never retyped into the script. A hand-typed ledger in a demo about not dropping things would be the joke writing itself.

rec 21 — the summary must print the count of blocking states demonstrated, and the count of honest-limit states demonstrated, separately.

A demo that only counts greens flatters itself; counting the ways it made the real binary say no is the useful number.

### What this demo does NOT show

rec 22 — say the four limits plainly, in the script's closing block, in this order: it does not show obedience; the refusal floor is a form floor; jurisdiction is self-granted; one gate consumes handoffs and the other seven do not.

Close with: a green demo is not a passing delivery; the fidelity verdict lives in `sessions/session-127-review.md`.

rec 23 — anti-cases: things that must NOT appear in this script.

No `|| true`, no `2>/dev/null` on a scored assertion, no scoring the read-only `--advice` surface as proof of blocking (it always exits 0). No `grep -q 'rec'` as a case. No assertion of a gate message's wording. No case reusing a mutated temp prompt across states — rewrite from one template per state, and re-run the passing state LAST to prove no residue.

rec 24 — runtime and clean-clone constraints.

Budget is 600s and the Demo-er gate re-runs this live at close. Build once, reuse one temp dir with per-state prompt rewrites, touch no network. Every input the script reads must be committed, and the merge-base reads should print the resolved base sha so a viewer can check it.

## Handoff Delta
- `+` new: first demo-producer handoff for this session (8719 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
