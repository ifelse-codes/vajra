use crate::engine::{CompressionRequest, Engine, EngineDecision, ToolOutput};
use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::io::{Read, Write};

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HookInput {
    pub tool_name: String,
    pub tool_input: HookToolInput,
    pub tool_response: HookToolResponse,
}

#[derive(Deserialize)]
pub struct HookToolInput {
    pub command: Option<String>,
}

#[derive(Deserialize, Serialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct HookToolResponse {
    pub stdout: String,
    pub stderr: String,
    pub interrupted: bool,
    pub is_image: bool,
    pub no_output_expected: bool,
    pub exit_code: Option<i32>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HookOutput {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub hook_specific_output: Option<HookSpecificOutput>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct HookSpecificOutput {
    pub updated_tool_output: HookToolResponse,
}

pub struct ClaudeCodeHookAdapter<E: Engine> {
    engine: E,
}

impl<E: Engine> ClaudeCodeHookAdapter<E> {
    pub fn new(engine: E) -> Self {
        Self { engine }
    }

    pub fn run(&self, reader: &mut impl Read, writer: &mut impl Write) -> Result<()> {
        if std::env::var("VAJRA_RAW").is_ok() {
            writer.write_all(b"{}")?;
            return Ok(());
        }

        let mut input = String::new();
        reader.read_to_string(&mut input)?;

        let hook_in: HookInput = match serde_json::from_str(&input) {
            Ok(v) => v,
            Err(_) => {
                writer.write_all(b"{}")?;
                return Ok(());
            }
        };

        // G5: only Bash tool; G6: skip images; G7: skip no-output
        if hook_in.tool_name != "Bash"
            || hook_in.tool_response.is_image
            || hook_in.tool_response.no_output_expected
        {
            writer.write_all(b"{}")?;
            return Ok(());
        }

        let command = hook_in.tool_input.command.unwrap_or_default();
        let request = CompressionRequest {
            command,
            tool_output: ToolOutput {
                stdout: hook_in.tool_response.stdout.clone(),
                stderr: hook_in.tool_response.stderr.clone(),
                exit_code: hook_in.tool_response.exit_code,
                interrupted: hook_in.tool_response.interrupted,
            },
        };

        match self.engine.decide(&request) {
            EngineDecision::Passthrough => {
                writer.write_all(b"{}")?;
            }
            EngineDecision::Compressed {
                output,
                lines_removed,
            } => {
                let compressed_stdout = format!(
                    "{}\n[{} lines hidden — set VAJRA_RAW=1 to disable]",
                    output, lines_removed
                );
                let updated = HookToolResponse {
                    stdout: compressed_stdout,
                    ..hook_in.tool_response
                };
                let out = HookOutput {
                    hook_specific_output: Some(HookSpecificOutput {
                        updated_tool_output: updated,
                    }),
                };
                writer.write_all(serde_json::to_string(&out)?.as_bytes())?;
            }
        }
        Ok(())
    }
}
