//! Scratch: print the receipt for a transcript file. `cargo run --example receipt_for -- <path>`
use std::path::PathBuf;

fn main() {
    let path = PathBuf::from(std::env::args().nth(1).expect("usage: receipt_for <jsonl>"));
    let cost = vajractl::meter::meter_session(&path, None, None).expect("meter");
    print!("{}", vajractl::meter::format_receipt(&cost));
}
