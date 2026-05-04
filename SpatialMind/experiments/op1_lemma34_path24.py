"""Paths 2 & 4: Farey arithmetic and dismantlability pattern.

Path 2: For each α at k=2 config (b), compute the "side partition":
  DL_1 = arcs in DL crossing a_1 once, disjoint from a_2
  DL_2 = arcs in DL crossing a_2 once, disjoint from a_1
The cone vertex δ should sit in one of {DL_1, DL_2} and dominate everything.

Path 4: For each DL(α), find an EXPLICIT dismantling order. Identify
patterns: is the order always "remove far-from-cone first" or similar?
"""

from __future__ import annotations

import json
import os
import sys
from collections import Counter, defaultdict
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link, has_cone_vertex, is_chordal_peo,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def find_dismantling_order(verts, adj):
    """Greedy dismantling: at each step, pick the lex-smallest vertex u
    that is dominated by some v. Return the order, or None if not
    dismantlable.
    """
    V = set(verts)
    A = {v: set(adj[v]) for v in verts}
    order = []
    while len(V) > 1:
        progress = False
        for u in sorted(V):
            Nu = A[u] | {u}
            for v in sorted(V):
                if v == u:
                    continue
                Nv = A[v] | {v}
                if Nu <= Nv:
                    order.append({"removed": u, "dominator": v})
                    V.remove(u)
                    for w in A[u]:
                        A[w].discard(u)
                    A.pop(u)
                    progress = True
                    break
            if progress:
                break
        if not progress:
            return None
    if V:
        order.append({"final": next(iter(V))})
    return order


def main():
    db_path = os.path.join(
        ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f

    cone_alphas = [13, 40, 42, 68, 74, 113, 121, 122, 126, 127, 145, 156, 170,
                   201, 210, 212, 216, 222, 322, 359, 371, 373, 374, 376, 386,
                   387, 389]

    out = {"alphas": []}
    print("=== Per-α DL dismantling order ===\n", flush=True)

    for ai in cone_alphas:
        DL, adj = build_descending_link(cache, ai)
        cone = has_cone_vertex(DL, adj)
        order = find_dismantling_order(DL, adj)
        # The dominator of cone is itself (last to be removed).
        # Compute the "domination structure" — for each non-cone vertex u,
        # is u dominated by cone? (Should be yes since cone is universal.)
        dominators_of = {}
        for u in DL:
            if u == cone:
                continue
            doms = []
            Nu = set(adj[u]) | {u}
            for v in DL:
                if v == u:
                    continue
                Nv = set(adj[v]) | {v}
                if Nu <= Nv:
                    doms.append(v)
            dominators_of[u] = doms
        # All non-cone u should have cone in their dominators.
        all_dom_by_cone = all(cone in doms for u, doms in dominators_of.items())
        # Number of dominators per u
        dom_count = sorted([len(doms) for doms in dominators_of.values()])
        # Print summary
        print(f"α={ai:>3} |DL|={len(DL):>2} cone={cone:>3} "
              f"all_dominated_by_cone={all_dom_by_cone} "
              f"per-vertex dominator counts: {dom_count}",
              flush=True)
        # Save
        out["alphas"].append({
            "alpha": ai,
            "DL_size": len(DL),
            "cone": cone,
            "all_dominated_by_cone": all_dom_by_cone,
            "dominator_counts": dom_count,
        })

    # Aggregate stats
    n_with_cone_dom_all = sum(1 for r in out["alphas"]
                              if r["all_dominated_by_cone"])
    print(f"\n{n_with_cone_dom_all}/{len(out['alphas'])} α have ALL non-cone "
          f"vertices dominated by the cone vertex.", flush=True)

    # ------------------------------------------------------------------
    # Path 2: side-partition analysis. Conjecturally, DL splits into
    # DL_1 ∪ DL_2 where each side is a "fan" around one α-arc.
    # ------------------------------------------------------------------

    # We can't directly compute "which α-arc β crosses" without surface
    # topology data. However, we CAN test a graph property: does DL split
    # into two cliques + cross-edges?
    print("\n=== Path 2: testing if DL has a 'two-fan' structure ===\n",
          flush=True)
    for ai in cone_alphas[:6]:
        DL, adj = build_descending_link(cache, ai)
        cone = has_cone_vertex(DL, adj)
        # Group vertices by their distance to cone in DL graph (0, 1, 2+)
        # Since cone is adjacent to ALL, all vertices are at distance ≤ 1 from cone.
        # Subgraph induced on DL \ {cone}: what's its structure?
        DL_minus_cone = [v for v in DL if v != cone]
        # Count edges in subgraph
        adj_sub = {v: adj[v] - {cone} for v in DL_minus_cone}
        edges_sub = sum(len(adj_sub[v]) for v in DL_minus_cone) // 2
        # Connected components in subgraph
        seen = set()
        components = []
        for v in DL_minus_cone:
            if v in seen:
                continue
            comp = set()
            stack = [v]
            while stack:
                x = stack.pop()
                if x in seen:
                    continue
                seen.add(x)
                comp.add(x)
                for nb in adj_sub.get(x, set()):
                    if nb not in seen:
                        stack.append(nb)
            components.append(comp)
        comp_sizes = sorted([len(c) for c in components], reverse=True)
        print(f"α={ai:>3}: DL\\{{cone}} has {len(DL_minus_cone)} vertices, "
              f"{edges_sub} edges, components: {comp_sizes}",
              flush=True)

    out_path = os.path.join(os.path.dirname(__file__), "op1_lemma34_path24.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
