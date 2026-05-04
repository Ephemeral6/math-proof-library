"""SymmetryEngine — group action on colorings.

Pure Python, no external libraries.

construct(spec) -> ColoringObject
relate(A, B, detail_level) -> RelationData
  L1: hamming_distance, same_orbit, orbit sizes
  L2: + connecting_elements (which group elements send A to B), per_vertex_diff
  L3: + stabilizer of each, orbit-stabilizer theorem holds, fixed-point counts,
       Burnside count, total orbits.
transform(obj, operation) -> TransformResult
  Apply a group element; record which vertices moved.
compare(A, B, g(A), ...) -> RelationComparison
invariants(obj) -> orbit_id, orbit_size, stabilizer_size, color_frequency, ...
"""

from __future__ import annotations

import sys
import os
from collections import Counter
from dataclasses import dataclass
from itertools import product
from typing import Any

# Ensure package import works whether run as a script or imported.
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_SPATIAL_ROOT = os.path.abspath(os.path.join(_THIS_DIR, "..", "..", ".."))
if _SPATIAL_ROOT not in sys.path:
    sys.path.insert(0, _SPATIAL_ROOT)

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformTrace, TransformResult
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


@dataclass(frozen=True)
class ColoringObject:
    object_id: str
    n_vertices: int
    n_colors: int
    coloring: tuple

    def to_json(self) -> dict:
        return {
            "object_id": self.object_id,
            "n_vertices": self.n_vertices,
            "n_colors": self.n_colors,
            "coloring": list(self.coloring),
        }


class SymmetryEngine:
    domain_name = "symmetry_combinatorics"

    def __init__(self, n_vertices: int = 6, n_colors: int = 3,
                 group: str = "cyclic"):
        self.m = n_vertices
        self.k = n_colors
        self.group_type = group
        self.group_elements = self._generate_group()
        self.all_colorings = list(product(range(self.k), repeat=self.m))
        self.orbits = self._compute_orbits()
        self._coloring_to_orbit = self._build_orbit_map()
        self._fixed_counts_cache: dict | None = None

    # ----- group construction ------------------------------------------------

    def _generate_group(self):
        m = self.m
        elements = []
        for i in range(m):
            perm = tuple((j + i) % m for j in range(m))
            elements.append(perm)
        if self.group_type == "dihedral":
            for i in range(m):
                perm = tuple((i - j) % m for j in range(m))
                elements.append(perm)
        return elements

    def _apply(self, coloring, perm):
        return tuple(coloring[perm[j]] for j in range(len(coloring)))

    # ----- orbits ------------------------------------------------------------

    def _compute_orbits(self):
        n = len(self.all_colorings)
        visited = [False] * n
        idx_map = {c: i for i, c in enumerate(self.all_colorings)}
        orbits = []
        for i in range(n):
            if visited[i]:
                continue
            orbit = []
            for g in self.group_elements:
                gc = self._apply(self.all_colorings[i], g)
                j = idx_map[gc]
                if not visited[j]:
                    visited[j] = True
                    orbit.append(j)
            orbits.append(orbit)
        return orbits

    def _build_orbit_map(self):
        m = {}
        for oi, orbit in enumerate(self.orbits):
            for j in orbit:
                m[self.all_colorings[j]] = oi
        return m

    def _orbit_of(self, c):
        return frozenset(self._apply(c, g) for g in self.group_elements)

    def _orbit_id(self, c):
        return min(self._apply(c, g) for g in self.group_elements)

    def _orbit_size(self, c):
        return len(self._orbit_of(c))

    def _stabilizer(self, c):
        return [i for i, g in enumerate(self.group_elements)
                if self._apply(c, g) == c]

    def _element_order(self, g):
        identity = tuple(range(len(g)))
        current = g
        order = 1
        while current != identity:
            current = tuple(current[g[j]] for j in range(len(g)))
            order += 1
            if order > len(g) * len(g):
                break
        return order

    # ----- GeometricEngine interface ----------------------------------------

    def construct(self, spec: dict) -> ColoringObject:
        if "coloring" in spec:
            c = tuple(spec["coloring"])
        elif "index" in spec:
            c = self.all_colorings[spec["index"]]
        else:
            raise ValueError(f"spec needs 'coloring' or 'index': {spec}")
        return ColoringObject(
            object_id=f"c{''.join(map(str, c))}",
            n_vertices=self.m,
            n_colors=self.k,
            coloring=c,
        )

    def relate(self, obj_a, obj_b, detail_level: int = 1) -> RelationData:
        a, b = obj_a.coloring, obj_b.coloring
        hamming = sum(1 for x, y in zip(a, b) if x != y)
        same_orbit = self._coloring_to_orbit[a] == self._coloring_to_orbit[b]

        summary = {
            "hamming_distance": hamming,
            "same_orbit": same_orbit,
            "orbit_size_a": self._orbit_size(a),
            "orbit_size_b": self._orbit_size(b),
        }

        detailed: dict = {}
        if detail_level >= 2:
            connecting = []
            for i, g in enumerate(self.group_elements):
                if self._apply(a, g) == b:
                    connecting.append({
                        "element_index": i,
                        "permutation": list(g),
                        "is_rotation": i < self.m,
                        "order": self._element_order(g),
                    })
            detailed = {
                "connecting_elements": connecting,
                "n_connecting": len(connecting),
                "per_vertex_diff": [int(x != y) for x, y in zip(a, b)],
            }

        structural: dict = {}
        if detail_level >= 3:
            stab_a = self._stabilizer(a)
            stab_b = self._stabilizer(b)
            structural = {
                "stabilizer_a": stab_a,
                "stabilizer_a_size": len(stab_a),
                "stabilizer_b": stab_b,
                "stabilizer_b_size": len(stab_b),
                "orbit_stabilizer_product_a":
                    len(stab_a) * self._orbit_size(a),
                "orbit_stabilizer_product_b":
                    len(stab_b) * self._orbit_size(b),
                "group_order": len(self.group_elements),
                "orbit_stabilizer_theorem_holds_a":
                    len(stab_a) * self._orbit_size(a) == len(self.group_elements),
                "orbit_stabilizer_theorem_holds_b":
                    len(stab_b) * self._orbit_size(b) == len(self.group_elements),
                "fixed_point_counts": self._fixed_point_counts(),
                "burnside_count": self._burnside_count(),
                "total_orbits": len(self.orbits),
            }

        return RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary=summary,
            detailed=detailed,
            structural=structural,
        )

    def transform(self, obj, operation: dict) -> TransformResult:
        g_idx = operation["element_index"]
        g = self.group_elements[g_idx]
        new_c = self._apply(obj.coloring, g)
        new_obj = self.construct({"coloring": list(new_c)})

        inv_before = self.invariants(obj)
        inv_after = self.invariants(new_obj)

        moved = [i for i in range(self.m) if obj.coloring[i] != new_c[i]]
        fixed = [i for i in range(self.m) if obj.coloring[i] == new_c[i]]

        trace = TransformTrace(
            operation_name="group_action",
            operation_params={
                "element_index": g_idx,
                "permutation": list(g),
                "is_rotation": g_idx < self.m,
                "order": self._element_order(g),
            },
            before_state={"coloring": list(obj.coloring)},
            after_state={"coloring": list(new_c)},
            delta={
                "vertices_changed": len(moved),
                "is_fixed_point": len(moved) == 0,
            },
            region_affected={
                "moved_vertices": moved,
                "fixed_vertices": fixed,
                "n_moved": len(moved),
                "n_fixed": len(fixed),
            },
        )

        invariants_delta = {}
        for k, v_before in inv_before.items():
            v_after = inv_after.get(k)
            if isinstance(v_before, (int, float)) and not isinstance(v_before, bool) \
               and isinstance(v_after, (int, float)) and not isinstance(v_after, bool):
                invariants_delta[k] = v_after - v_before

        invariants_preserved = {
            k: inv_before[k] == inv_after.get(k) for k in inv_before
        }

        return TransformResult(
            original_id=obj.object_id,
            transformed_id=new_obj.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta=invariants_delta,
            invariants_preserved=invariants_preserved,
        )

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
                "connecting_pre": pre.detailed.get("n_connecting", 0),
                "connecting_post": post.detailed.get("n_connecting", 0),
                "hamming_pre": pre.summary["hamming_distance"],
                "hamming_post": post.summary["hamming_distance"],
                "same_orbit_pre": pre.summary["same_orbit"],
                "same_orbit_post": post.summary["same_orbit"],
            }

        if detail_level >= 3:
            moved = transform_result.trace.region_affected.get("moved_vertices", [])
            fixed = transform_result.trace.region_affected.get("fixed_vertices", [])
            cmp.reference_in_transform_region = {
                "moved_vertices": moved,
                "fixed_vertices": fixed,
                "b_colors_at_moved": [obj_b.coloring[i] for i in moved],
                "b_colors_at_fixed": [obj_b.coloring[i] for i in fixed],
            }

        if detail_level >= 4:
            cmp.structural_comparison = {
                "stabilizer_a_size_pre": pre.structural.get("stabilizer_a_size", 0),
                "stabilizer_a_size_post": post.structural.get("stabilizer_a_size", 0),
                "orbit_stabilizer_holds_pre":
                    pre.structural.get("orbit_stabilizer_theorem_holds_a", False),
                "orbit_stabilizer_holds_post":
                    post.structural.get("orbit_stabilizer_theorem_holds_a", False),
                "fixed_point_counts": pre.structural.get("fixed_point_counts", {}),
                "burnside_count": pre.structural.get("burnside_count", 0),
                "total_orbits": pre.structural.get("total_orbits", 0),
                "group_order": pre.structural.get("group_order", 0),
            }

        return cmp

    def invariants(self, obj) -> dict:
        c = obj.coloring
        freq = Counter(c)
        return {
            "orbit_id": str(self._orbit_id(c)),
            "orbit_size": self._orbit_size(c),
            "stabilizer_size": len(self._stabilizer(c)),
            "n_distinct_colors": len(freq),
            "color_frequency": dict(sorted(freq.items())),
            "is_monochromatic": len(freq) == 1,
        }

    # ----- Burnside data -----------------------------------------------------

    def _fixed_point_counts(self) -> dict:
        """How many colorings each group element fixes (Burnside core data)."""
        if self._fixed_counts_cache is not None:
            return self._fixed_counts_cache
        counts = {}
        for i, g in enumerate(self.group_elements):
            n_fixed = sum(1 for c in self.all_colorings if self._apply(c, g) == c)
            counts[i] = n_fixed
        self._fixed_counts_cache = counts
        return counts

    def _burnside_count(self) -> int:
        """Orbit count via Burnside's lemma."""
        total_fixed = sum(self._fixed_point_counts().values())
        return total_fixed // len(self.group_elements)


# Self-test ------------------------------------------------------------------

if __name__ == "__main__":
    e = SymmetryEngine(6, 3, "cyclic")
    print(f"Hexagon, 3 colors, Z_6:")
    print(f"  Total colorings: {len(e.all_colorings)}")
    print(f"  Orbits: {len(e.orbits)}")
    print(f"  Group elements: {len(e.group_elements)}")
    print(f"  Burnside count: {e._burnside_count()}")

    a = e.construct({"coloring": [0, 1, 2, 0, 1, 2]})
    b = e.construct({"coloring": [1, 2, 0, 1, 2, 0]})

    rel = e.relate(a, b, detail_level=3)
    print(f"\n  relate({a.coloring}, {b.coloring}):")
    print(f"    same_orbit: {rel.summary['same_orbit']}")
    print(f"    connecting: {rel.detailed.get('n_connecting', '?')}")
    print(f"    stabilizer_a: {rel.structural.get('stabilizer_a', '?')}")
    print(f"    orbit_stabilizer: "
          f"{rel.structural.get('orbit_stabilizer_theorem_holds_a', '?')}")

    tr = e.transform(a, {"element_index": 2})
    print(f"\n  transform by rotation 2: {a.coloring} -> "
          f"{tr.trace.after_state['coloring']}")
    print(f"    invariants preserved: {tr.invariants_preserved}")

    cmp = e.compare(a, b, e.construct({"coloring": list(tr.trace.after_state['coloring'])}),
                    tr, detail_level=4)
    print(f"\n  compare summary_delta: {cmp.summary_delta}")
    print(f"  detailed_comparison: {cmp.detailed_comparison}")
    print(f"  structural_comparison.burnside_count: "
          f"{cmp.structural_comparison.get('burnside_count')}")
