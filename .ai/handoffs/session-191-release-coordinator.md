---
role: release-coordinator
session: 191
agent: claude-code-subagent (verified: toolu_01TwgEMUfQdVmBp22ZdaWj3q; text-sha: ed56560d2720b4085eab70262748c9d5c141d73375677311c2f0b0be5a561ebe)
source-sha: 03bb5f28881c3689346b975528dea877fa22b6a22af1cc9f08ce138dcdae257b
captured: 2026-10-08T15:34:32Z
cost_usd: null
---

# Release-coordinator handoff — session 191

Pass 2 of the release-coordinator's judgment for session 191. It replaces pass 1 completely. The judgment lines are plain lines below, not inside a code fence.

Changed answers re-checked:
- Tech-lead rec 7 now leads with 8effeb1. That commit records the one fidelity-reviewer pass after the build, and the six skip lines sit in `## Advice`. AGREE.
- Design-advisor rec 12 now leads with 1d43183. That commit adds DECISION-011 §2, which says `--sync-fleet` rewrites an unedited `hook-session-guard.sh`. §1 says `hook-pre-write.sh` is not shipped to projects. I checked both against `src/cli/init.rs`: line 25 lists the guard in SYNC_HOOKS, and `hook-pre-write.sh` is not on that list. AGREE.
- Fidelity-reviewer rec 1 now also cites aecfd25 and 3952a6d. AGREE. 3952a6d is real and correct: `hook-pre-write.sh:95` and `:116` now walk up comparing by inode against `r0`, the root as resolved. Before, the walk compared against the lower-cased copy, and on a case-sensitive disk that path may not exist, so the check would never match and the write would pass. On default macOS, where the disk ignores case, 23971d5 already worked, so rec 1 was met there.
- Tech-lead rec 5 now says the three hand rounds were on 96d4b86 and two rounds ran on aecfd25. AGREE.

My pass-1 rec 3 wording is also in place: DECISION-011:329 now says the typed-path refusal covers only the typed path, the hook comment at `:87` says "every symlink", and the reflog message for 3952a6d confirms it.

One small leftover, no new rec: tech-lead rec 5's refusal still says "a round is ~80 s". A round now takes about 3 minutes. The refusal's reason, the 600 s close bound, still holds.

How I checked: I cannot run git. I read the current branch, the reflog commit messages, and the fidelity-reviewer's read of the branch before its fixes. I did not read any commit's diff directly.

obeyed-check tech-lead rec 1 — implemented: c44bbd6 — item 2 built first, then 96d4b86 item 3, 64248b9 item 1, and 1d43183 item 4 in its own commit, well inside the cut line
obeyed-check tech-lead rec 2 — implemented: 1d43183 — removes the body for one quoted-delimiter cat/tee file-write shape only; every other shape is still read; EXTRA still comes from the raw command; with no perl nothing is removed
obeyed-check tech-lead rec 3 — implemented: 1445896 — verify-191 runs S173's whole list, including the bash 3.2 )" case and the git commit -m heredoc form, under /bin/bash 3.2; both still block
obeyed-check tech-lead rec 4 — implemented: c44bbd6 — the unit test holds the real S188 line as a literal, plus a line with no Number field and digits before the field, both left unchanged
obeyed-check tech-lead rec 5 — implemented: 96d4b86 — each run gets its own pid-named checkout under target/, removed by an EXIT trap, then git worktree prune; mktemp and three verify rounds refused with true reasons
obeyed-check tech-lead rec 7 — implemented: 8effeb1 — records the one fidelity-reviewer pass after the build (design-advisor came first); the skip lines with their budget reasons are in Advice
obeyed-check design-advisor rec 1 — implemented: 64248b9 — one S191 addendum inside DECISION-011; §1 says it records the guard's outside-pass for the first time (§2 added in 1d43183)
obeyed-check design-advisor rec 2 — implemented: 64248b9 — the new code sits inside GT_PW=1; the bad-path check runs before the allowlist; the allowlist's pass branch is unchanged; the outside test runs only in the *) branch; an outside write falls through to the main/master warning; gt_refuse keeps the L1 rule in one place
obeyed-check design-advisor rec 3 — implemented: 64248b9 — gt_plain_path accepts only absolute paths; it refuses a . or .. segment, a trailing /, a newline and any byte outside space..~; a grep failure also refuses
obeyed-check design-advisor rec 4 — implemented: 64248b9 — gt_outside does (a)-(e): root via cd -P and refused if it is /, parent and leaf split, a leaf that is a link, a hard link or not a plain file refuses, lower-casing in the C locale, quoted case compare on a / boundary
obeyed-check design-advisor rec 5 — implemented: 64248b9 — a missing folder blocks with a message naming mkdir -p and no walking up; the /tmp, /private/tmp and $TMPDIR rows that pass and the /var vs /private/var rows that block come in 1445896
obeyed-check design-advisor rec 6 — implemented: 64248b9 — addendum §1 is the rec's text, edited to match the built code
obeyed-check design-advisor rec 7 — implemented: 1d43183 — the six opener shapes, a quoted [A-Za-z_][A-Za-z0-9_]* delimiter, a plain [A-Za-z0-9_./-] path with an optional ~/; the opener and terminator stay in SCAN
obeyed-check design-advisor rec 8 — implemented: 1d43183 — one perl step that stops at the first line exactly equal to the delimiter and allows only whitespace after it; the byte-for-byte test is refused, truly, because for any other shape SRC is the command itself
obeyed-check design-advisor rec 9 — implemented: 1d43183 — EXTRA is still built from the raw command; the KNOWLEDGE line names the false block kept on purpose (a backticked or $( ) checkout inside even the quoted shape)
obeyed-check design-advisor rec 10 — implemented: 1445896 — 7 shape rows, 25 must-block rows, S173's list x both triggers with an old-blocks-subset-of-new check, a no-perl row and L1 owner rows
obeyed-check design-advisor rec 11 — implemented: 1d43183 — DECISION-011 S191 addendum §2 records the deviation from the S173 only-add rule; the prompt's Design and Guardrails were corrected in 8770150
obeyed-check design-advisor rec 12 — implemented: 1d43183 — §2 says --sync-fleet rewrites an unedited hook-session-guard.sh; §1 says hook-pre-write.sh is not shipped to projects; both match src/cli/init.rs
obeyed-check fidelity-reviewer rec 1 — implemented: 23971d5 — gt_outside also walks the target's folder up to / and refuses any step that -ef the root, closing the firmlink hole on default macOS; the firmlink verify row landed in aecfd25 and the case-sensitive-disk fix (compare against r0) in 3952a6d
obeyed-check fidelity-reviewer rec 2 — implemented: 23971d5 — addendum §1 says every symlink, names the inode walk and the firmlink, and says the non-ASCII refusal covers only the typed path (the last Rejected-bullet phrase was fixed in 3952a6d)
obeyed-check fidelity-reviewer rec 3 — implemented: aecfd25 — each verify-133 run builds into its own target/s133-probes-<pid>, cloned copy-on-write and removed by the EXIT trap; the old unsuffixed checkout path is never swept; no lock is left
obeyed-check fidelity-reviewer rec 5 — implemented: b0ef01b — update_session_boot returns whether a line moved; --advance warns when no Number line moved instead of saying updated; the test asserts a second call moves nothing

I did not judge my own recs 1–9. All of them are answered `deferred:` with a reason, and an advisor cannot grade its own advice.

## Handoff Delta
- `~` re-run: release-coordinator handoff replaced (6965 bytes now vs 16740 bytes prior)
- prior stage: this session's earlier release-coordinator handoff
