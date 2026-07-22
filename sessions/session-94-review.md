# Session 94 — Independent Fidelity Review (cold pass)

**Reviewer:** independent subagent, fed only the prompt + the delivery diff (did not read the
builder's summary). **Two passes** — pass 1 REJECTED, the gap was fixed in-session, pass 2 (this
record) re-verified the corrected diff and ran the tests.

**Pass 1 (REJECT):** closing the enclosing-branch *read* left the nested no-own-git path on the
pre-existing `[ -z "$SESS" ] → any non-empty marker allows` fallback, so a foreign/arbitrary marker
(`banana`, or Vajra's own `94`) authorized a commit in the subject — a fail-OPEN regression
(pre-S94 a mismatched marker was blocked because `SESS` resolved to the enclosing session). Fixed
with a distinct cannot-evaluate gate (fail-CLOSED when the project has no git of its own).

## Verdict table (pass 2, corrected diff)

| AC | Requirement | Verdict | Evidence |
|----|-------------|---------|----------|
| 1 | nested guard governs intended project, fail-closed | **SHIPPED** | Drove commit-guard from a nested no-own-git subdir (outer on `session-94`): markers `94`/`banana`/`07`/empty all → **exit 2**. Gate pins git facts to `OWN_GIT` (`GIT_TOP == pwd -P`) then refuses regardless of marker; tests assert the exit code (authorization property), not text. |
| 2 | resolved identity surfaced on advise/block | **SHIPPED** | `GOVERNS` echoed on every allow/advise/block in all three guards; nested block names subject + flags "nested inside git repo …". Reproduced live. |
| 3 | owner record + session-number pinned, no bleed | **SHIPPED** | Owner file `$ROOT/.ai/.session-owner` (never git); `$OUTER/.ai/.session-owner` never created. `sg-owner-pinned-to-subject`. |
| 4 | tests wired (exit 0); cargo green; non-nested unchanged | **SHIPPED** | `./scripts/verify-session-94.sh` → **23 pass, 0 fail** (ran it; incl. `cargo test`+`cargo build`). Own-git path byte-for-byte identical to pre-fix (allow/block/allow). |
| 5 | scaffold carries hardened guards byte-identical | **SHIPPED** | `include_str!` from `scripts/`; own `vajra init` → all three guards `cmp`-identical; scaffolded commit-guard carries the new gate. |
| 6 | summary maps ACs + independent cold review | **SHIPPED** | this independent pass (summary not read). |

## Is the prior fail-open genuinely closed?

**Yes — reproduced both directions live.** Against the pre-fix hook, a nested subject with the
enclosing repo's marker `VAJRA_ALLOW_COMMIT=94` returned rc=0 ALLOWED (the exact bleed pass 1
caught). Post-fix, the same input plus `banana`/`07`/empty all return rc=2 BLOCKED, with a
fail-closed message that never emits `=94` and never says ALLOWED.

## New regression introduced by the fix?

**None found.** Own-git session-branch + correct marker → ALLOW; wrong marker → BLOCK; empty →
BLOCK. Own-git L1 → advise; nested L1 → advise. `git status`/`log`/`diff` nested → pass through,
exit 0. Own-git non-session branch (`main`) + non-empty marker → ALLOW, **identical to pre-fix**
(zero-regression mandate honored, because `OWN_GIT` is set so the cannot-evaluate gate is skipped).

## Fakest green that remains

The pre-existing "any non-empty marker authorizes on an own-git **non-session** branch"
fallthrough (`[ -z "$SESS" ]`): off a `session-NN` branch, `VAJRA_ALLOW_COMMIT=banana` on
`main`/feature still authorizes — session-binding is enforced only when HEAD is `session-NN`. S94
deliberately leaves this intact (zero-regression mandate), so it is out of scope, but it is the
weakest authorization check still reading green. Secondary: nested-vs-own detection is tested only
for the vanilla `git init` plain-dir shape — worktrees / submodules / symlinked roots are untested;
all resolve **fail-CLOSED** (safe), but an exotic mount where git's `--show-toplevel` disagrees with
`pwd -P` would wrongly *block* a legitimate own-repo commit rather than fail open.

**Verdict:** ACCEPT — the S52/S93 nested fail-open is genuinely closed (every marker now blocks,
exit 2, live-verified), all 6 ACs ship, verify is 23/23, and the own-git path is byte-for-byte
behaviorally identical to pre-fix with no new regression.

**Review-Inputs-SHA:** 8a05903e7439ca25c73838610322d45d64922f0926f8dc46f0a7b742c4db5d14
