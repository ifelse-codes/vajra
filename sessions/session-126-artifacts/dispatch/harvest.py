#!/usr/bin/env python3
"""S126 — harvest + cross-check ONE headless dispatch (the S111 two-file check).

Given a role key and the headless run's JSON result, this pulls THREE files Claude Code itself
wrote and requires the two independent ones to agree on the same random tool-call id:
  1. the parent session transcript  ~/.claude/projects/<slug>/<session_id>.jsonl
  2. the subagent's own meta.json   ~/.claude/projects/<slug>/<session_id>/subagents/agent-*.meta.json
  3. the subagent's raw transcript  (same subagents/ dir, agent-*.jsonl)
Exits non-zero if they do not agree, if the subagent_type is not the role, or if the subagent
transcript carries no real assistant usage line.
"""
import glob, hashlib, json, os, sys

role, run_json, outdir = sys.argv[1], sys.argv[2], sys.argv[3]
run = json.load(open(run_json))
sid = run["session_id"]
proj = os.path.expanduser("~/.claude/projects/-Users-suman-playground-vajra")
parent_path = os.path.join(proj, sid + ".jsonl")
sub_dir = os.path.join(proj, sid, "subagents")

# --- 1. the parent's own tool_use record, extracted verbatim -------------------------------------
tool_uses = []
for line in open(parent_path):
    line = line.strip()
    if not line:
        continue
    v = json.loads(line)
    msg = v.get("message") or {}
    for block in (msg.get("content") or []) if isinstance(msg.get("content"), list) else []:
        if isinstance(block, dict) and block.get("type") == "tool_use" and block.get("name") == "Agent":
            if (block.get("input") or {}).get("subagent_type") == role:
                tool_uses.append({"type": "tool_use", "id": block["id"], "name": block["name"],
                                  "input": block["input"], "parent_timestamp": v.get("timestamp"),
                                  "parent_sessionId": v.get("sessionId"), "cwd": v.get("cwd")})
if not tool_uses:
    print(f"FAIL: no Agent tool_use with subagent_type={role!r} in {parent_path}"); sys.exit(1)
tu = tool_uses[0]

# --- 2. the subagent's own meta.json, written by a different part of the runtime ------------------
meta = None
meta_path = None
for p in glob.glob(os.path.join(sub_dir, "*.meta.json")):
    m = json.load(open(p))
    if m.get("agentType") == role and m.get("toolUseId") == tu["id"]:
        meta, meta_path = m, p
        break
if meta is None:
    print(f"FAIL: no meta.json in {sub_dir} with agentType={role!r} and toolUseId={tu['id']!r}")
    sys.exit(1)

# --- 3. the subagent's raw transcript, with real usage -------------------------------------------
tpath = meta_path[: -len(".meta.json")] + ".jsonl"
if not os.path.exists(tpath):
    print(f"FAIL: no subagent transcript at {tpath}"); sys.exit(1)
found_usage = False
for line in open(tpath):
    line = line.strip()
    if not line:
        continue
    v = json.loads(line)
    if v.get("type") == "assistant" and (v.get("message") or {}).get("usage"):
        found_usage = True
if not found_usage:
    print("FAIL: subagent transcript has no assistant line with real usage"); sys.exit(1)

os.makedirs(outdir, exist_ok=True)
json.dump([tu], open(os.path.join(outdir, f"{role}-parent-tooluse.json"), "w"), indent=2)
json.dump(meta, open(os.path.join(outdir, f"{role}-subagent-meta.json"), "w"), indent=2)
open(os.path.join(outdir, f"{role}-subagent-transcript.jsonl"), "w").write(open(tpath).read())
open(os.path.join(outdir, f"{role}-brief.md"), "w").write(run.get("result") or "")
sha = hashlib.sha256(open(tpath, "rb").read()).hexdigest()
print(f"OK {role}: parent tool_use.id == subagent meta.toolUseId == {tu['id']}")
print(f"   parent session   : {sid}  ({tu.get('parent_timestamp')})")
print(f"   transcript sha256: {sha}  ({sum(1 for _ in open(tpath))} lines)")
print(f"   run cost_usd     : {run.get('total_cost_usd')}")
