use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use vajractl::launcher::{merge_hook_settings_for, TempSettings};

fn fixture(name: &str) -> &'static str {
    match name {
        "clean" => include_str!("fixtures/settings_clean.json"),
        "bash" => include_str!("fixtures/settings_with_bash_hook.json"),
        "vajractl" => include_str!("fixtures/settings_with_vajractl.json"),
        "bad_post_tool_use" => include_str!("fixtures/settings_bad_post_tool_use.json"),
        _ => panic!("unknown fixture: {name}"),
    }
}

fn unique_dir(name: &str) -> PathBuf {
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    std::env::temp_dir().join(format!("vajra-test-{name}-{}-{nanos}", std::process::id()))
}

fn write_settings(root: &Path, relative: &str, fixture_name: &str) {
    let path = root.join(relative);
    fs::create_dir_all(path.parent().unwrap()).unwrap();
    fs::write(path, fixture(fixture_name)).unwrap();
}

fn make_project(name: &str) -> PathBuf {
    let root = unique_dir(name);
    fs::create_dir_all(root.join(".git")).unwrap();
    root
}

fn post_tool_use(hooks: &Value) -> &[Value] {
    hooks["PostToolUse"]
        .as_array()
        .expect("PostToolUse must be an array")
}

fn count_vajractl(entries: &[Value]) -> usize {
    entries
        .iter()
        .filter(|entry| entry.to_string().contains("vajractl"))
        .count()
}

#[test]
fn merge_skips_injection_if_vajractl_present() {
    let root = make_project("dedup");
    write_settings(&root, ".claude/settings.json", "vajractl");

    let hooks = merge_hook_settings_for(&root, None).unwrap();
    let entries = post_tool_use(&hooks);

    assert_eq!(entries.len(), 1);
    assert_eq!(count_vajractl(entries), 1);

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn merge_injects_entry_when_absent() {
    let root = make_project("inject");
    write_settings(&root, ".claude/settings.json", "clean");

    let hooks = merge_hook_settings_for(&root, None).unwrap();
    let entries = post_tool_use(&hooks);

    assert_eq!(entries.len(), 1);
    assert_eq!(entries[0]["matcher"], "Bash");
    assert_eq!(entries[0]["hooks"][0]["command"], "vajractl hook");

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn merge_warns_and_skips_malformed_post_tool_use() {
    let root = make_project("bad-post-tool-use");
    write_settings(&root, ".claude/settings.json", "bad_post_tool_use");

    let hooks = merge_hook_settings_for(&root, None).unwrap();
    let entries = post_tool_use(&hooks);

    assert_eq!(entries.len(), 1);
    assert_eq!(entries[0]["hooks"][0]["command"], "vajractl hook");

    fs::remove_dir_all(root).unwrap();
}

#[test]
fn temp_settings_drop_removes_file() {
    let path = {
        let temp = TempSettings::write(serde_json::json!({ "PostToolUse": [] })).unwrap();
        let path = temp.path().to_path_buf();
        assert!(path.exists(), "temp settings file should exist after write");
        path
    };

    assert!(
        !path.exists(),
        "temp settings file should be removed on drop"
    );
}

#[test]
fn merge_reads_global_and_project() {
    let home = unique_dir("home");
    let root = make_project("global-project");
    fs::create_dir_all(home.join(".claude")).unwrap();
    write_settings(&home, ".claude/settings.json", "bash");
    write_settings(&root, ".claude/settings.json", "bash");

    let hooks = merge_hook_settings_for(&root, Some(&home)).unwrap();
    let entries = post_tool_use(&hooks);

    assert_eq!(entries.len(), 3);
    assert_eq!(count_vajractl(entries), 1);

    fs::remove_dir_all(home).unwrap();
    fs::remove_dir_all(root).unwrap();
}
