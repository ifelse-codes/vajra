# Session 44 — Merge into an existing `.claude/settings.json` on `vajra init` (founder pick B)

> Founder pick B at S43 closeout. Closes the S34 finding: a brownfield repo that already
> has `.claude/settings.json` gets it **skipped** on init → the scaffolded `.ai/hooks/`
> are never wired → the entire L3 enforcement moat is silently absent for that project.
> Branch: `session-44-settings-json-merge`.

## The gap (S34 finding — a real, silent enforcement leak)
`vajra init` follows a skip-if-present convention for every file. For `.claude/settings.json`
that convention is **wrong**: a brownfield project that already has one (the primary use case)
keeps its own settings untouched, so Vajra's hooks (SessionStart Darshan boot; PreToolUse Bash
co-pilot + session-guard + publish-guard; PreToolUse Edit|Write co-pilot) are **never wired**.
The project scaffolds all the hook *files* under `.ai/hooks/` but nothing *fires* them →
publish-guard, session-guard, co-pilot, Darshan boot are all dead. Same class as the launcher's
`--settings` merge (ADR-0003), which already merges additively rather than replacing.

## The fix — merge, don't skip, for `.claude/settings.json` only
1. When `.claude/settings.json` **does not** exist → current behavior (write `TPL_CLAUDE_SETTINGS`).
2. When it **exists** → parse both as JSON (`serde_json` is already a dep) and **merge Vajra's
   hook entries into the user's file**, preserving every existing key/hook:
   - Append Vajra's `SessionStart` + `PreToolUse` hook entries to the existing arrays; **do not**
     replace the user's `hooks` block or any unrelated top-level key.
   - **Idempotent:** a re-run (or a project already carrying Vajra's hooks) must not duplicate
     entries — key the merge on the hook command/script path (e.g. skip if an entry already
     references `.ai/hooks/hook-session-guard.sh`).
   - Preserve formatting sanity (pretty-print) and never emit invalid JSON.
3. Study the launcher's existing settings-merge (ADR-0003, the `--settings` injector path) and
   **reuse it if it already does additive hook-array merging** — one merge algorithm, not two.
   If it isn't reusable as-is, factor the minimal shared helper rather than copy-pasting.

## Scope discipline (the real risk)
- **≤3 files / 1 story.** Expected touch: `src/cli/init.rs` (+ maybe the shared merge helper's
  module) + `scripts/verify-session-44.sh`. Do NOT redesign the launcher's merge.
- **Do not clobber user config.** Over-preserve: when unsure whether a key is Vajra's, leave the
  user's value. A merge that drops a user hook is worse than a skipped file.
- Malformed existing JSON → fail loud with a clear message (do not silently overwrite the user's
  file); decide + document the behavior (skip-with-warning vs error).

## Proof discipline (required)
- A real `vajra init` into a temp repo with a **pre-existing** `.claude/settings.json` (carrying a
  user hook + an unrelated key) → assert: the user's hook + key survive **and** all Vajra hooks are
  now wired (grep the merged file for each `.ai/hooks/*.sh` + the SessionStart Darshan hook).
- **Idempotence:** run `vajra init` twice → no duplicate Vajra entries; the user's entries still
  present exactly once.
- The greenfield path (no existing settings.json) still writes the canonical file unchanged
  (regression).
- New scaffold unit tests in `src/cli/init.rs`, same shape as S29/S38/S43. `scripts/verify-session-44.sh`
  green; `cargo test` + clippy + fmt clean.

## Guardrails
- Branch `session-44-settings-json-merge` from `main`. New chat.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h.
- To push/PR, the founder launches with `VAJRA_ALLOW_PUBLISH=1` (the publish-guard blocks the agent).

## Explicitly OUT of scope (carry-forwards)
- **Live re-dogfood of the moat** (ROADMAP #17a) — the moat + S41 compression + S42 `jq` + S43
  git-belt are all test/replay-verified, not live-verified. Own session, costs real $.
- **cargo/npm/pytest exit-code fold gap** (S41 carry) — own compression session.
- **Boot-packet cost trim** (#18) — backlog, unchanged.
- Note: **S45 is the next mandatory NO-CODE ground-truth** (every 5th; last = S40).
