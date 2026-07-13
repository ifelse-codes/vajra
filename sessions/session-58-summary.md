# Session 58 — Verdict-authorship attestation (make the ACCEPT un-forgeable) — CODE

**Goal:** bind an ACCEPT verdict to un-forgeable-ish evidence that a cold pass consumed the exact withheld
inputs (contract prompt + delivery diff), so a builder can no longer author its own free-floating ACCEPT.
Closes the standing honest #1 — **by downgrading it to a documented, bounded limit, not by claiming
tamper-evidence.**

## Goal achieved? YES (honestly scoped)

The fidelity gate now verifies the **verdict's** authorship-binding, not just the review's shape + the
waiver's authorship. On an ACCEPT, `scripts/verify-closeout.sh` recomputes `sha256(prompt ‖ delivery-diff)`
from the repo and FAILS a review whose `**Review-Inputs-SHA:**` is missing, forged, or stale — behind the
same founder waiver. **Proven live**, not asserted.

| Evidence | Result |
|---|---|
| `verify-session-58.sh` | **24/24 GREEN** — attestation cases driven live in a real temp git repo |
| `--attest-only 58` on S58's own review | **PASS** (`claimed == expected == d91d5c20…d59fe5`) — G4 self-dogfood |
| `--fidelity-only 58` (S56 shape gate) | **PASS** (13 in-table verdicts, ACCEPT) — unchanged behavior |
| Independent cold review (subagent, prompt+diff only) | **ACCEPT** — 12/16 SHIPPED, nothing overclaimed |
| `cargo test --lib` / fmt / clippy `-D warnings` | green — **no `src/` change** (attestation rides the script) |
| Scaffolded gate (`vajra init`) | byte-identical + carries `check_review_attestation` (S57 `include_str!`) |

## Fidelity map — EVERY requirement (DECISION-002)

Independently ruled by a cold subagent fed only the prompt + delivery diff (summary/STATE/verdict withheld);
full artifact + method controls in `sessions/session-58-review.md`. Reproduced:

| # | Requirement | Verdict |
|---|---|---|
| J1 | Design attestation, mapped onto artifact+gate; state honestly if not un-forgeable | **SHIPPED** |
| J2 | `check_review_attestation` requires+verifies on ACCEPT behind `waiver_ok`; keep `--fidelity-only`; S56 green | **SHIPPED** |
| J3 | Propagate via `vajra init` + `reviewer/SKILL.md` emits it + run S58 cold review with real attestation | **PARTIAL** (real self-review proven on fixtures cold; the live artifact = this closeout) |
| D1 | Design recorded (what's hashed / proves / does NOT prove) | **SHIPPED** (DECISION-003) |
| D2 | Gate extension + scaffolded copy byte-identical (one source) | **SHIPPED** |
| D3 | `verify-session-58.sh` exits 0; pass/forged/missing/waiver/S56-matrix, live not grep | **SHIPPED** |
| D4 | `demo-session-58.sh` (+ HTML when asked) | **SHIPPED** |
| D5 | `session-58-summary.md` + cold `session-58-review.md` (real attestation) + 3 S59 candidates | **SHIPPED** (this + the review; UNVERIFIED cold by design — `sessions/` is excluded from the hash) |
| A1 | Missing/forged attestation FAILS (real run) | **SHIPPED** |
| A2 | Genuine attestation PASSES + mechanism honestly described | **SHIPPED** |
| A3 | Byte-identical / drift-free (one source) | **SHIPPED** |
| A4 | Spine: no 8th command, no second store, cargo/clippy green | **SHIPPED** |
| G1 | Do NOT overclaim tamper-evidence — say bar-raising if same agent can recompute | **SHIPPED** |
| G2 | Map onto existing artifact+gate; no new command/store/file | **SHIPPED** |
| G4 | Eat the dog food — S58 closeout passes its own attestation gate | **SHIPPED** (`--attest-only 58` PASS) |

**12/16 SHIPPED · 1 PARTIAL (J3) · 1 process-N/A (G3) · nothing NOT-BUILT · nothing overclaimed.**

## What I did NOT build (plainly)

- **Real tamper-evidence.** The same agent can run `--inputs-sha` and paste the hash, so a determined
  self-forge still passes. This is **bar-raising, not un-forgeable** — recorded in DECISION-003, the skill,
  the gate comment, and the demo. The honest #1 is **downgraded to a bounded limit, not closed.**
- **What it *does* stop:** an ACCEPT recycled from another session, one written against an earlier diff then
  shipped over a changed delivery (freshness), and one decoupled from what actually shipped (recomputed at
  closeout from the live repo).
- **No src/ change:** the attestation lives entirely in the bash gate; `vajra init` inherits it free via the
  S57 `include_str!`. Zero new commands (`--inputs-sha`/`--attest-only` are script flags, not subcommands).

## Fakest green (self-named)

The **self-dogfood tail** — the cold reviewer could not see `session-58-review.md` / the closeout run (its
own coldness excludes `sessions/`), so those greens are demonstrated on synthetic temp-repo fixtures in the
cold view and only made real at *this* closeout (`--attest-only 58` PASS, above). Honest, not hidden: the
UNVERIFIED-by-design flags are the mechanism withholding its own outputs, working as intended.

## Deliverables

`scripts/verify-closeout.sh` (+`canonical_inputs_sha`/`check_review_attestation`/`--inputs-sha`/`--attest-only`)
· `reviewer/SKILL.md` (emits + honest limit) · `docs/decisions/DECISION-003-verdict-input-attestation.md` ·
`scripts/verify-session-58.sh` (24/24) · `scripts/demo-session-58.sh` · `sessions/session-58-summary.md` +
`sessions/session-58-review.md`. Commits `282f3ad` + `2da0333` (+ report/closeout). S58 spend **~$0** (one
cold-review subagent). Next mandatory NO-CODE ground-truth = **S60**.

## 3 ranked candidates for S59

### 🥇 A — The cross-stage delta ledger (the 0-code headline moat)
- **Goal:** commit each session's independent, **now-attested** acceptance verdict + its input-hash into a
  git-tied, hash-chained record → tamper-*evident* cross-stage evidence.
- **Why pick:** the headline moat is still 0 code; S58 just gave it its first trustworthy payload (an
  attested verdict, not a self-report). Composes directly on S58 — the attestation IS the ledger's content.
- **Key risk:** "ledger" can balloon; must ride existing artifacts (`sessions/*-review.md` + git), not a new
  store — map-to-Vajra first, ASK before any new file type.

### 🥈 B — Complete the S54 Analyst (Intake / Options / computed Delta)
- **Goal:** pay down the standing S54 REJECT — build the 4 of 5 Analyst steps that are NOT-BUILT/PARTIAL.
- **Why pick:** the fidelity gate now *blocks* S54's closeout; the stage is genuinely 1-of-5 real. Turns a
  known REJECT green honestly.
- **Key risk:** breadth-before-depth temptation; keep it one governed stage, resist scope creep.

### 🥉 C — Harden attestation toward real tamper-evidence (out-of-band signer)
- **Goal:** close the *remaining* half of honest #1 — prove a *different mind* authored the verdict (CI-side
  reviewer identity / a signature the builder cannot produce).
- **Why pick:** finishes the independence arc structurally, not just bar-raising.
- **Key risk:** needs a trust root **outside** the repo (a new store / identity) — may violate the spine;
  the S58 honest downgrade may already be "good enough," making this lower-leverage than the ledger.
