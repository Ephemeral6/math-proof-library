"""core/counterfactual.py — Counterfactual generation framework.

三种通用策略：
  boundary_relaxation:    把约束的边界值 +1（如 i≤1 → i=2）
  condition_removal:      完全去掉一个条件
  operation_perturbation: 修改操作的一个参数

输入格式统一为 CounterfactualInput（与 RelationComparison 对齐）。
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Protocol, runtime_checkable, Any
from enum import Enum


class CFStrategy(Enum):
    BOUNDARY_RELAXATION = "boundary_relaxation"
    CONDITION_REMOVAL = "condition_removal"
    OPERATION_PERTURBATION = "operation_perturbation"


@dataclass
class CounterfactualInput:
    """反事实生成器的输入。"""

    engine: Any                                # GeometricEngine 实例
    object_a: Any                              # 被变换的对象（如 α）
    object_b: Any                              # 参照对象（如 β）
    operation: dict                            # 变换操作
    conditions: dict                           # 当前成立的条件（如 {"intersection_bound": 1}）
    positive_comparison: Any = None            # 正例的 RelationComparison（可选）


@dataclass
class CounterfactualCase:
    """一个反事实 case。"""
    strategy: CFStrategy
    original_condition: dict
    modified_condition: dict
    original_result: dict
    counterfactual_result: dict
    delta: dict
    condition_is_critical: bool
    explanation: str = ""

    def to_json(self) -> dict:
        return {
            "strategy": self.strategy.value,
            "original_condition": self.original_condition,
            "modified_condition": self.modified_condition,
            "original_result": self.original_result,
            "counterfactual_result": self.counterfactual_result,
            "delta": self.delta,
            "condition_is_critical": self.condition_is_critical,
            "explanation": self.explanation,
        }


@runtime_checkable
class CounterfactualGenerator(Protocol):
    """Domain-specific 反事实生成器。"""

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        ...


class AutoCounterfactualGenerator:
    """通用反事实生成器——自动尝试所有策略。"""

    def __init__(self, domain_generator: CounterfactualGenerator):
        self.domain = domain_generator

    def find_critical_conditions(
        self,
        input: CounterfactualInput,
    ) -> list[CounterfactualCase]:
        """对每个条件逐个放宽，找到所有关键条件。"""
        results: list[CounterfactualCase] = []
        for strategy in CFStrategy:
            try:
                cases = self.domain.generate(input, strategy)
                results.extend(cases)
            except NotImplementedError:
                continue

        # 关键条件优先，delta 大的优先
        results.sort(key=lambda c: (
            not c.condition_is_critical,
            -sum(abs(v) for v in c.delta.values() if isinstance(v, (int, float)))
        ))
        return results
