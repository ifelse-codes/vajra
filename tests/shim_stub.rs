use vajractl::engine::{CompressionRequest, Engine, EngineDecision, StubEngine, ToolOutput};

#[test]
fn stub_returns_passthrough() {
    let engine = StubEngine;
    let request = CompressionRequest {
        tool_output: ToolOutput {
            tool: "echo".into(),
            stdout: "hello".into(),
            stderr: "".into(),
            exit_code: 0,
        },
    };
    let decision = engine.decide(&request);
    assert!(matches!(decision, EngineDecision::Passthrough));
}
