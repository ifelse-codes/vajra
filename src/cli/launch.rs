use anyhow::{Context, Result};
use std::process::{Command, Stdio};

pub fn run() -> Result<()> {
    let mut child = Command::new("echo")
        .arg("claude launcher: placeholder")
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
        .context("failed to spawn claude")?;
    let status = child.wait().context("failed to wait on claude")?;
    if !status.success() {
        anyhow::bail!("claude exited with non-zero status");
    }
    Ok(())
}
