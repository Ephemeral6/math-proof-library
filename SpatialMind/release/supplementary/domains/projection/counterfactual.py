"""Projection counterfactual generator.

Three strategies probe what makes projection lossy:

  boundary_relaxation:
      Original: project from R^3 to R^2 (drop one axis).
      Modified: "project" to R^3 (identity / no axis dropped).
      Identity preserves all distances; projection does not. This isolates
      "dimension reduction" as the cause of information loss.

  operation_perturbation:
      Original: orthogonal projection (axis fully dropped).
      Modified: anisotropic squash (z scaled by 0.5 instead of dropped).
      Squash preserves a partial signal; projection collapses one axis to 0.

  condition_removal:
      Original: keep all n points after projection (collisions allowed).
      Modified: deduplicate colliding points after projection.
      Removing duplicates changes n_points and changes topology.
"""

from __future__ import annotations

import math
import os
import sys

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_SPATIAL_ROOT = os.path.abspath(os.path.join(_THIS_DIR, "..", "..", ".."))
if _SPATIAL_ROOT not in sys.path:
    sys.path.insert(0, _SPATIAL_ROOT)

from SpatialMind.core.counterfactual import (
    CounterfactualCase,
    CounterfactualInput,
    CFStrategy,
)
from SpatialMind.domains.projection.engine import (
    ProjectionEngine,
    PointCloudObject,
)


def _dist(a, b):
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def _distance_matrix(points):
    n = len(points)
    return [[round(_dist(points[i], points[j]), 6)
             for j in range(n)] for i in range(n)]


def _fraction_preserved(dm_a, dm_b):
    n = len(dm_a)
    total = 0
    preserved = 0
    for i in range(n):
        for j in range(i + 1, n):
            d_a = dm_a[i][j]
            d_b = dm_b[i][j]
            if d_a > 0.001:
                total += 1
                if abs(d_a - d_b) < 0.01 * d_a:
                    preserved += 1
    return preserved, total


def _collisions(points, threshold=0.01):
    out = []
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            if _dist(points[i], points[j]) < threshold:
                out.append((i, j))
    return out


class ProjectionCounterfactualGenerator:
    """Projection-domain specific counterfactual cases."""

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        if strategy is None:
            out: list[CounterfactualCase] = []
            for s in CFStrategy:
                try:
                    out.extend(self.generate(input, s))
                except NotImplementedError:
                    continue
            return out

        if strategy == CFStrategy.BOUNDARY_RELAXATION:
            return self._no_dimension_drop(input)
        if strategy == CFStrategy.OPERATION_PERTURBATION:
            return self._squash_instead_of_project(input)
        if strategy == CFStrategy.CONDITION_REMOVAL:
            return self._dedupe_after_project(input)
        raise NotImplementedError(strategy)

    def _no_dimension_drop(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: ProjectionEngine = input.engine
        obj = input.object_a
        plane = input.operation.get("plane", "xy")

        # Original: real projection
        tr = engine.transform(obj, {"type": "project", "plane": plane})
        orig_collisions = tr.trace.delta["n_point_collisions"]
        orig_frac = tr.trace.delta["fraction_distances_preserved"]

        # Modified: identity (no axis dropped) — points stay 3D
        identity_pts = list(obj.points)
        dm_3d = _distance_matrix(list(obj.points))
        dm_id = _distance_matrix(identity_pts)
        preserved, total = _fraction_preserved(dm_3d, dm_id)
        frac_id = round(preserved / max(1, total), 4)
        coll_id = len(_collisions(identity_pts))

        critical = (frac_id != orig_frac) or (coll_id != orig_collisions)

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "drop_axis": True,
                "target_dimension": 2,
                "plane": plane,
            },
            modified_condition={
                "drop_axis": False,
                "target_dimension": 3,
                "plane": "identity",
            },
            original_result={
                "fraction_distances_preserved": orig_frac,
                "n_point_collisions": orig_collisions,
            },
            counterfactual_result={
                "fraction_distances_preserved": frac_id,
                "n_point_collisions": coll_id,
            },
            delta={
                "fraction_change": round(frac_id - orig_frac, 4),
                "collision_change": coll_id - orig_collisions,
            },
            condition_is_critical=critical,
            explanation=(
                f"No-projection identity preserves {frac_id:.0%} of distances "
                f"vs projection's {orig_frac:.0%}. "
                f"{'Critical: dimension reduction is the cause of information loss.' if critical else 'Not critical (object already 2D-flat).'}"
            ),
        )]

    def _squash_instead_of_project(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: ProjectionEngine = input.engine
        obj = input.object_a
        plane = input.operation.get("plane", "xy")

        tr = engine.transform(obj, {"type": "project", "plane": plane})
        orig_frac = tr.trace.delta["fraction_distances_preserved"]
        orig_coll = tr.trace.delta["n_point_collisions"]

        # Modified: scale the dropped axis by 0.5 instead of zeroing it.
        scale_axis = {"xy": 2, "xz": 1, "yz": 0, "diagonal": None}[plane]
        squash_pts = []
        if scale_axis is None:
            # diagonal: scale projection along (1,1,1) by 0.5
            for p in obj.points:
                avg = (p[0] + p[1] + p[2]) / 3
                # subtract half the projection onto (1,1,1)/sqrt(3)
                squash_pts.append((
                    p[0] - 0.5 * avg,
                    p[1] - 0.5 * avg,
                    p[2] - 0.5 * avg,
                ))
        else:
            for p in obj.points:
                q = list(p)
                q[scale_axis] = q[scale_axis] * 0.5
                squash_pts.append(tuple(q))

        dm_3d = _distance_matrix(list(obj.points))
        dm_sq = _distance_matrix(squash_pts)
        preserved, total = _fraction_preserved(dm_3d, dm_sq)
        frac_sq = round(preserved / max(1, total), 4)
        coll_sq = len(_collisions(squash_pts))

        critical = (frac_sq > orig_frac) or (coll_sq < orig_coll)

        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={
                "operation": "orthogonal_projection",
                "axis_scale": 0.0,
                "plane": plane,
            },
            modified_condition={
                "operation": "squash",
                "axis_scale": 0.5,
                "plane": plane,
            },
            original_result={
                "fraction_distances_preserved": orig_frac,
                "n_point_collisions": orig_coll,
            },
            counterfactual_result={
                "fraction_distances_preserved": frac_sq,
                "n_point_collisions": coll_sq,
            },
            delta={
                "fraction_change": round(frac_sq - orig_frac, 4),
                "collision_change": coll_sq - orig_coll,
            },
            condition_is_critical=critical,
            explanation=(
                f"Partial squash (×0.5) preserves {frac_sq:.0%} vs full projection's "
                f"{orig_frac:.0%}; collisions {orig_coll} -> {coll_sq}. "
                f"{'Critical: zeroing the axis is strictly more lossy than scaling.' if critical else 'Not critical.'}"
            ),
        )]

    def _dedupe_after_project(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: ProjectionEngine = input.engine
        obj = input.object_a
        plane = input.operation.get("plane", "xy")

        tr = engine.transform(obj, {"type": "project", "plane": plane})
        orig_n = tr.trace.after_state["n_points"]
        orig_crossings = tr.trace.delta["n_edge_crossings_introduced"]
        proj_pts = engine._project(list(obj.points), plane)

        # Modified: dedupe collisions
        seen = []
        idx_map = {}
        for i, p in enumerate(proj_pts):
            found = -1
            for k, q in enumerate(seen):
                if _dist(p, q) < 0.01:
                    found = k
                    break
            if found < 0:
                idx_map[i] = len(seen)
                seen.append(p)
            else:
                idx_map[i] = found
        deduped_n = len(seen)

        # Build deduped edge set (skip self-loops)
        new_edges = set()
        for (i, j) in obj.edges:
            ni, nj = idx_map[i], idx_map[j]
            if ni == nj:
                continue
            new_edges.add(tuple(sorted((ni, nj))))
        new_crossings = engine._edge_crossings_2d(seen, list(new_edges)) \
            if new_edges else 0

        critical = (deduped_n != orig_n) or (new_crossings != orig_crossings)

        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={
                "preserve_n_points": True,
                "n_points": orig_n,
                "edge_crossings": orig_crossings,
            },
            modified_condition={
                "preserve_n_points": False,
                "n_points": deduped_n,
                "edge_crossings": new_crossings,
            },
            original_result={
                "n_points": orig_n,
                "edge_crossings": orig_crossings,
            },
            counterfactual_result={
                "n_points": deduped_n,
                "edge_crossings": new_crossings,
            },
            delta={
                "n_points_change": deduped_n - orig_n,
                "edge_crossings_change": new_crossings - orig_crossings,
            },
            condition_is_critical=critical,
            explanation=(
                f"Deduping collided points: {orig_n} -> {deduped_n} points, "
                f"crossings {orig_crossings} -> {new_crossings}. "
                f"{'Critical: collisions encode 3D structure that dedupe destroys.' if critical else 'Not critical (no collisions to dedupe).'}"
            ),
        )]


# Self-test ------------------------------------------------------------------

if __name__ == "__main__":
    e = ProjectionEngine()
    cube = e.construct({"type": "cube"})
    gen = ProjectionCounterfactualGenerator()

    inp = CounterfactualInput(
        engine=e, object_a=cube, object_b=cube,
        operation={"type": "project", "plane": "xy"},
        conditions={"target_dim": 2},
    )
    cases = gen.generate(inp)
    for c in cases:
        print(f"[{c.strategy.value}] critical={c.condition_is_critical}")
        print(f"  original: {c.original_result}")
        print(f"  cf:       {c.counterfactual_result}")
        print(f"  delta:    {c.delta}")
        print(f"  why:      {c.explanation}")
        print()
