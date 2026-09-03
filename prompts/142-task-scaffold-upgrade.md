# Session 142 — Complete the upgrade loop: recorded provenance for the non-fleet scaffold files

> **Status: APPROVED** — founder confirmed the PICK (B) and approved this brief in chat at the S141
> close: *"i approve it — just a single update command and it will make update smooth and seamless."*
> **Founder design directive (binding): ONE update command upgrades everything.** A user runs a single
> invocation and roles + hooks + constitution all upgrade smoothly — NOT a second `--sync-scaffold`
> sibling, NOT a per-file-type command. See Design fork #3. **Start S142 in a FRESH chat** (one session
> per chat), where the agent creates `session-142-<slug>` and commits this prompt as its first act.
>
> Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Why this session exists (finishes the founder's #1 completeness priority)

S141 gave the smooth upgrade-in-place ONLY to the fleet role files (`.claude/agents/*.md`). Every OTHER
file `vajra init` scaffolds is still **add-only** — created if missing, then **frozen forever**:

| File | On upgrade today |
|---|---|
| `.claude/agents/*.md` (fleet roles) | ✅ S141 — stamped, auto-upgrades, edits protected |
| `.claude/settings.json` | ⚠️ merges (S44 special case) |
| `.ai/AGENTS.md` (the constitution) | ❌ add-only — never upgraded |
| `.ai/hooks/hook-*.sh` (the enforcement) | ❌ add-only |
| `.ai/CONSTRAINTS.yaml` (the rules) | ❌ add-only — **and user-tuned** |

So when Vajra improves a hook or a constitution rule, an existing project (chitra) **cannot pick it up
smoothly** — a human must hand-copy and risk clobbering their own edits. That is the second half of
*"the best install, or vajra upgrade in an existing vajra repo, so it will always be the best"* (the
founder's S140 #1 priority). S141 closed it for roles; **S142 closes it for the pure renders.**

## The one story

Generalise the S141 render stamp beyond frontmatter and widen the SINGLE update command
(`vajra init --sync-fleet`, scope broadened to all pure renders — founder directive, one command
upgrades everything) so the **pure-render** non-fleet scaffold files —
**the hooks (`.ai/hooks/hook-*.sh`) and the constitution (`.ai/AGENTS.md`)** — carry a
`vajra-render-sha:` stamp and gain the same four-state upgrade: an untouched old render auto-upgrades,
a user edit / unstamped file is refused unless `--overwrite-drifted`. One invocation makes the whole
update smooth and seamless. **`CONSTRAINTS.yaml` stays user-owned** and out of auto-upgrade (disclosed
limit — see Guardrails).

## Design (dispatch the tech-lead FIRST, then let it bind the crew)

- **design-significant: yes** — this generalises the stamp to new file TYPES (shell, markdown) with
  different comment syntax, and widens the domain `--sync-fleet` governs. Cite
  `docs/decisions/DECISION-007-agent-fleet.md` + the **S141 addendum**, and add an **S142 addendum**.
- **The core design questions the session must settle (with the design-advisor), not assume:**
  1. **Per-file-type stamp placement (the real work).** S141's stamp is a YAML frontmatter key and its
     helpers split on `\n---\n`. Hooks are shell (`# vajra-render-sha: <hex>` comment line);
     the constitution is markdown (an HTML comment `<!-- vajra-render-sha: <hex> -->`, or a trailing
     comment line). The stamp/strip/verify helpers (`fleet::stamp_render` / `strip_render_stamp` /
     `render_stamp_verifies`) must generalise to "a stamp line identified by the key, in this file's
     comment syntax, removed to recover the preimage" — the exact-inverse round-trip must still hold.
     Prefer REUSING/generalising the S141 helpers over a second copy (no drift).
  2. **Which files are in scope.** Pure renders (hooks, constitution) → stampable + auto-upgrade.
     `CONSTRAINTS.yaml` is user-TUNED (maturity, budget cap, approval tokens) → **leave user-owned**.
     Confirm this split against **what chitra actually edited** in its `.ai/` (a cheap read, no paid
     run) before locking it.
  3. **One command — RESOLVED by the founder: a SINGLE update command upgrades everything.** Widen the
     EXISTING `vajra init --sync-fleet` to cover ALL pure renders (roles + hooks + constitution) under one
     invocation — NOT a separate `--sync-scaffold`, NOT per-file-type commands. A user runs it once and
     every pure render upgrades smoothly. Consider renaming the flag to reflect the wider scope (e.g.
     `--sync`) IF and only if it adds no command; **do NOT add an 8th top-level command** (max 7).
- **Rejected-alternatives must be stated** (a rationale with no rejected option is not a decision):
  e.g. stamping `CONSTRAINTS.yaml` too (rejected — user-tuned) vs. leaving it user-owned; a per-file-type
  stamp vs. a sidecar manifest (S141 already rejected the sidecar — carry that reasoning).
- tech-lead FIRST + design-advisor + fidelity-reviewer mandatory; record every required role's handoff
  (the close runs `check_required_crew`, S139).

## Acceptance (testable, EARS-style — the session refines these)

1. WHEN a hook (`hook-*.sh`) and the constitution (`.ai/AGENTS.md`) are rendered, THEN each carries a
   `vajra-render-sha:` stamp in that file's comment syntax; re-deriving the hash from the body-minus-stamp
   reproduces the stamp (pure round-trip, unit-tested per file type), AND the stamp is inert to the file's
   consumer (a stamped hook still runs; the stamped constitution still reads).
2. WHEN a non-fleet pure-render file is on disk, THEN classification returns the four states
   (Missing · UpToDate · StaleRender · Drifted) as a pure function, same shape as S141.
3. WHEN the sync command runs, THEN a `StaleRender` hook/constitution auto-upgrades WITHOUT
   `--overwrite-drifted` (reported by name), a `Drifted`/unstamped one is refused (exit 1) unless
   `--overwrite-drifted`, and `CONSTRAINTS.yaml` is NEVER auto-upgraded (it stays user-owned). Proven by a
   four-case falsifiability fixture that goes RED for the right reason + a clean-exit-0 positive control.
4. WHEN a fresh `vajra init` scaffolds a project and the sync runs immediately after, THEN every
   pure-render file is `UpToDate` and nothing is rewritten (idempotent, no churn) — proven LIVE in a real
   empty dir with the real release binary.
5. `## Design` + a DECISION-007 S142 addendum record the generalised stamp, the in-scope file set, and
   why `CONSTRAINTS.yaml` is deliberately excluded.
6. `scripts/verify-session-142.sh` (exit 0, class tally) + `demo-session-142.sh` (4 sprint markers) +
   `sessions/session-142-summary.md` (full fidelity map + 3 ranked candidates). Cold `fidelity-reviewer` ACCEPT.

## Guardrails

- **Scope = the PURE-RENDER non-fleet scaffold files only** (hooks + constitution). `CONSTRAINTS.yaml`
  and `.claude/settings.json` are OUT of auto-upgrade — user-tuned / already-merged respectively. 1 story.
- **Honest backward-compat (the fakest green to avoid claiming).** Every pre-S142 install has UNSTAMPED
  hooks/constitution → `Drifted` on first contact → still needs one `--overwrite-drifted`. Smooth
  going-forward, not retroactive (same honest limit as S141).
- **The stamp must not change behavior** — a stamped hook must still run identically; assert it.
- **Preserve the no-churn property** — an `UpToDate` file is never rewritten.
- **Do NOT add an 8th top-level command** (max 7) — a flag on `vajra init`.
- **The fixture must fail for the RIGHT reason** (S122); positive control asserts clean exit 0 (S134).
- **Budget every subagent dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan).
- Un-forgeable `VAJRA_ALLOW_COMMIT=142` on every commit; attest LAST (`--inputs-sha 142`), run the FULL
  `verify-closeout.sh` on the branch BEFORE merging (S83). **After S142:** the chitra dogfood becomes a
  full-loop test (roles + hooks + constitution all upgrade smoothly). **Next GT: S145.**

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the render stamp generalises to shell + markdown scaffold files; hooks + constitution gain the
  four-state smooth upgrade.
- `~` the S141 upgrade path (roles only) widens to all pure-render scaffold files — the upgrade loop is
  complete for everything Vajra owns byte-for-byte.
- `-` the "non-fleet scaffold files are add-only" limit (S141 disclosed remainder) — retired for pure
  renders; disclosed as still-present for `CONSTRAINTS.yaml` (user-owned, by design).
