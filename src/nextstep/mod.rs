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

use crate::{advice, analyst, releaser, stations};

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
    // S173 F46: once the close is merged, the attested hash can no longer be rebuilt from the diff
    // (the branch is gone into main), so the Reviewer station reads ABSENT forever and rudra's boot
    // told the agent to redo session 03's ACCEPTed review. A merged session is reported on, never
    // re-graded (S172, F39): after the merge, an ACCEPT verdict on file is enough for this list.
    let accepted = std::fs::read_to_string(root.join(format!("sessions/session-{nn}-review.md")))
        .ok()
        .and_then(|t| stations::review_verdict_accept(&t))
        == Some(true);
    let stamped =
        passed("Reviewer") || (releaser::shipped_close(root, session).is_some() && accepted);
    // S173 F54: nothing on this list said the advisors' recommendations need an answer, so rudra
    // met all 38 at the close check — and failed it twice on format.
    // Only once the review exists: its recommendations are the last to arrive, and with no
    // handoffs at all the gate passes vacuously.
    let answered = (accepted || stamped) && !advice::advice_gate(root, session).blocked();
    // S172 F37: the counter in `.ai/SESSION` only moves on `--advance`, and nothing said when.
    let counter_moved = std::fs::read_to_string(root.join(".ai/SESSION"))
        .ok()
        .and_then(|s| s.trim().parse::<u32>().ok())
        .is_some_and(|n| n >= session);

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
            counter_moved,
            "the session number in .ai/SESSION says this session",
            "once the prompt, design and plan above are done, and the human has OK'd the plan: \
             vajra next --advance \
             (it checks them and moves the number; the previous session, if already merged, is \
             only reported on)"
                .to_string(),
        ),
        Step::new(
            passed("Coder"),
            "each plan step names the commit that landed it",
            "right after each step's commit, add `step N — done: <sha>` under the prompt's \
             `## Execution` — the close check refuses a plan step without one"
                .to_string(),
        ),
        Step::new(
            passed("QA"),
            "the checks run and pass",
            format!("write scripts/verify-session-{nn}.sh and run it — it must exit 0"),
        ),
        Step::new(
            passed("Demo-er"),
            "a demo script exists and draws every required section",
            format!(
                "copy scripts/demo-session-template.sh to scripts/demo-session-{nn}.sh, fill every \
                 section with live runs — then run it in front of them: bash \
                 scripts/demo-session-{nn}.sh"
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
            accepted || stamped,
            "an independent review has read the work and said ACCEPT",
            format!(
                "dispatch the fidelity-reviewer on the prompt + the diff, write its verdict to \
                 sessions/session-{nn}-review.md (leave its stamp for the last step)"
            ),
        ),
        Step::new(
            next_prompt,
            "the next session's prompt exists (write it from the human's pick)",
            format!(
                "print the three candidates from the summary in the chat, ask which one, then \
                 write prompts/{:02}-task-<slug>.md from the pick",
                session + 1
            ),
        ),
        Step::new(
            answered,
            "every advisor recommendation has an answer in the prompt's `## Advice`",
            format!(
                "one line per rec, exactly: `- <role> rec N — obeyed: <sha>` (a real commit) / \
                 `refused: <reason>` / `deferred: <path>` (an existing file, bare path). \
                 Check: vajra next --advice {nn}"
            ),
        ),
        // S173 F53: the stamp hashes the prompt AND every committed handoff, so each later
        // `## Advice` line or handoff moved it — rudra re-stamped four times. Say LAST, up front.
        Step::new(
            stamped,
            "the review's stamp matches the finished work (do this LAST)",
            format!(
                "after `## Advice`, `## Execution` and every handoff are committed: \
                 bash scripts/verify-closeout.sh --inputs-sha {nn} — paste it into the review as \
                 `**Review-Inputs-SHA:** <hash>`. Any later prompt edit or commit outside \
                 sessions/ and prompts/ moves it"
            ),
        ),
        Step::new(
            passed("Releaser"),
            "the work is merged and the branch is gone",
            "run scripts/verify-closeout.sh ON THE BRANCH first — since S172 nothing re-checks \
             it after the merge — then push the branch and open the pull request yourself when the \
             launch gave VAJRA_ALLOW_COMMIT=NN (S173), ask the human to merge it, then prune the \
             branch. If main has commits GitHub lacks, `vajra next --release NN` names them — tell \
             the human which ones (e.g. a Vajra sync); only the human pushes main"
                .replace("NN", &nn),
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
        None => {
            out.push_str("  ▶ nothing left — close the session.\n");
            // S171 pass-2 cold review rec 5: the caveat belongs here MOST of all — an all-✓ list
            // is exactly when someone reads it as "the human saw everything".
            out.push_str(
                "  ✓ means the file is there — never that the human watched the demo or picked.\n",
            );
        }
        Some(s) => {
            out.push_str(&format!("\n  ▶ YOUR NEXT STEP: {}\n", s.what));
            out.push_str(&format!("      how: {}\n", s.how));
            out.push_str(
                "  Do it without being asked — this list is the session, not a menu for the human.\n",
            );
            // S171 cold review rec 5: every ✓ above is a FILE existing. A demo written and never
            // run, or options written and never shown, still ticks. Say so rather than let the
            // wording imply the human was there.
            out.push_str(
                "  ✓ means the file is there — never that the human watched the demo or picked.\n",
            );
        }
    }
    out
}

/// The three ranked candidates, ready to paste into the chat (S171). The founder's session 02 wrote
/// them into the summary and then told him "next is S03" without ever showing them — so the file
/// had the options and the human never got the choice. `vajra next --steps` prints them whenever
/// they exist and the next prompt has not been written yet.
pub fn format_options(root: &Path, session: u32) -> String {
    // S171 cold review rec 8: printed whenever the three exist. Skipping them once the next prompt
    // was written let an agent suppress the handover simply by writing that prompt first.
    let Some(rel) = analyst::options_gate(root, session).summary_path else {
        return String::new();
    };
    let Ok(text) = std::fs::read_to_string(root.join(&rel)) else {
        return String::new();
    };
    if analyst::count_ranked_options(&text) != 3 {
        return String::new();
    }
    let mut out = String::from("\n----- show these to the human and ask which one -----\n");
    let mut in_section = false;
    for line in text.lines() {
        let trimmed = line.trim_start();
        if trimmed.starts_with('#') {
            in_section = trimmed.to_ascii_lowercase().contains("candidate");
            continue;
        }
        if in_section && !trimmed.is_empty() {
            out.push_str(&format!("  {trimmed}\n"));
        }
    }
    out.push_str(&format!("  (from {rel})\n"));
    if prompt_exists(root, session + 1) {
        out.push_str(&format!(
            "  A prompt for session {:02} is already written — say which of these it came from.\n",
            session + 1
        ));
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
    fn the_session_number_step_is_done_only_once_the_counter_reaches_the_session() {
        // S172 F37: rudra booted session 03 with `.ai/SESSION` still at 02 and no step said so.
        let d = repo();
        fs::create_dir_all(d.path().join(".ai")).unwrap();
        let step = |root: &std::path::Path| {
            steps(root, 3)
                .into_iter()
                .find(|s| s.what.contains(".ai/SESSION"))
                .expect("the checklist names the session number")
        };
        fs::write(d.path().join(".ai/SESSION"), "02\n").unwrap();
        let s = step(d.path());
        assert!(!s.done);
        assert!(s.how.contains("vajra next --advance"), "{}", s.how);
        fs::write(d.path().join(".ai/SESSION"), "03\n").unwrap();
        assert!(step(d.path()).done);
    }

    /// S173 F46: rudra's boot said "dispatch the fidelity-reviewer" for session 03 — merged, with
    /// an ACCEPT on file — because the attested hash cannot be rebuilt after the merge.
    #[test]
    fn a_merged_session_with_an_accept_on_file_is_not_sent_back_for_review() {
        let d = repo();
        let root = d.path();
        let git = |args: &[&str]| {
            let ok = std::process::Command::new("git")
                .args([
                    "-c",
                    "user.name=t",
                    "-c",
                    "user.email=t@t",
                    "-c",
                    "commit.gpgsign=false",
                ])
                .args(args)
                .current_dir(root)
                .output()
                .unwrap()
                .status
                .success();
            assert!(ok, "git {args:?}");
        };
        let review_step = || {
            steps(root, 3)
                .into_iter()
                .find(|s| s.what.contains("stamp"))
                .unwrap()
        };
        git(&["init", "-q", "-b", "main"]);
        fs::write(
            root.join("sessions/session-03-review.md"),
            "**Verdict:** ACCEPT\n",
        )
        .unwrap();
        assert!(
            !review_step().done,
            "not merged yet: the attested gate still decides"
        );

        fs::write(root.join("sessions/session-03-summary.md"), "# S03\n").unwrap();
        git(&["add", "-A"]);
        git(&["commit", "-qm", "s03 close"]);
        assert!(
            review_step().done,
            "merged with an ACCEPT on file: not re-graded"
        );

        fs::write(
            root.join("sessions/session-03-review.md"),
            "**Verdict:** REJECT\n",
        )
        .unwrap();
        assert!(!review_step().done, "a REJECT is never read as done");
    }

    /// S173 F53/F54: rudra met 38 unanswered recs and a stamp that moved four times only at the
    /// close check. The list now names both, with the exact format, and the stamp comes LAST.
    #[test]
    fn advice_and_the_stamp_are_steps_and_the_stamp_is_last_before_merge() {
        let d = repo();
        let steps = steps(d.path(), 1);
        let pos = |needle: &str| steps.iter().position(|s| s.what.contains(needle)).unwrap();
        let advice = &steps[pos("advisor recommendation")];
        assert!(advice.how.contains("obeyed: <sha>"), "{}", advice.how);
        assert!(advice.how.contains("deferred: <path>"), "{}", advice.how);
        let stamp = &steps[pos("stamp")];
        assert!(stamp.what.contains("LAST"), "{}", stamp.what);
        assert!(stamp.how.contains("--inputs-sha 01"), "{}", stamp.how);
        assert!(pos("advisor recommendation") < pos("stamp"));
        assert!(pos("next session's prompt") < pos("stamp"));
        assert_eq!(
            pos("stamp") + 1,
            pos("merged"),
            "only the merge comes after the stamp"
        );
    }

    #[test]
    fn the_checklist_names_the_demo_the_options_and_the_next_prompt() {
        let d = repo();
        let text = format_steps(&steps(d.path(), 1), 1);
        assert!(text.contains("a demo script exists"), "{text}");
        assert!(text.contains("exactly 3 ranked options"), "{text}");
        assert!(text.contains("next session's prompt exists"), "{text}");
        // S171 cold review rec 5: the list must not imply the human was in the room.
        assert!(text.contains("never that the human watched"), "{text}");
    }

    /// S171 pass-3 cold review rec 3: the handover the agent cannot suppress. Three candidates are
    /// printed whenever they exist — including after the next prompt is written, which is how an
    /// agent used to skip showing them (pass-1 rec 8).
    #[test]
    fn the_three_candidates_are_printed_and_cannot_be_suppressed() {
        let d = repo();
        let summary = d.path().join("sessions/session-01-summary.md");

        // Nothing to show yet.
        assert_eq!(format_options(d.path(), 1), "");

        // Two is not a handover.
        fs::write(&summary, "# S\n## candidates\n1. one\n2. two\n").unwrap();
        assert_eq!(format_options(d.path(), 1), "");

        fs::write(&summary, "# S\n## candidates\n1. one\n2. two\n3. three\n").unwrap();
        let shown = format_options(d.path(), 1);
        assert!(shown.contains("show these to the human"), "{shown}");
        assert!(shown.contains("3. three"), "{shown}");

        // Writing the next prompt first must NOT hide them.
        fs::write(d.path().join("prompts/02-task-next.md"), "# 02").unwrap();
        let still = format_options(d.path(), 1);
        assert!(still.contains("3. three"), "{still}");
        assert!(still.contains("already written"), "{still}");
    }

    /// The next prompt counts as written only when the padded file is really there.
    #[test]
    fn the_next_prompt_step_reads_the_padded_file_name() {
        let d = repo();
        let step = |n| {
            steps(d.path(), n)
                .into_iter()
                .find(|s| s.what.contains("next session's prompt exists"))
                .unwrap()
                .done
        };
        assert!(!step(1));
        fs::write(d.path().join("prompts/02-task-risk.md"), "# 02").unwrap();
        assert!(step(1));
    }
}
