"""CoE Geometric Reasoning Benchmark — Dimension 5 (projection / dimension awareness).

16 questions on point collisions, edge crossings, and distance distortion when
projecting 3D objects onto 2D planes.
"""

from __future__ import annotations

import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.projection.engine import ProjectionEngine
from SpatialMind.scripts.coe_reasoning_common import make_question, write_benchmark

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim5_projection"
)


def _R_for_cloud(engine, cloud):
    """3D point coordinates + edges only; no projection precomputed."""
    return {
        "n_points": len(cloud.points),
        "dimension": cloud.dimension,
        "points_3d": [list(p) for p in cloud.points],
        "edges": [list(e) for e in cloud.edges] if cloud.edges else [],
        "note": (
            "Raw 3D coordinates and edges are given. Compute projections / "
            "collisions / crossings yourself."
        ),
    }


def _T_for_projection(engine, cloud, plane):
    tr = engine.transform(cloud, {"type": "project", "plane": plane})
    return {
        "operation": "projection",
        "plane": plane,
        "dropped_axis": tr.trace.operation_params["dropped_axis"],
        "before": {
            "dimension": tr.trace.before_state["dimension"],
            "n_points": tr.trace.before_state["n_points"],
            "diameter": tr.trace.before_state["diameter"],
        },
        "after": {
            "dimension": tr.trace.after_state["dimension"],
            "n_points": tr.trace.after_state["n_points"],
            "diameter": tr.trace.after_state["diameter"],
        },
        "delta": {
            "n_point_collisions": tr.trace.delta["n_point_collisions"],
            "n_edge_crossings_introduced":
                tr.trace.delta["n_edge_crossings_introduced"],
            "diameter_change": tr.trace.delta["diameter_change"],
        },
        "note": (
            "Projecting drops one axis. Two distinct 3D points may collide "
            "in 2D; two non-adjacent edges may cross in 2D when they didn't "
            "in 3D."
        ),
    }


def _C_for_cloud(engine, cloud, alt_plane):
    """Counterfactual: try a different projection plane to compare info loss."""
    tr_alt = engine.transform(cloud, {"type": "project", "plane": alt_plane})
    return {
        "alternative_projection": {
            "plane": alt_plane,
            "n_collisions": tr_alt.trace.delta["n_point_collisions"],
            "n_crossings": tr_alt.trace.delta["n_edge_crossings_introduced"],
            "diameter_after": tr_alt.trace.after_state["diameter"],
        },
        "no_projection_baseline": {
            "description": "Without projection (kept in 3D) all distinct points "
                           "remain distinct and no spurious edge crossings appear.",
        },
        "note": (
            "Compare info loss across projections to gauge which plane is "
            "least lossy for this object."
        ),
    }


def make_q_projection_loss(qid, engine, preset, plane, alt_plane):
    """Ask about collisions, crossings, and distance preservation after one projection."""
    cloud = engine.construct({"type": preset})
    tr = engine.transform(cloud, {"type": "project", "plane": plane})
    n_coll = tr.trace.delta["n_point_collisions"]
    n_cross = tr.trace.delta["n_edge_crossings_introduced"]
    frac_pres = tr.trace.delta["fraction_distances_preserved"]
    n_total = tr.trace.delta["distances_total"]
    n_pres = tr.trace.delta["distances_preserved"]

    stem = (
        f"在三维空间中给定一个由 {len(cloud.points)} 个顶点和 {len(cloud.edges)} 条棱组成的对象（preset='{preset}'）。"
        f"现在把它沿 {plane} 平面做正交投影（丢弃 {{ 'xy':'z','xz':'y','yz':'x','diagonal':'(1,1,1)方向' }}[plane] 轴的坐标）。"
        " 投影后：(i) 两个不同的 3D 顶点可能在 2D 重合（collision），(ii) 原本不相交的两条棱可能在 2D 相交（edge crossing），(iii) 部分距离会被保留（差小于 1%）。"
    )
    subqs = [
        {"label": "(a)", "text": f"投影到 {plane} 平面后，多少对不同的 3D 顶点在 2D 中重合？",
         "answer_type": "integer", "answer": n_coll},
        {"label": "(b)", "text": f"投影到 {plane} 平面后，多少对原本不相交的棱在 2D 中产生交叉？",
         "answer_type": "integer", "answer": n_cross},
        {"label": "(c)", "text": f"在共 {n_total} 对顶点距离中，有多少对距离在投影后被保留（差距小于 1%）？",
         "answer_type": "integer", "answer": n_pres},
    ]
    R = _R_for_cloud(engine, cloud)
    T = _T_for_projection(engine, cloud, plane)
    C = _C_for_cloud(engine, cloud, alt_plane)
    gt = {
        "preset": preset,
        "plane": plane,
        "n_collisions": n_coll,
        "n_crossings": n_cross,
        "n_pairs_total": n_total,
        "n_pairs_preserved": n_pres,
        "fraction_preserved": frac_pres,
    }
    return make_question(qid, "projection_loss", stem, subqs, gt, R, T, C)


def make_q_diameter_change(qid, engine, preset, plane, alt_plane):
    """Ask about diameter before / after, and which projection preserves more info."""
    cloud = engine.construct({"type": preset})
    tr = engine.transform(cloud, {"type": "project", "plane": plane})
    tr_alt = engine.transform(cloud, {"type": "project", "plane": alt_plane})
    diam_3d = tr.trace.before_state["diameter"]
    diam_2d = tr.trace.after_state["diameter"]
    diam_alt = tr_alt.trace.after_state["diameter"]
    n_coll = tr.trace.delta["n_point_collisions"]
    n_coll_alt = tr_alt.trace.delta["n_point_collisions"]

    # which plane has fewer total collisions+crossings? lower is "better preserved"
    info_loss_main = (tr.trace.delta["n_point_collisions"]
                      + tr.trace.delta["n_edge_crossings_introduced"])
    info_loss_alt = (tr_alt.trace.delta["n_point_collisions"]
                     + tr_alt.trace.delta["n_edge_crossings_introduced"])
    if info_loss_main < info_loss_alt:
        better = plane
    elif info_loss_main > info_loss_alt:
        better = alt_plane
    else:
        better = "tie"

    stem = (
        f"考虑三维 preset='{preset}' 对象。比较两种正交投影：\n"
        f"  Plane A = {plane}\n"
        f"  Plane B = {alt_plane}\n"
        f"投影前对象的 3D 直径（最远两点距离）等多少；投影后两种平面中各自的 2D 直径如何变化；哪个投影信息损失更小（碰撞 + 边交叉之和最少）。"
    )
    subqs = [
        {"label": "(a)", "text": "3D 直径是多少？保留 4 位小数后的整数部分（即四舍五入到整数）即可。",
         "answer_type": "integer", "answer": int(round(diam_3d))},
        {"label": "(b)", "text": f"Plane A = {plane} 投影后，多少对顶点重合？",
         "answer_type": "integer", "answer": n_coll},
        {"label": "(c)", "text": f"Plane B = {alt_plane} 投影后，多少对顶点重合？",
         "answer_type": "integer", "answer": n_coll_alt},
    ]
    R = _R_for_cloud(engine, cloud)
    T = _T_for_projection(engine, cloud, plane)
    C = _C_for_cloud(engine, cloud, alt_plane)
    gt = {
        "preset": preset,
        "plane_main": plane,
        "plane_alt": alt_plane,
        "diameter_3d": diam_3d,
        "n_collisions_main": n_coll,
        "n_collisions_alt": n_coll_alt,
        "less_lossy_plane": better,
    }
    return make_question(qid, "diameter_compare", stem, subqs, gt, R, T, C)


def main():
    e = ProjectionEngine()
    questions = []

    # Q1-Q8: projection_loss across presets and planes
    loss_specs = [
        ("cube", "xy", "diagonal"),
        ("cube", "diagonal", "xy"),
        ("tetrahedron", "xy", "xz"),
        ("tetrahedron", "xz", "diagonal"),
        ("octahedron", "xy", "diagonal"),
        ("octahedron", "diagonal", "xy"),
        ("triangular_prism", "xy", "xz"),
        ("square_antiprism", "xy", "diagonal"),
    ]
    for k, (preset, plane, alt) in enumerate(loss_specs, 1):
        questions.append(make_q_projection_loss(
            f"dim5_q{k:02d}", e, preset, plane, alt))

    # Q9-Q16: diameter_compare across presets/planes
    cmp_specs = [
        ("cube", "xy", "diagonal"),
        ("cube", "xz", "yz"),
        ("tetrahedron", "xy", "diagonal"),
        ("tetrahedron", "xy", "yz"),
        ("octahedron", "xy", "diagonal"),
        ("octahedron", "xy", "xz"),
        ("triangular_prism", "xy", "diagonal"),
        ("square_antiprism", "xy", "diagonal"),
    ]
    for k, (preset, plane, alt) in enumerate(cmp_specs, 1):
        questions.append(make_q_diameter_change(
            f"dim5_q{k+8:02d}", e, preset, plane, alt))

    write_benchmark(OUT_DIR, dimension=5, dimension_name="projection",
                    questions=questions,
                    summary_keys=["preset", "plane", "n_collisions",
                                  "n_crossings", "fraction_preserved",
                                  "less_lossy_plane"])


if __name__ == "__main__":
    main()
