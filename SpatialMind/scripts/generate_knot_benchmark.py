"""Generate the 100-pair benchmark dataset for knot_theory.

10 prime knots × 10 R2 moves each = 100 ExperimentCases.
For each (knot, trial) pair we run a single R2 move and call compare()
to capture the four-level RelationComparison. We then run all three
counterfactual strategies on the trefoil to get the CF block.

Outputs benchmarks/knot_theory/level_1.json … level_5.json mirroring the
surface_topology layout.
"""

from __future__ import annotations

import json
import os
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
from SpatialMind.domains.knot_theory.counterfactual import (
    KnotCounterfactualGenerator,
)
from SpatialMind.domains.knot_theory.engine import KnotEngine

KNOTS = ["3_1", "4_1", "5_1", "5_2", "6_1", "6_2", "6_3", "7_1", "7_2", "7_3"]
TRIALS_PER_KNOT = 10
SEED = 2026


def main():
    random.seed(SEED)
    engine = KnotEngine(seed=SEED)

    all_cases: list[ExperimentCase] = []
    invariants_failed = []

    t0 = time.time()
    for knot_name in KNOTS:
        K = engine.construct({"name": knot_name})
        for trial in range(TRIALS_PER_KNOT):
            try:
                tr = engine.transform(
                    K, {"type": "R2", "max_attempts": 50},
                )
            except Exception as e:
                print(f"  [skip] {knot_name} trial {trial}: {e}")
                continue
            K_prime = engine.construct({
                "pd_code": tr.trace.after_state["pd_code"],
                "object_id": f"{knot_name}-r2-{trial}",
            })
            cmp = engine.compare(K, K, K_prime, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{knot_name}-r2-{trial}",
                object_a_id=K.object_id,
                object_b_id=K.object_id,  # in knot theory β = K itself
                transformed_a_id=K_prime.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "knot": knot_name,
                    "move": "R2",
                    "trial": trial,
                    "writhe_pre": K.writhe,
                    "writhe_post": K_prime.writhe,
                    "n_crossings_pre": len(K.pd_code),
                    "n_crossings_post": len(K_prime.pd_code),
                },
            )
            all_cases.append(ec)
            if not cmp.structural_comparison["all_topological_invariants_preserved"]:
                invariants_failed.append(ec.case_id)
        print(f"  {knot_name}: {TRIALS_PER_KNOT} trials done")

    t1 = time.time()
    print(f"\nTotal: {len(all_cases)} cases in {t1 - t0:.1f}s")
    if invariants_failed:
        print(f"[WARNING] invariants failed on: {invariants_failed}")
    else:
        print(f"All {len(all_cases)} cases preserve all topological invariants.")

    # ------ Counterfactual generation on a representative knot (3_1) ------
    cf_gen = KnotCounterfactualGenerator(engine=engine)
    K_ref = engine.construct({"name": "3_1"})
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine, object_a=K_ref, object_b=K_ref,
        operation={"type": "R2"}, conditions={},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ------ Build & save the 5-level benchmark ------
    suite = build_benchmark_suite("knot_theory", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "knot_theory"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Quick stats summary ------
    sigs = Counter()
    dets = Counter()
    for ec in all_cases:
        sc = ec.comparison.structural_comparison
        sigs[(sc["signature_pre"], sc["signature_post"])] += 1
        dets[(sc["determinant_pre"], sc["determinant_post"])] += 1
    print(f"\nSignature (pre, post) histogram (top 5): "
          f"{dict(sigs.most_common(5))}")
    print(f"Determinant (pre, post) histogram (top 5): "
          f"{dict(dets.most_common(5))}")
    knot_dist = Counter(ec.metadata["knot"] for ec in all_cases)
    print(f"Knot distribution: {dict(sorted(knot_dist.items()))}")


if __name__ == "__main__":
    main()
