"""Generate the 200-pair benchmark dataset for symmetry_combinatorics.

100 pairs (a, b) with same_orbit = True + 100 pairs with same_orbit = False.
For each pair we apply a random non-identity group element to a and call
compare() to capture the four-level RelationComparison. We then run all
three counterfactual strategies on a representative pair to populate the
CF block (separate CF runs per pair would explode JSON size; one
representative CF block matches the knot_theory layout).

Outputs benchmarks/symmetry/level_1.json … level_5.json.
"""

from __future__ import annotations

import json
import random
import sys
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
from SpatialMind.domains.symmetry.engine import SymmetryEngine
from SpatialMind.domains.symmetry.counterfactual import (
    SymmetryCounterfactualGenerator,
)

N_SAME = 100
N_DIFF = 100
SEED = 2026


def _sample_same_orbit_pairs(engine: SymmetryEngine, n: int, rng: random.Random):
    """Sample n pairs (a, b) where b is a non-identity rotation of a.

    Skips pairs where the orbit has size 1 (monochromatic colorings) — for
    those there is no non-trivial b.
    """
    pairs = []
    nontrivial_orbits = [
        o for o in engine.orbits if len(o) > 1
    ]
    if not nontrivial_orbits:
        raise RuntimeError("No non-trivial orbits to sample from")
    while len(pairs) < n:
        orbit = rng.choice(nontrivial_orbits)
        i = rng.choice(orbit)
        j = rng.choice([x for x in orbit if x != i])
        a_c = engine.all_colorings[i]
        b_c = engine.all_colorings[j]
        pairs.append((a_c, b_c))
    return pairs


def _sample_diff_orbit_pairs(engine: SymmetryEngine, n: int, rng: random.Random):
    """Sample n pairs (a, b) from different orbits."""
    pairs = []
    orbit_count = len(engine.orbits)
    while len(pairs) < n:
        oa, ob = rng.sample(range(orbit_count), 2)
        a_c = engine.all_colorings[rng.choice(engine.orbits[oa])]
        b_c = engine.all_colorings[rng.choice(engine.orbits[ob])]
        pairs.append((a_c, b_c))
    return pairs


def main():
    rng = random.Random(SEED)
    engine = SymmetryEngine(n_vertices=6, n_colors=3, group="cyclic")

    print(f"Engine: {engine.m} vertices, {engine.k} colors, "
          f"{engine.group_type} group")
    print(f"  Total colorings: {len(engine.all_colorings)}")
    print(f"  Orbits: {len(engine.orbits)}")
    print(f"  Burnside count: {engine._burnside_count()}")

    same_pairs = _sample_same_orbit_pairs(engine, N_SAME, rng)
    diff_pairs = _sample_diff_orbit_pairs(engine, N_DIFF, rng)
    print(f"\nSampled {len(same_pairs)} same-orbit + {len(diff_pairs)} diff-orbit pairs")

    all_cases: list[ExperimentCase] = []

    pairs_with_label = (
        [("same", a, b) for (a, b) in same_pairs]
        + [("diff", a, b) for (a, b) in diff_pairs]
    )

    for idx, (label, a_c, b_c) in enumerate(pairs_with_label):
        a = engine.construct({"coloring": list(a_c)})
        b = engine.construct({"coloring": list(b_c)})

        # Random non-identity group element
        g_idx = rng.randint(1, len(engine.group_elements) - 1)
        tr = engine.transform(a, {"element_index": g_idx})
        sigma_a = engine.construct(
            {"coloring": list(tr.trace.after_state["coloring"])}
        )

        cmp = engine.compare(a, b, sigma_a, tr, detail_level=4)

        ec = ExperimentCase(
            case_id=f"{label}-{idx:03d}",
            object_a_id=a.object_id,
            object_b_id=b.object_id,
            transformed_a_id=sigma_a.object_id,
            transform_result=tr,
            comparison=cmp,
            metadata={
                "label": label,
                "same_orbit": (label == "same"),
                "g_idx": g_idx,
                "g_perm": list(engine.group_elements[g_idx]),
                "a_coloring": list(a_c),
                "b_coloring": list(b_c),
                "orbit_size_a": engine._orbit_size(a_c),
                "orbit_size_b": engine._orbit_size(b_c),
                "n_distinct_a": len(set(a_c)),
                "n_distinct_b": len(set(b_c)),
            },
        )
        all_cases.append(ec)

    print(f"Built {len(all_cases)} ExperimentCases")

    # Sanity check: invariants_preserved should be true for all (group action
    # preserves the orbit_id of the coloring).
    n_preserved = sum(
        1 for ec in all_cases
        if all(ec.transform_result.invariants_preserved.values())
    )
    print(f"  Invariants preserved on all: {n_preserved}/{len(all_cases)}")

    # ------ Counterfactual generation on a representative pair (same-orbit) ------
    cf_gen = SymmetryCounterfactualGenerator()
    rep_a_c, rep_b_c = same_pairs[0]
    rep_a = engine.construct({"coloring": list(rep_a_c)})
    rep_b = engine.construct({"coloring": list(rep_b_c)})
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine,
        object_a=rep_a,
        object_b=rep_b,
        operation={"element_index": 1},
        conditions={"group": "Z_6"},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ------ Build & save the 5-level benchmark ------
    suite = build_benchmark_suite("symmetry_combinatorics", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "symmetry"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Stats summary ------
    label_dist = Counter(ec.metadata["label"] for ec in all_cases)
    g_dist = Counter(ec.metadata["g_idx"] for ec in all_cases)
    n_distinct_dist = Counter(ec.metadata["n_distinct_a"] for ec in all_cases)
    print(f"\nLabel distribution: {dict(label_dist)}")
    print(f"Group element distribution (g_idx): {dict(sorted(g_dist.items()))}")
    print(f"#distinct colors in a distribution: {dict(sorted(n_distinct_dist.items()))}")


if __name__ == "__main__":
    main()
