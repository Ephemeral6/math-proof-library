"""Test the JOIN-structure hypothesis:
DL(α) = K_n_cone ∨ G_outer, where K_n_cone is a complete graph on cone vertices
adjacent to all other vertices (the "core"), and G_outer is the induced subgraph
on the remaining outer vertices.

If TRUE: max-deg(DL) = |V|-1 always for non-G* cases.
For G* cases: the structure is "balanced" with no single universal vertex.

For each α at k=2 config (b), determine:
- cone vertices (universal, degree |V|-1)
- semi-cone vertices (degree |V|-2)
- partition by neighborhood
"""

from __future__ import annotations

import os, sys, json
from collections import Counter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import IntersectionCache, build_descending_link
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f

    # Test all 33 config(b) α
    config_b_alphas = []
    for ai in range(cache.n):
        if f[ai] != 2:
            continue
        DL, adj = build_descending_link(cache, ai)
        if not DL:
            continue
        if all(cache.i(ai, b) == 1 for b in DL):
            config_b_alphas.append(ai)

    print(f"Testing JOIN structure on {len(config_b_alphas)} α at k=2 config (b)\n",
          flush=True)

    join_pattern = Counter()
    for ai in config_b_alphas:
        DL, adj = build_descending_link(cache, ai)
        n_v = len(DL)
        # Identify cone vertices (deg = |V|-1)
        cones = [v for v in DL if len(adj[v]) == n_v - 1]
        # Identify near-cone vertices (deg = |V|-2)
        near_cones = [v for v in DL if len(adj[v]) == n_v - 2]
        # Outer = not cone, not near-cone (deg ≤ |V|-3)
        outer = [v for v in DL if len(adj[v]) <= n_v - 3]

        # JOIN structure: do cones form a clique, and is each cone adjacent
        # to every non-cone vertex?
        if cones:
            cones_clique = all(c2 in adj[c1] for c1 in cones for c2 in cones if c1 != c2)
            cones_join = all(v in adj[c] for c in cones for v in DL if v != c)
        else:
            cones_clique = False
            cones_join = False

        # K_4 substructure for G*: 4 near-cones forming K_4
        if len(near_cones) == 4:
            k4 = all(b in adj[a] for a in near_cones for b in near_cones if a != b)
            # Each near-cone misses exactly one outer (paired)
            paired = True
            for nc in near_cones:
                missed = [v for v in DL if v not in adj[nc] and v != nc]
                if len(missed) != 1:
                    paired = False
                    break
        else:
            k4 = False
            paired = False

        # Pattern signature
        pat = (len(cones), len(near_cones), len(outer))
        join_pattern[pat] += 1
        print(f"α={ai:>3} |V|={n_v:>2} cones={len(cones)} near={len(near_cones)} "
              f"outer={len(outer)} cones_clique={cones_clique} "
              f"cones_join={cones_join} K4_near={k4} G*_paired={paired}",
              flush=True)

    print(f"\n=== Pattern (n_cones, n_near, n_outer) frequency ===")
    for pat, c in sorted(join_pattern.items()):
        print(f"  {pat}: {c}")

    print(f"\n=== Summary ===")
    print(f"  Total: {sum(join_pattern.values())}")
    print(f"  Patterns with cones=1 (single cone): {sum(c for p, c in join_pattern.items() if p[0] == 1)}")
    print(f"  Patterns with cones=2 (double cone): {sum(c for p, c in join_pattern.items() if p[0] == 2)}")
    print(f"  Patterns with cones=0, near=4 (G*): {sum(c for p, c in join_pattern.items() if p[0] == 0 and p[1] == 4)}")


if __name__ == "__main__":
    main()
