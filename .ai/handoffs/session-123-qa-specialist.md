---
role: qa-specialist
session: 123
agent: claude-code-subagent
source-sha: 3f401d0250c9c31cb316709928babe706be7981543a956aa00ee70e62cabfb41
captured: 2026-08-19T14:44:53Z
cost_usd: null
---

# Qa-specialist handoff — session 123

## QA Evidence Brief — Session 123

**Command run (from repo root, twice, to confirm the exit code independent of any pipe):**
```
bash scripts/verify-session-123.sh
```
**Real exit code: `0`** (confirmed on a second, unpiped run: `REAL EXIT CODE: 0`).
Artifacts: `.ai/verify/session-123/20260819T142253Z/` (per-check logs + `latest` symlink).

Note: this dispatch ran under the PRE-S123 grant (`Bash, Read, Write, Edit, Grep, Glob`) — per the
standing S111 limit, Claude Code snapshots `.claude/agents/*.md` at session boot, and the S123 grant
narrowing landed mid-session, after this session's boot.

### Live summary output (verbatim)

```
=== Session 123 Verify Summary ===
STEP                                   CLASS   RESULT
------------------------------------   ------- ------
cargo-build                            exec    PASS
cargo-test                             exec    PASS
cargo-fmt                              exec    PASS
cargo-clippy                           exec    PASS
test-filter-guard-has-teeth            exec    PASS
tally-is-one-source                    struct  PASS
s122-suite-green                       nested  PASS
gate-run-open-persistent-tests         exec    PASS
gate-run-remove-persistent-tests       exec    PASS
grant-write-edit-dropped               exec    PASS
clean-room-open-refuses-read-only      exec    PASS
clean-room-fence-has-teeth             exec    PASS
no-eighth-command                      behav   PASS

ALL GREEN (13 pass, 0 fail)
```
`cargo test --lib` really ran 339 tests, not a stub. The two named-filter checks
(`gate_run::tests::open_persistent…`, `…remove_persistent…`) each really matched and ran exactly 1
test.

### Independent classification (13 top-level checks, pre-fix state)

EXECUTE-BASED (9): cargo-build, cargo-test, cargo-fmt, cargo-clippy, test-filter-guard-has-teeth,
gate-run-open-persistent-tests, gate-run-remove-persistent-tests, clean-room-open-refuses-read-only,
clean-room-fence-has-teeth.

STRUCTURAL (1): tally-is-one-source.

BEHAVIORAL SOURCE GREP / HOLLOW (2 after correction): no-eighth-command (self-disclosed hollow
since S121/S69) and **grant-write-edit-dropped, which the script had mislabeled `exec`** — it only
greps a static, already-committed file (`.claude/agents/qa-specialist.md`) rather than re-rendering
from `fleet::ROLES` and diffing, and proves nothing about whether the harness actually honours
`tools:` at dispatch time. This was corrected post-dispatch (commit `0e3d7c4`) — reclassified to
`behav` with an explanatory comment.

NESTED (1): s122-suite-green — really executes verify-session-122.sh in full and asserts real exit
0. That nested run reports 23 of its own checks (16 exec / 3 structural / 1 behavioral / 3 further
nested, unexpanded in this pass).

### Deep-dive on the load-bearing fixture: clean-room-fence-has-teeth

Read the fixture's own log and the implementation it exercises (`src/gate_run.rs`) to test the
specific S122 "fails for the wrong reason" / cross-half-pollution risk.

- Half 1 captures HEAD / `ls-files -s` hash / `status --porcelain` on the throwaway subject BEFORE
  `--clean-room-open` runs, then asserts the probe text landed in the clean-room worktree AND is
  explicitly absent from the subject's own `tracked.txt` — a genuine differential check.
- Cleanup between halves runs the real `git worktree remove --force` (confirmed by reading
  `src/gate_run.rs`), which prunes the `.git/worktrees/<name>` entry, not just `rm -rf`.
- Half 2 (negative control) writes directly to the subject's `tracked.txt`, a completely different
  code path from half 1, so there is no leak between the two. It asserts on `status --porcelain`
  (correctly, not `ls-files -s`, which hashes the index and would miss an unstaged edit) and
  genuinely fails if the detection were vacuous.
- The fixture restores the subject with `git checkout -- tracked.txt` and asserts clean status
  before `rm -rf`ing the throwaway repo.

**Verdict on this fixture: it holds up.** Real git, a real compiled binary, a real worktree, and a
real negative control. No cross-half pollution or wrong-reason-pass hole found.

### What this suite never exercises (stated plainly)

- No check anywhere in this chain drives a real Claude Code session as qa-specialist and observes a
  genuine tool-permission refusal when it attempts Write/Edit — that enforcement lives in Claude
  Code's harness, outside this repo, and is untestable from here. `grant-write-edit-dropped` only
  proves the checked-in manifest says the narrowed grant; nothing in THIS suite proves it's honoured
  at the point of use (the separate `researcher` dispatch measurement, captured in
  `sessions/session-123-artifacts/tools-enforcement-measurement.md`, is what actually measures that).
- Per the script's own header: the clean room isolates the repo, not the machine — Bash remains
  granted, so the executor thesis stays explicitly open, not resolved by this session.
- The nested suites were executed for real but not individually re-expanded and re-audited in this
  pass — disclosed as a floor, not a full census.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (5123 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
