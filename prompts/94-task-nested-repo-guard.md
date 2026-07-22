# Session 94 — Close the nested-repo guard blindspot

> **Status:** APPROVED (founder deferred to recommendation at S93 close → A).

## Goal

Vajra's PreToolUse guards (`hook-session-guard.sh`, `hook-commit-guard.sh`, `hook-copilot-*`) key
on a `session-NN-*` branch name and a git repo. During a **dogfood** the agent runs `vajra claude`
with `cwd` = a **subject repo** (e.g. chitra) that may have its *own* `session-NN-*` branches and
its *own* `.ai/`. The guards resolve context from `CLAUDE_PROJECT_DIR` / `$(dirname $0)/..`, so a
guard shipped into the subject repo governs the subject repo — but the blindspot (S52) is that
**nothing verifies the guard is acting on the project it was scaffolded into**, and a guard invoked
with a stale/wrong `CLAUDE_PROJECT_DIR`, or from a working tree nested inside another git repo, can
govern the wrong repo (or mis-derive the session number / owner record). This session makes the
guards **repo-identity-aware**: each guard acts only on the project it belongs to, and says so.

This is a **CODE** session. Deliverable is the hardened repo-identity resolution + tests, not prose.

## The gap (from S52, now load-bearing after S93)

- The S93 commit-guard also keys on `session-NN`, so a nested/subject `session-NN` branch now hits
  a *third* guard — the blindspot's blast radius grew.
- Symptom shapes to close: (a) a guard run from a path nested inside a different git repo derives
  the wrong `.ai/SESSION` / branch; (b) the session-guard's owner record (`.ai/.session-owner`)
  could be read/written in the wrong repo; (c) no guard states *which* project + repo it governs.

## Acceptance Criteria

1. Each guard resolves its governed project **deterministically and correctly when nested** inside
   another git repo — it acts on `CLAUDE_PROJECT_DIR` (the scaffolded project root), never silently
   on an enclosing repo's `.ai/` or branch. A test drives a guard from a working tree nested inside
   a DIFFERENT git repo and asserts it governs the intended project. `covers: 1`
2. The resolved identity is **surfaced** — on a block (and at L1 advise) the guard names the project
   root / repo it is governing, so a nested mis-fire is visible, not silent. `covers: 2`
3. The session-guard owner record and session-number derivation are pinned to the governed project
   (no cross-repo bleed). A test covers the nested case. `covers: 3`
4. Automated tests wired into `scripts/verify-session-94.sh` (exit 0); `cargo test --lib` stays
   green. Existing guard behavior (S26/S37/S39/S93) is unchanged for the non-nested case
   (zero regression — assert it). `covers: 4`
5. `vajra init` scaffold carries the hardened guards byte-identical (the `include_str!` one-source
   pattern); e2e asserts no drift. `covers: 5`
6. `sessions/session-94-summary.md` maps every AC to SHIPPED/PARTIAL/NOT-BUILT + names the fakest
   green; reviewed by an independent cold pass (subagent, prompt+diff only). `covers: all`

## Design

design-significant: **no** — this hardens the existing guard family's context resolution; it does
not introduce a new enforcement boundary. Cite `docs/decisions/DECISION-001-governance-as-product.md`
and the existing `CLAUDE_PROJECT_DIR` resolution convention shared by all hooks. No new ADR.

## Plan

1. Reproduce the blindspot: drive a guard from a temp working tree nested inside a different git
   repo and show it mis-deriving context today. `covers: 1`
2. Pin every guard's project resolution to `CLAUDE_PROJECT_DIR` (falling back to the hook's own
   scaffold location), never `git rev-parse` from an ambient cwd; surface the governed root. `covers: 1, 2`
3. Pin the session-guard owner file + session-number to the governed project. `covers: 3`
4. Add nested-case + zero-regression tests; wire `scripts/verify-session-94.sh`. `covers: 4`
5. Confirm `vajra init` inherits the hardened guards byte-identical. `covers: 5`
6. Summary + fidelity map + independent cold review. `covers: 6`

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story · max 3 files per atomic commit · ~2h cap.
- Branch: `session-94-nested-repo-guard`. **New chat.**
- Do NOT weaken any existing guard; the non-nested path must stay byte-for-byte behaviorally identical.
- Supply the approval marker for each commit (S93): `VAJRA_ALLOW_COMMIT=94 git commit …`.
- Full closeout: `scripts/verify-closeout.sh` exits 0 before close.
- **S95 is the mandatory NO-CODE ground truth** — do not overrun into it.

## Delta (Analyst gate)

- `~` `scripts/hook-session-guard.sh` · `scripts/hook-commit-guard.sh` · `scripts/hook-copilot-*.sh`
  — pin project resolution + surface governed root (touch only what's needed; ≤3 files/commit)
- `+` `scripts/verify-session-94.sh` + `scripts/demo-session-94.sh` — prove nested vs non-nested
- `~` `src/cli/init.rs` — only if a scaffold-drift test needs updating (guards are already `include_str!`)
