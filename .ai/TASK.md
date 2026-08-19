# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 123 — CODE: fence the `Write`/`Edit` grant — COMPLETE (between sessions)

- **Verdict: ACCEPT** (cold `fidelity-reviewer`, **pass 2** — 5 of 6 SHIPPED · 0 PARTIAL · 0
  NOT-BUILT). Summary: `sessions/session-123-summary.md`. Review: `sessions/session-123-review.md`.
- **What shipped:** both S122 fixtures isolated to fail for the right reason · the tally bound to
  one source (`scripts/lib-tally.sh`, now used by three suites) · `tools:` grant enforcement
  MEASURED live, not assumed (dispatched `researcher`, confirmed no Write/Edit/Bash tool present at
  all) · `qa-specialist` dispatch routed through a disposable `git worktree` checkout
  (`vajra next --role <name> --clean-room-open`/`--clean-room-close`) · the grant itself narrowed to
  `Bash, Read, Grep, Glob`. `verify-session-123.sh` **14 checks exit 0**; demo **6 of 6**; **339 lib
  tests**.
- **The load-bearing fixture holds up:** a real write attempted while pointed at a clean room lands
  there, not in the source repo — proven against a throwaway repo, with a negative control (an
  unfenced write) showing the detection isn't vacuous.
- **Fakest green (never soften this):** **`measurement-artifact-cited` only proves two committed
  documents agree with each other**, not that the underlying dispatch happened — the raw transcript
  lives outside the repo, uncommitted, unlike the S111 precedent it explicitly claims to match.
- **Cold pass 1 REJECTED, correctly and scoped:** the `tools:` measurement was true but
  unfalsifiable narrative with no artifact. Fixed in one commit.
- **🔴 The executor thesis is STILL UNPROVEN** — fencing removes one way to cheat, not the thesis.
  **🔴 The clean room isolates the REPO, not the MACHINE** — `Bash` remains granted to the role.

**Next = S124 — CODE: close the clean-room dispatch gap** (founder pick B of three).
Full prompt: `prompts/124-task-clean-room-dispatch-evidence.md`. **New chat.**
Recommended mechanism: a Vajra-written receipt (never an agent-typed marker) that `--clean-room-open`
writes and `--clean-room-close` completes with real before/after source-repo fingerprints;
`--from` fails closed for a Bash-holding role without a matching, fresh, fingerprint-clean receipt.
Design-significant — confirm or revise in a `DECISION-007` S124 addendum before step 2 lands.
S125 is fixed regardless of S124: mandatory NO-CODE GT.

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
- **Attest LAST (S69):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and the PROMPT IS AN
  INPUT — recompute strictly after the prompt's Execution shas are committed and confirm two
  consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).** Clean the planted defect out
  of the directory before testing the next branch, or the tooth is glued on. S123 applied this to
  its own new fixture (the two-half, restore-between-halves shape of `clean-room-fence-has-teeth`).
- **Expect more than one cold pass.** S122 needed four; S123 needed two. Every rejection so far has
  been correct.
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`. Cost 10
  minutes at S121 and 20 at S122. `verify-session-113.sh` is fixed; older scripts are not.
- **Running the product is not enough to call a check execute-based (S121)** — the ASSERTION has to
  bind to the behaviour, or it is a behavioral source grep wearing a costume. Reconfirmed at S123:
  the dispatched `qa-specialist` found `grant-write-edit-dropped` mislabeled this exact way.
- **The fleet has FOUR roles, ALL proven dispatched by name.** Exactly ONE executes
  (`qa-specialist`), now on the narrowed grant `Bash, Read, Grep, Glob` — Write/Edit dropped at S123.
- **Mid-session role changes are invisible to that same session's own dispatch (S111 limit).** S123
  reconfirmed it a second way: the narrowed grant (landed mid-session) did not apply to this
  session's own `qa-specialist` dispatch, which ran under the pre-S123 grant. Disclosed, not hidden.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — pending the founder's
  S124 pick.
- **New session = new chat** — open a fresh chat for S124.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate
  founder "yes". S123 added two flags to `next` (`--clean-room-open`/`--clean-room-close`), not a
  command.
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
- **QA STATION ≠ QA ROLE:** the station (`src/qa/mod.rs`) governs the process; the `qa-specialist`
  role does the work. Same pattern as Reviewer/fidelity-reviewer and Planner/plan-advisor.
