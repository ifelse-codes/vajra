//! Varta render — one-way generation of `vajra.varta` from the live `.ai/`.
//!
//! S24: a persisted `.varta` returns *only* because it can be generated (the S19
//! condition). The on-disk file is never hand-edited; it is regenerated from `.ai/`
//! and drift-guarded by `vajra check` (the S22 `cmp` pattern). One source of truth.

pub mod render;

pub use render::{render_from_root, RENDER_PATH};
