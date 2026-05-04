"""Build CoE-R-scrambled prompts: identical structure to CoE-R, but the
engine-computed R fields (summary_delta, detailed_comparison, structural_comparison)
have all numerical values randomly shuffled.  Metadata (problem definition) is
left untouched, modulo answer-leak fields filtered for parity with the original
coe_r prompts.

Seed: 42.  Per-trial sub-seed = 42 + index for reproducibility.
"""

from __future__ import annotations
import json
import random
import copy
from pathlib import Path

ROOT = Path("<REDACTED_LOCAL_PATH>")
BENCH = ROOT / "SpatialMind/benchmarks"
OUT = ROOT / "SpatialMind/experiments/scrambled_r_prompts.json"

DOMAINS_CASES = {
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

# Fields in metadata that leak the answer in the original honesty protocol.
# The original coe_r prompts in method_comparison_results.json strip these.
METADATA_ANSWER_LEAKS = {
    "symmetry": {"label", "same_orbit"},
    "knot_theory": set(),
    "graph_connectivity": set(),
    "boundary_interior": set(),
    "discrete_curvature": set(),
    "projection": set(),
    "surface_topology": set(),
    "surface_topology_s21": set(),
}


def scramble(obj, rng: random.Random):
    """Recursively replace numerical values with random ones; shuffle list orders.

    - bool          -> random True/False (must come before int test)
    - int           -> random int in [0, 10]
    - float         -> random float in [0, 10] rounded to 4 dp (sign randomized)
    - list[number]  -> each element resampled (preserves length)
    - list[other]   -> shuffled order, recurse on elements
    - dict          -> recurse on values; keys untouched
    - str / None    -> unchanged
    """
    if isinstance(obj, bool):
        return rng.random() < 0.5
    if isinstance(obj, int):
        return rng.randint(0, 10)
    if isinstance(obj, float):
        sign = 1 if rng.random() < 0.5 else -1
        return round(sign * rng.random() * 10, 4)
    if isinstance(obj, str) or obj is None:
        return obj
    if isinstance(obj, list):
        if all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in obj):
            return [scramble(x, rng) for x in obj]
        shuffled = list(obj)
        rng.shuffle(shuffled)
        return [scramble(x, rng) for x in shuffled]
    if isinstance(obj, dict):
        return {k: scramble(v, rng) for k, v in obj.items()}
    return obj


def build_problem_text(domain: str, meta: dict, case_id: str) -> str:
    """Construct a natural-language problem statement from metadata.
    Mirrors the question formats used in method_comparison_results.json.
    """
    if domain == "symmetry":
        a = meta.get("a_coloring")
        b = meta.get("b_coloring")
        n = len(a) if a else 6
        return (
            f"问题：在 {n} 顶点循环群 Z_{n} 作用下，"
            f"给定 a_coloring={a} 和 b_coloring={b}。"
            f"判断 a 和 b 是否在同一轨道。"
        )
    if domain == "knot_theory":
        knot = meta.get("knot")
        move = meta.get("move")
        n_pre = meta.get("n_crossings_pre")
        n_post = meta.get("n_crossings_post")
        return (
            f"问题：对结 {knot} 的图（{n_pre} 个交叉点）应用 Reidemeister {move} 操作"
            f"得到一个新图（{n_post} 个交叉点）。"
            f"判断该 R-move 是否保持结的不变量（writhe / signature / Alexander / determinant）。"
        )
    if domain == "graph_connectivity":
        nv = meta.get("n_vertices")
        ne = meta.get("n_edges_before")
        de = meta.get("deleted_edge")
        return (
            f"问题：给定一个 {nv} 顶点 {ne} 条边的图，删除边 {de}。"
            f"分析删除前后图的连通性、bridge 数、连通分量、关键点（articulation point）变化。"
        )
    if domain == "boundary_interior":
        preset = meta.get("preset") or meta.get("preset_a") or meta.get("preset_pair")
        op = meta.get("operation")
        return (
            f"问题：对格子多边形 {preset} 进行 {op} 变换。"
            f"比较变换前后的面积、周长、边界格点数 B、内部格点数 I，"
            f"以及 Pick 公式 A = I + B/2 - 1 是否保持。"
        )
    if domain == "discrete_curvature":
        preset = meta.get("preset")
        op = meta.get("operation")
        ref = meta.get("ref_preset")
        return (
            f"问题：对 3D 三角网格 {preset} 进行 {op} 操作（参照 {ref}）。"
            f"计算变换前后的总顶点亏角 Σδ、Euler 特征数 χ、"
            f"以及 Gauss-Bonnet 比率 Σδ/(2π) 是否等于 χ。"
        )
    if domain == "projection":
        obj = meta.get("object")
        plane = meta.get("plane")
        case_type = meta.get("case_type")
        return (
            f"问题：对 3D 物体 {obj} 进行投影到 {plane} 平面（case_type={case_type}）。"
            f"分析投影后的距离保持比例、引入的边交叉/碰撞、"
            f"维度损失，以及哪些信息是不可恢复的。"
        )
    if domain in ("surface_topology", "surface_topology_s21"):
        surface = meta.get("surface")
        a_idx = meta.get("alpha_index")
        b_idx = meta.get("beta_index")
        i_ab = meta.get("i_alpha_beta")
        return (
            f"问题：在亏格 surface={surface} 上，"
            f"曲线 alpha_{a_idx} 与 beta_{b_idx}。"
            f"理论几何相交数 i(α,β)={i_ab}。"
            f"判断当前的曲线代表是否处于最小相交位置（minimal position），"
            f"并比较 transform 前后的交叉数变化。"
        )
    return f"问题：{domain}/{case_id} (no template)"


def filter_metadata(meta: dict, domain: str) -> dict:
    leaks = METADATA_ANSWER_LEAKS.get(domain, set())
    return {k: v for k, v in meta.items() if k not in leaks}


def compact_json(obj) -> str:
    return json.dumps(obj, ensure_ascii=False, separators=(",", ":"))


def build_prompt(domain: str, case_id: str, case: dict, rng: random.Random) -> str:
    meta = filter_metadata(case["metadata"], domain)
    problem = build_problem_text(domain, case["metadata"], case_id)

    # Scramble the engine-computed R fields.
    sd = scramble(copy.deepcopy(case.get("summary_delta", {})), rng)
    dc = scramble(copy.deepcopy(case.get("detailed_comparison", {})), rng)
    sc = scramble(copy.deepcopy(case.get("structural_comparison", {})), rng)

    prompt = (
        "你是一个数学推理助手。以下是一个几何/拓扑问题。"
        "一个领域引擎已经计算了相关的结构数据（Relation data）。"
        "请基于这些数据进行推理。\n\n"
        f"{problem}\n"
        f"metadata={compact_json(meta)}\n"
        f"R 数据 (summary_delta)={compact_json(sd)}\n"
        f"R 数据 (detailed_comparison)={compact_json(dc)}\n"
        f"R 数据 (structural_comparison)={compact_json(sc)}"
    )
    return prompt


def main():
    trials = []
    trial_id = 0
    base_seed = 42
    for domain, cases in DOMAINS_CASES.items():
        path = BENCH / domain / "ablation" / "R00.json"
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        cmap = {c["case_id"]: c for c in data["cases"]}
        for case_id in cases:
            trial_id += 1
            case = cmap[case_id]
            rng = random.Random(base_seed + trial_id)
            prompt = build_prompt(domain, case_id, case, rng)
            trials.append(
                {
                    "trial_id": trial_id,
                    "domain": domain,
                    "case_id": case_id,
                    "condition": "coe_r_scrambled",
                    "seed": base_seed + trial_id,
                    "prompt": prompt,
                }
            )
    out = {
        "experiment": "scrambled_r_control",
        "design": {
            "purpose": (
                "Fake-R control: scramble all numeric values in engine-computed "
                "R primitive (summary_delta + detailed_comparison + "
                "structural_comparison) while keeping JSON structure, field names, "
                "and problem-defining metadata intact.  Compare against CoE-R "
                "baseline from method_comparison_results.json."
            ),
            "factors": "8 domains x 3 cases x 1 condition = 24 trials",
            "responder_model": "opus (self-response by claude-opus-4-7)",
            "rater_model": "opus (self-rated)",
            "scramble_rules": {
                "bool": "random True/False",
                "int": "random integer in [0,10]",
                "float": "random float in [-10,10] rounded to 4dp",
                "list_of_numbers": "each element resampled (length preserved)",
                "list_of_other": "order shuffled, contents recursed",
                "dict": "values recursed, keys untouched",
                "string_or_None": "unchanged",
            },
            "seeds": "base seed 42, per-trial seed = 42 + trial_id",
        },
        "trials": trials,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(trials)} prompts to {OUT}")


if __name__ == "__main__":
    main()
