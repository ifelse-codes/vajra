---
role: design-advisor
session: 187
agent: claude-code-subagent (verified: toolu_01BnjkxEh7xPmE2fSEqcu4qf; text-sha: 064dfe1adcc2fc075f7aa441d3577a8e37c0bb825915f4cef29e327a3adeac64)
source-sha: d50f58dc05afe9bdf80bb3fc0ecb18ad4e2f101949b56b11b22d83ee8ea5b2a5
captured: 2026-10-04T18:31:13Z
cost_usd: null
---

# Design-advisor handoff — session 187

Design-advisor brief: Session 187 (two questions only: F97/AC4 and N2/AC2)

Sources read: prompts/187-task-guard-message-and-leftovers.md, .ai/handoffs/session-187-tech-lead.md, docs/decisions/DECISION-007-agent-fleet.md (S136, S141–S143, S175–S186 addenda), docs/decisions/DECISION-011-controls-the-agent-cannot-type.md (whole), src/cli/init.rs (SYNC_HOOKS ~21, sync_targets ~340, sync_fleet ~426, the S182 block ~572, TPL_CONSTRAINTS ~1662, TPL_CLAUDE_SETTINGS ~1836, the test ~4036), build.rs (render_ground_truth, OMIT_AUDITS), .ai/CONSTRAINTS.yaml (ground_truth block), scripts/hook-pre-write.sh, plus greps of scripts/hook-pre-bash.sh and of every reader of `required_audits`.

## Marker
`design-significant: yes` is correct. The session reverses a locked record (DECISION-007's "Out permanently: CONSTRAINTS.yaml"), and it loosens a guard (the AC2 let-through). Both are design changes. Neither is a pure fix.

## Where the rule lives (question a)
- The "never touches CONSTRAINTS.yaml" rule comes from **DECISION-007**. The S142 addendum says "Out permanently: `CONSTRAINTS.yaml`" (around line 1218) and the S143 addendum repeats it (around line 1309). The `sync_targets` doc comment in init.rs cites S143.
- S179 did not make this rule. It only logged it as finding F97 (prompts/179-task-keep-testing.md:73). The prompt's phrase "Reverses S179's …" names the wrong source.
- **DECISION-011** says the same thing twice more, and both sentences become false after this session:
  - S182 §4: "The project's `.ai/CONSTRAINTS.yaml` is never written."
  - S183 §3: "Vajra never edits their CONSTRAINTS."
- init.rs:587 prints "(Vajra never edits this file)" to users. That also becomes false.

## Proposed `## Design` text (real rationale; the author records it)

design-significant: yes
- AC4 narrowly reverses DECISION-007's S142/S143 addenda ("Out permanently: CONSTRAINTS.yaml", logged as F97 at S179). It is recorded as a DECISION-007 S187 addendum. The DECISION-011 S182 §4 and S183 §3 wording is amended to match. `--sync-fleet` may do two things and nothing else:
  - add missing audit names to the one `ground_truth.required_audits:` line, keeping the project's entries in their order and with their exact bytes;
  - insert whole missing `<audit>_questions:` blocks inside `ground_truth:`.
- It never creates the file, never round-trips it through a YAML parser, and never writes a key a gate reads (`session_rules_from`, `ground_truth_next_session`, `obeyed_blocks_from`, `maturity`, `lint_command`). Those stay report-only, as decided in S182.
- AC2 loosens a guard. Per DECISION-011's S186 lesson ("loosening a text guard is a REMOVAL; it needs a class-level argument"), the argument is recorded as a DECISION-011 S187 addendum. The Write tool targets one absolute path. The guard resolves that path the same way the kernel will: parent with `cd -P`, root with `cd -P`, and the leaf checked for being a symlink or a hard link. Only "provably outside" passes. "Inside" and "can't tell" both block.
- Rejected alternatives:
  - Append the missing names at the end of the line. delivery_progress, the audit F97 exists for, would land behind the workflow audits and undo S179's project-first order.
  - Add a second key such as `required_audits_added:`. No reader knows that key, and it creates two lists that will drift apart.
  - Add a second `required_audits:` line. That is a duplicate YAML key, and every `grep -m1` reader sees only the first line.
  - Parse and re-write the file as YAML. That drops the project's comments and reorders its keys.
  - For AC2, resolve the nearest folder that exists. If the not-yet-existing rest of the path contains `..`, it leads back into the project once Write creates the folder.

## Proposed DECISION-007 S187 addendum wording (core)
"Narrowly reverses the S142/S143 'Out permanently: CONSTRAINTS.yaml'.
1. Sync adds to `ground_truth.required_audits` the carried audits the line lacks. 'Carried' means the build-derived scaffold list, with OMIT_AUDITS excluded. Only that one line is rewritten. The project's entries keep their bytes and their order. Each missing name goes right after the nearest audit that comes before it in the canonical list and is present in the line; if none is present, it goes before the first entry. Deleting the added names gives back the original line byte for byte.
2. Each missing `<audit>_questions:` block is inserted whole, as a pure line insertion inside `ground_truth:`. It goes after the block of the audit before it in canonical order, or else after the block's last line.
3. Sync prints what it added. `--dry-run` prints the same list and writes nothing. A second run adds nothing.
4. If sync does not recognise the shape (a block-style list, two `required_audits:` lines, no `ground_truth:`, a missing `]`), it prints the line to add and writes nothing.
'A write could switch a running session mid-way' (S182) does not apply here: no gate reads these lines. Limit: sync cannot tell an audit a project removed on purpose from one it never had (S136), so a removed audit comes back, and the output says so."

## Mid-session risk (question a, last part)
The risk does **not** apply to audits. The S182 worry held for `session_rules_from`, which decides which rules a session follows. I grepped for readers of `required_audits` and `_questions`. In a project, no hook, close gate or src reader parses them; only the agent reads them, at boot. The readers that do exist are Vajra-only (`stranger-check.sh`, `scaffold-drift.sh`) plus tests. So adding an audit while a ground truth is running changes what a re-read shows, but it cannot flip a gate.

To keep it that way, the writer must never touch any line outside `ground_truth:`. The verify check should prove that byte for byte.

## Question b — does the AC2 argument hold?
Yes, if the holes below are closed. The most important finding first:

**No scaffold copy of hook-pre-write.sh exists.** `SYNC_HOOKS` (init.rs:21) and `TPL_CLAUDE_SETTINGS` (init.rs:1882–1897) wire only `hook-copilot-loader.sh` and `hook-approvals-guard.sh` on Edit/Write. Projects have no ground-truth write guard at all. N2 is a change to Vajra's own guard only.

Holes, each with its fix:
1. **The root is a symlink.** If ROOT is not resolved with `cd -P`, every write inside the project, written via its physical path, looks "outside" and passes. On macOS `/var` points to `/private/var`, so `mktemp` fixtures hit this. This one fails open.
2. **The leaf.** `cd -P` on the parent never looks at the file itself. A file in `/tmp` that is a symlink, or a hard link, into the project passes, and Write follows it into the project.
3. **Relative paths and the hook's cwd.** Resolving a relative path against the hook's own working folder may pick a different folder than the tool uses. Only absolute paths should earn the pass.
4. **`..`.** Fine when the parent folder exists, because `cd -P` resolves it physically. Unsafe in a folder that does not exist yet, which is why the founder's "can't resolve → block" is right.
5. **Case on macOS.** The disk ignores case, and `pwd -P` may keep the case as typed. Comparing case-folded is safe because it can only add blocks.
6. **/tmp vs /private/tmp.** Fine once both sides are resolved physically.
7. **`set -e` exit 1.** A failed `$(cd …)` can make the hook exit 1. Claude Code does not treat exit 1 as a block, so the write would go through (S186 saw this).
8. **Prefix compare.** Without a `/` boundary, a sibling folder such as `proj2` counts as inside. That only over-blocks, but it breaks the AC2 fixture.
9. **Control characters.** A newline in the path can be stripped by `$(…)`.
10. **Already open today:** the allowlist matches the raw string, so `/proj/.ai/../src/x.rs` matches `*/.ai/*` and is let through.

Context for the disclosure: in a ground truth, Bash blocks only commit, push and PR (hook-pre-bash.sh:71). `cp` or `sed -i` from Bash already writes into the project. The let-through adds no path Bash does not already have.

## Recommendations

rec 1 — Record the F97 reversal as a DECISION-007 "S187 addendum" narrowing the S142/S143 "Out permanently: CONSTRAINTS.yaml", and fix the prompt's attribution (S179 only logged it as F97).
That is where the rule lives and what init.rs cites. Citing DECISION-007 alone would pass the Architect gate while the design goes against it, so the addendum is the lock.

rec 2 — In the same commit, correct the sentences that become false: DECISION-011 S182 §4 and S183 §3, the `sync_targets` doc comment, and the printed "(Vajra never edits this file)" at init.rs:587.
That is three files (DECISION-007, DECISION-011, src/cli/init.rs including the renamed test), which matches tech-lead rec 5 and the 3-files-per-commit cap. Leaving "never edits" in user-facing output after this session would be a false claim.

rec 3 — Keep `session_rules_from` and every other key a gate reads report-only. The reversal covers adding audit names and whole missing question blocks inside `ground_truth:`, nothing else.
The S182 reason ("a write could switch a running session mid-way") still holds for those keys.

rec 4 — Change only the one `required_audits:` flow line. Keep the project's entries byte-identical and in their order. Put each missing audit after its nearest canonical predecessor that is in the line (or before the first entry if it has none). Keep a trailing `# comment`. For any shape sync does not recognise, print the line to add and write nothing.
This keeps S179's project-first order (delivery_progress lands after roadmap_alignment), and the edit can be undone exactly.

rec 5 — Reword AC4 (founder's okay in chat): "every original line byte-identical except the one `required_audits:` line, which equals the original once the added names are removed". Check exactly that.
As written, AC4 can never pass whenever an audit is missing: a one-line flow list cannot grow without changing that line.

rec 6 — Insert missing question blocks whole, as pure line insertions inside the `ground_truth:` block. Never append them at the end of the file. Never rewrite a block that already exists.
At end of file, lines indented two spaces would belong to `copilot:`. Leaving existing blocks alone keeps "add-only" true, but it means F99's stale wording stays. Name that as a limit.

rec 7 — Take the canonical audit list and blocks from the build-derived `scaffold_ground_truth.yaml` (OMIT_AUDITS already removed), not from Vajra's live CONSTRAINTS.
One source (S129). Otherwise Vajra-only audits like dogfood_check would be pushed into projects.

rec 8 — Edit as text, never parse and re-write as YAML. Never create a missing CONSTRAINTS.yaml (keep the test's `unwanted` assertion). `--dry-run` writes nothing and prints the same additions. A second run adds nothing.
A YAML round-trip drops the project's comments and reorders its keys. The existing test fixture has no CONSTRAINTS.yaml, and it must stay absent after sync.

rec 9 — Disclose the re-add limit in the addendum and in sync's output: an audit a project removed on purpose comes back. Carry a strict opt-out key to S188 by name rather than build it now.
"Missing" cannot tell "never had" from "deleted on purpose" by looking at the file (S136). Disclosing it is honest, and building the key would grow this session's scope.

rec 10 — State in the addendum, with the grep as evidence, that no gate in a project reads `required_audits` or `*_questions`. Have verify-187 prove that every line outside `ground_truth:` is byte-identical.
That is why the mid-session risk does not apply. The byte check proves no key a gate reads can move.

rec 11 — Answer the scaffold half of tech-lead rec 2 as "no scaffold copy exists": hook-pre-write.sh is not in SYNC_HOOKS or TPL_CLAUDE_SETTINGS. Do not add a project ground-truth write guard this session.
A new guard in projects would be a new block, outside the founder's picks.

rec 12 — Resolve ROOT physically too (`cd -P "$ROOT" && pwd -P`), and block if that fails.
Without it, a symlinked project path (macOS `/var` → `/private/var`, a symlinked `~/playground`) makes every write inside the project look outside. That fails open.

rec 13 — Let only absolute paths earn the pass. Block when the path is empty, relative, contains a control character or newline, or ends in `.` or `..`.
Resolving against the hook's own cwd may not match the tool's, and `$(…)` strips trailing newlines.

rec 14 — If the leaf exists and is a symlink (`[ -L ]`) or has more than one hard link (`find "$f" -links +1`, which works on bash 3.2 and BSD), block.
`cd -P` on the parent never sees the leaf, and Write writes through both kinds of link.

rec 15 — Compare with a folder boundary and with case folded on both sides. Pass only when the folded path is neither the folded ROOT nor under the folded ROOT plus `/`.
Folding can only turn "outside" into "inside" (more blocks), and it covers macOS's case-insensitive disk. The `/` boundary stops sibling folders like `proj2` from counting as inside.

rec 16 — Make every resolution step survive `set -euo pipefail`: `X=$(CDPATH= cd -P -- "$d" 2>/dev/null && pwd -P) || X=""`. The fixtures should assert exit status exactly 2.
Exit 1 does not block in Claude Code (S186 saw this), so a crash would let the write through.

rec 17 — Put the outside-pass only inside the `GT_PW=1` branch, after the approvals-guard call. Keep today's allowlist match for inside paths. Also block any path with a `..` segment before the allowlist runs, or carry that fix to S188 by name.
The approvals guard must never be skipped. `/proj/.ai/../src/x.rs` matching `*/.ai/*` is an existing hole, and closing it only adds blocks (S173).

rec 18 — Keep "a folder that does not exist yet blocks", and have the block reason name the way past: create the folder first, in Bash, then write.
Resolving the nearest existing folder is unsafe when the rest of the path contains `..`. The message keeps the false block cheap, in the same spirit as item 1.

rec 19 — AC2 fixtures, expected red at 0071dca where it applies:
- outside, in /tmp: passes;
- ROOT given via `/var` and the file via `/private/var`, and the reverse: blocks;
- sibling `proj2`: passes;
- inside path with changed case: blocks;
- leaf symlink into the project, hard link, `..` path, relative path, new folder: all block.
Each case covers a hole named above. The red-at-start case is "outside blocks".

rec 20 — Record the AC2 argument and its limit in a DECISION-011 S187 addendum: the Write guard is a speed bump, not a sandbox. In a ground truth, Bash blocks only commit, push and PR, and parallel tool calls leave a check-then-write gap.
S186 requires a class-level argument for any loosening. Saying the let-through adds no path Bash lacks keeps the claim honest.

## Handoff Delta
- `+` new: first design-advisor handoff for session 187 (20 numbered recs)
- prior stage: .ai/handoffs/session-187-tech-lead.md. This answers its two scoped questions and corrects the scaffold half of its rec 2.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (15057 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
