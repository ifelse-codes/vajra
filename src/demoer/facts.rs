//! Demo facts (S168, DECISION-010) — the numbers a demo must never type by hand.
//!
//! S167's cold review named the fakest green of the terminal demo: number tiles were free text, so
//! a demo could print `STATIONS 8 of 8` whatever the truth was. This module derives the session's
//! facts from what Vajra already knows — the payload counter (`stations::station_report`), the
//! review verdict, the Advice gate's answered recommendations, and the fleet's governed handoffs —
//! and prints them in ONE closed, stable `key=value` form.
//!
//! Two callers, one function, so they cannot drift apart:
//!   - `vajra next --demo-facts NN` — the kit's `dk_vajra_tiles` / `dk_vajra_scorecard` draw these and
//!     print one `demo:fact key=value` line per fact;
//!   - the Demo-er gate — re-derives them right after the live re-run and compares every
//!     `demo:fact` line exactly (`check_facts`).
//!
//! Read-only by construction: every source here reads files and git refs; NOTHING runs a verify or
//! demo script (the QA and Demo-er stations are read statically). A demo calling `--demo-facts`
//! during its own gate re-run therefore cannot recurse — `demo_facts_never_runs_a_script` proves it.

use std::collections::HashMap;
use std::fs;
use std::path::Path;

use crate::{advice, stations};

/// The closed key list, in the documented stable order. A `demo:fact` with any other key BLOCKS.
pub const FACT_KEYS: &[&str] = &[
    "session",
    "stations_passed",
    "stations_total",
    "stations_names",
    "review",
    "recs_answered",
    "recs_total",
    "crew_handoffs",
    "crew_roles",
];

/// Session `session`'s facts, one `(key, value)` per `FACT_KEYS` entry, in that order. An absent
/// fact is `none` (words) or `0` (counts) — never omitted, so both sides print the same thing.
pub fn demo_facts(root: &Path, session: u32) -> Vec<(String, String)> {
    let report = stations::station_report(root, session);
    let passed: Vec<&str> = report
        .stations
        .iter()
        .filter(|s| s.outcome == stations::Outcome::Passed)
        .map(|s| s.name)
        .collect();
    let review =
        match fs::read_to_string(root.join(format!("sessions/session-{session:02}-review.md"))) {
            Err(_) => "none",
            Ok(text) => match stations::review_verdict_accept(&text) {
                Some(true) => "ACCEPT",
                Some(false) => "REJECT",
                None => "none",
            },
        };
    let adv = advice::advice_gate(root, session);
    let answered = adv.items.iter().filter(|i| i.answer.is_answered()).count();
    let crew = &report.fleet.governed;
    let list = |v: &[&str]| {
        if v.is_empty() {
            "none".to_string()
        } else {
            v.join(",")
        }
    };
    let crew_names: Vec<&str> = crew.iter().map(String::as_str).collect();
    let values = [
        session.to_string(),
        passed.len().to_string(),
        report.stations.len().to_string(),
        list(&passed),
        review.to_string(),
        answered.to_string(),
        adv.items.len().to_string(),
        crew.len().to_string(),
        list(&crew_names),
    ];
    FACT_KEYS
        .iter()
        .zip(values)
        .map(|(k, v)| (k.to_string(), v))
        .collect()
}

/// The `--demo-facts` surface: one `key=value` per line, in `FACT_KEYS` order.
pub fn format_demo_facts(facts: &[(String, String)]) -> String {
    facts.iter().map(|(k, v)| format!("{k}={v}\n")).collect()
}

/// Remove ANSI CSI escape sequences (`ESC [ … final-byte`). The kit dims marker lines when color is
/// forced into a pipe; an exact value match must not see those bytes.
pub fn strip_ansi(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut chars = s.chars().peekable();
    while let Some(c) = chars.next() {
        if c == '\u{1b}' && chars.peek() == Some(&'[') {
            chars.next();
            for f in chars.by_ref() {
                if ('@'..='~').contains(&f) {
                    break;
                }
            }
        } else {
            out.push(c);
        }
    }
    out
}

/// Every `demo:fact key=value` line in a demo's live output, color stripped, in output order.
/// A line with no `=` yields an empty key, which `check_facts` reports as unknown.
pub fn fact_lines(output: &str) -> Vec<(String, String)> {
    strip_ansi(output)
        .lines()
        .filter_map(|l| l.trim().strip_prefix("demo:fact "))
        .map(|rest| match rest.trim().split_once('=') {
            Some((k, v)) => (k.trim().to_string(), v.trim().to_string()),
            None => (String::new(), rest.trim().to_string()),
        })
        .collect()
}

/// Compare a kit-built demo's `demo:fact` lines to the facts Vajra derives (`derive`, injected so
/// the comparison is testable without a repo). Returns blocking reasons — empty means every fact
/// is true and the closing session's full fact set was printed.
///
/// A `session=NN` fact scopes the lines after it, so a cumulative demo may show earlier sessions'
/// facts too; each is checked against that session's derived facts.
pub fn check_facts(
    lines: &[(String, String)],
    closing: u32,
    derive: impl Fn(u32) -> Vec<(String, String)>,
) -> Vec<String> {
    let mut reasons = Vec::new();
    let mut derived: HashMap<u32, HashMap<String, String>> = HashMap::new();
    let mut seen: HashMap<(u32, String), String> = HashMap::new();
    let mut current: Option<u32> = None;
    for (k, v) in lines {
        let scope = if k == "session" {
            match v.parse::<u32>() {
                Ok(n) => {
                    current = Some(n);
                    n
                }
                Err(_) => {
                    reasons.push(format!(
                        "demo:fact session={v} is not a session number — Vajra fills in the facts, \
                         a demo does not type them"
                    ));
                    current = None;
                    continue;
                }
            }
        } else {
            match current {
                Some(n) => n,
                None => {
                    reasons.push(format!(
                        "demo:fact {k}={v} printed before any `session=` fact — print facts with \
                         dk_vajra_tiles / dk_vajra_scorecard, never by hand"
                    ));
                    continue;
                }
            }
        };
        if !FACT_KEYS.contains(&k.as_str()) {
            reasons.push(format!(
                "demo:fact {k}={v} is not a fact Vajra derives (known: {}) — a typed fact",
                FACT_KEYS.join(", ")
            ));
            continue;
        }
        match seen.get(&(scope, k.clone())) {
            Some(prev) if prev == v => continue,
            Some(prev) => {
                reasons.push(format!(
                    "demo:fact {k} for session {scope} printed twice with different values \
                     ({prev} and {v})"
                ));
                continue;
            }
            None => {
                seen.insert((scope, k.clone()), v.clone());
            }
        }
        let truth = derived
            .entry(scope)
            .or_insert_with(|| derive(scope).into_iter().collect());
        let want = truth.get(k).map(String::as_str).unwrap_or("none");
        if want != v {
            reasons.push(format!(
                "demo:fact {k}={v} (session {scope}) but Vajra derives {k}={want} — a typed or \
                 stale fact"
            ));
        }
    }
    let missing: Vec<&str> = FACT_KEYS
        .iter()
        .copied()
        .filter(|k| !seen.contains_key(&(closing, k.to_string())))
        .collect();
    if !missing.is_empty() {
        reasons.push(format!(
            "the demo prints no demo:fact for session {closing}'s {} — a kit-built demo must show \
             every fact Vajra fills in (dk_vajra_tiles {closing} or dk_vajra_scorecard {closing})",
            missing.join(", ")
        ));
    }
    reasons
}

#[cfg(test)]
mod tests {
    use super::*;

    fn facts(pairs: &[(&str, &str)]) -> Vec<(String, String)> {
        pairs
            .iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect()
    }

    fn truth(session: u32) -> Vec<(String, String)> {
        let s = session.to_string();
        facts(&[
            ("session", &s),
            ("stations_passed", "5"),
            ("stations_total", "8"),
            ("stations_names", "Analyst,Architect,Planner,Coder,QA"),
            ("review", "none"),
            ("recs_answered", "3"),
            ("recs_total", "4"),
            ("crew_handoffs", "2"),
            ("crew_roles", "tech-lead,design-advisor"),
        ])
    }

    #[test]
    fn demo_facts_prints_every_key_in_order_even_when_nothing_is_known() {
        let tmp = tempfile::tempdir().unwrap();
        let f = demo_facts(tmp.path(), 42);
        let keys: Vec<&str> = f.iter().map(|(k, _)| k.as_str()).collect();
        assert_eq!(keys, FACT_KEYS);
        let text = format_demo_facts(&f);
        for want in [
            "session=42\n",
            "stations_passed=0\n",
            "stations_total=8\n",
            "stations_names=none\n",
            "review=none\n",
            "recs_answered=0\n",
            "recs_total=0\n",
            "crew_handoffs=0\n",
            "crew_roles=none\n",
        ] {
            assert!(text.contains(want), "missing {want:?} in:\n{text}");
        }
    }

    /// The recursion guard: a demo calls `--demo-facts` during its own gate re-run, so deriving the
    /// facts must never execute the session's verify or demo script.
    #[test]
    fn demo_facts_never_runs_a_script() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::create_dir_all(root.join("sessions")).unwrap();
        for s in ["verify", "demo"] {
            fs::write(
                root.join(format!("scripts/{s}-session-42.sh")),
                format!("touch '{}/ran-{s}'\n", root.display()),
            )
            .unwrap();
        }
        fs::write(
            root.join("sessions/session-42-review.md"),
            "# review\n**Verdict:** REJECT\n",
        )
        .unwrap();
        let f = demo_facts(root, 42);
        assert!(
            !root.join("ran-verify").exists(),
            "--demo-facts ran the verify script"
        );
        assert!(
            !root.join("ran-demo").exists(),
            "--demo-facts ran the demo script"
        );
        assert!(f.contains(&("review".to_string(), "REJECT".to_string())));
        // The scripts ARE seen (statically): QA and Demo-er read them without running them.
        let names = &f.iter().find(|(k, _)| k == "stations_names").unwrap().1;
        assert!(names.contains("QA"), "QA should pass statically: {names}");
    }

    #[test]
    fn honest_facts_pass_and_ansi_is_stripped() {
        let out = format!(
            "slide\n{}\n\u{1b}[2mdemo:fact review=none\u{1b}[0m\n",
            truth(168)
                .iter()
                .map(|(k, v)| format!("demo:fact {k}={v}"))
                .collect::<Vec<_>>()
                .join("\n")
        );
        let lines = fact_lines(&out);
        assert_eq!(lines.len(), 10);
        assert_eq!(check_facts(&lines, 168, truth), Vec::<String>::new());
    }

    #[test]
    fn a_typed_fact_blocks_naming_the_mismatch() {
        let mut lines = truth(168);
        lines[1].1 = "8".to_string();
        let r = check_facts(&lines, 168, truth);
        assert_eq!(r.len(), 1, "{r:?}");
        assert!(r[0].contains("stations_passed=8") && r[0].contains("stations_passed=5"));
    }

    #[test]
    fn unknown_keys_scope_errors_duplicates_and_missing_facts_block() {
        // No session= first, an unknown key, and nothing for the closing session.
        let r = check_facts(&facts(&[("stations_passed", "5")]), 168, truth);
        assert!(
            r.iter().any(|x| x.contains("before any `session=`")),
            "{r:?}"
        );
        assert!(r.iter().any(|x| x.contains("prints no demo:fact")), "{r:?}");

        let mut lines = truth(168);
        lines.push(("stars".into(), "9000".into()));
        lines.push(("recs_answered".into(), "4".into()));
        let r = check_facts(&lines, 168, truth);
        assert!(r
            .iter()
            .any(|x| x.contains("stars=9000") && x.contains("not a fact")));
        assert!(r.iter().any(|x| x.contains("printed twice")));

        // Facts for an earlier session only (cumulative) do not satisfy the closing session.
        let r = check_facts(&truth(167), 168, truth);
        assert!(r.iter().any(|x| x.contains("session 168")), "{r:?}");
        assert_eq!(r.len(), 1, "167's own facts are true: {r:?}");

        // A malformed line (no `=`) is an unknown key, never silently ignored.
        assert_eq!(fact_lines("demo:fact garbage\n"), facts(&[("", "garbage")]));
    }
}
