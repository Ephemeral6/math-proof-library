"""core/comparison.py — 变换前后的 RelationData 结构化对比。

RelationComparison 自动对齐 pre/post 的三层数据并输出 delta。
这是 benchmark Level 3-4 的核心数据——agent 需要看到"什么变了、什么没变"。
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any

from .relation import RelationData
from .transform import TransformResult


@dataclass
class RelationComparison:
    """变换前后关系数据的结构化对比。"""

    # 身份
    object_a_id: str         # 被变换的对象（如 α）
    object_b_id: str         # 参照对象（如 β，不参与变换）
    transformed_a_id: str    # 变换后的对象（如 σ_α）

    # Pre/Post 原始数据
    pre: RelationData        # relate(α, β) 的结果
    post: RelationData       # relate(σ_α, β) 的结果

    # Summary 层的 delta
    summary_delta: dict = field(default_factory=dict)
    # 例：{"intersection_number": 0}（不变）

    # Detailed 层的对比
    detailed_comparison: dict = field(default_factory=dict)

    # Structural 层的对比
    structural_comparison: dict = field(default_factory=dict)

    # 变换的 trace（从 TransformResult 拿）
    transform_trace: dict = field(default_factory=dict)

    # 参照对象和变换区域的关系
    reference_in_transform_region: dict = field(default_factory=dict)

    def at_level(self, level: int) -> dict:
        """返回指定层级的对比数据。
        level 1: summary_delta only
        level 2: + detailed_comparison
        level 3: + transform_trace + reference_in_transform_region
        level 4: + structural_comparison
        """
        d = {
            "object_a_id": self.object_a_id,
            "object_b_id": self.object_b_id,
            "transformed_a_id": self.transformed_a_id,
            "summary_delta": self.summary_delta,
        }
        if level >= 2:
            d["detailed_comparison"] = self.detailed_comparison
        if level >= 3:
            d["transform_trace"] = self.transform_trace
            d["reference_in_transform_region"] = self.reference_in_transform_region
        if level >= 4:
            d["structural_comparison"] = self.structural_comparison
        return d

    def to_json(self) -> dict:
        return self.at_level(4)


def compute_summary_delta(pre: RelationData, post: RelationData) -> dict:
    """自动计算 summary 层的 delta。

    对 pre.summary 和 post.summary 中的每个共同 key：
    - 如果值是数字，delta = post - pre
    - 如果值是 bool 或同值，delta = "unchanged" 或 0
    - 否则 delta = {"pre": ..., "post": ...}
    """
    delta = {}
    all_keys = set(pre.summary.keys()) | set(post.summary.keys())
    for k in all_keys:
        v_pre = pre.summary.get(k)
        v_post = post.summary.get(k)
        if isinstance(v_pre, (int, float)) and isinstance(v_post, (int, float)) \
                and not isinstance(v_pre, bool) and not isinstance(v_post, bool):
            delta[k] = v_post - v_pre
        elif v_pre == v_post:
            delta[k] = 0 if isinstance(v_pre, (int, float)) else "unchanged"
        else:
            delta[k] = {"pre": v_pre, "post": v_post}
    return delta


def default_compare(
    engine,
    obj_a,
    obj_b,
    transformed_a,
    transform_result: TransformResult,
    detail_level: int = 4,
) -> RelationComparison:
    """Default compare() implementation: two relate() calls + summary delta only.

    Domain engines should override Engine.compare() to add detailed and
    structural comparison data, plus reference_in_transform_region.
    """
    pre = engine.relate(obj_a, obj_b, detail_level=min(detail_level, 3))
    post = engine.relate(transformed_a, obj_b, detail_level=min(detail_level, 3))
    return RelationComparison(
        object_a_id=obj_a.object_id,
        object_b_id=obj_b.object_id,
        transformed_a_id=transformed_a.object_id,
        pre=pre,
        post=post,
        summary_delta=compute_summary_delta(pre, post),
        transform_trace=transform_result.trace.to_json(),
    )
