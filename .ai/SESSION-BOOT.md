# Session Boot

## Current Session
- **Number:** 21 — COMPLETE
- **Type:** CODE — the co-pilot loader (make `⚡on` fire + enforce)
- **Branch:** `session-21-copilot-loader`
- **Date last updated:** 2026-06-29

## Repo State Snapshot
- `.ai/SESSION` = 21.
- `main`: includes up to Session 20 (PR #10 merged). S21 PR #11 pending merge.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.
- New this session: `scripts/hook-copilot-loader.sh` (the co-pilot loader) + `copilot.on` rules in `.ai/CONSTRAINTS.yaml` + PreToolUse wiring in `.claude/settings.json` + verify/demo 21. **Varta's first enforcing use.**

## Next Session
- **Number:** 22
- **Type:** CODE — scaffold propagation (the deferred S21 rider)
- **Read prompt:** `prompts/22-task-scaffold-propagation.md`
- **Branch:** `session-22-scaffold-propagation`

## Carry-Forwards
- **S22 = scaffold propagation** — `vajra init` must emit the S20 GT audits (`ground_truth:` block) + the S21 co-pilot (`copilot.on` + `hook-copilot-loader.sh` + settings wiring). `src/cli/init.rs`'s `TPL_CONSTRAINTS` has **no `ground_truth:` section at all** and no copilot block; stale `approval_tokens` (missing `"go ahead and commit"`) + missing `ground_truth_commit_exempt_branch_suffixes`.
- **S22 key decision:** how does `vajra init` ship the ~70-line hook **without it drifting** from canonical `scripts/hook-copilot-loader.sh` (embed const vs generate vs reference)?
- **Decision gate ANSWERED (S21):** Varta **enforces** — L2/L3 exit-2 block until context surfaced, L1 advises. On-wedge. Proven live (blocked a real `git commit`).
- Co-pilot v0 limits: simple-glob + `cmd:` substring (no `**`/regex); surfaces paths+why, not file contents; debounce keys on `session_id`.
- GT now audits **vision + roadmap drift** + a meta-check. Next GT = **S25**.
- "Grammar frozen at 9" still **provisional**; `vajra estimate` 3:1 ratio still unvalidated.
