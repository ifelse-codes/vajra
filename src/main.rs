use vajractl::cli;

use anyhow::Result;
use std::env::args;

enum Subcommand {
    Hook,
    Launch,
    Meter,
}

fn main() -> std::process::ExitCode {
    let args: Vec<String> = args().collect();
    let subcommand = args.get(1).map(|s| s.as_str()).unwrap_or("hook");

    let sub = match subcommand {
        "hook" => Subcommand::Hook,
        "launch" => Subcommand::Launch,
        "meter" => Subcommand::Meter,
        _ => Subcommand::Hook,
    };

    let exit_code = match sub {
        Subcommand::Hook => run_subcommand(cli::hook::run),
        Subcommand::Launch => {
            let launch_args: Vec<String> = args.into_iter().skip(2).collect();
            run_launch_subcommand(&launch_args)
        }
        Subcommand::Meter => run_subcommand(cli::meter::run),
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
