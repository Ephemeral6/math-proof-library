"""Tractability Report — scout exit artefact.

Spec: workspace/agents_spec/scout_mode.md §D.

Schema fields: problem_id, scout_outcome, scout_evidence, scout_wh,
scout_rep_id, estimated_difficulty, difficulty_signals, recommended_action, ts.
"""

from __future__ import annotations

import datetime as _dt
import json
from dataclasses import dataclass, field, asdict
from pathlib import Path

from .hypothesis_tracker import TrackerState


# Per spec §D.2 — heuristic thresholds; tunable per domain.
SHALLOW_RUNTIME_S = 5.0
MEDIUM_RUNTIME_S = 60.0


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


@dataclass
class DifficultySignals:
    verifier_runtime_s: float = 0.0
    rep_tools_status: str = "available"           # available | partial | missing
    wh_anchor_size: int = 0
    registry_hits: int = 0


@dataclass
class TractabilityReport:
    problem_id: str
    scout_outcome: str                             # pass | fail | inconclusive | error | timeout
    scout_evidence: str
    scout_wh: dict
    scout_rep_id: str | None
    estimated_difficulty: str                      # shallow | medium | deep | intractable
    difficulty_signals: DifficultySignals
    recommended_action: str                        # deep_dive | defer | discard | needs_tool_first
    ts: str = field(default_factory=_now_iso)

    def to_dict(self) -> dict:
        d = asdict(self)
        # difficulty_signals is already a dataclass and asdict handles it.
        return d

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)


# ────────────────────────────────────────────────────────────────────────────
# Heuristics (§D.2 / §D.3)
# ────────────────────────────────────────────────────────────────────────────


def estimate_difficulty(
    *,
    scout_outcome: str,
    runtime_s: float,
    rep_tools_status: str,
    wh_anchor_size: int = 0,
    registry_hits: int = 0,
    timeout_budget_s: float = MEDIUM_RUNTIME_S,
) -> str:
    """Per spec §D.2."""
    if rep_tools_status == "missing":
        return "intractable"
    if scout_outcome == "timeout":
        return "intractable"
    if runtime_s > timeout_budget_s and scout_outcome != "pass":
        return "intractable"
    if scout_outcome == "fail":
        # Without an explicit "structural axis identified" signal we conservatively call deep.
        return "deep"
    # scout_outcome == pass | inconclusive | error: difficulty depends on runtime + tool/registry.
    if scout_outcome == "pass":
        if rep_tools_status == "available" and runtime_s <= SHALLOW_RUNTIME_S \
                and wh_anchor_size <= 5 and registry_hits >= 2:
            return "shallow"
        if rep_tools_status == "available" and runtime_s <= MEDIUM_RUNTIME_S \
                and wh_anchor_size <= 50:
            return "medium"
        if rep_tools_status == "partial" or wh_anchor_size > 50:
            return "deep"
        return "medium"
    # inconclusive / error
    return "deep"


def recommend_action(
    *,
    scout_outcome: str,
    estimated_difficulty: str,
    registry_hits: int = 0,
    refinement_axis_identified: bool = False,
) -> str:
    """Per spec §D.3 truth table."""
    if scout_outcome == "fail":
        return "discard" if not refinement_axis_identified else "defer"
    if scout_outcome == "error":
        return "needs_tool_first"
    if scout_outcome == "timeout":
        return "needs_tool_first"
    if scout_outcome == "inconclusive":
        return "defer"
    # pass branch
    if estimated_difficulty == "shallow":
        return "deep_dive"
    if estimated_difficulty == "medium":
        return "deep_dive"
    if estimated_difficulty == "deep":
        return "deep_dive" if registry_hits >= 1 else "defer"
    if estimated_difficulty == "intractable":
        return "needs_tool_first"
    return "defer"


# ────────────────────────────────────────────────────────────────────────────
# Top-level constructor
# ────────────────────────────────────────────────────────────────────────────


def generate_report(
    *,
    problem_id: str,
    state: TrackerState,
    verifier_outcome: str,
    verifier_evidence: str,
    runtime_s: float,
    rep_id: str | None,
    rep_tools_status: str = "available",
    wh_anchor_size: int = 0,
    registry_hits: int = 0,
) -> TractabilityReport:
    # Derive scout_outcome from verifier outcome (spec §D.1):
    #   verifier "pass"  → scout "pass"
    #   verifier "fail"  → scout "fail"
    #   verifier "mixed" or repaired "error" → scout "inconclusive"
    #   verifier "error" (unrecovered)        → scout "error"
    #   verifier "timeout"                    → scout "timeout" (then mapped to needs_tool_first)
    scout_outcome = {
        "pass": "pass",
        "fail": "fail",
        "mixed": "inconclusive",
        "error": "error",
        "timeout": "timeout",
    }.get(verifier_outcome, verifier_outcome)

    difficulty = estimate_difficulty(
        scout_outcome=scout_outcome,
        runtime_s=runtime_s,
        rep_tools_status=rep_tools_status,
        wh_anchor_size=wh_anchor_size,
        registry_hits=registry_hits,
    )
    action = recommend_action(
        scout_outcome=scout_outcome,
        estimated_difficulty=difficulty,
        registry_hits=registry_hits,
    )

    wh_summary: dict = {}
    if state.why_hypotheses:
        wh = state.why_hypotheses[0]
        wh_summary = {
            "id": wh.id,
            "claim": wh.claim,
            "candidate_property": wh.candidate_property,
        }

    signals = DifficultySignals(
        verifier_runtime_s=runtime_s,
        rep_tools_status=rep_tools_status,
        wh_anchor_size=wh_anchor_size,
        registry_hits=registry_hits,
    )

    return TractabilityReport(
        problem_id=problem_id,
        scout_outcome=scout_outcome,
        scout_evidence=verifier_evidence,
        scout_wh=wh_summary,
        scout_rep_id=rep_id,
        estimated_difficulty=difficulty,
        difficulty_signals=signals,
        recommended_action=action,
    )


def write_report(report: TractabilityReport, output_dir: Path | str) -> Path:
    """Write the report as JSON to `<output_dir>/<problem_id>.json`. Creates dir."""
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    # Sanitise problem_id for filesystem.
    safe = "".join(c if c.isalnum() or c in "-_" else "_" for c in report.problem_id) or "scout"
    p = out / f"{safe}.json"
    p.write_text(report.to_json(), encoding="utf-8")
    return p
