"""Generate the ~100-case benchmark dataset for discrete_curvature.

4 preset polyhedra × (5 stellar_subdivisions + 5 vertex_displacements) = 40
intra-mesh transform cases.
+ All ordered (a,b) pairs of (preset, transformed) for cross-relate Level-1 data
  — captured implicitly via the comparison.pre / comparison.post (which already
  hold the b-side data via relate(a,b)).
+ Explicit cross-pair "comparison-only" cases between distinct preset polyhedra
  (no transform applied) to exercise local-to-global pattern across topologies.

We emit:
- 40 transform ExperimentCases (object_a transforms; object_b held as a fixed
  reference polyhedron from a different preset)
- 60 cross-pair "no-op transform" cases (object_a = preset_i, object_b =
  preset_j ≠ i; transform = identity stellar_subdivision applied to a tiny
  copy so the framework's compare() still has data to populate).

Counterfactual: 3 strategies × 1 representative mesh (tetrahedron) = 3 critical
cases, mirroring knot_theory.

Output: SpatialMind/benchmarks/discrete_curvature/level_{1..5}.json
"""

from __future__ import annotations

import json
import random
import sys
import time
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MATH_ROOT = ROOT.parent
for p in (str(ROOT), str(MATH_ROOT)):
    if p not in sys.path:
        sys.path.insert(0, p)

from SpatialMind.core.benchmark import ExperimentCase, build_benchmark_suite
from SpatialMind.core.counterfactual import CounterfactualInput
from SpatialMind.domains.discrete_curvature.counterfactual import (
    DiscreteCurvatureCounterfactualGenerator,
)
from SpatialMind.domains.discrete_curvature.engine import (
    DiscreteCurvatureEngine,
    MeshObject,
)

PRESETS = ["tetrahedron", "cube_triangulated", "octahedron", "icosahedron"]
N_SUBDIV = 5     # 5 stellar subdivisions per preset (face indices 0..4)
N_DISP = 5       # 5 vertex displacements per preset (vertex indices 0..4)
SEED = 2026


def _build_subdivided_mesh(engine: DiscreteCurvatureEngine,
                           mesh: MeshObject, face_idx: int,
                           transformed_id: str) -> MeshObject:
    """Reconstruct the post-stellar-subdivision mesh as a MeshObject."""
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
    return MeshObject(
        _object_id=transformed_id,
        vertices=tuple(tuple(v) for v in new_verts),
        faces=tuple(tuple(fa) for fa in new_faces),
    )


def _build_displaced_mesh(mesh: MeshObject, vertex_idx: int,
                          displacement, transformed_id: str) -> MeshObject:
    new_verts = list(mesh.vertices)
    old_v = new_verts[vertex_idx]
    new_verts[vertex_idx] = tuple(a + d for a, d in zip(old_v, displacement))
    return MeshObject(
        _object_id=transformed_id,
        vertices=tuple(tuple(v) for v in new_verts),
        faces=mesh.faces,
    )


def main():
    random.seed(SEED)
    engine = DiscreteCurvatureEngine()

    presets = {name: engine.construct({"type": name}) for name in PRESETS}

    all_cases: list[ExperimentCase] = []
    n_invariants_violated = 0
    t0 = time.time()

    # ---- 40 transform cases (each transformed against a fixed reference) ----
    # Pair each preset with the next one as the cross-mesh "reference β".
    refs = {
        "tetrahedron":       presets["cube_triangulated"],
        "cube_triangulated": presets["octahedron"],
        "octahedron":        presets["icosahedron"],
        "icosahedron":       presets["tetrahedron"],
    }

    for name in PRESETS:
        mesh = presets[name]
        ref = refs[name]
        n_faces = len(mesh.faces)
        n_verts = len(mesh.vertices)

        # 5 stellar subdivisions on faces 0..4
        for k in range(N_SUBDIV):
            face_idx = k % n_faces
            tr = engine.transform(mesh, {"type": "stellar_subdivision",
                                         "face": face_idx})
            transformed = _build_subdivided_mesh(
                engine, mesh, face_idx, tr.transformed_id)
            cmp = engine.compare(mesh, ref, transformed, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{name}-subdiv-f{face_idx}-{k}",
                object_a_id=mesh.object_id,
                object_b_id=ref.object_id,
                transformed_a_id=transformed.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": name,
                    "operation": "stellar_subdivision",
                    "face_index": face_idx,
                    "ref_preset": ref.object_id,
                    "kind": "intra_transform",
                },
            )
            all_cases.append(ec)
            if not cmp.structural_comparison["all_global_invariants_preserved"]:
                n_invariants_violated += 1

        # 5 vertex displacements on vertices 0..4
        for k in range(N_DISP):
            vert_idx = k % n_verts
            disp = (random.uniform(-0.3, 0.3),
                    random.uniform(-0.3, 0.3),
                    random.uniform(-0.3, 0.3))
            tr = engine.transform(mesh, {"type": "vertex_displacement",
                                         "vertex": vert_idx,
                                         "displacement": disp})
            transformed = _build_displaced_mesh(
                mesh, vert_idx, disp, tr.transformed_id)
            cmp = engine.compare(mesh, ref, transformed, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{name}-disp-v{vert_idx}-{k}",
                object_a_id=mesh.object_id,
                object_b_id=ref.object_id,
                transformed_a_id=transformed.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "preset": name,
                    "operation": "vertex_displacement",
                    "vertex_index": vert_idx,
                    "displacement": list(disp),
                    "ref_preset": ref.object_id,
                    "kind": "intra_transform",
                },
            )
            all_cases.append(ec)
            if not cmp.structural_comparison["all_global_invariants_preserved"]:
                n_invariants_violated += 1

        print(f"  {name}: {N_SUBDIV} subdiv + {N_DISP} disp cases done")

    # ---- 60 cross-pair relate-only cases -----------------------------------
    # Identity-like transform: stellar subdivision on face 0, but we keep
    # the cross-pair object_b distinct so summary_delta exercises cross-mesh
    # comparison structure. Use 4×3=12 ordered distinct preset pairs × 5 face
    # indices = 60 cases.
    for name_a in PRESETS:
        mesh_a = presets[name_a]
        n_faces = len(mesh_a.faces)
        for name_b in PRESETS:
            if name_b == name_a:
                continue
            mesh_b = presets[name_b]
            for k in range(5):
                face_idx = k % n_faces
                tr = engine.transform(mesh_a, {"type": "stellar_subdivision",
                                               "face": face_idx})
                transformed = _build_subdivided_mesh(
                    engine, mesh_a, face_idx, tr.transformed_id)
                cmp = engine.compare(mesh_a, mesh_b, transformed, tr,
                                     detail_level=4)
                ec = ExperimentCase(
                    case_id=f"cross-{name_a}-vs-{name_b}-f{face_idx}-{k}",
                    object_a_id=mesh_a.object_id,
                    object_b_id=mesh_b.object_id,
                    transformed_a_id=transformed.object_id,
                    transform_result=tr,
                    comparison=cmp,
                    metadata={
                        "preset_a": name_a,
                        "preset_b": name_b,
                        "operation": "stellar_subdivision",
                        "face_index": face_idx,
                        "kind": "cross_pair",
                    },
                )
                all_cases.append(ec)
                if not cmp.structural_comparison["all_global_invariants_preserved"]:
                    n_invariants_violated += 1

    t1 = time.time()
    print(f"\nTotal: {len(all_cases)} cases in {t1 - t0:.1f}s")
    print(f"  G-B violations among positive cases: {n_invariants_violated}")

    # ---- Counterfactual on tetrahedron ----
    cf_gen = DiscreteCurvatureCounterfactualGenerator(engine=engine)
    K_ref = engine.construct({"type": "tetrahedron"})
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine, object_a=K_ref, object_b=K_ref,
        operation={"type": "stellar_subdivision", "face": 0},
        conditions={},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ---- Build & save ----
    suite = build_benchmark_suite("discrete_curvature", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "discrete_curvature"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ---- Quick stats ----
    eulers = Counter()
    curvs = Counter()
    for ec in all_cases:
        sc = ec.comparison.structural_comparison
        eulers[(sc["euler_pre"], sc["euler_post"])] += 1
        curvs[(round(sc["total_curvature_pre"], 3),
               round(sc["total_curvature_post"], 3))] += 1
    print(f"\nEuler (pre, post) histogram: {dict(eulers.most_common(5))}")
    print(f"Total curvature (pre, post) histogram: "
          f"{dict(curvs.most_common(5))}")
    op_dist = Counter(ec.metadata["operation"] for ec in all_cases)
    print(f"Operation distribution: {dict(op_dist)}")
    kind_dist = Counter(ec.metadata["kind"] for ec in all_cases)
    print(f"Kind distribution: {dict(kind_dist)}")


if __name__ == "__main__":
    main()
