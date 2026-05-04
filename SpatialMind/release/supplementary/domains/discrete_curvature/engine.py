"""DiscreteCurvatureEngine — 多面体表面的离散曲率和 Euler 特征数。

构造多面体网格，计算每个顶点的角缺（离散高斯曲率），
验证 Gauss-Bonnet 定理：Σ δ(v) = 2π χ。

construct(spec) → MeshObject
  spec = {"type": "tetrahedron"} 或 {"vertices": [...], "faces": [...]}

relate(mesh_a, mesh_b, detail_level) → RelationData
  L1: n_vertices, n_edges, n_faces, euler_characteristic, total_curvature
  L2: + per-vertex angle_defect, per-vertex degree, per-face angles
  L3: + per-vertex is_flat/positive/negative curvature classification,
       vertex_type distribution (cone/saddle/flat)

transform(mesh, operation) → TransformResult
  operation = {"type": "stellar_subdivision", "face": i}（在一个面上加一个顶点）
  或 {"type": "vertex_displacement", "vertex": i, "displacement": (x,y,z)}
  trace: 局部角缺怎么变了，全局 Euler 特征数是否变了

invariants(mesh) → euler_characteristic, total_curvature, genus

compare(mesh_a, mesh_b, mesh_modified, ...) → RelationComparison
  summary_delta: euler_characteristic 变了吗？total_curvature 变了吗？
  detailed: 哪些顶点的角缺变了？
  structural: 变之前和变之后的 curvature distribution
"""

from __future__ import annotations
from collections import Counter
from dataclasses import dataclass
from typing import Any
import math

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformTrace, TransformResult
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


@dataclass(frozen=True)
class MeshObject:
    _object_id: str
    vertices: tuple
    faces: tuple

    @property
    def object_id(self) -> str:
        return self._object_id

    def to_json(self) -> dict:
        return {
            "object_id": self._object_id,
            "n_vertices": len(self.vertices),
            "n_faces": len(self.faces),
            "vertices": [list(v) for v in self.vertices],
            "faces": [list(f) for f in self.faces],
        }


def _edge_length(v1, v2):
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(v1, v2)))


def _triangle_angles(v0, v1, v2):
    """Return interior angles (radians) at v0, v1, v2 of triangle."""
    a = _edge_length(v1, v2)
    b = _edge_length(v0, v2)
    c = _edge_length(v0, v1)

    def _angle(opp, s1, s2):
        denom = 2 * s1 * s2
        if denom < 1e-15:
            return 0.0
        cos_val = (s1 * s1 + s2 * s2 - opp * opp) / denom
        cos_val = max(-1.0, min(1.0, cos_val))
        return math.acos(cos_val)

    return (_angle(a, b, c), _angle(b, a, c), _angle(c, a, b))


class DiscreteCurvatureEngine:
    domain_name = "discrete_curvature"

    PRESETS = {
        "tetrahedron": {
            "vertices": [(1, 1, 1), (-1, -1, 1), (-1, 1, -1), (1, -1, -1)],
            "faces": [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)],
        },
        "cube_triangulated": {
            "vertices": [
                (0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0),
                (0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1),
            ],
            "faces": [
                (0, 1, 2), (0, 2, 3),  # bottom z=0
                (4, 6, 5), (4, 7, 6),  # top z=1
                (0, 5, 1), (0, 4, 5),  # front y=0
                (2, 7, 3), (2, 6, 7),  # back y=1
                (0, 3, 7), (0, 7, 4),  # left x=0
                (1, 6, 2), (1, 5, 6),  # right x=1
            ],
        },
        "octahedron": {
            "vertices": [
                (1, 0, 0), (-1, 0, 0), (0, 1, 0),
                (0, -1, 0), (0, 0, 1), (0, 0, -1),
            ],
            "faces": [
                (0, 2, 4), (2, 1, 4), (1, 3, 4), (3, 0, 4),
                (2, 0, 5), (1, 2, 5), (3, 1, 5), (0, 3, 5),
            ],
        },
        "icosahedron": {
            "vertices": [
                (0, 1, 1.618), (0, 1, -1.618), (0, -1, 1.618), (0, -1, -1.618),
                (1, 1.618, 0), (-1, 1.618, 0), (1, -1.618, 0), (-1, -1.618, 0),
                (1.618, 0, 1), (-1.618, 0, 1), (1.618, 0, -1), (-1.618, 0, -1),
            ],
            "faces": [
                (0, 2, 8), (0, 8, 4), (0, 4, 5), (0, 5, 9), (0, 9, 2),
                (3, 6, 10), (3, 10, 1), (3, 1, 11), (3, 11, 7), (3, 7, 6),
                (2, 6, 8), (8, 10, 4), (4, 1, 5), (5, 11, 9), (9, 7, 2),
                (6, 2, 7), (10, 8, 6), (1, 4, 10), (11, 5, 1), (7, 9, 11),
            ],
        },
    }

    def construct(self, spec: dict) -> MeshObject:
        if "type" in spec and spec["type"] in self.PRESETS:
            p = self.PRESETS[spec["type"]]
            verts = tuple(tuple(float(x) for x in v) for v in p["vertices"])
            faces = tuple(tuple(int(x) for x in f) for f in p["faces"])
            oid = spec.get("object_id", spec["type"])
        elif "vertices" in spec and "faces" in spec:
            verts = tuple(tuple(float(x) for x in v) for v in spec["vertices"])
            faces = tuple(tuple(int(x) for x in f) for f in spec["faces"])
            oid = spec.get("object_id", f"mesh_{len(verts)}v_{len(faces)}f")
        else:
            raise ValueError(f"Unknown spec: {spec}")
        return MeshObject(_object_id=oid, vertices=verts, faces=faces)

    # ---- combinatorial helpers ----

    def _edges(self, mesh: MeshObject) -> set:
        edges = set()
        for f in mesh.faces:
            for i in range(3):
                e = tuple(sorted((f[i], f[(i + 1) % 3])))
                edges.add(e)
        return edges

    def _vertex_angles(self, mesh: MeshObject) -> dict:
        angles = {i: [] for i in range(len(mesh.vertices))}
        for f in mesh.faces:
            v0 = mesh.vertices[f[0]]
            v1 = mesh.vertices[f[1]]
            v2 = mesh.vertices[f[2]]
            a0, a1, a2 = _triangle_angles(v0, v1, v2)
            angles[f[0]].append(a0)
            angles[f[1]].append(a1)
            angles[f[2]].append(a2)
        return angles

    def _angle_defects(self, mesh: MeshObject) -> dict:
        va = self._vertex_angles(mesh)
        defects = {}
        for v, angle_list in va.items():
            if angle_list:
                defects[v] = 2 * math.pi - sum(angle_list)
            else:
                defects[v] = 2 * math.pi
        return defects

    def _euler_characteristic(self, mesh: MeshObject) -> int:
        V = len(mesh.vertices)
        E = len(self._edges(mesh))
        F = len(mesh.faces)
        return V - E + F

    def _vertex_degrees(self, mesh: MeshObject) -> dict:
        deg = {i: 0 for i in range(len(mesh.vertices))}
        for f in mesh.faces:
            for v in f:
                deg[v] += 1
        return deg

    # ---- relate ----

    def relate(self, obj_a: MeshObject, obj_b: MeshObject,
               detail_level: int = 1) -> RelationData:
        chi_a = self._euler_characteristic(obj_a)
        chi_b = self._euler_characteristic(obj_b)
        defects_a = self._angle_defects(obj_a)
        defects_b = self._angle_defects(obj_b)
        total_a = sum(defects_a.values())
        total_b = sum(defects_b.values())

        summary = {
            "euler_characteristic_a": chi_a,
            "euler_characteristic_b": chi_b,
            "euler_characteristic_match": chi_a == chi_b,
            "total_curvature_a": round(total_a, 6),
            "total_curvature_b": round(total_b, 6),
            "gauss_bonnet_ratio_a": round(total_a / (2 * math.pi), 6),
            "gauss_bonnet_ratio_b": round(total_b / (2 * math.pi), 6),
            "n_vertices_a": len(obj_a.vertices),
            "n_vertices_b": len(obj_b.vertices),
            "n_edges_a": len(self._edges(obj_a)),
            "n_edges_b": len(self._edges(obj_b)),
            "n_faces_a": len(obj_a.faces),
            "n_faces_b": len(obj_b.faces),
        }

        rel = RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary=summary,
        )

        if detail_level >= 2:
            deg_a = self._vertex_degrees(obj_a)
            deg_b = self._vertex_degrees(obj_b)
            rel.detailed = {
                "angle_defects_a": {str(k): round(v, 6)
                                    for k, v in defects_a.items()},
                "angle_defects_b": {str(k): round(v, 6)
                                    for k, v in defects_b.items()},
                "vertex_degrees_a": {str(k): v for k, v in deg_a.items()},
                "vertex_degrees_b": {str(k): v for k, v in deg_b.items()},
                "n_vertices_a": len(obj_a.vertices),
                "n_vertices_b": len(obj_b.vertices),
            }

        if detail_level >= 3:
            def classify(d):
                if abs(d) < 1e-6:
                    return "flat"
                return "positive" if d > 0 else "negative"

            types_a = {str(k): classify(v) for k, v in defects_a.items()}
            types_b = {str(k): classify(v) for k, v in defects_b.items()}
            rel.structural = {
                "curvature_types_a": dict(Counter(types_a.values())),
                "curvature_types_b": dict(Counter(types_b.values())),
                "per_vertex_type_a": types_a,
                "per_vertex_type_b": types_b,
                "genus_a": max(0, (2 - chi_a) // 2) if chi_a <= 2 else 0,
                "genus_b": max(0, (2 - chi_b) // 2) if chi_b <= 2 else 0,
            }
        return rel

    # ---- transform ----

    def transform(self, obj: MeshObject, operation: dict, **kwargs) -> TransformResult:
        op = operation["type"]
        if op == "stellar_subdivision":
            return self._stellar_subdivision(obj, operation["face"])
        if op == "vertex_displacement":
            return self._vertex_displacement(
                obj, operation["vertex"], operation["displacement"])
        raise ValueError(f"Unknown operation: {op}")

    def _stellar_subdivision(self, mesh: MeshObject, face_idx: int) -> TransformResult:
        """Subdivide one face by adding a new vertex at its centroid.
        ΔV=+1, ΔE=+3, ΔF=+2 → χ unchanged."""
        f = mesh.faces[face_idx]
        v0 = mesh.vertices[f[0]]
        v1 = mesh.vertices[f[1]]
        v2 = mesh.vertices[f[2]]
        center = tuple((a + b + c) / 3 for a, b, c in zip(v0, v1, v2))
        new_v_idx = len(mesh.vertices)

        new_verts = list(mesh.vertices) + [center]
        new_faces = [fa for i, fa in enumerate(mesh.faces) if i != face_idx]
        new_faces.extend([
            (f[0], f[1], new_v_idx),
            (f[1], f[2], new_v_idx),
            (f[2], f[0], new_v_idx),
        ])

        new_mesh = MeshObject(
            _object_id=f"{mesh.object_id}_subdiv_f{face_idx}",
            vertices=tuple(tuple(v) for v in new_verts),
            faces=tuple(tuple(fa) for fa in new_faces),
        )

        inv_before = self.invariants(mesh)
        inv_after = self.invariants(new_mesh)

        defects_before = self._angle_defects(mesh)
        defects_after = self._angle_defects(new_mesh)

        changed_vertices = []
        for v in range(len(mesh.vertices)):
            if abs(defects_before.get(v, 0) - defects_after.get(v, 0)) > 1e-6:
                changed_vertices.append(v)
        changed_vertices.append(new_v_idx)

        # local sum: defect change in subdivided face's three vertices + new vertex
        local_defect_sum_before = sum(defects_before[v] for v in f)
        local_defect_sum_after = (
            sum(defects_after[v] for v in f) + defects_after[new_v_idx]
        )

        trace = TransformTrace(
            operation_name="stellar_subdivision",
            operation_params={
                "face_index": face_idx,
                "face_vertices": list(f),
            },
            before_state={
                "n_vertices": len(mesh.vertices),
                "n_edges": inv_before["n_edges"],
                "n_faces": len(mesh.faces),
                "euler_characteristic": inv_before["euler_characteristic"],
                "total_curvature": inv_before["total_curvature"],
                "gauss_bonnet_ratio": inv_before["gauss_bonnet_ratio"],
            },
            after_state={
                "n_vertices": len(new_mesh.vertices),
                "n_edges": inv_after["n_edges"],
                "n_faces": len(new_mesh.faces),
                "euler_characteristic": inv_after["euler_characteristic"],
                "total_curvature": inv_after["total_curvature"],
                "gauss_bonnet_ratio": inv_after["gauss_bonnet_ratio"],
            },
            delta={
                "vertices_added": 1,
                "edges_added": 3,
                "faces_added": 2,
                "euler_change": inv_after["euler_characteristic"]
                                - inv_before["euler_characteristic"],
                "curvature_change": round(
                    inv_after["total_curvature"] - inv_before["total_curvature"], 6),
            },
            region_affected={
                "subdivided_face": list(f),
                "new_vertex_index": new_v_idx,
                "affected_vertices": changed_vertices,
                "new_vertex_defect": round(defects_after.get(new_v_idx, 0), 6),
                "local_defect_sum_before": round(local_defect_sum_before, 6),
                "local_defect_sum_after": round(local_defect_sum_after, 6),
                "local_defect_sum_preserved":
                    abs(local_defect_sum_before - local_defect_sum_after) < 1e-6,
            },
        )

        delta_inv = {}
        preserved = {}
        for k, v in inv_before.items():
            if isinstance(v, (int, float)) and not isinstance(v, bool):
                delta_inv[k] = round(inv_after[k] - inv_before[k], 6)
                preserved[k] = abs(inv_after[k] - inv_before[k]) < 1e-6
            else:
                delta_inv[k] = None
                preserved[k] = inv_before[k] == inv_after[k]

        return TransformResult(
            original_id=mesh.object_id,
            transformed_id=new_mesh.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta=delta_inv,
            invariants_preserved=preserved,
        )

    def _vertex_displacement(self, mesh: MeshObject, vertex_idx: int,
                             displacement) -> TransformResult:
        """Move one vertex. χ unchanged; total curvature unchanged; per-vertex
        defects shift but Σ stays at 2π χ."""
        new_verts = list(mesh.vertices)
        old_v = new_verts[vertex_idx]
        new_verts[vertex_idx] = tuple(a + d for a, d in zip(old_v, displacement))

        new_mesh = MeshObject(
            _object_id=f"{mesh.object_id}_disp_v{vertex_idx}",
            vertices=tuple(tuple(v) for v in new_verts),
            faces=mesh.faces,
        )

        inv_before = self.invariants(mesh)
        inv_after = self.invariants(new_mesh)

        defects_before = self._angle_defects(mesh)
        defects_after = self._angle_defects(new_mesh)

        affected = []
        for v in range(len(mesh.vertices)):
            if abs(defects_before[v] - defects_after[v]) > 1e-6:
                affected.append(v)

        trace = TransformTrace(
            operation_name="vertex_displacement",
            operation_params={
                "vertex": vertex_idx,
                "displacement": list(displacement),
            },
            before_state={
                "euler_characteristic": inv_before["euler_characteristic"],
                "total_curvature": inv_before["total_curvature"],
                "gauss_bonnet_ratio": inv_before["gauss_bonnet_ratio"],
                "vertex_defect": round(defects_before.get(vertex_idx, 0), 6),
            },
            after_state={
                "euler_characteristic": inv_after["euler_characteristic"],
                "total_curvature": inv_after["total_curvature"],
                "gauss_bonnet_ratio": inv_after["gauss_bonnet_ratio"],
                "vertex_defect": round(defects_after.get(vertex_idx, 0), 6),
            },
            delta={
                "euler_change": inv_after["euler_characteristic"]
                                - inv_before["euler_characteristic"],
                "curvature_change": round(
                    inv_after["total_curvature"] - inv_before["total_curvature"], 6),
                "local_defect_change": round(
                    defects_after.get(vertex_idx, 0)
                    - defects_before.get(vertex_idx, 0), 6),
            },
            region_affected={
                "displaced_vertex": vertex_idx,
                "neighbor_faces": [
                    i for i, f in enumerate(mesh.faces) if vertex_idx in f
                ],
                "affected_vertices": affected,
                "n_vertices_total": len(mesh.vertices),
            },
        )

        delta_inv = {}
        preserved = {}
        for k, v in inv_before.items():
            if isinstance(v, (int, float)) and not isinstance(v, bool):
                delta_inv[k] = round(inv_after[k] - inv_before[k], 6)
                preserved[k] = abs(inv_after[k] - inv_before[k]) < 1e-6
            else:
                delta_inv[k] = None
                preserved[k] = inv_before[k] == inv_after[k]

        return TransformResult(
            original_id=mesh.object_id,
            transformed_id=new_mesh.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta=delta_inv,
            invariants_preserved=preserved,
        )

    # ---- invariants ----

    def invariants(self, obj: MeshObject) -> dict:
        chi = self._euler_characteristic(obj)
        defects = self._angle_defects(obj)
        total = sum(defects.values())
        return {
            "euler_characteristic": chi,
            "total_curvature": round(total, 6),
            "gauss_bonnet_ratio": round(total / (2 * math.pi), 6),
            "n_vertices": len(obj.vertices),
            "n_edges": len(self._edges(obj)),
            "n_faces": len(obj.faces),
            "genus": max(0, (2 - chi) // 2) if chi <= 2 else 0,
        }

    # ---- compare ----

    def compare(self, obj_a: MeshObject, obj_b: MeshObject,
                transformed_a: MeshObject,
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

        if detail_level >= 2:
            defects_pre = self._angle_defects(obj_a)
            defects_post = self._angle_defects(transformed_a)
            n_pre = len(obj_a.vertices)
            n_post = len(transformed_a.vertices)
            common = min(n_pre, n_post)
            per_vertex_changes = {}
            for v in range(common):
                d_pre = defects_pre.get(v, 0)
                d_post = defects_post.get(v, 0)
                if abs(d_pre - d_post) > 1e-6:
                    per_vertex_changes[str(v)] = {
                        "pre": round(d_pre, 6),
                        "post": round(d_post, 6),
                        "delta": round(d_post - d_pre, 6),
                    }
            new_defects = {}
            for v in range(n_pre, n_post):
                new_defects[str(v)] = round(defects_post.get(v, 0), 6)

            cmp.detailed_comparison = {
                "n_vertices_pre": n_pre,
                "n_vertices_post": n_post,
                "n_faces_pre": len(obj_a.faces),
                "n_faces_post": len(transformed_a.faces),
                "n_edges_pre": len(self._edges(obj_a)),
                "n_edges_post": len(self._edges(transformed_a)),
                "vertex_defects_changed": per_vertex_changes,
                "n_vertices_with_changed_defect": len(per_vertex_changes),
                "new_vertex_defects": new_defects,
                "sum_of_vertex_changes": round(
                    sum(c["delta"] for c in per_vertex_changes.values()), 6),
                "sum_of_new_vertex_defects": round(
                    sum(new_defects.values()), 6),
                "total_curvature_pre": round(sum(defects_pre.values()), 6),
                "total_curvature_post": round(sum(defects_post.values()), 6),
                "total_curvature_preserved":
                    abs(sum(defects_pre.values()) - sum(defects_post.values()))
                    < 1e-6,
            }

        if detail_level >= 3:
            cmp.reference_in_transform_region = {
                **transform_result.trace.region_affected,
                "operation_name": transform_result.trace.operation_name,
            }

        if detail_level >= 4:
            cmp.structural_comparison = {
                "curvature_types_pre": pre.structural.get("curvature_types_a", {}),
                "curvature_types_post": post.structural.get("curvature_types_a", {}),
                "genus_pre": pre.structural.get("genus_a", 0),
                "genus_post": post.structural.get("genus_a", 0),
                "euler_pre": pre.summary["euler_characteristic_a"],
                "euler_post": post.summary["euler_characteristic_a"],
                "euler_preserved":
                    pre.summary["euler_characteristic_a"]
                    == post.summary["euler_characteristic_a"],
                "total_curvature_pre": pre.summary["total_curvature_a"],
                "total_curvature_post": post.summary["total_curvature_a"],
                "total_curvature_preserved":
                    abs(pre.summary["total_curvature_a"]
                        - post.summary["total_curvature_a"]) < 1e-6,
                "gauss_bonnet_ratio_pre": pre.summary["gauss_bonnet_ratio_a"],
                "gauss_bonnet_ratio_post": post.summary["gauss_bonnet_ratio_a"],
                "all_global_invariants_preserved": (
                    pre.summary["euler_characteristic_a"]
                    == post.summary["euler_characteristic_a"]
                    and abs(pre.summary["total_curvature_a"]
                            - post.summary["total_curvature_a"]) < 1e-6
                ),
            }
        return cmp


if __name__ == "__main__":
    e = DiscreteCurvatureEngine()

    print("=== Preset polyhedra (Gauss-Bonnet check) ===")
    for name in ["tetrahedron", "cube_triangulated", "octahedron", "icosahedron"]:
        mesh = e.construct({"type": name})
        inv = e.invariants(mesh)
        print(f"  {name}: V={inv['n_vertices']} E={inv['n_edges']} "
              f"F={inv['n_faces']} chi={inv['euler_characteristic']} "
              f"total/(2pi)={inv['gauss_bonnet_ratio']}")

    print("\n=== stellar_subdivision on tetrahedron face 0 ===")
    tet = e.construct({"type": "tetrahedron"})
    tr = e.transform(tet, {"type": "stellar_subdivision", "face": 0})
    b, a = tr.invariants_before, tr.invariants_after
    print(f"  V: {b['n_vertices']} -> {a['n_vertices']}")
    print(f"  E: {b['n_edges']} -> {a['n_edges']}")
    print(f"  F: {b['n_faces']} -> {a['n_faces']}")
    print(f"  chi: {b['euler_characteristic']} -> {a['euler_characteristic']}")
    print(f"  total/(2pi): {b['gauss_bonnet_ratio']} -> {a['gauss_bonnet_ratio']}")
    print(f"  invariants_preserved: {tr.invariants_preserved}")

    print("\n=== vertex_displacement on tetrahedron vertex 0 ===")
    tr2 = e.transform(tet, {"type": "vertex_displacement",
                            "vertex": 0,
                            "displacement": (0.3, -0.1, 0.2)})
    b, a = tr2.invariants_before, tr2.invariants_after
    print(f"  chi: {b['euler_characteristic']} -> {a['euler_characteristic']}")
    print(f"  total/(2pi): {b['gauss_bonnet_ratio']} -> {a['gauss_bonnet_ratio']}")
    print(f"  local defect change: {tr2.trace.delta['local_defect_change']}")
    print(f"  invariants_preserved: {tr2.invariants_preserved}")

    print("\n=== compare(tet_subdivided, cube) ===")
    cube = e.construct({"type": "cube_triangulated"})
    tet_subdiv = MeshObject(
        _object_id=tr.transformed_id,
        vertices=tuple(tuple(v) for v in
                       list(tet.vertices) +
                       [tuple((tet.vertices[tet.faces[0][0]][i]
                               + tet.vertices[tet.faces[0][1]][i]
                               + tet.vertices[tet.faces[0][2]][i]) / 3
                              for i in range(3))]),
        faces=tuple(tuple(f) for f in
                    [fa for i, fa in enumerate(tet.faces) if i != 0] +
                    [(tet.faces[0][0], tet.faces[0][1], len(tet.vertices)),
                     (tet.faces[0][1], tet.faces[0][2], len(tet.vertices)),
                     (tet.faces[0][2], tet.faces[0][0], len(tet.vertices))]),
    )
    cmp = e.compare(tet, cube, tet_subdiv, tr, detail_level=4)
    print(f"  summary_delta: {cmp.summary_delta}")
    print(f"  euler_preserved: {cmp.structural_comparison['euler_preserved']}")
    print(f"  total_curvature_preserved: "
          f"{cmp.structural_comparison['total_curvature_preserved']}")
