---
role: tech-lead
session: 184
agent: claude-code-subagent (verified: toolu_015pucZuyduhHwg1sn2NfpQE; text-sha: bd8f80dc6e6e0d75d2111e3b7e751e6e676a2cb87b0cea0e6d20462555fae99f)
source-sha: 3ebe230d27191553ee781c8990018b04b3ed33cb40f6a89db63ae88426032d98
captured: 2026-10-03T17:40:31Z
cost_usd: null
---

# Tech-lead handoff — session 184

# Tech-lead handoff — session 184

This phase allows only two verdicts, `required` or `deferred-budget`. Each budget is an instruction I am trusting the role to follow. It is not a hard limit, because Vajra cannot stop a role partway through a run.

**The money facts behind the deferrals**
- S134 measured about 6M raw tokens for each broadly briefed dispatch.
- The plan hit its monthly cap in late September (F82). I have not checked whether it reset, so I treat the account as tight.
- The founder asked for small scope, one cold review and no ceremony.
- The three required roles below come to about 0.42M tokens if each keeps to its narrow brief. Every role added puts its whole budget on top of that.

**What I found while reading**
- **F103:** `prompt()` (src/cli/init.rs:1217-1234) is a plain blocking `read_line`. It is called three times, at lines 91, 92 and 98. A thread stuck in `read_line` cannot be cancelled, so the fix needs one shared reader thread for all three questions, not a new thread for each.
- **F108:** Both close scripts run `mkdir -p "$ARTIFACTS"` at line 46. Only `--inputs-sha` is exempt. `--ledger` (verify-closeout.sh:1315, scaffold:1070) and `--ledger-verify` (1331 / 1086) never write to that folder, so the fix is to widen the line-46 condition the same way in both scripts.
- **F107:** Two pieces of the text quote Vajra's numbering:
  - src/obeyed/mod.rs:509: "(pre-threshold: WARN)"
  - src/obeyed/mod.rs:521-528: "predates this gate (threshold: session 132)"
- **Why the F107 wording matters:** the scaffold's own WARN row (verify-closeout-scaffold.sh:674-675) never says 132, so the number reaches the project's log through the binary's `⚠` lines. Because the threshold is a session number, every rudra session below 132 will show this WARN. The new wording has to say that plainly.

**Crew**

crew researcher — deferred-budget — budget: 40000 tokens — The evidence is already in the named lines above, and the founder brings rudra S17's logs himself. About 0.04M on top of ~0.42M required, on a plan that hit its cap (F82), buys nothing the main session cannot read directly.
crew requirements-analyst — deferred-budget — budget: 40000 tokens — The four acceptance criteria and the three tests are already written in the prompt, and F109… do not exist yet. About 0.04M on a capped account (F82) would compete with the one review slot.
crew design-advisor — required — budget: 80000 tokens — Mandatory role, and `## Design` is assigned to it. Two choices need recording: F103's wait time and the "first timeout means defaults for every later question" rule; F107's way of keeping the number out of project logs without guessing which repo it is running in (S177). Dispatch it ONCE, after the rudra findings are listed. Brief: the prompt, init.rs 85-100 and 1217-1234, obeyed/mod.rs 495-530, and next.rs 992-1002.
crew plan-advisor — required — budget: 40000 tokens — The prompt assigns `## Plan` to it, written after the findings are listed. Brief: the prompt and the findings list only. It produces the step order, `covers: N` for each step, and a cut line for the ~2h cap.
crew implementation-advisor — deferred-budget — budget: 150000 tokens — All three fixes are small (a widened shell condition, a wording change, one reader thread). A code-level review would cost about 0.15M, raising the required total from ~0.42M to ~0.57M on a capped plan (F82). The fidelity-reviewer probes the same code.
crew qa-specialist — deferred-budget — budget: 100000 tokens — Acceptance 2 already requires real-run checks in verify-session-184.sh, and Acceptance 4 requires verify-closeout.sh to exit 0. A second checker costs about 0.1M and breaks the one-review rule on a capped plan (F82).
crew demo-producer — deferred-budget — budget: 40000 tokens — The live proof is the founder's own rudra S17 run plus the verify script. About 0.04M for a separate demo cannot be afforded on a capped plan (F82).
crew fidelity-reviewer — required — budget: 300000 tokens — Mandatory: the one fresh cold review at close. Brief: the S184 prompt, `git diff main...HEAD` over the changed files, the verify-session-184 output, and the findings table with the founder's calls. No whole-repo read.
crew release-coordinator — deferred-budget — budget: 40000 tokens — The founder runs merges and rudra's commits himself, and release/publish is parked. About 0.04M cannot be afforded on a capped plan (F82).

**Recommendations**

rec 1 — Fix F108 by widening the line-46 condition in BOTH close scripts so that `--inputs-sha`, `--ledger` and `--ledger-verify` all skip the dated folder. Test it by counting folders before and after each mode.
A `case "${1:-}" in --inputs-sha|--ledger|--ledger-verify)` branch matches the S183 F106 fix. Check that neither ledger mode reads `$LOG` or `$ARTIFACTS`; from the lines I read, they do not. Run the test against Vajra's own script and against a scaffold copy written by `vajra init` in a scratchpad repo, because the scaffold ships through `include_str!`.

rec 2 — Fix F107 by taking Vajra's session number out of the binary's wording completely. Vajra's own close script can print its own threshold. Do not detect "am I in Vajra's repo" from text.
Rewrite both pieces of text (mod.rs:509 and :521-528) in words a project understands. For example: "this close gate names unchecked claims but does not block them; to check one, record `obeyed-check …`". Say plainly that this applies to every session. Do not suggest building the per-claim judge (founder decision, 2026-10-03). Test: a scaffolded scratch project with one unchecked `obeyed:` closes, and its log has no "132" and no "threshold". The unit tests in obeyed/mod.rs that match the old text will need updating. That is expected, not a regression.

rec 3 — Fix F103 with ONE reader thread and a channel shared by all three questions. Use `recv_timeout` only when stdin is not a terminal. On the first timeout or end of input, use that answer's default and every later default, and print each default used to stderr.
A new thread per question would leave the old one holding stdin, and it would take the next line meant for someone else. The design-advisor picks the wait time; about 3-5 s keeps `sleep 60 | vajra init` near the ~10 s test. Before choosing, check that no script piping answers in (demo-session-08/09/143, verify-session-46/143) pauses between answers for longer than that. Terminal use must stay exactly as it is now: a plain blocking read with no timer.

rec 4 — Land F108, then F107, then F103, ready to commit, before the rudra S17 findings arrive. Keep each to ≤3 files per commit. Fix F109… only when the founder says yes.
F108 is the smallest and safest, and F103 is the only one with a behaviour choice in it, so this order protects the ~2h cap. Test anything that touches the scaffold with `vajra init --sync-fleet` in a scratchpad repo, never in rudra. Check before close that `git -C /Users/suman/playground/rudra log -1` has not changed. Read rudra's logs for WAIVED, N/A and WARN first (S178).

rec 5 — Ask the founder the `cargo test` question at the start and record his answer. Build nothing for it unless he says yes. Close with verify-closeout.sh on the branch before merge, one cold review, and `--inputs-sha 184` computed last.
A green close followed by red CI on Linux (F102) is exactly the gap he is being asked about. Bring it up early, as a plain question, so the answer does not come in as unplanned scope. The merge-base disappears after merge (S83), and the attestation must use `--inputs-sha 184` (S69).

Files referenced:
- /Users/suman/playground/vajra/prompts/184-task-rudra-s17-new-rules.md
- /Users/suman/playground/vajra/.ai/handoffs/session-183-tech-lead.md
- /Users/suman/playground/vajra/src/cli/init.rs (lines 91-98, 1217-1234)
- /Users/suman/playground/vajra/src/obeyed/mod.rs (lines 498-530)
- /Users/suman/playground/vajra/src/cli/next.rs (lines 992-1002)
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (lines 41-46, 1315-1331)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (lines 43-46, 667-677, 1070-1086)

## Handoff Delta
- `+` new: first tech-lead handoff for this session (8184 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
