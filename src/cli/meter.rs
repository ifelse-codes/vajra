use crate::meter;
use crate::obedience;
use anyhow::{anyhow, Context, Result};
use std::path::PathBuf;

pub fn run() -> Result<()> {
    match std::env::args().nth(2).as_deref() {
        // S49 baseline: run the obedience metric across every transcript in a directory.
        Some("--all") => run_baseline(std::env::args().nth(3)),
        Some(path) => run_single(PathBuf::from(path)),
        None => Err(anyhow!(
            "usage: vajractl meter <path-to-session.jsonl> | vajractl meter --all [dir]"
        )),
    }
}

/// The receipt + obedience metric for one session (unchanged from S48).
fn run_single(path: PathBuf) -> Result<()> {
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

    // Obedience metric (S48): did the agent obey the rails? Read-only, same JSONL.
    let obedience = obedience::obedience_for(&path)?;
    eprint!("{}", obedience::format_obedience(&obedience));
    Ok(())
}

/// S49 obedience baseline: batch the S48 metric over a directory of transcripts and print a
/// ranked table + aggregate (median/range), so a single reading has a yardstick. Reporting
/// only ($0), read-only; no 8th command (rides `vajra meter`), no new dependency. The table is
/// the whole point of `--all`, so it goes to stdout (the single-session receipt stays stderr).
fn run_baseline(dir_arg: Option<String>) -> Result<()> {
    let dir = match dir_arg {
        Some(d) => PathBuf::from(d),
        None => default_project_dir().context(
            "could not locate ~/.claude/projects/<project>; pass one: vajractl meter --all <dir>",
        )?,
    };
    let rows = obedience::baseline_for_dir(&dir)?;
    let agg = obedience::aggregate(&rows);
    print!(
        "{}",
        obedience::format_baseline(&dir.display().to_string(), &rows, agg.as_ref())
    );
    Ok(())
}

/// `~/.claude/projects/<cwd-slug>` — the same layout the meter discovers (CC replaces `/` with `-`).
fn default_project_dir() -> Option<PathBuf> {
    let home = std::env::var_os("HOME").map(PathBuf::from)?;
    let cwd = std::env::current_dir().ok()?;
    let slug = cwd.to_string_lossy().replace('/', "-");
    Some(home.join(".claude/projects").join(slug))
}
