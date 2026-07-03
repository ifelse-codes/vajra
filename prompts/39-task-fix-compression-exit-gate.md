# Session 39 — Fix the compression fail-gate (S36 finding, PROVEN)

> Renumbered 37 → 38 → 39 as the enforcement work took priority: S37 shipped the publish-guard,
> S38 propagates it into `vajra init`. Compression is the "quiet bonus," not the moat, so it sits
> *behind* the enforcement work. Still a proven, ready fix — do it once enforcement is closed (or
> if the founder re-picks it sooner). Branch when scheduled: `session-39-fix-compression-exit-gate`.

## ⛔ Guiding principle (non-negotiable — founder directive, S36)
**Correctness and the agent's experience beat token savings, always.** Compression is the quiet
bonus (~6–8%, never the moat — governance is the moat). So compression must **never gamble**: if
folding *might* hide information the agent needs, **do not fold — pass the full output through.**
A passthrough is never a bug; a fold that hides a real failure or misleads the agent *is*. When in
doubt, don't shrink. Two hard invariants any fold must satisfy:
1. **Never drop the failure signal.** If output shows (or might be) a failure, its error text must
   survive the fold, or we don't fold at all.
2. **Always recoverable.** The breadcrumb + `VAJRA_RAW=1` path stays, so full output is one step away.

## The bug (root cause, proven S36)
`src/engine/default_engine.rs:17` runs a **fail-gate before any heuristic is selected**:

```rust
if line_count < LINE_CAP (30)                         { return Passthrough; }
if !is_success(&output) && line_count < 400           { return Passthrough; }  // ← the killer
```

`is_success` → `exitCode` if present, else `infer_success` (only true for cargo/pytest
**success-marker tails**: "Finished…", "test result: ok", "N passed"). **Real Claude Code sends
no `exitCode` for Bash** (confirmed S31/S33), so every ordinary command — `git log`, `git status`,
`ls`, `find`, `cat` — with 30–399 lines is inferred as *failure* → passthrough. **Only ≥400-line
output ever folds.** Net: compression does ~nothing in a normal session (S36: 0 folds live).

## Proof already captured (reuse as test oracle)
Deterministic `vajra hook` runs with complete real-shaped payloads (no `exitCode`):
| Case | Folds today | Target after fix |
|---|---|---|
| `git log` / `git status` (large), no `exitCode` | ❌ | ✅ **must fold** (known-safe heuristic unblocked) |
| `ls`/generic 80 lines, no `exitCode` | ❌ | session's call — **safe head+tail fold OR passthrough, never a risky fold** |
| anything with `exitCode:0` | ✅ | ✅ (unchanged) |
| ≥400 lines, no `exitCode` | ✅ | ✅ (unchanged) |
| **genuine failure** (error markers, no `exitCode`) | passthrough | **must still passthrough — never hide a failure** |

## Scope (1 story, ≤3 files)
The bug is real, but the fix must be **conservative, not aggressive.** Do NOT simply "fold unless
failure is proven" — that gambles on marker-less failures. Instead, unblock folding **only where
it is provably safe**, and passthrough everywhere we can't guarantee correctness.

1. **Unblock the purpose-built, format-aware heuristics regardless of exit code.** The git family
   (`git log` / `git status` / `git diff --stat`) already fold lossy-*safe* for their known format
   and preserve head+tail; today `default_engine.rs:17`'s fail-gate wrongly blocks them because
   real CC omits `exitCode`. Let these known-safe heuristics run when output is large — the win is
   here, and it satisfies the invariants (tail preserved, recoverable).
2. **Keep the generic/unknown path conservative.** For arbitrary commands (`ls`, `cat`, anything
   with no format-aware heuristic), do NOT fold merely because no failure was detected. Fold only
   when correctness is guaranteed — i.e. head+tail folding that *provably* preserves the failure
   signal (tail kept) — or leave it as passthrough. **Prefer passthrough over a risky fold.** If
   the safe rule ends up folding little for unknown commands, that is acceptable per the guiding
   principle — tokens are the least important axis.
3. **The danger case → passthrough.** A command that failed but printed no error marker and no
   exit code: do not fold it in a way that could hide the failure. When we can't be sure, don't
   shrink. Document exactly how the chosen predicate handles this.

## Proof discipline (required)
- Add regression tests from **verbatim real-shaped payloads** (snake_case top level, camelCase
  `tool_response`, `noOutputExpected` present, **no `exitCode`**). Load-bearing (correctness-first):
  - a large `git log`/`git status` that **fails to fold before / folds after** (the real win);
  - a **genuine-failure** payload (error markers, no `exitCode`) that **passes through both before
    and after** — the invariant that must never regress;
  - whatever the generic path decides for `ls`, assert it **never drops the tail** (failure signal
    preserved). The existing `tests/hook_adapter.rs` real-shape fixtures are the template.
- `scripts/verify-session-39.sh` green; `cargo test` + clippy clean.
- Sanity-check against the real loop if cheap: `vajra hook` fold table flips as above (no paid
  `vajra claude` run required — the S36 method proves it for $0).

## Guardrails
- Branch `session-39-fix-compression-exit-gate` from `main`.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h. New chat.

## Explicitly OUT of scope (carry-forwards, own sessions)
- **Silent-parse-failure blindness** (S36): `HookToolResponse` requires `isImage`/`noOutputExpected`
  as non-`Option` → a payload missing either → silent `{}` passthrough, no signal. Same fail-open
  shape that hid the S31 bug 22 sessions. Candidate: make them `#[serde(default)]` + a debug/warn
  or receipt line when the hook parse-fails or folds 0.
- **Boot cache-write cost** (S36): ~$1.87/session to load the constitution — the "<5% footprint"
  rule. Trim/lazy-load the boot packet. Separate session.
- **`.claude/settings.json` merge on init** (S34) — still backlogged.
- **verify/demo templates land in the project's own `scripts/`** (S36 minor) — a pnpm package in
  chitra.
