# Session 126 — CODE: finish the SDLC agent fleet (the last five roles, one pass)

> **Founder pick C at the S125 closeout**, over A (Architect only) and B (Developer only).
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *complete the fleet
roster.* Commits need the un-forgeable marker — `VAJRA_ALLOW_COMMIT=126 git commit …`.

## Why this session

The fleet has **four** named roles (`researcher`, `fidelity-reviewer`, `plan-advisor`,
`qa-specialist`). **Five of the eight stations still have no role at all:** Analyst · Architect ·
Coder · Demo-er · Releaser. The founder's gate for unparking the S125 reboot backlog is *"the SDLC
agent fleet is done AND working."* This session closes the **done** half — the whole roster, in one
pass, rather than one role per session for five more sessions.

That one-pass shape is affordable **because it has been proven three times**: S114, S116 and S121
each added a role and each traced that `vajra init`, `vajra next`, and the S113 counter needed
**zero code changes** to pick it up. One `fleet::ROLES` entry is the unit of work. This session
tests that claim at n=5 instead of n=1.

**Carry the S125 finding into the work, do not re-litigate it.** S125 established that the four
existing roles are never reached for on real work, because the shipped scaffold never asks and **no
gate consumes a handoff** — a role nothing depends on is decoration. Five more roles inherit that.
This session is scoped to **done**, not **working**; the *working* half (S116's own unpicked
candidate C — wire handoffs into a blocking gate — and S125's F2 dispatch receipt) is S127's
subject and must be named as the honest residual, never quietly claimed here.

## Goal

Register the five missing roles in `src/fleet/mod.rs::ROLES` with distinct keys, correct tool
grants, and real system prompts; prove each one is **dispatchable by name** from a fresh session;
record the decision in a `DECISION-007` S126 addendum. Change **no** other machinery — and prove
that, don't assert it.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Name the five keys, resolving the STATION-vs-ROLE collision for each.** The house rule is
   settled three times over (`fidelity-reviewer` ≠ Reviewer station; `plan-advisor` ≠ Planner
   station; `qa-specialist` ≠ QA station). Pick a distinct key per role and write down the rejected
   alternative for each. A key that shadows a station name is a REJECT condition, not a nit.
   `covers: 1`
2. **Write each role's system prompt against a marker the corresponding station's gate already
   parses** — the S116 contract shape. The Architect role cites the `## Design` /
   `design-significant:` marker `src/architect/mod.rs` reads; the Coder role cites the
   `step N — done: <sha>` marker `src/coder/mod.rs` existence-gates; and so on. **Every role
   proposes; none authors the recorded marker section.** `covers: 2`
3. **Set each tool grant deliberately, defaulting to read-only.** `Read, Grep, Glob` unless there is
   a written reason otherwise. **The Coder role is the one real decision here** — see `## Design`.
   `covers: 3`
4. **Prove no other machinery changed.** `vajra init` scaffolds nine agent files, `vajra next --role
   <each>` governs a handoff, the S113 counter still reads the same `K of 8`. Trace it in the diff —
   the S116 precedent is a traced claim, not an asserted one. `covers: 4`
5. **Dispatch each of the five by name from a FRESH session** and cross-verify with the S111
   two-file check (parent tool-call ID == subagent `meta.json` `toolUseId`). Remember the S111
   limit: a role file written mid-conversation is invisible to that conversation. `covers: 5`
6. **Write the `DECISION-007` S126 addendum**: the five keys, each rejected alternative, the Coder
   grant rationale, and the residual risk — stated, not softened. `covers: 6`
7. **`scripts/verify-session-126.sh` + `scripts/demo-session-126.sh`**, both exit 0, with the
   check-class tally. Every new check must be **execute-based or honestly labelled** — no
   behavioral source greps smuggled in as `exec` (S121/S123 lesson). `covers: 7`
8. **Independent cold `fidelity-reviewer` pass** fed only the prompt + the diff. Expect a REJECT;
   every rejection so far has been correct. `covers: 8`
9. **State the residual plainly in the session summary and the closeout record** — the roster is
   complete AND nothing depends on it; "done" is claimed, "working" is not. `covers: 9`

> **Added in-session (S126), disclosed not silent:** the Planner station's own gate reported
> `plan misses criteria 9` against this prompt as written — criterion 9 had no plan step citing
> it. Step 9 closes that gap; it adds no scope, since criterion 9 was always a required output of
> the session. The pipeline surfaced the hole in its own brief, which is the gate working.

## Acceptance criteria

1. Five roles registered in `fleet::ROLES` with distinct keys; each collision resolved in writing
   with its rejected alternative named.
2. Each role's system prompt cites the exact marker its station's gate already parses, and states
   that the role proposes rather than authors.
3. Tool grants set per role, read-only by default; any non-read-only grant carries a written
   rationale in the addendum.
4. **Traced, not asserted:** `vajra init` scaffolds all nine role files, `vajra next --role <name>`
   governs a handoff for each, and `vajra next --stations NN` reports an unchanged `K of 8`.
5. All five proven **dispatched by name** from a fresh session, each with the S111 two-file
   cross-check.
6. `DECISION-007` S126 addendum recorded, including the residual risk.
7. `verify-session-126.sh` and `demo-session-126.sh` both exit 0, with a printed check-class tally.
8. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
9. **The residual is stated plainly in the summary, never softened:** the roster is *complete*, and
   still *nothing depends on it* — no gate consumes a handoff. "Done" is claimed; "working" is not.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: `d1b4ac8`
- step 2 — done: `d1b4ac8`
- step 3 — done: `d1b4ac8`
- step 4 — done: `35fbd59`
- step 5 — done: `4d795e5`
- step 6 — done: `e754aba`
- step 7 — done: `980112f`
- step 8 — done: `<sha>`
- step 9 — done: `<sha>`

> **Fill these with real landing shas before closeout.** S119, S122 and S124 each left `<sha>`
> placeholders and only an independent cold review caught it — never self-noticed.

## Design

- design-significant: **yes** — step 3 is a real fork: **does the Coder role get `Write`/`Edit`?**
  S123 spent a whole session *narrowing* the only executing role's grant to `Bash, Read, Grep,
  Glob`, and the S122 `DECISION-007` addendum **retracted the executor thesis** (two live QA runs,
  seven real defects, every one found by independent *reading*). Granting the Coder role
  `Write`/`Edit` would reverse both in the same session that ships it.
- **Spine record cited:** `docs/decisions/DECISION-007-agent-fleet.md` (exists — the S114/S116/
  S121/S122/S123 addenda live there). This session appends an S126 addendum; it does not create a
  new decision record.
- **Recommended resolution, to be argued in the addendum, not assumed:** register the Coder role
  **read-only** (it proposes the change and cites the marker; the human or the governed session
  applies it), and record "grant the Coder role write access" as a separate, founder-gated decision.
  A deviation needs an explicit founder approval in chat.

## Non-goals (not built this session)

- **Not the "working" half.** No blocking gate on handoffs, no dispatch receipt, no change to what
  any station consumes. That is S127 (S116's unpicked candidate C + S125's F2).
- **No S125 reboot-backlog items** (F1–F5, K1–K4, A1) — parked by founder call until the fleet is
  done AND working.
- **No 8th top-level command.** The fleet rides `vajra init` + `vajra next`.
- No release, no crates.io action (founder directive).
- Not fixing the carried 🔴/🟡 items in `STATE.md` — record, don't repair.

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** five named fleet roles (Analyst · Architect · Coder · Demo-er · Releaser), completing
  the roster to nine; a `DECISION-007` S126 addendum.
- **MODIFIED:** the fleet's status line everywhere — "four roles" becomes "nine"; the S125 caveat
  gains n=5 of evidence either way.
- **UNCHANGED:** the 8 stations, the 7 commands, `K of 8`, every gate's evidence contract, and —
  stated deliberately — the fact that no gate depends on any role.

## Guardrails

- **`VAJRA_ALLOW_COMMIT=126`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **A key that shadows a station name is a REJECT**, not a nit. Three precedents.
- **Do not grant `Write`/`Edit` to any role without an explicit founder "yes" in chat** — it
  reverses S123 and the S122 executor-thesis retraction.
- **A dispatched agent's own report is not evidence.** Cross-verify every dispatch with the S111
  two-file check (S124 caught a fabricated citation exactly here).
- **Do not fix findings after the ACCEPT.** File them into the S127 prompt.
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land;
  confirm two consecutive `verify-closeout.sh --inputs-sha 126` runs agree before embedding.
- **Nine roles that nothing depends on is still nine decorations.** If the session finds itself
  arguing that the roster's completeness proves the fleet works, stop — that is the exact claim
  criterion 9 forbids.
