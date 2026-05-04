"""Tests for RelationComparison and SurfaceEngine.compare()."""

from __future__ import annotations

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)


def _require_db():
    db_path = "/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json"
    if not os.path.exists(db_path):
        db_path = os.path.abspath(os.path.join(
            ROOT, "workspace/projects/op1_geometry/data_S_1_2.json"))
    if not os.path.exists(db_path):
        import pytest
        pytest.skip("S_{1,2} curve database not available")
    return db_path


def test_compute_summary_delta():
    from SpatialMind.core.comparison import compute_summary_delta
    from SpatialMind.core.relation import RelationData

    pre = RelationData("a", "b", summary={"i": 5, "w": 7})
    post = RelationData("sigma", "b", summary={"i": 5, "w": 4})
    d = compute_summary_delta(pre, post)
    assert d == {"i": 0, "w": -3}


def test_relation_comparison_at_level():
    from SpatialMind.core.comparison import RelationComparison
    from SpatialMind.core.relation import RelationData

    pre = RelationData("a", "b", summary={"i": 1})
    post = RelationData("sigma", "b", summary={"i": 1})
    cmp_obj = RelationComparison(
        object_a_id="a", object_b_id="b", transformed_a_id="sigma",
        pre=pre, post=post,
        summary_delta={"i": 0},
        detailed_comparison={"crossings_pre_count": 3},
        structural_comparison={"bigons_pre": 2},
        transform_trace={"operation_name": "test"},
        reference_in_transform_region={"beta_triangles_in_region": 1},
    )
    l1 = cmp_obj.at_level(1)
    assert "summary_delta" in l1
    assert "detailed_comparison" not in l1

    l2 = cmp_obj.at_level(2)
    assert "detailed_comparison" in l2
    assert "transform_trace" not in l2

    l3 = cmp_obj.at_level(3)
    assert "transform_trace" in l3
    assert "reference_in_transform_region" in l3
    assert "structural_comparison" not in l3

    l4 = cmp_obj.at_level(4)
    assert "structural_comparison" in l4


def test_engine_compare_full():
    """End-to-end: compare(α, β, σ_α) on a real S_{1,2} case."""
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine

    db_path = _require_db()
    e = SurfaceEngine(g=1, n=2, database_path=db_path)
    gamma0 = e.S.curves["a_0"]

    alpha_idx = next(idx for idx, c in enumerate(e._db["curves"])
                     if int(gamma0.intersection(c)) == 4)
    alpha = e.construct({"surface": [1, 2], "curve_index": alpha_idx})

    alpha_lam = e._lam(alpha)
    beta_idx = next(idx for idx, c in enumerate(e._db["curves"])
                    if idx != alpha_idx
                    and int(alpha_lam.intersection(c)) == 1
                    and int(gamma0.intersection(c)) < 4)
    beta = e.construct({"surface": [1, 2], "curve_index": beta_idx})

    tr = e.transform(alpha, {"type": "hatcher_surgery", "gamma0": "a_0"})
    sigma = e.construct({"surface": [1, 2],
                         "weights": tr.trace.after_state["sigma_weights"],
                         "object_id": tr.transformed_id})

    cmp_obj = e.compare(alpha, beta, sigma, tr, detail_level=4)

    # Summary delta: intersection number must be preserved.
    assert cmp_obj.summary_delta["intersection_number"] == 0

    # Detailed comparison fields exist.
    dc = cmp_obj.detailed_comparison
    for key in ("crossings_pre_count", "crossings_post_count",
                "crossings_in_transform_region_pre",
                "crossings_in_transform_region_post",
                "crossings_outside_region_pre",
                "crossings_outside_region_post"):
        assert key in dc

    # Reference-in-region fields exist.
    rr = cmp_obj.reference_in_transform_region
    for key in ("beta_triangles_total", "beta_triangles_in_region",
                "beta_through_short_arc", "beta_through_long_arc"):
        assert key in rr

    # Structural comparison fields exist.
    sc = cmp_obj.structural_comparison
    for key in ("bigons_pre", "bigons_post",
                "bigons_with_puncture_pre", "bigons_with_puncture_post",
                "all_bigons_contain_puncture_pre",
                "all_bigons_contain_puncture_post"):
        assert key in sc


def test_experiment_case_json_roundtrip():
    """ExperimentCase serializes to a dict that the benchmark generator can use."""
    from SpatialMind.core.benchmark import (
        ExperimentCase, build_benchmark_suite,
    )
    from SpatialMind.core.comparison import RelationComparison
    from SpatialMind.core.relation import RelationData
    from SpatialMind.core.transform import TransformTrace, TransformResult

    pre = RelationData("a", "b", summary={"i": 1})
    post = RelationData("sigma", "b", summary={"i": 1})
    trace = TransformTrace(operation_name="test")
    tr = TransformResult(original_id="a", transformed_id="sigma", trace=trace)
    cmp_obj = RelationComparison(
        object_a_id="a", object_b_id="b", transformed_a_id="sigma",
        pre=pre, post=post,
        summary_delta={"i": 0},
    )
    ec = ExperimentCase(
        case_id="t1",
        object_a_id="a", object_b_id="b", transformed_a_id="sigma",
        transform_result=tr, comparison=cmp_obj,
        metadata={"surface": [1, 2]},
    )
    suite = build_benchmark_suite("t", [ec])
    assert set(suite.levels.keys()) == {1, 2, 3, 4, 5}
    l1 = suite.levels[1].cases[0]
    assert "summary_delta" in l1
    assert "detailed_comparison" not in l1
    l4 = suite.levels[4].cases[0]
    assert "structural_comparison" in l4


def test_make_prompt_render():
    """Domain prompt template renders without crashing on every level."""
    from SpatialMind.domains.surface_topology.prompts import make_prompt
    for level in range(1, 6):
        p = make_prompt(level)
        text = p.render()
        assert "## 问题背景" in text
        assert "## 你的任务" in text
        if level == 5:
            assert "反事实" in text
