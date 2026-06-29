# Session 22 — Scaffold Propagation (CODE)

## Goal
Make `vajra init` emit the **S20 ground-truth hardening** *and* the **S21 co-pilot loader**, so every Vajra-scaffolded project inherits them — not just this repo.

## Why now
The hardening lives only in *this* repo. A fresh `vajra init` today produces a **pre-S20** workflow: `src/cli/init.rs`'s `TPL_CONSTRAINTS` has **no `ground_truth:` section at all**, no `copilot:` rules, and the scaffolded `.claude/settings.json` has no co-pilot wiring. New projects get neither direction-drift auditing nor the enforcing co-pilot. This is the deferred S21 rider.

## Scope (1 story)
- **`src/cli/init.rs` templates:**
  - `TPL_CONSTRAINTS` gains the `ground_truth:` block (`vision_alignment`, `roadmap_alignment`, `constitution_review` + the question-lists + `drift_axes`) and a starter `copilot:` block with 1–2 example `⚡on` rules. (Also refresh stale bits: `approval_tokens` is missing `"go ahead and commit"`; `branch:` lacks `ground_truth_commit_exempt_branch_suffixes`.)
  - Scaffold `scripts/hook-copilot-loader.sh` and wire it into the scaffolded `.claude/settings.json` PreToolUse matchers.
- Update `init.rs` unit tests + `scripts/verify-session-22.sh` (assert a scaffolded project contains the GT audits + a firing co-pilot).

## Key decision (must answer in the summary)
The co-pilot hook is ~70 lines of bash. **How does `vajra init` ship it without it drifting from the canonical `scripts/hook-copilot-loader.sh`?** Options: (a) embed as a `const` (accept a copy — same drift Varta fights); (b) generate/render from the canonical file at build time; (c) reference a shipped template. Pick one, record why.

## Constraints
- Branch `session-22-scaffold-propagation`. Max 3 files / atomic commit. Max 1 story. ~2h cap.
- `scripts/verify-session-22.sh` must exit 0. Demo cumulative. ADRs locked.

## Output
- A scaffolded project that boots S20+S21-hardened, proven by verify + a real `vajra init` into a temp dir + `sessions/session-22-summary.md` (answer the decision + 3 next options).
