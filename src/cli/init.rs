use anyhow::{bail, Context, Result};
use serde_json::{json, Value};
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::{fmt, fs};

/// The one file `init` merges into rather than skips when it already exists (S44).
const CLAUDE_SETTINGS_PATH: &str = ".claude/settings.json";

/// The pure-render shell hooks S142 gives the render stamp + four-state smooth upgrade. Each is an
/// `include_str!` template (defined below) with NO fill placeholders — asserted by the test
/// `hook_templates_carry_no_fill_placeholders`, which is what makes the stamped render byte-identical
/// across every install, the same clean fit as a fleet role. ONE list: `files()` scaffolds these
/// stamped and `sync_targets()` syncs the same set, so a fresh `init` immediately reports them
/// `UpToDate`. INVARIANT: every template in this list MUST be fill-transparent (no `{{UPPER}}`
/// placeholders) — `fxs` calls `fill()` before stamping while `sync_targets` uses the raw
/// template; any placeholder breaks byte-identity and causes UpToDate-on-init to silently fail.
const SYNC_HOOKS: &[(&str, &str)] = &[
    (".ai/hooks/hook-session-start.sh", TPL_HOOK_SESSION_START),
    (".ai/hooks/hook-copilot-loader.sh", TPL_HOOK_COPILOT_LOADER),
    (".ai/hooks/hook-copilot-murmur.sh", TPL_HOOK_COPILOT_MURMUR),
    (".ai/hooks/hook-session-guard.sh", TPL_HOOK_SESSION_GUARD),
    (".ai/hooks/hook-publish-guard.sh", TPL_HOOK_PUBLISH_GUARD),
    (".ai/hooks/hook-commit-guard.sh", TPL_HOOK_COMMIT_GUARD),
    // S146 (DECISION-007 S146 addendum): the close-gate is a ShellComment-stamped pure-render shell
    // script — the same shape as the hooks above. Adding it to SYNC_HOOKS gives adopters the
    // four-state upgrade path (Missing/UpToDate/StaleRender/Drifted) so `--sync-fleet` can push a
    // corrected gate (e.g. with check_required_crew) without a manual patch (S144 finding 1).
    // Uses the scaffold template (PATH-first resolver) not the vajra source file — see S144 finding 2.
    ("scripts/verify-closeout.sh", TPL_VERIFY_CLOSEOUT_SCAFFOLD),
];

/// The canonical STAMPED render of one hook — a shell-comment `vajra-render-sha:` trailing line over
/// the template. Hooks carry no fill placeholders, so this is the same byte string whether produced
/// at scaffold time or sync time (no drift). The ONE place a hook's canonical bytes are defined.
fn render_stamped_hook(template: &str) -> String {
    crate::fleet::stamp_render(template, crate::fleet::StampSyntax::ShellComment)
}

/// The report label for a hook — its basename (e.g. `hook-session-guard.sh`).
fn hook_label(rel: &str) -> String {
    rel.rsplit('/').next().unwrap_or(rel).to_string()
}

pub fn run(args: &[String]) -> Result<()> {
    // S136 (DECISION-007 S136 addendum): the UPGRADE path a brownfield adopter needs. `init`
    // scaffolds ~40 entries and prompts for a project name, a first-session goal and a maturity
    // level — all wrong for a project that adopted Vajra ten sessions ago and only wants the
    // fleet roster its installed version predates. `--sync-fleet` re-enters THE SAME
    // `fleet::ROLES` loop `files()` already uses, scoped to the role definitions and nothing
    // else. A flag on an existing command, never an 8th top-level command.
    if args.iter().any(|a| a == "--sync-fleet") {
        return sync_fleet(
            &find_project_root()?,
            SyncOpts {
                dry_run: args.iter().any(|a| a == "--dry-run"),
                overwrite_drifted: args.iter().any(|a| a == "--overwrite-drifted"),
            },
            &mut io::stderr(),
        );
    }
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

/// What `--sync-fleet` may do to a file that is already on disk.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SyncOpts {
    /// Report the plan, write nothing. The exit code still reflects what a real run would leave
    /// behind, so a preview is a true preview and not a separate, kinder verdict.
    pub dry_run: bool,
    /// Rewrite a file whose bytes differ from the canonical render. Off by default, on purpose:
    /// see `FleetFileState::Drifted`.
    pub overwrite_drifted: bool,
}

/// The FOUR states a role's `.claude/agents/<name>.md` can be in, relative to the ONE canonical
/// render (`fleet::render_subagent_definition`).
///
/// **S136 said there were only three** — a fourth, "stale render" as distinct from "the user edited
/// it", was NOT DERIVABLE, because nothing on disk recorded which Vajra version produced a file.
/// **S141 makes it derivable by RECORDING the provenance** (DECISION-007 S141 addendum): every render
/// now carries a `vajra-render-sha:` stamp = sha256 of its own body-minus-stamp, so an untouched
/// older render re-hashes to its own embedded stamp and a hand-edit does not. This is not the git
/// blame / timestamp classifier S136 rejected as *inventing* provenance — it is a dedicated signal
/// written at render time and read back as a pure function of the bytes. The stamp is a content hash,
/// not a keyed signature: tamper-EVIDENT, not tamper-PROOF (a user could forge it by hand) — enough
/// to auto-upgrade the untouched-render case safely, which is the whole job.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FleetFileState {
    /// Not on disk. This is the case an older install leaves behind when the roster grows —
    /// safe to create, because creating a file that does not exist destroys nothing.
    Missing,
    /// Byte-for-byte identical to the canonical render. Never rewritten: a no-op write would
    /// churn the user's mtime and their git status for nothing.
    UpToDate,
    /// Present, bytes differ from the current render, BUT its body-minus-stamp re-hashes to its own
    /// embedded `vajra-render-sha:` stamp — provably an untouched Vajra render of an OLDER version.
    /// Safe to auto-upgrade to the current render with no human override (S141).
    StaleRender,
    /// Present, and NOT a verifiable older render: no stamp (every pre-S141 install), or a stamp that
    /// does not verify (a hand-edit, or a foreign file). Could be the user's deliberate
    /// customisation, so it is never silently clobbered — refused unless `--overwrite-drifted`.
    Drifted,
    /// S143: a BOUNDARY target (the constitution) present on disk with NO governed-body sentinel —
    /// every pre-S143 install, whose `.ai/AGENTS.md` predates the header/body split. There is no sound
    /// way to know where the user's filled header ends, so a rewrite would destroy the project's
    /// `{PROJECT_NAME}` fill. Refused even under `--overwrite-drifted` (distinct from `Drifted` on
    /// purpose — the fix is to paste the sentinel once, not to force-overwrite). Only a `boundary`
    /// target can reach this state; roles and hooks (whole-file, `boundary: None`) never do.
    NeedsBoundary,
}

/// Classify one scaffold file from what is actually on disk against the canonical render.
///
/// Takes the read content rather than the path so the decision is a pure function the tests can
/// drive without a filesystem — the classification is the part that has to be right. The
/// `StaleRender` arm calls `fleet::render_stamp_verifies`, which shells out for sha256 but is
/// deterministic and touches no filesystem, so this stays a pure function of its inputs (S141).
///
/// S142: `syntax` says which comment style carries the stamp (frontmatter for role files, a shell
/// comment for hooks), so the same four-state machine covers every pure-render scaffold file, not
/// only the fleet roles.
///
/// S143: `boundary` makes the four states BODY-SCOPED for a filled file (the constitution). A
/// `boundary: None` target (roles, hooks) compares the WHOLE file, byte-for-byte the S141/S142
/// behaviour. A `boundary: Some(sentinel)` target compares only the governed BODY region — the file
/// from the sentinel onward — so the user-owned header above the sentinel is neither compared nor
/// touched. A boundary target with no sentinel on disk is `NeedsBoundary` (the one-time legacy
/// migration), never `Missing`/`Drifted`, because there is no safe way to rewrite it without the
/// sentinel to split on.
pub fn classify_fleet_file(
    on_disk: Option<&str>,
    canonical: &str,
    syntax: crate::fleet::StampSyntax,
    boundary: Option<&str>,
) -> FleetFileState {
    let full = match on_disk {
        None => return FleetFileState::Missing,
        Some(f) => f,
    };
    // The region the four-state machine reasons about: the whole file (no boundary), or the governed
    // body alone (from the sentinel onward). A boundary target with no sentinel cannot be split.
    let region = match body_region(full, boundary) {
        Some(r) => r,
        None => return FleetFileState::NeedsBoundary,
    };
    if region == canonical {
        FleetFileState::UpToDate
    } else if crate::fleet::render_stamp_verifies(region, syntax) {
        FleetFileState::StaleRender
    } else {
        FleetFileState::Drifted
    }
}

/// The exact literal that divides the constitution's user-owned filled header (above) from the
/// governed body Vajra owns and upgrades (below). Inert to a markdown reader (an HTML comment), no
/// fill token (so it is byte-identical across installs), and self-evidently "do not edit below". No
/// `--` double-hyphen inside the comment (illegal in strict HTML comments) — single spaced hyphens.
/// The governed-body region begins at this line; the `<!-- vajra-render-sha: -->` stamp closes it.
pub const GOVERNED_BODY_SENTINEL: &str =
    "<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->";

/// The region a boundary target's four-state machine reasons about, as a pure function of the bytes.
///
/// `None` boundary (roles, hooks) → the WHOLE file (today's behaviour, unchanged). `Some(sentinel)`
/// (the constitution) → the slice from the FIRST occurrence of the sentinel to the end — the governed
/// body; everything before it is the user-owned header, out of scope. Returns `None` when a sentinel
/// is expected but absent, which `classify_fleet_file` reads as `NeedsBoundary`: there is no sound
/// place to split, so no rewrite is safe. Borrows from `on_disk`, so it allocates nothing.
pub fn body_region<'a>(on_disk: &'a str, boundary: Option<&str>) -> Option<&'a str> {
    match boundary {
        None => Some(on_disk),
        Some(sentinel) => on_disk.find(sentinel).map(|i| &on_disk[i..]),
    }
}

/// One scaffold file's line in the sync plan. S142 widened this from role-only to any pure-render
/// scaffold file, so it carries its own comment `syntax`, whether it is `executable`, and the exact
/// `canonical` bytes it was classified against — the SINGLE source the apply step writes, so a plan
/// can never carry a copy that drifts from what it compared.
#[derive(Debug, Clone)]
pub struct FleetSyncItem {
    /// Human label for the report (a role name, or a hook basename).
    pub label: String,
    pub rel: String,
    pub syntax: crate::fleet::StampSyntax,
    pub executable: bool,
    pub canonical: String,
    /// S143: the governed-body sentinel for a BOUNDARY target (the constitution), or `None` for a
    /// whole-file target (roles, hooks). When `Some`, `canonical` is the body-only render and the
    /// upgrade preserves the header above the sentinel verbatim.
    pub boundary: Option<&'static str>,
    pub state: FleetFileState,
}

/// One pure-render scaffold target, resolved BEFORE the disk is read: its repo-relative path, its
/// stamp comment syntax, whether it must be executable, and the exact canonical bytes to compare
/// against and (on apply) write. The SINGLE source both the plan and the scaffold derive from.
struct SyncTarget {
    label: String,
    rel: String,
    syntax: crate::fleet::StampSyntax,
    executable: bool,
    canonical: String,
    /// S143: the governed-body sentinel for a BOUNDARY target (the constitution), else `None`.
    boundary: Option<&'static str>,
}

/// Every pure-render scaffold file `--sync-fleet` governs: the fleet roles (frontmatter stamp), the
/// shell hooks (S142, shell-comment stamp), and — S143 — the constitution's governed BODY (markdown
/// stamp, a boundary target). ONE list, so `plan_fleet_sync` and the scaffold agree on exactly this
/// set — a fresh `init` immediately reports them all `UpToDate`. `CONSTRAINTS.yaml` (user-tuned, no
/// canonical) is deliberately absent — see the DECISION-007 S143 addendum.
fn sync_targets() -> Vec<SyncTarget> {
    let mut targets: Vec<SyncTarget> = crate::fleet::ROLES
        .iter()
        .map(|role| SyncTarget {
            label: role.name.to_string(),
            rel: role.subagent_rel(),
            syntax: crate::fleet::StampSyntax::Frontmatter,
            executable: false,
            canonical: crate::fleet::render_subagent_definition(role),
            boundary: None,
        })
        .collect();
    for (rel, tpl) in SYNC_HOOKS {
        targets.push(SyncTarget {
            label: hook_label(rel),
            rel: rel.to_string(),
            syntax: crate::fleet::StampSyntax::ShellComment,
            executable: true,
            canonical: render_stamped_hook(tpl),
            boundary: None,
        });
    }
    // S143: the constitution's governed body is a BOUNDARY target — `canonical` is the body-only
    // render (sentinel + governed content + markdown stamp), and the sync preserves the user-owned
    // filled header above the sentinel verbatim. This is the last pure-ish render Vajra owns.
    targets.push(SyncTarget {
        label: "constitution (.ai/AGENTS.md body)".to_string(),
        rel: ".ai/AGENTS.md".to_string(),
        syntax: crate::fleet::StampSyntax::MarkdownComment,
        executable: false,
        canonical: governed_body_canonical(),
        boundary: Some(GOVERNED_BODY_SENTINEL),
    });
    targets
}

/// Build the plan WITHOUT writing anything. `--sync-fleet` and `--sync-fleet --dry-run` compute
/// the identical plan; only the apply step differs, which is what makes the dry run trustworthy.
pub fn plan_fleet_sync(root: &Path) -> Vec<FleetSyncItem> {
    sync_targets()
        .into_iter()
        .map(|t| {
            // An unreadable file is NOT treated as absent — that would let a permissions error
            // silently become a create. It reads as `Drifted`: present, and not provably canonical.
            let on_disk = match fs::read_to_string(root.join(&t.rel)) {
                Ok(body) => Some(body),
                Err(e) if e.kind() == io::ErrorKind::NotFound => None,
                Err(_) => Some(String::new()),
            };
            let state = classify_fleet_file(on_disk.as_deref(), &t.canonical, t.syntax, t.boundary);
            FleetSyncItem {
                label: t.label,
                rel: t.rel,
                syntax: t.syntax,
                executable: t.executable,
                canonical: t.canonical,
                boundary: t.boundary,
                state,
            }
        })
        .collect()
}

/// `vajra init --sync-fleet [--dry-run] [--overwrite-drifted]` — bring an ALREADY-GOVERNED project
/// up to the current fleet roster.
///
/// Idempotent by construction: a second run finds every file `UpToDate` and writes nothing. The
/// exit code is the whole point of the command being usable in a check —
/// **0** when every role file is present and canonical, **1** when any file is left `Drifted`,
/// naming the flag that would resolve it. A dry run returns the code the real run would.
pub fn sync_fleet(root: &Path, opts: SyncOpts, out: &mut impl io::Write) -> Result<()> {
    let plan = plan_fleet_sync(root);
    let mut created = 0u32;
    let mut upgraded = 0u32;
    let mut refreshed = 0u32;
    let mut up_to_date = 0u32;
    // Drifted files (bytes differ, not a verifiable old render) — resolved by `--overwrite-drifted`.
    let mut unresolved: Vec<String> = Vec::new();
    // S143: boundary targets with no governed-body sentinel — the one-time constitution migration.
    // A DIFFERENT resolution (paste the sentinel), so tracked and reported separately from `Drifted`.
    let mut needs_boundary: Vec<String> = Vec::new();

    let n_roles = crate::fleet::ROLES.len();
    let n_boundary = plan.iter().filter(|i| i.boundary.is_some()).count();
    let n_hooks = plan
        .len()
        .saturating_sub(n_roles)
        .saturating_sub(n_boundary);
    writeln!(
        out,
        "=== vajra: fleet sync ({n_roles} roles + {n_hooks} hooks + {n_boundary} constitution) ==="
    )?;
    if opts.dry_run {
        writeln!(out, "  DRY RUN — nothing is written.")?;
    }

    for item in &plan {
        match item.state {
            FleetFileState::UpToDate => {
                up_to_date += 1;
                writeln!(out, "  ok      {} (up to date)", item.rel)?;
            }
            FleetFileState::Missing => {
                // S143: a boundary target (the constitution) that is ABSENT is not sync's to create —
                // its filled header (project name, goal, maturity) lives only in `vajra init`, and a
                // headerless body-only write would be a broken constitution. Sync UPGRADES existing
                // renders; creating the constitution is `init`'s job. Warn and skip, leaving the
                // exit code to the real upgrade work (a role that is Missing IS created — roster
                // growth is sync's job). A deleted constitution is a broken repo, surfaced not masked.
                if item.boundary.is_some() {
                    writeln!(
                        out,
                        "  note    {} is absent — run `vajra init` to create it (sync upgrades, it does not scaffold the constitution)",
                        item.rel
                    )?;
                    continue;
                }
                if opts.dry_run {
                    writeln!(out, "  would   create {}", item.rel)?;
                } else {
                    write_target(root, item)?;
                    writeln!(out, "  create  {}", item.rel)?;
                }
                created += 1;
            }
            // S141: a provably-untouched OLDER render. Auto-upgraded to the current render with NO
            // `--overwrite-drifted` — this is the whole point of the stamp — but reported by name
            // and old→new stamp, so a smooth upgrade is never an invisible one.
            FleetFileState::StaleRender => {
                let (old8, new8) = stale_upgrade_hashes(root, item);
                if opts.dry_run {
                    writeln!(
                        out,
                        "  would   upgrade {} (stale render {old8} → {new8})",
                        item.rel
                    )?;
                } else {
                    write_target(root, item)?;
                    writeln!(out, "  upgrade {} (stale render {old8} → {new8})", item.rel)?;
                }
                upgraded += 1;
            }
            FleetFileState::Drifted if opts.overwrite_drifted => {
                if opts.dry_run {
                    writeln!(out, "  would   refresh {} (drifted)", item.rel)?;
                } else {
                    write_target(root, item)?;
                    writeln!(out, "  refresh {} (drifted → canonical)", item.rel)?;
                }
                refreshed += 1;
            }
            FleetFileState::Drifted => {
                writeln!(
                    out,
                    "  DRIFT   {} differs from the canonical render — NOT touched",
                    item.rel
                )?;
                unresolved.push(item.rel.clone());
            }
            // S143: a boundary target with no governed-body sentinel — every pre-S143 constitution.
            // `--overwrite-drifted` does NOT satisfy it: there is no sound place to split the user's
            // filled header from the governed body, so a rewrite could destroy the project's fill.
            // The one-time fix is to paste the sentinel; reported separately with that guidance.
            FleetFileState::NeedsBoundary => {
                writeln!(
                    out,
                    "  BODY    {} has no governed-body boundary — NOT touched (needs one-time migration)",
                    item.rel
                )?;
                needs_boundary.push(item.rel.clone());
            }
        }
    }

    writeln!(out)?;
    // A dry run must not report work it did not do. Same numbers, honest verb.
    let (verb_c, verb_u, verb_r) = if opts.dry_run {
        ("to create", "to upgrade", "to refresh")
    } else {
        ("created", "upgraded", "refreshed")
    };
    writeln!(
        out,
        "{created} {verb_c}, {upgraded} {verb_u}, {refreshed} {verb_r}, \
         {up_to_date} already current, {} drifted, {} needs-boundary.",
        unresolved.len(),
        needs_boundary.len()
    )?;

    // S143: the constitution migration is a DIFFERENT fix from a drifted render — paste the sentinel,
    // don't `--overwrite-drifted` (which would refuse anyway, and must, to protect the filled header).
    // Printed first so a legacy user sees the exact line to copy.
    if !needs_boundary.is_empty() {
        writeln!(out)?;
        writeln!(
            out,
            "The constitution has no governed-body boundary yet, so Vajra cannot tell where YOUR\n\
             filled header ends. It will NOT rewrite it — that would destroy your project's name and\n\
             fill. One-time migration: paste this EXACT line into `.ai/AGENTS.md`, immediately ABOVE\n\
             the `## Mandatory Load Order` heading, then re-run `vajra init --sync-fleet`:\n\
             \n\
             \x20   {GOVERNED_BODY_SENTINEL}\n"
        )?;
    }

    if !unresolved.is_empty() {
        writeln!(out)?;
        writeln!(
            out,
            "Vajra cannot tell an OLD RENDER from YOUR OWN EDIT — both are just bytes that differ,\n\
             and nothing on disk records which Vajra wrote the file. So it refused to write.\n\
             Read the diff; if these are stale renders and not your edits, re-run with:\n\
             \n\
             \x20   vajra init --sync-fleet --overwrite-drifted\n"
        )?;
    }

    if !unresolved.is_empty() || !needs_boundary.is_empty() {
        let mut left = unresolved.clone();
        left.extend(needs_boundary.iter().cloned());
        bail!(
            "{} scaffold file(s) left untouched ({} drifted, {} needs-boundary): {}",
            left.len(),
            unresolved.len(),
            needs_boundary.len(),
            left.join(", ")
        );
    }
    Ok(())
}

/// Short old→new stamps for a `StaleRender` upgrade report line — old = the file's own embedded
/// stamp, new = the canonical render's. Both read in the item's own comment syntax (S142). Best-effort
/// display only (`?` when a stamp cannot be read); the decision to upgrade was already made by
/// `classify_fleet_file`, not by this.
fn stale_upgrade_hashes(root: &Path, item: &FleetSyncItem) -> (String, String) {
    let short = |h: &str| h.chars().take(8).collect::<String>();
    let old = fs::read_to_string(root.join(&item.rel))
        .ok()
        .and_then(|c| crate::fleet::extract_render_stamp(&c, item.syntax))
        .map(|h| short(&h))
        .unwrap_or_else(|| "?".to_string());
    let new = crate::fleet::extract_render_stamp(&item.canonical, item.syntax)
        .map(|h| short(&h))
        .unwrap_or_else(|| "?".to_string());
    (old, new)
}

/// Write one scaffold file from the canonical bytes computed in the plan (`item.canonical` — the
/// single source `sync_targets` derived, so nothing re-renders a second, drifting copy), setting the
/// executable bit for hooks. Covers roles (frontmatter) and hooks (shell) uniformly (S142).
///
/// S143: for a BOUNDARY target (the constitution), `item.canonical` is the governed BODY only. The
/// write re-reads the on-disk file, keeps the user-owned header ABOVE the sentinel byte-for-byte, and
/// appends the canonical body — so an upgrade never touches the project's `{PROJECT_NAME}` fill. If
/// the on-disk file somehow lacks the sentinel, it BAILS rather than write a headerless body (that
/// write is the session's fakest green — it would destroy the fill); `classify_fleet_file` already
/// routes such a file to `NeedsBoundary` so this is defense in depth, not the normal path.
fn write_target(root: &Path, item: &FleetSyncItem) -> Result<()> {
    let full = root.join(&item.rel);
    if let Some(parent) = full.parent() {
        fs::create_dir_all(parent).with_context(|| format!("mkdir {}", parent.display()))?;
    }
    let bytes = match item.boundary {
        None => item.canonical.clone(),
        Some(sentinel) => {
            let on_disk = fs::read_to_string(&full)
                .with_context(|| format!("re-read {} before body-scoped upgrade", item.rel))?;
            let idx = on_disk.find(sentinel).ok_or_else(|| {
                anyhow::anyhow!(
                    "refusing to write {}: no governed-body boundary on disk — a headerless \
                     rewrite would destroy the user's filled header",
                    item.rel
                )
            })?;
            format!("{}{}", &on_disk[..idx], item.canonical)
        }
    };
    fs::write(&full, &bytes).with_context(|| format!("failed to write {}", item.rel))?;
    #[cfg(unix)]
    if item.executable {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(&full, fs::Permissions::from_mode(0o755))
            .with_context(|| format!("failed to chmod {}", item.rel))?;
    }
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
    // S142: the `.ai/hooks/` shell hooks are scaffolded STAMPED (a trailing `# vajra-render-sha:`
    // comment) so a fresh `init` + immediate `--sync-fleet` reports them `UpToDate` — the same
    // clean fit as a fleet role. Fill runs first (a no-op for hooks, which carry no placeholders);
    // `render_stamped_hook` is the one source `sync_targets` also uses, so the two never drift.
    let fxs = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: render_stamped_hook(&fill(content)),
        executable: true,
    };
    // S143: the constitution is scaffolded as a user-owned filled HEADER + a byte-identical governed
    // BODY (sentinel + governed content + markdown stamp). Fill runs on the header only; the body is
    // `governed_body_canonical()`, the ONE source `sync_targets` also uses — so a fresh `init` +
    // immediate `--sync-fleet` reports the constitution `UpToDate`, and later upgrades touch only the
    // body while the filled header is preserved verbatim.
    let f_constitution = || FileEntry {
        path: ".ai/AGENTS.md".to_string(),
        content: format!("{}{}", fill(TPL_AGENTS_HEADER), governed_body_canonical()),
        executable: false,
    };

    let mut entries = vec![
        f_constitution(),
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
        fxs(".ai/hooks/hook-session-start.sh", TPL_HOOK_SESSION_START),
        fxs(".ai/hooks/hook-copilot-loader.sh", TPL_HOOK_COPILOT_LOADER),
        fxs(".ai/hooks/hook-copilot-murmur.sh", TPL_HOOK_COPILOT_MURMUR),
        fxs(".ai/hooks/hook-session-guard.sh", TPL_HOOK_SESSION_GUARD),
        fxs(".ai/hooks/hook-publish-guard.sh", TPL_HOOK_PUBLISH_GUARD),
        fxs(".ai/hooks/hook-commit-guard.sh", TPL_HOOK_COMMIT_GUARD),
        // Git-level belt (S43): tracked pre-commit/pre-push, an independent L2 layer
        // (git-native) beneath the L3 .claude/ hooks. Byte-identical to the vajra repo's
        // own .githooks/* (one source via include_str!); activated by core.hooksPath, set
        // in configure_githooks_path(). Closes the raw `echo > .ai/SESSION` / direct-commit
        // bypass at the right layer.
        fx(".githooks/pre-commit", TPL_GITHOOK_PRE_COMMIT),
        fx(".githooks/pre-push", TPL_GITHOOK_PRE_PUSH),
        fx("scripts/verify-session-template.sh", TPL_VERIFY_TEMPLATE),
        fx("scripts/demo-session-template.sh", TPL_DEMO_TEMPLATE),
        // S146: the scaffolded close-gate uses the scaffold template (PATH-first binary resolver,
        // S144 finding 2) and is stamped via `fxs` so a fresh `init` + immediate `--sync-fleet`
        // reports it `UpToDate` — the ONE-list invariant of DECISION-007.
        fxs("scripts/verify-closeout.sh", TPL_VERIFY_CLOSEOUT_SCAFFOLD),
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

// S143: the constitution `.ai/AGENTS.md` is scaffolded as a user-owned filled HEADER + a
// byte-identical governed BODY, divided by `GOVERNED_BODY_SENTINEL`. `--sync-fleet` upgrades only
// the body (a boundary target); the header — the project's own identity — is never rewritten. This
// is the last pure-ish render Vajra owns joining "one command upgrades everything" (DECISION-007
// S143 addendum). The two constants are joined by `governed_body_canonical()` at scaffold time and
// again in `sync_targets()`, from this ONE source, so the scaffold and the sync never drift.

/// The constitution's user-owned FILLED header: the `{PROJECT_NAME}` preamble a project owns and
/// Vajra never rewrites. `fill` touches ONLY this part of `.ai/AGENTS.md`. Ends with a blank line;
/// `governed_body_canonical` appends the sentinel + governed body directly after it.
const TPL_AGENTS_HEADER: &str = r#"# {PROJECT_NAME} — AI Agent Constitution

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

"#;

/// The constitution's GOVERNED body: the bytes Vajra owns, stamps, and upgrades. Carries NO fill
/// placeholders (asserted by `constitution_body_carries_no_fill_placeholders`) — byte-identical
/// across every install, the same clean fit as a hook. `governed_body_canonical` wraps it with the
/// sentinel (first) and the markdown stamp (last). The Hard Rules block is DERIVED from this repo's
/// own constitution at build time (build.rs, S129), so a new rule reaches every future scaffold with
/// no action taken.
const TPL_AGENTS_BODY: &str = concat!(
    r#"## Mandatory Load Order

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

"#,
    include_str!(concat!(env!("OUT_DIR"), "/scaffold_hard_rules.md")),
    r#"
## Communication Style

- Under 200 words per response
- Bullets and tables, no paragraphs
- No filler phrases, no trailing summaries
- Code first, explanation after
"#
);

/// The canonical STAMPED governed body of the constitution (S143): the boundary sentinel, the
/// governed content, and the `<!-- vajra-render-sha: -->` markdown stamp closing it — the body region
/// `--sync-fleet` owns and upgrades. The stamp COVERS the sentinel (editing the boundary breaks the
/// stamp → `Drifted`), and it reuses `StampSyntax::MarkdownComment` — no fourth stamp path. The ONE
/// source both the scaffold (`files()`) and `sync_targets()` derive the constitution body from, so the
/// two never drift.
fn governed_body_canonical() -> String {
    let preimage = format!("{GOVERNED_BODY_SENTINEL}\n\n{TPL_AGENTS_BODY}");
    crate::fleet::stamp_render(&preimage, crate::fleet::StampSyntax::MarkdownComment)
}

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

const TPL_CONSTRAINTS: &str = concat!(
    r#"version: 3

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
"#,
    // DERIVED from .ai/CONSTRAINTS.yaml#ground_truth at build time (build.rs, S129) — the audit
    // list AND each carried audit's question block. Audits withheld from a scaffolded project
    // are declared in build.rs's OMIT_AUDITS and their reasons ship as comments right here, so
    // a stranger can read what was withheld from them and why.
    include_str!(concat!(env!("OUT_DIR"), "/scaffold_ground_truth.yaml")),
    r#"
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
"#
);

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

// S146 (DECISION-007 S146 addendum): the scaffold template for the close-gate — identical to the
// vajra source gate except the three `local BIN="target/release/vajra"` lines use a PATH-first
// resolver (`command -v vajra`) so non-Rust adopters (TypeScript, Python, chitra) can run the
// binary-backed checks (S144 finding 2). Carries `check_fidelity_review` + `waiver_ok` +
// `--fidelity-only` + `check_required_crew` — a scaffolded project's closeout structurally
// requires an independent ACCEPT review (DECISION-002). Vajra's own `scripts/verify-closeout.sh`
// is NOT modified — it runs from source. `scripts/*` is excluded in Cargo.toml; this file is
// un-excluded there (per-file negation) so it ships with `cargo install`.
const TPL_VERIFY_CLOSEOUT_SCAFFOLD: &str =
    include_str!("../../scripts/verify-closeout-scaffold.sh");

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

    /// Test helper (S143): write a canonical scaffolded constitution — the filled header + the
    /// stamped governed body — so a `--sync-fleet` fixture's boundary target reports `UpToDate` and
    /// does not interfere with the role/hook assertions (a fixture with no constitution would refuse
    /// the whole run, which is a different test). Mirrors what `f_constitution()` writes at scaffold.
    fn seed_constitution(root: &Path) {
        fs::create_dir_all(root.join(".ai")).unwrap();
        let header = TPL_AGENTS_HEADER.replace("{PROJECT_NAME}", "test-project");
        let content = format!("{header}{}", governed_body_canonical());
        fs::write(root.join(".ai/AGENTS.md"), content).unwrap();
    }

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
        {
            let __body = fs::read_to_string(&hook).unwrap();
            assert_eq!(
                crate::fleet::strip_render_stamp(&__body, crate::fleet::StampSyntax::ShellComment),
                TPL_HOOK_COPILOT_LOADER,
                "scaffolded hook, stamp stripped, must equal the canonical template (one source, no drift)"
            );
            assert!(
                crate::fleet::render_stamp_verifies(
                    &__body,
                    crate::fleet::StampSyntax::ShellComment
                ),
                "scaffolded hook must carry a verifying S142 shell-comment stamp"
            );
        }
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
        {
            let __body = fs::read_to_string(&hook).unwrap();
            assert_eq!(
                crate::fleet::strip_render_stamp(&__body, crate::fleet::StampSyntax::ShellComment),
                TPL_HOOK_COPILOT_MURMUR,
                "scaffolded hook, stamp stripped, must equal the canonical template (one source, no drift)"
            );
            assert!(
                crate::fleet::render_stamp_verifies(
                    &__body,
                    crate::fleet::StampSyntax::ShellComment
                ),
                "scaffolded hook must carry a verifying S142 shell-comment stamp"
            );
        }
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
    fn scaffold_ships_verify_closeout_stamped_and_executable() {
        let dir = scaffold_tmp();
        let gate = dir.path().join("scripts/verify-closeout.sh");
        assert!(gate.exists(), "verify-closeout.sh not scaffolded");
        let on_disk = fs::read_to_string(&gate).unwrap();
        // S146: the scaffold now uses the PATH-first template (not the vajra source gate) and
        // is stamped via ShellComment so a fresh init + --sync-fleet reports UpToDate.
        // Verify the stamp round-trip (render → parse → verify) rather than byte-identity with
        // the vajra source gate (TPL_VERIFY_CLOSEOUT_SCAFFOLD, not the unmodified vajra gate).
        assert!(
            crate::fleet::render_stamp_verifies(&on_disk, crate::fleet::StampSyntax::ShellComment),
            "scaffolded verify-closeout.sh stamp does not verify — stamp mismatch or missing"
        );
        // PATH-first resolver must be present (S144 finding 2).
        assert!(
            on_disk.contains("command -v vajra"),
            "scaffolded verify-closeout.sh missing PATH-first binary resolver"
        );
        // The vajra source gate's hardcoded path must NOT appear (it's the fallback in a comment).
        assert!(
            on_disk.contains("target/release/vajra"),
            "scaffolded verify-closeout.sh missing fallback path"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&gate).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "verify-closeout.sh must be executable");
        }
    }

    #[test]
    fn verify_closeout_scaffold_template_has_no_fill_placeholders() {
        // DECISION-007 byte-identity invariant: `fxs` runs fill() before stamp, while
        // `sync_targets` uses the raw template. Both produce UpToDate only if fill is a no-op.
        // fill() replaces {PROJECT_NAME}, {GOAL}, {SLUG}, {DATE}, {MATURITY}, {FIRST_*}.
        // This test catches any future edit that adds such a placeholder to the scaffold template.
        for placeholder in [
            "{PROJECT_NAME}",
            "{GOAL}",
            "{SLUG}",
            "{DATE}",
            "{MATURITY}",
            "{FIRST_NN}",
            "{FIRST_PROMPT}",
            "{FIRST_TITLE}",
            "{FIRST_NOTE}",
        ] {
            assert!(
                !TPL_VERIFY_CLOSEOUT_SCAFFOLD.contains(placeholder),
                "verify-closeout-scaffold.sh contains fill placeholder {placeholder} — \
                 files() and sync_targets() would produce different bytes, breaking DECISION-007"
            );
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
        {
            let __body = fs::read_to_string(&hook).unwrap();
            assert_eq!(
                crate::fleet::strip_render_stamp(&__body, crate::fleet::StampSyntax::ShellComment),
                TPL_HOOK_SESSION_GUARD,
                "scaffolded hook, stamp stripped, must equal the canonical template (one source, no drift)"
            );
            assert!(
                crate::fleet::render_stamp_verifies(
                    &__body,
                    crate::fleet::StampSyntax::ShellComment
                ),
                "scaffolded hook must carry a verifying S142 shell-comment stamp"
            );
        }
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
        {
            let __body = fs::read_to_string(&hook).unwrap();
            assert_eq!(
                crate::fleet::strip_render_stamp(&__body, crate::fleet::StampSyntax::ShellComment),
                TPL_HOOK_PUBLISH_GUARD,
                "scaffolded hook, stamp stripped, must equal the canonical template (one source, no drift)"
            );
            assert!(
                crate::fleet::render_stamp_verifies(
                    &__body,
                    crate::fleet::StampSyntax::ShellComment
                ),
                "scaffolded hook must carry a verifying S142 shell-comment stamp"
            );
        }
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
        {
            let __body = fs::read_to_string(&hook).unwrap();
            assert_eq!(
                crate::fleet::strip_render_stamp(&__body, crate::fleet::StampSyntax::ShellComment),
                TPL_HOOK_COMMIT_GUARD,
                "scaffolded hook, stamp stripped, must equal the canonical template (one source, no drift)"
            );
            assert!(
                crate::fleet::render_stamp_verifies(
                    &__body,
                    crate::fleet::StampSyntax::ShellComment
                ),
                "scaffolded hook must carry a verifying S142 shell-comment stamp"
            );
        }
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

    // ── S136: `--sync-fleet`, the brownfield UPGRADE path ────────────────────────────────────
    //
    // The bug these bind against is not hypothetical. chitra — the one project outside this repo —
    // was scaffolded by an older Vajra and carried FOUR of ten role files, every one of them a
    // stale render missing the whole `rec N —` / `obeyed:` protocol block. `init`'s skip-if-present
    // convention could never have fixed that: it CAN ADD, it can never UPDATE.

    /// S141: FOUR states now — the fourth, `StaleRender`, is derivable because the provenance is
    /// RECORDED (the `vajra-render-sha:` stamp), not inferred. A stamped older render re-hashes to
    /// its own stamp (→ `StaleRender`); an unstamped or hand-edited file does not (→ `Drifted`).
    #[test]
    fn classify_fleet_file_names_the_four_states() {
        let canonical = "---\nname: researcher\n---\nbody\n";
        assert_eq!(
            classify_fleet_file(
                None,
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None
            ),
            FleetFileState::Missing
        );
        assert_eq!(
            classify_fleet_file(
                Some(canonical),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::UpToDate
        );
        // An UNSTAMPED file that differs (every pre-S141 install, incl. chitra) → Drifted, NOT
        // StaleRender: Vajra genuinely cannot prove provenance it never wrote.
        assert_eq!(
            classify_fleet_file(
                Some("---\nname: researcher\n---\nOLD\n"),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::Drifted
        );
        // The exact chitra shape: an older render is a PREFIX of the current one (a protocol block
        // was appended). Unstamped → still Drifted.
        assert_eq!(
            classify_fleet_file(
                Some("---\nname: researcher\n---\n"),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::Drifted
        );
        // Whitespace is not "close enough": an unstamped file is a byte-exact render or drifted.
        assert_eq!(
            classify_fleet_file(
                Some(&format!("{canonical}\n")),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::Drifted
        );
        // A STAMPED older render — built the SAME way the real renderer stamps — differs from the
        // current canonical yet re-hashes to its own embedded stamp → StaleRender (auto-upgradable).
        let stale = crate::fleet::stamp_render(
            "---\nname: researcher\ndescription: old\ntools: Read, Grep, Glob\n---\n\nOLD BODY\n",
            crate::fleet::StampSyntax::Frontmatter,
        );
        assert_ne!(stale, canonical);
        assert_eq!(
            classify_fleet_file(
                Some(&stale),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::StaleRender
        );
        // ...but a hand-edit of that stamped render breaks the round-trip → back to Drifted. This is
        // the load-bearing distinction: a stamp is not a free pass, it must actually VERIFY.
        let edited = format!("{stale}\na user's own added line\n");
        assert_eq!(
            classify_fleet_file(
                Some(&edited),
                canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::Drifted
        );
    }

    /// S142 (fidelity-reviewer rec 1): `classify_fleet_file` drives a `ShellComment` HOOK through all
    /// four states at the pure-unit level — not only `Frontmatter`. Without this the hook classify
    /// path had no unit guard and rode entirely on the fixture/live layer (the named fakest green).
    #[test]
    fn classify_names_the_four_states_for_a_shell_hook() {
        use crate::fleet::StampSyntax::ShellComment;
        // A canonical stamped hook (shell-comment stamp over a body ending in \n).
        let canonical = crate::fleet::stamp_render("#!/usr/bin/env bash\necho hi\n", ShellComment);
        assert_eq!(
            classify_fleet_file(None, &canonical, ShellComment, None),
            FleetFileState::Missing
        );
        assert_eq!(
            classify_fleet_file(Some(&canonical), &canonical, ShellComment, None),
            FleetFileState::UpToDate
        );
        // An unstamped hook that differs (every pre-S142 install) → Drifted, never StaleRender.
        assert_eq!(
            classify_fleet_file(
                Some("#!/usr/bin/env bash\necho OLD\n"),
                &canonical,
                ShellComment,
                None,
            ),
            FleetFileState::Drifted
        );
        // A correctly-stamped OLDER hook render (differs from canonical, yet re-hashes to its own
        // shell-comment stamp) → StaleRender (auto-upgradable).
        let stale =
            crate::fleet::stamp_render("#!/usr/bin/env bash\necho OLDER BODY\n", ShellComment);
        assert_ne!(stale, canonical);
        assert_eq!(
            classify_fleet_file(Some(&stale), &canonical, ShellComment, None),
            FleetFileState::StaleRender
        );
        // A hand-edit of that stamped hook breaks the round-trip → back to Drifted.
        let edited = format!("{stale}\n# the user added this\n");
        assert_eq!(
            classify_fleet_file(Some(&edited), &canonical, ShellComment, None),
            FleetFileState::Drifted
        );
        // Cross-syntax safety: the SAME stamped shell hook must NOT verify as Frontmatter — a file
        // classified under one syntax cannot be auto-upgraded via another's stamp reader.
        assert_eq!(
            classify_fleet_file(
                Some(&stale),
                &canonical,
                crate::fleet::StampSyntax::Frontmatter,
                None,
            ),
            FleetFileState::Drifted
        );
    }

    /// S143: `classify_fleet_file` drives the constitution — a BOUNDARY target — through all FIVE
    /// states on the governed BODY region alone, with a user-owned header that is neither compared nor
    /// touched. `NeedsBoundary` is the fifth state, reached only by a boundary target with no sentinel.
    #[test]
    fn classify_constitution_names_the_five_states_on_the_body_region() {
        use crate::fleet::StampSyntax::MarkdownComment;
        let sentinel = GOVERNED_BODY_SENTINEL;
        let canonical = governed_body_canonical();
        // A user-owned header — arbitrary, hand-edited, NEVER part of the comparison.
        let header = "# ACME — AI Agent Constitution\n\n> our own preamble\n\n";

        // Missing — no file at all.
        assert_eq!(
            classify_fleet_file(None, &canonical, MarkdownComment, Some(sentinel)),
            FleetFileState::Missing
        );
        // UpToDate — header + the canonical body; the header differs from the template's but the BODY
        // region matches, so the file is up to date and the header is out of scope.
        let up_to_date = format!("{header}{canonical}");
        assert_eq!(
            classify_fleet_file(
                Some(&up_to_date),
                &canonical,
                MarkdownComment,
                Some(sentinel)
            ),
            FleetFileState::UpToDate
        );
        // StaleRender — a correctly-stamped OLDER body under the same sentinel: differs from canonical
        // yet re-hashes to its own markdown stamp → auto-upgradable.
        let stale_body = crate::fleet::stamp_render(
            &format!("{sentinel}\n\n## Mandatory Load Order\n\nAN OLDER GOVERNED BODY\n"),
            MarkdownComment,
        );
        assert_ne!(stale_body, canonical);
        let stale = format!("{header}{stale_body}");
        assert_eq!(
            classify_fleet_file(Some(&stale), &canonical, MarkdownComment, Some(sentinel)),
            FleetFileState::StaleRender
        );
        // Drifted — the body was hand-edited so its stamp no longer verifies (sentinel still present).
        let drifted = format!(
            "{header}{}",
            canonical.replace("Mandatory Load Order", "Mangled")
        );
        assert_eq!(
            classify_fleet_file(Some(&drifted), &canonical, MarkdownComment, Some(sentinel)),
            FleetFileState::Drifted
        );
        // NeedsBoundary — a present file (every pre-S143 constitution) with NO sentinel: the body
        // region cannot be located, so no rewrite is safe. NOT Drifted — a different fix.
        let boundaryless =
            "# ACME — AI Agent Constitution\n\n## Mandatory Load Order\n\nold text\n";
        assert_eq!(
            classify_fleet_file(
                Some(boundaryless),
                &canonical,
                MarkdownComment,
                Some(sentinel)
            ),
            FleetFileState::NeedsBoundary
        );
        // Cross-check: with boundary None (a whole-file target), the SAME boundaryless file is just a
        // Drifted whole-file compare — NeedsBoundary is exclusively a boundary-target state.
        assert_eq!(
            classify_fleet_file(Some(boundaryless), &canonical, MarkdownComment, None),
            FleetFileState::Drifted
        );
    }

    /// S143: `body_region` is a pure function — whole file for a `None` boundary, the slice from the
    /// sentinel for a `Some` boundary, and `None` (→ `NeedsBoundary`) when the sentinel is absent.
    #[test]
    fn body_region_extracts_only_the_governed_body() {
        let sentinel = GOVERNED_BODY_SENTINEL;
        let file = format!("HEADER above\n\n{sentinel}\ngoverned below\n");
        // None boundary → the whole file, byte-for-byte (roles/hooks path, unchanged).
        assert_eq!(body_region(&file, None), Some(file.as_str()));
        // Some(sentinel) → from the sentinel to the end; the header is excluded.
        assert_eq!(
            body_region(&file, Some(sentinel)),
            Some(format!("{sentinel}\ngoverned below\n").as_str())
        );
        // Some(sentinel) but absent → None (the caller reads this as NeedsBoundary).
        assert_eq!(body_region("no boundary here\n", Some(sentinel)), None);
    }

    /// S143: the governed body carries NO `fill` placeholders — the same load-bearing invariant the
    /// hooks have (S142). If it did, sync would compute a different canonical than the scaffold wrote
    /// (which fills only the header), and the constitution would classify `Drifted` forever. The
    /// placeholders live ONLY above the sentinel, in the user-owned header.
    #[test]
    fn constitution_body_carries_no_fill_placeholders() {
        let body = governed_body_canonical();
        for ph in [
            "{PROJECT_NAME}",
            "{GOAL}",
            "{SLUG}",
            "{DATE}",
            "{MATURITY}",
            "{FIRST_NN}",
            "{FIRST_PROMPT}",
            "{FIRST_TITLE}",
            "{FIRST_NOTE}",
        ] {
            assert!(
                !body.contains(ph),
                "the governed body must carry no fill placeholder, found {ph}"
            );
        }
        // ...and the header is where the fill actually lives (the split is real, not cosmetic).
        assert!(
            TPL_AGENTS_HEADER.contains("{PROJECT_NAME}"),
            "the user-owned header must carry the fill"
        );
    }

    /// S143: the boundary sentinel is HTML-legal (no `--` double-hyphen inside the comment, which is
    /// illegal in strict HTML comments) and carries no fill token (so it is byte-identical across
    /// installs and can be located by `find`).
    #[test]
    fn governed_body_sentinel_is_html_legal_and_fill_free() {
        let inner = GOVERNED_BODY_SENTINEL
            .strip_prefix("<!--")
            .and_then(|s| s.strip_suffix("-->"))
            .expect("the sentinel must be an HTML comment");
        assert!(
            !inner.contains("--"),
            "no `--` inside the comment (illegal in strict HTML comments)"
        );
        assert!(
            !GOVERNED_BODY_SENTINEL.contains('{'),
            "the sentinel must carry no fill token — it is byte-identical across installs"
        );
    }

    /// S143: the scaffolded constitution is stamped and immediately `UpToDate` — a fresh `init` +
    /// immediate `--sync-fleet` never rewrites it (no churn). Proves the scaffold and `sync_targets`
    /// derive the body from the ONE source, and that `fill` (header only) leaves the body untouched.
    #[test]
    fn scaffolded_constitution_is_stamped_and_immediately_up_to_date() {
        let entries = files(
            "my-proj",
            "first goal",
            "first-goal",
            "2026-01-01",
            "L2",
            false,
        );
        let ac = entries
            .iter()
            .find(|e| e.path == ".ai/AGENTS.md")
            .expect("the scaffold must emit the constitution");
        // The scaffolded file classifies UpToDate against the sync target's body-only canonical.
        assert_eq!(
            classify_fleet_file(
                Some(&ac.content),
                &governed_body_canonical(),
                crate::fleet::StampSyntax::MarkdownComment,
                Some(GOVERNED_BODY_SENTINEL),
            ),
            FleetFileState::UpToDate,
            "a freshly scaffolded constitution must be immediately UpToDate — no churn"
        );
        // The header carries the filled project name; the body carries the sentinel + stamp.
        assert!(ac.content.starts_with("# my-proj — AI Agent Constitution"));
        assert!(ac.content.contains(GOVERNED_BODY_SENTINEL));
        assert!(crate::fleet::render_stamp_verifies(
            body_region(&ac.content, Some(GOVERNED_BODY_SENTINEL)).unwrap(),
            crate::fleet::StampSyntax::MarkdownComment
        ));
    }

    /// S143 — the session's fakest green, guarded: a body-scoped UPGRADE must preserve the user-owned
    /// header BYTE-FOR-BYTE while replacing the governed body. A stale-body constitution with a custom,
    /// hand-edited header is upgraded; the header survives verbatim, the body becomes canonical.
    #[test]
    fn governed_body_upgrade_preserves_the_user_header_verbatim() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join(".ai")).unwrap();
        let custom_header =
            "# ACME Corp — AI Agent Constitution\n\n> our own hand-edited preamble\n\n";
        let stale_body = crate::fleet::stamp_render(
            &format!("{GOVERNED_BODY_SENTINEL}\n\n## Mandatory Load Order\n\nOLD GOVERNED BODY\n"),
            crate::fleet::StampSyntax::MarkdownComment,
        );
        fs::write(
            dir.path().join(".ai/AGENTS.md"),
            format!("{custom_header}{stale_body}"),
        )
        .unwrap();

        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .expect("a stale constitution body must auto-upgrade");

        let after = fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap();
        let idx = after
            .find(GOVERNED_BODY_SENTINEL)
            .expect("the sentinel must still be present after upgrade");
        assert_eq!(
            &after[..idx],
            custom_header,
            "the user-owned header must survive the upgrade BYTE-FOR-BYTE"
        );
        assert_eq!(
            &after[idx..],
            governed_body_canonical(),
            "the governed body must be upgraded to the current canonical"
        );
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains("upgrade") && text.contains(".ai/AGENTS.md"),
            "the constitution upgrade must be reported by name, got: {text}"
        );
    }

    /// S143: a pre-S143 constitution (no sentinel) is `NeedsBoundary` — REFUSED even under
    /// `--overwrite-drifted` (that flag must never rewrite it, or it would destroy the filled header),
    /// and the refusal names the exact sentinel to paste. The one-time legacy migration, made safe.
    #[test]
    fn boundaryless_constitution_is_refused_even_with_overwrite_drifted() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join(".ai")).unwrap();
        let legacy =
            "# ACME — AI Agent Constitution\n\n## Mandatory Load Order\n\nour real content\n";
        fs::write(dir.path().join(".ai/AGENTS.md"), legacy).unwrap();

        let mut out = Vec::new();
        let err = sync_fleet(
            dir.path(),
            // Even with the force flag, a boundaryless constitution must NOT be rewritten.
            SyncOpts {
                dry_run: false,
                overwrite_drifted: true,
            },
            &mut out,
        )
        .unwrap_err();

        assert!(
            err.to_string().contains(".ai/AGENTS.md"),
            "the refusal must name the constitution, got: {err}"
        );
        assert!(
            err.to_string().contains("needs-boundary"),
            "the constitution must be reported as needs-boundary, got: {err}"
        );
        // Its bytes are untouched — refusing means refusing (the filled header is safe).
        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap(),
            legacy,
            "a boundaryless constitution must never be rewritten"
        );
        // The output prints the EXACT sentinel to paste — the one-time migration instruction.
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains(GOVERNED_BODY_SENTINEL),
            "the migration message must print the exact sentinel to paste, got: {text}"
        );
    }

    /// S143 (qa-specialist rec 1): a MISSING constitution (deleted `.ai/AGENTS.md`) is warned and
    /// SKIPPED, never written — sync UPGRADES existing renders, but creating the constitution is
    /// `init`'s job (its filled header can't be reconstructed). The run still succeeds because the
    /// roles/hooks (Missing → created) are sync's job; a headerless body-only write is refused.
    #[test]
    fn a_missing_constitution_warns_and_is_skipped_not_created() {
        let dir = tempfile::tempdir().unwrap();
        // No .ai/AGENTS.md on disk. Roles + hooks are also Missing (a fresh dir) and WILL be created.
        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .expect("a missing constitution must not fail the run — roles/hooks still sync");
        assert!(
            !dir.path().join(".ai/AGENTS.md").exists(),
            "sync must NEVER scaffold a headerless constitution — that would have no project fill"
        );
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains(".ai/AGENTS.md is absent") && text.contains("vajra init"),
            "a missing constitution must be reported with a run-`vajra init` note, got: {text}"
        );
        // The roles (Missing → created) ARE sync's job, so the run did real work and exited 0.
        assert!(
            dir.path()
                .join(crate::fleet::ROLES[0].subagent_rel())
                .exists(),
            "a missing role must still be created — only the constitution is init's to scaffold"
        );
    }

    /// S142 load-bearing invariant: the synced hooks carry NO `fill` placeholders, so their stamped
    /// render is byte-identical whether produced at scaffold time (after `fill`) or at sync time (no
    /// fill). If a future hook gained a `{PLACEHOLDER}`, sync would compute a different canonical than
    /// the scaffold wrote and the hook would classify `Drifted` forever — this test fails first.
    #[test]
    fn hook_templates_carry_no_fill_placeholders() {
        let placeholders = [
            "{PROJECT_NAME}",
            "{GOAL}",
            "{SLUG}",
            "{DATE}",
            "{MATURITY}",
            "{FIRST_NN}",
            "{FIRST_PROMPT}",
            "{FIRST_TITLE}",
            "{FIRST_NOTE}",
        ];
        for (rel, tpl) in SYNC_HOOKS {
            for ph in placeholders {
                assert!(
                    !tpl.contains(ph),
                    "{rel} contains the fill placeholder {ph}: a synced hook must be fill-free, \
                     else scaffold and sync compute different canonical bytes and it drifts forever"
                );
            }
        }
    }

    /// S142: a fresh scaffold writes every hook already STAMPED, so an immediate `--sync-fleet`
    /// finds them `UpToDate` (idempotent, no churn) — the whole point of stamping at scaffold time.
    #[test]
    fn scaffolded_hooks_are_stamped_and_immediately_up_to_date() {
        let dir = tempfile::tempdir().unwrap();
        scaffold(dir.path(), "demo", "first goal", "L2").unwrap();
        for (rel, _tpl) in SYNC_HOOKS {
            let body = fs::read_to_string(dir.path().join(rel)).unwrap();
            assert!(
                crate::fleet::render_stamp_verifies(&body, crate::fleet::StampSyntax::ShellComment),
                "{rel} was not scaffolded with a verifying shell-comment stamp"
            );
            // Inert to bash: the shebang is still line 1, the stamp is the trailing comment.
            assert!(body.starts_with("#!"), "{rel} lost its shebang");
        }
        let plan = plan_fleet_sync(dir.path());
        for item in plan.iter().filter(|i| i.rel.starts_with(".ai/hooks/")) {
            assert_eq!(
                item.state,
                FleetFileState::UpToDate,
                "{} should be UpToDate right after scaffold, was {:?}",
                item.rel,
                item.state
            );
        }
    }

    /// S146 fixture: exercises all four reachable states of classify_fleet_file for
    /// scripts/verify-closeout.sh specifically (AC8 requirement — the existing hook test
    /// explicitly filters to .ai/hooks/ and skips the close-gate).
    #[test]
    fn fixture_146_close_gate_classify_all_states() {
        let canonical = render_stamped_hook(TPL_VERIFY_CLOSEOUT_SCAFFOLD);

        // Missing — not yet scaffolded
        let state = classify_fleet_file(None, &canonical, crate::fleet::StampSyntax::ShellComment, None);
        assert_eq!(state, FleetFileState::Missing, "absent file must be Missing");

        // UpToDate — byte-identical to canonical
        let state = classify_fleet_file(
            Some(&canonical),
            &canonical,
            crate::fleet::StampSyntax::ShellComment,
            None,
        );
        assert_eq!(state, FleetFileState::UpToDate, "canonical bytes must be UpToDate");

        // StaleRender — a previous ShellComment-stamped version of the same body
        // (old stamp present but body is a prior render — here we mutate the canonical body
        // before re-stamping to simulate an older version being present on disk)
        let old_body = format!("{}\n# (old version)\n", TPL_VERIFY_CLOSEOUT_SCAFFOLD);
        let old_render = render_stamped_hook(&old_body);
        let state = classify_fleet_file(
            Some(&old_render),
            &canonical,
            crate::fleet::StampSyntax::ShellComment,
            None,
        );
        assert_eq!(
            state,
            FleetFileState::StaleRender,
            "a ShellComment-stamped old render must be StaleRender, not Drifted"
        );

        // Drifted — user-edited file with no stamp
        let state = classify_fleet_file(
            Some("#!/usr/bin/env bash\n# user edited this file\necho hello\n"),
            &canonical,
            crate::fleet::StampSyntax::ShellComment,
            None,
        );
        assert_eq!(state, FleetFileState::Drifted, "unstamped user-edited file must be Drifted");

        // UpToDate after scaffold — fresh init then plan_fleet_sync reports UpToDate
        let dir = scaffold_tmp();
        let plan = plan_fleet_sync(dir.path());
        let close_gate = plan.iter().find(|i| i.rel == "scripts/verify-closeout.sh").unwrap();
        assert_eq!(
            close_gate.state,
            FleetFileState::UpToDate,
            "close-gate must be UpToDate immediately after scaffold (S146 DECISION-007 ONE-list invariant)"
        );
    }

    #[test]
    fn plan_fleet_sync_reports_every_registered_role_and_finds_an_empty_repo_all_missing() {
        let dir = tempfile::tempdir().unwrap();
        let plan = plan_fleet_sync(dir.path());
        // S142: the plan covers every role AND every pure-render hook — the canonical set, not a
        // hand-typed subset. A fresh empty repo has none of them.
        assert_eq!(
            plan.len(),
            crate::fleet::ROLES.len() + SYNC_HOOKS.len() + 1,
            "the plan must cover every role + every synced hook + the constitution (S143), not a hand-typed subset"
        );
        assert!(
            plan.iter().any(|i| i.rel.starts_with(".claude/agents/")),
            "the plan must include the role files"
        );
        assert!(
            plan.iter().any(|i| i.rel.starts_with(".ai/hooks/")),
            "the plan must include the shell hooks (S142)"
        );
        assert!(
            plan.iter()
                .any(|i| i.rel == ".ai/AGENTS.md" && i.boundary.is_some()),
            "the plan must include the constitution as a boundary target (S143)"
        );
        assert!(
            plan.iter().all(|i| i.state == FleetFileState::Missing),
            "an empty repo has no scaffold files"
        );
    }

    /// The chitra case end to end: some roles missing, some present-but-stale.
    #[test]
    fn sync_fleet_creates_missing_but_refuses_to_touch_drifted_by_default() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        let stale = &crate::fleet::ROLES[0];
        let stale_rel = stale.subagent_rel();
        fs::create_dir_all(dir.path().join(".claude/agents")).unwrap();
        fs::write(dir.path().join(&stale_rel), "an older render\n").unwrap();

        let mut out = Vec::new();
        let err = sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .unwrap_err();

        // Fails CLOSED on unresolved drift — a silent exit 0 would let a stale roster look synced.
        assert!(
            err.to_string().contains(&stale_rel),
            "the error must NAME the drifted file, got: {err}"
        );
        // The drifted file is byte-identical to what it was: refusing means refusing.
        assert_eq!(
            fs::read_to_string(dir.path().join(&stale_rel)).unwrap(),
            "an older render\n",
            "a default run must never rewrite a file whose bytes it cannot account for"
        );
        // ...and every OTHER role was still created. A refusal on one file is not an abort.
        for role in crate::fleet::ROLES.iter().skip(1) {
            let full = dir.path().join(role.subagent_rel());
            assert!(full.exists(), "{} was not created", role.name);
            assert_eq!(
                fs::read_to_string(&full).unwrap(),
                crate::fleet::render_subagent_definition(role),
                "{} was not written from the canonical render",
                role.name
            );
        }
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains("DRIFT"),
            "the drift must be reported, got: {text}"
        );
        assert!(
            text.contains("--overwrite-drifted"),
            "the message must name the flag that resolves it, got: {text}"
        );
    }

    #[test]
    fn sync_fleet_refreshes_drifted_only_when_explicitly_told_to() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        let stale = &crate::fleet::ROLES[0];
        fs::create_dir_all(dir.path().join(".claude/agents")).unwrap();
        fs::write(dir.path().join(stale.subagent_rel()), "an older render\n").unwrap();

        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: true,
            },
            &mut out,
        )
        .unwrap();
        assert_eq!(
            fs::read_to_string(dir.path().join(stale.subagent_rel())).unwrap(),
            crate::fleet::render_subagent_definition(stale)
        );
    }

    /// S141: a provably-untouched OLDER render auto-upgrades with NO `--overwrite-drifted` and the
    /// run exits 0 — the whole point of the stamp. A `Drifted` file in the same run still blocks.
    #[test]
    fn sync_fleet_auto_upgrades_a_stale_render_without_overwrite_and_exits_zero() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        fs::create_dir_all(dir.path().join(".claude/agents")).unwrap();

        // A genuine older render of ROLES[0]: the current render's body, changed, then re-stamped
        // the SAME way the renderer stamps — so it differs from the current canonical yet verifies.
        let role = &crate::fleet::ROLES[0];
        let older_unstamped = format!(
            "{}\nAN OLDER RENDER'S EXTRA PARAGRAPH\n",
            crate::fleet::strip_render_stamp(
                &crate::fleet::render_subagent_definition(role),
                crate::fleet::StampSyntax::Frontmatter
            )
        );
        let stale =
            crate::fleet::stamp_render(&older_unstamped, crate::fleet::StampSyntax::Frontmatter);
        fs::write(dir.path().join(role.subagent_rel()), &stale).unwrap();

        let mut out = Vec::new();
        // No --overwrite-drifted, yet this must succeed (exit 0) because the stamp proves provenance.
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .expect("a stale render must auto-upgrade without --overwrite-drifted");

        // The stale file was rewritten to the CURRENT canonical render.
        assert_eq!(
            fs::read_to_string(dir.path().join(role.subagent_rel())).unwrap(),
            crate::fleet::render_subagent_definition(role),
            "the stale render was not upgraded to the current render"
        );
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains("upgrade") && text.contains(&role.subagent_rel()),
            "the upgrade must be reported by name, got: {text}"
        );
        assert!(
            !text.contains("--overwrite-drifted"),
            "a stale render must NOT prompt for --overwrite-drifted, got: {text}"
        );
    }

    /// Idempotence is the whole contract of an upgrade command: run it twice, the second run is a
    /// no-op that writes nothing and exits 0.
    #[test]
    fn sync_fleet_is_idempotent_and_the_second_run_writes_nothing() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .unwrap();

        let role = &crate::fleet::ROLES[0];
        let full = dir.path().join(role.subagent_rel());
        let before = fs::metadata(&full).unwrap().modified().unwrap();

        let mut out2 = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out2,
        )
        .unwrap();
        let text = String::from_utf8(out2).unwrap();
        assert!(
            text.contains(&format!(
                "{} already current",
                crate::fleet::ROLES.len() + SYNC_HOOKS.len() + 1
            )),
            "second run must report every role + hook + constitution current, got: {text}"
        );
        assert_eq!(
            before,
            fs::metadata(&full).unwrap().modified().unwrap(),
            "an up-to-date file must not be rewritten — a no-op write still churns mtime and git status"
        );
    }

    /// A dry run must be a TRUE preview: same plan, same exit code, zero writes. A preview that
    /// exits 0 where the real run exits 1 is a preview of a different command.
    #[test]
    fn sync_fleet_dry_run_writes_nothing_and_returns_the_real_runs_verdict() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: true,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .unwrap();
        for role in crate::fleet::ROLES {
            assert!(
                !dir.path().join(role.subagent_rel()).exists(),
                "{} was written during a DRY RUN",
                role.name
            );
        }
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains("DRY RUN"),
            "the dry run must say so, got: {text}"
        );
        assert!(
            text.contains("to create") && !text.contains(" created,"),
            "a dry run must not claim work it did not do, got: {text}"
        );

        // Drift + dry-run must still fail, exactly as the real run would.
        let stale = &crate::fleet::ROLES[0];
        fs::create_dir_all(dir.path().join(".claude/agents")).unwrap();
        fs::write(dir.path().join(stale.subagent_rel()), "an older render\n").unwrap();
        let mut out2 = Vec::new();
        assert!(
            sync_fleet(
                dir.path(),
                SyncOpts {
                    dry_run: true,
                    overwrite_drifted: false
                },
                &mut out2
            )
            .is_err(),
            "a dry run over drift must return the same verdict the real run would"
        );
    }

    /// `--sync-fleet` must not drag in the other ~40 scaffold entries. A project at session 16 that
    /// asked for the new roster and got a `prompts/01-task-kickoff.md` was handed a bug. S142 widened
    /// the scope to the fleet roles (`.claude/agents/`) AND the pure-render hooks (`.ai/hooks/`); S143
    /// adds the constitution's governed BODY (`.ai/AGENTS.md`) — and NOTHING else: not `CONSTRAINTS.yaml`
    /// (user-tuned), not `SESSION`/scripts/prompts/sessions/`.githooks`. And it must never touch the
    /// constitution's user-owned HEADER: a seeded UpToDate constitution is left byte-identical.
    #[test]
    fn sync_fleet_touches_only_roles_hooks_and_the_constitution() {
        let dir = tempfile::tempdir().unwrap();
        seed_constitution(dir.path());
        let constitution_before = fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap();
        let mut out = Vec::new();
        sync_fleet(
            dir.path(),
            SyncOpts {
                dry_run: false,
                overwrite_drifted: false,
            },
            &mut out,
        )
        .unwrap();

        let mut top: Vec<String> = fs::read_dir(dir.path())
            .unwrap()
            .map(|e| e.unwrap().file_name().to_string_lossy().into_owned())
            .collect();
        top.sort();
        assert_eq!(
            top,
            vec![".ai".to_string(), ".claude".to_string(), "scripts".to_string()],
            "sync-fleet wrote outside .claude/ + .ai/ + scripts/ — it must never run the full init scaffold"
        );
        // Under .ai/ ONLY the constitution + hooks/ — never CONSTRAINTS.yaml, SESSION, etc.
        let mut ai: Vec<String> = fs::read_dir(dir.path().join(".ai"))
            .unwrap()
            .map(|e| e.unwrap().file_name().to_string_lossy().into_owned())
            .collect();
        ai.sort();
        assert_eq!(
            ai,
            vec!["AGENTS.md".to_string(), "hooks".to_string()],
            "sync-fleet wrote an unexpected .ai/ file — only the constitution + hooks are in scope (S143)"
        );
        // The constitution was UpToDate (seeded canonical) → NOT rewritten, byte-for-byte identical.
        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap(),
            constitution_before,
            "an up-to-date constitution must never be rewritten (no-churn)"
        );
        // S146: scripts/ now exists (verify-closeout.sh is a sync target). Only scripts/
        // verify-closeout.sh should appear — not a full scaffold of prompts, sessions, etc.
        assert!(dir.path().join("scripts/verify-closeout.sh").exists());
        for unwanted in [
            ".ai/CONSTRAINTS.yaml",
            ".ai/SESSION",
            "prompts",
            "sessions",
            ".githooks",
        ] {
            assert!(
                !dir.path().join(unwanted).exists(),
                "{unwanted} was scaffolded by --sync-fleet"
            );
        }
    }

    /// An unreadable file must not be mistaken for an absent one — that would turn a permissions
    /// error into a silent overwrite.
    #[cfg(unix)]
    #[test]
    fn an_unreadable_role_file_reads_as_drifted_never_as_missing() {
        use std::os::unix::fs::PermissionsExt;
        let dir = tempfile::tempdir().unwrap();
        let role = &crate::fleet::ROLES[0];
        let full = dir.path().join(role.subagent_rel());
        fs::create_dir_all(full.parent().unwrap()).unwrap();
        fs::write(&full, "secret\n").unwrap();
        fs::set_permissions(&full, fs::Permissions::from_mode(0o000)).unwrap();

        let plan = plan_fleet_sync(dir.path());
        let item = plan.iter().find(|i| i.label == role.name).unwrap();
        // Root can read anything; skip the assertion rather than assert a falsehood about the env.
        if fs::read_to_string(&full).is_err() {
            assert_eq!(item.state, FleetFileState::Drifted);
        }
        fs::set_permissions(&full, fs::Permissions::from_mode(0o644)).unwrap();
    }
}
