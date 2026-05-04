"""Unit tests for KnotEngine + KnotCounterfactualGenerator."""

from __future__ import annotations

import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import pytest

from SpatialMind.core.counterfactual import CFStrategy, CounterfactualInput
from SpatialMind.domains.knot_theory.counterfactual import (
    KnotCounterfactualGenerator,
)
from SpatialMind.domains.knot_theory.engine import (
    KnotEngine,
    _normalize_alexander,
)


@pytest.fixture(autouse=True)
def fixed_seed():
    random.seed(42)


@pytest.fixture
def engine():
    return KnotEngine(seed=42)


def test_construct_from_name(engine):
    K = engine.construct({"name": "3_1"})
    assert K.object_id == "3_1"
    assert len(K.pd_code) == 3
    assert K.num_components == 1
    assert K.writhe in (-3, 3)


def test_construct_from_pd_code(engine):
    K0 = engine.construct({"name": "3_1"})
    pd = [list(c) for c in K0.pd_code]
    K1 = engine.construct({"pd_code": pd})
    assert tuple(tuple(c) for c in K1.pd_code) == K0.pd_code


def test_invariants_trefoil(engine):
    K = engine.construct({"name": "3_1"})
    inv = engine.invariants(K)
    assert inv["determinant"] == 3
    assert inv["seifert_genus_diagram"] == 1
    assert inv["alexander_polynomial"] == "t**2 - t + 1"
    # signature is ±2 depending on diagram chirality
    assert abs(inv["signature"]) == 2


def test_invariants_figure_eight(engine):
    K = engine.construct({"name": "4_1"})
    inv = engine.invariants(K)
    assert inv["determinant"] == 5
    assert inv["signature"] == 0
    assert inv["seifert_genus_diagram"] == 1


def test_relate_two_knots(engine):
    K_a = engine.construct({"name": "3_1"})
    K_b = engine.construct({"name": "4_1"})
    rel = engine.relate(K_a, K_b, detail_level=3)
    s = rel.summary
    assert s["crossing_count_a"] == 3
    assert s["crossing_count_b"] == 4
    assert s["writhe_a"] in (-3, 3)
    assert s["writhe_b"] == 0
    assert "alexander_polynomial_a" in rel.structural
    assert rel.structural["alexander_match"] is False


def test_transform_r2_preserves_writhe(engine):
    K = engine.construct({"name": "3_1"})
    tr = engine.transform(K, {"type": "R2", "max_attempts": 50})
    assert tr.trace.delta["crossing_count_delta"] == 2
    assert tr.trace.delta["writhe_delta"] == 0
    signs_pair = tr.trace.region_affected["added_crossing_signs_pair"]
    assert signs_pair == (-1, 1)
    assert len(tr.trace.region_affected["added_crossing_labels"]) == 2


def test_compare_r2_invariants_preserved(engine):
    """R2 must preserve signature, determinant, Alexander polynomial."""
    for name in ["3_1", "4_1", "5_1", "6_1"]:
        K = engine.construct({"name": name})
        tr = engine.transform(K, {"type": "R2", "max_attempts": 50})
        K_prime = engine.construct({
            "pd_code": tr.trace.after_state["pd_code"],
            "object_id": tr.transformed_id,
        })
        cmp = engine.compare(K, K, K_prime, tr, detail_level=4)
        sc = cmp.structural_comparison
        assert sc["signature_preserved"], f"sig fail on {name}"
        assert sc["determinant_preserved"], f"det fail on {name}"
        assert sc["alexander_preserved"], f"alex fail on {name}"
        assert sc["writhe_preserved"], f"writhe fail on {name}"
        assert sc["all_topological_invariants_preserved"], f"all fail on {name}"


def test_transform_mirror(engine):
    K = engine.construct({"name": "3_1"})
    tr = engine.transform(K, {"type": "mirror"})
    assert tr.trace.delta["writhe_delta"] == -2 * K.writhe


def test_alexander_normalization():
    # t^4 - t^3 + t^2 should canonicalize to [1, -1, 1] (t² · (t² - t + 1))
    assert _normalize_alexander([1, -1, 1, 0, 0]) == [1, -1, 1]
    # -t^2 + t - 1 should flip sign
    assert _normalize_alexander([-1, 1, -1]) == [1, -1, 1]
    # All zeros and trivial
    assert _normalize_alexander([0, 0, 0]) == [0]
    assert _normalize_alexander([1]) == [1]


def test_counterfactual_pseudo_r2_breaks_invariants(engine):
    K = engine.construct({"name": "3_1"})
    gen = KnotCounterfactualGenerator(engine=engine)
    cfs = gen.generate(
        CounterfactualInput(
            engine=engine, object_a=K, object_b=K,
            operation={"type": "R2"}, conditions={},
        ),
        strategy=CFStrategy.BOUNDARY_RELAXATION,
    )
    assert len(cfs) == 1
    cf = cfs[0]
    assert cf.condition_is_critical
    pair = cf.modified_condition.get("r2_added_signs_pair")
    # Same-sign pair: either (+1,+1) or (-1,-1)
    assert pair in ((1, 1), (-1, -1))
    # writhe must change by ±2
    assert abs(cf.delta["writhe_delta"]) == 2


def test_counterfactual_crossing_flip(engine):
    K = engine.construct({"name": "3_1"})
    gen = KnotCounterfactualGenerator(engine=engine)
    cfs = gen.generate(
        CounterfactualInput(
            engine=engine, object_a=K, object_b=K,
            operation={"type": "flip"}, conditions={},
        ),
        strategy=CFStrategy.OPERATION_PERTURBATION,
    )
    assert len(cfs) == 1
    cf = cfs[0]
    # Trefoil with one crossing flipped: 3_1 → unknot, signature changes
    assert cf.condition_is_critical
    assert cf.delta["alexander_changed"]


def test_counterfactual_condition_removal(engine):
    K = engine.construct({"name": "3_1"})
    gen = KnotCounterfactualGenerator(engine=engine)
    cfs = gen.generate(
        CounterfactualInput(
            engine=engine, object_a=K, object_b=K,
            operation={"type": "R2"}, conditions={},
        ),
        strategy=CFStrategy.CONDITION_REMOVAL,
    )
    assert len(cfs) == 1
    assert cfs[0].condition_is_critical
