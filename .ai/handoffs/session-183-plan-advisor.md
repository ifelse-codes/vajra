---
role: plan-advisor
session: 183
agent: claude-code-subagent (verified: toolu_01SqZy1cYDDra8KNgT8Jwm1h; text-sha: 9dc77f0b0a73470057029346084d5f03997e2a3caa0267737a3e98a499070931)
source-sha: 9252f52c55858a37f115d71d0d6fe9ef8eb78255a08b51381ae56a3567733d07
captured: 2026-10-03T01:47:46Z
cost_usd: null
---

# Plan-advisor handoff — session 183

Plan-advisor brief for session 183 (branch session-183-rudra-s16-new-rules)

What I read: prompts/183-task-rudra-s16-new-rules.md (Acceptance 1–4), scripts/verify-session-183.sh, and short slices of scripts/verify-closeout.sh, scripts/verify-closeout-scaffold.sh, scripts/lib-ground-truth.sh, src/cli/init.rs, src/obeyed/mod.rs, src/nextstep/mod.rs and tests/approvals_guard.rs. I have no shell, so I could not run `git log main..HEAD`. The commit list below is the one you gave me (56cb431, 581379d, 6fbade6, 2174807, 0cd5c3e, 9293b6d).

One thing I saw while reading: F106 is already being edited in the working tree. Line 46 of both close scripts now reads `if [ "${1:-}" = "--inputs-sha" ]; then ARTIFACTS="$(mktemp -d)"; trap ... EXIT; else mkdir -p "$ARTIFACTS"; fi`. That was not in the commit list, so I take it as uncommitted.

## Proposed `## Plan` (the author records it; numbering is a suggestion)

1. F101: pin the toolchain in rust-toolchain.toml, add scripts/ci-lint.sh, and make ci.yml read the pin. Landed in 56cb431. covers: 2
2. F101: both close gates run the shared lint, and release.yml builds on the pinned toolchain. Landed in 581379d. covers: 2
3. F101: the init template shows `lint_command`; add the F101 checks to scripts/verify-session-183.sh; add the DECISION-011 addendum. Landed in 6fbade6. covers: 2
4. The brief carries F101's evidence and the founder's call; tech-lead and design-advisor handoffs. Landed in 2174807. covers: 1
5. F102: the no-jq test removes jq on every OS (main CI was red since #219). Landed in 0cd5c3e. covers: 2
6. The founder's approval record (`vajra approve 183`). Landed in 9293b6d. covers: 4. This is a weak mapping: no criterion really owns this commit. I mapped it to 4 because a close cannot happen without it. Leave it out of the plan if you prefer.
7. Write the findings table F102–F106 in the session summary. Each row gets its evidence (rudra S16 log line, file, or commit) and the founder's call: "fix" for F102–F106. Add a "moves to S184" line that is filled in only if the cut is used. covers: 1
8. Make verify-session-183.sh run against the current build, not a leftover one. Always run `cargo build --release -q`. Put `$ROOT/target/release` first on PATH for every check that runs a project's close script. Add the F102 check. covers: 2
9. F106: neither close script leaves an empty `.ai/verify/closeout/<ts>/` folder on `--inputs-sha`. Add its check. covers: 2
10. F103: `vajra init` no longer hangs when stdin is a pipe that stays open but sends nothing. Answers piped in on purpose still work. Add its check. covers: 2
11. F104: in the scaffold gate, the `obeyed-judgments` row shows WARN with the count of unjudged lines instead of PASS. It still does not block. Add its check. covers: 2
--- CUT LINE: if the ~2h cap runs out, everything below moves to S184 (founder-approved) ---
12. F105: `vajra next --steps` shows "the prompt declares its session type" near the start, reading the type through the shared bash helper `vajra_session_type`. Add its check. covers: 2
13. Acceptance 3 evidence: the summary states that no Vajra commit touched rudra, with a `git -C ~/playground/rudra log` excerpt of S16's commits (the founder's). covers: 3
14. Close: run the full `scripts/verify-closeout.sh` on the branch before merging. Get one fresh cold review. Print `--inputs-sha 183` last and embed it. covers: 4

Coverage: 1 (steps 4, 7), 2 (1–3, 5, 8–12), 3 (13), 4 (6, 14). Nothing is left uncovered. If the cut is used, Acceptance 2 still holds for every fix that landed. F105 then needs its call recorded as "fix, moved to S184" in the step 7 table.

## Recommendations

rec 1 — Make verify-session-183.sh always rebuild the binary and put `$ROOT/target/release` first on PATH. Otherwise the F103/F104/F105 checks can pass or fail for the wrong reason.

Line 17 builds only when the binary is missing (`[ -x "$VAJRA" ] || cargo build`). So a binary built before your edit stays in use, and the scaffold template is baked into it by include_str!. Separately, the scaffold's obeyed check picks `command -v vajra` first (verify-closeout-scaffold.sh:633). Inside a temp project that finds the installed `~/.cargo/bin/vajra`, which is older and does not have the fix. This is the S122 "fails for the wrong reason" trap.

rec 2 — F106 check: run the real `--inputs-sha` against a temp project and against Vajra itself, and require the folder count under `.ai/verify/closeout/` to be the same before and after.

For the red case, run the `git show 9558801:scripts/verify-closeout.sh` copy on the same fixture. It must add one empty folder. Do this for the scaffold script too, inside a project made by `vajra init`. Also require the hash printed by the old and new script to be byte-identical on the same inputs, so the fix cannot quietly change what reviews attest.

rec 3 — Harden the F106 line as written: use `ARTIFACTS="$(mktemp -d)" || exit 1`, and decide about `--ledger` / `--ledger-verify`.

If mktemp fails, ARTIFACTS is empty and logs are written to `/session-file-valid.log`. `--ledger` and `--ledger-verify` (lines 1315/1331) never write to ARTIFACTS, so they also leave an empty folder today. Either send them down the same temp-folder branch (same line, no extra files) or list it in the summary as a separate finding. Do not leave it unmentioned.

rec 4 — F103: do NOT fix this with "stdin is not a terminal, so use the defaults". That breaks piped answers, a supported and tested use.

These scripts pipe answers into init: scripts/demo-session-143.sh:40 (it then checks for `acme-app` at lines 45 and 88), verify-session-143.sh:87, fixture-session-143.sh:88, and verify-session-46.sh:39. A blanket skip turns demo-143 red.

What I suggest instead: when stdin is not a terminal, wait a short, fixed time for each answer. Use a reader thread plus `recv_timeout`, which works on any OS. If nothing arrives in time, or the input has ended, use the default for that question and every question after it, and print the default used to stderr. This is a behavior choice the founder did not spell out, so record it in one line in `## Design`.

Check: in the background, run `sleep 60 | vajra init` in a temp git repo with a bash watchdog (macOS has no `timeout` command). It must finish within ~10s and write `.ai/` with `my-project`. The control is `printf 'acme-app\n...\nL2\n' | vajra init`, which must still write `acme-app`. Also re-run verify-session-143.sh.

rec 5 — Reproduce the exact rudra S16 command that hung (plain `vajra init`, or `init --sync-fleet` / `--help`?) and quote it in the F103 evidence.

If the hang came from a flag path that goes through `prompt()` some other way, the step 10 check must run that command, not a nearby one.

rec 6 — F104: have the binary print one fixed count line that the scaffold row matches, for example `unjudged (pre-threshold, WARN): <n>`. Keep exit 0, and do not parse its prose.

This follows the precedent at scaffold line 657, which requires the gate's own header line. Changing the exit code would ripple into the `--advance` callers.

Check: in a `vajra init` temp project, make a real commit and write a session prompt whose `## Advice` has two `obeyed: <that sha>` lines with no judgment. Run the project's scripts/verify-closeout.sh. The `obeyed-judgments` row must be WARN, and the table or log must show 2. The red case is the scaffold from 9558801, which prints PASS. The control: with zero obeyed lines the row is PASS. Vajra's own scripts/verify-closeout.sh needs no change, because every Vajra session ≥132 blocks. Say that in the summary instead of mirroring the change into a 4th file.

rec 7 — Record a separate finding, F107 or the next free number: the WARN text says a project's session "predates this gate (threshold: session 132)", which is Vajra's own numbering, so it is wrong for any other project. The founder approved only the WARN row, so do not fix it here.

The message is at src/obeyed/mod.rs:520–527. This needs a founder call, not a silent rewrite.

rec 8 — F105: put the new step second, right after the tech-lead step, not first.

Putting it first breaks `an_untouched_session_starts_with_the_tech_lead` (src/nextstep/mod.rs:370, which asserts "YOUR NEXT STEP: the tech-lead"). Second is still far ahead of the review stamp, which is what rudra S16 hit.

Find the helper in the same order the close script uses: `<root>/scripts/lib-ground-truth.sh`, then `<root>/.ai/hooks/lib-ground-truth.sh`. Run `bash -c '. "$lib"; vajra_session_type N "$root"; printf %s "$VAJRA_TYPE_STATE"'`. The step is done only when the state is `declared`. Its "how" text names the state (missing / unknown / conflict / noprompt) and the four allowed values. If the helper or bash is missing, the step shows not-done with "run `vajra init --sync-fleet`". Never fall back to a Rust parser.

This is the first time Rust calls the bash helper, so it is a design choice. Add one line to the DECISION-011 addendum or to `## Design`.

rec 9 — The F105 check must show by actually running it that the step reads the shared helper, not a Rust copy.

In a temp project, run `vajra next --steps 1` three times:
- no `session_type:` line: the step is open and names "missing";
- `session_type: CODE`: the step is done;
- `session_type: code`: the step is open and names "unknown".

Then edit the project's copy of `.ai/hooks/lib-ground-truth.sh` to remove `CODE` from the allowed list. The same prompt must flip to open. Only a step that reads the helper can flip. That proves there is one source of truth without grepping source. With the helper deleted, the step must be open and name `--sync-fleet`.

rec 10 — F102 check: run `cargo test --test approvals_guard no_jq_advises_at_l1_and_blocks_at_l2`, and require that the host itself has jq. Without jq on the host, the check proves nothing.

Be honest about the limit: the Linux `/bin`=`/usr/bin` layout that failed CI cannot be recreated locally without a container. Put the CI run links in the summary (main red from #219's merge, green on this branch) as the evidence that it fails without the fix.

rec 11 — Do not put Acceptance 3 into verify-session-183.sh. Show it as written evidence in the summary (step 13).

A check that reads `~/playground/rudra` fails for the cold reviewer and in CI, which is a red for the wrong reason. Acceptance 2 only asks for checks on fixes, and 3 is a process rule.

rec 12 — Keep each fix to at most 3 files per commit, and commit F106, F103 and F104 before you start F105, so the cut line is a clean branch point.

The likely file sets:
- F106: verify-closeout.sh, verify-closeout-scaffold.sh, verify-session-183.sh (3 files).
- F103: init.rs and verify-session-183.sh (2 files).
- F104: obeyed/mod.rs, verify-closeout-scaffold.sh, verify-session-183.sh (3 files).
- F105: nextstep/mod.rs and verify-session-183.sh (2 files).

If time runs out mid-F105, revert its working-tree changes and record "deferred to S184" rather than closing half-built.

## Ambiguities, stated plainly
- F103: "don't block" conflicts with piped answers being supported (rec 4). The wait time and the fall-back-to-defaults rule are the author's call, to be written down.
- F104: "the count" could mean the count of unjudged lines or the count of WARN rows. I read it as the number of unjudged `obeyed:` lines (34 in rudra S16).
- F105: "near the start" could mean step 1 or step 2. I recommend step 2 (rec 8).

Files relevant to this plan:
/Users/suman/playground/vajra/prompts/183-task-rudra-s16-new-rules.md
/Users/suman/playground/vajra/scripts/verify-session-183.sh
/Users/suman/playground/vajra/scripts/verify-closeout.sh
/Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh
/Users/suman/playground/vajra/scripts/lib-ground-truth.sh
/Users/suman/playground/vajra/src/cli/init.rs
/Users/suman/playground/vajra/src/obeyed/mod.rs
/Users/suman/playground/vajra/src/nextstep/mod.rs
/Users/suman/playground/vajra/tests/approvals_guard.rs
/Users/suman/playground/vajra/scripts/demo-session-143.sh

## Handoff Delta
- `+` new: first plan-advisor handoff for this session (12046 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
