//! Compression heuristics — tool-specific output folding.
//!
//! Each heuristic detects its tool from the command and applies
//! lossy-but-safe folding rules. Unknown tools fall back to `GenericHeuristic`.

pub trait Heuristic: Send + Sync {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool;
    fn compress(&self, request: &crate::engine::CompressionRequest) -> String;

    /// Whether this heuristic's fold is guaranteed to preserve a failure signal
    /// for its known output format, so it is safe to run *regardless of exit code*
    /// (S41 fix). Real Claude Code omits `exitCode` for Bash, which makes the
    /// engine infer "failure" and gate folding; heuristics that fold lossy-SAFE
    /// for their format (tail/error text always kept) opt out of that gate here.
    ///
    /// Default `false` — the conservative generic path stays gated: prefer a
    /// passthrough over a fold that might hide a marker-less failure.
    fn preserves_failure_signal(&self) -> bool {
        false
    }
}

/// Dispatch the correct heuristic for a request based on `command`.
pub fn select_heuristic(request: &crate::engine::CompressionRequest) -> Box<dyn Heuristic> {
    let cmd = &request.command;
    if cmd.starts_with("cargo build") {
        Box::new(cargo::CargoBuildHeuristic)
    } else if cmd.starts_with("cargo test") {
        Box::new(cargo::CargoTestHeuristic)
    } else if cmd.starts_with("git log") {
        Box::new(git::GitLogHeuristic)
    } else if cmd.starts_with("git status") {
        Box::new(git::GitStatusHeuristic)
    } else if cmd.starts_with("git diff --stat") {
        Box::new(git::GitDiffStatHeuristic)
    } else if cmd.starts_with("npm test") || cmd.starts_with("npm run test") {
        Box::new(npm::NpmTestHeuristic)
    } else if cmd.starts_with("pytest") {
        Box::new(pytest::PytestHeuristic)
    } else {
        Box::new(GenericHeuristic)
    }
}

/// Fallback heuristic: head+tail truncation when output exceeds LINE_CAP.
pub struct GenericHeuristic;

impl Heuristic for GenericHeuristic {
    fn detect(&self, _request: &crate::engine::CompressionRequest) -> bool {
        true
    }

    fn compress(&self, request: &crate::engine::CompressionRequest) -> String {
        let lines: Vec<&str> = request.tool_output.stdout.lines().collect();
        if lines.len() <= crate::engine::LINE_CAP {
            request.tool_output.stdout.clone()
        } else {
            let head = lines
                .iter()
                .take(10)
                .copied()
                .collect::<Vec<_>>()
                .join("\n");
            let tail = lines
                .iter()
                .skip(lines.len().saturating_sub(10))
                .copied()
                .collect::<Vec<_>>()
                .join("\n");
            let hidden = lines.len().saturating_sub(20);
            format!("{}\n\n… [{} hidden] …\n\n{}", head, hidden, tail)
        }
    }
}

pub mod cargo;
pub mod git;
pub mod npm;
pub mod pytest;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generic_under_cap_returns_as_is() {
        let request = crate::engine::CompressionRequest {
            command: "echo hello".into(),
            tool_output: crate::engine::ToolOutput {
                stdout: "hello\nworld".into(),
                stderr: "".into(),
                exit_code: Some(0),
                interrupted: false,
            },
        };
        let h = GenericHeuristic;
        assert!(h.detect(&request));
        assert_eq!(h.compress(&request), "hello\nworld");
    }

    #[test]
    fn generic_over_cap_truncates() {
        let lines: Vec<String> = (0..250).map(|i| format!("line {}", i)).collect();
        let stdout = lines.join("\n");
        let request = crate::engine::CompressionRequest {
            command: "echo".into(),
            tool_output: crate::engine::ToolOutput {
                stdout,
                stderr: "".into(),
                exit_code: Some(0),
                interrupted: false,
            },
        };
        let h = GenericHeuristic;
        let out = h.compress(&request);
        assert!(
            out.contains("[230 hidden]"),
            "expected [230 hidden], got: {}",
            out
        );
    }
}
