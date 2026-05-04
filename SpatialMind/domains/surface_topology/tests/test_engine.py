"""Tests for SurfaceEngine — verify it implements GeometricEngine and that
the migrated geometric computations agree with the original rich_geometry."""

from __future__ import annotations

import os
import sys

# Make sure the SpatialMind/ root is importable.
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)


def test_engine_protocol():
    from SpatialMind.core.engine import GeometricEngine
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine

    e = SurfaceEngine(g=1, n=2)
    assert isinstance(e, GeometricEngine)
    assert e.domain_name == "surface_topology"


def test_construct_named():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    b0 = e.construct({"surface": [1, 2], "curve_name": "b_0"})
    assert a0.object_id == "a_0"
    assert b0.object_id == "b_0"
    assert sum(a0.weights) > 0
    assert sum(b0.weights) > 0


def test_construct_gamma0_alias():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    g = e.construct({"surface": [1, 2], "curve_name": "gamma0"})
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    assert g.weights == a0.weights


def test_relate_summary_matches_curver():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    b0 = e.construct({"surface": [1, 2], "curve_name": "b_0"})
    rel = e.relate(a0, b0, detail_level=1)
    # On S_{1,2}, a_0 and b_0 are the two basis curves of the torus part —
    # they meet exactly once.
    assert rel.summary["intersection_number"] == 1


def test_relate_levels_grow_data():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    b0 = e.construct({"surface": [1, 2], "curve_name": "b_0"})
    r1 = e.relate(a0, b0, detail_level=1)
    r2 = e.relate(a0, b0, detail_level=2)
    r3 = e.relate(a0, b0, detail_level=3)
    assert r1.summary == r2.summary == r3.summary
    assert r1.detailed == {} and "crossings" in r2.detailed
    assert r2.structural == {} and "bigons" in r3.structural


def test_relate_upper_bound_consistent():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    b0 = e.construct({"surface": [1, 2], "curve_name": "b_0"})
    rel = e.relate(a0, b0, detail_level=2)
    # candidate ≥ geometric is the rich_geometry sanity invariant.
    assert rel.detailed["candidate_crossings_total"] >= rel.summary["intersection_number"]
    assert rel.detailed["upper_bound_consistent"] is True


def test_invariants_basic():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    b0 = e.construct({"surface": [1, 2], "curve_name": "b_0"})
    inv_a = e.invariants(a0)
    inv_b = e.invariants(b0)
    assert inv_a["weight"] >= 1
    assert inv_a["level"] == 0  # γ_0 = a_0 → i(a_0, a_0) = 0
    assert inv_b["level"] == 1


def test_construct_from_weights():
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    rebuilt = e.construct({"surface": [1, 2],
                           "weights": list(a0.weights),
                           "object_id": "a0_rebuilt"})
    assert rebuilt.weights == a0.weights


def test_decompose_weight_sanity():
    """sum(arc.multiplicity) must equal sum(weights) (each edge weight is
    the count of arc-ends on that edge, halved across two triangles)."""
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    e = SurfaceEngine(g=1, n=2)
    a0 = e.construct({"surface": [1, 2], "curve_name": "a_0"})
    dec = e._decompose(a0)
    s_arc = sum(a["multiplicity"] for a in dec["normal_arcs"])
    s_w = sum(dec["train_track_weights"])
    assert s_arc == s_w


def test_transform_hatcher_surgery_with_database():
    """If the OP-1 database is available, transform should run on a
    high-level α and produce a sigma at level ≤ k-2 disjoint from α."""
    from SpatialMind.domains.surface_topology.engine import SurfaceEngine
    db_path = "/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json"
    if not os.path.exists(db_path):
        # Try the Windows-relative path
        db_path = os.path.abspath(os.path.join(
            ROOT, "workspace/projects/op1_geometry/data_S_1_2.json"))
    if not os.path.exists(db_path):
        import pytest
        pytest.skip("S_{1,2} curve database not available")
    e = SurfaceEngine(g=1, n=2, database_path=db_path)
    # Pick an α with high level (≥ 4) — guaranteed non-trivial surgery.
    import curver
    gamma0 = e.S.curves["a_0"]
    alpha_idx = None
    for idx, c in enumerate(e._db["curves"]):
        if int(gamma0.intersection(c)) == 4:
            alpha_idx = idx
            break
    assert alpha_idx is not None
    alpha = e.construct({"surface": [1, 2], "curve_index": alpha_idx})
    inv_pre = e.invariants(alpha)
    res = e.transform(alpha, {"type": "hatcher_surgery", "gamma0": "a_0"})
    inv_post = res.invariants_after
    # σ should have lower level than α
    assert inv_post["level"] <= inv_pre["level"] - 2
