# Session 39 — Harden the guards: publish-guard false-positive (B) + session-boundary arming (A)

> **Deliberate owner override of `max 1 story per session`.** The founder picked *both* A and B for
> S39 (S38 closeout). They are two stories touching two different hooks; combining them is an explicit
> owner call, recorded here. **Order is load-bearing: do B first (small, contained, banks a real bug
> fix), then A (design-bearing — keep it bounded so the ~2h cap holds).** If the cap hits mid-A, B is
> already shipped and A splits cleanly to S41. Branch: `session-39-harden-guards`.
>
> Note: S40 is the mandatory NO-CODE ground-truth (every 5th). The compression fail-gate fix is
> renumbered to `prompts/41-task-fix-compression-exit-gate.md` (the leading post-GT candidate).

## Why both, why now
S38 propagated the publish-guard into every scaffolded project — but building S38 surfaced a **live
correctness bug in that very guard** (B), and the S36 root-cause enforcement gap (A) is still open.
Both are "make the enforcement moat actually correct," which is why the founder wants them together.

---

## Story B (FIRST) — Fix the publish-guard false-positive (over-blocking)

**The bug (hit live in S38):** `scripts/hook-publish-guard.sh` greps the *entire* Bash command
string, so the trigger phrase appearing **anywhere** — including inside a `git commit -m "…git
push…"` message, a `--body`, a heredoc, or an `echo` — is blocked even though nothing is being
pushed. S38's own feature commit was blocked because its message described the guard; worked around
with `git commit -F <file>`. This is the **over-block** direction (a real usability defect), distinct
from S37's recorded **under-block** limit (obfuscated `g=push; git $g`).

**Scope (conservative — enforcement must not weaken):**
1. Match the **command being invoked**, not any substring of the line. Detect `git push` /
   `gh pr create|merge` / `glab mr create|merge` as the *leading command token* (optionally after
   `cd … &&`, `env VAR=… `, leading whitespace), not as text buried in an argument or message.
2. **Never weaken the block.** A real `git push origin main` (any form: `--force`, compound
   `cd /x && git push`) must still block at L2/L3. Only the false-positive on argument/message text
   is removed. When in doubt about a construct, **keep blocking** (fail-safe: over-block > leak).
3. Keep it bash + here-strings (no new dep; the S32 SIGPIPE-under-pipefail gotcha still applies).

**Proof (reuse `verify-session-37.sh` harness — extend it or a new S39 harness):**
- Regression cases that must **now pass (exit 0)**: `git commit -m "mentions git push"`,
  `echo "gh pr create"`, `git commit -F file`.
- Cases that must **still block (exit 2 at L2)**: every S37 block case (real push, force-push,
  compound push, `gh pr create --fill`, `gh pr merge`, `glab mr *`) — zero regressions.
- `scripts/hook-publish-guard.sh` is `include_str!`'d into `vajra init` (S38), so the scaffolded
  copy inherits the fix for free — assert the byte-identical `cmp` still holds.

---

## Story A (SECOND, BOUNDED) — Arm the session-guard on *any* advance

**The gap (S36 root cause #1):** `scripts/hook-session-guard.sh` arms only on
`git checkout -b session-(N+1)-*` from a chat that already *owns* N. In S36 the brownfield agent
never branched `session-00`, so nothing was owned and the tripwire never armed — it advanced
00→01, pushed, and merged two PRs in one chat, unstopped. The boundary must arm on **any** session
advance, not just `checkout -b`.

**Bounded scope (define the "advance" signal — keep it minimal, do NOT gold-plate):**
1. Treat a **`.ai/SESSION` bump** and/or **`vajra next --advance`** as an advance event the guard
   watches — the same "same-chat crosses N→N+1" block it already does for `checkout -b`. Pick the
   **one** signal that most directly closes the S36 path (the `SESSION` write is the common
   denominator of every advance) and wire the guard to it; document why that signal.
2. Reuse the existing owner-record mechanism (`.ai/.session-owner`, `session_id`, maturity gate,
   `VAJRA_SESSION_OWNER_FILE` test knob). No new file, no new dep.
3. **If A grows past a clean ≤3-file change or the design forks, STOP and split the remainder to
   S41** — B is already banked. Do not blow the 2h cap chasing completeness.

**Proof:**
- A scaffolded/temp-repo test: same chat that owns N, on an advance signal (SESSION bump /
  `--advance`), is blocked (exit 2 at L2); a fresh chat passes; non-session advances pass.
- The S26/S29 checkout-b block still holds (no regression); scaffolded guard still byte-identical.

---

## Proof discipline (whole session)
- `scripts/verify-session-39.sh` green (B cases + A cases + no-regression on S37/S26 behavior).
- `cargo test` + clippy clean; if `src/` changes for A (e.g. `vajra next --advance`), fmt clean too.
- Byte-identical check: scaffolded copies of both hooks == canonical (the S22 `cmp`/drift guard).

## Guardrails
- Branch `session-39-harden-guards` from `main`.
- Max 2 assumptions / 2 retries / ~2h. **≤3 files per atomic commit** (commit B and A separately;
  B first). One session, two stories — owner-authorized override, ordered so B always ships.
- **To push/PR this session, launch with `VAJRA_ALLOW_PUBLISH=1`** — the guard blocks the agent
  otherwise (by design). Once B lands, a commit *message* mentioning the trigger phrases no longer
  false-blocks.

## Ranked follow-ons (own sessions, do NOT cram in)
- **S40** — mandatory NO-CODE ground-truth (every 5th).
- **S41 (leading)** — compression fail-gate, correctness-first (`prompts/41-task-fix-compression-exit-gate.md`, ready).
- Git-level `pre-push`/`pre-commit` scaffolding (the S38-split belt-and-suspenders L2 layer).
- Publish-guard remaining v0 limits: jq-missing fail-open, per-launch (not per-action) approval.
- Boot-packet cost trim (~$32 cache-read / $58 session — the "<5% footprint" rule).
