# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 119 — CODE: the clean-room runner — COMPLETE

- **Verdict: ACCEPT** — cold `fidelity-reviewer` pass, **8 of 8 SHIPPED**. No paid spend.
- **What shipped:** QA and Demo-er now route scripts through a fresh `git worktree add --detach`
  checkout of HEAD when `verify.clean_room.enabled: true` (default off). Bootstrap support;
  fail-closed on `CannotEvaluate`; `VAJRA_SKIP_CLEAN_ROOM=1` escape. `vajra init` scaffolds the
  new keys. The falsifiability fixture asserts both directions: working tree passes with a stale
  gitignored artifact, clean room fails without it — reproducing the S118 CI defect class.
  334 lib tests; verify 19/19 ALL GREEN; demo exits 0. Fakest green honestly named.
- **Fakest green:** `run-location-printed-in-output` in `verify-session-119.sh` greps source
  strings rather than capturing from a live gate run — the exact hollow pattern S118 named.
- **PR not yet opened** as of this snapshot (S119 on `session-119-clean-room-rerun`).

**Next = S120 — MANDATORY GT** (`120 % 5 == 0`). NO-CODE session. Audits S116–S119. Special focus:
does the grep-only-verify pattern appear in other historical verify scripts? Does the clean-room
runner change the pipeline-advance picture? Founder picks one of S119's A/B/C options for S121
after reviewing the session summary. **New chat.**

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
- **Attest LAST (S69, hit at S114, S116, S117, S118):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff)
  and the PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **A verdict line wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding)**
  — only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has THREE roles built, ALL THREE proven dispatched by name** (Researcher S111, Fidelity
  Reviewer S115, Plan Advisor S117). `reviewer/SKILL.md` is CANONICAL and the Reviewer role brief is
  its summary — bound by a check reading both files.
- **A "first try, no workaround" dispatch claim needs independent evidence** — count
  `subagent_type:"<role>"` occurrences in the real parent session transcript (exactly 1 = no hidden
  retry), not a magic-phrase grep against a file the same session wrote (S117 finding).
- **`vajra next --role X --from file` hashes the TRIMMED body**, not raw file bytes — strip before
  comparing a `--from` file's sha256 against a handoff's `source-sha`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end on ALL THREE
  roles (S111, S115, S117).** Vajra scaffolds the role + governs the handoff.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S120.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
