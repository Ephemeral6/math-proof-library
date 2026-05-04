"""core/engine.py — GeometricEngine protocol.

每个 domain 实现这个 protocol。Engine 是纯计算，不调用 LLM。
"""

from __future__ import annotations
from typing import Protocol, runtime_checkable, Any
from .relation import RelationData
from .transform import TransformTrace, TransformResult
from .comparison import RelationComparison


@runtime_checkable
class GeometricObject(Protocol):
    """Domain-specific 几何对象的最小接口。"""
    @property
    def object_id(self) -> str: ...
    def to_json(self) -> dict: ...


@runtime_checkable
class GeometricEngine(Protocol):
    """Domain-agnostic 几何引擎接口。"""

    @property
    def domain_name(self) -> str: ...

    def construct(self, spec: dict) -> GeometricObject:
        """从 spec 构造几何对象。"""
        ...

    def relate(self, obj_a: GeometricObject, obj_b: GeometricObject,
               detail_level: int = 1) -> RelationData:
        """计算两个对象之间的关系。
        detail_level: 1=summary, 2=+detailed, 3=+structural
        """
        ...

    def transform(self, obj: GeometricObject, operation: dict,
                  **kwargs) -> TransformResult:
        """对对象做变换，返回新对象 + trace。"""
        ...

    def invariants(self, obj: GeometricObject) -> dict:
        """计算对象的所有已知不变量。"""
        ...

    def compare(
        self,
        obj_a: GeometricObject,
        obj_b: GeometricObject,
        transformed_a: GeometricObject,
        transform_result: TransformResult,
        detail_level: int = 4,
    ) -> RelationComparison:
        """计算变换前后的结构化对比。

        Domain 可以 override 以加入更丰富的 detailed/structural 比较。
        默认实现见 core.comparison.default_compare。
        """
        ...
