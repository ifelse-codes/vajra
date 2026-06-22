use anyhow::{Context, Result};
use serde_json::{json, Value};
use std::env;
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

pub struct TempSettings {
    path: PathBuf,
}

impl TempSettings {
    pub fn write(hooks: Value) -> Result<Self> {
        let path = env::temp_dir().join(format!("vajra-{}.json", unique_suffix()));
        let payload = json!({ "hooks": hooks });
        fs::write(
            &path,
            serde_json::to_string_pretty(&payload).context("failed to encode settings JSON")?,
        )
        .with_context(|| format!("failed to write temp settings: {}", path.display()))?;
        Ok(Self { path })
    }

    pub fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for TempSettings {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.path);
    }
}

pub fn merge_hook_settings() -> Result<Value> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    let home = env::var_os("HOME").map(PathBuf::from);
    merge_hook_settings_for(&cwd, home.as_deref())
}

pub fn merge_hook_settings_for(cwd: &Path, home: Option<&Path>) -> Result<Value> {
    let mut entries = Vec::new();

    if let Some(home) = home {
        append_post_tool_use(&home.join(".claude/settings.json"), &mut entries);
    }

    let project_root = find_project_root(cwd);
    append_post_tool_use(&project_root.join(".claude/settings.json"), &mut entries);
    append_post_tool_use(
        &project_root.join(".claude/settings.local.json"),
        &mut entries,
    );

    if !has_vajra_hook(&entries) {
        entries.push(vajra_hook_entry());
    }

    Ok(json!({ "PostToolUse": entries }))
}

pub fn command_exists(command: &str) -> bool {
    let Some(paths) = env::var_os("PATH") else {
        return false;
    };
    env::split_paths(&paths).any(|dir| dir.join(command).is_file())
}

fn append_post_tool_use(path: &Path, entries: &mut Vec<Value>) {
    let Ok(raw) = fs::read_to_string(path) else {
        return;
    };

    let parsed: Value = match serde_json::from_str(&raw) {
        Ok(value) => value,
        Err(e) => {
            eprintln!(
                "[vajra] warning: malformed JSON in {}; skipping hooks ({e})",
                path.display()
            );
            return;
        }
    };

    let Some(post_tool_use) = parsed.pointer("/hooks/PostToolUse") else {
        return;
    };

    let Some(array) = post_tool_use.as_array() else {
        eprintln!(
            "[vajra] warning: hooks.PostToolUse in {} is not an array; skipping hooks",
            path.display()
        );
        return;
    };

    entries.extend(array.iter().cloned());
}

fn find_project_root(cwd: &Path) -> PathBuf {
    for dir in cwd.ancestors() {
        if dir.join(".git").exists() {
            return dir.to_path_buf();
        }
    }
    cwd.to_path_buf()
}

fn has_vajra_hook(entries: &[Value]) -> bool {
    entries.iter().any(value_contains_vajractl_command)
}

fn value_contains_vajractl_command(value: &Value) -> bool {
    match value {
        Value::Object(map) => map.iter().any(|(key, value)| {
            (key == "command"
                && value
                    .as_str()
                    .is_some_and(|command| command.contains("vajractl")))
                || value_contains_vajractl_command(value)
        }),
        Value::Array(values) => values.iter().any(value_contains_vajractl_command),
        _ => false,
    }
}

fn vajra_hook_entry() -> Value {
    json!({
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "vajractl hook" }]
    })
}

fn unique_suffix() -> String {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_nanos())
        .unwrap_or_default();
    format!("{:x}-{:x}", std::process::id(), nanos)
}

pub fn path_with_temp_dir(dir: &Path, command: &str) -> OsString {
    let mut paths = vec![dir.to_path_buf()];
    if let Some(existing) = env::var_os("PATH") {
        paths.extend(env::split_paths(&existing));
    }
    env::join_paths(paths).unwrap_or_else(|_| OsString::from(command))
}
