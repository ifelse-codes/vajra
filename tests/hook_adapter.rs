use vajractl::adapter::ClaudeCodeHookAdapter;
use vajractl::engine::DefaultEngine;

fn run_adapter(json_in: &str) -> String {
    let adapter = ClaudeCodeHookAdapter::new(DefaultEngine);
    let mut input = json_in.as_bytes();
    let mut output = Vec::new();
    let _ = adapter.run(&mut input, &mut output);
    String::from_utf8(output).expect("adapter output must be valid UTF-8")
}

/// Real Claude Code PostToolUse hook shape (captured, S31): top-level keys are
/// snake_case (tool_name/tool_input/tool_response); the nested tool_response
/// object is camelCase (isImage/noOutputExpected) and Bash omits exitCode
/// entirely (exit_code is inferred from the tail, not sent).
fn real_cc_payload(command: &str, stdout: &str) -> String {
    let escaped_stdout = serde_json::to_string(stdout).unwrap();
    let escaped_command = serde_json::to_string(command).unwrap();
    format!(
        r#"{{"session_id":"abc123","transcript_path":"/tmp/t.jsonl","cwd":"/repo","permission_mode":"default","effort":"medium","hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{{"command":{escaped_command}}},"tool_response":{{"stdout":{escaped_stdout},"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false}},"tool_use_id":"toolu_01","duration_ms":842}}"#
    )
}

/// Same snake_case top-level shape, but with an explicit `exitCode` — used where a test
/// wants to pin success deterministically rather than exercise tail-based `infer_success`.
fn real_cc_payload_with_exit_code(command: &str, stdout: &str, exit_code: i32) -> String {
    let escaped_stdout = serde_json::to_string(stdout).unwrap();
    let escaped_command = serde_json::to_string(command).unwrap();
    format!(
        r#"{{"tool_name":"Bash","tool_input":{{"command":{escaped_command}}},"tool_response":{{"stdout":{escaped_stdout},"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":{exit_code}}}}}"#
    )
}

#[test]
fn passthrough_non_bash_tool() {
    let json = r#"{"tool_name":"Read","tool_input":{},"tool_response":{"stdout":"file content","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "non-Bash tool must passthrough");
}

#[test]
fn passthrough_is_image() {
    let json = r#"{"tool_name":"Bash","tool_input":{"command":"cat image.png"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":true,"noOutputExpected":false}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "image response must passthrough");
}

#[test]
fn passthrough_no_output_expected() {
    let json = r#"{"tool_name":"Bash","tool_input":{"command":"touch foo"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":true}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "noOutputExpected must passthrough");
}

#[test]
fn passthrough_malformed_json() {
    let out = run_adapter("this is not json");
    assert_eq!(out, "{}", "malformed JSON must fail-open to passthrough");
}

#[test]
fn passthrough_vajra_raw_env() {
    std::env::set_var("VAJRA_RAW", "1");
    let json = real_cc_payload_with_exit_code(
        "cargo build",
        "Compiling foo v0.1\nFinished dev profile",
        0,
    );
    let out = run_adapter(&json);
    std::env::remove_var("VAJRA_RAW");
    assert_eq!(out, "{}", "VAJRA_RAW=1 must passthrough before stdin read");
}

#[test]
fn compression_bash_cargo_build_produces_updated_output() {
    let raw = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/cargo-build.txt"
    ));
    let json = real_cc_payload_with_exit_code("cargo build", raw, 0);
    let out = run_adapter(&json);

    // Must not be bare passthrough
    assert_ne!(out, "{}", "cargo build fixture should be compressed");

    let parsed: serde_json::Value = serde_json::from_str(&out).expect("output must be valid JSON");
    let updated_stdout = parsed["hookSpecificOutput"]["updatedToolOutput"]["stdout"]
        .as_str()
        .expect("updatedToolOutput.stdout must be a string");

    assert!(
        updated_stdout.contains("Finished") || updated_stdout.contains("crates"),
        "compressed stdout should contain build summary, got: {}",
        updated_stdout
    );
    assert!(
        updated_stdout.contains("lines folded"),
        "breadcrumb must be present, got: {}",
        updated_stdout
    );
    assert!(
        updated_stdout.contains("VAJRA_RAW=1"),
        "breadcrumb must mention VAJRA_RAW, got: {}",
        updated_stdout
    );
}

#[test]
fn real_cc_payload_folds_not_passthrough() {
    // Regression for S31 finding #2: HookInput previously required camelCase top-level
    // keys (toolName/toolInput/toolResponse), which real Claude Code never sends —
    // every real payload silently failed to parse and fell through to "{}" passthrough.
    //
    // Uses a >=FAIL_PASSTHROUGH_CAP-line generic (non-cargo/npm/pytest) command so this
    // test isolates the schema question. Real CC always omits exit_code for Bash, and
    // `is_success` only recognizes cargo/pytest tail markers — so anything else defaults
    // to "failure" and the fold only proceeds once output is large. (Two separate, deeper
    // gaps out of this fix's scope: cargo/npm/pytest heuristics key off `exit_code ==
    // Some(0)` directly rather than the engine's inferred success, and `infer_success`
    // has no generic-command success signal at all when exit_code is absent.)
    let lines: Vec<String> = (0..450).map(|i| format!("src/file_{i}.rs")).collect();
    let raw = lines.join("\n");
    let json = real_cc_payload("find . -name *.rs", &raw);
    let out = run_adapter(&json);

    assert_ne!(
        out, "{}",
        "a real-shaped CC payload must fold, not silently passthrough"
    );
    let parsed: serde_json::Value = serde_json::from_str(&out).expect("output must be valid JSON");
    let updated_stdout = parsed["hookSpecificOutput"]["updatedToolOutput"]["stdout"]
        .as_str()
        .expect("updatedToolOutput.stdout must be a string");
    assert!(
        updated_stdout.contains("lines folded"),
        "breadcrumb must be present, got: {}",
        updated_stdout
    );
}

#[test]
fn camel_case_top_level_is_not_the_real_shape_and_still_passthroughs() {
    // Documents the OLD (wrong) fixture shape this test suite used before S31: camelCase
    // top-level keys (toolName/toolInput/toolResponse). Real Claude Code never sends this —
    // it is not a supported alternate wire format, so it correctly fails to parse and
    // fails open to passthrough, same as any other malformed input.
    let json = r#"{"toolName":"Bash","toolInput":{"command":"cargo build"},"toolResponse":{"stdout":"a\nb\nc","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}"#;
    let out = run_adapter(json);
    assert_eq!(
        out, "{}",
        "camelCase top-level is not real CC's shape; must fail-open to passthrough"
    );
}

#[test]
fn passthrough_short_bash_output() {
    // Short output (under LINE_CAP) → Passthrough → "{}"
    let json = r#"{"tool_name":"Bash","tool_input":{"command":"echo hello"},"tool_response":{"stdout":"hello\nworld","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "short output should passthrough");
}

// ─── S41: fail-gate no longer blocks the known-safe format-aware folds ────────
//
// Root cause (S36, proven): real CC omits `exitCode` for Bash → `is_success`
// infers "failure" → the fail-gate blocked EVERY 30–399-line command (0 folds
// live). S41 scopes that gate to heuristics that do NOT guarantee the failure
// signal survives; the git family folds lossy-SAFE for its format, so it now
// folds regardless of exit code. The generic/unknown path stays gated —
// correctness-first, never gamble (founder directive).

#[test]
fn git_log_no_exit_code_folds_after_s41() {
    // THE WIN: a large `git log` with no exitCode passed through before S41
    // (silently — the S36 "0 folds live" bug); it must fold now.
    let raw: String = (0..60)
        .map(|i| format!("{i:04x} commit message {i}"))
        .collect::<Vec<_>>()
        .join("\n");
    let json = real_cc_payload("git log --oneline -60", &raw);
    let out = run_adapter(&json);

    assert_ne!(out, "{}", "git log (no exitCode) must fold after S41");
    let parsed: serde_json::Value = serde_json::from_str(&out).expect("valid JSON");
    let updated = parsed["hookSpecificOutput"]["updatedToolOutput"]["stdout"]
        .as_str()
        .expect("updatedToolOutput.stdout is a string");
    assert!(
        updated.contains("lines folded"),
        "breadcrumb missing: {updated}"
    );
    // Recoverable / never-drop-the-tail: the newest commit survives head+tail.
    assert!(
        updated.contains("commit message 59"),
        "tail (newest commit) must survive the fold: {updated}"
    );
}

#[test]
fn genuine_failure_no_exit_code_passthroughs_both_ways() {
    // INVARIANT #1 (never hide a failure): a generic command that failed but sent
    // no exitCode — and whose error is NOT in the last lines — must NOT be folded.
    // The generic path is not format-aware, so it stays gated. Passthrough before
    // AND after S41; this is the regression that must never flip.
    let mut lines = vec![String::from("error: could not find configuration file")];
    lines.extend((0..80).map(|i| format!("  ...retrying step {i}")));
    let raw = lines.join("\n");
    let json = real_cc_payload("./deploy.sh", &raw);
    let out = run_adapter(&json);
    assert_eq!(
        out, "{}",
        "a marker-less-tail failure on the generic path must passthrough — never gamble"
    );
}

#[test]
fn generic_ls_no_exit_code_stays_conservative() {
    // The generic/unknown path stays gated after S41 — an ordinary `ls` with no
    // exitCode (<FAIL_PASSTHROUGH_CAP lines) is NOT folded. Prefer passthrough
    // over a risky generic fold; folding little here is acceptable per the
    // guiding principle. Full passthrough trivially preserves the tail.
    let raw: String = (0..80)
        .map(|i| format!("src/file_{i}.rs"))
        .collect::<Vec<_>>()
        .join("\n");
    let json = real_cc_payload("ls -1 src", &raw);
    let out = run_adapter(&json);
    assert_eq!(
        out, "{}",
        "generic ls (no exitCode, under cap) stays passthrough — conservative"
    );
}
