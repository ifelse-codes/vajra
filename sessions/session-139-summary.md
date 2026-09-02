# Session 139 — make "required" bind at CLOSE: `check_required_crew` in `verify-closeout.sh`

**Type:** CODE (shell-gate wiring + fixture + scripts — 0 lines of Rust). **Next GT: S140.**

## What shipped

The S135 crew gate (`vajra next --check-crew N`) already checks "a real, provenance-verified tech-lead
handoff exists, and every role it marked `required` produced its own governed handoff." But that
binding lived ONLY in `vajra next --advance`, which a real close never invokes. The S138 dogfood proved
the hole live: its tech-lead marked FOUR roles required, the session ran ONE, self-certified the rest,
and closed **12/12 green + merged to main** with nothing catching the skip.

S139 wires a **`check_required_crew`** gate into `scripts/verify-closeout.sh` — the artifact `CLAUDE.md`
declares the close depends on — so the crew binding now runs at every close, not only at `--advance`:

- Runs the real binary `vajra next --check-crew N`, **requires the gate's own header**
  (`=== crew: tech-lead for session`) so an unknown flag routed to `run_dump` (exit 0) cannot green it,
  **fails closed** when the binary is absent, and honors the founder-held `VAJRA_CLOSEOUT_WAIVER=N` —
  identical to the sibling `check_obeyed_judgments` / `check_design_advisor_mandate`.
- Wired into `main()`'s check list (between the design-advisor mandate and the attestation) with a
  focused `--crew-only [N]` entry point mirroring `--attest-only`.
- Propagates to every adopter verbatim: `verify-closeout.sh` is embedded by `include_str!`, so the one
  edit reaches a fresh `vajra init` project (the byte-identity test proves it — acc 4).

**One correctness fix beyond the mirror (design-advisor rec 4):** the bare `out="$(cmd)"; code=$?`
capture that all three binary-backed checks used **aborts the whole script under `set -euo pipefail`**
the instant the binary exits non-zero (a command-substitution assignment is a simple command) — so a
BLOCKING verdict would kill the run before its FAIL reason and the summary print. The two siblings never
hit it because `--check-obeyed` / `--check-design-handoff` exit 0 in a normal close; this crew gate is
the **first whose blocking path is exercised in practice**, which surfaced the latent bug. All three now
use the set -e-safe `out="$(...)" && code=0 || code=$?` list form — hardening, not weakening.

## The self-bind (acceptance 3 — the whole point)

Building a gate no session runs is this repo's oldest failure (S125 "a role no gate consumes is
decoration"; S129 "a registered gate nobody executes is not a gate"). So S139 binds on **itself**: it
dispatched its tech-lead FIRST, which marked three roles `required` (design-advisor,
implementation-advisor, fidelity-reviewer) and six `deferred-budget` with arithmetic; all three required
roles produced real, provenance-verified handoffs; and **S139's own `verify-closeout.sh` passes
`check_required_crew`** (`--crew-only 139` → CREW: PASS). The falsifiability fixture proves the teeth:
hide any one required handoff and the close goes RED naming that exact role; restore it and it greens.

## Advisor recommendations — the dispositions, answered

**tech-lead (rec 1–5, process).** rec 1 — exactly three specialist dispatches ran (design-advisor ·
implementation-advisor · fidelity-reviewer) plus the tech-lead itself, the S135 affordable-envelope
shape. rec 2 — every brief was named-files-only; the four dispatches came in at **~46K / ~94K / ~52K /
(fidelity, see below) subagent tokens** — tens of thousands, not the millions a repo-read costs. rec 3
— all six `deferred-budget` lines carry money arithmetic, none a worth call (phase 1 has no off switch).
rec 4 — the **implementation-advisor**, not the design-advisor, judged the `obeyed:` dispositions
(different role → admissible). rec 5 — the gate binds on S139 itself and the fixture fails for the right
reason.

**design-advisor (rec 1–7).** rec 1 affirmed `design-significant: yes` + the DECISION-007/S135 citation
(both verified to exist) — kept. rec 2 (rejected alternatives) + rec 3 (waiver reconciliation) landed in
the `## Design` commit `9df330d`. rec 4 (set -e-safe capture, all three) landed in `c7c6337`. rec 6
(prove the header guard — a gate-less-binary plant + a header-drift assertion) landed in the fixture
`d2e0c2a`. rec 5 — placement accepted as-is: the checks are independent (each appends to `RESULTS`), so
order is cosmetic; kept between the design mandate and attestation. rec 7 — **verified: CI runs only
`cargo fmt`/`clippy`/`test`, never `verify-closeout.sh`** (`.github/workflows/ci.yml`), so the
binary-backed close checks — this one and its two siblings — regress no CI path; they run locally
pre-merge (S83). The S131 provenance limit (local `~/.claude/projects` only) is unchanged.

**implementation-advisor (rec 1–3, its own observations).** rec 1 — build clean, no missed case. rec 2
— the judge had no Bash, so it verified the four `obeyed:` changes at the branch TIP, not each cited
sha's isolated diff; the **builder confirmed per-sha** with `git show <sha>` (each sha introduces its own
change: `c7c6337` adds all three list-form captures, `d2e0c2a` adds the header-guard assertions,
`9df330d` adds the design lines) — an honest independent-judge limit, disclosed, not a self-grade of the
design recs. rec 3 — the judgments are admissible (implementation-advisor grading design-advisor).

## Cost / dispatch accounting (RAW subagent tokens, not new-only — S134)

- tech-lead **~46,937** · design-advisor **~93,921** · implementation-advisor **~52,028** (+ **~55,525**
  for the one follow-up judgment of the fidelity rec) · fidelity-reviewer **~98,195**. Four roles, five
  dispatches (the implementation-advisor was resumed once to judge the fidelity rec 1 fix), all
  named-files-only briefs — a total well under **~350K** RAW subagent tokens, the S135 affordable
  envelope, not the millions a repo-read costs (S134).
- Interactive session ⇒ authoritative `$` is an honest null (S77). The RAW figures above are the honest
  cost signal.

## What is disclosed / weak

- **Reviewer-independence self-certification stays OPEN (out of scope, per the prompt).** A review FILE
  with the right shape passes `check_fidelity_review` regardless of who wrote it (S138B showed a closing
  agent can finalize + attest its own review). This session binds the CREW at close; it does not prove
  the reviewer was independent from a file. **Named as the next-after candidate.**
- **Every judge this session had no shell** (the standing S133–S138 limit): the implementation-advisor
  and fidelity-reviewer read scripts; the live figures (verify, fixture, `--crew-only`) were executed by
  the builder + the close gates.
- **The "grep the binary's output for a header" house pattern now has TWO named soft edges**
  (fidelity-reviewer rec 3): (a) if `run_dump` can echo agent-authored file content, the header string
  could be planted to force exit-0-plus-header — a narrow false-green vector shared with the two sibling
  gates (design-advisor rec 6); and (b) the fixture's P2/P3 "names the missing role" assertion originally
  matched the always-printed crew echo rather than the block cause — **fixed in-session** (`3a9852e`,
  P2/P3 now grep `no real governed handoff: <role>`). If a future session moves these gates to a
  structured/exit-code-plus-fingerprint contract, close both at once rather than patching each fixture.
- **The cold fidelity review named the P2/P3 needle as this session's fakest green; it was fixed in the
  same session** and re-confirmed by the implementation-advisor. Running the fixture also surfaced three
  flakiness bugs (a command-sub subshell that swallowed `GATE_OUT`, a live-binary-swap exec race in P4
  replaced by an isolated `CLAUDE_PROJECT_DIR` stub, and an HDR `| grep -q` SIGPIPE under `pipefail`) —
  all fixed; the suite is now deterministic 6/6.

## Three ranked next candidates

1. **Reviewer independence at close (the S138B gap named above).** Bind `check_fidelity_review` to a
   provenance-verified `fidelity-reviewer` handoff whose dispatch id is not the closing session's own
   author — the last self-certification in the close path. Highest leverage; directly continues S139.
2. **Carry the recorded budget INTO the dispatch brief (S135 criterion 7, still PARTIAL).** `--crew-cost`
   reports actual-vs-allowance but nothing injects `budget_tokens` into a role's brief, so the allowance
   reaches no one who could honour it. Small, closes a known PARTIAL.
3. **`cargo fmt --check` as a per-session gate.** A recurrence risk (S96 was a whole session on it, S136
   found three unformatted files on main). Cheap, prevents a red-CI-on-main class.
