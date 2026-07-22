# Session 94 — Close the nested-repo guard blindspot

**Type:** CODE · **Branch:** `session-94-nested-repo-guard` · **Date:** 2026-07-22

## Goal

Make Vajra's PreToolUse guards **repo-identity-aware** — each acts only on the project it was
scaffolded into (`CLAUDE_PROJECT_DIR`), never on an enclosing repo during a nested dogfood, and
**says which project it governs**. Closes the S52 blindspot, now load-bearing after the S93
commit-guard (which also keys on `session-NN`).

## Result — achieved

- **Root cause found + reproduced:** two guards derived git facts from `$ROOT` (`git -C "$ROOT"`
  / `cd "$ROOT" && git status`), which **walk up to the nearest `.git`**. A subject tree nested
  inside another git repo (a subject checked out under Vajra, on `session-94-*`) had:
  - `commit-guard` read the **enclosing** repo's branch → block message demanded
    `VAJRA_ALLOW_COMMIT=94`, and Vajra's own founder marker (`94`) **authorized a commit inside
    the subject**. Live repro captured before the fix.
  - `copilot-murmur` run `git status` in `$ROOT` → murmured the **enclosing** repo's changes.
- **Fix:** pin git facts to the project's **own** git top-level — only read git when
  `git -C "$ROOT" rev-parse --show-toplevel` == `$ROOT` (canonicalized `pwd -P`). Otherwise the
  project has no own git state, and the guard neither adopts the enclosing branch nor murmurs its
  changes. Every advise/block now **surfaces the governed project** (and flags the nesting).
- **session-guard** was already file-pinned (`$ROOT/.ai/SESSION`, `$ROOT/.ai/.session-owner`, no
  git) — added the identity surfacing + nesting flag; a test proves no cross-repo bleed.
- **Evidence:** `scripts/verify-session-94.sh` = **21/21 PASS** (exit 0); `cargo test` green
  (286 lib tests incl. the byte-identical scaffold-drift tests); `scripts/demo-session-94.sh`
  emits all 4 Demo-er markers with every case green.
- **Commits:** `5218091` (3 guards) · `1e6d664` (verify + demo).

## Fidelity Map (every prompt AC → evidence)

| AC | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| 1 | Guard governs the intended project when nested; test drives it from a tree nested in a DIFFERENT git repo | **SHIPPED** | `commit-guard` + `murmur` pin to own git top-level. Checks `cg-nested-blocks-no-marker`, `cg-nested-no-enclosing-leak`, `cg-nested-names-project`, `murmur-nested-stays-quiet` |
| 2 | Resolved identity is surfaced on block + L1 advise | **SHIPPED** | `Governing $GOVERNS` in commit-guard ALLOW/advise/block; `Governing project …` in session-guard block/advise. Checks `cg-nested-names-project`, `sg-nested-block-names-project` |
| 3 | session-guard owner record + session-number pinned to the governed project; nested test | **SHIPPED** | already `$ROOT`-pinned (no git); `sg-owner-pinned-to-subject` (owner lands in subject, never enclosing), `sg-nested-block-names-project`, `sg-standalone-still-blocks` |
| 4 | Tests wired into `verify-session-94.sh` (exit 0); `cargo test --lib` green; non-nested unchanged (assert zero regression) | **SHIPPED** | 21/21 exit 0; `cargo-test` PASS; `cg-standalone-allow-correct` / `-block-wrong` / `-inline-blocked` / `-status-passes`, `sg-standalone-still-blocks`, `murmur-standalone-murmurs` |
| 5 | `vajra init` scaffold carries hardened guards byte-identical; e2e asserts no drift | **SHIPPED** | guards ride `include_str!` (no `init.rs` edit needed); `e2e-{commit,murmur,session}-guard-byte-identical` + init.rs drift tests in `cargo test` |
| 6 | summary maps every AC + names fakest green; independent cold review (subagent, prompt+diff) | **SHIPPED** | this file + cold review below |

## What I did NOT build (stated plainly)

- **No shared `hook-lib.sh`.** The identity block is inlined (copy-consistent) across the two
  git-using guards, matching the repo's existing duplicated jq-preflight / `_VROOT` idiom and the
  approved Delta (which scoped `~` the existing scripts, no new lib). One-source DRY was declined.
- **No `init.rs` change.** The guards are already `include_str!`, so scaffold byte-identity is
  structural; existing drift tests + e2e cmp cover AC5. (Prompt Delta flagged this as "only if
  needed" — it was not needed.)
- **copilot-loader untouched.** It is file-path pinned (`REL` from `$ROOT`), uses no git, so it
  has no git-bleed. It is *not* hardened beyond that, and it does **not** yet surface the governed
  project (only the two guards that block + session-guard do). Honest scope note, not a silent skip.

## Fakest "green" here

**The nested-no-own-git commit-guard falls back to "any non-empty marker allows."** When a subject
has no git repo of its own, the guard can't derive a session number, so it keeps the pre-existing
fail-closed default (`[ -z "$SESS" ]` → any non-empty `VAJRA_ALLOW_COMMIT` passes). The fix's real
win is that it **no longer adopts the enclosing repo's session number** (no false-reject of the
subject's correct marker, no binding to Vajra's `94`) and **surfaces the nesting**. But a nested
plain-dir subject is still governed only by "some approval marker present," not by *its* session.
The normal dogfood shape (subject IS its own git repo) resolves the subject's session correctly —
that is the case that matters, and it is fully tested. Disclosed, not hidden.

Second-fakest: the identity block is **inlined in two files**, so a future edit could let them
drift. Mitigated by the byte-identical scaffold tests + `bash -n` gates, not by a single source.

## Next options (A/B/C)

> **S95 is the mandatory NO-CODE ground truth** (`95 % 5 == 0`) — these frame what S96 tackles
> after the GT signs off.

- **A — Surface identity across the whole hook family.** Extend the S94 governed-project surfacing
  to copilot-loader + publish-guard (+ session-start banner) so *every* hook names its project.
  *Why:* completes AC2's spirit repo-wide; a nested mis-fire is visible everywhere, not just at the
  two blocking guards. *Risk:* low-leverage polish; touches many files for cosmetic parity.
- **B — Paid dogfood ride-along on a truly-nested subject.** Run `vajra claude` against a subject
  repo deliberately nested under Vajra and confirm the S94 fix holds in a real launch (not just
  synthetic payloads). *Why:* dogfood is the only proof of lived behavior; last paid run was S92.
  *Risk:* costs real $; the nested shape is contrived vs. the normal own-repo subject.
- **C — Extract the shared `hook-repo-identity.sh` (one-source DRY).** Replace the inlined identity
  block with a sourced helper, scaffolded via `include_str!`. *Why:* kills the drift risk named in
  the fakest-green. *Risk:* new file + sourcing-failure mode + scaffold wiring; net complexity may
  exceed the drift it prevents.

## Independent cold review

Two-pass (`sessions/session-94-review.md`):

- **Pass 1 — REJECT.** Caught a real **fail-open**: closing the enclosing-branch *read* left the
  nested no-own-git path on the pre-existing `[ -z "$SESS" ] → any non-empty marker allows`
  fallback, so `banana` (or Vajra's own `94`) authorized a commit in the subject — worse than the
  pre-S94 behavior (which blocked a mismatched marker). Real catch; the "green" tests asserted
  block-message text, not the authorization property.
- **Fix (commit `363e90c`).** A distinct **cannot-evaluate gate**: when the project has no git of
  its own, a commit here mutates the enclosing repo and no marker can bind to this project's
  session → **fail-CLOSED** (block regardless of marker; "a check that cannot evaluate FAILS"). The
  `[ -z "$SESS" ]` permissive path is now reached only for an own-repo, non-session branch (its
  original purpose). Tests upgraded to assert the authorization property (nested + `94`/`banana`/
  none → exit 2). verify 21→**23/23**.
- **Pass 2 — ACCEPT.** Re-verified the corrected diff live (both directions), ran verify (23/23),
  confirmed the own-git path byte-for-byte identical to pre-fix, no new regression.
  Attested `**Review-Inputs-SHA:** 8a05903e…`.

**Fakest green (updated):** the pass-1 catch upgrades the earlier "message-text-only" concern —
the nested authorization is now genuinely fail-closed and tested. The residual is the pre-existing
own-git **non-session-branch** fallthrough (any non-empty marker authorizes off a `session-NN`
branch), left intact by the zero-regression mandate; and nested-vs-own detection is tested only for
the plain-dir shape (worktrees/submodules/symlinked roots resolve fail-closed but are untested).
