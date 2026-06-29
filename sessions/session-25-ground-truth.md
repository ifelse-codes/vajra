# Session 25 — Ground Truth Audit

**Date:** 2026-06-29
**Type:** NO-CODE (`25 % 5 == 0`)
**Auditor:** Claude Code (Session 25)
**Branch:** none — audit only, on `main` (no commits/PRs; hooks active)
**Scope:** S21–S24 (4 sessions since last audit at S20)
**Primary lens (set at S24 closeout):** DIRECTION DRIFT

---

## Audit 0 — Direction Drift (vision + roadmap) — THE HEADLINE

**The question this GT exists to answer:** Four straight sessions (S21–S24) went into Varta. The north-star is a *cross-agent* coach — yet only Claude Code is wired. Was Varta the shortest path, or intellectually-fun scope creep?

**Vision pass** (per `vision_questions`):
- *North-star still right?* — "`vajra next` as cross-agent coach; **enforcement is the wedge**." **Holds.** Still differentiated vs GSD/SuperClaude (prompt libraries, no enforcement).
- *Was S21–S24 the shortest path?* — **Mixed verdict, leaning over-invested:**
  - S20 flagged Varta as possibly *off-wedge* (a spoken language enforces nothing). **S21 resolved that flag honestly** — the co-pilot loader makes `⚡on` *fire* and *block* (exit 2), proven live on a real `git commit`. So Varta is **on-wedge, not decoration.** That session earned its place.
  - **But the leverage tail decayed.** S22 (propagate to scaffold) was necessary — without it the enforcement only existed in this repo. S23 (first-run "aha") and S24 (render `.ai/`→`.varta`) are **polish on a Claude-only mechanism**: elegant, low-risk, and exactly the "intellectually-fun" shape the GT is meant to catch. They deepened the one agent we already had instead of widening to the agent we don't.
  - **The unbuilt pillar is the differentiator itself.** "Works with *any* agent" is the single claim in `VISION.md` with **zero code** behind it. The competitor table's recurring weakness is "Claude only" (SuperClaude, AxonFlow) — and that is precisely Vajra's unproven part.
- *What evidence justifies S26 = second agent?* — (1) cross-agent is the only wedge pillar with no implementation; (2) the design rule "2–3 agents **deep** > 10 shallow" is unmet at *one*; (3) ADR-0002's Engine trait + adapter contract was *designed* for multiple agents — a second adapter is the cheapest test of whether the architecture is genuinely vendor-neutral or secretly Claude-shaped. Building agent #2 either proves the moat or exposes a hidden coupling. Either outcome is high-information.

**Verdict:** Varta was a **legitimate, on-wedge investment that ran one or two sessions long.** No course correction needed on *what was built* — but the shortest line to the north-star now bends sharply toward the **second agent launcher**. Continuing to refine Varta would be the drift.

**Roadmap pass** (per `roadmap_questions`):
- *Each phase maps to north-star?* — Phase 1 (enforced loop) ✓; Phase 2 (Varta, now enforcing) ✓; Phase 3 (ship) ✓.
- *Next item highest-leverage?* — **Second agent launcher**, unambiguously. It is the north-star gap and the wedge's only untested pillar.
- *Obsolete / missing?* — None obsolete. **Missing item the vision now demands:** a *cross-agent breadth indicator* — see Meta-check.

---

## Meta-check (mandatory) — FALSE-GREEN RISK

**Prompt's specific question:** does a clean drift-guard on `vajra.varta` give false comfort while the cross-agent gap widens? **Yes — and it generalizes beyond varta. This is the headline meta-finding.**

- Every internal signal is green: `vajra check` passes (incl. `varta: matches render`), verify-session-24 21/21, verify-closeout green, 118 tests pass, clippy clean, all PRs merged.
- **Every one of those signals measures Claude-only depth and discipline.** Not a single metric anywhere measures *cross-agent breadth* — the actual north-star. The dashboard can be 100% green while the one differentiating pillar stays unbuilt.
- This is the **S20 trap reincarnated at a higher level.** S20 hardened the *audit* to ask "are we building the right thing?" — but the *day-to-day* green checkmarks (`check`, `verify`, CI) still reward only discipline + depth. The audit catches direction drift once every 5 sessions; nothing catches it in between.
- **Recommendation (for S26 user decision, not this NO-CODE session):** add a visible "north-star gap" indicator that stays **RED until ≥2 agents work** — e.g. a line in ROADMAP's "What does NOT work" promoted to a `vajra check` informational warning, or a single agent-count metric. The green dashboard should not be allowed to imply health while the vendor-neutral claim is vaporware.

---

## Audit 1 — State Drift (post-S24 reality)

| Claim (STATE.md / BOOT) | Actual | Verdict |
|---|---|---|
| `.ai/SESSION` = 24 | 24 | OK |
| SESSION-BOOT "24 — COMPLETE" | confirmed | OK |
| STATE: "S24 varta-render **PR #15 pending merge**" | **PR #15 MERGED** (`d0533f0` on main) | **DRIFT (low)** |
| STATE: `vajra.varta` exists (render of `.ai/`) | present — 59 lines / 3137 bytes | OK |
| STATE: "Only Claude Code is wired" | confirmed — `grep -rli cursor\|codex\|aider\|...` hits only `src/cli/init.rs` (scaffold pointers, not a launcher) | OK (accurate) |
| STATE: "`cargo test` 118 pass" | 92 `#[test]` in `src/` + 26 in `tests/` = **118** | OK |
| Active branch: None — between sessions | correct | OK |
| maturity L2; ≤7 commands | L2; user commands = check, estimate, init, claude, meter, next (6) + internal `hook` | OK |

**Findings:**
1. **The only drift is the recurring one:** STATE.md + SESSION-BOOT both call PR #15 "pending merge" — it merged after closeout wrote STATE. This is the **same low-severity drift flagged at S15 and S20** (PR merges *after* the closeout snapshot is written). It is structural, not negligence. → **see Constitution review for the systemic fix.**
2. Otherwise STATE.md is accurate post-S24 — including honestly naming the cross-agent gap under "What Is Broken."

---

## Audit 2 — Knowledge Staleness

| Section | Checked against | Verdict |
|---|---|---|
| §1 System info | actual system | OK |
| §2 Product identity | source + commands | OK |
| §3 Repo layout (incl. `varta/`) | `ls` | OK — S20 finding fixed in S21 closeout |
| §6 S21–S24 facts | git history + source | OK — accurate, detailed |
| §6 "grammar frozen at 9" (provisional since S20) | S24 render | **RESOLVE** — see below |
| §6 ADR-0005 `vajra estimate` 3:1 ratio | unchanged | **RE-FLAG** — still unvalidated placeholder |

**Findings:**
1. **"Grammar frozen at 9" — provisional flag can now be resolved.** S20's worry was that the grammar had survived only *one* hand-authoring pass that silently dropped `budget`/`maturity`/`max_bullets`. **S24's renderer is the real coverage test S20 asked for:** it renders the live `.ai/` (CONSTRAINTS incl. budget + maturity, AGENTS, SESSION, SESSION-BOOT) into the 9 constructs, deterministically, drift-guarded. The 9 held under a full generated render. **Recommend:** mark the grammar **validated-at-9** (the configs S20 feared lost are now represented in the render), and retire the "provisional" caveat.
2. **`vajra estimate` 3:1 output ratio remains unvalidated** — no historical JSONL ratios were ever gathered to replace the placeholder. Carry forward; still order-of-magnitude only. (Tracked, not new.)

---

## Audit 3 — Roadmap Priority

- **`[x]` marks audit:** Items 7, 8, 8a, 9, 9a all correctly `[x]` (S19/S21/S22/S23/S24); all map to Phase 2 (Varta) which is genuinely COMPLETE.
- **Phase 2 is closed; Phase 3 closed.** "What does NOT work" correctly lists **"Second agent launcher [ ] not built"** as the lone gap.
- **Rerank:** the backlog's "Add second agent (Codex or Cursor) — deferred until Claude experience is fully satisfying" should be **promoted to the front.** S25's direction verdict is that the Claude experience is now satisfying enough (enforces, propagates, felt, persisted) — the deferral condition is met.
- **Nit (low, carried from S20):** ROADMAP still has two "item 8"s (Phase 2 co-pilot vs Phase 3 installer). Cosmetic.

---

## Audit 4 — Constraint Violation Review (S21–S24)

| Check | Result |
|---|---|
| Branch naming `session-NN-<slug>` | compliant |
| ≤3 files per **atomic** commit | compliant (PR merges aggregate, exempt) |
| NO-CODE at S20 / S25 | S20 GT file exists; S25 on `main`, **no branch, no commits** (audit only) ✓ |
| Verify + demo + summary present | S21–S24 all present |
| No autonomous commits; PRs merged | #11 (S21), #12 (S22), #13 (S23), #15 (S24) — all merged |
| Max 1 story per session | compliant |

**No constraint violations in S21–S24.**

---

## Audit 5 — Constitution Review (are rules blocking the vision?)

The pointed question for S26 (a cross-agent launcher lift):

| Rule | Blocks the second-agent session? | Verdict |
|---|---|---|
| **Max 3 files per atomic commit** | A new adapter = Engine impl + CLI wiring + settings variant + tests + verify, likely >3 files | **No** — the cap is per *commit*, not per *session*. Slice into ≥2 atomic commits. Not blocking; requires disciplined commit slicing. |
| **Max 1 story per session** | Second agent could balloon | **Watch** — if "launch + enforce + verify agent #2" is >1 story, split (e.g. S26 = launch-only, S27 = hook-enforce). A pre-work scope call, not a violation. |
| **Max 7 top-level commands** | A `vajra codex` / `vajra cursor` adds command #7 | **At the cap.** ROADMAP already reserves the `vajra <agent>` slot (one pattern, `vajra claude` is its first instance). S26 must decide: per-agent commands (`vajra codex`) vs. generalized dispatch (`vajra run <agent>`). Pre-work design decision. |

**No rule is blocking the vision.** Two are *adjacent* to the second-agent lift and need an explicit scope/design call at S26 PLAN (commands shape + story split). 

**Systemic finding (the recurring PR-status drift):** STATE.md is written at closeout *before* the PR merges, so it perpetually claims "pending merge." Flagged at S15, S20, now S25 — three times. **Recommend (S26 candidate or closeout nicety):** either (a) set `closeout_active_branch_value`-style guidance to write PR status as "open (merge after closeout)" instead of "pending merge," or (b) a tiny `vajra check` rule that reconciles STATE's PR claims against `git log --merges`. The drift is harmless individually but its *recurrence* is the signal: the snapshot-before-merge ordering is structural.

---

## Audit 6 — Cost Review

| Session | Claimed | Verdict |
|---|---|---|
| S21–S24 | ~$0.00 each | OK (code/no-API sessions; no `vajra claude -p` calls) |
| **Cumulative** | **~$0.46** | accurate — all spend still from S07 |

**No cost drift.** Trivial, well under the $5.00 cap. (Same standing caveat: S07's ~$0.46 has no JSONL artifact to independently re-verify — as at S10/S15/S20.)

---

## Repo Health

- **118 tests passing** (92 unit + 26 integration), 0 failing
- `vajra.varta` present (59 lines), render-of-`.ai/`, drift-guarded by `vajra check`
- All S21–S24 PRs merged (#11, #12, #13, #15)
- Only Claude Code wired — confirmed (no second adapter in `src/`)
- On `main`, between sessions, clean working tree

---

## Summary of Findings

| # | Finding | Severity | Disposition |
|---|---|---|---|
| 0 | **Direction:** Varta (S21–S24) was on-wedge but ran ~1–2 sessions long; shortest path now bends to the **second agent launcher** | **Direction verdict** | drives S26 |
| 1 | **Meta:** green dashboard (`check`/verify/CI) measures Claude-depth only — no cross-agent breadth metric; false-green risk as the gap widens | **High (meta)** | add north-star gap indicator (S26 decision) |
| 2 | STATE/BOOT call PR #15 "pending merge" — merged; recurring 3rd time (S15/S20/S25), structural | Low (systemic) | S26 closeout / tiny check rule |
| 3 | "Grammar frozen at 9" — now validated by S24 render; retire "provisional" | Low | KNOWLEDGE note at next closeout |
| 4 | `vajra estimate` 3:1 ratio still unvalidated placeholder | Low | carry forward |
| 5 | ROADMAP duplicate "item 8" numbering | Low (cosmetic) | next closeout |

**Zero constraint violations in S21–S24.** No rule blocks the vision; two are adjacent to the second-agent lift (commands cap + story-split) and need a PLAN-time call.

---

## Direction Verdict

**Confirmed with a turn.** The north-star (cross-agent enforcing coach) is unchanged and still right. Varta was a legitimate, enforcing, on-wedge build — *not* the scope creep S20 feared it might become. **But its leverage is now spent**, and four sessions of Claude-only depth have left the one differentiating pillar — vendor-neutrality — entirely unbuilt. The single highest-leverage move is to **prove the architecture is actually cross-agent by wiring a second agent.** Anything else (more Varta, more polish) would be the real drift this GT exists to prevent.

---

## Candidate S26 Sessions (exactly 3 — A is recommended; ≥1 is the second agent launcher)

### A. Second agent launcher — Codex or Cursor *(RECOMMENDED — the north-star gap)*
- **Goal:** wire a second AI agent end-to-end (`vajra <agent>` launch + context load), proving the Engine/adapter contract (ADR-0002) is genuinely vendor-neutral.
- **Why pick this:** it is the *only* wedge pillar with zero code; closes the lone "What does NOT work" item; satisfies "2–3 agents deep > 10 shallow"; either validates the moat or exposes hidden Claude-coupling (high-information either way). The deferral condition ("until Claude is satisfying") is now met.
- **Key risk:** scope — "launch + enforce + verify agent #2" may exceed 1 story; the command-set cap (#7) and adapter lift force PLAN-time decisions (per-agent command vs. `vajra run <agent>`; which agent — Codex via AGENTS.md is easier to launch but weaker to enforce; Cursor has richer hooks). Likely needs a story split (S26 launch-only → S27 enforce).

### B. Enforce one-session-per-chat
- **Goal:** make AGENTS.md step 10 real — record the Claude `session_id` that opens a vajra-session; `vajra next --advance` (or a PreToolUse hook) refuses N→N+1 from the same chat.
- **Why pick this:** pure enforcement (the wedge); small, self-contained; closes a convention-only gap (S23 finding) that today relies on agent goodwill.
- **Key risk:** lower leverage than A — it hardens the *existing* single-agent loop instead of advancing the cross-agent north-star; defers the gap this GT just flagged as #1.

### C. Audit ledger v2 (git-native provenance)
- **Goal:** tamper-evident cross-agent action ledger in agent-trace format — the governance moat (memory `vajra-positioning`).
- **Why pick this:** advances the long-term moat (local-first, git-native, cross-agent ledger) that differentiates vs AxonFlow; complements A by giving multiple agents a shared audit trail.
- **Key risk:** premature without a second agent — a "cross-agent" ledger with one agent is theater; depends on A to be meaningful. Sequence after A.

---

## Sign-off

Ground truth complete. All 7 required audits answered + direction-drift lens (Audit 0) + the mandatory meta-check (false-green risk).
**6 findings: 1 direction verdict, 1 high meta (false-green / no breadth metric), 4 low.** Zero constraint violations in S21–S24. Cost trivial (~$0.46, unchanged).

**Direction:** the second agent launcher is the highest-leverage S26. Awaiting the user's pick of A / B / C before code resumes (S26).
