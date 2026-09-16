//! What to do next in this session — the coach's one job (S171).
//!
//! The founder's first-run test found the same thing three times: at the end of a session the
//! agent stopped and asked HIM what to do. No demo until he asked for one; no ranked options and
//! no next prompt until he asked; no specialist ever dispatched, because the host harness says
//! "don't spawn agents unless the user asks" and Vajra's rule lived only in prose. Prose is
//! skippable. So this module DERIVES the session's remaining steps from what is on disk — the
//! same classifiers the gates use — and `vajra next` prints them, with the first unfinished one
//! called out as the next move.
//!
//! It only ever SAYS what is left. Nothing here blocks, writes, or runs a script: a checklist the
//! agent (and the human) can read is the point, and a gate that already exists does the refusing.

use std::path::Path;

use crate::{analyst, stations};

/// One step of the session, and how to finish it.
#[derive(Debug, Clone)]
pub struct Step {
    /// Already done, judged by the same evidence the gates read.
    pub done: bool,
    /// What the step is, in plain words.
    pub what: String,
    /// How to finish it — a command where there is one.
    pub how: String,
}

impl Step {
    fn new(done: bool, what: impl Into<String>, how: impl Into<String>) -> Self {
        Step {
            done,
            what: what.into(),
            how: how.into(),
        }
    }
}

/// The session's steps in the order they happen, each marked done or not.
pub fn steps(root: &Path, session: u32) -> Vec<Step> {
    let nn = format!("{session:02}");
    let report = stations::station_report(root, session);
    let passed = |name: &str| {
        report
            .stations
            .iter()
            .any(|s| s.name == name && s.outcome == stations::Outcome::Passed)
    };
    let tech_lead = report.fleet.governed.iter().any(|r| r == "tech-lead");
    // The options gate passes vacuously when there is no summary at all — an absent summary is
    // not three ranked options, so the step is done only when the file exists AND the gate is happy.
    let options = analyst::options_gate(root, session);
    let options_ready = options.summary_path.is_some() && !options.blocked();
    let next_prompt = prompt_exists(root, session + 1);

    vec![
        Step::new(
            tech_lead,
            "the tech-lead has said which specialists this session needs",
            "dispatch the tech-lead, then record what it said: \
             vajra next --role tech-lead --from <its findings>",
        ),
        Step::new(
            passed("Analyst"),
            "the prompt says what this session is for",
            format!("fill the prompt's `## Delta`, then: vajra next --validate {nn}"),
        ),
        Step::new(
            passed("Architect"),
            "the design is recorded (or the prompt says it needs none)",
            format!(
                "set `design-significant:` and write `## Design` citing a real record, then: \
                 vajra next --check-design {nn}"
            ),
        ),
        Step::new(
            passed("Planner"),
            "every acceptance item is covered by a plan step",
            format!("mark each step `covers: N`, then: vajra next --check-plan {nn}"),
        ),
        Step::new(
            passed("Coder"),
            "each plan step names the commit that landed it",
            "record `step N — done: <sha>` under `## Execution` as the work lands".to_string(),
        ),
        Step::new(
            passed("QA"),
            "the checks run and pass",
            format!("write scripts/verify-session-{nn}.sh and run it — it must exit 0"),
        ),
        Step::new(
            passed("Demo-er"),
            "there is a demo the human can watch",
            format!(
                "copy scripts/demo-session-template.sh to scripts/demo-session-{nn}.sh, fill every \
                 section with live runs, then run it"
            ),
        ),
        Step::new(
            options_ready,
            "the summary ends with exactly 3 ranked options for the next session",
            format!(
                "write sessions/session-{nn}-summary.md with 3 ranked candidates, then: \
                 vajra next --check-options {nn}"
            ),
        ),
        Step::new(
            passed("Reviewer"),
            "an independent review has read the work and said ACCEPT",
            format!(
                "dispatch the fidelity-reviewer on the prompt + the diff, write its verdict to \
                 sessions/session-{nn}-review.md"
            ),
        ),
        Step::new(
            next_prompt,
            "the human has picked an option and the next prompt is written",
            format!(
                "show the 3 options, wait for the pick, then write prompts/{:02}-task-<slug>.md",
                session + 1
            ),
        ),
        Step::new(
            passed("Releaser"),
            "the work is merged and the branch is gone",
            "open the pull request, merge it, prune the branch, then: scripts/verify-closeout.sh"
                .to_string(),
        ),
    ]
}

/// True when a prompt file for `session` exists (`prompts/NN-task-*.md`, padded like everything
/// else Vajra writes).
fn prompt_exists(root: &Path, session: u32) -> bool {
    let dir = root.join("prompts");
    let prefix = format!("{session:02}-task-");
    match std::fs::read_dir(dir) {
        Err(_) => false,
        Ok(entries) => entries.flatten().any(|e| {
            e.file_name()
                .to_str()
                .is_some_and(|n| n.starts_with(&prefix) && n.ends_with(".md"))
        }),
    }
}

/// The checklist as `vajra next` prints it: every step, ✓ or ✗, and the first unfinished one
/// spelled out as the next move. Empty tail when the session is finished.
pub fn format_steps(steps: &[Step], session: u32) -> String {
    let mut out = format!("----- what is left in session {session:02} -----\n");
    for s in steps {
        out.push_str(&format!(
            "  {} {}\n",
            if s.done { "✓" } else { "✗" },
            s.what
        ));
    }
    match steps.iter().find(|s| !s.done) {
        None => out.push_str("  ▶ nothing left — close the session.\n"),
        Some(s) => {
            out.push_str(&format!("\n  ▶ YOUR NEXT STEP: {}\n", s.what));
            out.push_str(&format!("      how: {}\n", s.how));
            out.push_str(
                "  Do it without being asked — this list is the session, not a menu for the human.\n",
            );
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    fn repo() -> TempDir {
        let d = TempDir::new().unwrap();
        fs::create_dir_all(d.path().join("prompts")).unwrap();
        fs::create_dir_all(d.path().join("sessions")).unwrap();
        d
    }

    /// An empty session has every step open, and the first one named is the tech-lead — the
    /// dispatch the founder's test never saw happen (F20).
    #[test]
    fn an_untouched_session_starts_with_the_tech_lead() {
        let d = repo();
        let steps = steps(d.path(), 1);
        let open: Vec<&str> = steps
            .iter()
            .filter(|s| !s.done)
            .map(|s| s.what.as_str())
            .collect();
        let done: Vec<&str> = steps
            .iter()
            .filter(|s| s.done)
            .map(|s| s.what.as_str())
            .collect();
        assert!(
            open.len() >= 8,
            "most steps should be open, open = {open:?}, done = {done:?}"
        );
        assert!(
            done.is_empty(),
            "nothing is done in an untouched session, got {done:?}"
        );
        let text = format_steps(&steps, 1);
        assert!(text.contains("YOUR NEXT STEP: the tech-lead"), "{text}");
        assert!(text.contains("vajra next --role tech-lead"), "{text}");
    }

    /// The checklist names the two things the agent skipped until asked: the demo, and the three
    /// ranked options plus the next prompt (F7, F8, F18, F25).
    #[test]
    fn the_checklist_names_the_demo_the_options_and_the_next_prompt() {
        let d = repo();
        let text = format_steps(&steps(d.path(), 1), 1);
        assert!(text.contains("a demo the human can watch"), "{text}");
        assert!(text.contains("exactly 3 ranked options"), "{text}");
        assert!(text.contains("the next prompt is written"), "{text}");
    }

    /// The next prompt counts as written only when the padded file is really there.
    #[test]
    fn the_next_prompt_step_reads_the_padded_file_name() {
        let d = repo();
        let step = |n| {
            steps(d.path(), n)
                .into_iter()
                .find(|s| s.what.contains("next prompt is written"))
                .unwrap()
                .done
        };
        assert!(!step(1));
        fs::write(d.path().join("prompts/02-task-risk.md"), "# 02").unwrap();
        assert!(step(1));
    }
}
