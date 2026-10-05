//! The approvals guard (S182 → S188), driven with the JSON Claude Code sends.
//!
//! S182–S187 blocked a Bash command by reading its WORDS; S188 (DECISION-011 S188 addendum, the
//! founder's call of 2026-10-05) checks what the command CHANGED: the guard saves the folder's state
//! before every call and compares after it. The corpus below is the S181–S187 test list, kept: every
//! command the old guards blocked is now RUN for real between a real before call and a real after call,
//! and it is caught after it runs exactly when it changed the folder. The Write-tool path block is
//! unchanged and still blocks before the tool runs.

use std::collections::BTreeMap;
use std::io::Write as _;
use std::path::Path;
use std::process::{Command, Stdio};

const DIR: &str = ".ai/approvals";

/// Run `script` with `payload` on stdin in an empty L2 project; returns (exit code, stderr).
fn run(script: &str, payload: serde_json::Value) -> (i32, String) {
    let proj = tempfile::tempdir().unwrap();
    run_in(proj.path(), script, payload)
}

fn run_in(proj: &Path, script: &str, payload: serde_json::Value) -> (i32, String) {
    let shell = std::env::var("VAJRA_TEST_BASH").unwrap_or("bash".into());
    run_with(&shell, proj, script, payload)
}

fn run_with(
    shell: &str,
    proj: &Path,
    script: &str,
    mut payload: serde_json::Value,
) -> (i32, String) {
    std::fs::create_dir_all(proj.join(".ai")).unwrap();
    std::fs::write(proj.join(".ai/CONSTRAINTS.yaml"), "maturity: L2\n").unwrap();
    if let Some(o) = payload.as_object_mut() {
        o.entry("cwd")
            .or_insert_with(|| proj.to_string_lossy().into_owned().into());
    }
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let tmp = tempfile::tempdir().unwrap();
    let mut child = Command::new(shell)
        .arg(m.join(script))
        .env("CLAUDE_PROJECT_DIR", proj)
        .env("TMPDIR", tmp.path())
        .env_remove("VAJRA_GUARD_MATURITY")
        .current_dir(proj)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child
        .stdin
        .take()
        .unwrap()
        .write_all(payload.to_string().as_bytes())
        .unwrap();
    let out = child.wait_with_output().unwrap();
    (
        out.status.code().unwrap_or(-1),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

/// The before side of a Bash call, alone (no event name: how S182–S187 called it).
fn bash(cmd: &str) -> (i32, String) {
    run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}}),
    )
}

/// The declared non-writes of S182–S187.
fn reads() -> Vec<String> {
    vec![
        format!("cat {DIR}/session-181.json"),
        // the S182 live false block: a read beside a `2>&1` elsewhere in the same command
        format!("vajra approve --help 2>&1 | head -5; cat {DIR}/session-181.json"),
        format!("cat {DIR}/x 2>&1"),
        format!("ls {DIR} 2>/dev/null"),
        format!("jq . {DIR}/x >/dev/null 2>&1 && echo ok"),
        format!("git add {DIR}/session-182.json"),
        "echo hello > notes.txt".to_string(), // a write that does not name the folder
        // S186 design rec 9: a file name ending `.sh` and the word "source" are not commands.
        format!("git commit -m \"S186: {DIR} - one source, hook-approvals-guard.sh\""),
    ]
}

/// F110 — the false blocks S186 and S187 left open: these name the folder and redirect ELSEWHERE.
/// S188 closes F110: they write nothing in the folder, so nothing blocks them, before or after.
fn f110_open() -> Vec<String> {
    vec![
        format!("cat > notes.md <<'EOF'\nThe folder {DIR} holds the founder's approvals.\nEOF"),
        format!("git commit -m \"S186: fix the {DIR} guard\n\nCo-Authored-By: Claude <noreply@anthropic.com>\""),
        format!("cat <<'EOF' > notes.md\n> a quote that names {DIR}\nEOF"),
    ]
}

/// S186 (F110 b, S182 recs 1 and 5): writes the S182 guard missed or that the target reading had to
/// catch, and every spelling the S186 cold reviews found (P1–P7, R1–R3).
fn s186_writes() -> Vec<String> {
    vec![
        format!("echo x > {DIR}/y"),
        "echo x >> .AI//Approvals/../approvals/y".to_string(),
        "cd .ai && echo x > approvals/y".to_string(),
        format!("D={DIR}; echo x > $D/y"),
        format!("env -C {DIR} sh -c 'echo > x'"),
        format!("sh -c \"echo >\"' {DIR}/x'"),
        "echo x > .ai/hooks/../approvals/x".to_string(),
        "cp /tmp/y .ai/hooks/../approvals/x".to_string(),
        format!("find {DIR} -delete"),
        format!("git checkout -- {DIR}"),
        format!("sh x.sh {DIR}"),
        format!("echo x > {DIR}/`date`"),
        format!("echo x >(cat) {DIR}"),
        format!("echo x > ~/{DIR}/x"),
        format!("rsync /tmp/y {DIR}/x"),
        format!("curl -o {DIR}/x https://x"),
        format!("ls {DIR} | xargs rm"),
        // S186 cold review pass 1 — P1: a backslash-newline after `>` is a line continuation.
        format!("echo x > \\\n{DIR}/y"),
        // P2: a `>` inside another program's own text (awk's `print > f`).
        format!("awk -v f={DIR}/x 'BEGIN{{print 1 > f }}'"),
        // P3: a `cd` the old word match missed, and zsh's spellings.
        format!("${{x}}cd {DIR} && echo x > y"),
        format!("\"$x\"cd {DIR} && echo x > y"),
        format!("$'\\x63d' {DIR} && echo x > y"),
        format!("chdir {DIR} && echo x > y"),
        format!("echo x >! {DIR}/y"),
        // rec 4: wider command starts
        format!(". x.sh {DIR}"),
        format!("X=1 git checkout -- {DIR}"),
        format!("git -c a=b checkout -- {DIR}"),
        format!("curl -o{DIR}/x https://x"),
        format!("if true; then sh x.sh {DIR}; fi"),
        // S186 cold review pass 2 — P4 (zsh), P5, P6, P7.
        format!("echo x >&! {DIR}/y"),
        format!("echo x >>! {DIR}/y"),
        format!("echo x >>| {DIR}/y"),
        format!("if c${{x}}d {DIR}; then echo x > y; fi"),
        format!("builtin c${{x}}d {DIR} && echo x > y"),
        format!("/usr/bin/awk -v f={DIR}/x 'BEGIN{{print 1 > f }}'"),
        format!("/usr/bin/awk -v f={DIR}/x 'BEGIN{{print 1}}'"),
        format!("l''n -s {DIR} l; echo x > l/y"),
        format!("l''n -s {DIR} l"),
        // S186 cold review pass 3 — R1, R2: a comment line ending in `\` is not a continuation.
        format!("true #x\\\nrm -f {DIR}/session-186.json"),
        format!("true #x\\\ncp /tmp/forged {DIR}/187.json"),
        "true #x\\\ncd .ai\necho x > approvals/y".to_string(),
        // S186 cold review pass 4: large commands (the S182 guard let ~60 KB through by SIGPIPE).
        format!(
            "cp /tmp/forged {DIR}/187.json; true \\\n{}",
            "a".repeat(20 * 1024)
        ),
        format!(
            "cp /tmp/forged {DIR}/187.json; true \\\n{}",
            "a".repeat(70 * 1024)
        ),
        format!(
            "cp /tmp/forged {DIR}/187.json; true {}",
            "a".repeat(120 * 1024)
        ),
    ]
}

fn writes() -> Vec<String> {
    vec![
        format!("echo x > {DIR}/x"),
        format!("echo x >> {DIR}/x"),
        format!("echo x 2>&1 > {DIR}/x"),
        format!("echo x 2> {DIR}/x"),
        format!("echo x &> {DIR}/x"),
        format!("echo x >| {DIR}/x"),
        format!("echo x | tee {DIR}/x"),
        format!("cp /tmp/y {DIR}/x"),
        format!("mv /tmp/y {DIR}/x"),
        format!("rm {DIR}/x"),
        format!("touch {DIR}/x"),
        format!("sed -i '' 's/a/b/' {DIR}/x"),
        format!("sed -E -i '' 's/a/b/' {DIR}/x"),
        format!("ln -s /tmp/y {DIR}/x"),
        format!("truncate -s 0 {DIR}/x"),
        format!("python3 -c 'open(\"{DIR}/x\",\"w\")'"),
        format!("perl -e 'print 1' {DIR}/x"),
        format!("node -e '' {DIR}/x"),
        "cd .ai && echo x > approvals/x".to_string(),
        "cd .ai/approvals && touch x".to_string(),
        "x=`cd .ai && echo y > approvals/z`".to_string(),
        format!("echo x >&1/../{DIR}/x"),
        "echo x > .AI/Approvals/x".to_string(),
        "echo x > \".ai\"/approvals/x".to_string(),
        "echo x > '.ai/approvals'/x".to_string(),
    ]
}

/// S187 (F110 class): a read joined to an unrelated command — the S187 guard blocked it and said "split
/// it". S188: it writes nothing in the folder, so it passes.
fn s187_split() -> Vec<String> {
    vec![
        format!("git checkout -b X main && cd ~/playground/rudra && ls {DIR}/"),
        format!("ls {DIR}; rm notes.txt"),
        format!("cat {DIR}/session-187.json && python3 tool.py"),
        format!("ls {DIR} && awk 1 notes.txt"),
    ]
}

/// The whole S181–S187 corpus, each command once.
fn corpus() -> Vec<String> {
    let mut all: Vec<String> = Vec::new();
    for c in reads()
        .into_iter()
        .chain(writes())
        .chain(s186_writes())
        .chain(f110_open())
        .chain(s187_split())
    {
        if !all.contains(&c) {
            all.push(c);
        }
    }
    all
}

/// AC1: the before side reads no Bash command any more — every read the old guards false-blocked passes.
#[test]
fn reads_f110_and_joined_reads_pass_the_before_side() {
    for cmd in reads().into_iter().chain(f110_open()).chain(s187_split()) {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 0, "read was blocked: {cmd}\n{err}");
    }
}

#[test]
fn write_tools_block_on_the_path() {
    for (tool, key, path) in [
        ("Write", "file_path", format!("/p/{DIR}/session-9.json")),
        ("Edit", "file_path", format!("{DIR}/session-9.json")),
        (
            "MultiEdit",
            "file_path",
            "/p/.ai//./approvals/x".to_string(),
        ),
        ("NotebookEdit", "notebook_path", format!("/p/{DIR}/n.ipynb")),
        ("Write", "file_path", "/p/.AI/Approvals/x".to_string()),
        // S182 review rec 1 (S186): a `..` segment that lands in the folder.
        (
            "Write",
            "file_path",
            "/p/.ai/hooks/../approvals/x".to_string(),
        ),
        ("Edit", "file_path", ".ai/hooks/../approvals/x".to_string()),
    ] {
        let (code, _) = run(
            "scripts/hook-approvals-guard.sh",
            serde_json::json!({"tool_name": tool, "tool_input": {key: path}}),
        );
        assert_eq!(code, 2, "{tool} into {path} was not blocked");
        // S188: the same, sent as Claude Code sends it now (an event name and a call id).
        let (code, _) = run(
            "scripts/hook-approvals-guard.sh",
            serde_json::json!({"hook_event_name": "PreToolUse", "tool_name": tool,
                "tool_use_id": "toolu_w", "tool_input": {key: path}}),
        );
        assert_eq!(
            code, 2,
            "{tool} into {path} was not blocked (with an event)"
        );
    }
    let (code, _) = run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": "/p/prompts/approvals-notes.md"}}),
    );
    assert_eq!(code, 0, "a file merely named like the folder was blocked");
}

/// L1 is report-only on the before side too: a Write into the folder warns and passes.
#[test]
fn l1_warns_only() {
    let proj = tempfile::tempdir().unwrap();
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut child = Command::new("bash")
        .arg(m.join("scripts/hook-approvals-guard.sh"))
        .env("CLAUDE_PROJECT_DIR", proj.path())
        .env("VAJRA_GUARD_MATURITY", "L1")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let p =
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": format!("{DIR}/x")}});
    child
        .stdin
        .take()
        .unwrap()
        .write_all(p.to_string().as_bytes())
        .unwrap();
    let out = child.wait_with_output().unwrap();
    assert_eq!(out.status.code(), Some(0));
    assert!(String::from_utf8_lossy(&out.stdout).contains("[HOOK WARNING]"));
}

/// Vajra's own hooks call the one guard: the Write block through hook-pre-write.sh, and a Bash read
/// through hook-pre-bash.sh passes (the Bash pair through it: `s188_vajras_own_pre_hook_…` below).
#[test]
fn vajras_own_hooks_call_the_guard() {
    let (code, err) = run(
        "scripts/hook-pre-bash.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": format!("cat {DIR}/x 2>&1")}}),
    );
    assert_eq!(code, 0, "hook-pre-bash.sh blocked a read\n{err}");
    let (code, _) = run(
        "scripts/hook-pre-write.sh",
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": format!("/p/{DIR}/x")}}),
    );
    assert_eq!(code, 2, "hook-pre-write.sh let a write through");
}

/// S182 review rec 3: without jq the guard advises at L1 (like every other shipped hook) and still
/// fails closed at L2.
/// S183: PATH=/bin was "no jq" only on macOS — on Linux /bin IS /usr/bin, where GitHub's runners have
/// jq, so this failed CI from S182's merge on. PATH is now a folder of links to every tool in /bin and
/// /usr/bin except jq, and the test first proves jq is not found there.
#[test]
fn no_jq_advises_at_l1_and_blocks_at_l2() {
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let proj = tempfile::tempdir().unwrap();
    let nojq = tempfile::tempdir().unwrap();
    for dir in ["/bin", "/usr/bin"] {
        for e in std::fs::read_dir(dir).unwrap().flatten() {
            let name = e.file_name();
            let link = nojq.path().join(&name);
            if name != "jq" && !link.exists() {
                std::os::unix::fs::symlink(e.path(), link).unwrap();
            }
        }
    }
    let path = nojq.path().to_str().unwrap();
    let found = Command::new("/bin/bash")
        .args(["-c", "command -v jq"])
        .env("PATH", path)
        .output()
        .unwrap();
    assert!(!found.status.success(), "the no-jq PATH still finds jq");
    for (level, want) in [("L1", 0), ("L2", 2)] {
        let code = Command::new("/bin/bash")
            .arg(m.join("scripts/hook-approvals-guard.sh"))
            .env("PATH", path)
            .env("CLAUDE_PROJECT_DIR", proj.path())
            .env("VAJRA_GUARD_MATURITY", level)
            .stdin(Stdio::null())
            .output()
            .unwrap()
            .status
            .code();
        assert_eq!(code, Some(want), "no jq at {level}");
    }
}

/// What is in the folder, read independently of the guard: each entry's kind and bytes (a link's target).
fn folder(p: &Path) -> Option<BTreeMap<String, Vec<u8>>> {
    use std::os::unix::fs::PermissionsExt;
    let ap = p.join(DIR);
    let meta = std::fs::symlink_metadata(&ap).ok()?;
    let mut out = BTreeMap::new();
    out.insert(
        String::new(),
        format!("{:?} {:o}", meta.file_type(), meta.permissions().mode()).into_bytes(),
    );
    let mut stack = vec![ap.clone()];
    while let Some(d) = stack.pop() {
        let Ok(rd) = std::fs::read_dir(&d) else {
            continue;
        };
        for e in rd.flatten() {
            let path = e.path();
            let rel = path
                .strip_prefix(&ap)
                .unwrap()
                .to_string_lossy()
                .into_owned();
            let m = std::fs::symlink_metadata(&path).unwrap();
            let v = if m.file_type().is_symlink() {
                std::fs::read_link(&path)
                    .unwrap()
                    .to_string_lossy()
                    .as_bytes()
                    .to_vec()
            } else if m.is_dir() {
                stack.push(path.clone());
                b"dir".to_vec()
            } else {
                std::fs::read(&path).unwrap_or_else(|_| b"unreadable".to_vec())
            };
            out.insert(rel, v);
        }
    }
    Some(out)
}

/// One corpus command, run for real as an AI call in a fresh project: the before hook, the command (its
/// `/tmp/` fixtures and `https://x` made local, HOME a scratch folder), the after hook its exit picks.
struct Real {
    changed: bool,
    pre: i32,
    post: i32,
    voided: bool,
}

fn run_for_real(cmd: &str, old_guard: &Path) -> (i32, Real) {
    let ai = ai_project();
    let p = ai.proj.path();
    let fx = ai.tmp.path().join("fx");
    std::fs::create_dir_all(fx.join(DIR)).unwrap();
    for f in ["y", "forged", "f"] {
        std::fs::write(
            fx.join(f),
            "{\"session\": 189, \"method\": \"approve-command\"}\n",
        )
        .unwrap();
    }
    let cmd = cmd
        .replace("/tmp/", &format!("{}/", fx.display()))
        .replace("https://x", &format!("file://{}/y", fx.display()));
    let input = serde_json::json!({ "command": cmd });
    let old = hook_in(
        &ai,
        old_guard.to_str().unwrap(),
        &serde_json::json!({"tool_name": "Bash", "tool_input": input, "cwd": p}),
        None,
    )
    .0;
    let id = "toolu_corpus";
    let pre = hook_in(
        &ai,
        "scripts/hook-approvals-guard.sh",
        &payload("PreToolUse", "Bash", id, input.clone()),
        None,
    )
    .0;
    let before = folder(p);
    let ran = Command::new("bash")
        .args(["-c", &cmd])
        .current_dir(p)
        .env("HOME", &fx)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .unwrap();
    let changed = folder(p) != before;
    let event = if ran.success() {
        "PostToolUse"
    } else {
        "PostToolUseFailure"
    };
    let post = hook_in(
        &ai,
        "scripts/hook-approvals-guard.sh",
        &payload(event, "Bash", id, input),
        None,
    )
    .0;
    let voided = !approved_188(&ai);
    // restore permissions a command may have taken away, so the temp folder can be removed
    let _ = Command::new("chmod").args(["-R", "u+rwx"]).arg(p).status();
    (
        old,
        Real {
            changed,
            pre,
            post,
            voided,
        },
    )
}

/// S188 — "guard changes only add" (S173) is reversed for Bash by the founder's call; what replaces it,
/// CHECKED: every corpus command the guard S188 started from (43305fd) blocked before it ran, now run for
/// real, is caught after it runs exactly when it changed the folder (and the approval stops counting);
/// one that changed nothing passes. The before side blocks no Bash command at all.
#[test]
fn every_command_the_start_guard_blocked_is_caught_after_if_it_wrote() {
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let old = Command::new("git")
        .args(["show", "43305fd:scripts/hook-approvals-guard.sh"])
        .current_dir(m)
        .output()
        .unwrap();
    assert!(old.status.success(), "cannot read the start guard from git");
    let dir = tempfile::tempdir().unwrap();
    let old_guard = dir.path().join("old-approvals-guard.sh");
    std::fs::write(&old_guard, &old.stdout).unwrap();
    let (mut blocked, mut caught, mut moved) = (0, 0, Vec::new());
    for cmd in corpus() {
        let (o, r) = run_for_real(&cmd, &old_guard);
        assert_eq!(r.pre, 0, "the before side blocked a Bash command: {cmd}");
        assert_eq!(
            r.post == 2,
            r.changed,
            "`{cmd}`: changed {} but after-exit {}",
            r.changed,
            r.post
        );
        assert_eq!(
            r.voided, r.changed,
            "`{cmd}`: changed {} but voided {}",
            r.changed, r.voided
        );
        if o == 2 {
            blocked += 1;
            if r.changed {
                caught += 1;
            } else {
                moved.push(cmd.chars().take(60).collect::<String>());
            }
        }
    }
    eprintln!("start guard blocked {blocked}: {caught} caught after they wrote; {} wrote nothing and pass: {moved:?}", moved.len());
    assert!(
        blocked >= 60,
        "the old guard must actually run ({blocked} blocked)"
    );
    assert!(
        caught >= 40,
        "most old blocks must really write and be caught ({caught})"
    );
}

/// Writes through a link or a hard link into a record, run for real: caught after. (S186 wrote these
/// for the target-reading guard; the S182 rule blocked them by their words until S188.)
#[test]
fn writes_through_a_link_are_caught_after() {
    for cmd in [
        format!("cat {DIR}/session-188.json > soft.md"),
        format!("cat {DIR}/session-188.json > hard.md"),
        format!("cat {DIR}/session-188.json > sub/link/x"),
        format!("cat {DIR}/session-188.json > sub/link/../approvals/x"),
    ] {
        let ai = ai_project();
        let p = ai.proj.path();
        let rec = p.join(DIR).join("session-188.json");
        std::os::unix::fs::symlink(&rec, p.join("soft.md")).unwrap();
        std::fs::hard_link(&rec, p.join("hard.md")).unwrap();
        std::fs::create_dir_all(p.join("sub")).unwrap();
        std::os::unix::fs::symlink(p.join(DIR), p.join("sub/link")).unwrap();
        let c = bash_call(&ai, &cmd);
        assert_eq!((c.pre, c.post), (0, 2), "{cmd}: {}", c.err);
        assert!(!approved_188(&ai), "{cmd}");
    }
}

/// S186 cold review rec 8: a working folder inside `.ai/approvals` — a relative write lands there
/// without the command naming it. Caught after; the same command from the project root is not a change.
#[test]
fn a_write_from_inside_the_folder_is_caught_after() {
    let ai = ai_project();
    let c = bash_call(&ai, &format!("cd {DIR} && echo x > y"));
    assert_eq!(c.post, 2, "{}", c.err);
    let ai = ai_project();
    let c = bash_call(&ai, "echo x > y");
    assert_eq!(c.post, 0, "from the project root: {}", c.err);
}

/// S186 cold review pass 3, R3: a folder that cannot be entered must not end the guard with a
/// non-blocking exit 1. The change it hides (`chmod` back, then a write) is caught after.
#[test]
fn an_unenterable_folder_does_not_open_the_guard() {
    use std::os::unix::fs::PermissionsExt;
    let ai = ai_project();
    let ap = ai.proj.path().join(DIR);
    std::fs::set_permissions(&ap, std::fs::Permissions::from_mode(0o000)).unwrap();
    let c = bash_call(&ai, &format!("chmod 755 {DIR} && cp forged.json {DIR}/x"));
    std::fs::set_permissions(&ap, std::fs::Permissions::from_mode(0o755)).unwrap();
    assert_eq!((c.pre, c.post), (0, 2), "{}", c.err);
}

/// S186 cold review pass 5: a backslash-dense command must be decided fast (a hook past its timeout does
/// not block). Runs `/bin/bash` (macOS's 3.2) where it exists; the write in it is caught after.
#[test]
fn a_backslash_dense_command_is_decided_fast() {
    let dense = "\\a".repeat(30_000);
    let cmd = format!(": '{dense}' \\\n; echo x > {DIR}/y");
    let ai = ai_project();
    let t = std::time::Instant::now();
    let c = bash_call(&ai, &cmd);
    assert_eq!((c.pre, c.post), (0, 2), "{}", c.err);
    assert!(t.elapsed().as_secs() < 10, "took {:?}", t.elapsed());
}

// ── S188: the before/after check ─────────────────────────────────────────────────────────────────
// Each case is one AI tool call as Claude Code runs it: PreToolUse, the REAL command (bash, in the
// project), then PostToolUse — or PostToolUseFailure when the command failed — every hook a real run of
// the shipped script, paired by tool_use_id. TMPDIR is the test's own, so the before records of two
// tests never meet.

struct Ai {
    proj: tempfile::TempDir,
    tmp: tempfile::TempDir,
    calls: std::cell::Cell<u32>,
}

/// One hook run: (exit code, stdout, stderr).
fn hook_in(
    ai: &Ai,
    script: &str,
    payload: &serde_json::Value,
    maturity: Option<&str>,
) -> (i32, String, String) {
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut c = Command::new(std::env::var("VAJRA_TEST_BASH").unwrap_or("bash".into()));
    c.arg(m.join(script))
        .env("CLAUDE_PROJECT_DIR", ai.proj.path())
        .env("TMPDIR", ai.tmp.path())
        .env_remove("VAJRA_GUARD_MATURITY")
        .current_dir(ai.proj.path())
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    if let Some(l) = maturity {
        c.env("VAJRA_GUARD_MATURITY", l);
    }
    let mut child = c.spawn().unwrap();
    child
        .stdin
        .take()
        .unwrap()
        .write_all(payload.to_string().as_bytes())
        .unwrap();
    let out = child.wait_with_output().unwrap();
    (
        out.status.code().unwrap_or(-1),
        String::from_utf8_lossy(&out.stdout).into_owned(),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

/// A project with one approved session (188) and git, ready for AI calls.
fn ai_project() -> Ai {
    let ai = Ai {
        proj: tempfile::tempdir().unwrap(),
        tmp: tempfile::tempdir().unwrap(),
        calls: std::cell::Cell::new(0),
    };
    let p = ai.proj.path();
    std::fs::create_dir_all(p.join(DIR)).unwrap();
    std::fs::create_dir_all(p.join(".ai/hooks")).unwrap(); // so `.ai/hooks/../approvals/x` resolves
    std::fs::write(p.join(".ai/CONSTRAINTS.yaml"), "maturity: L2\n").unwrap();
    std::fs::write(
        p.join(DIR).join("session-188.json"),
        "{\"session\": 188, \"method\": \"approve-command\", \"at_unix\": 1}\n",
    )
    .unwrap();
    std::fs::write(p.join("notes.txt"), "n\n").unwrap();
    std::fs::write(
        p.join("forged.json"),
        "{\"session\": 189, \"method\": \"approve-command\"}\n",
    )
    .unwrap();
    let git = |args: &[&str]| {
        let ok = Command::new("git")
            .args(args)
            .current_dir(p)
            .env("GIT_AUTHOR_NAME", "t")
            .env("GIT_AUTHOR_EMAIL", "t@t")
            .env("GIT_COMMITTER_NAME", "t")
            .env("GIT_COMMITTER_EMAIL", "t@t")
            .output()
            .unwrap()
            .status
            .success();
        assert!(ok, "git {args:?}");
    };
    git(&["init", "-q", "-b", "main"]);
    git(&["add", "-A"]);
    git(&["commit", "-q", "-m", "start"]);
    ai
}

struct Call {
    pre: i32,
    ran: i32,
    post: i32,
    out: String,
    err: String,
}

fn payload(event: &str, tool: &str, id: &str, input: serde_json::Value) -> serde_json::Value {
    serde_json::json!({"hook_event_name": event, "tool_name": tool, "tool_use_id": id, "tool_input": input})
}

/// One Bash call: Pre → the command → Post/PostFailure, through `pre_script` for the Pre side (the guard
/// itself, or Vajra's own hook-pre-bash.sh which calls it).
fn bash_call_via(ai: &Ai, pre_script: &str, cmd: &str, maturity: Option<&str>) -> Call {
    ai.calls.set(ai.calls.get() + 1);
    let id = format!("toolu_s188_{}", ai.calls.get());
    let input = serde_json::json!({ "command": cmd });
    let (pre, _, _) = hook_in(
        ai,
        pre_script,
        &payload("PreToolUse", "Bash", &id, input.clone()),
        maturity,
    );
    let ran = Command::new("bash")
        .args(["-c", cmd])
        .current_dir(ai.proj.path())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .unwrap()
        .code()
        .unwrap_or(-1);
    let event = if ran == 0 {
        "PostToolUse"
    } else {
        "PostToolUseFailure"
    };
    let (post, out, err) = hook_in(
        ai,
        "scripts/hook-approvals-guard.sh",
        &payload(event, "Bash", &id, input),
        maturity,
    );
    Call {
        pre,
        ran,
        post,
        out,
        err,
    }
}

fn bash_call(ai: &Ai, cmd: &str) -> Call {
    bash_call_via(ai, "scripts/hook-approvals-guard.sh", cmd, None)
}

fn approved_188(ai: &Ai) -> bool {
    vajractl::approval::approved(ai.proj.path(), 188).is_some()
}

/// AC2's corpus: every write the old guard's corpus names that a stock machine can run, plus the two
/// tech-lead rec 7 cases — a write inside a FAILING command and a path built at run time (the hole
/// DECISION-011 admitted the word guard had).
fn s188_writes() -> Vec<String> {
    vec![
        format!("echo x > {DIR}/x"),
        format!("echo x >> {DIR}/session-188.json"),
        format!("cp forged.json {DIR}/session-189.json"),
        format!("mv {DIR}/session-188.json notes.md"),
        format!("rm {DIR}/session-188.json"),
        format!("echo x | tee {DIR}/x >/dev/null"),
        format!("touch {DIR}/x"),
        format!("ln -s ../../forged.json {DIR}/session-189.json"),
        format!("truncate -s 0 {DIR}/session-188.json"),
        format!("dd if=forged.json of={DIR}/session-189.json 2>/dev/null"),
        format!("python3 -c 'open(\"{DIR}/x\",\"w\").write(\"1\")'"),
        format!("perl -e 'open(F, \">\", \"{DIR}/x\"); print F 1'"),
        format!("awk 'BEGIN{{print 1 > \"{DIR}/x\"}}'"),
        format!("find {DIR} -name '*.json' -delete"),
        format!("cp forged.json {DIR}/session-189.json; false"),
        "d=.ai; a=appr; cp forged.json $d/${a}ovals/session-189.json".to_string(),
        format!("cd {DIR} && echo x > y"),
        format!("mkdir {DIR}/sub"),
        format!("rm -rf {DIR}"),
    ]
}

#[test]
fn s188_every_write_is_caught_after_it_runs_and_the_approval_stops_counting() {
    for cmd in s188_writes() {
        let ai = ai_project();
        assert!(approved_188(&ai), "the fixture starts approved");
        let c = bash_call(&ai, &cmd);
        assert_eq!(
            c.post, 2,
            "`{cmd}` (ran {}) was not caught: {}",
            c.ran, c.err
        );
        assert_eq!(c.pre, 0, "`{cmd}`: the before side reads no Bash command");
        assert!(c.err.contains("[vajra] CAUGHT"), "`{cmd}`: {}", c.err);
        assert!(
            c.err.contains("vajra approve NN") && c.err.contains("tell the founder"),
            "the message says who writes there and what to do: {}",
            c.err
        );
        assert!(!approved_188(&ai), "`{cmd}`: session 188 still counts");
        assert!(
            vajractl::approval::approved(ai.proj.path(), 189).is_none(),
            "`{cmd}`: a forged later record counts"
        );
    }
}

/// `git checkout --` restores a committed record over a changed one — a change, caught.
#[test]
fn s188_git_checkout_of_the_folder_is_caught() {
    let ai = ai_project();
    std::fs::write(
        ai.proj.path().join(DIR).join("session-188.json"),
        "{\"session\": 188, \"method\": \"approve-command\", \"at_unix\": 2}\n",
    )
    .unwrap(); // the founder's newer record, not yet committed
    let c = bash_call(&ai, &format!("git checkout -- {DIR}"));
    assert_eq!(c.post, 2, "{}", c.err);
    assert!(c.err.contains("changed: session-188.json"), "{}", c.err);
}

/// AC1 (the after side): every read the old guard false-blocked changes nothing, so the after check is
/// silent, and the before side (no word reading since S188) passes them too.
#[test]
fn s188_reads_change_nothing_and_the_after_check_is_silent() {
    let ai = ai_project();
    let reads = [
        format!("ls {DIR}/"),
        format!("cat {DIR}/session-188.json 2>&1"),
        format!(
            "git checkout -q -b X main && cd .. && ls {}/{DIR}/",
            ai.proj.path().display()
        ),
        format!("cat > notes.md <<'EOF'\nThe folder {DIR} holds the founder's approvals.\nEOF"),
        format!("git add notes.md && git -c user.name=t -c user.email=t@t commit -q -m \"fix the {DIR} guard\n\nCo-Authored-By: Claude <noreply@anthropic.com>\""),
        format!("ls {DIR}; rm notes.txt"),
        format!("cat {DIR}/session-188.json && python3 -c 'print(1)'"),
        format!("ls {DIR} && awk 1 notes.md"),
        format!("jq . {DIR}/session-188.json >/dev/null && false"),
    ];
    for cmd in reads {
        let c = bash_call(&ai, &cmd);
        assert_eq!(
            (c.pre, c.post),
            (0, 0),
            "`{cmd}` (ran {}) was flagged: {}",
            c.ran,
            c.err
        );
        assert!(approved_188(&ai), "`{cmd}` voided the approval");
    }
}

/// AC3 / deliverable 5: the founder's `vajra approve` lands BETWEEN two AI calls — nothing is raised,
/// and the new record counts, even after a void.
#[test]
fn s188_the_founders_approve_between_calls_raises_nothing() {
    let ai = ai_project();
    assert_eq!(bash_call(&ai, &format!("cp forged.json {DIR}/x")).post, 2);
    assert!(!approved_188(&ai));
    vajractl::approval::approve(ai.proj.path(), 188, false, true).unwrap();
    assert!(approved_188(&ai), "the founder's yes counts again");
    let c = bash_call(&ai, &format!("ls {DIR}"));
    assert_eq!(c.post, 0, "the founder's write was flagged: {}", c.err);
    assert!(approved_188(&ai));
}

/// Tech-lead rec 4: the founder's approve lands WHILE an AI command runs — what really happens: it is
/// flagged (the pair cannot tell who wrote), and the message tells the founder to run it again.
#[test]
fn s188_an_approve_during_a_command_is_flagged_and_says_run_it_again() {
    let ai = ai_project();
    let input = serde_json::json!({"command": "sleep 0"});
    let id = "toolu_s188_overlap";
    let script = "scripts/hook-approvals-guard.sh";
    let pre = payload("PreToolUse", "Bash", id, input.clone());
    assert_eq!(hook_in(&ai, script, &pre, None).0, 0);
    vajractl::approval::approve(ai.proj.path(), 188, false, true).unwrap(); // mid-command
    let post = payload("PostToolUse", "Bash", id, input);
    let (code, _, err) = hook_in(&ai, script, &post, None);
    assert_eq!(code, 2);
    assert!(
        err.contains("if you ran `vajra approve` yourself while this command was running"),
        "{err}"
    );
    assert!(!approved_188(&ai));
    vajractl::approval::approve(ai.proj.path(), 188, false, true).unwrap();
    assert!(approved_188(&ai), "running it again works");
}

/// Design-advisor rec 6: no before record (deleted, a Pre hook that never ran) and no tool_use_id both
/// count as a change at L2; at L1 they and a real change are one report line, exit 0, nothing voided.
#[test]
fn s188_no_before_record_counts_as_a_change_and_l1_only_reports() {
    let ai = ai_project();
    let script = "scripts/hook-approvals-guard.sh";
    let input = serde_json::json!({"command": "ls"});
    let never = payload("PostToolUse", "Bash", "toolu_never_pre", input.clone());
    let (code, _, err) = hook_in(&ai, script, &never, None);
    assert_eq!(code, 2, "a missing before record must void");
    assert!(
        err.contains("could not compare") && err.contains("no record of the folder from before"),
        "{err}"
    );
    assert!(!approved_188(&ai));

    let ai = ai_project();
    let no_id = serde_json::json!({"hook_event_name": "PostToolUseFailure", "tool_name": "Bash", "tool_input": input});
    let (code, _, err) = hook_in(&ai, script, &no_id, None);
    assert_eq!(code, 2);
    assert!(err.contains("update Claude Code"), "{err}");

    for cmd in [format!("cp forged.json {DIR}/x"), "true".to_string()] {
        let ai = ai_project();
        let c = bash_call_via(&ai, script, &cmd, Some("L1"));
        assert_eq!(c.post, 0, "L1 never blocks: {cmd}");
        assert!(
            c.out.contains("[HOOK WARNING]") || cmd == "true",
            "{cmd}: {}",
            c.out
        );
        assert!(
            !ai.proj.path().join(DIR).join("voided.json").exists(),
            "L1 voided: {cmd}"
        );
        assert!(approved_188(&ai));
    }
    let ai = ai_project();
    let none = payload("PostToolUse", "Bash", "toolu_none", serde_json::json!({}));
    let (code, out, _) = hook_in(&ai, script, &none, Some("L1"));
    assert_eq!(code, 0);
    assert!(
        out.contains("[HOOK WARNING]") && out.contains("no record"),
        "{out}"
    );
}

/// Design-advisor rec 2: the after check may run twice for one call (wired twice, or vajra claude's
/// --settings copy). It never deletes the before record, so both runs give the same answer.
#[test]
fn s188_a_second_after_run_gives_the_same_answer() {
    let ai = ai_project();
    let script = "scripts/hook-approvals-guard.sh";
    for (id, cmd, want) in [
        ("toolu_twice_a", "ls".to_string(), 0),
        ("toolu_twice_b", format!("cp forged.json {DIR}/x"), 2),
    ] {
        let input = serde_json::json!({ "command": cmd });
        let pre = payload("PreToolUse", "Bash", id, input.clone());
        assert_eq!(hook_in(&ai, script, &pre, None).0, 0);
        Command::new("bash")
            .args(["-c", &cmd])
            .current_dir(ai.proj.path())
            .status()
            .unwrap();
        for run in 1..=2 {
            let post = payload("PostToolUse", "Bash", id, input.clone());
            let (code, _, err) = hook_in(&ai, script, &post, None);
            assert_eq!(code, want, "`{cmd}` after-run {run}: {err}");
        }
    }
}

/// Removing or editing the void is itself a change: caught, and everything present is listed again.
#[test]
fn s188_removing_the_void_is_caught_and_relisted() {
    let ai = ai_project();
    let first = bash_call(&ai, &format!("cp forged.json {DIR}/session-189.json"));
    assert_eq!(first.post, 2);
    let c = bash_call(&ai, &format!("rm {DIR}/voided.json"));
    assert_eq!(c.post, 2, "{}", c.err);
    assert!(c.err.contains("removed: voided.json"), "{}", c.err);
    assert!(!approved_188(&ai));
    assert!(vajractl::approval::approved(ai.proj.path(), 189).is_none());
}

/// Design-advisor rec 3: a Write tool aimed at a link that leads into the folder passes the path check
/// before it runs (the path is not the folder) — and the after check catches the write.
#[test]
fn s188_a_write_tool_through_a_link_is_caught_after() {
    let ai = ai_project();
    let p = ai.proj.path();
    std::os::unix::fs::symlink(p.join(DIR).join("session-189.json"), p.join("docs.md")).unwrap();
    let input =
        serde_json::json!({"file_path": p.join("docs.md").to_string_lossy(), "content": "x"});
    let script = "scripts/hook-approvals-guard.sh";
    let pre = payload("PreToolUse", "Write", "toolu_link", input.clone());
    assert_eq!(hook_in(&ai, script, &pre, None).0, 0);
    std::fs::write(
        p.join("docs.md"),
        "{\"session\": 189, \"method\": \"approve-command\"}",
    )
    .unwrap();
    let post = payload("PostToolUse", "Write", "toolu_link", input);
    let (code, _, err) = hook_in(&ai, script, &post, None);
    assert_eq!(code, 2, "{err}");
    assert!(vajractl::approval::approved(p, 189).is_none());
}

fn uid() -> String {
    String::from_utf8(Command::new("id").arg("-u").output().unwrap().stdout)
        .unwrap()
        .trim()
        .to_string()
}

/// Design-advisor rec 4: when the before record cannot be saved the Pre side exits 0, never 1 — Vajra's
/// own hook-pre-bash.sh ends on any non-zero exit and would skip its later checks; the after side then
/// counts the missing record as a change.
#[test]
fn s188_an_unsavable_before_record_exits_0_at_pre_and_is_caught_after() {
    let ai = ai_project();
    let blocker = ai.tmp.path().join(format!("vajra-approvals-{}", uid()));
    std::fs::write(&blocker, "a file where the folder should be").unwrap();
    let c = bash_call(&ai, &format!("ls {DIR}"));
    assert_eq!(c.pre, 0);
    assert_eq!(c.post, 2, "{}", c.err);
    let c = bash_call_via(&ai, "scripts/hook-pre-bash.sh", &format!("ls {DIR}"), None);
    assert_eq!(c.pre, 0, "Vajra's own Pre hook must not end early");
}

/// Vajra's own Pre hook (hook-pre-bash.sh) saves the before record through the guard: the pair works.
#[test]
fn s188_vajras_own_pre_hook_saves_the_before_record() {
    let ai = ai_project();
    let c = bash_call_via(&ai, "scripts/hook-pre-bash.sh", &format!("ls {DIR}"), None);
    assert_eq!((c.pre, c.post), (0, 0), "{}", c.err);
    let ai = ai_project();
    let c = bash_call_via(
        &ai,
        "scripts/hook-pre-bash.sh",
        "d=.ai; cp forged.json $d/approvals/x",
        None,
    );
    assert_eq!(c.post, 2, "{}", c.err);
}
