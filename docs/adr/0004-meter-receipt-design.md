# ADR-0004 — Meter and receipt design

- **Status:** ✅ **Accepted** — ratified by Suman 2026-06-16 (panel-recommended same day).
- **Date:** 2026-06-16
- **Phase:** Design · **Design Session 4.**
- **Deciders:** Panel — Systems Architect · Principal Engineer · Practitioner; closed by Red-Team. Chair/facilitator: Claude Code. Ratifier: Suman.
- **Depends on:** [ADR-0001](0001-compression-delivery-mechanism.md) (no-proxy; JSONL is the cost source); [ADR-0002](0002-engine-trait-adapter-contract-module-layout.md) (`meter/` module slot); [ADR-0003](0003-settings-injector-and-compression-heuristics.md) (`cli/launch.rs` structure, `spawn()+wait()` lifecycle).

---

## 1. Context & the questions

The "honest meter" is one of Vajra's five day-0 trust commitments and is the receipt the user sees after every `vajra claude` session. JSONL-RECON.md verified the exact schema (CC v2.1.177) and corrected the S3 cost formula (two cache tiers, per-model pricing, subagent aggregation). ADR-0002 reserved `meter/` in the module layout. DS4 decides the public API, the receipt format, how the session JSONL is located, how compression stats reach the receipt, and what the bench/fixtures schema tripwire asserts.

**Five questions for this session:**

1. When is the meter invoked, and from where?
2. How does the launcher find the right JSONL file?
3. What does the receipt look like to the user?
4. How do compression line-counts reach the receipt?
5. What does the bench/fixtures schema tripwire assert, and what is the failure policy?

---

## 2. Decisions

### 2.1 Invocation timing and architecture

The meter runs **on-exit**: after `child.wait()` returns in `cli/launch.rs`, before the launcher exits. This moment has three favourable properties: the JSONL is fully flushed, the data is complete, and the receipt appears as the natural end-of-session signal.

A separate `vajractl meter [<session-uuid-or-path>]` subcommand exposes the same function for historical sessions. No new design needed — it calls `meter_session()` on the specified (or most-recently-found) JSONL and prints the same receipt.

### 2.2 Session JSONL discovery

```rust
// cli/launch.rs — called after child.wait()

fn find_session_jsonl(session_start: SystemTime) -> Option<PathBuf> {
    let cwd_slug = derive_cwd_slug(&std::env::current_dir().ok()?);
    let project_dir = home_dir()?.join(".claude/projects").join(&cwd_slug);

    // Validate slug (G10): if the directory doesn't exist, warn and do slug fallback search
    if !project_dir.exists() {
        eprintln!("[vajra] expected project dir not found: {} — run with VAJRA_DEBUG=1", project_dir.display());
        return find_session_jsonl_fallback(session_start);
    }

    let candidates: Vec<_> = std::fs::read_dir(&project_dir).ok()?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |x| x == "jsonl"))
        .filter(|e| !e.path().to_string_lossy().contains("subagents"))
        .filter(|e| e.metadata().ok()
            .and_then(|m| m.modified().ok())
            .map_or(false, |t| t > session_start))
        .map(|e| e.path())
        .collect();

    match candidates.len() {
        1 => Some(candidates.into_iter().next().unwrap()),
        0 => None,  // no tool calls this session; skip metering
        _ => {
            eprintln!("[vajra] multiple sessions detected — skipping meter (run vajractl meter <id> manually)");
            None
        }
    }
}

fn derive_cwd_slug(cwd: &Path) -> String {
    cwd.to_string_lossy().replace('/', "-")
    // Result: /Users/suman/playground/vajra → -Users-suman-playground-vajra
}
```

Subagent JSONLs are at `<project_dir>/<session-uuid>/subagents/`.

Derive the session UUID from the main JSONL filename (stem = UUID) and construct the subagent dir.

**Fallback discovery** (when slug doesn't match): search `~/.claude/projects/*/` for JSONL files modified after `session_start`, pick the newest. Emit a warning and note the correct slug under `VAJRA_DEBUG=1`.

### 2.3 Public meter module API

```rust
// meter/mod.rs

/// Aggregate cost of one CC session (main JSONL + all subagent JSONLs).
pub struct SessionCost {
    pub session_id: String,
    pub model_breakdown: Vec<ModelCost>,
    pub total_dollars: f64,
    /// None if the sidecar stats file was unavailable.
    pub lines_folded: Option<u64>,
    pub calls_compressed: Option<u64>,
    /// Schema warnings (non-fatal). Empty = clean parse.
    pub warnings: Vec<String>,
}

pub struct ModelCost {
    pub model: String,
    pub assistant_lines: u64,
    pub dollars: f64,
    pub tokens: TokenUsage,
}

pub struct TokenUsage {
    pub input: u64,
    pub output: u64,
    pub cache_read: u64,
    pub cache_write_5m: u64,
    pub cache_write_1h: u64,
    pub web_search_requests: u64,
    pub web_fetch_requests: u64,
}

/// Pure function — no network, no side effects, read-only.
pub fn meter_session(
    main_jsonl: &Path,
    subagent_dir: Option<&Path>,
    pricing: &Pricing,
    stats_file: Option<&Path>,   // VAJRA_SESSION_STATS sidecar; None = skip compression stats
) -> anyhow::Result<SessionCost>
```

### 2.4 JSONL parsing rules

```rust
for line in read_jsonl_lines(path)? {
    // Only assistant lines carry usage
    if line["type"].as_str() != Some("assistant") { continue; }

    let model = line["message"]["model"].as_str().unwrap_or("");
    // Skip synthetic placeholder lines (non-billable, no real usage)
    if model == "<synthetic>" || model.is_empty() { continue; }

    let usage = &line["message"]["usage"];

    // REQUIRED fields — absent → schema has changed → warn + estimate (not hard error)
    let write_5m = get_u64_or_warn(usage, &["cache_creation", "ephemeral_5m_input_tokens"], &mut warnings);
    let write_1h = get_u64_or_warn(usage, &["cache_creation", "ephemeral_1h_input_tokens"], &mut warnings);
    let cache_read = get_u64_or_warn(usage, &["cache_read_input_tokens"], &mut warnings);
    let input  = get_u64_or_warn(usage, &["input_tokens"], &mut warnings);
    let output = get_u64_or_warn(usage, &["output_tokens"], &mut warnings);

    // Optional fields — absent → 0 (these are clearly optional in the schema)
    let web_search = usage["server_tool_use"]["web_search_requests"].as_u64().unwrap_or(0);
    let web_fetch  = usage["server_tool_use"]["web_fetch_requests"].as_u64().unwrap_or(0);

    // TRAPS — do NOT read these (see JSONL-RECON.md §5):
    // cache_creation_input_tokens  → it's the sum of 5m+1h, adding it double-counts
    // iterations[]                 → sub-breakdown repeating top-level numbers
}
```

`get_u64_or_warn(node, path, warnings)`:
- If the field exists and is a number → return it.
- If the field is absent → push `"[estimated] missing field: <path>; using 0 — update vajractl"` to `warnings`, return 0.
- The `SessionCost.warnings` field surfaces these to the receipt, and the tripwire catches them in CI.

**Schema drift fallback:** if both 5m and 1h tier fields are absent, compute a rough estimate using `cache_creation_input_tokens × 1.625` (midpoint of 1.25 and 2.0 tiers). Mark the receipt with `[estimated]`. This keeps the receipt useful on a schema change rather than printing nothing.

### 2.5 Per-line cost formula

```rust
fn line_dollars(tokens: &TokenUsage, model: &str, pricing: &Pricing) -> f64 {
    let p = pricing.for_model(model);
    (tokens.input       as f64 * p.input_per_mtok
   + tokens.output      as f64 * p.output_per_mtok
   + tokens.cache_read  as f64 * p.input_per_mtok * 0.10
   + tokens.cache_write_5m as f64 * p.input_per_mtok * 1.25
   + tokens.cache_write_1h as f64 * p.input_per_mtok * 2.00
    ) / 1_000_000.0
   + tokens.web_search_requests as f64 * pricing.web_search_per_request
   + tokens.web_fetch_requests  as f64 * pricing.web_fetch_per_request
}
```

Unknown model → push a warning and use a safe default (opus pricing, the most expensive, so we never undercount).

### 2.6 Pricing source

Pricing is **compiled into the binary** as a Rust constant (a `pricing.toml` embedded via `include_str!` at build time). `bench/pricing.toml` is the canonical source; it is also `include_str!`'d into the binary. When pricing changes, users update `vajractl`. No runtime config file to discover, manage, or drift.

The `Pricing` struct is constructed from the embedded TOML once per launcher invocation (not per JSONL line).

### 2.7 Compression stats sidecar

The launcher sets `VAJRA_SESSION_STATS=<tempfile-path>` in the CC child's environment:

```rust
// cli/launch.rs — inside launch()

let stats_path = std::env::temp_dir().join(format!("vajra-stats-{}.jsonl", uuid_simple()));
Command::new("claude")
    .args(&user_args)
    .args(&["--settings", temp_settings.path().to_str().unwrap()])
    .env("VAJRA_SESSION_STATS", &stats_path)
    .spawn()?
    .wait()?;

let stats = read_compression_stats(&stats_path);  // aggregates lines
let _ = std::fs::remove_file(&stats_path);        // cleanup
```

The hook (`cli/hook.rs`) appends one line per compressed call:

```rust
// cli/hook.rs — after a Compressed decision is applied

if let Ok(stats_path) = std::env::var("VAJRA_SESSION_STATS") {
    let entry = serde_json::json!({
        "lines_in": lines_in,
        "lines_out": lines_out,
        "command": command_prefix,  // first token only, no args (no PII)
    });
    // O_APPEND write — atomic for small payloads on local filesystems
    let mut f = std::fs::OpenOptions::new()
        .create(true).append(true).open(&stats_path);
    if let Ok(mut f) = f {
        let _ = writeln!(f, "{}", entry);
    }
    // Silently skip on any error — fail-open, compression still applied
}
```

`read_compression_stats(path)` returns `Option<(u64, u64)>` (lines_folded, calls_compressed). Returns `None` if file absent or unreadable.

**No lock needed:** CC tool calls within a single session are serial. Concurrent hook invocations within one session are not a realistic concern in v1.

### 2.8 Receipt format

Printed to **stderr** after `child.wait()` returns, unless `VAJRA_QUIET=1` is set.

**Default (compact):**
```
─── vajra · a1b2c3d · 2026-06-16 14:32 ─────────────────────────────
 $0.0859  total  (opus 163 lines · haiku 8 lines via 2 subagents)
          input $0.0128 · output $0.0810 · cache-r $0.0022 · cache-w $0.0139
          83 lines folded across 7 tool calls
─────────────────────────────────────────────────────────────────────
```

If `lines_folded` is `None` (sidecar unavailable): omit the third row.

If `warnings` is non-empty: print each warning on its own line below the separator, prefixed with `[vajra warn]`.

If any cost is `[estimated]` due to schema drift: replace `$X.XXXX` with `~$X.XXXX [estimated — update vajractl]`.

**Verbose (`VAJRA_VERBOSE=1`):** expand to per-model table:
```
─── vajra · a1b2c3d · 2026-06-16 14:32 ─────────────────────────────
 model                 lines  input     output    cache-r   cache-w
 claude-opus-4-8         163  $0.0128   $0.0810   $0.0022   $0.0139
 claude-haiku-4-5          8  $0.0001   $0.0000   $0.0000   $0.0000
 ──────────────────────────────────────────────────────────────────
 total                  $0.0859
 compression            83 lines folded across 7 tool calls
─────────────────────────────────────────────────────────────────────
```

**Historical** (`vajractl meter`): same formats; `--verbose` flag mirrors `VAJRA_VERBOSE`.

### 2.9 Bench/fixtures schema tripwire

```
bench/
  fixtures/
    session_v1.jsonl    ← pinned at CC v2.1.177, minimal but exercising all fields
    expected_v1.json    ← hand-computed expected SessionCost at bench/pricing.toml rates
  pricing.toml          ← pinned price table (also include_str!'d into the binary)
```

`session_v1.jsonl` content (from JSONL-RECON §6 + one subagent line):

```jsonl
{"type":"assistant","version":"2.1.177","message":{"model":"claude-opus-4-8","usage":{"input_tokens":10,"output_tokens":132,"cache_read_input_tokens":11586,"cache_creation_input_tokens":6928,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":6928},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"assistant","version":"2.1.177","message":{"model":"<synthetic>","usage":{}}}
{"type":"user","message":{"content":"..."}}
```

`expected_v1.json` asserts (at pinned pricing):
- `total_dollars`: exact value to 6 decimal places
- `model_breakdown[0].model`: `"claude-opus-4-8"`
- `model_breakdown[0].tokens.cache_write_5m`: `0`
- `model_breakdown[0].tokens.cache_write_1h`: `6928`
- `model_breakdown[0].tokens.cache_read`: `11586`
- `warnings`: `[]` (no warnings on a clean fixture)
- No entry for `<synthetic>` (correctly skipped)

**Tripwire test policy:**

```rust
#[test]
fn cost_formula_fixture_v1() {
    let pricing = Pricing::from_toml(include_str!("../../bench/pricing.toml")).unwrap();
    let result = meter_session(
        Path::new("bench/fixtures/session_v1.jsonl"),
        None,
        &pricing,
        None,
    ).unwrap();
    let expected: SessionCost = serde_json::from_str(
        include_str!("../../bench/fixtures/expected_v1.json")
    ).unwrap();

    assert_eq!(result.warnings, expected.warnings,  "schema drift detected");
    assert!((result.total_dollars - expected.total_dollars).abs() < 1e-6,
        "cost formula mismatch: got {} expected {}", result.total_dollars, expected.total_dollars);
    assert_eq!(result.model_breakdown[0].tokens.cache_write_1h,
               expected.model_breakdown[0].tokens.cache_write_1h,
               "cache tier mismatch — Anthropic may have renamed ephemeral_1h_input_tokens");
}
```

If CI goes red on this test: **stop the release**. The schema or pricing has changed. Update the formula, regenerate `expected_v1.json`, bump the fixture version.

---

## 3. Rationale

1. **On-exit receipt** — the JSONL is complete and authoritative at that moment. Live polling adds file-watch complexity; the natural end-of-session moment is when the user most wants the summary.
2. **`stderr` for the receipt** — it's metadata. Users who pipe stdout get clean data; the receipt is never accidentally captured in a file.
3. **Sidecar env var** — the only way to communicate per-call compression stats from the hook subprocess back to the launcher. The hook runs as CC's child; shared state must be the filesystem. `O_APPEND` is sufficient for the serial tool-call case.
4. **Compiled-in pricing** — eliminates a config discovery problem. Pricing changes are infrequent; users update the binary. An external config file adds an update/drift hazard with no real benefit for solo developers.
5. **Warn + estimate on schema drift (not hard error)** — a missing `ephemeral_1h_input_tokens` field at runtime should degrade gracefully (warn, estimate, label). A hard parse failure would suppress the receipt entirely on a CC update, which is the worst possible user experience. The CI tripwire catches the change before release; the runtime fallback keeps the tool usable for users who haven't updated yet.
6. **Compact receipt by default** — the user ran a coding session; they want one number and a quick summary. Three lines max in the default view. Verbose mode for those who want the breakdown.
7. **`command_prefix` only in sidecar** — the sidecar records the first token of the command (e.g., `cargo`), not the full command string, to avoid accidentally logging arguments that could contain paths, tokens, or other sensitive data.

---

## 4. What this costs — accepted trade-offs

- **No per-receipt savings estimate.** The receipt shows actual session cost and lines-folded count, not a counterfactual savings dollar figure. Computing the counterfactual requires knowing the raw token sizes before compression — complex, approximate, and potentially misleading. The benchmark harness (`bench/`) provides the rigorous A/B comparison. Accepted: the receipt is honest about what it knows.
- **Session discovery can fail on concurrent CC sessions.** Two CC sessions running in the same project directory at the same time produce two post-`session_start` JSONLs; the meter skips both. The user can run `vajractl meter <id>` manually. Accepted for v1.
- **`O_APPEND` sidecar is not safe on network filesystems.** Concurrent writes to the sidecar on NFS/SMB may corrupt entries. For v1, local filesystem is assumed. Accepted; the meter degrades gracefully (no compression stats) rather than crashing.
- **Compiled-in pricing requires a binary update for price changes.** Anthropic price changes are infrequent. Users on stale binaries see slightly wrong numbers; the receipt's `[estimated]` marker appears if the formula is suspect. Accepted for v1.

---

## 5. Guardrails this ADR MANDATES (release-blocking for v1)

*(G1–G9 inherited and in force.)*

- **G10 — cwd-slug conformance test.** A CI test asserts that `derive_cwd_slug(cwd)` produces the same directory name that CC actually creates for that CWD. Run against a real `claude --version` invocation in a temp dir. This catches the slug-mismatch failure mode before release.

- **G11 — Tripwire blocks release on schema drift.** The `cost_formula_fixture_v1` test is release-blocking. If it goes red, the release pipeline stops. The fix path: inspect which field changed, update the formula and/or fixture, bump the fixture version, verify by hand, re-green CI.

- **G12 — No content in the sidecar.** The `VAJRA_SESSION_STATS` sidecar records ONLY `lines_in`, `lines_out`, and `command_prefix` (first command token). Full command strings, stdout content, and stderr content are never written to the sidecar. Enforced in `cli/hook.rs` at write time; verified by test.

---

## 6. Open implementation questions (resolve at code time)

- **Does CC flush the JSONL synchronously on exit?** Or is there a race where `child.wait()` returns before the JSONL write completes? If so, add a brief `std::thread::sleep(Duration::from_millis(200))` after `wait()` as a pragmatic guard, or use file-size polling. Test with a real CC session.
- **Does CC print its own cost summary before exit?** If so, decide whether to add a differentiating note to the vajra receipt ("↳ includes subagent costs and cache-tier breakdown") to explain the likely difference.
- **What is `pricing.web_search_per_request` and `pricing.web_fetch_per_request`?** Verify current Anthropic pricing for server-side tool use and add to `bench/pricing.toml`.

---

## 7. Consequences (for the build)

DS4 completes the design of all v1 components. The remaining implementation units (completing ADR-0002 §7):

8. `meter/mod.rs` — `meter_session()` + `SessionCost` / `ModelCost` / `TokenUsage` structs
9. `meter/pricing.rs` — `Pricing` struct + `include_str!("../../bench/pricing.toml")` + `for_model()`
10. `meter/parser.rs` — JSONL line parser + `get_u64_or_warn` + subagent aggregation
11. `meter/receipt.rs` — receipt formatter (compact + verbose)
12. `bench/fixtures/session_v1.jsonl` + `bench/fixtures/expected_v1.json` + `bench/pricing.toml`
13. `tests/meter_tripwire.rs` — G11 tripwire test
14. `cli/launch.rs` updated — add sidecar env var injection + post-exit meter call + receipt print
15. `cli/hook.rs` updated — add sidecar append (G12 content restriction)
16. `cli/` — `vajractl meter` subcommand

After these: the design phase is **complete**. The next phase is implementation (code).

---

## 8. Method note

Three lenses reached consensus on all structural decisions in Round 1. Cross-examination produced two refinements: (1) compact-first receipt format (Practitioner); (2) `command_prefix`-only sidecar (Practitioner, G12). Red-Team produced two amendments: (1) schema drift → warn+estimate rather than hard error (Attack 3); (2) G10 cwd-slug conformance test (Attack 1). G11 (tripwire release gate) and G12 (no content in sidecar) added as new guardrails. No reversals.
