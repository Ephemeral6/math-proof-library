"""Tests for SurfaceCounterfactualGenerator (CounterfactualInput interface)."""

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


def _setup_alpha_beta(e):
    """Find a level-4 α and a β in its descending link with i(α,β)=1."""
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
    return alpha, beta


def test_boundary_relaxation_produces_case():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    from SpatialMind.domains.surface_topology.counterfactual import (
        SurfaceCounterfactualGenerator,
    )
    from SpatialMind.core.counterfactual import CFStrategy, CounterfactualInput

    e = SurfaceEngine(g=1, n=2, database_path=_require_db())
    alpha, beta = _setup_alpha_beta(e)

    cf_in = CounterfactualInput(
        engine=e,
        object_a=alpha,
        object_b=beta,
        operation={"type": "hatcher_surgery", "gamma0": "a_0"},
        conditions={"intersection_bound": 1},
    )

    cf_gen = SurfaceCounterfactualGenerator()
    cases = cf_gen.generate(cf_in, strategy=CFStrategy.BOUNDARY_RELAXATION)
    assert len(cases) >= 1
    case = cases[0]
    assert case.strategy == CFStrategy.BOUNDARY_RELAXATION
    assert ("error" not in case.counterfactual_result) or case.condition_is_critical


def test_auto_counterfactual_runs_without_crash():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    from SpatialMind.domains.surface_topology.counterfactual import (
        SurfaceCounterfactualGenerator,
    )
    from SpatialMind.core.counterfactual import (
        AutoCounterfactualGenerator, CounterfactualInput,
    )

    e = SurfaceEngine(g=1, n=2, database_path=_require_db())
    alpha, beta = _setup_alpha_beta(e)

    cf_in = CounterfactualInput(
        engine=e,
        object_a=alpha,
        object_b=beta,
        operation={"type": "hatcher_surgery", "gamma0": "a_0"},
        conditions={"intersection_bound": 1},
    )

    auto = AutoCounterfactualGenerator(SurfaceCounterfactualGenerator())
    cases = auto.find_critical_conditions(cf_in)
    assert isinstance(cases, list)
    assert len(cases) >= 1


def test_strategy_none_iterates_all():
    """Calling generate(input, strategy=None) should iterate over every
    strategy and bundle the cases."""
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    from SpatialMind.domains.surface_topology.counterfactual import (
        SurfaceCounterfactualGenerator,
    )
    from SpatialMind.core.counterfactual import CounterfactualInput

    e = SurfaceEngine(g=1, n=2, database_path=_require_db())
    alpha, beta = _setup_alpha_beta(e)

    cf_in = CounterfactualInput(
        engine=e,
        object_a=alpha,
        object_b=beta,
        operation={"type": "hatcher_surgery", "gamma0": "a_0"},
        conditions={"intersection_bound": 1},
    )
    cases = SurfaceCounterfactualGenerator().generate(cf_in, strategy=None)
    assert isinstance(cases, list)
    assert len(cases) >= 1
