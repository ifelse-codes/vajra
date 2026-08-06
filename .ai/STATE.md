# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S113 complete, S114 not yet started).** S113 shipped on
`session-113-fleet-counter-visibility` (13 atomic commits), **merged via
[#120](https://github.com/ifelse-codes/vajra/pull/120)** with CI green on both OS, branch deleted,
local `main` synced and pruned. S113 = **CODE: make fleet work visible to the counter, then choose the second role**
(founder pick **A** at the S112 closeout; "all approved" at kickoff). **Verdict: SHIPPED.**

The counter could not see the fleet at all: a session that dispatched a named agent, governed its
findings and consumed them downstream scored exactly the same `K of 8` as one that did none of it
(flagged at S110 GT, carried unfixed through S111 and S112 — three sessions of "flagged, not fixed").
S113 reports fleet evidence **BESIDE** K — design shape **(c)**, picked at kickoff and recorded in
the prompt's `## Design`:

- `stations::FleetEvidence` + `fleet_evidence()` + `format_fleet_line()`, built from
  `fleet::read_handoffs` — the handoff is **parsed and validated off disk**, never a typed marker.
- **A malformed handoff is NAMED and counts as nothing** (`⚠ fleet: … — not counted`); **absence
  prints nothing at all**, so a session with no fleet work is byte-identical to pre-S113 output.
- **K-of-8 is UNCHANGED in meaning, and that is CHECKED, not claimed:** verify strips the fleet line
  and requires byte-equality with the pre-handoff report, and a test asserts K is invariant under
  *any* fleet evidence (the `>= 2` hole a cold reviewer named — two handoffs is the normal state once
  the chosen second role exists). Rejected: a 9th station (breaks the spine every past K rests on)
  and folding it into a station's verdict (old and new K would look identical while measuring
  different things).
- **The second fleet role is CHOSEN, not built: the Reviewer** (`DECISION-007` S113 addendum) — 46
  `sessions/*-review.md` on disk, mandated by DECISION-002's no-self-certification rule, prompt
  hand-typed every session today, output already gated + attested + ledgered, read-only tools only.
  Four alternatives rejected with reasons; a name collision with the Reviewer STATION recorded for
  the build session to resolve explicitly.

**317 lib tests; verify 14/14; demo 7/7 exit 0; two independent cold passes, both ACCEPT, attested
`d478a022…`.** Reports: `sessions/session-113-summary.md` + `sessions/session-113-review.md`.

**Two-pass cold review earned its keep for the third session running.** Pass 1 found the "role not
built" guard used `grep -E '\s'` — BSD/macOS grep reads that as a literal `s`, so an indented
reviewer role would NOT have matched and the guard would have said "not built" while one existed;
also that the byte-identity check ran in a repo where every station sat at its floor (a vacuous
comparison), a bare `grep -v fleet:` substring filter, a tautological assert, and a demo label
claiming the counter proved a by-name dispatch. A **fresh** pass 2 then found its own sharper hole:
every check wrote at most ONE handoff, so a station that began passing on `governed.len() >= 2` would
have kept the whole suite green. All fixed in-session.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 first slice
✓, S111 dispatch wire ✓, S112 consumption loop ✓, S113 counter-visibility + second role chosen ✓.**

## Active PRs
- None open. **S113 [#120](https://github.com/ifelse-codes/vajra/pull/120) MERGED** 2026-08-06,
  **CI green on both OS** (macOS + Ubuntu) — which retires the delivery's one PARTIAL. Remote branch
  deleted, local `main` synced and pruned (the S37 return-to-main step). `vajra next --stations 113`
  = **8 of 8** (the Releaser and Reviewer turned green on merge).
- **S112 [#118](https://github.com/ifelse-codes/vajra/pull/118) MERGED** 2026-08-04 (CI green both OS)
  + closeout [#119](https://github.com/ifelse-codes/vajra/pull/119); **S111 [#117](https://github.com/ifelse-codes/vajra/pull/117) MERGED** 2026-08-03.
- Prior merges: S109 #115 · S110 closeout #116 · **S108 #113** + S108-follow-up #114 · S107 #112 ·
  S106 #111 · S105-follow-up #110 · S105 #109 · S104 #108.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). The fleet = **real named agents behind the existing gates** (`DECISION-007`), now
  wired end-to-end **and consumed** (S109 write → S111 dispatch proof → S112 read).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106+S107+S108) ✓ COMPLETE,
  confirmed stranger-shippable at S110 GT** → **A fleet (S109 ✓ + S111 ✓ + S112 ✓ — next: fleet credit
  in the K-of-8 counter, a second role, or an opt-in blocking gate).** Release when v0.1 is
  stranger-shippable (it is); the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT, live-checked).** README carries no
  "NOT YET PUBLISHED" rows; all 4 channels real: `cargo install --git|--path` (S106) · prebuilt
  `v0.1.0` release binary, no Rust (S107) · `cargo install vajractl` from crates.io (S108) ·
  `brew install ifelse-codes/tap/vajra` (S108). `install-smoke.sh` = 5 modes, all fail-closed.
- **The fleet's first named agent — write, dispatch, AND read (S109 + S111 + S112):** `vajra init`
  scaffolds `.claude/agents/researcher.md` from the canonical `fleet::ROLES` (one source, no drift);
  a **fresh** Claude Code session's Task tool resolves `subagent_type: "researcher"` against that file
  **by name** (confirmed on disk via cross-referenced tool-call IDs); `vajra next --role researcher
  --from <findings>` governs the brief into a delta-tracked, validated handoff in `.ai/handoffs/`
  (fail-closed on unknown role / missing `--from` / empty findings); and **the pipeline now READS it
  back automatically** — the boot packet, the Analyst intake and the Analyst gate each surface the
  session's findings inline, silent when absent, naming an off-contract file rather than swallowing
  it. Real standing finding: a file scaffolded mid-session is invisible to that SAME session's Task
  tool (Claude Code snapshots `.claude/agents/*.md` at boot only) — the wire needs a fresh session,
  which is also exactly how a real Vajra user experiences it.
- **The counter can finally SEE the fleet (S113):** `vajra next --stations NN` prints
  `fleet: N governed handoff(s) — <roles>` **beside** `K of 8`, derived from the validated handoff
  on disk; malformed is named and never counted; absence is silent. **K's definition is untouched**,
  so every past K reading stays comparable. Read the claim narrowly: it certifies *a contract-valid
  handoff exists*, NOT *an agent was dispatched* — anyone can hand-type findings and run the writer.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner · Coder ·
  QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt AUTHORITATIVE
  when `total_cost_usd` exists, HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`),
  live-reconfirmed at S110 GT.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (the fleet rides `init` + `next`).

## What Is Broken / Weak
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now 10
  sessions / ~10 calendar days. S111's scratch-repo dispatch and S112's tempdir e2e are mechanism
  TESTS, not governed dogfood runs — neither resets this. Overdue; a candidate for S114 (option B).
- **🟡 Fleet consumption + fleet evidence are ADVISORY, never blocking.** Nothing fails when a session ignores (or never
  reads) a governed handoff. Deliberate this session; an opt-in "this session requires a handoff"
  gate is the obvious next step, and equally the obvious way to build false teeth.
- ~~🟡 The K-of-8 counter has no unit for fleet work~~ — **RETIRED S113.** Fleet work is now
  reported beside K (not inside it), derived from the validated handoff. **Residual 🟡: the line
  counts ARTIFACTS, not agents** — a contract-valid handoff proves a file, never a dispatch; and it
  does not prove any station *read* it ("governed" ≠ "used").
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007). The S109 handoff
  itself researched how: **`ANTHROPIC_API_KEY`** is the only auth that survives a fresh, no-TTY,
  no-keychain shell; `claude setup-token` is the subscription alternative; interactive OAuth won't do.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111 and S112 both) — an
  8th command whose author skipped the help text would pass. The non-goal holds structurally; the
  *check* does not enforce it. House-wide, named at S112, not fixed unilaterally.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): 482 lines but 242KB (lines up to 6.7KB each) —
  prune still queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale" (10/11,
  live-confirmed at S110 GT); no CLOSEOUT gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** (recurse subdirs) · **🟡 brew
  smoke tests a LOCAL formula copy** (S108) · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $ on sonnet/opus.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.
- ~~🟡 CI-both-OS not evidenced for S112~~ — **RESOLVED post-merge:** #118 ran green on macOS and
  Ubuntu before merging, retiring the delivery's one PARTIAL. The structural point stands for every
  future session: CI runs on the PR, so a pre-merge delivery can never evidence it.

## What Is In Progress
- **S113 DONE + MERGED (CODE; SHIPPED; 317 lib tests; verify 14/14; demo 7/7 exit 0; two cold passes,
  both ACCEPT, attested `c2cac3e0…`; CI green both OS; PR #120).** `vajra next --stations 113` =
  **8 of 8**.
  Reports: `sessions/session-113-summary.md` + `sessions/session-113-review.md`.
- **Next = S114 — CODE: build the second fleet role, the Reviewer** (founder pick **A**). Prompt:
  `prompts/114-task-fleet-role-reviewer.md`. Deferred: the paid dogfood (B) and an opt-in blocking
  consumption gate (C). **New chat.** (S115 = the next NO-CODE GT.)

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each** (S109's subagent tokens roll into the
  interactive session receipt, unitemized — `cost_usd: null`, disclosed).
- **S110: $0 (NO-CODE GT — no paid calls).**
- **S111: real but UNKNOWN in-chat** (interactive build session; the founder's own fresh-session
  dispatch test was a separate small paid call, cost in that scratch session's own receipt).
- **S112: $0 metered for the build; two cold-review subagent passes (~161k subagent tokens) roll into
  this interactive session's receipt, unitemized** — same structural reason as S109/S111
  (`scripts/check-subagent-cost-fields.sh`: no local subagent transcript carries a cost field).
- **S113: $0 metered for the build; two cold-review subagent passes (~151k subagent tokens) roll into
  this interactive session's receipt, unitemized** — same structural reason as S109/S111/S112.
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111/S112/S113 (unknown, small).**
