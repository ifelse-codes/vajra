use vajractl::cli;

use anyhow::Result;
use std::env::args;

enum Subcommand {
    Hook,
    Init,
    Launch,
    Meter,
    Next,
    Help,
}

fn main() -> std::process::ExitCode {
    let args: Vec<String> = args().collect();
    let subcommand = args.get(1).map(|s| s.as_str()).unwrap_or("help");

    let sub = match subcommand {
        "hook" => Subcommand::Hook,
        "init" => Subcommand::Init,
        "launch" | "claude" => Subcommand::Launch,
        "meter" => Subcommand::Meter,
        "next" => Subcommand::Next,
        "help" | "--help" | "-h" => Subcommand::Help,
        _ => Subcommand::Help,
    };

    let exit_code = match sub {
        Subcommand::Hook => run_subcommand(cli::hook::run),
        Subcommand::Init => run_subcommand(cli::init::run),
        Subcommand::Launch => {
            let launch_args: Vec<String> = args.into_iter().skip(2).collect();
            run_launch_subcommand(&launch_args)
        }
        Subcommand::Meter => run_subcommand(cli::meter::run),
        Subcommand::Next => run_subcommand(cli::next::run),
        Subcommand::Help => {
            print_usage();
            0
        }
    };

    std::process::ExitCode::from(exit_code)
}

fn run_subcommand(f: fn() -> Result<()>) -> u8 {
    match f() {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("vajra error: {e}");
            1
        }
    }
}

fn run_launch_subcommand(args: &[String]) -> u8 {
    match cli::launch::run(args) {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("vajra error: {e}");
            1
        }
    }
}

fn print_usage() {
    eprintln!("vajra <init|claude|next|hook|meter>");
    eprintln!("  init              Scaffold .ai/ workflow in the current repo");
    eprintln!("  claude [args...]  Launch Claude Code with Vajra hook injection");
    eprintln!("  next              Print the current agent handoff packet from .ai/");
    eprintln!("  hook              Claude Code PostToolUse hook entrypoint");
    eprintln!("  meter <jsonl>     Print a receipt for a past Claude Code session");
    eprintln!("  launch            Legacy alias for 'claude'");
}
