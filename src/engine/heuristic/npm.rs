//! npm test output heuristics.

use super::Heuristic;

pub struct NpmTestHeuristic;

impl Heuristic for NpmTestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        let tool = &request.tool_output.tool;
        tool.starts_with("npm test") || tool.starts_with("npm run test")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == 0 {
            compress_npm_test_pass(&request.tool_output.stdout)
        } else {
            compress_npm_test_fail(&request.tool_output.stdout)
        }
    }
}

fn compress_npm_test_pass(stdout: &str) -> String {
    // Small output passes through; large output gets folded to summary.
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() <= 30 {
        return stdout.to_string();
    }
    // Find the summary line (common patterns: "Tests:", "Test Suites:", "passed", "PASS")
    let summary = lines
        .iter()
        .rev()
        .find(|l| {
            let t = l.trim();
            t.contains("passed")
                || t.contains("PASS")
                || t.contains("Tests:")
                || t.contains("Test Suites:")
        })
        .copied();

    match summary {
        Some(line) => {
            let header: String = lines
                .iter()
                .take_while(|l| {
                    let t = l.trim();
                    !t.is_empty()
                        && !t.starts_with(" PASS ")
                        && !t.starts_with("  ✓")
                        && !t.ends_with("PASSED")
                        && !t.contains(" ms)")
                        && !t.contains(" s)")
                        && !t.contains("passed (")
                })
                .copied()
                .collect::<Vec<_>>()
                .join("\n");
            if header.is_empty() {
                line.to_string()
            } else {
                format!("{}\n{}", header, line)
            }
        }
        None => stdout.to_string(),
    }
}

fn compress_npm_test_fail(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < 300 {
        return stdout.to_string();
    }
    // Keep failure lines, test names, and error messages
    let failures: Vec<&str> = stdout
        .lines()
        .filter(|l| {
            let t = l.trim();
            t.starts_with("FAIL")
                || t.starts_with("●")
                || t.contains("FAIL")
                || t.starts_with("  ✗")
                || t.contains("Error:")
                || t.contains("expected")
                || t.contains("received")
        })
        .collect();

    if failures.is_empty() {
        stdout.to_string()
    } else {
        failures.join("\n")
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

    fn h() -> NpmTestHeuristic {
        NpmTestHeuristic
    }

    #[test]
    fn npm_test_detects_npm_test() {
        let request = make_request("", "npm test", 0);
        assert!(h().detect(&request));
    }

    #[test]
    fn npm_run_test_detects_npm_run_test() {
        let request = make_request("", "npm run test", 0);
        assert!(h().detect(&request));
    }

    #[test]
    fn npm_test_passthrough_small() {
        let stdout =
            "PASS test/foo.test.js\n\n  Console\n    2 tests passed\n\nTests: 2 passed, 2 total";
        let request = make_request(stdout, "npm test", 0);
        let out = h().compress(&request);
        assert_eq!(out, stdout);
    }

    #[test]
    fn npm_test_pass_folds_large_output() {
        // Simulate 200+ lines of pass output
        let lines: Vec<String> = (0..200)
            .map(|i| format!(" PASS  test/spec{}.test.js (X ms)", i))
            .collect();
        let stdout = format!(
            "Test Suites: 100 suites, 500 tests\n{}\nTests: 500 passed, 500 total",
            lines.join("\n")
        );
        let out = compress_npm_test_pass(&stdout);
        assert!(out.contains("500 passed") || out.contains("passed"));
        // Should NOT contain individual PASS lines
        assert!(!out.contains("PASS  test/spec0.test.js"));
    }

    #[test]
    fn npm_test_fail_keeps_failures() {
        let stdout = "FAIL test/bar.test.js\n  ● test_baz (5 ms)\n\n    expect(received).toBe(expected)\n\n    12 |   expect(a).toBe(b);\n    13 | });\n\nTests: 1 failed, 5 passed, 6 total";
        let request = make_request(stdout, "npm test", 1);
        let out = h().compress(&request);
        assert!(
            out.contains("FAIL") || out.contains("test_baz") || out.contains("expected"),
            "output: {}",
            out
        );
    }

    #[test]
    fn npm_test_fail_small_passthrough() {
        let stdout = "FAIL test/foo.test.js\n  ● test_one\n\n    Error: unexpected";
        let out = compress_npm_test_fail(stdout);
        assert_eq!(out, stdout);
    }
}
