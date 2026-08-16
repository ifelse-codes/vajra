# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 118 — DOGFOOD (paid): the overdue `vajra claude` run on chitra — COMPLETE

- **Verdict: ACCEPT** — two cold `fidelity-reviewer` passes, **pass 1 REJECT → pass 2 ACCEPT**
  (5 of 8 SHIPPED, 3 PARTIAL, 0 NOT-BUILT). **Spend $4.0911771 authoritative**, 1331s, under the
  founder's $5 cap. No `src/` change (`design-significant: no`).
- **THE FINDING:** the governed run delivered chitra S11, self-graded **8-of-8 SHIPPED** with
  `verify-session-11.sh` at **14/14 ALL GREEN** — while **19 of 20 chart pages showed an error
  instead of a chart.** All 11 catalog checks were greps for source strings. Six governance gates
  behaved correctly; none asks whether the delivered thing works. **S54 reproduced on a paid run.**
- **The operator repaired it** (4 defects: an option-injector brace closing the object early, a
  `return ( … )` wrapper that could not hold multi-statement examples, a chained-regex highlighter
  printing its own markup as text, and Reset leaving a stale preview) and closed the hollow check
  with one that EXECUTES all 20 examples × 3 renderers — 81 checks, falsifiable at 5/81.
- **Pass 1 REJECTed this session for the same sin one level up:** payload verification delivered as
  prose with no screenshot. Fixed with 5 real headless-Chrome PNGs. Pass 2 then caught an inflated
  "six gates fired" headline — one gate is file-backed against the agent; three fired against the
  operator, uncaptured. Corrected.
- **Dogfood staleness RETIRED:** `vajra next --dogfood-age` now reports S118 · 2026-08-15 · $4.0912.
- **chitra is left on `session-11-catalog-two-panel`, LOCAL — not pushed, no PR.** chitra `main`
  never moved. The founder reviews the page in a browser first.

**Next = S119 — CODE: the clean-room re-run** (`prompts/119-task-clean-room-rerun.md`, founder pick
at the S118 close, chosen over the grep-only-verify detector and the Planner-gate fix). Make QA and
Demo-er re-run their scripts in a fresh checkout of `HEAD` — no uncommitted files, no gitignored
build output — instead of in the tree the agent prepared. Opt-in per repo, fail-closed, and proven
against the exact defect CI caught at S118 while ten cold reviews missed it. **New chat.**

**🔒 FOUNDER DIRECTIVE (S118, in force):** `README.md` / `VISION.md` claims are the **target spec**,
not a status report. **Never** soften them to match current capability — record gaps in `.ai/` and
session records instead. **No release** (crates.io `0.1.1`+, announcements, wider distribution)
until reality meets the claim. When a dogfood exposes a gap: root-cause it, then fix it.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69, hit at S114, S116, AND S117):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff)
  and the PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **A verdict line wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding)**
  — only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has THREE roles built, ALL THREE proven dispatched by name** (Researcher S111, Fidelity
  Reviewer S115, Plan Advisor S117). `reviewer/SKILL.md` is CANONICAL and the Reviewer role brief is
  its summary — bound by a check reading both files (the Plan Advisor has no such counterpart).
- **A "first try, no workaround" dispatch claim needs independent evidence** — count
  `subagent_type:"<role>"` occurrences in the real parent session transcript (exactly 1 = no hidden
  retry), not a magic-phrase grep against a file the same session wrote (S117 finding).
- **`vajra next --role X --from file` hashes the TRIMMED body**, not raw file bytes — strip before
  comparing a `--from` file's sha256 against a handoff's `source-sha`.
- **A new fleet role's regression check should target the most recent COUNT-AGNOSTIC prior verify
  script**, not simply the most recent one — a prior script's hardcoded role count goes stale by
  construction as the fleet grows; that is expected staleness, not a regression, but must be named.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end on ALL THREE
  roles (S111, S115, S117) and CONSUMED (S112):** Vajra scaffolds the role + governs the handoff; a
  fresh session's Task tool resolves `subagent_type` against the scaffolded file by name. It does NOT
  spawn `claude -p`. An unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way).
- **Cost-null checks ride `scripts/check-subagent-cost-fields.sh`** — re-runnable, local-machine-only
  (same limitation class as `--dogfood-age`); reuse it, don't re-derive the grep by hand.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — S118's prompt is the one
  disclosed exception (waiting on the founder's own go-ahead + chitra's readiness), not an oversight.
- **New session = new chat** — open a fresh chat for S118 (only when told) and S119.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
