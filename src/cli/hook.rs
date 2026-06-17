use crate::engine::Engine;
use anyhow::Result;

pub fn run() -> Result<()> {
    let engine = crate::engine::StubEngine;
    let request = crate::engine::CompressionRequest {
        tool_output: crate::engine::ToolOutput {
            tool: "echo".into(),
            stdout: "hello".into(),
            stderr: "".into(),
            exit_code: 0,
        },
    };
    match engine.decide(&request) {
        crate::engine::EngineDecision::Passthrough => {
            println!("hook: passthrough");
        }
        _ => {
            println!("hook: compressed");
        }
    }
    Ok(())
}
