---
role: demo-producer
session: 168
agent: claude-code-subagent (verified: toolu_01BpBW3zezx5xjJvHLshzhNH)
source-sha: f179d9d83f45062e909137b618172ffd49fd64a626a0de3b71979a150d244935
captured: 2026-09-14T13:43:22Z
cost_usd: null
---

# Demo-producer handoff — session 168

# S168 demo proposal: `scripts/demo-session-168.sh` compared with the template and kit

**Brief:** Demo-producer pass on the S168 draft demo (read: the template, `scripts/demo-kit.sh`, the draft). The draft is mostly sound — all seven sections render, the four scanned markers come from `dk_section`, `demo:complete` from `dk_finish`, `demo:fact` from `dk_vajra_tiles`/`dk_vajra_scorecard`, the before runs the S167 kit out of git, the rule rows run the real gate. 14 recommendations close the gaps (typed numbers, checks that cannot fail for the right reason, missing odd inputs, honest notes).

**Headline (`demo:header`)**
rec 1 — Take the `LIB TESTS|507|recorded` tile from `$REC_TESTS` instead of typing 507 a second time.
The same number is typed twice today, so the two copies can drift apart. Otherwise the headline is right: the other tiles are filled in by Vajra.

rec 2 — Label the "Old: … the gate saw exit 0 and four markers and let it close" line as recorded, or narrow it to what the demo shows.
Only the S167 *kit* runs in the before. The S167 *gate* (the old binary) never does.

**Before → after (`demo:before_after`)**
rec 3 — Make the before/after check fail for the right reason. Add `grep -q 'refused'` on the after output, and turn the `git show "$S167:…"` step (errors hidden by `2>/dev/null`) into a check (`git cat-file -e $S167:scripts/demo-kit.sh`).
Today, any non-zero after exit passes, even a crash. A missing commit also produces a confusing panel.

rec 4 — Either show the typed `STATIONS 8 of 8` tile being caught in the after, or stop claiming it.
The text says "same faked demo" with a typed tile, but today's kit only refuses the PASS. The typed tile is never caught in this panel. Add a second after run through `vajra next --check-demo 99` with the PASS swapped for a real check and no Vajra facts, expecting NOT READY. Or reword the panel to say it covers the typed PASS only.

**Rule**
rec 5 — Take the Why column from the gate's own blocking line in `_DK_OUT`, and add a per-row `grep -q` for the expected reason.
Right now Why is typed text, and NOT READY for any reason passes the row.

rec 6 — Add two rows: "typed tile, no demo:fact at all" (want NOT READY) and "a check that always passes, `dk_check x true`" (want READY, labelled *fakest green, still passes*).
The first is the forgery people will actually try. The second shows the demo's own limit live instead of only in the notes.

rec 7 — In the forged row, derive a stations value that is sure to differ (derived + 1) instead of hard-coding 8.
Also make the legacy-old "warned" badge a real `dk_check`. Today it only decorates the row.

**Cases (`demo:cases`)**
rec 8 — Case 2: run it in a `fresh_project` and require `--demo-facts 42` to exit 0 with `session=42`.
Today the exit code is thrown away. A vajra that errors before doing anything would pass "ran neither script".

rec 9 — Case 3: drop `grep -q "any escape"` and assert the dark count too.
That grep only matches the label the demo typed itself, so it can never fail. Assert dark > 0 and light ≠ dark. Also add a `COLORFGBG='0;15'` run, since the story claims that detection works.

rec 10 — Case 4: tighten the grep from `upgrade` to `would upgrade`, and fail if the output mentions `drifted`.
A refusal message that suggests `--overwrite-drifted` matches the bare word. Also hash the kit before and after the dry-run, so "dry-run changes nothing" is live and not only recorded from chitra.

rec 11 — Add the odd inputs the kit refuses: `dk_check "x" 0`, `dk_check "x"` (no command) and `dk_check "x" FAIL`.
Run each in a small throwaway demo and check that it exits 1 and names the refusal. Also add a live `vajra next --check-demo 167` so the story's claim "S167 migrated and still passes" is actually shown. If that is too heavy, label the claim recorded.

**Scorecard (`demo:summary_table`)**
rec 12 — Remove the `REC_REVIEW` row.
It points to a file instead of stating a result, and the review verdict is already a fact Vajra fills in.

rec 13 — Add these "not shown" lines to the honest notes (condensed): the facts drawn come from this run and the gate compares them again at close; a hand-typed `demo:fact` line with the right value passes (the gate proves the value, not that Vajra drew it); the S167 gate binary is never re-run; the rule rows use session 99 in throwaway folders; a green demo is not a passing delivery.

**Next**
rec 14 — Add these words to the small-words helper: gate, fresh project, commit / "out of git", stream mode, dry-run, `--sync-fleet`, fakest green, legacy / downgrade.

## Handoff Delta
- `+` new: first demo-producer handoff for this session (4612 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
