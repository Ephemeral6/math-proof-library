"""Generate multiple-choice questions from each SpatialMind domain's level_4.json.

Each MCQ records the question text, 4 options, correct answer, the source
case id, and the per-case CoE data slice (R / T / C primitives + base) so the
eval runner can prompt 6 conditions:
Baseline / CoT / CoE-R / CoE-RT / CoE-RC / CoE-CTR.

Output: SpatialMind/benchmarks/<domain>/mcq/questions.json
"""

import json
import random
import argparse
from pathlib import Path
from collections import Counter

ROOT = Path(__file__).resolve().parents[2]  # SpatialMind/
BENCH = ROOT / "benchmarks"


def load_domain(domain):
    p = BENCH / domain / "level_4.json"
    with open(p, "r", encoding="utf-8") as f:
        d = json.load(f)
    rtc_path = BENCH / domain / "ablation" / "RTC.json"
    top_cf = []
    if rtc_path.exists():
        with open(rtc_path, "r", encoding="utf-8") as f:
            top_cf = json.load(f).get("counterfactual", [])
    return d["cases"], top_cf


def slice_RTC(case, top_counterfactual):
    return {
        "base": {
            "summary_delta": case.get("summary_delta", {}),
            "metadata":      case.get("metadata", {}),
        },
        "R": {
            "detailed_comparison":   case.get("detailed_comparison", {}),
            "structural_comparison": case.get("structural_comparison", {}),
        },
        "T": {
            "transform_trace":               case.get("transform_trace", {}),
            "reference_in_transform_region": case.get("reference_in_transform_region", {}),
        },
        "C": {"counterfactual": top_counterfactual},
    }


def balance_sample(cases, predicate, n_each, seed=42):
    pos = [c for c in cases if predicate(c)]
    neg = [c for c in cases if not predicate(c)]
    n = min(n_each, len(pos), len(neg))
    rng = random.Random(seed)
    return rng.sample(pos, n) + rng.sample(neg, n)


# ---------- Per-domain question generators ----------

def gen_graph_connectivity(case, top_cf, qid):
    md = case["metadata"]
    n, m, edge = md["n_vertices"], md["n_edges_before"], md["deleted_edge"]
    is_bridge = case["transform_trace"]["delta"]["is_bridge"]
    answer = "B" if is_bridge else "A"
    q = (f"给定一个有 {n} 个顶点、{m} 条边的连通图 G。"
         f"现在删除边 ({edge[0]}, {edge[1]})。删除之后 G 是否仍然连通？")
    return {
        "question_id": qid,
        "domain": "graph_connectivity",
        "question": q,
        "options": {
            "A": "仍然连通（图保持单一连通分量）",
            "B": "不再连通（图分裂为 2 个连通分量）",
            "C": "仍然连通，且与原图同构",
            "D": "不再连通，且分裂为 3 个或更多连通分量",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_symmetry(case, top_cf, qid):
    md = case["metadata"]
    a, b = md["a_coloring"], md["b_coloring"]
    same = bool(md["same_orbit"])
    answer = "A" if same else "B"
    q = (f"用 3 种颜色对正六边形 6 个顶点着色。考虑两种着色 a={a} 与 b={b}。"
         f"在循环群 Z6 的旋转作用下，a 和 b 是否属于同一轨道？")
    return {
        "question_id": qid,
        "domain": "symmetry",
        "question": q,
        "options": {
            "A": "是，存在一个旋转将 a 映为 b",
            "B": "否，没有旋转可以将 a 映为 b",
            "C": "是，但需要反射操作而非旋转",
            "D": "无法判断，需要先计算 Burnside 平均",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_projection(case, top_cf, qid):
    md = case["metadata"]
    obj = md.get("object", "?")
    plane = md.get("plane", "?")
    n_pts = md.get("n_points", "?")
    delta = case["transform_trace"]["delta"]
    has_collision = delta["n_point_collisions"] > 0
    answer = "A" if has_collision else "B"
    q = (f"将物体 {obj} ({n_pts} 个顶点) 投影到 {plane} 平面 (丢弃 {('z' if plane=='xy' else 'y' if plane=='xz' else 'x')} 轴)。"
         f"投影后是否存在两个原本不同的顶点重合到同一像点？")
    return {
        "question_id": qid,
        "domain": "projection",
        "question": q,
        "options": {
            "A": "存在顶点碰撞（至少两顶点投影后重合）",
            "B": "不存在顶点碰撞（所有顶点的投影互不相同）",
            "C": "投影后顶点数变多，因为出现新交点",
            "D": "无法投影，因为该方向上物体退化",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_surface_topology_s21(case, top_cf, qid):
    md = case["metadata"]
    a_idx, b_idx = md["alpha_index"], md["beta_index"]
    i_pre = md["i_alpha_beta"]
    delta_i = case["summary_delta"]["intersection_number"]
    reduced = delta_i < 0
    answer = "A" if reduced else "B"
    q = (f"在曲面 S_{{2,1}} 上有两条简单闭曲线 α (index={a_idx}) 和 β (index={b_idx})，"
         f"原始几何交点数 i(α,β) = {i_pre}。对 α 沿 σ 做 Hatcher surgery 得到 α'。"
         f"surgery 之后 i(α',β) 是否严格小于 i(α,β)？")
    return {
        "question_id": qid,
        "domain": "surface_topology_s21",
        "question": q,
        "options": {
            "A": "是，i(α',β) 严格小于原值",
            "B": "否，i(α',β) 等于或大于原值",
            "C": "是，且 i(α',β) = 0",
            "D": "无法判断，因为 surgery 不改变同伦类",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_boundary_interior(case, top_cf, qid):
    md = case["metadata"]
    op = md.get("operation", "?")
    preset = md.get("preset", "?")
    delta = case["transform_trace"]["delta"]
    area_changed = abs(delta.get("area_change", 0)) > 1e-9
    answer = "B" if area_changed else "A"
    q = (f"对一个格点多边形 (preset={preset}) 应用 {op} 变换。"
         f"变换之后，多边形的面积是否保持不变？")
    return {
        "question_id": qid,
        "domain": "boundary_interior",
        "question": q,
        "options": {
            "A": "面积保持不变",
            "B": "面积发生改变",
            "C": "面积保持不变，但内部格点数 I 改变",
            "D": "面积改变，但 Pick 公式 A = I + B/2 - 1 不再成立",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_knot_theory(case, top_cf, qid):
    """All level_4 cases are R2 moves with [+1,-1] crossing pair.
    4-way numerical: predict post-move crossing count.
    """
    md = case["metadata"]
    knot = md["knot"]
    n_pre = md["n_crossings_pre"]
    n_post = md["n_crossings_post"]
    correct_letter = "C"  # always n_pre + 2 for R2
    options = {
        "A": f"{n_pre}（保持不变）",
        "B": f"{n_pre + 1}",
        "C": f"{n_pre + 2}",
        "D": f"{n_pre + 4}",
    }
    assert int(options[correct_letter].split("（")[0]) == n_post, f"R2 invariant violated: {n_pre}+2 != {n_post}"
    q = (f"对纽结 {knot} 的一个图解 (有 {n_pre} 个交叉) 应用 Reidemeister R2 move (引入一对反号交叉)。"
         f"操作之后图解有多少个交叉？")
    return {
        "question_id": qid,
        "domain": "knot_theory",
        "question": q,
        "options": options,
        "answer": correct_letter,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


def gen_discrete_curvature(case, top_cf, qid):
    """Two operations: stellar_subdivision (adds 1 vertex) vs vertex_displacement (no add).
    Question: does this op add a new vertex?
    """
    md = case["metadata"]
    preset = md.get("preset", "?")
    op = md.get("operation", "?")
    v_added = case["transform_trace"]["delta"].get("vertices_added", 0)
    answer = "A" if v_added > 0 else "B"
    q = (f"对多面体 {preset} 应用 {op} 变换。变换之后，多面体的顶点数是否增加？")
    return {
        "question_id": qid,
        "domain": "discrete_curvature",
        "question": q,
        "options": {
            "A": "顶点数增加",
            "B": "顶点数保持不变",
            "C": "顶点数增加，且 Euler 特征数 χ 也改变",
            "D": "顶点数减少",
        },
        "answer": answer,
        "case_id": case["case_id"],
        "coe_data": slice_RTC(case, top_cf),
    }


# ---------- Domain registry ----------

DOMAIN_CONFIG = {
    "graph_connectivity": {
        "generator": gen_graph_connectivity,
        "predicate": lambda c: c["transform_trace"]["delta"]["is_bridge"],
        "n_each": 17,
    },
    "symmetry": {
        "generator": gen_symmetry,
        "predicate": lambda c: bool(c["metadata"]["same_orbit"]),
        "n_each": 30,
    },
    "projection": {
        "generator": gen_projection,
        "predicate": lambda c: c["transform_trace"]["delta"]["n_point_collisions"] > 0,
        "n_each": 25,
    },
    "surface_topology_s21": {
        "generator": gen_surface_topology_s21,
        "predicate": lambda c: c["summary_delta"]["intersection_number"] < 0,
        "n_each": 30,
    },
    "boundary_interior": {
        "generator": gen_boundary_interior,
        "predicate": lambda c: abs(c["transform_trace"]["delta"].get("area_change", 0)) > 1e-9,
        "n_each": 16,
    },
    "discrete_curvature": {
        "generator": gen_discrete_curvature,
        "predicate": lambda c: c["transform_trace"]["delta"].get("vertices_added", 0) > 0,
        "n_each": 20,
    },
    "knot_theory": {
        # No binary predicate (all R2). Random sample.
        "generator": gen_knot_theory,
        "predicate": None,
        "n_size": 30,
    },
}


def shuffle_options(q, seed):
    """Permute the {A,B,C,D} -> option-text mapping deterministically per question
    so the correct letter is not biased by question template order."""
    rng = random.Random(seed)
    letters = ["A", "B", "C", "D"]
    perm = letters[:]
    rng.shuffle(perm)
    old_to_new = dict(zip(letters, perm))
    new_options = {old_to_new[k]: v for k, v in q["options"].items()}
    q["options"] = {k: new_options[k] for k in letters}
    q["answer"] = old_to_new[q["answer"]]
    return q


def build_domain(domain, seed=42):
    cfg = DOMAIN_CONFIG[domain]
    cases, top_cf = load_domain(domain)
    if cfg.get("predicate") is None:
        rng = random.Random(seed)
        sample = rng.sample(cases, min(cfg["n_size"], len(cases)))
    else:
        sample = balance_sample(cases, cfg["predicate"], cfg["n_each"], seed=seed)
    out = []
    for i, c in enumerate(sample, 1):
        qid = f"{domain}_{i:03d}"
        q = cfg["generator"](c, top_cf, qid)
        q = shuffle_options(q, seed=seed * 1000 + i)
        out.append(q)
    return out


def write_domain(domain, qs):
    out_dir = BENCH / domain / "mcq"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "questions.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"domain": domain, "n_questions": len(qs), "questions": qs},
                  f, ensure_ascii=False, indent=2)
    answers = Counter(q["answer"] for q in qs)
    return out_path, dict(answers)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--domains", nargs="+", default=list(DOMAIN_CONFIG.keys()))
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()
    for dom in args.domains:
        qs = build_domain(dom, seed=args.seed)
        path, dist = write_domain(dom, qs)
        print(f"{dom}: {len(qs)} questions, answer distribution {dist}, -> {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
