use vajractl::engine::{CompressionRequest, Engine, EngineDecision, StubEngine, ToolOutput};

#[test]
fn stub_returns_passthrough() {
    let engine = StubEngine;
    let request = CompressionRequest {
        command: "echo".into(),
        tool_output: ToolOutput {
            stdout: "hello".into(),
            stderr: "".into(),
            exit_code: Some(0),
            interrupted: false,
        },
    };
    let decision = engine.decide(&request);
    assert!(matches!(decision, EngineDecision::Passthrough));
}
