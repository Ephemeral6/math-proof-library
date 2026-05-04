"""Build the 48 prompts for the cross-model Sonnet R-universality extension.

8 domains x 3 cases x 2 conditions = 48 trials.
Outputs SpatialMind/experiments/sonnet_prompts.json.
"""
import json
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
SAMPLED = os.path.join(ROOT, "sampled")

CASES = {
    "symmetry": ["same-006", "diff-163", "same-028"],
    "knot_theory": ["7_2-r2-1", "4_1-r2-4", "3_1-r2-3"],
    "graph_connectivity": ["R16_n12-t1", "R02_n12-t4", "R00_n8-t3"],
    "boundary_interior": [
        "crosspair-4-L_shape-vs-staircase",
        "rectangle_4x3-shear-1",
        "unit_square-shear-0",
    ],
    "discrete_curvature": [
        "cross-octahedron-vs-icosahedron-f1-1",
        "cube_triangulated-subdiv-f4-4",
        "tetrahedron-subdiv-f3-3",
    ],
    "projection": [
        "self-triangular_prism-yz",
        "self-cube-diagonal",
        "cross-octahedron-xzvsyz",
    ],
    "surface_topology": ["a331-b69", "a62-b12", "a12-b1"],
    "surface_topology_s21": ["a151-b6", "a122-b28", "a215-b1"],
}

QUESTION_TEMPLATES = {
    "symmetry": (
        "正六边形顶点 3 色着色 a 与 b。考虑循环群 Z_6 在顶点上的作用。"
        "判断 a 与 b 是否在同一个 Z_6 轨道下；若同轨道，给出群元素见证；若不同轨道，"
        "说明哪个不变量阻断了等价。"
    ),
    "knot_theory": (
        "对一个结的图代码应用 R2（Reidemeister 2）变换：在图上插入一对相消的交叉。"
        "判断该 R2 应用是否合法（即结类型与所有标准不变量是否保持），"
        "并说明 signature / determinant / Alexander 多项式 / writhe 的变化情况。"
    ),
    "graph_connectivity": (
        "给定一个简单无向图，删除一条指定的边。判断：(1) 该边是否为桥；"
        "(2) 删除后图是否仍连通；(3) 删除后桥数与关节点（articulation point）的变化。"
    ),
    "boundary_interior": (
        "给定一个网格多边形（顶点为整点）。基于 Pick 定理 A = I + B/2 - 1，"
        "判断给定的多边形（或一对多边形）的面积、边界格点数 B、内部格点数 I 是否一致，"
        "Pick 关系是否成立。"
    ),
    "discrete_curvature": (
        "给定一个三角化的多面体（曲面）。基于离散 Gauss-Bonnet：sum 角度亏格 = 2π·χ。"
        "对一个变换（细分或两个不同多面体比较），判断 Euler 特征 χ、总曲率、"
        "以及 Gauss-Bonnet 比率是否被保持。"
    ),
    "projection": (
        "给定一个三维多面体在某个二维平面上的投影。比较两种投影（自配对或两不同物体配对）"
        "在维度、点数、直径、边交叉数方面的结构差异。"
    ),
    "surface_topology": (
        "给定一个亏格 g=2 的紧致定向曲面 S 上的两条简单闭曲线 alpha 和 beta（用 Dehn 扭转字"
        "在标准生成元 a_1, b_1, a_2, b_2 上的 word 表示）。判断 alpha 与 beta 的几何相交"
        "数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
    "surface_topology_s21": (
        "给定一个亏格 g=2、带 1 个穿孔（边界）的曲面 S_{2,1} 上的两条简单闭曲线 alpha "
        "和 beta。判断几何相交数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
}

BASELINE_HEADER = (
    "你是一个数学推理助手。以下是一个几何/拓扑问题的数据。"
    "请分析这个问题并给出你的推理过程和结论。\n\n"
)
RTC_HEADER = (
    "你是一个数学推理助手。以下是一个几何/拓扑问题。一个领域引擎已经计算了"
    "结构数据 (R)、变换轨迹 (T) 和反事实对比 (C)。请基于这些数据进行推理并给出结论。\n\n"
)


def load_case(domain, case_id, condition):
    """condition is '000' or 'RTC'."""
    path = os.path.join(SAMPLED, domain, f"{case_id}__{condition}.json")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_baseline_prompt(domain, case_id):
    raw = load_case(domain, case_id, "000")
    cd = raw["case_data"]
    payload = {
        "case_id": case_id,
        "summary_delta": cd.get("summary_delta", {}),
        "metadata": cd.get("metadata", {}),
    }
    body = (
        f"### 问题背景\n{QUESTION_TEMPLATES[domain]}\n\n"
        f"### 案例 {case_id} 的基础数据 (summary_delta + metadata)\n"
        f"```json\n{json.dumps(payload, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 任务\n请基于以上数据回答上述问题，给出结论与简要推理。"
    )
    return BASELINE_HEADER + body


def build_rtc_prompt(domain, case_id):
    raw = load_case(domain, case_id, "RTC")
    cd = raw["case_data"]
    rtc_payload = {
        "case_id": case_id,
        "summary_delta": cd.get("summary_delta", {}),
        "metadata": cd.get("metadata", {}),
        "detailed_comparison": cd.get("detailed_comparison", {}),
        "structural_comparison": cd.get("structural_comparison", {}),
        "transform_trace": cd.get("transform_trace", {}),
    }
    if "reference_in_transform_region" in cd:
        rtc_payload["reference_in_transform_region"] = cd["reference_in_transform_region"]
    counterfactual = raw.get("counterfactual", [])
    body = (
        f"### 问题背景\n{QUESTION_TEMPLATES[domain]}\n\n"
        f"### 案例 {case_id} 的引擎结构数据 (R + T)\n"
        f"```json\n{json.dumps(rtc_payload, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 反事实对比 (C)\n"
        f"```json\n{json.dumps(counterfactual, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 任务\n请基于以上 R/T/C 数据回答问题，结合不变量、变换轨迹与反事实给出结论与推理。"
    )
    return RTC_HEADER + body


def main():
    prompts = []
    for domain, case_list in CASES.items():
        for case_id in case_list:
            prompts.append({
                "domain": domain,
                "case_id": case_id,
                "condition": "baseline",
                "prompt": build_baseline_prompt(domain, case_id),
            })
            prompts.append({
                "domain": domain,
                "case_id": case_id,
                "condition": "rtc",
                "prompt": build_rtc_prompt(domain, case_id),
            })
    out_path = os.path.join(ROOT, "sonnet_prompts.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(prompts, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(prompts)} prompts to {out_path}")
    print(f"Domains: {len(CASES)}, cases per domain: 3, conditions: 2")


if __name__ == "__main__":
    main()
