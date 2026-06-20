use vajractl::engine::{CompressionRequest, DefaultEngine, Engine, EngineDecision, ToolOutput};

fn make_request(command: &str, stdout: &str) -> CompressionRequest {
    CompressionRequest {
        command: command.into(),
        tool_output: ToolOutput {
            stdout: stdout.into(),
            stderr: "".into(),
            exit_code: Some(0),
            interrupted: false,
        },
    }
}

#[test]
fn cargo_build_fixture_compresses() {
    let engine = DefaultEngine;
    let stdout = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/cargo-build.txt"
    ));
    let request = make_request("cargo build", stdout);
    let decision = engine.decide(&request);
    match decision {
        EngineDecision::Compressed {
            output,
            lines_removed,
        } => {
            assert!(
                lines_removed > 0,
                "expected compression, got same line count"
            );
            assert!(
                output.contains("Finished") || output.contains("crates"),
                "expected Finished/crates, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compressed, got Passthrough"),
    }
}

#[test]
fn cargo_test_fixture_drops_compile_noise() {
    let engine = DefaultEngine;
    let stdout = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/cargo-test.txt"
    ));
    let request = make_request("cargo test", stdout);
    let decision = engine.decide(&request);
    match decision {
        EngineDecision::Compressed { output, .. } => {
            assert!(
                output.contains("test result")
                    || output.contains("passed")
                    || output.contains("ok"),
                "expected test results, got: {}",
                output
            );
            assert!(
                !output.contains("Compiling"),
                "compile noise should be dropped, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compressed, got Passthrough"),
    }
}

#[test]
fn git_log_fixture_passthrough() {
    let engine = DefaultEngine;
    let stdout = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/git-log.txt"
    ));
    let request = make_request("git log", stdout);
    let decision = engine.decide(&request);
    // git-log.txt is 20 lines (< LINE_CAP=200) — no compression, expect Passthrough
    assert!(
        matches!(decision, EngineDecision::Passthrough),
        "git log short output should passthrough"
    );
}

#[test]
fn git_status_fixture_passthrough() {
    let engine = DefaultEngine;
    let stdout = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/git-status.txt"
    ));
    let request = make_request("git status", stdout);
    let decision = engine.decide(&request);
    assert!(
        matches!(decision, EngineDecision::Passthrough),
        "git status should always passthrough"
    );
}

#[test]
fn git_diff_stat_fixture_passthrough() {
    let engine = DefaultEngine;
    let stdout = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/research/compression-fixtures/raw/git-diff-stat.txt"
    ));
    let request = make_request("git diff --stat", stdout);
    let decision = engine.decide(&request);
    assert!(
        matches!(decision, EngineDecision::Passthrough),
        "git diff --stat should always passthrough"
    );
}

#[test]
fn generic_over_cap_truncates() {
    let engine = DefaultEngine;
    let lines: Vec<String> = (0..250).map(|i| format!("line {}", i)).collect();
    let stdout = lines.join("\n");
    let request = make_request("echo", &stdout);
    let decision = engine.decide(&request);
    match decision {
        EngineDecision::Compressed { output, .. } => {
            assert!(
                output.contains("[230 hidden]"),
                "expected truncation marker, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compressed, got Passthrough"),
    }
}

#[test]
fn generic_under_cap_passthrough() {
    let engine = DefaultEngine;
    let stdout = "hello\nworld";
    let request = make_request("echo", stdout);
    let decision = engine.decide(&request);
    assert!(
        matches!(decision, EngineDecision::Passthrough),
        "short output should passthrough"
    );
}
