"""从已有的 Level 4 和 Level 5 数据切分出 8 个 ablation 条件。

每个条件对应三个原语的开/关组合：
  000: 只有 summary_delta
  R00: + detailed_comparison + structural_comparison
  0T0: + transform_trace + reference_in_transform_region
  00C: + counterfactual
  RT0: + R + T
  R0C: + R + C
  0TC: + T + C
  RTC: 全部（= Level 5）
"""

import json
from pathlib import Path

ROOT = Path(__file__).parent.parent
BD = ROOT / "benchmarks" / "surface_topology"


def load_full_data():
    """加载 Level 4（最完整的正例数据）和 Level 5 的反事实。"""
    with open(BD / "level_4.json", encoding="utf-8") as f:
        l4 = json.load(f)
    with open(BD / "level_5.json", encoding="utf-8") as f:
        l5 = json.load(f)
    return l4["cases"], l5.get("counterfactual", [])


def strip_to_summary(case: dict) -> dict:
    """只保留 summary_delta 和 metadata。"""
    return {
        "case_id": case["case_id"],
        "summary_delta": case["summary_delta"],
        "metadata": case.get("metadata", {}),
    }


def add_relation(case: dict, full_case: dict) -> dict:
    """加上 R 原语的字段。"""
    case["detailed_comparison"] = full_case.get("detailed_comparison", {})
    case["structural_comparison"] = full_case.get("structural_comparison", {})
    return case


def add_transform(case: dict, full_case: dict) -> dict:
    """加上 T 原语的字段。"""
    case["transform_trace"] = full_case.get("transform_trace", {})
    case["reference_in_transform_region"] = full_case.get("reference_in_transform_region", {})
    return case


CONDITIONS = ["000", "R00", "0T0", "00C", "RT0", "R0C", "0TC", "RTC"]


def generate_condition(condition: str, full_cases: list, cf_cases: list) -> dict:
    has_R = "R" in condition
    has_T = "T" in condition
    has_C = "C" in condition

    cases = []
    for fc in full_cases:
        c = strip_to_summary(fc)
        if has_R:
            add_relation(c, fc)
        if has_T:
            add_transform(c, fc)
        cases.append(c)

    result = {
        "condition": condition,
        "primitives": {"relation": has_R, "transform": has_T, "contrastive": has_C},
        "n_cases": len(cases),
        "cases": cases,
    }
    if has_C:
        result["counterfactual"] = cf_cases
    return result


def main():
    full_cases, cf_cases = load_full_data()
    out_dir = BD / "ablation"
    out_dir.mkdir(parents=True, exist_ok=True)

    for cond in CONDITIONS:
        data = generate_condition(cond, full_cases, cf_cases)
        path = out_dir / f"{cond}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=1, ensure_ascii=False)
        size = path.stat().st_size
        n_cf = len(data.get("counterfactual", []))
        print(f"  {cond}: {data['n_cases']} cases, {n_cf} CF, {size:,} bytes")

    print(f"\n8 条件数据已生成到 {out_dir}")


if __name__ == "__main__":
    main()
