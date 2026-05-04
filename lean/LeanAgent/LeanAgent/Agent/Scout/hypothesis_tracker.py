"""Hypothesis Tracker — WH lifecycle state machine + completion-status gate.

Spec: workspace/agents_spec/hypothesis_tracker.md
       §A schema, §B.1 creation, §B.2 verification, §G completion gate,
       §B.3 obstacle field.

Pure logic — no LLM calls. Scout-mode runs go through `create_seed_wh(seed,
intent="scout")` only; the scout guard prevents transition to VERIFIED.
"""

from __future__ import annotations

import dataclasses
import datetime as _dt
import enum
import json
from dataclasses import dataclass, field, asdict
from typing import Any


# ────────────────────────────────────────────────────────────────────────────
# Enums
# ────────────────────────────────────────────────────────────────────────────


class CompletionStatus(str, enum.Enum):
    PENDING = "pending"
    EMPIRICALLY_VERIFIED = "empirically_verified"
    FORMALLY_CERTIFIED = "formally_certified"
    FALSIFIED = "falsified"
    INCONCLUSIVE_OPEN = "inconclusive_open"
    ERROR = "error"


class WhVerdict(str, enum.Enum):
    ACTIVE = "ACTIVE"
    VERIFIED = "VERIFIED"
    FALSIFIED_AT_NEXT_LEVEL = "FALSIFIED_AT_NEXT_LEVEL"
    TERMINAL = "TERMINAL"


# ────────────────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────────────────


def _now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# Eight controlled-vocab obstruction classes from
# workspace/agents_spec/obstruction_catalog.md §A.
OBSTRUCTION_CLASSES = frozenset({
    "combinatorial_blowup",
    "loose_inequality",
    "wrong_direction",
    "missing_lower_bound",
    "non_constructive_witness",
    "coupling_breaks",
    "regularity_loss",
    "intractable_certificate",
})


# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class Prediction:
    next_complexity: str
    predicted_outcome: str = "unknown"           # pass | fail | mixed | unknown
    predicted_property_holds: bool | None = None
    status: str = "pending"                      # pending | verified | falsified | cancelled
    evidence: str | None = None
    diagnosis_id: str | None = None


@dataclass
class Obstacle:
    obstruction_class: str
    mathematical_property_needed: str = ""
    propagation_path: str = ""

    def validate(self) -> None:
        if self.obstruction_class not in OBSTRUCTION_CLASSES:
            raise ValueError(
                f"obstruction_class {self.obstruction_class!r} not in catalog "
                f"(expected one of {sorted(OBSTRUCTION_CLASSES)})"
            )


@dataclass
class WhyHypothesis:
    id: str                                      # WH-1, WH-2, ...
    claim: str
    candidate_property: str
    rep_id_at_creation: str | None = None
    anchor_case: str = ""
    predictions: list[Prediction] = field(default_factory=list)
    verdict: str = WhVerdict.ACTIVE.value
    successor_id: str | None = None
    obstacle: Obstacle | None = None
    created_at_iter: int = 0
    ts: str = field(default_factory=_now_iso)


@dataclass
class FailedAttempt:
    id: str
    form: str
    as_explanation: bool = True
    disproved_by: str = ""
    structural_pattern: str = ""
    successor_id: str | None = None
    rep_id_at_falsification: str | None = None
    obstacle: Obstacle | None = None
    ts: str = field(default_factory=_now_iso)


@dataclass
class Conjecture:
    id: str
    form: str
    rep_id: str | None = None
    test_plan: dict | None = None                # serialized TestPlan; opaque here
    verification_status: str = "unknown"
    completion_status: str = CompletionStatus.PENDING.value
    completion_rationale: str = ""
    verification_qualifier: str = "INCOMPLETE"   # EXACT | EXHAUSTIVE_ON_SAMPLE | NUMERICAL | INCOMPLETE


@dataclass
class TrackerState:
    current_conjecture: Conjecture
    why_hypotheses: list[WhyHypothesis] = field(default_factory=list)
    failed_attempts: list[FailedAttempt] = field(default_factory=list)
    evidence: list[str] = field(default_factory=list)
    tracker_log: list[dict] = field(default_factory=list)
    iteration_count: int = 0
    intent: str = "deep_dive"                    # "scout" | "deep_dive"

    # ---- log helpers ----
    def log(self, event: str, *, step: int | None = None) -> None:
        self.tracker_log.append({
            "iter": self.iteration_count,
            "step": step,
            "event": event,
            "ts": _now_iso(),
        })

    # ---- serialisation ----
    def to_dict(self) -> dict:
        def _conv(x: Any) -> Any:
            if dataclasses.is_dataclass(x) and not isinstance(x, type):
                return {k: _conv(v) for k, v in asdict(x).items()}
            if isinstance(x, list):
                return [_conv(v) for v in x]
            if isinstance(x, dict):
                return {k: _conv(v) for k, v in x.items()}
            return x
        return _conv(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)


# ────────────────────────────────────────────────────────────────────────────
# WH creation (§B.1)
# ────────────────────────────────────────────────────────────────────────────


def create_seed_wh(
    seed_json: dict,
    *,
    intent: str,
    rep_id: str | None = None,
    anchor_case: str = "",
    iteration: int = 0,
) -> WhyHypothesis:
    """Build WH-1 from the explain-why seed-prompt output.

    Per §B.1 the seed prompt produces:
      seed_json = { "wh_seed": { "claim": ..., "candidate_property": ... },
                    "candidate_properties": [...], "top_ranked_id": "P1" }

    For scout mode the WH stays ACTIVE forever (§G.5 / §B.2 guard).
    """
    wh_seed = seed_json.get("wh_seed") or {}
    claim = wh_seed.get("claim", "")
    candidate_property = wh_seed.get("candidate_property", "")
    if not claim or not candidate_property:
        raise ValueError(
            "seed_json missing wh_seed.claim or wh_seed.candidate_property"
        )

    wh = WhyHypothesis(
        id="WH-1",
        claim=claim,
        candidate_property=candidate_property,
        rep_id_at_creation=rep_id,
        anchor_case=anchor_case,
        predictions=[],
        verdict=WhVerdict.ACTIVE.value,
        successor_id=None,
        obstacle=None,
        created_at_iter=iteration,
    )

    # Attach scout-marker via predictions[]: scout has no next-step prediction
    # because it has only 1 plan step. The list stays empty.
    if intent == "scout":
        # Nothing to add — empty predictions are the scout signature.
        pass
    return wh


# ────────────────────────────────────────────────────────────────────────────
# §B.2 transition — only used by deep_dive
# ────────────────────────────────────────────────────────────────────────────


def maybe_transition_to_verified(wh: WhyHypothesis, intent: str) -> None:
    """Per §B.2: transition WH to VERIFIED iff every prediction is verified
    AND no pending predictions remain. Scout guard: scout-mode WH never
    transitions (predictions list is empty by design)."""
    if intent == "scout":
        return  # guard
    if not wh.predictions:
        return
    if all(p.status == "verified" for p in wh.predictions):
        wh.verdict = WhVerdict.VERIFIED.value


# ────────────────────────────────────────────────────────────────────────────
# §G.2 completion-status gate
# ────────────────────────────────────────────────────────────────────────────


def update_completion_status(state: TrackerState) -> str:
    """Per hypothesis_tracker.md §G.2.

    Scout mode short-circuits to PENDING.
    """
    c = state.current_conjecture

    if state.intent == "scout":
        c.completion_rationale = "scout mode — completion gated to deep_dive"
        c.completion_status = CompletionStatus.PENDING.value
        return c.completion_status

    plan = (c.test_plan or {}).get("steps", []) if c.test_plan else []

    # Step-level signals
    if any((s.get("actual_outcome") == "fail") for s in plan):
        c.completion_rationale = "step-level fail observed"
        c.completion_status = CompletionStatus.FALSIFIED.value
        return c.completion_status

    if any((s.get("actual_outcome") == "error") for s in plan):
        c.completion_rationale = "step-level error not recovered"
        c.completion_status = CompletionStatus.ERROR.value
        return c.completion_status

    if any((s.get("actual_outcome") is None) for s in plan):
        c.completion_rationale = "plan steps still pending"
        c.completion_status = CompletionStatus.PENDING.value
        return c.completion_status

    qualifier = c.verification_qualifier
    n = len(plan) or 1
    pass_rate = sum(1 for s in plan if s.get("actual_outcome") == "pass") / n
    all_wh_settled = all(
        wh.verdict in (WhVerdict.VERIFIED.value, WhVerdict.TERMINAL.value)
        for wh in state.why_hypotheses
    )

    if pass_rate == 1.0 and qualifier == "EXACT" and all_wh_settled:
        c.completion_rationale = "EXACT qualifier + all WHs settled"
        c.completion_status = CompletionStatus.FORMALLY_CERTIFIED.value
        return c.completion_status

    if pass_rate == 1.0 and qualifier == "EXHAUSTIVE_ON_SAMPLE" and all_wh_settled:
        c.completion_rationale = "EXHAUSTIVE_ON_SAMPLE + all WHs settled"
        c.completion_status = CompletionStatus.EMPIRICALLY_VERIFIED.value
        return c.completion_status

    chain_len = max(
        (
            int(wh.id.split("-")[-1])
            for wh in state.why_hypotheses
            if wh.id.startswith("WH-") and wh.id.split("-")[-1].isdigit()
        ),
        default=0,
    )
    if chain_len > 6:
        c.completion_rationale = "WH chain exceeded 6; per §B.6 escalate to Bridge"
        c.completion_status = CompletionStatus.INCONCLUSIVE_OPEN.value
        return c.completion_status

    if pass_rate == 1.0 and qualifier in {"NUMERICAL", "INCOMPLETE"}:
        c.completion_rationale = (
            f"empirical evidence at qualifier={qualifier}; needs lift to "
            f"EXHAUSTIVE_ON_SAMPLE or EXACT before completion"
        )
        c.completion_status = CompletionStatus.INCONCLUSIVE_OPEN.value
        return c.completion_status

    c.completion_rationale = "default fall-through"
    c.completion_status = CompletionStatus.PENDING.value
    return c.completion_status


# ────────────────────────────────────────────────────────────────────────────
# §G.3 archive gate
# ────────────────────────────────────────────────────────────────────────────


def can_emit_summary(state: TrackerState) -> bool:
    """Per §G.3: closing summary only on positive terminal states."""
    return state.current_conjecture.completion_status in (
        CompletionStatus.EMPIRICALLY_VERIFIED.value,
        CompletionStatus.FORMALLY_CERTIFIED.value,
    )
