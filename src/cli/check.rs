use anyhow::{Context, Result};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::maturity::{read_maturity, MaturityLevel};
use crate::varta::{render_from_root, RENDER_PATH};

const REQUIRED_FILES: &[&str] = &[
    ".ai/SESSION",
    ".ai/AGENTS.md",
    ".ai/SESSION-BOOT.md",
    ".ai/TASK.md",
    ".ai/STATE.md",
    ".ai/CONSTRAINTS.yaml",
];

struct CheckResult {
    name: String,
    passed: bool,
    detail: String,
}

pub fn run(args: &[String]) -> Result<()> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    let root =
        find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")?;

    // `--render`: regenerate the one-way `.varta` from the live `.ai/`, then return.
    if args.iter().any(|a| a == "--render") {
        let rendered = render_from_root(&root)?;
        fs::write(root.join(RENDER_PATH), &rendered)
            .with_context(|| format!("could not write {RENDER_PATH}"))?;
        println!(
            "rendered {RENDER_PATH} from .ai/ ({} bytes)",
            rendered.len()
        );
        return Ok(());
    }

    let maturity = read_maturity(&root.join(".ai/CONSTRAINTS.yaml"));

    let mut results = Vec::new();

    check_required_files(&root, &mut results);
    let session = check_session_valid(&root, &mut results);
    check_branch(&root, &mut results);
    if let Some(n) = session {
        check_boot_matches_session(&root, n, &mut results);
        check_verify_script(&root, n, &mut results);
    }
    check_varta_render(&root, &mut results);

    print_results(&results, maturity);

    let failed = results.iter().filter(|r| !r.passed).count();
    if failed > 0 && maturity != MaturityLevel::L1 {
        std::process::exit(1);
    }
    Ok(())
}

/// Drift guard: the on-disk `vajra.varta` must equal a fresh render of the live `.ai/`.
/// Proves the artifact is generated, not hand-edited (the S22 `cmp` pattern).
///
/// **S128 — the fork, decided.** Until now ABSENT and STALE were the same FAIL, so a fresh
/// `vajra init` scored 9/11 on a file `init` never creates: the product failed its own
/// health check on arrival. The two candidate fixes were
///   (a) make `init` render a `vajra.varta`, or
///   (b) stop demanding a file `init` never makes.
/// **(b) is what shipped.** `vajra.varta` is a DERIVED, one-way render and the render is
/// opt-in (`vajra check --render`); (a) would plant a derived artifact in every scaffold that
/// goes stale on the user's very next `.ai/` edit — trading one false red for a recurring one,
/// and hand-maintaining a derived copy is the trap this repo already named. The third option —
/// leaving a new user red on first run — is rejected out loud: a health check that is wrong on
/// arrival teaches strangers to ignore it, and then it protects nothing.
///
/// The guard keeps its teeth where drift can actually exist:
///   * absent + NOT tracked by git → PASS, labelled optional. Nothing exists, so nothing drifted.
///   * absent + TRACKED by git     → FAIL. The repo committed a render and it is gone: real drift.
///   * present + equal             → PASS.
///   * present + different         → FAIL, stale — the case the guard was built for.
fn check_varta_render(root: &Path, results: &mut Vec<CheckResult>) {
    let name = "varta: matches render".to_string();
    let rendered = match render_from_root(root) {
        Ok(r) => r,
        Err(e) => {
            results.push(CheckResult {
                name,
                passed: false,
                detail: format!("could not render: {e}"),
            });
            return;
        }
    };
    let on_disk = fs::read_to_string(root.join(RENDER_PATH));
    let (passed, detail) = match on_disk {
        Err(_) if is_tracked_by_git(root, RENDER_PATH) => (
            false,
            format!("{RENDER_PATH} tracked in git but missing — run `vajra check --render`"),
        ),
        Err(_) => (
            true,
            format!("{RENDER_PATH} not rendered (optional) — `vajra check --render` generates it"),
        ),
        Ok(d) if d == rendered => (true, format!("{RENDER_PATH} up to date")),
        Ok(_) => (
            false,
            format!("{RENDER_PATH} stale — run `vajra check --render`"),
        ),
    };
    results.push(CheckResult {
        name,
        passed,
        detail,
    });
}

/// Is `path` in git's index for `root`? Used to tell "never rendered" (fine) apart from
/// "the repo committed a render and it vanished" (drift). No git, no repo, or any error =>
/// `false`: a fresh `git init` must not inherit a failure it cannot act on.
fn is_tracked_by_git(root: &Path, path: &str) -> bool {
    Command::new("git")
        .args(["ls-files", "--error-unmatch", "--", path])
        .current_dir(root)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn find_repo_root(start: &Path) -> Option<PathBuf> {
    start
        .ancestors()
        .find(|dir| dir.join(".ai").is_dir())
        .map(Path::to_path_buf)
}

fn check_required_files(root: &Path, results: &mut Vec<CheckResult>) {
    for file in REQUIRED_FILES {
        let exists = root.join(file).is_file();
        results.push(CheckResult {
            name: format!("file: {file}"),
            passed: exists,
            detail: if exists {
                "exists".into()
            } else {
                "missing".into()
            },
        });
    }
}

fn check_session_valid(root: &Path, results: &mut Vec<CheckResult>) -> Option<u32> {
    let content = match fs::read_to_string(root.join(".ai/SESSION")) {
        Ok(c) => c,
        Err(_) => {
            results.push(CheckResult {
                name: "session: valid integer".into(),
                passed: false,
                detail: "could not read .ai/SESSION".into(),
            });
            return None;
        }
    };

    match content.trim().parse::<u32>() {
        Ok(n) => {
            results.push(CheckResult {
                name: "session: valid integer".into(),
                passed: true,
                detail: format!("{n:02}"),
            });
            Some(n)
        }
        Err(_) => {
            results.push(CheckResult {
                name: "session: valid integer".into(),
                passed: false,
                detail: format!("not an integer: {:?}", content.trim()),
            });
            None
        }
    }
}

fn check_branch(root: &Path, results: &mut Vec<CheckResult>) {
    let branch = current_branch(root);

    if branch == "main" || branch == "master" {
        results.push(CheckResult {
            name: "branch: not main".into(),
            passed: false,
            detail: format!("on {branch} — branch before working"),
        });
        return;
    }

    let matches = is_session_branch(&branch);
    results.push(CheckResult {
        name: "branch: session pattern".into(),
        passed: matches,
        detail: if matches {
            branch
        } else {
            format!("{branch} (expected session-NN-<slug>)")
        },
    });
}

fn check_boot_matches_session(root: &Path, session: u32, results: &mut Vec<CheckResult>) {
    let boot = match fs::read_to_string(root.join(".ai/SESSION-BOOT.md")) {
        Ok(c) => c,
        Err(_) => {
            results.push(CheckResult {
                name: "boot: matches session".into(),
                passed: false,
                detail: "could not read SESSION-BOOT.md".into(),
            });
            return;
        }
    };

    let session_str = format!("{session:02}");
    let found = boot
        .lines()
        .any(|line| line.contains("**Number:**") && line.contains(&session_str));

    results.push(CheckResult {
        name: "boot: matches session".into(),
        passed: found,
        detail: if found {
            format!("SESSION-BOOT.md references session {session_str}")
        } else {
            format!("SESSION-BOOT.md does not reference session {session_str}")
        },
    });
}

fn check_verify_script(root: &Path, session: u32, results: &mut Vec<CheckResult>) {
    if env::var("VAJRA_CHECK_RUNNING").is_ok() {
        results.push(CheckResult {
            name: "verify: script exists".into(),
            passed: true,
            detail: "skipped (already inside vajra check)".into(),
        });
        return;
    }

    let script = root.join(format!("scripts/verify-session-{session:02}.sh"));
    if !script.is_file() {
        results.push(CheckResult {
            name: "verify: script exists".into(),
            passed: true,
            detail: format!("scripts/verify-session-{session:02}.sh not found (optional)"),
        });
        return;
    }

    let output = Command::new("bash")
        .arg(&script)
        .current_dir(root)
        .env("VAJRA_CHECK_RUNNING", "1")
        .output();

    match output {
        Ok(o) if o.status.success() => {
            results.push(CheckResult {
                name: "verify: script passes".into(),
                passed: true,
                detail: format!("scripts/verify-session-{session:02}.sh exit 0"),
            });
        }
        Ok(o) => {
            results.push(CheckResult {
                name: "verify: script passes".into(),
                passed: false,
                detail: format!(
                    "scripts/verify-session-{session:02}.sh exit {}",
                    o.status.code().unwrap_or(-1)
                ),
            });
        }
        Err(e) => {
            results.push(CheckResult {
                name: "verify: script passes".into(),
                passed: false,
                detail: format!("failed to run verify script: {e}"),
            });
        }
    }
}

fn is_session_branch(branch: &str) -> bool {
    let rest = match branch.strip_prefix("session-") {
        Some(r) => r,
        None => return false,
    };
    let dash = match rest.find('-') {
        Some(i) if i >= 2 => i,
        _ => return false,
    };
    let digits = &rest[..dash];
    let slug = &rest[dash + 1..];
    digits.chars().all(|c| c.is_ascii_digit())
        && !slug.is_empty()
        && slug
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
}

fn current_branch(root: &Path) -> String {
    Command::new("git")
        .arg("branch")
        .arg("--show-current")
        .current_dir(root)
        .output()
        .ok()
        .filter(|output| output.status.success())
        .and_then(|output| String::from_utf8(output.stdout).ok())
        .map(|stdout| stdout.trim().to_string())
        .filter(|branch| !branch.is_empty())
        .unwrap_or_else(|| "?".to_string())
}

fn print_results(results: &[CheckResult], maturity: MaturityLevel) {
    println!("=== vajra check ({maturity} {}) ===", maturity.label());
    println!();
    let header_detail = "DETAIL";
    println!("{:<30} {:<6} {header_detail}", "CHECK", "STATUS");
    let rule = "─".repeat(30);
    println!("{rule:<30} {:<6} {rule}", "──────");

    let fail_label = if maturity == MaturityLevel::L1 {
        "WARN"
    } else {
        "FAIL"
    };

    for r in results {
        let status = if r.passed { "PASS" } else { fail_label };
        println!("{:<30} {:<6} {}", r.name, status, r.detail);
    }

    let pass = results.iter().filter(|r| r.passed).count();
    let fail = results.iter().filter(|r| !r.passed).count();
    let total = results.len();

    println!();
    if fail == 0 {
        println!("Score: {pass}/{total} — ALL GREEN");
    } else if maturity == MaturityLevel::L1 {
        println!("Score: {pass}/{total} — {fail} WARNED (L1 report-only)");
    } else {
        println!("Score: {pass}/{total} — {fail} FAILED");
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn setup_minimal_repo(dir: &Path, session: &str) {
        let ai = dir.join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(ai.join("SESSION"), session).unwrap();
        fs::write(ai.join("AGENTS.md"), "# Agents").unwrap();
        fs::write(
            ai.join("SESSION-BOOT.md"),
            format!("- **Number:** {}\n", session.trim()),
        )
        .unwrap();
        fs::write(ai.join("TASK.md"), "# Task").unwrap();
        fs::write(ai.join("STATE.md"), "# State").unwrap();
        fs::write(ai.join("CONSTRAINTS.yaml"), "version: 3").unwrap();
    }

    #[test]
    fn find_repo_root_finds_ai_dir() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join(".ai")).unwrap();
        assert_eq!(find_repo_root(tmp.path()), Some(tmp.path().to_path_buf()));
    }

    #[test]
    fn find_repo_root_returns_none_without_ai() {
        let tmp = tempfile::tempdir().unwrap();
        assert_eq!(find_repo_root(tmp.path()), None);
    }

    #[test]
    fn check_required_files_all_present() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "01\n");
        let mut results = Vec::new();
        check_required_files(tmp.path(), &mut results);
        assert!(results.iter().all(|r| r.passed));
        assert_eq!(results.len(), REQUIRED_FILES.len());
    }

    #[test]
    fn check_required_files_missing() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join(".ai")).unwrap();
        fs::write(tmp.path().join(".ai/SESSION"), "01\n").unwrap();
        let mut results = Vec::new();
        check_required_files(tmp.path(), &mut results);
        let failed: Vec<_> = results.iter().filter(|r| !r.passed).collect();
        assert!(!failed.is_empty());
    }

    #[test]
    fn check_session_valid_parses() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "08\n");
        let mut results = Vec::new();
        let n = check_session_valid(tmp.path(), &mut results);
        assert_eq!(n, Some(8));
        assert!(results[0].passed);
    }

    #[test]
    fn check_session_invalid() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(ai.join("SESSION"), "not-a-number\n").unwrap();
        let mut results = Vec::new();
        let n = check_session_valid(tmp.path(), &mut results);
        assert_eq!(n, None);
        assert!(!results[0].passed);
    }

    #[test]
    fn check_boot_matches() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "05\n");
        let mut results = Vec::new();
        check_boot_matches_session(tmp.path(), 5, &mut results);
        assert!(results[0].passed);
    }

    // ---- S128: the four states of the varta drift guard --------------------------------
    // A fresh `vajra init` repo has no `vajra.varta`. Before S128 that was a FAIL, so the
    // product failed its own health check on arrival. Absent-and-untracked is now PASS;
    // every state where drift can actually exist still FAILS.

    fn git_init(dir: &Path) {
        for args in [
            vec!["init", "-q"],
            vec!["config", "user.email", "t@t"],
            vec!["config", "user.name", "t"],
        ] {
            Command::new("git")
                .args(&args)
                .current_dir(dir)
                .output()
                .unwrap();
        }
    }

    #[test]
    fn varta_absent_and_untracked_passes_as_optional() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "01\n");
        git_init(tmp.path());
        let mut results = Vec::new();
        check_varta_render(tmp.path(), &mut results);
        assert!(
            results[0].passed,
            "a fresh init must not fail on a file init never creates: {}",
            results[0].detail
        );
        assert!(
            results[0].detail.contains("optional"),
            "{}",
            results[0].detail
        );
    }

    #[test]
    fn varta_absent_but_git_tracked_fails() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "01\n");
        git_init(tmp.path());
        // Commit a render, then delete it. That is real drift, and it must still be caught.
        fs::write(tmp.path().join(RENDER_PATH), "whatever").unwrap();
        Command::new("git")
            .args(["add", RENDER_PATH])
            .current_dir(tmp.path())
            .output()
            .unwrap();
        fs::remove_file(tmp.path().join(RENDER_PATH)).unwrap();

        let mut results = Vec::new();
        check_varta_render(tmp.path(), &mut results);
        assert!(!results[0].passed, "tracked-but-missing must FAIL");
        assert!(
            results[0].detail.contains("tracked in git"),
            "{}",
            results[0].detail
        );
    }

    #[test]
    fn varta_stale_fails() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "01\n");
        git_init(tmp.path());
        fs::write(tmp.path().join(RENDER_PATH), "hand-edited, not a render").unwrap();
        let mut results = Vec::new();
        check_varta_render(tmp.path(), &mut results);
        assert!(!results[0].passed, "a stale render must still FAIL");
        assert!(results[0].detail.contains("stale"), "{}", results[0].detail);
    }

    #[test]
    fn varta_matching_render_passes() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "01\n");
        git_init(tmp.path());
        let rendered = render_from_root(tmp.path()).unwrap();
        fs::write(tmp.path().join(RENDER_PATH), &rendered).unwrap();
        let mut results = Vec::new();
        check_varta_render(tmp.path(), &mut results);
        assert!(results[0].passed, "{}", results[0].detail);
        assert!(
            results[0].detail.contains("up to date"),
            "{}",
            results[0].detail
        );
    }

    #[test]
    fn check_boot_mismatch() {
        let tmp = tempfile::tempdir().unwrap();
        setup_minimal_repo(tmp.path(), "05\n");
        let mut results = Vec::new();
        check_boot_matches_session(tmp.path(), 99, &mut results);
        assert!(!results[0].passed);
    }
}
