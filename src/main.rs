use vajractl::cli;

use anyhow::Result;
use std::env::args;

fn reset_sigpipe() {
    #[cfg(unix)]
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

enum Subcommand {
    Check,
    Hook,
    Init,
    Claude,
    Meter,
    Next,
    Help,
}

fn main() -> std::process::ExitCode {
    reset_sigpipe();
    let args: Vec<String> = args().collect();
    let subcommand = args.get(1).map(|s| s.as_str()).unwrap_or("help");

    let sub = match subcommand {
        "check" => Subcommand::Check,
        "hook" => Subcommand::Hook,
        "init" => Subcommand::Init,
        "claude" => Subcommand::Claude,
        "meter" => Subcommand::Meter,
        "next" => Subcommand::Next,
        "help" | "--help" | "-h" => Subcommand::Help,
        _ => Subcommand::Help,
    };

    let exit_code = match sub {
        Subcommand::Check => run_subcommand(cli::check::run),
        Subcommand::Hook => run_subcommand(cli::hook::run),
        Subcommand::Init => run_subcommand(cli::init::run),
        Subcommand::Claude => {
            let claude_args: Vec<String> = args.into_iter().skip(2).collect();
            run_claude_subcommand(&claude_args)
        }
        Subcommand::Meter => run_subcommand(cli::meter::run),
        Subcommand::Next => {
            let next_args: Vec<String> = args.into_iter().skip(2).collect();
            run_args_subcommand(cli::next::run, &next_args)
        }
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

fn run_args_subcommand(f: fn(&[String]) -> Result<()>, args: &[String]) -> u8 {
    match f(args) {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("vajra error: {e}");
            1
        }
    }
}

fn run_claude_subcommand(args: &[String]) -> u8 {
    match cli::launch::run(args) {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("vajra error: {e}");
            1
        }
    }
}

fn print_usage() {
    eprintln!("vajra <init|claude|check|next|hook|meter>");
    eprintln!("  init              Scaffold .ai/ workflow in the current repo");
    eprintln!("  claude [args...]  Launch Claude Code with Vajra hook injection");
    eprintln!("  check             Drift detection + readiness score for .ai/ state");
    eprintln!("  next [--advance]  Print handoff packet, or advance to next session");
    eprintln!("  hook              Claude Code PostToolUse hook entrypoint");
    eprintln!("  meter <jsonl>     Print a receipt for a past Claude Code session");
}
