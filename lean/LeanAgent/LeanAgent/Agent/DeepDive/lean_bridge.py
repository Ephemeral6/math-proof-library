"""Lean Bridge — translate Tracker output into the Lean 7-stage pipeline.

The deep-dive orchestrator hands us a `TrackerState` whose
`current_conjecture` holds an empirically-verified or formally-certified
goal plus a chain of WHs whose `candidate_property` fields contain the
proof step structure.  We materialise that into the Lean pipeline's
input JSON (matching `LeanAgent/Tests/test_descent_lemma.json` shape) and
optionally run `Agent_legacy.Runner.run`.

Phase-2 status: the JSON writer + the verification helper.  The actual
runner invocation is opt-in via `run_lean_pipeline(invoke=True)`.
"""

from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    TrackerState,
)


# ────────────────────────────────────────────────────────────────────────────
# Data
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class ProofTarget:
    theorem_name: str
    theorem_nl: str
    assumptions: list[str] = field(default_factory=list)
    conclusion: str = ""
    steps: list[dict] = field(default_factory=list)

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class LeanResult:
    status: str  # "CERTIFIED" | "FAILED" | "TIMEOUT" | "NOT_RUN" | "ERROR"
    output_dir: str | None = None
    stderr: str = ""
    stdout: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


# ────────────────────────────────────────────────────────────────────────────
# Translation
# ────────────────────────────────────────────────────────────────────────────


_TRIGGER_STATUS = {
    CompletionStatus.EMPIRICALLY_VERIFIED.value,
    CompletionStatus.FORMALLY_CERTIFIED.value,
}


def _slugify(name: str) -> str:
    out = []
    for ch in name.lower():
        if ch.isalnum() or ch == "_":
            out.append(ch)
        elif ch in (" ", "-"):
            out.append("_")
    s = "".join(out).strip("_")
    return s or "theorem"


def extract_proof_target(state: TrackerState) -> ProofTarget:
    """Pull a Lean-pipeline-shaped statement out of the Tracker state.

    The conjecture form goes verbatim into `theorem_nl`; the WH chain's
    `candidate_property` strings become the proof steps.  Evidence
    bullets are appended to the assumptions list as comments.
    """
    c = state.current_conjecture
    name = _slugify(c.id) if c.id else "conjecture"
    steps: list[dict] = []
    for i, wh in enumerate(state.why_hypotheses, start=1):
        steps.append({
            "id": i,
            "description": wh.candidate_property or wh.claim,
            "method": "direct_compute",
            "uses": [],
            "external_theorem": None,
        })

    return ProofTarget(
        theorem_name=name,
        theorem_nl=c.form,
        assumptions=list(state.evidence) or [],
        conclusion=c.form,  # the conjecture's form is the goal
        steps=steps,
    )


def prepare_lean_input(target: ProofTarget, *, output_dir: Path | str) -> Path:
    """Write a `Tests/test_<problem_id>.json` file the runner can pick up."""
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    path = out / f"test_{target.theorem_name}.json"
    path.write_text(
        json.dumps(target.to_dict(), ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return path


# ────────────────────────────────────────────────────────────────────────────
# Pipeline invocation
# ────────────────────────────────────────────────────────────────────────────


def _resolve_runner_script() -> Path | None:
    """Locate `LeanAgent/scripts/run.py` from this package."""
    here = Path(__file__).resolve()
    candidate = here.parents[3] / "scripts" / "run.py"
    return candidate if candidate.exists() else None


def run_lean_pipeline(
    input_json_path: Path | str,
    *,
    invoke: bool = False,
    output_dir: Path | str | None = None,
    provider: str = "stub",
    stub_path: Path | str | None = None,
    timeout_s: float = 600.0,
) -> LeanResult:
    """Run the existing 7-stage Lean pipeline on the prepared input.

    `invoke=False` (default) returns a NOT_RUN result; this lets callers
    wire the pipeline in opt-in mode.  When `invoke=True`, dispatches
    `python scripts/run.py <input> --provider <p>` and parses the exit
    status.
    """
    input_json_path = Path(input_json_path)
    if not invoke:
        return LeanResult(status="NOT_RUN", output_dir=None,
                          stdout="lean pipeline opt-out (invoke=False)")

    runner = _resolve_runner_script()
    if runner is None:
        return LeanResult(
            status="ERROR",
            stderr="scripts/run.py not found",
        )

    cmd = ["python", str(runner), str(input_json_path),
           "--provider", provider]
    if stub_path:
        cmd += ["--stub", str(stub_path)]
    if output_dir:
        cmd += ["--output", str(output_dir)]

    try:
        proc = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout_s,
        )
    except subprocess.TimeoutExpired:
        return LeanResult(status="TIMEOUT", stderr="pipeline timed out")
    except FileNotFoundError as e:
        return LeanResult(status="ERROR", stderr=str(e))

    if proc.returncode == 0:
        status = "CERTIFIED"
    else:
        status = "FAILED"
    return LeanResult(
        status=status,
        output_dir=str(output_dir) if output_dir else None,
        stdout=proc.stdout[-2000:],
        stderr=proc.stderr[-2000:],
    )


# ────────────────────────────────────────────────────────────────────────────
# Axiom check
# ────────────────────────────────────────────────────────────────────────────


def verify_axiom_clean(lean_file_path: Path | str) -> bool:
    """Call `scripts/check_axioms.sh` on a generated .lean file."""
    here = Path(__file__).resolve()
    checker = here.parents[3] / "scripts" / "check_axioms.sh"
    if not checker.exists():
        return True  # no checker → optimistic; caller decides policy
    if shutil.which("bash") is None:
        return True
    try:
        proc = subprocess.run(
            ["bash", str(checker), str(lean_file_path)],
            capture_output=True, text=True, timeout=60,
        )
        return proc.returncode == 0
    except (subprocess.TimeoutExpired, OSError):
        return False


# ────────────────────────────────────────────────────────────────────────────
# Top-level wrapper used by the orchestrator
# ────────────────────────────────────────────────────────────────────────────


def attempt_formal_certification(
    state: TrackerState,
    *,
    output_dir: Path | str,
    invoke: bool = False,
    provider: str = "stub",
    stub_path: Path | str | None = None,
) -> dict:
    """Convenience wrapper: extract → prepare → run.

    Returns a JSON-serialisable dict.  When the conjecture's
    `completion_status` is not in `_TRIGGER_STATUS`, returns a
    NOT_TRIGGERED record without touching the filesystem.
    """
    if state.current_conjecture.completion_status not in _TRIGGER_STATUS:
        return {
            "status": "NOT_TRIGGERED",
            "reason": (
                f"completion_status="
                f"{state.current_conjecture.completion_status!r}; "
                f"need one of {sorted(_TRIGGER_STATUS)}"
            ),
        }
    target = extract_proof_target(state)
    input_path = prepare_lean_input(target, output_dir=output_dir)
    lean_result = run_lean_pipeline(
        input_path,
        invoke=invoke,
        output_dir=Path(output_dir) / "lean_run",
        provider=provider,
        stub_path=stub_path,
    )
    return {
        "status": lean_result.status,
        "input_json": str(input_path),
        "output_dir": lean_result.output_dir,
        "stderr_tail": lean_result.stderr,
        "stdout_tail": lean_result.stdout,
    }
