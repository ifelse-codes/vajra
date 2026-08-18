# Session 122 — CODE: prove the QA Specialist dispatches, and take its first LIVE run

> **Status:** APPROVED (founder pick A at the S121 closeout — "run it for real").
> Written at S121 closeout per `end_of_session.must_write_next_prompt_before_close`.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**.
> Do NOT soften them. No release until reality meets them.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap, new chat.
Branch: `session-122-qa-specialist-dispatch`.

## Goal
S121 shipped the fleet's fourth role, the QA Specialist (`qa-specialist`) — the first granted
`Bash, Read, Write, Edit, Grep, Glob` — as a scaffolded `.claude/agents/qa-specialist.md` and a
governed `vajra next --role qa-specialist --from` path. Per the S111 limit it was never dispatched:
an agent file written mid-session is invisible to that same session's Task tool. This is a **fresh
session**, so the S121 commit is already on `main` and the mechanism proven at S115 (Reviewer) and
S117 (Plan Advisor) should hold.

Two things must come out of this session, and the second is the one that matters:
1. **Dispatch proof** — the same rigorous, non-copyable evidence used at S111/S115/S117.
2. **The first live QA run.** S121's central claim is that *an executor cannot fake a pass*. That
   claim is untested. Hand the agent a REAL verify script and find out whether an agent that can
   run things produces evidence a reader could not have produced.

## Plan (ordered — cite the acceptance criteria each step covers)
1. Inside this live session, dispatch `subagent_type: "qa-specialist"` by name and give it a REAL
   target: run `scripts/verify-session-121.sh` (or another named session's script) and report the
   real exit code, the check-by-check result, and its classification of every check. Record plainly
   whether the dispatch resolved on the FIRST try or needed a workaround. `covers: 1`
2. Capture independent, non-copyable evidence the dispatch was real and by-name: the parent
   session's own tool-call record naming `subagent_type: "qa-specialist"`, cross-checked against the
   subagent's own transcript/meta (matching `toolUseId`), mirroring S111/S117. Count the
   `subagent_type:"qa-specialist"` occurrences in the REAL parent transcript — exactly 1 means no
   hidden retry (the S117 finding: a magic-phrase grep against a file this session wrote is not
   evidence). `covers: 1, 2`
3. **Grade the run against the thing S121 could not test.** Compare the agent's classification
   against the script's own self-assigned labels (13 execute-based · 3 structural · 1 behavioral).
   Record: did the executor find anything a reader could not have? Did it disagree with any label?
   Did it actually run the suite (real exit code + real output), or narrate reading it? A flat,
   agreeable report is a REAL and reportable finding — write it down as a finding, never soften it
   into a success. `covers: 3`
4. Govern the agent's brief into `.ai/handoffs/session-122-qa-specialist.md` via the unchanged
   `vajra next --role qa-specialist --from` path, and confirm `vajra next --stations 122` reports it
   beside `K of 8` with `K` unchanged. `covers: 2, 4`
5. `scripts/verify-session-122.sh` — classify every check the S121 way and print the tally. Include
   a check that binds the dispatch evidence (two independently-written files, matching ids), and
   re-run the role-count-agnostic regressions (`fleet-smoke.sh`, `verify-session-113.sh`). Confirm
   `cargo test --lib`, fmt, clippy green. `covers: 5`
6. Cold `fidelity-reviewer` pass by name (prompt + diff only); session summary with the
   per-requirement fidelity map + the fakest green. `covers: 6`

## Acceptance criteria
1. A real `subagent_type: "qa-specialist"` dispatch resolved BY NAME inside this fresh session, with
   it recorded plainly whether it worked first try or needed a workaround.
2. Independent, non-copyable dispatch evidence (matching ids across two independently-written
   files), plus an occurrence count in the real parent transcript — not merely a handoff file.
3. **The live-run finding, recorded honestly:** what the executing agent produced that a read-only
   agent could not, or the plain statement that it produced nothing extra.
4. The brief governed into `.ai/handoffs/session-122-qa-specialist.md`; `vajra next --stations 122`
   reports it beside an unchanged `K of 8`.
5. `verify-session-122.sh` exits 0, with its own check-class tally printed.
6. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark — the S119 defect S120 filed.

## Design
- design-significant: **no** — no new interface, no new module. This session exercises an existing
  mechanism on the fourth role. Record a `DECISION-007` addendum ONLY if the result differs from
  S115/S117 (e.g. the executing grant changes dispatch behaviour), or if the live run shows the
  executor thesis to be weaker than S121 claimed — either would be load-bearing, not absorbable.

## Non-goals (not built this session)
- A fifth role, parallel dispatch, or multi-stage orchestration (`DECISION-007` still defers this).
- Making the check-class tally machine-derived (option B at the S121 close — a separate session).
- Fixing the `no-eighth-command` weak check (option C at the S121 close).
- No 8th top-level command. Rides `init` + `next`, like roles 1–4.
- No blocking gate: nothing new fails a session.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Approval token required before any commit (`VAJRA_ALLOW_COMMIT=122 git commit …`).
- **The agent must not repair what it tests.** If it edits source or fixes a check, that is a
  finding about the grant being broader than the rule (the S121 residual risk) — record it.
- **`vajra init` blocks forever on stdin without EOF** (found live at S121). Any script calling it
  must redirect `</dev/null`.
- **Attest LAST**: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) — compute strictly after the
  `## Execution` shas are committed; two consecutive `verify-closeout.sh --inputs-sha 122` runs must
  agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**, and the canonical
  `**Verdict:** ACCEPT` must be its own bare line, never inside a table cell.
