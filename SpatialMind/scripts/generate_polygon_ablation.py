"""Generate the 8 primitive-ablation JSONs and 8 prompts for boundary_interior.

Mirrors generate_knot_ablation.py / generate_graph_ablation.py.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MATH_ROOT = ROOT.parent
for p in (str(ROOT), str(MATH_ROOT)):
    if p not in sys.path:
        sys.path.insert(0, p)

from SpatialMind.domains.boundary_interior.prompts import build_prompt

BD = ROOT / "benchmarks" / "boundary_interior"
OUT = BD / "ablation"
PROMPTS = OUT / "prompts"

CONDITIONS = ["000", "R00", "0T0", "00C", "RT0", "R0C", "0TC", "RTC"]


def load_full_data():
    with open(BD / "level_4.json", encoding="utf-8") as f:
        l4 = json.load(f)
    with open(BD / "level_5.json", encoding="utf-8") as f:
        l5 = json.load(f)
    return l4["cases"], l5.get("counterfactual", [])


def strip_to_summary(case):
    return {
        "case_id": case["case_id"],
        "summary_delta": case["summary_delta"],
        "metadata": case.get("metadata", {}),
    }


def add_relation(case, full_case):
    case["detailed_comparison"] = full_case.get("detailed_comparison", {})
    case["structural_comparison"] = full_case.get("structural_comparison", {})
    return case


def add_transform(case, full_case):
    case["transform_trace"] = full_case.get("transform_trace", {})
    case["reference_in_transform_region"] = full_case.get(
        "reference_in_transform_region", {})
    return case


def generate_condition(condition, full_cases, cf_cases):
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

    out = {
        "condition": condition,
        "domain": "boundary_interior",
        "primitives": {"relation": has_R, "transform": has_T, "contrastive": has_C},
        "n_cases": len(cases),
        "cases": cases,
    }
    if has_C:
        out["counterfactual"] = cf_cases
    return out


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    PROMPTS.mkdir(parents=True, exist_ok=True)
    full_cases, cf_cases = load_full_data()

    print(f"Loaded {len(full_cases)} positive cases + {len(cf_cases)} CF\n")
    for cond in CONDITIONS:
        data = generate_condition(cond, full_cases, cf_cases)
        path = OUT / f"{cond}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=1, ensure_ascii=False)
        size = path.stat().st_size
        n_cf = len(data.get("counterfactual", []))
        print(f"  {cond}: {data['n_cases']} cases, {n_cf} CF, {size:,} bytes")

        prompt_text = build_prompt(cond)
        (PROMPTS / f"{cond}.md").write_text(prompt_text, encoding="utf-8")

    print(f"\n8 conditions + prompts generated under {OUT}")


if __name__ == "__main__":
    main()
