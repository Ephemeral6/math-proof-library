"""Generate the ~100-case benchmark for boundary_interior (terminal 8).

Per preset polygon:
  - 3 add_vertex (different edges, lattice points interior to those edges)
  - 1 translate
  - 1 unimodular shear
  - 1 non-uniform scale (Pick still applies but area changes)
  - 1 cross-pair self compare (β = different preset)

Plus cross-domain compares (ref polygon = each preset; transform = identity-like).

Outputs benchmarks/boundary_interior/level_1.json ... level_5.json.
"""

from __future__ import annotations

import sys
import time
from collections import Counter
from math import gcd
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MATH_ROOT = ROOT.parent
for p in (str(ROOT), str(MATH_ROOT)):
    if p not in sys.path:
        sys.path.insert(0, p)

from SpatialMind.core.benchmark import ExperimentCase, build_benchmark_suite
from SpatialMind.core.counterfactual import CounterfactualInput
from SpatialMind.domains.boundary_interior.counterfactual import (
    PolygonCounterfactualGenerator,
)
from SpatialMind.domains.boundary_interior.engine import (
    BoundaryInteriorEngine, PolygonObject,
)


def add_vertex_specs_for_preset(name, verts):
    """Choose 3 add_vertex operations on edges that have at least one interior
    lattice point (gcd >= 2). Returns list of (after_index, position) tuples."""
    n = len(verts)
    candidates = []
    for i in range(n):
        j = (i + 1) % n
        x0, y0 = verts[i]
        x1, y1 = verts[j]
        dx, dy = x1 - x0, y1 - y0
        g = gcd(abs(dx), abs(dy))
        if g >= 2:
            # Insert at the midpoint of the edge (or first interior lattice point).
            for k in range(1, g):
                px = x0 + (dx * k) // g
                py = y0 + (dy * k) // g
                candidates.append((i, (px, py)))
    return candidates


def main():
    engine = BoundaryInteriorEngine()
    presets = list(engine.PRESETS.keys())

    all_cases: list[ExperimentCase] = []
    op_counts = Counter()
    pick_pre_post_counts = Counter()

    t0 = time.time()
    for preset in presets:
        P = engine.construct({"type": preset})
        verts = list(P.vertices)

        # 1) up to 3 add_vertex ops
        addv = add_vertex_specs_for_preset(preset, verts)
        for k, (idx, pos) in enumerate(addv[:3]):
            tr = engine.transform(P, {
                "type": "add_vertex",
                "after_index": idx,
                "position": list(pos),
            })
            P_after = engine.construct({
                "vertices": list(P.vertices[:idx + 1]) + [list(pos)] + list(P.vertices[idx + 1:]),
                "object_id": tr.transformed_id,
            })
            cmp = engine.compare(P, P, P_after, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{preset}-addv-{k}",
                object_a_id=P.object_id,
                object_b_id=P.object_id,
                transformed_a_id=P_after.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": preset,
                    "operation": "add_vertex",
                    "after_index": idx,
                    "position": list(pos),
                    "n_vertices_pre": len(P.vertices),
                    "n_vertices_post": len(P_after.vertices),
                },
            )
            all_cases.append(ec)
            op_counts["add_vertex"] += 1
            pick_pre_post_counts[(
                tr.trace.before_state["pick_holds"],
                tr.trace.after_state["pick_holds"],
            )] += 1

        # 2) translate (3 different deltas)
        for k, delta in enumerate([[5, 0], [0, 7], [3, 4]]):
            tr = engine.transform(P, {"type": "translate", "delta": delta})
            P_after = engine.construct({
                "vertices": [[v[0] + delta[0], v[1] + delta[1]] for v in P.vertices],
                "object_id": tr.transformed_id,
            })
            cmp = engine.compare(P, P, P_after, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{preset}-trans-{k}",
                object_a_id=P.object_id,
                object_b_id=P.object_id,
                transformed_a_id=P_after.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": preset,
                    "operation": "translate",
                    "delta": delta,
                    "n_vertices_pre": len(P.vertices),
                    "n_vertices_post": len(P_after.vertices),
                },
            )
            all_cases.append(ec)
            op_counts["translate"] += 1
            pick_pre_post_counts[(
                tr.trace.before_state["pick_holds"],
                tr.trace.after_state["pick_holds"],
            )] += 1

        # 3) unimodular shears (det=1 shears, 2 different ones)
        for k, mat in enumerate([[[1, 1], [0, 1]], [[1, 0], [1, 1]]]):
            tr = engine.transform(P, {"type": "shear", "matrix": mat})
            sheared = [
                (mat[0][0] * v[0] + mat[0][1] * v[1],
                 mat[1][0] * v[0] + mat[1][1] * v[1])
                for v in P.vertices
            ]
            P_after = engine.construct({
                "vertices": [[int(round(x)), int(round(y))] for x, y in sheared],
                "object_id": tr.transformed_id,
            })
            cmp = engine.compare(P, P, P_after, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{preset}-shear-{k}",
                object_a_id=P.object_id,
                object_b_id=P.object_id,
                transformed_a_id=P_after.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": preset,
                    "operation": "shear",
                    "matrix": mat,
                    "determinant":
                        mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0],
                    "n_vertices_pre": len(P.vertices),
                    "n_vertices_post": len(P_after.vertices),
                },
            )
            all_cases.append(ec)
            op_counts["shear"] += 1
            pick_pre_post_counts[(
                tr.trace.before_state["pick_holds"],
                tr.trace.after_state["pick_holds"],
            )] += 1

        # 4) non-uniform scale (det != 1; Pick still applies; area changes)
        for k, scale in enumerate([[2, 1], [1, 3]]):
            tr = engine.transform(P, {"type": "scale_non_uniform", "scale": scale})
            scaled = [(v[0] * scale[0], v[1] * scale[1]) for v in P.vertices]
            P_after = engine.construct({
                "vertices": [list(v) for v in scaled],
                "object_id": tr.transformed_id,
            })
            cmp = engine.compare(P, P, P_after, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{preset}-scale-{k}",
                object_a_id=P.object_id,
                object_b_id=P.object_id,
                transformed_a_id=P_after.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": preset,
                    "operation": "scale_non_uniform",
                    "scale": scale,
                    "determinant": scale[0] * scale[1],
                    "n_vertices_pre": len(P.vertices),
                    "n_vertices_post": len(P_after.vertices),
                },
            )
            all_cases.append(ec)
            op_counts["scale_non_uniform"] += 1
            pick_pre_post_counts[(
                tr.trace.before_state["pick_holds"],
                tr.trace.after_state["pick_holds"],
            )] += 1

    # 5) cross-preset compare cases: β = a different preset (translate of P_a)
    cross_pairs = [
        ("rectangle_4x3", "L_shape"),
        ("right_triangle", "diamond"),
        ("staircase", "thin_triangle"),
        ("unit_square", "big_square"),
        ("L_shape", "staircase"),
        ("big_square", "diamond"),
        ("rectangle_4x3", "right_triangle"),
        ("L_shape", "diamond"),
        ("thin_triangle", "rectangle_4x3"),
        ("big_square", "L_shape"),
    ]
    for k, (a, b) in enumerate(cross_pairs):
        P_a = engine.construct({"type": a})
        P_b = engine.construct({"type": b})
        tr = engine.transform(P_a, {"type": "translate", "delta": [0, 0]})
        P_after = P_a
        cmp = engine.compare(P_a, P_b, P_after, tr, detail_level=4)
        ec = ExperimentCase(
            case_id=f"crosspair-{k}-{a}-vs-{b}",
            object_a_id=P_a.object_id,
            object_b_id=P_b.object_id,
            transformed_a_id=P_after.object_id,
            transform_result=tr,
            comparison=cmp,
            metadata={
                "preset_a": a,
                "preset_b": b,
                "operation": "identity_compare",
                "n_vertices_pre": len(P_a.vertices),
                "n_vertices_post": len(P_after.vertices),
            },
        )
        all_cases.append(ec)
        op_counts["identity_compare"] += 1
        pick_pre_post_counts[(
            tr.trace.before_state["pick_holds"],
            tr.trace.after_state["pick_holds"],
        )] += 1

    t1 = time.time()
    print(f"\nTotal: {len(all_cases)} cases in {t1 - t0:.2f}s")
    print(f"Operation distribution: {dict(op_counts)}")
    print(f"(pick_pre, pick_post): {dict(pick_pre_post_counts)}")

    # ------ Counterfactual generation on rectangle_4x3 ------
    cf_gen = PolygonCounterfactualGenerator(engine=engine)
    P_ref = engine.construct({"type": "rectangle_4x3"})
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine, object_a=P_ref, object_b=P_ref,
        operation={"type": "shear"}, conditions={},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ------ Build & save the 5-level benchmark ------
    suite = build_benchmark_suite("boundary_interior", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "boundary_interior"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Quick stats ------
    preset_dist = Counter(ec.metadata.get("preset",
                                          ec.metadata.get("preset_a"))
                          for ec in all_cases)
    print(f"\nPreset distribution: {dict(sorted(preset_dist.items()))}")
    area_pres = Counter(bool(ec.transform_result.trace.delta["area_preserved"])
                        for ec in all_cases)
    print(f"area_preserved: {dict(area_pres)}")


if __name__ == "__main__":
    main()
