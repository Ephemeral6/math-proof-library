"""Explicit (side, twist) parameterization test on Σ_{0,4}.

Goal: for α at k=2 config (b), parameterize each β ∈ DL(α) as (side, twist)
where side ∈ {1, 2} indicates which α-arc β crosses, and twist counts windings.

Test: verify that intersection numbers between DL vertices follow a
Manhattan-style metric on the parameters.
"""

from __future__ import annotations

import json
import os
import sys
from collections import defaultdict, Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link, has_cone_vertex,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    pool = list(eng._db["curves"])

    # Test on α=13 (cone case, |DL|=12)
    ai = 13
    DL, adj = build_descending_link(cache, ai)
    cone = has_cone_vertex(DL, adj)
    print(f"α={ai}, |DL|={len(DL)}, cone={cone}", flush=True)

    # For each pair β, β' ∈ DL, compute i(β, β').
    print("\nIntersection matrix:")
    print("    " + " ".join(f"c{b:>3}" for b in DL))
    for b1 in DL:
        row = [f"{cache.i(b1, b2):>3}" for b2 in DL]
        print(f"c{b1:>3} " + " ".join(row))

    # Look for "side" partition: vertices with similar intersection patterns.
    # Define: distance(b1, b2) = i(b1, b2) — adjacency = distance ≤ 1.
    # Group by adjacency.
    adj_set = {v: frozenset(adj[v]) | {v} for v in DL}
    same_group = defaultdict(list)
    for v in DL:
        same_group[adj_set[v]].append(v)
    print(f"\nGrouping by closed neighborhood (= same N[v]): {len(same_group)} groups")
    for ng, vs in same_group.items():
        if len(vs) > 1:
            print(f"  group of {len(vs)}: {vs}")

    # Try: group by intersection-with-α (should all be 1 for k=2 config(b))
    print(f"\ni(α, β) for each β: " +
          ", ".join(f"c{b}={cache.i(ai, b)}" for b in DL))

    # Try: group by which α-arc β is "associated with" via a curve relation.
    # Heuristic: β might cross a specific PARALLEL curve at level 1.
    # We don't have direct access to a_1, a_2 as separate curves, but we can
    # pick a "reference" — say, the cone vertex itself — and partition based
    # on whether β is adjacent to cone with i=0 or i=1.
    print(f"\nPartition DL by i(cone, β):")
    side_partition = defaultdict(list)
    for b in DL:
        side_partition[cache.i(cone, b)].append(b)
    for ic, vs in sorted(side_partition.items()):
        print(f"  i(cone, β)={ic}: {vs}")

    # Now: in DL\{cone}, examine structure.
    # The "side 1" partition might correspond to vertices with i(cone, β) = 0
    # (= disjoint from cone, hence on the "same side").
    # The "side 2" partition: i(cone, β) = 1 (= crosses cone, hence opposite side).
    # Test: within each partition, compute pairwise i.
    p0 = side_partition.get(0, [])
    p1 = side_partition.get(1, [])
    print(f"\nWithin partition 0 (i(cone, β)=0, len={len(p0)}):")
    for b1, b2 in combinations(p0, 2):
        print(f"  i(c{b1}, c{b2}) = {cache.i(b1, b2)}")
    print(f"\nWithin partition 1 (i(cone, β)=1, len={len(p1)}):")
    for b1, b2 in combinations(p1, 2):
        print(f"  i(c{b1}, c{b2}) = {cache.i(b1, b2)}")

    # Also: across partitions
    print(f"\nAcross partitions (i(cone, β)=0 vs =1):")
    for b1 in p0:
        for b2 in p1:
            print(f"  i(c{b1}, c{b2}) = {cache.i(b1, b2)}")


if __name__ == "__main__":
    main()
