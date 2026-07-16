# Session 69 Summary — The QA station: verification becomes a real checkpoint (CODE)

## Goal achieved?
**Yes.** QA is the pipeline's **6th governed station** — the WORKS gate. "Verification = exit 0"
was a house rule (scripts + `.ai/verify/` artifacts by convention, nothing enforced at close);
it is now an enforced, **live-executed** gate riding `vajra next`. One deliberate upgrade over
the S61/S64/S67/S68 recorded-marker shape: the marker here is *executable*, so `--check-qa`
**RE-RUNS the script live** instead of trusting a recorded green — the stale-green (S68's
pre-session-sha analogue) is killed by construction.

## Evidence
- `src/qa/mod.rs` (registered in `lib.rs`): contract resolved from the **existing**
  `CONSTRAINTS.yaml#verify` spine (`script_pattern` + `artifacts_dir`; `demo:` section excluded;
  defaults on missing keys). `QaState`: NoScript → legacy WARN naming the dodge · live red /
  unevaluable → BLOCK ("a check that cannot evaluate FAILS") · live green → PASS. Runner
  injected for tests; the real one streams the run (the run IS the evidence).
- `vajra next --qa NN` (surface, read-only — nothing executes) · `--check-qa NN` (re-runs live,
  exit 1 on non-zero) · wired into `--advance` on the **CLOSING** session (the S62/S68 stance).
- `cargo test --lib` **203** (+9) · `verify-session-69.sh` **30/30** — temp git repo with real
  passing AND failing verify scripts: surface (missing + recorded contract), live-red block,
  **stale-green killed** (recorded runs + `latest` look green, script red NOW → still blocks),
  live-green pass, no-script legacy WARN, and all four advance outcomes (block ·
  override-skips-live-run · live-green pass · L1 advise on the live result).
- Dogfood: `--qa 69`'s contract names `scripts/verify-session-69.sh` — this session's own gate;
  closing S69 re-runs it live. S69's prompt also passes Architect/Planner/Coder gates (trace
  recorded: a591dad · 6a7c885 · 52c5b19).

## Fidelity map (every numbered acceptance criterion → what shipped)

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | `--qa NN` surfaces the QA contract from the existing spine | **SHIPPED** | `gather_contract()`/`format_qa_contract()`; patterns read from `CONSTRAINTS.yaml#verify` (unit: `verify_patterns_reads_verify_section_not_demo`); e2e `e2e-qa-surfaces-missing-script` + `e2e-qa-surfaces-recorded-contract`; real-repo `real-repo-qa-surfaces-69`. |
| 2 | `--check-qa NN` RE-RUNS live, blocks non-zero, never trusts a recorded green | **SHIPPED** | `qa_gate()`+`run_verify_script()` (real exit codes, unit-tested); e2e `e2e-check-qa-blocks-live-red` (names "exited 3" + "recorded green") · `e2e-check-qa-kills-stale-green` · `e2e-check-qa-passes-live-green`. |
| 3 | `--advance` on the CLOSING session: L2/L3 block, L1 advise, `VAJRA_SKIP_QA_GATE=1` alone | **SHIPPED** (one disclosed divergence) | Gate binds on `current` after the Coder gate; e2e: block · override · pass · L1-advise (advisory carries the live "exited 3"). Divergence, stated in code + here: the override skips the **slow live run itself**, not just the block — an opted-out close records **no live evidence at all** (the other stages still print their check's result under their overrides). |
| 4 | No script (NO-CODE GT / legacy) → WARN at most, dodge named plainly | **SHIPPED** | `QaState::NoScript` warn-only; the warning says "deleting the script downgrades this gate" + "self-granted jurisdiction"; unit + e2e `e2e-check-qa-warns-no-script`. |
| 5 | `verify-session-69.sh` proves surface + block-on-red + pass-on-green + legacy-warn + advance wiring in a temp repo; exit 0 | **SHIPPED** | 30 checks incl. 11 temp-repo e2e cases with real red/green scripts; 28/30 pre-closeout (only summary/review pending, by design), 30/30 final. |

**NOT built (plainly):** nothing from the numbered contract. Out of scope and untouched:
no test authoring (the binary never writes or fixes a test), no `qa.md`, no 8th command,
no new dependency, no semantic judgment of what the verify script checks.

## The fakest green (named loudly)
**A green QA gate proves the session's checks pass — not that the checks are sufficient.**
Two layers, both disclosed:
1. **Self-granted jurisdiction (the S68 class):** no script → WARN (AC-4's mandated legacy/GT
   compat), so deleting `scripts/verify-session-NN.sh` dodges the gate entirely. The warning
   names this dodge every time it fires.
2. **The author writes the test:** `--check-qa` re-executes whatever the session's author chose
   to check. A verify script asserting `true` is a live green. QA upgraded *stale-green* to
   *live-green*; it cannot upgrade *hollow-green*.
Plus the divergence from map row 3: a `VAJRA_SKIP_QA_GATE=1` close skips the live run, so the
skip leaves no evidence behind. Never pitch this station as "the code is verified" — pitch it as
"the session's own verify contract is re-executed and enforced at close."

## Cost
~$0 (local Rust + one cold-review subagent).

## 3 ranked candidates for **S71** (⚠ **S70 is the mandatory NO-CODE ground-truth**, every 5th)
- **A 🥇 — the Demo-er station (crew next, founder direction).** *Goal:* the demo becomes a
  governed station — surface the demo contract (`demo.script_pattern`, cumulative, required
  elements) and enforce it at close the way QA enforces verify. *Why:* founder direction at S68
  close — finish the crew, one per session (QA ✓ → **Demo-er** → Releaser). *Risk:* an honest
  mechanism that isn't a hollow re-run of QA — demo proves *show*, not *checks*; the
  required-elements floor (header/cases/scorecard) may be the only enforceable form.
- **B 🥈 — compression truth: fix or formally retire the 0-fold no-op.** *Goal:* compression
  folds on real CC traffic, or the savings claim is retired honestly. *Why:* carried since S63
  (measured 0 folds while the product implies savings) — S70's GT will flag it again; truth-debt
  ages badly. *Risk:* the honest outcome may be retirement, not a fix.
- **C 🥉 — the pipeline-payload counter.** *Goal:* one measured number for "did the pipeline
  advance real payload this session?" *Why:* recommended by THREE ground-truths (S25 · S60 ·
  S65) and still unbuilt — the longest-standing measurement gap. *Risk:* metric design (avoiding
  a vanity counter) is the hard part, not the code.
