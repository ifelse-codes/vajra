# S122 — landed run evidence (verify + demo)

The cold review's fair complaint at pass 2 was that the only run in the record was RED. This is
the green run, captured verbatim after the pass-3 repairs. It is EVIDENCE OF ONE RUN on one
machine, not a proof of correctness — re-run the scripts rather than trusting this file.

## `bash scripts/verify-session-122.sh` — exit 0

```
=== Session 122 Verify Summary ===
STEP                                 CLASS   RESULT
------------------------------------ ------- ------
cargo-build                          exec    PASS
cargo-test                           exec    PASS
cargo-fmt                            exec    PASS
cargo-clippy                         exec    PASS
test-filter-guard-has-teeth          exec    PASS
s121-suite-green                     nested  PASS
fleet-smoke                          nested  PASS
s113-counter-still-green             nested  PASS
fix1-fixture-ran-green               exec    PASS
fix1-independent-token-guard         exec    PASS
fix2-fixture-ran-green               exec    PASS
fix2-trap-live-and-defused           exec    PASS
fix3-content-asserted-per-role       exec    PASS
fix3-empty-prompt-fixture            exec    PASS
fix3-render-test-still-green         exec    PASS
fix3-no-self-referential-assert      struct  PASS
fix4-fixture-ran-green               exec    PASS
fix4-printed-tally-is-honest         exec    PASS
fix4-own-tally-has-teeth             exec    PASS
execution-policy-one-source          struct  PASS
execution-policy-guard-has-teeth     exec    PASS
no-eighth-command                    behav   PASS

CHECK CLASSES (this suite's OWN checks only — NOT a census of everything that ran)
  execute-based: 16 · structural grep: 2 · behavioral source grep: 1
  nested suites (their own checks are NOT counted above): 3
    - s121-suite-green — runs another whole suite; read that suite's own tally for its classes
    - fleet-smoke — runs another whole suite; read that suite's own tally for its classes
    - s113-counter-still-green — runs another whole suite; read that suite's own tally for its classes
  DISCLOSED: each of those 3 nested suite(s) runs checks of its own, including its own
  behavioral source greps. They are NOT included in the 1 above, so 1 is a FLOOR,
  never a total for this run.
NOTE: 1 behavioral source grep(s) in THIS suite — each must be named in the session's fakest-green disclosure.
STILL A SELF-ASSIGNED LABEL: nothing here proves a check marked `exec` executes anything.
S122 made the tally honest about NESTING. It did not make the labels EARNED.
ALL GREEN (22 pass, 0 fail)
```

## `bash scripts/demo-session-122.sh` — exit 0

```
== Scorecard  [demo:summary_table] ==
  CASE                                                   CLASS   RESULT
  ------------------------------------------------------ ------- ------
  the old grep passed it; the new guard rejects it       exec    PASS
  the real tally names what it hides; the old line does not exec    PASS
  four roles scaffolded                                  exec    PASS
  execution is an allowlist of exactly one role          exec    PASS
  one policy, three copies, no drift                     struct  PASS
  a governed handoff quotes the probe sentence and nothing breaks exec    PASS
  the tautology is gone and its replacement is falsifiable exec    PASS
  all four bad inputs still rejected                     exec    PASS
  still exactly 7 top-level commands                     behav   PASS

  9 of 9 cases passed
  CHECK CLASSES (this demo's own cases only) — execute-based: 7 · structural: 1 · behavioral: 1
  STILL A SELF-ASSIGNED LABEL: nothing here proves a case marked `exec` executes anything.

> Stated plainly, because the demo would otherwise flatter itself:
  · The check-class labels are STILL typed by the author. S122 made the tally honest about
    NESTING; it did not make a single label EARNED. That is the unpicked option B from S121.
  · 'no-eighth-command' is still a hardcoded-banner grep, here and in S113's suite.
  · The executor thesis is STILL UNPROVEN. The QA role found three more real defects this
    session (seven across its two runs) — every one by READING. Execution bought exit codes.
  · Three cold-review passes were needed. Pass 1 REJECT, pass 2 ACCEPT-with-findings, pass 3
    REJECT — and pass 3 found the same tautology on a THIRD field the guard did not name.
  · The Write/Edit grant is still documented, not FENCED. Next session's candidate.
DEMO GREEN (9/9)
```
