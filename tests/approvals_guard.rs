//! S182 Part 6 — the approvals guard blocks by whether a command can WRITE, not on any `>`.
//!
//! Drives the real `scripts/hook-approvals-guard.sh` (and Vajra's own `hook-pre-bash.sh` /
//! `hook-pre-write.sh`, which call it) with the JSON Claude Code sends. Two live false blocks at the
//! start of S182 are the read cases; every write the S181 line blocked must still block (S173).

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
    // Claude Code sends the agent's working folder; the guard reads it (a working folder inside
    // .ai/approvals counts as naming the folder).
    if let Some(o) = payload.as_object_mut() {
        o.entry("cwd")
            .or_insert_with(|| proj.to_string_lossy().into_owned().into());
    }
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut child = Command::new(shell)
        .arg(m.join(script))
        .env("CLAUDE_PROJECT_DIR", proj)
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

fn bash(cmd: &str) -> (i32, String) {
    run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}}),
    )
}

/// The declared non-writes: the ONLY commands the S181 line blocked that the guard may now pass.
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

/// F110 — still OPEN: the founder split (b) out of S186 (2026-10-04) after two cold reviews found
/// writes its target reading let through. These name the folder and redirect elsewhere; they still
/// block, and the block names the way past (`git commit -F`).
fn f110_open() -> Vec<String> {
    vec![
        format!("cat > notes.md <<'EOF'\nThe folder {DIR} holds the founder's approvals.\nEOF"),
        format!("git commit -m \"S186: fix the {DIR} guard\n\nCo-Authored-By: Claude <noreply@anthropic.com>\""),
        format!("cat <<'EOF' > notes.md\n> a quote that names {DIR}\nEOF"),
    ]
}

#[test]
fn f110_still_blocks_and_names_the_way_past() {
    for cmd in f110_open() {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 2, "{cmd}");
        assert!(
            err.contains("git commit -F"),
            "the block must name the way past: {err}"
        );
    }
}

/// S186 (F110 b, S182 recs 1 and 5): writes the S182 guard missed or that the new target reading
/// must still catch — AC2's block list and AC4.
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
        // S186 cold review pass 2 — P4 (zsh), P5, P6, P7: blocked by the S182 rule, kept.
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
        // S186 cold review pass 4: a large command — a piped `grep -q` could fail open on it
        // (SIGPIPE under pipefail). With and without a backslash-newline; the S182 guard let ~60 KB pass.
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
        "cd .ai && echo x > approvals/x".to_string(), // S181's disclosed gap, closed
        "cd .ai/approvals && touch x".to_string(),
        "x=`cd .ai && echo y > approvals/z`".to_string(), // inside backticks (S182, found at close)
        // S182 review rec 1: `>&word` with a non-digit word is a WRITE to the file `word`
        format!("echo x >&1/../{DIR}/x"),
        // S182 review rec 4: case and quotes reach the same folder on macOS
        "echo x > .AI/Approvals/x".to_string(),
        "echo x > \".ai\"/approvals/x".to_string(),
        "echo x > '.ai/approvals'/x".to_string(),
    ]
}

#[test]
fn reads_pass() {
    for cmd in reads() {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 0, "read was blocked: {cmd}\n{err}");
    }
}

#[test]
fn writes_still_block() {
    for cmd in writes().into_iter().chain(s186_writes()) {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 2, "write was not blocked: {cmd}");
        assert!(
            err.contains("[HOOK BLOCK]"),
            "block message not on stderr: {cmd}\n{err}"
        );
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
    }
    let (code, _) = run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": "/p/prompts/approvals-notes.md"}}),
    );
    assert_eq!(code, 0, "a file merely named like the folder was blocked");
}

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
    let p = serde_json::json!({"tool_input": {"command": format!("echo x > {DIR}/x")}});
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

/// Vajra's own hooks call the one guard: same verdicts through them.
#[test]
fn vajras_own_hooks_call_the_guard() {
    let (code, err) = run(
        "scripts/hook-pre-bash.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": format!("echo x > {DIR}/x")}}),
    );
    assert_eq!(code, 2, "hook-pre-bash.sh let a write through\n{err}");
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

/// S182 review rec 1 — "guard changes only add", CHECKED rather than stated: every command here that
/// the S181 hook (at e5db703, where S182 started) blocked must still block, unless it is one of the
/// declared non-writes in `reads()`.
#[test]
fn every_command_the_s181_guard_blocked_still_blocks() {
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let old = Command::new("git")
        .args(["show", "e5db703:scripts/hook-pre-bash.sh"])
        .current_dir(m)
        .output()
        .unwrap();
    assert!(old.status.success(), "cannot read the S181 hook from git");
    let dir = tempfile::tempdir().unwrap();
    let old_hook = dir.path().join("old-pre-bash.sh");
    std::fs::write(&old_hook, &old.stdout).unwrap();
    let reads = reads();
    let mut old_blocked = 0;
    for cmd in reads.iter().chain(writes().iter()) {
        let p = serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}});
        let (o, _) = run(old_hook.to_str().unwrap(), p);
        if o != 2 {
            continue;
        }
        old_blocked += 1;
        let (n, _) = bash(cmd);
        assert!(
            n == 2 || reads.contains(cmd),
            "the S181 guard blocked `{cmd}` and the new one lets it through"
        );
    }
    assert!(
        old_blocked >= 20,
        "the old hook must actually run ({old_blocked} blocked)"
    );
}

/// S186 AC3 — the same check one guard later, over THIS corpus: every listed command the S182 guard
/// (e1c348e) blocked must still block, unless it is a declared non-write in `reads()`. A finite list,
/// not a proof for every command (cold review pass 1 found three classes it missed: P1–P3, now listed).
#[test]
fn every_listed_command_the_s182_guard_blocked_still_blocks() {
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let old = Command::new("git")
        .args(["show", "e1c348e:scripts/hook-approvals-guard.sh"])
        .current_dir(m)
        .output()
        .unwrap();
    assert!(old.status.success(), "cannot read the S182 guard from git");
    let dir = tempfile::tempdir().unwrap();
    let old_guard = dir.path().join("old-approvals-guard.sh");
    std::fs::write(&old_guard, &old.stdout).unwrap();
    let reads = reads();
    let mut old_blocked = 0;
    for cmd in reads
        .iter()
        .chain(writes().iter())
        .chain(s186_writes().iter())
    {
        let p = serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}});
        let (o, _) = run(old_guard.to_str().unwrap(), p);
        if o != 2 {
            continue;
        }
        old_blocked += 1;
        let (n, _) = bash(cmd);
        assert!(
            n == 2 || reads.contains(cmd),
            "the S182 guard blocked `{cmd}` and the new one lets it through"
        );
    }
    assert!(
        old_blocked >= 30,
        "the old guard must actually run ({old_blocked} blocked)"
    );
}

/// Redirects into the folder through a link, or with no `cwd`, block. (Written in S186 for the
/// target-reading guard, which was split out; they now block under the S182 redirect rule, and stay as
/// cases the (b) session must keep blocking.)
#[test]
fn redirects_through_a_link_or_with_no_cwd_block() {
    let proj = tempfile::tempdir().unwrap();
    let rec = proj.path().join(DIR).join("session-1.json");
    std::fs::create_dir_all(rec.parent().unwrap()).unwrap();
    std::fs::write(&rec, "{}").unwrap();
    std::os::unix::fs::symlink(&rec, proj.path().join("soft.md")).unwrap();
    std::fs::hard_link(&rec, proj.path().join("hard.md")).unwrap();
    std::fs::create_dir_all(proj.path().join("sub")).unwrap();
    std::os::unix::fs::symlink(proj.path().join(DIR), proj.path().join("sub/link")).unwrap();
    for cmd in [
        format!("cat {DIR}/session-1.json > soft.md"),
        format!("cat {DIR}/session-1.json > hard.md"),
        format!("cat {DIR}/session-1.json > sub/link/x"),
        format!("cat {DIR}/session-1.json > sub/link/../approvals/x"),
    ] {
        let p = serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}});
        assert_eq!(
            run_in(proj.path(), "scripts/hook-approvals-guard.sh", p).0,
            2,
            "{cmd}"
        );
    }
    let p = serde_json::json!({"tool_name": "Bash", "cwd": "", "tool_input": {"command": format!("cat {DIR}/x > y")}});
    assert_eq!(
        run_in(proj.path(), "scripts/hook-approvals-guard.sh", p).0,
        2,
        "no cwd"
    );
}

/// S186 cold review rec 8: with the agent's working folder inside `.ai/approvals` (a `cd` in an
/// earlier call), a redirect writes there without naming the folder — it blocks.
#[test]
fn a_cwd_inside_the_folder_blocks_a_redirect() {
    let proj = tempfile::tempdir().unwrap();
    let inside = proj.path().join(DIR);
    std::fs::create_dir_all(&inside).unwrap();
    let p = serde_json::json!({"tool_name": "Bash", "cwd": inside.to_string_lossy(), "tool_input": {"command": "echo x > y"}});
    assert_eq!(
        run_in(proj.path(), "scripts/hook-approvals-guard.sh", p).0,
        2
    );
    let p = serde_json::json!({"tool_name": "Bash", "tool_input": {"command": "echo x > y"}});
    assert_eq!(
        run_in(proj.path(), "scripts/hook-approvals-guard.sh", p).0,
        0,
        "from the project root"
    );
}

/// S186 cold review pass 3, R3: an approvals folder that cannot be entered must not end the guard
/// with a non-blocking exit 1 — the guard still blocks a write (exit 2).
#[test]
fn an_unenterable_folder_does_not_open_the_guard() {
    use std::os::unix::fs::PermissionsExt;
    let proj = tempfile::tempdir().unwrap();
    let ap = proj.path().join(DIR);
    std::fs::create_dir_all(&ap).unwrap();
    std::fs::set_permissions(&ap, std::fs::Permissions::from_mode(0o000)).unwrap();
    let p = serde_json::json!({"tool_name": "Bash", "tool_input": {"command": format!("chmod 755 {DIR} && cp /tmp/f {DIR}/x")}});
    let code = run_in(proj.path(), "scripts/hook-approvals-guard.sh", p).0;
    std::fs::set_permissions(&ap, std::fs::Permissions::from_mode(0o755)).unwrap();
    assert_eq!(code, 2);
}

/// S186 cold review pass 5: a backslash-dense command must be decided fast. The first join was
/// quadratic on bash 3.2 (10,000 backslashes took over 120 s — a hook past its timeout does not block).
/// Runs `/bin/bash` (macOS's 3.2, the shell the slowdown needs); under bash 5 it cannot catch it.
#[test]
fn a_backslash_dense_command_blocks_fast() {
    let dense = "\\a".repeat(30_000);
    let cmd = format!(": '{dense}' \\\n; echo x > {DIR}/y");
    let proj = tempfile::tempdir().unwrap();
    let shell = if Path::new("/bin/bash").exists() {
        "/bin/bash"
    } else {
        "bash"
    };
    let t = std::time::Instant::now();
    let (code, _) = run_with(
        shell,
        proj.path(),
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}}),
    );
    assert_eq!(code, 2);
    assert!(t.elapsed().as_secs() < 5, "took {:?}", t.elapsed());
}
