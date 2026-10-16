# Session Boot

## Next Session
- **S202 — PAUSE: no Vajra development; use Vajra on another project** (founder, 2026-10-17). In YOUR terminal on main, after S201's PR merges: `git pull --ff-only`, then `cargo install --path . --locked` (S201 touched `src/`). Pick the project (rudra or a new one) and write down what "helpful" means before its first session. Come back to this repo only with a finding that blocks that project's work: read `prompts/202-task-pause-use-elsewhere.md`, run `vajra approve 202`, start S202 in a FRESH chat.

## Current Session
- **Number:** 201 — COMPLETE on `session-201-small-fixes` (PR open). CODE: the S200 small fixes. **N24** a review-only session's sign-off step says "write the report" first, and its verify/demo steps read "not needed" (the close passes them N/A) · **N22** verify-178/demo-178 RETIRED as history · **N25** in Vajra's own repo the merge step says to reinstall `vajra` · the README "tested with" line in the founder's words. N28 filed. **Founder (2026-10-17): pause Vajra development; use it on another project.** Summary: `sessions/session-201-summary.md`. Review: `sessions/session-201-review.md`. Verify: `scripts/verify-session-201.sh` (5/5). Demo: `scripts/demo-session-201.sh` (6/6).

## Prior Session
- **Number:** 200 — COMPLETE on `session-200-ground-truth` (PR open). NO-CODE ground truth, 🟡 PARTIAL PASS, signed off by the founder's `vajra approve 200 --close` (the first GT sign-off that is a record). 13 audits live; close-truth question's first use: 5 closes, no mismatch on the close check (rudra S21's "nothing half-done" named, F126). Founder: N22 retire, N23 keep, pick C. N24–N27 (N27 fixed here). Report: `sessions/session-200-ground-truth.md`. Review: `sessions/session-200-review.md`. Summary: `sessions/session-200-summary.md`.

## Prior Session
- **Number:** 199 — CLOSED (merged #238). Was on `session-199-all-pending-bugs`. CODE: every pending known bug, all nine, none moved out. **F126:** a real stamp run — the next prompt, the summary, `.ai/` TASK/STATE/ROADMAP leave the stamp; this session's own prompt, a handoff or code move it — the step list says where a late founder change goes (no new rule). **Sign-off step** on review-only sessions (`vajra approve NN --close`). **N19** CRLF kept · **N20** Prior entries untouched · **N21** two prompts refused by name · **N14** a close-truth ground-truth question (ships via `--sync-fleet`) · `latest` a link (founder's yes) · `gt_cadence_shared` exact · rest of N7. N22 filed. Summary: `sessions/session-199-summary.md`. Review: `sessions/session-199-review.md`. Verify: `scripts/verify-session-199.sh` (9/9). Demo: `scripts/demo-session-199.sh` (5/5).

## Prior Session
- **Number:** 198 — CLOSED (merged #236). Was on `session-198-known-bug-leftovers`. CODE: the known-bug leftovers. **F118 fixed:** `vajra next --advance` moves the old `## Current Session` entry, byte-for-byte, to the first `## Prior Session` on Vajra's shape (other shapes keep the number swap and say why) — live on this session's own advance. **N18 fixed:** check 6 sorts by the file name's number, prints `scanned:`. N19, N20 filed. Summary: `sessions/session-198-summary.md`. Review: `sessions/session-198-review.md` (ACCEPT 5/6, recs answered). Verify: `scripts/verify-session-198.sh` (4/4). Demo: `scripts/demo-session-198.sh` (5/5).

## Prior Session
- **Number:** 197 — CLOSED (merged #235). Was on `session-197-known-bugs`. CODE: the known-bug session. **F125 premise corrected:** user projects never had the review-only guard; founder: ship it — one `hook-ground-truth-guard.sh` via `vajra init` / `--sync-fleet`, no branch name opens it (`-closeout`/`-enforcement`, `VAJRA_GT_WAIVER`, another session's number), only `vajra approve NN --close` (DECISION-011 S197 addendum). N17, F116, F119, N10 fixed; F118 moved out (founder); N18 filed. Summary: `sessions/session-197-summary.md`. Review: `sessions/session-197-review.md` (ACCEPT 10/12, recs fixed). Verify: `scripts/verify-session-197.sh` (13/13). Demo: `scripts/demo-session-197.sh` (5/5).

## Prior Session
- **Number:** 196 — CLOSED (merged #234). Was on `session-196-rudra-s21`. INTERACTIVE: rudra S21 on Opus 5.5 — every instruction-only step ran (4 helpers, 18 `vajra next`, a real review), close GREEN 21/0, "fully closed" true, $19.21 = Claude Code's own cost-state. F121's box could only show after the merge; F123 not exercised. **F127 fixed (founder: "no pr creation till it is not green"):** `.githooks/pre-push` stops an agent's push of a session branch without a GREEN close for that exact commit; close result format 2 (`head:`, `clean:`) (DECISION-007 + ADR-0004 S196 addenda). F126 parked. Summary: `sessions/session-196-summary.md`. Review: `sessions/session-196-review.md` (pass 2 ACCEPT 6/8). Verify: `scripts/verify-session-196.sh` (10/10 + 4 records). Demo: `scripts/demo-session-196.sh` (5/5).

## Prior Session
- **Number:** 195 — CLOSED (merged #233). NO-CODE ground truth, 🟡 PARTIAL PASS, founder approved as written. 13 audits live; the Haiku answer (blocks stopped, the close check detected and stopped nothing, steps skipped → (c) a "tested with" fact, then (d) Vajra runs the reviewer itself); F125/F116/F118/F119/N10 → S197; N11 + verify-131 stale checks dropped; N14–N17. Report: `sessions/session-195-ground-truth.md`. Review: `sessions/session-195-review.md`. Summary: `sessions/session-195-summary.md`.

## Prior Session
- **Number:** 194 — CLOSED (merged #232). INTERACTIVE: rudra S20 (its ground truth) on Haiku 4.5 — $1.49 = Claude Code's own cost-state, one line (F117 live). Its close went RED (5 fail) but the agent said "fully closed". **Fixed:** F121 the exit box shows the close check (ADR-0004 S194 addendum) · F123 `.githooks/pre-merge-commit` · F120 `--role --from` refuses a transcript (DECISION-007 S194 addendum). F125 parked (known bugs). Summary: `sessions/session-194-summary.md`. Review: `sessions/session-194-review.md`. Verify: `scripts/verify-session-194.sh` (11/11 + 1 record). Demo: `scripts/demo-session-194.sh` (5/5).

## Prior Session
- **Number:** 193 — CLOSED (merged #231). INTERACTIVE: rudra S19 under the trusted receipt — $37.27 = Claude Code's own cost-state. **F117 fixed:** with Claude Code's own figure the receipt shows only that figure (ADR-0004 S193 addendum). F116/F118/F119 parked as known bugs (ROADMAP backlog, S195 checklist). Summary: `sessions/session-193-summary.md`. Review: `sessions/session-193-review.md`. Verify: `scripts/verify-session-193.sh` (11/11 + 1 record). Demo: `scripts/demo-session-193.sh` (5/5).

## Prior Session
- **Number:** 192 — CLOSED (merged #230). CODE, interactive: the receipt proven live — rudra $6.90/$22.96 = Claude Code's own cost-state; fresh $0.02, `--continue` $0.01 (this run's share), a fork labelled whole-conversation ($0.03; **a fork keeps the parent's `startTime`**, S189's assumption verified); `/clear` skips (named, founder 2026-10-09). The transcript folder is named by Claude Code's own rule (every non-alphanumeric → `-`, >200 hashed, `CLAUDE_CONFIG_DIR`) in the meter, `vajra meter --all` and dispatch's handoff provenance. ADR-0004 S192 addendum. Summary: `sessions/session-192-summary.md`. Review: `sessions/session-192-review.md`. Verify: `scripts/verify-session-192.sh` (6/6). Demo: `scripts/demo-session-192.sh` (5/5).

## Prior Session
- **Number:** 191 — CLOSED (merged #229). CODE: four small fixes from the S190 review. N2 — a ground-truth Write outside the project passes (symlinks resolved + an inode walk; `..` refused) · N13 — the session guard reads one quoted `cat`/`tee` heredoc shape's body as data · `--advance` moves only the `**Number:**` token (proven on its own advance) · verify-133 safe twice at once. DECISION-011 S191 addendum. Summary: `sessions/session-191-summary.md`. Review: `sessions/session-191-review.md` (ACCEPT 9/9). Verify: `scripts/verify-session-191.sh` (65/65). Demo: `scripts/demo-session-191.sh` (8/8).

## Prior Session
- **Number:** 190 — CLOSED (merged #228). NO-CODE ground truth, 🟡 PARTIAL PASS. 13 audits; 10 checklist sub-items picked (4 → S191); N10–N13. Report: `sessions/session-190-ground-truth.md`. Review: `sessions/session-190-review.md`. Summary: `sessions/session-190-summary.md`.

## Prior Session
- **Number:** 189 — CLOSED (merged #227). CODE: F67 — an interactive receipt's top line is Claude Code's own figure (the transcript's `cost-state` line, this run's share) or "no cost from Claude Code for this run"; the price list only feeds labelled `[estimate]` lines; no price rows (ADR-0004 S189 addendum). Proven on recorded lines and a stand-in, not a live interactive run. Summary: `sessions/session-189-summary.md`. Review: `sessions/session-189-review.md` (ACCEPT). Verify: `scripts/verify-session-189.sh` (20/20). Demo: `scripts/demo-session-189.sh`.

## Prior Session
- **Number:** 188 — COMPLETE (merged #226). CODE: the approvals folder — the Bash word guard replaced by a before/after check; a change voids the approvals until `vajra approve NN` (DECISION-011 S188 addendum). F110 closed. Of 76 commands the old guard blocked: 45 caught after they write, 31 pass. Live run $0.03. Summary: `sessions/session-188-summary.md`. Review: `sessions/session-188-review.md`. Verify: `scripts/verify-session-188.sh` (11/11). Demo: `scripts/demo-session-188.sh`.

## Prior Session
- **Number:** 187 — CLOSED (merged #224). CODE: the guard message and the S190 leftovers (rewritten with the founder; rudra S18 paused). The approvals guard says how to get past a joined read — what blocks is unchanged (F110 fix C) · `--steps` names a missing approval (N4) · `--sync-fleet` adds a project's missing ground-truth audits and questions, refusing any shape it cannot read exactly (F97, DECISION-007 S187 addendum) · verify-133 green · ROADMAP header derived (N6) · old checkouts in one folder (N7, newest scripts) · `--dogfood-age` says "THIS repo only" (N5, named not closed). N2 → backlog, a known issue (founder). Summary: `sessions/session-187-summary.md`. Review: `sessions/session-187-review.md` (ACCEPT). Verify: `scripts/verify-session-187.sh` (14/14). Demo: `scripts/demo-session-187.sh`.

## Prior Session
- **Number:** 186 — CLOSED (merged #223). CODE: the S185 fixes. F113 `obeyed_blocks_from:` (only Vajra's file sets it; projects warn, saying why; a bad key blocks naming its line) · S182 recs 1/2/5 add-only (`..`, more writers/shells/awk, no duplicate hooks) · F114 a fresh project's ledger speaks · F115 verify-132 green for the first time since S135 · N1 block reasons on stderr. **F110 (b) split out by the founder** after two cold-review REJECTs; the S182 redirect rule is back, its block names `git commit -F`. Summary: `sessions/session-186-summary.md`. Review: `sessions/session-186-review.md`. Verify: `scripts/verify-session-186.sh`. Demo: `scripts/demo-session-186.sh`.

## Prior Session
- **Number:** 185 — CLOSED (merged #222). NO-CODE ground truth, 🟡 PARTIAL PASS. Picked F113 → `obeyed_blocks_from:`, F110 → (b); F114, F115, N1 → S186. Report: `sessions/session-185-ground-truth.md`.

## Prior Session
- **Number:** 184 — CLOSED (merged #221). INTERACTIVE: rudra S17 under the new rules + F103/F107/F108. `vajra init` waits 10 s per answer on a silent pipe, then uses the defaults and says so (F103); the unchecked-claims warning names no Vajra session number and says "in this session" (F107); `--ledger`/`--ledger-verify` leave no empty folder (F108). rudra S17: GREEN with 2 honest WARN, 8/8 stations; F109–F113 all have the founder's call (F110 + F113 → S186, then fixed). Summary: `sessions/session-184-summary.md`. Review: `sessions/session-184-review.md`. Verify: `scripts/verify-session-184.sh` (14/14). Demo: `scripts/demo-session-184.sh` (7 live checks).

## Prior Session
- **Number:** 183 — CLOSED (merged #220). INTERACTIVE: rudra S16 under the new rules + F101. The close now runs CI's lint on CI's Rust version (not CI's tests, not Linux): `rust-toolchain.toml` pins Rust 1.99.0 and `scripts/ci-lint.sh` is the one lint both run (F101); main's red CI since #219 fixed (F102); unchecked `obeyed:` claims WARN with the count (F104); the step list names the session type at the start (F105); `--inputs-sha` leaves no empty folder (F106). F103/F107/F108 asked. Summary: `sessions/session-183-summary.md`. Review: `sessions/session-183-review.md`. Decision: DECISION-011 S183 addendum. Verify: `scripts/verify-session-183.sh` (24/24). Demo: `scripts/demo-session-183.sh` (6 live checks).

## Prior Session
- **Number:** 182 — CLOSED (merged #219). CODE, interactive: ship S181's controls into existing projects — one approvals guard (writes block, reads pass), shipped + wired by `--sync-fleet`, `session_rules_from` reported, `--allow-all=NN`, S181's two test gaps, rudra upgraded live. Summary: `sessions/session-182-summary.md`. Review: `sessions/session-182-review.md` (pass 2 ACCEPT 14/15). Verify: `scripts/verify-session-182.sh` (15/15).

## Prior Session
- **Number:** 181 — CLOSED (merged #218). CODE, interactive: shared ground-truth helper + smart one-time override · strict `session_type:` · `vajra approve` / launch-time yes / `--allow-all` · named waivers · text-bound stamps · `session_rules_from`. Summary: `sessions/session-181-summary.md`. Review: `sessions/session-181-review.md` (pass 1 REJECT → pass 2 ACCEPT). Decision: DECISION-011. Verify: `scripts/verify-session-181.sh` (13/13). Demo: `scripts/demo-session-181.sh` (6 live checks).

## Prior Session
- **Number:** 180 — CLOSED (NO-CODE ground truth, PARTIAL PASS). Report: `sessions/session-180-ground-truth.md`. Merged #217.

## Prior Session
- **Number:** 179 — CLOSED. CODE, interactive: F89 (`--help` ran the command) + F90 (`init` ignored unknown words) fixed; rudra S14 + S15 (OpenCode) → F91–F97; F93 fixed (a project's ground truth leads with the project). Summary: `sessions/session-179-summary.md`. Review: `sessions/session-179-review.md`.
  Verify: `scripts/verify-session-179.sh` (37/37). Demo: `scripts/demo-session-179.sh` (6 live checks).

**New chat.**
