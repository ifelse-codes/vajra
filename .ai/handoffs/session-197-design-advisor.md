---
role: design-advisor
session: 197
agent: claude-code-subagent (verified: toolu_011mxafnHVzTSBj5VKQv3D5A; text-sha: 8828bd1fdef93c1e65155a6bf5224aea27ca8aaf7439cc4157672c84d52e65e5)
source-sha: ef5cdec4a9eb043ce4ed9657595e6d34491a41a8e590b2278f1a70a2d4cd34c6
captured: 2026-10-14T16:55:30Z
cost_usd: null
---

# Design-advisor handoff — session 197

## Design-advisor brief — S197 (F125 + N17), read-only

**Marker:** keep `design-significant: yes`. This session adds a new shipped hook, a new `vajra approve` flag and a new record kind, and it changes a guard. Cite `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md`, which exists, and add the S197 addendum below. Say plainly where it **deviates**. S191 §1 said "`hook-pre-write.sh` is Vajra's own, `vajra init` ships no copy" (DECISION-011:325). `.ai/AGENTS.md:100` says "exempt by suffix". The S134 `VAJRA_GT_WAIVER` (hook-pre-bash.sh:63-69, hook-pre-write.sh:54-63) is retired. One more fact makes this urgent: the Hard Rule `.ai/AGENTS.md:112` "No code in Ground Truth | Hook-enforced" is carried by build.rs into every scaffold (rudra `.ai/AGENTS.md:58`), and until now it has been false in every project.

rec 1 — Move the ground-truth part into ONE shared script, `scripts/hook-ground-truth-guard.sh`. Ship it as `.ai/hooks/hook-ground-truth-guard.sh`. Do not ship the two whole hooks.
- It holds hook-pre-bash.sh:43-91 and hook-pre-write.sh:42-138 (the allowlist and the S191 outside-the-project pass), moved unchanged. It picks the Bash check or the path check from `tool_name`.
- Vajra's `hook-pre-bash.sh` and `hook-pre-write.sh` call it right after the approvals guard, the same way they call that guard now (`printf '%s' "$INPUT" | bash "$_GG" || exit $?`, as at :35-41).
- Projects: add it to SYNC_HOOKS next to the approvals guard (init.rs:32-35), with an `include_str!` const (as at init.rs:2303). It must stay fill-free (init.rs:18-20). Wire it as a second entry in the template's `Bash|Edit|Write|MultiEdit|NotebookEdit` PreToolUse group (init.rs:2219-2227). The S186 partial-group merge (init.rs:1284-1324) then adds it to existing projects.
- Do not wire it in any Post group. It exits 0 on `PostToolUse*` events.
- Why: there is one copy of the code. The approvals guard runs once in each place (Vajra calls it from hook-pre-*, projects through settings). Shipping the whole hooks would run the approvals guard twice in projects and bring Vajra-only warnings along.

rec 2 — The record is `.ai/approvals/session-NN-close.json` with `{"session": NN, "method": "close-command", "at_unix": …}`. It is written by `vajra approve NN --close`, which has the same refusals as plain approve (mod.rs:285-299).
- It un-lists only its own name, as `record_launch_env` does (mod.rs:318-323).
- `vajra approve MM` must never un-list it. Today that holds because `session_of("session-197-close.json")` returns None (mod.rs:196-201). Pin it with a test.
- The S188 check already watches the whole folder (hook-approvals-guard.sh:78-112, 153-169), so a forged file is caught and voided with no new code.
- The close record is not an approval of the session, and an approval of the session does not open the guard.

rec 3 — The hook asks the binary: `vajra next --check-close-record NN`. Exit 0 means the record counts; exit 1 means it does not, and it prints why.
- It reads the record with the same rules `approved()` uses (mod.rs:224-243, `is_void` :134-140): name compared lower-case, a void file it cannot read means closed.
- At L2/L3, these all mean closed: no `vajra` on PATH, an older binary that does not know the flag, or any other error. The message says "update vajra / founder: `vajra approve NN --close`".
- Rejected: a jq copy of the void reader. That is two readers of one format, and the S188 subtleties (lower-casing, unreadable means void) would drift apart.

rec 4 — Open by session number, never by branch name. Remove `*-closeout|*-enforcement` everywhere: hook-pre-bash.sh:53-54, hook-pre-write.sh:43-44, hook-session-start.sh:103-104 and hook-prompt-submit.sh:20-21.
- `-enforcement` gets the same treatment: "authorized hardening" during a ground truth now means the founder's record.
- Rewrite AGENTS.md:100 and the :112 rule text: "Hook-enforced; opens only with the founder's `vajra approve NN --close`". The :112 row goes through build.rs, so check its retext rules.
- When the record counts, session-start says so instead of skipping silently.

rec 5 — Retire `VAJRA_GT_WAIVER`. The founder said the record is "the only way". Running `vajra approve NN --close` at session start does the same job without a relaunch. Removing it only adds blocks, so S173's rule is kept.

rec 6 — N17: when the branch has no `session-NN`, use the **committed** `.ai/SESSION` at HEAD plus one (`git show HEAD:.ai/SESSION`). If HEAD has no such file, read the working-tree file. If neither can be read, the guard is on.
- During a ground truth the agent cannot commit, so it cannot move HEAD's counter. The working-tree file it could edit, because `.ai/*` is allowlisted.
- Do not use the bare `.ai/SESSION`. It holds the previous session until `--advance`, and `--steps` falls back to it unchanged (next.rs:452-465, 496-497). That is fine for advice but would give the wrong session here.

rec 7 — Name the wrong-number lie and do not fix it now. A branch like `session-196-x` during ground truth 195 still reads as not a ground truth.
- The fix (also check HEAD's counter on numbered branches) would block falsely wherever `.ai/SESSION` lags (S171: rudra's lagged; F118). That is a scope and ceremony cost.
- With the suffix rule gone from AGENTS.md, the conventional route that caught rudra S20 is closed.

rec 8 — Keep the write allowlist exactly as it is (hook-pre-write.sh:127) and confirm the ground-truth flow:
- The agent writes `sessions/session-NN-ground-truth.md`, `.ai/` notes, the review and outside-the-project scratch.
- These stay blocked until the record: `src/`, `prompts/`, the session summary, and every commit, push and PR.
- Order: report → founder reads it → `vajra approve NN --close` → summary, next prompt, commits, stamp → close → push. This is AGENTS.md:98's "User signs off before code resumes", now as a record.
- Vajra's habit of using `-closeout` from the first command just stops mattering.
- No allowlist loosening this session. Adding the summary to it would need the S186 class argument.

rec 9 — No new row in the close gate (`verify-closeout-scaffold.sh`): the founder ruled out policing Vajra's own paperwork. The push belt is unchanged. It still requires GREEN on `session-NN` branches after the record, and non-session branches stay ungoverned there (founder, 2026-09-21). During a ground truth they are now covered by rec 6 instead.
- L1 warns, L2/L3 block, and the jq preflight stays as in hook-approvals-guard.sh:28-32.
- The guard reads maturity with the `VAJRA_GUARD_MATURITY` override (hook-approvals-guard.sh:24), so tests can drive it.
- The project's commit guard stacks on top. `--allow-all` and `VAJRA_APPROVE` do not open a ground truth.

rec 10 — On a ground-truth session, `--steps` gets one step: "the founder signed off the report (`vajra approve NN --close`)". F116's "not in git" note should also name the close record.

rec 11 — AC1 proof in a temp `vajra init` project, each case red at eceb6d5:
- On a `-closeout` branch with no record, commit, push and `gh pr create` are blocked.
- With the record, they pass.
- A record forged through Bash is voided, and commits are still blocked.
- On a branch with no number and HEAD's `.ai/SESSION` = N−1, commits are blocked.
- A write to `src/` is blocked; a write to the report is allowed.
- `--sync-fleet` wires the entry into an existing `settings.json`.

rec 12 — F116, F119 and N10 need no further design. F116 and F119 are already in progress at nextstep/mod.rs:100-115 and :138-148/:286-289.
- F116 follows DECISION-011 §2 and the S187 step.
- F119 reuses `architect::design_gate` (one reader, DECISION-007's step list).
- N10 follows S195 design-advisor rec 5. No record covers check 6 (it came from S163), so say "no record covers this yet".

---

### Proposed addendum text

## S197 addendum — the review-only guard reaches every project, and only the founder opens it (2026-10-14)

**Deviates from** the S191 addendum §1 ("`vajra init` ships no copy") and `.ai/AGENTS.md`'s "exempt by suffix" line. **Retires** the S134 `VAJRA_GT_WAIVER`. **Follows** decision 2 and the S188 addendum. Founder's call, 2026-10-14, after F125: user projects never had the ground-truth guard, yet every scaffold's Hard Rules said "No code in Ground Truth — Hook-enforced".

1. **One guard, one source.** `scripts/hook-ground-truth-guard.sh` holds the ground-truth checks of `hook-pre-bash.sh` (commit, push, PR, rebase and other git state changes) and of `hook-pre-write.sh` (the allowlist and the S191 outside-the-project pass), unchanged. Vajra's two hooks call it after the approvals guard. `vajra init` ships the same bytes as `.ai/hooks/hook-ground-truth-guard.sh` in the PreToolUse `Bash|Edit|Write|MultiEdit|NotebookEdit` group, and `--sync-fleet` adds it through the S182 add-only merge.
2. **The opening is a founder record.** `vajra approve NN --close` writes `.ai/approvals/session-NN-close.json`. It is refused where `vajra approve` is refused. The guard asks `vajra next --check-close-record NN`, which reads the record the way an approval is read: listed in the S188 void means not counted, and a void it cannot read means closed. A missing binary or any error also means closed. The founder's sign-off before code resumes, until now a word in chat, is now a file.
3. **A branch name opens nothing.** The `-closeout` and `-enforcement` exemptions are gone from every hook. A ground-truth session number stays guarded until its record counts.
4. **No number in the branch (N17).** The guard uses HEAD's committed `.ai/SESSION` plus one. Commits are blocked, so the agent cannot move it. If it cannot be read, the guard is on.
5. **Unchanged:** L1 warns and L2/L3 block; the write allowlist; the close gate (no new row); the push belt.

**Rejected:**
- The report being on disk, or committed: the agent writes it, and the commit is the thing that is blocked.
- Shipping the two whole hooks: the approvals guard would run twice, and Vajra-only warnings would come along.
- A jq copy of the void reader: two readers of one format.
- Keeping `VAJRA_GT_WAIVER`: a second way to open the guard, and it needs a relaunch.

**Limit — bar-raising, not tamper-proof. Named, not closed:**
- A branch carrying the wrong number (`session-196-x` during ground truth 195) is not seen as a ground truth.
- The Bash check reads command text, so a spelling it does not match (`g=git; $g commit`) gets through. The push belt still checks pushes of `session-NN` branches.
- Bash can still write any file (S191 §1). `.ai/hooks/` and `scripts/` are on the Write allowlist, so the agent can edit the guard itself, or replace the `vajra` binary on PATH.
- A forged record written between two watched tool calls (a background job) looks like the founder's (the S188 limit).
- A branch with no number cut from an older commit takes that commit's number.
- The guard runs only from the next Claude Code launch after `--sync-fleet`.

Files: /Users/suman/playground/vajra/scripts/hook-pre-bash.sh, /Users/suman/playground/vajra/scripts/hook-pre-write.sh, /Users/suman/playground/vajra/scripts/hook-approvals-guard.sh, /Users/suman/playground/vajra/scripts/hook-session-start.sh, /Users/suman/playground/vajra/src/approval/mod.rs, /Users/suman/playground/vajra/src/cli/init.rs, /Users/suman/playground/vajra/src/cli/next.rs, /Users/suman/playground/vajra/.ai/AGENTS.md, /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md

## Handoff Delta
- `+` new: first design-advisor handoff for this session (11518 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
