//! Git output heuristics.

use super::Heuristic;
use crate::engine::LINE_CAP;

/// Always passthrough — git status is decision-critical.
pub struct GitStatusHeuristic;

impl Heuristic for GitStatusHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.command.starts_with("git status")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        request.tool_output.stdout.clone()
    }
}

/// Always passthrough — git diff --stat is already narrowed.
pub struct GitDiffStatHeuristic;

impl Heuristic for GitDiffStatHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.command.starts_with("git diff --stat")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        request.tool_output.stdout.clone()
    }
}

/// Head+tail truncation when git log output exceeds LINE_CAP.
pub struct GitLogHeuristic;

impl Heuristic for GitLogHeuristic {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool {
        request.command.starts_with("git log")
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        let lines: Vec<&str> = request.tool_output.stdout.lines().collect();
        if lines.len() <= LINE_CAP {
            return request.tool_output.stdout.clone();
        }
        let head_count = 10;
        let tail_count = 10;
        let head = lines
            .iter()
            .take(head_count)
            .copied()
            .collect::<Vec<_>>()
            .join("\n");
        let tail = lines
            .iter()
            .skip(lines.len() - tail_count)
            .copied()
            .collect::<Vec<_>>()
            .join("\n");
        let hidden = lines
            .len()
            .saturating_sub(head_count)
            .saturating_sub(tail_count);
        format!("{}\n\n… [{} hidden] …\n\n{}", head, hidden, tail)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::engine::{CompressionRequest, ToolOutput};

    fn make_request(stdout: &str, command: &str) -> CompressionRequest {
        CompressionRequest {
            command: command.into(),
            tool_output: ToolOutput {
                stdout: stdout.into(),
                stderr: String::new(),
                exit_code: Some(0),
                interrupted: false,
            },
        }
    }

    #[test]
    fn git_log_short_returns_as_is() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/git-log.txt"
        ));
        let request = make_request(raw, "git log --oneline -40");
        let h = GitLogHeuristic;
        assert!(h.detect(&request));
        assert_eq!(h.compress(&request), raw);
    }

    #[test]
    fn git_log_long_truncates() {
        let lines: Vec<String> = (0..250)
            .map(|i| format!("{:04x} fake commit message", i))
            .collect();
        let raw = lines.join("\n");
        let request = make_request(&raw, "git log --oneline");
        let h = GitLogHeuristic;
        assert!(h.detect(&request));
        let out = h.compress(&request);
        assert!(out.contains("[230 hidden]"), "hidden count wrong: {}", out);
        assert!(out.contains("0000 fake commit message"));
        assert!(
            out.contains("00f9 fake commit message"),
            "tail should contain line 249 (0x00f9)"
        );
    }

    #[test]
    fn git_status_passthrough() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/git-status.txt"
        ));
        let request = make_request(raw, "git status");
        let h = GitStatusHeuristic;
        assert!(h.detect(&request));
        assert_eq!(h.compress(&request), raw);
    }

    #[test]
    fn git_diff_stat_passthrough() {
        let raw = include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/research/compression-fixtures/raw/git-diff-stat.txt"
        ));
        let request = make_request(raw, "git diff --stat");
        let h = GitDiffStatHeuristic;
        assert!(h.detect(&request));
        assert_eq!(h.compress(&request), raw);
    }

    #[test]
    fn git_log_detects_git_log() {
        let request = make_request("commit 123", "git log --oneline -10");
        assert!(GitLogHeuristic.detect(&request));
        assert!(!GitStatusHeuristic.detect(&request));
        assert!(!GitDiffStatHeuristic.detect(&request));
    }

    #[test]
    fn git_status_detects_git_status() {
        let request = make_request("nothing to commit", "git status");
        assert!(GitStatusHeuristic.detect(&request));
        assert!(!GitLogHeuristic.detect(&request));
    }

    #[test]
    fn git_diff_stat_detects_git_diff_stat() {
        let request = make_request("file | 2 +", "git diff --stat");
        assert!(GitDiffStatHeuristic.detect(&request));
        assert!(!GitLogHeuristic.detect(&request));
    }
}
