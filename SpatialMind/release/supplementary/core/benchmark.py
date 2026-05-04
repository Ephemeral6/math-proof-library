"""core/benchmark.py — 5 层 benchmark 自动生成器。

从 ExperimentCase 列表（推荐）或预计算 dict 列表（向后兼容）生成 5 层数据：
  Level 1: comparison.at_level(1) — summary delta only
  Level 2: comparison.at_level(2) — + detailed comparison
  Level 3: comparison.at_level(3) — + transform trace + region overlap
  Level 4: comparison.at_level(4) — + structural comparison
  Level 5: Level 4 + counterfactual cases
"""

from __future__ import annotations
import json
from pathlib import Path
from dataclasses import dataclass, field
from typing import Any, Union

from .relation import RelationData
from .transform import TransformResult
from .counterfactual import CounterfactualCase
from .comparison import RelationComparison


@dataclass
class ExperimentCase:
    """一个完整的实验 case——包含变换前后的所有数据。

    benchmark 从 ExperimentCase 的不同字段提取不同层级的数据。
    """

    case_id: str
    object_a_id: str              # 被变换的对象
    object_b_id: str              # 参照对象
    transformed_a_id: str         # 变换后的对象
    transform_result: TransformResult
    comparison: RelationComparison
    metadata: dict = field(default_factory=dict)

    def to_json(self) -> dict:
        return {
            "case_id": self.case_id,
            "object_a_id": self.object_a_id,
            "object_b_id": self.object_b_id,
            "transformed_a_id": self.transformed_a_id,
            "transform_result": self.transform_result.to_json(),
            "comparison": self.comparison.to_json(),
            "metadata": self.metadata,
        }


@dataclass
class BenchmarkLevel:
    """一个层级的 benchmark 数据。"""
    level: int
    domain: str
    n_cases: int
    cases: list[dict]
    counterfactual: list[dict] = field(default_factory=list)

    def to_json(self) -> dict:
        d = {
            "level": self.level,
            "domain": self.domain,
            "n_cases": self.n_cases,
            "cases": self.cases,
        }
        if self.counterfactual:
            d["counterfactual"] = self.counterfactual
        return d

    def save(self, path: Path):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_json(), f, indent=2, ensure_ascii=False)


@dataclass
class BenchmarkSuite:
    """一个 domain 的完整 benchmark 套件。"""
    domain: str
    levels: dict[int, BenchmarkLevel] = field(default_factory=dict)

    def save_all(self, output_dir: Path):
        output_dir.mkdir(parents=True, exist_ok=True)
        for level, bl in sorted(self.levels.items()):
            bl.save(output_dir / f"level_{level}.json")


def build_benchmark_suite(
    domain: str,
    cases: Union[list[ExperimentCase], list[dict]],
    counterfactual_cases: Union[list[CounterfactualCase], list[dict], None] = None,
) -> BenchmarkSuite:
    """Build a 5-level benchmark.

    `cases` may be either:
      - list[ExperimentCase] (recommended): each case carries a RelationComparison
        which provides at_level(1..4) data.
      - list[dict] (legacy, Phase 1.0): each dict has keys "case_id", "relation",
        "transform". Produces older shape (no comparison object).
    """
    if cases and isinstance(cases[0], ExperimentCase):
        return _build_from_experiment_cases(domain, cases, counterfactual_cases)
    return _build_from_legacy_dicts(domain, cases or [], counterfactual_cases)


def _build_from_experiment_cases(
    domain: str,
    cases: list[ExperimentCase],
    counterfactual_cases,
) -> BenchmarkSuite:
    suite = BenchmarkSuite(domain=domain)
    for level in range(1, 6):
        level_cases = []
        for ec in cases:
            cmp_level = min(level, 4)
            case_data = {
                "case_id": ec.case_id,
                **ec.comparison.at_level(cmp_level),
                "metadata": ec.metadata,
            }
            level_cases.append(case_data)
        bl = BenchmarkLevel(
            level=level,
            domain=domain,
            n_cases=len(level_cases),
            cases=level_cases,
        )
        if level == 5 and counterfactual_cases:
            bl.counterfactual = [
                c.to_json() if hasattr(c, "to_json") else c
                for c in counterfactual_cases
            ]
        suite.levels[level] = bl
    return suite


def _build_from_legacy_dicts(
    domain: str,
    positive_cases: list[dict],
    counterfactual_cases,
) -> BenchmarkSuite:
    suite = BenchmarkSuite(domain=domain)
    for level in range(1, 6):
        cases = []
        for pc in positive_cases:
            case_data = {"case_id": pc["case_id"]}
            rel = pc.get("relation", {})
            trans = pc.get("transform", {})
            if level >= 1:
                case_data["summary"] = rel.get("summary", {})
                case_data["invariants_before"] = trans.get("invariants_before", {})
                case_data["invariants_after"] = trans.get("invariants_after", {})
                case_data["invariants_preserved"] = trans.get("invariants_preserved", {})
            if level >= 2:
                case_data["detailed"] = rel.get("detailed", {})
            if level >= 3:
                case_data["transform_trace"] = trans.get("trace", {})
            if level >= 4:
                case_data["structural"] = rel.get("structural", {})
            cases.append(case_data)
        bl = BenchmarkLevel(
            level=level,
            domain=domain,
            n_cases=len(cases),
            cases=cases,
        )
        if level == 5 and counterfactual_cases:
            bl.counterfactual = [
                c.to_json() if hasattr(c, "to_json") else c
                for c in counterfactual_cases
            ]
        suite.levels[level] = bl
    return suite
