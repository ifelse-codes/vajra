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
