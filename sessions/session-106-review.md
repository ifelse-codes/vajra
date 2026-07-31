# Session 106 — Independent Cold Fidelity Review

**Reviewer:** independent adversarial subagent, fed ONLY the contract prompt
(`prompts/106-task-installable-v01.md`) + the delivery diff (`main..HEAD` = `README.md` + the 3 new
scripts). Explicitly barred from reading STATE, the summary, ROADMAP, or any prior review (cold). The
reviewer **executed every script live** to verify the "proven live" claims rather than trusting them.

**Single pass = ACCEPT.** No code changes were required; the two items below are honest, pre-disclosed
residuals **within** the ACCEPT, not defects. Nothing was patched after the verdict (a post-ACCEPT edit
would invalidate the input attestation and require re-review).

## Fidelity map (reviewer's verdict per requirement)

| # | Requirement | Verdict | Evidence (reviewer-verified) |
|---|---|---|---|
| AC1 | Clean-checkout install produces a runnable `vajra`, shown by real output | SHIPPED | `bash scripts/install-smoke.sh` → `SMOKE PASS (7 checks, 0 fail)`, exit 0 (~26s cold): `install-from-path` → `binary-installed` (`test -x`) → `vajra-init` → `scaffold-created` (`test -f .ai/SESSION`) → `vajra-next` all PASS. `Cargo.toml` = package `vajractl`, `[[bin]] name = "vajra"` |
| AC2 | Smoke does fresh-dir install → init → next, asserts each, exits non-zero on any fail | SHIPPED | Falsification: `VAJRA_SMOKE_PATH=$BROKEN … install-smoke.sh` → `SMOKE FAIL (2 pass, 5 fail)`, `exit=1`, real cargo error. Fresh project dir + install root are **separate** `mktemp -d`s; the tested binary is `$INSTALL_ROOT/bin/vajra`, not the system one |
| AC3 | README shows only working paths; unshipped stay NOT YET PUBLISHED | SHIPPED | Working `cargo install --git …` + `--path` variant present; instrument referenced; crates.io / brew / prebuilt rows all still `NOT YET PUBLISHED`; `git remote` matches the URL. `verify-session-106.sh` `readme-truth-pass` PASS |
| AC4 | `cargo test --lib` green; no pipeline-station logic changed | SHIPPED | `verify-session-106.sh` → `ALL GREEN (5 pass, 0 fail)` (test-lib + fmt + clippy). Diff grep for `src/`, `Cargo.toml`, `Cargo.lock` → **none**; only README + 3 scripts |
| AC5 | Nothing published to crates.io without a founder token | SHIPPED | No `cargo publish` in the diff; crates.io row stays NOT YET PUBLISHED; no name burned |

Also confirmed live: `demo-session-106.sh` → exit 0 (all 4 sprint-demo markers).

## Findings (disclosed residuals — within ACCEPT)

- **Fakest green — the instrument's *default* proves `--path`, not the README's headline `--git`.** The
  advertised stranger one-liner is `cargo install --git <remote>`, but the default smoke run exercises
  `cargo install --path <local checkout>`. The remote one-liner runs only under `VAJRA_SMOKE_SOURCE=git`
  (and only once this code reaches the remote's default branch). Equivalence rests on "same Cargo.toml,
  same crate `vajractl`, same bin `vajra`" — **structurally true and disclosed in the script header** — so
  it is a floor, not a deception. It is the one place where "proven" leans on a claim, not the default run.
- **`within-budget` is a post-hoc assertion, not an enforced per-step timeout.** The budget is checked
  once at the end (`test "$ELAPSED" -le "$BUDGET"`); it catches a slow-but-finite run, but a genuine
  infinite hang in `cargo install`/`vajra` would hang forever and never reach the check. The
  "bounds hangs" wording slightly overstates what is enforced. Minor (cargo/vajra don't hang unbounded).
- **No vacuous passes.** `scaffold-created` and `binary-installed` both genuinely FAILED in the broken
  run → load-bearing, not rubber stamps.

**Review-Inputs-SHA:** 07b962afe9e9dcd83b1283b271ce7375ad9bac0fb4415a73c2a1e2a2a3fcb1b4

**Verdict:** ACCEPT
