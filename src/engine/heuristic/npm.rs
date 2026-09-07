//! npm test and jest output heuristics.

use super::Heuristic;

pub struct NpmTestHeuristic;

impl Heuristic for NpmTestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        let cmd = &request.command;
        cmd.starts_with("npm test") || cmd.starts_with("npm run test")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == Some(0) {
            compress_npm_test_pass(&request.tool_output.stdout)
        } else {
            compress_jest_family_fail(&request.tool_output.stdout)
        }
    }

    fn preserves_failure_signal(&self) -> bool {
        true
    }
}

/// Gap A (S148): detect bare `jest` command.
pub struct JestHeuristic;

impl Heuristic for JestHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        // Matches `jest` and `jest <flags>` (bare command). `npx jest` is
        // intentionally excluded — it starts with "npx", not "jest", and
        // would require a separate dispatch arm in mod.rs (S148 scope: bare only).
        request.command.starts_with("jest")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        if request.tool_output.exit_code == Some(0) {
            compress_jest_pass(&request.tool_output.stdout)
        } else {
            compress_jest_family_fail(&request.tool_output.stdout)
        }
    }

    fn preserves_failure_signal(&self) -> bool {
        true
    }
}

fn compress_npm_test_pass(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() <= 30 {
        return stdout.to_string();
    }
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

/// Shared fail-path compressor for npm test and jest (Gap B, S148).
/// Preserves failure-signal lines (AC3) + summary line (AC2) + fold notice (AC4).
/// Passthrough below FAIL_COMPRESS_FLOOR lines (AC7) or when no "Tests:" summary
/// is found (AC5 — non-matching output returned byte-identical).
fn compress_jest_family_fail(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() < super::FAIL_COMPRESS_FLOOR {
        return stdout.to_string();
    }
    // AC5: no "Tests:" summary → not test-runner output → passthrough unchanged.
    let summary = lines
        .iter()
        .rev()
        .find(|l| l.contains("Tests:"))
        .copied();
    let Some(summary_line) = summary else {
        return stdout.to_string();
    };
    let kept: Vec<&str> = lines
        .iter()
        .filter(|l| super::is_failure_line(l))
        .copied()
        .collect();
    let kept_count = kept.len() + 1; // +1 for summary_line
    let dropped = lines.len().saturating_sub(kept_count);
    let mut out = kept.join("\n");
    if !out.is_empty() {
        out.push('\n');
    }
    out.push_str(summary_line);
    if dropped > 0 {
        out.push('\n');
        out.push_str(&super::fold_notice(dropped));
    }
    out
}

/// Pass-path compressor for bare jest (Gap A, S148).
fn compress_jest_pass(stdout: &str) -> String {
    let lines: Vec<&str> = stdout.lines().collect();
    if lines.len() <= super::FAIL_COMPRESS_FLOOR {
        return stdout.to_string();
    }
    let summary = lines
        .iter()
        .rev()
        .find(|l| l.contains("Tests:") && (l.contains("passed") || l.contains("total")))
        .copied();
    match summary {
        Some(s) => {
            let dropped = lines.len() - 1;
            format!("{}\n{}", s, super::fold_notice(dropped))
        }
        None => stdout.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::{CompressionRequest, ToolOutput};

    fn make_request(stdout: &str, command: &str, exit_code: i32) -> CompressionRequest {
        CompressionRequest {
            command: command.into(),
            tool_output: ToolOutput {
                stdout: stdout.into(),
                stderr: String::new(),
                exit_code: Some(exit_code),
                interrupted: false,
            },
        }
    }

    fn npm() -> NpmTestHeuristic {
        NpmTestHeuristic
    }

    fn jest() -> JestHeuristic {
        JestHeuristic
    }

    // ── existing npm tests ────────────────────────────────────────────────────

    #[test]
    fn npm_test_detects_npm_test() {
        assert!(npm().detect(&make_request("", "npm test", 0)));
    }

    #[test]
    fn npm_run_test_detects_npm_run_test() {
        assert!(npm().detect(&make_request("", "npm run test", 0)));
    }

    #[test]
    fn npm_test_passthrough_small() {
        let stdout =
            "PASS test/foo.test.js\n\n  Console\n    2 tests passed\n\nTests: 2 passed, 2 total";
        let out = npm().compress(&make_request(stdout, "npm test", 0));
        assert_eq!(out, stdout);
    }

    #[test]
    fn npm_test_pass_folds_large_output() {
        let lines: Vec<String> = (0..200)
            .map(|i| format!(" PASS  test/spec{}.test.js (X ms)", i))
            .collect();
        let stdout = format!(
            "Test Suites: 100 suites, 500 tests\n{}\nTests: 500 passed, 500 total",
            lines.join("\n")
        );
        let out = compress_npm_test_pass(&stdout);
        assert!(out.contains("500 passed") || out.contains("passed"));
        assert!(!out.contains("PASS  test/spec0.test.js"));
    }

    #[test]
    fn npm_test_fail_short_passthrough() {
        // 9 lines — below FAIL_COMPRESS_FLOOR(20) — must be byte-identical
        let stdout = "FAIL test/bar.test.js\n  ● test_baz (5 ms)\n\n    expect(received).toBe(expected)\n\n    12 |   expect(a).toBe(b);\n    13 | });\n\nTests: 1 failed, 5 passed, 6 total";
        let out = npm().compress(&make_request(stdout, "npm test", 1));
        assert_eq!(out, stdout, "short fail must passthrough unchanged");
    }

    // ── Gap B: npm test fail-path for 20–399 lines ────────────────────────────

    #[test]
    fn npm_fail_gap_b_preserves_failed_line() {
        // 25 lines with one FAILED line — must appear in output
        let mut lines: Vec<String> = (0..23)
            .map(|i| format!("  ✓ test_passing_{} (1 ms)", i))
            .collect();
        lines.push("  ✕ test_broken FAILED".to_string());
        lines.push("Tests: 1 failed, 23 passed, 24 total".to_string());
        let stdout = lines.join("\n");
        let out = compress_jest_family_fail(&stdout);
        assert!(out.contains("FAILED"), "FAILED line must be preserved: {}", out);
        assert!(out.contains("Tests:"), "summary line must be preserved: {}", out);
        assert!(
            out.contains("lines folded"),
            "fold notice must be present: {}",
            out
        );
        assert!(
            out.lines().count() < stdout.lines().count(),
            "compressed output must be shorter than input"
        );
    }

    #[test]
    fn npm_fail_gap_b_notice_format() {
        // Verify exact notice format from AC4
        let mut lines: Vec<String> = (0..23)
            .map(|i| format!("  ✓ passing_{}", i))
            .collect();
        lines.push("  something FAILED here".to_string());
        lines.push("Tests: 1 failed, 23 passed, 24 total".to_string());
        let stdout = lines.join("\n");
        let out = compress_jest_family_fail(&stdout);
        assert!(
            out.contains("[vajra]") && out.contains("lines folded") && out.contains("VAJRA_RAW=1"),
            "notice must match AC4 format: {}",
            out
        );
    }

    #[test]
    fn npm_fail_floor_passthrough() {
        // Exactly 19 lines — below floor — byte-identical passthrough
        let lines: Vec<String> = (0..19).map(|i| format!("line {}", i)).collect();
        let stdout = lines.join("\n");
        assert_eq!(compress_jest_family_fail(&stdout), stdout);
    }

    // ── Gap A: JestHeuristic detection and compression ────────────────────────

    #[test]
    fn jest_detects_bare_jest() {
        assert!(jest().detect(&make_request("", "jest", 0)));
        assert!(jest().detect(&make_request("", "jest --watchAll=false", 0)));
    }

    #[test]
    fn jest_does_not_detect_npm() {
        assert!(!jest().detect(&make_request("", "npm test", 0)));
    }

    #[test]
    fn jest_pass_summary_preserved() {
        // 25-line passing jest output — summary line must survive
        let mut lines: Vec<String> = (0..23)
            .map(|i| format!("  ✓ test_{} (1 ms)", i))
            .collect();
        lines.push("Tests: 23 passed, 23 total".to_string());
        lines.push("".to_string());
        let stdout = lines.join("\n");
        let out = jest().compress(&make_request(&stdout, "jest", 0));
        assert!(
            out.contains("Tests: 23 passed"),
            "summary must be preserved: {}",
            out
        );
    }

    #[test]
    fn jest_pass_small_passthrough() {
        let stdout = "PASS src/foo.test.js\nTests: 3 passed, 3 total";
        let out = jest().compress(&make_request(stdout, "jest", 0));
        assert_eq!(out, stdout);
    }

    #[test]
    fn jest_fail_preserves_failed_line() {
        // 25 lines with a ✕ failure marker
        let mut lines: Vec<String> = (0..22)
            .map(|i| format!("  ✓ passing_{} (1 ms)", i))
            .collect();
        lines.push("  \u{2715} broken_test (5 ms)".to_string()); // ✕
        lines.push("Tests: 1 failed, 22 passed, 23 total".to_string());
        lines.push("".to_string());
        let stdout = lines.join("\n");
        let out = jest().compress(&make_request(&stdout, "jest", 1));
        assert!(
            out.contains('\u{2715}'),
            "✕ failure line must be preserved: {}",
            out
        );
        assert!(out.contains("Tests:"), "summary must be preserved: {}", out);
    }

    // ── AC5: passthrough on non-matching output ───────────────────────────────

    #[test]
    fn non_test_output_passthrough() {
        let stdout = (0..50).map(|i| format!("file_{}.txt", i)).collect::<Vec<_>>().join("\n");
        let out = compress_jest_family_fail(&stdout);
        assert_eq!(out, stdout, "non-test output must passthrough unchanged");
    }
}
