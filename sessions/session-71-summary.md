# Session 71 Summary — The Demo-er station (pipeline station 7, the SHOW gate)

**Goal achieved?** YES — every closing session now needs a sprint demo a human can watch
(before → after), surfaced read-only by `vajra next --demo NN` and enforced by
`--check-demo NN` re-running it LIVE (the S69 executable-marker pattern) at `--advance`.
The pipeline is now **7 governed stations**: WHAT · DESIGN · HOW-plan · CODE · WORKS ·
**SHOW** · REVIEW, riding one `vajra next`.

## Evidence (live, not quoted)

- `cargo test --lib` **214** (+11 demoer); fmt + clippy `-D warnings` clean.
- `scripts/verify-session-71.sh` **43 checks** — 41/41 code+E2E green at review time; the 2
  paperwork checks (this summary + the cold review) land with this closeout, then 43/43.
- `scripts/demo-session-71.sh` exit 0 — S71's own sprint demo emits all four
  `demo:<element>` markers and proves the BEFORE via `git cat-file` (template absent at the
  S70 merge); `--check-demo 71` re-runs it live, green.
- **Independent cold review = ACCEPT** (5/5 acceptance criteria SHIPPED, **27 adversarial
  probes** incl. marker-stuffing, chmod-000, SIGKILL, override distinctness both directions,
  scaffold byte-identity, pre-S71 3-element compat), attested
  `**Review-Inputs-SHA:** a51a44d6…` (`--attest-only 71` + `--fidelity-only 71` PASS).
- 8 commits, every one ≤3 files; branch `session-71-demoer-stage`; **S71 spend ~$0** (one
  cold-review subagent).

## Fidelity map (every prompt requirement → what shipped)

| Requirement | Verdict | Evidence |
|---|---|---|
| AC-1 `--demo` read-only surface (script, elements, honest-cost) | SHIPPED | reviewer P1/P2 — sentinel proved nothing executes |
| AC-2 `--check-demo` live re-run, blocks non-zero OR missing element, fail-closed | SHIPPED | P3–P8 — hollow/red/partial/chmod-000/SIGKILL all block, naming the real failure |
| AC-3 `--advance` binds on the CLOSING session; L1 advises; `VAJRA_SKIP_DEMOER_GATE=1` distinct, skips the run itself, disclosed; no-script WARN names the dodge | SHIPPED | P10–P17 |
| AC-4 `before_after` required element; template created; CONSTRAINTS records it; cumulative kept; scaffold propagation | SHIPPED | P5, P18, P19 — `include_str!`, byte-identical |
| AC-5 proven live: tests grow, verify E2E, no 8th command / new dep / second store | SHIPPED | P0, P25, P26 |
| Closeout paperwork (this summary, cold review, `.ai/` sync, 3 ranked candidates) | SHIPPED | this closeout bundle |

**Not built (stated plainly):** nothing from the contract. The readable-roadmap one-pager
rider did NOT fit inside the demo surface with zero extra store — it stays in backlog, per the
prompt's own guardrail.

## The fakest green (disclosed, reviewer-sharpened)

**A one-line marker-stuffed demo is a READY sprint demo.** `echo "demo:header demo:cases
demo:summary_table demo:before_after"` passes the gate. The gate genuinely proves the demo
EXISTS + RUNS GREEN LIVE + PRINTS the four elements — it cannot prove the printed before/after
demonstrates anything (the `covers:`-class form floor, same self-granted-jurisdiction family
as every recorded marker; now SIX gates wide). Disclosed in the module doc, the demo's own
honest-edge footer, and the gate's block message. **Never pitch as "the demo is verified."**

## In-session finds (the harness earning its keep)

- **Permission dodge killed:** the E2E caught `chmod 000` classifying as no-script WARN —
  existence is now `is_file()`, unreadable scripts BLOCK fail-closed (regression-tested).
- **Fixture-writer brace-cut bug:** `${2:-...{NN}.sh}` truncates at the first `}` — five E2E
  cases were passing as false-greens off a mangled script_pattern before the fix.
- Reviewer minors, recorded as debt: no timeout on the live run (shared with QA's runner),
  directory-at-script-path reads as "missing", explicit-empty `required_elements: []` falls
  back to defaults, `--demo`'s static scan counts comments (gate's live scan is the enforced
  one).

## Next — ranked candidates (S72)

- **A — the Releaser station (finish the crew).** Goal: govern the SHIP step — release/PR
  hygiene surfaced + enforced at close (the crew's 8th station; Monitor stays later). Why:
  the standing founder direction ("finish the crew — Demo-er → Releaser, one per session");
  after SHOW, releasing is the last ungoverned handoff. Risk: another ~$0-green station while
  the measured debts (compression truth, paid run) age — S75 GT will weigh exactly this.
- **B — compression truth: make it real or retire it.** Goal: a paid pipeline run that either
  makes the compression hook fold on real CC output or formally retires the claim. Why: the
  oldest measured 🔴-class debt (0 folds since S63); "never claim until measured" is decided,
  making-it-real is not started. Risk: touches the engine heuristics — bigger blast radius
  than one station.
- **C — the pipeline-payload counter (backlog, founder-flagged do-not-lose).** Goal:
  `vajra check`/`vajra next` prints stations built · ACCEPT'd/attested · sessions-since-a-paid-run
  · sessions-since-a-new-station. Why: recommended by 4 GTs (S25/S60/S65/S70) and hand-derived
  every time — recommendation-rot made visible. Risk: a metrics surface, not a gate — lowest
  enforcement value of the three.
