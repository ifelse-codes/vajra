# Session 146 — Propagate the close-gate to adopters

## Goal

Close the two structural findings S144 uncovered in chitra. A brownfield adopter who runs
`vajra init --sync-fleet` today gets an upgrade to their role files, hooks, and constitution —
but their `scripts/verify-closeout.sh` stays frozen at adopt-time, and the binary-backed gates
inside that script hardcode `BIN="target/release/vajra"` (Vajra's own Rust build path). Both
were worked around by a disclosed manual patch in S144. Make the loop close for real.

## Two deliverables

### D1 — `--sync-fleet` propagates `scripts/verify-closeout.sh`

`vajra init --sync-fleet` currently covers only the 17 pure-render fleet files (roles + hooks +
the governed constitution body). Extend `sync_targets()` to include the close-gate script.

**Constraints:**
- The close-gate DOES carry user-written content (session-specific verify scripts are included
  via `source` or called by name). Treat `verify-closeout.sh` as a governed template with a
  known stamp, using the same S141/S142 four-state upgrade path already in place.
- Do NOT extend to session-specific `scripts/verify-session-NN.sh` — those are user-authored.
- Stamp the scaffolded version at `vajra init` time (same as hooks and roles).
- The upgrade must be dry-run-able via `--dry-run` and auto-upgrade via `--overwrite-drifted`
  (consistent with the existing API; no new flags).

### D2 — resolve `vajra` on PATH, not `target/release/vajra`

The canonical close-gate has `BIN="target/release/vajra"` hardcoded. Any non-Rust adopter (a
TypeScript project, a Python project, chitra) cannot run the three binary-backed gates because
that path does not exist.

**Fix:** the scaffolded `verify-closeout.sh` must resolve the binary via PATH first
(`which vajra` / `command -v vajra`), falling back to `target/release/vajra` for
self-governing (Vajra building Vajra). The fallback must be labeled as such in a comment.

**Constraint:** do NOT change the close-gate for the Vajra repo itself (this file is not
scaffolded here — we run the source file). The fix lives in the scaffolded template only.

## Acceptance criteria

1. `vajra init` scaffolds `scripts/verify-closeout.sh` with a render-sha stamp and a PATH-first
   binary resolver.
2. `vajra init --sync-fleet` classifies an unstamped or stale `verify-closeout.sh` as
   `Drifted` / `StaleRender` (matching the role/hook four-state logic) and upgrades it.
3. `--sync-fleet --dry-run` reports the close-gate's state without writing.
4. `--sync-fleet` with a user-edited close-gate refuses unless `--overwrite-drifted` is given.
5. The PATH-first resolver works in a directory with no `target/release/vajra` (proven live:
   the stranger-check or a fixture runs the close-gate from an empty `vajra init` directory
   where no Rust build exists).
6. The Vajra repo's own `scripts/verify-closeout.sh` is NOT modified by this session.
7. `verify-session-146.sh` exits 0 with all checks execute-based (no hollow source-greps).
8. `fixture-146` covers the five-state close-gate classification + the PATH-first resolver.
9. Tech-lead dispatched FIRST, verdict recorded. All required handoffs produced before close.
10. `verify-closeout.sh 146` exits 0 (incl. `check_required_crew`).

## Delta (what is new)

`sync_targets()` was extended to roles (S141), hooks (S142), and the constitution body (S143)
but never to the executable close-gate — because the close-gate is not a pure render. S144
proved this gap is real: a brownfield adopter's close-gate was frozen at pre-S139 (missing
`check_required_crew`) and had to be patched by hand. This session makes the loop close.

The PATH-first resolver is the simpler of the two fixes but equally important: without it,
chitra can never run `verify-closeout.sh` natively (no `target/release/vajra` in a non-Rust
project). The manual patch in S144 did exactly this; shipping it means the next adopter gets
it automatically.

## Design note

The close-gate has the same structure as a shell hook (shell script, comment-syntax stamp). The
S142 `MarkdownComment`/`ShellComment` `StampSyntax` already covers shell files — check whether
`verify-closeout.sh` fits the existing path before adding a new code path. Cite or deviate
from ADR-0001/0002/0003 as appropriate (the `## Design` section is mandatory — contact the
design-advisor role if uncertain).

## Guardrails

- Max 7 top-level commands (currently at 7 — this session adds NO new commands; the fix rides
  `vajra init` and `vajra init --sync-fleet`, existing commands).
- Max 3 files per atomic commit, `VAJRA_ALLOW_COMMIT=146`.
- No changes to the Vajra repo's own `scripts/verify-closeout.sh`.
- No changes outside `src/`, `scripts/`, and the scaffolded template string(s).
- Attest last: `vajra next --inputs-sha 146` after every prompt edit; run full
  `verify-closeout.sh` on the branch BEFORE merging.

## Launch

New chat · `git checkout -b session-146-closeout-propagation` · `vajra next 146`.
