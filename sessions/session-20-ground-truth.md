# Session 20 — Ground Truth Audit

**Date:** 2026-06-28
**Type:** NO-CODE (`20 % 5 == 0`)
**Auditor:** Claude Code (Session 20)
**Branch:** `session-20-ground-truth` (hook enforcement active — no commits/PRs)
**Scope:** S16–S19 (5 sessions since last audit at S15)

---

## Audit 0 — Direction Drift (vision + roadmap) — NEW

**Meta-finding (the headline of this audit).** The GT mechanism, as specified through S15, checked only *discipline* drift (state / knowledge / constraint / cost) plus roadmap *ordering*. It never asked **"are we still building the right thing?"** — the exact failure mode Vajra was founded to fix (S18: *"agents forget the vision and rush to finish"*). The audit meant to catch vision loss was structurally blind to it. **Fixed this session** — see *Hardening Applied*.

**Vision pass** (per the new `vision_questions`):
- *North-star still right?* — "`vajra next` as cross-agent workflow coach; **enforcement is the wedge**." **Holds** — still differentiated vs GSD/SuperClaude (prompt libraries with no enforcement).
- *Shortest path, or scope creep?* — **FLAG.** Varta (a ⚡ language the agent learns at boot and speaks) trends toward the *prompt-library* shape we vowed to beat *on enforcement*. The wedge is "your agent follows rules, **provably**"; a hand-spoken language enforces nothing — nothing parses it. Risk: Varta is intellectually fun but **off-wedge**.
- *What would make us pivot?* — if S21's co-pilot loader cannot make `⚡on` actually **fire** (enforce context-loading at runtime), Varta stays decorative and should drop below first-run "aha".

**Roadmap pass** (per the new `roadmap_questions`):
- *Each phase maps to north-star?* — Phase 1 (enforced loop) ✓. Phase 2 (Varta) ✓ **only if the co-pilot loader makes it enforcing**; otherwise it is prompts wearing a wedge costume.
- *Next item highest-leverage?* — Yes. The co-pilot loader (S21) is precisely the **test** of whether Varta earns its place; doing it next resolves the flag above. If it proves hard, first-run "aha" (item 9) is the safer ROI.
- *Obsolete / missing items?* — none obsolete. **Missing item the vision now demands:** an explicit **"does Varta enforce, or merely advise?"** decision gate before further language investment.

This is exactly the pass the old audit would have skipped.

---

## Audit 1 — State Drift

| Claim | Actual | Verdict |
|---|---|---|
| `.ai/SESSION` = 19 | 19 | OK |
| SESSION-BOOT "19 — COMPLETE" | confirmed | OK |
| STATE: "S19 Varta-v0 PR **pending merge**" | **PR #9 MERGED** (`a72861b` on main) | **DRIFT** |
| SESSION-BOOT: "S19 PR pending merge" | merged | **DRIFT** |
| TASK: `varta/` = SKILL + GRAMMAR + **vajra.varta + READBACK**, "10/10" | only SKILL.md + GRAMMAR.varta exist; verify = **9/9** | **DRIFT (high)** |
| TASK build-queue: "Skill + grammar + **vajra.varta + read-back**" | both dropped | **DRIFT** |
| TASK: "Companion to `.ai/`, not a replacement" | final S19 decision: language spoken from **live `.ai/`**, not a companion | **DRIFT (contradicts decision)** |
| STATE: "`varta/` = language only (SKILL + GRAMMAR)" | matches reality | OK |
| Active branch: None | correct (was between sessions) | OK |
| Tests green: "77 unit + 26 integration" | `cargo test` = **77 + 26 = 103**, 0 fail | OK |
| clippy clean | confirmed (exit 0) | OK |

**Findings:**
1. **TASK.md is the drift epicenter** — it still describes S19's *pre-correction* plan (4 files, 10/10, "companion"). STATE/KNOWLEDGE/ROADMAP/BOOT all correctly narrate the drop. TASK is the most-read pointer, so this is the highest-value fix.
2. STATE.md + SESSION-BOOT.md call PR #9 "pending merge" — it merged into `main`.
3. `git grep vajra.varta` shows the term only in **narrative** (correct: STATE/KNOWLEDGE/BOOT explain the drop), the **no-handcopy guard** (verify-19, correct), frozen prompts/summaries (historical), and **TASK.md as a live deliverable** (the one genuine stale use).

---

## Audit 2 — Knowledge Staleness

| Section | Checked against | Verdict |
|---|---|---|
| §1 System info | actual system | OK |
| §2 Product identity | source + commands | OK |
| §3 Repo layout | `ls` | **STALE — `varta/` not listed** |
| §6 Varta v0 fact (S19) | varta/ + git history | OK — accurate, detailed |
| §6 "grammar frozen at 9" | carry-forward "validate over 2–3 sessions" | **TENSION** — "frozen" vs "validate before locking" |
| §7 type shapes / breadcrumb | source | OK (S15's breadcrumb fix applied) |
| §8 maturity levels | source | OK |

**Findings:**
1. §3 Repo Layout omits `varta/`, now a permanent tree. Add it.
2. §6 says grammar is "frozen at 9"; the carry-forward says validate over 2–3 real sessions before locking. Only **one** authoring pass has happened (the dropped `vajra.varta`). Treat "frozen" as **provisional** until S21–S23 exercise it.

---

## Audit 3 — Roadmap Priority

- **`[x]` marks audit:** Item 7 (Varta v0) correctly `[x]`. All prior `[x]` items still hold.
- **Item 8 (co-pilot loader):** correctly marked NEXT (S21) — matches the user's S21 pick. **No rerank needed.**
- **Rerank confirmed:** (1) co-pilot loader → (2) first-run "aha" → (3) wire Varta into `vajra init` (S19 deferred follow-up) → (4) render `.ai/` → `.varta` (generated, drift-free).
- **Nit (low):** ROADMAP has two "item 8"s — Phase 2 item 8 (co-pilot) and Phase 3 item 8 (installer). Numbering collision; cosmetic.

---

## Audit 4 — Constraint Violation Review (S16–S19)

| Check | Result |
|---|---|
| Branch naming `session-NN-<slug>` | compliant (all branches) |
| ≤3 files per **atomic** commit | compliant — every non-merge commit ≤3 files (PR merges aggregate, exempt) |
| S19 docs-only (no Rust drift) | confirmed — `src/` untouched; tests unchanged at 103 |
| NO-CODE at S15 / S20 | S15 GT file exists; S20 running on correct branch, no commits |
| Verify + demo + summary present | S16–S19 all present |
| No autonomous commits; PRs merged | #4 (S16), #6 (S17), #8 (S18), #9 (S19) — all merged |
| Max 1 story per session | compliant |

**No constraint violations in S16–S19.**

---

## Audit 5 — Cost Review

| Session | Claimed | Verdict |
|---|---|---|
| S16 | ~$0.00 | OK (cleanup, no API) |
| S17 | ~$0.00 | OK (code, no `vajra claude` calls) |
| S18 | ~$0.00 | OK (interactive review) |
| S19 | ~$0.00 | OK (docs/skill) |
| **Cumulative** | **~$0.46** | accurate — all spend still from S07 |

**No cost drift.** Well under the $5.00 cap. (S07's ~$0.46 has no JSONL artifact to independently re-verify — same caveat as S10/S15.)

---

## Varta-Specific Checks (new this audit)

1. **Is the 9-construct grammar the right set?** Unproven — only **one** authoring pass (the dropped `vajra.varta`), and it silently **lost `budget.cap_usd`, `maturity`, and `communication.max_bullets`**. That loss is the tell: either those configs have no comfortable construct, or hand-authoring is too error-prone (which is exactly why the companion was dropped). `⚡max{}` plausibly covers numeric caps but wasn't used for them. **Recommend:** keep grammar unlocked; let S21's generated render (`.ai/` → `.varta`) be the real test of coverage.
2. **Has `vajra.varta` drifted from source?** N/A — it was deleted. The decision held (no live companion in the tree). The drift it *would* have caused is precisely what S19 avoided.
3. **S21 pre-work — where does `⚡on(...)` fire? (sketch, no code):**

| Option | Fires when | Verdict |
|---|---|---|
| **CC hook** (PreToolUse/PostToolUse or UserPromptSubmit) reads touched files → matches `⚡on(cond)` → injects `⚡include` context | **reactively, mid-session** | **Recommended** — only option that reacts to what the agent touches; consistent with ADR-0001 (compression already rides a CC `PostToolUse` hook) |
| New `vajra` subcommand | only when the agent remembers to call it | fragile — defeats "co-pilot, not cop" |
| `src/launcher` at boot | once, at startup | can't react mid-session |

   **Lands as:** a new hook script in `scripts/` + matcher logic alongside `src/adapter/`, wired via `.claude/settings.json`. Reuses the proven additive-`--settings` injection path. Risk: needs a condition language for `⚡on(cond)` and a debounce so nudges don't spam.

---

## Cross-File Consistency

| File pair | Consistent? |
|---|---|
| SESSION (19) ↔ SESSION-BOOT | Yes |
| SESSION-BOOT ↔ TASK (pointer) | Yes — both point to `prompts/20-task-ground-truth.md` |
| STATE ↔ reality (tests, varta/, PR) | varta/ ✓, tests ✓; **PR status drifts** |
| **TASK ↔ STATE/KNOWLEDGE/ROADMAP (Varta scope)** | **No — TASK still on the dropped-companion plan** |
| KNOWLEDGE §6 ↔ varta/ | Yes |
| Cost ↔ budget cap | Yes |

**Note:** the S20 prompt itself (`prompts/20-task-ground-truth.md`, frozen) instructs reading `varta/vajra.varta` + `varta/READBACK.md`, which do not exist — written during S19 closeout before the drop settled. Informational only; prompts are frozen contracts.

---

## Summary of Corrections Needed

| # | Finding | Severity | Fix in |
|---|---|---|---|
| 0 | **GT mechanism was blind to vision/roadmap drift** (meta — see Audit 0) | **Critical** | **fixed this session** (`session-20-enforcement`) |
| 1 | TASK.md describes S19 as 4-file/"10/10"/"companion" — the dropped plan | **High** | S21 closeout |
| 2 | STATE.md + SESSION-BOOT.md: PR #9 "pending merge" → merged | Low | S21 closeout |
| 3 | KNOWLEDGE.md §3: add `varta/` to repo layout | Low | S21 closeout |
| 4 | KNOWLEDGE.md §6: mark grammar "frozen at 9" as provisional pending validation | Low | S21 closeout |
| 5 | ROADMAP.md: duplicate "item 8" numbering | Low (cosmetic) | S21 closeout |

Findings 1–5 are doc-only and land in the S21 closeout. Finding 0 was hardened this session (below).

---

## Hardening Applied This Session (branch `session-20-enforcement`)

Per user authorization ("catch vision + roadmap drift as well as rule + constitution drift"), the GT mechanism was hardened so future audits cannot repeat the S20 blind spot:

- **`.ai/CONSTRAINTS.yaml#ground_truth`** — `required_audits` now leads with `vision_alignment` + `roadmap_alignment` and adds `constitution_review`; added `drift_axes: [vision, roadmap, rules, constitution, state, cost]` and `vision_/roadmap_/constitution_questions` (so the audit is actionable, not just a label); the `constitution_questions` include the **meta-check** "did this audit's own mechanism have a blind spot?".
- **`.ai/AGENTS.md`** — Ground Truth section rewritten around **two drift classes** (direction + discipline) with the meta-check.
- **Propagation (QUEUED — code, not this NO-CODE session):** `src/cli/init.rs` embeds the `.ai/` scaffold that every `vajra init` stamps into other repos. It must be updated to emit the new audit list + AGENTS.md checklist so any Vajra-using project inherits this. That is a Rust change with tests/verify → S21 (or its own session), per the NO-CODE rule.

---

## Repo Health

- **103 tests passing** (77 unit + 26 integration), 0 failing
- **clippy clean** (exit 0)
- **verify-session-19** ALL GREEN (9/9); **verify-closeout** ALL GREEN (8/8)
- **All S16–S19 PRs merged** (#4, #6, #8, #9)
- `varta/` = exactly 2 files (SKILL.md + GRAMMAR.varta); no hand-copy companion

---

## Sign-off

Ground truth complete. All required audits done + direction-drift pass (Audit 0) + 3 Varta-specific checks.
**7 findings: 1 critical (GT mechanism blind to direction drift — fixed this session), 1 high (TASK.md scope drift), 5 low.** Zero constraint violations in S16–S19.

**Direction is *provisionally* confirmed, not rubber-stamped:** co-pilot loader (S21) is correctly next, but it doubles as the gate on whether Varta enforces (the wedge) or merely advises (off-wedge prompts). The new `vision_alignment` audit will re-test this at S25.

**Two open items for the user:**
1. Approval token to commit this hardening on `session-20-enforcement` (3 files: CONSTRAINTS.yaml, AGENTS.md, this report).
2. Confirm the scaffold propagation (`src/cli/init.rs`) is queued for S21.

Awaiting user sign-off before code resumes (S21).
