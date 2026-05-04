#!/usr/bin/env bash
# init_child.sh — scaffold a child lemma file for recursive synthesis.
#
# Usage:
#   scripts/init_child.sh <child-name> <parent-run-dir>
#
# Effects:
#   1. Creates LeanAgent/Generated/<child-name>.lean with a minimal header
#      and a `sorry` body. (If the file already exists, refuses; pass
#      INIT_CHILD_FORCE=1 to overwrite.)
#   2. Ensures <parent-run-dir>/children/<child-name>/ exists; writes a
#      stub input.json keyed by metadata so the child run dir mirrors the
#      parent layout described in protocols/recursive_synthesis.md.
#   3. Appends a {"event":"descend",...} line to <parent-run-dir>/recursion_log.jsonl
#      with the timestamp now.
#
# Notes:
#   - The signature in the .lean file is a placeholder; Claude Code MUST
#     edit it to the real lemma signature before compiling. The placeholder
#     is what the user sees if they run lake build prematurely.
#   - Exits 0 on success, 1 on usage / IO error.

set -u
export PATH="$HOME/.elan/bin:$PATH"

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJ_ROOT" || exit 1

if [[ $# -lt 2 ]]; then
  echo "usage: scripts/init_child.sh <child-name> <parent-run-dir>" >&2
  exit 1
fi

CHILD="$1"
PARENT_RUN="$2"

# Sanitize child name — must be a valid Lean identifier (letters, digits,
# underscores; no dots or slashes — the user passes the bare name).
if ! [[ "$CHILD" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "[init_child.sh] invalid child name: $CHILD (must match [A-Za-z_][A-Za-z0-9_]*)" >&2
  exit 1
fi

if [[ ! -d "$PARENT_RUN" ]]; then
  echo "[init_child.sh] parent run dir not found: $PARENT_RUN" >&2
  exit 1
fi

LEAN_FILE="LeanAgent/Generated/${CHILD}.lean"
if [[ -f "$LEAN_FILE" && "${INIT_CHILD_FORCE:-0}" != "1" ]]; then
  echo "[init_child.sh] $LEAN_FILE already exists. Set INIT_CHILD_FORCE=1 to overwrite." >&2
  exit 1
fi

CHILD_RUN_DIR="$PARENT_RUN/children/$CHILD"
mkdir -p "$CHILD_RUN_DIR"

TS="$(date +%Y-%m-%dT%H:%M:%S%z)"
PARENT_NAME="$(basename "$PARENT_RUN" | sed 's/_[0-9]*_[0-9]*$//')"

# Step 1 — child .lean placeholder.
cat > "$LEAN_FILE" <<EOF
/-
Synthesized helper lemma — child of \`${PARENT_NAME}\`.
Generated: ${TS}
NOTE: this is a placeholder. Replace the signature with the real lemma
before running lake build.
-/
import Mathlib

namespace LeanAgent.Generated

theorem ${CHILD} : True := by
  sorry

end LeanAgent.Generated
EOF

# Step 2 — child input.json stub.
cat > "$CHILD_RUN_DIR/input.json" <<EOF
{
  "theorem_name": "${CHILD}",
  "theorem_nl": "TODO: fill from parent goal state",
  "assumptions": [],
  "conclusion": "TODO: fill from parent goal state",
  "steps": [
    {
      "id": 1,
      "description": "Synthesized helper for parent ${PARENT_NAME}; user-provided proof skeleton not available.",
      "method": "apply_theorem",
      "uses": [],
      "external_theorem": null
    }
  ],
  "metadata": {
    "source": "synthesized:recursive_dependency",
    "parent_lemma": "${PARENT_NAME}",
    "parent_run_dir": "${PARENT_RUN}",
    "ts": "${TS}"
  }
}
EOF

# Step 3 — recursion_log descend event.
LOG="$PARENT_RUN/recursion_log.jsonl"
touch "$LOG"

# Read current depth: count existing descend events in log + 1, fall back to 1.
DEPTH=1
if [[ -s "$LOG" ]]; then
  ACTIVE="$(grep -c '"event":"descend"' "$LOG" 2>/dev/null || echo 0)"
  CLOSED="$(grep -cE '"event":"(certify|fail|cycle|depth_limit)"' "$LOG" 2>/dev/null || echo 0)"
  DEPTH=$(( ACTIVE - CLOSED + 1 ))
  if [[ $DEPTH -lt 1 ]]; then DEPTH=1; fi
fi

echo "{\"event\":\"descend\",\"parent\":\"${PARENT_NAME}\",\"child\":\"${CHILD}\",\"depth\":${DEPTH},\"ts\":\"${TS}\"}" >> "$LOG"

echo "[init_child.sh] OK"
echo "  lean file:    $LEAN_FILE"
echo "  child run:    $CHILD_RUN_DIR"
echo "  recursion:    descend event appended (depth=${DEPTH})"
echo "  next step:    edit signature in $LEAN_FILE, then run scripts/compile.sh ${CHILD}"
exit 0
