# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-175-keep-testing` — S175 complete on its branch; PR to open (the founder merges).**

## What was done this session (S175 - interactive, the founder's rudra session 06)

- **Deliverable 0:** `N % 5 == 0` ("ground truth") was hardcoded in **6** places, not the 2 the brief named — also `hook-pre-bash.sh` (would have BLOCKED this session's own first `git commit`, since 175 % 5 == 0 — a live self-block, not a paperwork gap), `hook-pre-write.sh`, `hook-prompt-submit.sh`, `hook-stop.sh`. All 6 now read `.ai/CONSTRAINTS.yaml#ground_truth_next_session` (set to 180), falling back to the untouched old rule when the key is absent.
- He ran rudra's session 06 under the fix (his paste was only the cost receipt; findings mined from the real transcript). **Confirmed fixed:** F59/F62 (boot hands over correctly, `vajra next --steps` re-read 3×) · F60 (the 4 waiting Vajra files named and committed first). **Not exercised this run** (no block fired to test): F58, F61/F63. **Still untested live:** the `cwd`/worktree push assumption.
- **F65 (new, fixed):** he launched with `VAJRA_ALLOW_PUBLISH=1` (new). That gate allowed ALL FIVE guarded publish actions with no distinction, so the agent ran `gh pr merge` on both its own PRs, itself, unsupervised — contradicting F55 (S173): "merging stays with the human." Founder confirmed and it was fixed: `hook-publish-guard.sh`'s `VAJRA_ALLOW_PUBLISH=1` bypass now excludes merge, always, no env var.
- **F66 (new, NOT fixed — disclosed):** `vajra next --check-crew` checks a handoff file exists ON DISK, never that it's git-tracked — the exact gap that left rudra S06 with 2/8 required handoffs uncommitted, needing a same-morning fixup PR. Watch-only per Guardrails (no new gate on Vajra's own paperwork without the founder's yes).
- **Process:** tech-lead required qa-specialist + fidelity-reviewer. qa-specialist's own live execution found `verify-session-175.sh` initially covered only 3 of the 6 fixed sites — closed in the tracked artifact (AC1h-k), not just narrated in a handoff. Cold review: **ACCEPT, 11/11 SHIPPED**, and it found a real fakest green (AC1a/b comparing two functions reimplemented inside the verify script against each other — retired, rebuilt against the real `hook-session-start.sh`) plus an overclaiming header banner (corrected) — fixing the former surfaced and fixed a second, unrelated real bug (AC3 silently diffing `HEAD` against itself once this session's own fix had landed there). 13/13 `obeyed:` dispositions independently judged by release-coordinator, 0 mismatch.
- Verify 18/18 (all real hook/script executions, not source-grep, except one disclosed structural floor).

## Previous session (S174 - interactive, the founder's rudra session 05)

- F58–F63: six fixed (his call: all of it). F31 clean a fifth time. `sessions/session-174-summary.md`.

## What Currently Works

- The close gate refuses made-up evidence: prose/malformed/non-existent `done:` shas, unlanded plan steps, unbacked verdict claims, a CODE session with no tech-lead (S169).
- A demo that cannot be faked: command-backed checks, Vajra-filled numbers, gate re-derives facts at close (S168).
- Terminal demo deck for every Vajra project: `scripts/demo-kit.sh` + the seven-section template (S167).
- `vajra init --sync-fleet` upgrades fleet roles + hooks + constitution + close gate + demo template + kit.
- 10-role fleet, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`); 8 stations + closeout gate (19+ checks); tamper-evident ledger; receipts.
- **The ground-truth cadence is config-driven (S175):** `.ai/CONSTRAINTS.yaml#ground_truth_next_session` overrides the every-5th default in all 6 sites that read it; absent behaves byte-for-byte as before.
- **`VAJRA_ALLOW_PUBLISH=1` no longer covers merge (S175):** `gh pr merge`/`glab mr merge` always fall to the founder, matching the boundary `VAJRA_ALLOW_COMMIT` (F55) already held.

## What Is Broken / Weak / Disclosed

- **🟡 Release 0.2.0 half done** — tag `v0.2.0` + GitHub release out; **crates.io still 0.1.0** (founder types `cargo publish`); brew tap formula is at 0.2.0 but install-smoke not run (ROADMAP `S168-release`). A stranger's `cargo install` gets none of S167–S175. Founder's own installed `vajra` is 0.2.0 (reinstalled for S174's fixes, 2026-09-22 — not yet rebuilt with S175's bash-only changes, which need no rebuild since nothing in `src/` moved).
- **🟡 S169 fakest green:** the claim match is words only; claimed-evidence proves files exist, not that they are real; a made-up `done:` sha is still waivable; `git cat-file -e` accepts any old commit → **parked — policing** (ROADMAP `S171-parked`).
- **🟢 F31 clean six times (S171–S176 evidence pending; S171–S175 confirmed).**
- **🔴 The backstop is gone (S172, disclosed):** a skipped `verify-closeout.sh` used to be caught at the next session's start; it is caught nowhere now. Running the close check on the branch before the merge is the whole enforcement story, and it is a text rule. DECISION-007 S172 addendum.
- **🟡 `shipped_close()` keys on one file** — landing a summary on main early downgrades the closing gates to reporting while a session is live (self-granted jurisdiction, disclosed).
- **🟡 F50/F44 — not fixed in code (S173, by decision):** a commit message that mentions a guarded command still blocks; the block names `git commit -F <file>` / `--body-file`.
- **🟡 F55's `cwd` assumption:** still unverified live — no rudra session has used a worktree yet (S06 didn't either).
- **🟡 The guards' old-vs-new check is a list (S173):** named shapes × triggers; a spelling nobody listed is not covered.
- **🟡 Parked LOW (S173):** F47 copied jargon · F56 the session guard cannot tell a command runs in another project · F57 the Coder check reads only `1. …` plan steps.
- **🟡 F66 (new, S175, disclosed, not fixed):** `--check-crew`/`read_handoff` checks a handoff file's presence on disk, never that it's git-tracked — a session's required crew can close with real handoffs left uncommitted. Same bug family as F60 (Vajra's own sync files), different target. No new gate on Vajra's own paperwork without the founder's explicit yes (Guardrails).
- **🟡 `scripts/verify-closeout-scaffold.sh` (the `vajra init` template) does not carry the S175 cadence-config fix** — deliberate, disclosed (DECISION-007 S175 addendum): a new project has no reason to move its first ground truth on day one, and this file already lags the live gate on other counts (S154's execution-sha tightening, cargo-fmt).
- **🟡 `.ai/ROADMAP.md`'s "NN % 5 == 0 → mandatory NO-CODE GT" pointer line had gone stale for many cycles** (last hand-updated at S120/S125, corrected at S175 to S170/S180) — a reminder that a hand-maintained "next X" pointer drifts unless something derives it.
- **🟡 Not tested:** Windows; a real light-background terminal. **Zero external users**; prove-then-cut-cost arc unstarted; Autopilot Rung 2/3 incomplete.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S175 closed on its branch; PR to open. S176 = the founder's pick (see `sessions/session-175-summary.md`'s 3 ranked candidates).

## Active PRs

- S175's, once opened. S174 merged as #211.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S175 | $0 | No paid run in this repo; the founder's own rudra run supplied the findings. 4 fleet dispatches (tech-lead, qa-specialist, fidelity-reviewer, release-coordinator as judge) |
| S174 | $0 | No paid run; the founder's own rudra run supplied the findings. |
| S173 | $0 | No paid run; the founder's own rudra run supplied the findings. 11 fleet dispatches (tech-lead, design-advisor, 9 fidelity-reviewer passes) |
| S172 | $0 | No paid run; the founder's own rudra run supplied the findings. 4 fleet dispatches (tech-lead, qa-specialist, design-advisor, fidelity-reviewer) |
| S169 | $0 | No paid run; bash gate + scripts + fleet subagents only |
| S168 | $0 | No paid run; code + scripts + fleet subagents only |
| S167 | $0 | No paid run; code + scripts + fleet subagents only |
| S166 | $0 | No paid run; bash scripting + verify + demo scripts only |
| S161 (Part 2 — D2 dogfood) | null | `total_cost_usd` not in JSONL; token estimate ~$14.15 (not authoritative) |

## Direction (governance is the product)

- **Product = provable agent governance** (`DECISION-001`). Direction (2026-09-15): **no more policing — reach a real user.** Founder tests Vajra himself; sessions are interactive from S171.
- **Founder priorities (S140/S160):** (1) fresh-user experience + release; (2) prove it works, then cut cost; (3) self-driving unattended close / Rung 2–3; (4) external adoption.
