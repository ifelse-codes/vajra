//! S182 Parts 3–4 — the approvals guard reaches projects, and a project is told (never edited) when
//! it has no `session_rules_from`.
//!
//! A guard file on disk that no settings entry runs is not a guard (S129, "registered ≠ run"), so
//! every check here finds the hook THROUGH the project's `.claude/settings.json` — the matcher that
//! Claude Code would apply to the tool — and runs that exact command string.

use std::fs;
use std::io::Write as _;
use std::path::Path;
use std::process::{Command, Stdio};

const GUARD: &str = "hook-approvals-guard.sh";

/// The command strings `.claude/settings.json` registers for `tool` under PreToolUse.
fn registered_for(root: &Path, tool: &str) -> Vec<String> {
    registered_in(root, "PreToolUse", tool)
}

/// The command strings `.claude/settings.json` registers for `tool` under `event` (S188: the after
/// events too — a guard the settings never run after a call catches nothing).
fn registered_in(root: &Path, event: &str, tool: &str) -> Vec<String> {
    let s: serde_json::Value =
        serde_json::from_str(&fs::read_to_string(root.join(".claude/settings.json")).unwrap())
            .unwrap();
    let mut out = Vec::new();
    for g in s["hooks"][event].as_array().into_iter().flatten() {
        let m = g["matcher"].as_str().unwrap_or("");
        if !m.split('|').any(|t| t == tool) {
            continue;
        }
        for h in g["hooks"].as_array().unwrap() {
            out.push(h["command"].as_str().unwrap().to_string());
        }
    }
    out
}

/// Run the registered approvals-guard command for `tool` under `event` exactly as settings spell it.
fn guard_run(
    root: &Path,
    tmp: &Path,
    event: &str,
    tool: &str,
    id: &str,
    input: serde_json::Value,
) -> i32 {
    let cmds: Vec<String> = registered_in(root, event, tool)
        .into_iter()
        .filter(|c| c.contains(GUARD))
        .collect();
    assert_eq!(
        cmds.len(),
        1,
        "{event} {tool}: the approvals guard must be registered exactly once, got {cmds:?}"
    );
    let mut child = Command::new("bash")
        .arg("-c")
        .arg(&cmds[0])
        .env("CLAUDE_PROJECT_DIR", root)
        .env("TMPDIR", tmp)
        .env_remove("VAJRA_GUARD_MATURITY")
        .current_dir(root)
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .unwrap();
    let payload = serde_json::json!({"hook_event_name": event, "tool_name": tool,
        "tool_use_id": id, "tool_input": input});
    child
        .stdin
        .take()
        .unwrap()
        .write_all(payload.to_string().as_bytes())
        .unwrap();
    child.wait().unwrap().code().unwrap_or(-1)
}

fn guard_exit(root: &Path, tool: &str, input: serde_json::Value) -> i32 {
    let tmp = tempfile::tempdir().unwrap();
    guard_run(root, tmp.path(), "PreToolUse", tool, "toolu_pre", input)
}

/// One AI Bash call through the project's settings: Pre, the real command, then the after event its
/// exit picks. Returns (pre, after): `after` is None when the Pre side blocked (the call never ran).
fn bash_pair(root: &Path, id: &str, cmd: &str) -> (i32, Option<i32>) {
    let tmp = tempfile::tempdir().unwrap();
    let input = serde_json::json!({ "command": cmd });
    let pre = guard_run(root, tmp.path(), "PreToolUse", "Bash", id, input.clone());
    if pre == 2 {
        return (pre, None);
    }
    let ran = Command::new("bash")
        .args(["-c", cmd])
        .current_dir(root)
        .status()
        .unwrap();
    let event = if ran.success() {
        "PostToolUse"
    } else {
        "PostToolUseFailure"
    };
    (
        pre,
        Some(guard_run(root, tmp.path(), event, "Bash", id, input)),
    )
}

fn assert_guarded(root: &Path) {
    let w = format!("{}/.ai/approvals/session-9.json", root.display());
    assert_eq!(
        guard_exit(root, "Write", serde_json::json!({"file_path": w})),
        2
    );
    assert_eq!(
        guard_exit(root, "Edit", serde_json::json!({"file_path": w})),
        2
    );
    // S188: a Bash write is caught AFTER it runs (the word checks that blocked it before are gone);
    // both after events are wired for every tool the Pre side sees.
    fs::create_dir_all(root.join(".ai/approvals")).unwrap();
    let (pre, after) = bash_pair(root, "toolu_w", "echo x > .ai/approvals/s.json");
    assert!(
        pre == 2 || after == Some(2),
        "a Bash write was neither blocked nor caught (pre {pre}, after {after:?})"
    );
    let _ = fs::remove_file(root.join(".ai/approvals/voided.json"));
    let _ = fs::remove_file(root.join(".ai/approvals/s.json"));
    assert_eq!(
        bash_pair(root, "toolu_r", "cat .ai/approvals/s.json 2>&1"),
        (0, Some(0)),
        "a read must pass, before and after"
    );
    for event in ["PostToolUse", "PostToolUseFailure"] {
        for tool in ["Bash", "Edit", "Write", "MultiEdit", "NotebookEdit"] {
            let n = registered_in(root, event, tool)
                .iter()
                .filter(|c| c.contains(GUARD))
                .count();
            assert_eq!(
                n, 1,
                "{event} {tool}: the guard must run after the call, once"
            );
        }
    }
}

fn new_project() -> tempfile::TempDir {
    let t = tempfile::tempdir().unwrap();
    fs::create_dir(t.path().join(".git")).unwrap();
    vajractl::cli::init::scaffold(t.path(), "P", "build the thing", "L2").unwrap();
    t
}

#[test]
fn a_new_project_is_guarded_through_its_settings() {
    let t = new_project();
    assert!(t.path().join(".ai/hooks").join(GUARD).exists());
    assert_guarded(t.path());
}

/// A project scaffolded before S182: no guard file, no guard group in its settings, a key of the
/// user's own, and no `session_rules_from` in its constraints.
fn old_project() -> tempfile::TempDir {
    let t = new_project();
    let r = t.path();
    fs::remove_file(r.join(".ai/hooks").join(GUARD)).unwrap();
    let p = r.join(".claude/settings.json");
    let mut s: serde_json::Value = serde_json::from_str(&fs::read_to_string(&p).unwrap()).unwrap();
    s["hooks"]["PreToolUse"]
        .as_array_mut()
        .unwrap()
        .retain(|g| !g.to_string().contains(GUARD));
    let hooks = s["hooks"].as_object_mut().unwrap();
    hooks.shift_remove("PostToolUse");
    hooks.shift_remove("PostToolUseFailure");
    s["model"] = serde_json::json!("the-user's-own-key");
    // appended LAST, so its place differs from alphabetical — the merge must keep it there (rec 5)
    s["aaa_user_key"] = serde_json::json!(1);
    fs::write(&p, serde_json::to_string_pretty(&s).unwrap()).unwrap();
    let c = r.join(".ai/CONSTRAINTS.yaml");
    let kept: String = fs::read_to_string(&c)
        .unwrap()
        .lines()
        .filter(|l| !l.contains("session_rules_from"))
        .map(|l| format!("{l}\n"))
        .collect();
    fs::write(&c, kept).unwrap();
    fs::write(r.join(".ai/SESSION"), "15\n").unwrap();
    t
}

fn sync(root: &Path, extra: &[&str]) -> String {
    let out = Command::new(env!("CARGO_BIN_EXE_vajra"))
        .args(["init", "--sync-fleet"])
        .args(extra)
        .current_dir(root)
        .output()
        .unwrap();
    format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    )
}

fn read(root: &Path, rel: &str) -> String {
    fs::read_to_string(root.join(rel)).unwrap()
}

#[test]
fn sync_fleet_guards_an_old_project_through_its_settings() {
    let t = old_project();
    let r = t.path();
    assert!(
        registered_for(r, "Bash").iter().all(|c| !c.contains(GUARD)),
        "fixture must start unguarded"
    );

    // --dry-run writes nothing.
    let before = read(r, ".claude/settings.json");
    let text = sync(r, &["--dry-run"]);
    assert!(text.contains("would   add"), "{text}");
    assert_eq!(read(r, ".claude/settings.json"), before);
    assert!(!r.join(".ai/hooks").join(GUARD).exists());

    let text = sync(r, &[]);
    assert!(text.contains("merge"), "{text}");
    // S188 cold review rec 2: the new groups run only from Claude Code's next start — said at once.
    assert!(
        text.contains("restart Claude Code in this project now"),
        "{text}"
    );
    assert!(r.join(".ai/hooks").join(GUARD).exists());
    assert_guarded(r);

    // Every hook listed exactly as a fresh scaffold lists it (no group doubled), user key kept.
    let s: serde_json::Value = serde_json::from_str(&read(r, ".claude/settings.json")).unwrap();
    let fresh = new_project();
    let f: serde_json::Value =
        serde_json::from_str(&read(fresh.path(), ".claude/settings.json")).unwrap();
    assert_eq!(
        s["hooks"], f["hooks"],
        "merged hooks must equal a fresh scaffold's"
    );
    assert_eq!(s["model"], "the-user's-own-key");
    let keys: Vec<&String> = s.as_object().unwrap().keys().collect();
    assert_eq!(
        keys.last().map(|k| k.as_str()),
        Some("aaa_user_key"),
        "the user's key order must be kept, not re-sorted: {keys:?}"
    );

    // A second run changes nothing.
    let once = read(r, ".claude/settings.json");
    let text = sync(r, &[]);
    assert!(text.contains("already wired"), "{text}");
    assert!(
        !text.contains("restart Claude Code"),
        "nothing new wired, no restart asked: {text}"
    );
    assert_eq!(read(r, ".claude/settings.json"), once);
}

/// S182 review rec 2: a project from before S93 — its Bash group lacks `hook-commit-guard.sh`. The
/// merge must add ONLY the missing hooks; appending the whole template group ran the co-pilot loader,
/// session guard and publish guard twice on every Bash call.
#[test]
fn sync_fleet_never_lists_a_hook_twice_in_a_pre_s93_project() {
    let t = old_project();
    let r = t.path();
    let p = r.join(".claude/settings.json");
    let mut s: serde_json::Value = serde_json::from_str(&read(r, ".claude/settings.json")).unwrap();
    for g in s["hooks"]["PreToolUse"].as_array_mut().unwrap() {
        if g["matcher"] == "Bash" {
            g["hooks"]
                .as_array_mut()
                .unwrap()
                .retain(|h| !h.to_string().contains("hook-commit-guard.sh"));
        }
    }
    fs::write(&p, serde_json::to_string_pretty(&s).unwrap()).unwrap();
    assert!(registered_for(r, "Bash")
        .iter()
        .all(|c| !c.contains("hook-commit-guard.sh")));

    sync(r, &[]);
    let fresh = new_project();
    let count = |root: &Path| {
        let mut all: Vec<String> = ["Bash", "Edit", "Write", "MultiEdit", "NotebookEdit"]
            .iter()
            .flat_map(|t| {
                registered_for(root, t)
                    .into_iter()
                    .map(move |c| format!("{t}:{c}"))
            })
            .collect();
        all.sort();
        all
    };
    assert_eq!(
        count(r),
        count(fresh.path()),
        "after the merge each tool must run exactly the hooks a fresh scaffold runs — none twice"
    );
    assert_guarded(r);
}

#[test]
fn sync_fleet_reports_a_missing_session_rules_from_and_never_writes_it() {
    let t = old_project();
    let r = t.path();
    let before = read(r, ".ai/CONSTRAINTS.yaml");
    let text = sync(r, &[]);
    assert!(text.contains("session_rules_from: 16"), "{text}");
    assert!(text.contains("never writes this line"), "{text}");
    // S187 (F97, DECISION-007 S187 addendum): sync may now ADD missing ground-truth audits and question
    // blocks — but never this key, and every original line stays (the one `required_audits:` line may
    // gain names; it is compared without them).
    let after = read(r, ".ai/CONSTRAINTS.yaml");
    assert!(
        !after.contains("session_rules_from"),
        "the key must never be written: {after}"
    );
    let keep = |t: &str| -> Vec<String> {
        t.lines()
            .filter(|l| !l.starts_with("  required_audits:"))
            .map(str::to_string)
            .collect()
    };
    let mut rest = keep(&after).into_iter();
    for line in keep(&before) {
        assert!(
            rest.any(|l| l == line),
            "an original line moved or changed: {line:?}"
        );
    }

    // Once the line is there, no report.
    fs::write(
        r.join(".ai/CONSTRAINTS.yaml"),
        before.replace("session:\n", "session:\n  session_rules_from: 16\n"),
    )
    .unwrap();
    let text = sync(r, &[]);
    assert!(!text.contains("session_rules_from:"), "{text}");
}

/// S188 (tech-lead rec 8): a project that already runs its OWN PostToolUse hooks keeps them exactly;
/// `--sync-fleet` adds the guard's two after groups once, and a second run adds nothing.
#[test]
fn sync_fleet_adds_the_after_check_once_and_keeps_a_projects_own_after_hooks() {
    let t = old_project();
    let r = t.path();
    let p = r.join(".claude/settings.json");
    let mut s: serde_json::Value = serde_json::from_str(&read(r, ".claude/settings.json")).unwrap();
    let own = serde_json::json!({"matcher": "Bash", "hooks": [{"type": "command", "command": "bash my-own-after.sh"}]});
    s["hooks"]["PostToolUse"] = serde_json::json!([own.clone()]);
    fs::write(&p, serde_json::to_string_pretty(&s).unwrap()).unwrap();

    sync(r, &[]);
    let s: serde_json::Value = serde_json::from_str(&read(r, ".claude/settings.json")).unwrap();
    let post = s["hooks"]["PostToolUse"].as_array().unwrap();
    assert_eq!(
        post[0], own,
        "the project's own after hook must be untouched"
    );
    assert_eq!(post.len(), 2, "one guard group added: {post:?}");
    assert_eq!(
        s["hooks"]["PostToolUseFailure"].as_array().unwrap().len(),
        1
    );
    assert_guarded(r);
    let once = read(r, ".claude/settings.json");
    sync(r, &[]);
    assert_eq!(
        read(r, ".claude/settings.json"),
        once,
        "a second run adds nothing"
    );
}

/// S188: a fresh project ignores the void (this machine's state, never committed).
#[test]
fn a_new_project_ignores_the_void() {
    let t = new_project();
    assert!(read(t.path(), ".gitignore").contains(".ai/approvals/voided.json"));
}
