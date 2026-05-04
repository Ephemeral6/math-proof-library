#!/usr/bin/env bash
# check_axioms.sh — verify a Lean theorem closes only over the trusted core.
#
# Usage:
#   scripts/check_axioms.sh <relative-lean-path> <theorem-name>
#
# Behaviour:
#   1. Builds the module (so its .olean exists).
#   2. Creates a temp .lean file that imports the module and runs
#      `#print axioms <theorem-name>`.
#   3. Captures the output.
#   4. Verifies the printed axioms are EXACTLY some subset of:
#        propext, Classical.choice, Quot.sound
#      Any other axiom (e.g. sorryAx, sorry, Lean.ofReduceBool) is a fail.
#
# Exits 0 if the theorem is "axiom-clean", 1 otherwise, 2 on usage error.

set -u
export PATH="$HOME/.elan/bin:$PATH"

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJ_ROOT" || exit 2

if [[ $# -lt 2 ]]; then
  echo "usage: scripts/check_axioms.sh <relative-lean-path> <theorem-name>" >&2
  exit 2
fi

LEAN_PATH="$1"
THEOREM="$2"

if [[ ! -f "$LEAN_PATH" ]]; then
  echo "[check_axioms.sh] file not found: $LEAN_PATH" >&2
  exit 2
fi

# Map relative path -> module name. Strips the leading "LeanAgent/", trailing
# ".lean", and converts slashes to dots.
MODULE_REL="${LEAN_PATH#LeanAgent/}"
MODULE_REL="${MODULE_REL%.lean}"
MODULE="LeanAgent.${MODULE_REL//\//.}"

echo "[check_axioms.sh] module=$MODULE theorem=$THEOREM"

# Step 1 — build the module so its olean is fresh.
if ! lake build "$MODULE" >/dev/null 2>&1; then
  echo "[check_axioms.sh] underlying build failed; cannot inspect axioms" >&2
  lake build "$MODULE" 2>&1 | tail -20
  exit 1
fi

# Step 2 — write a probe file under the project so the module path resolves.
PROBE_DIR="output/_axiom_probe"
mkdir -p "$PROBE_DIR"
PROBE_FILE="$PROBE_DIR/probe_$$_$(date +%s).lean"
{
  echo "import $MODULE"
  echo "#print axioms $THEOREM"
} > "$PROBE_FILE"

OUT="$(lake env lean "$PROBE_FILE" 2>&1)"
RC=$?
rm -f "$PROBE_FILE"

echo "$OUT"
if [[ $RC -ne 0 ]]; then
  echo "[check_axioms.sh] probe compile failed (rc=$RC)"
  exit 1
fi

# Step 3 — parse axioms. Lean prints e.g.
#   '<theorem>' depends on axioms: [propext, Classical.choice, Quot.sound]
# or "no axioms" if the theorem is axiom-free.
AXIOM_LINE="$(echo "$OUT" | grep -E "depends on axioms|no axioms" | tail -1)"
if [[ -z "$AXIOM_LINE" ]]; then
  echo "[check_axioms.sh] FAIL: could not find an axioms line in the output" >&2
  exit 1
fi

if echo "$AXIOM_LINE" | grep -q "no axioms"; then
  echo "[check_axioms.sh] OK: $THEOREM depends on no axioms"
  exit 0
fi

# Extract the bracketed list and split on commas.
LIST="$(echo "$AXIOM_LINE" | sed -n 's/.*\[\(.*\)\].*/\1/p')"
if [[ -z "$LIST" ]]; then
  echo "[check_axioms.sh] FAIL: could not parse the axioms list" >&2
  exit 1
fi

ALLOWED="propext Classical.choice Quot.sound"
BAD=()
for raw in ${LIST//,/ }; do
  ax="$(echo "$raw" | tr -d ' ')"
  case " $ALLOWED " in
    *" $ax "*) ;;
    *) BAD+=("$ax") ;;
  esac
done

if [[ ${#BAD[@]} -gt 0 ]]; then
  echo "[check_axioms.sh] FAIL: $THEOREM uses disallowed axiom(s): ${BAD[*]}"
  exit 1
fi

echo "[check_axioms.sh] OK: $THEOREM closes over a subset of {propext, Classical.choice, Quot.sound}"
exit 0
