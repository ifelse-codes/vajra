# Arm A vs Arm B — dist-build deliverable comparison

## package.json build script + devDeps: IDENTICAL between arms
## build.mjs + tsconfig.build.json: cosmetic diffs only (comments, var names, sourcemaps, which base tsconfig)
## Both shipped the SAME .tsbuildinfo non-reproducible-.d.ts defect (chitra base tsconfig incremental:true).
## Arm A landed to chitra with 1 correction folded in: incremental:false.
