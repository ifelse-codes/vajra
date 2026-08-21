## Release Coordinator brief — Session 126 (`session-126-finish-the-fleet`)

**Verdict: NOT shippable yet.** The work exists on the branch, but the closeout bundle that the gate re-derives from is not assembled. I have not run git; every state claim below says what I read and what I am inferring from it.

### The three recorded gate keys (what the Releaser will re-derive)
- `require_merged_prior` — the session branch merged into `main` by ancestry. **Inferring UNMET:** the task states S126 is not merged, and I cannot observe ancestry (no git). This is the expected pre-ship state, not a defect.
- `require_main_synced` — local `main` neither behind nor diverged from `origin/main`. **Cannot observe** — I have no fetch and no git. Blind spot: `origin/main` is only as fresh as the last human fetch; I am not reporting it as green.
- `require_pruned` — merged `session-*` branches deleted locally. **Cannot observe.** Note the standing blind spot: a branch deleted *before* it was merged looks identical to one deleted after — the gate cannot tell them apart.

### What blocks the ship right now (from files I read, not git)
1. **`## Execution` shas are still placeholders.** `prompts/126-task-finish-the-fleet.md` lines 88–95 all read `done: <sha>`. `verify-closeout.sh check_execution_shas` BLOCKS on the literal `done: <sha>` (exit 1) for a CODE session. This is called out in the prompt's own carry-forward (S119/S122/S124 each left these unfilled). Blocks L4.
2. **No independent fidelity review file.** `sessions/session-126-review.md` does not exist (Glob: no files). `check_fidelity_review` FAILS without it; `check_review_attestation` then has nothing to attest. Criterion 8 requires an ACCEPT, attested. Blocks L4.
3. **No session summary.** `sessions/session-126-summary.md` absent. `check_session_pair` requires each summary to pair with a prompt; more directly, Session Loop step 7 is unmet.
4. **No per-session verify/demo scripts.** `scripts/verify-session-126.sh` and `scripts/demo-session-126.sh` both absent. `check_verify_demo_scripts` BLOCKS (S126 is CODE — `126 % 5 != 0`, not waivable as NO-CODE). Blocks L4.
5. **`.ai/` closeout sync not done.** `.ai/SESSION` still reads `125`; SESSION-BOOT/STATE describe S125 as current and S126 as "next". `check_session_boot`, `check_task_ref`, `check_roadmap_current` all compare against N and would DRIFT until synced.
6. **Uncommitted / untracked working tree.** The opening git status showed `sessions/session-126-artifacts` and many other paths as untracked (`??`). I am inferring from that snapshot only — it was a point-in-time capture and I cannot re-run git. Anything meant to ship must be committed with the `VAJRA_ALLOW_COMMIT=126` marker (max 3 files/commit) before the PR reflects it.

### Ordered ship sequence (the order the gate checks — a step out of order is why the *next* session's gate blocks)
Everything below is a human act. I propose; I do not push, merge, or prune.

1. **Finish closeout on the branch first** (Session Loop steps 5, 7, 9): fill the eight `## Execution` shas with real landing commits; write `sessions/session-126-summary.md` with the SHIPPED/PARTIAL/NOT-BUILT map; add `scripts/verify-session-126.sh` + `scripts/demo-session-126.sh` (both exit 0); sync `.ai/` (`SESSION`→126, STATE replace, ROADMAP `[x]`, TASK "between sessions", SESSION-BOOT `**Number:** 126`).
2. **Land the independent cold review verdict:** run the `fidelity-reviewer` cold pass fed only prompt + diff. Attest LAST — after the Execution shas land, confirm two consecutive `verify-closeout.sh --inputs-sha 126` runs agree, then embed the `Review-Inputs-SHA` and a canonical `**Verdict:** ACCEPT` in `sessions/session-126-review.md`.
3. **Run the FULL `scripts/verify-closeout.sh` on the branch, pre-merge, and get exit 0.** Do this *before* the PR is merged — merge-base collapses once `main` absorbs the branch, so the attestation hash must be verified while the branch is still distinct ([[vajra-closeout-verify-must-run-premerge]]).
4. **Open the PR** to `main` (step 6). Not closed until merged.
5. **Merge the PR** (human act) — this is what satisfies `require_merged_prior` for S127's gate.
6. **Return to `main` and pull** — brings local `main` even with `origin/main`, satisfying `require_main_synced`. Its freshness is only as good as this fetch.
7. **Prune the merged `session-*` branches locally** — satisfies `require_pruned`.

### Named blockers, plainly (separate from the steps)
- An **unmerged branch** — S126 is not in `main` (inferred from the task statement; not git-observed).
- **Closeout artifacts missing** — placeholder Execution shas, no review, no summary, no verify/demo scripts, `.ai/` unsynced (`.ai/SESSION` = 125).
- **Uncommitted work** — from the opening snapshot only; must be committed before the PR is honest.

### Founder-gated — raised as questions, never checklist items
The prompt's own non-goals forbid a **release / crates.io publish** this session (S118 directive: no release until reality meets README/VISION). I am **not** proposing a version bump, publish, or announcement. If the founder intends any of those, that is a separate decision to raise explicitly — not a routine ship step here.

### Honest residual to carry (criterion 9)
Even once the roster is complete and merged, **nothing depends on it** — no gate consumes a handoff. "Done" is claimed; "working" is S127's subject. Do not let roster completeness be read as proof the fleet works.

---

**This is a proposal, not the release of record.** Git is the only record of what shipped; every push, merge, and prune stays a human act.