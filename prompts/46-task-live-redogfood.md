# Session 46 — Live re-dogfood: prove the moat fires live (#17a, CODE/VERIFY, PAID)

> **Founder pick at S45 close (A):** schedule S46 as the live re-dogfood. Run the real `vajra claude`
> loop against a scaffolded L3 project and **prove the guards fire live.** This is the move the last
> **four** ground-truths (S30, S35, S40, S45) each flagged: the enforcement moat is architecturally
> complete and paper-sound, but **not live-verified since S36 — when it leaked.** Test-green ≠ fires-live.

## Why this session (the S45 verdict, one paragraph)
The S37→S44 enforcement-completeness arc is **done**: publish-guard + session-guard + `jq`-preflight +
git-level belt + `.claude/settings.json` merge, across L2+L3, greenfield+brownfield, all scaffolded
byte-identical. But since S36 the only proof is `verify-session-*.sh` + `vajra hook` payload replay +
`cmp` byte-identity. The publish-guard was proven **live exactly once** (S37, blocking the agent's own
push in its own build session); S38-scaffold, S39-fixes, S42-jq, S43-git-belt, S44-merge have **zero**
live evidence. This is the identical cliff compression sat on before S31/S36 falsified it (green tests,
dead in the real loop — proven 3× for compression/Darshan/brownfield). **One real run closes it — or
finds the next leak.**

## Goal (single story)
Run the real `vajra claude` loop against a **freshly scaffolded, L3** project and produce **live
evidence** that the moat fires against an autonomous agent — then render the founder-satisfaction gate
verdict **with that evidence**, not on paper.

## Method — cheap first, paid only as needed (the S36 method)
1. **$0 replay pass first.** For each guard, pipe a real-shaped PreToolUse/PostToolUse payload through the
   scaffolded `.ai/hooks/*.sh` (or `vajra hook`) against a temp scaffolded project and confirm the exit-2
   block. This re-confirms S37–S44 at the scaffold site for ~$0 before spending.
2. **Then one real paid run.** `vajra init` a throwaway project (or reuse the S36 `/private/tmp/chitra`
   method), set `maturity: L3`, launch `vajra claude -p` with a task that will make the agent try to
   `git push` / `gh pr create` / advance the session. Capture the nested transcript
   (`~/.claude/projects/-<path>/<session_id>.jsonl`) — it holds the SessionStart boot packet, every
   tool_use/result, the exit-2 blocks, and any `[vajra: N lines folded]` breadcrumb.
3. **Interactive only if `-p` can't provoke a guard.** Escalate to an interactive session only if the
   cheap agent run doesn't exercise the outward actions.

## What counts as proof (success criteria)
- **At least one guard blocks a LIVE autonomous agent action** in the transcript — a real `git push` or
  `gh pr create`/`merge` or `vajra next --advance` hitting **exit 2**, visible in the captured JSONL (not
  a synthetic payload).
- The founder-satisfaction gate rendered **with evidence** (transcript excerpts + cost receipt), not a
  guess. Verdict is honest either way: **fires-live ✅** or **a new leak 🔴** (S36-style → ranks the fix).
- **Cost captured in the ledger** (`.ai/STATE.md` Cost Tracking) — the dollar figure IS the dogfood
  proof (`dogfood_check` reads the ledger, not test counts).

## Watch-items (from the S45 lenses)
- **Boot-packet cost (#18).** The S36 $58 run was ~$32 cache-read of the heavy `.ai/`. Capture the
  cache-read share of this run's receipt — it's the evidence for whether the `<5% footprint` trim (#18)
  is the next priority after this.
- **Compression on real CC.** Confirm the S41 git-family fold actually fires live (git log/status/diff),
  and note cargo/npm/pytest still won't fold (the exit-code carry). Low-$ but worth a line.
- **Second-agent gate.** This run is the input the S26 founder gate needs; do NOT decide the 2nd agent
  here — render the gate verdict so the founder can.

## Guardrails
- Branch `session-46-<slug>` off `main` (open a **new chat** — this session is NOT started in the S45
  chat). Max 1 story, ≤3 files/commit, max 2 assumptions, ~2h cap.
- **This session spends real $** — that is the point (the audit itself cannot run the paid loop). Prefer
  the cheap `-p` + replay path; escalate to interactive only to provoke a guard.
- To let the agent push/PR for the proof, the founder controls `VAJRA_ALLOW_PUBLISH` — the guard blocking
  the agent IS the success signal; do not set it just to make a push succeed.
- Self-review before ship: what can break · hidden assumptions · production-ready · repro-evidence only ·
  scope intact.

## Output
- `sessions/session-46-summary.md`: goal achieved? the live evidence (transcript excerpts + receipt);
  the gate verdict; exactly 3 next options A/B/C.
- Update the ledger + STATE + ROADMAP (#17a → done or leak-found).
