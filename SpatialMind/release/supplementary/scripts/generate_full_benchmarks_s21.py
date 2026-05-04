"""Generate the full benchmark dataset on S_{2,1}.

Mirror of generate_full_benchmarks.py but on the larger surface S_{2,1}
(genus 2, 1 puncture). Two of three S_{1,2} degeneracies should clear:
  #2 surgery region == whole surface (4/4 on S_{1,2}; expected partial on S_{2,1})
  #3 crossings_outside_region == 0   (always on S_{1,2}; expected often non-zero on S_{2,1})
The bigon-puncture-tag degeneracy (#1) is structural to curver triangulations
(every triangulation vertex is a puncture) and is NOT expected to clear here.
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


SURFACE = (2, 1)
DB_PATH = os.path.join(ROOT, "domains/surface_topology/data/s21_curves.json")
OUT_DIR = Path(ROOT) / "benchmarks" / "surface_topology_s21"


def main():
    if not os.path.exists(DB_PATH):
        raise SystemExit(f"[FAIL] Cannot find {DB_PATH}")

    g, n = SURFACE
    engine = SurfaceEngine(g=g, n=n, database_path=DB_PATH)
    gamma0 = engine.S.curves["a_0"]
    n_curves = len(engine._db["curves"])
    total_tris = len(engine._tri_indices)
    print(f"S_{{{g},{n}}}: {n_curves} curves, {total_tris} triangles\n")

    all_cases: list[ExperimentCase] = []
    alpha_sigmas: dict[int, tuple] = {}
    skipped_alphas = 0

    t0 = time.time()
    for alpha_idx in range(n_curves):
        alpha_lam = engine._db["curves"][alpha_idx]
        k_alpha = int(gamma0.intersection(alpha_lam))
        if k_alpha < 2:
            continue

        alpha = engine.construct({"surface": list(SURFACE),
                                  "curve_index": alpha_idx})
        try:
            tr = engine.transform(alpha,
                                  {"type": "hatcher_surgery", "gamma0": "a_0"})
        except Exception:
            skipped_alphas += 1
            continue

        sigma = engine.construct({
            "surface": list(SURFACE),
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
                continue

            beta = engine.construct({"surface": list(SURFACE),
                                     "curve_index": beta_idx})
            cmp_obj = engine.compare(alpha, beta, sigma, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"a{alpha_idx}-b{beta_idx}",
                object_a_id=alpha.object_id,
                object_b_id=beta.object_id,
                transformed_a_id=sigma.object_id,
                transform_result=tr,
                comparison=cmp_obj,
                metadata={
                    "surface": list(SURFACE),
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

    if not all_cases:
        print("[FAIL] No cases generated; aborting.")
        sys.exit(1)

    # Sanity: net intersection-number change should be 0 (Hatcher).
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
    first = all_cases[0]
    cf_alpha = engine.construct({"surface": list(SURFACE),
                                 "curve_index": first.metadata["alpha_index"]})
    cf_beta = engine.construct({"surface": list(SURFACE),
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
    suite.save_all(OUT_DIR)
    print(f"\nBenchmark saved to {OUT_DIR}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = OUT_DIR / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Degeneracy report (the whole point of this run) ------
    l4 = suite.levels[4].cases
    region_full = sum(
        1 for c in l4
        if len(c["transform_trace"]["region_affected"]["triangles"]) == total_tris
    )
    outside_pos = sum(
        1 for c in l4
        if c["detailed_comparison"]["crossings_outside_region_pre"] > 0
    )
    bigon_with = sum(
        1 for c in l4
        if c["structural_comparison"].get("bigons_pre", 0) > 0
    )
    bigon_all_punct = sum(
        1 for c in l4
        if c["structural_comparison"].get("all_bigons_contain_puncture_pre", False)
    )
    print(f"\nDegeneracy report (Level 4 / structural cases, total={len(l4)}):")
    print(f"  #2 region == whole surface ({total_tris} tris): "
          f"{region_full}/{len(l4)} (lower better)")
    print(f"  #3 crossings_outside_region_pre > 0:           "
          f"{outside_pos}/{len(l4)} (higher better)")
    print(f"  #1 bigons exist:                                "
          f"{bigon_with}/{len(l4)}")
    print(f"  #1 all bigons contain puncture (when present): "
          f"{bigon_all_punct}/{bigon_with} (still trivially true on curver tri)")

    # ------ Distributions ------
    alpha_levels = Counter(ec.metadata["alpha_level"] for ec in all_cases)
    beta_levels = Counter(ec.metadata["beta_level"] for ec in all_cases)
    print(f"\nα-level distribution: {dict(sorted(alpha_levels.items()))}")
    print(f"β-level distribution: {dict(sorted(beta_levels.items()))}")


if __name__ == "__main__":
    main()
