# QA Evidence Brief — Session 122

Produced by the `qa-specialist` fleet role, dispatched by name from the S122 build session.
It ran the suites; it did not build them, did not edit them, and did not commit.

## 1. What actually ran

Both scripts exist and both ran to completion. No tracked file was modified by the agent
(`git status --porcelain` showed zero non-untracked entries).

### `bash scripts/verify-session-121.sh` — real exit code `0`, 20 pass / 0 fail
Every check PASS, including the four new fixture checks (`read-only-guard-has-teeth`,
`one-source-guard-has-teeth`, `tally-disclosure-has-teeth`) and the reclassified
`s113-counter-still-green  nested  PASS`.

### `bash scripts/verify-session-122.sh` — real exit code `1`, 18 pass / 2 fail

## 2. HEADLINE — there were TWO reds, not the one I was briefed to expect

**RED #1 — `fix2-trap-live-and-defused` — EXPECTED, not a defect.**
`FAIL: no governed qa-specialist handoff for session 122 — the trap is not live, so this proves
nothing`. Correct, self-explaining, fail-closed. The file it demands is this report, landed after
the run.

**RED #2 — `fix3-no-self-referential-assert` — A REAL DEFECT IN WHAT S122 SHIPPED.**
The check greped the whole of `src/fleet/mod.rs` for `def.contains(role.system_prompt)` with no
comment exclusion, so it went RED on **three comment lines** (930, 931, 965) that *describe* the
removed defect. Zero of the hits were code. Its failure message — "the render is still asserted
against the field it renders from" — was false, and a reader trusting it would hunt a defect that
does not exist. This is precisely the S121 defect-2 shape reborn inside the session that was
fixing it: a check red for a reason its own message cannot explain.

## 3. Check classification — I agree with 19 of 20 self-assigned labels

Tally arithmetic verified: 15 exec + 1 struct + 1 behav + 3 nested = 20 rows printed.

- **Hollow, named:** `no-eighth-command` — runs `vajra --help` but asserts on a hardcoded usage
  banner. An 8th command could be wired into the dispatcher without touching that string.
  Correctly self-labelled `behav`.
- **One label qualified:** `fix2-trap-live-and-defused` is labelled `exec` but is two things
  stitched together — the first half greps a *document* for a probe sentence (artifact-structural),
  the load-bearing half asserts against the live S121 log (genuinely execute-based).
- **A hollow element the tally did not count:** the nesting disclosure printed by `print_tally` was
  itself a hardcoded banner — the literal `2` and two literal suite names, not derived from
  `NESTED_NAMES`. Called with one nested suite it still claimed "at least 2". *The fix for
  hollowness was delivered as a hardcoded string.*
- **S122's own predicate was weaker than the one it inherited:** its `tally_discloses_nesting`
  dropped the "how much is hidden" assertion that the S121 version carries.

## 4. Are the four falsifiability fixtures real, or cosmetic?

- **Fix 1 — REAL, strongest of the four.** Plants the exact leak, *demonstrates the old prefix grep
  going green on it*, requires the new token-exact guard to go RED, requires green on a clean fleet
  (not a check that always fails), adds a fail-closed case. S122 then re-derives it independently
  with its own parser against what the real binary rendered.
- **Fix 2 — REAL.** Three states in a miniature repo: canonical only (green) → governed handoff
  quoting the probe (stays green, and the S121 exclusion list is shown tripping on it) → a genuine
  second carrier (RED, and the message must name the path).
- **Fix 3 — REAL BUT WEAKER THAN IT LOOKS.** The fixture reproduces the tautology honestly, but its
  "fix" half **retypes** the new assertions inline rather than invoking the real test against a
  planted hollow role. Change the real test's threshold and the fixture still passes. It
  demonstrates "the assertion shape I retyped here would reject a hollow role", not "the real test
  rejects a hollow role". Its structural backstop was the broken check (RED #2).
- **Fix 4 — REAL FOR NESTING, SILENT ON LABELS.** Genuine RED-on-defect (the S121 one-liner is kept
  verbatim as a negative control and must be rejected), and `fix4-printed-tally-is-honest` asserts
  against the tally the live run actually printed. **But it only proves the tally discloses
  nesting — never that the class numbers are correct.**

## 5. What the suite never exercises

- **The `exec` labels are never earned.** Self-disclosed twice in the script's own output. Unpicked
  option B from the S121 close; still open.
- **No live agent dispatch.** Every fleet check verifies the *rendered* subagent definition and the
  *handoff writer*. Nothing invokes an actual subagent and observes it behaving. The role's contract
  is checked as text, never as conduct.
- **Nothing proves the runtime honours `tools:`.** Whether Claude Code actually refuses `Write` to a
  role granted `Read, Grep, Glob` is outside every check here.
- **The execution policy existed in three divergent hand-maintained copies.**
  `src/fleet/mod.rs` forbade `Write, Edit, Bash, NotebookEdit`; both shell guards also forbade
  `Task`. **A role granted `Task` — execution by proxy — would have passed the Rust test and been
  rejected by both scripts.** No check bound the three lists together.
- **The nesting disclosure's counts were hardcoded**, never derived from the suites actually run.
- **No cost, receipt, compression, or ledger surface** is touched by either suite.

## 6. Independence statement

I ran both suites, read the failure logs, and read the source of every check I classified. I did not
edit any file, did not repair `fix3-no-self-referential-assert`, and did not commit. That restraint
is deliberate and is the point of the role: "Fixing what you just tested destroys the independence that makes your report worth reading."

A green suite would not have been a passing delivery here, and this one was not green. Real exit
codes: `verify-session-121.sh` -> 0 (20 pass, 0 fail); `verify-session-122.sh` -> 1 (18 pass, 2
fail). Grading whether that clears the session's requirements is the Fidelity Reviewer's call.
