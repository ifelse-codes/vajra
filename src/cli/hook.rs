use crate::adapter::ClaudeCodeHookAdapter;
use crate::engine::DefaultEngine;
use anyhow::Result;

pub fn run() -> Result<()> {
    let adapter = ClaudeCodeHookAdapter::new(DefaultEngine);
    let mut stdin = std::io::stdin();
    let mut stdout = std::io::stdout();
    let result = adapter.run(&mut stdin, &mut stdout);

    if let Ok(Some(stats)) = &result {
        write_sidecar_stats(stats);
    }

    let _ = result;
    Ok(())
}

fn write_sidecar_stats(stats: &crate::adapter::CompressionResult) {
    let stats_path = match std::env::var("VAJRA_SESSION_STATS") {
        Ok(p) => p,
        Err(_) => return,
    };

    let entry = serde_json::json!({
        "lines_in": stats.lines_in,
        "lines_out": stats.lines_out,
        "command": stats.command_prefix,
    });

    let Ok(mut f) = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&stats_path)
    else {
        return;
    };

    use std::io::Write;
    let _ = writeln!(f, "{}", entry);
}
