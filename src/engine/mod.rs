pub const LINE_CAP: usize = 200;
pub const FAIL_PASSTHROUGH_CAP: usize = 50;

pub enum EngineDecision {
    Passthrough,
    Compress { tool: String, output: String },
}

pub struct ToolOutput {
    pub tool: String,
    pub stdout: String,
    pub stderr: String,
    pub exit_code: i32,
}

pub struct CompressionRequest {
    pub tool_output: ToolOutput,
}

pub trait Engine {
    fn decide(&self, request: &CompressionRequest) -> EngineDecision;
}

pub struct StubEngine;

impl Engine for StubEngine {
    fn decide(&self, _request: &CompressionRequest) -> EngineDecision {
        EngineDecision::Passthrough
    }
}

pub mod heuristic;
