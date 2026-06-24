use crate::engine::heuristic::{select_heuristic, GenericHeuristic, Heuristic};
use crate::engine::{
    CompressionRequest, Engine, EngineDecision, ToolOutput, FAIL_PASSTHROUGH_CAP, LINE_CAP,
};
use std::panic::AssertUnwindSafe;

pub struct DefaultEngine;

impl Engine for DefaultEngine {
    fn decide(&self, request: &CompressionRequest) -> EngineDecision {
        let line_count = request.tool_output.stdout.lines().count();

        if line_count < LINE_CAP {
            return EngineDecision::Passthrough;
        }

        if !is_success(&request.tool_output) && line_count < FAIL_PASSTHROUGH_CAP {
            return EngineDecision::Passthrough;
        }

        let heuristic: Box<dyn Heuristic> = if is_compound(&request.command) {
            Box::new(GenericHeuristic)
        } else {
            select_heuristic(request)
        };

        let compressed =
            match std::panic::catch_unwind(AssertUnwindSafe(|| heuristic.compress(request))) {
                Ok(result) => result,
                Err(_) => return EngineDecision::Passthrough,
            };
        let lines_removed = line_count.saturating_sub(compressed.lines().count());
        if lines_removed == 0 {
            return EngineDecision::Passthrough;
        }
        EngineDecision::Compressed {
            output: compressed,
            lines_removed,
        }
    }
}

fn is_success(output: &ToolOutput) -> bool {
    match output.exit_code {
        Some(0) => true,
        Some(_) => false,
        None if output.interrupted => false,
        None => infer_success(output),
    }
}

fn infer_success(output: &ToolOutput) -> bool {
    let tail: String = output
        .stdout
        .lines()
        .rev()
        .take(5)
        .collect::<Vec<_>>()
        .join("\n");

    if tail.contains("Finished dev")
        || tail.contains("Finished release")
        || tail.contains("Finished test")
        || tail.contains("Finished bench")
    {
        return true;
    }
    if tail.contains("test result: ok") {
        return true;
    }
    if tail.contains(" passed") && !tail.contains(" failed") && !tail.contains(" error") {
        return true;
    }

    if output.stderr.contains("error:") || output.stdout.contains("error[E") {
        return false;
    }

    false
}

fn is_compound(command: &str) -> bool {
    command.contains("&&")
        || command.contains("||")
        || command.contains(" | ")
        || command.contains(';')
        || command.contains("$(")
        || command.contains('`')
}
