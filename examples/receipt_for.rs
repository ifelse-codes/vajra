//! Price a past session: print Vajra's receipt for any Claude Code transcript on disk.
//!
//! `cargo run --example receipt_for -- ~/.claude/projects/<slug>/<uuid>.jsonl`
//!
//! Kept because a cost claim you cannot re-run is not a cost claim (S171): this is what produced
//! the $19.25-against-Claude-Code's-$19.56 check on the founder's own session.
use std::path::PathBuf;

fn main() {
    let path = PathBuf::from(std::env::args().nth(1).expect("usage: receipt_for <jsonl>"));
    let cost = vajractl::meter::meter_session(&path, None, None).expect("meter");
    print!("{}", vajractl::meter::format_receipt(&cost));
}
