//! The Releaser station — the pipeline's SHIP gate (S72), the 8th governed station.
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (S54+S61+S62)
//! governs the **WHAT**; the Architect (S67) the **DESIGN**; the Planner (S64) the **HOW-plan**;
//! the Coder (S68) the **DID**; QA (S69) the **WORKS**; the Demo-er (S71) the **SHOW**; the
//! Reviewer/ledger (S55–59) the **REVIEW**. Nothing governs **SHIP**: a session's work ships
//! (PR → merge → main synced → branches pruned) on convention alone — the S37 founder-flagged
//! gap ("the workflow has no post-merge 'checkout main + prune merged branches' step") is
//! enforced by nobody.
//!
//! The contract is NOT a new artifact. The evidence already exists in git — merge ancestry,
//! the local `origin/main` ref, the local branch list (memory `feedback-map-concepts-to-vajra`):
//! no `release.md`, no second store, no 8th command (rides `vajra next`), no new dependency,
//! no network call and no `gh` in the gate. The binary **surfaces + enforces, never ships** —
//! pushing, merging, and pruning stay human acts the gate waits for.
//!
//! The marker here is *derived git state* (the S68 Coder lesson, git-shaped): per the S69/S71
//! executable-marker lesson the gate RE-DERIVES ancestry/sync/prune facts from git at check
//! time — there is no recorded text to forge:
//!
//! 1. `--release NN` surfaces session NN's ship state read-only: branch found/missing, merged
//!    into main or not (ancestry), local main vs `origin/main`, unpruned merged `session-*`
//!    locals. Nothing is fetched, pushed, merged, or deleted.
//! 2. `--check-release NN` BLOCKS (exit 1) on an unmerged session branch, a main that is
//!    behind/diverged from a known `origin/main`, or merged `session-*` branches (other than
//!    the currently checked-out one) left unpruned. "A check that cannot evaluate FAILS" — a
//!    repo with no git or no main blocks, never silently passes.
//! 3. At `--advance` the gate binds on the PRIOR session — the newest session at-or-below the
//!    one being closed that left evidence (a `prompts/NN-task-*.md` or a `session-NN-*`
//!    branch), skipping the session whose branch is currently checked out (its close is the
//!    one in flight). A fresh repo (no prior evidence, no remote) WARNS at most, the dodge
//!    named.
//! 4. `CONSTRAINTS.yaml#release` records the contract (`require_merged_prior`,
//!    `require_main_synced`, `require_pruned` — house line-scan, missing keys default true).
//!
//! Honest limits, stated not hidden: `origin/main` is read as of the LAST FETCH — the gate
//! never fetches, so an unfetched remote merge is invisible. A branch pruned after merge is
//! the desired end-state, but it leaves ancestry nothing to bind to — a branch pruned
//! UNMERGED is indistinguishable from it (the self-granted-jurisdiction class, disclosed).
//! "Merged" proves ancestry, not that the merge was the reviewed PR. Never pitch this as
//! "the release is verified" — the gate governs ship MECHANICS, not release quality.

use std::fs;
use std::path::Path;
use std::process::Command;

/// The ship contract, read from `.ai/CONSTRAINTS.yaml#release` (house-style line scan — no
/// YAML dependency). Missing file/section/keys default to `true` — the scaffold defaults.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReleaseContract {
    pub require_merged_prior: bool,
    pub require_main_synced: bool,
    pub require_pruned: bool,
}

impl Default for ReleaseContract {
    fn default() -> Self {
        ReleaseContract {
            require_merged_prior: true,
            require_main_synced: true,
            require_pruned: true,
        }
    }
}

/// Read the `release:` section keys (scoped like the QA/Demo-er scans: keys only count inside
/// their own top-level section; anything unrecorded keeps the scaffold default `true`).
pub fn release_contract(constraints_path: &Path) -> ReleaseContract {
    let content = fs::read_to_string(constraints_path).unwrap_or_default();
    let mut in_release = false;
    let mut contract = ReleaseContract::default();
    for line in content.lines() {
        if !line.starts_with([' ', '\t', '#']) && line.trim_end().ends_with(':') {
            in_release = line.trim_end() == "release:";
            continue;
        }
        if !in_release {
            continue;
        }
        let t = line.trim();
        for (key, slot) in [
            ("require_merged_prior:", &mut contract.require_merged_prior),
            ("require_main_synced:", &mut contract.require_main_synced),
            ("require_pruned:", &mut contract.require_pruned),
        ] {
            if let Some(v) = t.strip_prefix(key) {
                *slot = v.trim() != "false";
            }
        }
    }
    contract
}

/// Run a read-only git plumbing command at `root`; `Some((exit_code, stdout))` when it spawned.
fn git_out(root: &Path, args: &[&str]) -> Option<(i32, String)> {
    let out = Command::new("git")
        .args(args)
        .current_dir(root)
        .output()
        .ok()?;
    Some((
        out.status.code()?,
        String::from_utf8_lossy(&out.stdout).into_owned(),
    ))
}

fn is_git_repo(root: &Path) -> bool {
    matches!(git_out(root, &["rev-parse", "--git-dir"]), Some((0, _)))
}

/// The integration branch: `main`, else `master`, else none — a repo with neither cannot be
/// release-checked (fail-closed).
pub fn main_branch(root: &Path) -> Option<String> {
    ["main", "master"].into_iter().find_map(|name| {
        let ref_ = format!("refs/heads/{name}");
        match git_out(root, &["rev-parse", "--verify", "--quiet", &ref_]) {
            Some((0, _)) => Some(name.to_string()),
            _ => None,
        }
    })
}

/// The session number a `session-NN-<slug>` ref encodes (local or `origin/`-prefixed), if any.
pub fn session_number_of(ref_name: &str) -> Option<u32> {
    let name = ref_name.strip_prefix("origin/").unwrap_or(ref_name);
    let rest = name.strip_prefix("session-")?;
    let digits: String = rest.chars().take_while(|c| c.is_ascii_digit()).collect();
    if digits.is_empty() || !rest[digits.len()..].starts_with('-') {
        return None;
    }
    digits.parse().ok()
}

/// List `session-*` refs (short names) under the given ref namespaces.
fn session_refs_under(root: &Path, patterns: &[&str]) -> Vec<String> {
    let mut args = vec!["for-each-ref", "--format=%(refname:short)"];
    args.extend_from_slice(patterns);
    match git_out(root, &args) {
        Some((0, out)) => out
            .lines()
            .map(str::to_string)
            .filter(|r| session_number_of(r).is_some())
            .collect(),
        _ => Vec::new(),
    }
}

/// Every ref (local + `origin/` remote-tracking) that names session `nn`.
pub fn refs_for_session(root: &Path, nn: u32) -> Vec<String> {
    session_refs_under(
        root,
        &["refs/heads/session-*", "refs/remotes/origin/session-*"],
    )
    .into_iter()
    .filter(|r| session_number_of(r) == Some(nn))
    .collect()
}

/// Is `ref_name` an ancestor of `main` (merged)? `None` when ancestry cannot be derived.
fn is_ancestor(root: &Path, ref_name: &str, main: &str) -> Option<bool> {
    match git_out(root, &["merge-base", "--is-ancestor", ref_name, main]) {
        Some((0, _)) => Some(true),
        Some((1, _)) => Some(false),
        _ => None,
    }
}

fn current_branch(root: &Path) -> Option<String> {
    match git_out(root, &["branch", "--show-current"]) {
        Some((0, out)) if !out.trim().is_empty() => Some(out.trim().to_string()),
        _ => None,
    }
}

/// The target session's branch ship state, derived live from ancestry.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum BranchShip {
    /// No `session-NN-*` ref survives (local or origin) — pruned after merge is the desired
    /// end-state, but ancestry has nothing left to bind to (vacuous; the dodge named).
    NoBranch,
    /// Every surviving ref for the session is an ancestor of main.
    Merged(Vec<String>),
    /// These refs are NOT ancestors of main — the work has not shipped. A ref whose ancestry
    /// cannot be derived counts here too (a check that cannot evaluate FAILS).
    Unmerged(Vec<String>),
}

/// Local main vs the last-fetched `origin/<main>` ref. The gate never fetches.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum MainSync {
    /// No `origin/<main>` ref known — fresh repo / no remote; sync is unverifiable.
    NoRemote,
    Synced,
    /// Local-only commits (not pushed). Disclosed, not blocked — the contract blocks on
    /// behind/diverged; ahead is publishable by a push the gate must not perform.
    Ahead(u32),
    Behind(u32),
    Diverged(u32, u32),
}

/// Session NN's ship state, re-derived from git at check time — never a recorded claim.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ShipState {
    pub session: u32,
    /// The integration branch the facts are derived against (`main` or `master`).
    pub main: String,
    pub branch: BranchShip,
    pub sync: MainSync,
    /// Merged `session-*` LOCAL branches (other than the currently checked-out one) still
    /// undeleted — the S37 "prune merged branches" step, unfinished.
    pub unpruned: Vec<String>,
}

/// Derive session `nn`'s ship state live. `Err` = the state cannot be derived at all
/// (no git repo / no main branch) — which FAILS, never silently passes.
pub fn derive_ship_state(root: &Path, nn: u32) -> Result<ShipState, String> {
    if !is_git_repo(root) {
        return Err("not a git repository — ship state cannot be derived".to_string());
    }
    let main = main_branch(root)
        .ok_or_else(|| "no main (or master) branch — ship state cannot be derived".to_string())?;

    let refs = refs_for_session(root, nn);
    let branch = if refs.is_empty() {
        BranchShip::NoBranch
    } else {
        let unmerged: Vec<String> = refs
            .iter()
            .filter(|r| is_ancestor(root, r, &main) != Some(true))
            .cloned()
            .collect();
        if unmerged.is_empty() {
            BranchShip::Merged(refs)
        } else {
            BranchShip::Unmerged(unmerged)
        }
    };

    let origin_main = format!("refs/remotes/origin/{main}");
    let sync = match git_out(root, &["rev-parse", "--verify", "--quiet", &origin_main]) {
        Some((0, _)) => {
            let range = format!("{main}...origin/{main}");
            let counts = git_out(root, &["rev-list", "--left-right", "--count", &range])
                .filter(|(code, _)| *code == 0)
                .map(|(_, out)| out)
                .ok_or_else(|| format!("could not compare {main} with origin/{main}"))?;
            let mut nums = counts.split_whitespace().map(|n| n.parse::<u32>());
            match (nums.next(), nums.next()) {
                (Some(Ok(ahead)), Some(Ok(behind))) => match (ahead, behind) {
                    (0, 0) => MainSync::Synced,
                    (a, 0) => MainSync::Ahead(a),
                    (0, b) => MainSync::Behind(b),
                    (a, b) => MainSync::Diverged(a, b),
                },
                _ => return Err(format!("could not compare {main} with origin/{main}")),
            }
        }
        _ => MainSync::NoRemote,
    };

    let current = current_branch(root);
    let unpruned = session_refs_under(root, &["refs/heads/session-*"])
        .into_iter()
        .filter(|b| Some(b) != current.as_ref())
        .filter(|b| is_ancestor(root, b, &main) == Some(true))
        .collect();

    Ok(ShipState {
        session: nn,
        main,
        branch,
        sync,
        unpruned,
    })
}

/// Does session `nn` have a prompt on disk (`prompts/NN-task-*.md`)?
pub fn prompt_exists(root: &Path, nn: u32) -> bool {
    let prefix = format!("{nn:02}-task-");
    fs::read_dir(root.join("prompts"))
        .ok()
        .into_iter()
        .flatten()
        .filter_map(|e| e.ok())
        .any(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            name.starts_with(&prefix) && name.ends_with(".md")
        })
}

/// The PRIOR session the close-gate binds on: the newest session at-or-below `closing` that
/// left evidence (a prompt or a `session-NN-*` ref), skipping the session whose branch is the
/// currently checked-out one — that session's close is the one in flight (a ground-truth
/// closeout advances while standing ON its own `session-NN-closeout` branch).
pub fn find_release_target(root: &Path, closing: u32) -> Option<u32> {
    let current = current_branch(root);
    let in_flight = current.as_deref().and_then(session_number_of);
    let mut candidates: Vec<u32> = session_refs_under(
        root,
        &["refs/heads/session-*", "refs/remotes/origin/session-*"],
    )
    .iter()
    .filter_map(|r| session_number_of(r))
    .collect();
    if let Ok(entries) = fs::read_dir(root.join("prompts")) {
        for e in entries.filter_map(|e| e.ok()) {
            let name = e.file_name().to_string_lossy().to_string();
            if !name.ends_with(".md") {
                continue;
            }
            if let Some((digits, rest)) = name.split_once("-task-") {
                if !rest.is_empty() {
                    if let Ok(n) = digits.parse::<u32>() {
                        candidates.push(n);
                    }
                }
            }
        }
    }
    candidates
        .into_iter()
        .filter(|&n| n <= closing && Some(n) != in_flight)
        .max()
}

/// The Releaser station's decision. Mirrors the Demo-er's `DemoVerdict`.
#[derive(Debug, Clone)]
pub struct ReleaseVerdict {
    /// The session whose ship state was judged (`None` = fresh repo, nothing to bind to).
    pub session: Option<u32>,
    pub contract: ReleaseContract,
    /// The derived state (`None` when it could not be derived — see `reasons`).
    pub state: Option<ShipState>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    /// Non-blocking disclosures (vacuous ancestry, unpushed main, no remote — dodges named).
    pub warnings: Vec<String>,
}

impl ReleaseVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The Releaser gate for an EXPLICIT session (`--check-release NN`): judge session `nn`'s ship
/// state against the recorded contract. A session with no evidence at all (no branch, no
/// prompt) cannot be evaluated — which BLOCKS, never silently passes.
pub fn release_gate(root: &Path, nn: u32) -> ReleaseVerdict {
    let contract = release_contract(&root.join(".ai/CONSTRAINTS.yaml"));
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    let state = match derive_ship_state(root, nn) {
        Ok(s) => s,
        Err(e) => {
            reasons.push(format!("{e} — a check that cannot evaluate FAILS"));
            return ReleaseVerdict {
                session: Some(nn),
                contract,
                state: None,
                reasons,
                warnings,
            };
        }
    };

    if state.branch == BranchShip::NoBranch && !prompt_exists(root, nn) {
        reasons.push(format!(
            "session {nn:02} left no evidence (no session-{nn:02}-* branch local or origin, \
             no prompts/{nn:02}-task-*.md) — nothing to release-check; a check that cannot \
             evaluate FAILS"
        ));
        return ReleaseVerdict {
            session: Some(nn),
            contract,
            state: Some(state),
            reasons,
            warnings,
        };
    }

    if contract.require_merged_prior {
        match &state.branch {
            BranchShip::Merged(_) => {}
            BranchShip::NoBranch => warnings.push(format!(
                "session {nn:02}'s branch is not found (local or origin/) — pruned after merge \
                 is the desired end-state, but ancestry has nothing to bind to: a branch pruned \
                 UNMERGED would look identical (self-granted jurisdiction, disclosed)"
            )),
            BranchShip::Unmerged(refs) => reasons.push(format!(
                "session {nn:02}'s branch {} is NOT an ancestor of {} — the session's work has \
                 not shipped; merge it (PR → {}) before closing",
                refs.join(", "),
                state.main,
                state.main
            )),
        }
    }

    if contract.require_main_synced {
        match &state.sync {
            MainSync::Synced => {}
            MainSync::NoRemote => warnings.push(format!(
                "no origin/{} ref known (fresh repo / no remote) — main sync is unverifiable; \
                 judged from local refs only",
                state.main
            )),
            MainSync::Ahead(a) => warnings.push(format!(
                "{} is ahead of origin/{} by {a} commit(s) — local merges not pushed; not \
                 blocked (publishing is a human act), but the ship is not on origin yet",
                state.main, state.main
            )),
            MainSync::Behind(b) => reasons.push(format!(
                "{} is behind origin/{} by {b} commit(s) — sync main (checkout {} + pull) \
                 before closing (the S37 return-to-main step)",
                state.main, state.main, state.main
            )),
            MainSync::Diverged(a, b) => reasons.push(format!(
                "{} has DIVERGED from origin/{} ({a} ahead / {b} behind) — reconcile main \
                 before closing",
                state.main, state.main
            )),
        }
    }

    if contract.require_pruned && !state.unpruned.is_empty() {
        reasons.push(format!(
            "merged session-* branches left unpruned: {} — delete them (git branch -d) to \
             return to a clean {} (the S37 prune step)",
            state.unpruned.join(", "),
            state.main
        ));
    }

    ReleaseVerdict {
        session: Some(nn),
        contract,
        state: Some(state),
        reasons,
        warnings,
    }
}

/// The Releaser gate as `--advance` fires it: bind on the PRIOR session (the newest one
/// at-or-below `closing` with evidence). A fresh repo — no prior session branch or prompt —
/// WARNS at most, the dodge named in the gate's own output.
pub fn release_gate_for_close(root: &Path, closing: u32) -> ReleaseVerdict {
    match find_release_target(root, closing) {
        Some(target) => release_gate(root, target),
        None => ReleaseVerdict {
            session: None,
            contract: release_contract(&root.join(".ai/CONSTRAINTS.yaml")),
            state: None,
            reasons: Vec::new(),
            warnings: vec![format!(
                "no prior session with a branch or prompt at-or-below {closing:02} — fresh \
                 repos pass, but note the dodge: a repo can reach this state by deleting the \
                 evidence (self-granted jurisdiction, disclosed)"
            )],
        },
    }
}

/// Render the `--release NN` surface: the session's ship state, read-only. States the honest
/// limits plainly: derived from LOCAL refs (origin/main is as of the last fetch — the gate
/// never fetches), and the gate never pushes, merges, or deletes — shipping stays a human act.
pub fn format_release_report(v: &ReleaseVerdict) -> String {
    let mut s = match v.session {
        Some(nn) => format!("=== releaser: ship state for session {nn:02} ===\n"),
        None => "=== releaser: ship state ===\n".to_string(),
    };
    if let Some(state) = &v.state {
        s.push_str(&format!(
            "main:     {} (vs origin/{}: {})\n",
            state.main,
            state.main,
            match &state.sync {
                MainSync::NoRemote => "no remote ref known".to_string(),
                MainSync::Synced => "synced".to_string(),
                MainSync::Ahead(a) => format!("ahead {a} — not pushed"),
                MainSync::Behind(b) => format!("BEHIND {b} — pull to sync"),
                MainSync::Diverged(a, b) => format!("DIVERGED {a} ahead / {b} behind"),
            }
        ));
        s.push_str(&format!(
            "branch:   {}\n",
            match &state.branch {
                BranchShip::Merged(refs) => format!("{} (merged into {})", refs.join(", "), state.main),
                BranchShip::Unmerged(refs) =>
                    format!("{} (NOT merged into {})", refs.join(", "), state.main),
                BranchShip::NoBranch => "not found (pruned after merge, or never created)".to_string(),
            }
        ));
        s.push_str(&format!(
            "unpruned: {}\n",
            if state.unpruned.is_empty() {
                "(none)".to_string()
            } else {
                state.unpruned.join(", ")
            }
        ));
    }
    let c = &v.contract;
    s.push_str(&format!(
        "contract: merged_prior={} · main_synced={} · pruned={} (CONSTRAINTS.yaml#release; \
         missing keys default true)\n",
        c.require_merged_prior, c.require_main_synced, c.require_pruned
    ));
    for r in &v.reasons {
        s.push_str(&format!("  ✗ {r}\n"));
    }
    for w in &v.warnings {
        s.push_str(&format!("  ⚠ {w}\n"));
    }
    s.push_str(
        "surfaced read-only from LOCAL git refs — nothing fetched, pushed, merged, or deleted; \
         origin/main is as of the last fetch (an unfetched remote merge is invisible — honest \
         limit). `--check-release` blocks on unmerged / behind / diverged / unpruned; merging \
         and pruning stay human acts the gate waits for.\n",
    );
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const CONSTRAINTS: &str = "\
version: 3

maturity: L2

verify:
  script_pattern: 'scripts/verify-session-{NN}.sh'

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  required_elements: [header, cases, summary_table, before_after]

release:
  require_merged_prior: true
  require_main_synced: true
  require_pruned: true
";

    fn git_in(dir: &Path, args: &[&str]) {
        let ok = Command::new("git")
            .args(args)
            .current_dir(dir)
            .output()
            .unwrap()
            .status
            .success();
        assert!(ok, "git {args:?} failed in {dir:?}");
    }

    fn head_sha(dir: &Path) -> String {
        let (_, out) = git_out(dir, &["rev-parse", "HEAD"]).unwrap();
        out.trim().to_string()
    }

    /// A temp Vajra git repo on `main` with one commit and the house CONSTRAINTS.
    fn repo() -> tempfile::TempDir {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        fs::create_dir_all(root.join(".ai")).unwrap();
        fs::create_dir_all(root.join("prompts")).unwrap();
        fs::write(root.join(".ai/CONSTRAINTS.yaml"), CONSTRAINTS).unwrap();
        git_in(root, &["init", "-q", "-b", "main"]);
        git_in(root, &["config", "user.email", "t@t"]);
        git_in(root, &["config", "user.name", "t"]);
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "init"]);
        tmp
    }

    /// Cut `session-NN-x`, land one commit on it, and (optionally) merge it back into main.
    fn session_branch(root: &Path, nn: u32, merge: bool) -> String {
        let name = format!("session-{nn:02}-x");
        git_in(root, &["checkout", "-qb", &name]);
        fs::write(root.join(format!("f{nn}.txt")), "work\n").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", &format!("s{nn} work")]);
        git_in(root, &["checkout", "-q", "main"]);
        if merge {
            git_in(root, &["merge", "-q", "--no-ff", &name, "-m", "merge"]);
        }
        name
    }

    #[test]
    fn contract_defaults_true_on_missing_file_or_section() {
        assert_eq!(
            release_contract(Path::new("/nonexistent/CONSTRAINTS.yaml")),
            ReleaseContract::default()
        );
        let tmp = tempfile::tempdir().unwrap();
        let p = tmp.path().join("c.yaml");
        fs::write(&p, "version: 3\nmaturity: L2\n").unwrap();
        assert_eq!(release_contract(&p), ReleaseContract::default());
    }

    #[test]
    fn contract_reads_recorded_false_keys_scoped_to_release_section() {
        let tmp = tempfile::tempdir().unwrap();
        let p = tmp.path().join("c.yaml");
        // The same key under another section must NOT count (house section scoping).
        fs::write(
            &p,
            "demo:\n  require_pruned: false\n\nrelease:\n  require_main_synced: false\n",
        )
        .unwrap();
        let c = release_contract(&p);
        assert!(c.require_merged_prior);
        assert!(!c.require_main_synced);
        assert!(c.require_pruned, "demo-section key must not leak in");
    }

    #[test]
    fn session_number_parses_refs_and_rejects_non_session_names() {
        assert_eq!(session_number_of("session-41-x"), Some(41));
        assert_eq!(session_number_of("origin/session-07-fix-thing"), Some(7));
        assert_eq!(session_number_of("session-x-y"), None);
        assert_eq!(session_number_of("session-41"), None);
        assert_eq!(session_number_of("main"), None);
    }

    #[test]
    fn ship_state_errs_outside_git_and_without_main() {
        let tmp = tempfile::tempdir().unwrap();
        assert!(derive_ship_state(tmp.path(), 41).is_err());

        let trunk = tempfile::tempdir().unwrap();
        git_in(trunk.path(), &["init", "-q", "-b", "trunk"]);
        git_in(trunk.path(), &["config", "user.email", "t@t"]);
        git_in(trunk.path(), &["config", "user.name", "t"]);
        fs::write(trunk.path().join("a"), "a").unwrap();
        git_in(trunk.path(), &["add", "-A"]);
        git_in(trunk.path(), &["commit", "-qm", "init"]);
        let err = derive_ship_state(trunk.path(), 41).unwrap_err();
        assert!(err.contains("no main"), "got: {err}");
    }

    #[test]
    fn main_falls_back_to_master() {
        let tmp = tempfile::tempdir().unwrap();
        git_in(tmp.path(), &["init", "-q", "-b", "master"]);
        git_in(tmp.path(), &["config", "user.email", "t@t"]);
        git_in(tmp.path(), &["config", "user.name", "t"]);
        fs::write(tmp.path().join("a"), "a").unwrap();
        git_in(tmp.path(), &["add", "-A"]);
        git_in(tmp.path(), &["commit", "-qm", "init"]);
        assert_eq!(main_branch(tmp.path()), Some("master".to_string()));
        let state = derive_ship_state(tmp.path(), 41).unwrap();
        assert_eq!(state.main, "master");
    }

    #[test]
    fn merged_branch_is_merged_and_unmerged_is_not() {
        let tmp = repo();
        let root = tmp.path();
        session_branch(root, 40, true);
        session_branch(root, 41, false);
        let s40 = derive_ship_state(root, 40).unwrap();
        assert_eq!(s40.branch, BranchShip::Merged(vec!["session-40-x".into()]));
        let s41 = derive_ship_state(root, 41).unwrap();
        assert_eq!(
            s41.branch,
            BranchShip::Unmerged(vec!["session-41-x".into()])
        );
    }

    #[test]
    fn sync_states_derive_from_the_local_origin_ref() {
        let tmp = repo();
        let root = tmp.path();
        // No origin ref at all → NoRemote.
        assert_eq!(derive_ship_state(root, 1).unwrap().sync, MainSync::NoRemote);

        // origin/main == main → Synced (update-ref: a local ref write, no network, no remote).
        let tip = head_sha(root);
        git_in(root, &["update-ref", "refs/remotes/origin/main", &tip]);
        assert_eq!(derive_ship_state(root, 1).unwrap().sync, MainSync::Synced);

        // A commit on main not on origin/main → Ahead(1).
        fs::write(root.join("ahead.txt"), "a").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "local-only"]);
        assert_eq!(
            derive_ship_state(root, 1).unwrap().sync,
            MainSync::Ahead(1)
        );

        // origin/main moved past main (exactly what a fetch would record): put two commits on
        // a scratch branch, point origin/main at its tip, park main back at the base → Behind(2).
        let base = format!("{}~1", head_sha(root));
        git_in(root, &["checkout", "-qb", "remote-work"]);
        fs::write(root.join("remote.txt"), "r").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "remote-only"]);
        let remote_tip = head_sha(root);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(root, &["branch", "-qD", "remote-work"]);
        git_in(root, &["update-ref", "refs/remotes/origin/main", &remote_tip]);
        git_in(root, &["reset", "-q", "--hard", &base]);
        assert_eq!(
            derive_ship_state(root, 1).unwrap().sync,
            MainSync::Behind(2)
        );

        // One local-only commit on top of the base while origin holds its two → Diverged(1, 2).
        fs::write(root.join("mine.txt"), "m").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "mine"]);
        assert_eq!(
            derive_ship_state(root, 1).unwrap().sync,
            MainSync::Diverged(1, 2)
        );
    }

    #[test]
    fn unpruned_lists_merged_locals_and_excludes_the_current_branch() {
        let tmp = repo();
        let root = tmp.path();
        let merged = session_branch(root, 40, true);
        session_branch(root, 41, false); // unmerged — never a prune candidate
        let state = derive_ship_state(root, 40).unwrap();
        assert_eq!(state.unpruned, vec![merged.clone()]);

        // Standing ON the merged branch → excluded (its close is the one in flight).
        git_in(root, &["checkout", "-q", &merged]);
        let state = derive_ship_state(root, 40).unwrap();
        assert!(state.unpruned.is_empty());
        git_in(root, &["checkout", "-q", "main"]);

        // Pruned → gone from the list, and ancestry falls back to… nothing (NoBranch).
        git_in(root, &["branch", "-qd", &merged]);
        let state = derive_ship_state(root, 40).unwrap();
        assert!(state.unpruned.is_empty());
        assert_eq!(state.branch, BranchShip::NoBranch);
    }

    #[test]
    fn gate_blocks_unmerged_behind_diverged_and_unpruned_naming_each() {
        let tmp = repo();
        let root = tmp.path();
        session_branch(root, 41, false);
        let v = release_gate(root, 41);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("NOT an ancestor")));

        // Merge it but leave the branch local → the prune reason names it.
        git_in(root, &["merge", "-q", "--no-ff", "session-41-x", "-m", "m"]);
        let v = release_gate(root, 41);
        assert!(v.blocked());
        assert!(v
            .reasons
            .iter()
            .any(|r| r.contains("unpruned") && r.contains("session-41-x")));

        // Prune (the prompt stays as the session's surviving evidence — without it the gate
        // would rightly fail-close on "no evidence" before reaching the sync check).
        fs::write(root.join("prompts/41-task-x.md"), "# S41").unwrap();
        git_in(root, &["branch", "-qd", "session-41-x"]);
        let tip = head_sha(root);
        git_in(root, &["update-ref", "refs/remotes/origin/main", &tip]);
        git_in(root, &["reset", "-q", "--hard", "HEAD~1"]);
        let v = release_gate(root, 41);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("behind origin/main")));
        git_in(root, &["reset", "-q", "--hard", &tip]);

        // All hygiene done and the branch pruned: with the prompt as the surviving evidence the
        // gate is READY — the vacuous-ancestry warning names the pruned state (the dodge).
        let v = release_gate(root, 41);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert!(v.warnings.iter().any(|w| w.contains("pruned")));
    }

    #[test]
    fn gate_blocks_a_session_with_no_evidence_fail_closed() {
        let tmp = repo();
        let v = release_gate(tmp.path(), 39);
        assert!(v.blocked());
        assert!(v
            .reasons
            .iter()
            .any(|r| r.contains("no evidence") && r.contains("cannot evaluate")));
    }

    #[test]
    fn gate_honors_recorded_false_keys() {
        let tmp = repo();
        let root = tmp.path();
        fs::write(
            root.join(".ai/CONSTRAINTS.yaml"),
            "release:\n  require_merged_prior: false\n  require_pruned: false\n",
        )
        .unwrap();
        session_branch(root, 40, true); // merged but unpruned — pruning not required
        session_branch(root, 41, false); // unmerged — merging not required
        let v = release_gate(root, 41);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
    }

    #[test]
    fn find_target_prefers_newest_evidence_and_skips_the_in_flight_branch() {
        let tmp = repo();
        let root = tmp.path();
        session_branch(root, 40, true);
        session_branch(root, 41, true);
        fs::write(root.join("prompts/41-task-x.md"), "# S41").unwrap();
        // Closing 41 from main (or any non-41 branch): the newest evidence ≤ 41 is 41 itself.
        assert_eq!(find_release_target(root, 41), Some(41));
        // Standing ON 41's branch (a GT-closeout shape): 41 is in flight → bind on 40.
        git_in(root, &["checkout", "-q", "session-41-x"]);
        assert_eq!(find_release_target(root, 41), Some(40));
        git_in(root, &["checkout", "-q", "main"]);
        // Evidence above the closing session never binds (42 in flight is not ≤ 41)…
        session_branch(root, 42, false);
        assert_eq!(find_release_target(root, 41), Some(41));
    }

    #[test]
    fn close_gate_on_a_fresh_repo_warns_and_names_the_dodge() {
        let tmp = repo();
        let v = release_gate_for_close(tmp.path(), 1);
        assert!(!v.blocked());
        assert_eq!(v.session, None);
        assert!(v
            .warnings
            .iter()
            .any(|w| w.contains("fresh") && w.contains("self-granted jurisdiction")));
    }

    #[test]
    fn report_surfaces_state_contract_and_honest_limits() {
        let tmp = repo();
        let root = tmp.path();
        session_branch(root, 41, false);
        let report = format_release_report(&release_gate(root, 41));
        assert!(report.contains("ship state for session 41"));
        assert!(report.contains("NOT merged into main"));
        assert!(report.contains("no remote ref known"));
        assert!(report.contains("merged_prior=true"));
        assert!(report.contains("read-only"));
        assert!(report.contains("last fetch"), "got:\n{report}");
        assert!(report.contains("human acts"));
    }
}
