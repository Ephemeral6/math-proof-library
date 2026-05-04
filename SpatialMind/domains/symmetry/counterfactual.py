"""Symmetry counterfactual generator.

Three strategies probe whether the *group* is the load-bearing condition for
"a and b are in the same orbit":

  boundary_relaxation:
      Original: G = Z_6 (rotations only).
      Modified: G' = D_6 (rotations + reflections).
      Larger group can MERGE orbits — pairs that were not equivalent under
      Z_6 may become equivalent under D_6.

  condition_removal:
      Original: G = Z_6.
      Modified: G' = {e} (trivial group).
      Equivalence collapses to identity — same_orbit(a,b) iff a == b.

  operation_perturbation:
      Original: transform with a group element g ∈ Z_6.
      Modified: transform with a non-group permutation (e.g. swap two adjacent
      vertices). Result is no longer in the same orbit as the input — the
      invariants are not preserved.
"""

from __future__ import annotations

import os
import sys
from typing import Any

_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_SPATIAL_ROOT = os.path.abspath(os.path.join(_THIS_DIR, "..", "..", ".."))
if _SPATIAL_ROOT not in sys.path:
    sys.path.insert(0, _SPATIAL_ROOT)

from SpatialMind.core.counterfactual import (
    CounterfactualCase,
    CounterfactualInput,
    CFStrategy,
)
from SpatialMind.domains.symmetry.engine import SymmetryEngine


class SymmetryCounterfactualGenerator:
    """Symmetry-domain specific counterfactual cases."""

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        if strategy is None:
            out: list[CounterfactualCase] = []
            for s in CFStrategy:
                try:
                    out.extend(self.generate(input, s))
                except NotImplementedError:
                    continue
            return out

        if strategy == CFStrategy.BOUNDARY_RELAXATION:
            return self._group_enlargement(input)
        if strategy == CFStrategy.CONDITION_REMOVAL:
            return self._group_to_trivial(input)
        if strategy == CFStrategy.OPERATION_PERTURBATION:
            return self._non_group_permutation(input)
        raise NotImplementedError(strategy)

    # ----- boundary_relaxation: Z_6 -> D_6 -----------------------------------

    def _group_enlargement(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: SymmetryEngine = input.engine
        a = input.object_a
        b = input.object_b

        rel_orig = engine.relate(a, b, detail_level=1)
        same_orig = bool(rel_orig.summary["same_orbit"])

        bigger = SymmetryEngine(engine.m, engine.k, group="dihedral")
        rel_cf = bigger.relate(a, b, detail_level=1)
        same_cf = bool(rel_cf.summary["same_orbit"])

        critical = (same_orig != same_cf)

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "group": "Z_6",
                "group_order": len(engine.group_elements),
                "total_orbits": len(engine.orbits),
            },
            modified_condition={
                "group": "D_6",
                "group_order": len(bigger.group_elements),
                "total_orbits": len(bigger.orbits),
            },
            original_result={"same_orbit": same_orig},
            counterfactual_result={"same_orbit": same_cf},
            delta={
                "same_orbit_changed": int(same_orig != same_cf),
                "orbit_count_change": len(bigger.orbits) - len(engine.orbits),
            },
            condition_is_critical=critical,
            explanation=(
                f"Enlarged group Z_6 -> D_6 (added 6 reflections). "
                f"Original same_orbit={same_orig}, modified={same_cf}. "
                f"Orbit count: {len(engine.orbits)} -> {len(bigger.orbits)}. "
                f"{'Critical: reflections merge these into one orbit.' if critical else 'Not critical: relation unchanged under enlarged group.'}"
            ),
        )]

    # ----- condition_removal: Z_6 -> trivial group ---------------------------

    def _group_to_trivial(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: SymmetryEngine = input.engine
        a = input.object_a
        b = input.object_b

        rel_orig = engine.relate(a, b, detail_level=1)
        same_orig = bool(rel_orig.summary["same_orbit"])

        # Trivial group {e}: same_orbit iff a == b
        same_cf = (a.coloring == b.coloring)

        critical = (same_orig != same_cf)

        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={
                "group": "Z_6",
                "group_order": len(engine.group_elements),
                "total_orbits": len(engine.orbits),
            },
            modified_condition={
                "group": "{e}",
                "group_order": 1,
                "total_orbits": engine.k ** engine.m,
            },
            original_result={"same_orbit": same_orig},
            counterfactual_result={"same_orbit": same_cf},
            delta={
                "same_orbit_changed": int(same_orig != same_cf),
                "orbit_count_change": engine.k ** engine.m - len(engine.orbits),
            },
            condition_is_critical=critical,
            explanation=(
                f"Removed all symmetry: G = Z_6 -> G' = {{e}}. "
                f"Original same_orbit={same_orig}, modified={same_cf}. "
                f"{'Critical: a and b are equivalent only because of rotational symmetry.' if critical else 'Not critical (a == b already).'}"
            ),
        )]

    # ----- operation_perturbation: non-group permutation ---------------------

    def _non_group_permutation(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine: SymmetryEngine = input.engine
        a = input.object_a
        operation = input.operation or {"element_index": 1}

        tr_orig = engine.transform(a, operation)
        sigma_a = engine.construct(
            {"coloring": tr_orig.trace.after_state["coloring"]}
        )
        rel_orig = engine.relate(a, sigma_a, detail_level=1)
        same_orig = bool(rel_orig.summary["same_orbit"])

        # Non-group permutation: swap vertices 0 and 1 (a transposition, not in Z_6).
        m = engine.m
        perm = list(range(m))
        perm[0], perm[1] = perm[1], perm[0]
        new_c = tuple(a.coloring[perm[j]] for j in range(m))

        sigma_a_cf = engine.construct({"coloring": list(new_c)})
        rel_cf = engine.relate(a, sigma_a_cf, detail_level=1)
        same_cf = bool(rel_cf.summary["same_orbit"])

        critical = (same_orig != same_cf)

        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={
                "operation": "group_action",
                "permutation_in_group": True,
                "element_index": operation.get("element_index", 1),
            },
            modified_condition={
                "operation": "swap(0,1)",
                "permutation_in_group": False,
                "permutation": perm,
            },
            original_result={
                "same_orbit_a_sigma_a": same_orig,
                "sigma_a_coloring": list(tr_orig.trace.after_state["coloring"]),
            },
            counterfactual_result={
                "same_orbit_a_sigma_a": same_cf,
                "sigma_a_coloring": list(new_c),
            },
            delta={
                "same_orbit_changed": int(same_orig != same_cf),
            },
            condition_is_critical=critical,
            explanation=(
                f"Replaced group element with a non-group transposition (swap 0,1). "
                f"Original same_orbit(a, g·a)={same_orig}, modified same_orbit(a, swap·a)={same_cf}. "
                f"{'Critical: non-group permutations break orbit equivalence.' if critical else 'Not critical: a is fixed by both (e.g. monochromatic or symmetric pattern).'}"
            ),
        )]


# Self-test ------------------------------------------------------------------

if __name__ == "__main__":
    e = SymmetryEngine(6, 3, "cyclic")
    a = e.construct({"coloring": [0, 1, 2, 0, 1, 2]})
    b_same = e.construct({"coloring": [1, 2, 0, 1, 2, 0]})  # same orbit
    b_diff = e.construct({"coloring": [0, 0, 1, 1, 2, 2]})  # different orbit

    gen = SymmetryCounterfactualGenerator()

    print("=== Pair in SAME orbit ===")
    inp = CounterfactualInput(
        engine=e, object_a=a, object_b=b_same,
        operation={"element_index": 2}, conditions={},
    )
    cases = gen.generate(inp)
    for c in cases:
        print(f"  [{c.strategy.value}] critical={c.condition_is_critical}")
        print(f"    original_result: {c.original_result}")
        print(f"    counterfactual_result: {c.counterfactual_result}")
        print(f"    delta: {c.delta}")

    print("\n=== Pair in DIFFERENT orbits ===")
    inp = CounterfactualInput(
        engine=e, object_a=a, object_b=b_diff,
        operation={"element_index": 2}, conditions={},
    )
    cases = gen.generate(inp)
    for c in cases:
        print(f"  [{c.strategy.value}] critical={c.condition_is_critical}")
        print(f"    original_result: {c.original_result}")
        print(f"    counterfactual_result: {c.counterfactual_result}")
        print(f"    delta: {c.delta}")
