---
role: release-coordinator
session: 185
agent: claude-code-subagent (verified: toolu_01VNrg4mJBZji74spVCNcnmG; text-sha: 4fc67ba77b2b260b0bf7708b50cacb845e4df29fb9684411708ce44ef579db63)
source-sha: 41e74596fec57f8b5ff4d8a5b6eee6f0d80dfc08f76876264f1bdaeb0ee2d089
captured: 2026-10-04T05:25:57Z
cost_usd: null
---

# Release-coordinator handoff — session 185

S185 ground truth: proposed ship steps (proposal only; a human runs every step)

I can't run git. What I say about branches below comes from reading the files under `.git/`, not from git commands.

rec 1 — Get the founder's written sign-off on `sessions/session-185-ground-truth.md` first; nothing ships before it.
Blocker: the founder.

rec 2 — Founder runs `vajra approve 185` in his own terminal, then `vajra next --advance` moves `.ai/SESSION` from 184 to 185.
Blocker: the founder. The approvals guard stops the agent writing `.ai/approvals/`, and `--advance` refuses until the approval exists (`src/analyst/mod.rs` ~661). `verify-closeout.sh` reads the session number from `.ai/SESSION`, so it can't judge 185 until this is done.

rec 3 — Rename the branch to `session-185-closeout` before any commit or prompt write, as S180 did.
- On `session-185-ground-truth`, `hook-pre-bash.sh` (lines 53-61, 72-90) blocks `git commit`.
- `hook-pre-write.sh` (line 67) blocks writes to `prompts/`. It only allows the report, review files, `reviewer/`, `.ai/` and `scripts/`.
- Both hooks exempt any branch ending in `-closeout` (`CONSTRAINTS.yaml:24`).
- Precedent: `.git/logs/HEAD` lines 1862-1867 show S180 renamed `session-180-ground-truth` to `session-180-closeout`, then made 4 commits: report, SESSION/BOOT/TASK, STATE/ROADMAP, next prompt.

rec 4 — On `-closeout`, use one founder-run commit script in this order:
1. The report plus the three `.ai/handoffs/session-185-*.md` handoffs. The three are tech-lead, design-advisor and this one; the crew and design checks read the handoffs.
2. `.ai/` sync: SESSION, SESSION-BOOT `**Number:**`, TASK = "between sessions".
3. STATE replaced, ROADMAP marked [x].
4. `prompts/186-…` as a DRAFT.
Leave these out: `.claude/launch.json`, `first-mate.html`, `sessions/session-137-scatter-render.html`, `vajra-cto-audit-2026-07-22.html`. They are local artifacts that don't belong in git.

rec 5 — Run the full `scripts/verify-closeout.sh` on the closeout branch before the PR is merged, and get exit 0. After the merge, merge-base checks fall apart.

rec 6 — Founder opens the PR and merges it. Then: `git checkout main`, `git pull --ff-only`, then delete `session-185-closeout` locally. Right now `.git/refs/heads/` holds only `session-185-ground-truth`, and there is no `packed-refs` file, so the S184 branch already looks pruned.

Blind spots:
- `origin/main` is only as fresh as the last fetch, so fetch before checking sync.
- After the rename, `session-185-ground-truth` is gone. A deleted branch looks the same whether or not it was ever merged.

There are no `obeyed:` answers to judge this session, so I recorded no obeyed-check lines. I raise no version bump, publish or announcement.

## Handoff Delta
- `+` new: first release-coordinator handoff for this session (2745 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
