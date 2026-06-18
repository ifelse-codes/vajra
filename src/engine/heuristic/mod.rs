//! Compression heuristics — tool-specific output folding.
//!
//! Each heuristic detects its tool from the command and applies
//! lossy-but-safe folding rules. Unknown tools fall back to `GenericHeuristic`.

pub trait Heuristic: Send + Sync {
    fn detect(&self, request: &crate::engine::CompressionRequest) -> bool;
    fn compress(&self, request: &crate::engine::CompressionRequest) -> String;
}

/// Dispatch the correct heuristic for a request based on `tool_output.tool`.
pub fn select_heuristic(request: &crate::engine::CompressionRequest) -> Box<dyn Heuristic> {
    let tool = &request.tool_output.tool;
    if tool.starts_with("cargo build") {
        Box::new(cargo::CargoBuildHeuristic)
    } else if tool.starts_with("cargo test") {
        Box::new(cargo::CargoTestHeuristic)
    } else if tool.starts_with("git log") {
        Box::new(git::GitLogHeuristic)
    } else if tool.starts_with("git status") {
        Box::new(git::GitStatusHeuristic)
    } else if tool.starts_with("git diff --stat") {
        Box::new(git::GitDiffStatHeuristic)
    } else if tool.starts_with("npm test") || tool.starts_with("npm run test") {
        Box::new(npm::NpmTestHeuristic)
    } else if tool.starts_with("pytest") {
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
            tool_output: crate::engine::ToolOutput {
                tool: "echo hello".into(),
                stdout: "hello\nworld".into(),
                stderr: "".into(),
                exit_code: 0,
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
            tool_output: crate::engine::ToolOutput {
                tool: "echo".into(),
                stdout,
                stderr: "".into(),
                exit_code: 0,
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
