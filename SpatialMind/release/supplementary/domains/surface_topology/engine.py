"""Surface topology engine — wraps curver for the SpatialMind framework.

Implements GeometricEngine for curves on surfaces S_{g,n}.

Migrated from workspace/projects/op1_geometry/{rich_geometry.py,surface_geo.py}.

construct(spec) → SurfaceCurve
  spec accepts one of:
    {"surface": [g, n], "curve_name": "a_0"}      — named curver curve
    {"surface": [g, n], "curve_index": int,
                        "database_path": str}     — curve by db index
    {"surface": [g, n], "weights": [w_0, ...],
                        "object_id": str}         — explicit lamination weights
    {"surface": [g, n], "lamination": <curver>,
                        "object_id": str}         — pass an existing lamination

relate(curve_a, curve_b, detail_level) → RelationData
  level 1: intersection number
  level 2: + per-crossing triangle locations (normal-arc decomposition)
  level 3: + bigon detection

transform(curve, operation) → TransformResult
  operation = {"type": "hatcher_surgery",
               "gamma0": <object_id or "a_0">,
               "sigma_index": int (optional)}
  trace contains: surgery_region_triangles, short/long arc triangles,
  surgery_region_punctures, alpha-gamma crossing locations.

invariants(curve) → {"level", "weight", ...}
"""

from __future__ import annotations

import json
import os
from collections import defaultdict
from dataclasses import dataclass, field
from itertools import combinations
from typing import Any, Iterable

try:
    import curver  # type: ignore
    _HAS_CURVER = True
except Exception:
    curver = None  # type: ignore
    _HAS_CURVER = False

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformTrace, TransformResult
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


# ============================================================================
# Internal helpers (migrated from surface_geo._passage_counts /
# rich_geometry helpers).
# ============================================================================

def _passage_counts(weights: Iterable[int],
                    triangle: tuple[int, int, int]) -> dict:
    """Bonahon train-track passage counts in one triangle.

    n_{ij} = max(0, (w_i + w_j - w_k) // 2). Returns dict keyed by sorted
    pair (i,j) with i < j.
    """
    wl = list(weights)
    a, b, c = triangle
    w_a, w_b, w_c = wl[a], wl[b], wl[c]
    return {
        tuple(sorted((a, b))): max(0, (w_a + w_b - w_c) // 2),
        tuple(sorted((b, c))): max(0, (w_b + w_c - w_a) // 2),
        tuple(sorted((c, a))): max(0, (w_c + w_a - w_b) // 2),
    }


def _vertex_index_table(S) -> dict:
    T = S.triangulation
    verts = list(T.vertices)
    verts_sorted = sorted(verts, key=lambda cyc: min(cyc))
    label_to_vidx: dict = {}
    for vidx, cyc in enumerate(verts_sorted):
        for lbl in cyc:
            label_to_vidx[lbl] = vidx
    return label_to_vidx


# ============================================================================
# SurfaceCurve — the GeometricObject.
# ============================================================================

@dataclass
class SurfaceCurve:
    """A curve on a surface S_{g,n}, represented as a curver lamination."""
    _object_id: str
    weights: tuple[int, ...]
    surface: tuple[int, int]            # (g, n)
    _lamination: Any = field(default=None, repr=False)

    @property
    def object_id(self) -> str:
        return self._object_id

    def to_json(self) -> dict:
        return {
            "object_id": self._object_id,
            "weights": list(self.weights),
            "surface": list(self.surface),
        }


# ============================================================================
# Engine.
# ============================================================================

class SurfaceEngine:
    """Implements GeometricEngine for curves on a single surface S_{g,n}."""

    def __init__(self, g: int, n: int, database_path: str | None = None):
        if not _HAS_CURVER:
            raise RuntimeError("SurfaceEngine requires the `curver` package")
        self.g = g
        self.n = n
        self.S = curver.load(g, n)
        self._tri_indices = [tuple(tri.indices) for tri in self.S.triangulation]
        self._vertex_table = _vertex_index_table(self.S)
        self._db: dict | None = None
        if database_path:
            self.attach_database(database_path)

    # ---------------- protocol surface ----------------

    @property
    def domain_name(self) -> str:
        return "surface_topology"

    def attach_database(self, path: str) -> None:
        with open(path) as f:
            d = json.load(f)
        hashes = [tuple(h) for h in d["curves"]]
        curves = [self.S.lamination(list(h)) for h in hashes]
        self._db = {
            "hashes": hashes,
            "curves": curves,
            "data": d,
        }

    # ---------------- construct ----------------

    def construct(self, spec: dict) -> SurfaceCurve:
        surface = tuple(spec.get("surface", (self.g, self.n)))
        if surface != (self.g, self.n):
            raise ValueError(
                f"engine bound to S_{{{self.g},{self.n}}} but spec surface={surface}")

        if "curve_name" in spec:
            name = spec["curve_name"]
            if name == "gamma0":
                name = "a_0"  # OP-1 convention
            if name not in self.S.curves:
                raise KeyError(f"no named curve {name!r} on S_{{{self.g},{self.n}}}")
            lam = self.S.curves[name]
            return SurfaceCurve(
                _object_id=name,
                weights=tuple(int(w) for w in tuple(lam)),
                surface=surface,
                _lamination=lam,
            )

        if "lamination" in spec:
            lam = spec["lamination"]
            return SurfaceCurve(
                _object_id=spec.get("object_id", "lam"),
                weights=tuple(int(w) for w in tuple(lam)),
                surface=surface,
                _lamination=lam,
            )

        if "weights" in spec:
            ws = list(spec["weights"])
            lam = self.S.lamination(ws)
            return SurfaceCurve(
                _object_id=spec.get("object_id", f"w[{','.join(map(str, ws))}]"),
                weights=tuple(int(w) for w in tuple(lam)),
                surface=surface,
                _lamination=lam,
            )

        if "curve_index" in spec:
            db_path = spec.get("database_path")
            if self._db is None and db_path:
                self.attach_database(db_path)
            if self._db is None:
                raise RuntimeError(
                    "curve_index requires a curve database (pass database_path "
                    "in the spec or call engine.attach_database first)")
            idx = int(spec["curve_index"])
            lam = self._db["curves"][idx]
            return SurfaceCurve(
                _object_id=f"c{idx}",
                weights=tuple(int(w) for w in tuple(lam)),
                surface=surface,
                _lamination=lam,
            )

        raise ValueError(f"construct: unrecognised spec {spec!r}")

    # ---------------- relate ----------------

    def relate(self, obj_a: SurfaceCurve, obj_b: SurfaceCurve,
               detail_level: int = 1) -> RelationData:
        a_lam = self._lam(obj_a)
        b_lam = self._lam(obj_b)
        i_ab = int(a_lam.intersection(b_lam))

        rel = RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary={
                "intersection_number": i_ab,
                "weight_a": int(sum(obj_a.weights)),
                "weight_b": int(sum(obj_b.weights)),
            },
        )

        if detail_level <= 1:
            return rel

        # ---- level 2: per-triangle crossings + decompositions ----
        dec_a = self._decompose(obj_a)
        dec_b = self._decompose(obj_b)
        crossings = self._find_crossings(dec_a, dec_b)
        cand_total = sum(c["candidate_count"] for c in crossings)
        rel.detailed = {
            "crossings": crossings,
            "candidate_crossings_total": cand_total,
            "decomposition_a": dec_a,
            "decomposition_b": dec_b,
            "upper_bound_consistent": cand_total >= i_ab,
        }

        if detail_level == 2:
            return rel

        # ---- level 3: bigons + minimal-position flag ----
        bigons = self._detect_bigons(dec_a, dec_b, crossings)
        rel.structural = {
            "bigons": bigons,
            "n_bigons": len(bigons),
            "minimal_position": (i_ab == cand_total),
            "puncture_in_region": self._punctures_in_triangles(
                {c["triangle"] for c in crossings}),
        }
        return rel

    # ---------------- transform ----------------

    def transform(self, obj: SurfaceCurve, operation: dict,
                  **kwargs) -> TransformResult:
        op_type = operation.get("type")
        if op_type != "hatcher_surgery":
            raise NotImplementedError(f"transform op {op_type!r} not implemented")

        gamma0_ref = operation.get("gamma0", "a_0")
        gamma0_curve = self._resolve_curve_ref(gamma0_ref)

        # Resolve sigma. Two paths:
        # (a) explicit sigma_index in DB
        # (b) search the DB for a level-(k-2) candidate disjoint from alpha
        #     that is universal on the descending link of alpha.
        sigma_curve = None
        sigma_id = "sigma"
        if "sigma_index" in operation:
            if self._db is None:
                raise RuntimeError("sigma_index requires an attached database")
            idx = int(operation["sigma_index"])
            sigma_curve = self._db["curves"][idx]
            sigma_id = f"sigma_c{idx}"
        elif "sigma_lamination" in operation:
            sigma_curve = operation["sigma_lamination"]
            sigma_id = operation.get("sigma_id", "sigma")
        else:
            sigma_curve, sigma_idx = self._search_canonical_sigma(
                obj._lamination if obj._lamination is not None
                else self.S.lamination(list(obj.weights)),
                gamma0_curve,
            )
            if sigma_curve is None:
                raise RuntimeError(
                    "hatcher_surgery: could not find a canonical filler "
                    "(attach a database via attach_database to enable search)")
            sigma_id = f"sigma_c{sigma_idx}"

        sigma_obj = SurfaceCurve(
            _object_id=sigma_id,
            weights=tuple(int(w) for w in tuple(sigma_curve)),
            surface=(self.g, self.n),
            _lamination=sigma_curve,
        )

        # Build trace data.
        alpha_lam = self._lam(obj)
        di_ag = self._find_crossings(self._decompose(obj),
                                     self._decompose_lam(gamma0_curve, "gamma0"))
        region_tris = sorted({c["triangle"] for c in di_ag})

        dec_alpha = self._decompose(obj)
        dec_sigma = self._decompose(sigma_obj)
        cnt_alpha = self._per_triangle_arc_count(dec_alpha)
        cnt_sigma = self._per_triangle_arc_count(dec_sigma)
        short_tris, long_tris = [], []
        for tri_idx in range(len(self._tri_indices)):
            d = cnt_sigma.get(tri_idx, 0) - cnt_alpha.get(tri_idx, 0)
            if d < 0:
                short_tris.append(tri_idx)
            elif d > 0:
                long_tris.append(tri_idx)

        n_punctures = self._punctures_in_triangles(set(region_tris))

        trace = TransformTrace(
            operation_name="hatcher_surgery",
            operation_params={
                "gamma0_id": gamma0_ref if isinstance(gamma0_ref, str) else "<lam>",
                "alpha_id": obj.object_id,
                "sigma_id": sigma_id,
            },
            before_state={
                "alpha_weights": list(obj.weights),
                "level_alpha": int(alpha_lam.intersection(gamma0_curve)),
            },
            after_state={
                "sigma_weights": list(sigma_obj.weights),
                "level_sigma": int(sigma_curve.intersection(gamma0_curve)),
            },
            delta={
                "level_shift": int(sigma_curve.intersection(gamma0_curve))
                               - int(alpha_lam.intersection(gamma0_curve)),
                "weight_shift": int(sum(sigma_obj.weights) - sum(obj.weights)),
            },
            region_affected={
                "triangles": region_tris,
                "short_arc_triangles": short_tris,
                "long_arc_triangles": long_tris,
                "punctures_in_region": n_punctures,
                "alpha_gamma_crossings": di_ag,
            },
        )

        inv_before = self.invariants(obj)
        inv_after = self.invariants(sigma_obj)
        inv_delta = {k: inv_after.get(k, 0) - inv_before.get(k, 0)
                     for k in set(inv_before) | set(inv_after)
                     if isinstance(inv_before.get(k), (int, float))}
        inv_pres = {k: (inv_delta.get(k, 0) == 0)
                    for k in inv_delta
                    if isinstance(inv_before.get(k), (int, float))}

        return TransformResult(
            original_id=obj.object_id,
            transformed_id=sigma_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta=inv_delta,
            invariants_preserved=inv_pres,
        )

    # ---------------- compare ----------------

    def compare(
        self,
        obj_a: SurfaceCurve,
        obj_b: SurfaceCurve,
        transformed_a: SurfaceCurve,
        transform_result: TransformResult,
        detail_level: int = 4,
    ) -> RelationComparison:
        """Surface-topology specific comparison.

        Computes:
          - summary_delta (intersection number, weight)
          - detailed_comparison (crossings in/out of surgery region)
          - structural_comparison (bigons with/without puncture)
          - reference_in_transform_region (β triangles vs surgery region)
        """
        pre = self.relate(obj_a, obj_b, detail_level=3)
        post = self.relate(transformed_a, obj_b, detail_level=3)

        cmp_obj = RelationComparison(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            transformed_a_id=transformed_a.object_id,
            pre=pre,
            post=post,
            summary_delta=compute_summary_delta(pre, post),
            transform_trace=transform_result.trace.to_json(),
        )

        if detail_level <= 1:
            return cmp_obj

        region = set(transform_result.trace.region_affected.get("triangles", []))

        # ---- detailed_comparison ----
        pre_crossings = pre.detailed.get("crossings", [])
        post_crossings = post.detailed.get("crossings", [])
        pre_in = [c for c in pre_crossings if c["triangle"] in region]
        pre_out = [c for c in pre_crossings if c["triangle"] not in region]
        post_in = [c for c in post_crossings if c["triangle"] in region]
        post_out = [c for c in post_crossings if c["triangle"] not in region]
        cmp_obj.detailed_comparison = {
            "crossings_pre_count": len(pre_crossings),
            "crossings_post_count": len(post_crossings),
            "crossings_pre_candidate_total": pre.detailed.get("candidate_crossings_total", 0),
            "crossings_post_candidate_total": post.detailed.get("candidate_crossings_total", 0),
            "crossings_in_transform_region_pre": len(pre_in),
            "crossings_in_transform_region_post": len(post_in),
            "crossings_outside_region_pre": len(pre_out),
            "crossings_outside_region_post": len(post_out),
            "crossings_pre_locations": [
                {"triangle": c["triangle"], "shared_edge": c["shared_edge"]}
                for c in pre_crossings],
            "crossings_post_locations": [
                {"triangle": c["triangle"], "shared_edge": c["shared_edge"]}
                for c in post_crossings],
        }

        if detail_level <= 2:
            return cmp_obj

        # ---- reference_in_transform_region ----
        dec_b = self._decompose(obj_b)
        beta_tris = [tri_idx for tri_idx, idxs in
                     enumerate(dec_b["arcs_per_triangle"])
                     if any(dec_b["normal_arcs"][i]["multiplicity"] > 0
                            for i in idxs)]
        short_tris = set(transform_result.trace.region_affected.get(
            "short_arc_triangles", []))
        long_tris = set(transform_result.trace.region_affected.get(
            "long_arc_triangles", []))
        beta_set = set(beta_tris)
        cmp_obj.reference_in_transform_region = {
            "beta_triangles_total": len(beta_tris),
            "beta_triangles": sorted(beta_tris),
            "beta_triangles_in_region": len(beta_set & region),
            "beta_through_short_arc": len(beta_set & short_tris),
            "beta_through_long_arc": len(beta_set & long_tris),
        }

        if detail_level <= 3:
            return cmp_obj

        # ---- structural_comparison: bigons with/without puncture ----
        bigons_pre = pre.structural.get("bigons", [])
        bigons_post = post.structural.get("bigons", [])
        bigons_pre_punct = [self._classify_bigon_puncture(b) for b in bigons_pre]
        bigons_post_punct = [self._classify_bigon_puncture(b) for b in bigons_post]
        n_pre_with = sum(1 for c in bigons_pre_punct if c["puncture_count"] > 0)
        n_post_with = sum(1 for c in bigons_post_punct if c["puncture_count"] > 0)

        cmp_obj.structural_comparison = {
            "bigons_pre": len(bigons_pre),
            "bigons_post": len(bigons_post),
            "bigons_with_puncture_pre": n_pre_with,
            "bigons_with_puncture_post": n_post_with,
            "bigons_without_puncture_pre": len(bigons_pre) - n_pre_with,
            "bigons_without_puncture_post": len(bigons_post) - n_post_with,
            "all_bigons_contain_puncture_pre":
                len(bigons_pre) > 0 and n_pre_with == len(bigons_pre),
            "all_bigons_contain_puncture_post":
                len(bigons_post) > 0 and n_post_with == len(bigons_post),
            "minimal_position_pre": pre.structural.get("minimal_position"),
            "minimal_position_post": post.structural.get("minimal_position"),
            "bigon_puncture_classification_pre": bigons_pre_punct,
            "bigon_puncture_classification_post": bigons_post_punct,
        }
        return cmp_obj

    def _classify_bigon_puncture(self, bigon: dict) -> dict:
        """For one bigon, identify the 'tip' puncture vertices of the two
        triangles (the corner of each triangle NOT incident to the shared
        edge). Returns a dict with the count and vertex indices.

        On S_{1,2} every triangulation vertex is a puncture, so a non-empty
        tip-vertex set witnesses that the bigon's local 2-triangle region
        contains a puncture.
        """
        T = list(self.S.triangulation)
        tri_a_idx = bigon["triangle_a"]
        tri_b_idx = bigon["triangle_b"]
        shared_edge = bigon["shared_edge"]
        punctures = set()
        for tri_idx in (tri_a_idx, tri_b_idx):
            tri = T[tri_idx]
            indices = list(tri.indices)
            labels = list(tri.labels)
            try:
                slot = indices.index(shared_edge)
            except ValueError:
                continue
            tip_corner = (slot + 2) % 3
            tip_label = labels[tip_corner]
            punctures.add(self._vertex_table[tip_label])
        return {
            "triangle_a": tri_a_idx,
            "triangle_b": tri_b_idx,
            "shared_edge": shared_edge,
            "tip_punctures": sorted(punctures),
            "puncture_count": len(punctures),
        }

    # ---------------- invariants ----------------

    def invariants(self, obj: SurfaceCurve) -> dict:
        lam = self._lam(obj)
        gamma0 = self.S.curves.get("a_0")
        out = {
            "weight": int(sum(obj.weights)),
        }
        if gamma0 is not None:
            out["level"] = int(gamma0.intersection(lam))
        return out

    # ============================================================
    # Helper machinery
    # ============================================================

    def _lam(self, obj: SurfaceCurve):
        if obj._lamination is None:
            obj._lamination = self.S.lamination(list(obj.weights))
        return obj._lamination

    def _resolve_curve_ref(self, ref):
        if hasattr(ref, "intersection"):
            return ref
        if isinstance(ref, str):
            if ref == "gamma0":
                ref = "a_0"
            return self.S.curves[ref]
        if isinstance(ref, SurfaceCurve):
            return self._lam(ref)
        if isinstance(ref, (list, tuple)):
            return self.S.lamination(list(ref))
        raise ValueError(f"cannot resolve curve reference {ref!r}")

    def _decompose(self, obj: SurfaceCurve) -> dict:
        return self._decompose_lam(self._lam(obj), obj.object_id)

    def _decompose_lam(self, lam, curve_id: str) -> dict:
        weights = tuple(int(w) for w in tuple(lam))
        arcs: list[dict] = []
        arcs_per_tri: list[list[int]] = []
        for tri_idx, edges in enumerate(self._tri_indices):
            counts = _passage_counts(weights, edges)
            local: list[int] = []
            for (i, j), n in counts.items():
                if n > 0:
                    arcs.append({
                        "triangle": tri_idx,
                        "entry_edge": int(i),
                        "exit_edge": int(j),
                        "multiplicity": int(n),
                    })
                    local.append(len(arcs) - 1)
            arcs_per_tri.append(local)
        return {
            "curve_id": curve_id,
            "train_track_weights": list(weights),
            "normal_arcs": arcs,
            "arcs_per_triangle": arcs_per_tri,
            "total_weight": int(sum(weights)),
        }

    def _find_crossings(self, dec_a: dict, dec_b: dict) -> list[dict]:
        crossings: list[dict] = []
        next_idx = 0
        arcs_a = dec_a["normal_arcs"]
        arcs_b = dec_b["normal_arcs"]
        for tri_idx in range(len(self._tri_indices)):
            a_idxs = dec_a["arcs_per_triangle"][tri_idx]
            b_idxs = dec_b["arcs_per_triangle"][tri_idx]
            for ai in a_idxs:
                arc_a = arcs_a[ai]
                pair_a = frozenset((arc_a["entry_edge"], arc_a["exit_edge"]))
                for bi in b_idxs:
                    arc_b = arcs_b[bi]
                    pair_b = frozenset((arc_b["entry_edge"], arc_b["exit_edge"]))
                    shared = pair_a & pair_b
                    if len(shared) == 1:
                        cand = min(arc_a["multiplicity"], arc_b["multiplicity"])
                        if cand > 0:
                            crossings.append({
                                "index": next_idx,
                                "triangle": tri_idx,
                                "curve_a_arc": ai,
                                "curve_b_arc": bi,
                                "shared_edge": int(next(iter(shared))),
                                "candidate_count": int(cand),
                                "sign": +1,
                            })
                            next_idx += 1
        return crossings

    def _detect_bigons(self, dec_a: dict, dec_b: dict,
                       crossings: list[dict]) -> list[dict]:
        T = self.S.triangulation
        arcs_a = dec_a["normal_arcs"]
        arcs_b = dec_b["normal_arcs"]
        # tri_idx → set of unsigned edge indices
        tri_edges = [set(int(e) for e in idxs) for idxs in self._tri_indices]
        bigons: list[dict] = []
        seen: set[tuple[int, int]] = set()
        for i, c1 in enumerate(crossings):
            a1 = arcs_a[c1["curve_a_arc"]]
            b1 = arcs_b[c1["curve_b_arc"]]
            a1_e = {a1["entry_edge"], a1["exit_edge"]}
            b1_e = {b1["entry_edge"], b1["exit_edge"]}
            for j in range(i + 1, len(crossings)):
                c2 = crossings[j]
                if c1["triangle"] == c2["triangle"]:
                    continue
                a2 = arcs_a[c2["curve_a_arc"]]
                b2 = arcs_b[c2["curve_b_arc"]]
                a2_e = {a2["entry_edge"], a2["exit_edge"]}
                b2_e = {b2["entry_edge"], b2["exit_edge"]}
                shared = tri_edges[c1["triangle"]] & tri_edges[c2["triangle"]]
                for e in shared:
                    if e in a1_e and e in a2_e and e in b1_e and e in b2_e:
                        key = (i, j)
                        if key in seen:
                            continue
                        seen.add(key)
                        bigons.append({
                            "crossing_a": i,
                            "crossing_b": j,
                            "triangle_a": c1["triangle"],
                            "triangle_b": c2["triangle"],
                            "shared_edge": int(e),
                        })
                        break
        return bigons

    def _per_triangle_arc_count(self, dec: dict) -> dict[int, int]:
        out: dict[int, int] = {}
        arcs = dec["normal_arcs"]
        for tri_idx, idxs in enumerate(dec["arcs_per_triangle"]):
            out[tri_idx] = sum(arcs[i]["multiplicity"] for i in idxs)
        return out

    def _punctures_in_triangles(self, triangles: set) -> int:
        # On S_{g,n} with curver triangulation every vertex is a puncture.
        T = self.S.triangulation
        verts: set = set()
        for tri_idx in triangles:
            tri = list(T)[tri_idx]
            for lbl in tri.labels:
                verts.add(self._vertex_table[lbl])
        return len(verts)

    # ---------------- canonical sigma search ----------------

    def _search_canonical_sigma(self, alpha_lam, gamma0_lam):
        """Search the attached DB for the canonical Hatcher filler σ_α.

        Returns (sigma_curve, sigma_idx) or (None, None).
        """
        if self._db is None:
            return None, None
        curves = self._db["curves"]
        f_vals = [int(gamma0_lam.intersection(c)) for c in curves]
        k = int(gamma0_lam.intersection(alpha_lam))
        if k < 2:
            return None, None

        # Find α index
        alpha_h = tuple(int(w) for w in tuple(alpha_lam))
        try:
            alpha_idx = self._db["hashes"].index(alpha_h)
        except ValueError:
            alpha_idx = None

        # Build descending link DL of α: vertices β with f(β) < k
        # and i(α, β) ≤ 1.
        DL = []
        for b_idx, c in enumerate(curves):
            if alpha_idx is not None and b_idx == alpha_idx:
                continue
            if f_vals[b_idx] < k and int(alpha_lam.intersection(c)) <= 1:
                DL.append(b_idx)
        if not DL:
            return None, None

        # Walk down levels k-2, k-3, … looking for σ disjoint from α and
        # universal on DL.
        for target_level in range(k - 2, -1, -1):
            for cand_idx, cand in enumerate(curves):
                if alpha_idx is not None and cand_idx == alpha_idx:
                    continue
                if f_vals[cand_idx] != target_level:
                    continue
                if int(alpha_lam.intersection(cand)) != 0:
                    continue
                if all(int(cand.intersection(curves[b])) <= 1 for b in DL):
                    return cand, cand_idx
        return None, None
