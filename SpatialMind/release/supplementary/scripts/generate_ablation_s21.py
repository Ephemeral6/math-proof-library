"""从 S_{2,1} 的 Level 4 / Level 5 数据切分出 8 个 ablation 条件。

镜像 generate_ablation.py，输入路径改为 surface_topology_s21。
"""

import json
from pathlib import Path

ROOT = Path(__file__).parent.parent
BD = ROOT / "benchmarks" / "surface_topology_s21"


def load_full_data():
    with open(BD / "level_4.json", encoding="utf-8") as f:
        l4 = json.load(f)
    with open(BD / "level_5.json", encoding="utf-8") as f:
        l5 = json.load(f)
    return l4["cases"], l5.get("counterfactual", [])


def strip_to_summary(case: dict) -> dict:
    return {
        "case_id": case["case_id"],
        "summary_delta": case["summary_delta"],
        "metadata": case.get("metadata", {}),
    }


def add_relation(case: dict, full_case: dict) -> dict:
    case["detailed_comparison"] = full_case.get("detailed_comparison", {})
    case["structural_comparison"] = full_case.get("structural_comparison", {})
    return case


def add_transform(case: dict, full_case: dict) -> dict:
    case["transform_trace"] = full_case.get("transform_trace", {})
    case["reference_in_transform_region"] = full_case.get(
        "reference_in_transform_region", {})
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
        "surface": "S_{2,1}",
        "primitives": {"relation": has_R, "transform": has_T,
                       "contrastive": has_C},
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

    print(f"\n8 conditions written to {out_dir}")


if __name__ == "__main__":
    main()
