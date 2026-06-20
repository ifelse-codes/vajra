use crate::adapter::ClaudeCodeHookAdapter;
use crate::engine::DefaultEngine;
use anyhow::Result;

pub fn run() -> Result<()> {
    let adapter = ClaudeCodeHookAdapter::new(DefaultEngine);
    let mut stdin = std::io::stdin();
    let mut stdout = std::io::stdout();
    // Fail-open: any error → exit 0 (hook must never block Claude Code)
    let _ = adapter.run(&mut stdin, &mut stdout);
    Ok(())
}
