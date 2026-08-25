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

---

## S126 addendum — the LAST FIVE roles, and the roster closed at nine

S109 shipped one role and named scope creep as the key risk; S114, S116 and S121 each added
exactly one more, deliberately. This addendum records adding **five in one pass** — the roster's
completion — and why that was affordable here when it would not have been at S114.

**Why one pass.** S114, S116 and S121 each traced the same fact independently: a new role is one
`fleet::ROLES` entry, and `vajra init`, `render_subagent_definition`, `vajra next --role`, the
handoff contract and the S113 station counter all iterate the table already. Three sessions'
worth of evidence that the unit of work is one table entry, tested here at n=5 instead of n=1.
**Traced, not asserted:** this session's diff changes `src/fleet/mod.rs` (the table and its tests)
and adds five rendered `.claude/agents/*.md` files. No dispatch code, no CLI surface, no gate, no
new command, no change to `K of 8`.

### The five keys, and the rejected alternative for each

The STATION-vs-ROLE collision has now been resolved five more times, the same way S114 (Reviewer),
S116 (Planner) and S121 (QA) resolved it: **the role key is never the station's own word.** `K of
8` narrates the stations; a role sharing a station's word would make one word mean two things in
the same report. A key that shadows a station name is a REJECT condition here, not a nit.

| station (`K of 8`) | role key registered | rejected alternative — and why |
|---|---|---|
| Analyst (`src/analyst/mod.rs`) | **`requirements-analyst`** | `analyst` — the bare station word. |
| Architect (`src/architect/mod.rs`) | **`design-advisor`** | `architect` — the bare station word. `solution-architect` also rejected: it still reads as the station, and "solution" adds no meaning. |
| Coder (`src/coder/mod.rs`) | **`implementation-advisor`** | `coder` — the bare station word. `implementer` also rejected: the name would assert execution the grant deliberately withholds. |
| Demo-er (`src/demoer/mod.rs`) | **`demo-producer`** | `demoer` / `demo` — the station's word, and `demo` would also collide with the `--demo` flag's noun. |
| Releaser (`src/releaser/mod.rs`) | **`release-coordinator`** | `releaser` — the bare station word. `release-engineer` also rejected: it implies the role performs the release, and on this team every push, merge and prune stays a human act. |

Each key is asserted in both directions by
`fleet::tests::the_last_five_roles_are_registered_with_non_colliding_keys`: the role resolves, and
the station word does **not** resolve as a role.

### Each role's contract is a marker its station's gate ALREADY parses

The S116 contract shape, applied five times. No role gains a new parsing or grading path, and
**every role proposes; none authors the recorded marker section**:

- `requirements-analyst` → the four required prompt sections, the `Status:` line, the `## Delta`
  bullets' OpenSpec markers, and the exactly-three ranked candidates the Options gate counts. It
  is told never to propose `Status: APPROVED` — the human's signature is not a role's to draft.
- `design-advisor` → `design-significant: yes|no` plus a `## Design` citing a record that EXISTS
  under `docs/adr/` or `docs/decisions/`. Its read tools are load-bearing rather than incidental:
  they are how it checks a record is real before citing it, which is the exact hole S67 closed.
- `implementation-advisor` → `step N — done: <sha>` in `## Execution`, every sha resolved against
  git. It is forbidden to propose a sha or to suggest recording a step done before its commit
  exists.
- `demo-producer` → the four elements the Demo-er gate scans in the LIVE re-run output
  (`demo:header`, `demo:cases`, `demo:summary_table`, `demo:before_after`), with the station's own
  disclosed floor stated to the role: the scan proves the script printed the element, never that
  what it printed is true.
- `release-coordinator` → the three re-derived contract keys `require_merged_prior`,
  `require_main_synced`, `require_pruned`. It cannot run git, and its prompt makes the consequence
  a rule: never report ancestry or sync state as if it had been observed (the S124 failure, in the
  role most exposed to it).

### The tool grants — the one real decision, resolved read-only

Four of the five are read-only without argument. **`implementation-advisor` is the fork**: it is
the role most obviously "supposed" to write.

**Decision: read-only (`Read, Grep, Glob`). No `Write`, no `Edit`, no `Bash`.**

The argument against granting it write access is that the grant would reverse two things in the
same session that ships it: S123 *narrowed* the only executing role's grant after measuring that
the harness enforces `tools:` mechanically, and the S122 addendum *retracted* the executor thesis
outright — two live `qa-specialist` runs found seven real defects and **every one came from
independent reading**, not from execution. Granting a second role write access on the strength of
a thesis this repo has already retracted would be adding capability against its own evidence.

The argument for it — that an advisor who cannot apply the change adds a hop — is real and is not
dismissed. It is recorded as a **separate, founder-gated decision**: "grant the implementation
role write access" needs an explicit founder yes in chat, on its own, with its own fence designed
first (the S123 clean room is the obvious starting point). It was not taken here, and this
session shipped no deviation from that.

Consequence, asserted in the same test: **five roles added, zero new grants of `Bash`.** The
execution allowlist is still exactly one role, and the three-copy execution policy
(`src/fleet/mod.rs` + the two shell guards bound by `verify-session-122.sh`) did not move.

### One file outside the fleet was touched, and why

`scripts/verify-session-121.sh` asserted `N = 4` scaffolded agent files. That pin measured the
roster SIZE of its day, not the check's substance — which is that the repo's committed copies are
byte-identical to what `vajra init` renders and that the two sets are exactly equal, both
count-independent. The pin went red on a roster that grew as designed, and
`verify-session-122.sh` **re-runs the S121 suite live**, so the breakage chained into a second
green suite. The pin is now a non-vacuity floor (`-ge 4`); nothing else in that suite changed, and
both suites were re-run green afterwards. (The older `verify-session-114.sh` and
`verify-session-116.sh` carry the same class of pin at 2 and 3; they are not in any live chain and
were left alone — recorded here so the decay is on the record rather than discovered later.)

### Residual risk — stated, not softened

**The roster is complete. Nothing depends on it.** S125 established, and this session does not
re-litigate, that the four existing roles are never reached for on real work: the shipped scaffold
never asks for a role, and **no gate anywhere consumes a handoff**. Five more roles inherit that
unchanged. Nine roles that nothing depends on is nine decorations, and the completeness of the
roster is **not** evidence that the fleet works.

What S126 claims is the **done** half of the founder's gate ("the fleet is done AND working"). The
*working* half — S116's own unpicked candidate C (wire handoffs into a blocking gate) and S125's
F2 (a dispatch receipt) — is not built here and must not be read into this addendum.

Second residual, smaller and specific: the five dispatch proofs each show the runtime resolving a
role by name when a parent was **told** to dispatch it. That is the wire, not the demand. Nothing
here shows a session reaching for a role unprompted, and per S124 a dispatched agent's own report
is never the evidence — which is why the evidence recorded is two runtime-written files agreeing
on a tool-call id neither the agent nor Vajra chose.

---

## S127 addendum — the disposition contract, and the S116 deferral is LIFTED

**Date:** 2026-08-22 · **Session:** 127 · **Status:** locked

### What this addendum reverses, stated first

The S116 addendum, in the section *"The `covers: N` contract: reused, not re-derived"*, closed with:

> …consuming a handoff into a station's own gate … **explicitly deferred as a non-goal.**

**S127 lifts that deferral.** This is not a clarification and not a re-reading — it moves a line
this record locked, and it says so where a reader will find it. The `design-advisor` flagged the
reversal at dispatch time; the Architect gate would NOT have caught it, because that gate checks
that a cited spine record EXISTS, not that the design obeys it. Citing `DECISION-007` passes while
the deviation stands. The addendum is the lock; the citation was never enough.

The deferral is lifted **narrowly**: exactly one gate consumes governed handoffs as a binding
input. The eight stations, the nine roles and the seven commands are untouched, and no other gate's
evidence contract moves.

### The problem this closes

S126 asked five roles for advice and dropped two recommendations in silence:

- the `demo-producer` said to show the `verify-session-121.sh` unpin in the before/after,
  "otherwise the before/after only shows the after". The shipped demo showed only the roster.
- the `design-advisor` found the deferral this addendum lifts. That finding never reached the first
  draft of the S127 prompt — the brief was read at dispatch time, the prompt written later, from
  memory.

Neither was defiance. **Neither left a trace.** The defect is not disobedience — it is *invisible*
disobedience, and until S127 no gate anywhere could see it.

### The contract

A recommendation is a **recorded marker**, never an inference:

```
rec 2 — show the verify-121 unpin in the before/after
```

Its answer is a **disposition**, recorded in the `## Advice` section of the session's own prompt —
the same place the `## Execution` trace lives, for the same reason (`.ai/` and `prompts/` ARE the
memory; no new store, no new artifact type):

| disposition | what the gate requires | precedent |
|---|---|---|
| `obeyed: <sha>` | the leading hex run resolves via `git cat-file -e <sha>^{commit}` | S68 Coder |
| `refused: <reason>` | non-empty and not a `<...>` template placeholder | S61 Delta |
| `deferred: <path>` | an in-repo path that EXISTS | S67 Architect spine-existence |

`vajra next --advice NN` surfaces; `--check-advice NN` blocks; both ride `vajra next`. No 8th
command. Wired into `--advance` on the CLOSING session, overridable by `VAJRA_SKIP_ADVICE_GATE=1`.

**State precedence, decided rather than left to fall out:** `Malformed` (BLOCK) → `Unanswered`
(BLOCK) → `NoRecommendations` (WARN, dodge named) → `Answered` (PASS) → `NoHandoffs` (silent).

### The fork, argued rather than assumed

*What happens when a handoff exists but records NO numbered recommendations?*

**Decided: WARN, with the dodge named in the gate's own output.** BLOCK would close the dodge and
break every handoff written before this contract existed — all eleven currently on disk. WARN keeps
them working and follows the S68/S71 precedent for a form floor. The cost is stated in the gate's
own words, not buried: *deleting the numbers dodges this gate.* Revisit once the roles have emitted
numbered recommendations for a few sessions.

**A deliberate divergence from the two existing `HandoffRead::Malformed` consumers**
(`format_handoff_brief` prints a ⚠; `stations::fleet_evidence` files it): for this gate a malformed
handoff is **binding**. It is the first consumer for which that is true, and the reason is S69 — a
gate that cannot evaluate FAILS.

### Rejected alternatives

- **`REC-N:` upper-case only** — fights the roles' prose voice; invites case drift across nine
  independently-written prompts.
- **A YAML list in the handoff frontmatter** — Vajra owns the frontmatter (`format_handoff`); this
  record already forbids the role authoring it.
- **Numbering by heading ordinal** — implicit numbering silently re-maps every recorded disposition
  when a heading is inserted.
- **Bare ordinals (`1.`)** — every advisory brief is full of numbered lists; ordinals would turn
  ordinary prose into gate-binding claims.
- **A role-qualified number (`design-advisor/2`)** — duplicates the `role:` frontmatter the gate
  already trusts as the placement source of truth, and lets a role mislabel itself.
- **A new `.ai/advice/` store or an `advice.md` artifact** — `.ai/` and `prompts/` ARE the memory.
- **Detecting "I recommend…" in free text** — that is the judgement this gate refuses to fake.
- **Per-role hand-edited numbering rules** (the `implementation-advisor`'s own rec 6) — rejected in
  favour of one shared rule rendered into every `ROLES` entry, so a tenth role inherits the contract
  with no edit. The S114 lesson: one hardcoded word stamped every future role.
- **A stop-word list (`tbd`, `n/a`) and a three-word minimum for `refused:`** — shipped, then
  removed on the `implementation-advisor`'s rec 13. S122: a guard bound to a spelling gets escaped;
  a length threshold is a judgement dressed as a check. The floor is disclosed instead.

### What this addendum does NOT claim

- **It does not make the agent obey.** It forces an ANSWER. `refused: <reason>` passes, and that is
  correct and intended. What becomes impossible is the silent version.
- **It does not judge the answer.** That an `obeyed:` commit really implements the advice, or that a
  `refused:` reason is sound, stays a judgement only an independent reader can make.
  **Required ≠ obeyed; answered ≠ obeyed well.**
- **The refusal floor is a FORM floor.** A one-word reason passes, by decision.
- **Jurisdiction is self-granted** (S68/S71). An advisor that never numbers its advice cannot be
  made to. Measured, not theorised: run against S126's own five handoffs, this gate exits 0 — it
  would **not** have caught either of the two drops that motivated it. Retroactively it is a WARN.
- **One gate consumes handoffs; the other seven do not.** The roster is still nine and the fleet is
  still not "wired in" — this is one notch up from S126, not ten.
- **A WRONG `obeyed:` is indistinguishable from a right one, to this gate.** Not an abstraction — a
  live specimen, caught by the independent cold review of the very session that shipped this
  contract. The `implementation-advisor`'s rec 9 said "delete the `_uses` stub"; the ledger recorded
  `obeyed: 8cd3bea`; the stub was still in `src/advice/mod.rs`. The sha resolved, so the gate scored
  it ANSWERED. **The disposition word carries all the meaning and none of the checking.** Every
  `obeyed:` in every future ledger should be read that way: it certifies that a human typed a word
  and named a real commit, and nothing else. The only thing that caught it was a reader.

## S131 addendum — `fidelity-reviewer` made MANDATORY, and its provenance made PROVABLE

**Status: BUILT.** S130's ground truth found the fleet's usage falling every session it measured
(S126 5 handoffs -> S127 3 -> S128 1 -> S129 **0**) with no gate that ever complained about the
zero — `--check-advice` (S127) only fires once a handoff already exists. Layered on top,
`src/cli/next.rs`'s `agent:` field was a hardcoded literal, `"claude-code-subagent"`, never derived
from any real dispatch evidence — a hand-typed handoff satisfied it for free. The founder's own
words at the S130 closeout, choosing which role to harden first: not a new pre-work advisor, but
the one that "ensure[s] the session complete[s] all acceptance criteria and what it build[s] is
actually high quality work — not fake stamping and shortcuts." That is `fidelity-reviewer`
(DECISION-002's fidelity auditor, already the most-used role S127-S129).

### Two changes, one session

1. **Mandatory.** A session cannot close without `.ai/handoffs/session-{NN}-fidelity-reviewer.md`
   existing and satisfying the DECISION-007 handoff contract — a NEW gate (`src/fidelity/mod.rs`),
   wired into `vajra next --advance` exactly like the Coder/Advice/QA/Demo gates (binds on the
   session being CLOSED), `VAJRA_SKIP_FIDELITY_GATE=1` the documented override. Unlike every prior
   stage gate, **absence here carries no legacy WARN-only escape hatch** — the founder locked this
   role mandatory, so a missing handoff blocks at L2/L3 exactly like a fabricated one.
2. **Provable.** `src/cli/next.rs`'s hardcoded `agent:` literal is replaced by
   `dispatch::derive_provenance` (`src/dispatch/mod.rs`), which independently cross-checks this
   machine's real Claude Code dispatch history and reports honestly (`Verified{tool_use_id}` /
   `Unverifiable(reason)`) rather than asserting a claim it cannot back.

### Design choice, recorded rather than left implicit: its own command

The Advice gate (S127) already exists at `--check-advice`. This session's prompt asked whether the
new gate should extend it or stand alone. **Decided: its own command,
`--check-fidelity-handoff`.** The two gates check genuinely different things — Advice proves every
numbered *recommendation* a handoff makes was ANSWERED; this gate proves the *handoff itself*
EXISTS and its provenance is REAL. A handoff can pass one and fail the other (a real dispatch with
no numbered recs WARNs on Advice but PASSES here; a hand-typed handoff with perfect numbered recs
PASSES Advice but FAILS here). Folding them into one command would blur two distinct failure modes
behind one exit code — the same reasoning DECISION-007's S114 addendum used to give the role a
distinct key from the station it sits beside.

### The provenance mechanism: S111's evidentiary shape, automated, plus a third fact

S111/S117/S123 each proved a real by-name dispatch BY HAND, once, as a committed evidence artifact:
two independently-written Claude Code files — the parent session's own transcript
(`subagent_type` on a `tool_use` call) and the dispatched subagent's own `agent-<id>.meta.json`
(`agentType`) — agreeing on a random tool-use id neither side controlled. `dispatch::cross_check`
makes this a pure, unit-tested function instead of a hand-assembled artifact, run live on every
write and re-run independently by the gate.

A gap the three hand-assembled addenda left open: an old, genuinely real tool-use id from an
unrelated past session could be pasted into a forged handoff and would satisfy the two-file
agreement. **Closed with a third, independent fact the runtime already writes and a forger does not
control: the subagent transcript's own first line records `gitBranch`** — the branch the
dispatching session was actually on. The cross-check requires it to start with
`session-{NN:02}-`, binding the dispatch to the SESSION being gated, not merely to a real
dispatch of the right role at some point in this repo's history. No new heuristic, no clock, no
age window — a field Claude Code already writes, read the same way `vajra meter` already reads the
transcripts next to it.

**The gate never trusts the handoff's own label.** `vajra next --role --from` writes what it found
at write time (`Provenance::label()` — `claude-code-subagent (verified: <id>)` or
`(unverifiable: <reason>)`); the gate (`fidelity::fidelity_gate`) parses only the tool-use id back
out (`dispatch::claimed_tool_use_id`) and independently re-derives whether it still cross-checks
(`dispatch::reverify`) against a FRESH scan. A forged label copying the exact `(verified: …)` shape
with a fabricated or stale id fails the re-derivation, not the string match.

### Known limits of this choice (disclosed now, so a future session cannot claim more)

- **Local-machine-only**, the same disclosed limitation as `scripts/check-subagent-cost-fields.sh`
  (S111) and `vajra next --dogfood-age` (S91): a fresh CI runner or a different machine has no
  `~/.claude/projects` history, so this gate cannot run there at all. It is not wired into any
  CI/remote closeout path today.
- **Proves dispatch, not verdict quality.** This gate proves the handoff exists and was really
  produced by a `fidelity-reviewer` subagent on this session's branch. It says nothing about
  whether that subagent's review was thorough or its ACCEPT/REJECT correct — that remains
  `sessions/session-NN-review.md`'s job, gated separately and pre-existing
  (`verify-closeout.sh#check_fidelity_review`, `#check_review_attestation`).
  **The pre-stage-input / record-of-record split from the S114 addendum is unchanged** — this
  gate governs the PRE-STAGE INPUT only.
  - **It does not prove the review's ACCEPT/REJECT informed the delivery, or reads the same
    session as the review artifact.** A stray dispatch that happens to name the right role, the
    right session number, and land its cross-check would satisfy this gate even if its findings
    were never read by anyone — the fleet's OLD problem (a written-but-unread artifact,
    `handoff_body` not `Absent`), not solved by mandating existence, only surfaced. S132's job.
- **`derive_provenance`'s newest-first selection at WRITE time is a heuristic, not a proof** — if
  two matching dispatches exist on this machine, the write path binds to whichever has the
  freshest meta.json mtime. The GATE's `reverify` does not depend on this choice (it re-checks the
  SPECIFIC id the handoff recorded), so a wrong pick at write time is visible immediately (the
  wrong provenance line prints) rather than hidden.
- **Nine roles, one now mandatory; eight remain optional**, exactly as before. This addendum does
  not generalise the pattern to a second role — S131's own prompt names that explicitly out of
  scope, to be repeated only after this one is proven in use.
- **Named plainly, not softened (the cold review's rec 1): the on-disk dispatch evidence is
  UNSIGNED and hand-fabricable with a text editor by anyone with ordinary shell access to this
  machine.** `agent-<id>.meta.json`, its sibling `.jsonl`, and the parent transcript are plain
  JSON/JSONL with no cryptographic or process binding to a subagent that actually ran — this
  session's OWN `scripts/verify-session-131.sh` (`build_real_dispatch_fixture`) and
  `scripts/demo-session-131.sh` prove exactly how cheap that is: three `printf` calls produce a
  dispatch the gate reports `Verified`. "Local-machine-only" (stated above) is true but
  understates this — the honest reading is **"provable" means proves a real dispatch happened
  when nobody on this machine is adversarially forging one, not "tamper-proof."** The bar this
  raises over the pre-S131 hardcoded literal is real (a forger must now reproduce a specific,
  three-fact-consistent shape rather than type any string) but it is a bar, not a wall.
- **A residual the cold review's rec 4 named and this session did NOT close, deferred rather than
  silently dropped (`.ai/ROADMAP.md` F2):** `reverify` proves a real `fidelity-reviewer` dispatch
  occurred for this session; it does NOT bind that dispatch's OWN returned content to the specific
  `--from` findings file the orchestrator later ingests. Within one session, a single real dispatch
  could in principle be cited to stamp `Verified` provenance onto different findings text than what
  that subagent actually returned. Normal usage (capture the subagent's final message, then
  `--from` that exact file) does not hit this; nothing today PROVES it. Closing it would mean
  hashing the subagent's own last transcript message and requiring the `--from` content match (or
  derive from) it — a real design decision, not a quick fix, and out of this session's locked
  scope (one story: mandatory + provable dispatch, not content-binding).

---

## S133 addendum — the `design-advisor` made MANDATORY, and the RECORDED SKIP as a first-class outcome

**Status:** accepted, session 133. Extends `DECISION-007` and its S131 addendum.

### The measurement that forced it

Counted live at the S132 closeout: **18 governed handoffs across 132 sessions** —
`fidelity-reviewer` 5 · `implementation-advisor` 3 · `researcher` 2 · `qa-specialist` 2 ·
`demo-producer` 2 · `requirements-analyst` 1 · `release-coordinator` 1 · `plan-advisor` 1 ·
`design-advisor` 1 — and most of the 1s were the session that CREATED the role. Of 30 recorded
dispositions only 13% were refusals, so the advice is not being dodged; it is not being sought.

S131's mandatory role runs at the END and grades finished work. The advisors that could change
what gets BUILT were all optional, and optional loses to time pressure every session. The two most
expensive discoveries of S131 and S132 (`.ai/ROADMAP.md` F2 and F2a) were both DESIGN holes found
by a cold reader after the code was already written.

### The decision

1. **`design-advisor` is the fleet's SECOND mandatory role.** A session cannot close without
   either a `design-advisor` governed handoff whose provenance independently re-verifies through
   the S131 chain, or a recorded reason for skipping it.
2. **A skip is a first-class outcome, and it costs a sentence.** The grammar is
   `<role-name>: skipped — <reason>`, recorded in the session's own prompt, line-anchored,
   fence-skipping, and substantiveness-gated by `advice::substantive_reason`. It is keyed on the
   ROLE NAME, not on a design-specific literal, so a second mandatory advisor inherits it whole.
3. **No environment variable satisfies or bypasses this gate.** `VAJRA_SKIP_*_GATE=1` is the
   pattern every other gate uses and it is refused here: an env var leaves no trace a reader can
   find months later, and the whole novelty of this gate is that its escape hatch does.
   `VAJRA_CLOSEOUT_WAIVER` still applies at `verify-closeout.sh`, and that difference is
   deliberate — a founder-held, session-scoped marker the AGENT cannot set (S56/S93) is a
   different animal from a flag the agent writes on its own command line. L1 maturity still
   advises rather than blocks, uniformly with every other gate.
4. **Its own command, not a ride on `--check-design`.** `vajra next --check-design-handoff NN`.
   `--check-design` binds on the session being advanced INTO and asks whether the `## Design`
   rationale is substantive; this binds on the session being CLOSED and asks whether a real
   advisor was consulted at all. Folding them would also have made `design-significant: no`
   silently exempt a mandatory role, because `architect::parse_design` never blocks on that value.
   `--check-design` prints a cross-reference line instead, so a reader still has one place to
   start. The 7-command floor is untouched — both are sub-flags on `vajra next`.
5. **`design-significant: no` does NOT excuse the handoff.** An author's own judgement that their
   work is not design-significant is exactly what a second brain exists to check; accepting it as
   an exemption would be the cheapest instance of the self-granted-jurisdiction class (S68/S71). A
   pure fix skips in one sentence like anything else. Recording `design-significant: yes` AND a
   skip passes, with a loud WARN naming the contradiction.
6. **Migration threshold 133, governing SILENCE ONLY** (the S132 precedent). A marker that exists
   but records no usable reason, and a handoff that exists but does not re-verify, both BLOCK at
   any session number. Below 133, silence WARNs and the warning names the exemption.
7. **The mechanism is named for the mechanism.** `src/mandate/mod.rs`, generic over a
   `fleet::Role` plus its marker key, so a second mandatory advisor is a call site rather than a
   third copy of the ladder.

### The condition this relaxes, stated rather than implied

The S131 addendum closes with: *this addendum does not generalise the pattern to a second role —
S131's own prompt names that explicitly out of scope, to be repeated only after this one is proven
in use.* **S133 IS that repetition**, on n=2 sessions of enforced use (S131, S132), under the
founder's direct instruction at the S132 closeout. Citing `DECISION-007` passes the Architect gate
while moving a line that record locked, which is the deviation class the S127 addendum already
documented — so the relaxation is written here rather than left to a citation to imply.

### What this does NOT establish

- **Not that the advice is good, or that it was read.** The gate proves a dispatch happened, or
  that a sentence was written. `design-advisor: skipped — pure fix`, typed reflexively, passes.
- **Not that the advice reached the design.** A session may write all its code, dispatch at close,
  land the handoff, and show green. `.ai/ROADMAP.md` F2f records the cheap partial answer that was
  proposed and deliberately not built here (compare the handoff's `captured:` timestamp against
  the session's first code commit and WARN).
- **Not that a reasoned skip will stay rare.** Assume it drifts into a ritual unless someone
  counts. The counting rule, fixed now so a later session cannot pick a flattering one: **skips
  outnumbering dispatches in any rolling 5-session window means the skip has become the default.**
- **Not that all nine roles should be mandatory.** The founder named two. The second
  (`implementation-advisor`) is S134, on this mechanism.
- **Nothing improves on S131's disclosed limit:** the on-disk dispatch evidence is UNSIGNED and
  hand-fabricable by anyone with shell access to this machine. Inherited whole.
