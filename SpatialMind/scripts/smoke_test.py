"""End-to-end smoke test for the new Phase-1.0+ API:
  construct → relate → transform → compare → counterfactual
  → ExperimentCase → build_benchmark_suite → write JSON.

Also renders the surface_topology prompt for each level so we exercise
the prompt template path."""

from __future__ import annotations

import os
import sys
import json
from pathlib import Path

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)
SPATIALMIND_PARENT = os.path.abspath(os.path.join(ROOT, ".."))
if SPATIALMIND_PARENT not in sys.path:
    sys.path.insert(0, SPATIALMIND_PARENT)


def run():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    from SpatialMind.domains.surface_topology.counterfactual import (
        SurfaceCounterfactualGenerator,
    )
    from SpatialMind.domains.surface_topology.prompts import make_prompt
    from SpatialMind.core.counterfactual import (
        AutoCounterfactualGenerator, CounterfactualInput,
    )
    from SpatialMind.core.benchmark import (
        ExperimentCase, build_benchmark_suite,
    )

    db_candidates = [
        "/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json",
        os.path.abspath(os.path.join(
            ROOT, "..", "workspace/projects/op1_geometry/data_S_1_2.json")),
    ]
    db_path = next((p for p in db_candidates if os.path.exists(p)), None)

    engine = SurfaceEngine(g=1, n=2, database_path=db_path)
    cf_gen = AutoCounterfactualGenerator(SurfaceCounterfactualGenerator())

    if db_path is None:
        print("[fail] curve database missing; cannot run full E2E.")
        sys.exit(1)

    gamma0 = engine.S.curves["a_0"]
    alpha_idx = next(idx for idx, c in enumerate(engine._db["curves"])
                     if int(gamma0.intersection(c)) == 4)
    alpha = engine.construct({"surface": [1, 2], "curve_index": alpha_idx})

    alpha_lam = engine._lam(alpha)
    beta_idx = next(idx for idx, c in enumerate(engine._db["curves"])
                    if idx != alpha_idx
                    and int(alpha_lam.intersection(c)) == 1
                    and int(gamma0.intersection(c)) < 4)
    beta = engine.construct({"surface": [1, 2], "curve_index": beta_idx})

    print(f"[ok] Engine: {engine.domain_name}")
    print(f"[ok] α = c{alpha_idx} (level 4), β = c{beta_idx} (i(α,β) = 1)")

    # Transform.
    tr = engine.transform(alpha, {"type": "hatcher_surgery", "gamma0": "a_0"})
    sigma = engine.construct({
        "surface": [1, 2],
        "weights": tr.trace.after_state["sigma_weights"],
        "object_id": tr.transformed_id,
    })
    print(f"[ok] σ = {sigma.object_id}, level shift = {tr.trace.delta['level_shift']}")

    # Compare.
    cmp_obj = engine.compare(alpha, beta, sigma, tr, detail_level=4)
    sd = cmp_obj.summary_delta
    print(f"[ok] compare: summary_delta = {sd}")
    assert sd["intersection_number"] == 0, "invariant should be preserved on i ≤ 1 case"
    print(f"[ok] structural: bigons {cmp_obj.structural_comparison['bigons_pre']} → "
          f"{cmp_obj.structural_comparison['bigons_post']}, "
          f"all_with_puncture: pre="
          f"{cmp_obj.structural_comparison['all_bigons_contain_puncture_pre']}, "
          f"post="
          f"{cmp_obj.structural_comparison['all_bigons_contain_puncture_post']}")
    print(f"[ok] reference_in_region: β triangles in region = "
          f"{cmp_obj.reference_in_transform_region['beta_triangles_in_region']}/"
          f"{cmp_obj.reference_in_transform_region['beta_triangles_total']}")

    # Counterfactual.
    cf_in = CounterfactualInput(
        engine=engine, object_a=alpha, object_b=beta,
        operation={"type": "hatcher_surgery", "gamma0": "a_0"},
        conditions={"intersection_bound": 1},
        positive_comparison=cmp_obj,
    )
    cf_cases = cf_gen.find_critical_conditions(cf_in)
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"[ok] counterfactual: {len(cf_cases)} cases, {n_critical} critical")

    # Experiment case + benchmark.
    ec = ExperimentCase(
        case_id=f"a{alpha_idx}-b{beta_idx}",
        object_a_id=alpha.object_id,
        object_b_id=beta.object_id,
        transformed_a_id=sigma.object_id,
        transform_result=tr,
        comparison=cmp_obj,
        metadata={"surface": [1, 2],
                  "alpha_level": int(gamma0.intersection(alpha_lam)),
                  "beta_level": int(gamma0.intersection(engine._lam(beta))),
                  "i_alpha_beta": int(alpha_lam.intersection(engine._lam(beta)))},
    )
    suite = build_benchmark_suite("surface_topology", [ec], cf_cases[:3])
    out_dir = Path(ROOT) / "benchmarks" / "surface_topology"
    suite.save_all(out_dir)
    print(f"[ok] Benchmark suite saved to {out_dir}: {len(suite.levels)} levels")
    for level in range(1, 6):
        bl = suite.levels[level]
        case0 = bl.cases[0]
        keys = [k for k in case0 if k != "case_id" and k != "metadata"]
        print(f"     Level {level}: {bl.n_cases} cases, "
              f"keys={keys}, "
              f"counterfactual={len(bl.counterfactual)}")

    # Verify per-level field presence.
    l1 = suite.levels[1].cases[0]
    assert "summary_delta" in l1 and "detailed_comparison" not in l1
    l2 = suite.levels[2].cases[0]
    assert "detailed_comparison" in l2 and "transform_trace" not in l2
    l3 = suite.levels[3].cases[0]
    assert "transform_trace" in l3 and "structural_comparison" not in l3
    l4 = suite.levels[4].cases[0]
    assert "structural_comparison" in l4
    bigon_keys = ("bigons_pre", "bigons_post",
                  "bigons_with_puncture_pre", "bigons_with_puncture_post",
                  "all_bigons_contain_puncture_pre",
                  "all_bigons_contain_puncture_post")
    for k in bigon_keys:
        assert k in l4["structural_comparison"], f"Level 4 missing {k}"
    l5 = suite.levels[5]
    assert len(l5.counterfactual) >= 1
    print("[ok] all per-level field assertions passed")

    # Render prompts.
    prompt_dir = out_dir / "prompts"
    prompt_dir.mkdir(parents=True, exist_ok=True)
    for level in range(1, 6):
        text = make_prompt(level).render()
        (prompt_dir / f"level_{level}.md").write_text(text, encoding="utf-8")
        assert "## 问题背景" in text and "## 你的任务" in text
    print(f"[ok] Prompts rendered for levels 1..5 to {prompt_dir}")

    print("\n[PASS] E2E smoke test passed.")


if __name__ == "__main__":
    run()
