use anyhow::{Context, Result};
use serde_json::{json, Value};
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::{fmt, fs};

/// The one file `init` merges into rather than skips when it already exists (S44).
const CLAUDE_SETTINGS_PATH: &str = ".claude/settings.json";

pub fn run() -> Result<()> {
    let root = find_project_root()?;

    eprintln!("vajra init — scaffolding .ai/ workflow");
    eprintln!();

    let project_name = prompt("Project name: ")?.unwrap_or_else(|| "my-project".into());
    let goal = prompt("First session goal: ")?.unwrap_or_else(|| "first session".into());
    eprintln!();
    eprintln!("Maturity levels:");
    eprintln!("  L1 (Report) — hooks log violations but never block");
    eprintln!("  L2 (Gated)  — hooks can reject, human approval required [default]");
    eprintln!("  L3 (Auto)   — auto-advance, strict enforcement");
    let maturity = prompt("Maturity level [L1/L2/L3]: ")?
        .and_then(|v| match v.trim() {
            "L1" | "l1" => Some("L1"),
            "L3" | "l3" => Some("L3"),
            _ => None,
        })
        .unwrap_or("L2");

    scaffold(&root, &project_name, &goal, maturity)?;
    first_run_aha(&root);
    Ok(())
}

pub fn scaffold(root: &Path, project_name: &str, goal: &str, maturity: &str) -> Result<()> {
    let slug = slugify(goal);
    let date = today();
    let brownfield = is_brownfield(root);

    let mut created = 0u32;
    let mut skipped = 0u32;
    let mut merged = 0u32;

    for dir in &[
        ".ai",
        ".ai/hooks",
        ".githooks",
        "scripts",
        "prompts",
        "sessions",
        ".claude",
    ] {
        fs::create_dir_all(root.join(dir))
            .with_context(|| format!("failed to create {dir}/ directory"))?;
    }

    for entry in files(project_name, goal, &slug, &date, maturity, brownfield) {
        let full = root.join(&entry.path);
        if full.exists() {
            // Brownfield L3-moat fix (S44): a pre-existing `.claude/settings.json` must be
            // MERGED, not skipped — otherwise the scaffolded `.ai/hooks/` are never fired and
            // the whole L3 enforcement moat is silently absent for exactly the primary
            // (brownfield) use case. Every other file keeps the skip-if-present convention.
            if entry.path == CLAUDE_SETTINGS_PATH {
                match merge_claude_settings_file(&full, &entry.content) {
                    Ok(true) => {
                        eprintln!(
                            "  merge  {} (Vajra hooks wired into existing file)",
                            entry.path
                        );
                        merged += 1;
                    }
                    Ok(false) => {
                        eprintln!("  skip   {} (Vajra hooks already present)", entry.path);
                        skipped += 1;
                    }
                    // Never overwrite the user's file: warn loudly and leave it untouched.
                    Err(e) => {
                        eprintln!("  warn   {} left untouched — {e}", entry.path);
                        eprintln!(
                            "           fix the JSON, then re-run `vajra init` to wire the L3 hooks."
                        );
                        skipped += 1;
                    }
                }
            } else {
                eprintln!("  skip   {}", entry.path);
                skipped += 1;
            }
        } else {
            if let Some(parent) = full.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(&full, &entry.content)
                .with_context(|| format!("failed to write {}", entry.path))?;
            #[cfg(unix)]
            if entry.executable {
                use std::os::unix::fs::PermissionsExt;
                fs::set_permissions(&full, fs::Permissions::from_mode(0o755))?;
            }
            eprintln!("  create {}", entry.path);
            created += 1;
        }
    }

    eprintln!();
    eprintln!("Created {created} files, merged {merged}, skipped {skipped}.");

    // Activate the git-level belt (S43): point git at the scaffolded .githooks/.
    configure_githooks_path(root);

    if brownfield {
        eprintln!();
        eprintln!("Existing codebase detected → session 00 is a guided onboarding:");
        eprintln!("  study the repo, fill .ai/KNOWLEDGE.md + .ai/STATE.md with reality,");
        eprintln!("  then start feature work in session 01.");
        eprintln!("  Brief: prompts/00-task-brownfield-onboarding.md");
    }
    Ok(())
}

/// Activate the scaffolded git-level belt (S43): point git at `.githooks/` so the tracked
/// pre-commit/pre-push run as an independent L2 layer beneath the L3 `.claude/` hooks.
/// Idempotent + graceful — a non-git dir is a documented no-op; an existing `core.hooksPath`
/// is left untouched (init's skip-if-present convention). Never fails init.
fn configure_githooks_path(root: &Path) {
    if !root.join(".git").exists() {
        eprintln!("  note   not a git repo yet — after `git init`, activate the belt with:");
        eprintln!("           git config core.hooksPath .githooks");
        return;
    }
    // Respect an existing hooksPath (skip-if-present, like the file scaffold). Read the
    // repo-LOCAL value only — a machine-global hooksPath isn't this project's decision, and
    // the belt's scope is this one repo (local config overrides global anyway).
    let existing = Command::new("git")
        .arg("-C")
        .arg(root)
        .args(["config", "--local", "--get", "core.hooksPath"])
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty());
    if let Some(path) = existing {
        eprintln!("  skip   core.hooksPath already set to '{path}' (left as-is)");
        return;
    }
    match Command::new("git")
        .arg("-C")
        .arg(root)
        .args(["config", "core.hooksPath", ".githooks"])
        .status()
    {
        Ok(s) if s.success() => {
            eprintln!("  config core.hooksPath = .githooks (git-level L2 belt active)")
        }
        _ => eprintln!(
            "  warn   could not set core.hooksPath; run: git config core.hooksPath .githooks"
        ),
    }
}

/// Read → merge → write-back the L3 hooks into an existing `.claude/settings.json` (S44).
/// Returns `Ok(true)` if the file changed, `Ok(false)` if Vajra's hooks were already wired,
/// or `Err` if the existing file is malformed — the caller then leaves it untouched.
fn merge_claude_settings_file(path: &Path, template: &str) -> Result<bool> {
    let existing =
        fs::read_to_string(path).with_context(|| format!("failed to read {}", path.display()))?;
    let (merged, changed) = merge_claude_settings(&existing, template)?;
    if changed {
        fs::write(path, merged).with_context(|| format!("failed to write {}", path.display()))?;
    }
    Ok(changed)
}

/// Additively merge Vajra's `SessionStart` + `PreToolUse` hook groups (from `template`) into
/// an existing user `.claude/settings.json`, preserving every user key and hook. Idempotent:
/// a Vajra group is appended only if the target event array does not already contain a
/// structurally-equal group *or* reference that group's `.ai/hooks/*.sh` script paths.
/// Returns `(pretty-printed merged JSON, changed?)`. A malformed / non-object existing file
/// is an `Err` — the caller must not overwrite it.
///
/// Why not reuse the launcher's `merge_hook_settings_for` (ADR-0003): that builds a *fresh*
/// `PostToolUse`-only object for the `--settings` temp file at launch; this merges
/// `SessionStart`+`PreToolUse` into the user's on-disk file preserving all keys. Different shape.
fn merge_claude_settings(existing_json: &str, template_json: &str) -> Result<(String, bool)> {
    let mut existing: Value = serde_json::from_str(existing_json)
        .context("existing .claude/settings.json is not valid JSON")?;
    let template: Value =
        serde_json::from_str(template_json).context("internal: TPL_CLAUDE_SETTINGS is not JSON")?;

    let root = existing
        .as_object_mut()
        .context("existing .claude/settings.json is not a JSON object")?;
    let tpl_hooks = template
        .get("hooks")
        .and_then(Value::as_object)
        .context("internal: template missing hooks object")?;

    // Ensure a `hooks` object exists without disturbing any other top-level key.
    let hooks = root
        .entry("hooks")
        .or_insert_with(|| json!({}))
        .as_object_mut()
        .context("existing .claude/settings.json `hooks` is not an object")?;

    let mut changed = false;
    for (event, tpl_groups) in tpl_hooks {
        let Some(tpl_groups) = tpl_groups.as_array() else {
            continue;
        };
        let arr = hooks
            .entry(event.clone())
            .or_insert_with(|| json!([]))
            .as_array_mut()
            .with_context(|| format!("existing `hooks.{event}` is not an array"))?;
        // Snapshot before appending so groups added this run don't affect each other's
        // idempotence check (the co-pilot hook is shared across the Bash + Edit groups).
        let snapshot = arr.clone();
        for group in tpl_groups {
            if group_already_present(&snapshot, group) {
                continue;
            }
            arr.push(group.clone());
            changed = true;
        }
    }

    let mut out = serde_json::to_string_pretty(&existing)
        .context("failed to encode merged .claude/settings.json")?;
    out.push('\n');
    Ok((out, changed))
}

/// A Vajra hook-group is already wired if the event array holds a structurally-equal group,
/// or already references every `.ai/hooks/*.sh` script path that group carries (so a
/// user-reformatted copy still de-dupes rather than duplicating).
fn group_already_present(snapshot: &[Value], group: &Value) -> bool {
    if snapshot.iter().any(|e| e == group) {
        return true;
    }
    let paths = hook_script_paths(group);
    !paths.is_empty()
        && paths
            .iter()
            .all(|p| snapshot.iter().any(|e| entry_references(e, p)))
}

/// The distinct `.ai/hooks/*.sh` script paths a hook group's `command` strings reference —
/// the stable idempotence key (survives quoting/formatting differences).
fn hook_script_paths(group: &Value) -> Vec<String> {
    let mut cmds = Vec::new();
    collect_command_strings(group, &mut cmds);
    let mut paths = Vec::new();
    for cmd in cmds {
        if let Some(p) = extract_ai_hook_path(&cmd) {
            if !paths.contains(&p) {
                paths.push(p);
            }
        }
    }
    paths
}

fn entry_references(entry: &Value, path: &str) -> bool {
    let mut cmds = Vec::new();
    collect_command_strings(entry, &mut cmds);
    cmds.iter().any(|c| c.contains(path))
}

/// Recursively collect every `"command": "<str>"` value under a JSON node.
fn collect_command_strings(value: &Value, out: &mut Vec<String>) {
    match value {
        Value::Object(map) => {
            for (key, v) in map {
                if key == "command" {
                    if let Some(s) = v.as_str() {
                        out.push(s.to_string());
                    }
                } else {
                    collect_command_strings(v, out);
                }
            }
        }
        Value::Array(items) => items.iter().for_each(|v| collect_command_strings(v, out)),
        _ => {}
    }
}

/// Extract the `.ai/hooks/<name>.sh` substring from a hook command, if present.
fn extract_ai_hook_path(cmd: &str) -> Option<String> {
    let start = cmd.find(".ai/hooks/")?;
    let rest = &cmd[start..];
    let end = rest.find(".sh")? + ".sh".len();
    Some(rest[..end].to_string())
}

/// Brownfield = the repo already has content Vajra didn't put there. Detected by any
/// root entry that isn't `.git` or one of the paths this scaffold itself creates —
/// so re-running `init` on an already-scaffolded project stays greenfield, while a
/// repo with real source (src/, package.json, …) gets the session-0 onboarding path.
fn is_brownfield(root: &Path) -> bool {
    const SCAFFOLD_OWNED: &[&str] = &[
        ".git",
        ".ai",
        ".githooks",
        "scripts",
        "prompts",
        "sessions",
        ".claude",
        "darshan",
        "reviewer",
        "CLAUDE.md",
        "AGENTS.md",
        ".cursorrules",
        ".gitignore",
    ];
    fs::read_dir(root)
        .map(|entries| {
            entries.filter_map(|e| e.ok()).any(|e| {
                let name = e.file_name();
                !SCAFFOLD_OWNED
                    .iter()
                    .any(|owned| name.as_os_str() == *owned)
            })
        })
        .unwrap_or(false)
}

/// First-run "aha" (S23): after scaffolding, let the user *see* the co-pilot work in
/// seconds — fire the just-scaffolded hook once against a sample `git commit` so the
/// guard is felt, not just filed. Best-effort: a missing bash/jq never fails init.
fn first_run_aha(root: &Path) {
    eprintln!();
    eprintln!("▶ See it work — a 5-second simulation against your new project:");
    eprintln!();
    match copilot_fire_preview(root) {
        Some(block) => {
            for line in block.lines() {
                eprintln!("    {line}");
            }
            eprintln!();
            eprintln!("↑ That's Vajra guiding your agent: the moment it runs `git commit`, the");
            eprintln!(
                "  right context is surfaced first — automatically, for every guarded action."
            );
        }
        None => eprint!("{}", render_aha_fallback()),
    }
    eprintln!();
    eprintln!("Next: git add .ai/ && start a guided session →  vajra claude");
}

/// Fire the scaffolded co-pilot hook once and capture what the agent would see.
/// Returns None if the hook or its deps (bash/jq) aren't available — caller falls back.
fn copilot_fire_preview(root: &Path) -> Option<String> {
    use std::io::Write as _;
    use std::process::Stdio;

    let hook = root.join(".ai/hooks/hook-copilot-loader.sh");
    if !hook.exists() {
        return None;
    }
    // Isolated debounce dir so the preview can't interfere with a real session.
    let state_dir = std::env::temp_dir().join(format!("vajra-aha-{}", std::process::id()));
    let payload = r#"{"tool_name":"Bash","tool_input":{"command":"git commit -m wip"},"session_id":"vajra-init-aha"}"#;

    let mut child = Command::new("bash")
        .arg(&hook)
        .env("CLAUDE_PROJECT_DIR", root)
        .env("VAJRA_COPILOT_STATE_DIR", &state_dir)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .ok()?;

    // Drop stdin right after writing so the hook's `cat` sees EOF and proceeds.
    child.stdin.take()?.write_all(payload.as_bytes()).ok()?;
    let out = child.wait_with_output().ok()?;
    let _ = fs::remove_dir_all(&state_dir);

    let mut combined = String::from_utf8_lossy(&out.stdout).into_owned();
    combined.push_str(&String::from_utf8_lossy(&out.stderr));
    let trimmed = combined.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

/// Shown when the live fire can't run (no bash/jq): a static, still-useful preview.
fn render_aha_fallback() -> String {
    let lines = [
        "    [co-pilot] Your agent is now guided. Example rule (.ai/CONSTRAINTS.yaml):",
        "",
        "        ⚡on(cmd:git commit) ⚡include \".ai/STATE.md\"",
        "",
        "    Before a commit, Vajra surfaces STATE.md to check first — for every",
        "    guarded action. (Install `jq` to see this fire live on `vajra init`.)",
    ];
    let mut s = lines.join("\n");
    s.push('\n');
    s
}

struct FileEntry {
    path: String,
    content: String,
    executable: bool,
}

impl fmt::Debug for FileEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("FileEntry")
            .field("path", &self.path)
            .field("executable", &self.executable)
            .finish()
    }
}

fn prompt(label: &str) -> Result<Option<String>> {
    eprint!("{label}");
    io::stderr().flush()?;
    let mut line = String::new();
    let bytes = io::stdin()
        .lock()
        .read_line(&mut line)
        .context("failed to read input")?;
    if bytes == 0 {
        return Ok(None);
    }
    let trimmed = line.trim().to_string();
    if trimmed.is_empty() {
        Ok(None)
    } else {
        Ok(Some(trimmed))
    }
}

pub fn slugify(s: &str) -> String {
    let slug: String = s
        .to_ascii_lowercase()
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '-' })
        .collect();
    let slug = slug.trim_matches('-').to_string();
    let mut result: String = slug.chars().take(30).collect();
    while result.ends_with('-') {
        result.pop();
    }
    // collapse consecutive hyphens
    let mut collapsed = String::with_capacity(result.len());
    let mut prev_hyphen = false;
    for c in result.chars() {
        if c == '-' {
            if !prev_hyphen {
                collapsed.push(c);
            }
            prev_hyphen = true;
        } else {
            collapsed.push(c);
            prev_hyphen = false;
        }
    }
    collapsed
}

fn today() -> String {
    Command::new("date")
        .arg("+%Y-%m-%d")
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|| "YYYY-MM-DD".into())
}

fn find_project_root() -> Result<PathBuf> {
    let cwd = std::env::current_dir().context("failed to read current directory")?;
    Ok(cwd
        .ancestors()
        .find(|dir| dir.join(".git").exists())
        .map(Path::to_path_buf)
        .unwrap_or(cwd))
}

fn files(
    name: &str,
    goal: &str,
    slug: &str,
    date: &str,
    maturity: &str,
    brownfield: bool,
) -> Vec<FileEntry> {
    // Brownfield repos boot into session 00 (study the codebase); greenfield goes
    // straight to the session-01 kickoff. The kickoff prompt is emitted either way.
    let (first_nn, first_prompt, first_title, first_note) = if brownfield {
        (
            "00",
            "prompts/00-task-brownfield-onboarding.md",
            "Brownfield onboarding (study the codebase)",
            "Existing codebase — session 00 studies it before any feature work.",
        )
    } else {
        (
            "01",
            "prompts/01-task-kickoff.md",
            goal,
            "First session. No prior work.",
        )
    };
    let fill = move |content: &str| {
        content
            .replace("{PROJECT_NAME}", name)
            .replace("{GOAL}", goal)
            .replace("{SLUG}", slug)
            .replace("{DATE}", date)
            .replace("{MATURITY}", maturity)
            .replace("{FIRST_NN}", first_nn)
            .replace("{FIRST_PROMPT}", first_prompt)
            .replace("{FIRST_TITLE}", first_title)
            .replace("{FIRST_NOTE}", first_note)
    };
    let f = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: fill(content),
        executable: false,
    };
    let fx = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: fill(content),
        executable: true,
    };

    let mut entries = vec![
        f(".ai/AGENTS.md", TPL_AGENTS),
        f(".ai/SESSION", TPL_SESSION),
        f(".ai/SESSION-BOOT.md", TPL_SESSION_BOOT),
        f(".ai/TASK.md", TPL_TASK),
        f(".ai/STATE.md", TPL_STATE),
        f(".ai/CONSTRAINTS.yaml", TPL_CONSTRAINTS),
        f(".ai/KNOWLEDGE.md", TPL_KNOWLEDGE),
        f(".ai/ROADMAP.md", TPL_ROADMAP),
        f("CLAUDE.md", TPL_CLAUDE_MD),
        f("AGENTS.md", TPL_AGENTS_ROOT),
        f(".cursorrules", TPL_CURSORRULES),
        f(".gitignore", TPL_GITIGNORE),
        f("darshan/SKILL.md", TPL_DARSHAN),
        // Reviewer skill (S57) — the fidelity/acceptance auditor's brain, boot-loaded like
        // Darshan. Byte-identical to the canonical reviewer/SKILL.md (include_str!, no drift).
        f("reviewer/SKILL.md", TPL_REVIEWER),
        f(".claude/settings.json", TPL_CLAUDE_SETTINGS),
        // Hooks live under .ai/hooks/ (S34): they are Vajra's, not the project's —
        // keeps them out of a brownfield project's own scripts/ package. Per-session
        // verify/demo scripts stay in scripts/ (that contract is unchanged).
        fx(".ai/hooks/hook-session-start.sh", TPL_HOOK_SESSION_START),
        fx(".ai/hooks/hook-copilot-loader.sh", TPL_HOOK_COPILOT_LOADER),
        fx(".ai/hooks/hook-copilot-murmur.sh", TPL_HOOK_COPILOT_MURMUR),
        fx(".ai/hooks/hook-session-guard.sh", TPL_HOOK_SESSION_GUARD),
        fx(".ai/hooks/hook-publish-guard.sh", TPL_HOOK_PUBLISH_GUARD),
        fx(".ai/hooks/hook-commit-guard.sh", TPL_HOOK_COMMIT_GUARD),
        // Git-level belt (S43): tracked pre-commit/pre-push, an independent L2 layer
        // (git-native) beneath the L3 .claude/ hooks. Byte-identical to the vajra repo's
        // own .githooks/* (one source via include_str!); activated by core.hooksPath, set
        // in configure_githooks_path(). Closes the raw `echo > .ai/SESSION` / direct-commit
        // bypass at the right layer.
        fx(".githooks/pre-commit", TPL_GITHOOK_PRE_COMMIT),
        fx(".githooks/pre-push", TPL_GITHOOK_PRE_PUSH),
        fx("scripts/verify-session-template.sh", TPL_VERIFY_TEMPLATE),
        fx("scripts/demo-session-template.sh", TPL_DEMO_TEMPLATE),
        // The closeout gate with teeth (S57): byte-identical to the vajra repo's own
        // scripts/verify-closeout.sh (include_str!, one source). Carries the fidelity gate, so a
        // scaffolded project's closeout also structurally requires an independent ACCEPT review.
        fx("scripts/verify-closeout.sh", TPL_VERIFY_CLOSEOUT),
        // S99: the kickoff carries the station markers, rendered from the one canonical
        // template — a fresh repo is measurable by `vajra next --stations` from session 01.
        f("prompts/01-task-kickoff.md", &kickoff_prompt(goal, slug)),
    ];
    if brownfield {
        entries.push(f(
            "prompts/00-task-brownfield-onboarding.md",
            TPL_PROMPT_ONBOARD,
        ));
    }
    // S109 (DECISION-007): scaffold the fleet's named roles as native Claude Code subagents,
    // rendered from the ONE canonical source (`fleet::ROLES`) — the same move as scaffolding
    // `.claude/settings.json` + hooks (S44). Skip-if-present like every other scaffolded file.
    for role in crate::fleet::ROLES {
        entries.push(f(
            &role.subagent_rel(),
            &crate::fleet::render_subagent_definition(role),
        ));
    }
    entries
}

// ── Templates ───────────────────────────────────────────────────────────────

const TPL_AGENTS: &str = r#"# {PROJECT_NAME} — AI Agent Constitution

> Every AI agent MUST read this file and the load order below before executing any task.

## What This Repo Is

{PROJECT_NAME}. Managed by the Vajra workflow.

## Speaking Skills (Load at Boot)

**Darshan** (`darshan/SKILL.md`) is your default human-output skill — read and internalize
it at boot, then speak it all session. One rule: *render the richest visual this surface can
handle; always glanceable; never drop meaning.* It is a skill, not a renderer — nothing in
the binary parses or draws it. The user sees Darshan in every reply.

## Fidelity Review (Load at Boot)

**Reviewer** (`reviewer/SKILL.md`) is the independent acceptance auditor — read it at boot.
At closeout it judges whether you built **what the prompt asked** (fidelity), not just whether
you followed the rules (discipline). The builder never grades itself: an independent cold pass,
fed only the prompt + the diff, rules every requirement SHIPPED / PARTIAL / NOT-BUILT and writes
`sessions/session-NN-review.md`. `scripts/verify-closeout.sh` **requires** that review and fails
closeout on a missing / incomplete / REJECT verdict, absent a founder waiver.

## Mandatory Load Order

1. `.ai/AGENTS.md` (this file)
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md` (on demand)
8. `.ai/ROADMAP.md` (on demand)

## Session Loop

1. BOOT — Read load order. Confirm goal.
2. BRANCH — `session-NN-<slug>` from `main`.
3. PLAN — Bullets. Max 2 assumptions. Wait for approval.
4. EXECUTE — Atomic changes. Max 3 files per commit.
5. VERIFY + DEMO — `scripts/verify-session-NN.sh` exits 0. `scripts/demo-session-NN.sh` shows what was built (cumulative).
6. PR — Open PR to `main`.
7. SUMMARY + FIDELITY REVIEW — `sessions/session-NN-summary.md` + an independent `sessions/session-NN-review.md` (a cold pass; see `reviewer/SKILL.md`). 3 next options.
8. CLOSEOUT — Sync `.ai/` files. `scripts/verify-closeout.sh` exits 0 (structurally requires an ACCEPT review).
9. CLOSE — New chat from next prompt file.

## Hard Rules

| Rule | Detail |
|---|---|
| Max 2 assumptions | More = STOP and ask |
| Max 2 retries | 3rd failure = escalate |
| No autonomous commits | Wait for approval |
| No `main` commits | Branch first |
| Max 3 files per commit | Atomic changes |
| Verification = exit 0 | Never leave red |
| Fidelity ≠ discipline | Map every requirement to evidence (SHIPPED/PARTIAL/NOT-BUILT). A green verify script proves discipline, never fidelity. |
| No self-certification | The builder never accepts its own delivery — an independent review (`reviewer/SKILL.md`) does. |

## Communication Style

- Under 200 words per response
- Bullets and tables, no paragraphs
- No filler phrases, no trailing summaries
- Code first, explanation after
"#;

const TPL_SESSION: &str = "{FIRST_NN}\n";

const TPL_SESSION_BOOT: &str = r#"# Session Boot

## Current Session
- **Number:** {FIRST_NN}
- **Type:** CODE
- **Branch:** pending
- **Date last updated:** {DATE}

## Repo State Snapshot
- `.ai/SESSION` = {FIRST_NN}.
- {FIRST_NOTE}

## Next Session
- **Read prompt:** `{FIRST_PROMPT}`
"#;

const TPL_TASK: &str = r#"# Current Task Pointer

## Session {FIRST_NN} — {FIRST_TITLE}

- **Branch:** pending
- **Goal:** {FIRST_TITLE}

Read prompt: `{FIRST_PROMPT}`
"#;

const TPL_STATE: &str = r#"# {PROJECT_NAME} — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — initialization complete, S01 not yet started.

## What Currently Works
- Vajra workflow initialized.

## What Is Broken
- Nothing yet.

## What Is In Progress
- Session 01 pending.

## Cost Tracking
- Cumulative: $0.00
"#;

const TPL_CONSTRAINTS: &str = r#"version: 3

maturity: {MATURITY}

session:
  max_assumptions: 2
  max_retries: 2
  max_files_per_atomic_change: 3
  max_stories_per_session: 1
  cap_hours_per_session: 2
  ground_truth_every_n_sessions: 5
  one_session_per_chat: true   # new session = new chat; enforced by .ai/hooks/hook-session-guard.sh

branch:
  forbid_direct_work_on: [main, master]
  required_session_branch_pattern: '^session-\d{2,}-[a-z0-9-]+$'
  ground_truth_commit_exempt_branch_suffixes: [-closeout, -enforcement]

commit:
  autonomous: false
  require_user_approval: true
  approval_tokens: [approved, lgtm, "ship it", "yes commit", "go ahead and commit", "go ahead"]

verify:
  required_for_done: true
  script_pattern: 'scripts/verify-session-{NN}.sh'
  template: 'scripts/verify-session-template.sh'
  exit_zero_required: true
  closeout_script: 'scripts/verify-closeout.sh'
  closeout_must_pass_before_close: true   # fails on a missing/incomplete/REJECT fidelity review (reviewer/SKILL.md)
  # The bound (S73): the QA gate re-runs this script LIVE at close; a run past timeout_secs is
  # killed and BLOCKS (cannot-evaluate → FAIL). Missing key → a generous built-in default (600s).
  timeout_secs: 600
  # S119: clean-room re-run. When enabled, QA and Demo-er run scripts in a fresh checkout of HEAD
  # (git worktree add --detach) — no uncommitted files, no gitignored build output. Default off.
  # bootstrap: command run inside the clean room before the script (e.g. "pnpm install --frozen-lockfile")
  clean_room:
    enabled: false
    # bootstrap: "pnpm install --frozen-lockfile"

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  template: 'scripts/demo-session-template.sh'
  cumulative: true
  # The sprint-demo contract (S71): the demo must SHOW each element (a `demo:<element>` marker
  # in its live output) — the Demo-er gate re-runs the script at close and blocks otherwise.
  required_elements: [header, cases, summary_table, before_after]
  # Same bound (S73) on the Demo-er live re-run — killed past timeout_secs → cannot-evaluate BLOCK.
  timeout_secs: 600

release:
  # The ship contract (S72): the Releaser gate re-derives these facts from git LIVE at close —
  # prior session's branch merged into main (ancestry) · local main synced with the last-fetched
  # origin/main · merged session-* locals pruned. Never a recorded claim; the gate surfaces +
  # enforces and never pushes, merges, or deletes.
  require_merged_prior: true
  require_main_synced: true
  require_pruned: true

state:
  state_md_mode: snapshot
  knowledge_md_mode: append-permanent-only

communication:
  max_words_per_response: 200
  required_formats: [bullets, tables, code-blocks]
  forbid: [greetings, apologies, filler, trailing-summaries]

ground_truth:
  # Every 5th session is NO-CODE. It must catch BOTH direction drift (vision+roadmap)
  # and discipline drift (rules+constitution+state). Rules exist to serve the vision —
  # auditing rule-following without auditing the vision is the trap.
  forbid_code_changes: true
  forbid_commits: true
  forbid_prs: true
  required_outputs: [sessions/session-{NN}-ground-truth.md]
  drift_axes: [vision, roadmap, rules, constitution, state, cost]
  required_audits: [vision_alignment, roadmap_alignment, state_drift, knowledge_staleness, constraint_violation_review, constitution_review, cost_review]
  vision_questions:
    - Is the north-star still the right destination?
    - Is current work the shortest path to it, or intellectually-fun scope creep?
    - What new evidence would make us pivot or abandon this direction?
  roadmap_questions:
    - Does each phase still map to the north-star?
    - Is the next item the highest-leverage one, or just the easiest?
    - Any item now obsolete, or any the vision now demands but the roadmap lacks?
  constitution_questions:
    - Is any rule now blocking the vision instead of protecting it?
    - Did this audit's own mechanism have a blind spot? (meta-check)

load_order:
  - .ai/AGENTS.md
  - .ai/SESSION
  - .ai/SESSION-BOOT.md
  - .ai/TASK.md
  - .ai/STATE.md
  - .ai/CONSTRAINTS.yaml
  - .ai/KNOWLEDGE.md
  - .ai/ROADMAP.md

copilot:
  # The co-pilot loader (fired by .ai/hooks/hook-copilot-loader.sh): surface the right
  # context the moment matching work is touched, not all up front.
  # Rule form:  "PATTERN => file, file | why this context, for this work"
  #   PATTERN = a path glob (matched against the touched file, repo-relative)
  #          or cmd:<substring> (matched against a Bash command).
  # Maturity-gated: L1 advises (non-blocking); L2/L3 enforce (exit 2 — block until surfaced).
  # Per-session debounce: each rule fires once per session. Edit these for your project.
  on:
    - "cmd:git commit => .ai/STATE.md | STATE.md is a snapshot of reality — confirm it matches before you commit"
    - "prompts/* => .ai/TASK.md, .ai/ROADMAP.md | the prompt is the session contract — re-read the task + roadmap before editing it"
"#;

const TPL_KNOWLEDGE: &str = r#"# {PROJECT_NAME} — Knowledge Base

**Permanent facts only. Reloaded every session.**
"#;

const TPL_ROADMAP: &str = r#"# {PROJECT_NAME} — Working Roadmap

**Updated at every closeout.**

## Session 01 — {GOAL}
- [ ] {GOAL}
"#;

const TPL_CLAUDE_MD: &str = r#"# CLAUDE.md — Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`.
"#;

const TPL_AGENTS_ROOT: &str = r#"# AGENTS.md — Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`.
"#;

const TPL_CURSORRULES: &str = r#"# Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`. Mandatory load order:

1. `.ai/AGENTS.md`
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md`
8. `.ai/ROADMAP.md`

## Communication style

- Under 200 words per response.
- Bullets and tables. No paragraphs.
- Max 5 bullets per section.
- No filler phrases.
- No trailing summaries.
- Code first.
"#;

const TPL_CLAUDE_SETTINGS: &str = r#"{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-start.sh\""
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-copilot-murmur.sh\""
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-copilot-loader.sh\""
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-guard.sh\""
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-publish-guard.sh\""
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-commit-guard.sh\""
          }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-copilot-loader.sh\""
          }
        ]
      }
    ]
  }
}
"#;

// Canonical SessionStart boot hook, embedded verbatim (S32) so the scaffolded copy can
// never drift from the real one — the same one-source pattern as the co-pilot loader and
// session guard. This is what surfaces the Darshan speaking skill in every project's boot
// packet (S32 Darshan enforcement: advised -> enforced). Un-excluded in Cargo.toml so it
// ships with `cargo install`.
const TPL_HOOK_SESSION_START: &str = include_str!("../../scripts/hook-session-start.sh");

// Canonical co-pilot loader, embedded verbatim from the real script — one source of
// truth, no hand-copy, so it can never drift (the S19 rule Varta enforces). The file is
// un-excluded in Cargo.toml's `exclude` so it ships with `cargo install`.
const TPL_HOOK_COPILOT_LOADER: &str = include_str!("../../scripts/hook-copilot-loader.sh");

// Canonical co-pilot MURMUR (S47) — the proactive, non-blocking half of the co-pilot (direction B).
// A UserPromptSubmit hook: each user turn it murmurs the copilot.on context relevant to the
// working-tree changes (advisory, exit 0 — never blocks; the loader owns enforcement). Embedded
// verbatim so the scaffolded copy can never drift (S22 one-source pattern); un-excluded in
// Cargo.toml so it ships with `cargo install`.
const TPL_HOOK_COPILOT_MURMUR: &str = include_str!("../../scripts/hook-copilot-murmur.sh");

// Canonical session-guard (S26/S29) — one-session-per-chat enforcement, embedded
// verbatim so the scaffolded copy can never drift (S22 pattern). Gated on
// CONSTRAINTS.yaml#session.one_session_per_chat: true; records the owning chat in a
// gitignored `.ai/.session-owner`. Un-excluded in Cargo.toml so it ships with `cargo install`.
const TPL_HOOK_SESSION_GUARD: &str = include_str!("../../scripts/hook-session-guard.sh");

// Canonical publish-guard (S37/S38) — blocks outward/irreversible actions (git push,
// gh pr create/merge, glab mr create/merge) at L2/L3 unless the founder launched with
// VAJRA_ALLOW_PUBLISH=1. Embedded verbatim so the scaffolded copy can never drift (S22
// pattern). This is the S36 leak fix propagated to where it actually leaked: scaffolded
// projects run the real autonomous sessions. Un-excluded in Cargo.toml so it ships with
// `cargo install`.
const TPL_HOOK_PUBLISH_GUARD: &str = include_str!("../../scripts/hook-publish-guard.sh");

// Canonical commit-guard (S93) — the un-forgeable teeth on `git commit`: a PreToolUse(Bash)
// hook that BLOCKS an autonomous commit unless VAJRA_ALLOW_COMMIT (== the session number) is in
// the hook's own launch env — beyond an inline prefix's reach, and firing even on `--no-verify`.
// Embedded verbatim so the scaffolded copy can never drift (S22 one-source pattern). The scaffold
// ships NO `commit_guard: off` line, so new projects get it ON (the vajra repo turns it off to
// avoid bricking the build agent's own commits — see .ai/CONSTRAINTS.yaml). Un-excluded in
// Cargo.toml so it ships with `cargo install`.
const TPL_HOOK_COMMIT_GUARD: &str = include_str!("../../scripts/hook-commit-guard.sh");

// Canonical git-level hooks (S43) — the SAME files the vajra repo runs, embedded verbatim
// so the scaffolded copy can never drift (S22 one-source pattern). An independent L2 belt
// (git-native) beneath the L3 .claude/ hooks: pre-commit blocks main-commits / >3 staged /
// .ai/ drift; pre-push blocks push to main|master. Activated by `git config core.hooksPath
// .githooks` (configure_githooks_path). `.githooks/*` is excluded in Cargo.toml, so both
// files are un-excluded there (per-file negation) so they ship with `cargo install`.
const TPL_GITHOOK_PRE_COMMIT: &str = include_str!("../../.githooks/pre-commit");
const TPL_GITHOOK_PRE_PUSH: &str = include_str!("../../.githooks/pre-push");

// The scaffold's `.gitignore` — the session-guard writes the owning chat's id into
// `.ai/.session-owner`, a local-only record that must never be committed.
const TPL_GITIGNORE: &str = r#"# Vajra session-guard owner record (one-session-per-chat) — local only, never commit.
.ai/.session-owner
"#;

// Darshan (S27/S28) — the human's glanceable output skill, embedded verbatim from the
// canonical file so the scaffolded copy can never drift. `darshan/` is not in Cargo.toml's
// `exclude`, so it already ships with `cargo install`. Skill-not-renderer holds: `init`
// only *copies* the skill + wires the AGENTS.md boot pointer; nothing in Rust renders it.
const TPL_DARSHAN: &str = include_str!("../../darshan/SKILL.md");

// Reviewer (S55 brain / S56 teeth → S57 propagation) — the independent fidelity / acceptance
// auditor, embedded verbatim from the canonical file so the scaffolded copy can never drift
// (S22/S28 one-source pattern). `reviewer/` is not in Cargo.toml's `exclude`, so it already ships
// with `cargo install` (like `darshan/`). Boot-loaded like Darshan; nothing in the binary parses it.
const TPL_REVIEWER: &str = include_str!("../../reviewer/SKILL.md");

// Canonical closeout gate (S56 teeth → S57 propagation) — the SAME `scripts/verify-closeout.sh`
// the vajra repo runs, embedded verbatim so the scaffolded copy can never drift (S22 one-source
// pattern). It carries `check_fidelity_review` + `waiver_ok` + `--fidelity-only`, so a scaffolded
// project's closeout also STRUCTURALLY requires an independent ACCEPT review (DECISION-002), not
// just discipline. Fully portable — it reads only the `.ai/` + `sessions/` + `prompts/` spine every
// scaffold has, nothing vajra-repo-specific. `scripts/*` is excluded in Cargo.toml, so this file is
// un-excluded there (per-file negation) so it ships with `cargo install`. Closes the S36-class
// "the constitution tells the agent to run verify-closeout.sh but the scaffold never shipped it" gap.
const TPL_VERIFY_CLOSEOUT: &str = include_str!("../../scripts/verify-closeout.sh");

const TPL_VERIFY_TEMPLATE: &str = r#"#!/usr/bin/env bash
# Template — copy to scripts/verify-session-NN.sh and customize per session.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# === EDIT PER SESSION ===
# run_check "cargo-check"  cargo check --all-targets
# run_check "cargo-test"   cargo test --all-targets
# run_check "cargo-fmt"    cargo fmt -- --check
# run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings
# ========================

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
"#;

// The demo template is the CANONICAL scripts/demo-session-template.sh, embedded byte-identical
// (include_str!, one source, no drift — the S22/S57 propagation pattern). It carries the
// sprint-demo contract: the four `demo:<element>` markers the Demo-er gate (S71) scans for.
// Until S71 the canonical file did not exist on disk (named in CONSTRAINTS, inline-only here —
// the S70 GT finding); now the file IS the source and this embed cannot drift from it.
const TPL_DEMO_TEMPLATE: &str = include_str!("../../scripts/demo-session-template.sh");

/// The session-01 kickoff prompt, rendered from the ONE canonical station-marker template
/// (`analyst::PROMPT_TEMPLATE`) rather than a second inline copy (S99).
///
/// Until S99 this was a hand-written stub carrying Goal/Deliverables/Exit-Criteria and **none**
/// of the station markers (`## Acceptance`/`## Design`/`## Plan`/`## Execution`/`## Delta`). A
/// repo scaffolded that way was structurally unmeasurable by `vajra next --stations`: four of the
/// eight stations read for sections the prompt could never contain (the S97 Ladder-Rung-1 finding,
/// live-evidenced on chitra). Sourcing the kickoff from `render_scaffold` means the scaffold and
/// the gates can no longer drift apart — there is exactly one template.
///
/// The founder's goal (asked at `vajra init` time) replaces the template's title + goal
/// placeholders; every other placeholder stays, because the human is meant to fill them in
/// before flipping `Status: DRAFT` to APPROVED.
fn kickoff_prompt(goal: &str, slug: &str) -> String {
    let rendered = crate::analyst::render_scaffold(1, slug).replace("<one-line goal>", goal);
    // Replace the `## Goal` placeholder paragraph by its stable prefix, so a reworded template
    // still substitutes. If it ever stops matching, the placeholder simply survives (harmless)
    // and `kickoff_prompt_carries_goal_and_markers` fails loudly rather than shipping drift.
    rendered
        .lines()
        .map(|l| {
            if l.starts_with("<One paragraph") {
                goal
            } else {
                l
            }
        })
        .collect::<Vec<_>>()
        .join("\n")
        + "\n"
}

// Session-0 brief for brownfield repos (S34): the codebase existed before Vajra, so the
// first session studies it and seeds the .ai/ files with reality — no feature work.
const TPL_PROMPT_ONBOARD: &str = r#"# Session 00 — Brownfield Onboarding (study the codebase)

> This project existed before Vajra. Session 00 is a guided study session: learn the
> codebase, then fill the `.ai/` files with reality instead of empty templates. No
> feature work happens here — session 01 (`prompts/01-task-kickoff.md`) starts on facts.

## Goal (one story)
Study the existing repo and seed `.ai/KNOWLEDGE.md` + `.ai/STATE.md` with a real
first-pass understanding.

## Steps
1. **Scan the repo** — layout, languages, entry points, how to build/test/run, CI,
   existing docs. Read the top-level manifests (package.json / Cargo.toml / etc.) first.
2. **Ask the founder** (max 5 framing questions) — what is this project, what state is it
   really in, what is the next milestone, what must never break, any no-go areas?
3. **Fill `.ai/KNOWLEDGE.md`** — permanent facts only: stack, commands, conventions,
   invariants, environment quirks. If you can't verify a fact, don't write it.
4. **Rewrite `.ai/STATE.md`** — What Currently Works / What Is Broken from observed
   reality (run the tests; the results are the evidence).
5. **Seed `.ai/ROADMAP.md`** with the founder's next milestone, then point `.ai/TASK.md`
   at `prompts/01-task-kickoff.md` and set `.ai/SESSION` to 01.

## Guardrails
- **Docs only**: `.ai/` files. No source-code edits, no refactors, no "quick fixes".
- Branch `session-00-onboarding` from `main`. Commits need the founder's approval token.
- Max 2 assumptions; unverifiable claims are questions for the founder, not facts.

## Exit Criteria
- Founder signs off that `KNOWLEDGE.md` + `STATE.md` match reality.
- Session 01 starts in a **new chat** from `prompts/01-task-kickoff.md`.
"#;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn slugify_basic() {
        assert_eq!(slugify("Build the CLI"), "build-the-cli");
    }

    #[test]
    fn slugify_special_chars() {
        assert_eq!(
            slugify("Add `vajra init` command"),
            "add-vajra-init-command"
        );
    }

    #[test]
    fn slugify_truncates() {
        let long = "this is a very long goal that should be truncated at thirty chars";
        let result = slugify(long);
        assert!(result.len() <= 30);
        assert!(!result.ends_with('-'));
    }

    #[test]
    fn slugify_empty() {
        assert_eq!(slugify(""), "");
    }

    // ── Scaffold propagation (S22) ────────────────────────────────────────────

    fn scaffold_tmp() -> tempfile::TempDir {
        let dir = tempfile::tempdir().unwrap();
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        dir
    }

    #[test]
    fn scaffold_emits_ground_truth_audits() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        for needle in [
            "ground_truth:",
            "vision_alignment",
            "roadmap_alignment",
            "constitution_review",
            "drift_axes:",
            "vision_questions:",
        ] {
            assert!(c.contains(needle), "TPL_CONSTRAINTS missing {needle:?}");
        }
    }

    #[test]
    fn scaffold_records_the_release_contract() {
        // S72: the ship contract is recorded, not implied — a fresh scaffold carries the
        // `release:` section the Releaser gate reads (missing keys default true either way).
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        for needle in [
            "release:",
            "require_merged_prior: true",
            "require_main_synced: true",
            "require_pruned: true",
        ] {
            assert!(c.contains(needle), "TPL_CONSTRAINTS missing {needle:?}");
        }
        let contract = crate::releaser::release_contract(&dir.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(contract, crate::releaser::ReleaseContract::default());
    }

    #[test]
    fn scaffold_records_the_gate_timeout_bound() {
        // S73: the live-gate bound is recorded on the spine (verify: + demo:), and the reader
        // resolves it per-section from a fresh scaffold. A pre-S73 repo without the key still
        // resolves to the built-in default — so this propagation adds a bound, never a break.
        let dir = scaffold_tmp();
        let path = dir.path().join(".ai/CONSTRAINTS.yaml");
        assert!(fs::read_to_string(&path)
            .unwrap()
            .contains("timeout_secs: 600"));
        use std::time::Duration;
        assert_eq!(
            crate::gate_run::gate_timeout(&path, "verify"),
            Duration::from_secs(600)
        );
        assert_eq!(
            crate::gate_run::gate_timeout(&path, "demo"),
            Duration::from_secs(600)
        );
    }

    #[test]
    fn scaffold_emits_copilot_rules_and_refreshes() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(c.contains("copilot:"), "missing copilot block");
        assert!(c.contains("=>"), "missing a ⚡on rule");
        // refreshed since pre-S20:
        assert!(c.contains("go ahead and commit"), "stale approval_tokens");
        assert!(
            c.contains("ground_truth_commit_exempt_branch_suffixes"),
            "missing GT exempt suffixes"
        );
    }

    #[test]
    fn scaffold_ships_copilot_hook_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-copilot-loader.sh");
        assert!(hook.exists(), "hook not scaffolded");
        // The whole point of option (b): the scaffolded copy is byte-identical to the
        // canonical script — one source of truth, no drift.
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_COPILOT_LOADER,
            "scaffolded hook drifted from canonical"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "hook must be executable");
        }
    }

    #[test]
    fn scaffold_ships_copilot_murmur_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-copilot-murmur.sh");
        assert!(hook.exists(), "murmur hook not scaffolded");
        // Byte-identical to the canonical script — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_COPILOT_MURMUR,
            "scaffolded murmur hook drifted from canonical"
        );
        // Direction-B invariant: the murmur guides, it never blocks — no `exit 2` anywhere.
        assert!(
            !TPL_HOOK_COPILOT_MURMUR.contains("exit 2"),
            "the murmur must never block (exit 2) — it is advisory at every maturity"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "murmur hook must be executable");
        }
    }

    #[test]
    fn scaffold_wires_murmur_into_user_prompt_submit() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert!(
            s.contains("UserPromptSubmit"),
            "murmur must be wired on UserPromptSubmit (the proactive lane)"
        );
        assert_eq!(
            s.matches("hook-copilot-murmur.sh").count(),
            1,
            "murmur wired exactly once, on UserPromptSubmit"
        );
    }

    #[test]
    fn scaffold_ships_darshan_skill_verbatim() {
        let dir = scaffold_tmp();
        let skill = dir.path().join("darshan/SKILL.md");
        assert!(skill.exists(), "Darshan skill not scaffolded");
        // Byte-identical to the canonical source — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&skill).unwrap(),
            TPL_DARSHAN,
            "scaffolded Darshan skill drifted from canonical darshan/SKILL.md"
        );
    }

    #[test]
    fn scaffold_wires_darshan_into_constitution() {
        let dir = scaffold_tmp();
        let agents = fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap();
        assert!(
            agents.contains("Speaking Skills"),
            "missing Speaking Skills boot section"
        );
        assert!(
            agents.contains("darshan/SKILL.md"),
            "AGENTS.md must point at the scaffolded Darshan skill"
        );
    }

    // ── Fidelity gate + reviewer propagation (S57) ───────────────────────────

    #[test]
    fn scaffold_ships_reviewer_skill_verbatim() {
        let dir = scaffold_tmp();
        let skill = dir.path().join("reviewer/SKILL.md");
        assert!(skill.exists(), "reviewer skill not scaffolded");
        // Byte-identical to the canonical reviewer/SKILL.md — one source, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&skill).unwrap(),
            TPL_REVIEWER,
            "scaffolded reviewer skill drifted from canonical reviewer/SKILL.md"
        );
    }

    #[test]
    fn scaffold_wires_reviewer_into_constitution() {
        let dir = scaffold_tmp();
        let agents = fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap();
        // Boot pointer (like Darshan) so scaffolded agents load the acceptance auditor.
        assert!(
            agents.contains("reviewer/SKILL.md"),
            "AGENTS.md must point at the scaffolded reviewer skill"
        );
        assert!(
            agents.contains("Fidelity Review"),
            "missing Fidelity Review boot section"
        );
        // The closeout step must promise the gate (an independent ACCEPT review), not just discipline.
        assert!(
            agents.contains("FIDELITY REVIEW") && agents.contains("session-NN-review.md"),
            "Session Loop must require an independent per-session review"
        );
    }

    #[test]
    fn scaffold_ships_verify_closeout_verbatim_and_executable() {
        let dir = scaffold_tmp();
        let gate = dir.path().join("scripts/verify-closeout.sh");
        assert!(gate.exists(), "verify-closeout.sh not scaffolded");
        // Byte-identical to the vajra repo's own gate — one source of truth, no drift.
        assert_eq!(
            fs::read_to_string(&gate).unwrap(),
            TPL_VERIFY_CLOSEOUT,
            "scaffolded verify-closeout.sh drifted from canonical scripts/verify-closeout.sh"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&gate).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "verify-closeout.sh must be executable");
        }
    }

    #[test]
    fn scaffolded_closeout_carries_the_fidelity_gate() {
        // The whole point of S57: the scaffolded closeout is not a discipline-only stub — it
        // carries the S56 teeth (the fidelity gate + un-forgeable waiver + focused entry point).
        let dir = scaffold_tmp();
        let gate = fs::read_to_string(dir.path().join("scripts/verify-closeout.sh")).unwrap();
        for needle in [
            "check_fidelity_review",
            "waiver_ok",
            "--fidelity-only",
            "VAJRA_CLOSEOUT_WAIVER",
            "session-${N}-review.md",
        ] {
            assert!(
                gate.contains(needle),
                "scaffolded closeout gate missing the fidelity-gate token {needle:?}"
            );
        }
    }

    #[test]
    fn scaffold_wires_closeout_into_constraints() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(
            c.contains("closeout_script: 'scripts/verify-closeout.sh'"),
            "CONSTRAINTS.yaml must point at the scaffolded closeout gate"
        );
        assert!(
            c.contains("closeout_must_pass_before_close: true"),
            "CONSTRAINTS.yaml must make the closeout gate mandatory"
        );
    }

    // ── Session-guard propagation (S29) ──────────────────────────────────────

    #[test]
    fn scaffold_ships_session_guard_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-session-guard.sh");
        assert!(hook.exists(), "session-guard not scaffolded");
        // Byte-identical to canonical — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_SESSION_GUARD,
            "scaffolded session-guard drifted from canonical hook-session-guard.sh"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "session-guard must be executable");
        }
    }

    #[test]
    fn scaffold_wires_session_guard_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-session-guard.sh").count(),
            1,
            "session-guard must be wired once (PreToolUse Bash)"
        );
        // Both Bash-matcher co-pilot + guard fire on Bash: the guard rides the Bash matcher.
        assert!(s.contains("hook-copilot-loader.sh"), "co-pilot wiring lost");
    }

    #[test]
    fn scaffold_emits_one_session_per_chat_flag() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(
            c.contains("one_session_per_chat: true"),
            "session-guard is gated on one_session_per_chat: true"
        );
    }

    #[test]
    fn scaffold_gitignores_session_owner() {
        let dir = scaffold_tmp();
        let gi = dir.path().join(".gitignore");
        assert!(gi.exists(), ".gitignore not scaffolded");
        assert!(
            fs::read_to_string(&gi)
                .unwrap()
                .contains(".ai/.session-owner"),
            ".gitignore must ignore the session-guard owner record"
        );
    }

    // ── Publish-guard propagation (S38) ──────────────────────────────────────

    #[test]
    fn scaffold_ships_publish_guard_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-publish-guard.sh");
        assert!(hook.exists(), "publish-guard not scaffolded");
        // Byte-identical to canonical — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_PUBLISH_GUARD,
            "scaffolded publish-guard drifted from canonical hook-publish-guard.sh"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "publish-guard must be executable");
        }
    }

    #[test]
    fn scaffold_wires_publish_guard_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-publish-guard.sh").count(),
            1,
            "publish-guard must be wired once (PreToolUse Bash)"
        );
        // Rides the same Bash matcher as the co-pilot + session-guard.
        assert!(
            s.contains("hook-session-guard.sh"),
            "session-guard wiring lost"
        );
    }

    // ── Commit-guard propagation (S93) ───────────────────────────────────────

    #[test]
    fn scaffold_ships_commit_guard_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-commit-guard.sh");
        assert!(hook.exists(), "commit-guard not scaffolded");
        // Byte-identical to canonical — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_COMMIT_GUARD,
            "scaffolded commit-guard drifted from canonical hook-commit-guard.sh"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "commit-guard must be executable");
        }
    }

    #[test]
    fn scaffold_wires_commit_guard_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-commit-guard.sh").count(),
            1,
            "commit-guard must be wired once (PreToolUse Bash)"
        );
    }

    #[test]
    fn scaffold_ships_commit_guard_on_no_off_toggle() {
        // The un-forgeable teeth must ship ON in new projects: the scaffolded CONSTRAINTS must
        // NOT carry `commit_guard: off` (that line is the vajra repo's own build-agent exemption).
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(
            !c.lines()
                .any(|l| l.trim_start().starts_with("commit_guard:") && l.contains("off")),
            "scaffold must not disable the commit-guard (no `commit_guard: off`)"
        );
    }

    // ── Git-level belt propagation (S43) ─────────────────────────────────────

    #[test]
    fn scaffold_ships_githooks_verbatim() {
        let dir = scaffold_tmp();
        for (rel, canonical) in [
            (".githooks/pre-commit", TPL_GITHOOK_PRE_COMMIT),
            (".githooks/pre-push", TPL_GITHOOK_PRE_PUSH),
        ] {
            let hook = dir.path().join(rel);
            assert!(hook.exists(), "{rel} not scaffolded");
            // Byte-identical to the vajra repo's own .githooks/* — one source, no drift.
            assert_eq!(
                fs::read_to_string(&hook).unwrap(),
                canonical,
                "scaffolded {rel} drifted from the canonical .githooks source"
            );
            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                let mode = fs::metadata(&hook).unwrap().permissions().mode();
                assert_eq!(mode & 0o111, 0o111, "{rel} must be executable");
            }
        }
    }

    fn git_init(path: &Path) {
        Command::new("git")
            .arg("-C")
            .arg(path)
            .args(["init", "-q"])
            .status()
            .expect("git init failed");
    }

    fn local_hookspath(path: &Path) -> String {
        let out = Command::new("git")
            .arg("-C")
            .arg(path)
            .args(["config", "--local", "--get", "core.hooksPath"])
            .output()
            .unwrap();
        String::from_utf8_lossy(&out.stdout).trim().to_string()
    }

    #[test]
    fn scaffold_sets_core_hookspath_in_git_repo() {
        let dir = tempfile::tempdir().unwrap();
        git_init(dir.path());
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        assert_eq!(
            local_hookspath(dir.path()),
            ".githooks",
            "core.hooksPath must be set to .githooks (git-level belt active)"
        );
    }

    #[test]
    fn scaffold_respects_existing_hookspath() {
        let dir = tempfile::tempdir().unwrap();
        git_init(dir.path());
        // A project that already configured its own hooks — init must not clobber it.
        Command::new("git")
            .arg("-C")
            .arg(dir.path())
            .args(["config", "core.hooksPath", "my-hooks"])
            .status()
            .unwrap();
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        assert_eq!(
            local_hookspath(dir.path()),
            "my-hooks",
            "an existing core.hooksPath must be left untouched (skip-if-present)"
        );
    }

    #[test]
    fn scaffold_non_git_dir_emits_belt_without_crashing() {
        // scaffold_tmp() is a non-git temp dir: init runs on non-git dirs too, so the belt
        // must still be emitted and the config step must degrade to a documented no-op.
        let dir = scaffold_tmp();
        assert!(
            !dir.path().join(".git").exists(),
            "precondition: scaffold_tmp is not a git repo"
        );
        assert!(dir.path().join(".githooks/pre-commit").exists());
        assert!(dir.path().join(".githooks/pre-push").exists());
    }

    // ── Brownfield onboarding + hook placement (S34) ──────────────────────────

    #[test]
    fn scaffold_hooks_land_in_ai_hooks_not_scripts() {
        let dir = scaffold_tmp();
        for hook in [
            "hook-session-start.sh",
            "hook-copilot-loader.sh",
            "hook-session-guard.sh",
        ] {
            assert!(
                dir.path().join(".ai/hooks").join(hook).exists(),
                "{hook} missing from .ai/hooks/"
            );
            assert!(
                !dir.path().join("scripts").join(hook).exists(),
                "{hook} must not land in the project's scripts/"
            );
        }
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert!(
            s.contains("$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-start.sh"),
            "settings.json must point at .ai/hooks/"
        );
        assert!(
            !s.contains("scripts/hook-"),
            "settings.json still references scripts/ hooks"
        );
    }

    #[test]
    fn scaffold_empty_repo_is_greenfield() {
        let dir = scaffold_tmp();
        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/SESSION")).unwrap(),
            "01\n"
        );
        assert!(!dir
            .path()
            .join("prompts/00-task-brownfield-onboarding.md")
            .exists());
        let task = fs::read_to_string(dir.path().join(".ai/TASK.md")).unwrap();
        assert!(task.contains("prompts/01-task-kickoff.md"));
    }

    #[test]
    fn scaffold_existing_code_gets_session_zero() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join("src")).unwrap();
        fs::write(dir.path().join("src/index.ts"), "export {};\n").unwrap();
        fs::write(dir.path().join("package.json"), "{}\n").unwrap();
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();

        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/SESSION")).unwrap(),
            "00\n"
        );
        let brief = dir.path().join("prompts/00-task-brownfield-onboarding.md");
        assert!(brief.exists(), "onboarding brief not emitted");
        let brief = fs::read_to_string(brief).unwrap();
        for needle in [
            "KNOWLEDGE.md",
            "STATE.md",
            "Docs only",
            "session-00-onboarding",
        ] {
            assert!(
                brief.contains(needle),
                "onboarding brief missing {needle:?}"
            );
        }
        // Session 00 studies; session 01 still holds the user's goal.
        let task = fs::read_to_string(dir.path().join(".ai/TASK.md")).unwrap();
        assert!(task.contains("Session 00 — Brownfield onboarding"));
        assert!(task.contains("prompts/00-task-brownfield-onboarding.md"));
        assert!(dir.path().join("prompts/01-task-kickoff.md").exists());
    }

    /// S99 (AC1): the kickoff is the ONE canonical station-marker template — nothing hand-copied.
    ///
    /// The ratchet must catch a REGRESSION where someone re-forks the kickoff into an inline stub
    /// (the pre-S99 `TPL_PROMPT` shape). It does NOT compare the output to itself: it ties the
    /// kickoff to strings authored in a DIFFERENT module (`analyst::PROMPT_TEMPLATE`) and to this
    /// file's own source text.
    ///   1. Every `## ` heading line the canonical template authors — parentheticals and all —
    ///      must appear VERBATIM in the kickoff. A hand-written stub (`## Goal`/`## Deliverables`/
    ///      `## Exit Criteria`) cannot reproduce `## Execution (the Coder gate — record each plan
    ///      step's landing commit as work lands)`, so it trips here.
    ///   2. This file must carry no second prompt-template constant. A re-added `const TPL_PROMPT:`
    ///      (the exact byte pattern S99 deleted) fails the source check below.
    #[test]
    fn kickoff_is_the_one_canonical_template_no_second_copy() {
        let goal = "ship the first slice";
        let out = kickoff_prompt(goal, "kickoff");

        // (1) Heading lines are authored once, in analyst::PROMPT_TEMPLATE. Pull them live (not a
        // hardcoded list) and require each verbatim in the kickoff — the cross-module tie.
        let canonical = crate::analyst::render_scaffold(1, "kickoff");
        let headings: Vec<&str> = canonical.lines().filter(|l| l.starts_with("## ")).collect();
        assert!(
            headings.len() >= 6,
            "canonical template is not the expected multi-section shape ({} headings)",
            headings.len()
        );
        for line in &headings {
            // Skip the `## Goal` heading's body-substituted case is irrelevant — the heading LINE
            // itself is unchanged by substitution, so it must survive verbatim.
            assert!(
                out.contains(line),
                "kickoff diverged from the canonical template — missing verbatim {line:?}. A \
                 hand-written second copy is the likely cause."
            );
        }

        // (2) Source ratchet: this file must not re-introduce the inline template constant S99
        // removed. `include_str!` reads THIS file's bytes at compile time. Anchor on a line whose
        // trimmed start is the DEFINITION `const TPL_PROMPT:` — the onboarding template
        // (`const TPL_PROMPT_ONBOARD:`) does not match, and this test's own string-literal mention
        // (indented, preceded by `(`) does not start a line with `const`, so it does not match.
        const SELF_SRC: &str = include_str!("init.rs");
        assert!(
            !SELF_SRC
                .lines()
                .any(|l| l.trim_start().starts_with("const TPL_PROMPT:")),
            "a second inline prompt template (const TPL_PROMPT) was reintroduced — the kickoff \
             must derive from analyst::PROMPT_TEMPLATE, not a local copy"
        );

        // Substitution + identity sanity — the founder's goal lands, session is 01, no raw tokens.
        assert!(
            !out.contains("<one-line goal>"),
            "title goal not substituted"
        );
        assert!(
            !out.contains("<One paragraph"),
            "`## Goal` placeholder not substituted"
        );
        assert_eq!(out.matches(goal).count(), 2, "goal not placed twice");
        assert!(out.contains("# Session 01 —"), "kickoff is not session 01");
        assert!(!out.contains("{{NN}}"), "unsubstituted template token");
    }

    /// S99 (AC1): the scaffolded file on disk — not just the renderer — carries the markers.
    #[test]
    fn scaffolded_kickoff_file_is_station_measurable() {
        let dir = scaffold_tmp();
        let p = fs::read_to_string(dir.path().join("prompts/01-task-kickoff.md")).unwrap();
        for heading in [
            "## Acceptance",
            "## Design",
            "## Plan",
            "## Execution",
            "## Delta",
        ] {
            assert!(
                p.contains(heading),
                "scaffolded kickoff missing {heading:?}"
            );
        }
        assert!(
            p.contains("Status:** DRAFT"),
            "kickoff must ship DRAFT — the human approves before the session starts"
        );
    }

    #[test]
    fn brownfield_detection_ignores_scaffold_owned_paths() {
        let dir = scaffold_tmp();
        // A fully-scaffolded (or re-run) project is not brownfield…
        assert!(!is_brownfield(dir.path()));
        // …but one real source file flips it.
        fs::write(dir.path().join("main.py"), "print()\n").unwrap();
        assert!(is_brownfield(dir.path()));
    }

    #[test]
    fn aha_fallback_is_informative() {
        let s = render_aha_fallback();
        assert!(s.contains("⚡on(cmd:git commit)"), "fallback lost the rule");
        assert!(s.contains(".ai/STATE.md"), "fallback lost the include");
        assert!(s.contains("guided"), "fallback lost the framing");
    }

    #[test]
    fn scaffold_wires_copilot_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-copilot-loader.sh").count(),
            2,
            "co-pilot must be wired for both Bash and Edit|Write|MultiEdit"
        );
        assert!(s.contains("PreToolUse"), "missing PreToolUse wiring");
    }

    // ── Brownfield .claude/settings.json merge (S44) ─────────────────────────

    // A realistic pre-existing user file: an unrelated top-level key, a user SessionStart
    // hook, and a user PreToolUse Bash group — all of which the merge must preserve.
    const USER_SETTINGS: &str = r#"{
  "model": "claude-opus-4",
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "echo user-boot" } ] }
    ],
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "echo user-bash" } ] }
    ]
  }
}"#;

    #[test]
    fn merge_wires_all_vajra_hooks_and_preserves_user() {
        let (out, changed) = merge_claude_settings(USER_SETTINGS, TPL_CLAUDE_SETTINGS).unwrap();
        assert!(changed, "merging into a Vajra-less file must change it");
        // All four Vajra hook scripts wired, each exactly as often as canonical.
        assert_eq!(out.matches("hook-session-start.sh").count(), 1);
        assert_eq!(out.matches("hook-session-guard.sh").count(), 1);
        assert_eq!(out.matches("hook-publish-guard.sh").count(), 1);
        assert_eq!(out.matches("hook-copilot-loader.sh").count(), 2);
        // The user's hooks + unrelated key survive untouched.
        assert!(
            out.contains("echo user-boot"),
            "user SessionStart hook dropped"
        );
        assert!(
            out.contains("echo user-bash"),
            "user PreToolUse hook dropped"
        );
        assert!(
            out.contains("claude-opus-4"),
            "unrelated top-level key dropped"
        );
        // Output is valid JSON.
        serde_json::from_str::<Value>(&out).expect("merged output is not valid JSON");
    }

    #[test]
    fn merge_is_idempotent() {
        let (once, c1) = merge_claude_settings(USER_SETTINGS, TPL_CLAUDE_SETTINGS).unwrap();
        assert!(c1);
        let (twice, c2) = merge_claude_settings(&once, TPL_CLAUDE_SETTINGS).unwrap();
        assert!(!c2, "second merge must be a no-op");
        assert_eq!(once, twice, "second merge must not mutate the file");
        // No duplication — the shared co-pilot hook stays at 2, guards at 1.
        assert_eq!(twice.matches("hook-session-guard.sh").count(), 1);
        assert_eq!(twice.matches("hook-copilot-loader.sh").count(), 2);
    }

    #[test]
    fn merge_into_file_without_hooks_key() {
        let (out, changed) =
            merge_claude_settings(r#"{"model":"x"}"#, TPL_CLAUDE_SETTINGS).unwrap();
        assert!(changed);
        assert!(out.contains("hook-session-guard.sh"), "hooks not created");
        assert!(out.contains("\"model\""), "unrelated key dropped");
    }

    #[test]
    fn merge_rejects_malformed_json() {
        assert!(
            merge_claude_settings("{ not json", TPL_CLAUDE_SETTINGS).is_err(),
            "malformed existing JSON must error (caller leaves the file untouched)"
        );
    }

    #[test]
    fn merge_rejects_non_object_root() {
        assert!(
            merge_claude_settings("[]", TPL_CLAUDE_SETTINGS).is_err(),
            "a non-object root must error rather than be clobbered"
        );
    }

    #[test]
    fn scaffold_merges_existing_claude_settings() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join(".claude")).unwrap();
        fs::write(dir.path().join(".claude/settings.json"), USER_SETTINGS).unwrap();

        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        // User content preserved…
        assert!(s.contains("echo user-boot"));
        assert!(s.contains("echo user-bash"));
        assert!(s.contains("claude-opus-4"));
        // …and every Vajra hook wired into the pre-existing file.
        for needle in [
            "hook-session-start.sh",
            "hook-copilot-loader.sh",
            "hook-session-guard.sh",
            "hook-publish-guard.sh",
        ] {
            assert!(s.contains(needle), "merge lost {needle}");
        }
        // Re-running init stays greenfield: no duplicate Vajra entries.
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        let s2 = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s2.matches("hook-session-guard.sh").count(),
            1,
            "re-run duplicated Vajra hooks"
        );
    }
}
