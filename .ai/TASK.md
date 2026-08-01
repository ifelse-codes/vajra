# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 107 — CODE: tagged binary release v0.1.0 — COMPLETE

- **Delivered (goal achieved):** the no-Rust install path. The **`v0.1.0` GitHub release is live** —
  3 prebuilt tarballs + `.sha256` (`aarch64-apple-darwin`, `x86_64-apple-darwin`,
  `x86_64-unknown-linux-gnu`). `install-smoke.sh` gained `VAJRA_SMOKE_SOURCE=release` (detect host →
  download tarball + `.sha256` → verify sha → extract `vajra` → `init`→`next`, **fail-closed**);
  proven live **11/11 SMOKE PASS** on arm64. README un-marks the prebuilt row (real command); crates.io +
  brew stay NOT YET PUBLISHED. **In-scope `release.yml` fix:** `x86_64-apple-darwin` now cross-compiles on
  `macos-latest` (the `macos-13` Intel runner sat queued forever). **No `src/`; no crates.io publish.**
  verify 7/7; demo exit 0 (4 markers). Independent cold review **ACCEPT**, attested `836cdfec…`. **PR #112.**
  Fakest green (disclosed): the x86_64 binaries are proven by architecture + checksum, never *executed*.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106 Rust path + instrument + S107 no-Rust prebuilt path) ✓** → A real agent fleet.

Between sessions. **Next = S108 — CODE: publish crates.io + Homebrew tap** (founder pick B): publish
`vajractl` to crates.io + a tap formula installing the `v0.1.0` release binary → un-mark the last two
README rows. Brief: `prompts/108-task-publish-crates-brew.md`. **crates.io publish is IRREVERSIBLE +
founder-gated.** **New chat** for S108.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. **S108 = CODE** (verify + demo scripts required; no waiver).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io publish is IRREVERSIBLE** — never publish (even an empty reserve) without an explicit
  founder "yes publish" in chat; the name burns on first publish.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S108; do NOT start it here.
- **S108 runs `cargo publish` → IRREVERSIBLE public crates.io release** — founder "yes publish" in chat
  first (the name `vajractl` burns). `cargo publish --dry-run` is safe. The tap repo is a public repo too.
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
