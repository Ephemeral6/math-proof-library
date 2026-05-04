"""ProjectionEngine — 3D point clouds and their 2D projections.

Pure Python, no external libraries.

construct(spec) -> PointCloudObject
  spec = {"type": "cube"} or {"points_3d": [[x,y,z], ...]} or {"points_2d": ...}

relate(cloud_a, cloud_b, detail_level) -> RelationData
  L1: n_points, dimensions, diameters, edge_crossings (2D only)
  L2: + distance matrices, point collisions
  L3: + per-pair distance distortions, fraction preserved

transform(cloud, operation) -> TransformResult
  operation = {"type": "project", "plane": "xy"} (also xz, yz, diagonal)
  trace: dropped axis, point collisions, edge crossings, distance distortions

compare(cloud_3d, cloud_b, projected, ...) -> RelationComparison
"""

from __future__ import annotations

import math
import os
import sys
from dataclasses import dataclass
from typing import Any

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_SPATIAL_ROOT = os.path.abspath(os.path.join(_THIS_DIR, "..", "..", ".."))
if _SPATIAL_ROOT not in sys.path:
    sys.path.insert(0, _SPATIAL_ROOT)

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformTrace, TransformResult
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


@dataclass(frozen=True)
class PointCloudObject:
    object_id: str
    points: tuple
    dimension: int          # 2 or 3
    edges: tuple = ()       # tuple of (i, j) index pairs

    def to_json(self) -> dict:
        return {
            "object_id": self.object_id,
            "n_points": len(self.points),
            "dimension": self.dimension,
            "points": [list(p) for p in self.points],
            "edges": [list(e) for e in self.edges] if self.edges else [],
        }


class ProjectionEngine:
    domain_name = "projection"

    PRESETS = {
        "cube": {
            "points": [(0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0),
                       (0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)],
            "edges": [(0, 1), (1, 2), (2, 3), (3, 0),
                      (4, 5), (5, 6), (6, 7), (7, 4),
                      (0, 4), (1, 5), (2, 6), (3, 7)],
        },
        "tetrahedron": {
            "points": [(1, 1, 1), (-1, -1, 1), (-1, 1, -1), (1, -1, -1)],
            "edges": [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)],
        },
        "octahedron": {
            "points": [(1, 0, 0), (-1, 0, 0), (0, 1, 0),
                       (0, -1, 0), (0, 0, 1), (0, 0, -1)],
            "edges": [(0, 2), (0, 3), (0, 4), (0, 5),
                      (1, 2), (1, 3), (1, 4), (1, 5),
                      (2, 4), (2, 5), (3, 4), (3, 5)],
        },
        "triangular_prism": {
            "points": [(0, 0, 0), (1, 0, 0), (0.5, 0.866, 0),
                       (0, 0, 1), (1, 0, 1), (0.5, 0.866, 1)],
            "edges": [(0, 1), (1, 2), (2, 0),
                      (3, 4), (4, 5), (5, 3),
                      (0, 3), (1, 4), (2, 5)],
        },
        "square_antiprism": {
            "points": [(1, 0, 0), (0, 1, 0), (-1, 0, 0), (0, -1, 0),
                       (0.707, 0.707, 1), (-0.707, 0.707, 1),
                       (-0.707, -0.707, 1), (0.707, -0.707, 1)],
            "edges": [(0, 1), (1, 2), (2, 3), (3, 0),
                      (4, 5), (5, 6), (6, 7), (7, 4),
                      (0, 4), (0, 7), (1, 4), (1, 5),
                      (2, 5), (2, 6), (3, 6), (3, 7)],
        },
    }

    PROJECTIONS = {
        "xy": (0, 1),
        "xz": (0, 2),
        "yz": (1, 2),
        "diagonal": None,
    }

    # ----- construction ------------------------------------------------------

    def construct(self, spec: dict) -> PointCloudObject:
        if "type" in spec and spec["type"] in self.PRESETS:
            p = self.PRESETS[spec["type"]]
            pts = tuple(tuple(v) for v in p["points"])
            edges = tuple(tuple(e) for e in p.get("edges", []))
            return PointCloudObject(spec["type"], pts, 3, edges)
        if "points_3d" in spec:
            pts = tuple(tuple(v) for v in spec["points_3d"])
            edges = tuple(tuple(e) for e in spec.get("edges", []))
            oid = spec.get("object_id", f"cloud_{len(pts)}pts")
            return PointCloudObject(oid, pts, 3, edges)
        if "points_2d" in spec:
            pts = tuple(tuple(v) for v in spec["points_2d"])
            edges = tuple(tuple(e) for e in spec.get("edges", []))
            oid = spec.get("object_id", f"proj_{len(pts)}pts")
            return PointCloudObject(oid, pts, 2, edges)
        raise ValueError(f"Unknown spec: {spec}")

    # ----- core geometry helpers --------------------------------------------

    def _project(self, points_3d, plane):
        if plane == "diagonal":
            s2 = math.sqrt(2)
            s6 = math.sqrt(6)
            projected = []
            for p in points_3d:
                u = (p[0] - p[1]) / s2
                v = (p[0] + p[1] - 2 * p[2]) / s6
                projected.append((round(u, 6), round(v, 6)))
            return projected
        axes = self.PROJECTIONS[plane]
        return [(round(p[axes[0]], 6), round(p[axes[1]], 6)) for p in points_3d]

    def _dist(self, a, b):
        return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))

    def _distance_matrix(self, points):
        n = len(points)
        return [[round(self._dist(points[i], points[j]), 6)
                 for j in range(n)] for i in range(n)]

    def _convex_hull_area_2d(self, points_2d):
        n = len(points_2d)
        if n < 3:
            return 0.0
        cx = sum(p[0] for p in points_2d) / n
        cy = sum(p[1] for p in points_2d) / n
        centered = [(p[0] - cx, p[1] - cy) for p in points_2d]
        centered.sort(key=lambda p: math.atan2(p[1], p[0]))
        area = 0.0
        for i in range(n):
            j = (i + 1) % n
            area += centered[i][0] * centered[j][1] - centered[j][0] * centered[i][1]
        return abs(area) / 2

    def _edge_crossings_2d(self, points_2d, edges):
        def ccw(A, B, C):
            return (C[1] - A[1]) * (B[0] - A[0]) > (B[1] - A[1]) * (C[0] - A[0])

        def intersect(A, B, C, D):
            return (ccw(A, C, D) != ccw(B, C, D)
                    and ccw(A, B, C) != ccw(A, B, D))

        crossings = 0
        edge_list = list(edges)
        for i in range(len(edge_list)):
            for j in range(i + 1, len(edge_list)):
                e1, e2 = edge_list[i], edge_list[j]
                if set(e1) & set(e2):
                    continue
                A, B = points_2d[e1[0]], points_2d[e1[1]]
                C, D = points_2d[e2[0]], points_2d[e2[1]]
                if intersect(A, B, C, D):
                    crossings += 1
        return crossings

    def _point_collisions(self, points, threshold=0.01):
        collisions = []
        for i in range(len(points)):
            for j in range(i + 1, len(points)):
                if self._dist(points[i], points[j]) < threshold:
                    collisions.append((i, j))
        return collisions

    def _distance_distortion(self, dm_3d, dm_2d):
        n = len(dm_3d)
        distortions = []
        for i in range(n):
            for j in range(i + 1, n):
                d3 = dm_3d[i][j]
                d2 = dm_2d[i][j]
                if d3 > 0.001:
                    distortions.append({
                        "pair": [i, j],
                        "dist_3d": d3,
                        "dist_2d": d2,
                        "ratio": round(d2 / d3, 4),
                        "preserved": abs(d2 - d3) < 0.01 * d3,
                    })
        return distortions

    # ----- GeometricEngine interface ----------------------------------------

    def relate(self, obj_a, obj_b, detail_level: int = 1) -> RelationData:
        dm_a = self._distance_matrix(list(obj_a.points))
        dm_b = self._distance_matrix(list(obj_b.points))

        diam_a = max((max(row) for row in dm_a), default=0) if dm_a else 0
        diam_b = max((max(row) for row in dm_b), default=0) if dm_b else 0

        summary = {
            "n_points_a": len(obj_a.points),
            "n_points_b": len(obj_b.points),
            "dimension_a": obj_a.dimension,
            "dimension_b": obj_b.dimension,
            "diameter_a": round(diam_a, 6),
            "diameter_b": round(diam_b, 6),
        }
        if obj_a.dimension == 2 and obj_a.edges:
            summary["edge_crossings_a"] = self._edge_crossings_2d(
                list(obj_a.points), obj_a.edges)
        if obj_b.dimension == 2 and obj_b.edges:
            summary["edge_crossings_b"] = self._edge_crossings_2d(
                list(obj_b.points), obj_b.edges)

        detailed: dict = {}
        if detail_level >= 2:
            detailed = {
                "distance_matrix_a": dm_a,
                "distance_matrix_b": dm_b,
            }
            if obj_a.dimension == 2:
                detailed["point_collisions_a"] = self._point_collisions(
                    list(obj_a.points))
            if obj_b.dimension == 2:
                detailed["point_collisions_b"] = self._point_collisions(
                    list(obj_b.points))

        structural: dict = {}
        if detail_level >= 3 and len(obj_a.points) == len(obj_b.points):
            distortions = self._distance_distortion(dm_a, dm_b)
            n_preserved = sum(1 for d in distortions if d["preserved"])
            ratios = [d["ratio"] for d in distortions]
            structural = {
                "distance_distortions_sample": distortions[:20],
                "n_pairs_total": len(distortions),
                "n_pairs_preserved": n_preserved,
                "fraction_preserved": round(n_preserved / max(1, len(distortions)), 4),
                "max_distortion_ratio": max(ratios, default=1.0),
                "min_distortion_ratio": min(ratios, default=1.0),
                "comparable": True,
            }
        elif detail_level >= 3:
            structural = {"comparable": False,
                          "reason": "different point counts"}

        return RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary=summary,
            detailed=detailed,
            structural=structural,
        )

    def transform(self, obj: PointCloudObject, operation: dict) -> TransformResult:
        plane = operation.get("plane", "xy")
        pts_2d = self._project(list(obj.points), plane)

        new_obj = PointCloudObject(
            object_id=f"{obj.object_id}_proj_{plane}",
            points=tuple(tuple(p) for p in pts_2d),
            dimension=2,
            edges=obj.edges,
        )

        inv_before = self.invariants(obj)
        inv_after = self.invariants(new_obj)

        dm_3d = self._distance_matrix(list(obj.points))
        dm_2d = self._distance_matrix(pts_2d)
        distortions = self._distance_distortion(dm_3d, dm_2d)
        n_preserved = sum(1 for d in distortions if d["preserved"])
        collisions = self._point_collisions(pts_2d)
        crossings = self._edge_crossings_2d(pts_2d, list(obj.edges)) \
            if obj.edges else 0
        most_distorted = sorted(
            distortions, key=lambda d: abs(1 - d["ratio"]))[-5:] \
            if distortions else []

        dropped = {"xy": "z", "xz": "y", "yz": "x",
                   "diagonal": "(1,1,1)"}[plane]

        trace = TransformTrace(
            operation_name="projection",
            operation_params={"plane": plane, "dropped_axis": dropped},
            before_state={
                "dimension": 3,
                "n_points": len(obj.points),
                "diameter": inv_before.get("diameter", 0),
            },
            after_state={
                "dimension": 2,
                "n_points": len(pts_2d),
                "diameter": inv_after.get("diameter", 0),
                "edge_crossings": crossings,
            },
            delta={
                "dimension_lost": 1,
                "n_point_collisions": len(collisions),
                "n_edge_crossings_introduced": crossings,
                "fraction_distances_preserved": round(
                    n_preserved / max(1, len(distortions)), 4),
                "distances_total": len(distortions),
                "distances_preserved": n_preserved,
                "diameter_change": round(
                    inv_after.get("diameter", 0) - inv_before.get("diameter", 0),
                    6),
            },
            region_affected={
                "collided_point_pairs": collisions,
                "most_distorted_pairs": most_distorted,
                "n_collisions": len(collisions),
                "n_crossings": crossings,
            },
        )

        invariants_delta = {}
        invariants_preserved = {}
        for k, v_before in inv_before.items():
            v_after = inv_after.get(k)
            if isinstance(v_before, (int, float)) and not isinstance(v_before, bool) \
               and isinstance(v_after, (int, float)) and not isinstance(v_after, bool):
                invariants_delta[k] = round(v_after - v_before, 6)
                invariants_preserved[k] = abs(v_before - v_after) < 0.01
            else:
                invariants_preserved[k] = (v_before == v_after)

        return TransformResult(
            original_id=obj.object_id,
            transformed_id=new_obj.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta=invariants_delta,
            invariants_preserved=invariants_preserved,
        )

    def invariants(self, obj: PointCloudObject) -> dict:
        dm = self._distance_matrix(list(obj.points))
        diameter = max((max(row) for row in dm), default=0) if dm else 0
        result = {
            "n_points": len(obj.points),
            "dimension": obj.dimension,
            "diameter": round(diameter, 6),
        }
        if obj.dimension == 2:
            result["convex_hull_area"] = round(
                self._convex_hull_area_2d(list(obj.points)), 6)
            if obj.edges:
                result["edge_crossings"] = self._edge_crossings_2d(
                    list(obj.points), list(obj.edges))
        return result

    def compare(self, obj_a, obj_b, transformed_a, transform_result,
                detail_level: int = 4) -> RelationComparison:
        pre = self.relate(obj_a, obj_b, detail_level=min(detail_level, 3))
        post = self.relate(transformed_a, obj_b, detail_level=min(detail_level, 3))

        cmp = RelationComparison(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            transformed_a_id=transformed_a.object_id,
            pre=pre,
            post=post,
            summary_delta=compute_summary_delta(pre, post),
            transform_trace=transform_result.trace.to_json(),
        )

        if detail_level >= 2:
            cmp.detailed_comparison = {
                "collisions_introduced":
                    transform_result.trace.delta["n_point_collisions"],
                "crossings_introduced":
                    transform_result.trace.delta["n_edge_crossings_introduced"],
                "fraction_distances_preserved":
                    transform_result.trace.delta["fraction_distances_preserved"],
                "diameter_change":
                    transform_result.trace.delta["diameter_change"],
            }

        if detail_level >= 3:
            cmp.reference_in_transform_region = {
                "collided_point_pairs":
                    transform_result.trace.region_affected.get(
                        "collided_point_pairs", []),
                "most_distorted_pairs":
                    transform_result.trace.region_affected.get(
                        "most_distorted_pairs", []),
                "n_collisions":
                    transform_result.trace.region_affected.get("n_collisions", 0),
                "n_crossings":
                    transform_result.trace.region_affected.get("n_crossings", 0),
            }

        if detail_level >= 4:
            cmp.structural_comparison = {
                "distances_preserved_count":
                    transform_result.trace.delta["distances_preserved"],
                "distances_total":
                    transform_result.trace.delta["distances_total"],
                "dimension_before": 3,
                "dimension_after": 2,
                "information_loss_summary": {
                    "collisions": transform_result.trace.delta["n_point_collisions"],
                    "crossings":
                        transform_result.trace.delta["n_edge_crossings_introduced"],
                    "distance_distortion": round(
                        1.0 - transform_result.trace.delta["fraction_distances_preserved"],
                        4),
                },
                "invariants_preserved": transform_result.invariants_preserved,
                "invariants_delta": transform_result.invariants_delta,
            }
        return cmp


# Self-test ------------------------------------------------------------------

if __name__ == "__main__":
    e = ProjectionEngine()
    cube = e.construct({"type": "cube"})
    print(f"Cube: {len(cube.points)} points, {len(cube.edges)} edges, dim={cube.dimension}")

    for plane in ["xy", "xz", "yz", "diagonal"]:
        tr = e.transform(cube, {"type": "project", "plane": plane})
        print(f"\nProject cube to {plane}:")
        print(f"  dropped axis: {tr.trace.operation_params['dropped_axis']}")
        print(f"  collisions: {tr.trace.delta['n_point_collisions']}")
        print(f"  crossings: {tr.trace.delta['n_edge_crossings_introduced']}")
        print(f"  fraction_distances_preserved: "
              f"{tr.trace.delta['fraction_distances_preserved']}")
        print(f"  diameter: 3D={tr.trace.before_state['diameter']:.4f} → "
              f"2D={tr.trace.after_state['diameter']:.4f}")

    # Cross-projection compare
    tet = e.construct({"type": "tetrahedron"})
    tr = e.transform(tet, {"type": "project", "plane": "xy"})
    proj = e.construct({
        "points_2d": [list(p) for p in
                      [(1, 1), (-1, -1), (-1, 1), (1, -1)]],
        "edges": list(tet.edges),
        "object_id": "tet_xy",
    })
    cmp = e.compare(tet, tet, proj, tr, detail_level=4)
    print(f"\nTetrahedron compare:")
    print(f"  summary_delta: {cmp.summary_delta}")
    print(f"  detailed_comparison: {cmp.detailed_comparison}")
    print(f"  structural info_loss: {cmp.structural_comparison.get('information_loss_summary')}")
