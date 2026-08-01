# Session 108 — CODE: publish to crates.io + Homebrew tap — Summary

**Type:** CODE · **Goal:** un-mark the last two README install rows by publishing `vajractl` to
crates.io and standing up a Homebrew tap for the `v0.1.0` release — each proven by a falsifiable
install, not a claim. The C→B→A order's **B**, now complete (every install channel works).

## Verdict: DELIVERED (goal achieved)

Both remaining channels are **published and proven live**:

- **crates.io** — `vajractl 0.1.0` published (irreversible; run only after the founder's explicit
  "yes publish" in chat, and after the founder ran `cargo login` themselves — I never handled the
  token). Proven by a fresh-dir `cargo install vajractl` from the registry → `vajra init`→`next`
  (**7/7 SMOKE PASS**). crates.io API confirms `vajractl` at `max_version 0.1.0`.
- **Homebrew** — public tap [`ifelse-codes/homebrew-tap`](https://github.com/ifelse-codes/homebrew-tap)
  with `Formula/vajra.rb` (real `v0.1.0` sha256 for arm64/x86_64 macOS + x86_64 Linux). Proven
  end-to-end from the **public** tap: `brew tap` → `brew install ifelse-codes/tap/vajra` →
  sha256-verified download → `vajra --help`/`init` run (**11/11 SMOKE PASS**), host cleaned after.
- **`install-smoke.sh`** grew `crates` + `brew` modes, both **fail closed** (missing crate / bad
  formula / sha mismatch / non-zero `vajra` → exit non-zero) — proven.
- **README** un-marks both rows with real commands; nothing left `NOT YET PUBLISHED`. All four
  install methods now work.
- **Cargo.toml** excludes two stray root HTML files that would otherwise ship inside the crate.

**verify-session-108.sh → 10/10 ALL GREEN** · **demo-session-108.sh → exit 0** (markers
header/cases/summary_table/before_after; live path/brew/crates all SMOKE PASS). No `src/` touched;
no pipeline-station logic changed. **PR [#113](https://github.com/ifelse-codes/vajra/pull/113).**

## Fidelity map — every prompt requirement → what shipped

| # (AC) | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | `vajractl` live on crates.io @ 0.1.0 (real install, not a claim) | **SHIPPED** | `cargo publish` exit 0; API `max_version 0.1.0`; fresh-dir `cargo install vajractl` → 7/7 SMOKE PASS |
| 2 | Homebrew tap installs a working `vajra` (sha256-verified) | **SHIPPED** | public tap live; `brew install ifelse-codes/tap/vajra` → 11/11 SMOKE PASS; reviewer re-hashed all 3 shas + corrupted one → brew rejects |
| 3 | Both smoke paths exit non-zero on any failure | **SHIPPED** | bogus crate → exit 1; missing formula → exit 1 (both proven) |
| 4 | README un-marks crates.io + brew; no row dropped; nothing faked | **SHIPPED** | `grep "NOT YET PUBLISHED"` empty; both real commands present; source + prebuilt rows kept |
| 5 | `cargo test --lib` green; CI green both OS; no station logic changed | **SHIPPED** | 296 lib tests pass; diff touches no `src/` |
| 6 | `cargo publish` only after founder token; tap created with founder awareness | **SHIPPED** | "yes publish" + "yes tap" given in chat; `cargo login` done by founder; no credential in diff |
| 7 | Independent cold review → ACCEPT, attested; ledger intact | **SHIPPED** | cold subagent ACCEPT, attested `f5a97e8b…`; ledger chain INTACT (43 records) |

**Scripts (constitution step 5):** `scripts/verify-session-108.sh` + `scripts/demo-session-108.sh`
shipped (CODE session requires both).

## Fakest green (disclosed)

The `brew` **smoke mode** installs a *local copy* of `Formula/vajra.rb` into a throwaway tap, so the
gating instrument never touches the *published* `homebrew-tap` repo a stranger uses — it would stay
green if the public tap ever drifts from the local formula. Harmless only because (a) they were pushed
byte-identical this session and (b) the true public-tap path was run live (by me and independently by
the cold reviewer). A durable fix would point the brew smoke at the published tap.

Secondary: the crates + brew fail-closed *gate* checks (in verify) assert non-zero on a bad target,
which holds whether the cause is a 404 or no network — the positive live installs are captured as
artifacts + re-run by the cold reviewer, not by the offline close-gate (deliberate: a gate must not
depend on the network).

## Cost

~$0 launcher spend (no paid `vajra claude` run). Spend = one cold-review subagent + `cargo publish`
upload + `brew`/`cargo` installs. crates.io + a public GitHub repo are the outward artifacts.

## What's next — pick one (A/B/C)

Order **C→B→A** is now **B-complete**. S110 is the next mandatory NO-CODE ground truth, so S109 is a
CODE session.

### A — Start the agent fleet (order's **A**, the next major) — *recommended*
- **Goal:** ship the first concrete slice of the real named parallel-agent fleet (e.g. one additional
  named agent — a Researcher — invoked by `vajra` with the existing gates as the hidden trust engine),
  the fleet-vs-gates fork opened at S103.
- **Why pick this:** B is done and v0.1 is stranger-shippable; the fleet is the product's headline
  ("leave a *team* of agents working, come back, trust the result") and the last leg of C→B→A.
- **Key risk:** a fleet is many sessions — scoping the FIRST slice to fit one story / ~2h is the hard
  part; easy to sprawl. Needs a crisp "one agent, one handoff" cut.

### B — v0.1 release-readiness polish (`vajra --version` + a 10-min quickstart)
- **Goal:** close the two known installability residuals — `vajra --version` returns a real version
  string (today a stranger gets usage), and a 10-minute quickstart in the README (named in the release
  backstop) — so the founder's long real-world test + public release runs on a pristine v0.1.
- **Why pick this:** cheap, high-polish, makes v0.1 genuinely stranger-ready right before the founder
  owns the long unattended test.
- **Key risk:** polish, not product — doesn't advance the pipeline or fleet; could read as easy-green
  the session before a GT.

### C — Pay down the two loudest 🟡 debts (durable `--dogfood-age` + KNOWLEDGE §6 prune)
- **Goal:** make `dogfood_age()` recurse into per-run subdirs (retire the by-hand aggregate receipt,
  `src/dogfood/mod.rs:63-66`), and prune KNOWLEDGE §6 (475 lines / ~91K tokens, growing since S60).
- **Why pick this:** both are chronic and bite every session (context bloat + hand-maintained
  receipts); clears the deck before the S110 GT.
- **Key risk:** housekeeping, not product; the fleet still waits; a rushed prune risks dropping a
  load-bearing lesson.
