# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S115 complete, S116 not yet started).** S115 = **NO-CODE GROUND TRUTH**
(`115 % 5 == 0`), auditing S111–S114. Work done on `session-115-ground-truth` (no commits, per
`CONSTRAINTS.yaml#ground_truth`); this closeout bundle commits on the exempt `session-115-closeout`
branch (the standing GT pattern: S100, S105, S110).

**Verdict: PARTIAL PASS.** The session's one live opportunity — dispatch the S114-built Fidelity
Reviewer role **by name**, for the first time ever — worked on the first try: `subagent_type:
"fidelity-reviewer"` resolved in this fresh session (retiring the S111 "invisible until the next
session" limitation, for that specific case — a role created mid-session dispatching *itself* in that
same session remains untested and is presumed to still fail). The returned verdict's content was
excellent: 13 of 13 SHIPPED, independently re-deriving the same fakest green S114's own builder
disclosed, by reading the check code cold rather than trusting the summary. But the raw output
surfaced a **real, previously-unknown gap**: the agent formatted its canonical verdict as a markdown
table row (`| **Verdict:** | ACCEPT |`), and `verify-closeout.sh`'s line-anchored regex
(`^[*_[:space:]]*verdict...`) does **not** match a line starting with `|` — confirmed by running the
actual gate regex against the actual raw agent output, not a paraphrase. A bare `**Verdict:** ACCEPT`
line passes; the table-wrapped form does not. This is a brief-vs-gate mismatch no synthetic test could
find, because S114's own shape tests write the required strings by hand rather than letting an agent
choose its own formatting. Filed, not fixed (session is NO-CODE).

The PARTIAL (not PASS) verdict is because the launcher dogfood — the product's central promise, "leave
your agent working for days, come back, trust the result" — is now **12 sessions / ~11 calendar days**
stale, the longest gap since the metric existed, named at every GT since S105 (this is the 6th+
consecutive GT to name it), and this session's explicit top recommendation (a real paid dogfood run)
was passed over by the founder in favor of building a third fleet role. That is the founder's call to
make, not the audit's, and is recorded as such — not contested further.

## Active PRs
- **None open.** S115 is a NO-CODE GT; its closeout bundle (`sessions/session-115-ground-truth.md` +
  `.ai/` sync + `prompts/116-...`) is committed on `session-115-closeout` and opened as a PR per the
  standing GT pattern.
- Prior: **S114 [#122](https://github.com/ifelse-codes/vajra/pull/122) MERGED** 2026-08-07, CI green
  both OS · S113 [#120](https://github.com/ifelse-codes/vajra/pull/120) MERGED · S112
  [#118](https://github.com/ifelse-codes/vajra/pull/118) + closeout #119 · S111 #117 · S109 #115 ·
  S110 closeout #116 · S108 #113 + #114 · S107 #112 · S106 #111.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — two roles built and proven, a third (Planner) approved and scoped for S116.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  (S109 ✓ + S111 ✓ + S112 ✓ + S113 ✓ + S114 ✓ + S115 dispatch-proof ✓ — next: S116 builds the third
  role (Planner); the overdue paid dogfood remains the single highest-leverage item not yet picked).**
  Release when v0.1 is stranger-shippable (it is).
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105).

## What Currently Works
- **The fleet has TWO named roles, both proven end-to-end INCLUDING by-name dispatch (S111 for the
  Researcher, S115 for the Fidelity Reviewer).** `vajra init` scaffolds both `.claude/agents/*.md`
  files as *renderings* of `fleet::ROLES` (no drift); `vajra next --role <key> --from <file>` governs
  either into a validated handoff; `vajra next --stations NN` reports fleet evidence beside `K of 8`.
  S115 additionally exercised the S112 read-side + the S113 counter on the SECOND role for the first
  time (`fleet: 1 governed handoff(s) — fidelity-reviewer` at `--stations 115`) — clean, no drift.
- **The reviewer contract is TWO BOUND FILES, not a duplicate:** `reviewer/SKILL.md` is canonical; the
  role's system prompt is its dispatch-time summary. A unit test + a verify check require every
  closeout-gate token in both — mutation-verified in both directions.
- **A real, independent Fidelity Reviewer subagent dispatch, fed only a prompt + a diff, correctly
  re-derived S114's own two-pass fidelity finding cold** (13/13 SHIPPED, same fakest green,
  independently confirmed via live grep rather than trusting the delivery's self-report) — the
  strongest evidence yet that the role's judgment quality, not just its shape, holds up on real input.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE when `total_cost_usd` exists,
  HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → **INTACT**, re-confirmed live at S115
  (`908e00c…` committed head == worktree head).
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (both fleet roles ride `init` + `next`).

## What Is Broken / Weak
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now **12
  sessions / ~11 calendar days** (S115-confirmed via `git log`, correcting the live tool's own
  `--dogfood-age` output — see the residual bug below). Mechanism tests do not reset it; only a real
  paid run does. Deferred again at the S115 closeout by explicit founder choice (picked a third fleet
  role instead) — flagged, not neglected; the next GT should press on this if S116–S119 don't reach it.
- **🟡 NEW (S115): `verify-closeout.sh`'s canonical-verdict regex rejects a valid `|`-table-wrapped
  verdict line.** A real fidelity-reviewer dispatch produced `| **Verdict:** | ACCEPT |` — not "buried
  in a heading" (the failure mode the role's brief explicitly warns against), just table-formatted —
  and the gate's line-anchored regex does not match it. Confirmed by running the actual regex against
  the actual raw output. Candidate fix: loosen the regex to also accept a `|`-delimited two-cell
  verdict row (recommended over tightening the brief to forbid tables). Not fixed this session
  (NO-CODE).
- **🟡 NEW (S115): `--dogfood-age`'s date field can use the wrong commit's date.** It derives the date
  from the git commit that reads the receipt file at scan time, which is not always the commit that
  *produced* the receipt — the S103 receipt was backfilled by an S105 follow-up commit (2026-07-30),
  so the tool reports that date instead of the true run date (2026-07-27, which `git log` confirms and
  which STATE.md already had right). Session-count is unaffected; only the calendar-days figure is off
  (true gap ≈ 11 days, not the tool's reported 8). Durable fix: derive the date from the run's own
  commit, not the file-read commit. Not fixed this session (NO-CODE).
- **🟡 NEW (S115): no standing GT audit checks a prompt's own factual premises against repo reality.**
  S114's cold review caught a false premise ("the reviewer's brief lives nowhere") only by chance of
  the two-pass adversarial process — no required audit in `CONSTRAINTS.yaml#ground_truth` targets this
  class of drift. Named as a real gap in the audit mechanism itself (the S115 meta-check finding), not
  fixed.
- **🟡 The fleet has exactly TWO roles proven; a third (Planner) is scoped for S116 but not yet built.**
  The S114 "one-element registry hides assumptions" pattern is worth re-checking again at three
  elements — two leaks were found going from 1→2 roles; a third may surface more.
- **🟡 Fleet consumption + fleet evidence are ADVISORY, never blocking.** Nothing fails when a session
  ignores a governed handoff. Deliberate; an opt-in gate remains an obvious, still-unpicked next step.
- **🟡 The fleet line counts ARTIFACTS, not agents — except where a real dispatch is independently
  proven** (as S115 did for `fidelity-reviewer`, via the tool-call record). Say precisely what was
  proven in each case; don't conflate "a handoff exists" with "an agent ran" outside a proven instance.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007);
  `ANTHROPIC_API_KEY` is the only auth that survives a fresh no-TTY shell.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111–S114, now S115's
  report as well) — **4 consecutive sessions flagged, unfixed.** An 8th command whose author skipped
  the help text would pass. House-wide, still not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60) — now **496 lines** (was 475 at the S105
  mention). The file's own staleness-disclaimer header is itself now stale (still says "475 lines...
  as of S105"). Prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix (now two distinct residuals:
  subdirectory-recursion + wrong-commit-date)** · **🟡 brew smoke tests a LOCAL formula copy** · **🟡
  x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S115 DONE (NO-CODE GT; lens-A PARTIAL PASS; ledger INTACT; dispatch-by-name RETIRED for the
  next-session case; two new real gaps found — the verdict-regex brittleness and the dogfood-age date
  bug — both filed, neither fixed).** Report: `sessions/session-115-ground-truth.md`.
- **Next = S116 — CODE: the fleet's THIRD named role, the Planner** (founder pick B at the S115
  closeout, over the recommended paid dogfood A; role named specifically Planner, read-only/advisory
  shape). Load-bearing open item: resolve the role-key collision with the existing Planner **station**
  in writing (mirrors the S113/S114 Reviewer-key precedent) — silence is a FAIL. Prompt:
  `prompts/116-task-fleet-role-planner.md`. Deferred by explicit founder call: the paid dogfood
  (🔴 12+ sessions) — next GT should press on this if S116–S119 don't reach it. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111/S112/S113: $0 metered for the build**; cold-review subagent
  tokens roll into the interactive session receipt, unitemized (`scripts/check-subagent-cost-fields.sh`:
  no local subagent transcript carries a cost field).
- **S114: $0 metered for the build; two cold-review subagent passes (~215k subagent tokens) roll into
  this interactive session's receipt, unitemized** — same structural reason as S109/S111/S112/S113.
- **S115: $0 metered (NO-CODE GT); one live `fidelity-reviewer` subagent dispatch (107,664 tokens)
  rolls into this interactive session's receipt, unitemized** — same structural reason as above.
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S115 (unknown, small).**
