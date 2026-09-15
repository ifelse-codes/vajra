# Session 169 — Summary: a session cannot close on made-up evidence

**Verdict:** ACCEPT — independent cold review, pass 2 of record (`sessions/session-169-review.md`): 8 SHIPPED · 1 PARTIAL (this summary, written after the review) · 0 NOT-BUILT. Pass 1 was **REJECT** (zero-padding bug + dodgeable claim match), fixed in 59e1686 before pass 2.

## Goal achieved?
Yes, for the four kinds of made-up evidence the prompt named. `scripts/verify-closeout.sh` — and the gate `vajra init` hands a new project — now refuses: prose in a `done:` sha, a sha that names no commit, a plan step with no landing commit (`pending:`), a summary that claims a verdict with no review file or fidelity handoff (even under `VAJRA_CLOSEOUT_WAIVER`), and a CODE session with no tech-lead file (even under the waiver).

## Fidelity map

| # | Requirement | Grade | Evidence |
|---|---|---|---|
| AC1 | prose / 6-char / 41-char `done:` BLOCKS, line named | SHIPPED | whole 7–40 hex with a word boundary; verify AC1a–c on both gates |
| AC2 | well-formed sha with no commit BLOCKS, sha named | SHIPPED | `git cat-file -e`; verify AC2a–b; old gate (8bdd69a) passed `done: defaced prose` live in the demo |
| AC3 | claimed verdict, no review/handoff → BLOCK even under waiver | SHIPPED | `check_claimed_evidence`, no waiver path; AC3a–c + dodge a/b + full-close wiring test |
| AC4 | CODE session with no tech-lead file → BLOCK at close | SHIPPED | plain `-s` on `session-NN-tech-lead.md`, zero-padded; AC4a/b + pad a/b |
| AC5 | decide how a post-merge step is recorded without a skip env | SHIPPED | DECISION-007 S169 addendum: its own ROADMAP row, never a plan step; `NO-DONE` blocks at close |
| D1 | `verify-closeout.sh` checks | SHIPPED | 14e6cc8 + 59e1686 |
| D2 | scaffolded gate carries them | SHIPPED | 07c2f2d + 59e1686; every case runs on a real `vajra init` gate |
| D3 | `verify-session-169.sh` exits 0 | SHIPPED | 39 pass · 0 fail |
| D4 | this summary + 3 ranked candidates | SHIPPED (after the review) | this file |

## Evidence

| Check | Result |
|---|---|
| `scripts/verify-session-169.sh` | 39 pass, 0 fail (19 cases × Vajra's gate + the scaffolded gate, + scaffold presence) |
| `scripts/demo-session-169.sh` / `vajra next --check-demo 169` | 13/13 live checks · READY |
| `cargo test --release --lib` | 509 passed |
| `vajra next --check-obeyed 169` · `--check-crew` · `--check-fidelity-handoff` | READY (see the closeout log) |
| Crew | tech-lead · design-advisor · fidelity-reviewer ×2 · implementation-advisor (judge of pass-1 recs) — all provenance-verified |

## What was NOT built — stated plainly
- **A made-up `done:` sha is still waivable** — only `claimed-evidence-real` refuses the waiver (design-advisor scope). Carried to S171 item 3.
- **Existence, not ownership:** `git cat-file -e` accepts any old real commit (pass 1 rec 3 → S171).
- **The claim match is words only** — misses `Cold review: ACCEPT`, over-matches "Acceptance" (pass 2 recs 7–10 → S171).
- **`check_fidelity_review` / `check_review_attestation` still read the review unpadded** (rec 9 → S171).
- The Rust Coder gate is unchanged; closed S167/S168 prompts now fail `--check-exec-shas`; `verify-session-166.sh` AC3 is red (non-git fixture). Old sessions are never re-graded.

## Fakest green
The claimed-evidence check proves the review files **exist**, and recognises a claim by **words** — a claim in another shape passes unseen, and a real file with hollow content passes this check (the fidelity + attestation checks own content).

## Disclosed process facts
- `vajra next --advance` into S169 used `VAJRA_SKIP_CODER_GATE=1` — S168 step 11 (the release) was still `pending:`. AC5 is meant to make this the last time.
- Commits used `VAJRA_ALLOW_COMMIT=169` on the founder's "all approved" (2026-09-15).
- Release 0.2.0: tag + GitHub release are out; **crates.io still 0.1.0** (`cargo publish` is founder-typed).
- Cost: $0 paid runs; fleet subagents only.

## Next — S170 is the mandatory NO-CODE Ground Truth (`prompts/170-task-ground-truth.md`, DRAFT)
Candidates for S171, ranked:
- **A — Close the S169 carry-forwards (ROADMAP S171).** Goal: the claim match stops over- and under-matching, every review read is zero-padded, and a `done:` sha must belong to this session. Why: finishes this gate honestly before anything new stands on it. Risk: branch-reachability after merge + prune is a real design problem.
- **B — Publish vajractl 0.2.0 for real (crates.io + brew + install-smoke).** Goal: a stranger's `cargo install` gets S167–S169. Why: zero users can reach any of this work today. Risk: irreversible, founder-typed `cargo publish`.
- **C — S168 review recs 1–3.** Goal: DECISION-010 says what its gate really proves, a live disclosed-floor row, verify-168's greps replaced. Why: small, keeps the demo claims honest. Risk: low leverage next to A and B.
