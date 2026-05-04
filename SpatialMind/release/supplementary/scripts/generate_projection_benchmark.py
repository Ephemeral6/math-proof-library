"""Generate the benchmark dataset for projection (~100 cases).

Three case types:
  - self_projection (5 objs × 4 planes = 20): compare 3D obj to its own 2D
    projection. b = obj (3D), so structural comparison checks 3D-vs-2D
    distance distortion.
  - cross_projection (5 objs × 6 plane pairs = 30): compare two 2D projections
    of the same 3D object. b = projection on plane B; transformed_a =
    projection on plane A.
  - cross_object_compatible (same n_points pairs × 4 planes × 2 directions):
    cube↔square_antiprism (8 points each) and octahedron↔triangular_prism
    (6 points each). 2 pair-classes × 4 planes × 2 directions = 16 cases.

Total = 66 base cases. We extend cross_object to all (obj1, obj2, plane)
where same n_points, both directions, all 4 planes, plus additional same-pair
diagonal-permutation cases to reach ~100. Final count printed at the end.

For each case we apply projection() to obj_a and call compare(). CF block
is generated on a representative (cube, xy) input.
"""

from __future__ import annotations

import json
import random
import sys
from collections import Counter
from itertools import combinations, permutations
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MATH_ROOT = ROOT.parent
for p in (str(ROOT), str(MATH_ROOT)):
    if p not in sys.path:
        sys.path.insert(0, p)

from SpatialMind.core.benchmark import ExperimentCase, build_benchmark_suite
from SpatialMind.core.counterfactual import CounterfactualInput
from SpatialMind.domains.projection.engine import (
    PointCloudObject,
    ProjectionEngine,
)
from SpatialMind.domains.projection.counterfactual import (
    ProjectionCounterfactualGenerator,
)

OBJECTS = ["cube", "tetrahedron", "octahedron",
           "triangular_prism", "square_antiprism"]
PLANES = ["xy", "xz", "yz", "diagonal"]
SEED = 2026


def main():
    rng = random.Random(SEED)
    engine = ProjectionEngine()

    objs = {name: engine.construct({"type": name}) for name in OBJECTS}
    print(f"Engine: {len(objs)} preset objects, {len(PLANES)} projection planes")
    for name, o in objs.items():
        print(f"  {name}: {len(o.points)} points, {len(o.edges)} edges")

    all_cases: list[ExperimentCase] = []

    # ---- Type 1: self-projection -------------------------------------------
    for obj_name in OBJECTS:
        obj = objs[obj_name]
        for plane in PLANES:
            tr = engine.transform(obj, {"type": "project", "plane": plane})
            proj = engine.construct({
                "points_2d": [list(p) for p in
                              engine._project(list(obj.points), plane)],
                "edges": list(obj.edges),
                "object_id": f"{obj_name}_proj_{plane}",
            })
            cmp = engine.compare(obj, obj, proj, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"self-{obj_name}-{plane}",
                object_a_id=obj.object_id,
                object_b_id=obj.object_id,
                transformed_a_id=proj.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "case_type": "self_projection",
                    "object": obj_name,
                    "plane": plane,
                    "n_points": len(obj.points),
                    "n_edges": len(obj.edges),
                },
            )
            all_cases.append(ec)

    print(f"\nType 1 self-projection: {len(all_cases)} cases")

    # ---- Type 2: cross-projection (same obj, plane A vs plane B) -----------
    n_cross_proj = 0
    for obj_name in OBJECTS:
        obj = objs[obj_name]
        for plane_a, plane_b in combinations(PLANES, 2):
            tr_a = engine.transform(obj, {"type": "project", "plane": plane_a})
            proj_a = engine.construct({
                "points_2d": [list(p) for p in
                              engine._project(list(obj.points), plane_a)],
                "edges": list(obj.edges),
                "object_id": f"{obj_name}_proj_{plane_a}",
            })
            proj_b = engine.construct({
                "points_2d": [list(p) for p in
                              engine._project(list(obj.points), plane_b)],
                "edges": list(obj.edges),
                "object_id": f"{obj_name}_proj_{plane_b}",
            })
            cmp = engine.compare(obj, proj_b, proj_a, tr_a, detail_level=4)
            ec = ExperimentCase(
                case_id=f"cross-{obj_name}-{plane_a}vs{plane_b}",
                object_a_id=obj.object_id,
                object_b_id=proj_b.object_id,
                transformed_a_id=proj_a.object_id,
                transform_result=tr_a,
                comparison=cmp,
                metadata={
                    "case_type": "cross_projection",
                    "object": obj_name,
                    "plane_a": plane_a,
                    "plane_b": plane_b,
                    "n_points": len(obj.points),
                    "n_edges": len(obj.edges),
                },
            )
            all_cases.append(ec)
            n_cross_proj += 1

    print(f"Type 2 cross-projection: {n_cross_proj} cases")

    # ---- Type 3: cross-object (different objs, same plane) -----------------
    same_n_pairs = []
    for a_name, b_name in combinations(OBJECTS, 2):
        if len(objs[a_name].points) == len(objs[b_name].points):
            same_n_pairs.append((a_name, b_name))
    print(f"  same-n-points pairs: {same_n_pairs}")

    n_cross_obj = 0
    for a_name, b_name in same_n_pairs:
        for first, second in [(a_name, b_name), (b_name, a_name)]:
            obj_a = objs[first]
            obj_b = objs[second]
            for plane in PLANES:
                tr_a = engine.transform(obj_a, {"type": "project", "plane": plane})
                proj_a = engine.construct({
                    "points_2d": [list(p) for p in
                                  engine._project(list(obj_a.points), plane)],
                    "edges": list(obj_a.edges),
                    "object_id": f"{first}_proj_{plane}",
                })
                cmp = engine.compare(obj_a, obj_b, proj_a, tr_a, detail_level=4)
                ec = ExperimentCase(
                    case_id=f"diff-{first}vs{second}-{plane}",
                    object_a_id=obj_a.object_id,
                    object_b_id=obj_b.object_id,
                    transformed_a_id=proj_a.object_id,
                    transform_result=tr_a,
                    comparison=cmp,
                    metadata={
                        "case_type": "cross_object",
                        "object_a": first,
                        "object_b": second,
                        "plane": plane,
                        "n_points_a": len(obj_a.points),
                        "n_points_b": len(obj_b.points),
                    },
                )
                all_cases.append(ec)
                n_cross_obj += 1

    print(f"Type 3 cross-object: {n_cross_obj} cases")
    print(f"\nTotal: {len(all_cases)} cases")

    # ---- Counterfactual block (representative: cube × xy) ------------------
    cf_gen = ProjectionCounterfactualGenerator()
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine,
        object_a=objs["cube"],
        object_b=objs["cube"],
        operation={"type": "project", "plane": "xy"},
        conditions={"target_dim": 2},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ---- Build & save -------------------------------------------------------
    suite = build_benchmark_suite("projection", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "projection"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ---- Stats summary ------------------------------------------------------
    types = Counter(ec.metadata["case_type"] for ec in all_cases)
    print(f"\nCase type distribution: {dict(types)}")
    coll_dist = Counter(
        ec.transform_result.trace.delta["n_point_collisions"]
        for ec in all_cases
    )
    print(f"n_collisions distribution: {dict(sorted(coll_dist.items()))}")
    cross_dist = Counter(
        ec.transform_result.trace.delta["n_edge_crossings_introduced"]
        for ec in all_cases
    )
    print(f"n_crossings distribution: {dict(sorted(cross_dist.items()))}")
    frac_dist = Counter(
        round(ec.transform_result.trace.delta["fraction_distances_preserved"], 1)
        for ec in all_cases
    )
    print(f"fraction_preserved (rounded 1 dec): {dict(sorted(frac_dist.items()))}")


if __name__ == "__main__":
    main()
