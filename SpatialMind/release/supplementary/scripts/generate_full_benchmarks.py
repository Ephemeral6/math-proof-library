"""Generate the full 99-pair benchmark dataset.

For S_{1,2}, iterate over every α with level ≥ 2; for each, find every β in
its descending link with i(α, β) = 1 (i = 0 is trivial; i ≥ 2 is outside
the conjecture), run a Hatcher surgery on α, and emit one ExperimentCase
per (α, β) pair. Build a 5-level benchmark suite and dump it to disk.
"""

from __future__ import annotations

import os
import sys
import time
from pathlib import Path
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
MATH_ROOT = os.path.abspath(os.path.join(ROOT, ".."))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)
if MATH_ROOT not in sys.path:
    sys.path.insert(0, MATH_ROOT)

from SpatialMind.domains.surface_topology.engine import SurfaceEngine
from SpatialMind.domains.surface_topology.counterfactual import (
    SurfaceCounterfactualGenerator,
)
from SpatialMind.core.counterfactual import (
    AutoCounterfactualGenerator, CounterfactualInput,
)
from SpatialMind.core.benchmark import ExperimentCase, build_benchmark_suite


def find_database() -> str:
    candidates = [
        os.path.join(ROOT, "domains/surface_topology/data/data_S_1_2.json"),
    ]
    for p in candidates:
        if os.path.exists(p):
            return p
    raise SystemExit("[FAIL] Cannot find data_S_1_2.json")


def main():
    db_path = find_database()
    engine = SurfaceEngine(g=1, n=2, database_path=db_path)
    gamma0 = engine.S.curves["a_0"]
    n_curves = len(engine._db["curves"])
    print(f"S_{{1,2}}: {n_curves} curves in database\n")

    all_cases: list[ExperimentCase] = []
    alpha_sigmas: dict[int, tuple] = {}
    skipped_alphas = 0

    t0 = time.time()
    for alpha_idx in range(n_curves):
        alpha_lam = engine._db["curves"][alpha_idx]
        k_alpha = int(gamma0.intersection(alpha_lam))
        if k_alpha < 2:
            continue

        alpha = engine.construct({"surface": [1, 2], "curve_index": alpha_idx})

        try:
            tr = engine.transform(alpha,
                                  {"type": "hatcher_surgery", "gamma0": "a_0"})
        except Exception as e:
            skipped_alphas += 1
            continue

        sigma = engine.construct({
            "surface": [1, 2],
            "weights": tr.trace.after_state["sigma_weights"],
            "object_id": tr.transformed_id,
        })
        alpha_sigmas[alpha_idx] = (sigma, tr)

        n_betas = 0
        for beta_idx in range(n_curves):
            if beta_idx == alpha_idx:
                continue
            beta_lam = engine._db["curves"][beta_idx]
            k_beta = int(gamma0.intersection(beta_lam))
            if k_beta >= k_alpha:
                continue
            i_ab = int(alpha_lam.intersection(beta_lam))
            if i_ab != 1:
                continue  # i = 0: trivial (disjoint stays disjoint); i ≥ 2: outside hypothesis

            beta = engine.construct({"surface": [1, 2], "curve_index": beta_idx})
            cmp_obj = engine.compare(alpha, beta, sigma, tr, detail_level=4)

            ec = ExperimentCase(
                case_id=f"a{alpha_idx}-b{beta_idx}",
                object_a_id=alpha.object_id,
                object_b_id=beta.object_id,
                transformed_a_id=sigma.object_id,
                transform_result=tr,
                comparison=cmp_obj,
                metadata={
                    "surface": [1, 2],
                    "alpha_index": alpha_idx,
                    "beta_index": beta_idx,
                    "alpha_level": k_alpha,
                    "beta_level": k_beta,
                    "i_alpha_beta": i_ab,
                },
            )
            all_cases.append(ec)
            n_betas += 1

        if n_betas > 0:
            print(f"  α=c{alpha_idx} (level {k_alpha}): {n_betas} βs")

    t1 = time.time()
    print(f"\nTotal: {len(all_cases)} cases from {len(alpha_sigmas)} αs "
          f"(skipped {skipped_alphas} αs whose surgery failed) in {t1 - t0:.1f}s")

    # Sanity: every case should preserve the intersection number.
    deltas = [ec.comparison.summary_delta.get("intersection_number")
              for ec in all_cases]
    n_zero = sum(1 for d in deltas if d == 0)
    n_nonzero = sum(1 for d in deltas if d != 0)
    print(f"net_change == 0: {n_zero}/{len(all_cases)}")
    if n_nonzero > 0:
        print(f"[WARNING] {n_nonzero} cases with net_change != 0:")
        for ec in all_cases:
            d = ec.comparison.summary_delta.get("intersection_number")
            if d != 0:
                print(f"  {ec.case_id}: net = {d}")

    # ------ Counterfactual generation: pick the first α/β pair ------
    if not all_cases:
        print("[FAIL] No cases generated; aborting.")
        sys.exit(1)
    first = all_cases[0]
    cf_alpha = engine.construct({"surface": [1, 2],
                                 "curve_index": first.metadata["alpha_index"]})
    cf_beta = engine.construct({"surface": [1, 2],
                                "curve_index": first.metadata["beta_index"]})
    cf_gen = AutoCounterfactualGenerator(SurfaceCounterfactualGenerator())
    cf_in = CounterfactualInput(
        engine=engine, object_a=cf_alpha, object_b=cf_beta,
        operation={"type": "hatcher_surgery", "gamma0": "a_0"},
        conditions={"intersection_bound": 1},
    )
    cf_cases = cf_gen.find_critical_conditions(cf_in)
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ------ Build & save the 5-level benchmark ------
    suite = build_benchmark_suite("surface_topology", all_cases, cf_cases)
    out_dir = Path(ROOT) / "benchmarks" / "surface_topology"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Stats summary on Level 4 bigon-puncture data ------
    l4_cases = suite.levels[4].cases
    n_pre_all = sum(1 for c in l4_cases
                    if c.get("structural_comparison", {})
                         .get("all_bigons_contain_puncture_pre", False))
    n_post_all = sum(1 for c in l4_cases
                     if c.get("structural_comparison", {})
                          .get("all_bigons_contain_puncture_post", False))
    print(f"\nBigon puncture stats (Level 4):")
    print(f"  all_bigons_contain_puncture_pre:  {n_pre_all}/{len(l4_cases)}")
    print(f"  all_bigons_contain_puncture_post: {n_post_all}/{len(l4_cases)}")

    bp_pre = [c["structural_comparison"]["bigons_pre"] for c in l4_cases]
    bp_post = [c["structural_comparison"]["bigons_post"] for c in l4_cases]
    bw_pre = [c["structural_comparison"]["bigons_without_puncture_pre"]
              for c in l4_cases]
    bw_post = [c["structural_comparison"]["bigons_without_puncture_post"]
               for c in l4_cases]
    print(f"  bigons_pre  range: {min(bp_pre)}-{max(bp_pre)}, mean={sum(bp_pre)/len(bp_pre):.2f}")
    print(f"  bigons_post range: {min(bp_post)}-{max(bp_post)}, mean={sum(bp_post)/len(bp_post):.2f}")
    print(f"  bigons_without_puncture_pre  total: {sum(bw_pre)}")
    print(f"  bigons_without_puncture_post total: {sum(bw_post)}")

    # alpha-level distribution
    alpha_levels = Counter(ec.metadata["alpha_level"] for ec in all_cases)
    print(f"\nα-level distribution (cases per α level): {dict(sorted(alpha_levels.items()))}")
    beta_levels = Counter(ec.metadata["beta_level"] for ec in all_cases)
    print(f"β-level distribution: {dict(sorted(beta_levels.items()))}")


if __name__ == "__main__":
    main()
