---
role: release-coordinator
session: 191
agent: claude-code-subagent (verified: toolu_01TwgEMUfQdVmBp22ZdaWj3q; text-sha: b7cee680a6cbd0cafc7ca249c0ccd62c3b04cbafbc9c236f89728e3d8a207917)
source-sha: 00385ed81230de7772c0b59338d53f7d336a8b4ae6f02f14a89f7f4886610f23
captured: 2026-10-08T15:26:51Z
cost_usd: null
---

# Release-coordinator handoff — session 191

## S191 — judgment of every `## Advice` answer (release-coordinator, one pass)

**What I could and could not check.** I cannot run git. I read `## Advice`, the three handoffs and the current files on the branch. To see which commit did what, I used the commit messages in `.git/logs/HEAD` (lines 2175–2186). For the four build commits I also used the fidelity-reviewer's notes, because it read the branch before the review fixes landed. I did not read any commit's diff directly. Wherever I say "commit X does Y", I am inferring it from those sources.

**Coverage.** Every rec has an answer: tech-lead recs 1–7, design-advisor recs 1–12, fidelity-reviewer recs 1–5 (24 answers: 22 `obeyed`, 2 `refused`). All 6 roles the tech-lead deferred on budget have a reasoned skip line: researcher, requirements-analyst, plan-advisor, implementation-advisor, qa-specialist, demo-producer.

| Rec | Answer | Judgment | Evidence (one line) |
|---|---|---|---|
| tech-lead 1 | obeyed c44bbd6… | AGREE | The build order matches the rec: c44bbd6 item 2 → 96d4b86 item 3 → 64248b9 item 1 → 1d43183 item 4, which is its own commit. Item 4 landed about 21 minutes after the branch was cut, well inside the cut line. |
| tech-lead 2 | obeyed 1d43183 | AGREE | `hook-session-guard.sh:85-108`: only one `cat`/`tee` shape loses its body, with a quoted delimiter and nothing after the terminator. EXTRA is still built from the raw `$CMD`. With no perl, SRC is just `$CMD`. |
| tech-lead 3 | obeyed 1445896 | AGREE | `verify-session-191.sh` runs under `BASH32=/bin/bash`. The `commit -m "$(cat <<'EOF'…)"` row and the `)"` row (lines 164–165, 204) and S173's whole list (177–209) must block both old and new. |
| tech-lead 4 | obeyed c44bbd6 | AGREE | `next.rs:2381-2419` has the real S188 line as a literal, plus the "no field 188" and "S188 - **Number:** 188" edge cases. |
| tech-lead 5 | obeyed 96d4b86 + refused in part | AGREE, with a note | Each run gets its own pid-named checkout, an EXIT trap removes it, then `worktree prune` (`verify-session-133.sh:35, 462-468`). Both refusal reasons are true: the >10-minute measurement under $TMPDIR is recorded at :458-459, and the 600 s bound is at CONSTRAINTS.yaml:48. Note: the "three rounds by hand, all green" were run on the 96d4b86 version, before aecfd25 fixed the shared build folder. Also, a round now takes about 3 minutes, not 80 seconds (summary line 50). |
| tech-lead 6 | refused | AGREE | `init.rs:25` lists `hook-session-guard.sh` in SYNC_HOOKS, and the StaleRender rewrite exists (`init.rs:176/227`). `hook-pre-write.sh` is not on that list. The refusal's reason is true. |
| tech-lead 7 | obeyed (no sha) | AGREE on substance; the line will fail the gate | The order was followed: design-advisor handoff captured 14:37:52Z, first build commit 14:38Z, one fidelity pass, skip lines present. But the answer reads `obeyed: design-advisor → …`. The gate reads only the leading hex letters ("de"), which name no commit, so `--check-advice` will count it unanswered (`src/advice/mod.rs:506-519`). |
| design-advisor 1 | obeyed 64248b9 | AGREE | DECISION-011:291-300 is one S191 addendum with §1 and §2, and it says it records the outside check for the first time. |
| design-advisor 2 | obeyed 64248b9 | AGREE | `hook-pre-write.sh:122-137`: the path check runs first, the allowlist's pass branch is unchanged, `gt_outside` runs only in `*)`, and a write outside the project falls through to the main/master warning. `gt_refuse` (:66-73) keeps the L1 rule in one place. |
| design-advisor 3 | obeyed 64248b9 | AGREE | `gt_plain_path` (:78-84): absolute paths only; no `.`/`..` segment, no trailing `/`, no newline; any byte outside space..`~` refuses; only grep exit 1 passes. |
| design-advisor 4 | obeyed 64248b9 | AGREE | `gt_outside` (:90-109) does steps (a)–(e) in order. The verify `n2` rows require exactly exit 2. |
| design-advisor 5 | obeyed 64248b9 | AGREE | The missing-folder message names `mkdir -p` (:130). verify-191:52-60: /tmp, /private/tmp and $TMPDIR pass; /var and /private/var block in both directions. |
| design-advisor 6 | obeyed 64248b9 | AGREE | The §1 text is the rec's text, edited for what was built. One wording leftover is listed under fidelity-reviewer 2. |
| design-advisor 7 | obeyed 1d43183 | AGREE | The perl patterns (:93-96) cover the six opener shapes, a quoted `[A-Za-z_][A-Za-z0-9_]*` delimiter and the `(?:~/)?[A-Za-z0-9_./-]+` path. It prints the opener and terminator, so they stay in SCAN. |
| design-advisor 8 | obeyed 1d43183 + refused in part | AGREE | Perl stops at the first line exactly equal to the delimiter, and only whitespace may follow (:99-101). The refusal is true: for any other shape SRC is `$CMD` itself (:105-106), so there is no reprinted copy to compare byte for byte. |
| design-advisor 9 | obeyed 1d43183 | AGREE | :108 builds EXTRA from `$CMD`. `KNOWLEDGE.md:377` names the false block that was kept on purpose. |
| design-advisor 10 | obeyed 1445896 | AGREE | verify-191:129-242 has the 7 shape rows, the 25 must-block rows, S173's list × both triggers with an old-blocks ⊆ new-blocks check (:215), the no-perl row and the L1 rows. |
| design-advisor 11 | obeyed 1d43183 | AGREE | DECISION-011:348-350 says it "deviates". The prompt's Design (:74-77) and Guardrails (:97-99) were corrected in 8770150. |
| design-advisor 12 | obeyed (no sha first) | AGREE on substance; the line will fail the gate | The init.rs finding is true, and §2 (:360-362) and §1 (:325-326) say so. But the answer reads `obeyed: checked src/cli/init.rs…`. The gate reads "c", which names no commit, so it will count it unanswered. |
| fidelity-reviewer 1 | obeyed 23971d5 | AGREE | `hook-pre-write.sh:110-118` adds the walk up the folders comparing by inode (`-ef`); the string compare stays as a first check, which is stricter. Note: the firmlink verify row that really shows the hole, on a /private/tmp project, came in aecfd25 (its commit message says so), not 23971d5. |
| fidelity-reviewer 2 | obeyed 23971d5 | AGREE, one leftover | The addendum now says "every symlink" (:305), names the inode walk and the firmlink (:306-308), and says the non-ASCII refusal covers only the typed path (:323-325). Keeping "PROVE" is allowed because rec 1 landed. Leftover: DECISION-011:329 (the Rejected bullet) still says "refusing non-ASCII closes that case", and the comment at `hook-pre-write.sh:87` still says "every link". |
| fidelity-reviewer 3 | obeyed aecfd25 | AGREE | `verify-session-133.sh:471-482`: each run builds into its own `target/s133-probes-$$`, cloned from the shared folder and removed by the trap. No lock is left. The sweep pattern `s133-fixture-wt-*` never matches the old path without a suffix. |
| fidelity-reviewer 4 | refused | AGREE | `hook-pre-write.sh:29-52`: with ROOT=`/` or a root it cannot enter, BRANCH becomes "?", SESSION_NUM is empty, GT_PW=0, and the hook exits 0 before `gt_outside` runs. The refusal's reason is true, from reading the code. |
| fidelity-reviewer 5 | obeyed b0ef01b | AGREE | `next.rs:1941-1949` prints the warning. The test at :2366-2370 asserts that a second call moves nothing. |

**Judgment lines for Vajra.** For each `obeyed` answer I checked the sha it names. I read the current branch and the commit messages, not the diffs. The two lines marked "only valid if" hold only when the Advice line is edited to put that sha first (rec 1 below).

```
obeyed-check tech-lead rec 1 — implemented: c44bbd6 — item 2 first; then 96d4b86 item 3, 64248b9 item 1, 1d43183 item 4 alone, inside the cut line
obeyed-check tech-lead rec 2 — implemented: 1d43183 — allow-list of one quoted-delimiter cat/tee file-write shape; EXTRA from the raw command; no perl removes nothing
obeyed-check tech-lead rec 3 — implemented: 1445896 — S173 list incl. the )" and commit -m heredoc forms, run under /bin/bash 3.2, block old and new
obeyed-check tech-lead rec 4 — implemented: c44bbd6 — the real S188 line as a literal in the unit test, plus the no-field and digits-before-field cases
obeyed-check tech-lead rec 5 — implemented: 96d4b86 — pid-named checkout under target/, EXIT trap removes it and prunes; mktemp and 3 rounds refused with true reasons
obeyed-check tech-lead rec 7 — implemented: 8effeb1 — design-advisor before build, one fidelity pass recorded after it, skip lines in Advice (only valid if the Advice line is edited to name 8effeb1 first)
obeyed-check design-advisor rec 1 — implemented: 64248b9 — one S191 addendum inside DECISION-011, §1 says it records the outside check for the first time
obeyed-check design-advisor rec 2 — implemented: 64248b9 — inside GT_PW=1; path check before the allowlist; outside test only in *); falls through to the main warning
obeyed-check design-advisor rec 3 — implemented: 64248b9 — gt_plain_path: absolute, no ./.. segment or trailing /, no newline, printable ASCII only, grep failure refuses
obeyed-check design-advisor rec 4 — implemented: 64248b9 — gt_outside (a)-(e): root via cd -P and not /, parent/leaf split, leaf link/hard link/non-file refuse, C-locale fold, quoted / boundary
obeyed-check design-advisor rec 5 — implemented: 64248b9 — missing folder blocks naming mkdir -p, no walking up; /tmp, /private/tmp, TMPDIR rows pass in 1445896
obeyed-check design-advisor rec 6 — implemented: 64248b9 — addendum §1 is the rec's text edited for the built code
obeyed-check design-advisor rec 7 — implemented: 1d43183 — six opener shapes, quoted delimiter, plain path class; opener and terminator kept in SCAN
obeyed-check design-advisor rec 8 — implemented: 1d43183 — perl stops at the first exact delimiter line, whitespace only after; byte-for-byte test refused, true because SRC is $CMD itself otherwise
obeyed-check design-advisor rec 9 — implemented: 1d43183 — EXTRA still from $CMD; KNOWLEDGE line names the kept backtick/$( ) false block
obeyed-check design-advisor rec 10 — implemented: 1445896 — shape rows, 25 must-block rows, S173 corpus x triggers with old-subset-of-new check, no-perl and L1 rows
obeyed-check design-advisor rec 11 — implemented: 1d43183 — DECISION-011 S191 addendum §2 records the deviation; prompt Design/Guardrails corrected in 8770150
obeyed-check design-advisor rec 12 — implemented: 1d43183 — §2 says --sync-fleet rewrites an unedited hook-session-guard.sh; §1 says hook-pre-write.sh is not shipped (only valid if the Advice line is edited to name 1d43183 first)
obeyed-check fidelity-reviewer rec 1 — implemented: 23971d5 — gt_outside walks the folder up to / and refuses any step that -ef the root; the working firmlink row landed in aecfd25
obeyed-check fidelity-reviewer rec 2 — implemented: 23971d5 — addendum says every symlink, names the inode walk and firmlink, non-ASCII refusal covers only the typed path; one Rejected-bullet phrase left
obeyed-check fidelity-reviewer rec 3 — implemented: aecfd25 — each verify-133 run builds into its own cloned target/s133-probes-<pid>, removed by the trap; old unsuffixed path never swept
obeyed-check fidelity-reviewer rec 5 — implemented: b0ef01b — update_session_boot returns whether a line moved; --advance warns instead of saying updated
```

## What blocks the close today

1. **Two Advice answers name no commit:** tech-lead rec 7 and design-advisor rec 12. The `--check-advice 191` gate reads only the leading hex letters ("de", "c"), so both will count as unanswered. I inferred this from `src/advice/mod.rs:506-519`; I did not run it.
2. **Execution step 6 is still `done: <sha>`.** A placeholder records nothing, so the Coder gate blocks.
3. **No Review-Inputs-SHA in `sessions/session-191-review.md` yet**, so the attestation check blocks.
4. **The merged branch `session-190-closeout` is still on disk locally** (`.git/refs/heads`, at 0caff31). That trips `require_pruned`. It is also why `--advance` refused and `.ai/SESSION` still says 190. I infer it is merged: the reflog shows main pulled to f37b0fe right after S190's last commit. I have not seen the ancestry.
5. **This handoff is not recorded yet.** Until it is, the obeyed gate sees no judge, and silence blocks because `obeyed_blocks_from: 132`.
6. **Risk, not yet a fact: verify-191's run time against the 600 s bound.** A concurrent verify-133 pair now takes about 3 minutes, and verify-191 runs an old pair, a new pair and an old-commit cargo build.

## Ordered ship steps (a proposal; every step is a human act)

rec 1 — Rewrite the two Advice lines that name no commit so a real sha comes first: `tech-lead rec 7 — obeyed: 8effeb1 (…)` and `design-advisor rec 12 — obeyed: 1d43183 (…)`.
Why: the gate reads only the leading hex of the answer. Today it reads "de" and "c", which name no commit, so both count as unanswered and block. My judgment lines above are recorded against exactly 8effeb1 and 1d43183. Any other sha leaves those two unjudged, and silence blocks.

rec 2 — Fill Execution step 6 with a real commit sha (the closeout-sync commit), not `<sha>`.
Why: the Coder gate records nothing for a placeholder, so step 6 stays untraced and the close blocks.

rec 3 — While the closeout is open, fix four stale bits of wording:
- DECISION-011:329 → say the non-ASCII refusal "closes it for a typed path only".
- `hook-pre-write.sh:87` comment → "every symlink".
- The review header's "(23971d5, b0ef01b)" → add aecfd25 for rec 3.
- verify-191:247's "~80 s per pair" → the real figure.
Why: the record still makes the overclaim that fidelity-reviewer rec 2 asked to remove ("a label is not a fix"), and two lines point at the wrong commit and a stale time. These are text-only edits. Do them before the stamp.

rec 4 — Either re-run the verify-133 concurrent pair three times by hand on the current tip, or say in the summary and Advice that the three green rounds were run on 96d4b86.
Why: those rounds tested the shared-build-folder version. The review showed that version could run the other run's binary, and the fix (aecfd25) came after them.

rec 5 — Founder, in your terminal: `git branch -d session-190-closeout` (lower-case `-d`, never `-D`). Then run `--advance` with a vajra built from THIS branch (for example `cargo run -q -- next --advance`). Then check that the SESSION-BOOT diff changes only `**Number:** 190 → 191`. Then commit the advance together with `.ai/approvals/session-191.json`, as S186 and S187 did.
Why: `-d` refuses to delete a branch that is not merged, which covers the gate's blind spot (a branch deleted before its merge looks the same as one deleted after). An installed vajra is pre-S191; I infer this because S191 is not merged. It would rewrite every "190" on SESSION-BOOT line 7, which is exactly the bug this session fixed. The 191 approval record is the only one still untracked.

rec 6 — Record this handoff. Then do the closeout sync (STATE, ROADMAP, SESSION-BOOT, TASK) and draft the S192 prompt. Then answer this handoff's recs in Advice and commit. Run `bash scripts/verify-closeout.sh --inputs-sha 191` LAST, paste the result as `**Review-Inputs-SHA:**` in the review, and commit.
Why: the hash covers the committed prompt plus every file the diff does not exclude, and `.ai/handoffs/` and `.ai/approvals/` are not excluded (`verify-closeout.sh:1110-1123`). Any Advice edit, handoff or approval record added after the stamp makes it stale. Only `sessions/` and the synced `.ai/*` files are safe after it.

rec 7 — Run the full `bash scripts/verify-closeout.sh 191` on the branch, before any merge. It must exit 0, and check that the verify step finishes under 600 s.
Why: the branch-point comparison breaks once main contains the branch. The QA gate kills a run that passes 600 s and blocks, and verify-191 now carries a ~3-minute concurrent pair.

rec 8 — Founder: push the branch, open the PR, and merge it with a merge commit (no squash, no rebase), only after the green close and the recorded ACCEPT.
Why: `require_merged_prior` checks that the branch is merged by ancestry. A squash leaves the branch tip outside main, so S192's gate blocks and `git branch -d` refuses.

rec 9 — Founder, after the merge: `git fetch`, then `git checkout main && git pull --ff-only`, then `git branch -d session-191-small-fixes`. Leave `.claude/launch.json`, `first-mate.html`, `sessions/session-137-scatter-render.html` and `vajra-cto-audit-2026-07-22.html` out of every commit.
Why: `require_main_synced` is only as fresh as the last fetch. Today local main = origin/main = f37b0fe according to `FETCH_HEAD`, but that fetch dates from S190. `require_pruned` needs the merged branch gone. The founder's rule keeps local artifacts out of git.

**Question for the founder (not a step):** existing projects such as rudra get the S191 session-guard change only from a vajra built from S191 or later, on their next `--sync-fleet`. Whether and when to build or publish such a version is your call.

## Handoff Delta
- `+` new: first release-coordinator handoff for this session (16932 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
