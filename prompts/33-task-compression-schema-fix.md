# Session 33 — Compression schema fix: make the hook fire on real Claude Code (CODE)

> **S31 finding #2, pre-pinned.** The compression hook has produced **zero savings in every real session since S03/S07**. Root cause is pinned against a captured real PostToolUse payload (`.ai/KNOWLEDGE.md` S31): the real CC envelope is **snake_case at the top level** (`tool_name/tool_input/tool_response`), but `HookInput` in `src/adapter/claude_code.rs` carries `#[serde(rename_all = "camelCase")]` → it expects `toolName/toolInput/toolResponse` → `serde_json::from_str` fails on every real payload → the adapter hits the silent `Err → "{}"` passthrough branch. The 98 tests are green because the fixtures encode the WRONG casing — **the tests validate the bug.**

## Goal (one story)
Make the compression hook actually parse a real CC payload and fire, and add a regression test built from a **verbatim captured** payload so it can never silently regress to passthrough.

## The precise fix (pinned — do exactly this)
1. **Remove `#[serde(rename_all = "camelCase")]` from `HookInput` ONLY** — its three fields (`tool_name`, `tool_input`, `tool_response`) are already snake_case and match the real envelope.
2. **Keep `rename_all = "camelCase"` on `HookToolResponse`** — the nested `tool_response` object IS camelCase (`stdout, stderr, interrupted, isImage, noOutputExpected`); this one is correct.
3. **`exit_code` stays `Option`** — real CC omits it for Bash → `None` → `infer_success` falls back to its tail-match. Do not invent an `exit_code`/`exitCode` field.
4. **Add a regression test from a verbatim captured real payload** (snake_case top level, camelCase `tool_response`). Assert the 181-line cargo fixture folds (not the 1-line passthrough). Consider keeping the old (buggy-casing) fixture only if renamed to document what real CC does NOT send.

## Guardrails
- One story (schema fix + regression test). ≤3 files/commit, ~2h cap, branch `session-33-<slug>` from `main`. No `main`/autonomous commits.
- **Do NOT touch Darshan (S32) or brownfield (S31 #3)** — 1-story discipline.
- Empirical check to reproduce first: camelCase top-level folds the fixture → 1 line; snake_case top-level → passthrough. Confirm the bug BEFORE the fix, then confirm the fix flips it.
- `verify-session-33.sh` green before closeout; `scripts/verify-closeout.sh` exits 0.
- Meta-rule: this fix restores a real (measurable) capability — verify with an actual fold on a real-shaped payload, not just a green test count.

## Carry-forwards
- **Brownfield onboarding** (S31 #3) is the session after.
- **Second agent stays parked** until the core (Darshan ✓ S32, compression, brownfield) is fixed.
- **Next ground truth = S35** (NO-CODE). S33 + S34 are the last two CODE sessions before it.
