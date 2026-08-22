---
role: fidelity-reviewer
session: 127
agent: claude-code-subagent
source-sha: cfb61f9afa264359a167c9b2a9d092e57b6ee5531dfc9a1c427155b053b1a463
captured: 2026-08-22T05:33:43Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 127

## Cold fidelity review — S127, PASS 2 (supersedes the PASS 1 brief at this path)

**Verdict: ACCEPT.** 10 of 12 SHIPPED · 2 PARTIAL (criteria 10 and 11) · 0 NOT-BUILT.

**Tooling limit, stated first:** Read/Grep/Glob only — no Bash. Could not run `git diff`, `git cat-file`, `cargo test`, either script, or the binary. The delivery was reconstructed from the files at HEAD and every claimed sha verified against `.git/logs/HEAD`. Anything marked unverified is unverified for that reason, not because it looked wrong.

**Note on this handoff:** pass 1's brief lived at this same path and is superseded here. Its eight recommendations, and the commits that closed them, are recorded in `sessions/session-127-review.md`. This renumbering is itself a limit of the contract and is disclosed in the session summary.

### The two PARTIALs

Criterion 10 — `scripts/demo-session-127.sh` still used the GNU-only `\s` in a scored assertion, the exact escape just fixed in the verify suite. On a repo whose own memory records "spelling-bound guards get escaped", fixing the reported instance and leaving its twin is the pattern the lesson warns about. Criterion 11 — the review record's Pass 2 section was empty when I read it; this brief is the missing input, and the criterion closes only when it is landed and attested.

### THE FAKEST GREEN

**The 51-answer ledger the session presents as its own dogfood proof — and specifically demo case 1, which scores "this session answers every one of its own 51 recommendations" and prints a 51/0 disposition table.** That is a count of well-formed strings. Three of the 51 are demonstrably mis-certified, and I found them with nothing but the reflog: `implementation-advisor rec 15 — obeyed: 2043432` (a commit predating `advice_gate` itself; the `DODGE` hoist landed in `8da2093`); `fidelity-reviewer rec 7 — obeyed: 4e93ddf` (the summary commit, which cannot contain the `## Execution` fill it certifies); `demo-producer rec 17 — obeyed: 15581a0` (the demo explicitly declines that row in its own comment — a refusal recorded as obedience).

**The count would be identical if the advice had been read and ignored, provided the author typed three words and pasted any commit from the branch.** The pass-1 reviewer found one such specimen and the session made it a virtue by recording it in the addendum; it then shipped three more without noticing. The disclosure is now doing work the ledger isn't.

Runner-up: a hardcoded literal printed as a BEFORE cell inside a block whose own label reads "Read from git, not typed", read by no assertion — unfalsifiable decoration in the one place the demo promises there is none.

### What held up

Criterion 9 binds to behaviour, assertion by assertion: `items.len()==1` can only be true if the parser really read the marker; `Unreal` vs `Missing` is what binds state C to `check_evidence` rather than to mere absence; the control replay proves no residue. Each `perl` pattern in the verify twin matches current source, and a silently no-opping substitution leaves the fixture green and the check reporting FAIL — drift fails safe. No `$?` bug anywhere in either script: `OUT="$(...)"` is a plain assignment, so the classic `local` footgun is avoided, consistently. Criterion 12 is the cleanest thing in the delivery — every occurrence of `obey|obedien|enforce` is a denial of the claim. Criterion 8: nothing else moved. The new close-path check is the single best thing added between passes — it neutralises all seven other stages with their own overrides so the refusal can only be this gate's, then proves it by advancing under the override.

**The one gap in criterion 9:** the fixture never exercises `NoRecommendations`. Deleting the WARN branch leaves it green, and that is the branch criterion 6 rests on.

### Recommendations

rec 1 — land this brief as pass 2 in `sessions/session-127-review.md` with a canonical `**Verdict:** ACCEPT` and a `**Review-Inputs-SHA:**` recomputed strictly AFTER every other fix lands, and delete the `**Verdict:** ACCEPT` line from the summary.

The summary is the builder's artifact. A verdict field in it is a self-certification in the exact shape the gate parses elsewhere. Two consecutive `--inputs-sha 127` runs must agree before embedding.

rec 2 — correct the summary's criterion-11 row and its `12 SHIPPED · 0 PARTIAL · 0 NOT-BUILT` count to the grades pass 2 actually returned, and strike the phrase "pass 2 ACCEPT" from a row written before pass 2 existed.

That is the builder grading the reviewer's not-yet-given verdict — the S54 failure mode this entire arc exists to prevent, in miniature.

rec 3 — fix the three mis-certified dispositions in the prompt's `## Advice`: `implementation-advisor rec 15`, `fidelity-reviewer rec 7`, and `demo-producer rec 17` — the last as a `refused:` with the reason the demo already writes in its own comment.

This is the fakest green, and unlike the pass-1 specimen it is not yet disclosed anywhere. If any of the three is deliberate, record it as `refused:` — that is what the contract is for, and a refusal would be more honest evidence than another `obeyed:`.

rec 4 — replace the GNU-only `\s` in the demo's station-row count with a POSIX-portable pattern, the identical fix already applied in the verify suite.

It fails safe (red, not falsely green), so this is portability rather than a fake green — but leaving the twin of a defect you just fixed is the escape the fixture-right-reason lesson warns about.

rec 5 — either score the hardcoded BEFORE cell or drop it from the before/after table.

The honest options are to implement the row demo-producer rec 17 actually asked for, or to delete it and say in `dim` why the base has no comparable number.

rec 6 — reconcile the stale 43-vs-51 counts in the prompt's `## Advice` preamble and the summary's fakest-green paragraph.

Three advisors returned 51. Both sentences are pass-1-era numbers, and both sit in paragraphs otherwise arguing for the ledger's trustworthiness.

rec 7 — repair the two comment drifts the insertion left: `handoff_findings_raw`'s doc still opens with `handoff_body`'s old description, and a `// The QA stage (S69)` marker now labels the Advice arms.

The first matters because that function is now load-bearing for a gate and its doc currently contradicts itself in the first two sentences.

rec 8 — add a fourth state to `mod falsifiability` covering the `NoRecommendations` WARN path, so that turning the disclosed dodge into a block, or into silence, also turns the fixture red.

Criterion 6 is the criterion the whole honest-limit story rests on, and it is the one branch the fixture does not touch.

### Scope call

A faithful build of the whole contract, not one narrow slice presented as the whole. The pass-1 REJECT was closed in substance, not cosmetically. It is short in two places, both narrow: the closeout attestation does not exist yet (this brief is it), and the session's own advice ledger carries three answers that a reader can falsify from the reflog in five minutes. The second matters more than its size, because it is the third consecutive time this session has demonstrated its own thesis by failing it.

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (7232 bytes now vs 4091 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
