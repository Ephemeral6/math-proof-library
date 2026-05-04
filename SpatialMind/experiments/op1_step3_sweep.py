"""Comprehensive Step-3 sweep.

Phase 1: For S_{2,1}, locate the SMALLEST set of fixed (v, u) pairs that
achieves 100% coverage. (Empirically (5,1) already gets 96%; check if
(5,1) + one more pair closes the gap.)

Phase 2: For S_{1,2}, sweep ALL low-level pairs (v, u) with f(v), f(u) ≤ 2
and i(v, u) ≤ 1, and tabulate which α each pair covers. Output: matrix of
(α, pair) → covered, and the minimum pair count to cover all α.

Phase 3: For each α uncovered by the chosen menu, find its actual
lex-first dominator pair. Output the per-α dominator menu.
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
    IntersectionCache, build_descending_link,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def alphas_where_pair_works(cache, v, u, all_alphas):
    """For fixed (v, u): list of α where (a) v, u ∈ DL(α) and
    (b) v dominates u in DL(α)."""
    f = cache.f
    works = []
    for ai in all_alphas:
        if ai == v or ai == u:
            continue
        if f[v] >= f[ai] or f[u] >= f[ai]:
            continue
        if cache.i(ai, v) > 1 or cache.i(ai, u) > 1:
            continue
        # Build DL.
        DL = []
        for j in range(cache.n):
            if j == ai:
                continue
            if f[j] < f[ai] and cache.i(ai, j) <= 1:
                DL.append(j)
        if u not in DL or v not in DL:
            continue
        # N_DL[u] = {u} ∪ {β ∈ DL : i(u, β) ≤ 1}
        ok = True
        for b in DL:
            if b == u or b == v:
                continue
            if cache.i(u, b) <= 1 and cache.i(v, b) > 1:
                ok = False
                break
        if ok:
            works.append(ai)
    return works


def find_first_dominator(cache, alpha_idx):
    """For α, return (u*, v*) — first u dominated by some v in DL."""
    f = cache.f
    k = f[alpha_idx]
    DL = []
    for j in range(cache.n):
        if j == alpha_idx:
            continue
        if f[j] < k and cache.i(alpha_idx, j) <= 1:
            DL.append(j)
    if not DL:
        return None, None
    adj = {x: set() for x in DL}
    for a, b in combinations(DL, 2):
        if cache.i(a, b) <= 1:
            adj[a].add(b)
            adj[b].add(a)
    A = {x: set(adj[x]) | {x} for x in DL}
    for u in DL:
        for v in DL:
            if u == v:
                continue
            if A[u] <= A[v]:
                return u, v
    return None, None


def main():
    db_root = os.path.join(ROOT, "workspace", "projects", "op1_geometry")
    out = {}

    # ----------------------------------------------------------
    # Phase 1: Close S_{2,1} coverage.
    # ----------------------------------------------------------
    print("\n=== Phase 1: S_{2,1} closure ===", flush=True)
    eng21 = SurfaceEngine(2, 1, database_path=os.path.join(db_root, "data_S_2_1.json"))
    cache21 = IntersectionCache(eng21)
    all_alphas_21 = [i for i in range(cache21.n) if cache21.f[i] >= 2]
    print(f"  total α (f≥2): {len(all_alphas_21)}", flush=True)

    # Anchor pair (5, 1) — covered 45/47.
    covered_by_5_1 = set(alphas_where_pair_works(cache21, 5, 1, all_alphas_21))
    uncovered = [a for a in all_alphas_21 if a not in covered_by_5_1]
    print(f"  (5,1) covers {len(covered_by_5_1)}/{len(all_alphas_21)}; "
          f"uncovered α: {uncovered}", flush=True)

    # For uncovered α, find their actual dominator pairs.
    uncov_dominators = {}
    for ai in uncovered:
        u_star, v_star = find_first_dominator(cache21, ai)
        uncov_dominators[ai] = {
            "alpha": ai, "level": cache21.f[ai],
            "u_star": u_star, "v_star": v_star,
            "f_v": cache21.f[v_star] if v_star is not None else None,
            "f_u": cache21.f[u_star] if u_star is not None else None,
        }
    print(f"  uncovered α dominators: {uncov_dominators}", flush=True)

    # Test additional pairs from the uncovered α dominators.
    extra_pairs = set()
    for info in uncov_dominators.values():
        if info["v_star"] is not None and info["u_star"] is not None:
            extra_pairs.add((info["v_star"], info["u_star"]))
    print(f"  trying extra pairs: {extra_pairs}", flush=True)

    menu_21 = [(5, 1)]
    cumul = set(covered_by_5_1)
    for (v, u) in extra_pairs:
        works = set(alphas_where_pair_works(cache21, v, u, all_alphas_21))
        new_covered = works - cumul
        if new_covered:
            menu_21.append((v, u))
            cumul |= works
            print(f"  + ({v},{u}): adds {len(new_covered)} new α; cumul={len(cumul)}",
                  flush=True)

    out["S_2_1"] = {
        "n_total": len(all_alphas_21),
        "covered_by_5_1": len(covered_by_5_1),
        "menu": [list(p) for p in menu_21],
        "menu_total_coverage": len(cumul),
        "uncovered_after_menu": [a for a in all_alphas_21 if a not in cumul],
        "uncov_dominators_initial": uncov_dominators,
    }

    # ----------------------------------------------------------
    # Phase 2: S_{1,2} comprehensive low-level pair sweep.
    # ----------------------------------------------------------
    print("\n=== Phase 2: S_{1,2} comprehensive sweep ===", flush=True)
    eng12 = SurfaceEngine(1, 2, database_path=os.path.join(db_root, "data_S_1_2.json"))
    cache12 = IntersectionCache(eng12)
    all_alphas_12 = [i for i in range(cache12.n) if cache12.f[i] >= 2]
    print(f"  total α (f≥2): {len(all_alphas_12)}", flush=True)

    # Candidate pool: (v, u) with f(v), f(u) ≤ 2, i(v, u) ≤ 1.
    low_v = [i for i in range(cache12.n) if cache12.f[i] <= 2]
    print(f"  low-level candidate vertices (f ≤ 2): {len(low_v)}", flush=True)

    # Sweep all (v, u) pairs with v ≠ u, i(v, u) ≤ 1.
    cand_pairs = []
    for v in low_v:
        for u in low_v:
            if u == v:
                continue
            if cache12.i(v, u) <= 1:
                cand_pairs.append((v, u))
    print(f"  candidate (v, u) pairs: {len(cand_pairs)}", flush=True)

    # For each pair, count which α it covers.
    # To save time, only run on pairs that have at least 5 applicable α
    # (filter quickly).
    pair_coverage = {}
    print(f"  testing pairs (this may take a while)...", flush=True)
    t0 = time.time()
    for idx_p, (v, u) in enumerate(cand_pairs):
        if idx_p % 500 == 0:
            print(f"    {idx_p}/{len(cand_pairs)}, elapsed {time.time() - t0:.1f}s",
                  flush=True)
        works = alphas_where_pair_works(cache12, v, u, all_alphas_12)
        if works:
            pair_coverage[(v, u)] = set(works)

    print(f"  pairs with non-empty coverage: {len(pair_coverage)}, "
          f"{time.time() - t0:.1f}s", flush=True)

    # Greedy set cover.
    cumul = set()
    menu_12 = []
    while True:
        # find pair with max marginal coverage
        best = None
        best_n = 0
        for (v, u), s in pair_coverage.items():
            new = len(s - cumul)
            if new > best_n:
                best = (v, u); best_n = new
        if best is None or best_n == 0:
            break
        menu_12.append(best)
        cumul |= pair_coverage[best]
        if len(menu_12) >= 25:
            break

    print(f"\n  greedy set-cover menu (top {len(menu_12)}):", flush=True)
    for (v, u) in menu_12:
        n_cov = len(pair_coverage[(v, u)])
        print(f"    (v={v}, u={u}): covers {n_cov} α  [f(v)={cache12.f[v]}, "
              f"f(u)={cache12.f[u]}, i(v,u)={cache12.i(v, u)}]",
              flush=True)
    print(f"  total covered: {len(cumul)}/{len(all_alphas_12)}", flush=True)
    uncovered_12 = [a for a in all_alphas_12 if a not in cumul]
    print(f"  uncovered after menu: {len(uncovered_12)}", flush=True)

    # For first 10 uncovered α, find their actual dominator.
    uncov_dom_12 = []
    for ai in uncovered_12[:15]:
        u_star, v_star = find_first_dominator(cache12, ai)
        uncov_dom_12.append({
            "alpha": ai, "level": cache12.f[ai],
            "u_star": u_star, "v_star": v_star,
            "f_v": cache12.f[v_star] if v_star is not None else None,
            "f_u": cache12.f[u_star] if u_star is not None else None,
        })

    out["S_1_2"] = {
        "n_total": len(all_alphas_12),
        "candidate_pairs_tried": len(cand_pairs),
        "pairs_with_coverage": len(pair_coverage),
        "menu_size": len(menu_12),
        "menu": [{"pair": list(p), "covered": len(pair_coverage[p])}
                 for p in menu_12],
        "menu_total_coverage": len(cumul),
        "uncovered_after_menu": uncovered_12[:50],
        "uncovered_total": len(uncovered_12),
        "uncovered_α_dominators_sample": uncov_dom_12,
    }

    out_path = os.path.join(os.path.dirname(__file__), "op1_step3_sweep.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
