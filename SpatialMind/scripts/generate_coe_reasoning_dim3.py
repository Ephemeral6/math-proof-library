"""CoE Geometric Reasoning Benchmark — Dimension 3 (local-to-global, Gauss-Bonnet).

16 questions on Euler characteristic / genus from per-vertex angle defects, and
on the invariance of χ under stellar subdivision and vertex displacement.
"""

from __future__ import annotations

import math
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.discrete_curvature.engine import DiscreteCurvatureEngine
from SpatialMind.scripts.coe_reasoning_common import make_question, write_benchmark

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim3_curvature"
)


# A double torus (genus 2) constructed by gluing two octahedra; we just supply
# coordinates and faces consistent with χ = -2.
# Simpler approach: take the icosahedron (chi=2, genus=0) plus add a handle
# represented as 4 extra vertices and 4 faces removed/added — too complex for
# a self-contained spec. Instead, use only chi=2 surfaces (sphere) for the
# invariance questions and let the user infer.

def _per_vertex_defects_rounded(engine, mesh, ndigits=4):
    return {str(k): round(v, ndigits)
            for k, v in engine._angle_defects(mesh).items()}


def _R_for_mesh(engine, mesh):
    """Per-vertex angle defects + V/E/F counts. Hides χ and genus."""
    defects = _per_vertex_defects_rounded(engine, mesh)
    V = len(mesh.vertices)
    E = len(engine._edges(mesh))
    F = len(mesh.faces)
    return {
        "n_vertices": V,
        "n_edges": E,
        "n_faces": F,
        "vertices": [list(v) for v in mesh.vertices],
        "faces": [list(f) for f in mesh.faces],
        "angle_defects_per_vertex": defects,
        "vertex_degrees": {str(k): v for k, v in engine._vertex_degrees(mesh).items()},
        "note": (
            "δ(v) = 2π − Σ(face-angles at v). Gauss-Bonnet says "
            "Σ_v δ(v) = 2π·χ. We do NOT pre-compute χ — derive it yourself."
        ),
    }


def _T_for_subdiv(engine, mesh, face_idx):
    tr = engine.transform(mesh, {"type": "stellar_subdivision", "face": face_idx})
    return {
        "operation": "stellar_subdivision",
        "subdivided_face_index": face_idx,
        "before": {
            "n_vertices": tr.trace.before_state["n_vertices"],
            "n_edges": tr.trace.before_state["n_edges"],
            "n_faces": tr.trace.before_state["n_faces"],
        },
        "after": {
            "n_vertices": tr.trace.after_state["n_vertices"],
            "n_edges": tr.trace.after_state["n_edges"],
            "n_faces": tr.trace.after_state["n_faces"],
        },
        "delta": {
            "vertices_added": tr.trace.delta["vertices_added"],
            "edges_added": tr.trace.delta["edges_added"],
            "faces_added": tr.trace.delta["faces_added"],
        },
        "new_vertex_defect": tr.trace.region_affected["new_vertex_defect"],
        "local_defect_sum_before": tr.trace.region_affected["local_defect_sum_before"],
        "local_defect_sum_after": tr.trace.region_affected["local_defect_sum_after"],
        "note": (
            "Stellar subdivision: ΔV=+1, ΔE=+3, ΔF=+2 ⇒ Δχ = ΔV−ΔE+ΔF = 0. "
            "The sum of defects in the subdivided face's region also stays "
            "constant (locality of curvature)."
        ),
    }


def _C_for_mesh(engine, mesh):
    """Counterfactual: 'incomplete subdivision' where we add the centroid vertex
    but DON'T retriangulate (just leave a hanging vertex). Gauss-Bonnet then
    fails because the new vertex has full 2π defect with no faces around it.
    We emulate this by reporting what the defects would look like."""
    return {
        "incomplete_subdivision": {
            "description": (
                "Adding a vertex without triangulating the surrounding face "
                "leaves a vertex with 0 incident face-angles, so its defect "
                "= 2π. χ also changes because ΔV=+1, ΔE=0, ΔF=0 ⇒ Δχ=+1."
            ),
            "expected_defect_at_new_vertex": round(2 * math.pi, 6),
            "expected_chi_change": +1,
        },
        "vertex_displacement": {
            "description": (
                "Moving an existing vertex to a new spatial location changes "
                "individual defects but their sum stays at 2π·χ (and χ unchanged)."
            ),
        },
        "note": (
            "Use the contrast to confirm: a 'proper' subdivision preserves χ; "
            "a vertex-without-faces does not."
        ),
    }


def make_q_chi_genus(qid, engine, mesh, t_face_idx):
    """Type A: from per-vertex defects, derive χ and genus."""
    chi = engine._euler_characteristic(mesh)
    genus = max(0, (2 - chi) // 2) if chi <= 2 else 0
    total_curv = sum(engine._angle_defects(mesh).values())
    stem = (
        "在三维空间中考虑一个三角网格曲面。每个顶点 v 的角缺定义为\n"
        "  δ(v) = 2π − Σ(以 v 为顶角的所有三角面的内角)\n"
        "Gauss-Bonnet 离散版本：Σ_v δ(v) = 2π·χ，其中 χ 是 Euler 特征数 V−E+F。"
        "对闭曲面有 χ = 2 − 2g（g 为亏格）。"
    )
    subqs = [
        {"label": "(a)", "text": "Euler 特征数 χ = V − E + F 是多少？",
         "answer_type": "integer", "answer": chi},
        {"label": "(b)", "text": "曲面的亏格 g 是多少？（对球面 g=0）",
         "answer_type": "integer", "answer": genus},
        {"label": "(c)", "text": "在该面（face_index = "
                                   f"{t_face_idx}）上做 stellar subdivision（在面内加一个顶点并把面分成 3 个三角形），新顶点的角缺 δ_new 是多少？请给出 2π 的倍数（如 0.5 表示 π，1.0 表示 2π）。",
         "answer_type": "two_integers", "answer": [0, 1]},  # not used; see below
    ]
    # subq (c): stellar subdivision puts new vertex inside a flat triangle:
    # the new vertex's angles are the three angles inside the small triangles
    # at the centroid, which sum to 2π exactly (centroid lies on the face).
    # → defect_new = 2π − 2π = 0.
    subqs[2] = {
        "label": "(c)",
        "text": (f"在面 face_index={t_face_idx} 上做 stellar subdivision（在面内加一个顶点 v_new 并把该面分成 3 个三角形）。新顶点 v_new 的角缺 δ(v_new) 是多少？"
                 " 请回答 0 / 0.5 / 1.0 / 2.0（这些数表示该值是 2π 的倍数；例如 0 表示 δ=0, 0.5 表示 δ=π）。"),
        "answer_type": "integer", "answer": 0,  # δ_new = 0 (centroid sits in a flat plane)
    }
    R = _R_for_mesh(engine, mesh)
    T = _T_for_subdiv(engine, mesh, t_face_idx)
    C = _C_for_mesh(engine, mesh)
    gt = {
        "n_vertices": len(mesh.vertices),
        "n_edges": len(engine._edges(mesh)),
        "n_faces": len(mesh.faces),
        "chi": chi,
        "genus": genus,
        "total_curvature": round(total_curv, 4),
        "subdivision_new_vertex_defect": 0,
    }
    return make_question(qid, "chi_genus", stem, subqs, gt, R, T, C)


def make_q_invariance(qid, engine, mesh, t_face_idx):
    """Type B: predict whether χ / Σδ are preserved under subdivision and vertex moves."""
    chi = engine._euler_characteristic(mesh)
    stem = (
        "三角网格曲面，离散 Gauss-Bonnet：Σ_v δ(v) = 2π·χ。\n"
        "考虑两类操作：\n"
        "  (op1) stellar_subdivision: 在某个面内加一个新顶点，把该面分成 3 个三角形。\n"
        "  (op2) vertex_displacement: 移动一个已有顶点的空间位置（不改变拓扑）。"
    )
    subqs = [
        {"label": "(a)", "text": "在 op1 之后，Euler 特征数 χ 是否保持不变？请回答 1（保持）或 0（改变）。",
         "answer_type": "integer", "answer": 1},
        {"label": "(b)", "text": "在 op2 之后，Σ_v δ(v) 是否保持不变？请回答 1（保持）或 0（改变）。",
         "answer_type": "integer", "answer": 1},
        {"label": "(c)", "text": "原网格的 Euler 特征数 χ 是多少？",
         "answer_type": "integer", "answer": chi},
    ]
    R = _R_for_mesh(engine, mesh)
    T = _T_for_subdiv(engine, mesh, t_face_idx)
    C = _C_for_mesh(engine, mesh)
    gt = {
        "chi": chi,
        "stellar_chi_preserved": True,
        "displacement_curvature_preserved": True,
    }
    return make_question(qid, "invariance", stem, subqs, gt, R, T, C)


def main():
    e = DiscreteCurvatureEngine()
    questions = []

    # Q1-Q8: chi_genus on the 4 platonic-ish meshes (×2 face anchors each)
    chi_genus_specs = [
        ("tetrahedron", 0),
        ("tetrahedron", 2),
        ("cube_triangulated", 0),
        ("cube_triangulated", 5),
        ("octahedron", 0),
        ("octahedron", 4),
        ("icosahedron", 0),
        ("icosahedron", 10),
    ]
    for k, (preset, face) in enumerate(chi_genus_specs, 1):
        mesh = e.construct({"type": preset})
        questions.append(make_q_chi_genus(
            f"dim3_q{k:02d}", e, mesh, face))

    # Q9-Q16: invariance on same meshes
    invariance_specs = [
        ("tetrahedron", 1),
        ("tetrahedron", 3),
        ("cube_triangulated", 2),
        ("cube_triangulated", 8),
        ("octahedron", 1),
        ("octahedron", 6),
        ("icosahedron", 5),
        ("icosahedron", 15),
    ]
    for k, (preset, face) in enumerate(invariance_specs, 1):
        mesh = e.construct({"type": preset})
        questions.append(make_q_invariance(
            f"dim3_q{k+8:02d}", e, mesh, face))

    write_benchmark(OUT_DIR, dimension=3, dimension_name="discrete_curvature",
                    questions=questions,
                    summary_keys=["chi", "genus", "subdivision_new_vertex_defect",
                                  "stellar_chi_preserved",
                                  "displacement_curvature_preserved"])


if __name__ == "__main__":
    main()
