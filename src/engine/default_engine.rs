use crate::engine::heuristic::select_heuristic;
use crate::engine::{CompressionRequest, Engine, EngineDecision};
use std::panic::AssertUnwindSafe;

pub struct DefaultEngine;

impl Engine for DefaultEngine {
    fn decide(&self, request: &CompressionRequest) -> EngineDecision {
        let tool = request.tool_output.tool.clone();
        let stdout = request.tool_output.stdout.clone();
        let heuristic = select_heuristic(request);
        let compressed = match std::panic::catch_unwind(AssertUnwindSafe(|| {
            let req = crate::engine::CompressionRequest {
                tool_output: crate::engine::ToolOutput {
                    tool: tool.clone(),
                    stdout,
                    stderr: request.tool_output.stderr.clone(),
                    exit_code: request.tool_output.exit_code,
                },
            };
            heuristic.compress(&req)
        })) {
            Ok(result) => result,
            Err(_) => return EngineDecision::Passthrough,
        };
        EngineDecision::Compress {
            tool,
            output: compressed,
        }
    }
}
