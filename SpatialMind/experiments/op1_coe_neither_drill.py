"""Drill-down on the 6 'neither chordal nor cone' α on S_{2,1} at k=2.

Question: what is the explicit *dominator vertex* that lets DL dismantle?
"""

from __future__ import annotations

import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
    is_dismantlable, has_cone_vertex, is_chordal_peo,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def first_dominator(verts, adj):
    """Find a u that is dominated by some v ≠ u (N[u] ⊆ N[v])."""
    A = {v: set(adj[v]) | {v} for v in verts}
    pairs = []
    for u in verts:
        for v in verts:
            if u == v:
                continue
            if A[u] <= A[v]:
                pairs.append((u, v))
    return pairs


def degree_sequence(verts, adj):
    return sorted([len(adj[v]) for v in verts], reverse=True)


def main():
    eng = SurfaceEngine(
        2, 1,
        database_path=os.path.join(
            ROOT, "workspace", "projects", "op1_geometry", "data_S_2_1.json"))
    cache = IntersectionCache(eng)

    target_alphas = [33, 77, 192, 208, 210, 211]
    out = []
    for idx in target_alphas:
        verts, adj = build_descending_link(cache, idx)
        n = len(verts)
        n_e = sum(len(adj[v]) for v in verts) // 2
        chord, _ = is_chordal_peo(verts, adj)
        cone = has_cone_vertex(verts, adj)
        disman = is_dismantlable(verts, adj)
        dom_pairs = first_dominator(verts, adj)
        # Group dominators by dominator vertex
        from collections import defaultdict
        by_dominator = defaultdict(list)
        for u, v in dom_pairs:
            by_dominator[v].append(u)
        # The dominator with the most "victims" — likely the principal universal-ish vertex
        principal = sorted(by_dominator.items(), key=lambda kv: -len(kv[1]))[:5]
        # Max degree vertices — candidate "near-universal"
        deg = sorted([(v, len(adj[v])) for v in verts], key=lambda kv: -kv[1])
        out.append({
            "alpha": idx, "DL_size": n, "DL_edges": n_e,
            "chordal": chord, "cone": cone, "dismantlable": disman,
            "max_degree": deg[0][1] if deg else None,
            "max_deg_vertex": deg[0][0] if deg else None,
            "min_degree": deg[-1][1] if deg else None,
            "n_dominator_pairs": len(dom_pairs),
            "n_distinct_dominators": len(by_dominator),
            "top_dominators": [(v, len(victims), victims[:3])
                                for v, victims in principal],
            "degree_top10": [(v, d) for v, d in deg[:10]],
        })

    print(json.dumps(out, indent=2))
    with open(os.path.join(os.path.dirname(__file__),
                            "op1_neither_drill.json"), "w") as fh:
        json.dump(out, fh, indent=2)


if __name__ == "__main__":
    main()
