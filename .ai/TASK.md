# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 106 — CODE: make it installable (v0.1) — COMPLETE

- **Delivered (goal achieved):** one install path that works from a clean checkout
  (`cargo install --git|--path` → `vajractl` crate, `vajra` binary; `Cargo.toml` was already
  release-correct — the S105 "paper-only" note was stale), **plus the missing instrument**
  `scripts/install-smoke.sh` (fresh temp install → `vajra init` → `vajra next`, asserts each inside a
  time budget, **exits non-zero on any failure**; proven both ways live — 7/7 PASS on the real tree,
  FAIL→exit 1 on a broken source), **plus a README truth-pass** (working one-liner proven; crates.io /
  brew / prebuilt rows stay NOT YET PUBLISHED). **No `src/` changes; no crates.io publish; no tag.**
  verify 5/5 GREEN; demo exit 0 (4 markers). Independent cold review **ACCEPT**, attested
  `07b962af…`. **PR #111.** Fakest green (disclosed): the smoke default proves `--path`; the README's
  headline `--git` remote path is only exercised under `VAJRA_SMOKE_SOURCE=git` (structurally identical).

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B make it installable**
(S106 ✓ Rust path + instrument; **S107 = the no-Rust prebuilt-binary path**) → A real agent fleet.

Between sessions. **Next = S107 — CODE: tagged binary release v0.1.0** (founder pick A): push a
`v0.1.0` tag → `release.yml` builds 3-target prebuilt binaries + GH release → a **download-and-run
smoke** proves the no-Rust path → un-mark that README row. Brief:
`prompts/107-task-tagged-binary-release-v010.md`. **New chat** for S107.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. **S107 = CODE** (verify + demo scripts required; no waiver).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io publish is IRREVERSIBLE** — never publish (even an empty reserve) without an explicit
  founder "yes publish" in chat; the name burns on first publish.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S107; do NOT start it here.
- **S107 pushes a `v0.1.0` git tag → public GH release** — founder "yes push the tag" in chat first.
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
