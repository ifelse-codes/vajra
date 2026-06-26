use std::fs;
use std::path::PathBuf;

fn make_project(name: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("vajra-test-init-{name}-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).unwrap();
    fs::create_dir(dir.join(".git")).unwrap();
    dir
}

#[test]
fn init_creates_all_files() {
    let root = make_project("full");
    vajractl::cli::init::scaffold(&root, "TestProject", "build the thing").unwrap();

    let expected = [
        ".ai/AGENTS.md",
        ".ai/SESSION",
        ".ai/SESSION-BOOT.md",
        ".ai/TASK.md",
        ".ai/STATE.md",
        ".ai/CONSTRAINTS.yaml",
        ".ai/KNOWLEDGE.md",
        ".ai/ROADMAP.md",
        "CLAUDE.md",
        "AGENTS.md",
        ".cursorrules",
        ".claude/settings.json",
        "scripts/hook-session-start.sh",
        "scripts/verify-session-template.sh",
        "scripts/demo-session-template.sh",
        "prompts/01-task-kickoff.md",
    ];
    for path in &expected {
        assert!(root.join(path).exists(), "missing: {path}");
    }

    let agents = fs::read_to_string(root.join(".ai/AGENTS.md")).unwrap();
    assert!(agents.contains("TestProject"));

    let session = fs::read_to_string(root.join(".ai/SESSION")).unwrap();
    assert_eq!(session.trim(), "01");

    let task = fs::read_to_string(root.join(".ai/TASK.md")).unwrap();
    assert!(task.contains("build the thing"));

    let roadmap = fs::read_to_string(root.join(".ai/ROADMAP.md")).unwrap();
    assert!(roadmap.contains("build the thing"));

    let prompt = fs::read_to_string(root.join("prompts/01-task-kickoff.md")).unwrap();
    assert!(prompt.contains("build the thing"));

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn init_is_idempotent() {
    let root = make_project("idem");
    vajractl::cli::init::scaffold(&root, "Proj", "goal one").unwrap();

    let agents_path = root.join(".ai/AGENTS.md");
    fs::write(&agents_path, "custom content").unwrap();

    vajractl::cli::init::scaffold(&root, "Proj2", "goal two").unwrap();

    let content = fs::read_to_string(&agents_path).unwrap();
    assert_eq!(content, "custom content");

    fs::remove_dir_all(root).unwrap();
}

#[cfg(unix)]
#[test]
fn init_scripts_are_executable() {
    use std::os::unix::fs::PermissionsExt;

    let root = make_project("exec");
    vajractl::cli::init::scaffold(&root, "Proj", "goal").unwrap();

    for script in &[
        "scripts/hook-session-start.sh",
        "scripts/verify-session-template.sh",
        "scripts/demo-session-template.sh",
    ] {
        let meta = fs::metadata(root.join(script)).unwrap();
        assert!(
            meta.permissions().mode() & 0o111 != 0,
            "{script} should be executable"
        );
    }

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn init_substitutes_date() {
    let root = make_project("date");
    vajractl::cli::init::scaffold(&root, "Proj", "goal").unwrap();

    let boot = fs::read_to_string(root.join(".ai/SESSION-BOOT.md")).unwrap();
    assert!(!boot.contains("{DATE}"), "DATE placeholder not substituted");

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn init_directories_created() {
    let root = make_project("dirs");
    vajractl::cli::init::scaffold(&root, "Proj", "goal").unwrap();

    assert!(root.join("scripts").is_dir());
    assert!(root.join("prompts").is_dir());
    assert!(root.join("sessions").is_dir());
    assert!(root.join(".claude").is_dir());
    assert!(root.join(".ai").is_dir());

    fs::remove_dir_all(root).unwrap();
}
