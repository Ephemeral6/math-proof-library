"""core/ablation.py — Ablation study runner.

旧的 5-level 消融条件（保留向后兼容）：
  full:            完整数据（level 5）
  -engine:         只给 summary（level 1 数据）
  -transform:      给 summary + detailed 但不给 transform trace（level 2）
  -structural:     给 summary + detailed + trace 但不给 structural（level 3）
  -counterfactual: 给完整 level 4 但不给反事实
  -engine-cf:      只给 summary，不给反事实（最差条件）

新的三原语 2³ 消融（PrimitiveAblation）：
  R = Relation       — 每元素位置数据（crossings、bigon puncture 归属）
  T = Transform      — 变换轨迹（surgery region、short/long arc、β 与区域重叠）
  C = Contrastive    — 反事实 case（条件放宽后不变量被破坏）

8 个条件 = R/T/C 三个二值因子的全交叉。
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
import json
from typing import Any

from .evaluator import Score


class AblationCondition(Enum):
    FULL = "full"                         # level 5 完整数据
    NO_ENGINE = "-engine"                 # 退化到 level 1
    NO_TRANSFORM = "-transform"           # 退化到 level 2（无 trace）
    NO_STRUCTURAL = "-structural"         # 退化到 level 3（无 structural）
    NO_COUNTERFACTUAL = "-counterfactual" # level 4（无反事实）
    MINIMAL = "-engine-cf"                # level 1 无反事实


# 每个条件对应的 benchmark level 和是否包含反事实
CONDITION_TO_LEVEL = {
    AblationCondition.FULL: (5, True),
    AblationCondition.NO_ENGINE: (1, False),
    AblationCondition.NO_TRANSFORM: (2, False),
    AblationCondition.NO_STRUCTURAL: (3, False),
    AblationCondition.NO_COUNTERFACTUAL: (4, False),
    AblationCondition.MINIMAL: (1, False),
}


class PrimitiveAblation(Enum):
    """三原语 2³ 全交叉的 8 个条件。

    code 是 3 字符串：第 1 位 R/✗，第 2 位 T/✗，第 3 位 C/✗。
    为了便于文件命名，我们用固定 3 字符的 ID（如 "000", "R00", "RTC"）。
    """
    NONE = "000"        # 无原语
    R    = "R00"        # 只有 Relation
    T    = "0T0"        # 只有 Transform
    C    = "00C"        # 只有 Contrastive
    RT   = "RT0"        # Relation + Transform
    RC   = "R0C"        # Relation + Contrastive
    TC   = "0TC"        # Transform + Contrastive
    RTC  = "RTC"        # 全部

    @property
    def has_R(self) -> bool:
        return "R" in self.value

    @property
    def has_T(self) -> bool:
        return "T" in self.value

    @property
    def has_C(self) -> bool:
        return "C" in self.value


def _project_case(case_dict: dict, has_R: bool, has_T: bool) -> dict:
    """从 level-5 形式的 case dict 中投影出 R/T 控制下的字段子集。

    所有条件都保留：case_id、object_a_id/b_id、transformed_a_id、summary_delta、metadata。
    has_R: 加入 detailed_comparison + structural_comparison。
    has_T: 加入 transform_trace + reference_in_transform_region。
    """
    out: dict = {
        k: case_dict[k] for k in (
            "case_id", "object_a_id", "object_b_id", "transformed_a_id",
            "summary_delta",
        ) if k in case_dict
    }
    if has_R:
        if "detailed_comparison" in case_dict:
            out["detailed_comparison"] = case_dict["detailed_comparison"]
        if "structural_comparison" in case_dict:
            out["structural_comparison"] = case_dict["structural_comparison"]
    if has_T:
        if "transform_trace" in case_dict:
            out["transform_trace"] = case_dict["transform_trace"]
        if "reference_in_transform_region" in case_dict:
            out["reference_in_transform_region"] = case_dict["reference_in_transform_region"]
    if "metadata" in case_dict:
        out["metadata"] = case_dict["metadata"]
    return out


def generate_primitive_ablation_data(
    condition: PrimitiveAblation,
    cases: list[Any],
    counterfactual_cases: list[Any] | None = None,
    domain: str = "surface_topology",
) -> dict:
    """根据三原语条件构造一份 ablation 数据 dict。

    `cases` 可以是 ExperimentCase（带 .comparison 等属性）或者已经投影到
    level-5 形态的 dict。两种都接受，便于直接从 level_5.json 重投影。
    """
    has_R = condition.has_R
    has_T = condition.has_T
    has_C = condition.has_C

    out_cases: list[dict] = []
    for ec in cases:
        if isinstance(ec, dict):
            level5_view = ec
        else:
            cmp_obj = ec.comparison
            level5_view = {
                "case_id": ec.case_id,
                "object_a_id": ec.object_a_id,
                "object_b_id": ec.object_b_id,
                "transformed_a_id": ec.transformed_a_id,
                "summary_delta": cmp_obj.summary_delta,
                "detailed_comparison": cmp_obj.detailed_comparison,
                "structural_comparison": cmp_obj.structural_comparison,
                "transform_trace": cmp_obj.transform_trace,
                "reference_in_transform_region": cmp_obj.reference_in_transform_region,
                "metadata": getattr(ec, "metadata", {}),
            }
        out_cases.append(_project_case(level5_view, has_R, has_T))

    result: dict = {
        "condition": condition.value,
        "domain": domain,
        "primitives": {
            "relation": has_R,
            "transform": has_T,
            "contrastive": has_C,
        },
        "n_cases": len(out_cases),
        "cases": out_cases,
    }

    if has_C and counterfactual_cases:
        result["counterfactual"] = [
            cf.to_json() if hasattr(cf, "to_json") else cf
            for cf in counterfactual_cases
        ]
    elif has_C:
        result["counterfactual"] = []

    return result


def save_primitive_ablation_suite(
    output_dir: Path,
    cases: list[Any],
    counterfactual_cases: list[Any] | None = None,
    domain: str = "surface_topology",
) -> dict[PrimitiveAblation, Path]:
    """对 8 个条件依次生成 JSON 并保存到 output_dir/condition_<id>.json。"""
    output_dir.mkdir(parents=True, exist_ok=True)
    written: dict[PrimitiveAblation, Path] = {}
    for cond in PrimitiveAblation:
        data = generate_primitive_ablation_data(
            cond, cases, counterfactual_cases, domain=domain
        )
        path = output_dir / f"condition_{cond.value}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        written[cond] = path
    return written


@dataclass
class AblationResult:
    domain: str
    condition: AblationCondition
    score: Score
    findings: str

    def to_json(self) -> dict:
        return {
            "domain": self.domain,
            "condition": self.condition.value,
            "score": self.score.name,
            "score_value": int(self.score),
            "findings": self.findings,
        }


@dataclass
class AblationStudy:
    domain: str
    results: list[AblationResult]

    def to_json(self) -> dict:
        return {
            "domain": self.domain,
            "results": [r.to_json() for r in self.results],
            "summary": {
                r.condition.value: r.score.name for r in self.results
            }
        }

    def save(self, path: Path):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_json(), f, indent=2, ensure_ascii=False)
