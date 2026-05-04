"""End-to-End Runner — Scout → Deep Dive → (Lean) → Novelty.

Phase 3 — P3-C.

Usage:
    python -m LeanAgent.LeanAgent.Agent.runner \
        --input problems.json \
        --output results/ \
        --top-k 3 \
        --lean-enabled \
        --max-iterations 7 \
        --stub-mode
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any

from LeanAgent.LeanAgent.Agent.DeepDive import lean_bridge as lb
from LeanAgent.LeanAgent.Agent.DeepDive.orchestrator import (
    DeepDiveConfig,
    DeepDiveResult,
    deep_dive,
)
from LeanAgent.LeanAgent.Agent.Scout import novelty_verifier as nv


# ────────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class RunnerConfig:
    top_k: int = 3
    lean_enabled: bool = False
    novelty_enabled: bool = True
    stub_mode: bool = True
    deep_dive_config: DeepDiveConfig = field(default_factory=DeepDiveConfig)


@dataclass
class Result:
    problem_id: str
    scout_report: dict | None = None
    deep_dive: dict | None = None
    lean_status: dict | None = None
    novelty: dict | None = None

    def to_dict(self) -> dict:
        return asdict(self)


# ────────────────────────────────────────────────────────────────────────────
# Lightweight scout shim
# ────────────────────────────────────────────────────────────────────────────


def _scout_problem(problem: dict) -> dict:
    """Per scout_mode.md §D — emit a tractability_report.

    Stub-only implementation: declares everything `pass × medium` and
    recommends `deep_dive`.  The real scout module (Phase-1) lives in
    `LeanAgent/LeanAgent/Agent/Scout/` and would replace this.
    """
    return {
        "problem_id": problem.get("problem_id", "unknown"),
        "scout_outcome": "pass",
        "scout_evidence": "stub-scout: anchor passed",
        "scout_wh": {
            "claim": problem.get("goal", ""),
            "candidate_property": problem.get(
                "candidate_property",
                "stub-WH candidate",
            ),
        },
        "scout_rep_id": problem.get("rep_hint") or "rep_unknown",
        "estimated_difficulty": "medium",
        "difficulty_signals": {
            "verifier_runtime_s": 0.01,
            "rep_tools_status": "available",
            "wh_anchor_size": 1,
            "registry_hits": 0,
        },
        "recommended_action": "deep_dive",
        "ts": _now_iso(),
    }


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _difficulty_rank(rep: str) -> int:
    return {"shallow": 0, "medium": 1, "deep": 2, "intractable": 3}.get(rep, 99)


# ────────────────────────────────────────────────────────────────────────────
# Top-level batch entry
# ────────────────────────────────────────────────────────────────────────────


def run_batch(
    problems: list[dict],
    *,
    config: RunnerConfig | None = None,
) -> list[Result]:
    config = config or RunnerConfig()

    if config.stub_mode:
        os.environ["BRIDGE_STUB"] = "1"
        os.environ["NOVELTY_STUB"] = "1"

    # ── Phase 1: Scout all ─────────────────────────────────────────────
    scout_reports = [_scout_problem(p) for p in problems]
    paired = list(zip(problems, scout_reports))
    paired.sort(
        key=lambda pr: _difficulty_rank(
            pr[1].get("estimated_difficulty", "deep")
        )
    )

    results: list[Result] = []

    # ── Phase 2: deep dive top-K ──────────────────────────────────────
    for problem, scout in paired[: max(0, config.top_k)]:
        if scout.get("recommended_action") not in ("deep_dive", "publish"):
            results.append(Result(
                problem_id=problem.get("problem_id", "unknown"),
                scout_report=scout,
            ))
            continue

        dd_result: DeepDiveResult = deep_dive(
            problem,
            scout_result=scout,
            config=config.deep_dive_config,
        )

        # ── Phase 3a: Lean pipeline ──────────────────────────────────
        lean_status: dict | None = None
        if config.lean_enabled and dd_result.state is not None:
            output_dir = Path("workspace") / "active" / (
                f"e2e_{problem.get('problem_id', 'unk')}_"
                f"{_now_iso().replace(':', '').replace('-', '')}"
            )
            lean_status = lb.attempt_formal_certification(
                dd_result.state,
                output_dir=output_dir,
                invoke=False,  # opt-out by default; runner is a stub
            )

        # ── Phase 3b: Novelty verifier ───────────────────────────────
        novelty: dict | None = None
        if config.novelty_enabled and dd_result.state is not None:
            verdict = nv.run_novelty_check(dd_result.state)
            novelty = verdict.to_dict()

        results.append(Result(
            problem_id=problem.get("problem_id", "unknown"),
            scout_report=scout,
            deep_dive=dd_result.to_dict(),
            lean_status=lean_status,
            novelty=novelty,
        ))

    return results


# ────────────────────────────────────────────────────────────────────────────
# CLI
# ────────────────────────────────────────────────────────────────────────────


def _build_argparser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="LeanAgent.runner",
        description="End-to-end Scout → Deep Dive → Lean → Novelty pipeline.",
    )
    p.add_argument("--input", required=True,
                   help="JSON file with a list of problem dicts.")
    p.add_argument("--output", required=True,
                   help="Output directory for results.")
    p.add_argument("--top-k", type=int, default=3)
    p.add_argument("--lean-enabled", action="store_true")
    p.add_argument("--no-novelty", action="store_true")
    p.add_argument("--max-iterations", type=int, default=7)
    p.add_argument("--stub-mode", action="store_true",
                   help="Set BRIDGE_STUB / NOVELTY_STUB.")
    return p


def _load_problems(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    if isinstance(data, dict) and "problems" in data:
        return list(data["problems"])
    if isinstance(data, list):
        return list(data)
    raise ValueError(f"unsupported input shape in {path}")


def main(argv: list[str] | None = None) -> int:
    args = _build_argparser().parse_args(argv)
    in_path = Path(args.input)
    out_dir = Path(args.output)
    out_dir.mkdir(parents=True, exist_ok=True)

    problems = _load_problems(in_path)
    cfg = RunnerConfig(
        top_k=args.top_k,
        lean_enabled=args.lean_enabled,
        novelty_enabled=not args.no_novelty,
        stub_mode=args.stub_mode,
        deep_dive_config=DeepDiveConfig(max_iterations=args.max_iterations),
    )
    results = run_batch(problems, config=cfg)
    out_file = out_dir / f"results_{_now_iso().replace(':', '')}.json"
    out_file.write_text(
        json.dumps([r.to_dict() for r in results], ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"wrote {len(results)} results → {out_file}")
    return 0


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
