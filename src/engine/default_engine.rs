use crate::engine::heuristic::select_heuristic;
use crate::engine::{CompressionRequest, Engine, EngineDecision};
use std::panic::AssertUnwindSafe;

pub struct DefaultEngine;

impl Engine for DefaultEngine {
    fn decide(&self, request: &CompressionRequest) -> EngineDecision {
        let original_lines = request.tool_output.stdout.lines().count();
        let heuristic = select_heuristic(request);
        let compressed =
            match std::panic::catch_unwind(AssertUnwindSafe(|| heuristic.compress(request))) {
                Ok(result) => result,
                Err(_) => return EngineDecision::Passthrough,
            };
        let lines_removed = original_lines.saturating_sub(compressed.lines().count());
        if lines_removed == 0 {
            return EngineDecision::Passthrough;
        }
        EngineDecision::Compressed {
            output: compressed,
            lines_removed,
        }
    }
}
