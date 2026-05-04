"""CoE Geometric Reasoning Benchmark — Dimension 1 (invariants).

16 knot-theory questions on which classical invariants — signature,
determinant (=|det(S+S^T)|), normalized Alexander polynomial — change under
which operations:

  R1 / R2 Reidemeister moves: all three preserved
  mirror:  signature flips sign; |det| same; Alexander same (under standard
           normalization).
  connected_sum K # K_b: signature sums; det multiplies; Alexander multiplies.

NOTE: surface_topology subdomain (intersection number after Hatcher surgery)
was originally planned but the curve database for S_{2,1} doesn't contain
canonical sigma fillers for the curves we tried. Skipped here; recommend
using a richer surface-topology dataset for a future expansion.
"""

from __future__ import annotations

import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.knot_theory.engine import (
    KnotEngine, _normalize_alexander, _derived_invariants,
)
from SpatialMind.scripts.coe_reasoning_common import make_question, write_benchmark

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim1_invariants"
)


def _normalized_alex(K):
    """Return the normalized Alexander coefficients of a KnotObject."""
    derived = _derived_invariants(K._link)
    return derived["alexander_coeffs_normalized"]


def _R_for_knot(engine, K, op_label):
    """Pre-state invariants and PD info; the LLM still has to predict POST."""
    inv = engine.invariants(K)
    return {
        "knot_object_id": K.object_id,
        "operation_to_be_applied": op_label,
        "n_crossings": inv["crossing_count_diagram"],
        "writhe_pre": inv["writhe"],
        "signature_pre": inv["signature"],
        "determinant_pre": inv["determinant"],
        "alexander_polynomial_pre": inv["alexander_polynomial"],
        "alexander_coeffs_pre": inv["alexander_coeffs"],
        "alexander_coeffs_normalized_pre": _normalized_alex(K),
        "crossing_signs_pre": list(K.crossing_signs),
        "pd_code_pre": [list(c) for c in K.pd_code],
        "note": (
            "Pre-state invariants are given. Post-state invariants are NOT "
            "given; predict them from the operation type. Reidemeister moves "
            "are isotopies (all classical invariants preserved); mirror flips "
            "signature sign; connected_sum has additive/multiplicative effects."
        ),
    }


def _T_for_op(engine, K, op):
    """Apply the operation and report what the diagram-level changes are
    (without giving away post-invariants)."""
    if op["type"] == "connected_sum":
        # We display K_b's invariants explicitly so the LLM has something to
        # combine, but NOT the result.
        K_b = op["other"]
        inv_b = engine.invariants(K_b)
        tr = engine.transform(K, op)
        return {
            "operation": "connected_sum",
            "other_knot_id": K_b.object_id,
            "other_invariants": {
                "signature": inv_b["signature"],
                "determinant": inv_b["determinant"],
                "alexander_polynomial": inv_b["alexander_polynomial"],
                "alexander_coeffs_normalized": _normalized_alex(K_b),
                "writhe": inv_b["writhe"],
            },
            "before": {
                "n_crossings": tr.trace.before_state["n_crossings"]
                if "n_crossings" in tr.trace.before_state else None,
                "writhe": tr.trace.before_state.get("writhe"),
            },
            "after": {
                "n_crossings": len(tr.trace.after_state["pd_code"]),
                "writhe": tr.trace.after_state.get("writhe"),
            },
            "note": (
                "K_b's invariants are listed. Combine using K # K_b rules "
                "yourself; we don't pre-compute K # K_b's invariants."
            ),
        }
    else:
        tr = engine.transform(K, op)
        out = {
            "operation": op["type"],
            "operation_params": tr.trace.operation_params,
            "before": {
                "writhe": tr.trace.before_state.get("writhe"),
                "n_crossings": tr.trace.before_state.get("n_crossings"),
                "signs": tr.trace.before_state.get("signs"),
            },
            "after": {
                "writhe": tr.trace.after_state.get("writhe"),
                "n_crossings": tr.trace.after_state.get("n_crossings"),
                "signs": tr.trace.after_state.get("signs"),
            },
            "delta": {
                "writhe_delta": tr.trace.delta.get("writhe_delta"),
                "crossing_count_delta": tr.trace.delta.get("crossing_count_delta"),
            },
            "note": (
                "Diagram-level changes are shown. Topological invariants "
                "(signature, det, Alexander) are NOT pre-computed."
            ),
        }
        if op["type"] == "mirror":
            out["mirror_rule_hint"] = (
                "All crossing signs flip; writhe flips sign. Topological "
                "rule: signature(mirror(K)) = −signature(K); |det| same; "
                "Alexander coefficients unchanged under standard normalization."
            )
        elif op["type"] in ("R1", "R2"):
            out["reidemeister_hint"] = (
                "R1 / R2 are local moves; the underlying knot is unchanged "
                "topologically, so all topological invariants are preserved."
            )
        return out


def _C_for_knot(engine, K):
    """Counterfactual: a 'crossing flip' (changing one sign) is NOT a
    Reidemeister move and generally changes invariants."""
    return {
        "crossing_flip": {
            "description": (
                "Flipping a single crossing sign turns over/under at that "
                "crossing — this is not an ambient isotopy, and it generally "
                "changes signature, determinant, AND Alexander polynomial. "
                "Use this contrast to confirm: a *Reidemeister* move (R1/R2) "
                "preserves all three; a crossing flip does not."
            ),
        },
        "trivial_isotopy": {
            "description": (
                "Translating / scaling the diagram in the plane is an isotopy "
                "and preserves every classical invariant."
            ),
        },
    }


def _changed(pre, post):
    """1 if changed, 0 if same."""
    return int(pre != post)


def _build_post(engine, K, op):
    """Reconstruct the post-operation knot to compute its invariants."""
    tr = engine.transform(K, op)
    K_post = engine.construct({"pd_code": tr.trace.after_state["pd_code"]})
    return K_post


def make_q_invariant_change(qid, engine, knot_name, op, op_label, op_human):
    K = engine.construct({"name": knot_name})
    K_post = _build_post(engine, K, op)
    inv_pre = engine.invariants(K)
    inv_post = engine.invariants(K_post)

    sig_changed = _changed(inv_pre["signature"], inv_post["signature"])
    det_changed = _changed(inv_pre["determinant"], inv_post["determinant"])
    alex_changed = _changed(_normalized_alex(K), _normalized_alex(K_post))

    stem = (
        f"考虑纽结 K = {knot_name}（snappy 标准命名）。\n"
        f"对 K 施加操作：{op_human}\n"
        "我们关注三个经典不变量：\n"
        "  • signature σ(K)：来自 Seifert 矩阵 S 的 (S + S^T) 的特征值符号差\n"
        "  • determinant |det(S + S^T)|\n"
        "  • Alexander 多项式（按标准化规则取消 ±t^k 的歧义）"
    )
    subqs = [
        {"label": "(a)", "text": "操作后 signature 是否变化？请回答 1（变化）或 0（不变）。",
         "answer_type": "integer", "answer": sig_changed},
        {"label": "(b)", "text": "操作后 determinant 是否变化？请回答 1（变化）或 0（不变）。",
         "answer_type": "integer", "answer": det_changed},
        {"label": "(c)", "text": "操作后归一化的 Alexander 系数是否变化？请回答 1（变化）或 0（不变）。",
         "answer_type": "integer", "answer": alex_changed},
    ]
    R = _R_for_knot(engine, K, op_label)
    T = _T_for_op(engine, K, op)
    C = _C_for_knot(engine, K)
    gt = {
        "knot": knot_name,
        "operation": op_label,
        "signature_pre": inv_pre["signature"],
        "signature_post": inv_post["signature"],
        "signature_changed": sig_changed,
        "determinant_pre": inv_pre["determinant"],
        "determinant_post": inv_post["determinant"],
        "determinant_changed": det_changed,
        "alex_pre_norm": _normalized_alex(K),
        "alex_post_norm": _normalized_alex(K_post),
        "alex_changed": alex_changed,
    }
    return make_question(qid, "invariant_change", stem, subqs, gt, R, T, C)


def main():
    e = KnotEngine(seed=42)
    questions = []

    # Knot zoo (small classical knots)
    knot_names = ["3_1", "4_1", "5_1", "5_2", "6_1", "6_2"]

    # Q1-Q4: R2 moves (all should preserve all invariants)
    r2_specs = [
        ("3_1", {"type": "R2", "signs": (+1, -1)}, "R2 move (signs +/-)"),
        ("4_1", {"type": "R2", "signs": (+1, -1)}, "R2 move (signs +/-)"),
        ("5_1", {"type": "R2", "signs": (+1, -1)}, "R2 move (signs +/-)"),
        ("5_2", {"type": "R2", "signs": (+1, -1)}, "R2 move (signs +/-)"),
    ]
    for k, (name, op, label) in enumerate(r2_specs, 1):
        questions.append(make_q_invariant_change(
            f"dim1_q{k:02d}", e, name, op, "R2",
            f"R2 (Reidemeister type II)：在图中加上 2 个反号的相邻交叉。{label}"))

    # Q5-Q8: R1 moves
    r1_specs = [
        ("3_1", {"type": "R1", "sign": +1}, "R1 (Reidemeister type I, sign=+1)"),
        ("4_1", {"type": "R1", "sign": -1}, "R1 (Reidemeister type I, sign=-1)"),
        ("5_1", {"type": "R1", "sign": +1}, "R1 (Reidemeister type I, sign=+1)"),
        ("5_2", {"type": "R1", "sign": -1}, "R1 (Reidemeister type I, sign=-1)"),
    ]
    for k, (name, op, label) in enumerate(r1_specs, 1):
        questions.append(make_q_invariant_change(
            f"dim1_q{k+4:02d}", e, name, op, "R1", label))

    # Q9-Q12: mirror
    for k, name in enumerate(["3_1", "5_1", "5_2", "6_2"], 1):
        op = {"type": "mirror"}
        questions.append(make_q_invariant_change(
            f"dim1_q{k+8:02d}", e, name, op, "mirror",
            "mirror (镜像，所有交叉号翻转)"))

    # Q13-Q16: connected_sum with various K_b
    cs_specs = [
        ("3_1", "3_1"),       # 3_1 # 3_1 (granny knot if same chirality)
        ("3_1", "4_1"),       # 3_1 # 4_1
        ("4_1", "4_1"),       # 4_1 # 4_1
        ("5_1", "3_1"),       # 5_1 # 3_1
    ]
    for k, (name_a, name_b) in enumerate(cs_specs, 1):
        K_b = e.construct({"name": name_b})
        op = {"type": "connected_sum", "other": K_b}
        questions.append(make_q_invariant_change(
            f"dim1_q{k+12:02d}", e, name_a, op, "connected_sum",
            f"connected_sum with K_b = {name_b} (K # K_b)"))

    write_benchmark(OUT_DIR, dimension=1, dimension_name="invariants",
                    questions=questions,
                    summary_keys=["operation", "signature_changed",
                                  "determinant_changed", "alex_changed"])


if __name__ == "__main__":
    main()
