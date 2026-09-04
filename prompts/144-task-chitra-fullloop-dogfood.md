# Session 144 — The chitra FULL-LOOP dogfood: upgrade (roles + hooks + constitution) then govern a build, end to end

> **Status: APPROVED** — founder picked **A** at the S143 close. **This is a PAID dogfood.** Run it in a
> FRESH chat; the agent creates `session-144-chitra-fullloop-dogfood` and commits this prompt as its
> first act. Founder directives in force: run Vajra INSIDE the target repo, not across the fence
> ([[feedback-run-vajra-inside-target-repo]]); run END TO END through close, and WATCH the tech-lead's
> `required` set actually run (the S138 "required ≠ required" gap — now bound at close by S139)
> ([[feedback-dogfood-method]] · [[vajra-required-not-required]]); README/VISION claims are the spec, never softened (S118).

## Why this session exists (the founder's #2 completeness priority, now #1 is done)

The fresh-user / upgrade-in-place arc is COMPLETE in the Vajra repo: roles (S141) + hooks (S142) +
constitution (S143) all upgrade under the SINGLE `vajra init --sync-fleet`, proven on fixtures and a
throwaway dir. **But every one of those proofs was exercised against dirs THIS repo created.** The whole
loop has never met a real brownfield adopter. chitra is that adopter — its `.ai/` was scaffolded by an
older Vajra (pre-S141/S142/S143): its role files are stale renders, its hooks are unstamped, and its
constitution is boundaryless. S144 runs the upgrade for real, then governs an actual chitra build
through close — the first end-to-end test of the thing the last three sessions built.

## The one story

Inside chitra (`/Users/suman/playground/chitra`), run `vajra claude` as a NATIVE chitra session and:
1. **Upgrade chitra's `.ai/` with the real installed binary** — roles + hooks (one `--overwrite-drifted`
   for the pre-stamp files) + the constitution (paste the `GOVERNED_BODY_SENTINEL` once, then
   `--overwrite-drifted`), and prove the NEXT `--sync-fleet` is smooth (all UpToDate, 0 churn) for all
   three file classes, with chitra's own filled constitution header preserved byte-for-byte.
2. **Govern a real chitra build end to end through CLOSE** — a small, founder-agreed chart/task in
   chitra, driven by chitra's OWN fleet + hooks, run to a green `verify-closeout.sh` (where the S139
   `check_required_crew` gate binds), so the tech-lead's `required` roles are actually dispatched, not
   self-certified.

## Design (dispatch chitra's tech-lead FIRST, then let it bind the crew)

- **design-significant: no** (recorded) — this session RUNS existing machinery on a real repo; it builds
  no new Vajra mechanism. If a genuine design fork appears (e.g. the constitution migration needs a step
  the tool doesn't support), STOP and surface it, don't invent. Cite DECISION-007 (S141/S142/S143 addenda).
- **The setup that must be right (the S137 lesson):** `cwd` = chitra; the whole session is a chitra
  session — chitra's SessionStart boot fires, chitra's `.claude/agents` fleet is dispatched, chitra's
  hooks gate, and every check looks at chitra's evidence. Do NOT run inside the Vajra repo reaching across.
- **The founder call to surface, not swallow:** interactive vs headless. Interactive proves the approval
  flow but yields an honest-null receipt (S77); headless `-p --output-format stream-json` yields an
  authoritative `$` but skips the approval flow (S134/S138). Ask the founder which this run is FOR before
  spending a paid minute; record the choice and its consequence, never dress a sidestep as a free win (S134).
- tech-lead FIRST + design-advisor + fidelity-reviewer mandatory in the WRAPPER session too; and inside
  chitra, WATCH that chitra's tech-lead's `required` roles each produce a real handoff by close.

## Acceptance (testable, EARS-style)

1. WHEN the installed binary runs `vajra init --sync-fleet` in chitra for the FIRST time, THEN chitra's
   stale role files + unstamped hooks classify (Drifted/StaleRender) and its boundaryless constitution
   classifies `NeedsBoundary` — captured verbatim as the real brownfield first-contact state.
2. WHEN the one-time migration is applied (roles/hooks via `--overwrite-drifted`; the constitution via
   paste-the-sentinel + `--overwrite-drifted`), THEN chitra's constitution's FILLED header (its own
   project identity) is preserved byte-for-byte and only the governed body is rewritten — proven by a
   before/after diff of the bytes above the sentinel.
3. WHEN `vajra init --sync-fleet` runs AGAIN, THEN roles + hooks + constitution are ALL UpToDate, 0
   created/upgraded/refreshed — the upgrade is smooth going forward for all three classes on a real repo.
4. WHEN a real chitra build is governed to CLOSE, THEN chitra's tech-lead is dispatched FIRST, every
   role it marks `required` produces a real governed handoff (the S139 gate binds — no self-certification),
   and `verify-closeout.sh` passes green IN chitra. The founder signs off on the built artifact (seen, not read).
5. WHEN the run ends, THEN chitra is proven UNDISTURBED four ways (HEAD, index hash, stash list, branch),
   with exactly the intended new/changed paths declared by name in advance.
6. `scripts/verify-session-144.sh` (exit 0) + `sessions/session-144-summary.md` (full fidelity map + the
   TWO audiences: the founder's build verdict AND what Vajra's governance actually did) + cold
   `fidelity-reviewer` ACCEPT. Report the receipt honestly (authoritative `$` OR honest null per run mode)
   AND the RAW subagent token total (never the new-tokens-only figure — S134).

## Guardrails

- **Run INSIDE chitra** (`vajra claude`, cwd=chitra), a native chitra session — not a Vajra chat poking
  chitra across the fence (S137 correction). **Run END TO END through close** (S138).
- **chitra must be left undisturbed** — four-ways proof (HEAD + index hash + stash list + branch), not
  just `git status`. Declare every path you will touch in advance. The founder's in-flight work is sacred.
- **Watch "required ≠ required"** — if chitra's tech-lead marks N roles required, N real handoffs must
  exist by close; the S139 gate should catch a shortfall. Report whether it did.
- **Budget every dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan). Report RAW
  subagent tokens from `~/.claude/projects/*/*/subagents/agent-*.jsonl`, not new-tokens.
- **Do NOT fix chitra's charts beyond the one agreed build.** No scope creep into chitra's own roadmap.
- **The migration must never clobber chitra's filled constitution header** — that is the S143 guarantee
  under real-world test; if it does, that is the headline finding, reported not hidden.
- Un-forgeable `VAJRA_ALLOW_COMMIT=144` on Vajra-side commits; attest LAST (`--inputs-sha 144`), run the
  FULL `verify-closeout.sh` on the branch BEFORE merging (S83). **Next GT: S145 (mandatory NO-CODE).**

## Delta (vs ROADMAP — OpenSpec markers)

- `+` first real-world exercise of the complete upgrade loop (roles + hooks + constitution) on a
  brownfield adopter (chitra), including the constitution's one-time boundary migration.
- `+` first end-to-end governed chitra BUILD run to a green close where the S139 required-crew gate binds.
- `~` the S141/S142/S143 upgrade proofs widen from throwaway fixtures to a real installed project.
