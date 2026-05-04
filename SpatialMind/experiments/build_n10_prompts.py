"""Build n=10 method comparison prompt set.

Selection rule: keep the 3 original cases, then add 7 NEW cases drawn from
sorted-by-case_id (excluding any that overlap with the original 3) until we
hit 10 cases per domain. This satisfies both:
  - "前 3 个和之前实验相同"
  - "按 case_id 排序取前 10 个"
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # SpatialMind/
DOMAINS = [
    "symmetry", "knot_theory", "graph_connectivity", "boundary_interior",
    "discrete_curvature", "projection", "surface_topology", "surface_topology_s21",
]

ORIG_CASES = {
    "symmetry": ["same-006", "diff-163", "same-028"],
    "knot_theory": ["3_1-r2-3", "4_1-r2-4", "5_2-r2-5"],
    "graph_connectivity": ["R00_n8-t3", "R02_n12-t4", "R07_n8-t0"],
    "boundary_interior": ["crosspair-4-L_shape-vs-staircase", "L_shape-scale-0", "L_shape-trans-1"],
    "discrete_curvature": [
        "cross-icosahedron-vs-cube_triangulated-f4-4",
        "cross-octahedron-vs-icosahedron-f1-1",
        "cube_triangulated-subdiv-f4-4",
    ],
    "projection": [
        "cross-octahedron-xzvsyz",
        "cross-tetrahedron-xyvsdiagonal",
        "cross-tetrahedron-yzvsdiagonal",
    ],
    "surface_topology": ["a12-b1", "a131-b389", "a331-b69"],
    "surface_topology_s21": ["a122-b28", "a151-b103", "a151-b181"],
}

CONDITIONS = ["zero_cot", "cot_code", "coe_r", "coe_rtc"]


def load_ablation(domain: str, cond: str):
    p = ROOT / "benchmarks" / domain / "ablation" / f"{cond}.json"
    with open(p, "r", encoding="utf-8") as f:
        data = json.load(f)
    return {c["case_id"]: c for c in data["cases"]}


def select_cases(domain: str, cases_000: dict) -> list:
    orig = ORIG_CASES[domain]
    have = [c for c in orig if c in cases_000]
    sorted_ids = sorted(cases_000.keys())
    extras = [cid for cid in sorted_ids if cid not in have]
    selected = have[:]
    for cid in extras:
        if len(selected) >= 10:
            break
        selected.append(cid)
    return selected[:10]


def render_prompt(domain: str, condition: str, case000: dict, caseR00: dict, caseRTC: dict) -> str:
    """Render a prompt mirroring the n=3 experiment format."""
    cid = case000["case_id"]
    sd = case000.get("summary_delta", {})
    md = case000.get("metadata", {})
    sd_str = ", ".join(f"{k}:{v}" for k, v in sd.items())
    md_str = ", ".join(f"{k}:{v}" for k, v in md.items())

    base_q = f"领域={domain}，case_id={cid}。"
    base_data = f"summary_delta={{{sd_str}}}; metadata={{{md_str}}}"

    if condition == "zero_cot":
        return (
            "以下是一个几何/拓扑问题的数据。请一步一步思考（think step by step），"
            "分析这个问题并给出你的推理过程和结论。\n\n"
            f"{base_q}\n数据：{base_data}"
        )
    if condition == "cot_code":
        return (
            "以下是一个几何/拓扑问题的数据。你可以写 Python 代码来辅助计算"
            "（不能使用任何引擎预计算的结构数据）。请给出推理过程和结论。\n\n"
            f"{base_q}\n数据：{base_data}"
        )
    if condition == "coe_r":
        dc = caseR00.get("detailed_comparison", {})
        sc = caseR00.get("structural_comparison", {})
        return (
            "以下是一个几何/拓扑问题。一个领域引擎已经计算了相关的结构数据 (R primitive)。"
            "请基于这些数据进行推理。\n\n"
            f"{base_q}\n基础数据：{base_data}\n"
            f"detailed_comparison={dc}\n"
            f"structural_comparison={sc}"
        )
    if condition == "coe_rtc":
        dc = caseRTC.get("detailed_comparison", {})
        sc = caseRTC.get("structural_comparison", {})
        tt = caseRTC.get("transform_trace", {})
        ctf = caseRTC.get("reference_in_transform_region", {})
        return (
            "以下是一个几何/拓扑问题。一个领域引擎已经计算了完整的 R+T+C 结构数据。"
            "请综合分析并给出推理过程和结论。\n\n"
            f"{base_q}\n基础数据：{base_data}\n"
            f"detailed_comparison={dc}\n"
            f"structural_comparison={sc}\n"
            f"transform_trace={tt}\n"
            f"counterfactual={ctf}"
        )
    raise ValueError(condition)


def main():
    out_trials = []
    selected_per_domain = {}
    trial_id = 0
    for domain in DOMAINS:
        c000 = load_ablation(domain, "000")
        cR00 = load_ablation(domain, "R00")
        cRTC = load_ablation(domain, "RTC")
        sel = select_cases(domain, c000)
        selected_per_domain[domain] = sel
        for cid in sel:
            for cond in CONDITIONS:
                trial_id += 1
                prompt = render_prompt(
                    domain, cond,
                    c000.get(cid, {}),
                    cR00.get(cid, {}),
                    cRTC.get(cid, {}),
                )
                out_trials.append({
                    "trial_id": trial_id,
                    "domain": domain,
                    "case_id": cid,
                    "condition": cond,
                    "prompt": prompt,
                })

    out = {
        "experiment": "method_comparison_n10",
        "design": {
            "factors": "8 domains x 4 conditions x 10 cases = 320 trials",
            "responder_model": "opus (self-response by claude-opus-4-7)",
            "rater_model": "opus (self-rated)",
            "domains": DOMAINS,
            "cases_per_domain": selected_per_domain,
            "conditions_meta": {
                "zero_cot": "Zero-shot CoT (Wei et al. 2022). Data: summary_delta + metadata only.",
                "cot_code": "CoT with Python tool (ToRA). Data: summary_delta + metadata, may write code.",
                "coe_r": "CoE with R primitive only. + detailed_comparison + structural_comparison.",
                "coe_rtc": "CoE full: R + T + C. + transform_trace + counterfactual.",
            },
            "rubric_0_to_4": {
                "0": "NO_SIGNAL — no useful reasoning or wrong",
                "1": "WRONG_PATTERN / NOTICE — observes structure but no real argument, or wrong",
                "2": "PATTERN — correct conclusion via pattern recognition / hand-wave / answer-leak",
                "3": "ARGUMENT — correct conclusion + sound reasoning chain with minor gaps",
                "4": "PROOF — rigorous derivation with explicit verification + invariant identification",
            },
            "honesty_protocol": (
                "For zero_cot and cot_code, responder restricts itself to the 000.json data. "
                "For coe_r, R00.json data only. For coe_rtc, RTC.json full access."
            ),
        },
        "trials": out_trials,
    }
    with open(ROOT / "experiments" / "method_comparison_n10_prompts.json", "w", encoding="utf-8") as f:
        json.dump(out, f, indent=2, ensure_ascii=False)
    print(f"Wrote {len(out_trials)} prompts.")
    print("Selected cases per domain:")
    for d, sel in selected_per_domain.items():
        print(f"  {d}: {sel}")


if __name__ == "__main__":
    main()
