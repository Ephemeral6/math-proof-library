"""CoE Geometric Reasoning Benchmark — Dimension 6 (boundary behavior, Pick's theorem).

16 questions on lattice-polygon B / I / area, and how vertex perturbations affect them.
"""

from __future__ import annotations

import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.boundary_interior.engine import (
    BoundaryInteriorEngine, PolygonObject,
)
from SpatialMind.scripts.coe_reasoning_common import make_question, write_benchmark

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim6_boundary"
)


def _R_for_polygon(engine, poly):
    """Vertices + per-edge gcd decomposition. Hides A, B, I."""
    edges = engine._edge_data(list(poly.vertices))
    # Strip lattice_points_on_edge / lattice_points_interior_to_edge to keep
    # B-derivation as a real task. Keep direction + length + gcd.
    edges_clean = [{
        "from": e["from"], "to": e["to"],
        "direction": e["direction"], "length": e["length"],
        "gcd": e["gcd"],
    } for e in edges]
    return {
        "n_vertices": len(poly.vertices),
        "vertices": [list(v) for v in poly.vertices],
        "edges": edges_clean,
        "is_convex": engine._is_convex(list(poly.vertices)),
        "is_simple": engine._is_simple(list(poly.vertices)),
        "is_lattice": engine._is_lattice(list(poly.vertices)),
        "note": (
            "Each edge has direction (dx, dy) and gcd(|dx|, |dy|). "
            "Pick: A = I + B/2 − 1. Σ gcd over edges = B. Use shoelace for A."
        ),
    }


def _T_for_polygon_op(engine, poly, op):
    tr = engine.transform(poly, op)
    return {
        "operation": op["type"],
        "operation_params": tr.trace.operation_params,
        "before": {
            "area": tr.trace.before_state["area"],
            "B": tr.trace.before_state["B"],
            "I": tr.trace.before_state["I"],
            "n_vertices": tr.trace.before_state["n_vertices"],
        },
        "after": {
            "area": tr.trace.after_state["area"],
            "B": tr.trace.after_state["B"],
            "I": tr.trace.after_state["I"],
            "n_vertices": tr.trace.after_state["n_vertices"],
        },
        "delta": {
            "area_change": tr.trace.delta["area_change"],
            "B_change": tr.trace.delta["B_change"],
            "I_change": tr.trace.delta["I_change"],
            "pick_preserved": tr.trace.delta["pick_preserved"],
        },
        "note": (
            "Trace shows the after-state directly. To answer about the ORIGINAL "
            "polygon you must read the 'before' fields."
        ),
    }


def _C_for_polygon(engine, poly):
    """Counterfactual: a non-lattice perturbation breaks Pick."""
    return {
        "non_lattice_perturbation": {
            "description": (
                "If a vertex is moved off the integer lattice (e.g. (3, 0) → (3.5, 0)), "
                "Pick's formula no longer applies — there is no notion of 'lattice points "
                "on the boundary' for a non-integer vertex."
            ),
            "result": "Pick's theorem fails (B undefined).",
        },
        "scale_non_uniform": {
            "description": (
                "Non-uniform scaling like (sx, sy) = (2, 1) keeps the lattice structure "
                "(if sx, sy are integers) but doubles A and changes B / I. Pick still holds."
            ),
        },
        "note": (
            "Use the contrast to identify Pick's domain: integer vertices + simple polygon."
        ),
    }


def make_q_pick_basics(qid, engine, poly, op_for_T):
    """Type A: from vertex list, derive B, I, A."""
    inv = engine.invariants(poly)
    stem = (
        f"给定整点多边形 P（所有顶点都在整数格点上），按顺序给出顶点：\n"
        f"  V = {[list(v) for v in poly.vertices]}\n"
        f"Pick 定理：A = I + B/2 − 1，其中 A 是面积，B 是边界格点数，I 是内部格点数。\n"
        f"边界格点公式：B = Σ_{{edge}} gcd(|dx|, |dy|)。"
    )
    subqs = [
        {"label": "(a)", "text": "多边形面积 A 是多少？（整数或简单分数；Pick 公式给出整数或半整数）",
         "answer_type": "integer", "answer": int(round(inv["area"]))},
        {"label": "(b)", "text": "边界格点数 B 是多少？",
         "answer_type": "integer", "answer": inv["B"]},
        {"label": "(c)", "text": "内部格点数 I 是多少？",
         "answer_type": "integer", "answer": inv["I"]},
    ]
    R = _R_for_polygon(engine, poly)
    T = _T_for_polygon_op(engine, poly, op_for_T)
    C = _C_for_polygon(engine, poly)
    gt = {
        "vertices": [list(v) for v in poly.vertices],
        "area": inv["area"],
        "B": inv["B"],
        "I": inv["I"],
    }
    return make_question(qid, "pick_basics", stem, subqs, gt, R, T, C)


def make_q_perturbation(qid, engine, poly, op):
    """Type B: predict how A / I change under a vertex perturbation."""
    inv_before = engine.invariants(poly)
    tr = engine.transform(poly, op)
    A_change = tr.trace.delta["area_change"]
    I_change = tr.trace.delta["I_change"]
    B_change = tr.trace.delta["B_change"]
    pick_preserved = tr.trace.delta["pick_preserved"]
    stem = (
        f"给定整点多边形 P，顶点序列：\n"
        f"  V = {[list(v) for v in poly.vertices]}\n"
        f"现在对 P 施加操作 op = {op}。"
    )

    def _format_change(x):
        if x is None:
            return "undefined"
        return int(round(x))

    subqs = [
        {"label": "(a)", "text": "操作后面积的变化 ΔA 是多少？（请给整数；负数表示减少）",
         "answer_type": "integer", "answer": _format_change(A_change)},
        {"label": "(b)", "text": "操作后内部格点数的变化 ΔI 是多少？（若操作让多边形不再是整点多边形则回答 -999）",
         "answer_type": "integer",
         "answer": (-999 if I_change is None else _format_change(I_change))},
        {"label": "(c)", "text": "操作后 Pick 定理是否仍然成立？请回答 1（成立）或 0（不成立）。",
         "answer_type": "integer", "answer": int(bool(pick_preserved))},
    ]
    R = _R_for_polygon(engine, poly)
    T = _T_for_polygon_op(engine, poly, op)
    C = _C_for_polygon(engine, poly)
    gt = {
        "vertices": [list(v) for v in poly.vertices],
        "operation": op,
        "delta_A": A_change,
        "delta_B": B_change,
        "delta_I": I_change,
        "pick_preserved": pick_preserved,
    }
    return make_question(qid, "perturbation", stem, subqs, gt, R, T, C)


def main():
    e = BoundaryInteriorEngine()
    questions = []

    # Q1-Q8: pick_basics across presets
    basics_specs = [
        ("rectangle_4x3", {"type": "translate", "delta": [10, 5]}),
        ("right_triangle", {"type": "translate", "delta": [3, 7]}),
        ("L_shape", {"type": "translate", "delta": [-2, 1]}),
        ("diamond", {"type": "translate", "delta": [5, 5]}),
        ("staircase", {"type": "translate", "delta": [1, 1]}),
        ("thin_triangle", {"type": "translate", "delta": [0, 5]}),
        ("big_square", {"type": "translate", "delta": [-3, 0]}),
        ("unit_square", {"type": "translate", "delta": [4, 4]}),
    ]
    for k, (preset, op) in enumerate(basics_specs, 1):
        poly = e.construct({"type": preset})
        questions.append(make_q_pick_basics(
            f"dim6_q{k:02d}", e, poly, op))

    # Q9-Q16: perturbation under various operations
    pert_specs = [
        ("rectangle_4x3", {"type": "add_vertex", "position": [2, 0], "after_index": 0}),
        ("rectangle_4x3", {"type": "translate", "delta": [10, 5]}),
        ("rectangle_4x3", {"type": "shear", "matrix": [[1, 1], [0, 1]]}),
        ("rectangle_4x3", {"type": "scale_non_uniform", "scale": [2, 1]}),
        ("L_shape", {"type": "scale_non_uniform", "scale": [2, 2]}),
        ("right_triangle", {"type": "translate", "delta": [0, 0]}),
        ("big_square", {"type": "shear", "matrix": [[1, 2], [0, 1]]}),
        ("staircase", {"type": "scale_non_uniform", "scale": [3, 1]}),
    ]
    for k, (preset, op) in enumerate(pert_specs, 1):
        poly = e.construct({"type": preset})
        questions.append(make_q_perturbation(
            f"dim6_q{k+8:02d}", e, poly, op))

    write_benchmark(OUT_DIR, dimension=6, dimension_name="boundary_interior",
                    questions=questions,
                    summary_keys=["area", "B", "I", "delta_A", "delta_I",
                                  "pick_preserved"])


if __name__ == "__main__":
    main()
