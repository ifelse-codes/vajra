# Session 171 — Interactive: built from the founder's own testing

> **Status:** DRAFT — written together with the founder at the start of the S171 chat, from what he found testing Vajra in his other project. Flip to `APPROVED` when he says so.

## Type
- To be decided with the founder (CODE or DOCUMENT).

## How this session runs (founder, 2026-09-15)
1. Founder shares what he hit testing Vajra in his other project.
2. We write or edit this prompt together — goal, what done looks like.
3. Build in short loops: small change → show it → founder checks → next.

## Findings (founder testing Vajra 0.2.0 on `rudra`, 2026-09-15)
| # | Step | What happened | Severity |
|---|---|---|---|
| F1 | 2 — first commit | Vajra's pre-commit hook blocks the **human's own** "Add Vajra" commit (no approval marker) | 🔴 blocks every new user |
| F2 | 2 — first commit | Error text is jargon: "S93", "un-forgeable env marker", "L3 guard" | 🔴 |
| F3 | 2 — first commit | The suggested fix (`VAJRA_ALLOW_COMMIT=00 git commit`) would still fail — 38 files > 3-file cap. Only `--no-verify` works | 🔴 |
| F4 | 1 — `vajra init` end | Says "`git add .ai/` → `vajra claude`" — never says commit; doesn't warn the commit will be blocked | 🟡 |
| F5 | guide | S170 guide said 39 files; real = 38 created + 1 skipped | ⚪ |
| F6 | 3 — session 00 close | Founder said `ship it`; agent still can't commit — hook needs `VAJRA_ALLOW_COMMIT=00` in the **launch** env. Agent hands back 3 `!` commands or "restart with the env var". Chat approval does nothing. Founder: "a kill for someone new" | 🔴 |
| F7 | 3 — session 00 close | Agent skipped the "3 next options → founder picks → agent writes prompt 01" step; `prompts/01-task-kickoff.md` left empty. Founder had to ask for it. Vajra didn't force it | 🔴 |
| F8 | 3 — session 00 close | No demo at all. Agent: "docs-only session, nothing to show". Founder expected to SEE what session 00 did (e.g. what Vajra learned about his project) | 🟡 |
| F9 | 3 — session 00 close | Agent's explanation leans on Vajra words ("rails", "Analyst gate", "M1 spine") — new user can't follow | 🟡 |
| F10 | 3 — prompt 01 written | Founder again handed commit commands to type (same root as F6) | 🔴 (repeat) |
| F11 | 3 — prompt 01 written | To approve the plan the founder must hand-edit the file ("flip to APPROVED, drop your token in the file"). Saying "approved" in chat isn't enough | 🟡 |
| F12 | 3 — prompt 01 written | Agent contradicts itself: S00 docs-only = "no demo", but S01 (also docs-only) "is where the first demo appears" | ⚪ |
| F13 | after session 00 | Nobody says how to finish session 00: branch never merged to `main`, never pushed. Guide + agent jump straight to "new chat, session 01" | 🔴 |
| F13b | after session 00 | Founder asks "doesn't Claude/Vajra merge it if I ask?" Checked rudra's hooks: agent CAN local-merge (nothing blocks), but push / PR / PR-merge are blocked by the publish-guard unless launched with `VAJRA_ALLOW_PUBLISH=1` — same "chat approval doesn't count" wall as F6 | 🔴 |
| F14 | `vajra next` | Shows "✓ Analyst framed what to build" while prompt 01 is still DRAFT; also says "approval token in chat before any commit" — but chat approval doesn't work (F6) | 🟡 |
| F15 | after merge | Agent merged locally then offers `git push origin main`. Vajra's own pre-push hook forbids pushing `main` ("open a PR instead") AND the publish-guard blocks the agent's push — but a PR is now impossible (branch == main). Local-merge path strands the work off GitHub; Vajra never told the agent to go branch → PR → merge | 🔴 |
| F26 | after the fixes | `vajra init --sync-fleet` upgraded 5 files in rudra but NOT `.githooks/pre-commit` / `pre-push` — the only guard it could never update, so the human-vs-agent fix would never reach an existing project. Both are sync targets now (stamped) | 🔴 |
| F16 | exit receipt (session 00, opus-4-8) | Receipt estimate **~$19.33**; Claude Code's own status line showed **"Est. usage: $8.38"** for the same session → Vajra is **2.3× higher**. Session 01 receipt: **~$54.47** (cache-w $28.90, cache-r $18.59) — Claude Code figure not captured. Biggest lines: cache-write $8.85, cache-read $6.84 — suspect cache pricing. Text is jargon: "authoritative", "JSONL", "total_cost_usd", "cache-r/cache-w" | 🟡 |
| F17 | session 01 start | Co-pilot loader stops the agent's edit with a red "hook error" ("load TASK.md + ROADMAP.md first"). Agent recovers on its own, but it looks like a failure to the user | ⚪ |
| F18 | session 01 end | Demo skipped AGAIN until founder asked "why no demo?" (repeat of F8). Nothing made it happen before asking for commit | 🔴 (repeat) |
| F19 | session 01 demo | **Code bug:** `scripts/demo-kit.sh:266` checks `session=$n` with `n=01`, but `vajra --demo-facts` prints `session=1` → facts fail for every zero-padded session (00–09 = every new project's first 10). Agent hand-patched its demo around it | 🔴 |
| F20 | session 01 | **Zero helper agents ran** — no tech-lead (the "FIRST and mandatory" one), no reviewer, no QA, no demo-producer. Agent's reason: Claude Code's own instructions say "don't spawn agents unless the user asks" — that beats Vajra's mandate. Only caught at close | 🔴 |
| F21 | session 01 | Vajra says "3 of 8 roles passed" — but those are prompt sections, not agents that ran. Looks like crew work that never happened | 🟡 |
| F22 | session 01 end | Agent asks the founder whether to run the crew and which roles — a new user can't answer that | 🟡 |
| F23 | session 01 close | **Code bug (same family as F19):** `verify-closeout.sh:364,399` build `verify-session-${N}.sh` / `session-${N}-review.md` with unpadded N=1, while everything else is `01`. Agent had to add duplicate files: `verify-session-1.sh`, `demo-session-1.sh`, `session-1-review.md` — now clutter in rudra | 🔴 |
| F24 | session 01 close | Review "attestation" hashes `.ai/handoffs/`, so committing the crew's handoffs broke it → extra re-attest commit. 8 commits for a docs-only session, 3 of them paperwork | 🟡 |
| F25 | session 01 close | Agent did NOT show the 3 options for session 02 or let founder pick — just announced "next: risk crate". No `prompts/02-*` written (repeat of F7) | 🔴 (repeat) |

## What worked (session 01, launched `VAJRA_ALLOW_COMMIT=01 VAJRA_ALLOW_PUBLISH=1 vajra claude`)
- W1: "start session 01" → clear boot box: type, goal, deliverables, 4-step plan, 8 specs checked.
- W2: Founder said "approved, branch and start" in chat → agent flipped the prompt to APPROVED and made the branch itself (softens F11: works in chat once the session is running).
- W3: Session 01 finished on its own: readiness doc (8/8 specs), verify script 11/11 exit 0, summary + 3 candidates, zero code touched. Stopped to ask for commit approval + one real project decision — right moments to stop.
- W4: Once asked, the crew ran for real (tech-lead → qa-specialist + fidelity-reviewer). **The reviewers caught a real contradiction** in the founder's project docs (OQ-7) — the crew added value.
- W5: Full close worked with the two launch settings: PR #1 opened + merged on GitHub, closeout 16/16, branch pruned, main synced.

## Goal
1. _Filled in from the founder's findings at session start._

## Deliverables
1. _Filled in with the founder._

## Acceptance
1. _Filled in with the founder — each item something he can check himself._

## Guardrails
- No new checks or gates on Vajra's own paperwork (no more policing).
- Show each step before the next; stop when the founder says stop.
- Background from S170: `sessions/session-170-ground-truth.md` (release 0.2.0 half done; lighter-session table; first-run confusions).
