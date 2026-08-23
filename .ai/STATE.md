# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-129-one-source-scaffold` — S129 COMPLETE, PR to open.**

S129 closed with **ACCEPT on TWO independent cold passes**, run because the post-ACCEPT work after
pass 1 was substantive enough that shipping pass 1's verdict over changed code would have been
dishonest. **Pass 2: 14 SHIPPED · 2 PARTIAL · 0 NOT-BUILT.** 17 recommendations across both passes
— **16 obeyed, 1 refused with a reason.**

**What a stranger gets now.** For 128 sessions the constitution `vajra init` handed them was a
hand-typed fork of the one this repo runs on, and nothing compared the two. It had drifted to
**8 binding rules of 13** (two of those under a different NAME, which is why equality was never
checkable) and **7 audits of 11**, with **no reason on record for a single omission**. Now:

- **13 of 13 binding rules · 10 of 12 audits · 7 of 7 drift axes**, names byte-exact.
- **`build.rs` derives them at compile time** from `.ai/AGENTS.md#Hard Rules` and
  `.ai/CONSTRAINTS.yaml#ground_truth`. **The DEFAULT is CARRIED** — a rule added here reaches every
  future scaffold with no action taken. The failure mode that made the fork is structurally gone,
  not merely detected.
- **Deviation must be declared, and the declaration SHIPS to the stranger** —
  `scaffold-omits-audit:` / `scaffold-omits-rule:` / `scaffold-retexts-rule:`, each with its reason,
  in their own file. **A stale declaration PANICS the build.**
- `stranger_check` stays declared OUT with S128's own reason (its evidence script is not shipped);
  S128 refused this in prose inside a prompt, where nothing reads it — it is enforced data now.
- **`scripts/scaffold-drift.sh`** — the guard missing for 128 sessions. Real `mktemp -d`, real
  `git init`, the real release binary; it reads only what a real `vajra init` writes, never the
  templates. Three inventories, both directions. **Its GREEN line states its own JURISDICTION.**
- `Cargo.toml` un-excludes the two derivation sources, so `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml`
  are **compile inputs that ship inside the published crate** — asserted via `cargo package --list`.

**Numbers:** verify **12/12** · demo **15/15** · drift **17/17** · stranger **21/21** (was 16) ·
fixture **18/18** (7 plants + a control) · **365** tests · `K of 8` unmoved · **7 commands**.

**BOTH COLD READERS FOUND A FORK THE BUILDER HAD NOT SEEN, INSIDE THE BLAST RADIUS OF THE FIX.**

- **Pass 1 → `drift_axes`**, a THIRD hand-typed twin, 6 against 7, *three lines above the derived
  include, in the block the session had just rewritten.* Its words: *"the honest form of the
  summary's residual is: we did not look one line up."* **Derived in-session.**
- **Pass 2 → the FOURTH fork, and it is the standing residual.** `TPL_CONSTRAINTS` hand-types a
  family of twins of live `.ai/CONSTRAINTS.yaml` keys, **and two are already WRONG in a stranger's
  file**: `communication.forbid` ships **4 of our 5**, and **`commit.forbid_skip_hooks` is absent
  while `src/varta/render.rs:84` reads it.** Also absent: `commit.forbid_force_push_to`,
  `self_review_questions` (read at `src/varta/render.rs:194`), the whole `end_of_session` block.
  Plus the scaffolded load order (8 vs 9) and session loop (9 vs 10) — sections the live file labels
  *Mandatory*. **REFUSED in-session, with a reason:** block-shaped keys under three YAML parents
  needing a KEY-SET inventory, not a fourth list comparison — and hand-patching the two drifted
  lines would put fresh hand-typed content into the session that removed it. Named in four places,
  including `scaffold-drift.sh`'s own GREEN output. **It is the S131 candidate A.**

**🔴 UNPLANNED FIND, and the most important thing here for the next session:**
**`vajra next --check-plan` had been mis-parsing EVERY prompt since the heading changed.** The house
heading `## Plan (ordered — cite the acceptance criteria each step covers)` contains the word
*acceptance*, and the acceptance parser matched on `contains` — so a plan's own steps were counted
as acceptance criteria. It surfaced only because S129's plan had eleven steps against ten criteria
and the gate demanded a `covers: 11` for a criterion that does not exist. **The Planner station in
`K of 8` has been reporting PASSED off that parser.** Fixed at the source with a falsifiable test.
**The lesson is the general one: a registered gate nobody executes is not a gate.**

**Fakest green (pass 2's call, adopted over the builder's own):** *the drift check's jurisdiction is
defined by the thing it audits.* "Every difference declared with a reason" was a statement about the
three lists `build.rs` happens to derive, not about the files. The in-session fix is **honesty, not
coverage** — the GREEN line now names the family it cannot see.

**Standing residuals, unsoftened:** the fourth fork · carrying a rule is not enforcing it (the same
hook set enforces, untouched) · a declared rewrite's wording is unconstrained forever after ·
**`scaffold_drift_check` is REGISTERED, not RUN** (identical to S128's `stranger_check` residual —
and the Planner mis-parse is exactly what that costs) · `vajra init` still blocks on stdin without
EOF · a stranger's first `vajra check` still exits 1 · **0 stars · 0 forks · 0 issues · 19 downloads,
unchanged.**

## Active PRs
- **S129 PR — to be opened from `session-129-one-source-scaffold`.** (Structural drift, named S65,
  S125 and S128 and unfixed on purpose: this field is written *before* the PR is opened, so "not yet
  opened" is stale by construction every session. Read git, not this line.)
- S128 [#147](https://github.com/ifelse-codes/vajra/pull/147) MERGED · S127
  [#145](https://github.com/ifelse-codes/vajra/pull/145) MERGED · S126
  [#143](https://github.com/ifelse-codes/vajra/pull/143) MERGED · S125
  [#140](https://github.com/ifelse-codes/vajra/pull/140) MERGED · S124
  [#139](https://github.com/ifelse-codes/vajra/pull/139) MERGED · S123
  [#138](https://github.com/ifelse-codes/vajra/pull/138) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Fleet = real named agents behind the existing gates
  (`DECISION-007`).
- **Current direction, set by the founder at the S127 closeout and continued at S128: FIRST CONTACT
  over more fleet work.** S128 fixed what a stranger hits; **S129 fixed what a stranger is GOVERNED
  BY** — the founder picked A in plain English, over the first-contact residuals (B) and a paid
  ride-along (C). The rest of the S125 reboot backlog stays parked.
- **The founder's S125 gate is still open: nine roles is "done"; "and WORKING" is unproven.** One
  gate consumes one handoff (S127). S128 and S129 each reached for exactly one role — the
  `fidelity-reviewer` — and S129 dispatched no advisor at all before building. **S130's GT must
  answer whether that is a fleet or a roster.**
- **Post-pivot path:** S118 ✓ dogfood → S119 ✓ clean-room → S120 ✓ GT → S121 ✓ QA Specialist →
  S122 ✓ guardrails → S123 ✓ role fenced → S124 ✓ paid dogfood → S125 ✓ GT (PARTIAL) →
  S126 ✓ fleet complete → S127 ✓ Advice gate → S128 ✓ first contact → **S129 ✓ one source →
  S130 = MANDATORY GT, and the first that must RUN both product-facing audits.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
  **Read the Planner caveat above before trusting a historical `K of 8`.**
- **The enforcement floor is real and re-verified in a FRESH repo (S125).** A clean `vajra init` +
  a commit attempt on `main` → `.githooks/pre-commit` blocks, exit 1, clear message. No config
  required. This is still the strongest thing in the product.
- **The co-pilot hook fires and is obeyed (S125, live; fired again in S129 before every commit).**
- **The fleet roster is COMPLETE at NINE named roles (S126)**, one per station plus the station-less
  `researcher`; exactly one executes (`qa-specialist`). **Nothing depends on eight of them** — see
  the direction note above.
- **The Advice gate (S127)** — the first gate that CONSUMES a governed handoff. It proves ANSWERED,
  never obeyed. S129 answered 17 recommendations through it, one of them a refusal.
- **First contact works (S128)** — `vajra --version`, an unknown subcommand exits 2 and is named,
  `verify-closeout.sh` survives bash 3.2, `vajra check` is 10/11 on a fresh init.
- **One source for what a stranger is governed by (S129)** — the whole §Active Branch above.
- **TWO instruments now measure the PRODUCT rather than this repo governing itself:**
  `scripts/stranger-check.sh` (S128, 21 checks) and `scripts/scaffold-drift.sh` (S129, 17 checks).
  Both registered as required GT audits. **Neither has ever been run BY a ground truth. S130 is the
  first that must.**
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` re-confirmed INTACT at S125.
- **v0.1 install: four real channels**, stranger-shippable as measured at S110. `vajractl 0.1.0` on
  crates.io predates everything above.

## What Is Broken / Weak
- **🔴 THE FOURTH FORK — refused at S129, and TWO of its keys are already WRONG in a stranger's
  file.** `TPL_CONSTRAINTS` in `src/cli/init.rs` hand-types twins of live `.ai/CONSTRAINTS.yaml`
  keys: `communication.forbid` ships **4 of our 5**; **`commit.forbid_skip_hooks` is absent while
  `src/varta/render.rs:84` READS it**, so a stranger's Varta render silently drops that governance
  line. Also absent: `commit.forbid_force_push_to`, `self_review_questions` (read at
  `src/varta/render.rs:194`), the whole `end_of_session` block (cited by `src/analyst/mod.rs` and
  `src/cli/next.rs`). Plus `demo.required_elements` and `verify.artifacts_dir` (twins that agree
  today), the scaffolded load order (8 vs 9) and session loop (9 vs 10). **S131 candidate A.**
- **🔴 A registered gate nobody executes is not a gate.** `vajra next --check-plan` had been
  mis-parsing every prompt since the `## Plan (ordered — cite the acceptance criteria each step
  covers)` heading was adopted; the Planner station in `K of 8` reported PASSED off it. Fixed at
  S129. **Assume the same of any other gate no session has run** — that is an S130 GT question.
- **`stranger_check` and `scaffold_drift_check` are REGISTERED, not RUN.** Nothing forces a ground
  truth to execute either. S130 is the first that must.
- **Carrying a rule is not enforcing it.** A stranger READS all 13 binding rules; what enforces them
  is the same hook set as before, untouched by S129.
- **A declared rewrite's wording is unconstrained forever after.** `scaffold-retexts-rule:` proves a
  declaration and a reason exist; it never proves the rewrite preserves the rule.
- **The fleet is nine roles that almost nothing reaches for.** One gate consumes one handoff (S127);
  S128 and S129 each dispatched exactly one role. The founder's "done AND working" gate is open.
- **A recorded disposition certifies a typed word and a resolving sha, nothing more (S127).**
- **`vajra init` blocks on stdin without EOF**; a stranger's first `vajra check` exits 1.
- **Adoption has never moved: 0 stars · 0 forks · 0 issues · 19 downloads.**
- **Dogfood is stale.** Last paid run S124 (`$3.2985`). Read `vajra next --dogfood-age`, never this
  file.

## What Is In Progress
- **Nothing is mid-flight.** S129 is complete and its PR is to be opened; S130 is the mandatory
  NO-CODE ground truth (`prompts/130-task-ground-truth.md`) and takes no code.
- Queued for the founder's pick at the S130 closeout: **A** the fourth fork + a KEY-SET inventory ·
  **B** F2, the dispatch receipt · **C** a paid dogfood ride-along from a FRESH scaffold.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered.** **S120: $0** (NO-CODE GT). **S121–S123: $0 metered.**
- **S124: $3.2984944499999984** authoritative (sonnet, headless `-p`) — **the last paid dogfood.**
- **S125: $0 metered** (interactive NO-CODE GT).
- **S126: $4.4482 authoritative** — five headless `claude -p` dispatches, each figure the run's own
  `total_cost_usd`. The orchestrating interactive session's own cost is not metered here.
- **S128: $0 metered for build** (interactive; one `fidelity-reviewer` subagent pass, unitemized).
- **S129: $0 metered for build** (interactive; **two** `fidelity-reviewer` subagent passes roll in
  unitemized — ~113k and ~154k subagent tokens respectively, which is the largest un-metered review
  spend of any session so far and worth naming rather than reporting as "$0"). **Dogfood staleness
  unchanged — the last paid dogfood remains S124.**
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S129 subagents (unknown,
  not small).**
