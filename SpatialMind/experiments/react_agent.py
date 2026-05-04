"""ReAct + domain-engine experiment.

Comparison condition for the CoE method comparison: instead of pushing all
R/T/C primitives up-front (CoE), the LLM gets only the baseline data and
chooses when/which primitive to query. Engine-side data is identical to CoE;
the difference is who initiates the data flow.

The engine is exposed as a CLI so a constrained LLM agent can fetch primitives
via a single tool call. Each query is logged for audit.

Usage:
    python react_agent.py init <domain> <case_id>           # baseline data
    python react_agent.py query <domain> <case_id> <R|T|C>  # one primitive
    python react_agent.py cases                             # list all 24 cases
"""
import argparse
import json
import os
import sys
import time

ROOT = os.path.dirname(os.path.abspath(__file__))
SAMPLED = os.path.join(ROOT, "sampled")
LOG_PATH = os.path.join(ROOT, "react_engine_log.jsonl")

# Same 24 cases as method_comparison_results.json (the existing 4-condition experiment).
CASES = {
    "symmetry": ["same-006", "diff-163", "same-028"],
    "knot_theory": ["3_1-r2-3", "4_1-r2-4", "5_2-r2-5"],
    "graph_connectivity": ["R00_n8-t3", "R02_n12-t4", "R07_n8-t0"],
    "boundary_interior": [
        "crosspair-4-L_shape-vs-staircase",
        "L_shape-scale-0",
        "L_shape-trans-1",
    ],
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

QUESTION_TEMPLATES = {
    "symmetry": (
        "正六边形顶点 3 色着色 a 与 b。考虑循环群 Z_6 在顶点上的作用。"
        "判断 a 与 b 是否在同一个 Z_6 轨道下；若同轨道，给出群元素见证；"
        "若不同轨道，说明哪个不变量阻断了等价。"
    ),
    "knot_theory": (
        "对一个结的图代码应用 R2（Reidemeister 2）变换：在图上插入一对相消的交叉。"
        "判断该 R2 应用是否合法（即结类型与所有标准不变量是否保持），"
        "并说明 signature / determinant / Alexander 多项式 / writhe 的变化情况。"
    ),
    "graph_connectivity": (
        "给定一个简单无向图，删除一条指定的边。判断："
        "(1) 该边是否为桥；(2) 删除后图是否仍连通；"
        "(3) 删除后桥数与关节点（articulation point）的变化。"
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
        "给定一个三维多面体在某个二维平面上的投影。比较两种投影"
        "（自配对或两不同物体配对）在维度、点数、直径、边交叉数方面的结构差异。"
    ),
    "surface_topology": (
        "给定一个亏格 g=2 的紧致定向曲面 S 上的两条简单闭曲线 alpha 和 beta"
        "（用 Dehn 扭转字在标准生成元 a_1, b_1, a_2, b_2 上的 word 表示）。"
        "判断 alpha 与 beta 的几何相交数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
    "surface_topology_s21": (
        "给定一个亏格 g=2、带 1 个穿孔（边界）的曲面 S_{2,1} 上的两条简单闭曲线 "
        "alpha 和 beta。判断几何相交数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
}


def _load_rtc(domain, case_id):
    path = os.path.join(SAMPLED, domain, f"{case_id}__RTC.json")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _log(record):
    record["ts"] = time.time()
    with open(LOG_PATH, "a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


def init_case(domain, case_id):
    """Baseline data the ReAct agent sees up-front. Same as 000.json."""
    raw = _load_rtc(domain, case_id)
    cd = raw["case_data"]
    payload = {
        "domain": domain,
        "case_id": case_id,
        "question": QUESTION_TEMPLATES[domain],
        "summary_delta": cd.get("summary_delta", {}),
        "metadata": cd.get("metadata", {}),
    }
    _log({"event": "init", "domain": domain, "case_id": case_id})
    return payload


def query_primitive(domain, case_id, primitive):
    """Return one of R / T / C. The same data CoE-RTC pushes up-front."""
    raw = _load_rtc(domain, case_id)
    cd = raw["case_data"]
    p = primitive.upper()
    if p == "R":
        result = {
            "primitive": "R",
            "detailed_comparison": cd.get("detailed_comparison", {}),
            "structural_comparison": cd.get("structural_comparison", {}),
        }
    elif p == "T":
        result = {
            "primitive": "T",
            "transform_trace": cd.get("transform_trace", {}),
        }
        if "reference_in_transform_region" in cd:
            result["reference_in_transform_region"] = cd["reference_in_transform_region"]
    elif p == "C":
        result = {
            "primitive": "C",
            "counterfactual": raw.get("counterfactual", []),
        }
    else:
        raise ValueError(f"primitive must be R/T/C, got {primitive}")
    _log({"event": "query", "domain": domain, "case_id": case_id, "primitive": p})
    return result


def _print_json(obj):
    json.dump(obj, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")


def main():
    parser = argparse.ArgumentParser(description="ReAct domain engine")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_init = sub.add_parser("init")
    p_init.add_argument("domain")
    p_init.add_argument("case_id")

    p_query = sub.add_parser("query")
    p_query.add_argument("domain")
    p_query.add_argument("case_id")
    p_query.add_argument("primitive", choices=["R", "T", "C", "r", "t", "c"])

    sub.add_parser("cases")

    args = parser.parse_args()
    if args.cmd == "init":
        _print_json(init_case(args.domain, args.case_id))
    elif args.cmd == "query":
        _print_json(query_primitive(args.domain, args.case_id, args.primitive))
    elif args.cmd == "cases":
        _print_json(CASES)


if __name__ == "__main__":
    main()
