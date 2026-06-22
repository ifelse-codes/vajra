# Vajra — Compression Fixtures (from REAL command output)

**Date:** 2026-06-15 · Captured live from the `akrti` repo (a real Rust/tokio/axum project).
**Purpose:** a concrete test corpus for the v1 compression engine (now delivered via the Claude
Code `PostToolUse` hook per ADR-0001). Raw outputs in `raw/`. *Does not edit master/ADRs/memory.*

> **Bonus finding (high value):** the old `akrti` source already implements these exact
> heuristics — `src/hooks/{cargo,git,npm,pytest,docker,generic}.rs` + `ctx/compress.rs`, each
> with passing unit tests (visible in `raw/cargo-test.txt`). Vajra is greenfield (no code
> reuse), but **this is a proven reference design to study**, not guess at. See §6.

---

## 1. The corpus (real, with measured sizes)

| Fixture | Cmd | Lines | Exit | Compress? | → after |
|---|---|---|---|---|---|
| `raw/cargo-build.txt` | `cargo build` (clean) | **181** | 0 | YES (success) | **1 line** |
| `raw/cargo-test.txt` | `cargo test` | **86** | 0 | YES (success) | **~3 lines** |
| `raw/git-log.txt` | `git log --oneline -40` | 21 | 0 | NO (under cap) | passthrough |
| `raw/git-status.txt` | `git status` | 4 | 0 | NO (small/decision) | passthrough |
| `raw/git-diff-stat.txt` | `git diff --stat` | 6 | 0 | NO (already narrowed) | passthrough |
| `raw/ls-R-src.txt` | `ls -R src` | 46 | 0 | YES (listing) | count + sample |

---

## 2. The high-value cases (real numbers)

### `cargo build` — 181 lines → 1 (≈99% cut, zero info loss)
Raw = 180× `   Compiling <crate> vX.Y.Z` + 1× `Finished`. On **exit 0**, all "Compiling" lines
are pure noise.
**Ideal compressed:**
```
✓ cargo build — Finished dev profile in 18.50s (180 crates compiled)
```
*(Tail line kept verbatim; the count is the only signal worth keeping.)*

### `cargo test` — 86 lines → ~3 (success path)
Raw = 14 compile lines + 47 `test … ok` lines + 4 suite summaries. On **all-pass**, individual
`… ok` lines are noise; the per-suite `test result:` lines are the signal.
**Ideal compressed:**
```
✓ cargo test — all green in ~4.9s
  lib: 43 passed · bin: 0 · integration: 4 passed · doc: 0
```
*(Drop compile noise + every `… ok`; keep the result summaries.)*

### `cargo test` — FAIL path (the rule that matters; constructed, no real failing run on hand)
On **exit ≠ 0**: **keep every failing test's name + full panic/assert output VERBATIM**, collapse
the passing ones to a count, drop compile noise.
**Ideal compressed:**
```
✗ cargo test — 2 failed, 41 passed (lib)
--- FAILED: hooks::git::tests::test_compress_log_long ---
thread '…' panicked at src/hooks/git.rs:88:9:
assertion `left == right` failed
  left: 30
 right: 31
--- FAILED: proxy::tests::test_extract_openai_usage ---
<full verbatim panic>
[compile + 41 passing lines folded]
```
**Non-negotiable:** if total failing output < ~400 lines, pass the WHOLE thing through — the
agent is mid-debug (the day-1 uninstall trap).

### `ls -R src` — 46 lines → count + sample
**Ideal compressed:**
```
src/ — 13 dirs, 33 files [VAJRA_RAW=1 for full tree]
  src/main.rs, src/cli.rs, src/config.rs, … (+30 more)
```

---

## 3. The passthrough cases (proving we DON'T over-compress)
- `git log` 21 lines < 30 cap → **passthrough**. (Fixture proves the threshold gate works.)
- `git status` 4 lines, decision-critical → **passthrough**.
- `git diff --stat` 6 lines, already narrowed by the agent → **passthrough**.

These matter as much as the compress cases: they guard against the "compressed away the thing I
needed" failure mode.

## 4. The universal rules (validated against the real data)
1. **exit 0 → safe to fold the body** (build/test/install success).
2. **exit ≠ 0 AND < ~400 lines → passthrough verbatim** (mid-debug).
3. **exit ≠ 0 AND large → keep failures verbatim, fold the passing/noise** + `[N hidden]` breadcrumb.
4. **Always lossless-on-demand** (`VAJRA_RAW=1`) and **fail-open** if the parser can't classify.
5. **Below the per-tool line cap → passthrough** (don't touch small output).

## 5. How these become tests
Pair each `raw/<x>.txt` with an `expected/<x>.txt` (the compressed form) once the engine exists.
The hook engine's test = `compress(raw) == expected` for the success cases, and
`compress(raw_fail) contains every failing block verbatim` for the fail cases. This corpus also
backs the **lossless invariant test** (`VAJRA_RAW` recovers `raw` byte-for-byte).

## 6. Reference implementation to study (don't copy — greenfield)
`akrti/src/hooks/` already has, with passing tests:
- `cargo.rs` (`test_compress_test_pass_short`, `test_compress_test_fail`)
- `git.rs` (`test_compress_log_long/short`, `test_compress_status_long`, `test_compress_diff_long`)
- `pytest.rs`, `npm.rs`, `docker.rs`, `generic.rs` (head+tail truncation), `ctx/compress.rs`
- ⚠ `akrti/src/proxy/optimizer.rs` has the **dedup** logic (`dedupes_repeated_tool_result_content`,
  `strips_orphan_tool_results`) — this is the **cache footgun D2 says to delete**. Study what NOT
  to carry forward.

**Takeaway for the code phase:** the compression heuristics are a (mostly) solved problem with a
working reference next door. The novel v1 work is the **delivery mechanism (CC PostToolUse hook,
ADR-0001) + the honest meter + lossless-on-demand discipline**, not reinventing the folding logic.

For future compression expansion, also read `research/HEADROOM-LESSONS.md`. Use it as a
learn-only reference for reversible raw recovery, cache safety, benchmark discipline, and
content routing. Do not copy Headroom code, naming, benchmark claims, or dependencies.
