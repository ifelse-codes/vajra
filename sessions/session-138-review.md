# Session 138 — Independent cold fidelity review

**Reviewer:** `fidelity-reviewer` subagent, cold, fed only the prompt + the Vajra-side artifacts
(prompt, summary, verify script, handoff, render) + the trustable already-executed evidence. No shell
(so it read scripts, it did not run them — the S133–S136 standing limit holds: the live figures were
executed by the builder).

## Per-criterion grading

| # | Criterion | Verdict | Note |
|---|---|---|---|
| 1 | panel language; accent-once + grey ramp, raw-RGB verified | SHIPPED | verify #6/#8/#9 + render; one non-grey `#8B7CF6` + 4 grey tones on the committed preview |
| 2 | chitra pipeline green + README `LOCKED: heatmap` | SHIPPED | README block on branch; 15 heatmap tests live — thin: only the heatmap SUBSET, no `gen:charts` regen-diff proving the preview is derived not hand-tuned |
| 3 | founder signs off on the render | SHIPPED | "this looks good and impressive"; render exists for seen-not-read |
| 4 | run INSIDE chitra, INTERACTIVELY, hooks/fleet dispatched; authoritative $ + RAW | PARTIAL | native-inside ✓, $2.988 ✓, 237,584 RAW ✓; NOT interactive (headless `-p`, permissions bypassed, wrapper-driven); mandated design-advisor absent |
| 5 | session-16 + locked charts undisturbed (four ways); exactly the heatmap files | SHIPPED | byte-identical restore (tree `1c276700`), HEAD unmoved, stash intact; verify #10 = exactly 6 declared files |

**4 of 5 SHIPPED · 1 PARTIAL.**

## The corrected-method check (did S137's fence-poke recur?)

**No, and the distinction is real, not spin.** In S137 chitra's hooks never fired (a plain-git
cross-fence poke). Here the build agent ran with cwd=chitra and chitra's hooks demonstrably fired on
its edits and commits (copilot-loader blocked a commit exit-2; commit-guard gated on the marker). The
edits and commits WERE governed by chitra.

But three residual reaches keep it from being the run the prompt approved, and the summary originally
overstated it (now corrected):

- The Vajra wrapper chat **launched and drove** the build subprocess — guardrail #1 said the wrapper
  "does NOT dispatch chitra's build fleet" and "the build is a native session the founder runs."
- `VAJRA_ALLOW_COMMIT=18` was set in the launch env by the wrapper — the commit-guard was
  pre-authorized globally, not per-commit; the gate "held" only because the wrapper supplied the marker.
- `--dangerously-skip-permissions` removed the human approval channel entirely.

So: a genuine native session for the BUILD (hooks governed it), but NOT the interactive, founder-driven
run that was approved. "The way a user runs it" was overstated relative to what the prompt approved —
corrected in the summary to "unattended/CI-style, headless, wrapper-driven, permissions bypassed."

## Fakest green

The summary honestly disclosed two (permission bypass; verify not re-running vitest) — named plainly,
not buried. **The WORSE one the builder missed:** the mandated **design-advisor never ran** — only
tech-lead + fidelity-reviewer were dispatched. The visual design was produced by the headless agent
and rubber-stamped by the founder's sign-off, not proposed by the design role; the "Governance USED"
section implied otherwise and would look identical had the mandate been silently skipped — which is
what happened. **Now corrected in the summary and named here.**

Secondary hollow spots: verify #1 (`grep "INSIDE chitra"/"corrected"`) and #5 (`grep -c "S18:"`) are
typed-marker checks that pass regardless of whether the dogfood worked — they pad the 10/10. The
load-bearing checks are #9 (raw-RGB behavioral) and #10 (scope), which are genuinely falsifiable.

## Recommendations (recorded)

- rec 1 — Run the interactive, founder-driven `vajra claude` inside chitra (no
  `--dangerously-skip-permissions`, no wrapper-set marker) to close criterion 4's "interactively"
  clause. → **candidate A for S139.**
- rec 2 — Disclose the design-advisor gap: only tech-lead + fidelity-reviewer ran; the design role did
  not. → **DONE in this review + the summary.**
- rec 3 — Stop equating "the way a user runs it" with unattended headless. → **DONE (summary method
  paragraph rewritten).**
- rec 4 — Add criterion-2 evidence: a `pnpm gen:charts` regen-diff proving the preview is derived, and
  a full-pipeline-green result on the branch (not only the heatmap subset). → deferred, recorded.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 840e64d900919987f0d5028133c8d6e89f08146af38b7eb248555d69244e1d42

4 of 5 SHIPPED (criterion 4 PARTIAL). The substantive deliverable landed with strong falsifiable
evidence (byte-identical restore, behavioral raw-RGB, live tests, authoritative $, RAW tokens), and
the S137 correction genuinely shipped — chitra's hooks governed a real build. The gap is on criterion
4's method: not interactive, wrapper-driven, permissions bypassed, design-advisor absent — a real but
bounded, now-disclosed shortfall the next session closes.
