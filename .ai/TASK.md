# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 44 — `.claude/settings.json` merge on `vajra init` (CODE, founder pick B) — COMPLETE

- **Delivered:** `vajra init` now MERGES Vajra's hooks into a pre-existing `.claude/settings.json`
  instead of skipping it (ROADMAP #18b, closes the S34 finding — the last silent L3-enforcement leak).
  For `.claude/settings.json` only, `scaffold()` routes an existing file to `merge_claude_settings_file`
  → the pure `merge_claude_settings`: appends Vajra's `SessionStart` + `PreToolUse` groups additively,
  preserving every user key/hook; idempotent (structural-equality OR `.ai/hooks/*.sh` path, vs a
  pre-merge snapshot); malformed existing JSON → left untouched + loud warn, init still exits 0. The
  launcher's ADR-0003 `--settings` merge is NOT reused (fresh `PostToolUse`-only object — different
  shape; documented inline).
- **Evidence:** `verify-session-44.sh` 24/24 (real `vajra init` into a temp brownfield repo: user hook
  + key survive + all 4 Vajra hooks wired + valid JSON; run 2× = no dupes; greenfield writes canonical;
  malformed preserved + warns); `cargo test` 117 lib (+6) + 12 adapter; clippy + fmt clean. Commit `8a78ca6`.

Between sessions. Next = S45 (NO-CODE — mandatory ground-truth, all three lenses combined).

## Next Session (S45 — NO-CODE, mandatory ground-truth)

- **Prompt (ready):** `prompts/45-task-combined-ground-truth.md` — the every-5th NO-CODE audit (last =
  S40). Founder directed **all three lenses in one comprehensive review**: (A) dogfood /
  enforcement-completeness · (B) direction / vision drift · (C) process-cost drift. "No rule should stop
  us." Run every `required_audit`; render one honest verdict; rank + tee up the paid live re-dogfood
  (#17a) as the likely S46 code/verify session (the audit itself cannot run the paid loop).
- **Branch:** `session-45-combined-ground-truth` (NO-CODE; doc-only closeout on a `-closeout` suffix branch is exempt).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S40; **S45 is next and mandatory**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S45; do NOT start it here.
- **Enforcement is the moat** — S37→S39 closed the S36 harm; S40 audited it; S41 fixed compression;
  S42 closed the `jq` fail-open; S43 added the git-level L2 belt; **S44 wired the moat into brownfield
  repos that already own a `.claude/settings.json` — the last silent L3 leak.**
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the
  guard blocks the agent otherwise, by design).
