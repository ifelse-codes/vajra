use crate::launcher::{command_exists, merge_hook_settings, TempSettings};
use anyhow::{Context, Result};
use std::process::{Command, Stdio};

pub fn run(args: &[String]) -> Result<()> {
    if !command_exists("vajractl") {
        anyhow::bail!("vajractl not found in PATH; install vajractl before using vajra launch");
    }
    if !command_exists("claude") {
        anyhow::bail!("claude not found in PATH; install Claude Code before using vajra launch");
    }

    let mut command = Command::new("claude");
    match merge_hook_settings().and_then(TempSettings::write) {
        Ok(temp_settings) => {
            if std::env::var("VAJRA_DEBUG").ok().as_deref() == Some("1") {
                eprintln!("[vajra] temp settings: {}", temp_settings.path().display());
                match std::fs::read_to_string(temp_settings.path()) {
                    Ok(content) => eprintln!("[vajra] temp settings content:\n{content}"),
                    Err(e) => eprintln!("[vajra] warning: failed to read temp settings: {e}"),
                }
            }
            command
                .arg("--settings")
                .arg(temp_settings.path())
                .args(args);
            wait_for_child(command, Some(temp_settings))
        }
        Err(e) => {
            eprintln!("[vajra] warning: settings injection failed; running bare claude ({e})");
            command.args(args);
            wait_for_child(command, None)
        }
    }
}

fn wait_for_child(mut command: Command, temp_settings: Option<TempSettings>) -> Result<()> {
    let mut child = command
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
        .context("failed to spawn claude")?;
    let status = child.wait();
    std::mem::drop(temp_settings);
    let status = status.context("failed to wait on claude")?;
    if !status.success() {
        std::process::exit(status.code().unwrap_or(1));
    }
    Ok(())
}
