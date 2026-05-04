"""Scout orchestrator — wires the 7 modules together.

Spec: workspace/agents_spec/scout_mode.md §C (single-problem) + §G (batch).

Public API:
  scout_one(problem, config) -> TractabilityReport
  scout_batch(problems, config) -> dict (batch report with ranking)
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM

from . import explain_why_seed, proposer_scout, rep_selector, verifier
from .hypothesis_tracker import (
    Conjecture,
    TrackerState,
    create_seed_wh,
    update_completion_status,
)
from .instance_sorter import TestPlan, validate_test_plan
from .tractability_report import TractabilityReport, generate_report, write_report


# ────────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────────


_REPO_ROOT = Path(__file__).resolve().parents[4]
_DEFAULT_REGISTRY = _REPO_ROOT / "LeanAgent" / "registry" / "representations" / "entries.jsonl"
_DEFAULT_PROPOSER_STUB = _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout" / "stubs" / "proposer_scout.json"
_DEFAULT_SEED_STUB = _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout" / "stubs" / "explain_why_seed.json"


@dataclass
class ScoutConfig:
    registry_path: Path = _DEFAULT_REGISTRY
    output_dir: Path = field(default_factory=lambda: _REPO_ROOT / "workspace" / "active" / "scout_default")
    stub_mode: bool = False
    timeout_s: float = 60.0
    proposer_stub_path: Path = _DEFAULT_PROPOSER_STUB
    seed_stub_path: Path = _DEFAULT_SEED_STUB
    batch_id: str | None = None


# ────────────────────────────────────────────────────────────────────────────
# Per-problem scout
# ────────────────────────────────────────────────────────────────────────────


def scout_one(problem: dict, config: ScoutConfig) -> TractabilityReport:
    """Run the 5-stage scout flow for one problem.

    Required keys in `problem`:
      - problem_id: str
      - goal: str (NL theorem statement)
    Optional:
      - domain: str (controlled vocab; defaults to "meta")
      - object_keywords: str (defaults to "")
      - literature_in_scope: list (defaults to [])
    """
    pid = problem.get("problem_id") or "unknown"
    goal = problem.get("goal") or ""
    if not goal:
        raise ValueError(f"problem {pid}: missing 'goal'")
    domain = problem.get("domain", "meta")
    object_keywords = problem.get("object_keywords", "")
    literature = problem.get("literature_in_scope", [])

    # Configure LLMs (shared for both Proposer and Explain-Why).
    if config.stub_mode:
        proposer_llm = LLM(provider="stub", stub_path=config.proposer_stub_path)
        seed_llm = LLM(provider="stub", stub_path=config.seed_stub_path)
    else:
        proposer_llm = LLM(provider="auto", stub_path=config.proposer_stub_path)
        seed_llm = LLM(provider="auto", stub_path=config.seed_stub_path)

    # ── Step 1: Rep Selector (read-only on registry) ──
    reps = rep_selector.load_representations(config.registry_path)
    rep_select = rep_selector.select_rep(
        object=object_keywords or pid,
        domain=domain,
        reps=reps,
    )
    chosen_rep_id = rep_select["preferred_starting_rep"]
    rep_tools_status = "available"
    rep_obj = None
    for r in rep_select["representations"]:
        if r.id == chosen_rep_id:
            rep_obj = r
            rep_tools_status = r.tools_status
            break
    registry_hits = len(rep_select["representations"])

    # ── Step 2: Proposer-scout (LLM) ──
    proposal = proposer_scout.run_proposer_scout(
        goal=goal,
        rep_id=chosen_rep_id or "",
        domain=domain,
        object_keywords=object_keywords,
        literature_in_scope=literature,
        llm=proposer_llm,
    )

    # Build TestPlan dataclass and validate scout cap.
    plan = TestPlan.from_dict(proposal["test_plan"])
    validate_test_plan(plan, intent="scout")
    step = plan.steps[0]

    # ── Step 3: Verifier (1 step) ──
    vresult = verifier.dispatch(step, timeout_s=config.timeout_s)
    step.actual_outcome = vresult.actual_outcome
    step.actual_evidence = vresult.actual_evidence
    step.runtime_s = vresult.runtime_s

    # ── Step 4: Explain-Why seed (LLM) — only if Verifier returned non-error ──
    seed_json = {
        "wh_seed": {"claim": "(no seed — verifier did not produce usable evidence)",
                    "candidate_property": "(none)"},
        "candidate_properties": [],
        "top_ranked_id": None,
    }
    if vresult.actual_outcome not in ("error",):
        try:
            seed_json = explain_why_seed.run_seed(
                conjecture=proposal["conjecture"].get("form", goal),
                actual_evidence=vresult.actual_evidence,
                rep_id=chosen_rep_id or "(no_rep)",
                anchor_case=step.instance,
                next_case="(scout has only 1 step)",
                failed_attempts=None,
                llm=seed_llm,
            )
        except Exception as e:
            # Soft-degrade: seed prompt failed; record placeholder WH.
            seed_json["wh_seed"]["claim"] = f"(seed prompt failed: {type(e).__name__})"

    # ── Step 5: Tracker (WH-1 only; scout guard) ──
    state = TrackerState(
        current_conjecture=Conjecture(
            id=pid,
            form=proposal["conjecture"].get("form", goal),
            rep_id=chosen_rep_id,
            test_plan=plan.to_dict(),
        ),
        intent="scout",
    )
    try:
        wh = create_seed_wh(seed_json, intent="scout", rep_id=chosen_rep_id, anchor_case=step.instance)
        state.why_hypotheses.append(wh)
        state.log(f"WH-1 created from anchor {step.instance}", step=1)
    except ValueError as e:
        state.log(f"WH creation failed: {e}", step=1)

    # Scout always returns PENDING per §G.5; call once for log invariant.
    update_completion_status(state)

    # ── Step 6: Tractability report ──
    rpt = generate_report(
        problem_id=pid,
        state=state,
        verifier_outcome=vresult.actual_outcome,
        verifier_evidence=vresult.actual_evidence,
        runtime_s=vresult.runtime_s,
        rep_id=chosen_rep_id,
        rep_tools_status=rep_tools_status,
        wh_anchor_size=problem.get("wh_anchor_size", 0),
        registry_hits=registry_hits,
    )

    # Persist report.
    out_dir = Path(config.output_dir)
    if config.batch_id:
        out_dir = out_dir / config.batch_id
    write_report(rpt, out_dir)
    return rpt


# ────────────────────────────────────────────────────────────────────────────
# Batch scout
# ────────────────────────────────────────────────────────────────────────────


def _ranking_key(rpt: TractabilityReport) -> tuple:
    """Ranking key per scout_mode.md §G.2:
       (scout_outcome == "pass", -estimated_difficulty rank, registry_hits desc, runtime asc)
    """
    diff_rank = {"shallow": 0, "medium": 1, "deep": 2, "intractable": 3}
    return (
        rpt.scout_outcome == "pass",
        -diff_rank.get(rpt.estimated_difficulty, 99),
        rpt.difficulty_signals.registry_hits,
        -rpt.difficulty_signals.verifier_runtime_s,                # asc → negate so higher key wins
    )


def scout_batch(problems: list[dict], config: ScoutConfig) -> dict:
    """Run scout over a list of problems. Sequential; no shared state."""
    batch_id = config.batch_id or _dt.datetime.now(_dt.timezone.utc).strftime("scout_%Y%m%dT%H%M%S")
    config = ScoutConfig(
        registry_path=config.registry_path,
        output_dir=config.output_dir,
        stub_mode=config.stub_mode,
        timeout_s=config.timeout_s,
        proposer_stub_path=config.proposer_stub_path,
        seed_stub_path=config.seed_stub_path,
        batch_id=batch_id,
    )
    reports: list[TractabilityReport] = []
    for p in problems:
        try:
            rpt = scout_one(p, config)
        except Exception as e:
            rpt = _failure_report(p, e)
        reports.append(rpt)

    # Rank for top-K selection.
    ranked = sorted(reports, key=_ranking_key, reverse=True)
    ranking = [
        {"problem_id": r.problem_id, "rank": i + 1,
         "rationale": f"{r.scout_outcome} + {r.estimated_difficulty} + "
                      f"{r.difficulty_signals.registry_hits} hits"}
        for i, r in enumerate(ranked)
    ]
    top_k_for_dd = [r.problem_id for r in ranked
                    if r.recommended_action == "deep_dive"][:5]

    batch_report = {
        "batch_id": batch_id,
        "ts": _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "reports": [r.to_dict() for r in reports],
        "ranking": ranking,
        "top_K_for_deep_dive": top_k_for_dd,
    }

    out = Path(config.output_dir) / batch_id
    out.mkdir(parents=True, exist_ok=True)
    (out / "_batch_report.json").write_text(
        json.dumps(batch_report, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return batch_report


def _failure_report(problem: dict, err: Exception) -> TractabilityReport:
    """Synthesise a failure-flavoured TractabilityReport when scout_one raises."""
    from .tractability_report import DifficultySignals
    return TractabilityReport(
        problem_id=problem.get("problem_id") or "unknown",
        scout_outcome="error",
        scout_evidence=f"{type(err).__name__}: {str(err)[:300]}",
        scout_wh={},
        scout_rep_id=None,
        estimated_difficulty="intractable",
        difficulty_signals=DifficultySignals(rep_tools_status="missing"),
        recommended_action="needs_tool_first",
    )


# ────────────────────────────────────────────────────────────────────────────
# CLI entry
# ────────────────────────────────────────────────────────────────────────────


def _cli(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(
        prog="python -m LeanAgent.LeanAgent.Agent.Scout.orchestrator",
        description="Scout Mode batch runner",
    )
    p.add_argument("--input", required=True, help="JSON file: list of problems")
    p.add_argument("--output", required=True, help="Output directory")
    p.add_argument("--stub", action="store_true", help="Use stub LLM responses")
    p.add_argument("--timeout-s", type=float, default=60.0,
                   help="Per-problem verifier timeout")
    p.add_argument("--registry", help="Override path to representations/entries.jsonl")
    p.add_argument("--batch-id", help="Override batch id (default: scout_<utc-ts>)")
    args = p.parse_args(argv)

    problems = json.loads(Path(args.input).read_text(encoding="utf-8"))
    if not isinstance(problems, list):
        problems = [problems]

    cfg = ScoutConfig(
        registry_path=Path(args.registry) if args.registry else _DEFAULT_REGISTRY,
        output_dir=Path(args.output),
        stub_mode=args.stub,
        timeout_s=args.timeout_s,
        batch_id=args.batch_id,
    )
    batch = scout_batch(problems, cfg)
    sys.stdout.write(json.dumps({
        "batch_id": batch["batch_id"],
        "n_reports": len(batch["reports"]),
        "top_K_for_deep_dive": batch["top_K_for_deep_dive"],
    }, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(_cli())
