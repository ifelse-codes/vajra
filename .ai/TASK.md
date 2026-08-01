# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 108 — CODE: publish to crates.io + Homebrew tap — COMPLETE

- **Delivered (goal achieved):** every install channel is now real. **`vajractl 0.1.0` published to
  crates.io** (irreversible; run only after the founder's explicit in-chat "yes publish", and after the
  founder ran `cargo login` themselves — the token was never handled by the agent). Proven live by a
  fresh-dir `cargo install vajractl` → `init`→`next` (**7/7 SMOKE PASS**). **Public Homebrew tap
  `ifelse-codes/homebrew-tap`** with `Formula/vajra.rb` (real `v0.1.0` sha256 for arm64/x86_64 macOS +
  x86_64 Linux); proven end-to-end `brew install ifelse-codes/tap/vajra` (**11/11 SMOKE PASS**,
  sha256-verified). `install-smoke.sh` gained `crates` + `brew` modes, both **fail-closed**. README
  un-marks both rows (nothing left `NOT YET PUBLISHED`). `Cargo.toml` excludes two stray root HTML files
  from the package. **No `src/`; no station logic changed.** verify **10/10**; demo exit 0 (4 markers).
  Independent cold review **ACCEPT**, attested `f5a97e8b…`. **PR #113.** Fakest green (disclosed): the
  `brew` smoke installs a local copy of the formula into a throwaway tap, not the published tap.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106 Rust path + S107 prebuilt + S108 crates.io + brew) ✓ — B COMPLETE** → **A real agent fleet (next)**.

Between sessions. **Next = S109 — CODE: fleet slice 1 — one real named agent (Researcher) as a governed
step** (founder pick A, "start the fleet"): dispatch one named role with a role-scoped prompt +
delta-tracked handoff, proven with a stub agent (no paid call); design-significant → author
`DECISION-007`; ride an existing command (no 8th). Brief: `prompts/109-task-fleet-slice-1-researcher.md`.
**New chat** for S109.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. **S109 = CODE** (verify + demo scripts required; no waiver).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S109; do NOT start it here.
- **Max 7 top-level commands** — S109 fleet work must ride an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
