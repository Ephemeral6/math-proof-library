"""BoundaryInteriorEngine — Pick's theorem for lattice polygons.

construct(spec) -> PolygonObject
  spec = {"vertices": [[0,0],[4,0],[4,3],[0,3]]}
  spec = {"type": "rectangle_4x3"}  # uses PRESETS

relate(poly_a, poly_b, detail_level) -> RelationData
  L1: area, perimeter, n_vertices, B, I, pick_holds
  L2: + per-edge data (direction, length, gcd, lattice points on edge)
  L3: + is_convex, pick_formula expression, edge_gcd_decomposition

transform(poly, operation) -> TransformResult
  operation = {"type": "add_vertex", "position": [x, y], "after_index": i}
  operation = {"type": "translate", "delta": [dx, dy]}
  operation = {"type": "shear", "matrix": [[1, k], [0, 1]]}
  operation = {"type": "scale_non_uniform", "scale": [sx, sy]}

invariants(poly) -> area, perimeter, B, I, pick_holds, is_convex, n_vertices
compare(...) -> RelationComparison
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from math import gcd

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformResult, TransformTrace
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


@dataclass(frozen=True)
class PolygonObject:
    object_id: str
    vertices: tuple  # tuple of (x, y) pairs (numeric, usually integers)

    def to_json(self) -> dict:
        return {
            "object_id": self.object_id,
            "n_vertices": len(self.vertices),
            "vertices": [list(v) for v in self.vertices],
        }


class BoundaryInteriorEngine:
    domain_name = "boundary_interior"

    PRESETS = {
        "unit_square":     [(0, 0), (1, 0), (1, 1), (0, 1)],
        "rectangle_4x3":   [(0, 0), (4, 0), (4, 3), (0, 3)],
        "right_triangle":  [(0, 0), (6, 0), (0, 4)],
        "L_shape":         [(0, 0), (4, 0), (4, 2), (2, 2), (2, 4), (0, 4)],
        "diamond":         [(3, 0), (6, 3), (3, 6), (0, 3)],
        "staircase":       [(0, 0), (1, 0), (1, 1), (2, 1), (2, 2), (3, 2), (3, 3), (0, 3)],
        "thin_triangle":   [(0, 0), (10, 0), (0, 1)],
        "big_square":      [(0, 0), (5, 0), (5, 5), (0, 5)],
    }

    def construct(self, spec: dict) -> PolygonObject:
        if "type" in spec and spec["type"] in self.PRESETS:
            verts = self.PRESETS[spec["type"]]
            oid = spec.get("object_id") or spec["type"]
        elif "vertices" in spec:
            verts = [tuple(v) for v in spec["vertices"]]
            oid = spec.get("object_id") or f"poly_{len(verts)}v"
        else:
            raise ValueError(f"Unknown spec: {spec}")
        return PolygonObject(object_id=oid,
                             vertices=tuple(tuple(v) for v in verts))

    # ---- core polygon routines ---------------------------------------------
    def _shoelace_area(self, vertices) -> float:
        n = len(vertices)
        area = 0.0
        for i in range(n):
            j = (i + 1) % n
            area += vertices[i][0] * vertices[j][1]
            area -= vertices[j][0] * vertices[i][1]
        return abs(area) / 2.0

    def _is_lattice(self, vertices) -> bool:
        for x, y in vertices:
            if not (isinstance(x, int) or float(x).is_integer()):
                return False
            if not (isinstance(y, int) or float(y).is_integer()):
                return False
        return True

    def _boundary_lattice_points(self, vertices) -> int:
        """B in Pick: number of lattice points on the polygon boundary.
        Sum of gcd(|dx|, |dy|) over edges (each edge endpoint counted once
        because gcd-counts include the start, exclude the end)."""
        if not self._is_lattice(vertices):
            return -1  # undefined for non-lattice
        n = len(vertices)
        B = 0
        for i in range(n):
            j = (i + 1) % n
            dx = abs(int(vertices[j][0]) - int(vertices[i][0]))
            dy = abs(int(vertices[j][1]) - int(vertices[i][1]))
            B += gcd(dx, dy)
        return B

    def _interior_lattice_points(self, vertices) -> int:
        """I = A - B/2 + 1 (inverted Pick) — only valid if polygon is lattice
        AND simple (no self-intersection). For non-lattice or self-intersecting,
        returns -1."""
        if not self._is_lattice(vertices):
            return -1
        if not self._is_simple(vertices):
            return -1
        A = self._shoelace_area(vertices)
        B = self._boundary_lattice_points(vertices)
        I = A - B / 2.0 + 1
        return int(round(I))

    def _is_simple(self, vertices) -> bool:
        """Check if polygon is simple (non-self-intersecting)."""
        n = len(vertices)
        if n < 3:
            return False
        # Check every pair of non-adjacent edges
        for i in range(n):
            for j in range(i + 2, n):
                # Skip the wraparound adjacency: i=0, j=n-1
                if i == 0 and j == n - 1:
                    continue
                if _segments_intersect(
                    vertices[i], vertices[(i + 1) % n],
                    vertices[j], vertices[(j + 1) % n],
                ):
                    return False
        return True

    def _perimeter(self, vertices) -> float:
        n = len(vertices)
        total = 0.0
        for i in range(n):
            j = (i + 1) % n
            dx = vertices[j][0] - vertices[i][0]
            dy = vertices[j][1] - vertices[i][1]
            total += math.sqrt(dx * dx + dy * dy)
        return round(total, 6)

    def _edge_data(self, vertices) -> list[dict]:
        n = len(vertices)
        edges = []
        is_lattice = self._is_lattice(vertices)
        for i in range(n):
            j = (i + 1) % n
            dx = vertices[j][0] - vertices[i][0]
            dy = vertices[j][1] - vertices[i][1]
            length = math.sqrt(dx * dx + dy * dy)
            if is_lattice:
                g = gcd(abs(int(dx)), abs(int(dy)))
                lattice_on_edge = g + 1  # includes both endpoints
                lattice_interior = max(g - 1, 0)
            else:
                g = -1
                lattice_on_edge = -1
                lattice_interior = -1
            edges.append({
                "from": list(vertices[i]),
                "to": list(vertices[j]),
                "direction": [dx, dy],
                "length": round(length, 6),
                "gcd": g,
                "lattice_points_on_edge": lattice_on_edge,
                "lattice_points_interior_to_edge": lattice_interior,
            })
        return edges

    def _is_convex(self, vertices) -> bool:
        n = len(vertices)
        if n < 3:
            return True
        sign = None
        for i in range(n):
            j = (i + 1) % n
            k = (i + 2) % n
            cross = ((vertices[j][0] - vertices[i][0]) * (vertices[k][1] - vertices[j][1]) -
                    (vertices[j][1] - vertices[i][1]) * (vertices[k][0] - vertices[j][0]))
            if cross != 0:
                if sign is None:
                    sign = cross > 0
                elif (cross > 0) != sign:
                    return False
        return True

    # ---- relate --------------------------------------------------------------
    def relate(self, obj_a: PolygonObject, obj_b: PolygonObject,
               detail_level: int = 1) -> RelationData:
        va = list(obj_a.vertices)
        vb = list(obj_b.vertices)
        A_a = self._shoelace_area(va)
        A_b = self._shoelace_area(vb)
        B_a = self._boundary_lattice_points(va)
        B_b = self._boundary_lattice_points(vb)
        I_a = self._interior_lattice_points(va)
        I_b = self._interior_lattice_points(vb)

        def pick_holds(A, I, B):
            if I < 0 or B < 0:
                return False
            return abs(A - (I + B / 2.0 - 1)) < 1e-6

        summary = {
            "area_a": A_a, "area_b": A_b,
            "perimeter_a": self._perimeter(va),
            "perimeter_b": self._perimeter(vb),
            "n_vertices_a": len(va), "n_vertices_b": len(vb),
            "B_a": B_a, "B_b": B_b,
            "I_a": I_a, "I_b": I_b,
            "pick_holds_a": pick_holds(A_a, I_a, B_a),
            "pick_holds_b": pick_holds(A_b, I_b, B_b),
        }

        rel = RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary=summary,
        )
        if detail_level <= 1:
            return rel

        edges_a = self._edge_data(va)
        edges_b = self._edge_data(vb)
        rel.detailed = {
            "edges_a": edges_a,
            "edges_b": edges_b,
            "boundary_lattice_sum_a":
                sum(max(e["lattice_points_interior_to_edge"], 0) for e in edges_a)
                + len(edges_a),  # interior-of-edge + n_vertices = total B
            "boundary_lattice_sum_b":
                sum(max(e["lattice_points_interior_to_edge"], 0) for e in edges_b)
                + len(edges_b),
        }
        if detail_level <= 2:
            return rel

        rel.structural = {
            "is_convex_a": self._is_convex(va),
            "is_convex_b": self._is_convex(vb),
            "is_simple_a": self._is_simple(va),
            "is_simple_b": self._is_simple(vb),
            "pick_formula_a": (
                f"A={A_a} ?= I+B/2-1 = {I_a}+{B_a/2.0}-1 = {I_a + B_a/2.0 - 1}"
                if I_a >= 0 and B_a >= 0 else "undefined (non-lattice or self-intersecting)"
            ),
            "pick_formula_b": (
                f"A={A_b} ?= I+B/2-1 = {I_b}+{B_b/2.0}-1 = {I_b + B_b/2.0 - 1}"
                if I_b >= 0 and B_b >= 0 else "undefined (non-lattice or self-intersecting)"
            ),
            "edge_gcd_decomposition_a": [e["gcd"] for e in edges_a],
            "edge_gcd_decomposition_b": [e["gcd"] for e in edges_b],
            "vertices_a": [list(v) for v in va],
            "vertices_b": [list(v) for v in vb],
        }
        return rel

    # ---- transform -----------------------------------------------------------
    def transform(self, obj: PolygonObject, operation: dict) -> TransformResult:
        verts = list(obj.vertices)
        op_type = operation["type"]

        if op_type == "add_vertex":
            pos = tuple(operation["position"])
            idx = int(operation["after_index"])
            new_verts = verts[:idx + 1] + [pos] + verts[idx + 1:]
            oid = f"{obj.object_id}_addv_{pos[0]}_{pos[1]}"

        elif op_type == "translate":
            dx, dy = operation["delta"]
            new_verts = [(v[0] + dx, v[1] + dy) for v in verts]
            oid = f"{obj.object_id}_tr_{dx}_{dy}"

        elif op_type == "shear":
            m = operation["matrix"]
            new_verts = [
                (m[0][0] * v[0] + m[0][1] * v[1],
                 m[1][0] * v[0] + m[1][1] * v[1])
                for v in verts
            ]
            # Round if shear preserves lattice structure (det = ±1 with int entries)
            new_verts = [(int(round(v[0])), int(round(v[1]))) for v in new_verts]
            oid = f"{obj.object_id}_shear"

        elif op_type == "scale_non_uniform":
            sx, sy = operation["scale"]
            new_verts = [(v[0] * sx, v[1] * sy) for v in verts]
            oid = f"{obj.object_id}_scale_{sx}_{sy}"

        else:
            raise ValueError(f"Unknown operation: {operation}")

        new_obj = PolygonObject(
            object_id=oid,
            vertices=tuple(tuple(v) for v in new_verts),
        )

        inv_before = self.invariants(obj)
        inv_after = self.invariants(new_obj)

        trace = TransformTrace(
            operation_name=op_type,
            operation_params=dict(operation),
            before_state={
                "area": inv_before["area"],
                "B": inv_before["B"],
                "I": inv_before["I"],
                "pick_holds": inv_before["pick_holds"],
                "n_vertices": len(verts),
            },
            after_state={
                "area": inv_after["area"],
                "B": inv_after["B"],
                "I": inv_after["I"],
                "pick_holds": inv_after["pick_holds"],
                "n_vertices": len(new_verts),
            },
            delta={
                "area_change": round(inv_after["area"] - inv_before["area"], 6),
                "B_change": (inv_after["B"] - inv_before["B"]
                             if inv_before["B"] >= 0 and inv_after["B"] >= 0 else None),
                "I_change": (inv_after["I"] - inv_before["I"]
                             if inv_before["I"] >= 0 and inv_after["I"] >= 0 else None),
                "pick_preserved": (inv_after["pick_holds"]
                                   == inv_before["pick_holds"]
                                   and inv_before["pick_holds"]),
                "area_preserved":
                    abs(inv_after["area"] - inv_before["area"]) < 1e-6,
            },
            region_affected={
                "operation": op_type,
                "vertices_before": len(verts),
                "vertices_after": len(new_verts),
                "vertex_diff": len(new_verts) - len(verts),
            },
        )

        def _safe_delta(k):
            a, b = inv_before[k], inv_after[k]
            if isinstance(a, (int, float)) and isinstance(b, (int, float)) \
                    and not isinstance(a, bool) and not isinstance(b, bool):
                return round(b - a, 6)
            return None

        return TransformResult(
            original_id=obj.object_id,
            transformed_id=new_obj.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta={k: _safe_delta(k) for k in inv_before
                              if _safe_delta(k) is not None},
            invariants_preserved={
                k: (abs(inv_before[k] - inv_after[k]) < 1e-6
                    if isinstance(inv_before[k], (int, float))
                    and not isinstance(inv_before[k], bool)
                    else inv_before[k] == inv_after[k])
                for k in inv_before
            },
        )

    # ---- invariants ----------------------------------------------------------
    def invariants(self, obj: PolygonObject) -> dict:
        verts = list(obj.vertices)
        A = self._shoelace_area(verts)
        B = self._boundary_lattice_points(verts)
        I = self._interior_lattice_points(verts)
        is_simple = self._is_simple(verts)
        pick_holds = (B >= 0 and I >= 0
                      and abs(A - (I + B / 2.0 - 1)) < 1e-6)
        return {
            "area": A,
            "perimeter": self._perimeter(verts),
            "B": B,
            "I": I,
            "pick_holds": pick_holds,
            "is_convex": self._is_convex(verts),
            "is_simple": is_simple,
            "is_lattice": self._is_lattice(verts),
            "n_vertices": len(verts),
        }

    # ---- compare -------------------------------------------------------------
    def compare(self, obj_a: PolygonObject, obj_b: PolygonObject,
                transformed_a: PolygonObject,
                transform_result: TransformResult,
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

        cmp.detailed_comparison = {
            "area_preserved": transform_result.trace.delta["area_preserved"],
            "B_change": transform_result.trace.delta["B_change"],
            "I_change": transform_result.trace.delta["I_change"],
            "edges_pre": pre.detailed.get("edges_a", []),
            "edges_post": post.detailed.get("edges_a", []),
        }

        cmp.reference_in_transform_region = transform_result.trace.region_affected

        before = transform_result.trace.before_state
        after = transform_result.trace.after_state
        area_pre = before["area"]
        area_post = after["area"]
        B_pre, B_post = before["B"], after["B"]
        I_pre, I_post = before["I"], after["I"]
        cmp.structural_comparison = {
            "pick_holds_pre": before["pick_holds"],
            "pick_holds_post": after["pick_holds"],
            "pick_preserved": transform_result.trace.delta["pick_preserved"],
            "area_from_pick_pre":
                (I_pre + B_pre / 2.0 - 1) if (I_pre >= 0 and B_pre >= 0) else None,
            "area_from_pick_post":
                (I_post + B_post / 2.0 - 1) if (I_post >= 0 and B_post >= 0) else None,
            "area_from_shoelace_pre": area_pre,
            "area_from_shoelace_post": area_post,
            "is_lattice_pre": self._is_lattice(obj_a.vertices),
            "is_lattice_post": self._is_lattice(transformed_a.vertices),
            "is_simple_pre": self._is_simple(obj_a.vertices),
            "is_simple_post": self._is_simple(transformed_a.vertices),
        }
        return cmp


# ---- segment intersection helper -------------------------------------------
def _ccw(a, b, c) -> int:
    """Return sign of cross product (b-a) x (c-a). 0 = collinear."""
    v = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    if v > 1e-9:
        return 1
    if v < -1e-9:
        return -1
    return 0


def _on_segment(a, b, c) -> bool:
    """Whether c lies on segment ab, assuming collinearity."""
    return (min(a[0], b[0]) - 1e-9 <= c[0] <= max(a[0], b[0]) + 1e-9
            and min(a[1], b[1]) - 1e-9 <= c[1] <= max(a[1], b[1]) + 1e-9)


def _segments_intersect(p1, p2, p3, p4) -> bool:
    """Strict intersection test for non-adjacent edges. Touching at a shared
    endpoint (which would only happen on adjacent edges in a polygon, and
    those are excluded by the caller) does not count."""
    d1 = _ccw(p3, p4, p1)
    d2 = _ccw(p3, p4, p2)
    d3 = _ccw(p1, p2, p3)
    d4 = _ccw(p1, p2, p4)
    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) \
            and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
        return True
    # Collinear overlap cases
    if d1 == 0 and _on_segment(p3, p4, p1):
        return True
    if d2 == 0 and _on_segment(p3, p4, p2):
        return True
    if d3 == 0 and _on_segment(p1, p2, p3):
        return True
    if d4 == 0 and _on_segment(p1, p2, p4):
        return True
    return False


# Self-test
if __name__ == "__main__":
    e = BoundaryInteriorEngine()
    P = e.construct({"type": "rectangle_4x3"})
    print(f"rectangle_4x3: invariants = {e.invariants(P)}")

    P_T = e.construct({"type": "right_triangle"})
    print(f"right_triangle (6,4): invariants = {e.invariants(P_T)}")

    # Verify Pick on all presets
    print("\nPick check on all presets:")
    for name in e.PRESETS:
        P = e.construct({"type": name})
        inv = e.invariants(P)
        ok = "OK" if inv["pick_holds"] else "FAIL"
        print(f"  {name:18s} A={inv['area']:6.1f} I={inv['I']:3d} B={inv['B']:3d}  Pick: {ok}")

    # Add a vertex on an edge: B should grow by 1 (if interior to a previously-lattice-only edge)
    P = e.construct({"type": "rectangle_4x3"})
    tr = e.transform(P, {"type": "add_vertex", "position": [2, 0], "after_index": 0})
    print(f"\nadd_vertex (2,0) after idx 0: A_change={tr.trace.delta['area_change']}, "
          f"B_change={tr.trace.delta['B_change']}, I_change={tr.trace.delta['I_change']}, "
          f"pick_preserved={tr.trace.delta['pick_preserved']}")

    # Translate
    tr_t = e.transform(P, {"type": "translate", "delta": [10, 5]})
    print(f"translate (10,5): A_change={tr_t.trace.delta['area_change']}, "
          f"B_change={tr_t.trace.delta['B_change']}, I_change={tr_t.trace.delta['I_change']}, "
          f"pick_preserved={tr_t.trace.delta['pick_preserved']}")

    # Unimodular shear
    tr_s = e.transform(P, {"type": "shear", "matrix": [[1, 1], [0, 1]]})
    print(f"shear [[1,1],[0,1]]: A_change={tr_s.trace.delta['area_change']}, "
          f"B_change={tr_s.trace.delta['B_change']}, I_change={tr_s.trace.delta['I_change']}, "
          f"pick_preserved={tr_s.trace.delta['pick_preserved']}")

    # Non-area-preserving scale
    tr_sc = e.transform(P, {"type": "scale_non_uniform", "scale": [2, 1]})
    print(f"scale [2,1]: A_change={tr_sc.trace.delta['area_change']}, "
          f"B_change={tr_sc.trace.delta['B_change']}, I_change={tr_sc.trace.delta['I_change']}, "
          f"pick_preserved={tr_sc.trace.delta['pick_preserved']}")

    # Compare
    P2 = e.construct({"type": "L_shape"})
    cmp = e.compare(P, P2, P, tr_t, detail_level=4)
    print(f"\nCompare (rectangle_4x3, L_shape) under translate:")
    print(f"  summary_delta keys: {list(cmp.summary_delta.keys())}")
    print(f"  structural_comparison: {cmp.structural_comparison}")
