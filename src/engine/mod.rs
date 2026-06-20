pub const LINE_CAP: usize = 200;
pub const FAIL_PASSTHROUGH_CAP: usize = 50;

pub enum EngineDecision {
    Passthrough,
    Compressed {
        output: String,
        lines_removed: usize,
    },
}

pub struct ToolOutput {
    pub stdout: String,
    pub stderr: String,
    pub exit_code: Option<i32>,
    pub interrupted: bool,
}

pub struct CompressionRequest {
    pub command: String,
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

pub mod default_engine;
pub mod heuristic;
pub use default_engine::DefaultEngine;
