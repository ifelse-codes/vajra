use vajractl::cli;

use anyhow::Result;
use std::env::args;

fn reset_sigpipe() {
    #[cfg(unix)]
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_DFL);
    }
}

/// Usage error: the front door did not recognise the word it was given.
/// Distinct from `1` (a command ran and failed) so a caller can tell the two apart.
const EXIT_UNKNOWN_COMMAND: u8 = 2;

enum Subcommand {
    Check,
    Estimate,
    Hook,
    Init,
    Approve,
    Claude,
    Meter,
    Next,
    Help,
    /// `--version` / `-V`. A FLAG, not an 8th top-level command (S128 non-goal).
    Version,
    /// Anything the front door does not recognise. Carries the offending word so the
    /// message can name it. Fails CLOSED (non-zero) — before S128 this fell through to
    /// `Help` and exited 0, so `vajra <typo> && deploy` ran deploy.
    Unknown(String),
}

fn main() -> std::process::ExitCode {
    reset_sigpipe();
    let args: Vec<String> = args().collect();
    let subcommand = args.get(1).map(|s| s.as_str()).unwrap_or("help");

    let sub = match subcommand {
        "check" => Subcommand::Check,
        "estimate" => Subcommand::Estimate,
        "hook" => Subcommand::Hook,
        "init" => Subcommand::Init,
        "approve" => Subcommand::Approve,
        "claude" => Subcommand::Claude,
        "meter" => Subcommand::Meter,
        "next" => Subcommand::Next,
        "help" | "--help" | "-h" => Subcommand::Help,
        "--version" | "-V" => Subcommand::Version,
        other => Subcommand::Unknown(other.to_string()),
    };

    // S179 (F89): `vajra <command> --help` prints that command's help and runs NOTHING. Before
    // S179 every subcommand ignored the flag and ran — `vajra init --help` scaffolded 11 files into
    // an empty repo (and merged a second set of guard hooks into Vajra's own settings). `claude`
    // is left out on purpose: its arguments belong to Claude Code, whose own help is the answer.
    if let Some(usage) = subcommand_usage(&sub) {
        if args.iter().skip(2).any(|a| a == "--help" || a == "-h") {
            eprintln!("{usage}");
            return std::process::ExitCode::from(0);
        }
    }

    let exit_code = match sub {
        Subcommand::Check => {
            let check_args: Vec<String> = args.into_iter().skip(2).collect();
            run_args_subcommand(cli::check::run, &check_args)
        }
        Subcommand::Estimate => run_subcommand(cli::estimate::run),
        Subcommand::Hook => run_subcommand(cli::hook::run),
        Subcommand::Init => {
            // S136: `init` takes args now — `--sync-fleet` is the brownfield UPGRADE path.
            let init_args: Vec<String> = args.into_iter().skip(2).collect();
            run_args_subcommand(cli::init::run, &init_args)
        }
        Subcommand::Approve => {
            let approve_args: Vec<String> = args.into_iter().skip(2).collect();
            run_args_subcommand(vajractl::approval::run, &approve_args)
        }
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
        Subcommand::Version => {
            // READ from the crate at compile time. Never typed into a string here — a
            // hand-typed version is a lie waiting for the next `cargo release`.
            println!("vajra {}", env!("CARGO_PKG_VERSION"));
            0
        }
        Subcommand::Unknown(word) => {
            eprintln!("vajra: unrecognised command '{word}'");
            eprintln!("Run `vajra --help` for the list of commands.");
            print_usage();
            EXIT_UNKNOWN_COMMAND
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

/// The help one Vajra subcommand prints for `--help`/`-h` (S179, F89). `None` for the words that
/// have no help of their own: `claude` (its flags are Claude Code's), and the top-level forms.
fn subcommand_usage(sub: &Subcommand) -> Option<&'static str> {
    Some(match sub {
        Subcommand::Init => {
            "vajra init — set up Vajra's .ai/ workflow in the current git repo (asks 3 questions)\n\
             \n\
             usage:\n\
             \x20 vajra init                        scaffold a repo that has no Vajra yet\n\
             \x20 vajra init --sync-fleet           upgrade an already-set-up repo to this version's roles,\n\
             \x20                                   hooks and close gate\n\
             \x20   --dry-run                       with --sync-fleet: show what would change, write nothing\n\
             \x20   --overwrite-drifted             with --sync-fleet: also rewrite files you have edited\n\
             \x20 vajra init --help, -h             print this help and write nothing"
        }
        Subcommand::Check => {
            "vajra check — drift detection + readiness score for the current Vajra repo\n\
             \n\
             usage:\n\
             \x20 vajra check                       run the checks and print the score\n\
             \x20 vajra check --render              also regenerate vajra.varta\n\
             \x20 vajra check --help, -h            print this help and run nothing"
        }
        Subcommand::Next => {
            "vajra next — the session's handoff packet, its stations, and the session advance\n\
             \n\
             usage:\n\
             \x20 vajra next                        print the handoff packet (read-only)\n\
             \x20 vajra next --advance              close this session and move to the next one\n\
             \x20 vajra next --steps [NN]           what is left to do in this session\n\
             \x20 vajra next --stations NN          how many of the 8 stations session NN passed\n\
             \x20 vajra next --role <name> --from <file>   record a helper role's findings\n\
             \x20 vajra next --check-<station> NN   one close check: plan, design, exec, qa, demo,\n\
             \x20                                   release, crew, advice, obeyed, fidelity-handoff, ...\n\
             \x20 vajra next --help, -h             print this help and run nothing"
        }
        Subcommand::Estimate => {
            "vajra estimate — predict a session's token spend and cost before running it\n\
             \n\
             usage:\n\
             \x20 vajra estimate                    estimate for the current session's prompt\n\
             \x20 vajra estimate --help, -h         print this help and run nothing"
        }
        Subcommand::Hook => {
            "vajra hook — the Claude Code PostToolUse hook (reads a tool result on stdin)\n\
             \n\
             Claude Code runs this itself; `vajra claude` wires it in. You do not run it by hand.\n\
             usage:\n\
             \x20 vajra hook --help, -h             print this help and run nothing"
        }
        Subcommand::Meter => {
            "vajra meter — a receipt for a past Claude Code session\n\
             \n\
             usage:\n\
             \x20 vajra meter <session.jsonl>       receipt + obedience for one transcript\n\
             \x20 vajra meter --all [dir]           the obedience baseline across a directory\n\
             \x20 vajra meter --help, -h            print this help and run nothing"
        }
        Subcommand::Approve => {
            "vajra approve — record YOUR yes for a session's brief (the agent cannot)\n\
             \n\
             usage:\n\
             \x20 vajra approve NN                  write the approval for session NN\n\
             \x20 vajra approve --help, -h          print this help and write nothing\n\
             \n\
             Works only typed by you at a terminal, outside anything Vajra launched. It refuses\n\
             inside an agent's shell. Bar-raising, not tamper-proof: see .ai/approvals/."
        }
        Subcommand::Claude
        | Subcommand::Help
        | Subcommand::Version
        | Subcommand::Unknown(_) => return None,
    })
}

fn print_usage() {
    eprintln!("vajra <init|claude|check|next|estimate|hook|meter>");
    eprintln!("  init              Scaffold .ai/ workflow in the current repo");
    eprintln!("    --sync-fleet    Upgrade an ALREADY-governed repo to the current role roster");
    eprintln!(
        "                    (--dry-run previews; --overwrite-drifted rewrites changed files)"
    );
    eprintln!("  approve NN        Record the founder's yes for session NN (own terminal only)");
    eprintln!("  claude [args...]  Launch Claude Code with Vajra hook injection");
    eprintln!(
        "  check [--render]   Drift detection + readiness score; --render regenerates vajra.varta"
    );
    eprintln!("  next [--advance]  Print handoff packet, or advance to next session");
    eprintln!("  estimate          Predict token spend and cost before running a session");
    eprintln!("  hook              Claude Code PostToolUse hook entrypoint");
    eprintln!("  meter <jsonl>     Print a receipt for a past Claude Code session");
    eprintln!("  --version, -V     Print the version and exit");
    eprintln!("  <command> --help  Print that command's help and run nothing (not `claude`: its arguments go to Claude Code)");
}
