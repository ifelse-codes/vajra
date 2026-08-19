# DECISION-007 — agent fleet, slice 1: a named role as a governed Claude Code subagent

- **Date:** 2026-08-02 (Session 109)
- **Status:** ACCEPTED
- **Type:** architecture decision (a new product direction — the named-agent fleet)
- **Relates to:** DECISION-001 (governance is the product), DECISION-005 (autopilot trust — "leave a
  team of agents working, come back, trust the result"), and the S103 fleet-vs-gates fork (opened at
  the founder pivot; recommended shape = **both**). This decision resolves that fork for the FIRST
  slice only and locks the subagent dispatch + handoff mechanism it introduces.

---

## Context — why decide now

The product's headline is a **team** of agents you can trust unattended (DECISION-005). But in code,
`vajra claude` launches exactly **one** undifferentiated agent. The eight "stations" (S104) are
**gates + a team-voice roster** — labels over a single agent, not real separate agent invocations.
The fleet fork opened at S103 has **0 code**. B (installable v0.1) is complete (S106–S108), so A (the
fleet) is the right next leg — but a fleet is many sessions. This decision de-risks it by locking the
**one-agent-one-handoff primitive** before any parallelism or multi-stage orchestration is designed.

## The fork, resolved (first slice only)

**Both.** The fleet is **real named agents running behind the existing trust gates** — not a
gate-only pipeline, and not a fleet that routes around governance. This decision commits only to
slice 1 (**one** role, the Researcher); it does **not** design the whole fleet (parallelism, a second
role, multi-stage orchestration are all explicitly deferred).

## Decision — the fleet is native Claude Code subagents, scaffolded + governed by Vajra

A named role is a **native Claude Code subagent** (a `.claude/agents/<name>.md` definition the
running agent dispatches via its Task tool), NOT a fresh `claude -p` subprocess Vajra spawns.

**Why the subagent model (chosen over a `claude -p` subprocess):** Vajra is an external binary — it
cannot *call* a Claude Code subagent (those exist only inside a running agent session). So Vajra's
role for a named agent is not "spawn the process" but **scaffold the role + govern its handoff** —
which is exactly what Vajra already is (the coach, not the coder; DECISION-001) and exactly how it
already scaffolds `.claude/settings.json` + hooks (S44). Concretely the subagent model:

- **inherits the live session's auth** — no separate headless login. (S109 proved the alternative's
  cost: a `claude -p` subprocess hit a "Not logged in" headless-auth wall that only the human can
  clear. The subagent path has no such wall.)
- **is the native Claude Code idiom** — `.claude/agents/*.md` is the built-in "named role with a
  scoped prompt" mechanism; it maps 1:1 to this decision.
- **meters for free** — a subagent's cost rolls into the parent session's receipt (`meter`'s
  `subagent_dir` already accounts for it).

Vajra's two jobs, both locked here:

### 1. Scaffold the role as a subagent — one canonical source, rides `vajra init`

`vajra init` writes `.claude/agents/<name>.md` for every role in `fleet::ROLES`, rendered by
`fleet::render_subagent_definition` (YAML frontmatter `name`/`description`/read-only `tools` + the
role's system prompt + a pointer to the governed handoff). The role text lives in **exactly one
place** (`fleet::ROLES` — the S104/S99 no-drift rule); the subagent file is a *rendering* of it, the
same way `.claude/settings.json` is scaffolded. The role source is **vendor-neutral**; only the
rendering is Claude-specific (v1 is Claude-first — ADR-0001 — so this matches the existing posture).

### 2. Govern the handoff — rides `vajra next`, fail-closed

The subagent returns a findings brief. `vajra next --role <name> --from <findings>` (or `--from -`
for stdin) wraps it into a **governed handoff**:

- **Where:** `.ai/handoffs/session-{NN}-{role}.md` — the `.ai/` spine **is** the memory
  (`feedback-map-concepts-to-vajra`); no new store, no 8th artifact type, no 8th command.
- **What:** frontmatter (`role`, `session`, `agent`, `source-sha` = sha256 of the exact findings,
  `captured` timestamp, `cost_usd` = `null` for slice 1 — the subagent cost is in the session
  receipt, disclosed in the summary) + the findings body + a **`## Handoff Delta`** section.
- **Delta tracking:** `## Handoff Delta` records what this handoff adds vs the prior stage (slice 1
  has no prior handoff — the prior stage is the session prompt / Analyst's WHAT — so it records
  "new" + byte count; a re-run records the size change against the existing handoff).
- **Fail-closed:** an unknown role, a missing/empty findings file, or a handoff that would not
  validate all exit non-zero — an unusable handoff never reads as a successful step. The subagent is
  told NOT to author the frontmatter; Vajra owns the hash, timestamp, and delta.

## Alternatives considered

- **A `claude -p` subprocess Vajra spawns** (`vajra claude --role`, agent injectable via
  `VAJRA_AGENT_CMD`) — built first this session, then **replaced** (founder call): it needs headless
  credentials Vajra cannot supply (the S109 auth wall), and it makes Vajra a process-spawner rather
  than a coach. It could return later as an *unattended, no-parent-session* mode, but it is **not
  built** and is out of scope here.
- **A new `vajra research` / `vajra agent` top-level command** — rejected: breaks the max-7 rule for
  a capability existing commands already carry (`init` scaffolds, `next` governs).
- **A new handoff store (DB / `.vajra/` dir / JSON index)** — rejected: `.ai/` already IS the memory.
- **Designing the whole fleet now** — rejected as scope creep (the named key risk of S109).

## Consequences

- **Locked:** fleet = native Claude Code subagents behind the existing gates; `vajra init` scaffolds
  `.claude/agents/<name>.md` from the canonical `fleet::ROLES`; `vajra next --role <name> --from`
  governs the findings into `.ai/handoffs/session-{NN}-{role}.md` with the frontmatter + `## Handoff
  Delta` contract; unknown role / missing-or-empty findings / malformed handoff all fail closed.
- **Deferred (need their own decision):** a second/third role, parallel dispatch, multi-stage
  orchestration, per-subagent cost in the handoff, an unattended `claude -p` dispatch mode.
- **Reversible?** Additive — nothing existing changes behavior. A later decision can extend the
  handoff contract or add the unattended dispatch mode without breaking slice-1 artifacts.

## S111 addendum — the def-vs-dispatch wire, closed with on-disk proof

S109 proved the scaffold and a real subagent run **separately**: the live run was dispatched by
handing the Task tool a hand-typed copy of the canonical prompt, not by resolving `subagent_type`
against the scaffolded file. S111 closed this:

- **The mechanism (confirmed, not assumed):** Claude Code auto-discovers project-level
  `.claude/agents/<name>.md` files into available subagent types **once, at session start**. A file
  written mid-conversation is invisible to that same conversation (verified as a real negative
  result — see `sessions/session-111-artifacts/researcher-run-note.md`). A **fresh** session
  (`vajra claude` in a freshly-`vajra init`'d repo) that is asked to "use the researcher subagent"
  dispatches it **by that name** — confirmed by TWO independently-written Claude Code files agreeing
  on a random tool-call ID they didn't choose, not by a single copy-pasted JSON blob: the parent
  session's transcript records `subagent_type: "researcher"` on tool call `toolu_01BUEt…`
  (`researcher-parent-tooluse.json`), and the subagent's own `agent-<id>.meta.json` independently
  records `toolUseId: toolu_01BUEt…` resolved to `agentType: "researcher"` — same ID, two files,
  two different Claude Code runtime paths. The raw subagent transcript is captured byte-for-byte too
  (`researcher-subagent-transcript.jsonl`, sha256 cited in the run note). Full evidence:
  `sessions/session-111-artifacts/`.
- **Cost, checked not guessed, and re-runnable:** `scripts/check-subagent-cost-fields.sh` scans
  every real subagent JSONL transcript on the checking machine (not a one-off count baked into a
  doc-comment) for `total_cost_usd` / `cost_usd`. Zero found, at every run so far including S111's
  own dispatch. A subagent never produces the headless `-p` result stream that field lives on
  (S77/S78 root cause), so the figure structurally does not exist for Vajra to read. `cost_usd: null`
  stays, now for a specific, falsifiable, checked, **re-runnable** reason — anyone can re-run the
  script and get the same answer, and `--assert-null` turns it into a regression check.
- **Consequence:** the fleet's first slice is fully wired end-to-end — scaffold (`vajra init`) →
  live dispatch-by-name (Claude Code's own mechanism, a fresh session) → governed handoff
  (`vajra next --role --from`). No code change was needed to the dispatch path itself; S109 had
  already built it correctly. What was missing was the proof, which S111 supplies.

## S113 addendum — the SECOND role is the **Reviewer** (chosen, not built)

**Status: CHOSEN.** S113's deliverable was to pick the second role from evidence and record why;
building it is its own session (the S109 anti-scope-creep rule still applies). No `fleet::ROLES`
entry, no `.claude/agents/reviewer.md`, no code ships with this addendum.

### The evidence that drove it (all from this repo, countable)

1. **It is the one dispatch this repo already performs every single session — 46 times.**
   `ls sessions/*-review.md` = **46** independent cold reviews, S55 through S112, plus S67/S112/S113
   running it TWICE. It is not a hypothetical role; it is the fleet's busiest real job, running
   today with no scaffold at all.
2. **The constitution mandates it and forbids the alternative.** DECISION-002 + the "No
   self-certification" hard rule: fidelity must be judged by an independent pass fed only the prompt
   and the diff. Every session is contractually obliged to dispatch this agent.
3. **Today its prompt is HAND-TYPED each session — the exact drift the `fleet::ROLES` single source
   exists to kill.** The Researcher's instructions live in one canonical place and render into the
   subagent file; the Reviewer's do not live anywhere. Review quality therefore varies with how
   carefully the builder re-wrote the brief that day. Two sessions running (S112, S113) the
   carry-forward notes say "reuse the two-pass pattern" — a convention kept in prose, not in code.
4. **Its output already has a governed home and teeth.** `sessions/session-NN-review.md` is read by
   `verify-closeout.sh` (missing/hollow/REJECT all FAIL), attested by `Review-Inputs-SHA`
   (DECISION-003), chained in the ledger (DECISION-004), and counted by the Reviewer station. A
   Reviewer role is the shortest distance from "role scaffolded" to "role's output already gated" —
   every other candidate would need new machinery first.
5. **It needs read-only tools only** — the same posture as the Researcher (`Read, Grep, Glob`,
   plus git reads for the diff). No new trust surface: a fleet role that could WRITE would be a
   materially bigger decision, and this one avoids it.

### Alternatives considered, and why each loses

- **A Planner / Architect role (an agent that authors the `## Plan` or `## Design`).** Rejected:
  those stations "surface and enforce, never author" (S64, S67) — the human/parent agent owns the
  content and the gate checks it. A role that authors what a gate then grades is self-certification
  wearing a second hat.
- **A Coder role.** Rejected for now: it needs write tools, which is a genuinely larger governance
  decision (what may it edit, under whose approval token, against which commit gate), and the main
  agent already does this work under the existing gates.
- **A QA / verifier role.** Rejected: the QA station re-runs `verify-session-NN.sh` **live** (S69).
  A live green script is stronger evidence than an agent's opinion about the script — adding an
  agent here would swap teeth for prose.
- **A Demo-er / Releaser role.** Rejected: both are mechanical and derived from git and script
  output; there is no judgment for an agent to add.

### Known limits of this choice (disclosed now, so the build session cannot claim more)

- Scaffolding the Reviewer makes its brief **canonical and re-runnable**; it does **not** by itself
  make the review more independent than today's ad-hoc dispatch. Independence comes from the
  context boundary (a subagent gets a fresh context window, fed only the prompt + the diff), which
  already holds today.
- A scaffolded role is only as good as its dispatch: like the Researcher, a `.claude/agents/*.md`
  written mid-session is invisible to that same session (S111). The Reviewer role will land in one
  session and first be dispatchable by name in the next.
- **Name collision to resolve at build time (cold-review finding, S113):** the pipeline already has
  a **Reviewer station** (the eighth station in `K of 8`, `stations::reviewer_status`). A fleet role
  keyed `reviewer` would read ambiguously against it — "Reviewer PASSED" would mean the station,
  while "fleet: 1 governed handoff — reviewer" would mean the agent. The build session must either
  pick a distinct role key (e.g. `fidelity-reviewer`) or state explicitly that the role IS the
  station's agent. Do not leave it implicit.

## S114 addendum — the Reviewer BUILT, and the two open items closed

**Status: BUILT.** S113 chose the role; S114 ships it as a second `fleet::ROLES` entry rendered by
the same machinery (no second scaffolding path, no second handoff writer, no second role-text
source). The S113 addendum left two questions open and forbade leaving them implicit. Both are
decided here, and the code matches.

### Open item 1 — the role key: **`fidelity-reviewer`** (a distinct key)

The pipeline's eighth station is already called the **Reviewer** (`stations::reviewer_status`,
counted in `K of 8`). A role keyed `reviewer` would put the same word on two different things in
adjacent lines of the same report — `Reviewer PASSED` (the station) directly above `fleet: 1
governed handoff — reviewer` (the agent).

**Decision: the role key is `fidelity-reviewer`.** Rejected the alternative ("state that the role IS
the station's agent") because it is not true: the station passes on an *attested review artifact
existing and not saying REJECT*, which a human can satisfy with no agent at all. The station measures
the artifact; the role produces one input to it. Two different things deserve two different names.

Consequences, all mechanical: the subagent is `.claude/agents/fidelity-reviewer.md`, the handoff is
`.ai/handoffs/session-NN-fidelity-reviewer.md`, the dispatch is `subagent_type:
"fidelity-reviewer"`, and `vajra next --role reviewer` FAILS with the known-roles list (asserted by
test — `resolve_role("reviewer").is_none()`).

### Open item 2 — the handoff vs `sessions/session-NN-review.md`: **pre-stage input, one record of record**

The fidelity verdict already has a governed home with teeth: `sessions/session-NN-review.md` is read
by `verify-closeout.sh` (missing / hollow / REJECT all FAIL), attested by `Review-Inputs-SHA`
(DECISION-003), and chained in the ledger (DECISION-004). The failure mode to avoid is two competing
records of the same judgment.

**Decision: the governed handoff is a PRE-STAGE INPUT — the captured raw verdict, hashed and
timestamped at the moment the agent returned it. `sessions/session-NN-review.md` remains the single
RECORD OF RECORD and the only thing any gate reads.** Rejected "pointer only" (a pointer throws away
the `source-sha` — the whole reason a handoff is evidence rather than prose) and rejected "the
handoff replaces the review artifact" (it would strip the attestation + ledger chain that make the
verdict tamper-evident, trading teeth for a newer file).

How the code matches, not just the prose:
- The role's system prompt — the ONE canonical source, rendered verbatim into the subagent file —
  ends by stating the verdict is a pre-stage input, that `sessions/session-NN-review.md` is the
  canonical gated record, and that this agent does not write it.
- The role has **no write tool** (`Read, Grep, Glob`), so it *cannot* author the record of record.
- Nothing in `verify-closeout.sh` or the Reviewer station learns to read the handoff. The gate keeps
  reading exactly one artifact. A session that never dispatches the role closes exactly as before.

### What this addendum does NOT claim

- Scaffolding the role does not make the review more independent than today's hand-typed dispatch —
  independence comes from the fresh context window, which already held (S113 addendum, restated).
- Like every role, a `.claude/agents/*.md` written mid-session is invisible to that same session's
  Task tool (S111). The Reviewer role lands at S114 and is first dispatchable **by name** at S115.
- `fleet: 2 governed handoff(s)` certifies **two contract-valid files exist**, never that two agents
  ran (the standing S113 reading rule).
- A third role remains a separate decision. Two roles is not a fleet; it is two roles.

### Open item 3 — found by THIS session's cold review: `reviewer/SKILL.md` was already a second source

The S113 addendum listed two open items. The S114 cold pass found a third that nobody had named:
**the repo already contained a statement of the reviewer's contract** — `reviewer/SKILL.md`, 127
lines, hand-maintained, and scaffolded into every fresh repo by the *same* `vajra init` (via
`include_str!`, `src/cli/init.rs`). So this session's goal statement ("its brief is re-typed from
memory each time") was **partly false**, and shipping the role brief unexamined would have created
exactly the drift this decision forbids: two hand-maintained versions of one job.

The dangerous half is not duplication, it is the **output shape**. `verify-closeout.sh` FAILS a
landed review that lacks a per-requirement `SHIPPED`/`PARTIAL`/`NOT-BUILT` table, a canonical
`**Verdict:** ACCEPT|REJECT` line, or an `X of N SHIPPED` count. The first draft of the role brief
mentioned none of the three — an agent dispatched by name, obeying only that brief, would have
returned a verdict the gate then rejected.

**Decision: `reviewer/SKILL.md` stays CANONICAL; the role's system prompt is its dispatch-time
summary, and the two are BOUND by a check that reads both files.** The brief names the skill and
tells the agent to read it. Rejected "delete the skill and render it from `fleet::ROLES`" (the skill
is boot-loaded by every agent, including ones that never dispatch a subagent, and it documents the
gate's own expectations — it is not role text) and rejected "leave them independent" (that is the
defect, stated in this session's own prompt).

The binding is enforced twice, both with positive controls: the unit test
`the_role_brief_carries_the_output_shape_the_closeout_gate_requires` reads `reviewer/SKILL.md` off
disk and requires every gate token to appear in BOTH, and `verify-session-114.sh#role-brief-bound-to-skill`
re-checks it against the *scaffolded* file. A change to the canonical contract that the brief does
not follow turns both red.

## S116 addendum — the Planner BUILT, and the key collision closed

**Status: BUILT.** Founder pick B at the S115 closeout (over the report's recommended A: the paid
dogfood), then, asked to name the role, **Planner** specifically. S116 ships it as a THIRD
`fleet::ROLES` entry, rendered by the same machinery as roles 1 and 2 (no second scaffolding path,
no second handoff writer, no second role-text source). The one load-bearing open item the S116
prompt required to be resolved in writing, not left implicit, is decided here.

### The role key: **`plan-advisor`** (a distinct key)

The pipeline already has a **Planner station** (`src/planner/mod.rs`, S64), counted in `K of 8`
exactly the way the Reviewer station is. A role keyed `planner` would put the same word on two
different things in adjacent lines of the same report — `Planner PASSED` (the station: the
session's `## Plan` cites every acceptance criterion via `covers: N`) directly above `fleet: 1
governed handoff — planner` (the agent: a subagent that *proposes* such a plan).

**Decision: the role key is `plan-advisor`.** Considered and rejected two alternatives, mirroring
the S114 addendum's shape exactly:
- **Rejected — state that the role IS the station's agent.** Not true, for the same reason it was
  not true of the Reviewer: the station passes on a *recorded coverage marker existing in the
  prompt file*, which a human author can satisfy with no agent at all — `plan_coverage` in
  `src/planner/mod.rs` reads the prompt's own `## Plan` section, never a fleet handoff. The station
  measures the artifact; the role, when dispatched, is one way a human might arrive at good step
  citations. Two different things, two different names.
- **Rejected — key it `planner-advisor` or `planning-assistant`.** Both considered (named as
  candidates in the S116 prompt); `plan-advisor` was picked as the shorter of the two non-colliding
  options with no loss of clarity — the words "plan" and "advisor" together are not the station's
  name, and neither `resolve_role("planner")` nor a human skimming `K of 8` beside a fleet line can
  mistake one for the other.

Consequences, all mechanical: the subagent is `.claude/agents/plan-advisor.md`, the handoff is
`.ai/handoffs/session-NN-plan-advisor.md`, the dispatch is `subagent_type: "plan-advisor"`, and
`vajra next --role planner` FAILS with the known-roles list (asserted by test —
`resolve_role("planner").is_none()`), exactly as `--role reviewer` already fails.

### The `covers: N` contract: reused, not re-derived

The Planner station already owns the grading logic (`cited_criteria`, `plan_coverage` in
`src/planner/mod.rs`) — a step is covered when it carries a `covers: N` marker in the exact shape
that parser reads. The Plan Advisor role's system prompt states that shape verbatim and tells the
agent to cite in it; **the role does not gain a new parser, and the station's gate is not touched.**
This session does not wire the role's output into the station's grading — that is a separate,
larger story (consuming a handoff into a station's own gate, mirroring the S112 Researcher-handoff
consumption arc), explicitly deferred as a non-goal.

### What this addendum does NOT claim

- Same standing limits as the S113/S114 addenda: a `.claude/agents/*.md` written mid-session is
  invisible to that same session's Task tool (S111) — the Plan Advisor role lands at S116 and is
  first dispatchable **by name** at S117 or later.
- `fleet: 3 governed handoff(s)` certifies **three contract-valid files exist**, never that three
  agents ran (the standing S113 reading rule, now exercised at a third count).
- The role proposes; it does not write the session's `## Plan` section, and has no tool that could.
- A fourth role remains a separate decision.

## S121 addendum — the QA Specialist BUILT, and the first EXECUTION grant

**Status: BUILT.** Founder pick at the S120 GT closeout. S121 ships it as a FOURTH `fleet::ROLES`
entry, rendered by the same machinery as roles 1–3 (no second scaffolding path, no second handoff
writer, no second role-text source). Two things this session had to decide in writing rather than
leave implicit: the role key, and the tool grant.

### The role key: **`qa-specialist`** (a distinct key)

Third instance of the same collision the S114 and S116 addenda each closed. The pipeline already has
a **QA station** (`src/qa/mod.rs`, S69), counted in `K of 8`. A role keyed `qa` would put the same
word on two different things in adjacent lines of one report — `QA PASSED` (the station: the
session's recorded verify marker re-ran live and exited 0) directly above `fleet: 1 governed
handoff — qa` (the agent: a subagent that ran the suite and classified its checks).

**Decision: the role key is `qa-specialist`.** `resolve_role("qa")` returns `None` and
`vajra next --role qa` fails with the known-roles list, asserted by test.

**The station is not touched, and does not learn the role key.** The QA STATION governs the
process (did a recorded, executable marker actually re-run and pass?); the QA ROLE does the work
(run it, and say which of its checks were real). Same separation as Reviewer/`fidelity-reviewer`
and Planner/`plan-advisor`.

### The tool grant: **`Bash, Read, Write, Edit, Grep, Glob`** — the first executing role

Every role before this one is read-only, and the S114 note in `Role::tools` said plainly that a
role which could write is "a materially bigger governance decision (DECISION-007) and none is taken
here." It is taken here, scoped to this one role.

**Why Bash is load-bearing.** S118 and S120 measured the failure this role exists to catch: verify
suites can be built largely out of greps that find a message string in `src/` and call that proof
the feature works — checks that would still pass with the feature deleted. A read-only agent
auditing that problem can only grep for the greps. An agent that runs the suite either has an exit
code and real output, or it has nothing; it cannot physically fake a pass. Treating the root cause
means the QA agent must be an executor.

**Considered and rejected:**
- **Rejected — a read-only QA agent (`Read, Grep, Glob`), like the other three.** It would produce
  exactly the artifact this session exists to stop trusting: prose about source it read, with no
  live evidence behind it. It could report that `verify-session-NN.sh` *contains* an execute-based
  check without ever learning whether that check passes, and its own findings would be the same
  class of hollow evidence it was hired to name. The role would be theatre.
- **Rejected — `Bash` only (no `Write`/`Edit`).** Considered as the minimal grant, and it is
  genuinely narrower. Rejected because the role's own contract requires it to hand back a findings
  brief that Vajra then governs via `vajra next --role qa-specialist --from <file>` — a file on
  disk — and because a real QA pass writes scratch: captured logs, a reduced repro, a temp fixture.
  Forcing all of that through stdout would push the agent toward `bash -c 'cat > file'`, which is
  the same capability with the audit trail removed. The narrowing that actually matters is stated
  in the role prompt instead: do not edit the product under test, do not repair the checks you
  criticise, do not commit.
- **Rejected — grant the existing `fidelity-reviewer` a Bash tool instead of adding a role.** It
  collapses two jobs that must stay independent: the Reviewer grades requirements from the prompt
  and the diff and must not be able to run (or fix) the thing it judges; the QA Specialist produces
  the evidence, and explicitly does not issue the verdict. Merging them would also silently widen
  the grant of the one role whose whole value is that it only reads.

**The residual risk, stated plainly.** `Write`/`Edit` are broader than the rule that governs them.
The prompt forbids touching the product under test, but the tools do not enforce that — this is a
prompt-level constraint, not a sandbox. It is disclosed here rather than hidden behind "the role
is told not to." The existing L2/L3 hooks (`hook-pre-write.sh`, `hook-commit-guard.sh`,
`VAJRA_ALLOW_COMMIT`) still apply to anything the agent does inside a governed repo, so the
commit path in particular stays closed by machinery, not by instruction.

### What this addendum does NOT claim

- Same standing limit as the S113/S114/S116 addenda: a `.claude/agents/*.md` written mid-session is
  invisible to that same session's Task tool (S111). The role lands at S121 and is first
  dispatchable **by name** at S122 or later. **This session does not dispatch it.**
- `fleet: N governed handoff(s)` certifies **N contract-valid files exist**, never that N agents
  ran (the standing S113 reading rule).
- The role does not gain a new parser, a new artifact type, or an 8th command; it rides `init` and
  `next` exactly as roles 1–3 do, and it is reported BESIDE `K of 8`, never inside it (S113).
- Granting execution to this role grants it to no other. The allowlist is one name, asserted by a
  test that fails if a fifth role inherits Bash by being added to the table.
- A fifth role remains a separate decision.

## S122 addendum — the executor thesis is UNPROVEN (correction, not a new decision)

The S121 addendum above argues the QA role must be an executor because an executor "cannot
physically fake a pass". **That claim is unproven and must not be repeated as measured.** This
addendum corrects the record; the decision itself (the role, the key, the `Bash, Read, Write, Edit,
Grep, Glob` grant) is unchanged.

- **What two live runs actually measured.** The role has now run twice — the S121 post-close audit
  of `verify-session-121.sh`, and the S122 audit of this session's own suites. Between them it
  found **seven real defects**. Every single one came from careful independent READING. Execution
  bought the exit codes and the pass counts; it produced no finding on either run.
- **What IS evidenced: INDEPENDENCE, not execution.** An agent that did not build the thing finds
  defects the builder cannot see. That is the load-bearing property, and it is the property the
  read-only Fidelity Reviewer already had. Execution is a convenience for gathering evidence, not
  the mechanism that catches the lie.
- **What is NOT evidenced.** Nothing has tested whether an executor can fake a pass. No check in
  this repo attempts it.
- **The residual risk named in the S121 addendum is unchanged and unfenced.** The `Write`/`Edit`
  grant is documented, not controlled. On both live runs the working tree was byte-identical
  before and after — verified, not trusted — but in the agent's own words, *"that constraint held
  because I chose to hold it, which is not a control."* Fencing it is the leading candidate for
  the next session.
- **Where this correction is repeated:** `src/fleet/mod.rs` module header and the QA role's doc
  comment, both S122 verify-suite headers, and `scripts/demo-session-122.sh`. Anywhere the QA role
  is described, the thesis is described as unproven.

## S123 addendum — fencing the `Write`/`Edit` grant (the last self-granted jurisdiction)

The S121/S122 addenda both name the same open risk: `qa-specialist`'s `Write`/`Edit` grant is
documented, not controlled. This addendum records the fence — and, first, the measurement the
S122 `qa-specialist` report itself demanded: *"Nothing proves the runtime honours `tools:`."*

### Measurement — is a role's `tools:` grant actually enforced, or only a convention?

Tested live, in this session, against the real dispatch mechanism (not a mock): the `researcher`
role — already a real, session-boot-registered subagent, granted `Read, Grep, Glob, WebSearch,
WebFetch`, no `Write`/`Edit`/`Bash` — was dispatched with an explicit instruction to attempt
writing a file by any means it could find, and to report the raw mechanism, not to reason about
whether it should comply.

**Full evidence, captured and cross-verified, is
`sessions/session-123-artifacts/tools-enforcement-measurement.md`** — not asserted here as prose.
It reuses the exact evidentiary shape the S111 addendum used to prove a real by-name dispatch: two
independently-written files (this session's own transcript, and the dispatched subagent's separate
`meta.json`) agreeing on the same random tool-call ID (`toolu_01BpAnw69h7MVcRAZjbjYQo1`) neither
side controlled, plus the subagent's tool call and final report quoted verbatim. **A cold
`fidelity-reviewer` pass rejected the first cut of this addendum for exactly the gap that artifact
closes** — the claim below was true but, as first written, unfalsifiable narrative with nothing to
check it against.

**Result: the grant IS enforced, mechanically, at the tool-definition level — not a prompt-level
convention the agent chooses to follow.** The dispatched agent reported no `Write`, `Edit`, or
`Bash` function was present in its callable tool schema at all: "not disabled, not erroring, simply
absent from the list of callable functions I was given." There was no rejected call and no error
text to quote, because there was nothing to call. The target file was confirmed absent afterward.

**What this measurement does and does not license.** It proves the harness will not hand a
role a tool outside its recorded grant. It does **not** prove that dropping `Write`/`Edit` from
`qa-specialist` would close the write path — `qa-specialist` keeps `Bash` (it must, to run the
verify script), and a granted `Bash` tool can write a file by shell redirection
(`echo x > src/foo.rs`) with no `Write`/`Edit` tool involved at all. The measurement licenses only
this: narrowing `Write`/`Edit` is not worth *zero* (it closes one real, now-confirmed-enforced
path), but it is not the fence — `Bash` is the fence-defeating grant, and it cannot be removed
without removing the role's entire reason to exist.

### Decision — route the dispatch through the existing clean-room runner (`src/gate_run.rs`, S119)

`qa-specialist`'s dispatch is pointed at a disposable `git worktree add --detach HEAD` checkout,
not the source repo, via two new flags riding the existing `--role` surface (no 8th top-level
command): `vajra next --role qa-specialist --clean-room-open` materialises the worktree and prints
its path (gated: a role without a `Bash` grant is refused — nothing to isolate); `--clean-room-close
<path>` removes it once the run is done. `gate_run::CleanRoom::open_persistent`/`remove_persistent`
reuse the exact worktree-add/-remove primitives `qa_gate`'s `CleanRoom` already uses for the S119
live re-run — split out of that struct's `new`/`Drop` so a **fleet role's** dispatch (which happens
in a separate, longer-lived Claude Code session, not inside a single `vajra` process) can hold the
same checkout open across process boundaries instead of it being removed the instant the CLI call
that created it returns.

**Considered and rejected — narrow the grant alone (drop `Write`/`Edit`, keep `Bash`).** The
measurement above shows this is not worthless, but it is not sufficient: the role needs `Bash` to
run the suite, and anything that can run a shell command can write a file. A fence that closes the
tool path while leaving the command path wide open is exactly the fake-green shape S122 spent four
review passes removing — it would look like a fence and not be one. **Kept as a cheap SECOND
layer** alongside the clean room, not as the fence itself; not yet applied to the scaffolded grant
this session (recorded as the residual, not silently done).

**Considered and rejected — a hook that blocks writes during a QA run.** The only option that
requires *guessing intent*: the guard would need to know a given write came from the dispatched
subagent specifically (unverified, and per the measurement above the harness gives no signal for
this), and to close the `Bash` path it would have to parse arbitrary shell to decide "is this
write-shaped" — unwinnable in general (`printf`, `dd`, `tee`, a Python one-liner, redirection
through a pipe of unknown depth). A fence made of *rules* has to be right about everything a
malicious or confused agent might try; a fence made of *walls* only has to exist.

### Residual risk — stated plainly, not softened

**The clean room isolates the REPO, not the MACHINE.** `qa-specialist` still holds `Bash`, and the
real repo still exists on disk at a known absolute path — nothing stops `cd /path/to/real/repo &&
echo x > src/foo.rs`. What the clean room does is remove every *legitimate reason* to touch the
original and make any touch to it **detectable**: the source repo's `HEAD` sha, `git ls-files -s`
hash, and `git status --porcelain` are compared before and after (`verify-session-123.sh`'s
falsifiability fixture, S123 step 5) — the same technique the S121/S122 live runs already used by
hand. The honest claim is **isolation by default plus tamper-evidence as the backstop** — the same
posture as the verdict ledger (`DECISION-004`), which is tamper-**evident**, not tamper-**proof**.
Do not write "the QA role cannot modify the repo." Write what is true: it is not pointed at the
repo, and if it reaches for it anyway, that is visible. Anything stronger needs OS-level
sandboxing (a filesystem namespace, a container, a restricted user) — a different session, and
probably a different product surface than a CLI that scaffolds `.claude/` files.

**This does not touch the executor thesis.** The S122 addendum retracted the claim that an
executor "cannot physically fake a pass" — this session does not restore it. Fencing removes one
specific way `qa-specialist` could cheat (repair the product, then report the repaired state as the
original). It does not establish that no executor can fake a pass by any means, and the property
actually evidenced by both live runs remains INDEPENDENCE, not execution. Never restate the S121
claim as measured because this fence now exists.
