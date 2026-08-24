//! The Obeyed gate (S132) — an `obeyed: <sha>` disposition must be JUDGED TRUE by an independent
//! party, not merely carry a sha that resolves.
//!
//! Not to be confused with `src/obedience/mod.rs` (S48), which measures rail blocks in a
//! transcript. Different thing entirely; named apart on purpose.
//!
//! # The defect this closes, on the real record
//!
//! S127 shipped the disposition contract: every numbered recommendation must be ANSWERED, and the
//! answer's evidence must be existence-real (`src/advice/mod.rs`). Its own session then recorded
//! `- implementation-advisor rec 9 — obeyed: 8cd3bea` against a recommendation that said "delete
//! the `_uses` stub". `8cd3bea` resolves, so the gate scored it ✓ and the session closed READY.
//! The commit's diff carries `fn _uses(_r: &Path)` as an unchanged CONTEXT line. **The sha was
//! real; the claim was false; nothing in the machine could tell the difference.** Only a cold
//! human reader caught it, two sessions later.
//!
//! `--check-advice` proves ANSWERED. This gate proves the answer was TRUE — and, exactly like
//! every marker gate here, it does so by converting a judgement into a **recorded marker a machine
//! can existence-check**, never by pretending a program can read a diff and decide obedience.
//!
//! # The grammar
//!
//! Recorded in a governed handoff's findings body (DECISION-007), by a role that is not the one
//! being graded:
//!
//! ```text
//! obeyed-check implementation-advisor rec 9 — mismatch: 8cd3bea — the commit adds the parser and leaves the `_uses` stub in place
//! obeyed-check plan-advisor rec 2 — implemented: 1a2b3c4 — the step really records `covers:` per criterion
//! obeyed-check session 127 implementation-advisor rec 9 — mismatch: 8cd3bea — graded from a later session
//! ```
//!
//! - `obeyed-check` anchors the line after list/emphasis decoration is stripped (`advice::
//!   strip_decoration`), so the words appearing mid-prose never count — the S127 anchor rule.
//! - An optional `session <NN>` qualifier says WHICH session's disposition is being graded. Absent,
//!   it grades the handoff's own session. This is what lets a later session grade an older one
//!   (and is how the S127 specimen is re-graded on the real record, not on a fixture).
//! - `<role> rec <N>` reuses `advice::split_role_rec` verbatim — one boundary rule, not two.
//! - The verdict word is `implemented:` or `mismatch:`, then **the sha the judge actually looked
//!   at**, then a note.
//!
//! ## Rejected alternatives (recorded, not silently skipped)
//!
//! 1. **A new dispatch scoped only to grading dispositions** (Deliverables option b) — rejected:
//!    it would add a second dispatch shape whose independence has to be re-proved from scratch,
//!    where riding the already-MANDATORY `fidelity-reviewer` handoff (S131) inherits
//!    `dispatch::reverify` unchanged. Recorded in the S132 prompt's `## Design`, Q1.
//! 2. **Folding this into `--check-advice`** — rejected: that gate answers "was every
//!    recommendation ANSWERED?" and a session mid-flight is legitimately answered-but-not-yet
//!    judged. Different question, different evidence source, different blocking message (Q3).
//! 3. **The words `true:` / `false:`** — rejected: they read as booleans about the LINE, not about
//!    the commit. `implemented:` / `mismatch:` say what was checked.
//! 4. **A judgment with no sha** — rejected: a judgment that does not record which commit it read
//!    silently survives an edit to the `obeyed:` sha it graded. That is S131 rec 4's class (a real
//!    dispatch proves a role ran, not that its findings are what got ingested) one level down, and
//!    it costs one token to close (Q4).
//! 5. **Deciding obedience mechanically** (diffing the recommendation text against the commit) —
//!    rejected for the reason `advice` states: that is the judgement this repo refuses to fake.
//!
//! # The honest ceiling
//!
//! This gate proves an INDEPENDENT, provenance-verified judge recorded a verdict against the exact
//! commit the disposition names. It does **not** prove that verdict is correct — a lazy judge that
//! writes `implemented:` without reading the diff passes, exactly as a lazy `refused:` reason
//! passes S127's form floor. What becomes impossible is the silent version: an `obeyed:` that
//! nobody ever looked at, which is precisely how the S127 specimen shipped.

use std::path::Path;

use crate::advice::{self, Disposition};
use crate::fleet::{self, Handoff};

/// The migration threshold (S132 prompt, `## Design` Q2). Sessions **at or after** this number
/// BLOCK on a missing judgment; before it, silence WARNs and the warning names the exemption.
/// The threshold governs SILENCE only — a judgment that EXISTS is binding at any session number,
/// which is what makes the S127 specimen re-gradable on the real historical record.
pub const OBEYED_JUDGMENT_FROM_SESSION: u32 = 132;

/// Named once so the gate, the surface and the summary cannot drift into three different
/// admissions of the same limit (the S127 `DODGE` precedent).
pub const CEILING: &str = "this proves an INDEPENDENT, provenance-verified judge recorded a \
     verdict against the exact commit the disposition names — never that the verdict itself is \
     correct. A judge that writes `implemented:` without reading the diff still passes; what is \
     no longer possible is an `obeyed:` nobody ever looked at";

/// What an independent judge said about one `obeyed:` disposition.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Verdict {
    /// The cited commit really does what the recommendation asked.
    Implemented,
    /// It does not. BLOCKS at any session number.
    Mismatch,
}

impl Verdict {
    pub fn word(&self) -> &'static str {
        match self {
            Verdict::Implemented => "implemented",
            Verdict::Mismatch => "mismatch",
        }
    }
}

/// One `obeyed-check` marker, as recorded — never inferred.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Judgment {
    /// Which session's disposition this grades (the `session NN` qualifier, or the handoff's own).
    pub target_session: u32,
    /// The advisor role whose recommendation is being graded.
    pub advisor_role: String,
    pub number: u32,
    pub verdict: Verdict,
    /// The sha the judge says it read — bound against the disposition's own sha.
    pub sha: String,
    pub note: String,
    /// The role that RECORDED the judgment (the handoff's `role:`), and where.
    pub judge_role: String,
    pub judge_session: u32,
    pub handoff_path: String,
}

impl Judgment {
    pub fn label(&self) -> String {
        format!("{} rec {}", self.advisor_role, self.number)
    }
}

/// How one `obeyed:` disposition stands after the join.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ObeyedState {
    /// A real, admissible judgment says the commit implements the recommendation. PASSES.
    Implemented(Judgment),
    /// A real, admissible judgment says it does not. BLOCKS at any session.
    Mismatch(Judgment),
    /// A judgment exists but is NOT admissible (self-graded, stale sha, empty note, unverifiable
    /// provenance). Carries why. BLOCKS at any session — the threshold exempts silence, never a
    /// claim that looks judged and is not (the S127 `Unreal` precedent).
    Rejected(String),
    /// No judgment names this disposition at all.
    Unjudged,
}

/// One `obeyed:` disposition paired with its judgment state — the unit the gate counts.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ObeyedItem {
    pub label: String,
    /// The sha recorded on the disposition itself.
    pub sha: String,
    /// The recommendation's text when a handoff records it; empty for an orphan disposition.
    pub rec_text: String,
    pub state: ObeyedState,
}

/// The Obeyed gate's decision for session `session`. Same shape as `AdviceVerdict`.
#[derive(Debug, Clone)]
pub struct ObeyedVerdict {
    pub session: u32,
    pub prompt_path: Option<String>,
    pub items: Vec<ObeyedItem>,
    pub reasons: Vec<String>,
    pub warnings: Vec<String>,
}

impl ObeyedVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

// ---------------------------------------------------------------------------
// The pure core — text in, markers out. No fs, no git, no process.
// ---------------------------------------------------------------------------

/// The leading hexadecimal run of a token: what `coder::execution_record` and `advice`'s own
/// evidence check already treat as "a recorded sha", mirrored deliberately so a ref like `HEAD`
/// yields nothing here too.
fn leading_hex(s: &str) -> String {
    s.trim()
        .trim_matches('`')
        .chars()
        .take_while(char::is_ascii_hexdigit)
        .collect()
}

/// Do a judgment's sha and a disposition's sha name the same commit? Abbreviations differ between
/// what an author types and what a judge copies, so the shorter must be a prefix of the longer —
/// and must be long enough to mean anything (git's own floor for an abbreviation).
pub fn same_commit(a: &str, b: &str) -> bool {
    let (a, b) = (a.to_ascii_lowercase(), b.to_ascii_lowercase());
    let (short, long) = if a.len() <= b.len() {
        (&a, &b)
    } else {
        (&b, &a)
    };
    short.len() >= 4 && long.starts_with(short.as_str())
}

/// Parse one `obeyed-check` line. Returns the marker with its target session left as the optional
/// qualifier — the caller supplies the handoff's own session when there is none.
pub fn parse_obeyed_check_line(
    line: &str,
) -> Option<(Option<u32>, String, u32, Verdict, String, String)> {
    let s = advice::strip_decoration(line);
    let lower = s.to_ascii_lowercase();
    let rest = lower.strip_prefix("obeyed-check")?;
    if !rest.starts_with(char::is_whitespace) {
        return None;
    }
    // Back to the original casing, offsets preserved by ASCII lower-casing.
    let mut rest = s[s.len() - rest.len()..].trim_start();

    // Optional `session <NN>` qualifier — which session's disposition is being graded.
    let mut qualifier = None;
    let lower_rest = rest.to_ascii_lowercase();
    if let Some(after) = lower_rest.strip_prefix("session") {
        if after.starts_with(char::is_whitespace) {
            let after = after.trim_start();
            let digits: String = after.chars().take_while(char::is_ascii_digit).collect();
            if !digits.is_empty() {
                qualifier = digits.parse::<u32>().ok();
                let consumed = rest.len() - after.len() + digits.len();
                rest = rest[consumed..].trim_start();
            }
        }
    }

    let (advisor_role, number, tail) = advice::split_role_rec(rest)?;
    let (word, evidence) = tail.split_once(':')?;
    let verdict = match word.trim().to_ascii_lowercase().as_str() {
        "implemented" => Verdict::Implemented,
        "mismatch" => Verdict::Mismatch,
        // Any other word is not a judgment. Failing to parse is safe: the disposition stays
        // unjudged, which is what an invented verdict word deserves.
        _ => return None,
    };
    let sha = leading_hex(evidence);
    if sha.is_empty() {
        return None;
    }
    // Everything after the sha, minus one separator, is the note.
    let after_sha = evidence.trim().trim_start_matches('`');
    let note = after_sha[sha.len()..]
        .trim()
        .trim_start_matches(['—', '–', '-', ':', '`'])
        .trim()
        .to_string();
    Some((qualifier, advisor_role, number, verdict, sha, note))
}

/// Every judgment recorded in one contract-valid handoff, in document order. Fenced blocks are
/// skipped for the S127 reason: fences are where the grammar is SHOWN, and this module's own doc
/// comment shows it.
pub fn judgments_in(handoff: &Handoff) -> Vec<Judgment> {
    let mut out = Vec::new();
    for line in advice::skip_fenced(&handoff.raw_body) {
        if let Some((qualifier, advisor_role, number, verdict, sha, note)) =
            parse_obeyed_check_line(line)
        {
            out.push(Judgment {
                target_session: qualifier.unwrap_or(handoff.session),
                advisor_role,
                number,
                verdict,
                sha,
                note,
                judge_role: handoff.role.clone(),
                judge_session: handoff.session,
                handoff_path: handoff.path.clone(),
            });
        }
    }
    out
}

/// Is a judgment admissible against this disposition? The three refusals are the three ways a
/// recorded judgment can look real and mean nothing.
///
/// `verified` is injected so the whole classifier is unit-testable without a machine's dispatch
/// evidence (the same shape `advice::classify` uses for its evidence check).
pub fn admit(
    j: &Judgment,
    disposition_sha: &str,
    verified: impl Fn(&Judgment) -> Result<(), String>,
) -> Result<(), String> {
    // 1. No self-certification (DECISION-002, applied to a disposition). The advisor that made the
    //    recommendation may never grade the answer to it.
    if j.judge_role.eq_ignore_ascii_case(&j.advisor_role) {
        return Err(format!(
            "{} graded its OWN recommendation ({}) — a judgment must come from an independent \
             role, never the advisor whose advice is being graded (DECISION-002)",
            j.judge_role,
            j.label()
        ));
    }
    // 2. The judgment must name the commit the disposition actually records — otherwise editing
    //    `obeyed:` afterwards silently inherits a verdict about a different commit.
    if !same_commit(&j.sha, disposition_sha) {
        return Err(format!(
            "the judgment reads commit `{}` but the disposition records `{}` — a judgment about a \
             different commit is stale, not evidence",
            j.sha, disposition_sha
        ));
    }
    // 3. A form floor, and disclosed as one (S127's `substantive_reason`, same rule, same limit).
    advice::substantive_reason(&j.note)
        .map_err(|why| format!("the judgment records no usable note: {why}"))?;
    // 4. The judge must be a REAL dispatch, not a hand-typed file (S131's provenance chain).
    verified(j)
}

/// Join `obeyed:` dispositions to judgments and classify each one. Pure.
///
/// Two rules the cold review's rec 5 forced into the open, because "LAST wins" alone was wrong:
///
/// 1. **A `mismatch` is STICKY.** Among the admissible judgments for one disposition, a recorded
///    disagreement wins over any `implemented` verdict, whatever the order. Ordering here comes
///    from filenames, and `session-99-…` sorts after `session-131-…` lexicographically — so
///    "the freshest wins" was a claim the data could not support. Sticky is also the safer rule
///    for a BLOCKING gate, and it costs the author nothing honest: landing the work the
///    recommendation asked for produces a NEW sha, and the old judgment stops being admissible
///    against it the moment `obeyed:` is updated (the sha bind, rule 2 of `admit`).
/// 2. **An inadmissible judgment only speaks when there is no admissible one.** A forged or stale
///    line sitting beside a real judgment is reported, not obeyed; with no real judgment beside
///    it, its refusal reason is what blocks.
pub fn classify(
    dispositions: &[(String, Disposition)],
    rec_text: impl Fn(&str) -> String,
    judgments: &[Judgment],
    verified: impl Fn(&Judgment) -> Result<(), String>,
) -> Vec<ObeyedItem> {
    dispositions
        .iter()
        .filter_map(|(label, d)| match d {
            Disposition::Obeyed(sha) => Some((label, sha)),
            _ => None,
        })
        .map(|(label, sha)| {
            let disposition_sha = leading_hex(sha);
            // rec 8: both sides already lower-case their role through `advice::split_role_rec`,
            // and this comparison says so explicitly rather than relying on that invariant
            // holding forever in two files.
            let mine: Vec<&Judgment> = judgments
                .iter()
                .filter(|j| j.label().eq_ignore_ascii_case(label))
                .collect();
            let mut admitted: Vec<&Judgment> = Vec::new();
            let mut refused: Vec<String> = Vec::new();
            for j in &mine {
                match admit(j, &disposition_sha, &verified) {
                    Ok(()) => admitted.push(j),
                    Err(why) => refused.push(format!("{} — {why}", j.handoff_path)),
                }
            }
            // Stickiness lives in ONE expression, so the falsifiability fixture can neutralise
            // exactly this rule and nothing else (verify-session-132.sh, bypass D).
            let sticky_mismatch = admitted.iter().find(|j| j.verdict == Verdict::Mismatch);
            let chosen = sticky_mismatch.or_else(|| admitted.last());
            let state = match chosen {
                Some(j) => match j.verdict {
                    Verdict::Mismatch => ObeyedState::Mismatch((*j).clone()),
                    Verdict::Implemented => ObeyedState::Implemented((*j).clone()),
                },
                None => match refused.first() {
                    Some(why) => ObeyedState::Rejected(why.clone()),
                    None => ObeyedState::Unjudged,
                },
            };
            ObeyedItem {
                label: label.clone(),
                sha: disposition_sha,
                rec_text: rec_text(label),
                state,
            }
        })
        .collect()
}

// ---------------------------------------------------------------------------
// The impure edges — read the handoffs, re-verify provenance, run the gate.
// ---------------------------------------------------------------------------

/// Every contract-valid handoff in `.ai/handoffs/`, whatever session it belongs to. A judgment may
/// be recorded by a LATER session than the one it grades (the `session NN` qualifier), so this
/// gate cannot use `fleet::read_handoffs`, which is scoped to one session by construction.
///
/// A malformed file is skipped here rather than failing closed: `--check-advice` (S127) and
/// `--check-fidelity-handoff` (S131) already BLOCK on a malformed handoff for the session being
/// closed, so a second, weaker copy of that rule would only duplicate their message — and a
/// malformed handoff from some OTHER session is not this gate's jurisdiction.
pub fn all_handoffs(root: &Path) -> Vec<Handoff> {
    let dir = root.join(".ai/handoffs");
    let Ok(entries) = std::fs::read_dir(&dir) else {
        return Vec::new();
    };
    let paths: Vec<std::path::PathBuf> = entries.flatten().map(|e| e.path()).collect();
    let mut out: Vec<Handoff> = paths
        .iter()
        .filter_map(|path| {
            let name = path.file_name()?.to_str()?;
            let stem = name.strip_suffix(".md")?.strip_prefix("session-")?;
            let (digits, _role) = stem.split_once('-')?;
            let session: u32 = digits.parse().ok()?;
            let text = std::fs::read_to_string(path).ok()?;
            let rel = format!(".ai/handoffs/{name}");
            fleet::parse_handoff(&text, session, &rel).ok()
        })
        .collect();
    // rec 5: sort by session NUMBER, never by filename — `session-99-…` sorts after
    // `session-131-…` as a string, which silently inverted "a later session's judgment".
    out.sort_by(|a, b| (a.session, &a.path).cmp(&(b.session, &b.path)));
    out
}

/// Independently re-verify that the handoff carrying a judgment came from a REAL dispatch of that
/// role for that session (S131's chain, reused whole). A hand-typed handoff can claim any verdict
/// it likes; this is what makes "independent" a checked fact rather than a label.
pub fn verify_judge(root: &Path, j: &Judgment) -> Result<(), String> {
    let handoffs = all_handoffs(root);
    let h = handoffs
        .iter()
        .find(|h| h.path == j.handoff_path)
        .ok_or_else(|| format!("{} could not be re-read", j.handoff_path))?;
    let role = fleet::resolve_role(&h.role)
        .ok_or_else(|| format!("{} names an unregistered role `{}`", h.path, h.role))?;
    let id = crate::dispatch::claimed_tool_use_id(&h.agent).ok_or_else(|| {
        format!(
            "{}'s provenance ({:?}) carries no verifiable dispatch id — a hand-typed judgment is \
             not an independent one",
            h.path, h.agent
        )
    })?;
    crate::dispatch::reverify(root, role.name, h.session, &id).map_err(|why| {
        format!(
            "{}'s provenance could not be independently re-verified: {why}",
            h.path
        )
    })
}

/// The Obeyed gate (S132): every `obeyed:` disposition recorded by `session` must carry an
/// admissible, independent judgment, and that judgment must not say `mismatch`.
pub fn obeyed_gate(root: &Path, session: u32) -> ObeyedVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    // The recommendations, only for their TEXT — the gate binds on dispositions, so an orphan
    // disposition (answering advice no handoff records) is graded too, never skipped.
    let mut rec_texts: Vec<(String, String)> = Vec::new();
    for read in fleet::read_handoffs(root, session) {
        if let fleet::HandoffRead::Found(h) = read {
            for r in advice::recommendations_in(&h) {
                rec_texts.push((r.label(), r.text));
            }
        }
    }

    let prompt_path = crate::analyst::find_prompt_for(root, session);
    let prompt_text = prompt_path
        .as_deref()
        .and_then(|rel| std::fs::read_to_string(root.join(rel)).ok());
    let dispositions = prompt_text
        .as_deref()
        .map(advice::dispositions_in)
        .unwrap_or_default();

    let judgments: Vec<Judgment> = all_handoffs(root)
        .iter()
        .flat_map(judgments_in)
        .filter(|j| j.target_session == session)
        .collect();

    let items = classify(
        &dispositions,
        |label| {
            rec_texts
                .iter()
                .find(|(l, _)| l == label)
                .map(|(_, t)| t.clone())
                .unwrap_or_default()
        },
        &judgments,
        |j| verify_judge(root, j),
    );

    for item in &items {
        match &item.state {
            ObeyedState::Implemented(_) => {}
            ObeyedState::Mismatch(j) => reasons.push(format!(
                "{} — `obeyed: {}` is recorded, and {} judged that commit a MISMATCH: {}. Either \
                 land the work the recommendation asked for and record the new sha, or change the \
                 disposition to `refused: <reason>` — an honest refusal passes, a false `obeyed:` \
                 does not",
                item.label, item.sha, j.judge_role, j.note
            )),
            ObeyedState::Rejected(why) => reasons.push(format!(
                "{} — a judgment is recorded but is not admissible: {why}",
                item.label
            )),
            ObeyedState::Unjudged => {
                if session >= OBEYED_JUDGMENT_FROM_SESSION {
                    reasons.push(format!(
                        "{} — `obeyed: {}` carries no independent judgment. An independent role \
                         (never the advisor, never the builder) must record `obeyed-check {} — \
                         implemented: {} — <what the commit actually does>` in its governed \
                         handoff",
                        item.label, item.sha, item.label, item.sha
                    ));
                } else {
                    warnings.push(format!(
                        "{} — `obeyed: {}` carries no independent judgment (pre-threshold: WARN)",
                        item.label, item.sha
                    ));
                }
            }
        }
    }

    // The exemption, stated ONCE and out loud rather than buried in a constant — the S68/S71
    // self-granted-jurisdiction class, disclosed in the output that relies on it.
    if !warnings.is_empty() {
        warnings.push(format!(
            "session {session:02} predates this gate (threshold: session \
             {OBEYED_JUDGMENT_FROM_SESSION}), so the {} unjudged disposition(s) above WARN instead \
             of blocking. Named, not silently exempt: they were recorded under a contract that had \
             no judgment marker in it, and re-grading every past session is not what this gate was \
             built to do. The exemption is not permanent — any later session may grade one by \
             recording `obeyed-check session {session:02} <role> rec <N> — …` in its own governed \
             handoff",
            warnings.len()
        ));
    }

    ObeyedVerdict {
        session,
        prompt_path,
        items,
        reasons,
        warnings,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn j(label_role: &str, n: u32, v: Verdict, sha: &str, judge: &str) -> Judgment {
        Judgment {
            target_session: 132,
            advisor_role: label_role.into(),
            number: n,
            verdict: v,
            sha: sha.into(),
            note: "the commit really does it".into(),
            judge_role: judge.into(),
            judge_session: 132,
            handoff_path: format!(".ai/handoffs/session-132-{judge}.md"),
        }
    }
    fn ok(_j: &Judgment) -> Result<(), String> {
        Ok(())
    }

    #[test]
    fn parses_the_marker_with_every_part() {
        let (q, role, n, v, sha, note) = parse_obeyed_check_line(
            "- **obeyed-check implementation-advisor rec 9 — mismatch: 8cd3bea — the stub survives**",
        )
        .expect("parses");
        assert_eq!(q, None);
        assert_eq!(role, "implementation-advisor");
        assert_eq!(n, 9);
        assert_eq!(v, Verdict::Mismatch);
        assert_eq!(sha, "8cd3bea");
        assert_eq!(note, "the stub survives");
    }

    #[test]
    fn parses_the_session_qualifier_so_a_later_session_can_grade_an_older_one() {
        let (q, role, n, ..) = parse_obeyed_check_line(
            "obeyed-check session 127 implementation-advisor rec 9 — mismatch: 8cd3bea — x",
        )
        .expect("parses");
        assert_eq!(q, Some(127));
        assert_eq!(role, "implementation-advisor");
        assert_eq!(n, 9);
    }

    #[test]
    fn prose_and_invented_verdict_words_are_not_markers() {
        assert!(
            parse_obeyed_check_line("we ran an obeyed-check on rec 9 and it looked fine").is_none()
        );
        assert!(
            parse_obeyed_check_line("obeyed-check plan-advisor rec 2 — probably: 1a2b3c4 — x")
                .is_none()
        );
        // No sha recorded at all — refuse rather than accept a judgment bound to nothing.
        assert!(parse_obeyed_check_line(
            "obeyed-check plan-advisor rec 2 — implemented: yes it is"
        )
        .is_none());
    }

    // The three admissibility tests below assert BEHAVIOUR (Err-ness plus a matched positive
    // control), never message wording — S122's lesson, hit live by S131: a test bound to the exact
    // text makes "renaming every gate message must stay GREEN" impossible to satisfy honestly.
    // Each case differs from its own control in exactly ONE input, so only one rule can be the
    // reason it fails.
    #[test]
    fn an_advisor_may_not_grade_its_own_recommendation() {
        let mine = j(
            "implementation-advisor",
            9,
            Verdict::Implemented,
            "8cd3bea",
            "implementation-advisor",
        );
        assert!(admit(&mine, "8cd3bea", ok).is_err());
        // Control: the SAME judgment from any other role is admissible — so the refusal above can
        // only be the self-certification rule.
        let theirs = Judgment {
            judge_role: "fidelity-reviewer".into(),
            ..mine
        };
        assert!(admit(&theirs, "8cd3bea", ok).is_ok());
    }

    #[test]
    fn a_judgment_about_a_different_commit_is_stale_not_evidence() {
        let jj = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "deadbee",
            "fidelity-reviewer",
        );
        assert!(admit(&jj, "1a2b3c4", ok).is_err());
        // Control: an ABBREVIATION of the same commit is the same commit.
        assert!(admit(&jj, "deadbeef1234", ok).is_ok());
    }

    #[test]
    fn an_unverifiable_judge_is_refused() {
        let jj = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "1a2b3c4",
            "fidelity-reviewer",
        );
        assert!(admit(&jj, "1a2b3c4", |_| Err("no dispatch evidence".into())).is_err());
        // Control: everything else about this judgment is admissible.
        assert!(admit(&jj, "1a2b3c4", ok).is_ok());
    }

    #[test]
    fn an_empty_or_placeholder_note_is_refused() {
        let base = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "1a2b3c4",
            "fidelity-reviewer",
        );
        for note in ["", "   ", "<what the commit does>"] {
            let jj = Judgment {
                note: note.into(),
                ..base.clone()
            };
            assert!(admit(&jj, "1a2b3c4", ok).is_err(), "note {note:?} admitted");
        }
        assert!(admit(&base, "1a2b3c4", ok).is_ok());
    }

    #[test]
    fn classify_grades_only_obeyed_dispositions() {
        let ds = vec![
            (
                "plan-advisor rec 2".to_string(),
                Disposition::Obeyed("1a2b3c4".into()),
            ),
            (
                "plan-advisor rec 3".to_string(),
                Disposition::Refused("out of scope".into()),
            ),
            (
                "plan-advisor rec 4".to_string(),
                Disposition::Deferred(".ai/ROADMAP.md".into()),
            ),
        ];
        let items = classify(&ds, |_| String::new(), &[], ok);
        assert_eq!(items.len(), 1, "only the obeyed: disposition is graded");
        assert_eq!(items[0].state, ObeyedState::Unjudged);
    }

    #[test]
    fn a_mismatch_verdict_survives_the_join_and_an_implemented_one_passes() {
        let ds = vec![(
            "plan-advisor rec 2".to_string(),
            Disposition::Obeyed("1a2b3c4".into()),
        )];
        let good = classify(
            &ds,
            |_| String::new(),
            &[j(
                "plan-advisor",
                2,
                Verdict::Implemented,
                "1a2b3c4",
                "fidelity-reviewer",
            )],
            ok,
        );
        assert!(matches!(good[0].state, ObeyedState::Implemented(_)));
        let bad = classify(
            &ds,
            |_| String::new(),
            &[j(
                "plan-advisor",
                2,
                Verdict::Mismatch,
                "1a2b3c4",
                "fidelity-reviewer",
            )],
            ok,
        );
        assert!(matches!(bad[0].state, ObeyedState::Mismatch(_)));
    }

    #[test]
    fn a_recorded_mismatch_is_sticky_whatever_the_order() {
        let ds = vec![(
            "plan-advisor rec 2".to_string(),
            Disposition::Obeyed("1a2b3c4".into()),
        )];
        // Both orders, same answer: a disagreement is never cleared by a later `implemented:`
        // about the SAME commit — only landing new work (a new sha) clears it.
        for pair in [
            vec![
                j(
                    "plan-advisor",
                    2,
                    Verdict::Mismatch,
                    "1a2b3c4",
                    "fidelity-reviewer",
                ),
                j(
                    "plan-advisor",
                    2,
                    Verdict::Implemented,
                    "1a2b3c4",
                    "fidelity-reviewer",
                ),
            ],
            vec![
                j(
                    "plan-advisor",
                    2,
                    Verdict::Implemented,
                    "1a2b3c4",
                    "fidelity-reviewer",
                ),
                j(
                    "plan-advisor",
                    2,
                    Verdict::Mismatch,
                    "1a2b3c4",
                    "fidelity-reviewer",
                ),
            ],
        ] {
            let items = classify(&ds, |_| String::new(), &pair, ok);
            assert!(matches!(items[0].state, ObeyedState::Mismatch(_)));
        }
    }

    #[test]
    fn an_inadmissible_judgment_only_speaks_when_no_admissible_one_exists() {
        let ds = vec![(
            "plan-advisor rec 2".to_string(),
            Disposition::Obeyed("1a2b3c4".into()),
        )];
        let forged = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "1a2b3c4",
            "plan-advisor",
        );
        let real = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "1a2b3c4",
            "fidelity-reviewer",
        );
        assert!(matches!(
            classify(&ds, |_| String::new(), std::slice::from_ref(&forged), ok)[0].state,
            ObeyedState::Rejected(_)
        ));
        assert!(matches!(
            classify(&ds, |_| String::new(), &[forged, real], ok)[0].state,
            ObeyedState::Implemented(_)
        ));
    }

    #[test]
    fn a_judgment_joins_its_disposition_regardless_of_case() {
        let ds = vec![(
            "plan-advisor rec 2".to_string(),
            Disposition::Obeyed("1a2b3c4".into()),
        )];
        let mut mixed = j(
            "plan-advisor",
            2,
            Verdict::Implemented,
            "1a2b3c4",
            "fidelity-reviewer",
        );
        mixed.advisor_role = "Plan-Advisor".into();
        let items = classify(&ds, |_| String::new(), &[mixed], ok);
        assert!(
            matches!(items[0].state, ObeyedState::Implemented(_)),
            "a mixed-case judgment must not read as UNJUDGED"
        );
    }

    #[test]
    fn same_commit_needs_a_real_abbreviation() {
        assert!(same_commit("8cd3bea", "8cd3beac71d2"));
        assert!(
            !same_commit("8cd", "8cd3beac71d2"),
            "3 hex chars is not an abbreviation"
        );
        assert!(!same_commit("8cd3bea", "1a2b3c4"));
    }
}
