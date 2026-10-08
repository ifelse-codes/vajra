---
role: fidelity-reviewer
session: 191
agent: claude-code-subagent (verified: toolu_01YPHqE3rVbK3syaMwdkMfQj; text-sha: 66d5faf07988ba954e165baa746db17eae1a78b6a20c803afa4530cee01e35f4)
source-sha: d248ed8dc8194a9aa7e1f9f783ae0e2ba520fe762d66808c2d7da5bb95ae585b
captured: 2026-10-08T15:02:22Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 191

## Session 191 fidelity review (cold, adversarial)

**What I reviewed:** I read `/Users/suman/playground/vajra/reviewer/SKILL.md` and the contract `prompts/191-task-small-fixes.md` (D1–D4, AC1–AC5). I then read the delivered files directly: `scripts/hook-pre-write.sh`, `scripts/hook-session-guard.sh`, `src/cli/next.rs` (lines 1951–1988 and the tests at 2346–2406), `scripts/verify-session-133.sh`, `scripts/verify-session-191.sh`, `scripts/demo-session-191.sh`, the DECISION-011 S191 addendum and the KNOWLEDGE S191 facts. I compared them with the old code: `update_session_boot` from the packaged 0.2.0 copy, and the old guards as described by the verify script's own `git show f37b0fe:` usage. I checked the summary's claims rather than trusting them.

**Limits:** my tools are read-only, so I ran nothing. Every runtime claim below comes from reading the code. The branch was cut at f37b0fe (reflog line 2175 says "checkout: moving from main to session-191-small-fixes" at f37b0fe). The Execution shas c44bbd6, 96d4b86, 64248b9, 1d43183 and 1445896 all exist.

| Req | Verdict | Evidence |
|---|---|---|
| D1 — N2 outside-pass (recs 12–18) + DECISION-011 S191 addendum (rec 20) | SHIPPED | `gt_outside`: root resolved with `CDPATH= cd -P … && pwd -P` and refused if it fails or equals `/` (rec 12). `gt_plain_path`: absolute only; refuses `.`/`..` segments, a trailing `/`, a newline, and any byte outside space..`~`; a grep failure also refuses (rec 13). Leaf that is a link, is not a plain file, or has `find -prune -links +1` hard links: refused (rec 14). Both sides lower-cased with `LC_ALL=C tr`; quoted `case "$r"\|"$r"/*` boundary (rec 15). Every step uses `\|\| x=""` / `\|\| return 1`, and the functions are only called in a conditional position, so `set -e` cannot exit 1 (rec 16). Placed inside `GT_PW=1`, after the approvals guard; the plain-path refusal runs before the allowlist (rec 17). Missing folder gives `GT_WHY=missing` and a message naming `mkdir -p` (rec 18). Addendum §1 states the speed-bump limit, the "Bash blocks only commit/push/PR" point and the parallel-call gap (rec 20). It is built exactly as specified. The hole in rec 1 below comes from the specified method itself. |
| D2 — `update_session_boot` replaces only the token after `**Number:**` | SHIPPED | `swap_boot_number` finds the field, skips whitespace, takes only the ASCII digits, and swaps only when they equal `current`. The rest of the line is copied as slices. Byte offsets are safe because `trim_start` lengths and ASCII digits always fall on character boundaries. Old code was `line.replace(&format!("{current:02}"), …)` on any `**Number:**` line. |
| D3 — verify-133 safe to run twice at once | SHIPPED | The fixture path is `target/s133-fixture-wt-$$` (the "pid suffix" option the prompt allowed). An EXIT trap removes it, then `git worktree prune`. A sweep skips leftovers whose pid is still alive. The log folder becomes `${TS}-$$`. One shared resource is still there: `CARGO_TARGET_DIR=target/s133-probes` (rec 3). |
| D4 — session guard stops reading a heredoc body unless it is fed to a shell | SHIPPED | `vajra_strip_heredoc` (perl). The first line must be exactly one of the cat/tee shapes, with a quoted delimiter and a plain path. The body is cut only up to the first line exactly equal to the delimiter, and only whitespace may follow. Anything else prints nothing, so `SRC=$CMD` and the guard reads as before. `EXTRA` is still built from the raw command. This is narrower than the prompt's wording (unquoted `<<EOF` notes still block), and the summary says so. |
| AC1 — inside blocks (physical, symlinked ancestor, `..`); genuine outside passes; rec 19 cases red at start | SHIPPED | verify-191 runs 19 `n2` rows through the real hook, old and new, and requires exit exactly 2. Outside paths in /tmp, /private/tmp, $TMPDIR and sibling `proj2` give new 0 / old 2. The `..` path gives new 2 / old 0 (the old `*/.ai/*` hole). These all block: logical vs physical root and the reverse, changed case, linked ancestor, leaf link, hard link, FIFO, relative path, non-ASCII, missing folder. Each row would fail if its matching code were deleted. I checked case folding, the `/` boundary, the leaf check and the root `cd -P`. Caveat: the listed aliases are covered; a firmlink alias probably is not (rec 1). |
| AC2 — the real S188 line goes 188→189, the other 188s untouched | SHIPPED | The test `update_session_boot_leaves_prose_numbers_alone` uses the literal S188 line, and verify `grep -qF` checks it against `git show 976ba05:.ai/SESSION-BOOT.md`. Verify also copies the test into the f37b0fe checkout and needs "panicked" plus "session-189-summary", which is the real old failure. The prompt says "six more" 188s; there are really five, and the builder says so openly. |
| AC3 — two concurrent verify-133 runs both pass | SHIPPED | verify-191 `pair`: two background `bash` runs with no lock, then `wait`. The old copy must not exit `0 0` and its `fixture-red-on-bypass` row must FAIL. The new copy must exit `0 0` with no `s133-fixture-wt*` left behind. It runs one round, not three, and says so. |
| AC4 — the plain-file heredoc passes; typed checkout and `\| bash` heredoc still block; old-vs-new corpus | SHIPPED | 7 shape rows (new 0, old 2). 25 must-block rows, which I read clause by clause: `\| bash`, `bash <<`, `sh -s`, `source /dev/stdin`, `ssh`, `xargs`, `;`, a run line after the terminator, unquoted delimiter, `$( )` in an unquoted body, `<<-`, two heredocs, CRLF, `=git`, `$( )` in the path, missing terminator, the commit-message forms, backtick, eval, `sh -c`. All are 2 and 2. Corpus: S173's 30 forms (matches `verify-session-173.sh:226-258`) plus 3 new forms, × 2 triggers = 66, and none change. A no-perl row and two owner-record rows (L2 and L1) are also present. My own hunt found no command the old guard blocked that the new one lets through outside the declared shape. |
| AC5 — verify-191 green; full `cargo test` | SHIPPED | This is the builder's recorded run (verify 64/64, cargo 699/0); I could not re-run it. The row arithmetic adds up: AC1 21 + AC2 3 + AC4 37 + AC3 3 = 64. |

**Count: 9 of 9 SHIPPED.** This is a faithful build of the whole contract, not one slice dressed up as the whole. The problems below are in the specified design and in two claims, not in fidelity.

### The fakest green

**AC1's "every inside spelling blocks at both" rows.** The "at f37b0fe: 2" half of each inside row can never fail, because the old guard blocked every path not on the allowlist during a ground truth. That column proves nothing. The "new: 2" half only tries the aliases the code was written to handle (symlinks and ASCII case). The headline claim, in the addendum ("a Write passes when the guard can PROVE the target is outside") and the summary ("resolved through every link"), rests on that list, not on a proof.

Bash's `cd -P`/`pwd -P` resolve symlinks only (it walks the path calling readlink, it does not ask the system for the canonical path). So `/System/Volumes/Data/Users/suman/playground/vajra/src/main.rs` contains no symlink and keeps that spelling. It does not start with the lower-cased `/users/suman/playground/vajra`, so it most likely reads as "outside" and passes. That is a fail-open inside the project on default macOS. I reasoned this from the code; it was not run.

Runner-up: the 66-command corpus "0 changed at all" would also pass with the strip deleted. By construction none of those commands fit the declared shape. It proves only the non-shape side, and the summary admits this.

### Recommendations

rec 1 — Replace the string-prefix "inside?" test in `gt_outside` with a same-folder walk: from the resolved parent `p` up to `/`, refuse if any step `[ "$d" -ef "$r" ]`. Add a verify-191 AC1 row for `/System/Volumes/Data$PP/src/x.rs` (want new 2).
Why: `-ef` compares device and inode, so it sees through firmlinks, bind mounts, case and Unicode normalization, none of which `cd -P` resolves. The current check most likely passes an inside write spelled through `/System/Volumes/Data/…`. That is the fail-open class rec 12 was written to prevent. It is bash 3.2 compatible and keeps the fail-closed shape.

rec 2 — Correct DECISION-011 S191 addendum §1 and the summary. Change "can PROVE the target is outside" / "resolved through every link" to "resolved through every symlink; firmlinks, bind mounts and non-ASCII link targets or roots are not seen", unless rec 1 lands. Also change "refusing non-ASCII closes that case" to say it covers only the typed path.
Why: non-ASCII still gets in through a symlink target or a non-ASCII project root (for example a link to the root spelled in NFD form or with different-case `É`), and `LC_ALL=C tr` folds ASCII only. A label is not a fix: it is named, not closed, until the wording matches.

rec 3 — Give each verify-133 run its own probe build folder (`CARGO_TARGET_DIR=$ROOT/target/s133-probes-$$`, cleared by the same EXIT trap), or hold a lock around each build-and-run pair. If neither is done, name the gap in the "never exercised" list.
Why: both runs still build into one shared `target/s133-probes`. Cargo names a path package's binary from its path relative to the workspace root, so both checkouts produce the same `vajra-<hash>` file. Cargo also releases its build lock before it runs the tests. So run A can run run B's mutated binary. Today's green very likely depends on the two runs applying the same bypass at the same moment. Smaller related point: the sweep deletes the unsuffixed `target/s133-fixture-wt` without checking, so it would break a pre-S191 copy running at the same time (for example two verify-191 runs at once).

rec 4 — Add one AC1 row with `CLAUDE_PROJECT_DIR=/` (and one with a root that cannot be resolved), wanting exit 2.
Why: no row tests rec 12's "block if the root fails or is `/`". If `[ "$r" != "/" ]` were deleted, the case pattern becomes `"/"|"//"*`, every absolute target reads as outside, and the suite stays green.

rec 5 — Make `vajra next --advance` warn when no SESSION-BOOT line changed, instead of always printing ".ai/SESSION-BOOT.md updated".
Why: the old `replace` also changed forms like `**Number:** S190` or `**Number:** **190**`. `swap_boot_number` now skips those silently. The real file and both scaffolds use the plain `**Number:** NN` shape, so nothing breaks today, but a hand-edited line would stop advancing with no message.

**Verdict:** ACCEPT

Every requirement was built as specified and is checked by tests that can go red for the reason they name. The firmlink hole (rec 1) is a gap in the S187-specified design, bounded by the guard's own stated limit ("speed bump; Bash can already write"). It should still not be described as "proven outside" until rec 1 or rec 2 lands.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (10812 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
