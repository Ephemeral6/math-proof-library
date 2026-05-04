"""Generate the CoE Geometric Reasoning Benchmark — Dimension 4 (symmetry).

Each question has 3 sub-parts with objective integer / set answers, and is
rendered into 4 prompt conditions:

  baseline   — stem + sub-questions only
  cot        — baseline + "let's think step by step"
  coe_r      — baseline + Relation data (group permutations, fixed-point counts)
  coe_ctr    — coe_r + Transform data (one g acting on c) + Counterfactual (Z_6 vs D_6)

The Relation/Transform/Counterfactual bundles are deliberately scrubbed of
direct answers — `orbit_size_a`, `stabilizer_a`, `burnside_count`, and
`total_orbits` are removed before serialization. The LLM must derive each
target value via orbit-stabilizer or Burnside reasoning.

Output:
  SpatialMind/benchmarks/coe_reasoning/dim4_symmetry/questions.json
"""

from __future__ import annotations

import json
import os
import sys
from copy import deepcopy

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.symmetry.engine import SymmetryEngine

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim4_symmetry"
)


# ----- helpers --------------------------------------------------------------

def fmt_coloring(c):
    return "(" + ", ".join(str(x) for x in c) + ")"


def fmt_perm(p):
    return "[" + ", ".join(str(x) for x in p) + "]"


def fmt_set(s):
    return "{" + ", ".join(str(x) for x in sorted(s)) + "}"


def stab_indices(engine, coloring):
    return [i for i, g in enumerate(engine.group_elements)
            if engine._apply(coloring, g) == coloring]


def orbit_size(engine, coloring):
    seen = set()
    for g in engine.group_elements:
        seen.add(engine._apply(coloring, g))
    return len(seen)


# ----- coe data builders ----------------------------------------------------

def build_R_for_coloring(engine, coloring, group_label="Z_6"):
    """Relation-bundle data for a single-coloring question.

    Includes group permutations and fixed-point counts (the Burnside core
    data). Does NOT include orbit_size, stabilizer, burnside_count, or
    total_orbits — those are the targets.
    """
    return {
        "group": group_label,
        "group_order": len(engine.group_elements),
        "group_elements": [
            {"index": i, "permutation": list(g),
             "is_rotation": i < engine.m,
             "order_in_group": engine._element_order(g)}
            for i, g in enumerate(engine.group_elements)
        ],
        "fixed_point_counts": {
            str(i): engine._fixed_point_counts()[i]
            for i in range(len(engine.group_elements))
        },
        "fixed_point_counts_explanation": (
            "fixed_point_counts[i] = number of colorings c (out of "
            f"{engine.k**engine.m}) such that g_i · c = c."
        ),
        "n_total_colorings": engine.k ** engine.m,
    }


def build_T_for_coloring(engine, coloring, g_index):
    """Transform-bundle data: show one group element acting on c."""
    g = engine.group_elements[g_index]
    new_c = engine._apply(coloring, g)
    moved = [i for i in range(engine.m) if coloring[i] != new_c[i]]
    fixed = [i for i in range(engine.m) if coloring[i] == new_c[i]]
    return {
        "chosen_element_index": g_index,
        "permutation": list(g),
        "before_coloring": list(coloring),
        "after_coloring": list(new_c),
        "moved_vertices": moved,
        "fixed_vertices": fixed,
        "is_fixed_point": coloring == new_c,
        "note": (
            f"Applying g_{g_index} (permutation {list(g)}) to the coloring. "
            f"new[j] = old[perm[j]]."
        ),
    }


def build_C_for_coloring(engine, coloring):
    """Counterfactual data: contrast Z_6 with D_6 and {e}.

    Hides total orbit counts; only exposes what changes structurally.
    """
    bigger = SymmetryEngine(engine.m, engine.k, group="dihedral")
    # Z_6 stabilizer change to D_6: hidden — but show that D_6 has 6 extra
    # reflection elements and report fixed-point counts for those alone.
    reflection_fpc = {}
    for i in range(engine.m, len(bigger.group_elements)):
        reflection_fpc[str(i)] = bigger._fixed_point_counts()[i]

    return {
        "boundary_relaxation": {
            "original_group": "Z_6 (6 rotations)",
            "modified_group": "D_6 (6 rotations + 6 reflections)",
            "added_elements": [
                {"index": i, "permutation": list(bigger.group_elements[i]),
                 "is_reflection": True}
                for i in range(engine.m, len(bigger.group_elements))
            ],
            "added_elements_fixed_point_counts": reflection_fpc,
            "note": (
                "Enlarging G merges some Z_6-orbits into single D_6-orbits. "
                "Total orbit counts not provided — derive via Burnside on D_6."
            ),
        },
        "condition_removal": {
            "original_group": "Z_6",
            "modified_group": "{e} (trivial)",
            "consequence": "Every coloring is its own orbit; #orbits = "
                           f"{engine.k}^{engine.m} = {engine.k**engine.m}.",
        },
        "operation_perturbation": {
            "non_group_permutation_example": [1, 0, 2, 3, 4, 5],
            "note": (
                "swap(0,1) is not a rotation — applying it can leave the "
                "Z_6-orbit. Useful as a contrast for what counts as a 'symmetry'."
            ),
        },
    }


def build_R_for_pair(engine, a_col, b_col):
    """Relation bundle for an (a, b) pair.

    Includes per-vertex diff and Hamming distance (geometric evidence).
    Does NOT include the explicit list of connecting group elements —
    LLM must compute g·a for each g and check equality with b. The
    `connecting_elements_count` is included as a "same-orbit witness"
    integer (count > 0 ⟺ same orbit), which makes (a) easier but leaves
    (b) and (c) as real reasoning tasks.
    """
    base = build_R_for_coloring(engine, a_col)
    n_connecting = sum(
        1 for g in engine.group_elements if engine._apply(a_col, g) == b_col
    )
    base["pair_data"] = {
        "a": list(a_col),
        "b": list(b_col),
        "hamming_distance": sum(1 for x, y in zip(a_col, b_col) if x != y),
        "per_vertex_diff": [int(x != y) for x, y in zip(a_col, b_col)],
        "connecting_elements_count": n_connecting,
        "note": (
            "connecting_elements_count is the number of g in G with g·a = b. "
            "The explicit list is NOT given — derive it by checking each g."
        ),
    }
    return base


# ----- prompt rendering -----------------------------------------------------

ANSWER_FORMAT = """
请严格按照以下格式输出答案（这部分会被自动评分系统解析）：

[ANSWER]
(a) <答案>
(b) <答案>
(c) <答案>
[/ANSWER]

答案规范：
- 整数请直接写数字（如 3、130）。
- 集合/列表请用花括号或方括号，元素间用逗号分隔（如 {0, 3} 或 [0,3]）。
- 不要在 [ANSWER] 块内添加解释。

随后用 [REASONING] ... [/REASONING] 提供推理过程。
"""


def render_baseline(stem, subqs):
    parts = [stem, ""]
    parts.append("请回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_cot(stem, subqs):
    parts = [stem, ""]
    parts.append("请回答以下子问题。Let's think step by step —— "
                 "请逐步推理，先分析每个子问题的关键概念，再给出答案。")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_coe_r(stem, subqs, R):
    parts = [stem, ""]
    parts.append("以下是 CoE 引擎提供的关系数据 (Relation)：")
    parts.append("```json")
    parts.append(json.dumps(R, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("请基于上述数据回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_coe_ctr(stem, subqs, R, T, C):
    parts = [stem, ""]
    parts.append("以下是 CoE 引擎提供的完整数据。")
    parts.append("")
    parts.append("### Relation (R) — 群结构与不动点计数")
    parts.append("```json")
    parts.append(json.dumps(R, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("### Transform (T) — 单个群元素作用的具体轨迹")
    parts.append("```json")
    parts.append(json.dumps(T, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("### Counterfactual (C) — 群放大 / 缩小 / 非群置换的对比")
    parts.append("```json")
    parts.append(json.dumps(C, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("请基于上述数据回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


# ----- question constructors -----------------------------------------------

def make_orbit_stab_question(qid, engine, coloring, t_g_index):
    """Q-type 1: given c, ask (a) orbit size, (b) stabilizer, (c) total Z_6 orbits."""
    c_str = fmt_coloring(coloring)
    stem = (
        f"在正六边形（6 个顶点）上用 3 种颜色着色（颜色编号 0/1/2）。给定一个具体着色\n"
        f"  c = {c_str}\n"
        f"考虑循环群 G = Z_6（6 个旋转）作用在着色上：g_i 把顶点 j 上的颜色换成顶点 perm_i(j) 上的颜色。"
    )
    subqs = [
        {"label": "(a)", "text": "着色 c 在 Z_6 作用下的轨道大小 |Orbit(c)| 是多少？",
         "answer_type": "integer", "answer": orbit_size(engine, coloring)},
        {"label": "(b)", "text": "稳定子 Stab(c) 包含哪些群元素？请以索引集合形式给出（例如 {0, 3} 表示 g_0 和 g_3）。",
         "answer_type": "set_of_int", "answer": stab_indices(engine, coloring)},
        {"label": "(c)", "text": "在 Z_6 作用下，3 色 6 顶点正六边形一共有多少个不等价的着色？",
         "answer_type": "integer", "answer": len(engine.orbits)},
    ]
    R = build_R_for_coloring(engine, coloring)
    T = build_T_for_coloring(engine, coloring, t_g_index)
    C = build_C_for_coloring(engine, coloring)

    return {
        "question_id": qid,
        "type": "orbit_stabilizer",
        "stem": stem,
        "subquestions": subqs,
        "ground_truth": {
            "coloring": list(coloring),
            "orbit_size": orbit_size(engine, coloring),
            "stabilizer": stab_indices(engine, coloring),
            "total_orbits_Z6": len(engine.orbits),
        },
        "coe_data": {"R": R, "T": T, "C": C},
        "prompts": {
            "baseline": render_baseline(stem, subqs),
            "cot": render_cot(stem, subqs),
            "coe_r": render_coe_r(stem, subqs, R),
            "coe_ctr": render_coe_ctr(stem, subqs, R, T, C),
        },
    }


def make_group_switch_question(qid, engine_z6, engine_d6, coloring, t_g_index):
    """Q-type 2: contrast Z_6 and D_6 orbit structure for a fixed coloring."""
    c_str = fmt_coloring(coloring)
    stem = (
        f"在正六边形上用 3 种颜色着色。给定着色\n"
        f"  c = {c_str}\n"
        f"我们对比两个对称群：Z_6（6 个旋转）和 D_6（6 个旋转 + 6 个反射）作用在 729 个 3 着色上。"
    )
    orbit_z = orbit_size(engine_z6, coloring)
    orbit_d = orbit_size(engine_d6, coloring)
    subqs = [
        {"label": "(a)", "text": "着色 c 在 Z_6 作用下的轨道大小是多少？",
         "answer_type": "integer", "answer": orbit_z},
        {"label": "(b)", "text": "着色 c 在 D_6 作用下的轨道大小是多少？",
         "answer_type": "integer", "answer": orbit_d},
        {"label": "(c)", "text": "把 G 从 Z_6 扩大到 D_6 时，全部不等价着色的总数从多少变到多少？请以「X -> Y」格式回答（例如 130 -> 92）。",
         "answer_type": "two_integers",
         "answer": [len(engine_z6.orbits), len(engine_d6.orbits)]},
    ]
    R = build_R_for_coloring(engine_z6, coloring)
    # Augment R with D_6 fixed-point counts
    R_aug = deepcopy(R)
    R_aug["d6_extension"] = {
        "added_reflection_elements": [
            {"index": i, "permutation": list(engine_d6.group_elements[i])}
            for i in range(engine_z6.m, len(engine_d6.group_elements))
        ],
        "d6_fixed_point_counts": {
            str(i): engine_d6._fixed_point_counts()[i]
            for i in range(len(engine_d6.group_elements))
        },
        "d6_group_order": len(engine_d6.group_elements),
    }
    T = build_T_for_coloring(engine_d6, coloring, t_g_index)  # one reflection
    C = build_C_for_coloring(engine_z6, coloring)

    return {
        "question_id": qid,
        "type": "group_switch",
        "stem": stem,
        "subquestions": subqs,
        "ground_truth": {
            "coloring": list(coloring),
            "orbit_size_Z6": orbit_z,
            "orbit_size_D6": orbit_d,
            "total_orbits_Z6": len(engine_z6.orbits),
            "total_orbits_D6": len(engine_d6.orbits),
        },
        "coe_data": {"R": R_aug, "T": T, "C": C},
        "prompts": {
            "baseline": render_baseline(stem, subqs),
            "cot": render_cot(stem, subqs),
            "coe_r": render_coe_r(stem, subqs, R_aug),
            "coe_ctr": render_coe_ctr(stem, subqs, R_aug, T, C),
        },
    }


def make_pair_question(qid, engine, a_col, b_col, t_g_index):
    """Q-type 3: given (a, b), ask equivalence + connecting elements + stab."""
    same_orbit = engine._coloring_to_orbit[a_col] == engine._coloring_to_orbit[b_col]
    connecting = [i for i, g in enumerate(engine.group_elements)
                  if engine._apply(a_col, g) == b_col]
    stab_a = stab_indices(engine, a_col)
    stem = (
        f"在正六边形上的两个 3 着色：\n"
        f"  a = {fmt_coloring(a_col)}\n"
        f"  b = {fmt_coloring(b_col)}\n"
        f"考虑循环群 Z_6 作用。"
    )
    subqs = [
        {"label": "(a)", "text": "a 和 b 是否属于同一个 Z_6-轨道？请回答 1（是）或 0（否）。",
         "answer_type": "integer", "answer": int(same_orbit)},
        {"label": "(b)", "text": "在 Z_6 中，使得 g·a = b 的群元素索引集合是什么？（若 a, b 不同轨道则为空集 {}。）",
         "answer_type": "set_of_int", "answer": connecting},
        {"label": "(c)", "text": "Stab(a) 在 Z_6 中的大小 |Stab(a)| 是多少？",
         "answer_type": "integer", "answer": len(stab_a)},
    ]
    R = build_R_for_pair(engine, a_col, b_col)
    T = build_T_for_coloring(engine, a_col, t_g_index)
    C = build_C_for_coloring(engine, a_col)
    return {
        "question_id": qid,
        "type": "equivalence_pair",
        "stem": stem,
        "subquestions": subqs,
        "ground_truth": {
            "a": list(a_col),
            "b": list(b_col),
            "same_orbit": int(same_orbit),
            "connecting_elements": connecting,
            "stab_a_size": len(stab_a),
        },
        "coe_data": {"R": R, "T": T, "C": C},
        "prompts": {
            "baseline": render_baseline(stem, subqs),
            "cot": render_cot(stem, subqs),
            "coe_r": render_coe_r(stem, subqs, R),
            "coe_ctr": render_coe_ctr(stem, subqs, R, T, C),
        },
    }


def make_burnside_question(qid, engine_z6, engine_d6, t_g_index):
    """Q-type 4: from given fixed-point data, derive Burnside count for D_6."""
    # Use a representative coloring just for the T-bundle.
    coloring = (0, 0, 1, 1, 2, 2)
    stem = (
        "在正六边形上的 3 色着色（共 3^6 = 729 种）。考虑两个对称群：\n"
        "  Z_6 = 6 个旋转（含恒等）\n"
        "  D_6 = Z_6 + 6 条对称轴的反射，共 12 个元素\n\n"
        "Burnside 引理：|X / G| = (1/|G|) Σ_{g ∈ G} |Fix(g)|，其中 Fix(g) 是被 g 固定的着色集合。"
    )
    fpc_z6 = engine_z6._fixed_point_counts()
    fpc_d6 = engine_d6._fixed_point_counts()
    subqs = [
        {"label": "(a)", "text": "对 Z_6 而言，Σ_{g ∈ Z_6} |Fix(g)| 是多少？",
         "answer_type": "integer", "answer": sum(fpc_z6.values())},
        {"label": "(b)", "text": "Z_6 的轨道总数是多少？",
         "answer_type": "integer", "answer": len(engine_z6.orbits)},
        {"label": "(c)", "text": "D_6 的轨道总数是多少？",
         "answer_type": "integer", "answer": len(engine_d6.orbits)},
    ]
    R = build_R_for_coloring(engine_z6, coloring)
    R["d6_extension"] = {
        "added_reflection_elements": [
            {"index": i, "permutation": list(engine_d6.group_elements[i])}
            for i in range(engine_z6.m, len(engine_d6.group_elements))
        ],
        "d6_fixed_point_counts": {str(i): fpc_d6[i]
                                  for i in range(len(engine_d6.group_elements))},
        "d6_group_order": len(engine_d6.group_elements),
    }
    # T uses D_6 so we can pick a reflection element (indices 6-11) as anchor.
    T = build_T_for_coloring(engine_d6, coloring, t_g_index)
    C = build_C_for_coloring(engine_z6, coloring)
    return {
        "question_id": qid,
        "type": "burnside_reasoning",
        "stem": stem,
        "subquestions": subqs,
        "ground_truth": {
            "sum_fix_Z6": sum(fpc_z6.values()),
            "total_orbits_Z6": len(engine_z6.orbits),
            "total_orbits_D6": len(engine_d6.orbits),
        },
        "coe_data": {"R": R, "T": T, "C": C},
        "prompts": {
            "baseline": render_baseline(stem, subqs),
            "cot": render_cot(stem, subqs),
            "coe_r": render_coe_r(stem, subqs, R),
            "coe_ctr": render_coe_ctr(stem, subqs, R, T, C),
        },
    }


# ----- main -----------------------------------------------------------------

def main():
    e_z6 = SymmetryEngine(6, 3, "cyclic")
    e_d6 = SymmetryEngine(6, 3, "dihedral")
    questions = []

    # Q1-5: orbit_stabilizer — varying symmetry classes.
    orbit_stab_specs = [
        ((0, 1, 2, 0, 1, 2), 2),   # period-3, |Orbit|=3, |Stab|=2
        ((0, 1, 0, 1, 0, 1), 1),   # period-2, |Orbit|=2, |Stab|=3
        ((0, 0, 0, 0, 0, 0), 1),   # mono, |Orbit|=1, |Stab|=6
        ((0, 0, 1, 1, 2, 2), 2),   # generic, |Orbit|=6, |Stab|=1
        ((0, 1, 0, 2, 0, 1), 3),   # asymmetric, |Orbit|=6, |Stab|=1
    ]
    for k, (col, t) in enumerate(orbit_stab_specs, 1):
        questions.append(make_orbit_stab_question(
            f"dim4_q{k:02d}", e_z6, col, t))

    # Q6-9: group_switch — contrast Z_6 and D_6.
    group_switch_specs = [
        ((0, 1, 2, 0, 1, 2), 6),   # apply reflection (idx 6 in D_6)
        ((0, 1, 0, 1, 0, 1), 7),
        ((0, 0, 1, 1, 2, 2), 8),
        ((0, 1, 1, 2, 2, 0), 9),
    ]
    for k, (col, t) in enumerate(group_switch_specs, 1):
        questions.append(make_group_switch_question(
            f"dim4_q{k+5:02d}", e_z6, e_d6, col, t))

    # Q10-13: equivalence_pair.
    pair_specs = [
        ((0, 1, 2, 0, 1, 2), (1, 2, 0, 1, 2, 0), 1),   # same orbit (rotation by 1)
        ((0, 0, 1, 1, 2, 2), (1, 1, 2, 2, 0, 0), 2),   # same orbit
        ((0, 1, 2, 0, 1, 2), (0, 0, 1, 1, 2, 2), 1),   # different orbit
        ((0, 0, 0, 1, 1, 1), (0, 1, 0, 1, 0, 1), 3),   # different orbit
    ]
    for k, (a, b, t) in enumerate(pair_specs, 1):
        questions.append(make_pair_question(
            f"dim4_q{k+9:02d}", e_z6, a, b, t))

    # Q14-18: burnside_reasoning — same template, vary T anchor only.
    # T anchors are indices into D_6 (12 elements), so 6-11 are reflections.
    for k, t in enumerate([6, 7, 8, 9, 10], 1):
        questions.append(make_burnside_question(
            f"dim4_q{k+13:02d}", e_z6, e_d6, t))

    out = {
        "benchmark": "coe_reasoning",
        "dimension": 4,
        "dimension_name": "symmetry",
        "n_questions": len(questions),
        "conditions": ["baseline", "cot", "coe_r", "coe_ctr"],
        "scoring": "0-4 per sub-question (0 wrong, 1 direction, 2 partial, "
                   "3 mostly, 4 fully correct); aggregate average per question.",
        "questions": questions,
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    out_path = os.path.join(OUT_DIR, "questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print(f"Wrote {len(questions)} questions to {out_path}")
    for q in questions:
        gt = q["ground_truth"]
        print(f"  {q['question_id']} [{q['type']}]: {gt}")


if __name__ == "__main__":
    main()
