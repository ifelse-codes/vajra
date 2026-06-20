use vajractl::adapter::ClaudeCodeHookAdapter;
use vajractl::engine::DefaultEngine;

fn run_adapter(json_in: &str) -> String {
    let adapter = ClaudeCodeHookAdapter::new(DefaultEngine);
    let mut input = json_in.as_bytes();
    let mut output = Vec::new();
    let _ = adapter.run(&mut input, &mut output);
    String::from_utf8(output).expect("adapter output must be valid UTF-8")
}

fn cargo_build_hook_json(stdout: &str) -> String {
    let escaped = serde_json::to_string(stdout).unwrap();
    format!(
        r#"{{"toolName":"Bash","toolInput":{{"command":"cargo build"}},"toolResponse":{{"stdout":{escaped},"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}}}"#
    )
}

#[test]
fn passthrough_non_bash_tool() {
    let json = r#"{"toolName":"Read","toolInput":{},"toolResponse":{"stdout":"file content","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "non-Bash tool must passthrough");
}

#[test]
fn passthrough_is_image() {
    let json = r#"{"toolName":"Bash","toolInput":{"command":"cat image.png"},"toolResponse":{"stdout":"","stderr":"","interrupted":false,"isImage":true,"noOutputExpected":false,"exitCode":0}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "image response must passthrough");
}

#[test]
fn passthrough_no_output_expected() {
    let json = r#"{"toolName":"Bash","toolInput":{"command":"touch foo"},"toolResponse":{"stdout":"","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":true,"exitCode":0}}"#;
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
    let json = cargo_build_hook_json("Compiling foo v0.1\nFinished dev profile");
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
    let json = cargo_build_hook_json(raw);
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
        updated_stdout.contains("lines hidden"),
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
fn passthrough_short_bash_output() {
    // Short output (under LINE_CAP) → Passthrough → "{}"
    let json = r#"{"toolName":"Bash","toolInput":{"command":"echo hello"},"toolResponse":{"stdout":"hello\nworld","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}"#;
    let out = run_adapter(json);
    assert_eq!(out, "{}", "short output should passthrough");
}
