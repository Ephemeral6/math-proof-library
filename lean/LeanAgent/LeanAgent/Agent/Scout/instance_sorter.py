"""Instance Sorter — test_plan dataclass + scout-mode validation.

Spec: workspace/agents_spec/instance_sorter.md.

In scout mode, test_plan must have exactly 1 step.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field, asdict
from typing import Any


@dataclass
class TestPlanStep:
    step: int
    instance: str
    verifier_command: Any                              # str (CLI) or dict (engine_call)
    complexity: float = 0.0
    complexity_rationale: str = ""
    predicted_outcome: str = "unknown"                 # pass | fail | mixed | unknown
    why_hypothesis_id: str | None = None
    actual_outcome: str | None = None                  # pass | fail | mixed | error | timeout
    actual_evidence: str | None = None
    runtime_s: float | None = None

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: dict) -> "TestPlanStep":
        return cls(**{k: d.get(k) for k in cls.__dataclass_fields__})


@dataclass
class TestPlan:
    steps: list[TestPlanStep] = field(default_factory=list)
    max_steps: int = 1                                 # scout default

    def to_dict(self) -> dict:
        return {"max_steps": self.max_steps,
                "steps": [s.to_dict() for s in self.steps]}

    @classmethod
    def from_dict(cls, d: dict) -> "TestPlan":
        return cls(
            max_steps=d.get("max_steps", 1),
            steps=[TestPlanStep.from_dict(s) for s in d.get("steps", [])],
        )

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)

    @classmethod
    def from_json(cls, s: str) -> "TestPlan":
        return cls.from_dict(json.loads(s))


def validate_test_plan(plan: TestPlan, intent: str) -> bool:
    """Per scout_mode.md §I rule 4: scout caps test_plan at 1 step."""
    if intent == "scout":
        if len(plan.steps) != 1:
            raise ValueError(
                f"scout: test_plan length {len(plan.steps)} != 1 (scout caps at 1 step)"
            )
        if plan.steps[0].step != 1:
            raise ValueError(
                f"scout: first step.step = {plan.steps[0].step}, expected 1"
            )
        return True
    if intent == "deep_dive":
        if len(plan.steps) < 1:
            raise ValueError("deep_dive: test_plan must have ≥ 1 step")
        for i, s in enumerate(plan.steps, start=1):
            if s.step != i:
                raise ValueError(f"deep_dive: step indices not 1..N (got {s.step} at position {i})")
        return True
    raise ValueError(f"unknown intent: {intent!r} (must be 'scout' or 'deep_dive')")
