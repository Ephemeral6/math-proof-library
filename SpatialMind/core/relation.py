"""core/relation.py — Domain-agnostic relation data structures.

三层数据：
  summary:    数值摘要（如 intersection number = 1）
  detailed:   per-element 位置数据（如 crossing 在哪个三角形）
  structural: 拓扑结构数据（如 bigon 列表、是否含 puncture）

每层对应 benchmark 的一个级别。
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any


@dataclass
class RelationData:
    """两个几何对象之间的关系。"""

    object_a_id: str
    object_b_id: str

    # Level 1: 数值摘要
    summary: dict = field(default_factory=dict)
    # 例：{"intersection_number": 1, "algebraic_intersection": -1}

    # Level 2: per-element 位置数据
    detailed: dict = field(default_factory=dict)
    # 例：{"crossings": [{"triangle": 2, "arc_a": ..., "arc_b": ...}]}

    # Level 3: 拓扑结构
    structural: dict = field(default_factory=dict)
    # 例：{"bigons": [...], "minimal_position": true}

    def at_level(self, level: int) -> dict:
        """返回指定层级的数据。
        level 1 = summary only
        level 2 = summary + detailed
        level 3 = summary + detailed + structural
        """
        if level <= 1:
            return {"summary": self.summary}
        elif level == 2:
            return {"summary": self.summary, "detailed": self.detailed}
        else:
            return {"summary": self.summary, "detailed": self.detailed,
                    "structural": self.structural}

    def to_json(self) -> dict:
        return {
            "object_a_id": self.object_a_id,
            "object_b_id": self.object_b_id,
            "summary": self.summary,
            "detailed": self.detailed,
            "structural": self.structural,
        }
