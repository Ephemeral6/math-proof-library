"""core/transform.py — Domain-agnostic transform trace structures."""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any


@dataclass
class TransformTrace:
    """变换的逐步记录。"""

    operation_name: str          # 如 "hatcher_surgery", "reidemeister_R2"
    operation_params: dict = field(default_factory=dict)

    # 变换前后的关键指标
    before_state: dict = field(default_factory=dict)
    after_state: dict = field(default_factory=dict)
    delta: dict = field(default_factory=dict)

    # 受影响的局部区域
    region_affected: dict = field(default_factory=dict)
    # 例：{"triangles": [0,1,2], "punctures_in_region": 2}

    # 子步骤（可选，用于多步变换）
    sub_steps: list[dict] = field(default_factory=list)

    def to_json(self) -> dict:
        return {
            "operation_name": self.operation_name,
            "operation_params": self.operation_params,
            "before_state": self.before_state,
            "after_state": self.after_state,
            "delta": self.delta,
            "region_affected": self.region_affected,
            "sub_steps": self.sub_steps,
        }


@dataclass
class TransformResult:
    """变换的完整结果。"""

    original_id: str
    transformed_id: str
    trace: TransformTrace

    # 不变量对比
    invariants_before: dict = field(default_factory=dict)
    invariants_after: dict = field(default_factory=dict)
    invariants_delta: dict = field(default_factory=dict)
    invariants_preserved: dict = field(default_factory=dict)  # {name: bool}

    def to_json(self) -> dict:
        return {
            "original_id": self.original_id,
            "transformed_id": self.transformed_id,
            "trace": self.trace.to_json(),
            "invariants_before": self.invariants_before,
            "invariants_after": self.invariants_after,
            "invariants_delta": self.invariants_delta,
            "invariants_preserved": self.invariants_preserved,
        }
