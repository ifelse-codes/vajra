use crate::meter;
use anyhow::{Context, Result};
use std::path::PathBuf;

pub fn run() -> Result<()> {
    let path = std::env::args()
        .nth(2)
        .map(PathBuf::from)
        .context("usage: vajractl meter <path-to-session.jsonl>")?;

    let subagent_dir = path
        .file_stem()
        .map(|stem| {
            path.parent()
                .unwrap_or(&path)
                .join(stem.to_string_lossy().as_ref())
                .join("subagents")
        })
        .filter(|d| d.exists());

    let cost = meter::meter_session(&path, subagent_dir.as_deref(), None)?;
    eprint!("{}", meter::format_receipt(&cost));
    Ok(())
}
