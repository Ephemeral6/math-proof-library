"""Integration glue for Gap 1 / Gap 2 / Gap 3.

Composes Scope Judge → Diagnoser → Strategy Proposer → Bridge into a
single deep-dive iteration step. Pure orchestration; all underlying
modules already have their own tests.

Public API:
  iterate_with_strategy(state, verifier_result, falsification_evidence,
                        diagnoser_decision, config, *,
                        proof_deps=None, llm=None, scout_one_fn=None)
      -> IterationDecision

The caller (deep dive's main loop) reads `IterationDecision.next_action`
and either continues, applies a strategy, or stops for human review.
"""

from __future__ import annotations

import datetime as _dt
from dataclasses import dataclass, field
from typing import Any, Callable, Optional

from LeanAgent.LeanAgent.Agent.Bridge.literature_search import (
    BridgeResult,
    run_bridge_with_triggers,
)
from LeanAgent.LeanAgent.Agent.Scout.diagnoser import (
    BinaryJudge,
    BridgeTrigger,
    DispatchDecision,
    extract_bridge_trigger,
    select_highest_priority_trigger,
)
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import TrackerState
from LeanAgent.LeanAgent.Agent.Scout.orchestrator import ScoutConfig, scout_one
from LeanAgent.LeanAgent.Agent.Scout.scope_judge import (
    ScopeVerdict,
    has_prior_passes,
    run_scope_judge,
)
from LeanAgent.LeanAgent.Agent.Scout.strategy_proposer import (
    StrategyCandidate,
    StrategyProposal,
    run_strategy_proposer,
)


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# ────────────────────────────────────────────────────────────────────────────
# Decision record
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class IterationDecision:
    """The output of a single integrated step.

    `next_action` ∈ {
        "continue_with_caveat",       # scope_limitation + workaround
        "apply_strategy",              # falsification → use recommended_id
        "human_review",                # uncertain / low confidence
        "stop_falsified",              # falsification + no usable strategy
        "no_op"                        # fall-through (no failure)
    }
    """
    next_action: str
    scope_verdict: Optional[ScopeVerdict] = None
    strategy_proposal: Optional[StrategyProposal] = None
    bridge_result: Optional[BridgeResult] = None
    bridge_trigger_used: Optional[str] = None    # "strategy_proposer" | "diagnoser" | "tool_discoverer" | None
    notes: list[str] = field(default_factory=list)
    ts: str = field(default_factory=_now_iso)


# ────────────────────────────────────────────────────────────────────────────
# Helpers — unwrap Diagnoser output
# ────────────────────────────────────────────────────────────────────────────


def _unpack_diagnoser(diagnoser_decision: Any) -> tuple[str, str, dict | None]:
    """Returns (binary_str, dispatch_str, obstacle_dict_or_None)."""
    if isinstance(diagnoser_decision, dict):
        return (
            str(diagnoser_decision.get("binary", "")),
            str(diagnoser_decision.get("dispatch", "")),
            diagnoser_decision.get("obstacle"),
        )
    # Fallback: unknown shape.
    return ("", "", None)


def _binary_str(d: Any) -> str:
    if isinstance(d, dict):
        return str(d.get("binary", ""))
    if isinstance(d, BinaryJudge):
        return d.value
    return str(d)


def _dispatch_str(d: Any) -> str:
    if isinstance(d, dict):
        return str(d.get("dispatch", ""))
    if isinstance(d, DispatchDecision):
        return d.value
    return str(d)


# ────────────────────────────────────────────────────────────────────────────
# Top-level integration step
# ────────────────────────────────────────────────────────────────────────────


def iterate_with_strategy(
    *,
    state: TrackerState | dict,
    verifier_result: dict,                              # {"actual_outcome": ..., ...}
    falsification_evidence: dict,
    diagnoser_decision: dict,                           # {"binary": ..., "dispatch": ..., "obstacle": ...}
    config: ScoutConfig,
    proof_deps: dict | None = None,
    passing_instances: list[dict] | None = None,
    failing_instance: dict | None = None,
    failed_attempts: list[dict] | None = None,
    llm: Any | None = None,
    scout_one_fn: Callable | None = None,
    extract_bridge_trigger_fn: Callable = extract_bridge_trigger,
) -> IterationDecision:
    """Single integrated post-Verifier step.

    Sequence:
      1. If outcome != fail → no_op.
      2. If has_prior_passes → run Scope Judge.
         · scope_limitation + workaround → continue_with_caveat
         · scope_limitation no workaround → fall through (will likely return
           continue_with_caveat with a degraded note; the orchestrator
           may also force completion=inconclusive_open externally)
         · uncertain → human_review
         · falsification → fall through to step 3
      3. Run Strategy Proposer (with fall-through to Bridge selection):
         a. Build BridgeTrigger candidates (strategy_proposer / diagnoser
            direct).
         b. Pick highest-priority trigger; run Bridge once.
         c. Return apply_strategy with the recommended_id and bridge_result.
    """
    decision = IterationDecision(next_action="no_op")
    if scout_one_fn is None:
        scout_one_fn = scout_one

    outcome = (verifier_result or {}).get("actual_outcome")
    if outcome != "fail":
        decision.notes.append("verifier did not fail; skipping integration step")
        return decision

    # ── Stage 1: Scope Judge ────────────────────────────────────────────────
    if has_prior_passes(state):
        if passing_instances is None or failing_instance is None:
            decision.notes.append(
                "scope_judge skipped: passing_instances/failing_instance not provided"
            )
        else:
            cc_form = ""
            cc = getattr(state, "current_conjecture", None) or (state or {}).get("current_conjecture")
            if cc is not None:
                cc_form = getattr(cc, "form", None) or (cc or {}).get("form", "")
            sv = run_scope_judge(
                conjecture={"form": cc_form},
                passing_instances=passing_instances,
                failing_instance=failing_instance,
                falsification_evidence=falsification_evidence,
                proof_deps=proof_deps,
                llm=llm,
            )
            decision.scope_verdict = sv
            if sv.verdict == "scope_limitation" and sv.workaround.exists:
                decision.next_action = "continue_with_caveat"
                decision.notes.append(
                    f"scope_limitation workaround: {sv.workaround.description}"
                )
                return decision
            if sv.verdict == "uncertain" or sv.recommendation == "human_review":
                decision.next_action = "human_review"
                decision.notes.append("[HUMAN_REVIEW_NEEDED] uncertain scope verdict")
                return decision
            if sv.verdict == "scope_limitation" and not sv.workaround.exists:
                decision.notes.append(
                    "scope_limitation without workaround; falling through to strategy"
                )

    # ── Stage 2: Strategy Proposer ──────────────────────────────────────────
    binary = _binary_str(diagnoser_decision)
    dispatch = _dispatch_str(diagnoser_decision)
    obstacle = diagnoser_decision.get("obstacle") if isinstance(diagnoser_decision, dict) else None
    cc = getattr(state, "current_conjecture", None) or (state or {}).get("current_conjecture")
    cc_dict = cc if isinstance(cc, dict) else {
        "id": getattr(cc, "id", ""),
        "form": getattr(cc, "form", ""),
        "rep_id": getattr(cc, "rep_id", None),
        "domain": getattr(cc, "domain", "meta"),
    }
    strategy: StrategyProposal | None = None
    try:
        strategy = run_strategy_proposer(
            current_conjecture=cc_dict,
            falsification_evidence=falsification_evidence,
            diagnoser_output={
                "binary": binary,
                "dispatch": dispatch,
                "obstacle": obstacle,
            },
            failed_attempts=failed_attempts or [],
            registry_context={},
            config=config,
            llm=llm,
            scout_one_fn=scout_one_fn,
        )
    except Exception as e:
        decision.notes.append(f"strategy_proposer failed: {type(e).__name__}: {e}")
    decision.strategy_proposal = strategy

    # ── Stage 3: Bridge trigger selection ───────────────────────────────────
    triggers: list[BridgeTrigger | None] = []

    if strategy and strategy.recommended_id:
        rec = next(
            (c for c in strategy.candidates if c.id == strategy.recommended_id),
            None,
        )
        if rec is not None and rec.type == "bridge_to_literature" and rec.search_queries:
            triggers.append(BridgeTrigger(
                source="strategy_proposer",
                priority=1,
                queries=list(rec.search_queries),
            ))

    diag_trigger = extract_bridge_trigger_fn(
        binary,
        falsification_evidence=falsification_evidence,
        current_property=(cc_dict.get("form") or "")[:200],
        target_property=(cc_dict.get("form") or "")[:200],
    )
    triggers.append(diag_trigger)

    chosen = select_highest_priority_trigger(triggers)
    if chosen is not None:
        bres = run_bridge_with_triggers(
            strategy_queries=chosen.queries if chosen.source == "strategy_proposer" else None,
            diagnoser_trigger=chosen if chosen.source == "diagnoser" else None,
            obstruction_summary=chosen.obstruction_summary if chosen.source == "tool_discoverer" else None,
            llm=llm,
        )
        decision.bridge_result = bres
        decision.bridge_trigger_used = chosen.source

    # ── Final dispatch ──────────────────────────────────────────────────────
    if strategy and strategy.recommended_id:
        decision.next_action = "apply_strategy"
        decision.notes.append(
            f"apply strategy {strategy.recommended_id}: {strategy.recommendation_rationale}"
        )
    else:
        decision.next_action = "stop_falsified"
        decision.notes.append("no usable strategy candidate; halt this conjecture")
    return decision
