#!/usr/bin/env bash
# compile.sh — compile a Lean module under LeanAgent.Generated.* via lake.
#
# Usage:
#   scripts/compile.sh <module-name>           # e.g. strong_convex_gradient_lower_bound
#   scripts/compile.sh -f <relative-lean-path> # e.g. LeanAgent/Generated/foo.lean
#
# Exits 0 on clean compile, 1 on compile error, 2 on usage error,
# 124 on timeout (default 600s, override with COMPILE_TIMEOUT=<seconds>).
#
# stderr is captured and re-emitted to stdout with the [stderr] prefix so
# Claude Code reads errors in a single stream.

set -u
export PATH="$HOME/.elan/bin:$PATH"

PROJ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJ_ROOT" || exit 2

if [[ $# -lt 1 ]]; then
  echo "usage: scripts/compile.sh <module-name> | -f <relative-lean-path>" >&2
  exit 2
fi

MODE="module"
TARGET="$1"
if [[ "$1" == "-f" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "usage: scripts/compile.sh -f <relative-lean-path>" >&2
    exit 2
  fi
  MODE="file"
  TARGET="$2"
fi

TIMEOUT_SECS="${COMPILE_TIMEOUT:-600}"

echo "[compile.sh] mode=$MODE target=$TARGET timeout=${TIMEOUT_SECS}s"

START=$(date +%s)
TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_OUT"' EXIT

if [[ "$MODE" == "module" ]]; then
  CMD=(lake build "LeanAgent.Generated.${TARGET}")
else
  CMD=(lake env lean "$TARGET")
fi

# Prefer GNU timeout if available; fall back to no-timeout (the harness
# wraps us anyway).
if command -v timeout >/dev/null 2>&1; then
  timeout --kill-after=10 "${TIMEOUT_SECS}" "${CMD[@]}" >"$TMP_OUT" 2>&1
  RC=$?
else
  "${CMD[@]}" >"$TMP_OUT" 2>&1
  RC=$?
fi

END=$(date +%s)
ELAPSED=$((END - START))

cat "$TMP_OUT"

if [[ $RC -eq 124 ]]; then
  echo "[compile.sh] TIMEOUT after ${TIMEOUT_SECS}s"
  exit 124
elif [[ $RC -eq 0 ]]; then
  echo "[compile.sh] OK in ${ELAPSED}s"
  exit 0
else
  echo "[compile.sh] FAIL rc=$RC in ${ELAPSED}s"
  exit 1
fi
