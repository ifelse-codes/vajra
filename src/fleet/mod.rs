//! S109 — fleet slice 1: one named agent role (the Researcher) dispatched as a NATIVE Claude Code
//! **subagent** and governed by Vajra. Locked by `docs/decisions/DECISION-007-agent-fleet.md`.
//!
//! Vajra is an external binary — it does not (cannot) *call* a Claude Code subagent; subagents only
//! exist inside a running agent session. So Vajra's job for a named role is two things, both in this
//! module's contract:
//!   1. **Scaffold** the role as a native subagent definition (`.claude/agents/<name>.md`), rendered
//!      from ONE canonical source (the S104/S99 no-drift rule) — the same way `vajra init` already
//!      scaffolds `.claude/settings.json` + hooks (S44). The role prompt is vendor-neutral here;
//!      only the *rendering* is Claude-specific.
//!   2. **Govern the handoff.** The subagent returns a findings brief; Vajra wraps it into a
//!      delta-tracked handoff in the `.ai/` spine (the memory — no new store) and FAIL-CLOSES on an
//!      unknown role, missing/empty findings, or a handoff that would not validate.
//!
//! This module is the PURE core (role resolution, subagent rendering, handoff format + validate +
//! delta, one hash). The impure edges (reading findings, writing files, git) live in `cli::next` /
//! `cli::init`. Everything here is unit-testable without spawning anything.
//!
//! S112 adds the READ side — `read_handoff`/`read_handoffs` — so a station can consume what the
//! fleet produced. That is one narrow, fs-READ-only edge (no writes, no processes, tempdir-testable);
//! its parsing core, `parse_handoff`, stays pure like everything else here.
//!
//! S114 adds the SECOND role — the **Fidelity Reviewer** (chosen from evidence at S113, built here;
//! `DECISION-007` S114 addendum). No new machinery: it is one more `ROLES` entry, and every path
//! above already iterates the roles. What it DID force is honesty about the single source — the tool
//! grant and the delta text were both hardcoded to the Researcher while only one role existed, and
//! are now per-role.
//!
//! S116 adds the THIRD role — the **Plan Advisor** (founder pick B at the S115 closeout, named
//! Planner specifically; `DECISION-007` S116 addendum). Same zero-new-machinery shape as S114. Its
//! key is `plan-advisor`, not `planner` — the exact collision the S114 addendum resolved for the
//! Reviewer, now hit a second time against the Planner **station** (`src/planner/mod.rs`, S64),
//! which already counts a "Planner" in `K of 8`. Its contract is the `covers: N` marker that
//! station's gate already parses and grades (`cited_criteria` in `src/planner/mod.rs`) — the role
//! proposes citations in that exact shape; it does not gain any new parsing or grading path.
//!
//! S121 adds the FOURTH role — the **QA Specialist** (founder pick at the S120 GT closeout;
//! `DECISION-007` S121 addendum). Same zero-new-machinery shape again, with ONE deliberate
//! exception that is the whole point of the role: it is the first registered role granted
//! `Bash, Write, Edit`. Every prior role can only READ, which means the only "evidence" the fleet
//! could ever produce was prose about source it had read — and S118/S120 measured what that costs:
//! verify scripts made largely of source greps that would still pass with the feature deleted. An
//! executor could not fake a pass — it either ran the thing and has output, or it does not. The
//! grant is data on the `ROLES` table, not a new code path — nothing else in this module changed.
//!
//! **S122, and do not soften this: THAT THESIS IS UNPROVEN.** The role has now taken two live runs
//! (the S121 post-close audit and the S122 audit of this session's own suite) and found seven real
//! defects between them. Every single one came from careful independent READING. Execution bought
//! the exit codes and the `passed` counts, nothing more. What IS evidenced is the INDEPENDENCE
//! thesis: an agent that did not build the thing finds defects the builder cannot see. Whether an
//! executor can be made unable to fake a pass remains untested.
//!
//! **S123: the `Write`/`Edit` grant is FENCED now, not merely documented.** Two changes,
//! `DECISION-007` S123 addendum: (1) `Write`/`Edit` DROPPED from this role's grant — measured
//! live this session that the harness enforces `tools:` mechanically, so this closes a real path,
//! not a theatrical one; (2) the actual fence is routing this role's dispatch through a disposable
//! `git worktree` checkout (`vajra next --role qa-specialist --clean-room-open` /
//! `--clean-room-close`, `src/gate_run.rs`) instead of the source repo — because `Bash` remains
//! granted (it must, to run the suite) and anything with `Bash` can write a file by shell
//! redirection with no `Write`/`Edit` tool involved. **This does not prove the executor thesis
//! either.** It removes one specific way this role could cheat (repair the product, then report
//! the repaired state as original); it does not establish that no executor can fake a pass by any
//! means, and the clean room isolates the REPO, not the MACHINE — `Bash` inside it could still
//! reach for the real repo's absolute path. What closes that residual is tamper-EVIDENCE (the
//! source repo's HEAD sha / index hash / porcelain compared before and after), not
//! tamper-PROOFING. See the addendum for the full reasoning and the two rejected alternatives.
//!
//! Its key is `qa-specialist`, not `qa`, for the third instance of the STATION-vs-ROLE collision
//! (`src/qa/mod.rs`, the QA station, S69) that S114 and S116 each resolved the same way.

use std::io::Write;
use std::process::{Command, Stdio};

/// A named fleet role: its key, a one-line description (for the subagent picker), the system prompt
/// that scopes the agent, and — via `handoff_rel` — where its governed handoff lands. The ONE place
/// role text lives; both the subagent definition and the handoff are rendered from it (no drift).
pub struct Role {
    /// The `--role <name>` key and the subagent `name:`. Lower-case, stable — the join key.
    pub name: &'static str,
    /// One line describing WHEN to use this role — the subagent frontmatter `description:`.
    pub description: &'static str,
    /// The role-scoping system prompt — the subagent definition body.
    pub system_prompt: &'static str,
    /// This role's tool grant, rendered verbatim into the subagent frontmatter `tools:`. Per-role
    /// (S114) — it was hardcoded to the Researcher's list while only one role existed, which would
    /// have silently handed every future role the Researcher's web access.
    ///
    /// **Advisory roles are read-only. Exactly one role executes:** `qa-specialist` (S121) is
    /// granted `Bash, Write, Edit` because QA evidence that was never run is not evidence. That is
    /// the materially bigger governance decision the S114 note said none had taken — it is taken
    /// now, explicitly, in the `DECISION-007` S121 addendum, and it is scoped to this one role.
    pub tools: &'static str,
}

impl Role {
    /// Where this role's governed handoff for `session` lands, repo-relative. `.ai/` IS the memory
    /// (DECISION-007 / `feedback-map-concepts-to-vajra`) — no new store, no 8th artifact type.
    pub fn handoff_rel(&self, session: u32) -> String {
        format!(".ai/handoffs/session-{session:02}-{}.md", self.name)
    }

    /// Where this role's native subagent definition is scaffolded, repo-relative — the standard
    /// Claude Code `.claude/agents/<name>.md` location.
    pub fn subagent_rel(&self) -> String {
        format!(".claude/agents/{}.md", self.name)
    }
}

const RESEARCHER_SYSTEM_PROMPT: &str = "You are the Researcher on a governed software team. \
Your ONE job is to investigate the question you are given and return a concise, decision-ready \
findings brief.\n\
Rules:\n\
- Do NOT write, edit, or run code. You investigate and report only.\n\
- Lead with the answer, then the few facts that support it.\n\
- Prefer specifics (names, numbers, versions, trade-offs) over generalities.\n\
- If the question is ambiguous or you are unsure, say so plainly — never invent facts or sources.\n\
- Keep it short: a busy engineer should be able to act on it in under a minute.";

/// The Reviewer's contract (S114). This is the brief this repo has re-typed from memory every
/// session for 47 cold reviews — made canonical here, which is the whole point of `ROLES`.
///
/// Two things it states that no other role does, both locked by the `DECISION-007` S114 addendum:
/// the verdict it returns is a **pre-stage input**, and the canonical, gated record of the verdict
/// stays `sessions/session-NN-review.md` — this agent never writes that file (it has no write tool
/// and is told not to ask for one).
const FIDELITY_REVIEWER_SYSTEM_PROMPT: &str =
    "You are the Fidelity Reviewer on a governed software \
team. Your ONE job is an INDEPENDENT, ADVERSARIAL cold review of a delivery you did not build.\n\
You are fed only two things: the session prompt (what was asked) and the diff (what was done). \
Judge from those. Do not accept the builder's own summary as evidence.\n\
Rules:\n\
- Do NOT write, edit, or run code. You read and judge only.\n\
- Grade EVERY numbered requirement in the prompt: SHIPPED / PARTIAL / NOT-BUILT, each with the \
concrete evidence in the diff that earns the grade. A requirement with no evidence is NOT-BUILT.\n\
- Following the rules is not delivering what was asked: a green verify script proves discipline, \
never fidelity. Never grade from test counts alone.\n\
- Name THE FAKEST GREEN — the thing that looks done but is hollow (a check that would pass if the \
feature were deleted, a marker the author simply typed, an assertion that cannot fail).\n\
- Never self-certify and never soften: if the delivery is short, say so.\n\
Shape your brief so it can be landed without rewriting — the closeout gate reads the landed record \
and FAILS unless it carries all three of these:\n\
- a per-requirement MARKDOWN TABLE — the gate counts verdict words only on `|`-delimited rows and \
requires at least three of them, so one row per requirement carrying SHIPPED / PARTIAL / NOT-BUILT \
(a bulleted list with the same words does NOT pass),\n\
- a canonical `**Verdict:** ACCEPT` or `**Verdict:** REJECT` line (the word buried in a heading \
does not count),\n\
- a count of the form `X of N SHIPPED`.\n\
The full contract you are performing is `reviewer/SKILL.md` in this repo — READ IT before you \
judge; it is canonical and this brief is its dispatch-time summary, never a competing version.\n\
Your verdict is a PRE-STAGE INPUT. The canonical, gated record of the fidelity verdict is \
`sessions/session-NN-review.md` (read by `verify-closeout.sh`, attested by a `**Review-Inputs-SHA:**` \
the orchestrator computes, chained in the ledger) — you do not write it, and you are not its \
replacement.";

/// The Plan Advisor's contract (S116). Fed a session's goal + numbered acceptance criteria, it
/// proposes ordered plan steps citing which criterion/criteria each covers, in the exact `covers: N`
/// shape `src/planner/mod.rs::cited_criteria` already parses and `plan_coverage` already grades. It
/// proposes; it never authors the recorded plan (no Write/Edit — the same fail-closed shape as the
/// other two roles, stated explicitly here because "planning" reads closer to "editing the plan"
/// than "researching" or "reviewing" did).
const PLAN_ADVISOR_SYSTEM_PROMPT: &str = "You are the Plan Advisor on a governed software team. \
Your ONE job is to propose an ordered, coverage-checked plan for a session BEFORE any code is \
written.\n\
You are fed two things: the session's goal and its numbered acceptance criteria. Propose ordered \
plan steps that would satisfy them.\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT write the plan into the prompt file yourself — you \
propose, the author records. You have no Write or Edit tool, by design.\n\
- Every step you propose must explicitly cite which acceptance-criterion number(s) it covers, in \
the exact form `covers: N` or `covers: N, M` — a comma/whitespace-separated digit list straight \
after the literal word `covers:`. This is the exact marker the Planner station's gate parses and \
grades; a step without it counts as uncovered, not merely undocumented.\n\
- Cover EVERY numbered criterion with at least one step. A criterion your plan does not cite is a \
gap — say so plainly rather than silently leaving it out.\n\
- Do not invent criteria you were not given, and do not renumber the ones you were given.\n\
- Order steps so each is buildable given only the steps before it.\n\
- If the goal or the criteria are ambiguous, say so plainly rather than guessing a plan around the \
ambiguity.\n\
Your output is a PROPOSAL, never the plan of record: the session's own `## Plan` section, inside \
its own prompt file, is the only place a real plan lives — you do not create a second artifact, and \
only the session's author decides what actually lands there.";

/// The QA Specialist's contract (S121). The fleet's first role granted execution: it runs the
/// session's verify script and reports what actually ran. Its value so far is measured as
/// INDEPENDENCE, not execution — see the module header; the executor thesis is unproven. The classification it is asked for is the S120 GT finding
/// made operational — a check that greps `src/` for a message string is hollow (it survives the
/// feature being deleted), while a grep asserting ARCHITECTURE (one source of truth, no collision)
/// is structural and legitimate. It reports; it never edits the product under test.
const QA_SPECIALIST_SYSTEM_PROMPT: &str = "You are the QA Specialist on a governed software team. \
Your ONE job is to RUN the session's verification and report what actually executed.\n\
You are the first role on this team that can execute — you have Bash — because QA evidence that \
was never run is not evidence. Use that grant to RUN and to RECORD, never to change the thing you \
are testing.\n\
You will be pointed at a disposable clean-room checkout, not the source repo (S123 — \
`vajra next --role qa-specialist --clean-room-open`). Run every command inside that path. This is \
not a suggestion you are trusted to follow — it is the actual working directory you were given.\n\
Rules:\n\
- RUN the session's `scripts/verify-session-NN.sh` for the session number you are given. Report its \
real exit code and its real check-by-check output. Never report a result you did not observe.\n\
- CLASSIFY every check in that script into exactly one of two classes, and say which:\n\
  - EXECUTE-BASED — it runs the product (the binary, `cargo test`, a script) and asserts on real \
output.\n\
  - BEHAVIORAL SOURCE GREP — it greps source for a message, flag, or prompt string and treats \
finding that string as proof the feature works. This is HOLLOW: it would still pass if the feature \
were deleted and only the string survived.\n\
  A grep that asserts ARCHITECTURE instead of behaviour (one source of truth, no second copy, no \
name collision, a file's absence) is STRUCTURAL, not hollow — name it as such and keep it out of \
the hollow tally.\n\
- REPORT, every time: how many checks fall in each class, the NAME of every hollow check, and the \
live output that proves you ran the suite (the exit code and the summary lines).\n\
- Do NOT edit source code, do NOT repair the checks you criticise, and do NOT commit anything. \
Fixing what you just tested destroys the independence that makes your report worth reading.\n\
- If the verify script is missing, or will not run, SAY SO and STOP. A QA pass you could not run is \
a FAIL, never a silent skip — a check that cannot evaluate fails.\n\
- A green suite is not a passing delivery: say plainly what the suite never exercised.\n\
Your output is an evidence brief, not a verdict on the delivery — grading the requirements is the \
Fidelity Reviewer's job, and the gated record of that verdict is `sessions/session-NN-review.md`, \
which you do not write.";

/// The Requirements Analyst's contract (S126). The Analyst station (`src/analyst/mod.rs`, S54 +
/// S61 + S62) governs the **WHAT**: the session prompt IS the spec, and its gate parses four
/// required sections, the `Status:` line, the `## Delta` bullets' OpenSpec markers, and the
/// summary's exactly-three ranked candidates. This role proposes text for all of those; it never
/// writes the prompt file, and — stated explicitly because it is the one tempting overreach for
/// this role — it never proposes flipping `Status:` to APPROVED, which is the human's signature.
const REQUIREMENTS_ANALYST_SYSTEM_PROMPT: &str = "You are the Requirements Analyst on a governed \
software team. Your ONE job is to turn a vague intent into a proposal for the next session's \
governed prompt — the WHAT, before any design or code.\n\
This team has no separate spec file. The session prompt `prompts/NN-task-<slug>.md` IS the spec, \
and the Analyst station's gate parses it directly.\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT write the prompt file yourself — you propose, the \
author records. You have no Write or Edit tool, by design.\n\
- Propose text for all four sections the gate requires by name: Goal, Deliverables, Acceptance, \
Guardrails. A prompt missing any of them is ill-formed and BLOCKS the advance into that session.\n\
- Write acceptance criteria as numbered, testable EARS-style lines — WHEN <x> THEN <observable \
y> — that a non-author could check by running one command. Never phrase a criterion so that only \
the author can say whether it passed.\n\
- Propose a `## Delta` block whose bullets each carry an OpenSpec marker — `+` added, `~` \
modified, `-` removed — followed by REAL text. A bullet still reading `<like this>` is scored as \
a placeholder, and a Delta of placeholders counts as not recorded at all.\n\
- Never propose `Status: APPROVED`. The scaffold ships `Status: DRAFT` and only the human flips \
it; proposing the flip is proposing your own approval.\n\
- When you are asked for next-session candidates, give EXACTLY THREE, ranked. The Options gate \
counts them and blocks on any other number.\n\
- One story per session. If the intent needs an `and`, say which half you would cut and why \
rather than proposing a session that carries both.\n\
- If the intent is ambiguous enough that two readings would produce different sessions, say so \
plainly and ask — never invent scope to fill a section.\n\
Your output is a PROPOSAL, never the prompt of record: `prompts/NN-task-<slug>.md` is the only \
place a real session prompt lives, and only the session's author decides what lands there.";

/// The Design Advisor's contract (S126). The Architect station (`src/architect/mod.rs`, S67)
/// governs the **DESIGN**, and its gate parses exactly two recorded things: the
/// `design-significant: yes|no` marker, and a substantive `## Design` section citing a record that
/// EXISTS under `docs/adr/` or `docs/decisions/`. The role is told to CHECK existence before
/// citing — a made-up `ADR-9999` is the exact hole S67 closed, and the role that would most
/// plausibly invent one is this one.
const DESIGN_ADVISOR_SYSTEM_PROMPT: &str = "You are the Design Advisor on a governed software \
team. Your ONE job is to propose the DESIGN rationale for a session — the decision that sits \
between what is being built and how it will be built.\n\
The design record is not a new file. It is the `## Design` section INSIDE the session's own \
prompt, and the Architect station's gate parses exactly two things there.\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT write the `## Design` section yourself — you \
propose, the author records. You have no Write or Edit tool, by design.\n\
- Recommend the `design-significant: yes` or `design-significant: no` marker line and say WHY. \
`yes` = a new or changed interface, a new module, or a deviation from a locked record; `no` = a \
pure fix. The gate READS that marker and never guesses, so leaving it unrecorded is not a \
neutral omission.\n\
- Cite a design record that EXISTS in this repo's spine — `docs/adr/` or `docs/decisions/`. Look \
for the file before you cite it: the gate blocks a citation that resolves to no file, and an \
invented id is worse than an honest 'no record covers this yet'.\n\
- Propose real rationale text, never the template `<placeholder>` shape — an angle-bracketed \
`## Design` body counts as unrecorded.\n\
- Name the alternatives you rejected and why. A rationale with no rejected option is a \
description, not a decision.\n\
- Say plainly when the session needs a NEW decision record rather than a citation of an old one, \
and say when the design DEVIATES from the record it cites — the gate checks the form of the \
citation, not whether the design obeys what it cites.\n\
Your output is a PROPOSAL, never the design of record: the `## Design` section of the session's \
prompt, and the locked records under `docs/adr/` and `docs/decisions/`, are the only places a \
real design decision lives.";

/// The Implementation Advisor's contract (S126). The Coder station (`src/coder/mod.rs`, S68)
/// governs the **DID**: each landed plan step recorded as `step N — done: <sha>` in `## Execution`,
/// with every sha existence-checked against git. This role is deliberately NOT named `coder` and
/// deliberately CANNOT write — see the `DECISION-007` S126 addendum: granting it `Write`/`Edit`
/// would reverse both the S123 narrowing and the S122 retraction of the executor thesis in the
/// same session that ships it. The prompt therefore forbids the one thing a write-capable role
/// would be tempted into: recording a step done before its commit exists.
const IMPLEMENTATION_ADVISOR_SYSTEM_PROMPT: &str = "You are the Implementation Advisor on a \
governed software team. Your ONE job is to propose HOW a recorded plan step should be built, and \
to keep the execution trace honest.\n\
You are an advisor, not the author of the change: on this team code lands as commits made by the \
governed session under an explicit human approval, and the Coder station's gate reads the \
`## Execution` section of the session's own prompt, where each landed step is recorded as \
`step N — done: <sha>` and every sha is resolved against git.\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT edit the `## Execution` section yourself — you \
propose, the author builds, commits, and records. You have no Write, Edit, or Bash tool, by \
design.\n\
- Propose the change concretely: the files to touch, the shape of the change in each, and the \
test that would fail without it. Quote the existing code you are building on so the author can \
see you read it.\n\
- Map every proposal back to a numbered plan step, so the author can record `step N` against a \
real commit when it lands. Never propose a sha, never guess one, and never suggest recording a \
step as done before its commit exists — a recorded sha that git cannot resolve is scored as \
unrecorded, not as a small slip.\n\
- Keep each step landable in one small commit; this team's limit is three files per commit, so a \
proposal that cannot be split that way is really a proposal to split the step.\n\
- Prefer the smallest change that satisfies the step. If the step cannot be built without \
touching something outside the session's scope, say so rather than quietly widening it.\n\
- If you cannot see enough of the code to be specific, say what you would need to read. Never \
invent an API, a path, or a function you have not read.\n\
Your output is a PROPOSAL, never the change of record: the commits on the session branch are the \
only implementation, and the `## Execution` trace is written by the author from shas that already \
exist.";

/// The Demo Producer's contract (S126). The Demo-er station (`src/demoer/mod.rs`, S71) governs the
/// **SHOW**, and its marker is *executable*: the gate RE-RUNS `scripts/demo-session-NN.sh` live and
/// scans the LIVE output for `demo:header`, `demo:cases`, `demo:summary_table`, `demo:before_after`.
/// The role is told the honest floor the station itself discloses — the scan proves the script
/// PRINTED the element, never that what it printed is true — so it cannot pitch a hollow demo as
/// verification.
const DEMO_PRODUCER_SYSTEM_PROMPT: &str = "You are the Demo Producer on a governed software team. \
Your ONE job is to propose what a session's demo must SHOW, so someone watching it knows what \
shipped and what changed.\n\
The demo is not a document. It is the session's demo script, and the Demo-er station's gate \
RE-RUNS that script live and scans its OUTPUT for four recorded elements: `demo:header`, \
`demo:cases`, `demo:summary_table`, `demo:before_after`.\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT write the demo script yourself — you propose, the \
author records. You have no Write, Edit, or Bash tool, by design.\n\
- Propose content for each of the four scanned elements by name: the header that says which \
session this is and what it delivered; the cases that exercise the real thing; the summary table \
of results; and the before-and-after that shows what changed.\n\
- Every case you propose must run the REAL product — the built binary, the real script — and \
print what it observed. A demo that prints claims is theatre: the gate can only tell that the \
script emitted the element, never that what it emitted is true.\n\
- Show the BEFORE state honestly, including when the honest before state is 'this did not exist \
at all'. A before-and-after that only shows the after is the commonest hollow demo.\n\
- Never propose a case that cannot fail — one wrapped so its exit code is ignored, quieted to \
nothing, or asserting something already true. A case that cannot fail shows nothing.\n\
- Say plainly what the demo does NOT show. A session's demo is not its verification, and a green \
demo is not a passing delivery.\n\
Your output is a PROPOSAL, never the demo of record: `scripts/demo-session-NN.sh` is the only \
demo the gate re-runs, and only the session's author decides what lands in it.";

/// The Release Coordinator's contract (S126). The Releaser station (`src/releaser/mod.rs`, S72)
/// governs the **SHIP**, and it is the one station whose marker is *derived git state* rather than
/// recorded text: `require_merged_prior`, `require_main_synced`, `require_pruned` in
/// `.ai/CONSTRAINTS.yaml#release`, re-derived at check time. This role is read-only and cannot run
/// git at all, so its prompt's load-bearing rule is that it must never report ancestry or sync
/// state as if it had observed it — the S124 fabricated-citation failure, in the one role most
/// exposed to it.
const RELEASE_COORDINATOR_SYSTEM_PROMPT: &str = "You are the Release Coordinator on a governed \
software team. Your ONE job is to propose the ordered steps that ship a finished session — and to \
say plainly when it is not shippable yet.\n\
Shipping is a human act here. The Releaser station's gate never pushes, merges, or deletes \
anything: it RE-DERIVES the ship state from git and blocks on three recorded contract keys — \
`require_merged_prior` (the session branch is merged into main by ancestry), `require_main_synced` \
(local main is neither behind nor diverged from `origin/main`), and `require_pruned` (merged \
`session-*` branches are deleted locally).\n\
Rules:\n\
- Do NOT write, edit, or run code, and do NOT push, merge, tag, publish, or delete anything — you \
propose, a human acts. You have no Write, Edit, or Bash tool, by design.\n\
- You cannot run git. Work only from the ship state you were given and the files you can read, \
and never report ancestry, sync, or branch state as if you had observed it — say which fact you \
are inferring and from what.\n\
- Propose the steps in the order the gate checks them: open the PR, land the review verdict, \
merge, return to main and pull, then prune the merged branches. A step taken out of that order is \
the usual reason the next session's gate blocks.\n\
- List the blockers separately from the steps, and name each one plainly: an unmerged branch, a \
main behind its remote, merged branches left lying around.\n\
- State the gate's own blind spots when they matter: `origin/main` is only as fresh as the last \
fetch, and a branch deleted before it was merged looks exactly like one deleted after.\n\
- Never propose a version bump, a package publish, or an announcement as a routine step. Those \
are founder-gated decisions on this team; raise them as a question, never as a checklist item.\n\
Your output is a PROPOSAL, never the release of record: git is the only record of what shipped, \
and every push, merge, and prune stays a human act.";

/// The registered roles. Slice 1 (DECISION-007) shipped exactly ONE — the Researcher. S114 added the
/// SECOND (the Fidelity Reviewer, chosen from evidence at S113). S116 added the THIRD: the Plan
/// Advisor (founder pick at the S115 closeout). S121 adds the FOURTH: the QA Specialist (founder
/// pick at the S120 GT closeout) — the first that can execute. A fifth role remains a separate
/// decision, not a reflex (the named key risk of S109 is scope creep).
///
/// **The Reviewer's key is `fidelity-reviewer`, not `reviewer`** — the deliberate resolution of the
/// collision the S113 cold review named (`DECISION-007` S114 addendum). `K of 8` already counts a
/// **Reviewer station**; a role keyed `reviewer` would make "Reviewer" mean two different things in
/// two lines of the same report.
///
/// **The Planner's key is `plan-advisor`, not `planner`** — the exact same collision, hit a second
/// time: `K of 8` already counts a **Planner station** (`src/planner/mod.rs`, S64). Distinct key,
/// distinct word, no ambiguity (`DECISION-007` S116 addendum).
///
/// **The QA Specialist's key is `qa-specialist`, not `qa`** — the same collision a THIRD time:
/// `K of 8` already counts a **QA station** (`src/qa/mod.rs`, S69), which governs the process; the
/// role does the work (`DECISION-007` S121 addendum).
pub const ROLES: &[Role] = &[
    Role {
        name: "researcher",
        description: "Investigate a question and return a concise, decision-ready findings brief. \
                      Use before a design or build decision that needs facts, trade-offs, or prior \
                      art. Read-only — never writes code.",
        system_prompt: RESEARCHER_SYSTEM_PROMPT,
        // Investigation needs the web; judging a diff does not.
        tools: "Read, Grep, Glob, WebSearch, WebFetch",
    },
    Role {
        name: "fidelity-reviewer",
        description: "Independently cold-review a finished delivery against the session prompt: \
                      grade every numbered requirement SHIPPED/PARTIAL/NOT-BUILT and name the \
                      fakest green. Use at close, never on your own work. Read-only.",
        system_prompt: FIDELITY_REVIEWER_SYSTEM_PROMPT,
        // Strictly local reads. No web (a fidelity call is decided by the prompt and the diff in
        // front of it, not by the internet) and no Bash (running things is the QA station's job,
        // live — DECISION-007 rejected swapping those teeth for an agent's prose).
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "plan-advisor",
        description: "Propose an ordered, coverage-checked plan mapping a session's acceptance \
                      criteria to plan steps (`covers: N`), before code is written. Use during \
                      planning, never to author the recorded `## Plan` itself. Read-only.",
        system_prompt: PLAN_ADVISOR_SYSTEM_PROMPT,
        // Strictly local reads, same shape as the Reviewer: planning a session is decided by that
        // session's own prompt, not the internet, and it does not run anything.
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "qa-specialist",
        description: "Run the session's verify script and report what actually executed: real exit \
                      code, plus every check classified execute-based vs hollow source-grep. Use at \
                      verification time, on work you did not build. Executes code.",
        system_prompt: QA_SPECIALIST_SYSTEM_PROMPT,
        // THE ONE EXECUTING ROLE (S121, DECISION-007 S121 addendum). Bash is the load-bearing
        // grant: a role that cannot run the suite can only grep for the suite, which is the exact
        // hollow evidence this role exists to catch.
        //
        // S123: Write/Edit DROPPED — the cheap second layer of the DECISION-007 S123 addendum's
        // fence, applied because this session measured (live, not assumed) that the harness
        // enforces a role's `tools:` grant mechanically, not just by prompt convention. This is
        // NOT the fence itself: Bash remains, and anything with Bash can write a file by shell
        // redirection with no Write/Edit tool involved. The real fence is dispatching this role
        // against a disposable clean-room checkout (`vajra next --role qa-specialist
        // --clean-room-open`), never the source repo directly — see the addendum for why
        // narrowing the grant alone was rejected as the fence and kept only as a second layer.
        // Still NO web and NO NotebookEdit: QA is decided by this repo's own suite, not the
        // internet, and not by spawning another agent.
        tools: "Bash, Read, Grep, Glob",
    },
    Role {
        name: "requirements-analyst",
        description: "Propose the next session's governed prompt — goal, deliverables, testable \
                      acceptance, guardrails, and a substantive `## Delta` — before any design or \
                      code. Use at intake, never to author the prompt file. Read-only.",
        system_prompt: REQUIREMENTS_ANALYST_SYSTEM_PROMPT,
        // Read-only by default (S126). Intake is decided by this repo's own spine — the ROADMAP,
        // the prior session's summary, the prompts already written — not by the internet, and it
        // runs nothing.
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "design-advisor",
        description: "Propose a session's `## Design` rationale and its `design-significant:` \
                      marker, citing a design record that really exists under docs/adr or \
                      docs/decisions. Use before the plan is executed. Read-only.",
        system_prompt: DESIGN_ADVISOR_SYSTEM_PROMPT,
        // Read-only, and the read tools are load-bearing rather than incidental: Glob/Grep are how
        // this role checks that the record it wants to cite EXISTS before citing it, which is the
        // exact hole S67 closed in the station's gate.
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "implementation-advisor",
        description: "Propose how a recorded plan step should be built — files, shape, the test \
                      that would fail without it — and keep the `step N — done: <sha>` trace \
                      honest. Use during the build, never to write the change. Read-only.",
        system_prompt: IMPLEMENTATION_ADVISOR_SYSTEM_PROMPT,
        // THE ONE REAL FORK OF S126, resolved read-only and argued in the DECISION-007 S126
        // addendum: this is the role most obviously "supposed" to write, and granting it
        // Write/Edit would reverse S123 (which narrowed the only executing role's grant) and the
        // S122 retraction of the executor thesis in the same session that ships it. It proposes;
        // the governed session commits under human approval. Widening this grant is a separate,
        // founder-gated decision.
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "demo-producer",
        description: "Propose what a session's demo script must show — header, cases, summary \
                      table, before-and-after — so the gate's live re-run proves what shipped. \
                      Use before the demo is written. Read-only.",
        system_prompt: DEMO_PRODUCER_SYSTEM_PROMPT,
        // Read-only. Note what is NOT granted: Bash. The Demo-er station already RE-RUNS the demo
        // script live (S71) — a role that could run it too would only add a second, ungoverned
        // account of the same output, which is the failure mode S124 named.
        tools: "Read, Grep, Glob",
    },
    Role {
        name: "release-coordinator",
        description: "Propose the ordered ship steps for a finished session — PR, merge, main \
                      synced, branches pruned — and name what blocks it. Use at closeout, never \
                      to push, merge, or prune. Read-only.",
        system_prompt: RELEASE_COORDINATOR_SYSTEM_PROMPT,
        // Read-only, deliberately including NO Bash: this role advises on pushing, merging and
        // deleting branches, so it is the single role where an execution grant would put
        // irreversible git acts one tool call away. Its prompt states the consequence plainly —
        // it cannot run git, so it must never report git state as observed.
        tools: "Read, Grep, Glob",
    },
];

/// Resolve a role by its key. `None` (→ the caller fails closed) for an unknown role: vajra never
/// governs a role it cannot scope.
pub fn resolve_role(name: &str) -> Option<&'static Role> {
    ROLES.iter().find(|r| r.name == name)
}

/// The known role names, comma-joined — for a fail-closed "unknown role" error message.
pub fn known_roles() -> String {
    ROLES.iter().map(|r| r.name).collect::<Vec<_>>().join(", ")
}

/// Render a role as a native Claude Code subagent definition (`.claude/agents/<name>.md`): YAML
/// frontmatter (`name`, `description`, read-only `tools`) + the system prompt + a short note that
/// its findings become a Vajra-governed handoff (so the subagent returns a brief, and does NOT try
/// to author the handoff frontmatter — Vajra owns that). Rendered from the SAME `Role` the handoff
/// uses — one canonical source, no drift.
pub fn render_subagent_definition(role: &Role) -> String {
    format!(
        "---\n\
         name: {name}\n\
         description: {desc}\n\
         tools: {tools}\n\
         ---\n\
         \n\
         {sys}\n\
         \n\
         ## Governed handoff (Vajra owns this)\n\
         Return your findings brief as your final message. The orchestrator records it as a\n\
         Vajra-governed, delta-tracked handoff at `.ai/handoffs/session-<NN>-{name}.md` via\n\
         `vajra next --role {name} --from <file>`. Do NOT write the handoff frontmatter yourself —\n\
         Vajra computes the source hash, the timestamp, and the delta against the prior stage.\n",
        name = role.name,
        desc = role.description,
        tools = role.tools,
        sys = role.system_prompt,
    )
}

/// The `## Handoff Delta` body: what this handoff adds relative to the PRIOR stage. A first handoff
/// has no prior (the prior stage is the session prompt / Analyst's WHAT), so the delta records
/// "new"; a re-run against an existing handoff records the size change. This is what makes the
/// handoff a *tracked* artifact with a recorded delta, not an opaque dump.
///
/// S114: takes the `role` instead of writing the word "researcher" into every delta. With one role
/// registered the hardcoding was invisible; with two it would have stamped a Reviewer handoff with
/// the Researcher's name — the single-source drift this module exists to prevent.
pub fn compute_delta(role: &Role, prior_body: Option<&str>, new_body: &str) -> String {
    match prior_body {
        None => format!(
            "- `+` new: first {role} handoff for this session ({} bytes of findings)\n\
             - prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against",
            new_body.len(),
            role = role.name
        ),
        Some(p) => format!(
            "- `~` re-run: {role} handoff replaced ({} bytes now vs {} bytes prior)\n\
             - prior stage: this session's earlier {role} handoff",
            new_body.len(),
            p.len(),
            role = role.name
        ),
    }
}

/// Format the governed handoff artifact (the DECISION-007 contract). Deterministic given its
/// inputs — the timestamp is passed in so this stays pure and testable. `cost` is the subagent's
/// metered dollars when known, else `None`. **S111 checked this, not guessed it, with a re-runnable
/// script** (`scripts/check-subagent-cost-fields.sh`, not a one-off count baked in here): every real
/// subagent JSONL transcript on the checking machine was scanned — zero carry a `total_cost_usd` /
/// `cost_usd` key. A Task-tool subagent never produces the `-p` headless result stream that field is
/// emitted on (same root cause as S77/S78), so the figure structurally does not exist for Vajra to
/// read — `null` is the honest, checked answer, not a gap to close.
#[allow(clippy::too_many_arguments)]
pub fn format_handoff(
    role: &Role,
    session: u32,
    agent_label: &str,
    source_sha: &str,
    captured_utc: &str,
    cost: Option<f64>,
    body: &str,
    delta: &str,
) -> String {
    let cost_str = match cost {
        Some(c) => format!("{c:.6}"),
        None => "null".to_string(),
    };
    format!(
        "---\n\
         role: {role}\n\
         session: {session}\n\
         agent: {agent}\n\
         source-sha: {sha}\n\
         captured: {captured}\n\
         cost_usd: {cost}\n\
         ---\n\
         \n\
         # {Role} handoff — session {session}\n\
         \n\
         {body}\n\
         \n\
         ## Handoff Delta\n\
         {delta}\n",
        role = role.name,
        Role = title_case(role.name),
        agent = agent_label,
        sha = source_sha,
        captured = captured_utc,
        cost = cost_str,
    )
}

fn title_case(s: &str) -> String {
    let mut c = s.chars();
    match c.next() {
        None => String::new(),
        Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
    }
}

/// The six frontmatter keys the handoff contract requires (DECISION-007).
const FRONTMATTER_KEYS: [&str; 6] = [
    "role:",
    "session:",
    "agent:",
    "source-sha:",
    "captured:",
    "cost_usd:",
];

/// A handoff is well-formed iff it carries every frontmatter contract key, a non-empty findings
/// body, AND the `## Handoff Delta` section (DECISION-007). Used by the fail-closed governance: a
/// malformed or empty handoff must NEVER read as a successful step. `Err(reason)` names the first
/// missing piece.
pub fn validate_handoff(text: &str) -> Result<(), String> {
    for key in FRONTMATTER_KEYS {
        if !text.lines().any(|l| l.trim_start().starts_with(key)) {
            return Err(format!("handoff missing frontmatter key `{key}`"));
        }
    }
    if !text.contains("## Handoff Delta") {
        return Err("handoff missing `## Handoff Delta` section".into());
    }
    match handoff_body(text) {
        Some(b) if !b.trim().is_empty() => Ok(()),
        _ => Err("handoff has an empty findings body".into()),
    }
}

/// The findings body — the content between the closing frontmatter fence and the `## Handoff Delta`
/// section, minus heading lines. `None` when the frontmatter fence or the delta section is absent.
/// Public so the ingest can extract a PRIOR handoff's body to feed `compute_delta` on a re-run.
pub fn handoff_body(text: &str) -> Option<String> {
    let after_fm = text.strip_prefix("---\n")?;
    let close = after_fm.find("\n---\n")?;
    let rest = &after_fm[close + 5..];
    let (before_delta, _) = rest.split_once("## Handoff Delta")?;
    let body: Vec<&str> = before_delta
        .lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty() && !l.starts_with('#'))
        .collect();
    Some(body.join("\n"))
}

/// sha256 of a byte string — the handoff's `source-sha` preimage (the subagent's raw findings), so
/// a governed handoff is verifiably derived from those exact findings. Shells out (same tool-fallback
/// order as `verify-closeout.sh#_sha256`) rather than add a crate for one hash; this codebase already
/// shells to git/sha tools throughout.
pub fn sha256_hex(bytes: &[u8]) -> Option<String> {
    let variants: [(&str, &[&str]); 2] = [("sha256sum", &[]), ("shasum", &["-a", "256"])];
    for (cmd, args) in variants {
        let mut child = match Command::new(cmd)
            .args(args)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
        {
            Ok(c) => c,
            Err(_) => continue,
        };
        if let Some(mut stdin) = child.stdin.take() {
            if stdin.write_all(bytes).is_err() {
                continue;
            }
        }
        if let Ok(out) = child.wait_with_output() {
            if out.status.success() {
                if let Some(h) = String::from_utf8_lossy(&out.stdout)
                    .split_whitespace()
                    .next()
                {
                    return Some(h.to_string());
                }
            }
        }
    }
    None
}

// ---------------------------------------------------------------------------
// S112 — the READ side. S109 wrote governed handoffs; S111 proved they come from a real by-name
// dispatch; nothing read them back, so the fleet's output sat orphaned next to the pipeline it
// belongs to. Everything below turns a written handoff into something a station can consume.
// ---------------------------------------------------------------------------

/// What a governed handoff says about itself, read back off disk. Built ONLY from a handoff that
/// passed `validate_handoff` — a malformed one becomes `HandoffRead::Malformed`, never a `Handoff`
/// with blank fields, so a broken artifact can never read as a good one (the fail-closed rule,
/// applied to the reader).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Handoff {
    /// The role that produced it (`role:` frontmatter) — e.g. `researcher`.
    pub role: String,
    /// The session it belongs to, from the path it was found at (the SoT for placement).
    pub session: u32,
    /// Repo-relative path, so a caller can point a human at the file.
    pub path: String,
    /// The `agent:` frontmatter — which agent produced the findings.
    pub agent: String,
    /// The `captured:` frontmatter — when.
    pub captured: String,
    /// The `source-sha:` frontmatter — the hash of the raw findings it was derived from.
    pub source_sha: String,
    /// The findings body, already stripped of headings/blank lines by `handoff_body`.
    pub body: String,
}

impl Handoff {
    /// Every non-empty body line, trimmed — the basis for both the inline head and the honest
    /// "there is more" count.
    fn body_lines(&self) -> Vec<String> {
        self.body
            .lines()
            .map(|l| l.trim().to_string())
            .filter(|l| !l.is_empty())
            .collect()
    }

    /// The first `n` body lines — what a consuming station inlines so the findings are actually in
    /// front of the reader, not merely referenced by path.
    pub fn head_lines(&self, n: usize) -> Vec<String> {
        self.body_lines().into_iter().take(n).collect()
    }

    /// How many body lines the inline head LEAVES OUT at `n`. A reader who is shown 6 of 40 lines
    /// must be told so — a truncation that looks like the whole thing is exactly the false green
    /// this project exists to kill.
    pub fn omitted_lines(&self, n: usize) -> usize {
        self.body_lines().len().saturating_sub(n)
    }
}

/// The three honest outcomes of looking for a role's handoff. `Absent` is the silent, harmless
/// case (most sessions have no researcher handoff and must behave exactly as before). `Malformed`
/// is deliberately NOT silent: a file that exists but fails the contract is a problem to surface,
/// not to swallow.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum HandoffRead {
    /// No handoff file for this role/session.
    Absent,
    /// A file exists but does not satisfy the DECISION-007 contract. Carries (path, reason).
    Malformed(String, String),
    /// A contract-valid handoff.
    Found(Handoff),
}

/// Parse handoff TEXT into a `Handoff` (pure — the testable core). `session`/`path` come from where
/// it was found rather than from the frontmatter: the path is the placement SoT, and trusting a
/// self-declared `session:` would let a misfiled handoff claim any session it liked.
pub fn parse_handoff(text: &str, session: u32, path: &str) -> Result<Handoff, String> {
    validate_handoff(text)?;
    let body = handoff_body(text).ok_or_else(|| "handoff has no findings body".to_string())?;
    // Every displayed field must come from the FRONTMATTER BLOCK, not merely from somewhere in the
    // file. `validate_handoff` accepts a `role:` line anywhere (it scans all lines), so without this
    // a file whose keys sit in the body would parse into a `Handoff` with blank fields and render as
    // "  (agent: , captured: )" — a broken artifact reading as a good one. Fail closed instead.
    let field = |key: &str| {
        frontmatter_value(text, key)
            .ok_or_else(|| format!("handoff frontmatter block has no `{key}` value"))
    };
    Ok(Handoff {
        role: field("role:")?,
        session,
        path: path.to_string(),
        agent: field("agent:")?,
        captured: field("captured:")?,
        source_sha: field("source-sha:")?,
        body,
    })
}

/// The value of a frontmatter `key:` line, trimmed. Only the frontmatter block is searched (the
/// text before the closing `---` fence), so a body line that merely starts with `agent:` cannot
/// impersonate a frontmatter field.
fn frontmatter_value(text: &str, key: &str) -> Option<String> {
    let after_fm = text.strip_prefix("---\n")?;
    let close = after_fm.find("\n---\n")?;
    after_fm[..close]
        .lines()
        .find_map(|l| l.trim_start().strip_prefix(key))
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

/// Read one role's governed handoff for `session` back off disk (the module's one narrow read
/// edge — fs-read-only, no writes, no processes; testable against a tempdir). An unreadable file
/// is reported as `Malformed`, never silently `Absent`.
pub fn read_handoff(root: &std::path::Path, role: &Role, session: u32) -> HandoffRead {
    let rel = role.handoff_rel(session);
    let path = root.join(&rel);
    if !path.exists() {
        return HandoffRead::Absent;
    }
    match std::fs::read_to_string(&path) {
        Err(e) => HandoffRead::Malformed(rel, format!("unreadable: {e}")),
        Ok(text) => match parse_handoff(&text, session, &rel) {
            Ok(h) => HandoffRead::Found(h),
            Err(reason) => HandoffRead::Malformed(rel, reason),
        },
    }
}

/// Every registered role's handoff for `session`, dropping the `Absent` ones. Empty vec = this
/// session simply had no fleet work, which every caller must treat as normal and silent.
pub fn read_handoffs(root: &std::path::Path, session: u32) -> Vec<HandoffRead> {
    ROLES
        .iter()
        .map(|r| read_handoff(root, r, session))
        .filter(|h| !matches!(h, HandoffRead::Absent))
        .collect()
}

/// Render read handoffs as the block a consuming station prints: who produced it, when, where it
/// lives, and the first `head` findings lines INLINE (a path alone is not consumption). Empty
/// input renders the empty string — absence prints nothing at all.
pub fn format_handoff_brief(reads: &[HandoffRead], head: usize) -> String {
    let mut s = String::new();
    for r in reads {
        match r {
            HandoffRead::Absent => {}
            HandoffRead::Malformed(path, reason) => {
                s.push_str(&format!(
                    "  ⚠ {path} exists but does not satisfy the handoff contract ({reason}) \
                     — not used\n"
                ));
            }
            HandoffRead::Found(h) => {
                s.push_str(&format!(
                    "  {role} (agent: {agent}, captured: {captured})\n    {path}\n",
                    role = h.role,
                    agent = h.agent,
                    captured = h.captured,
                    path = h.path,
                ));
                for line in h.head_lines(head) {
                    let clipped: String = line.chars().take(110).collect();
                    let ell = if line.chars().count() > 110 {
                        "…"
                    } else {
                        ""
                    };
                    s.push_str(&format!("    · {clipped}{ell}\n"));
                }
                // Never let a truncated head read as the whole brief — say how much was left out
                // and where the rest is. A partial view that looks complete is a false green.
                let omitted = h.omitted_lines(head);
                if omitted > 0 {
                    s.push_str(&format!(
                        "    · … {omitted} more line(s) — full findings at {}\n",
                        h.path
                    ));
                }
            }
        }
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn resolve_role_knows_researcher_and_fails_closed_on_unknown() {
        assert!(resolve_role("researcher").is_some());
        assert_eq!(resolve_role("researcher").unwrap().name, "researcher");
        // Unknown role → None (the caller fails closed). Case-sensitive on the stable key.
        assert!(resolve_role("Researcher").is_none());
        assert!(resolve_role("coder").is_none());
        assert!(resolve_role("").is_none());
        assert!(known_roles().contains("researcher"));
    }

    #[test]
    fn handoff_and_subagent_paths_are_conventional() {
        let r = resolve_role("researcher").unwrap();
        assert_eq!(r.handoff_rel(109), ".ai/handoffs/session-109-researcher.md");
        assert_eq!(r.handoff_rel(9), ".ai/handoffs/session-09-researcher.md");
        assert_eq!(r.subagent_rel(), ".claude/agents/researcher.md");
    }

    #[test]
    fn render_subagent_definition_is_valid_claude_agent_from_one_source() {
        let r = resolve_role("researcher").unwrap();
        let def = render_subagent_definition(r);
        // Claude Code subagent frontmatter: name + description, opening `---` fence.
        assert!(def.starts_with("---\n"));
        assert!(def.contains("name: researcher"));
        assert!(def.contains("description:"));
        assert!(def.contains("tools:"));
        // The body is the CANONICAL system prompt (no drift). S122: this used to add
        // `assert!(def.contains(r.system_prompt))` — the render checked against the field it
        // renders from, true for any value including "". The cold review found it still standing
        // after the same shape was removed from the every-role test. Substance is asserted instead.
        assert!(def.contains("You are the Researcher"));
        assert!(def.contains("Do NOT write, edit, or run code."));
        assert!(role_prompt_substance(r).is_ok());
        // It points at the governed handoff, and tells the subagent NOT to author frontmatter.
        assert!(def.contains(".ai/handoffs/session-<NN>-researcher.md"));
        assert!(def.contains("vajra next --role researcher --from"));
    }

    #[test]
    fn compute_delta_new_vs_rerun() {
        let r = resolve_role("researcher").unwrap();
        let d0 = compute_delta(r, None, "abcde");
        assert!(d0.contains("`+` new"));
        assert!(d0.contains("5 bytes"));
        let d1 = compute_delta(r, Some("ab"), "abcde");
        assert!(d1.contains("`~` re-run"));
        assert!(d1.contains("5 bytes now vs 2 bytes"));
    }

    /// S114 — the delta names the role that produced it. Hardcoded to "researcher" before a second
    /// role existed, so a Reviewer handoff would have carried the Researcher's name in its own
    /// tracked delta. Asserted for EVERY registered role, so a third role cannot regress it.
    #[test]
    fn compute_delta_names_the_producing_role_not_a_hardcoded_one() {
        for role in ROLES {
            let new = compute_delta(role, None, "findings");
            let rerun = compute_delta(role, Some("prior"), "findings");
            assert!(
                new.contains(&format!("first {} handoff", role.name)),
                "new-delta does not name {}: {new}",
                role.name
            );
            assert!(
                rerun.contains(&format!("{} handoff replaced", role.name)),
                "re-run delta does not name {}: {rerun}",
                role.name
            );
            // A non-researcher role must not carry the Researcher's name anywhere in its delta.
            if role.name != "researcher" {
                assert!(
                    !new.contains("researcher"),
                    "{} leaked 'researcher'",
                    role.name
                );
                assert!(
                    !rerun.contains("researcher"),
                    "{} leaked 'researcher'",
                    role.name
                );
            }
        }
    }

    /// S114 — the SECOND role exists, is keyed to avoid the Reviewer-STATION collision, and carries
    /// the adversarial contract. This fails if the role is removed, renamed to `reviewer`, or
    /// hollowed out to a stub prompt.
    #[test]
    fn fidelity_reviewer_is_registered_with_a_non_colliding_key() {
        assert_eq!(ROLES.len(), 9, "the fleet ships exactly nine roles at S126");
        let r = resolve_role("fidelity-reviewer").expect("the second role is registered");
        // The collision resolution, asserted: the key is NOT the bare station word.
        assert!(resolve_role("reviewer").is_none());
        assert!(known_roles().contains("fidelity-reviewer"));
        assert_eq!(
            r.handoff_rel(114),
            ".ai/handoffs/session-114-fidelity-reviewer.md"
        );
        assert_eq!(r.subagent_rel(), ".claude/agents/fidelity-reviewer.md");
        // The contract, not a stub: the three grades, the fakest green, and no self-certification.
        for must in [
            "SHIPPED / PARTIAL / NOT-BUILT",
            "FAKEST GREEN",
            "Never self-certify",
            "PRE-STAGE INPUT",
            "sessions/session-NN-review.md",
        ] {
            assert!(
                r.system_prompt.contains(must),
                "reviewer prompt is missing {must:?}"
            );
        }
    }

    /// S116 — the THIRD role exists, is keyed to avoid the Planner-STATION collision (the same
    /// collision the Reviewer hit at S114, now hit a second time), and carries the `covers: N`
    /// contract the Planner station's own gate parses and grades. Fails if the role is removed,
    /// renamed to `planner`, or hollowed out to a stub prompt.
    #[test]
    fn plan_advisor_is_registered_with_a_non_colliding_key() {
        let r = resolve_role("plan-advisor").expect("the third role is registered");
        // The collision resolution, asserted: the key is NOT the bare station word.
        assert!(resolve_role("planner").is_none());
        assert!(known_roles().contains("plan-advisor"));
        assert_eq!(
            r.handoff_rel(116),
            ".ai/handoffs/session-116-plan-advisor.md"
        );
        assert_eq!(r.subagent_rel(), ".claude/agents/plan-advisor.md");
        // The contract, not a stub: proposes, cites `covers: N`, never authors the plan of record.
        for must in [
            "covers: N",
            "covers: N, M",
            "propose, the author records",
            "no Write or Edit tool",
            "never the plan of record",
        ] {
            assert!(
                r.system_prompt.contains(must),
                "plan-advisor prompt is missing {must:?}"
            );
        }
    }

    /// S114, cold-review finding — the role brief is NOT the only statement of this contract:
    /// `reviewer/SKILL.md` is the canonical 100+ line version, scaffolded into every repo by the
    /// same `vajra init`. Two hand-maintained statements of one job is exactly the drift this
    /// module exists to prevent, and the dangerous half is the OUTPUT SHAPE: a dispatched agent
    /// obeying only the role brief could return a verdict the closeout gate then REJECTS.
    ///
    /// So this test binds them: every token `verify-closeout.sh` requires of a landed review must
    /// appear in BOTH files. It reads the skill off disk on purpose — a change to the canonical
    /// contract that the role brief does not follow turns this red.
    #[test]
    fn the_role_brief_carries_the_output_shape_the_closeout_gate_requires() {
        let skill =
            std::fs::read_to_string(concat!(env!("CARGO_MANIFEST_DIR"), "/reviewer/SKILL.md"))
                .expect("reviewer/SKILL.md is the canonical contract and must exist");
        let brief = resolve_role("fidelity-reviewer").unwrap().system_prompt;

        // The gate counts verdict words ONLY on `|`-delimited rows (`check_fidelity_review`), so a
        // brief that says "a table" without saying which shape sends the agent to write bullets the
        // gate then rejects — cold-review pass 2 wrote exactly that review and watched it BLOCK.
        assert!(
            brief.contains("MARKDOWN TABLE") && brief.contains("`|`-delimited rows"),
            "the role brief does not state the pipe-row table shape the gate actually counts"
        );

        // The three things the gate FAILS a review for missing (verify-closeout.sh).
        for token in [
            "SHIPPED",
            "PARTIAL",
            "NOT-BUILT",
            "**Verdict:**",
            "of N SHIPPED",
        ] {
            // Positive control: the canonical contract really does require it. Without this, a
            // typo'd token would make the assertion below vacuously about nothing.
            assert!(
                skill.contains(token) || skill.contains(&token.replace("of N ", "X of N ")),
                "positive control failed: reviewer/SKILL.md does not mention {token:?} — \
                 fix this test's tokens, do not weaken it"
            );
            assert!(
                brief.contains(token),
                "the role brief omits {token:?}, which the closeout gate requires of the landed \
                 review — a dispatched agent obeying only this brief would produce a REJECTED file"
            );
        }
        // And the brief must point at the canonical contract by name, so it reads as a summary of
        // one source rather than a rival second source.
        assert!(
            brief.contains("reviewer/SKILL.md"),
            "the role brief does not name reviewer/SKILL.md as canonical"
        );
    }

    /// S114, widened at S121 — the tool grant is the ROLE's, not a hardcoded list, and execution is
    /// granted to EXACTLY ONE role. Renamed from `every_role_is_read_only_and_renders_its_own_tools`
    /// because that invariant was deliberately changed at S121, not quietly relaxed: the
    /// `qa-specialist` executes (DECISION-007 S121 addendum) and every OTHER role must stay
    /// read-only. An allowlist of one, asserted by name, so a fifth role cannot inherit Bash by
    /// being added to the table.
    #[test]
    fn tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone() {
        const MAY_EXECUTE: &[&str] = &["qa-specialist"];
        // The grant each role is EXPECTED to hold, written out literally here. S122 pass 3: this
        // used to be `def.contains(&format!("tools: {}", role.tools))` — the render asserted
        // against the field it renders from, the third surviving instance of the same tautology,
        // true for any value including "". Checking a literal expectation is the only shape that
        // can fail; the length check keeps a fifth role from being added with no expectation.
        const EXPECTED_GRANTS: &[(&str, &str)] = &[
            ("researcher", "Read, Grep, Glob, WebSearch, WebFetch"),
            ("fidelity-reviewer", "Read, Grep, Glob"),
            ("plan-advisor", "Read, Grep, Glob"),
            ("qa-specialist", "Bash, Read, Grep, Glob"),
            // S126 — the last five roles, completing the roster to nine. Every one read-only:
            // the roster grew by five and the execution allowlist did not grow at all.
            ("requirements-analyst", "Read, Grep, Glob"),
            ("design-advisor", "Read, Grep, Glob"),
            ("implementation-advisor", "Read, Grep, Glob"),
            ("demo-producer", "Read, Grep, Glob"),
            ("release-coordinator", "Read, Grep, Glob"),
        ];
        assert_eq!(
            EXPECTED_GRANTS.len(),
            ROLES.len(),
            "a role was added to or removed from ROLES without recording its expected tool grant"
        );
        for role in ROLES {
            let def = render_subagent_definition(role);
            let (_, want) = EXPECTED_GRANTS
                .iter()
                .find(|(n, _)| *n == role.name)
                .unwrap_or_else(|| {
                    panic!("no expected tool grant recorded for role {}", role.name)
                });
            assert!(
                def.contains(&format!("tools: {want}")),
                "{} renders `tools: {}` but the recorded grant is `{want}`",
                role.name,
                role.tools
            );
            if MAY_EXECUTE.contains(&role.name) {
                continue;
            }
            // S122: `Task` added. The qa-specialist run found this list had DRIFTED from the two
            // shell guards that police the same invariant — a role granted `Task` (which can spawn
            // other agents, execution by proxy) would have been rejected by both scripts and
            // permitted here. `verify-session-122.sh#execution-policy-one-source` now binds all
            // three lists together so they cannot drift apart again.
            for forbidden in ["Write", "Edit", "Bash", "NotebookEdit", "Task"] {
                assert!(
                    !role.tools.contains(forbidden),
                    "{} grants the write/exec tool {forbidden} — only {MAY_EXECUTE:?} may execute",
                    role.name
                );
            }
        }
        let rev = resolve_role("fidelity-reviewer").unwrap();
        assert_eq!(rev.tools, "Read, Grep, Glob");
        let res = resolve_role("researcher").unwrap();
        assert_ne!(res.tools, rev.tools, "the tool grant must be per-role");
        let plan = resolve_role("plan-advisor").unwrap();
        assert_eq!(plan.tools, "Read, Grep, Glob");
        assert_ne!(res.tools, plan.tools, "the tool grant must be per-role");
        // The exception, pinned exactly — a widened grant elsewhere in the table turns this red.
        // S123: Write/Edit dropped (DECISION-007 S123 addendum, the cheap second layer) — Bash
        // remains the load-bearing grant; the real fence is the clean-room dispatch route.
        let qa = resolve_role("qa-specialist").unwrap();
        assert_eq!(qa.tools, "Bash, Read, Grep, Glob");
        assert!(
            !qa.tools.contains("Write") && !qa.tools.contains("Edit"),
            "S123 dropped Write/Edit from the QA grant — a regrant here silently reopens the \
             tool-call write path the S123 fence closed"
        );
        assert!(
            !qa.tools.contains("WebSearch") && !qa.tools.contains("NotebookEdit"),
            "the QA grant is execution-local, not the Researcher's web grant plus everything"
        );
        assert_eq!(
            ROLES.iter().filter(|r| r.tools.contains("Bash")).count(),
            1,
            "exactly one role may execute"
        );
    }

    /// S121 — the FOURTH role exists, is keyed to avoid the QA-STATION collision (the third time
    /// this collision has been hit: Reviewer S114, Planner S116, QA S121), and carries the
    /// classification contract that is the whole reason it was built. Fails if the role is removed,
    /// renamed to `qa`, hollowed to a stub, or silently de-fanged back to read-only.
    #[test]
    fn qa_specialist_is_registered_with_a_non_colliding_key_and_the_execution_grant() {
        let r = resolve_role("qa-specialist").expect("the fourth role is registered");
        // The collision resolution, asserted: the key is NOT the bare station word.
        assert!(resolve_role("qa").is_none());
        assert!(known_roles().contains("qa-specialist"));
        assert_eq!(
            r.handoff_rel(121),
            ".ai/handoffs/session-121-qa-specialist.md"
        );
        assert_eq!(r.subagent_rel(), ".claude/agents/qa-specialist.md");
        // The grant that makes it a QA agent rather than a fourth reader.
        assert!(r.tools.contains("Bash"));
        // The contract, not a stub: run it, classify every check, name the hollow ones, never fix.
        for must in [
            "RUN the session's `scripts/verify-session-NN.sh`",
            "EXECUTE-BASED",
            "BEHAVIORAL SOURCE GREP",
            "HOLLOW",
            "STRUCTURAL",
            "do NOT repair the checks you criticise",
            "a check that cannot evaluate fails",
        ] {
            assert!(
                r.system_prompt.contains(must),
                "qa-specialist prompt is missing {must:?}"
            );
        }
        // It reports evidence; it does not grade the delivery (that is the Reviewer's role, and
        // the gated record is a file this agent must not write).
        assert!(r.system_prompt.contains("sessions/session-NN-review.md"));
        assert!(r.system_prompt.contains("which you do not write"));
    }

    /// S126 — the LAST FIVE roles complete the roster to nine, and every one of them resolves the
    /// STATION-vs-ROLE collision the same way S114/S116/S121 did: the key is never the station's
    /// own word. `K of 8` counts an **Analyst**, an **Architect**, a **Coder**, a **Demo-er** and a
    /// **Releaser** station; a role keyed with any of those words would make one word mean two
    /// different things in the same report (`DECISION-007` S126 addendum). Asserted by NAME in both
    /// directions — the role resolves, the station word does not.
    #[test]
    fn the_last_five_roles_are_registered_with_non_colliding_keys() {
        // (role key, the station word it must NOT shadow)
        const PAIRS: &[(&str, &[&str])] = &[
            ("requirements-analyst", &["analyst"]),
            ("design-advisor", &["architect"]),
            ("implementation-advisor", &["coder", "developer"]),
            ("demo-producer", &["demoer", "demo-er", "demo"]),
            ("release-coordinator", &["releaser", "release"]),
        ];
        for (key, shadowed) in PAIRS {
            let r = resolve_role(key).unwrap_or_else(|| panic!("{key} is not registered"));
            assert_eq!(r.name, *key);
            assert!(
                known_roles().contains(key),
                "{key} is not listed by known_roles()"
            );
            assert_eq!(r.subagent_rel(), format!(".claude/agents/{key}.md"));
            assert_eq!(
                r.handoff_rel(126),
                format!(".ai/handoffs/session-126-{key}.md")
            );
            for word in *shadowed {
                assert!(
                    resolve_role(word).is_none(),
                    "{word} resolves as a role key — it shadows a station name"
                );
            }
        }
        // The roster is complete AND the execution allowlist did not grow with it: five roles
        // added, zero new grants of Bash. This is the whole S126 governance claim in one line.
        assert_eq!(ROLES.len(), 9);
        assert_eq!(
            ROLES.iter().filter(|r| r.tools.contains("Bash")).count(),
            1,
            "S126 added five roles; exactly one role in the fleet may still execute"
        );
    }

    /// S114 — the rendering is generic: every registered role produces a valid subagent definition
    /// pointing at ITS OWN handoff path and ITS OWN `vajra next --role` command line.
    /// The substance rule, in ONE place (S122, second cold pass). The first cut hand-mirrored
    /// these assertions inside the fixture, so the fixture proved only that *the copy it retyped*
    /// would reject a hollow role — loosen the real test and the "fixture" stayed green. Both the
    /// real per-role test and the fixture now call THIS function, so they cannot drift apart.
    ///
    /// Returns `Err` naming the first failure, so a fixture can assert rejection without
    /// `catch_unwind`.
    fn role_prompt_substance(role: &Role) -> Result<(), String> {
        if role.description.trim().is_empty() {
            return Err(format!("{} has an empty description", role.name));
        }
        let n = role.system_prompt.trim().len();
        if n <= 400 {
            return Err(format!(
                "{} has a stub system prompt ({n} bytes) — a role prompt this short cannot carry \
                 its contract",
                role.name
            ));
        }
        let def = render_subagent_definition(role);
        for required in ["You are the", "Your ONE job", "Rules:"] {
            if !def.contains(required) {
                return Err(format!(
                    "{}'s rendered definition is missing the contract phrase {required:?}",
                    role.name
                ));
            }
        }
        Ok(())
    }

    #[test]
    fn render_subagent_definition_is_correct_for_every_registered_role() {
        for role in ROLES {
            let def = render_subagent_definition(role);
            assert!(def.starts_with("---\n"));
            assert!(def.contains(&format!("name: {}", role.name)));
            // S122 fix 3 — this test used to assert `def.contains(role.system_prompt)` and
            // `def.contains(role.description)`: the RENDER checked against the very field it
            // renders from. Those pass for ANY value of the field, including an empty one
            // (`contains("")` is always true), so a role registered with a blank prompt was
            // "correct". Wiring is now asserted separately from CONTENT: the loop below checks the
            // render carries substantive text this test names literally, and the fields are
            // checked for substance directly.
            // Substance, via the ONE shared rule the fixture below also calls (S122 pass 2).
            if let Err(e) = role_prompt_substance(role) {
                panic!("{e}");
            }
            assert!(def.contains(&format!(".ai/handoffs/session-<NN>-{}.md", role.name)));
            assert!(def.contains(&format!("vajra next --role {} --from", role.name)));
        }
    }

    /// S122 fix 3, the CONTENT half. Each registered role must render a phrase unique to its own
    /// contract — written out literally here, never read back from the `Role` it is checking. A
    /// role whose prompt were emptied, stubbed, or cross-wired to another role's text fails this;
    /// the old `def.contains(role.system_prompt)` assertion could not fail at all.
    ///
    /// The list is exhaustive by construction: a fifth role added to `ROLES` with no entry here
    /// turns this test red, so the check cannot silently stop covering the fleet.
    #[test]
    fn every_role_renders_substantive_content_unique_to_its_own_contract() {
        const EXPECTED: &[(&str, &[&str])] = &[
            (
                "researcher",
                &[
                    "You are the Researcher on a governed software team.",
                    "Do NOT write, edit, or run code. You investigate and report only.",
                ],
            ),
            (
                "fidelity-reviewer",
                &[
                    "You are the Fidelity Reviewer on a governed software team.",
                    "Grade EVERY numbered requirement in the prompt: SHIPPED / PARTIAL / NOT-BUILT",
                    "Name THE FAKEST GREEN",
                ],
            ),
            (
                "plan-advisor",
                &[
                    "You are the Plan Advisor on a governed software team.",
                    "in the exact form `covers: N` or `covers: N, M`",
                ],
            ),
            (
                "qa-specialist",
                &[
                    "You are the QA Specialist on a governed software team.",
                    "BEHAVIORAL SOURCE GREP",
                    "Fixing what you just tested destroys the independence",
                ],
            ),
            (
                "requirements-analyst",
                &[
                    "You are the Requirements Analyst on a governed software team.",
                    "Never propose `Status: APPROVED`",
                ],
            ),
            (
                "design-advisor",
                &[
                    "You are the Design Advisor on a governed software team.",
                    "an invented id is worse than an honest",
                ],
            ),
            (
                "implementation-advisor",
                &[
                    "You are the Implementation Advisor on a governed software team.",
                    "never suggest recording a step as done before its commit exists",
                ],
            ),
            (
                "demo-producer",
                &[
                    "You are the Demo Producer on a governed software team.",
                    "A demo that prints claims is theatre",
                ],
            ),
            (
                "release-coordinator",
                &[
                    "You are the Release Coordinator on a governed software team.",
                    "never report ancestry, sync, or branch state as if you had observed it",
                ],
            ),
        ];
        assert_eq!(
            EXPECTED.len(),
            ROLES.len(),
            "a role was added to or removed from ROLES without updating this content check"
        );
        for role in ROLES {
            let (_, phrases) = EXPECTED
                .iter()
                .find(|(n, _)| *n == role.name)
                .unwrap_or_else(|| panic!("no expected content recorded for role {}", role.name));
            let def = render_subagent_definition(role);
            for phrase in *phrases {
                assert!(
                    def.contains(phrase),
                    "{}'s rendered definition does not carry its own contract text {phrase:?}",
                    role.name
                );
            }
            // ...and it does not carry ANOTHER role's identity line (a cross-wired prompt).
            for (other, other_phrases) in EXPECTED {
                if *other == role.name {
                    continue;
                }
                assert!(
                    !def.contains(other_phrases[0]),
                    "{} renders {other}'s identity line — the prompts are cross-wired",
                    role.name
                );
            }
        }
    }

    /// The falsifiability fixture for fix 3: the OLD assertion shape is shown passing on a role
    /// with an empty prompt, and the NEW shape is shown rejecting it. Without this, "we fixed the
    /// tautology" would itself be an unfalsified claim.
    #[test]
    fn render_test_cannot_pass_on_an_empty_system_prompt() {
        let hollow = Role {
            name: "hollow",
            description: "",
            system_prompt: "",
            tools: "Read, Grep, Glob",
        };
        let def = render_subagent_definition(&hollow);

        // The defect, reproduced: the S121 assertions are GREEN on a role with no contract at all.
        assert!(def.contains(hollow.system_prompt));
        assert!(def.contains(hollow.description));

        // The fix, exercised through the SAME function the real per-role test calls — not a
        // retyped copy of it. Loosen the rule and this fixture goes green with the real test,
        // which is the point: they are one implementation.
        let rejected = role_prompt_substance(&hollow);
        assert!(
            rejected.is_err(),
            "the substance rule accepted a role with an empty prompt and description"
        );
        assert!(rejected.unwrap_err().contains("empty description"));

        // And it rejects a stub that is non-empty but hollow — an empty string is the easy case.
        let stub = Role {
            name: "stub",
            description: "d",
            system_prompt: "You are the Stub. Your ONE job is nothing. Rules:\n- none",
            tools: "Read, Grep, Glob",
        };
        assert!(
            role_prompt_substance(&stub).is_err(),
            "the substance rule accepted a stub prompt carrying every contract phrase"
        );

        // Positive control: every REGISTERED role passes the same rule, so it is not a check that
        // simply rejects everything.
        for role in ROLES {
            assert!(
                role_prompt_substance(role).is_ok(),
                "{} fails the substance rule",
                role.name
            );
        }
    }

    #[test]
    fn format_handoff_carries_the_full_contract_and_validates() {
        let r = resolve_role("researcher").unwrap();
        let delta = compute_delta(r, None, "the findings");
        let h = format_handoff(
            r,
            109,
            "claude-code-subagent",
            "a".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            None,
            "the findings",
            &delta,
        );
        assert!(h.contains("role: researcher"));
        assert!(h.contains("session: 109"));
        assert!(h.contains("agent: claude-code-subagent"));
        assert!(h.contains("source-sha: aaaa"));
        assert!(h.contains("captured: 2026-08-02T00:00:00Z"));
        assert!(h.contains("cost_usd: null"));
        assert!(h.contains("# Researcher handoff — session 109"));
        assert!(h.contains("the findings"));
        assert!(h.contains("## Handoff Delta"));
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn format_handoff_renders_known_cost() {
        let r = resolve_role("researcher").unwrap();
        let h = format_handoff(
            r,
            5,
            "claude-code-subagent",
            "b".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            Some(0.0031),
            "body",
            "- `+` new",
        );
        assert!(h.contains("cost_usd: 0.003100"));
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn validate_handoff_fails_closed_on_each_missing_piece() {
        let r = resolve_role("researcher").unwrap();
        let good = format_handoff(
            r,
            109,
            "claude-code-subagent",
            "c".repeat(64).as_str(),
            "t",
            Some(0.1),
            "real body",
            "- `+` new",
        );
        assert!(validate_handoff(&good).is_ok());

        // Missing a frontmatter key (drop the `agent:` line).
        let no_agent = good
            .lines()
            .filter(|l| !l.trim_start().starts_with("agent:"))
            .collect::<Vec<_>>()
            .join("\n");
        assert!(validate_handoff(&no_agent).is_err());

        // Missing the delta section.
        let no_delta = good.replace("## Handoff Delta", "## Something Else");
        assert!(validate_handoff(&no_delta).is_err());

        // Empty body (frontmatter + delta only, heading but no findings).
        let empty_body = "---\nrole: researcher\nsession: 109\nagent: claude-code-subagent\n\
             source-sha: cccc\ncaptured: t\ncost_usd: 0.1\n---\n\n\
             # Researcher handoff — session 109\n\n## Handoff Delta\n- `+` new\n";
        assert!(validate_handoff(empty_body).is_err());

        // Not a handoff at all.
        assert!(validate_handoff("just some notes").is_err());
    }

    #[test]
    fn sha256_hex_is_deterministic_64_hex() {
        let a = sha256_hex(b"hello").expect("sha available");
        let b = sha256_hex(b"hello").unwrap();
        assert_eq!(a, b);
        assert_eq!(a.len(), 64);
        assert!(a.chars().all(|c| c.is_ascii_hexdigit()));
        assert_eq!(
            a,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        );
    }

    // ---- S112: the read side ------------------------------------------------------------

    /// A contract-valid handoff, written where `read_handoff` will look for it.
    fn write_handoff(root: &std::path::Path, session: u32, body: &str) -> String {
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            session,
            "claude-code-subagent",
            &"d".repeat(64),
            "2026-08-04T00:00:00Z",
            None,
            body,
            &compute_delta(r, None, body),
        );
        let rel = r.handoff_rel(session);
        let path = root.join(&rel);
        std::fs::create_dir_all(path.parent().unwrap()).unwrap();
        std::fs::write(&path, &text).unwrap();
        text
    }

    #[test]
    fn parse_handoff_round_trips_what_format_handoff_wrote() {
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            112,
            "claude-code-subagent",
            &"e".repeat(64),
            "2026-08-04T00:00:00Z",
            Some(0.25),
            "line one\nline two",
            "- `+` new",
        );
        let h = parse_handoff(&text, 112, ".ai/handoffs/session-112-researcher.md").unwrap();
        assert_eq!(h.role, "researcher");
        assert_eq!(h.session, 112);
        assert_eq!(h.agent, "claude-code-subagent");
        assert_eq!(h.captured, "2026-08-04T00:00:00Z");
        assert_eq!(h.source_sha, "e".repeat(64));
        assert_eq!(h.head_lines(1), vec!["line one".to_string()]);
        assert_eq!(h.head_lines(9), vec!["line one", "line two"]);
    }

    #[test]
    fn parse_handoff_trusts_the_path_not_a_self_declared_session() {
        // Frontmatter claims session 999; it was found at session 112's path. The path wins —
        // a misfiled handoff must not be able to claim a session it is not in.
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            999,
            "a",
            &"f".repeat(64),
            "t",
            None,
            "findings",
            "- `+` new",
        );
        let h = parse_handoff(&text, 112, ".ai/handoffs/session-112-researcher.md").unwrap();
        assert_eq!(h.session, 112);
    }

    /// A file whose contract keys live in the BODY rather than the frontmatter block passes
    /// `validate_handoff` (it scans every line) but must NOT parse into a `Handoff` with blank
    /// fields — that would render as "(agent: , captured: )" and read as a good artifact.
    #[test]
    fn parse_handoff_fails_closed_when_a_key_is_not_in_the_frontmatter_block() {
        let text = "---\nrole: researcher\nsession: 1\nsource-sha: x\ncaptured: t\n\
             cost_usd: null\n---\n\n# H\n\nagent: down-here-not-in-frontmatter\n\n\
             ## Handoff Delta\n- d\n";
        // The legacy contract check passes — every key appears SOMEWHERE.
        assert!(validate_handoff(text).is_ok());
        // The reader does not: `agent:` is not in the frontmatter block.
        let err = parse_handoff(text, 1, "p").unwrap_err();
        assert!(err.contains("agent:"), "got: {err}");
    }

    #[test]
    fn head_lines_truncation_is_disclosed_not_silent() {
        let tmp = tempfile::tempdir().unwrap();
        write_handoff(tmp.path(), 112, "l1\nl2\nl3\nl4\nl5");
        let out = format_handoff_brief(&read_handoffs(tmp.path(), 112), 2);
        assert!(out.contains("l1"));
        assert!(out.contains("l2"));
        assert!(!out.contains("l5"));
        // The reader is TOLD what was left out, and where the rest lives.
        assert!(out.contains("3 more line(s)"), "got: {out}");
        assert!(out.contains(".ai/handoffs/session-112-researcher.md"));

        // Nothing omitted -> no "more lines" noise.
        let full = format_handoff_brief(&read_handoffs(tmp.path(), 112), 99);
        assert!(!full.contains("more line(s)"));
    }

    #[test]
    fn frontmatter_value_ignores_a_body_line_that_looks_like_a_key() {
        let text = "---\nrole: researcher\nsession: 1\nagent: real-agent\nsource-sha: x\n\
             captured: t\ncost_usd: null\n---\n\n# H\n\nagent: impostor\n\n## Handoff Delta\n- d\n";
        let h = parse_handoff(text, 1, "p").unwrap();
        assert_eq!(h.agent, "real-agent");
    }

    #[test]
    fn read_handoff_absent_found_and_malformed() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        let r = resolve_role("researcher").unwrap();

        // Absent — the silent, harmless case every no-fleet session must hit.
        assert_eq!(read_handoff(root, r, 112), HandoffRead::Absent);
        assert!(read_handoffs(root, 112).is_empty());

        // Found.
        write_handoff(root, 112, "the finding that matters");
        match read_handoff(root, r, 112) {
            HandoffRead::Found(h) => {
                assert_eq!(h.role, "researcher");
                assert_eq!(h.path, ".ai/handoffs/session-112-researcher.md");
                assert!(h.body.contains("the finding that matters"));
            }
            other => panic!("expected Found, got {other:?}"),
        }
        assert_eq!(read_handoffs(root, 112).len(), 1);

        // Malformed — present but off-contract. NOT silent: it must name why.
        std::fs::write(
            root.join(r.handoff_rel(112)),
            "not a handoff at all, just notes\n",
        )
        .unwrap();
        match read_handoff(root, r, 112) {
            HandoffRead::Malformed(path, reason) => {
                assert!(path.ends_with("session-112-researcher.md"));
                assert!(!reason.is_empty());
            }
            other => panic!("expected Malformed, got {other:?}"),
        }
    }

    #[test]
    fn format_handoff_brief_inlines_findings_and_is_empty_when_absent() {
        // Absence renders NOTHING — a session with no fleet work looks exactly as it did before.
        assert_eq!(format_handoff_brief(&[], 3), "");
        assert_eq!(format_handoff_brief(&[HandoffRead::Absent], 3), "");

        let tmp = tempfile::tempdir().unwrap();
        write_handoff(
            tmp.path(),
            112,
            "first finding\nsecond finding\nthird finding",
        );
        let out = format_handoff_brief(&read_handoffs(tmp.path(), 112), 2);
        assert!(out.contains("researcher"));
        assert!(out.contains("claude-code-subagent"));
        assert!(out.contains(".ai/handoffs/session-112-researcher.md"));
        // The findings are INLINE, not just pointed at — and clipped to `head`.
        assert!(out.contains("first finding"));
        assert!(out.contains("second finding"));
        assert!(!out.contains("third finding"));

        // A malformed handoff is surfaced, never swallowed.
        let bad = HandoffRead::Malformed("p.md".into(), "missing frontmatter key `role:`".into());
        let out = format_handoff_brief(&[bad], 2);
        assert!(out.contains("p.md"));
        assert!(out.contains("not used"));
    }
}
