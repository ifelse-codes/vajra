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
//! 6. **Bare ordinals — `1.` as the recommendation number** — rejected: every advisory brief is
//!    already full of numbered lists, so ordinals would turn ordinary prose into gate-binding
//!    claims. A marker must be something an advisor CHOSE to write.
//! 7. **A role-qualified number — `design-advisor/2`** — rejected: it duplicates the `role:`
//!    frontmatter the gate already trusts as the placement source of truth, and it hands a role
//!    the ability to mislabel itself.
//! 8. **The disposition words `done` / `wontfix` / `later`** — rejected: `done:` collides with the
//!    Coder's own marker, and the other two are issue-tracker jargon. `obeyed` / `refused` /
//!    `deferred` say exactly what happened, in the founder's own framing.
//!
//! # Direction of error (rec 2 — different on each side, and deliberately so)
//!
//! Both sides lean the same way: **toward blocking, never toward passing.** On the HANDOFF side,
//! when a line is ambiguous, COUNT it — one more item the session must answer. On the PROMPT side,
//! when a line is ambiguous, DON'T CREDIT it — one fewer answer claimed. The one case where both
//! sides skip is a **fenced code block**: fences are the designated place to SHOW the grammar, and
//! this very session's prompt and role definitions quote `rec 1 — …` examples inside them. Without
//! fence-skipping the contract manufactures phantom recommendations and phantom answers on day one.
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
    /// A file exists at a role's handoff path but fails the DECISION-007 contract, so its
    /// recommendations cannot be READ AT ALL. BLOCKS — a gate that cannot evaluate fails (S69).
    ///
    /// rec 5: without this variant a malformed handoff collapsed into `NoHandoffs` — the state
    /// said "nothing to answer" while the file on disk said otherwise. Note the deliberate
    /// divergence from the two existing `HandoffRead::Malformed` consumers, which only SURFACE it
    /// (`format_handoff_brief` prints a ⚠; `stations::fleet_evidence` files it): this is the first
    /// consumer for which a malformed handoff is BINDING.
    Malformed(Vec<(String, String)>),
}

impl AdviceState {
    /// A blocking state refuses the close at L2/L3.
    pub fn blocks(&self) -> bool {
        matches!(self, AdviceState::Unanswered(_) | AdviceState::Malformed(_))
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

// ---------------------------------------------------------------------------
// Step 3 — parse the RECOMMENDATIONS out of a governed handoff. Pure: text in, markers out. No
// fs, no git, no process. The whole grammar lives here so the two sides (advisor writes, session
// answers) can never drift apart.
// ---------------------------------------------------------------------------

/// The separator set, longest first. An em dash is what the roles are told to write; the en dash,
/// hyphen and colon are accepted because nine independently-written agents will produce all four
/// and rejecting three of them would turn a typography slip into silent unrecorded advice — the
/// exact failure this module exists to end.
pub(crate) const SEPARATORS: [&str; 4] = ["—", "–", "-", ":"];

/// The lines of `text` that are NOT inside a fenced code block (rec 2). A fence opens and closes
/// on a trimmed line starting with ``` or ~~~ — the designated escape hatch for SHOWING the
/// grammar without recording it.
pub(crate) fn skip_fenced(text: &str) -> Vec<&str> {
    let mut out = Vec::new();
    let mut fenced = false;
    for line in text.lines() {
        let t = line.trim_start();
        if t.starts_with("```") || t.starts_with("~~~") {
            fenced = !fenced;
            continue;
        }
        if !fenced {
            out.push(line);
        }
    }
    out
}

/// Strip one leading list marker (`-`, `*`, `+`, `N.`, `N)`) and any emphasis wrapper from a line,
/// so `- **rec 1 — x**` and `rec 1 — x` parse identically. Anchoring after this strip is what keeps
/// the word "rec" in mid-sentence prose from ever counting as a marker.
pub(crate) fn strip_decoration(line: &str) -> String {
    let mut s = line.trim();
    // rec 3: a heading is a perfectly natural place for an advisor to put a recommendation
    // (`### rec 1 — …`), so the markers strip here too.
    s = s.trim_start_matches('#').trim_start();
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
    // rec 3: read the RAW findings region, not the display `body` — `handoff_body` drops every
    // `#` line, so a `### rec 3 — …` heading would be silently under-counted.
    for line in skip_fenced(&handoff.raw_body) {
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
    // Fences are stripped BEFORE the heading is located, not merely before its lines are parsed.
    // Found the hard way, by this gate, on this session's own prompt: the prompt shows the contract
    // in a fenced example that contains a literal `## Advice` heading, and locating the heading on
    // raw lines picked up the EXAMPLE — so the real section's 43 answers were never read while the
    // example's three fake ones were. rec 2's direction-of-error rule, applied one level up.
    let mut lines = skip_fenced(text).into_iter();
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

/// Split a `<role> rec <N> <sep> <tail>` line into its three parts, already decoration-stripped by
/// the caller. Factored out at S132 so the `obeyed-check` marker family reuses this boundary rule
/// verbatim rather than re-implementing it — two parsers drifting apart on what counts as a role
/// is exactly how a recorded answer silently stops matching the advice it answers.
///
/// Role keys never contain the token `rec`, so the first ` rec <N>` boundary splits the line
/// cleanly even for hyphenated keys like `implementation-advisor`.
pub(crate) fn split_role_rec(s: &str) -> Option<(String, u32, String)> {
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
    Some((role, number, tail))
}

/// Parse one `## Advice` line into `(role, number, disposition)`.
///
/// Role keys never contain the token `rec`, so the first ` rec <N>` boundary splits the line
/// cleanly even for hyphenated keys like `implementation-advisor`. Everything right of the
/// separator is `<word>: <evidence>`, split at the FIRST colon so a refusal reason may contain
/// colons of its own.
pub fn parse_disposition_line(line: &str) -> Option<(String, u32, Disposition)> {
    let (role, number, tail) = split_role_rec(&strip_decoration(line))?;
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
    for line in skip_fenced(&section) {
        if let Some((role, number, d)) = parse_disposition_line(line) {
            let label = format!("{role} rec {number}");
            // rec 11: LAST wins here, deliberately the opposite of `recommendations_in`'s
            // first-wins. An advisor states its number once; a session AUTHOR edits and appends in
            // `## Advice` exactly as they do in `## Execution`, so the later line is the current
            // answer. Both rules point the same way: the freshest honest statement.
            out.retain(|(l, _)| *l != label);
            out.push((label, d));
        }
    }
    out
}

// ---------------------------------------------------------------------------
// Step 5 — EXISTENCE-GATE each disposition, then classify. This is where the house pattern lands:
// a recorded claim only counts when the thing it names is REAL (S67 spine records, S68 commits).
// A `<placeholder>` answer that satisfies the parser but names nothing is the fake green this
// whole module would otherwise ship.
// ---------------------------------------------------------------------------

/// Is a refusal reason substantive? **A FORM floor, deliberately, and disclosed as one.**
///
/// The rule is the S61 Delta rule verbatim and nothing more: non-empty after trimming, and not a
/// `<...>` template placeholder. The implementation-advisor's rec 13 talked this session out of the
/// two extras it first shipped — a stop-word list (`tbd`, `n/a`) and a three-word minimum. S122's
/// lesson is that a guard bound to a SPELLING gets escaped by the next instance, and a length
/// threshold is a judgement dressed up as a check.
///
/// **So state the floor instead of faking it: a one-word reason PASSES.** This checks that a reason
/// was written, never that it is sound. Judging soundness is exactly the judgement criterion 12
/// forbids this gate from pretending to make.
pub fn substantive_reason(reason: &str) -> Result<(), String> {
    let r = reason.trim();
    if r.is_empty() {
        return Err("the refusal records no reason at all".into());
    }
    if r.starts_with('<') && r.ends_with('>') {
        return Err(format!(
            "the refusal reason is still the template placeholder `{r}`"
        ));
    }
    Ok(())
}

/// Existence-gate one recorded disposition against the real repo. The three checks are the three
/// precedents, applied to advice: a commit that resolves (S68), a reason that is a sentence (S61),
/// a destination file that exists (S67).
pub fn check_evidence(root: &Path, d: &Disposition) -> Result<(), String> {
    match d {
        Disposition::Obeyed(sha) => {
            // rec 13: only the leading hex run is a sha, so trailing prose falls off — and a ref
            // like `HEAD` yields an empty run and records nothing (`coder::execution_record`'s
            // exact behaviour, mirrored deliberately).
            let hex: String = sha.chars().take_while(char::is_ascii_hexdigit).collect();
            if hex.is_empty() {
                Err(format!(
                    "`obeyed: {sha}` records no commit sha — a ref or a placeholder is not a \
                     recorded landing commit"
                ))
            } else if crate::coder::commit_exists(root, &hex) {
                Ok(())
            } else {
                Err(format!(
                    "`obeyed: {hex}` names no commit in this repo (`git cat-file -e`) — a \
                     recorded sha that does not resolve is scored unanswered"
                ))
            }
        }
        Disposition::Refused(reason) => substantive_reason(reason),
        Disposition::Deferred(path) => {
            // rec 13: a deferral target outside the repo is not a record this repo can show
            // anyone — refuse absolute paths and any `..` escape BEFORE touching the fs.
            if path.is_empty() {
                Err("`deferred:` names no destination".into())
            } else if Path::new(path).is_absolute() || path.split('/').any(|c| c == "..") {
                Err(format!(
                    "`deferred: {path}` points outside the repo — a deferral must name a file this \
                     repo can show"
                ))
            } else if root.join(path).exists() {
                Ok(())
            } else {
                Err(format!(
                    "`deferred: {path}` names a file that does not exist — file it somewhere real"
                ))
            }
        }
    }
}

/// Join recommendations to dispositions and classify each one. Pure: `check` is injected so the
/// whole classifier is unit-testable without a repo, exactly like `coder::exec_report`.
///
/// Returns the items in recommendation order plus the ORPHAN labels — disposition lines answering
/// advice no handoff records. An orphan is surfaced, never silent: it usually means a renumbered
/// brief, which is the one way a recorded answer can quietly stop meaning what it said.
pub fn classify(
    recs: Vec<Recommendation>,
    dispositions: &[(String, Disposition)],
    check: impl Fn(&Disposition) -> Result<(), String>,
) -> (Vec<AdviceItem>, Vec<String>) {
    let items: Vec<AdviceItem> = recs
        .into_iter()
        .map(|rec| {
            let label = rec.label();
            let answer = match dispositions.iter().find(|(l, _)| *l == label) {
                None => Answer::Missing,
                Some((_, d)) => match check(d) {
                    Ok(()) => Answer::Answered(d.clone()),
                    Err(why) => Answer::Unreal(d.clone(), why),
                },
            };
            AdviceItem { rec, answer }
        })
        .collect();

    let orphans = dispositions
        .iter()
        .map(|(l, _)| l.clone())
        .filter(|l| !items.iter().any(|i| i.rec.label() == *l))
        .collect();

    (items, orphans)
}

/// The dodge, in ONE place (the `fidelity-reviewer`'s rec 4, and the `implementation-advisor`'s
/// rec 15 answered properly this time). The gate prints it, the surface prints it, the summary
/// quotes it — and none of them retypes it, so the three cannot drift into three different
/// admissions of the same limit.
pub const DODGE: &str = "NO numbered `rec N —` recommendations are recorded, so this gate has \
     nothing to enforce. Say it plainly: DELETING THE NUMBERS DODGES THIS GATE. Like every marker \
     gate here, its jurisdiction is self-granted (S68/S71) — an advisor that never numbers its \
     advice cannot be made to, and advice dropped from an unnumbered brief stays exactly as \
     invisible as it was before S127";

/// The Advice gate (S127): CLOSING `session` requires every numbered recommendation in its
/// governed handoffs to carry a disposition whose evidence is REAL.
///
/// Fail-closed, in the order the guardrails demand:
/// - a MALFORMED handoff BLOCKS — a gate that cannot evaluate FAILS (S69), and `Malformed` is
///   never swallowed as `Absent`;
/// - recommendations with no prompt to answer them in BLOCK, for the same reason;
/// - no handoffs at all is silent and legacy-compatible;
/// - handoffs with zero numbered recommendations WARN **and name the dodge out loud**.
pub fn advice_gate(root: &Path, session: u32) -> AdviceVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    let reads = crate::fleet::read_handoffs(root, session);
    let mut recs: Vec<Recommendation> = Vec::new();
    let mut roles_without_recs: Vec<String> = Vec::new();
    let mut malformed: Vec<(String, String)> = Vec::new();
    for r in &reads {
        match r {
            crate::fleet::HandoffRead::Absent => {}
            crate::fleet::HandoffRead::Malformed(path, why) => {
                malformed.push((path.clone(), why.clone()));
                reasons.push(format!(
                "{path} exists but does not satisfy the handoff contract ({why}) — a gate that \
                     cannot read its input FAILS; it never passes by treating the file as absent"
                ));
            }
            crate::fleet::HandoffRead::Found(h) => {
                let found = recommendations_in(h);
                if found.is_empty() {
                    roles_without_recs.push(h.role.clone());
                }
                recs.extend(found);
            }
        }
    }

    let prompt_path = crate::analyst::find_prompt_for(root, session);
    let prompt_text = match &prompt_path {
        None => None,
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Ok(t) => Some(t),
            Err(e) => {
                reasons.push(format!("cannot read {rel}: {e}"));
                None
            }
        },
    };

    if !recs.is_empty() && prompt_text.is_none() && prompt_path.is_none() {
        reasons.push(format!(
            "session {session:02} records {} recommendation(s) in its handoffs but has no prompt \
             to answer them in — the `## Advice` section lives in the session's own prompt",
            recs.len()
        ));
    }

    let dispositions = prompt_text
        .as_deref()
        .map(dispositions_in)
        .unwrap_or_default();
    let (items, orphans) = classify(recs, &dispositions, |d| check_evidence(root, d));

    let unanswered: Vec<String> = items
        .iter()
        .filter(|i| !i.answer.is_answered())
        .map(|i| i.rec.label())
        .collect();

    // rec 14 — the precedence, stated so it is a DECISION and not an accident:
    //   Malformed (BLOCK, fail closed) > Unanswered (BLOCK) > NoRecommendations (WARN, dodge
    //   named) > Answered (PASS) > NoHandoffs (silent).
    // Malformed and Unanswered can coexist; a blocking reason is pushed for each, and only the
    // reported STATE has to pick one.
    let state = if !malformed.is_empty() {
        AdviceState::Malformed(malformed)
    } else if reads.is_empty() {
        AdviceState::NoHandoffs
    } else if items.is_empty() {
        AdviceState::NoRecommendations(roles_without_recs.clone())
    } else if unanswered.is_empty() {
        AdviceState::Answered
    } else {
        AdviceState::Unanswered(unanswered)
    };

    match &state {
        // The malformed reasons were pushed at read time — a second message would only repeat them.
        AdviceState::NoHandoffs | AdviceState::Answered | AdviceState::Malformed(_) => {}
        AdviceState::NoRecommendations(roles) => {
            warnings.push(format!("handoff(s) from {}: {DODGE}", roles.join(", ")))
        }
        AdviceState::Unanswered(_) => {
            for item in items.iter().filter(|i| !i.answer.is_answered()) {
                let why = match &item.answer {
                    Answer::Missing => format!(
                        "no line in `## Advice` answers it (recorded at {})",
                        item.rec.handoff_path
                    ),
                    Answer::Unreal(_, why) => why.clone(),
                    Answer::Answered(_) => unreachable!(),
                };
                reasons.push(format!(
                    "{} — {why}. Record `- {} — obeyed: <sha>` / `refused: <reason>` / \
                     `deferred: <path>` in the prompt's `## Advice`",
                    item.rec.label(),
                    item.rec.label()
                ));
            }
        }
    }

    for o in &orphans {
        warnings.push(format!(
            "`## Advice` answers `{o}`, which no handoff for session {session:02} records — a \
             renumbered brief silently re-points a recorded answer at different advice"
        ));
    }

    AdviceVerdict {
        session,
        prompt_path,
        items,
        orphans,
        state,
        reasons,
        warnings,
    }
}

/// Render the `--advice NN` surface: one line per recommendation with the disposition it took,
/// the advice text INLINE (a path alone is not consumption — S112), and the source handoff named.
pub fn format_advice_checklist(v: &AdviceVerdict) -> String {
    let mut s = format!(
        "=== advice: recommendations for session {:02} ===\n",
        v.session
    );
    s.push_str(&format!(
        "prompt: {}\n",
        v.prompt_path.as_deref().unwrap_or("(none)")
    ));

    if v.items.is_empty() {
        s.push_str(match v.state {
            AdviceState::NoHandoffs => "recommendations: (no governed handoff for this session)\n",
            AdviceState::Malformed(_) => "recommendations: (unreadable — see below)\n",
            _ => "recommendations: (handoffs exist but record no numbered `rec N —` items)\n",
        });
    }

    for item in &v.items {
        let (mark, note) = match &item.answer {
            Answer::Answered(d) => ("✓", format!("{}: {}", d.word(), d.evidence())),
            Answer::Unreal(d, why) => ("✗", format!("{}: {} — {why}", d.word(), d.evidence())),
            Answer::Missing => ("✗", "UNANSWERED".to_string()),
        };
        s.push_str(&format!(
            "  [{mark}] {label} — {text}\n        {note}\n        source: {src}\n",
            label = item.rec.label(),
            text = item.rec.text,
            src = item.rec.handoff_path,
        ));
    }

    match &v.state {
        AdviceState::Answered => s.push_str(&format!(
            "state: ANSWERED ({} of {} recommendations)\n",
            v.items.len(),
            v.items.len()
        )),
        AdviceState::Unanswered(u) => {
            s.push_str(&format!("state: UNANSWERED -> {}\n", u.join(", ")))
        }
        AdviceState::NoRecommendations(roles) => s.push_str(&format!(
            "state: NO NUMBERED RECOMMENDATIONS ({}) — {DODGE}\n",
            roles.join(", ")
        )),
        AdviceState::NoHandoffs => s.push_str("state: NO HANDOFFS (nothing to answer)\n"),
        AdviceState::Malformed(m) => {
            for (path, why) in m {
                s.push_str(&format!(
                    "state: MALFORMED HANDOFF {path} ({why}) — fails closed\n"
                ));
            }
        }
    }
    s.push_str(
        "note: this proves each recommendation was ANSWERED and its evidence is real. It does \
         NOT prove the answer was good.\n",
    );
    s
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
            raw_body: body.to_string(),
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

    /// rec 3 — a recommendation written as a HEADING must still count. `fleet::handoff_body`
    /// drops every `#` line, so reading the display body here would silently under-count exactly
    /// the advice this gate exists to make un-droppable. This test fails the moment someone
    /// switches the input back to `body`.
    #[test]
    fn a_heading_form_recommendation_is_still_counted() {
        let mut h = handoff("design-advisor", "");
        h.raw_body = "### rec 1 — lift the S116 deferral\n\nrationale follows\n".into();
        h.body = "rationale follows".into(); // what handoff_body would have produced
        let recs = recommendations_in(&h);
        assert_eq!(
            recs.len(),
            1,
            "a `### rec 1 — …` heading must count: {recs:?}"
        );
        assert_eq!(recs[0].number, 1);
    }

    /// rec 2 — fences are where the grammar is SHOWN, on both sides. Without this, the role
    /// definitions and this session's own prompt manufacture phantom advice on day one.
    #[test]
    fn recommendations_and_dispositions_inside_a_fence_are_never_recorded() {
        let mut h = handoff("plan-advisor", "");
        h.raw_body = "Here is the shape:\n```\nrec 9 — an EXAMPLE, not advice\n```\n                      rec 1 — real advice\n"
            .into();
        let recs = recommendations_in(&h);
        assert_eq!(recs.len(), 1, "the fenced example must not count: {recs:?}");
        assert_eq!(recs[0].number, 1);

        let prompt = "## Advice\nrecord it like this:\n```\n- ghost rec 9 — obeyed: deadbeef\n```\n                      - plan-advisor rec 1 — refused: a real answer\n";
        let d = dispositions_in(prompt);
        assert_eq!(
            d.len(),
            1,
            "the fenced example must not claim an answer: {d:?}"
        );
        assert_eq!(d[0].0, "plan-advisor rec 1");
    }

    /// rec 8 — the round trip: the instruction every role is given and the parser that reads it
    /// back are ONE thing, not two. For every registered role, the example line printed in its own
    /// definition is fed through the real parser and must come back as exactly one recommendation
    /// numbered 1. If someone rewords the taught shape, this fails; if someone narrows the parser,
    /// this fails. A verify-script grep for the sentence would catch neither (S122's hollow-grep
    /// class), which is why the binding lives here.
    #[test]
    fn what_every_role_is_taught_to_write_is_what_the_parser_reads_back() {
        for role in crate::fleet::ROLES {
            let def = crate::fleet::render_subagent_definition(role);
            let taught: Vec<&str> = def
                .lines()
                .filter(|l| l.trim_start().starts_with("rec 1 "))
                .collect();
            assert_eq!(
                taught.len(),
                1,
                "{}: expected exactly one taught `rec 1` example line, got {taught:?}",
                role.name
            );
            let parsed = parse_rec_marker(taught[0]);
            assert!(
                matches!(parsed, Some((1, _))),
                "{}: the shape its own definition teaches does not parse: {:?} -> {parsed:?}",
                role.name,
                taught[0]
            );
        }
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
    fn hyphenated_role_keys_split_cleanly_and_the_last_answer_wins() {
        let (role, n, d) =
            parse_disposition_line("- implementation-advisor rec 12 — obeyed: abc1234").unwrap();
        assert_eq!((role.as_str(), n), ("implementation-advisor", 12));
        assert_eq!(d, Disposition::Obeyed("abc1234".into()));

        let dup =
            "## Advice\n- x rec 1 — obeyed: aaa\n- x rec 1 — refused: changed my mind later\n";
        let got = dispositions_in(dup);
        assert_eq!(got.len(), 1);
        // rec 11: LAST wins — an author edits and appends in `## Advice` as they do in
        // `## Execution`, so the later line is the current answer.
        assert_eq!(
            got[0].1,
            Disposition::Refused("changed my mind later".into())
        );
    }

    /// The bug this gate found in ITSELF, on this session's own prompt: a fenced EXAMPLE showing
    /// the contract contains a literal `## Advice` heading, and locating the section on raw lines
    /// picked up the example instead of the real section further down.
    #[test]
    fn a_fenced_example_heading_is_not_mistaken_for_the_real_advice_section() {
        let prompt = "# Session 127\n\nHere is the shape:\n\n```\n## Advice (every recommendation, answered)\n- design-advisor rec 1 — obeyed: `a1b2c3d`\n```\n\n## Advice (the real one)\n- demo-producer rec 7 — refused: a real answer\n";
        let d = dispositions_in(prompt);
        assert_eq!(
            d.len(),
            1,
            "the fenced example section must be skipped: {d:?}"
        );
        assert_eq!(d[0].0, "demo-producer rec 7");
    }

    #[test]
    fn no_advice_section_records_nothing() {
        assert!(dispositions_in("# Session 1\n\n## Plan\n1. do it\n").is_empty());
        assert!(advice_section("# Session 1\n").is_none());
    }
}

#[cfg(test)]
mod gate_tests {
    use super::*;
    use std::process::Command;

    /// A real git repo with one real commit — the only way to test the `obeyed:` existence gate
    /// honestly (mirrors `coder`'s fixture).
    fn git_repo_with_commit(dir: &Path) -> String {
        let git = |args: &[&str]| {
            Command::new("git")
                .args(args)
                .current_dir(dir)
                .output()
                .unwrap()
        };
        git(&["init", "-q", "."]);
        git(&["config", "user.email", "t@t"]);
        git(&["config", "user.name", "t"]);
        fs::write(dir.join("seed.txt"), "seed").unwrap();
        git(&["add", "-A"]);
        git(&["commit", "-q", "-m", "seed", "--no-verify"]);
        let out = git(&["rev-parse", "HEAD"]);
        String::from_utf8_lossy(&out.stdout).trim().to_string()
    }

    fn write_handoff(root: &Path, role: &str, body: &str) {
        fs::create_dir_all(root.join(".ai/handoffs")).unwrap();
        fs::write(
            root.join(format!(".ai/handoffs/session-127-{role}.md")),
            format!(
                "---\nrole: {role}\nsession: 127\nagent: claude-code-subagent\n\
                 source-sha: abc\ncaptured: 2026-08-22T00:00:00Z\ncost_usd: null\n---\n\n\
                 # {role} handoff — session 127\n\n{body}\n\n## Handoff Delta\n- `+` new\n"
            ),
        )
        .unwrap();
    }

    fn write_prompt(root: &Path, advice: &str) {
        fs::create_dir_all(root.join("prompts")).unwrap();
        fs::write(
            root.join("prompts/127-task-x.md"),
            format!("# Session 127\n\n## Advice\n{advice}\n\n## Plan\n1. x\n"),
        )
        .unwrap();
    }

    #[test]
    fn criterion_1_an_unanswered_recommendation_blocks_and_names_role_number_and_path() {
        let tmp = tempfile::tempdir().unwrap();
        git_repo_with_commit(tmp.path());
        write_handoff(
            tmp.path(),
            "demo-producer",
            "rec 1 — show the unpin\nrec 2 — show the tally",
        );
        write_prompt(
            tmp.path(),
            "- demo-producer rec 1 — refused: the unpin is a separate story",
        );

        let v = advice_gate(tmp.path(), 127);
        assert!(v.blocked(), "an unanswered recommendation must BLOCK");
        assert_eq!(
            v.state,
            AdviceState::Unanswered(vec!["demo-producer rec 2".into()])
        );
        let joined = v.reasons.join("\n");
        assert!(joined.contains("demo-producer rec 2"), "{joined}");
        assert!(
            joined.contains(".ai/handoffs/session-127-demo-producer.md"),
            "{joined}"
        );
    }

    #[test]
    fn criterion_2_every_recommendation_answered_passes_and_prints_each_disposition() {
        let tmp = tempfile::tempdir().unwrap();
        let sha = git_repo_with_commit(tmp.path());
        write_handoff(
            tmp.path(),
            "demo-producer",
            "rec 1 — a\nrec 2 — b\nrec 3 — c",
        );
        write_prompt(
            tmp.path(),
            &format!(
                "- demo-producer rec 1 — obeyed: {sha}\n\
                 - demo-producer rec 2 — refused: out of scope for one story\n\
                 - demo-producer rec 3 — deferred: prompts/127-task-x.md"
            ),
        );
        let v = advice_gate(tmp.path(), 127);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.state, AdviceState::Answered);
        let out = format_advice_checklist(&v);
        for w in ["obeyed:", "refused:", "deferred:"] {
            assert!(out.contains(w), "surface omits {w}:\n{out}");
        }
        assert!(
            out.contains("does NOT prove the answer was good"),
            "the surface must state the floor every time it passes:\n{out}"
        );
    }

    #[test]
    fn criteria_3_4_5_each_unreal_evidence_blocks() {
        let tmp = tempfile::tempdir().unwrap();
        git_repo_with_commit(tmp.path());
        write_handoff(
            tmp.path(),
            "plan-advisor",
            "rec 1 — a\nrec 2 — b\nrec 3 — c",
        );
        write_prompt(
            tmp.path(),
            "- plan-advisor rec 1 — obeyed: 9999999\n\
             - plan-advisor rec 2 — refused: <reason>\n\
             - plan-advisor rec 3 — deferred: prompts/999-does-not-exist.md",
        );
        let v = advice_gate(tmp.path(), 127);
        assert!(v.blocked());
        assert_eq!(v.items.len(), 3);
        assert!(v
            .items
            .iter()
            .all(|i| matches!(i.answer, Answer::Unreal(..))));
        let j = v.reasons.join("\n");
        assert!(j.contains("names no commit"), "{j}"); // criterion 3
        assert!(j.contains("template placeholder"), "{j}"); // criterion 4
        assert!(j.contains("names a file that does not exist"), "{j}"); // criterion 5
    }

    #[test]
    /// The refusal floor, with its limit asserted rather than hidden: an EMPTY or still-template
    /// reason blocks, and a SHORT real one passes. `rec 13` argued this session out of a stop-word
    /// list and a word-count threshold — S122 (a guard bound to a spelling gets escaped) and the
    /// fact that "is this reason good?" is precisely the judgement criterion 12 forbids faking.
    fn criterion_4_an_empty_or_placeholder_refusal_blocks_and_a_short_real_one_passes() {
        assert!(substantive_reason("out of scope for this session").is_ok());
        assert!(substantive_reason("").is_err());
        assert!(substantive_reason("   ").is_err());
        assert!(substantive_reason("<reason>").is_err());
        // The disclosed floor, asserted so nobody can later claim more than it does:
        assert!(
            substantive_reason("no").is_ok(),
            "a one-word reason PASSES — this gate checks that a reason was written, never that \
             it is sound"
        );
    }

    #[test]
    fn criterion_6_handoffs_with_no_numbers_warn_and_name_the_dodge() {
        let tmp = tempfile::tempdir().unwrap();
        git_repo_with_commit(tmp.path());
        write_handoff(
            tmp.path(),
            "researcher",
            "You should probably do the thing.",
        );
        write_prompt(tmp.path(), "- (none)");
        let v = advice_gate(tmp.path(), 127);
        assert!(!v.blocked(), "a legacy/unnumbered brief must never block");
        assert_eq!(
            v.state,
            AdviceState::NoRecommendations(vec!["researcher".into()])
        );
        assert!(
            v.warnings
                .iter()
                .any(|w| w.contains("DELETING THE NUMBERS DODGES THIS GATE")),
            "the dodge must be named in plain words: {:?}",
            v.warnings
        );
    }

    #[test]
    fn a_malformed_handoff_fails_closed_and_is_never_read_as_absent() {
        let tmp = tempfile::tempdir().unwrap();
        git_repo_with_commit(tmp.path());
        fs::create_dir_all(tmp.path().join(".ai/handoffs")).unwrap();
        fs::write(
            tmp.path().join(".ai/handoffs/session-127-researcher.md"),
            "not a handoff at all\n",
        )
        .unwrap();
        write_prompt(tmp.path(), "- (none)");
        let v = advice_gate(tmp.path(), 127);
        assert!(v.blocked(), "a gate that cannot read its input FAILS (S69)");
        assert!(v
            .reasons
            .iter()
            .any(|r| r.contains("cannot read its input FAILS")));
    }

    #[test]
    fn no_handoffs_is_silent_and_an_orphan_answer_is_surfaced() {
        let tmp = tempfile::tempdir().unwrap();
        git_repo_with_commit(tmp.path());
        write_prompt(tmp.path(), "- ghost-role rec 4 — obeyed: 9999999");
        let v = advice_gate(tmp.path(), 127);
        assert!(!v.blocked());
        assert_eq!(v.state, AdviceState::NoHandoffs);
        assert_eq!(v.orphans, vec!["ghost-role rec 4".to_string()]);
        assert!(v
            .warnings
            .iter()
            .any(|w| w.contains("no handoff for session 127 records")));
    }
}

/// The falsifiability fixture (criterion 9, shaped by the implementation-advisor's rec 17).
///
/// The S122 lesson is that a fixture which goes red for the WRONG reason is glued on. So this
/// drives the REAL `advice_gate` over three states of one subject, asserts on `blocks()` and on
/// labels composed from PARSED input, and never on a message string — renaming any message here
/// leaves it green, while deleting either half of the consumption turns it red:
///
/// - delete the ANSWER classification (make every disposition count) → B and C flip green → RED;
/// - delete the RECOMMENDATION parser (nothing to answer) → B and C become `NoRecommendations`,
///   which does not block → also RED.
///
/// State A is the negative control that makes both of those meaningful: a gate that simply blocked
/// unconditionally would sail through B and C and fail here.
///
/// Every state REWRITES the prompt from one template. Nothing is mutated in place — that is
/// exactly how S122's planted defect leaked into the next case's baseline.
#[cfg(test)]
mod falsifiability {
    use super::*;
    use std::process::Command;

    const HANDOFF_BODY: &str = "rec 1 — lift the S116 deferral in a DECISION-007 addendum";

    fn subject(dir: &Path) -> String {
        let git = |args: &[&str]| {
            Command::new("git")
                .args(args)
                .current_dir(dir)
                .output()
                .unwrap()
        };
        git(&["init", "-q", "."]);
        git(&["config", "user.email", "t@t"]);
        git(&["config", "user.name", "t"]);
        fs::write(dir.join("seed.txt"), "seed").unwrap();
        git(&["add", "-A"]);
        git(&["commit", "-q", "-m", "seed", "--no-verify"]);
        let sha = String::from_utf8_lossy(&git(&["rev-parse", "HEAD"]).stdout)
            .trim()
            .to_string();

        // The handoff is built through the REAL contract writer, never hand-typed frontmatter, so
        // if DECISION-007's contract changes the fixture follows it automatically.
        let role = crate::fleet::resolve_role("design-advisor").unwrap();
        fs::create_dir_all(dir.join(".ai/handoffs")).unwrap();
        fs::write(
            dir.join(role.handoff_rel(127)),
            crate::fleet::format_handoff(
                role,
                127,
                "claude-code-subagent",
                &crate::fleet::sha256_hex(HANDOFF_BODY.as_bytes()).unwrap_or_default(),
                "2026-08-22T00:00:00Z",
                None,
                HANDOFF_BODY,
                &crate::fleet::compute_delta(role, None, HANDOFF_BODY),
            ),
        )
        .unwrap();
        fs::create_dir_all(dir.join("prompts")).unwrap();
        sha
    }

    /// Rewrite the prompt from the ONE template. Never edit the previous state's file (S122).
    fn write_prompt(dir: &Path, advice_lines: &str) {
        fs::write(
            dir.join("prompts/127-task-x.md"),
            format!("# Session 127\n\n## Advice\n{advice_lines}\n\n## Plan\n1. x\n"),
        )
        .unwrap();
    }

    #[test]
    fn deleting_the_consumption_turns_this_red_and_renaming_a_message_does_not() {
        let tmp = tempfile::tempdir().unwrap();
        let sha = subject(tmp.path());
        let label = "design-advisor rec 1";

        // --- State A: the negative control. Answered, with real evidence. MUST BE GREEN. ---
        write_prompt(tmp.path(), &format!("- {label} — obeyed: {sha}"));
        let a = advice_gate(tmp.path(), 127);
        assert!(!a.blocked(), "state A must pass: {:?}", a.reasons);
        assert_eq!(a.state, AdviceState::Answered);
        assert_eq!(
            a.items.len(),
            1,
            "the recommendation must be READ, not merely tolerated"
        );

        // --- State B: the disposition is gone. MUST BE RED, naming the parsed label. ---
        write_prompt(tmp.path(), "- (nothing answered here)");
        let b = advice_gate(tmp.path(), 127);
        assert!(
            b.blocked(),
            "state B: an unanswered recommendation must BLOCK"
        );
        assert_eq!(b.state, AdviceState::Unanswered(vec![label.to_string()]));

        // --- State C: answered, but every evidence kind is unreal. MUST BE RED, three ways. ---
        for line in [
            format!("- {label} — obeyed: 9999999"),
            format!("- {label} — refused: <reason>"),
            format!("- {label} — deferred: prompts/999-task-nope.md"),
        ] {
            write_prompt(tmp.path(), &line);
            let c = advice_gate(tmp.path(), 127);
            assert!(c.blocked(), "state C must BLOCK on `{line}`");
            assert_eq!(
                c.state,
                AdviceState::Unanswered(vec![label.to_string()]),
                "`{line}` must be scored UNANSWERED, not merely warned about"
            );
            assert!(
                matches!(c.items[0].answer, Answer::Unreal(..)),
                "`{line}` must classify as a claim whose evidence is not real"
            );
        }

        // --- State D: the WARN branch criterion 6 rests on. MUST NOT BLOCK, must NAME itself. ---
        // rec 8 (pass 2): every other state exercises the BLOCK paths, so deleting the WARN branch
        // — turning the disclosed dodge into a hard block, or into silence — left the fixture
        // green. That is the one branch the entire "honest limit" story depends on.
        let role = crate::fleet::resolve_role("design-advisor").unwrap();
        let prose = "You should probably do the thing.";
        fs::write(
            tmp.path().join(role.handoff_rel(127)),
            crate::fleet::format_handoff(
                role,
                127,
                "claude-code-subagent",
                &crate::fleet::sha256_hex(prose.as_bytes()).unwrap_or_default(),
                "2026-08-22T00:00:00Z",
                None,
                prose,
                &crate::fleet::compute_delta(role, None, prose),
            ),
        )
        .unwrap();
        write_prompt(tmp.path(), "- (nothing to answer)");
        let d = advice_gate(tmp.path(), 127);
        assert!(
            !d.blocked(),
            "state D: an unnumbered brief must never block"
        );
        assert_eq!(
            d.state,
            AdviceState::NoRecommendations(vec!["design-advisor".to_string()]),
            "state D must be its own state, not silence and not a block"
        );
        assert_eq!(d.items.len(), 0, "there is nothing to answer");
        assert!(
            !d.warnings.is_empty(),
            "state D must SAY something — a limit nobody is told about is not disclosed"
        );

        // Restore the numbered handoff so the control below tests what it says it tests.
        fs::write(
            tmp.path().join(role.handoff_rel(127)),
            crate::fleet::format_handoff(
                role,
                127,
                "claude-code-subagent",
                &crate::fleet::sha256_hex(HANDOFF_BODY.as_bytes()).unwrap_or_default(),
                "2026-08-22T00:00:00Z",
                None,
                HANDOFF_BODY,
                &crate::fleet::compute_delta(role, None, HANDOFF_BODY),
            ),
        )
        .unwrap();

        // Re-run state A LAST, from the same template, to prove nothing above left residue.
        write_prompt(tmp.path(), &format!("- {label} — obeyed: {sha}"));
        let again = advice_gate(tmp.path(), 127);
        assert!(
            !again.blocked(),
            "the control must still pass after the red states"
        );
    }
}
