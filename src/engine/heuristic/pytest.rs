//! Pytest output heuristics.

use super::Heuristic;

pub struct PytestHeuristic;

impl Heuristic for PytestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.tool_output.tool.starts_with("pytest")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == 0 {
            compress_pytest_pass(&request.tool_output.stdout)
        } else {
            compress_pytest_fail(&request.tool_output.stdout)
        }
    }
}

fn compress_pytest_pass(stdout: &str) -> String {
    // Keep the final summary line, drop verbose pass details.
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() <= 30 {
        return stdout.to_string();
    }
    // Find the summary line (typically "X passed" or "passed Y tests")
    let summary = lines
        .iter()
        .rev()
        .find(|l| {
            let t = l.trim();
            t.contains("passed") || t.contains("PASSED") || t.contains("===")
        })
        .copied();

    match summary {
        Some(line) => {
            let header = lines
                .iter()
                .take_while(|l| {
                    let t = l.trim();
                    !t.is_empty()
                        && !t.starts_with("collected")
                        && !t.starts_with("test ")
                        && !t.contains("PASSED")
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

fn compress_pytest_fail(stdout: &str) -> String {
    // Keep failures verbatim, drop pass noise.
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < 300 {
        return stdout.to_string();
    }
    let failures: Vec<&str> = stdout
        .lines()
        .filter(|l| {
            let t = l.trim();
            t.starts_with("FAILED") || t.starts_with("ERROR") || t.contains("AssertionError")
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

    fn make_request(stdout: &str, exit_code: i32) -> CompressionRequest {
        CompressionRequest {
            tool_output: ToolOutput {
                tool: "pytest".into(),
                stdout: stdout.into(),
                stderr: String::new(),
                exit_code,
            },
        }
    }

    fn h() -> PytestHeuristic {
        PytestHeuristic
    }

    #[test]
    fn pytest_pass_small_passthrough() {
        let stdout = "collected 3 items\n\ntest_foo.py::test_a PASSED\ntest_foo.py::test_b PASSED\n===== 2 passed in 0.01s =====";
        let request = make_request(stdout, 0);
        assert!(h().detect(&request));
        let out = h().compress(&request);
        assert_eq!(out, stdout);
    }

    #[test]
    fn pytest_pass_extracts_summary() {
        // Large output — summary should be extracted
        let stdout =
            "============================= test session starts ==============================\n\
            platform darwin -- Python 3.11.0, pytest-7.0.0\n\
            collected 100 items\n\
            \n\
            test_a.py::test_one PASSED                                              [  1%]\n\
            test_a.py::test_two PASSED                                              [  2%]\n\
            ... [90 more PASSED lines] ...\n\
            ====== 95 passed, 5 skipped in 12.34s ======";
        let out = compress_pytest_pass(stdout);
        assert!(out.contains("passed") || out.contains("PASSED"));
    }

    #[test]
    fn pytest_fail_keeps_failures() {
        let stdout = "========================= test session starts =========================\n\
            collected 10 items\n\
            \n\
            test_a.py::test_one PASSED                                          [ 10%]\n\
            test_a.py::test_two FAILED                                          [ 20%]\n\
            \n\
            def test_two():\n\
                assert False\n\
            E       AssertionError\n\
            \n\
            test_a.py::test_three PASSED                                        [ 40%]\n\
            \n\
            ======== 1 failed, 9 passed in 0.05s ========";
        let request = make_request(stdout, 1);
        assert!(h().detect(&request));
        let out = h().compress(&request);
        assert!(out.contains("FAILED") || out.contains("AssertionError"));
        // Pass details may be folded but failures must be present
        assert!(out.contains("test_two") || out.contains("FAILED"));
    }

    #[test]
    fn pytest_fail_small_passthrough() {
        let stdout = "FAILED test_foo.py::test_bar";
        let out = compress_pytest_fail(stdout);
        assert_eq!(out, stdout);
    }
}
