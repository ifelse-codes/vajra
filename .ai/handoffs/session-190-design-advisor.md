---
role: design-advisor
session: 190
agent: claude-code-subagent (verified: toolu_01MZ9VQT2ZGjexkwHmRMqaNm; text-sha: dd51b5e6c1e692b43c83fa80feebdbbb50eac06cd72655f929737a707c0f8f20)
source-sha: cd43798af1e1985422a8196dffef4fc0c3042b79ac75c757d30e280ea47fef06
captured: 2026-10-07T16:17:28Z
cost_usd: null
---

# Design-advisor handoff — session 190

Design read on the 6 checklist items (sources: prompts/190-task-ground-truth.md, .ai/STATE.md broken-list, DECISION-011, DECISION-007, ADR-0004 S189 addendum, src/cli/next.rs, scripts/hook-session-guard.sh, scripts/verify-session-{133,187}.sh).

rec 1 — Drop F110(b) as a session; its target no longer exists.
DECISION-011 S186 addendum designed (b) as a redirect-TARGET resolver for Bash COMMAND TEXT. DECISION-011's S188 addendum then "reverses, for Bash, … the S186 addendum §1–2 — block a command by reading its text" and replaces it with the before/after folder-state check. (b)'s whole mechanism (de-quote, resolve redirect target, `cd -P`) was built for a text-reading Bash guard that S188 retired. Building it now would harden a design the record already superseded — not a fix, a dead branch. If anyone wants Bash text-matching back, that needs its own new decision arguing against S188, not a citation of the old S186 addendum. Size: XS (close the backlog line, note why in STATE). Risk: none — S188's own named limits (change-undone-in-one-command, writes between pairs, another project's folder) are the real open Bash risks, untouched by (b).

rec 2 — Keep F110 option A (sandbox `denyWrite`) rejected; it's already a closed decision, not an open one.
DECISION-011 S188 addendum's Rejected list names it explicitly: "Claude Code's sandbox and Vajra's own OS box (founder, 2026-10-05)" — same wording as prompts/188-task-approvals-before-after-check.md line 66. This is not an undecided checklist item; it already has a record and a founder "no." Re-citing it as still-open in S190 would be a stale read. If the founder now wants it as a defense-in-depth LAYER (not a replacement for the before/after check), that is a genuinely new ask and needs its own addendum arguing why — not a quiet reopening. Size: XS (mark "already decided, cite DECISION-011 S188"). Risk: low either way; the only risk is treating a closed decision as still pending.

rec 3 — Fix `update_session_boot` to anchor the replace on the field, not the line.
Confirmed live: `.ai/SESSION-BOOT.md:10` is a real specimen — the session-188 line contains "188" six more times in prose (`S188 addendum`, `verify-session-188.sh`, `demo-session-188.sh`, `session-188-summary.md`...). `line.replace(&current_str, &next_str)` corrupts all of them. Fix: find `"**Number:**"`, split the line there, and replace only the number token immediately following it (skip leading whitespace, `strip_prefix(current_str)`), leaving everything after that token byte-for-byte untouched — never scan the rest of the line. Size: XS/S (~10-line diff + one regression test using this exact real line as the fixture, since it already exists on disk). Risk: low, mechanical.

rec 4 — Fix hook-session-guard.sh to stop reading heredoc bodies as command text.
The hook already strips `'...'`/`"..."` spans (S173, for commit messages) but a heredoc body (`cat > file <<'EOF' … EOF`) isn't a quoted span by that regex — it's unquoted multi-line text that lands straight into `$SCAN`. Vajra's own boilerplate (AGENTS.md step 10, this hook's own block message) literally contains the string "checkout -b session-NN-<slug>"; writing or copying that prose via a Bash heredoc trips the same regex that looks for a real checkout. Fix: strip heredoc bodies from `$SCAN` the same way quotes are stripped (data being written to a file, not executed), UNLESS the heredoc is piped into a shell (`<<EOF | bash`), which stays scanned under the existing "extra text only adds" rule. Size: S (bounded awk/sed addition, same shape as the existing quote-strip; needs the existing corpus-test discipline — old-vs-new must still block everything it blocked before). Risk: medium — stripping the wrong thing could reopen a real bypass; must go through the same two-pass cold-review discipline S186/S188 used for the approvals guard.

rec 5 — The lock-folder workaround is not sufficient; verify-133 itself needs the fix.
scripts/verify-session-133.sh's `fixture_fails_for_the_right_reason` hardcodes one fixed worktree path (`$ROOT/target/s133-fixture-wt`), so ANY two concurrent invocations collide on its index.lock — not just the one path S187 serialized. `V133_LOCK` in verify-session-187.sh only guards verify-187's OWN nested call; CI, a direct `bash scripts/verify-session-133.sh` run, or a future verify-NNN nesting it again all still race. Fix: make verify-133 use a per-invocation worktree path (`mktemp -d` or PID/timestamp-suffixed), same pattern `vajra_old_checkout` already uses elsewhere in this repo. Size: XS/S. Risk: low — localized to one fixture helper.

rec 6 — N2: a cheap path-scoping fix already has a full design on record; don't start over.
`.ai/handoffs/session-187-design-advisor.md` recs 12–19 already specify the fix for the GT write guard (`scripts/hook-pre-write.sh`, `GT_PW` branch) precisely: physically resolve ROOT (`cd -P`), require absolute paths only, block on symlink/hardlink leaves, fold case, boundary-match on `/`, fail-closed on any resolution error (exit 2, not 1), and scope the loosening to only the outside-pass inside `GT_PW=1`, never touching the approvals-guard allowlist. Rec 20 already calls for recording this as a DECISION-011 addendum with its stated limit (speed bump, not a sandbox; parallel-call check-then-write gap remains). This is the "cheap, safe" fix the session asks about — it is already fully designed, just not yet built or recorded as an addendum. Size: S/M (7 well-specified checks, bounded scope, no new guard class). Risk: medium only in the sense that it loosens a guard (S186's rule: loosening needs a class-level argument) — recs 12-19 already supply that argument; skipping the DECISION-011 addendum (rec 20) would repeat the exact "citation not written" gap S127 fixed.

design-significant for this GT session itself: no (it picks, builds nothing) — but items 3, 4, 5, 6 if built are each design-significant `yes` (new/changed guard or launcher logic); cite DECISION-011 for 1/2/6, and note 3/4/5 are implementation bugs against existing records, not new design (no ADR needed, just the fix + a STATE line).

## Handoff Delta
- `+` new: first design-advisor handoff for this session (6166 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
