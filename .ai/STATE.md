# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-126-finish-the-fleet`** — S126 COMPLETE (CODE), **ACCEPT** on the independent cold
`fidelity-reviewer` pass (**7 of 9 SHIPPED**, 2 PARTIAL, 0 NOT-BUILT — the two PARTIALs were the
review record and the summary, which cannot exist in the diff the reviewer reads).

**The fleet roster is COMPLETE: four roles → nine.** Every one of the 8 stations now has a named
role, plus the station-less `researcher`. New keys, each resolving the STATION-vs-ROLE collision
the S114/S116/S121 way: `requirements-analyst` (Analyst) · `design-advisor` (Architect) ·
`implementation-advisor` (Coder) · `demo-producer` (Demo-er) · `release-coordinator` (Releaser).

**Five roles added, ZERO new grants of `Bash`.** The one real fork — does the Coder role get
`Write`/`Edit`? — resolved **read-only**: granting it would reverse S123 and the S122
executor-thesis retraction in the same session that ships it. A write grant is now a separate,
founder-gated decision (`DECISION-007` S126 addendum).

**All five DISPATCHED BY NAME from five separate headless sessions** — the S111 session boundary
crossed five times instead of waiting five sessions — each cross-checked against two
Claude-Code-written files agreeing on a random tool-call id. **$4.4482 metered.**

**Residual, stated not softened: the roster is complete and NOTHING DEPENDS ON IT.** No gate
consumes a handoff; nine roles that nothing depends on is nine decorations. S126 closes the *done*
half of the founder's gate; the *working* half is S127.

## Active PRs
- **S126 PR — to be opened from `session-126-finish-the-fleet`.** (Structural drift, named S125
  and S65: this field is written *before* the PR is opened, so "not yet opened" is stale by
  construction every session. Read git, not this line.)
- S125 [#140](https://github.com/ifelse-codes/vajra/pull/140) MERGED 2026-08-20 · S124
  [#139](https://github.com/ifelse-codes/vajra/pull/139) MERGED · S123
  [#138](https://github.com/ifelse-codes/vajra/pull/138) MERGED · S122 (#133) MERGED · S121 (#131)
  MERGED · S120 (#130) MERGED · S119 (#129) MERGED · S118 (#128) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Fleet = real named agents behind the existing gates
  (`DECISION-007`).
- **Current direction, set by the founder at the S125 closeout: FINISH THE SDLC AGENT FLEET.**
  Four roles built (`researcher`, `fidelity-reviewer`, `plan-advisor`, `qa-specialist`); **five
  stations still have no named role** — Analyst, Architect, Coder, Demo-er, Releaser. The S125
  reboot backlog stays parked until the fleet is done **and working**.
- **Recorded caveat (S125, carried not argued):** S125 findings 1–3 say the four existing roles are
  never reached for, because the shipped scaffold never asks and no gate depends on them. Roles 5–9
  inherit that unless F1/F2 land — so *"and working"* is the load-bearing half of the founder's
  gate, and proving the fleet works may **be** F2.
- **Post-pivot path:** C team-voice (S104 ✓) → B installable v0.1 ✓ → A fleet (4 of 9 roles) →
  S118 ✓ dogfood → S119 ✓ clean-room → S120 ✓ GT → S121 ✓ QA Specialist → S122 ✓ guardrails fixed →
  S123 ✓ `Write`/`Edit` grant fenced → S124 ✓ paid dogfood (fleet measured idle) →
  **S125 ✓ MANDATORY GT + full-stack review (PARTIAL PASS; findings parked) → S126 = finish the
  fleet.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The enforcement floor is real and re-verified in a FRESH repo (S125, new evidence).** A clean
  `vajra init` + a commit attempt on `main` → `.githooks/pre-commit` blocks, exit 1, clear message.
  No config required. This is the strongest thing in the product.
- **The co-pilot hook fires and is obeyed (S125, live).** It blocked this session's own agent mid-run
  and refused until `.ai/STATE.md` was read — the same mechanism S124 traced end-to-end under
  `--dangerously-skip-permissions`.
- **The fleet roster is COMPLETE at NINE named roles (S126), all proven dispatched by name.**
  One per station — `requirements-analyst` · `design-advisor` · `plan-advisor` ·
  `implementation-advisor` · `qa-specialist` · `demo-producer` · `release-coordinator` ·
  `fidelity-reviewer` — plus the station-less `researcher`. **Exactly one executes**
  (`qa-specialist`, narrowed grant `Bash, Read, Grep, Glob`, S123, dispatched through a disposable
  `git worktree` checkout); the other eight are read-only, token-exact. Each role's prompt cites
  the exact marker its station's gate already parses, and every role PROPOSES — none authors the
  recorded marker section. **Read the next section before quoting this one: nothing depends on any
  of them.**
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` **re-confirmed INTACT at S125**
  (`7862ebd4…`, committed == worktree).
- **v0.1 install: four real channels**, stranger-shippable as measured at S110.
- **CI green on `main`** (both OS); 7 commands, no 8th. **341 lib tests** (S126 added one: the five new keys asserted in both directions).

## What Is Broken / Weak

- **🔴 THE FLEET IS DONE BUT NOT WORKING (S126, the session's own headline).** Nine roles are
  registered, scaffolded, dispatchable and governed — and **no gate consumes a handoff**, so
  skipping every role has no consequence. Nine decorations. This is the founder's gate to unpark
  the S125 backlog, and only its *done* half is closed. **S127 = make one gate consume a handoff.**
- **🟡 The dispatch cross-check runs over COPIES (S126 fakest green, reviewer's call).** The
  committed `*-parent-tooluse.json` / `*-subagent-meta.json` pairs are checked for internal
  consistency; nothing binds them to the runtime originals in `~/.claude/projects/`, so a
  *consistent* fabrication would pass exactly as a real dispatch does. What makes fabrication
  implausible is off-check (five result streams, distinct session ids, $4.45 metered, ~600KB of
  transcripts).
- **🟡 Five smaller S126 review findings, filed to S127, not fixed after the ACCEPT:** the
  `K of 8` invariance check compares at a degenerate `0 of 8` baseline · the demo omits the one
  out-of-fleet edit its own `demo-producer` brief said to show · `verify-session-121.sh`'s check
  name still says "four" after being unpinned · `verify-session-114.sh`/`-116.sh` still pin 2 and 3
  roles and are permanently red if run (no live chain runs them) · the attestation-ordering hazard
  (the attested inputs differ from what the reviewer read by exactly the two closing sha lines).

**🅿️ S125 full-stack review — findings PARKED by founder call (2026-08-20).** Gate to unpark: the
SDLC agent fleet is done AND working. Backlog: `ROADMAP.md` §Backlog "🅿️ S125 REBOOT BACKLOG".
Evidence: `sessions/session-125-ground-truth.md`. Listed here so they surface at every boot — not
to be worked before the gate.

- **🔴 `vajra init` ships a 55-line constitution while this repo runs 183 (S125).** The scaffolded
  `AGENTS.md`/`CONSTRAINTS.yaml` are hand-maintained inline consts in `src/cli/init.rs`; the
  fidelity map, no-self-certification, the cold review, the GT session, the fleet, and six config
  blocks (incl. `enforcement:`) are all absent. **Everything S54–S124 added to governance exists
  only in this repo.** Fix = `include_str!` (F1).
- **🔴 The shipped scaffold self-contradicts (S125).** Its `verify-closeout.sh` hard-blocks without
  `sessions/session-NN-review.md` + ACCEPT; its `AGENTS.md` never mentions that file. This is the
  incentive that produced S124's fabricated citation — root-caused, not merely repeated.
- **🔴 Vajra governs artifacts, never actors (S125 — architectural).** No gate can ask "did someone
  other than you write this?" `src/cli/next.rs:275` hardcodes `"claude-code-subagent"` as
  provenance; `src/stations/mod.rs:102` says in a comment that the counter cannot verify a real
  dispatch. The ledger is tamper-evident about content, blind about authorship. Fix = the dispatch
  receipt S111/S117 already built by hand twice and never gated (F2).
- **🔴 `verify-closeout.sh:87` crashes on every fresh `vajra init` repo (S125).** `set -u` + empty
  glob on bash 3.2 (macOS default) → `summaries[@]: unbound variable`, zero output, exit 1. The L4
  fail-closed layer is broken on first contact.
- **🔴 Unknown subcommands exit 0 (S125).** `src/main.rs:36` — `vajra chek && deploy` runs deploy.
  Fail-open front door. Still no `vajra --version`.
- **🟡 Boot cost ~100k tokens/session (S125).** 399 KB across the load order; KNOWLEDGE 278 KB
  (70%), ROADMAP 75 KB (19%); cold cache every session by rule. **Supersedes the "KNOWLEDGE §6
  bloat" item — the bloat is §10 (537 of 813 lines), mislabelled since S60.**
- **🟡 Hook blocks print their reason to stdout (S125).** `hook-pre-write.sh` exits 2 with the
  explanation on stdout, so the agent receives only `No stderr output`. One-line `1>&2` fix.
- **🟡 The GT fence is asymmetric (S125).** `hook-pre-write.sh` fences by path;
  `hook-pre-bash.sh` fences Bash by substring-matching git verbs — so a plain `>` redirect writes
  freely under NO-CODE, while a `cat >` merely *mentioning* a git verb in its payload is blocked.
- **🟡 First-run UX is red (S125).** Fresh init → `vajra check` 9/11, failing on `vajra.varta
  missing`, a file `init` never creates; `vajra next` calls init's own prompt 00 "predates the
  team" on 4 of 8 stations.
- **🟡 No required GT audit looks at what a stranger receives (S125).** Every instrument measures
  this repo governing itself — which is why all of the above hid for 125 sessions. Fix = a
  `stranger_check` audit (F5).
- **🟡 Adoption flat (S125, measured):** 0 stars · 0 forks · 0 issues · 0 external contributors ·
  19 crates.io downloads. Last user-reachable change was **S108 (2026-08-01), 16 sessions ago.**

**Carried from earlier sessions (unchanged by S125):**
- **🔴 The S121–S123 fleet + clean-room machinery is UNPROVEN under real, unprompted use** (S124) —
  root-caused by S125 (see the three 🔴 above), still unfixed.
- **🔴 A dogfood harness's wall-clock watchdog does not fire** (S124) — `run-task.sh` `TIMEOUT_SECS`
  never terminated a 12,474s run. The `$5` cap held by task luck, not mechanism.
- **🔴 Coder-dark for S119** (S120) · **🔴 The executor thesis is UNPROVEN** · **🔴 The check-class
  tally is a SELF-ASSIGNED LABEL**.
- **🟡 3 behavioral source greps in `verify-session-119.sh`** (S120) · **🟡 VISION.md body still
  references the retired machinery-freeze rule** (S120) · **🟡 clean-room untested via the compiled
  CLI path for `--check-qa`/`--check-demo`** · **🟡 Planner-gate double-count bug**
  (`task_2162b487`) · **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirs**
  (S115) · **🟡 `no-eighth-command` is a grep for a hardcoded usage banner** · **🟡 `vajra.varta`
  re-render drifts every session** · **🟡 brew smoke tests LOCAL formula** · **🟡
  `measurement-artifact-cited`** (S123) · **🟡 five `def.contains(…role.name…)` instances by
  design**.
- **🟡 `vajra init` blocks on stdin without EOF** (needs `</dev/null`) · **🟡 `vajra init`'s
  skip-if-present is file-granularity, not key-granularity** (S124).
- **🟡 chitra `session-12-bar-chart-lock` sits uncommitted and REJECTED** — chitra's own next
  session, not Vajra's.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S126 DONE (CODE, ACCEPT).** The roster is complete at nine roles; only `src/fleet/mod.rs`
  changed in `src/`; `K of 8` unmoved; no 8th command. One file outside the fleet was touched —
  `scripts/verify-session-121.sh`'s roster-SIZE pin (`= 4` → `-ge 4`), because
  `verify-session-122.sh` re-runs the S121 suite LIVE and the breakage chained. Both re-run green.
- **S127 = the WORKING half: make a gate CONSUME a handoff** (S116's unpicked candidate C +
  S125's F2). Prompt: `prompts/127-task-*.md`. Until it lands, the S125 reboot backlog stays
  parked and the fleet stays decoration.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered.** **S120: $0** (NO-CODE GT). **S121–S123: $0 metered** (interactive;
  subagent passes roll in unitemized).
- **S124: $3.2984944499999984** authoritative (sonnet, headless `-p`, 12474s wall / 1662s internal,
  69 turns, ended in a real API-connection error).
- **S125: $0 metered** (interactive NO-CODE GT; zero subagents dispatched — every finding was
  derived first-hand). Dogfood staleness NOT reset by this session: `vajra next --dogfood-age`
  reads S124, 2026-08-20, 0 sessions / 0 days since.
- **S126: $4.4482 authoritative** — five headless `claude -p` dispatches (one per new role), each
  figure the run's own `total_cost_usd`. The orchestrating interactive session's own cost is not
  metered here. Dogfood staleness unchanged (last paid dogfood = S124).
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S124 subagents (unknown,
  not small).**
