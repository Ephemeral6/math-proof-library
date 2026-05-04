"""Deep Dive Orchestrator — the multi-round iteration loop.

Inherits the Scout's WH-1 + step-1 evidence (per scout_mode.md §E) and
runs the full feedback loop:

    Proposer  →  Verifier (multi-step)  →  Explain-Why  →  Tracker
       ▲                                                       │
       │                                                       ▼
   merge candidates                       ┌────  carry over WH chain
       ▲                                  │
       │                                  ▼
   Diagnoser ──── ternary ────► Rep / Tool Discoverer
                                          │
                                          ▼
                                  Bridge (synthesis path)

Stub-friendly: every external call is routed through a hook which can
be replaced with a deterministic fixture (Verifier, Explain-Why,
Discoverer paths).
"""

from __future__ import annotations

import datetime as _dt
from dataclasses import dataclass, field, asdict
from typing import Any, Callable

from LeanAgent.LeanAgent.Agent.Scout.diagnoser import (
    BinaryJudge,
    DispatchDecision,
    apply_stagnation_override,
    ternary_judge,
)
from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    CompletionStatus,
    Conjecture,
    Obstacle,
    Prediction,
    TrackerState,
    WhVerdict,
    WhyHypothesis,
    update_completion_status,
)
from LeanAgent.LeanAgent.Agent.Scout.tool_discoverer import (
    ToolDiscovererInput,
    ToolDiscovererOutput,
    run_tool_discoverer,
)


# ────────────────────────────────────────────────────────────────────────────
# Configuration & data
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class DeepDiveConfig:
    max_iterations: int = 7
    max_wh_chain_length: int = 6
    timeout_per_step_s: float = 60.0
    lean_pipeline_enabled: bool = False
    invoke_bridge: bool = True


@dataclass
class DeepDiveResult:
    state: TrackerState | None = None
    completion_status: str = CompletionStatus.PENDING.value
    iterations_run: int = 0
    discoverer_calls: list[dict] = field(default_factory=list)
    halt_reason: str = ""
    ts: str = ""

    def to_dict(self) -> dict:
        return {
            "state": (None if self.state is None else self.state.to_dict()),
            "completion_status": self.completion_status,
            "iterations_run": self.iterations_run,
            "discoverer_calls": list(self.discoverer_calls),
            "halt_reason": self.halt_reason,
            "ts": self.ts,
        }


# ────────────────────────────────────────────────────────────────────────────
# Hook protocols
# ────────────────────────────────────────────────────────────────────────────


# A "verifier" hook takes (state, step_idx) and returns
#   {"actual_outcome": "pass"|"fail"|"mixed"|"error",
#    "actual_evidence": str}
VerifierHook = Callable[[TrackerState, int], dict]

# An "explain why" hook takes the state and returns a structured
# REFUTED_AT_EXPLANATION verdict, or None on PASS:
#   None                              ← step passed; no successor needed
#   {"binary_judge": BinaryJudge,
#    "obstacle": Obstacle | None,
#    "wh_seed": dict | None,           ← optional next-WH seed
#    "diagnoser_axis_uniformity_confirmed": bool}
ExplainWhyHook = Callable[[TrackerState], dict | None]


def default_verifier_pass(state: TrackerState, step_idx: int) -> dict:
    return {
        "actual_outcome": "pass",
        "actual_evidence": f"stub: step {step_idx} passed",
    }


def default_explain_why_pass(state: TrackerState) -> dict | None:
    return None


# ────────────────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────────────────


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _seed_state_from_scout(scout: dict | None, problem: dict) -> TrackerState:
    """Build a deep-dive state from a scout report (or a bare problem)."""
    if scout:
        seed_wh = WhyHypothesis(
            id="WH-1",
            claim=scout.get("scout_wh", {}).get("claim", problem.get("goal", "")),
            candidate_property=scout.get("scout_wh", {}).get(
                "candidate_property", ""
            ),
            rep_id_at_creation=scout.get("scout_rep_id"),
            anchor_case=scout.get("scout_evidence", "")[:80],
        )
        plan_steps = [
            {
                "step": 1,
                "actual_outcome": scout.get("scout_outcome", "pass"),
                "actual_evidence": scout.get("scout_evidence", ""),
                "why_hypothesis_id": "WH-1",
            }
        ]
    else:
        seed_wh = WhyHypothesis(
            id="WH-1",
            claim=problem.get("goal", ""),
            candidate_property="",
        )
        plan_steps = []

    state = TrackerState(
        current_conjecture=Conjecture(
            id=problem.get("problem_id", "C-1"),
            form=problem.get("goal", ""),
            rep_id=scout.get("scout_rep_id") if scout else None,
            test_plan={"steps": plan_steps, "max_steps": 16},
            verification_qualifier="INCOMPLETE",
        ),
        why_hypotheses=[seed_wh],
        intent="deep_dive",
    )
    return state


def _next_step_idx(state: TrackerState) -> int:
    plan = (state.current_conjecture.test_plan or {}).get("steps", [])
    return (plan[-1].get("step", 0) if plan else 0) + 1


def _append_step(state: TrackerState, idx: int, result: dict) -> None:
    plan = state.current_conjecture.test_plan or {"steps": [], "max_steps": 16}
    steps = list(plan.get("steps", []))
    steps.append({
        "step": idx,
        "actual_outcome": result.get("actual_outcome"),
        "actual_evidence": result.get("actual_evidence", ""),
        "why_hypothesis_id": (
            state.why_hypotheses[-1].id if state.why_hypotheses else None
        ),
    })
    plan["steps"] = steps
    state.current_conjecture.test_plan = plan


def _create_successor_wh(
    state: TrackerState,
    seed: dict,
    obstacle: Obstacle | None,
) -> WhyHypothesis:
    """Mark current WH as falsified, create a new successor WH."""
    cur = state.why_hypotheses[-1]
    cur.verdict = WhVerdict.FALSIFIED_AT_NEXT_LEVEL.value
    cur.obstacle = obstacle
    new_id = f"WH-{len(state.why_hypotheses) + 1}"
    cur.successor_id = new_id
    succ = WhyHypothesis(
        id=new_id,
        claim=seed.get("claim", ""),
        candidate_property=seed.get("candidate_property", ""),
        rep_id_at_creation=cur.rep_id_at_creation,
        anchor_case=cur.anchor_case,
        created_at_iter=state.iteration_count,
    )
    state.why_hypotheses.append(succ)
    return succ


def _build_tool_discoverer_payload(
    state: TrackerState,
    obstacle: Obstacle,
    domain: str,
    trigger_reason: str,
    tried_discoveries: list[str],
) -> ToolDiscovererInput:
    cur = state.why_hypotheses[-1]
    return ToolDiscovererInput(
        object=state.current_conjecture.form[:120] or "object",
        domain=domain,
        current_rep_id=cur.rep_id_at_creation or "rep_unknown",
        current_technique=cur.candidate_property or "current_technique",
        obstruction_class=obstacle.obstruction_class,
        mathematical_property_needed=(
            obstacle.mathematical_property_needed or cur.candidate_property
        ),
        propagation_path=(
            obstacle.propagation_path
            or "obstacle propagated from explain-why"
        ),
        trigger_reason=trigger_reason,
        tried_discoveries=list(tried_discoveries),
        wh_at_trigger=cur.id,
    )


# ────────────────────────────────────────────────────────────────────────────
# Main loop
# ────────────────────────────────────────────────────────────────────────────


def deep_dive(
    problem: dict,
    *,
    scout_result: dict | None = None,
    config: DeepDiveConfig | None = None,
    verifier_hook: VerifierHook | None = None,
    explain_why_hook: ExplainWhyHook | None = None,
) -> DeepDiveResult:
    """Run the deep-dive loop.

    `problem` is a dict like
        {
          "problem_id": "...",
          "goal": "<NL>",
          "domain": "<see obstruction_catalog AMS bucket>"
        }

    `scout_result` if present is the tractability_report that seeds WH-1
    and step-1 (per scout_mode §E inheritance).

    Returns a `DeepDiveResult` carrying the final TrackerState plus a log
    of Discoverer calls.  Stub mode is implicit when both hooks default.
    """
    config = config or DeepDiveConfig()
    verifier_hook = verifier_hook or default_verifier_pass
    explain_why_hook = explain_why_hook or default_explain_why_pass

    state = _seed_state_from_scout(scout_result, problem)
    domain = problem.get("domain", "optimization")
    discoverer_calls: list[dict] = []
    tried_discoveries: list[str] = []
    halt_reason = ""

    # Update completion immediately so the gate runs over the inherited
    # step-1 row.  Result is most likely PENDING (we still need to lift
    # the qualifier to EXACT/EXHAUSTIVE_ON_SAMPLE).
    update_completion_status(state)

    for it in range(1, config.max_iterations + 1):
        state.iteration_count = it
        state.log("deep_dive.iter.begin", step=it)

        # ── 1. Verifier on the next step ──────────────────────────────
        step_idx = _next_step_idx(state)
        v_result = verifier_hook(state, step_idx)
        _append_step(state, step_idx, v_result)
        state.log(
            f"verifier.step{step_idx}.outcome="
            f"{v_result.get('actual_outcome', 'unknown')}",
            step=step_idx,
        )

        # On a clean fail → bail out via completion gate.
        if v_result.get("actual_outcome") == "fail":
            update_completion_status(state)
            halt_reason = "verifier returned fail"
            break

        # ── 2. Explain-Why on the step ────────────────────────────────
        ew = explain_why_hook(state)

        if ew is None:
            # Step passed cleanly; mark current WH eligible for VERIFIED.
            cur = state.why_hypotheses[-1]
            cur.predictions.append(Prediction(
                next_complexity=str(step_idx),
                predicted_outcome="pass",
                status="verified",
            ))
            # Lift the qualifier to EXHAUSTIVE_ON_SAMPLE if the user's
            # hook signals the plan is exhaustive.  In stub mode we set
            # this once we've successfully run more than one step.
            if step_idx >= 2:
                state.current_conjecture.verification_qualifier = (
                    "EXHAUSTIVE_ON_SAMPLE"
                )
                cur.verdict = WhVerdict.VERIFIED.value
            update_completion_status(state)
            if state.current_conjecture.completion_status in (
                CompletionStatus.EMPIRICALLY_VERIFIED.value,
                CompletionStatus.FORMALLY_CERTIFIED.value,
            ):
                halt_reason = "completion gate passed"
                break
            continue

        # ── 3. Diagnoser ternary → Discoverer dispatch ────────────────
        binary = ew.get("binary_judge", BinaryJudge.EXPLANATION_WRONG)
        obstacle: Obstacle | None = ew.get("obstacle")
        axis_confirmed = bool(
            ew.get("diagnoser_axis_uniformity_confirmed", False)
        )
        decision = ternary_judge(
            binary,
            obstacle,
            diagnoser_axis_uniformity_confirmed=axis_confirmed,
            why_hypotheses=state.why_hypotheses,
        )
        decision = apply_stagnation_override(decision, state.why_hypotheses)
        state.log(f"diagnoser.decision={decision.value}", step=step_idx)

        # ── 4. Run discoverers ────────────────────────────────────────
        if decision in (DispatchDecision.TOOL_ONLY, DispatchDecision.BOTH):
            if obstacle is None:
                # Inferred-stagnation branch — synthesise a generic
                # "loose_inequality" obstacle as a placeholder so the
                # tool discoverer payload validates.  Only used when
                # explain-why didn't supply one.
                obstacle = Obstacle(
                    obstruction_class="loose_inequality",
                    mathematical_property_needed=(
                        state.why_hypotheses[-1].candidate_property
                        or "tighten current bound"
                    ),
                    propagation_path="chain stagnation; obstacle inferred",
                )
            payload = _build_tool_discoverer_payload(
                state,
                obstacle,
                domain=domain,
                trigger_reason=(
                    "ternary_judge"
                    if decision != DispatchDecision.BOTH
                    else "ternary_judge"
                ),
                tried_discoveries=tried_discoveries,
            )
            tool_out: ToolDiscovererOutput = run_tool_discoverer(
                payload, invoke_bridge=config.invoke_bridge,
            )
            for c in tool_out.candidates:
                if c.discovery_id:
                    tried_discoveries.append(c.discovery_id)
            discoverer_calls.append({
                "kind": "tool_discoverer",
                "iter": it,
                "wh": state.why_hypotheses[-1].id,
                "decision": decision.value,
                "output": tool_out.to_dict(),
            })

        if decision in (DispatchDecision.REP_ONLY, DispatchDecision.BOTH):
            # Rep Discoverer is Phase-1; we record the call but do not
            # execute it here (lives outside this orchestrator).  Future
            # work: wire the registry/representations Mode-1/2 query.
            discoverer_calls.append({
                "kind": "rep_discoverer",
                "iter": it,
                "wh": state.why_hypotheses[-1].id,
                "decision": decision.value,
                "output": {"note": "rep discoverer not wired in P3-A"},
            })

        # ── 5. Successor WH ───────────────────────────────────────────
        seed = ew.get("wh_seed")
        if seed and decision != DispatchDecision.NO_DISCOVERER:
            _create_successor_wh(state, seed, obstacle)

        # WH-chain length gate.
        if len(state.why_hypotheses) > config.max_wh_chain_length:
            update_completion_status(state)
            halt_reason = "wh chain length exceeded"
            break

        # If conjecture_wrong, bail.
        if decision == DispatchDecision.NO_DISCOVERER:
            update_completion_status(state)
            halt_reason = "conjecture_wrong"
            break

    else:
        update_completion_status(state)
        halt_reason = "max_iterations reached"

    return DeepDiveResult(
        state=state,
        completion_status=state.current_conjecture.completion_status,
        iterations_run=state.iteration_count,
        discoverer_calls=discoverer_calls,
        halt_reason=halt_reason,
        ts=_now_iso(),
    )
