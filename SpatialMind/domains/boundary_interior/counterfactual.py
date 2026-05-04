"""PolygonCounterfactualGenerator — counterfactuals for Pick's theorem.

Three strategies:

  BOUNDARY_RELAXATION: positive case is a lattice polygon (Pick applies).
    Counterfactual displaces one vertex by a non-integer offset (e.g. 0.5),
    making it non-lattice -> B, I become undefined and Pick's discrete
    formula no longer has meaning.

  OPERATION_PERTURBATION: positive case applies a unimodular shear
    (det = 1, area preserved). Counterfactual applies non-uniform scale
    (det != 1, area not preserved). Pick formula still holds on the
    scaled polygon (it's still lattice), but the *value* A changes —
    illustrating that area-preserving transforms are a strictly smaller
    class than lattice-preserving transforms.

  CONDITION_REMOVAL: positive case is a simple polygon. Counterfactual
    permutes vertices to create self-intersection -> the "interior" is
    no longer well-defined and Pick fails.
"""

from __future__ import annotations

from SpatialMind.core.counterfactual import (
    CFStrategy,
    CounterfactualCase,
    CounterfactualInput,
)

from .engine import BoundaryInteriorEngine, PolygonObject


class PolygonCounterfactualGenerator:
    """Domain-specific counterfactual generator for Pick's theorem."""

    def __init__(self, engine: BoundaryInteriorEngine | None = None):
        self.engine = engine or BoundaryInteriorEngine()

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

    # ---- BOUNDARY_RELAXATION (lattice -> non-lattice) -----------------------
    def _boundary_relaxation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        P: PolygonObject = input.object_a
        engine = self.engine
        if not engine._is_lattice(P.vertices):
            return []

        inv_pos = engine.invariants(P)

        # Displace one vertex by 0.5 in x — kills lattice property.
        new_verts = list(P.vertices)
        new_verts[0] = (new_verts[0][0] + 0.5, new_verts[0][1])
        P_cf = engine.construct({
            "vertices": [list(v) for v in new_verts],
            "object_id": f"{P.object_id}_nonlattice",
        })
        inv_cf = engine.invariants(P_cf)

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "is_lattice": True,
                "vertices": [list(v) for v in P.vertices],
            },
            modified_condition={
                "is_lattice": False,
                "displaced_vertex_index": 0,
                "displacement": [0.5, 0],
                "vertices": [list(v) for v in P_cf.vertices],
            },
            original_result={
                "area": inv_pos["area"],
                "B": inv_pos["B"],
                "I": inv_pos["I"],
                "pick_holds": inv_pos["pick_holds"],
            },
            counterfactual_result={
                "area": inv_cf["area"],
                "B": inv_cf["B"],   # = -1 (undefined)
                "I": inv_cf["I"],   # = -1 (undefined)
                "pick_holds": inv_cf["pick_holds"],
            },
            delta={
                "area_change": round(inv_cf["area"] - inv_pos["area"], 6),
                "B_change_meaning": "undefined (not a lattice polygon)",
                "pick_applicability_lost": (inv_pos["pick_holds"]
                                            and not inv_cf["pick_holds"]),
            },
            condition_is_critical=(inv_pos["pick_holds"]
                                   and not inv_cf["pick_holds"]),
            explanation=(
                "Pick's theorem requires lattice (integer) vertices. Moving "
                "one vertex by 0.5 makes B and I (counts of integer points "
                "on/in the polygon) ambiguous — Pick's formula no longer "
                "applies. The shoelace area is still defined but cannot be "
                "recovered from B + I."
            ),
        )]

    # ---- OPERATION_PERTURBATION (unimodular shear vs non-uniform scale) -----
    def _operation_perturbation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        P: PolygonObject = input.object_a
        engine = self.engine
        if not engine._is_lattice(P.vertices):
            return []

        # Positive: unimodular shear (det = 1).
        tr_pos = engine.transform(P, {"type": "shear", "matrix": [[1, 1], [0, 1]]})
        # Counterfactual: scale by [2, 1] (det = 2, not area-preserving).
        tr_cf = engine.transform(P, {"type": "scale_non_uniform", "scale": [2, 1]})

        inv_pre = engine.invariants(P)
        inv_pos = tr_pos.invariants_after
        inv_cf  = tr_cf.invariants_after

        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={
                "operation": "shear",
                "matrix": [[1, 1], [0, 1]],
                "determinant": 1,
            },
            modified_condition={
                "operation": "scale_non_uniform",
                "scale": [2, 1],
                "determinant": 2,
            },
            original_result={
                "area_after": inv_pos["area"],
                "B_after": inv_pos["B"],
                "I_after": inv_pos["I"],
                "pick_holds_after": inv_pos["pick_holds"],
            },
            counterfactual_result={
                "area_after": inv_cf["area"],
                "B_after": inv_cf["B"],
                "I_after": inv_cf["I"],
                "pick_holds_after": inv_cf["pick_holds"],
            },
            delta={
                "area_change_positive": round(inv_pos["area"] - inv_pre["area"], 6),
                "area_change_counterfactual": round(inv_cf["area"] - inv_pre["area"], 6),
                "pick_holds_both": inv_pos["pick_holds"] and inv_cf["pick_holds"],
                "ratio_area_change":
                    round(inv_cf["area"] / inv_pre["area"], 6) if inv_pre["area"] else None,
            },
            condition_is_critical=(
                abs(inv_pos["area"] - inv_pre["area"]) < 1e-6
                and abs(inv_cf["area"] - inv_pre["area"]) > 1e-6
            ),
            explanation=(
                "Linear maps with |det|=1 (unimodular) preserve both area "
                "AND lattice structure. Maps with |det|!=1 still send "
                "lattice polygons to lattice polygons (if entries are "
                "integers), so Pick continues to apply, but the area "
                "scales by the determinant. Shear preserves area; "
                "non-uniform scale does not."
            ),
        )]

    # ---- CONDITION_REMOVAL (simple polygon -> self-intersecting) ------------
    def _condition_removal(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        P: PolygonObject = input.object_a
        engine = self.engine
        if len(P.vertices) < 4:
            return []
        if not engine._is_simple(P.vertices):
            return []

        # Swap two non-adjacent vertices to create a "bowtie" / self-intersecting polygon.
        # For a 4-vertex polygon ABCD, ABCD -> ABDC is the standard bowtie.
        verts = list(P.vertices)
        n = len(verts)
        # swap index 1 and 2 produces self-intersection for most polygons.
        new_verts = verts.copy()
        new_verts[1], new_verts[2] = new_verts[2], new_verts[1]
        if n >= 4 and engine._is_simple(new_verts):
            # Try a different swap.
            new_verts = verts.copy()
            new_verts[2], new_verts[3 % n] = new_verts[3 % n], new_verts[2]
        P_cf = engine.construct({
            "vertices": [list(v) for v in new_verts],
            "object_id": f"{P.object_id}_selfint",
        })
        inv_pos = engine.invariants(P)
        inv_cf  = engine.invariants(P_cf)

        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={
                "is_simple": True,
                "vertices": [list(v) for v in P.vertices],
            },
            modified_condition={
                "is_simple": False,
                "vertices": [list(v) for v in P_cf.vertices],
                "swap": [1, 2],
            },
            original_result={
                "area": inv_pos["area"],
                "B": inv_pos["B"],
                "I": inv_pos["I"],
                "pick_holds": inv_pos["pick_holds"],
            },
            counterfactual_result={
                "area": inv_cf["area"],
                "B": inv_cf["B"],
                "I": inv_cf["I"],
                "pick_holds": inv_cf["pick_holds"],
            },
            delta={
                "is_simple_lost": inv_pos["is_simple"] and not inv_cf["is_simple"],
                "pick_applicability_lost":
                    inv_pos["pick_holds"] and not inv_cf["pick_holds"],
                "area_shoelace_changed":
                    abs(inv_cf["area"] - inv_pos["area"]) > 1e-6,
            },
            condition_is_critical=(inv_pos["pick_holds"] and not inv_cf["pick_holds"]),
            explanation=(
                "Pick's theorem assumes the polygon is *simple* (no edge "
                "self-intersections). For a self-intersecting polygon, "
                "'interior' is ambiguous (e.g. bowtie has two lobes) and "
                "the I count is meaningless. The shoelace formula computes "
                "a *signed* area that no longer matches I + B/2 - 1."
            ),
        )]
