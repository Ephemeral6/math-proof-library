"""KnotEngine — wraps SnapPy/spherogram for SpatialMind.

Implements GeometricEngine for knots and links. Without Sage, polynomial
invariants are derived from the Seifert matrix using NumPy + SymPy:
  signature   = sig(S + S^T)
  determinant = |det(S + S^T)|
  alexander   = det(t·S - S^T)

See `audit_snappy.md` for the API survey and known caveats (signature
sign convention, diagram-genus vs topological-genus).
"""

from __future__ import annotations

import hashlib
import random
from dataclasses import dataclass, field
from typing import Any

import numpy as np
import snappy
from sympy import Matrix, Poly, symbols

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformResult, TransformTrace
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


# ---------------------------------------------------------------------------
# KnotObject
# ---------------------------------------------------------------------------

def _pd_hash(pd: tuple) -> str:
    h = hashlib.sha1(repr(pd).encode("utf-8")).hexdigest()[:8]
    return f"pd_{h}"


@dataclass
class KnotObject:
    """A knot/link diagram backed by snappy.Link."""

    _object_id: str
    pd_code: tuple                       # tuple of 4-tuples (hashable)
    crossing_signs: tuple                # tuple of ±1
    num_components: int
    writhe: int
    _link: Any = field(default=None, repr=False)

    @property
    def object_id(self) -> str:
        return self._object_id

    def to_json(self) -> dict:
        return {
            "object_id": self._object_id,
            "pd_code": [list(c) for c in self.pd_code],
            "crossing_signs": list(self.crossing_signs),
            "num_components": self.num_components,
            "writhe": self.writhe,
        }


def _knot_object_from_link(L, object_id: str | None = None) -> KnotObject:
    pd = tuple(tuple(int(x) for x in c) for c in L.PD_code())
    signs = tuple(int(c.sign) for c in L.crossings)
    if object_id is None:
        object_id = _pd_hash(pd)
    return KnotObject(
        _object_id=object_id,
        pd_code=pd,
        crossing_signs=signs,
        num_components=len(L.link_components),
        writhe=int(L.writhe()),
        _link=L,
    )


# ---------------------------------------------------------------------------
# Derived invariants (Sage-free)
# ---------------------------------------------------------------------------

_t = symbols("t")


def _normalize_alexander(coeffs: list[int]) -> list[int]:
    """Canonicalize Alexander coefficients up to ±t^k.

    Alexander polynomial is defined only up to multiplication by ±t^k.
    Coefficients here come from sympy's Poly.all_coeffs() (highest degree
    first). Normalization:
      1. strip leading zeros
      2. strip trailing zeros (factor out t^k)
      3. if first nonzero coeff is negative, flip all signs
    Empty / all-zero input returns [0].
    """
    c = list(coeffs)
    while c and c[0] == 0:
        c.pop(0)
    while c and c[-1] == 0:
        c.pop()
    if not c:
        return [0]
    if c[0] < 0:
        c = [-x for x in c]
    return c


def _derived_invariants(L) -> dict:
    """Compute signature, determinant, Alexander, Seifert genus from
    seifert_matrix() without Sage."""
    S_list = L.seifert_matrix()
    S = np.array(S_list, dtype=int) if S_list else np.zeros((0, 0), dtype=int)

    if S.size == 0:
        return {
            "signature": 0,
            "determinant": 1,
            "seifert_genus_diagram": 0,
            "alexander_polynomial": "1",
            "alexander_coeffs": [1],
            "alexander_coeffs_normalized": [1],
            "alexander_degree": 0,
            "seifert_matrix": [],
        }

    M = (S + S.T).astype(float)
    eig = np.linalg.eigvalsh(M)
    sig = int(np.sum(eig > 1e-9) - np.sum(eig < -1e-9))
    det = abs(int(round(float(np.linalg.det(M)))))

    Sm = Matrix(S.tolist())
    alex_expr = (_t * Sm - Sm.T).det().expand()
    poly = Poly(alex_expr, _t)
    coeffs = [int(c) for c in poly.all_coeffs()]
    norm_coeffs = _normalize_alexander(coeffs)
    deg = len(norm_coeffs) - 1 if norm_coeffs and norm_coeffs != [0] else 0

    return {
        "signature": sig,
        "determinant": det,
        "seifert_genus_diagram": S.shape[0] // 2,
        "alexander_polynomial": str(alex_expr),
        "alexander_coeffs": coeffs,
        "alexander_coeffs_normalized": norm_coeffs,
        "alexander_degree": int(deg),
        "seifert_matrix": [list(map(int, row)) for row in S_list],
    }


# ---------------------------------------------------------------------------
# KnotEngine
# ---------------------------------------------------------------------------

class KnotEngine:
    """SpatialMind GeometricEngine for knot diagrams."""

    domain_name = "knot_theory"

    def __init__(self, seed: int | None = None):
        if seed is not None:
            random.seed(seed)

    # ---- construct -----------------------------------------------------------
    def construct(self, spec: dict) -> KnotObject:
        if "link" in spec:
            L = spec["link"]
        elif "name" in spec:
            L = snappy.Link(spec["name"])
        elif "pd_code" in spec:
            L = snappy.Link(spec["pd_code"])
        elif "braid_closure" in spec:
            L = snappy.Link(braid_closure=spec["braid_closure"])
        else:
            raise ValueError(f"unrecognised spec {spec!r}")

        oid = spec.get("object_id") or spec.get("name")
        return _knot_object_from_link(L, object_id=oid)

    # ---- invariants ----------------------------------------------------------
    def invariants(self, K: KnotObject) -> dict:
        L = K._link
        derived = _derived_invariants(L)
        out = {
            "crossing_count_diagram": len(L.crossings),
            "num_components": K.num_components,
            "writhe": K.writhe,
            "linking_number": float(L.linking_number()),
            "signature": derived["signature"],
            "determinant": derived["determinant"],
            "seifert_genus_diagram": derived["seifert_genus_diagram"],
            "alexander_polynomial": derived["alexander_polynomial"],
            "alexander_coeffs": derived["alexander_coeffs"],
            "alexander_degree": derived["alexander_degree"],
        }
        try:
            out["is_alternating"] = bool(L.is_alternating())
        except Exception:
            out["is_alternating"] = None
        try:
            out["bridge_upper_bound"] = int(L.bridge_upper_bound())
        except Exception:
            out["bridge_upper_bound"] = None
        return out

    # ---- relate --------------------------------------------------------------
    def relate(self, K_a: KnotObject, K_b: KnotObject,
               detail_level: int = 1) -> RelationData:
        L_a, L_b = K_a._link, K_b._link
        rel = RelationData(
            object_a_id=K_a.object_id,
            object_b_id=K_b.object_id,
            summary={
                "crossing_count_a": len(L_a.crossings),
                "crossing_count_b": len(L_b.crossings),
                "writhe_a": K_a.writhe,
                "writhe_b": K_b.writhe,
                "writhe_delta": K_b.writhe - K_a.writhe,
                "linking_number": float(L_a.linking_number()),
            },
        )
        if detail_level <= 1:
            return rel

        rel.detailed = {
            "crossing_signs_a": list(K_a.crossing_signs),
            "crossing_signs_b": list(K_b.crossing_signs),
            "pd_code_a": [list(c) for c in K_a.pd_code],
            "pd_code_b": [list(c) for c in K_b.pd_code],
            "signs_multiset_match": (
                sorted(K_a.crossing_signs) == sorted(K_b.crossing_signs)
            ),
            "signs_count_pos_a": sum(1 for s in K_a.crossing_signs if s > 0),
            "signs_count_neg_a": sum(1 for s in K_a.crossing_signs if s < 0),
            "signs_count_pos_b": sum(1 for s in K_b.crossing_signs if s > 0),
            "signs_count_neg_b": sum(1 for s in K_b.crossing_signs if s < 0),
            "pd_code_match": K_a.pd_code == K_b.pd_code,
        }
        if detail_level <= 2:
            return rel

        inv_a = _derived_invariants(L_a)
        inv_b = _derived_invariants(L_b)
        rel.structural = {
            "seifert_matrix_a": inv_a["seifert_matrix"],
            "seifert_matrix_b": inv_b["seifert_matrix"],
            "signature_a": inv_a["signature"],
            "signature_b": inv_b["signature"],
            "determinant_a": inv_a["determinant"],
            "determinant_b": inv_b["determinant"],
            "seifert_genus_diagram_a": inv_a["seifert_genus_diagram"],
            "seifert_genus_diagram_b": inv_b["seifert_genus_diagram"],
            "alexander_polynomial_a": inv_a["alexander_polynomial"],
            "alexander_polynomial_b": inv_b["alexander_polynomial"],
            "alexander_coeffs_a": inv_a["alexander_coeffs"],
            "alexander_coeffs_b": inv_b["alexander_coeffs"],
            "alexander_coeffs_normalized_a": inv_a["alexander_coeffs_normalized"],
            "alexander_coeffs_normalized_b": inv_b["alexander_coeffs_normalized"],
            "alexander_match":
                inv_a["alexander_coeffs_normalized"]
                == inv_b["alexander_coeffs_normalized"],
            "signature_match": inv_a["signature"] == inv_b["signature"],
            "determinant_match": inv_a["determinant"] == inv_b["determinant"],
        }
        return rel

    # ---- transform -----------------------------------------------------------
    def transform(self, K: KnotObject, operation: dict, **kwargs) -> TransformResult:
        op = operation["type"]
        if op == "R2":
            return self._transform_r2(K, operation)
        if op == "R1":
            return self._transform_r1(K, operation)
        if op == "mirror":
            return self._transform_mirror(K)
        if op == "connected_sum":
            return self._transform_connected_sum(K, operation)
        if op == "simplify":
            return self._transform_simplify(K, operation)
        raise ValueError(f"Unsupported operation type: {op}")

    def _transform_r2(self, K: KnotObject, operation: dict) -> TransformResult:
        target_signs = tuple(operation.get("signs", (+1, -1)))
        max_attempts = int(operation.get("max_attempts", 50))
        for _ in range(max_attempts):
            L = K._link.copy()
            labels_before = {c.label for c in L.crossings}
            try:
                L.backtrack(steps=1, prob_type_1=0.0, prob_type_2=1.0)
            except Exception:
                continue
            new = [c for c in L.crossings if c.label not in labels_before]
            if len(new) == 2 and tuple(sorted(int(c.sign) for c in new)) \
                    == tuple(sorted(target_signs)):
                return self._build_transform_result(
                    K, L, new, "R2",
                    {"target_signs": list(target_signs)},
                )
        raise RuntimeError(
            f"R2 with signs={target_signs} not produced in {max_attempts} attempts"
        )

    def _transform_r1(self, K: KnotObject, operation: dict) -> TransformResult:
        target_sign = int(operation.get("sign", +1))
        max_attempts = int(operation.get("max_attempts", 50))
        for _ in range(max_attempts):
            L = K._link.copy()
            labels_before = {c.label for c in L.crossings}
            try:
                L.backtrack(steps=1, prob_type_1=1.0, prob_type_2=0.0)
            except Exception:
                continue
            new = [c for c in L.crossings if c.label not in labels_before]
            if len(new) == 1 and int(new[0].sign) == target_sign:
                return self._build_transform_result(
                    K, L, new, "R1",
                    {"target_sign": target_sign},
                )
        raise RuntimeError(
            f"R1 with sign={target_sign} not produced in {max_attempts} attempts"
        )

    def _transform_mirror(self, K: KnotObject) -> TransformResult:
        L = K._link.mirror()
        new_K = _knot_object_from_link(L, object_id=f"mirror({K.object_id})")
        trace = TransformTrace(
            operation_name="mirror",
            operation_params={},
            before_state={
                "pd_code": [list(c) for c in K.pd_code],
                "writhe": K.writhe,
                "signs": list(K.crossing_signs),
            },
            after_state={
                "pd_code": [list(c) for c in new_K.pd_code],
                "writhe": new_K.writhe,
                "signs": list(new_K.crossing_signs),
            },
            delta={
                "crossing_count_delta": 0,
                "writhe_delta": new_K.writhe - K.writhe,
            },
            region_affected={
                "all_signs_flipped": True,
            },
        )
        return TransformResult(
            original_id=K.object_id,
            transformed_id=new_K.object_id,
            trace=trace,
        )

    def _transform_connected_sum(self, K: KnotObject, operation: dict) -> TransformResult:
        K_b: KnotObject = operation["other"]
        L = K._link.connected_sum(K_b._link)
        new_K = _knot_object_from_link(
            L, object_id=f"({K.object_id}#{K_b.object_id})"
        )
        trace = TransformTrace(
            operation_name="connected_sum",
            operation_params={"other_id": K_b.object_id},
            before_state={"pd_code": [list(c) for c in K.pd_code]},
            after_state={"pd_code": [list(c) for c in new_K.pd_code]},
            delta={
                "crossing_count_delta": len(new_K.pd_code) - len(K.pd_code),
                "writhe_delta": new_K.writhe - K.writhe,
            },
            region_affected={},
        )
        return TransformResult(
            original_id=K.object_id,
            transformed_id=new_K.object_id,
            trace=trace,
        )

    def _transform_simplify(self, K: KnotObject, operation: dict) -> TransformResult:
        mode = operation.get("mode", "global")
        L = K._link.copy()
        before_labels = {c.label for c in L.crossings}
        try:
            L.simplify(mode=mode)
        except TypeError:
            L.simplify()
        new_K = _knot_object_from_link(
            L, object_id=f"simplify[{mode}]({K.object_id})"
        )
        kept = [c for c in L.crossings if c.label in before_labels]
        trace = TransformTrace(
            operation_name="simplify",
            operation_params={"mode": mode},
            before_state={
                "pd_code": [list(c) for c in K.pd_code],
                "n_crossings": len(K.pd_code),
            },
            after_state={
                "pd_code": [list(c) for c in new_K.pd_code],
                "n_crossings": len(new_K.pd_code),
            },
            delta={
                "crossing_count_delta": len(new_K.pd_code) - len(K.pd_code),
                "writhe_delta": new_K.writhe - K.writhe,
            },
            region_affected={
                "persistent_crossing_labels":
                    [str(c.label) for c in kept],
            },
        )
        return TransformResult(
            original_id=K.object_id,
            transformed_id=new_K.object_id,
            trace=trace,
        )

    def _build_transform_result(self, K: KnotObject, L_after,
                                new_crossings: list, op_name: str,
                                params: dict) -> TransformResult:
        new_K = _knot_object_from_link(
            L_after, object_id=f"{op_name}({K.object_id})"
        )
        added_labels = [str(c.label) for c in new_crossings]
        added_signs = [int(c.sign) for c in new_crossings]
        kept = [c for c in L_after.crossings
                if str(c.label) not in set(added_labels)]
        trace = TransformTrace(
            operation_name=op_name,
            operation_params=params,
            before_state={
                "pd_code": [list(c) for c in K.pd_code],
                "writhe": K.writhe,
                "n_crossings": len(K.pd_code),
                "signs": list(K.crossing_signs),
            },
            after_state={
                "pd_code": [list(c) for c in new_K.pd_code],
                "writhe": new_K.writhe,
                "n_crossings": len(new_K.pd_code),
                "signs": list(new_K.crossing_signs),
            },
            delta={
                "crossing_count_delta": len(new_K.pd_code) - len(K.pd_code),
                "writhe_delta": new_K.writhe - K.writhe,
            },
            region_affected={
                "added_crossing_labels": added_labels,
                "added_crossing_signs": added_signs,
                "added_crossing_signs_pair":
                    tuple(sorted(added_signs)) if len(added_signs) == 2 else None,
                "added_crossing_count": len(added_labels),
                "persistent_crossing_labels":
                    [str(c.label) for c in kept],
                "persistent_crossing_count": len(kept),
            },
        )
        return TransformResult(
            original_id=K.object_id,
            transformed_id=new_K.object_id,
            trace=trace,
        )

    # ---- compare -------------------------------------------------------------
    def compare(self, K_a: KnotObject, K_b: KnotObject,
                transformed_a: KnotObject,
                transform_result: TransformResult,
                detail_level: int = 4) -> RelationComparison:
        # In knot theory, "β" can be K_a itself; we still call relate to
        # capture invariants for both pre and post.
        pre  = self.relate(K_a, K_b, detail_level=min(detail_level, 3))
        post = self.relate(transformed_a, K_b, detail_level=min(detail_level, 3))
        cmp = RelationComparison(
            object_a_id=K_a.object_id,
            object_b_id=K_b.object_id,
            transformed_a_id=transformed_a.object_id,
            pre=pre,
            post=post,
            summary_delta=compute_summary_delta(pre, post),
            transform_trace=transform_result.trace.to_json(),
        )

        # detailed: per-crossing sign and PD-code changes
        cmp.detailed_comparison = {
            "crossings_a_before": len(K_a.pd_code),
            "crossings_a_after":  len(transformed_a.pd_code),
            "added_crossing_count":
                transform_result.trace.delta.get("crossing_count_delta", 0),
            "added_crossing_signs":
                transform_result.trace.region_affected.get(
                    "added_crossing_signs", []),
            "added_crossing_signs_pair":
                transform_result.trace.region_affected.get(
                    "added_crossing_signs_pair", None),
            "writhe_change_a": int(transformed_a.writhe - K_a.writhe),
            "signs_count_pos_pre":
                sum(1 for s in K_a.crossing_signs if s > 0),
            "signs_count_neg_pre":
                sum(1 for s in K_a.crossing_signs if s < 0),
            "signs_count_pos_post":
                sum(1 for s in transformed_a.crossing_signs if s > 0),
            "signs_count_neg_post":
                sum(1 for s in transformed_a.crossing_signs if s < 0),
        }

        # reference_in_transform_region: for knots, β = K_a itself.
        # We instead record which persistent crossings remain.
        cmp.reference_in_transform_region = {
            "persistent_crossing_count":
                transform_result.trace.region_affected.get(
                    "persistent_crossing_count", 0),
            "persistent_crossing_labels":
                transform_result.trace.region_affected.get(
                    "persistent_crossing_labels", []),
            "added_crossing_labels":
                transform_result.trace.region_affected.get(
                    "added_crossing_labels", []),
        }

        # structural: invariant preservation
        inv_pre  = pre.structural or _derived_invariants(K_a._link)
        inv_post = post.structural or _derived_invariants(transformed_a._link)
        # Both pre.structural and post.structural use suffix "_a" referring to
        # K_a / transformed_a. linking_number / writhe live in summary.
        sig_pre  = inv_pre.get("signature_a", inv_pre.get("signature", 0))
        sig_post = inv_post.get("signature_a", inv_post.get("signature", 0))
        det_pre  = inv_pre.get("determinant_a", inv_pre.get("determinant", 1))
        det_post = inv_post.get("determinant_a", inv_post.get("determinant", 1))
        alex_pre_raw = inv_pre.get("alexander_polynomial_a",
                                   inv_pre.get("alexander_polynomial", "1"))
        alex_post_raw = inv_post.get("alexander_polynomial_a",
                                     inv_post.get("alexander_polynomial", "1"))
        alex_pre_norm = inv_pre.get("alexander_coeffs_normalized_a",
                                    inv_pre.get("alexander_coeffs_normalized", [1]))
        alex_post_norm = inv_post.get("alexander_coeffs_normalized_a",
                                      inv_post.get("alexander_coeffs_normalized", [1]))
        cmp.structural_comparison = {
            "signature_pre": sig_pre,
            "signature_post": sig_post,
            "signature_preserved": sig_pre == sig_post,
            "determinant_pre": det_pre,
            "determinant_post": det_post,
            "determinant_preserved": det_pre == det_post,
            "alexander_pre_raw": alex_pre_raw,
            "alexander_post_raw": alex_post_raw,
            "alexander_pre_normalized": alex_pre_norm,
            "alexander_post_normalized": alex_post_norm,
            "alexander_preserved": alex_pre_norm == alex_post_norm,
            "writhe_pre": K_a.writhe,
            "writhe_post": transformed_a.writhe,
            "writhe_preserved": K_a.writhe == transformed_a.writhe,
            "all_topological_invariants_preserved": (
                sig_pre == sig_post
                and det_pre == det_post
                and alex_pre_norm == alex_post_norm
            ),
        }

        return cmp
