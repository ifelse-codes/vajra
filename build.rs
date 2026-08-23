// =====================================================================================
// build.rs — ONE SOURCE for what a stranger gets (S129).
//
// For 128 sessions the constitution `vajra init` hands a stranger was a hand-typed fork
// of the one this repo runs on. It drifted to 8 binding rules against 13, and to 7
// ground-truth audits against 11, with no reason on record for a single omission — see
// `sessions/session-129-fork-measurement.md`.
//
// So the scaffold's binding sets are no longer typed. They are DERIVED here, at compile
// time, from the live `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml`, and included into
// `src/cli/init.rs`'s templates.
//
// Three rules govern this file:
//
//   1. THE DEFAULT IS CARRIED. Anything not named in a declaration below reaches every
//      future scaffold verbatim, with no action taken. The failure mode that produced the
//      fork is structurally gone, not merely detected.
//   2. DEVIATION MUST BE DECLARED — `OMIT_RULES` / `OMIT_AUDITS` / `RETEXT_RULES`, each
//      carrying its reason. The reasons are emitted INTO the scaffold, so a stranger can
//      read what was withheld from them and why.
//   3. A STALE DECLARATION FAILS THE BUILD. Declaring an omission or an override for
//      something no longer in the live source panics right here. S128's fakest green was
//      a hand-typed list that measured the boundary its own author drew; a declaration
//      that cannot go stale is the fix for that class.
//
// `scripts/scaffold-drift.sh` is the independent second opinion: it compares the LIVE
// `.ai/` against what a REAL `vajra init` writes into a REAL empty directory, using the
// REAL release binary — never against these constants.
// =====================================================================================

use std::fs;
use std::path::{Path, PathBuf};

// ── The declaration manifest ─────────────────────────────────────────────────────────

/// Binding rules in `.ai/AGENTS.md#Hard Rules` deliberately WITHHELD from a scaffolded
/// project. Empty is the honest state today: the fork's five missing rules were missing
/// by accident, and every one of them is portable.
const OMIT_RULES: &[(&str, &str)] = &[];

/// Rules carried, whose DETAIL column is rewritten for a stranger because the live text
/// cites a record only this repo has. The RULE NAME is never rewritten — the name is the
/// identity the drift check compares on.
///
/// `(rule name, the stranger's detail, why it was rewritten)`. The REASON is not decoration:
/// it is emitted into the stranger's own constitution as `scaffold-retexts-rule:`, and
/// `scripts/scaffold-drift.sh` fails if a rewritten rule arrives without its marker. S129's
/// cold reviewer named this channel unguarded and unlabelled — an author could invert a rule's
/// meaning while the file still said "Declared omissions: none". Now it says what changed.
const RETEXT_RULES: &[(&str, &str, &str)] = &[
    (
        "**Fidelity ≠ discipline**",
        "Following the rules is not delivering what was asked. Map **every** numbered requirement in the prompt to evidence (SHIPPED / PARTIAL / NOT-BUILT). A green verify script proves discipline, never fidelity.",
        "the live detail cites DECISION-002, a decision record only this repo has",
    ),
    (
        "**No self-certification**",
        "The builder does not accept its own delivery. Fidelity is judged by an **independent** pass fed only the prompt + the diff, adversarially — not by the agent that wrote the code. See `reviewer/SKILL.md`.",
        "same DECISION-002 citation, replaced by the pointer to `reviewer/SKILL.md` that the scaffold does ship",
    ),
];

/// Ground-truth audits in `.ai/CONSTRAINTS.yaml` deliberately WITHHELD from a scaffolded
/// project, because their evidence cannot exist there. Registering an audit whose evidence
/// a project cannot produce makes its ground truth fail a check it cannot run — S128
/// refused to do that, and the refusal is now enforced data instead of prose in a prompt.
const OMIT_AUDITS: &[(&str, &str)] = &[
    (
        "stranger_check",
        "its evidence is scripts/stranger-check.sh — Vajra's OWN first-contact harness, which this scaffold does not ship. A stranger's analogue is first contact with THEIR product, which no generic scaffold can script for them.",
    ),
    (
        "scaffold_drift_check",
        "it compares this scaffold against the repo that generates it. A scaffolded project has no scaffold of its own to compare, so the audit has no subject there.",
    ),
];

/// Ground-truth drift AXES in `.ai/CONSTRAINTS.yaml` withheld from a scaffolded project.
/// Empty, and this list exists because of S129's cold review: `drift_axes` was a THIRD
/// hand-typed fork — six entries against seven — sitting three lines above the derived
/// include, in the same `ground_truth:` block this session rewrote. It was invisible to every
/// instrument the session built. A list you did not derive is a list that has already drifted.
const OMIT_AXES: &[(&str, &str)] = &[];

fn main() {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let out = PathBuf::from(std::env::var("OUT_DIR").expect("OUT_DIR"));

    let agents_path = root.join(".ai/AGENTS.md");
    let constraints_path = root.join(".ai/CONSTRAINTS.yaml");

    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=.ai/AGENTS.md");
    println!("cargo:rerun-if-changed=.ai/CONSTRAINTS.yaml");

    // `.ai/` is un-excluded in Cargo.toml precisely so this works from a packaged crate.
    // If it ever gets re-excluded, `cargo install vajractl` breaks HERE, loudly, rather
    // than shipping a scaffold silently derived from nothing.
    let agents = read_or_die(&agents_path);
    let constraints = read_or_die(&constraints_path);

    fs::write(
        out.join("scaffold_hard_rules.md"),
        render_hard_rules(&agents),
    )
    .expect("write scaffold_hard_rules.md");
    fs::write(
        out.join("scaffold_ground_truth.yaml"),
        render_ground_truth(&constraints),
    )
    .expect("write scaffold_ground_truth.yaml");
}

fn read_or_die(p: &Path) -> String {
    fs::read_to_string(p).unwrap_or_else(|e| {
        panic!(
            "vajra build: cannot read the derivation source {} ({e}).\n\
             The scaffold's binding rules are DERIVED from this file (S129). Without it the \n\
             build would have to fall back to a hand-typed copy, which is the exact drift \n\
             this mechanism exists to kill. Check Cargo.toml's `exclude` list.",
            p.display()
        )
    })
}

// ── Parsing the live source ──────────────────────────────────────────────────────────

/// Drop fenced code blocks before looking for anything. S127: a fenced `## Advice` example
/// inside a prompt was read as the real section. Strip fences BEFORE locating a heading.
fn defenced(src: &str) -> Vec<&str> {
    let mut out = Vec::new();
    let mut fenced = false;
    for line in src.lines() {
        if line.trim_start().starts_with("```") {
            fenced = !fenced;
            continue;
        }
        if !fenced {
            out.push(line);
        }
    }
    out
}

/// Every row of `.ai/AGENTS.md`'s `## Hard Rules` table, as (name, detail).
fn parse_hard_rules(agents: &str) -> Vec<(String, String)> {
    let lines = defenced(agents);
    let start = lines
        .iter()
        .position(|l| l.trim() == "## Hard Rules")
        .expect("vajra build: no `## Hard Rules` heading in .ai/AGENTS.md");
    let mut rules = Vec::new();
    for line in &lines[start + 1..] {
        let t = line.trim();
        if t.starts_with("## ") {
            break;
        }
        if !t.starts_with('|') {
            continue;
        }
        let cells: Vec<&str> = t.trim_matches('|').split('|').map(|c| c.trim()).collect();
        if cells.len() < 2 {
            continue;
        }
        if cells[0] == "Rule" || cells[0].starts_with("---") {
            continue;
        }
        rules.push((cells[0].to_string(), cells[1].to_string()));
    }
    if rules.is_empty() {
        panic!("vajra build: `## Hard Rules` in .ai/AGENTS.md has no rows");
    }
    rules
}

/// An inline `key: [a, b, c]` list under `ground_truth`, in declaration order.
fn parse_inline_list(constraints: &str, key: &str) -> Vec<String> {
    let want = format!("{key}:");
    let line = defenced(constraints)
        .into_iter()
        .find(|l| l.trim_start().starts_with(&want))
        .unwrap_or_else(|| panic!("vajra build: no `{key}:` in .ai/CONSTRAINTS.yaml"));
    let inner = line
        .split_once('[')
        .and_then(|(_, r)| r.rsplit_once(']'))
        .map(|(v, _)| v)
        .unwrap_or_else(|| panic!("vajra build: `{key}:` is not an inline [list]"));
    let items: Vec<String> = inner
        .split(',')
        .map(|a| a.trim().to_string())
        .filter(|a| !a.is_empty())
        .collect();
    if items.is_empty() {
        panic!("vajra build: `{key}:` is empty");
    }
    items
}

/// Panic by name when a declaration no longer matches the live source. One function, so every
/// declared list fails the build the same way.
fn assert_declarations_live(kind: &str, decls: &[(&str, &str)], live: &[String]) {
    for (name, _) in decls {
        if !live.iter().any(|l| l == name) {
            panic!(
                "vajra build: STALE DECLARATION — the {kind} declaration names `{name}`, which is \n\
                 no longer in the live .ai/. Remove the declaration or restore the entry."
            );
        }
    }
}

/// Every `  <key>_questions:` block under `ground_truth`, as (key, full block text).
fn parse_question_blocks(constraints: &str) -> Vec<(String, String)> {
    let lines = defenced(constraints);
    let mut blocks: Vec<(String, String)> = Vec::new();
    let mut i = 0;
    while i < lines.len() {
        let line = lines[i];
        let trimmed = line.trim_end();
        let is_head = line.starts_with("  ")
            && !line.starts_with("   ")
            && trimmed.ends_with("_questions:")
            && !trimmed.trim_start().starts_with('#');
        if !is_head {
            i += 1;
            continue;
        }
        let key = trimmed
            .trim()
            .trim_end_matches(':')
            .trim_end_matches("_questions")
            .to_string();
        let mut body = String::from(trimmed);
        body.push('\n');
        i += 1;
        while i < lines.len() && lines[i].starts_with("    ") {
            body.push_str(lines[i].trim_end());
            body.push('\n');
            i += 1;
        }
        blocks.push((key, body));
    }
    blocks
}

/// Which audit owns a `<key>_questions:` block. Exactly one must claim it, or the file has
/// drifted from its own audit list and the build stops.
fn owning_audit(key: &str, audits: &[String]) -> String {
    let candidates: Vec<&String> = audits
        .iter()
        .filter(|a| {
            a.as_str() == key
                || a.as_str() == format!("{key}_check")
                || a.as_str() == format!("{key}_alignment")
                || a.as_str() == format!("{key}_review")
        })
        .collect();
    match candidates.len() {
        1 => candidates[0].clone(),
        0 => panic!(
            "vajra build: `{key}_questions:` in .ai/CONSTRAINTS.yaml belongs to no audit in \n\
             required_audits. Either the audit was removed and its questions were left behind, \n\
             or the block is misnamed. Fix the live file — the scaffold is derived from it."
        ),
        n => panic!(
            "vajra build: `{key}_questions:` is claimed by {n} audits — the naming is ambiguous."
        ),
    }
}

// ── Rendering the scaffold's fragments ───────────────────────────────────────────────

fn render_hard_rules(agents: &str) -> String {
    let rules = parse_hard_rules(agents);
    let names: Vec<&str> = rules.iter().map(|(n, _)| n.as_str()).collect();

    let live_names: Vec<String> = names.iter().map(|n| n.to_string()).collect();
    assert_declarations_live("OMIT_RULES", OMIT_RULES, &live_names);
    let retext_decls: Vec<(&str, &str)> = RETEXT_RULES.iter().map(|(n, _, w)| (*n, *w)).collect();
    assert_declarations_live("RETEXT_RULES", &retext_decls, &live_names);
    for (name, _, why) in RETEXT_RULES {
        if why.trim().is_empty() {
            panic!("vajra build: RETEXT_RULES rewrites `{name}` with no reason. A silent rewrite is the channel this field exists to close.");
        }
    }

    let mut s = String::new();
    s.push_str("| Rule | Detail |\n|---|---|\n");
    let mut carried = 0usize;
    for (name, detail) in &rules {
        if OMIT_RULES.iter().any(|(n, _)| n == name) {
            continue;
        }
        let text = RETEXT_RULES
            .iter()
            .find(|(n, _, _)| n == name)
            .map(|(_, t, _)| *t)
            .unwrap_or(detail.as_str());
        // The scaffold templates substitute `{PLACEHOLDER}` tokens. A brace that arrived
        // from the live constitution would be substituted or left dangling — either way the
        // stranger's file would not say what this repo's says.
        if name.contains('{') || name.contains('}') || text.contains('{') || text.contains('}') {
            panic!(
                "vajra build: hard rule `{name}` carries a brace. The scaffold templates do \n\
                 placeholder substitution, so braces cannot be derived verbatim. Reword the \n\
                 rule in .ai/AGENTS.md, or add a RETEXT_RULES override."
            );
        }
        s.push_str(&format!("| {name} | {text} |\n"));
        carried += 1;
    }
    s.push_str(&format!(
        "\n> **Derived, not typed.** These {carried} rules are generated at build time from\n\
         > Vajra's own constitution, so a rule added there reaches this file with no action\n\
         > taken. `scripts/scaffold-drift.sh` in the Vajra repo fails when the two diverge.\n"
    ));
    if OMIT_RULES.is_empty() {
        s.push_str("> Declared omissions: **none** — every binding rule Vajra runs on is above.\n");
    } else {
        s.push_str("> Declared omissions (withheld on purpose, with the reason):\n");
        for (name, why) in OMIT_RULES {
            s.push_str(&format!("> - scaffold-omits-rule: {name} — {why}\n"));
        }
    }
    if RETEXT_RULES.is_empty() {
        s.push_str(
            "> Reworded details: **none** — every rule above reads exactly as Vajra's own does.\n",
        );
    } else {
        s.push_str("> Reworded details (the rule is unchanged; its wording was rewritten for you, with the reason):\n");
        for (name, _, why) in RETEXT_RULES {
            s.push_str(&format!("> - scaffold-retexts-rule: {name} — {why}\n"));
        }
    }
    s
}

fn render_ground_truth(constraints: &str) -> String {
    let audits = parse_inline_list(constraints, "required_audits");
    let axes = parse_inline_list(constraints, "drift_axes");

    assert_declarations_live("OMIT_AUDITS", OMIT_AUDITS, &audits);
    assert_declarations_live("OMIT_AXES", OMIT_AXES, &axes);

    let carried: Vec<&String> = audits
        .iter()
        .filter(|a| !OMIT_AUDITS.iter().any(|(n, _)| *n == a.as_str()))
        .collect();

    let carried_axes: Vec<&String> = axes
        .iter()
        .filter(|a| !OMIT_AXES.iter().any(|(n, _)| *n == a.as_str()))
        .collect();

    let mut s = String::new();
    s.push_str(&format!(
        "  # DERIVED at build time from Vajra's own .ai/CONSTRAINTS.yaml — {} of {} drift axes.\n",
        carried_axes.len(),
        axes.len()
    ));
    for (name, why) in OMIT_AXES {
        s.push_str(&format!("  # scaffold-omits-axis: {name} — {why}\n"));
    }
    s.push_str(&format!(
        "  drift_axes: [{}]\n",
        carried_axes
            .iter()
            .map(|a| a.as_str())
            .collect::<Vec<_>>()
            .join(", ")
    ));
    s.push_str(&format!(
        "  # DERIVED at build time from Vajra's own .ai/CONSTRAINTS.yaml — {} of {} audits.\n\
         \x20 # Vajra's repo fails `scripts/scaffold-drift.sh` when this list and its own diverge.\n",
        carried.len(),
        audits.len()
    ));
    for (name, why) in OMIT_AUDITS {
        s.push_str(&format!("  # scaffold-omits-audit: {name} — {why}\n"));
    }
    s.push_str(&format!(
        "  required_audits: [{}]\n",
        carried
            .iter()
            .map(|a| a.as_str())
            .collect::<Vec<_>>()
            .join(", ")
    ));

    for (key, body) in parse_question_blocks(constraints) {
        let owner = owning_audit(&key, &audits);
        if OMIT_AUDITS.iter().any(|(n, _)| *n == owner.as_str()) {
            continue;
        }
        s.push_str(&body);
    }
    s
}
