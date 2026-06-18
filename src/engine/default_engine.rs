use crate::engine::heuristic::select_heuristic;
use crate::engine::{CompressionRequest, Engine, EngineDecision};

pub struct DefaultEngine;

impl Engine for DefaultEngine {
    fn decide(&self, request: &CompressionRequest) -> EngineDecision {
        let tool = request.tool_output.tool.clone();
        let heuristic = select_heuristic(request);
        let compressed = heuristic.compress(request);
        EngineDecision::Compress {
            tool,
            output: compressed,
        }
    }
}
