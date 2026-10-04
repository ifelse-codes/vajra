---
role: design-advisor
session: 186
agent: claude-code-subagent (verified: toolu_01EYa9QkLfkbkBdtEFFVDpcg; text-sha: d504921db12ce427bfc2acb08c62365195bc274b9535f9bcf00bf11b2d84cf6b)
source-sha: df321f1003d7ebc8bf9e9b3360b77e7549cdb27f0711312f59817a996a79a3aa
captured: 2026-10-04T08:51:07Z
cost_usd: null
---

# Design-advisor handoff — session 186

Design-advisor brief, S186 (fixes from S185). I checked the picks against the code; I did not reopen them.

Note first: the working tree changed while I was reading it. F113 and F115 are already partly built: `src/obeyed/mod.rs:79-108, 477-579`, `.ai/CONSTRAINTS.yaml:22`, `scripts/verify-session-132.sh:92, 246-260, 329, 353-396`. Where it matters, I checked that in-progress code too. Line numbers below are for the working tree as I read it.

rec 1 — F113: one strict reader, with its error pushed into `reasons` every time the gate runs, not only when an unjudged claim exists.
The working tree already does this (`obeyed/mod.rs:477-483`), so `--check-obeyed`, `--advance` and the close row all block on a bad key. Keep it. A broken switch should show up at the next close, not wait for the first unchecked claim. Do not copy `approval::rules_from` (`src/approval/mod.rs:36-40`): it skips a line that is not a number without saying anything, which is the quiet default this key must not have.

rec 2 — In the reader, only a missing file means "no key". Any other read error should block.
`obeyed/mod.rs:85` uses `read_to_string(...).unwrap_or_default()`. A `.ai/CONSTRAINTS.yaml` that exists but cannot be read (permissions, a non-UTF-8 byte) quietly becomes "no key", and Vajra's own repo stops blocking. Match on `ErrorKind::NotFound` → `Ok(None)`; any other error → `Err` naming the file.

rec 3 — When the key is malformed, the words must not claim "no key".
At `obeyed/mod.rs:561-565`, an `Err` sets `blocks_from = None`, so the summary line says "(no `obeyed_blocks_from:` in .ai/CONSTRAINTS.yaml)". That is false: the key is there, it just can't be read. Give the summary a third wording ("`obeyed_blocks_from:` could not be read — see the blocking reason"). Also widen two other texts so they cover this case: the `[vajra obeyed]` heading and refusal (`src/cli/next.rs:1717, :1729`) and the close log's BLOCK/FAIL lines (`scripts/verify-closeout.sh:775-780`, plus the scaffold copy). Today they only say "unjudged / mismatch".

rec 4 — Removing the constant breaks no compiled caller. It does break scripts that use a fixture with no key, and the words have hard limits.
- **Compiled code:** the only code use was `obeyed/mod.rs:499`. The unit tests call `classify`, not `obeyed_gate`. The doc comments at `src/mandate/mod.rs:62` and `src/cli/next.rs:957` are already updated in the working tree.
- **Scripts:** any fixture with no CONSTRAINTS file now WARNs where it used to block. That hits verify-132 checks 1 and 7 (already reworked: `:92`, `:329`) and `scripts/demo-session-132.sh:103, :177`, which still expect a block from a keyless fixture. That demo goes red; fix it or say so in writing.
- **Words:** keep the phrases "names them but does not block on them" and "warning, not blocking". `scripts/verify-session-184.sh:84` and verify-132 `:293` grep for them. The no-key wording must not contain "132" or "threshold" (`verify-session-184.sh:80-81`). The working-tree text meets all of this.

rec 5 — `src/mandate/mod.rs:428`: delete only "(threshold {from_session})". Keep "predates the design-advisor mandate", and update verify-133 in the same commit.
Four scripts grep that prefix: `scripts/verify-closeout.sh` (the "predates the design-advisor mandate" branch), `verify-closeout-scaffold.sh:750`, `verify-session-134.sh:226` and `demo-session-134.sh:97`. `scripts/verify-session-133.sh:358` greps the full old text, and `:544` patches the exact old source string, failing with "PROBE FAIL: the bypass target is not present" when it is gone. Both go red unless updated.

rec 6 — F110(b): decide "is this a redirect, and does it have a next word?" on the de-quoted copy. Take the target text from the original command, at the same `>` position, and block if that text holds `"`, `'` or `\`.
`NAMED` (`hook-approvals-guard.sh:58`) deletes quotes and backslashes. That merges or splits words. `echo x > "a b/../../.ai/approvals/y"` (or `> a\ b/...`) de-quotes to the target `a`, which would pass while the shell really writes into the folder (if `a b/` exists, which the agent can create). `tr -d` deletes no `>` character, so the k-th `>` in `NAMED` is exactly the k-th `>` in `CMD`. The AC2 commit-message case (`<noreply@x>"` with nothing after it) is settled as "not a redirect" on the de-quoted copy and never reaches the original-text check, so it still passes.

rec 7 — Check every component of the raw target path for a symlink before collapsing `..`, and check the last component too. Resolve `cwd` and `$ROOT` with `cd -P`/`pwd -P`. A missing or empty `.cwd` blocks.
If `..` is collapsed first, `link/../y` (with `link` pointing to `.ai/approvals/sub`) reads as `./y` and passes. The brief only says "a symlink in the target's parent path", which misses a target that is itself a symlink: `cat .ai/approvals/x > notes.md`, with `notes.md` linked into the folder, passes under (b) but blocks today. That would break AC3 for a real write. A hard link to an approval file (link count above 1) is the same case; one `stat` covers it.

rec 8 — Do not skip heredoc bodies or quoted strings to get AC2 green. Read them as commands, so the worst outcome is an over-block (S173).
A quote-aware scanner would be wrong here. One apostrophe in a heredoc body ("don't") flips the quote state, and a later real `> .ai/approvals/y` becomes "inside quotes" and passes. The de-quoted scan treats every `>` as a possible redirect, which errs in the safe direction. A body line like `> quote` resolves to a harmless literal and passes.

rec 9 — Rec 5's new writers and interpreters must match only at command position, never as a bare `\bword\b`.
`\bsh\b` matches every `*.sh` file name: `.` followed by `sh` is a word boundary. `\bsource\b`, `\bpatch\b` and `\btar\b` match ordinary prose. With bare matching, AC2's heredoc and commit-message cases fail as soon as they mention `hook-approvals-guard.sh` or "one source". Command position means start of the command, or after `;`, `&`, `|`, `(`, a backtick, `$(`, a newline, `xargs`, `env …`, `exec`, `command`, `nohup`, `sudo` or `time`; `find … -exec/-execdir/-delete` gets its own rule. This keeps the guard add-only: the S182 words at `:79` and `:83` stay exactly as they are. Put a commit message naming `hook-approvals-guard.sh` and "source" in the AC2 corpus.

rec 10 — Write the guard for bash 3.2 and BSD tools only: no `${x,,}`, `realpath`, `readlink -f` or associative arrays.
`vajra init` ships these exact bytes to every project (`src/cli/init.rs:1929`), and macOS's `/usr/bin/env bash` is 3.2. The existing `tr '[:upper:]' '[:lower:]'` approach is the right one.

rec 11 — S182 rec 2 is still open at HEAD, but the fix must not be the literal "never a hook already wired under another matcher". Count a hook as wired only when a group whose matcher covers all of this group's tools already runs it.
The exact duplicate condition, at `init.rs:982-988`, is `same_matcher.is_none() && !all_missing` (and the group was not already skipped as present). Line 988 then pushes the whole template group, including hooks already wired under a different matcher. The literal fix causes a regression: the template wires `hook-copilot-loader.sh` under both `Bash` and `Edit|Write|MultiEdit` (`init.rs:1844, :1865`). In a project with the loader only under `Edit|Write|MultiEdit`, the loader would never be added for Bash. To compare matchers, split each matcher on `|` into tool names; absent, `""` or `"*"` means all tools; any other regex character means "unknown, not a cover", which errs toward adding the hook. Push `{matcher: G.matcher, hooks: missing}`. Optionally apply the same cover rule in `group_already_present` (`init.rs:1003-1012`): it currently treats a hook as present if it is wired anywhere in the event, which is the same under-wiring. AC5 fixture: `PreToolUse: [{matcher:"Bash|Edit|Write|MultiEdit", hooks:[copilot-loader]}]`. Today this duplicates the loader for Bash, and that goes red at both e1c348e and HEAD.

rec 12 — N1: all four lines already send their message to stderr at HEAD, and neither hook ships to projects. Build the AC8 test first, and do not record N1 as "fixed" by an edit.
`hook-pre-bash.sh:39, :77` and `hook-pre-write.sh:38, :72` all end in `>&2`. Neither file is in the `include_str!` list (`init.rs:1888-1938`), so they are Vajra-only and the brief's "and their scaffold copies" refers to nothing. Every scaffolded guard (commit, publish and session guards) already prints its block message inside `{ … } 1>&2`. Run `git blame` on those lines. If AC8 passes with no change, record N1 as "already on stderr at <blame sha>; the S185 evidence line was wrong", or find what really produced "No stderr output". A label is not a fix.

rec 13 — F115: a `tech-lead: skipped — <reason>` line is not an option. Record a real, verified tech-lead handoff.
`src/crew/mod.rs:311-318` refuses the skip (test at `:748`), and the crew gate has no skip variable (`next.rs:1702`). The working-tree fixture (`verify-session-132.sh:353-359`, all roles `deferred-budget`) already does it right. Remove "(or a `tech-lead: skipped …`)" from the brief.

rec 14 — Fix the citation. DECISION-007 has no S132 clause. Name the deviation against the S133 addendum §6 and the S134 addendum's rejected option 1.
The threshold was decided in the S132 prompt's `## Design` Q2 (`obeyed/mod.rs:72`). DECISION-007 records it only as "the S132 precedent" (`DECISION-007-agent-fleet.md:913`). The S134 addendum (`:986-992`) rejected exactly this kind of switch: a per-project marker in `.ai/` that the agent can edit. F113 reverses that rejection for the obeyed gate only. The reason is the direction: with no key nothing blocks, which is the founder's 2026-10-03 rule for projects. The honest limit: an opted-in repo, Vajra included, can opt itself out by deleting or raising the key, and only the diff shows it. That is the same weakest point as `lint_command: none` (DECISION-011 `:131-132`). The latest DECISION-007 addendum is S177 (`:1653`); write S186 after it.

rec 15 — Add an S186 addendum to DECISION-011 that follows its strict-key rule for F113 and records two reversals from its S182 addendum.
- **Follows** `:101-103`: one strict field, read by exact key.
- **Reversal 1, §2 (`:73-78`):** "block on any redirect left" becomes "block on a redirect that resolves into the folder or cannot be resolved". The sentence "Over-block kept: `cat <folder>/x > /tmp/y` still blocks" (`:77-78`) is now false; that command passes.
- **Reversal 2, `:92`:** the claim "`--sync-fleet` never lists a hook twice" is false at HEAD (rec 11). Correct it.
- **Unchanged limit:** a path built at run time or a glob still gets past (`:94-95`).

---

Proposed `## Design` block (the session author records the real one):

```
## Design
design-significant: yes
- Why yes: a new `.ai/CONSTRAINTS.yaml` key (`obeyed_blocks_from:`) changes when the Obeyed gate
  blocks in every project; the approvals guard changes what it blocks; `--sync-fleet`'s merge
  changes its output. Two locked records are deviated from (below).
- Cites docs/decisions/DECISION-011-controls-the-agent-cannot-type.md — FOLLOWS its S183 rule (a
  project switch is one strict CONSTRAINTS field read by exact key, never derived). S186 addendum
  there AMENDS the S182 addendum: §2 "block on any redirect left" becomes "block on a redirect
  that resolves into .ai/approvals or cannot be resolved", and its "over-block kept: `cat
  <folder>/x > /tmp/y`" sentence is REVERSED (it now passes); its "never lists a hook twice" claim
  is corrected (false at e1c348e when a hook is wired under a covering matcher).
- Cites docs/decisions/DECISION-007-agent-fleet.md — DEVIATES from the S133 addendum §6 (the
  S132 precedent: one built-in session-number threshold for every project) and REVERSES the S134
  addendum's rejection of a per-project `.ai/` marker, for the Obeyed gate only: absent key =
  never blocks (founder 2026-10-03: obeyed claims are not a blocking gate for projects); only
  Vajra's own file declares 132; `vajra init` never writes it. Honest limit: a repo that opted
  in can opt out by editing the key, visible only in the diff (the `lint_command: none` class).
  The design-advisor threshold (133) is not changed; only its printed words drop the number.
- F113 reader: absent file → no key; one line → N; empty / not a number / twice / unreadable file
  → a blocking reason naming the line. The reason is pushed whatever the session holds, so a typo
  surfaces at the next close, not at the first unchecked claim.
- F110 (b): the redirect is decided on the de-quoted copy; its target is read from the original
  command at the same `>` position (quotes and backslashes in it → block). Literal targets are
  resolved against the hook input's physical `cwd` after a symlink check on every raw path
  component including the last; `..` collapsed only after that. Anything on the fail-closed list
  blocks as today, with (a)'s message. Heredoc bodies and quoted strings are scanned, never
  skipped (S173). New writer/interpreter words match at command position only; the S182 words
  are unchanged, so the change only adds (AC3 corpus vs e1c348e).
- Rec 2 merge: a hook counts as wired only under a group whose matcher covers every tool of the
  template group's matcher; the pushed group carries only the missing hooks.
- Rejected: keeping the constant and detecting Vajra's own repo (text guessing, S177/S184);
  scaffolding `obeyed_blocks_from: 1` (breaks the founder's project rule); git-birth-date
  (S134 option 2: a git call per gate, dies in a shallow clone); a lenient reader like
  `rules_from` (quiet default); a quote-aware shell tokenizer (one apostrophe in a heredoc flips
  its state and hides a later real redirect); stripping heredoc bodies (hides text from the
  guard); `realpath` (not in bash 3.2 / older macOS); "never add a hook wired under any other
  matcher" (drops the co-pilot loader from Bash in a project wired only for Edit).
```

## Handoff Delta
- `+` new: first design-advisor handoff for this session (14066 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
