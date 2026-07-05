# Session 44 — Merge into an existing `.claude/settings.json` on `vajra init` (CODE, founder pick B)

## Goal
Close the S34 finding (ROADMAP #18b): `vajra init` followed skip-if-present for every file,
which is **wrong** for `.claude/settings.json` — a brownfield repo that already had one kept it
untouched, so the scaffolded `.ai/hooks/` were never fired and the **entire L3 enforcement moat
(Darshan boot, co-pilot, session-guard, publish-guard) was silently absent** for exactly the
primary use case. Make init **merge** Vajra's hooks into the existing file, additively + idempotently.

## Goal achieved? YES.
For `.claude/settings.json` **only**, init now merges instead of skipping:
- Appends Vajra's `SessionStart` + `PreToolUse` hook groups as separate array entries; **every user
  key and hook is preserved** (verified: `model` key, user SessionStart hook, user Bash hook all survive).
- **Idempotent** — a re-run adds nothing (keyed on structural group-equality *or* the group's
  `.ai/hooks/*.sh` script paths already being referenced, checked against a pre-merge snapshot so the
  co-pilot hook shared across the Bash + Edit groups doesn't self-cancel).
- **Malformed existing JSON → left untouched with a loud `warn`** (never overwritten); init still exits 0.
- Greenfield path (no existing settings) unchanged — canonical file written (regression green).
- Launcher's `merge_hook_settings_for` (ADR-0003) **not reused** — it builds a *fresh PostToolUse-only*
  object for the `--settings` temp file; a different shape from an additive on-disk merge. Documented in a
  code comment rather than force-shared.

## Evidence
- `scripts/verify-session-44.sh` — **24/24 ALL GREEN**: real `vajra init` into a temp brownfield repo
  (pre-existing settings carrying a user hook + an unrelated key) → user hook + key survive **and** all 4
  Vajra hooks wired **and** valid JSON; run 2× → no duplicate Vajra entries, user hook still once;
  greenfield still writes the canonical file (clean); malformed file preserved byte-for-byte + warns.
- `cargo test` — **117 lib (+6 new)** + 12 adapter; `cargo clippy --all-targets -D warnings` clean; `cargo fmt --check` clean.
- **Files: 2** — `src/cli/init.rs` (+281) · `scripts/verify-session-44.sh` (new). Commit `8a78ca6`. ~$0.
- Accepted cosmetic: `serde_json` sorts object keys (no `preserve_order` feature → would need a dep change),
  so top-level key *order* may shift. **Zero content dropped; hook execution order (array order) preserved.**

## Self-review (5/5 clear)
- **What breaks?** malformed JSON (handled: skip+warn), non-object root (errors, not clobbered), pre-wired
  project (idempotent), user with own Bash group (preserved as a separate group). All tested.
- **Hidden assumptions?** key reordering is cosmetic (documented); idempotence snapshot avoids the shared-copilot hazard.
- **Production ready?** yes — unit + real-init E2E.  **Defensive only on repro?** yes.  **Scope intact?** 2 files, 1 story.

## PR
- **Pending — founder pushes.** The publish-guard blocks the agent by design. Push:
  `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-44-settings-json-merge`, then open the PR to `main`.
- Post-merge: checkout `main` + prune the merged branch (the S37 return-to-main step).

## Next session — S45 is the MANDATORY NO-CODE ground-truth (every 5th; last = S40)
The session *type* is forced (NO-CODE audit, all `required_audits` run). The choice is the **primary lens**:

### A — Dogfood / enforcement-completeness re-audit (recommended)
- **Goal:** re-run the S40 lens — is the moat provably *live* yet? The dogfood gate has been UNMEASURED
  since S36; S41 (compression) + S42 (jq) + S43 (git-belt) + S44 (settings-merge) are **all test-verified,
  not live-verified**. Rank whether a real `vajra claude` re-dogfood (#17a) must precede more code.
- **Why pick:** four straight plumbing sessions with zero live proof; the honest gate keeps slipping.
- **Key risk:** another "flag it, don't guess" verdict without an actual run — the audit can't itself dogfood.

### B — Direction / vision drift (Claude depth vs cross-agent breadth)
- **Goal:** re-examine whether deepening Claude-on-enforcement is still the shortest path to the north-star
  (*cross-agent* workflow coach). S44 is the ~4th consecutive Claude-only session; cross-agent code is zero
  (S25, ~19 sessions stale). Is this on-wedge, or comfortable scope creep?
- **Why pick:** the north-star is vendor-neutral; we keep building Claude plumbing.
- **Key risk:** re-litigates a settled founder call (second agent parked until Claude-on-Claude is satisfying).

### C — Constitution / process-cost drift
- **Goal:** audit whether the workflow mechanics still serve the vision — boot-packet cost (#18: the heavy
  constitution drove ~$32 cache-read of a $58 session), the ≤3-file cap forcing story-splits (S42), the
  co-pilot commit-gate friction seen this session.
- **Why pick:** process overhead taxes every session; the <5% footprint rule is unmet.
- **Key risk:** lowest external leverage; introspective.

_Founder picks A/B/C → I write `prompts/45-task-<lens>-gt.md`, update the `.ai/` pointers, and run the closeout._
