"""Scout Verifier — dispatcher for the 1-step Verifier.

Three modes per scout_mode.md / instance_sorter.md / geometric_reasoner.md §6.3:
  - python_cli   : run a Python script, parse stdout
  - lean_compile : invoke LeanAgent/scripts/compile.sh -f <file>
  - engine_call  : in-process call into a registered engine (e.g. surface_geo)

`verifier_command` shape:
  - str                      → python_cli (legacy: assume `python <args>`)
  - dict {kind: "lean_compile", path: ...}
  - dict {kind: "engine_call", engine, op, kwargs}
  - dict {kind: "python_cli",  argv: [...]}

VerifierResult.actual_outcome ∈ {"pass", "fail", "mixed", "error", "timeout"}
"""

from __future__ import annotations

import importlib
import shlex
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from .instance_sorter import TestPlanStep


# Repo root: …/Math
_REPO_ROOT = Path(__file__).resolve().parents[4]
_COMPILE_SH = _REPO_ROOT / "LeanAgent" / "scripts" / "compile.sh"


@dataclass
class VerifierResult:
    actual_outcome: str
    actual_evidence: str
    runtime_s: float
    raw_stdout: str = ""
    raw_stderr: str = ""
    returncode: int | None = None


def _run_subprocess(
    argv: list[str],
    *,
    timeout_s: float,
    cwd: Path | None = None,
) -> tuple[int, str, str, float, bool]:
    """Returns (returncode, stdout, stderr, runtime_s, timed_out)."""
    t0 = time.time()
    timed_out = False
    try:
        proc = subprocess.run(
            argv,
            cwd=str(cwd or _REPO_ROOT),
            capture_output=True,
            text=True,
            timeout=timeout_s,
        )
        rc = proc.returncode
        out, err = proc.stdout or "", proc.stderr or ""
    except subprocess.TimeoutExpired as e:
        rc = -1
        out = e.stdout.decode("utf-8", "replace") if isinstance(e.stdout, bytes) else (e.stdout or "")
        err = e.stderr.decode("utf-8", "replace") if isinstance(e.stderr, bytes) else (e.stderr or "")
        timed_out = True
    except FileNotFoundError as e:
        rc = -2
        out = ""
        err = f"FileNotFoundError: {e}"
    runtime = time.time() - t0
    return rc, out, err, runtime, timed_out


def _dispatch_python_cli(cmd: str | dict, *, timeout_s: float) -> VerifierResult:
    if isinstance(cmd, str):
        # Always posix-split: simpler, handles quoted paths with backslashes
        # (verified on Windows). Callers needing Windows-cmd quoting should
        # use the dict {kind: "python_cli", argv: [...]} form.
        argv = shlex.split(cmd)
        # If the first token is "python" / "python3", redirect to current interpreter.
        if argv and argv[0] in ("python", "python3", "python.exe"):
            argv = [sys.executable] + argv[1:]
    else:
        argv = list(cmd.get("argv") or [])
        if not argv:
            return VerifierResult(
                actual_outcome="error",
                actual_evidence="python_cli: empty argv",
                runtime_s=0.0,
            )
        if argv[0] in ("python", "python3", "python.exe"):
            argv = [sys.executable] + argv[1:]

    rc, out, err, t, timed_out = _run_subprocess(argv, timeout_s=timeout_s)
    if timed_out:
        return VerifierResult(
            actual_outcome="timeout",
            actual_evidence=f"timed out after {timeout_s}s",
            runtime_s=t,
            raw_stdout=out,
            raw_stderr=err,
            returncode=rc,
        )
    if rc == 0:
        outcome = "pass"
        evidence = (out.strip().splitlines() or [""])[-1][:400] or "exit code 0"
    else:
        outcome = "fail"
        evidence = (err.strip().splitlines() or out.strip().splitlines() or [""])[-1][:400] or f"exit code {rc}"
    return VerifierResult(
        actual_outcome=outcome,
        actual_evidence=evidence,
        runtime_s=t,
        raw_stdout=out,
        raw_stderr=err,
        returncode=rc,
    )


def _dispatch_lean_compile(cmd: dict, *, timeout_s: float) -> VerifierResult:
    path = cmd.get("path") or cmd.get("file")
    if not path:
        return VerifierResult(
            actual_outcome="error",
            actual_evidence="lean_compile: missing 'path' or 'file' in command",
            runtime_s=0.0,
        )
    argv = ["bash", str(_COMPILE_SH), "-f", str(path)]
    rc, out, err, t, timed_out = _run_subprocess(argv, timeout_s=timeout_s)
    if timed_out:
        return VerifierResult(
            actual_outcome="timeout",
            actual_evidence=f"compile.sh timed out after {timeout_s}s",
            runtime_s=t,
            raw_stdout=out,
            raw_stderr=err,
            returncode=rc,
        )
    if rc == 0:
        outcome = "pass"
        evidence = "compile.sh exit 0"
    elif rc == 124:
        outcome = "timeout"
        evidence = "compile.sh exit 124 (compile timed out)"
    else:
        outcome = "fail"
        last_err = (err.strip().splitlines() or out.strip().splitlines() or [""])[-1]
        evidence = f"compile.sh exit {rc}: {last_err[:300]}"
    return VerifierResult(
        actual_outcome=outcome,
        actual_evidence=evidence,
        runtime_s=t,
        raw_stdout=out,
        raw_stderr=err,
        returncode=rc,
    )


def _dispatch_engine_call(cmd: dict) -> VerifierResult:
    engine = cmd.get("engine")
    op = cmd.get("op")
    kwargs = cmd.get("kwargs") or {}
    if not engine or not op:
        return VerifierResult(
            actual_outcome="error",
            actual_evidence="engine_call: missing 'engine' or 'op'",
            runtime_s=0.0,
        )
    t0 = time.time()
    try:
        # Locate the module. Engines are wired via a small registry; the
        # default mapping points at workspace/projects/op1_geometry.
        engine_mod = _resolve_engine(engine)
        if engine_mod is None:
            return VerifierResult(
                actual_outcome="error",
                actual_evidence=f"engine_call: unknown engine {engine!r}",
                runtime_s=time.time() - t0,
            )
        fn = getattr(engine_mod, op, None)
        if fn is None or not callable(fn):
            return VerifierResult(
                actual_outcome="error",
                actual_evidence=f"engine_call: {engine}.{op} not callable",
                runtime_s=time.time() - t0,
            )
        result = fn(**kwargs)
        evidence = repr(result)[:400]
        return VerifierResult(
            actual_outcome="pass",
            actual_evidence=evidence,
            runtime_s=time.time() - t0,
        )
    except Exception as e:
        return VerifierResult(
            actual_outcome="fail",
            actual_evidence=f"{type(e).__name__}: {str(e)[:300]}",
            runtime_s=time.time() - t0,
        )


def _resolve_engine(engine_name: str):
    """Maps engine name → Python module. Failure returns None."""
    candidates = {
        "surface_geo": "workspace.projects.op1_geometry.surface_geo",
        "scout_test_engine": "LeanAgent.LeanAgent.Agent.Scout.tests._engine_fixture",
    }
    mod_path = candidates.get(engine_name)
    if mod_path is None:
        return None
    try:
        return importlib.import_module(mod_path)
    except ImportError:
        return None


def dispatch(step: TestPlanStep, *, timeout_s: float = 60.0) -> VerifierResult:
    """Public entry point. Reads `step.verifier_command` and routes."""
    cmd = step.verifier_command
    if isinstance(cmd, str):
        return _dispatch_python_cli(cmd, timeout_s=timeout_s)
    if isinstance(cmd, dict):
        kind = cmd.get("kind", "python_cli")
        if kind == "python_cli":
            return _dispatch_python_cli(cmd, timeout_s=timeout_s)
        if kind == "lean_compile":
            return _dispatch_lean_compile(cmd, timeout_s=timeout_s)
        if kind == "engine_call":
            return _dispatch_engine_call(cmd)
        return VerifierResult(
            actual_outcome="error",
            actual_evidence=f"verifier: unknown kind {kind!r}",
            runtime_s=0.0,
        )
    return VerifierResult(
        actual_outcome="error",
        actual_evidence=f"verifier: bad verifier_command type {type(cmd).__name__}",
        runtime_s=0.0,
    )
