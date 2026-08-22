//! The Advice gate (S127) — every recommendation you asked for must be ANSWERED.
//!
//! S126 completed the fleet roster: nine roles, one per station. S125 established, and S126's own
//! record proved twice over, that **no gate consumes a handoff** — the `demo-producer` said to show
//! the verify-121 unpin in the before/after and the shipped demo showed only the roster; the
//! `design-advisor` found a locked deferral that had to be lifted and that finding never reached
//! the first draft of the next prompt. Neither was defiance. **Neither left a trace.**
//!
//! The defect is not disobedience — it is INVISIBLE disobedience.
//!
//! # What a machine can and cannot decide
//!
//! "Did the session follow this paragraph of advice?" is a judgement, and any gate claiming to
//! decide it is a fake green. What Vajra does instead — five times now — is convert a judgement
//! into a **recorded marker a machine can check**: `covers: N` (S64), `design-significant: yes` +
//! a spine record that EXISTS (S67), `step N — done: <sha>` + `git cat-file -e` (S68), a
//! `demo:<element>` marker in LIVE output (S71). This module adds the sixth: a **disposition**.
//!
//! ```text
//! advice given (numbered by the advisor)  →  a disposition recorded per item  →  gate checks all answered
//! ```
//!
//! **It does not force obedience and must never be sold as if it did.** It forces an ANSWER. A
//! refusal with a written reason is honest disobedience and PASSES — that is correct and intended.
//! What becomes impossible is the silent version, which is the one that actually cost S126 twice.
//!
//! # The grammar (step 1 — decided before anything downstream parses it)
//!
//! ## A recommendation, in a governed handoff body
//!
//! ```text
//! rec 2 — show the verify-121 unpin in the before/after, or the demo shows only the after
//! ```
//!
//! Anchored at line start after stripping leading list markers (`-`, `*`, `+`, `N.`) and emphasis
//! wrappers (`**`, `__`, `*`, `_`): the literal token `rec` (case-insensitive), whitespace, a
//! decimal number, one separator from `—` / `–` / `-` / `:`, then non-empty text. `rec` appearing
//! mid-sentence in prose never counts — the anchor is the whole point.
//!
//! ## A disposition, in the session prompt's own `## Advice` section
//!
//! ```text
//! - design-advisor rec 1 — obeyed: a1b2c3d
//! - demo-producer  rec 1 — deferred: prompts/128-task-next.md
//! - plan-advisor   rec 3 — refused: out of scope; this session ships one story and rec 3 is a second
//! ```
//!
//! Role key first (role keys never contain the token `rec`, so the first ` rec <N>` boundary splits
//! it cleanly), then the same separator set, then exactly one of three disposition words.
//!
//! ## Rejected alternatives (recorded, not silently skipped)
//!
//! 1. **`REC-N:` upper-case only** — rejected: fights the roles' prose voice and invites case drift
//!    across nine independently-written system prompts.
//! 2. **A YAML list of recommendations in the handoff frontmatter** — rejected: Vajra owns the
//!    frontmatter (`fleet::format_handoff`); DECISION-007 forbids the role authoring it.
//! 3. **Numbering by the ordinal position of `##` headings** — rejected: implicit numbering silently
//!    re-maps every recorded disposition the moment a heading is inserted.
//! 4. **A new `.ai/advice/` store, or an `advice.md` artifact** — rejected: `.ai/` and `prompts/`
//!    ARE the memory; the disposition lives in the session's own prompt for exactly the reason the
//!    `## Execution` trace does (S68), and the Analyst refused a `spec.md` for the same reason.
//! 5. **Detecting "I recommend…" in free text** — rejected: that is the judgement this module is
//!    built to refuse to fake.
//! 6. **The disposition words `done` / `wontfix` / `later`** — rejected: `done:` collides with the
//!    Coder's own marker, and the other two are issue-tracker jargon. `obeyed` / `refused` /
//!    `deferred` say exactly what happened, in the founder's own framing.
//!
//! # The floor, stated here and repeated in the summary
//!
//! This gate proves every recommendation was **ANSWERED**, and that the answer's evidence is REAL
//! (the sha resolves, the reason is a sentence, the deferral target exists). It does **not** prove
//! the answer was good — that an `obeyed:` commit really implements the advice, or that a
//! `refused:` reason is sound, stays a judgement only an independent reader can make.
//! **Required ≠ obeyed; answered ≠ obeyed well.**

use std::fs;
use std::path::Path;

/// One numbered recommendation, read out of a governed handoff body. Never inferred — a
/// recommendation exists only because an advisor recorded the marker.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Recommendation {
    /// The role key that produced it, taken from the handoff's `role:` frontmatter (not guessed).
    pub role: String,
    /// The advisor's own number for this item.
    pub number: u32,
    /// The recommendation's one-line text, for the `--advice` surface.
    pub text: String,
    /// Repo-relative path of the handoff it came from — a block must always name its source.
    pub handoff_path: String,
}

impl Recommendation {
    /// The stable label a gate message and a disposition line both use: `<role> rec <N>`.
    pub fn label(&self) -> String {
        format!("{} rec {}", self.role, self.number)
    }
}

/// What a session DID with one recommendation, as recorded in its prompt's `## Advice` section.
/// Each variant carries the evidence token the gate must existence-check.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Disposition {
    /// `obeyed: <sha>` — the commit that carries it. Existence-gated by `git cat-file -e` (S68).
    Obeyed(String),
    /// `refused: <reason>` — honest disobedience. Substantiveness-gated (S61 Delta).
    Refused(String),
    /// `deferred: <path>` — filed somewhere real. Existence-gated (S67 spine records).
    Deferred(String),
}

impl Disposition {
    /// The disposition word as recorded — used in the surface and in gate messages.
    pub fn word(&self) -> &'static str {
        match self {
            Disposition::Obeyed(_) => "obeyed",
            Disposition::Refused(_) => "refused",
            Disposition::Deferred(_) => "deferred",
        }
    }

    /// The recorded evidence token (sha / reason / path).
    pub fn evidence(&self) -> &str {
        match self {
            Disposition::Obeyed(s) | Disposition::Refused(s) | Disposition::Deferred(s) => s,
        }
    }
}

/// How one recommendation was answered. `Unreal` is deliberately distinct from `Missing`: a
/// made-up sha, a `<placeholder>` reason, or a deferral to a file that does not exist is a claim
/// that LOOKS answered, which is a worse failure than an honest blank — but both BLOCK.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Answer {
    /// No line in `## Advice` names this recommendation.
    Missing,
    /// A disposition is recorded but its evidence is not real. Carries the disposition and why.
    Unreal(Disposition, String),
    /// A disposition is recorded and its evidence checks out.
    Answered(Disposition),
}

impl Answer {
    /// Only a real, evidence-checked disposition counts as answered.
    pub fn is_answered(&self) -> bool {
        matches!(self, Answer::Answered(_))
    }
}

/// One recommendation paired with what the session did about it — the unit the surface prints and
/// the gate counts.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AdviceItem {
    pub rec: Recommendation,
    pub answer: Answer,
}

/// The classified advice state of a session. Mirrors `coder::ExecState`: absence is
/// legacy-compatible and silent, a contract breach fails closed, and only a real, unanswered
/// recommendation BLOCKS.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AdviceState {
    /// No governed handoff for this session at all — most sessions, and every session before
    /// S109. Silent, exactly as before this gate existed.
    NoHandoffs,
    /// Handoffs exist but record ZERO numbered recommendations. WARN, and the gate NAMES the
    /// dodge in plain words: deleting the numbers dodges this gate. (The self-granted-jurisdiction
    /// class, S68/S71 — disclosed, never papered over.) Carries the role keys.
    NoRecommendations(Vec<String>),
    /// Recommendations exist that are unanswered, or answered with evidence that is not real.
    /// BLOCKS. Carries each item's `<role> rec <N>` label.
    Unanswered(Vec<String>),
    /// Every recorded recommendation carries a disposition whose evidence is real. Passes.
    Answered,
}

impl AdviceState {
    /// A blocking state refuses the close at L2/L3.
    pub fn blocks(&self) -> bool {
        matches!(self, AdviceState::Unanswered(_))
    }
}

/// The Advice gate's decision for CLOSING `session`. Mirrors `coder::ExecVerdict` field for field
/// so the CLI surface and the `--advance` wiring are the same shape as every other station.
#[derive(Debug, Clone)]
pub struct AdviceVerdict {
    pub session: u32,
    /// The prompt found for `session` (repo-relative), if any.
    pub prompt_path: Option<String>,
    /// Every recommendation found, with its answer. Empty when there is nothing to answer.
    pub items: Vec<AdviceItem>,
    /// Disposition lines that name a recommendation no handoff records — surfaced, never silent.
    pub orphans: Vec<String>,
    pub state: AdviceState,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (no handoffs, no numbered recs, missing prompt, orphan lines).
    pub warnings: Vec<String>,
}

impl AdviceVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

// Silence dead-code warnings for the imports the later steps use.
#[allow(dead_code)]
fn _uses(_r: &Path) -> Option<String> {
    fs::read_to_string(_r).ok()
}

// ---------------------------------------------------------------------------
// Step 3 — parse the RECOMMENDATIONS out of a governed handoff. Pure: text in, markers out. No
// fs, no git, no process. The whole grammar lives here so the two sides (advisor writes, session
// answers) can never drift apart.
// ---------------------------------------------------------------------------

/// The separator set, longest first. An em dash is what the roles are told to write; the en dash,
/// hyphen and colon are accepted because nine independently-written agents will produce all four
/// and rejecting three of them would turn a typography slip into silent unrecorded advice — the
/// exact failure this module exists to end.
const SEPARATORS: [&str; 4] = ["—", "–", "-", ":"];

/// Strip one leading list marker (`-`, `*`, `+`, `N.`, `N)`) and any emphasis wrapper from a line,
/// so `- **rec 1 — x**` and `rec 1 — x` parse identically. Anchoring after this strip is what keeps
/// the word "rec" in mid-sentence prose from ever counting as a marker.
fn strip_decoration(line: &str) -> String {
    let mut s = line.trim();
    if let Some(r) = s
        .strip_prefix("- ")
        .or_else(|| s.strip_prefix("* "))
        .or_else(|| s.strip_prefix("+ "))
    {
        s = r.trim_start();
    } else if let Some((head, rest)) = s.split_once(['.', ')']) {
        if !head.is_empty() && head.chars().all(|c| c.is_ascii_digit()) {
            s = rest.trim_start();
        }
    }
    for m in ["***", "**", "__", "*", "_"] {
        if let Some(r) = s.strip_prefix(m) {
            s = r;
            break;
        }
    }
    let mut out = s.trim();
    for m in ["***", "**", "__"] {
        if let Some(r) = out.strip_suffix(m) {
            out = r.trim_end();
            break;
        }
    }
    out.to_string()
}

/// Split `text` at the first separator, returning what follows it. `None` when no separator opens
/// the remainder — a `rec 3` with nothing after it is not a recommendation.
fn after_separator(text: &str) -> Option<&str> {
    SEPARATORS
        .iter()
        .find_map(|sep| text.strip_prefix(*sep))
        .map(str::trim)
        .filter(|t| !t.is_empty())
}

/// If `line` records a recommendation marker, return `(number, text)`. The grammar in one function
/// — everything downstream depends on this and nothing else re-implements it.
pub fn parse_rec_marker(line: &str) -> Option<(u32, String)> {
    let s = strip_decoration(line);
    // ASCII lower-casing preserves byte length, so offsets into `s` stay valid.
    let lower = s.to_ascii_lowercase();
    let rest = lower.strip_prefix("rec")?;
    if !rest.starts_with(char::is_whitespace) {
        return None;
    }
    let rest = s[s.len() - rest.len()..].trim_start();
    let digits: String = rest.chars().take_while(char::is_ascii_digit).collect();
    let number: u32 = digits.parse().ok()?;
    let text = after_separator(rest[digits.len()..].trim_start())?;
    Some((number, text.to_string()))
}

/// Every numbered recommendation recorded in one contract-valid handoff, in document order and
/// de-duplicated by number (first wins). A brief that lists `rec 1` in a summary and again in the
/// body records ONE recommendation, not two — otherwise a conscientious advisor would manufacture
/// unanswerable duplicates for the author.
pub fn recommendations_in(handoff: &crate::fleet::Handoff) -> Vec<Recommendation> {
    let mut out: Vec<Recommendation> = Vec::new();
    for line in handoff.body.lines() {
        if let Some((number, text)) = parse_rec_marker(line) {
            if out.iter().any(|r| r.number == number) {
                continue;
            }
            out.push(Recommendation {
                role: handoff.role.clone(),
                number,
                text,
                handoff_path: handoff.path.clone(),
            });
        }
    }
    out
}

// ---------------------------------------------------------------------------
// Step 4 — parse the DISPOSITIONS out of the session's own prompt. Also pure. The `## Advice`
// section lives inside the prompt for the same reason the `## Execution` trace does (S68):
// `prompts/` and `.ai/` ARE the memory, so there is no new store and no new artifact type.
// ---------------------------------------------------------------------------

/// A heading opens the `## Advice` block — first token exactly `advice`, matching the way every
/// other station finds its section, so a title merely mentioning advice in prose never counts.
fn is_advice_heading(line: &str) -> bool {
    line.trim_start_matches('#')
        .trim()
        .to_ascii_lowercase()
        .split_whitespace()
        .next()
        == Some("advice")
}

/// The body of the prompt's `## Advice` section, or `None` when there is no such section.
pub fn advice_section(text: &str) -> Option<String> {
    let mut lines = text.lines();
    lines.find(|l| l.starts_with('#') && is_advice_heading(l))?;
    let body: Vec<&str> = lines.take_while(|l| !l.starts_with('#')).collect();
    Some(body.join("\n"))
}

/// Trim an evidence TOKEN (a sha or a path): surrounding backticks and trailing sentence
/// punctuation are formatting, not part of the thing that must exist.
fn clean_token(raw: &str) -> String {
    raw.trim()
        .trim_matches('`')
        .trim_end_matches(['.', ',', ';'])
        .trim()
        .to_string()
}

/// Parse one `## Advice` line into `(role, number, disposition)`.
///
/// Role keys never contain the token `rec`, so the first ` rec <N>` boundary splits the line
/// cleanly even for hyphenated keys like `implementation-advisor`. Everything right of the
/// separator is `<word>: <evidence>`, split at the FIRST colon so a refusal reason may contain
/// colons of its own.
pub fn parse_disposition_line(line: &str) -> Option<(String, u32, Disposition)> {
    let s = strip_decoration(line);
    let lower = s.to_ascii_lowercase();

    let mut idx = None;
    let mut from = 0usize;
    while let Some(p) = lower[from..].find("rec") {
        let abs = from + p;
        let preceded_by_space = abs > 0 && lower.as_bytes()[abs - 1].is_ascii_whitespace();
        let tail = &lower[abs + 3..];
        let numbered = tail.starts_with(char::is_whitespace)
            && tail.trim_start().starts_with(|c: char| c.is_ascii_digit());
        if preceded_by_space && numbered {
            idx = Some(abs);
            break;
        }
        from = abs + 3;
    }
    let idx = idx?;
    let role = s[..idx].trim().to_ascii_lowercase();
    if role.is_empty() {
        return None;
    }

    let (number, tail) = parse_rec_marker(&s[idx..])?;
    let (word, evidence) = tail.split_once(':')?;
    let disposition = match word.trim().to_ascii_lowercase().as_str() {
        "obeyed" => Disposition::Obeyed(clean_token(evidence)),
        "deferred" => Disposition::Deferred(clean_token(evidence)),
        // A reason is prose: keep its punctuation, strip only the surrounding whitespace.
        "refused" => Disposition::Refused(evidence.trim().to_string()),
        // Any other word is NOT a disposition. Failing to parse is correct and safe here: the
        // recommendation simply stays unanswered and BLOCKS, which is what an invented
        // disposition word deserves.
        _ => return None,
    };
    Some((role, number, disposition))
}

/// Every disposition recorded in the prompt's `## Advice` section, keyed `<role> rec <N>` — the
/// same label `Recommendation::label` produces, which is what joins the two sides. First line
/// wins, so a later duplicate can never quietly overwrite an earlier answer.
pub fn dispositions_in(prompt_text: &str) -> Vec<(String, Disposition)> {
    let Some(section) = advice_section(prompt_text) else {
        return Vec::new();
    };
    let mut out: Vec<(String, Disposition)> = Vec::new();
    for line in section.lines() {
        if let Some((role, number, d)) = parse_disposition_line(line) {
            let label = format!("{role} rec {number}");
            if out.iter().any(|(l, _)| *l == label) {
                continue;
            }
            out.push((label, d));
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn handoff(role: &str, body: &str) -> crate::fleet::Handoff {
        crate::fleet::Handoff {
            role: role.to_string(),
            session: 127,
            path: format!(".ai/handoffs/session-127-{role}.md"),
            agent: "claude-code-subagent".into(),
            captured: "2026-08-22T00:00:00Z".into(),
            source_sha: "deadbeef".into(),
            body: body.to_string(),
        }
    }

    #[test]
    fn rec_marker_parses_every_accepted_shape_and_refuses_prose() {
        // The taught shape, and the three tolerated separators.
        assert_eq!(
            parse_rec_marker("rec 1 — do the thing"),
            Some((1, "do the thing".into()))
        );
        assert_eq!(parse_rec_marker("rec 2 – do it"), Some((2, "do it".into())));
        assert_eq!(parse_rec_marker("rec 3 - do it"), Some((3, "do it".into())));
        assert_eq!(parse_rec_marker("rec 4: do it"), Some((4, "do it".into())));
        // Decoration: list markers, emphasis, ordered items, mixed case.
        assert_eq!(
            parse_rec_marker("- **rec 5 — do it**"),
            Some((5, "do it".into()))
        );
        assert_eq!(
            parse_rec_marker("  7. REC 6 — do it"),
            Some((6, "do it".into()))
        );
        // Prose must NEVER count — this is the whole reason the marker is anchored.
        assert_eq!(parse_rec_marker("I rec 9 — you read this"), None);
        assert_eq!(parse_rec_marker("my recommendation 1 — x"), None);
        assert_eq!(parse_rec_marker("record 1 — x"), None);
        // Degenerate: no number, no separator, no text.
        assert_eq!(parse_rec_marker("rec — x"), None);
        assert_eq!(parse_rec_marker("rec 1 do it"), None);
        assert_eq!(parse_rec_marker("rec 1 —"), None);
    }

    #[test]
    fn recommendations_are_read_in_order_and_deduped_by_number() {
        let h = handoff(
            "demo-producer",
            "Summary:\nrec 1 — show the unpin\nrec 2 — show the tally\n\
             Detail follows.\nrec 1 — show the unpin (repeated in the body)\n",
        );
        let recs = recommendations_in(&h);
        assert_eq!(
            recs.len(),
            2,
            "a repeated number is ONE recommendation: {recs:?}"
        );
        assert_eq!(recs[0].number, 1);
        assert_eq!(recs[0].role, "demo-producer");
        assert_eq!(
            recs[0].handoff_path,
            ".ai/handoffs/session-127-demo-producer.md"
        );
        assert_eq!(recs[1].text, "show the tally");
        assert_eq!(recs[0].label(), "demo-producer rec 1");
    }

    #[test]
    fn a_handoff_with_no_markers_records_no_recommendations() {
        let h = handoff("researcher", "I think you should probably do the thing.\n");
        assert!(recommendations_in(&h).is_empty());
    }
}

#[cfg(test)]
mod dispositions_tests {
    use super::*;

    const PROMPT: &str = "# Session 127\n\n\
## Advice (every recommendation, answered)\n\n\
- design-advisor rec 1 — obeyed: `a1b2c3d`\n\
- demo-producer rec 2 — deferred: prompts/128-task-next.md\n\
- implementation-advisor rec 3 — refused: out of scope; this session ships one story\n\
- plan-advisor rec 4 — pondered: not a disposition word\n\
This paragraph mentions a rec in prose and must not parse.\n\n\
## Design\n\
- design-advisor rec 9 — obeyed: deadbeef\n";

    #[test]
    fn dispositions_are_read_only_from_the_advice_section() {
        let d = dispositions_in(PROMPT);
        let labels: Vec<&str> = d.iter().map(|(l, _)| l.as_str()).collect();
        assert_eq!(
            labels,
            vec![
                "design-advisor rec 1",
                "demo-producer rec 2",
                "implementation-advisor rec 3"
            ],
            "an invented disposition word, prose, and a line in another section must all be ignored"
        );
        assert_eq!(d[0].1, Disposition::Obeyed("a1b2c3d".into()));
        assert_eq!(
            d[1].1,
            Disposition::Deferred("prompts/128-task-next.md".into())
        );
        assert_eq!(
            d[2].1,
            Disposition::Refused("out of scope; this session ships one story".into()),
            "a reason keeps its own punctuation, including colons and semicolons"
        );
    }

    #[test]
    fn hyphenated_role_keys_split_cleanly_and_the_first_answer_wins() {
        let (role, n, d) =
            parse_disposition_line("- implementation-advisor rec 12 — obeyed: abc1234").unwrap();
        assert_eq!((role.as_str(), n), ("implementation-advisor", 12));
        assert_eq!(d, Disposition::Obeyed("abc1234".into()));

        let dup =
            "## Advice\n- x rec 1 — obeyed: aaa\n- x rec 1 — refused: changed my mind later\n";
        let got = dispositions_in(dup);
        assert_eq!(got.len(), 1);
        assert_eq!(got[0].1, Disposition::Obeyed("aaa".into()));
    }

    #[test]
    fn no_advice_section_records_nothing() {
        assert!(dispositions_in("# Session 1\n\n## Plan\n1. do it\n").is_empty());
        assert!(advice_section("# Session 1\n").is_none());
    }
}
