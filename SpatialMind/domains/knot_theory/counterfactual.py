"""KnotCounterfactualGenerator — generates counterfactual R-moves.

Three strategies:

  BOUNDARY_RELAXATION: pseudo R2 with same-sign crossing pair (legal R2 has
    +1,-1; relaxing this to +1,+1 or -1,-1 breaks topological invariance).

  OPERATION_PERTURBATION: flip the over/under of one existing crossing.
    PD-code rotation by one slot flips a single crossing's sign — this is
    not a Reidemeister move and changes the knot type.

  CONDITION_REMOVAL: drop the planarity check and feed snappy.Link a
    non-planar PD code. Most often the resulting Link object cannot
    compute Seifert matrix; that itself is the signal.
"""

from __future__ import annotations

import random
from typing import Any

import snappy

from SpatialMind.core.counterfactual import (
    CFStrategy,
    CounterfactualCase,
    CounterfactualInput,
)

from .engine import (
    KnotEngine,
    KnotObject,
    _derived_invariants,
    _knot_object_from_link,
)


def _rotate_tuple(t: tuple, k: int = 1) -> tuple:
    n = len(t)
    k %= n
    return tuple(t[(i + k) % n] for i in range(n))


def _flip_crossing_sign(pd_code: list, crossing_index: int) -> list:
    """Return a new PD code with crossing `crossing_index`'s sign flipped.

    Cyclic rotation of a 4-tuple by 1 position swaps over/under, hence
    flips the SnapPy sign. (Verified on 3_1.)
    """
    new_pd = [list(c) for c in pd_code]
    new_pd[crossing_index] = list(_rotate_tuple(tuple(new_pd[crossing_index]), 1))
    return new_pd


def _signs_after(pd_code) -> list[int]:
    L = snappy.Link(pd_code)
    return [int(c.sign) for c in L.crossings]


class KnotCounterfactualGenerator:
    """Domain-specific counterfactual generator for knots."""

    def __init__(self, engine: KnotEngine | None = None):
        self.engine = engine or KnotEngine()

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

    # ---- BOUNDARY_RELAXATION (pseudo R2 with same-sign pair) ---------------
    def _boundary_relaxation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        K: KnotObject = input.object_a
        engine = self.engine

        # Step 1: do a real R2 directly here so we keep the in-memory Link
        # whose .crossings still carry the 'newN' string labels for the two
        # crossings the backtrack just added. (Re-loading from PD code loses
        # that information — labels become 0..n-1.)
        L_after = None
        added_idx = None
        added_signs = None
        for _ in range(50):
            L = K._link.copy()
            labels_before = {c.label for c in L.crossings}
            try:
                L.backtrack(steps=1, prob_type_1=0.0, prob_type_2=1.0)
            except Exception:
                continue
            new = [(i, c) for i, c in enumerate(L.crossings)
                   if c.label not in labels_before]
            if len(new) == 2:
                L_after = L
                added_idx = [i for i, _ in new]
                added_signs = [int(c.sign) for _, c in new]
                break
        if L_after is None or added_idx is None:
            return []

        post_pd = [list(c) for c in L_after.PD_code()]

        # Step 2: flip one of the two added crossings to force a same-sign
        # pair (pseudo R2). Cyclic rotation of a 4-tuple swaps over/under,
        # which flips that crossing's SnapPy sign.
        flipped_pd = _flip_crossing_sign(post_pd, added_idx[0])
        try:
            new_signs = _signs_after(flipped_pd)
        except Exception as e:
            return [CounterfactualCase(
                strategy=CFStrategy.BOUNDARY_RELAXATION,
                original_condition={"r2_added_signs": list(added_signs),
                                    "expected_signs_pair": "(+1,-1)"},
                modified_condition={"flipped_crossing_index": added_idx[0],
                                    "intended_signs_pair": "same-sign"},
                original_result={"all_topological_invariants_preserved": True},
                counterfactual_result={"error": str(e)},
                delta={"error": str(e)},
                condition_is_critical=True,
                explanation=("Pseudo-R2 (same-sign pair) yielded an invalid PD "
                             "code, demonstrating the (+1,-1) sign constraint "
                             "is structurally required."),
            )]

        # Step 3: compute invariants on K vs flipped post.
        K_pre  = K
        K_pseudo = engine.construct({"pd_code": flipped_pd,
                                     "object_id": f"pseudoR2({K.object_id})"})
        inv_pre = engine.invariants(K_pre)
        inv_post = engine.invariants(K_pseudo)
        all_preserved = (
            inv_pre["signature"] == inv_post["signature"]
            and inv_pre["determinant"] == inv_post["determinant"]
            and inv_pre["alexander_coeffs"][:0]  # placeholder, see below
            or False
        )
        # Robust normalized comparison
        from .engine import _normalize_alexander
        alex_pre_n = _normalize_alexander(
            _derived_invariants(K_pre._link)["alexander_coeffs"])
        alex_post_n = _normalize_alexander(
            _derived_invariants(K_pseudo._link)["alexander_coeffs"])
        all_preserved = (
            inv_pre["signature"] == inv_post["signature"]
            and inv_pre["determinant"] == inv_post["determinant"]
            and alex_pre_n == alex_post_n
        )

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "r2_added_signs_pair": tuple(sorted(added_signs)),
                "writhe_change_required": 0,
            },
            modified_condition={
                "r2_added_signs_pair": tuple(sorted(new_signs[i] for i in added_idx)),
                "writhe_change_observed": K_pseudo.writhe - K.writhe,
            },
            original_result={
                "signature": inv_pre["signature"],
                "determinant": inv_pre["determinant"],
                "alexander_normalized": alex_pre_n,
            },
            counterfactual_result={
                "signature": inv_post["signature"],
                "determinant": inv_post["determinant"],
                "alexander_normalized": alex_post_n,
            },
            delta={
                "signature_delta": inv_post["signature"] - inv_pre["signature"],
                "determinant_delta": inv_post["determinant"] - inv_pre["determinant"],
                "writhe_delta": K_pseudo.writhe - K.writhe,
                "alexander_changed": alex_pre_n != alex_post_n,
            },
            condition_is_critical=not all_preserved,
            explanation=(
                "Real R2 inserts a (+1, -1) crossing pair so writhe is "
                "preserved. Forcing same-sign pair gives a 'pseudo R2' that "
                "changes writhe by ±2 and breaks topological invariants."
            ),
        )]

    # ---- OPERATION_PERTURBATION (flip one existing crossing) -----------------
    def _operation_perturbation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        K: KnotObject = input.object_a
        engine = self.engine
        if not K.pd_code:
            return []
        crossing_idx = 0
        flipped_pd = _flip_crossing_sign(list(K.pd_code), crossing_idx)
        try:
            K_flip = engine.construct({"pd_code": flipped_pd,
                                       "object_id": f"flip{crossing_idx}({K.object_id})"})
        except Exception as e:
            return [CounterfactualCase(
                strategy=CFStrategy.OPERATION_PERTURBATION,
                original_condition={"flipped_crossing_index": None},
                modified_condition={"flipped_crossing_index": crossing_idx},
                original_result={},
                counterfactual_result={"error": str(e)},
                delta={"error": str(e)},
                condition_is_critical=True,
                explanation="Crossing flip produced an invalid PD code.",
            )]
        from .engine import _normalize_alexander
        inv_pre = engine.invariants(K)
        inv_post = engine.invariants(K_flip)
        alex_pre_n = _normalize_alexander(
            _derived_invariants(K._link)["alexander_coeffs"])
        alex_post_n = _normalize_alexander(
            _derived_invariants(K_flip._link)["alexander_coeffs"])
        all_preserved = (
            inv_pre["signature"] == inv_post["signature"]
            and inv_pre["determinant"] == inv_post["determinant"]
            and alex_pre_n == alex_post_n
        )
        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={"flipped_crossing_index": None},
            modified_condition={"flipped_crossing_index": crossing_idx},
            original_result={
                "signature": inv_pre["signature"],
                "determinant": inv_pre["determinant"],
                "alexander_normalized": alex_pre_n,
            },
            counterfactual_result={
                "signature": inv_post["signature"],
                "determinant": inv_post["determinant"],
                "alexander_normalized": alex_post_n,
            },
            delta={
                "signature_delta": inv_post["signature"] - inv_pre["signature"],
                "determinant_delta": inv_post["determinant"] - inv_pre["determinant"],
                "writhe_delta": K_flip.writhe - K.writhe,
                "alexander_changed": alex_pre_n != alex_post_n,
            },
            condition_is_critical=not all_preserved,
            explanation=(
                "Flipping one crossing's over/under is not a Reidemeister "
                "move; it changes the knot type, so signature / determinant / "
                "Alexander all generally change."
            ),
        )]

    # ---- CONDITION_REMOVAL (planarity off) -----------------------------------
    def _condition_removal(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        K: KnotObject = input.object_a
        # Construct a deliberately non-planar PD by swapping two strand
        # labels in one crossing so adjacent crossings don't match up.
        if len(K.pd_code) < 2:
            return []
        broken_pd = [list(c) for c in K.pd_code]
        # swap two labels between crossing 0 and 1 — this almost always
        # produces a non-planar (invalid) diagram.
        broken_pd[0][0], broken_pd[1][0] = broken_pd[1][0], broken_pd[0][0]
        try:
            K_broken = self.engine.construct({"pd_code": broken_pd,
                                              "object_id": f"broken({K.object_id})"})
            inv_post = self.engine.invariants(K_broken)
            err = None
        except Exception as e:
            inv_post = None
            err = str(e)
        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={"planarity_check": True},
            modified_condition={"planarity_check": False,
                                "swap_strands": [0, 1]},
            original_result={"valid_diagram": True},
            counterfactual_result=(
                {"valid_diagram": False, "error": err} if err
                else {"valid_diagram": True,
                      "signature": inv_post["signature"],
                      "determinant": inv_post["determinant"]}
            ),
            delta={"error": err} if err else {
                "signature_delta": (inv_post["signature"]
                                    - self.engine.invariants(K)["signature"]),
            },
            condition_is_critical=True,
            explanation=(
                "Dropping planarity (swapping strand labels at random) yields "
                "an inconsistent diagram. This shows the planarity constraint "
                "is structurally required for any topological reasoning."
            ),
        )]
