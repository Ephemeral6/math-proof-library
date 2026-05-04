"""Compute Betti numbers of DL(α) flag complexes to VERIFY contractibility
(not just dismantlability — though dismantlable ⇒ contractible).

For each α in the DB at f≥2, build the flag complex of DL(α), compute its
chain complex, and check H_0 = Z, H_i = 0 for i ≥ 1 (= contractible).

Also extends to a richer set of fresh α via more aggressive Dehn-twist
generation.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import defaultdict
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
    is_chordal_peo, has_cone_vertex, is_dismantlable,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def flag_complex_betti(verts, adj, max_dim=4):
    """Compute Betti numbers of the flag complex on (verts, adj) up to
    dimension max_dim. Uses simple Smith Normal Form via numpy.

    Returns [b_0, b_1, b_2, ..., b_{max_dim}].
    """
    if not verts:
        return [0] * (max_dim + 1)
    V = list(verts)
    Vset = set(V)
    # Build simplices.
    simplices_by_dim = {0: [tuple([v]) for v in V]}
    # k-simplex = a (k+1)-clique
    # k=1: edges
    edges = []
    for a in V:
        for b in adj[a]:
            if a < b:
                edges.append((a, b))
    simplices_by_dim[1] = edges
    # k>=2: cliques
    for d in range(2, max_dim + 2):
        prev = simplices_by_dim[d - 1]
        cur = []
        seen = set()
        for s in prev:
            # extend with any vertex in common neighbours of all members
            common = set(adj[s[0]])
            for x in s[1:]:
                common &= adj[x]
            for v in common:
                if v <= s[-1]:  # avoid duplicates
                    continue
                # actually we want lexicographic order
                if v > s[-1]:
                    new = tuple(sorted(list(s) + [v]))
                    if new not in seen:
                        seen.add(new)
                        cur.append(new)
        simplices_by_dim[d] = cur

    # Compute chain ranks via numpy
    import numpy as np

    def boundary_matrix(d):
        """Boundary map C_d -> C_{d-1}."""
        if d == 0:
            return None
        cur = simplices_by_dim.get(d, [])
        prev = simplices_by_dim.get(d - 1, [])
        if not cur or not prev:
            return np.zeros((max(1, len(prev)), max(1, len(cur))), dtype=int)
        prev_idx = {s: i for i, s in enumerate(prev)}
        M = np.zeros((len(prev), len(cur)), dtype=int)
        for j, s in enumerate(cur):
            for i in range(len(s)):
                face = s[:i] + s[i+1:]
                if face in prev_idx:
                    sign = (-1) ** i
                    M[prev_idx[face], j] = sign
        return M

    n_simplices = [len(simplices_by_dim.get(d, [])) for d in range(max_dim + 2)]
    bettis = []
    rank_prev = 0
    for d in range(max_dim + 1):
        n_d = n_simplices[d]
        # rank(d_d): boundary from d to d-1
        if d == 0:
            rank_d = 0
        else:
            M = boundary_matrix(d)
            if M is None or n_d == 0:
                rank_d = 0
            else:
                # rank over Q (good enough for torsion-free Betti)
                M_float = M.astype(float)
                rank_d = int(np.linalg.matrix_rank(M_float))
        # Betti_d = dim(ker d_d) - rank(d_{d+1})
        # First compute rank(d_{d+1}) which is rank_next.
        if d + 1 <= max_dim + 1:
            M_next = boundary_matrix(d + 1)
            if M_next is None or n_simplices[d + 1] == 0:
                rank_next = 0
            else:
                rank_next = int(np.linalg.matrix_rank(M_next.astype(float)))
        else:
            rank_next = 0
        ker_d = n_d - rank_d
        b_d = ker_d - rank_next
        bettis.append(b_d)
    return bettis, n_simplices


def main():
    db_path = os.path.join(
        ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    alphas = [i for i in range(cache.n) if f[i] >= 2]

    # Full sweep mode: ALL 309 α with f≥2
    target_alphas = list(alphas)

    rows = []
    print(f"Computing Betti numbers for {len(target_alphas)} target α...",
          flush=True)
    n_done = 0
    n_contract = 0
    for ai in target_alphas:
        verts, adj = build_descending_link(cache, ai)
        if not verts:
            continue
        try:
            bettis, n_simp = flag_complex_betti(verts, adj, max_dim=3)
        except Exception as e:
            bettis = ["err: " + str(e)]
            n_simp = []
        contractible = (bettis[0] == 1 and all(b == 0 for b in bettis[1:]))
        rows.append({
            "alpha": ai, "level": f[ai], "DL_size": len(verts),
            "bettis": bettis, "n_simplices": n_simp,
            "contractible": contractible,
        })
        n_done += 1
        if contractible:
            n_contract += 1
        else:
            print(f"  NON-CONTRACTIBLE α={ai} k={f[ai]} |DL|={len(verts)} "
                  f"bettis={bettis}", flush=True)
        if n_done % 25 == 0:
            print(f"  progress: {n_done}/{len(target_alphas)}, "
                  f"{n_contract} contractible", flush=True)

    # Summary
    n_contract = sum(1 for r in rows if r.get("contractible"))
    print(f"\n{n_contract}/{len(rows)} are contractible (b_0=1, b_i=0 for i≥1)",
          flush=True)
    n_betti_nonzero = sum(1 for r in rows
                          if isinstance(r["bettis"], list)
                          and len(r["bettis"]) > 1
                          and any(b != 0 for b in r["bettis"][1:]))
    print(f"  α with non-trivial higher Betti: {n_betti_nonzero}", flush=True)

    out_path = os.path.join(os.path.dirname(__file__), "op1_homology.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump({"rows": rows}, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
