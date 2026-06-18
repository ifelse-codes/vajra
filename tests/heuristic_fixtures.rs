use vajractl::engine::{CompressionRequest, DefaultEngine, Engine, EngineDecision, ToolOutput};

fn make_request(tool: &str, stdout: &str) -> CompressionRequest {
    CompressionRequest {
        tool_output: ToolOutput {
            tool: tool.into(),
            stdout: stdout.into(),
            stderr: "".into(),
            exit_code: 0,
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
        EngineDecision::Compress { tool, output } => {
            assert_eq!(tool, "cargo build");
            // Should contain "Finished" and "crates compiled"
            assert!(
                output.contains("Finished") || output.contains("crates"),
                "expected Finished/crates, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compress, got Passthrough"),
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
        EngineDecision::Compress { output, .. } => {
            // Should contain test suite info (ok / passed / test result markers)
            assert!(
                output.contains("test result")
                    || output.contains("passed")
                    || output.contains("ok"),
                "expected test results, got: {}",
                output
            );
            // Compile noise should be dropped by CargoTestHeuristic
            assert!(
                !output.contains("Compiling"),
                "compile noise should be dropped, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compress, got Passthrough"),
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
    match decision {
        EngineDecision::Compress { output, .. } => {
            // git-log.txt is 20 lines, under LINE_CAP=200, should pass through unchanged
            assert_eq!(
                output, stdout,
                "git log output should passthrough unchanged"
            );
        }
        EngineDecision::Passthrough => panic!("git log returned passthrough unexpectedly"),
    }
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
    match decision {
        EngineDecision::Compress { output, .. } => {
            assert_eq!(
                output, stdout,
                "git status output should passthrough unchanged"
            );
        }
        EngineDecision::Passthrough => panic!("git status returned passthrough unexpectedly"),
    }
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
    match decision {
        EngineDecision::Compress { output, .. } => {
            assert_eq!(
                output, stdout,
                "git diff --stat output should passthrough unchanged"
            );
        }
        EngineDecision::Passthrough => panic!("git diff --stat returned passthrough unexpectedly"),
    }
}

#[test]
fn generic_over_cap_truncates() {
    let engine = DefaultEngine;
    let lines: Vec<String> = (0..250).map(|i| format!("line {}", i)).collect();
    let stdout = lines.join("\n");
    let request = make_request("echo", &stdout);
    let decision = engine.decide(&request);
    match decision {
        EngineDecision::Compress { output, .. } => {
            assert!(
                output.contains("[230 lines hidden]"),
                "expected truncation marker, got: {}",
                output
            );
        }
        EngineDecision::Passthrough => panic!("expected Compress, got Passthrough"),
    }
}

#[test]
fn generic_under_cap_passthrough() {
    let engine = DefaultEngine;
    let stdout = "hello\nworld";
    let request = make_request("echo", stdout);
    let decision = engine.decide(&request);
    match decision {
        EngineDecision::Compress { output, .. } => {
            assert_eq!(output, stdout, "output should passthrough unchanged");
        }
        EngineDecision::Passthrough => panic!("expected Compress, got Passthrough"),
    }
}
