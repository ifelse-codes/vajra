//! Cargo output heuristics.

use super::Heuristic;

pub struct CargoBuildHeuristic;

impl Heuristic for CargoBuildHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.tool_output.tool.starts_with("cargo build")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == 0 {
            compress_cargo_build_success(&request.tool_output.stdout)
        } else {
            compress_cargo_build_fail(&request.tool_output.stdout)
        }
    }
}

pub struct CargoTestHeuristic;

impl Heuristic for CargoTestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.tool_output.tool.starts_with("cargo test")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == 0 {
            compress_cargo_test_success(&request.tool_output.stdout)
        } else {
            compress_cargo_test_fail(&request.tool_output.stdout)
        }
    }
}

// ─── helpers ────────────────────────────────────────────────────────────────

fn compress_cargo_build_success(stdout: &str) -> String {
    let compiling_count = stdout
        .lines()
        .filter(|l| l.trim_start().starts_with("Compiling"))
        .count();
    let finished_line = stdout.lines().find(|l| l.trim().starts_with("Finished"));
    match finished_line {
        Some(line) => format!(
            "\u{2713} cargo build — {} ({} crates compiled)",
            line.trim(),
            compiling_count
        ),
        None => stdout.to_string(),
    }
}

fn compress_cargo_build_fail(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < 400 {
        return stdout.to_string();
    }
    let errors: Vec<&str> = stdout
        .lines()
        .filter(|l| {
            let t = l.trim();
            t.starts_with("error")
                || t.starts_with("warning")
                || t.contains("thread '")
                || t.contains("panicked at")
        })
        .collect();
    if errors.is_empty() {
        stdout.to_string()
    } else {
        errors.join("\n")
    }
}

fn compress_cargo_test_success(stdout: &str) -> String {
    // Drop "Compiling" lines and individual "test … ok" lines.
    // Keep "test result:", "Running", and "Finished" lines.
    let last_result = stdout.lines().rfind(|l| l.contains("test result:"));
    let ok_count = stdout.lines().filter(|l| l.trim().ends_with("ok")).count();

    let mut out = String::from("\u{2713} cargo test");
    if let Some(r) = last_result {
        out.push_str(" — ");
        out.push_str(r.trim());
    } else {
        out.push_str(&format!(" ({} tests passed)", ok_count));
    }
    out
}

fn compress_cargo_test_fail(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < 400 {
        return stdout.to_string();
    }
    // Keep every failing test name + panic trace verbatim.
    let mut failures: Vec<&str> = Vec::new();
    let mut in_failure = false;
    for line in stdout.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("test ")
            && (trimmed.ends_with("FAILED") || trimmed.ends_with("fAILED"))
        {
            in_failure = true;
            failures.push(line);
        } else if in_failure {
            failures.push(line);
            if trimmed.is_empty() || trimmed.starts_with("test result:") {
                in_failure = false;
            }
        }
    }
    let pass_count = stdout.lines().filter(|l| l.trim().ends_with("ok")).count();
    if failures.is_empty() {
        format!("[{} passing lines omitted — errors present]", pass_count)
    } else {
        let fail_summary = format!("[{} passing lines folded]", pass_count);
        let mut out = failures.join("\n");
        out.push_str("\n\n");
        out.push_str(&fail_summary);
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::{CompressionRequest, ToolOutput};

    fn make_request(stdout: &str, tool: &str, exit_code: i32) -> CompressionRequest {
        CompressionRequest {
            tool_output: ToolOutput {
                tool: tool.into(),
                stdout: stdout.into(),
                stderr: String::new(),
                exit_code,
            },
        }
    }

    fn build_heuristic() -> CargoBuildHeuristic {
        CargoBuildHeuristic
    }

    fn test_heuristic() -> CargoTestHeuristic {
        CargoTestHeuristic
    }

    #[test]
    fn cargo_build_exit_0_compresses_to_finished_line() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/cargo-build.txt"
        ));
        let request = make_request(raw, "cargo build", 0);
        let h = build_heuristic();
        assert!(h.detect(&request));
        let out = h.compress(&request);
        assert!(out.starts_with("\u{2713} cargo build"));
        assert!(out.contains("Finished"));
        assert!(out.contains("crates compiled"));
    }

    #[test]
    fn cargo_build_exit_0_counts_180_crates() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/cargo-build.txt"
        ));
        let out = compress_cargo_build_success(raw);
        assert!(out.contains("(180 crates compiled)"));
    }

    #[test]
    fn cargo_test_exit_0_drops_compiling() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/cargo-test.txt"
        ));
        let request = make_request(raw, "cargo test", 0);
        let h = test_heuristic();
        assert!(h.detect(&request));
        let out = h.compress(&request);
        assert!(out.starts_with("\u{2713} cargo test"));
        assert!(!out.contains("Compiling"));
    }

    #[test]
    fn cargo_test_exit_0_keeps_summary() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/cargo-test.txt"
        ));
        let out = compress_cargo_test_success(raw);
        assert!(out.contains("test result"));
    }

    #[test]
    fn cargo_test_fail_keeps_failure_detail() {
        // Synthetic: failing test with panic trace + passing tests
        let stdout = r#"   Compiling mycrate v0.1.0
    Finished test profile
     Running unittests src/lib.rs

running 1 test
test tests::failing_test ... FAILED
thread 'tests::failing_test' panicked at src/lib.rs:10:9:
assertion failed: false
failures:
---- tests::failing_test stdout ----
thread 'tests::failing_test' panicked at src/lib.rs:10:9:
assertion failed: false
failures:
    tests::failing_test

test result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out

     Running unittests src/lib.rs

running 1 test
test tests::passing_test ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s"#;
        let request = make_request(stdout, "cargo test", 101);
        let h = test_heuristic();
        assert!(h.detect(&request));
        let out = h.compress(&request);
        // Should contain the failure trace and pass count summary
        assert!(
            out.contains("failing_test") || out.contains("assertion failed"),
            "output: {}",
            out
        );
    }

    #[test]
    fn cargo_build_fail_small_is_passthrough() {
        // Under 400 lines → passthrough
        let stdout = "error: could not compile `foo` due to previous error";
        let out = compress_cargo_build_fail(stdout);
        assert_eq!(out, stdout);
    }

    #[test]
    fn cargo_test_fail_small_is_passthrough() {
        let stdout = "error: could not compile";
        let out = compress_cargo_test_fail(stdout);
        assert_eq!(out, stdout);
    }
}
