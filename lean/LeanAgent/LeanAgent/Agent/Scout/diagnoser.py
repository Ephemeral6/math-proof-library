"""Diagnoser — ternary judge that routes failures between Discoverers.

Spec: workspace/agents_spec/hypothesis_tracker.md §C.1 (binary) + §C.2 (ternary).

The binary judge is upstream; this module owns the *ternary* dispatch
that follows. Output is a `DispatchDecision` enum that the orchestrator
uses to pick which Discoverer(s) to invoke.

No LLM calls — pure routing logic.
"""

from __future__ import annotations

import enum
from dataclasses import dataclass

from LeanAgent.LeanAgent.Agent.Scout.hypothesis_tracker import (
    Obstacle,
    OBSTRUCTION_CLASSES,
    WhyHypothesis,
)


# ────────────────────────────────────────────────────────────────────────────
# Vocab
# ────────────────────────────────────────────────────────────────────────────


class BinaryJudge(str, enum.Enum):
    REP_TOO_RESTRICTIVE = "rep_too_restrictive"
    EXPLANATION_WRONG = "explanation_wrong"
    CONJECTURE_WRONG = "conjecture_wrong"


class DispatchDecision(str, enum.Enum):
    NO_DISCOVERER = "no_discoverer"               # conjecture_wrong → §B.4
    REP_ONLY = "rep_only"                         # rep too restrictive
    TOOL_ONLY = "tool_only"                       # technique insufficient
    BOTH = "both"                                 # rep_too_restrictive + obstruction-driven
    SUCCESSOR_WH_ONLY = "successor_wh_only"       # explanation_wrong, no obstacle


# §C.2 obstruction-class routing buckets
_REP_PARALLEL_OBSTRUCTIONS = frozenset({
    "loose_inequality", "wrong_direction", "regularity_loss",
})
_TOOL_ONLY_OBSTRUCTIONS = frozenset({
    "combinatorial_blowup", "missing_lower_bound",
    "non_constructive_witness", "coupling_breaks",
    "intractable_certificate",
})


# ────────────────────────────────────────────────────────────────────────────
# Stagnation heuristic — secondary trigger from tool_discoverer.md §B.2
# ────────────────────────────────────────────────────────────────────────────


def detect_chain_stagnation(why_hypotheses: list[WhyHypothesis]) -> bool:
    """True when chain length ≥ 4 AND last two WHs share rep_id_at_creation."""
    if len(why_hypotheses) < 4:
        return False
    last = why_hypotheses[-1]
    prev = why_hypotheses[-2]
    return (
        last.rep_id_at_creation is not None
        and last.rep_id_at_creation == prev.rep_id_at_creation
    )


# ────────────────────────────────────────────────────────────────────────────
# Ternary judge core
# ────────────────────────────────────────────────────────────────────────────


def ternary_judge(
    binary_output: BinaryJudge | str,
    obstacle: Obstacle | None,
    *,
    diagnoser_axis_uniformity_confirmed: bool = False,
    why_hypotheses: list[WhyHypothesis] | None = None,
) -> DispatchDecision:
    """Decide which Discoverer(s) to invoke after the binary judge.

    Mirrors hypothesis_tracker.md §C.2:

      conjecture_wrong                                     → NO_DISCOVERER
      rep_too_restrictive  AND obstacle in {LI/WD/RL}      → BOTH (parallel)
                           AND axis_uniformity confirmed
      rep_too_restrictive  (otherwise)                     → REP_ONLY
      explanation_wrong    AND obstacle in
                           {CB/MLB/NCW/CB-coupling/IC}     → TOOL_ONLY
      explanation_wrong    AND obstacle is None            → SUCCESSOR_WH_ONLY
      else (chain stagnation fallback)                      → TOOL_ONLY
    """
    binary = BinaryJudge(binary_output) if isinstance(binary_output, str) else binary_output

    if obstacle is not None:
        # Validate vocab; raise on bad input — caller should handle.
        if obstacle.obstruction_class not in OBSTRUCTION_CLASSES:
            raise ValueError(
                f"obstacle.obstruction_class {obstacle.obstruction_class!r} "
                f"is not in catalog vocab"
            )

    if binary == BinaryJudge.CONJECTURE_WRONG:
        return DispatchDecision.NO_DISCOVERER

    if binary == BinaryJudge.REP_TOO_RESTRICTIVE:
        if (
            obstacle is not None
            and obstacle.obstruction_class in _REP_PARALLEL_OBSTRUCTIONS
            and diagnoser_axis_uniformity_confirmed
        ):
            return DispatchDecision.BOTH
        return DispatchDecision.REP_ONLY

    if binary == BinaryJudge.EXPLANATION_WRONG:
        if obstacle is None:
            # Stagnation fallback per §C.2 ELSE branch.
            if why_hypotheses is not None and detect_chain_stagnation(why_hypotheses):
                return DispatchDecision.TOOL_ONLY
            return DispatchDecision.SUCCESSOR_WH_ONLY
        if obstacle.obstruction_class in _TOOL_ONLY_OBSTRUCTIONS:
            return DispatchDecision.TOOL_ONLY
        return DispatchDecision.SUCCESSOR_WH_ONLY

    # Defensive — unknown binary verdict.
    return DispatchDecision.NO_DISCOVERER


# ────────────────────────────────────────────────────────────────────────────
# Stagnation override — secondary trigger
# ────────────────────────────────────────────────────────────────────────────


def apply_stagnation_override(
    decision: DispatchDecision,
    why_hypotheses: list[WhyHypothesis],
) -> DispatchDecision:
    """If the chain has stagnated (§B.2 secondary trigger), bias toward Tool.

    Called after `ternary_judge` to upgrade `SUCCESSOR_WH_ONLY` and
    `REP_ONLY` decisions to `TOOL_ONLY` / `BOTH` when stagnation is
    detected — same thrashing-within-rep fingerprint that the
    Tool Discoverer §B.2 watches for.
    """
    if not detect_chain_stagnation(why_hypotheses):
        return decision
    if decision == DispatchDecision.SUCCESSOR_WH_ONLY:
        return DispatchDecision.TOOL_ONLY
    if decision == DispatchDecision.REP_ONLY:
        return DispatchDecision.BOTH
    return decision


# ────────────────────────────────────────────────────────────────────────────
# Bridge Trigger (Gap-2)
# Spec: workspace/agents_spec/hypothesis_tracker.md §C.2.1
#       workspace/agents_spec/tool_discoverer.md §H.2
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class BridgeTrigger:
    """A request to invoke Bridge, emitted by Diagnoser / Strategy Proposer /
    Tool Discoverer. The orchestrator picks the highest-priority trigger
    when multiple fire in the same cycle.

    `priority`: 1 = Strategy Proposer (vetted queries),
                2 = Diagnoser direct (synthesised query from pattern),
                3 = Tool Discoverer fallback (catalog-derived).
    """
    source: str                                          # "diagnoser" | "strategy_proposer" | "tool_discoverer"
    priority: int
    query: str | None = None                              # diagnoser path
    queries: list[str] | None = None                      # strategy_proposer path
    obstruction_summary: dict | None = None               # tool_discoverer path
    pattern: str | None = None                            # verbatim structural pattern, when applicable


def extract_bridge_trigger(
    binary_output: BinaryJudge | str,
    *,
    obstacle: Obstacle | None = None,                    # currently unused, kept for forward-compat
    falsification_evidence: dict | None = None,
    current_property: str = "",
    target_property: str = "",
) -> BridgeTrigger | None:
    """Diagnoser-direct Bridge trigger.

    Fires only when:
      - binary verdict is `rep_too_restrictive` (or `explanation_wrong` —
        per spec §H.2 we focus on rep_too_restrictive but explanation_wrong
        with a non-empty pattern is also acceptable);
      - `falsification_evidence.structural_pattern` is non-empty.

    Returns None when no trigger should fire.
    """
    binary = BinaryJudge(binary_output) if isinstance(binary_output, str) else binary_output

    if binary not in (BinaryJudge.REP_TOO_RESTRICTIVE, BinaryJudge.EXPLANATION_WRONG):
        return None
    if not falsification_evidence:
        return None
    pattern = falsification_evidence.get("structural_pattern")
    if not pattern:
        return None

    # Synthesise the search query in the form spec'd by §C.2.1.
    cp = current_property or "<current property>"
    tp = target_property or "<target property>"
    query = f"weaker than {cp} implies {tp}"

    return BridgeTrigger(
        source="diagnoser",
        priority=2,
        query=query,
        pattern=pattern,
    )


def select_highest_priority_trigger(
    triggers: list[BridgeTrigger | None],
) -> BridgeTrigger | None:
    """Among multiple BridgeTrigger candidates, pick the lowest `priority`
    integer (= highest priority). None values are skipped."""
    real = [t for t in triggers if t is not None]
    if not real:
        return None
    return min(real, key=lambda t: t.priority)
