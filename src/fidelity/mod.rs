//! The Fidelity gate (S131) — a session cannot close without a REAL `fidelity-reviewer` governed
//! handoff. Mandatory, mirroring how the Coder/Architect/Planner gates already block on absence
//! (`src/coder/mod.rs`, `src/architect/mod.rs`, `src/planner/mod.rs`), not merely on content.
//!
//! S130's ground truth found the fleet's usage falling every session (S126 5 handoffs -> S129 0)
//! with no gate that ever complained about the zero. The founder's own words at that closeout:
//! the first role to make mandatory is the one that "ensure[s] the session complete[s] all
//! acceptance criteria and what it build[s] is actually high quality work — not fake stamping and
//! shortcuts." That is `fidelity-reviewer` (DECISION-002's fidelity auditor).
//!
//! "Mandatory" alone is not enough — a hand-typed handoff satisfies mere existence for free. This
//! gate also demands the handoff's provenance be PROVABLE: it re-derives, independently, whether
//! the `agent:` field's claimed tool-use id really cross-checks against real Claude Code dispatch
//! evidence on this machine (`src/dispatch/mod.rs`). It never trusts the handoff's own label — a
//! forger can paste `(verified: toolu_xxx)` into a hand-typed file as easily as anything else; only
//! a fresh, independent re-scan closes that hole.
//!
//! This is a DISTINCT gate from the Advice gate (S127, `src/advice/mod.rs`): the Advice gate
//! proves every numbered RECOMMENDATION a handoff makes was ANSWERED; this gate proves the
//! handoff ITSELF exists and is real. Different artifacts, different failure modes — the same
//! handoff can pass one and fail the other. Its own command (`--check-fidelity-handoff`, not an
//! extension of `--check-advice`) keeps that boundary explicit rather than implicit.

use std::path::Path;

use crate::dispatch;
use crate::fleet::{self, HandoffRead};

/// The Fidelity gate's decision for CLOSING `session`. Mirrors `advice::AdviceVerdict` field for
/// field so the CLI surface and the `--advance` wiring are the same shape as every other station.
#[derive(Debug, Clone)]
pub struct FidelityVerdict {
    pub session: u32,
    /// The handoff's repo-relative path, when one exists (however malformed).
    pub handoff_path: Option<String>,
    /// When a valid handoff exists, the `agent:` field it recorded — surfaced so a human can see
    /// exactly what claim the gate did or did not accept.
    pub agent_field: Option<String>,
    blocked: bool,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    pub warnings: Vec<String>,
}

impl FidelityVerdict {
    pub fn blocked(&self) -> bool {
        self.blocked
    }
}

/// The Fidelity gate (S131): CLOSING `session` requires `.ai/handoffs/session-{NN}-fidelity-
/// reviewer.md` to exist, satisfy the DECISION-007 handoff contract, AND carry a provenance claim
/// that independently re-verifies against real Claude Code subagent-dispatch evidence. Absence,
/// malformation, and unverifiable provenance are three distinct BLOCKING reasons — none of them
/// silently reads as any of the others (the fail-closed rule, S67's existence lesson applied to a
/// fleet role instead of a spine record).
pub fn fidelity_gate(root: &Path, session: u32) -> FidelityVerdict {
    let role = fleet::resolve_role("fidelity-reviewer")
        .expect("fidelity-reviewer is a permanently registered fleet role");

    match fleet::read_handoff(root, role, session) {
        HandoffRead::Absent => FidelityVerdict {
            session,
            handoff_path: None,
            agent_field: None,
            blocked: true,
            reasons: vec![format!(
                "no fidelity-reviewer handoff recorded for session {session:02} \
                 ({}) — dispatch the cold review and run `vajra next --role fidelity-reviewer \
                 --from <findings>` before closing (S131: this role is now mandatory)",
                role.handoff_rel(session)
            )],
            warnings: vec![],
        },
        HandoffRead::Malformed(path, why) => FidelityVerdict {
            session,
            handoff_path: Some(path.clone()),
            agent_field: None,
            blocked: true,
            reasons: vec![format!(
                "{path} exists but does not satisfy the handoff contract ({why}) — a gate that \
                 cannot read its input FAILS; it never passes by treating the file as absent"
            )],
            warnings: vec![],
        },
        HandoffRead::Found(h) => match dispatch::claimed_tool_use_id(&h.agent) {
            None => FidelityVerdict {
                session,
                handoff_path: Some(h.path.clone()),
                agent_field: Some(h.agent.clone()),
                blocked: true,
                reasons: vec![format!(
                    "{}'s provenance ({:?}) carries no verifiable dispatch id — a hand-typed or \
                     pre-S131 handoff is not accepted as fleet evidence",
                    h.path, h.agent
                )],
                warnings: vec![],
            },
            Some(tool_use_id) => match dispatch::reverify(root, role.name, session, &tool_use_id) {
                Ok(()) => FidelityVerdict {
                    session,
                    handoff_path: Some(h.path),
                    agent_field: Some(h.agent),
                    blocked: false,
                    reasons: vec![],
                    warnings: vec![],
                },
                Err(reason) => FidelityVerdict {
                    session,
                    handoff_path: Some(h.path.clone()),
                    agent_field: Some(h.agent),
                    blocked: true,
                    reasons: vec![format!(
                        "{}'s provenance could not be independently re-verified: {reason} — \
                             a claim this gate cannot re-derive is treated as absent/invalid, not \
                             trusted",
                        h.path
                    )],
                    warnings: vec![],
                },
            },
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::dispatch::Provenance;
    use std::fs;

    fn tmp_root() -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "vajra-fidelity-test-{}-{}",
            std::process::id(),
            uniq()
        ));
        fs::create_dir_all(dir.join(".ai/handoffs")).unwrap();
        dir
    }
    fn uniq() -> u64 {
        use std::sync::atomic::{AtomicU64, Ordering};
        static N: AtomicU64 = AtomicU64::new(0);
        N.fetch_add(1, Ordering::Relaxed)
    }

    fn write_handoff(root: &Path, session: u32, agent: &str) {
        let role = fleet::resolve_role("fidelity-reviewer").unwrap();
        let body = "## Findings\nrec 1 — an example finding\n";
        let handoff = fleet::format_handoff(
            role,
            session,
            agent,
            "deadbeef",
            "2026-08-24T00:00:00Z",
            None,
            body,
            "- `+` new: first fidelity-reviewer handoff for this session (test fixture)",
        );
        fs::write(root.join(role.handoff_rel(session)), handoff).unwrap();
    }

    // (a) no handoff at all -> BLOCKS, naming the absence.
    #[test]
    fn absent_handoff_blocks() {
        let root = tmp_root();
        let v = fidelity_gate(&root, 131);
        assert!(v.blocked());
        assert!(
            v.reasons[0].contains("no fidelity-reviewer handoff recorded"),
            "{:?}",
            v.reasons
        );
        assert!(v.reasons[0].contains("session 131"));
    }

    // (b) a handoff with fabricated/unverifiable provenance -> BLOCKS, not silently accepted.
    #[test]
    fn fabricated_provenance_blocks() {
        let root = tmp_root();
        write_handoff(
            &root,
            131,
            "claude-code-subagent (verified: toolu_FAKEFAKEFAKE)",
        );
        let v = fidelity_gate(&root, 131);
        assert!(v.blocked());
        assert!(
            v.reasons[0].contains("could not be independently re-verified"),
            "{:?}",
            v.reasons
        );
    }

    #[test]
    fn a_pre_s131_bare_agent_label_blocks_as_no_derivable_id() {
        let root = tmp_root();
        write_handoff(&root, 131, "claude-code-subagent");
        let v = fidelity_gate(&root, 131);
        assert!(v.blocked());
        assert!(
            v.reasons[0].contains("no verifiable dispatch id"),
            "{:?}",
            v.reasons
        );
    }

    #[test]
    fn malformed_handoff_fails_closed_not_silently_absent() {
        let root = tmp_root();
        fs::write(
            root.join(".ai/handoffs/session-131-fidelity-reviewer.md"),
            "not a handoff at all",
        )
        .unwrap();
        let v = fidelity_gate(&root, 131);
        assert!(v.blocked());
        assert!(
            v.reasons[0].contains("does not satisfy the handoff contract"),
            "{:?}",
            v.reasons
        );
    }

    // (c) a real, independently-verifiable dispatch -> PASSES. `reverify` is real machine IO
    // (`src/dispatch/mod.rs`), so this exercises the label round-trip against a Provenance the
    // dispatch module itself produced, proving the two modules speak the same claim shape end to
    // end (the fs-backed cross-check itself is covered by `dispatch::tests`).
    #[test]
    fn verified_provenance_label_round_trips_into_the_gates_claim_parsing() {
        let p = Provenance::Verified {
            tool_use_id: "toolu_01REALSHAPE".into(),
        };
        let label = p.label();
        write_handoff(&tmp_root(), 131, &label);
        assert_eq!(
            dispatch::claimed_tool_use_id(&label),
            Some("toolu_01REALSHAPE".to_string())
        );
    }
}
