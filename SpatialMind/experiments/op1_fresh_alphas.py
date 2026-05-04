"""Generate FRESH α on S_{1,2} outside the existing DB via mapping class
group orbits, and test the chordal-or-cone dichotomy on them.

Strategy:
  1. Use curver's Dehn twist machinery to twist named curves around
     other named curves, producing α at varying levels.
  2. For each fresh α, build DL using the existing DB as the "vertex
     pool" augmented with twist-generated low-level curves.
  3. Test chordal/cone/dismantlable.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import defaultdict, Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    is_chordal_peo, has_cone_vertex, is_dismantlable,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def dl_with_pool(eng, alpha_lam, pool_lams):
    """Build DL(α) using a fresh α and a pool of candidate β's.

    Returns (DL_indices_in_pool, adj_in_pool).
    """
    gamma0 = eng.S.curves["a_0"]
    k_a = int(gamma0.intersection(alpha_lam))
    DL = []
    for j, beta in enumerate(pool_lams):
        f_b = int(gamma0.intersection(beta))
        if f_b >= k_a:
            continue
        if int(alpha_lam.intersection(beta)) > 1:
            continue
        DL.append(j)
    if not DL:
        return [], {}, {}
    # Pairwise adjacency (cache locally).
    pair_cache = {}
    def pi(a, b):
        key = (min(a, b), max(a, b))
        if key not in pair_cache:
            pair_cache[key] = int(pool_lams[a].intersection(pool_lams[b]))
        return pair_cache[key]
    adj = {j: set() for j in DL}
    for a, b in combinations(DL, 2):
        if pi(a, b) <= 1:
            adj[a].add(b)
            adj[b].add(a)
    return DL, adj, pair_cache


def main():
    db_path = os.path.join(
        ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    pool_lams = list(eng._db["curves"])  # 400 curves
    n_pool = len(pool_lams)
    gamma0 = eng.S.curves["a_0"]
    print(f"Pool: {n_pool} curves", flush=True)

    # Generate fresh α via Dehn twists.
    fresh = []
    a0 = eng.S.curves["a_0"]
    b0 = eng.S.curves["b_0"]
    p1 = eng.S.curves["p_1"]

    # Strategy: take a named curve and apply mapping classes
    # (Dehn twists) to generate fresh α.
    base_curves = {"a_0": a0, "b_0": b0, "p_1": p1}
    twist_curves = {"a_0": a0, "b_0": b0, "p_1": p1}

    print("Generating α via Dehn twists...", flush=True)
    t0 = time.time()

    # Single twist of base by twist_curve, n times.
    for base_name, base in base_curves.items():
        for tw_name, tw in twist_curves.items():
            T = tw.encode_twist()
            cur = base
            for power in range(1, 12):
                cur = T(cur)
                k = int(gamma0.intersection(cur))
                if k >= 2:
                    fresh.append({
                        "construction": f"{base_name} -> T_{tw_name}^{power}",
                        "level": k,
                        "lam": cur,
                    })

    # Compose two different twists.
    for b_name, b in base_curves.items():
        for t1_name, t1 in twist_curves.items():
            for t2_name, t2 in twist_curves.items():
                if t1_name >= t2_name:
                    continue
                T1 = t1.encode_twist()
                T2 = t2.encode_twist()
                cur = b
                for k in range(3):
                    cur = T1(cur)
                    cur = T2(cur)
                    lvl = int(gamma0.intersection(cur))
                    if lvl >= 2:
                        fresh.append({
                            "construction": f"{b_name} -> (T_{t1_name} T_{t2_name})^{k+1}",
                            "level": lvl,
                            "lam": cur,
                        })

    print(f"Generated {len(fresh)} candidate fresh α in {time.time()-t0:.1f}s",
          flush=True)

    # Deduplicate via weight tuple.
    seen = set()
    unique = []
    for r in fresh:
        h = tuple(int(x) for x in tuple(r["lam"]))
        if h in seen:
            continue
        # Skip if it's already in DB.
        if h in {tuple(x) for x in eng._db["hashes"]}:
            continue
        seen.add(h)
        unique.append(r)
    print(f"  unique fresh α (not in DB): {len(unique)}", flush=True)

    # Test each fresh α.
    rows = []
    counters = defaultdict(lambda: {
        "total": 0, "chordal_only": 0, "cone_only": 0,
        "both": 0, "neither": 0, "dismantlable": 0,
    })
    t0 = time.time()
    for idx, r in enumerate(unique[:60]):  # cap to 60 for speed
        DL, adj, _ = dl_with_pool(eng, r["lam"], pool_lams)
        if not DL:
            continue
        chord, _ = is_chordal_peo(DL, adj)
        cone = has_cone_vertex(DL, adj)
        disman = is_dismantlable(DL, adj)
        cat = ("chordal_only" if chord and cone is None
               else "cone_only" if (not chord) and cone is not None
               else "both" if chord and cone is not None
               else "neither")
        rows.append({
            "construction": r["construction"], "level": r["level"],
            "DL_size": len(DL), "chordal": chord, "cone": cone,
            "category": cat, "dismantlable": disman,
        })
        b = counters[r["level"]]
        b["total"] += 1
        b[cat] += 1
        if disman: b["dismantlable"] += 1

    elapsed = time.time() - t0
    print(f"\nTested {len(rows)} fresh α in {elapsed:.1f}s", flush=True)

    print(f"\n  k | n  | chord_only | cone_only | both | neither | disman")
    print(f"----|----|------------|-----------|------|---------|--------")
    for k in sorted(counters):
        b = counters[k]
        print(f"  {k:>2} | {b['total']:>2} | {b['chordal_only']:>10} | "
              f"{b['cone_only']:>9} | {b['both']:>4} | {b['neither']:>7} | "
              f"{b['dismantlable']:>6}", flush=True)

    n_total = sum(b["total"] for b in counters.values())
    n_neither = sum(b["neither"] for b in counters.values())
    n_disman = sum(b["dismantlable"] for b in counters.values())
    print(f"\nTOTAL fresh: {n_total}, chordal-or-cone: {n_total - n_neither} "
          f"({(n_total-n_neither)/max(1,n_total)*100:.1f}%), "
          f"dismantlable: {n_disman} ({n_disman/max(1,n_total)*100:.1f}%)",
          flush=True)

    out = {
        "n_fresh": len(rows),
        "rows": rows,
        "by_level": {str(k): v for k, v in counters.items()},
    }
    out_path = os.path.join(os.path.dirname(__file__), "op1_fresh_alphas.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
