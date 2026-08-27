# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S135 complete, S136 not yet started).**

S135 shipped the **`tech-lead`** — the tenth fleet role, the first that is not a specialist — and
the binding **`vajra next --check-crew`** gate. The tech-lead decides, for each of the nine
specialists, whether a task needs it (`required`) or cannot afford it (`deferred-budget`), with a
token budget; its verdict BINDS (a `required` role must produce a real governed handoff or the
session cannot close). **Cold `fidelity-reviewer` ACCEPT** (two passes; pass 1 REJECT of a mid-flight
state fixed in-session, pass 2 **11/12 SHIPPED · 1 PARTIAL**), attested `d538f522…`.

**Genuine self-binding achieved on S135 itself:** a real, provenance-verified `tech-lead` was
dispatched and `vajra next --check-crew 135` PASSES (3 required · 6 deferred-budget; every required
role has a real handoff).

## What was proven this session
- **The S133 genericity falsification test HELD.** The crew gate is a CALL SITE on `src/mandate` —
  **0 lines added to `mandate_gate` / `parse_skip_marker` / `classify_marker_value`**
  (`git diff main -- src/mandate/mod.rs` is empty). S133's "second mandatory role is a table entry,
  not a third copy" was real, not decoration.
- **The crew gate has NO migration threshold** (`from_session: 0`) — the fix to the S134 brownfield
  hole: a brand-new role has no legacy prompts to exempt, so silence about it blocks from session 1
  in every project (DECISION-007 S135 addendum). The two EXISTING thresholded roles are unchanged;
  this establishes the pattern that future mandatory roles ship threshold-free.
- **Phase 1 has NO off switch:** only `required` and `deferred-budget` are admitted; `not-needed` /
  a bare skip / an empty reason are REFUSED, and the refusal names phase 1b. Value-bound tests.
- **`--crew-cost` reads REAL on-disk bytes:** 2,540,174 raw tokens across 4 dispatches this session
  vs S134's 19,192,697 across 3 — tight named-files briefs cut ~8×. The Agent tool reported the
  fidelity pass-1 dispatch as 98,758 (NEW only); the raw truth is 2,003,866 — the S134 45× trap
  caught live by the new instrument.

## What Is Broken / Weak / Disclosed
- **🟡 Criterion 7 is PARTIAL (disclosed, the pass-2 review's independent catch).** The budget is
  RECORDED by the tech-lead, DISPLAYED by `--check-crew`, and REPORTED against actual by
  `--crew-cost` — but nothing in the dispatch path reads `budget_tokens` to CARRY the allowance INTO
  a role's brief (`run_role_handoff` never reads it). The reporting half is built; the injection half
  is not. **S136 candidate 3** closes it (a small read surface, no ladder edit).
- **🔴 THE BOOTSTRAPPING WALL (NEW, S135, found live).** A brand-new native-subagent role is normally
  NOT dispatchable in the session that creates it — Claude Code snapshots `.claude/agents/` at
  startup. The founder chose "ship + let the gate block" while the wall was up; a mid-session
  registry refresh then let S135 achieve real self-binding. The reliable rule stands: a
  native-subagent role first binds the session AFTER it is created.
- **🔴 `tech-lead` is a Vajra-only feature until chitra's scaffold is upgraded.** chitra carries 4 of
  9 role files; its upgrade to the full ten-role roster is deferred (founder's call) to just before
  the next dogfood. **S136 candidate 1.** Until then S135 narrows the "true here, decorative there"
  gap without closing it in the one project that would prove it.
- **🔴 THE BROWNFIELD THRESHOLD HOLE (S134, carried).** The two EXISTING thresholded roles
  (`design-advisor`, and `implementation-advisor` when it lands) still carry the session-number
  threshold. S135 fixed it only for NEW roles (threshold-free), and did not retrofit the old two.
- **🔴 THREE CONSECUTIVE JUDGES HAVE HAD NO SHELL** (S133, S134, and S135's fidelity + impl-advisor).
  Every "verify 10/10" claim was executed only by the builder; the independent passes read scripts.
- **🔴 A dispatch that happened ≠ advice that reached the work** — ROADMAP F2f (rubber-stamp
  detector). S135 makes it MORE valuable: a binding crew gate is exactly what a rubber-stamp would
  satisfy hollowly. **S136 candidate (F2f, dropped from the top 3 in favour of the crit-7 close).**
- **🟡 Carried, not re-verified live this session:** F2e (now n=3: three mandatory roles, still one
  shared ladder — the duplication is with `src/fidelity`, untouched), F2g (`L1` escape prose-only),
  `parse_delta()` landmine, VISION.md / `.ai/AGENTS.md:118` staleness, KNOWLEDGE.md growth (F4).
- **Dogfood: last paid run S134 ($1.6103385, 2026-08-26).** S135 built no dogfood; D2 (fresh-scaffold
  first-contact paid run) still OUTSTANDING.

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. `K of 8` unchanged — the crew gate is a FLEET gate,
  not a ninth station.
- **The fleet is now TEN roles, THREE mandatory:** `fidelity-reviewer` (S131, grades finished work),
  `design-advisor` (S133, consulted-or-a-recorded-skip), and now the `tech-lead` (S135, the first and
  mandatory dispatch whose crew decision binds). The execution allowlist is still exactly one role
  (`qa-specialist`).
- Enforcement floor, ledger (S100), first contact (S128), one source for a stranger's rulebook
  (S129): unchanged, not re-verified live this session.

## Active PRs
- **S135 — PR opens at closeout, after `.ai/` sync.**
- S133 [#155](https://github.com/ifelse-codes/vajra/pull/155) MERGED · S132
  [#153](https://github.com/ifelse-codes/vajra/pull/153) MERGED · S131
  [#150](https://github.com/ifelse-codes/vajra/pull/150) MERGED + hotfix
  [#151](https://github.com/ifelse-codes/vajra/pull/151).

## Direction (governance is the product — shaped as a shippable MVP)
- **Product = provable agent governance** (`DECISION-001`), the autopilot trust layer. Fleet = real
  named agents behind the gates (`DECISION-007`). **Current direction, locked S130: MAKE THE FLEET
  REAL.** S131 made one role mandatory + provable; S132 made advice consequential; S133 made the
  first build-shaping advisor mandatory; S135 made the ROLE THAT DECIDES THE CREW mandatory and its
  decision binding — with the first cost control in the product.
- **Next-GT: S140** (this cycle's GT was skipped by founder decision at the S134 close; S135 was a
  CODE session under `VAJRA_GT_WAIVER=135`, the first skipped GT in the project's history).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 · S97: $1.2758 · S102: $0.4644 · S103: $0.6797.**
- **S104–109: ~$0 each. S110: $0 (NO-CODE GT). S111–S117: $0 metered. S118: $4.0911771 authoritative.**
- **S120: $0 (NO-CODE GT). S124: $3.2984944 authoritative. S126: $4.4482 authoritative.**
- **S128–S133: $0 metered for build** (interactive). **S134: $1.6103385 AUTHORITATIVE** (chitra
  dogfood) + ~19.2M raw subagent tokens across 3 dispatches.
- **S135: $0 metered for build** (interactive) — **2,540,174 RAW subagent tokens** across 4 dispatches
  (design-advisor 155,319 · tech-lead 13,194 · implementation-advisor 367,795 · fidelity-reviewer
  pass 1 2,003,866; pass 2 adds more — the closing `--crew-cost 135` is authoritative). The
  named-files discipline held per-session dispatch cost ~8× below S134. **Phase 1b (all-nine)
  estimated ~4–5M raw/session** — roughly 4 all-nine sessions/month under the $20 plan's ~19M cap.
- Cumulative: **~$92.8 + S76 (unknown, ≤ ~$26.6) + S111–S135 subagents (unknown, growing).**
