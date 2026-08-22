# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-128-first-contact-works` — S128 COMPLETE, PR to open.**

S128 closed with **ACCEPT** on the independent cold `fidelity-reviewer` — one pass, no re-run,
no renumbering. **14 SHIPPED · 2 PARTIAL · 2 NOT-BUILT · 1 N/A**; both PARTIALs and both
NOT-BUILTs were closed after it read, and each closure is named as post-ACCEPT rather than
blended in.

**The first session since S108 that a stranger could notice.** Four defects, every one reproduced
LIVE in an empty directory *before* its fix (`sessions/session-128-repro.md`):

- **`vajra --version` / `-V` now exists** — `env!("CARGO_PKG_VERSION")`, exit 0, a **FLAG** not an
  8th command. Its test parses `Cargo.toml` at runtime instead of comparing against the constant
  the binary prints, so "read from the crate" is falsifiable.
- **The front door fails CLOSED.** An unknown word exits **2** and is named in the message.
  `vajra chek && deploy` no longer runs deploy. Help and bare `vajra` still exit 0.
- **`verify-closeout.sh` survives bash 3.2** on a fresh repo. It reports RED, which is a verdict;
  it no longer aborts, which was not. **Measured, not guessed:** on 3.2.57 `${#arr[@]}` is fine and
  `"${arr[@]}"` is what aborts — the emptiness tests never needed guarding, only the expansions.
- **`vajra check` is honest on arrival: 9/11 → 10/11.** The `vajra.varta missing` demand is
  RETIRED, not patched around, and the drift guard kept its teeth: `absent + tracked by git` FAILS,
  `present + different` FAILS. Only `absent + untracked` — where nothing exists, so nothing can
  have drifted — became a labelled PASS. Both retained failures are driven live in the demo.
- **`stranger_check`** is a required ground-truth audit (`CONSTRAINTS.yaml`), backed by
  `scripts/stranger-check.sh`: a real `mktemp -d`, a real `git init`, the real release binary,
  16 checks, with an in-repo BLOCK guard so it can never measure this repo by accident.

**Numbers:** verify **9/9** · demo **13/13** · stranger-check **16/16** · fixture **12/12** ·
**364** tests · `K of 8` unmoved in derivation and shape · **7 commands**, no 8th.

**🔴 THE RESIDUAL, UNSOFTENED.** The front door works; the SCAFFOLD is still a fork. A stranger
gets a **66-line** constitution against this repo's **183**, and a **7-entry** `required_audits`
against this repo's **11** — `stranger_check` among the four missing. The audit invented to protect
strangers does not reach them, and **S128 REFUSED to fix that** (reviewer rec 4) because
registering a script the scaffold does not ship would make every stranger's ground truth fail a
check it cannot run. The refusal is recorded, with its reason, in the prompt's `## Advice` and as
item 2 of the summary's stranger-still-broken list. Two smaller residuals in the same place: a
stranger's first `vajra check` still exits **1** (`branch: not main` on a fresh `git init`), and
`vajra init` still blocks on stdin without EOF.

**And the honest limit on the ACCEPT, in the reviewer's own words:** *"my ACCEPT does not certify
per-commit content"* — it had no shell, so it verified sha→work from reflog subjects and the final
tree, not from `git show --stat`.

## Active PRs
- **S128 PR — to be opened from `session-128-first-contact-works`.** (Structural drift, named S125
  and S65 and unfixed on purpose: this field is written *before* the PR is opened, so "not yet
  opened" is stale by construction every session. Read git, not this line.)
- S127 [#145](https://github.com/ifelse-codes/vajra/pull/145) MERGED · S126
  [#143](https://github.com/ifelse-codes/vajra/pull/143) MERGED · S125
  [#140](https://github.com/ifelse-codes/vajra/pull/140) MERGED 2026-08-20 · S124
  [#139](https://github.com/ifelse-codes/vajra/pull/139) MERGED · S123
  [#138](https://github.com/ifelse-codes/vajra/pull/138) MERGED · S122 (#133) MERGED · S121 (#131)
  MERGED · S120 (#130) MERGED · S119 (#129) MERGED · S118 (#128) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Fleet = real named agents behind the existing gates
  (`DECISION-007`).
- **Current direction, set by the founder at the S125 closeout: FINISH THE SDLC AGENT FLEET.**
  **S126 closed the *done* half** (nine roles, one per station). **S127 closed the first slice of
  the *working* half** — one gate now consumes a role's output, so skipping that role has a
  consequence. **Whether ONE gate of eight satisfies *working* is the founder's call at the next
  pick**; the S125 reboot backlog stays parked until they say so.
- **Recorded caveat (S125, carried not argued):** S125 findings 1–3 say the four existing roles are
  never reached for, because the shipped scaffold never asks and no gate depends on them. Roles 5–9
  inherit that unless F1/F2 land — so *"and working"* is the load-bearing half of the founder's
  gate, and proving the fleet works may **be** F2.
- **S128 UNPARKED the first-contact slice of the S125 reboot backlog** (founder pick C at the S127
  closeout). The rest of that backlog stays parked. Founder's reasoning, carried because it shapes
  the work: candidate B — binding `obeyed:` harder to the diff — was **rejected on principle**
  (*"we can and should not build a mechanical guardrail"* to an agent that reports it did something
  it did not); candidate A was set aside as extending a team nobody outside this repo can use yet.
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
- **The Advice gate (S127) — the first gate that CONSUMES a governed handoff.** Advice a session
  asked for must carry a recorded, existence-gated disposition or the close path refuses to finish
  the session; `vajra next --advice NN` surfaces it read-only. Driven live at close with every
  other stage neutralised by its own override, so the refusal can only be this gate's. **Read its
  residual in §Active Branch before citing it: it proves ANSWERED, never obeyed.**
- **First contact works (S128) — the first user-reachable change since S108.** `vajra --version` /
  `-V` exists (a flag, not an 8th command) · an unknown subcommand exits **2** and names the word,
  so `vajra <typo> && deploy` cannot run deploy · `--help` and bare `vajra` still exit 0 ·
  `verify-closeout.sh` runs to completion on a fresh scaffold under bash 3.2 · `vajra check` on a
  fresh init is **10/11** with no failure for a file `init` never creates.
- **`stranger_check` (S128) — the ONLY instrument that measures the product, not this repo.**
  `scripts/stranger-check.sh`: real empty dir, real `git init`, real release binary, 16 checks,
  registered in `CONSTRAINTS.yaml#ground_truth.required_audits` with a question list. Falsifiable:
  `scripts/fixture-session-128.sh` plants each of the five defects back and each turns it RED
  **through the check that owns it**, while renaming a message leaves it GREEN.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` **re-confirmed INTACT at S125**
  (`7862ebd4…`, committed == worktree).
- **v0.1 install: four real channels**, stranger-shippable as measured at S110.
- **CI green on `main`** (both OS); 7 commands, no 8th. **340 lib tests** (S126 added one: the five new keys asserted in both directions).

## What Is Broken / Weak

- **🔴 A DISPOSITION CERTIFIES A TYPED WORD, NOT A DEED (S127, the session's own headline).**
  Four `obeyed:` labels in S127's own 51-answer ledger were factually wrong and passed the gate;
  every one was caught by a cold reader, none by the mechanism. **Never read an advice ledger's
  count as evidence the advice was followed.**
- **🟡 ONE gate of eight consumes a handoff (S127).** S126's "nine decorations" is no longer true
  and is not yet false: skipping the roles the *other seven* stations own still has no consequence.
- **🟡 A re-run handoff RENUMBERS (S127).** One role writes one handoff, so a second brief replaces
  the first at that path and previously-recorded answers silently re-point at different advice. The
  gate's orphan warning does not fire when the counts happen to match.
- **🟡 Jurisdiction is self-granted (S127, measured not theorised).** Run against S126's own five
  committed handoffs the Advice gate exits 0 — it would not have caught either drop that motivated
  it. An advisor that never numbers its advice cannot be made to.
- **🟡 `hook-session-guard.sh` false-armed on PROSE (S127, live).** Writing STATE.md text that
  merely *described* the advance command tripped the one-session-per-chat block, because the
  guard's quoted-span strip only removes shell quotes and a heredoc body is unquoted. The S125
  "spelling-bound guards over-block on words" finding, recurring inside the enforcement layer.
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
- **✅ FIXED S128 — `verify-closeout.sh` no longer crashes on a fresh `vajra init` repo.** Kept
  here one session as the record of what it took: 125 sessions, because no instrument ever ran the
  product outside this repo.
- **✅ FIXED S128 — unknown subcommands exit 2 and are named; `vajra --version` exists.**
- **🟡 Boot cost ~100k tokens/session (S125).** 399 KB across the load order; KNOWLEDGE 278 KB
  (70%), ROADMAP 75 KB (19%); cold cache every session by rule. **Supersedes the "KNOWLEDGE §6
  bloat" item — the bloat is §10 (537 of 813 lines), mislabelled since S60.**
- **🟡 Hook blocks print their reason to stdout (S125).** `hook-pre-write.sh` exits 2 with the
  explanation on stdout, so the agent receives only `No stderr output`. One-line `1>&2` fix.
- **🟡 The GT fence is asymmetric (S125).** `hook-pre-write.sh` fences by path;
  `hook-pre-bash.sh` fences Bash by substring-matching git verbs — so a plain `>` redirect writes
  freely under NO-CODE, while a `cat >` merely *mentioning* a git verb in its payload is blocked.
- **✅ HALF-FIXED S128 — first-run `vajra check` is 10/11**, the `vajra.varta` demand retired. Still
  red in two smaller ways, both named and neither decided: it **exits 1** on a fresh `git init`
  (`branch: not main` — true and actionable, but `vajra check && …` still stops on a brand-new
  repo), and `vajra next` still calls init's own prompt 00 "predates the team" on 4 of 8 stations.
- **✅ FIXED S128 — a required GT audit now looks at what a stranger receives** (`stranger_check`).
  **But read the next line before crediting it.**
- **🔴 THE SCAFFOLD IS STILL A FORK, IN TWO PLACES (S128, one of them new).** The 66-vs-183
  constitution below, **and** `src/cli/init.rs`'s `required_audits`, which ships strangers **seven**
  entries against this repo's **eleven** — missing `stranger_check`, `dogfood_check`,
  `pipeline_advance_check` and `dogfood_staleness`. *A stranger's ground truth will never run the
  audit invented to protect strangers.* **S128 REFUSED to fix it** (reviewer rec 4, refused with a
  reason): registering an audit whose script the scaffold does not ship would make every stranger's
  GT fail a check it cannot run. Fixing it means deciding what a stranger's audit list should BE.
- **🟡 `stranger_check` is REGISTERED, not RUN (S128 second-fakest-green, unfixed).** Nothing forces
  a future ground-truth session to execute it — the self-granted-jurisdiction class from S68/S71.
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
- **S128 DONE (CODE, ACCEPT).** Two source files changed and both are DECLARED in the verify suite
  with a reason — `src/main.rs` (the front door + the version flag) and `src/cli/check.rs` (whose
  evidence contract MOVED, by design and by order: an absent `vajra.varta` was a FAIL and is now a
  labelled PASS). No gate or station module touched. `K of 8` unmoved; 7 commands, no 8th.
- **Nothing is in flight.** S129 is the founder's pick from the three candidates in
  `sessions/session-128-summary.md`. **S130 is the mandatory NO-CODE ground truth** — and it is the
  first GT that must run `stranger_check`.

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
- **S128: $0 metered for build** (interactive; one `fidelity-reviewer` subagent pass rolls in
  unitemized). Dogfood staleness unchanged — last paid dogfood remains S124.
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S124 subagents (unknown,
  not small).**
