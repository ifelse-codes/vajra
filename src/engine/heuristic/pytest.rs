//! Pytest output heuristics.

use super::Heuristic;

pub struct PytestHeuristic;

impl Heuristic for PytestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.command.starts_with("pytest")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == Some(0) {
            compress_pytest_pass(&request.tool_output.stdout)
        } else {
            compress_pytest_fail(&request.tool_output.stdout)
        }
    }

    fn preserves_failure_signal(&self) -> bool {
        true
    }
}

fn compress_pytest_pass(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() <= 30 {
        return stdout.to_string();
    }
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
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < super::FAIL_COMPRESS_FLOOR {
        return stdout.to_string();
    }
    // Keep AC3 failure-signal lines + last summary line + fold notice (Gap B, S148).
    let summary = lines
        .iter()
        .rev()
        .find(|l| l.contains("passed") || l.contains("failed") || l.contains("==="))
        .copied();
    let kept: Vec<&str> = lines
        .iter()
        .filter(|l| super::is_failure_line(l))
        .copied()
        .collect();
    let kept_count = kept.len() + summary.map_or(0, |_| 1);
    let dropped = lines.len().saturating_sub(kept_count);
    let mut out = kept.join("\n");
    if let Some(s) = summary {
        if !out.is_empty() {
            out.push('\n');
        }
        out.push_str(s);
    }
    if dropped > 0 {
        if !out.is_empty() {
            out.push('\n');
        }
        out.push_str(&super::fold_notice(dropped));
    }
    if out.is_empty() {
        stdout.to_string()
    } else {
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::{CompressionRequest, ToolOutput};

    fn make_request(stdout: &str, exit_code: i32) -> CompressionRequest {
        CompressionRequest {
            command: "pytest".into(),
            tool_output: ToolOutput {
                stdout: stdout.into(),
                stderr: String::new(),
                exit_code: Some(exit_code),
                interrupted: false,
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
        assert!(out.contains("test_two") || out.contains("FAILED"));
    }

    #[test]
    fn pytest_fail_small_passthrough() {
        let stdout = "FAILED test_foo.py::test_bar";
        let out = compress_pytest_fail(stdout);
        assert_eq!(out, stdout);
    }

    // ── Gap B: pytest fail-path for 20–399 lines (S148) ─────────────────────

    #[test]
    fn pytest_fail_gap_b_preserves_failed_line() {
        // 25-line output with FAILED line — must survive
        let mut lines: Vec<String> = (0..23)
            .map(|i| format!("test_module.py::test_pass_{} PASSED", i))
            .collect();
        lines.push("test_module.py::test_broken FAILED".into());
        lines.push("====== 1 failed, 23 passed in 0.12s ======".into());
        let stdout = lines.join("\n");
        let out = compress_pytest_fail(&stdout);
        assert!(
            out.contains("FAILED"),
            "FAILED line must be preserved: {}",
            out
        );
        assert!(out.contains("passed"), "summary must be preserved: {}", out);
        assert!(
            out.contains("[vajra]") && out.contains("VAJRA_RAW=1"),
            "fold notice must be present: {}",
            out
        );
        assert!(
            out.lines().count() < stdout.lines().count(),
            "compressed output must be shorter than input"
        );
    }

    #[test]
    fn pytest_fail_floor_passthrough() {
        // 19 lines — below FAIL_COMPRESS_FLOOR — byte-identical passthrough
        let lines: Vec<String> = (0..19)
            .map(|i| format!("test_module.py::test_{} PASSED", i))
            .collect();
        let stdout = lines.join("\n");
        assert_eq!(compress_pytest_fail(&stdout), stdout);
    }

    #[test]
    fn pytest_preserves_failure_signal_override() {
        assert!(h().preserves_failure_signal());
    }
}
