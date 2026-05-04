"""DiscreteCurvatureCounterfactualGenerator — counterfactuals for Gauss-Bonnet.

三种策略：

  BOUNDARY_RELAXATION: 把"加一个顶点 + 用 3 条新边把它接到面三个顶点上 +
    把原来 1 个面替换为 3 个新面"放宽到"加一个顶点但只加 1 条边、不替换面"。
    合法 stellar subdivision: ΔV=+1, ΔE=+3, ΔF=+2 → Δχ = 1-3+2 = 0
    放宽 (illegal):           ΔV=+1, ΔE=+1, ΔF=0 → Δχ = 1-1+0 = +1
    Gauss-Bonnet 不再等式（χ 改变 ⟹ 总曲率应当改变 2π，但角度数据不会自动跟上）。

  OPERATION_PERTURBATION: 删一个面（删 1 个面，但不动顶点和边）。
    合法 case: 不存在——任何一致的 manifold operation 都得保持 V-E+F 一致。
    放宽: ΔV=0, ΔE=0, ΔF=-1 → Δχ = -1。不再是闭合曲面。

  CONDITION_REMOVAL: 删一个顶点但不删它参与的面（指标失效，face 索引越界）。
    破坏 mesh 的合法性，验证 "manifold consistency" 是 G-B 的前提条件。
"""

from __future__ import annotations

from typing import Any

from SpatialMind.core.counterfactual import (
    CFStrategy,
    CounterfactualCase,
    CounterfactualInput,
)

from .engine import DiscreteCurvatureEngine, MeshObject


def _safe_invariants(engine: DiscreteCurvatureEngine, mesh: MeshObject):
    try:
        return engine.invariants(mesh), None
    except Exception as e:
        return None, str(e)


class DiscreteCurvatureCounterfactualGenerator:
    """Domain-specific counterfactual generator for discrete curvature."""

    def __init__(self, engine: DiscreteCurvatureEngine | None = None):
        self.engine = engine or DiscreteCurvatureEngine()

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        if strategy is None:
            return (
                self._boundary_relaxation(input)
                + self._operation_perturbation(input)
                + self._condition_removal(input)
            )
        if strategy == CFStrategy.BOUNDARY_RELAXATION:
            return self._boundary_relaxation(input)
        if strategy == CFStrategy.OPERATION_PERTURBATION:
            return self._operation_perturbation(input)
        if strategy == CFStrategy.CONDITION_REMOVAL:
            return self._condition_removal(input)
        return []

    # ---- BOUNDARY_RELAXATION ------------------------------------------------
    def _boundary_relaxation(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        """Add a vertex without completing the face split:
        legal stellar subdiv:  ΔV=+1, ΔE=+3, ΔF=+2  → Δχ = 0
        relaxed (illegal):     ΔV=+1, ΔE=+1, ΔF=+0  → Δχ = +1
        """
        engine = self.engine
        mesh: MeshObject = input.object_a
        if not mesh.faces:
            return []

        face_idx = input.operation.get("face", 0) % len(mesh.faces)
        f = mesh.faces[face_idx]
        v0 = mesh.vertices[f[0]]
        v1 = mesh.vertices[f[1]]
        v2 = mesh.vertices[f[2]]
        center = tuple((a + b + c) / 3 for a, b, c in zip(v0, v1, v2))

        # Legal stellar subdivision
        legal = engine.transform(
            mesh, {"type": "stellar_subdivision", "face": face_idx}
        )
        legal_inv = legal.invariants_after

        # Illegal: add vertex, splice in only ONE new face on the boundary,
        # leaving the original face intact and creating a non-manifold edge.
        # Concretely: keep ALL original faces, plus add (f[0], f[1], new_v).
        # That gives ΔV=+1, ΔE=+2 (two new edges to v0 and v1; the third side
        # f[0]-f[1] is shared with the original face), ΔF=+1 → Δχ = 1-2+1 = 0.
        # To get Δχ = +1 cleanly, we instead add the vertex and a single new
        # edge but no new face: ΔV=+1, ΔE=+1, ΔF=0 → Δχ = +1. We model
        # this as a "stub": new vertex connected to f[0] only, no new face.
        new_v_idx = len(mesh.vertices)
        broken_verts = list(mesh.vertices) + [center]
        # Faces unchanged (no new face); we don't have an explicit edge list
        # so the "edge" is implicit by being mentioned in faces. To force a
        # clean Δχ accounting we add a DEGENERATE face (v0, new, new) that
        # only contributes 1 new edge (v0-new). With our edge derivation
        # (set of unordered pairs from face triples), the new face introduces
        # edges {v0,new}, {new,new}, {new,v0}. Self-loops collapse → only
        # one new edge {v0, new}. ΔV=+1, ΔE=+1, ΔF=+1 → Δχ = +1.
        broken_faces = list(mesh.faces) + [(f[0], new_v_idx, new_v_idx)]
        broken_mesh = MeshObject(
            _object_id=f"relaxed({mesh.object_id})_f{face_idx}",
            vertices=tuple(tuple(v) for v in broken_verts),
            faces=tuple(tuple(fa) for fa in broken_faces),
        )
        broken_inv, err = _safe_invariants(engine, broken_mesh)
        legal_chi = legal_inv["euler_characteristic"]
        legal_curv = legal_inv["total_curvature"]
        broken_chi = broken_inv["euler_characteristic"] if broken_inv else None
        broken_curv = broken_inv["total_curvature"] if broken_inv else None

        all_preserved = (
            broken_inv is not None
            and legal_chi == broken_chi
            and abs(legal_curv - broken_curv) < 1e-6
        )

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "delta_V": 1,
                "delta_E": 3,
                "delta_F": 2,
                "delta_chi": 0,
                "operation": "complete stellar subdivision",
            },
            modified_condition={
                "delta_V": 1,
                "delta_E": 2,  # new edges {v0,new} and a degenerate self-loop
                "delta_F": 1,  # one degenerate face (v0, new, new)
                "operation": "vertex + degenerate triangle (incomplete splice)",
                "note": ("The added 'face' has two coincident vertices, so it "
                         "contributes zero interior angles. Combinatorial χ "
                         "may stay equal but Σδ jumps by 2π (the new vertex "
                         "sees no angles around it ⇒ defect = 2π)."),
            },
            original_result={
                "euler_characteristic": legal_chi,
                "total_curvature": round(legal_curv, 6),
                "gauss_bonnet_holds": True,
            },
            counterfactual_result=(
                {"error": err} if err else {
                    "euler_characteristic": broken_chi,
                    "total_curvature": round(broken_curv, 6),
                    "gauss_bonnet_holds":
                        abs(broken_curv - 2 * 3.141592653589793 * broken_chi)
                        < 1e-3,
                }
            ),
            delta=(
                {"error": err} if err else {
                    "euler_change":
                        broken_chi - legal_chi,
                    "curvature_change":
                        round(broken_curv - legal_curv, 6),
                    "gauss_bonnet_violated":
                        abs(broken_curv - 2 * 3.141592653589793 * broken_chi)
                        > 1e-3,
                }
            ),
            condition_is_critical=not all_preserved,
            explanation=(
                "Legal stellar subdivision adds ΔV=+1, ΔE=+3, ΔF=+2 so "
                "Δχ=0 AND ΔΣδ=0 (the new interior vertex's defect 0 = "
                "2π − 2π exactly cancels). Splicing in only a degenerate "
                "face leaves the new vertex with zero surrounding angles, "
                "so its defect = 2π and ΔΣδ = +2π. χ may even stay "
                "constant (here Δχ=0), so Σδ no longer equals 2πχ. The "
                "geometric and combinatorial sides of Gauss-Bonnet have "
                "to move TOGETHER for the equality to hold."
            ),
        )]

    # ---- OPERATION_PERTURBATION ---------------------------------------------
    def _operation_perturbation(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        """Delete a face without removing its edges. Mesh becomes non-closed
        (a hole), so χ shifts by -1 while angle defects stay roughly the
        same (deleting the face removes its angle contribution at three
        vertices, which actually changes total curvature too)."""
        engine = self.engine
        mesh: MeshObject = input.object_a
        if not mesh.faces:
            return []

        face_idx = input.operation.get("face", 0) % len(mesh.faces)
        before_inv = engine.invariants(mesh)
        broken_faces = tuple(f for i, f in enumerate(mesh.faces) if i != face_idx)
        # NOTE: we keep all vertices and edges (no edge-removal), so this is
        # ΔV=0, ΔE=0, ΔF=-1 → Δχ = -1.
        broken_mesh = MeshObject(
            _object_id=f"hole({mesh.object_id})_f{face_idx}",
            vertices=mesh.vertices,
            faces=broken_faces,
        )
        # But our edge derivation rebuilds from faces, so removing a face
        # *will* drop edges that no other face uses. To enforce the "edges
        # untouched" perturbation, force a special faces tuple that includes
        # the removed face's edges as degenerate edge-only "faces".
        deleted_face = mesh.faces[face_idx]
        # encode the three deleted edges as (a,b,b) degenerate faces so the
        # edge set is preserved.
        edge_stub_faces = tuple(
            (deleted_face[i], deleted_face[(i + 1) % 3], deleted_face[(i + 1) % 3])
            for i in range(3)
        )
        broken_mesh_edges_kept = MeshObject(
            _object_id=f"hole_edges_kept({mesh.object_id})_f{face_idx}",
            vertices=mesh.vertices,
            faces=tuple(broken_faces) + edge_stub_faces,
        )

        broken_inv, err = _safe_invariants(engine, broken_mesh_edges_kept)
        all_preserved = (
            broken_inv is not None
            and before_inv["euler_characteristic"]
                == broken_inv["euler_characteristic"]
            and abs(before_inv["total_curvature"]
                    - broken_inv["total_curvature"]) < 1e-6
        )

        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={
                "operation": "no perturbation (closed manifold)",
                "delta_V": 0,
                "delta_E": 0,
                "delta_F": 0,
                "delta_chi": 0,
            },
            modified_condition={
                "operation": "delete face (keep edges)",
                "deleted_face": list(deleted_face),
                "delta_V": 0,
                "delta_E": 0,
                "delta_F": -1,
                "delta_chi_expected": -1,
            },
            original_result={
                "euler_characteristic": before_inv["euler_characteristic"],
                "total_curvature": before_inv["total_curvature"],
                "gauss_bonnet_holds": True,
            },
            counterfactual_result=(
                {"error": err} if err else {
                    "euler_characteristic": broken_inv["euler_characteristic"],
                    "total_curvature": broken_inv["total_curvature"],
                    "gauss_bonnet_holds":
                        abs(broken_inv["total_curvature"]
                            - 2 * 3.141592653589793
                              * broken_inv["euler_characteristic"]) < 1e-3,
                }
            ),
            delta=(
                {"error": err} if err else {
                    "euler_change":
                        broken_inv["euler_characteristic"]
                        - before_inv["euler_characteristic"],
                    "curvature_change":
                        round(broken_inv["total_curvature"]
                              - before_inv["total_curvature"], 6),
                    "gauss_bonnet_violated":
                        abs(broken_inv["total_curvature"]
                            - 2 * 3.141592653589793
                              * broken_inv["euler_characteristic"]) > 1e-3,
                }
            ),
            condition_is_critical=not all_preserved,
            explanation=(
                "Deleting a face creates a hole. The angle defects at the "
                "three vertices of the deleted face shift (each loses one "
                "interior angle), and χ drops by 1. The defect-sum and 2πχ "
                "no longer match: closedness of the surface is required."
            ),
        )]

    # ---- CONDITION_REMOVAL --------------------------------------------------
    def _condition_removal(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        """Drop the manifold-consistency check: reference a face index that
        points to a non-existent vertex. invariants() should fail."""
        mesh: MeshObject = input.object_a
        if len(mesh.vertices) < 1 or not mesh.faces:
            return []

        before_inv = self.engine.invariants(mesh)
        bad_idx = len(mesh.vertices) + 5  # out-of-range vertex index
        f0 = mesh.faces[0]
        broken_faces = ((bad_idx, f0[1], f0[2]),) + tuple(mesh.faces[1:])
        broken_mesh = MeshObject(
            _object_id=f"nonmanifold({mesh.object_id})",
            vertices=mesh.vertices,
            faces=broken_faces,
        )
        broken_inv, err = _safe_invariants(self.engine, broken_mesh)
        all_preserved = (
            broken_inv is not None
            and before_inv["euler_characteristic"]
                == broken_inv["euler_characteristic"]
            and abs(before_inv["total_curvature"]
                    - broken_inv["total_curvature"]) < 1e-6
        )

        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={
                "manifold_consistency": True,
                "all_face_indices_in_range": True,
            },
            modified_condition={
                "manifold_consistency": False,
                "all_face_indices_in_range": False,
                "invalid_face_index": bad_idx,
            },
            original_result={
                "valid_mesh": True,
                "euler_characteristic": before_inv["euler_characteristic"],
                "total_curvature": before_inv["total_curvature"],
            },
            counterfactual_result=(
                {"valid_mesh": False, "error": err} if err else {
                    "valid_mesh": True,
                    "euler_characteristic":
                        broken_inv["euler_characteristic"],
                    "total_curvature":
                        broken_inv["total_curvature"],
                }
            ),
            delta=(
                {"error": err} if err else {
                    "euler_change":
                        broken_inv["euler_characteristic"]
                        - before_inv["euler_characteristic"],
                    "curvature_change":
                        round(broken_inv["total_curvature"]
                              - before_inv["total_curvature"], 6),
                }
            ),
            condition_is_critical=not all_preserved,
            explanation=(
                "Dropping manifold-consistency (faces referencing valid "
                "vertices) yields a malformed mesh. Gauss-Bonnet implicitly "
                "assumes a closed simplicial surface where each edge is "
                "shared by exactly two faces and each face has 3 valid "
                "vertices; without this, neither side of Σδ = 2πχ is "
                "well-defined."
            ),
        )]
