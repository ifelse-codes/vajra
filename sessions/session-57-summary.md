# Session 57 — Propagate the fidelity gate + reviewer into `vajra init` (CODE)

**Branch:** `session-57-propagate-fidelity-gate` · **Type:** CODE · **Spend:** ~$0 (one cold-review subagent,
negligible) · **Result:** every project scaffolded by `vajra init` now inherits the S56 fidelity gate.

## Goal (achieved)

Close the S36-class "built but not scaffolded" gap for the QA/Reviewer stage: the fidelity gate S56 built
protected only Vajra's own repo. **S57 propagates the brain + the teeth into `vajra init`** so a scaffolded
project's closeout also **structurally requires an independent ACCEPT review**, not just discipline.

**Headline finding:** the scaffold never shipped `verify-closeout.sh` *at all* — the scaffolded constitution
told agents to "run `verify-closeout.sh`" but the file was absent. So the gap was wider than the prompt
assumed. And because the canonical `scripts/verify-closeout.sh` is already a clean standalone file, the
feared "template-generated → `include_str!`" refactor **does not exist** → `include_str!` is a one-liner →
**no S58 split needed.** Shipped both the reviewer brain and the full closeout gate this session.

## What shipped (evidence)

| Deliverable | Evidence |
|---|---|
| Reviewer brain scaffolded | `f("reviewer/SKILL.md", TPL_REVIEWER)` + `TPL_REVIEWER = include_str!("../../reviewer/SKILL.md")`; byte-identical (test + live `cmp`) |
| Boot pointer | new `## Fidelity Review (Load at Boot)` in `TPL_AGENTS` + Session Loop step 7/8 + 2 Hard Rules |
| Closeout gate scaffolded | `fx("scripts/verify-closeout.sh", TPL_VERIFY_CLOSEOUT)` (executable) + `include_str!`; carries `check_fidelity_review`/`waiver_ok`/`--fidelity-only` |
| CONSTRAINTS wiring | `closeout_script` + `closeout_must_pass_before_close: true` in `TPL_CONSTRAINTS` |
| Packaging | `Cargo.toml` un-excludes `!scripts/verify-closeout.sh`; `cargo package --list` ships both |
| Re-run safety | `reviewer` added to `SCAFFOLD_OWNED` (a re-run stays greenfield) |
| Live proof | real `vajra init` into a temp repo → scaffolded gate BLOCKS missing/REJECT, PASSES ACCEPT, forged in-file waiver inert, founder env waiver clears |
| Tests | `cargo test` **145 lib** (+5) · fmt clean · clippy `-D warnings` clean · `verify-session-57.sh` **24/24** |

## Fidelity self-map (every numbered requirement — reviewed independently, see `sessions/session-57-review.md`)

| Requirement | Verdict | Note |
|---|---|---|
| J1 reviewer brain + boot pointer | **SHIPPED** | include_str! + `## Fidelity Review` section + test |
| J2 teeth in scaffolded closeout + mechanism recorded + Cargo.toml | **SHIPPED** | include_str! (one-source, recorded in comment); no split needed |
| J3 prove live (real init, not a grep) | **SHIPPED** | verify §3 drives the scaffolded gate under `CLAUDE_PROJECT_DIR=$TMP` |
| D1 init.rs scaffolds both + packaging via `cargo package --list` | **SHIPPED** | asserted in verify |
| D2 verify-session-57.sh exits 0 | **SHIPPED** | 24/24 |
| D3 demo + HTML-when-asked | **SHIPPED** | demo present; HTML on request |
| D4 summary + independent review + 3 S58 candidates | **SHIPPED** | this file + `session-57-review.md` (cold pass, ACCEPT) + candidates below |
| A1 scaffolded closeout requires ACCEPT (real run) | **SHIPPED** | live matrix, not a mock |
| A2 byte-identical / drift-free | **SHIPPED** | include_str! + equality tests + `cmp` |
| A3 spine + cargo green + clippy clean | **SHIPPED** | main.rs untouched; 145 lib green; clippy clean *(cold pass ruled PARTIAL — it couldn't execute the toolchain; verify re-runs all three green)* |
| A4 honest split boundary | **N/A** | no split — full scope delivered (over-delivery vs the pre-authorized minimum, not a re-scope) |

**What I did NOT build (stated plainly):**
- **Verdict *authorship* independence is still procedural, not structural** (the standing S56 honest #1). The
  scaffolded gate makes the *waiver* un-forgeable and blocks missing/hollow/REJECT — but a builder can still
  author its own `**Verdict:** ACCEPT`. Independence rides the cold-subagent *procedure* (used again this
  session), not code. → **S58-A.**
- **The cross-agent tamper-evident ledger is still 0 code** — the headline moat. The fidelity arc now
  produces something worth recording (independent verdicts), but nothing records them yet. → S58-B.
- **The S54 Analyst REJECT is still open** — the gate now *blocks* S54's own closeout, but Intake/Options/
  computed-Delta remain NOT-BUILT. → S58-C.

**Fakest green (named by the cold pass, FIXED after it ruled):** the original `no 8th command` spine check
was a tautology (its regex enumerated only the 7 known command literals, so it could never count an 8th).
Replaced with the real invariant — adding a command requires editing `src/main.rs`'s dispatch, so assert
`main.rs` is untouched this session — plus a non-tautological arm-pattern count. Now 24/24.

## Independent fidelity review (DECISION-002)

A cold subagent fed ONLY the prompt + the code diff (summary/STATE/expected-verdict withheld) ruled
**9/9 core SHIPPED · 1 PARTIAL · no split** → **`**Verdict:** ACCEPT`** (`sessions/session-57-review.md`).
Its one substantive finding (the tautological spine check) was fixed after the pass. Dogfood: the gate
itself PASSES on this session's review (`verify-closeout.sh --fidelity-only 57` → 11 in-table verdicts,
canonical ACCEPT).

## 3 ranked candidates for S58

- **🥇 A — Structural verdict-authorship independence (close the standing honest #1).** *Goal:* bind an
  ACCEPT to un-forgeable proof it came from a cold pass (e.g. an attested hash of the withheld prompt+diff
  inputs the reviewer actually consumed), so a builder can no longer author its own ACCEPT. *Why pick:* it
  is the one gap that keeps the whole fidelity arc "procedurally independent, structurally self-gradeable" —
  the highest-leverage hardening now that the gate is everywhere. *Risk:* the attestation boundary is subtle
  (what exactly is hashed, who holds the key) — easy to build ceremony that isn't actually un-forgeable.
- **🥈 B — The cross-stage delta ledger (the headline moat).** *Goal:* commit the auditor's verdicts +
  each stage's +/~/− deltas into a git-tied, hash-chained record → tamper-*evident*. *Why pick:* it's the
  0-code headline moat, and it finally has something worth recording (independent acceptance verdicts, not
  self-reports); upgrades the Analyst's `Status:` marker from claim to evidence. *Risk:* composes best
  *after* A (recording a self-gradeable verdict records a weaker thing).
- **🥉 C — Complete the Analyst (pay down the S54 REJECT).** *Goal:* build Intake/Options/computed-Delta so
  the S54 gaps the cold re-audit caught are actually closed. *Why pick:* the gate now blocks S54's own
  closeout — this is the "fix what the gate caught" path. *Risk:* breadth-before-depth; adds pipeline
  surface while the fidelity kernel is still procedurally-independent (A first).

**Recommendation (guide, don't menu): A.** The fidelity arc is brain (S55) → teeth (S56) → propagated (S57);
A is the load-bearing next link — make the ACCEPT itself un-forgeable. `prompts/58-task-*.md` written for A;
founder may reprioritize to B/C in the new S58 chat.
