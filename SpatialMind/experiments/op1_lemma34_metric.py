"""Test the integer-label hypothesis: DL(α) at k=2 config (b) is parameterized
by a single integer k ∈ ℤ such that i(β, β') = |k(β) - k(β')|.

If TRUE: max-deg = |V|-1 always (the median element is adjacent to everything
within distance 1), so cone always exists. But this contradicts G*.

So the metric must be more subtle. Let me test: maybe it's |k(β) - k(β')| but
on a DOUBLE COVER, with ℤ_2 partition.
"""

from __future__ import annotations

import os, sys
from collections import defaultdict, Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import IntersectionCache, build_descending_link, has_cone_vertex
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def try_assign_labels(DL, cache):
    """Try to assign integer labels k(β) to each β ∈ DL such that
    i(β, β') = |k(β) - k(β')|. Returns labels dict or None.
    """
    if not DL:
        return None
    # Pick a base vertex with smallest index, assign k = 0.
    base = min(DL)
    labels = {base: 0}
    # BFS: assign labels based on distances.
    # Try multiple starting orientations: pick one neighbor as label = +1.
    neighbors_dist = [(v, cache.i(base, v)) for v in DL if v != base]
    neighbors_dist.sort()
    if not neighbors_dist:
        return labels  # singleton
    # Pick the first neighbor at distance 1 as +1
    plus_one = None
    for v, d in neighbors_dist:
        if d == 1:
            plus_one = v
            break
    if plus_one is None:
        # No distance-1 neighbor — try distance 2
        for v, d in neighbors_dist:
            if d == 2:
                plus_one = v
                break
    if plus_one is None:
        return None
    labels[plus_one] = 1
    # Now: for each remaining v, label k(v) such that
    # |k(v) - k(base)| = i(v, base) AND |k(v) - k(plus_one)| = i(v, plus_one).
    for v in DL:
        if v in labels:
            continue
        d_base = cache.i(v, base)
        d_plus = cache.i(v, plus_one)
        # k(v) ∈ {±d_base}, also satisfies |k(v) - 1| = d_plus
        candidates = [d_base, -d_base]
        valid = [k for k in candidates if abs(k - 1) == d_plus]
        if len(valid) == 1:
            labels[v] = valid[0]
        elif len(valid) > 1:
            labels[v] = valid[0]  # pick one
        else:
            return None  # contradiction
    return labels


def verify_labels(labels, DL, cache):
    """Verify that for all pairs, i(β, β') = |k(β) - k(β')|."""
    fails = []
    for b1, b2 in combinations(DL, 2):
        actual = cache.i(b1, b2)
        predicted = abs(labels[b1] - labels[b2])
        if actual != predicted:
            fails.append((b1, b2, actual, predicted))
    return fails


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f

    # Test on representative α: cone, single-cone, G*
    test_alphas = [13, 25, 40, 68, 122, 145, 170, 216, 217, 322, 386, 387]
    for ai in test_alphas:
        DL, adj = build_descending_link(cache, ai)
        if not DL:
            continue
        cone = has_cone_vertex(DL, adj)
        labels = try_assign_labels(DL, cache)
        fails = verify_labels(labels, DL, cache) if labels else None
        status = (
            "FAIL: no labels" if labels is None else
            f"PASS (single label, max={max(labels.values())}, min={min(labels.values())})"
            if not fails else
            f"FAIL: {len(fails)} pairs miss"
        )
        print(f"α={ai:>3} |DL|={len(DL):>2} cone={cone} status: {status}",
              flush=True)
        if labels:
            print(f"  labels: {sorted(labels.items())}", flush=True)
        if fails:
            for fail in fails[:3]:
                print(f"  fail: i(c{fail[0]}, c{fail[1]}) = {fail[2]}, "
                      f"predicted = {fail[3]}", flush=True)


if __name__ == "__main__":
    main()
