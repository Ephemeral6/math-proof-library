"""Step-3 (Dehn-Thurston domination) brute-force check.

For each candidate fixed background pair (v, u), test:
  ∀α with f(α) ≥ 2, v, u ∈ DL(α):
    ∀β ∈ N_{DL(α)}[u]:  i(v, β) ≤ 1?

Equivalently: N_{DL(α)}[u] ⊆ N_{DL(α)}[v] (i.e. v dominates u in DL(α)).

Also tabulates which α the FIXED pair fails on, and what β witnesses
failure — so we can see whether α is still covered by another fixed pair.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import defaultdict, Counter
from itertools import product

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
)
from SpatialMind.experiments.op1_proof_probe import find_sigma_idx
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def alphas_with_pair_in_DL(cache, v, u):
    """Return all α with f(α) ≥ 2, i(α, v) ≤ 1, i(α, u) ≤ 1, v, u ≠ α."""
    f = cache.f
    return [
        ai for ai in range(cache.n)
        if ai != v and ai != u
        and f[ai] >= 2
        and f[v] < f[ai] and f[u] < f[ai]
        and cache.i(ai, v) <= 1 and cache.i(ai, u) <= 1
    ]


def test_pair_on_alpha(cache, alpha_idx, v, u):
    """For this α, build DL(α), build N_DL[u], check whether
    every β in N_DL[u] satisfies i(v, β) ≤ 1.

    Returns (success, counterexample_betas).
    """
    f = cache.f
    k = f[alpha_idx]
    DL = []
    for j in range(cache.n):
        if j == alpha_idx:
            continue
        if f[j] < k and cache.i(alpha_idx, j) <= 1:
            DL.append(j)
    if u not in DL or v not in DL:
        return None, []  # pair not even in DL; skip
    # N_DL[u] = {u} ∪ {β ∈ DL : i(u, β) ≤ 1}
    N_u = [u] + [b for b in DL if b != u and cache.i(u, b) <= 1]
    counterexamples = []
    for b in N_u:
        if b == v:
            continue
        if cache.i(v, b) > 1:
            counterexamples.append({
                "beta": b, "level_beta": f[b],
                "i_alpha_beta": cache.i(alpha_idx, b),
                "i_u_beta": cache.i(u, b),
                "i_v_beta": cache.i(v, b),
            })
    return (len(counterexamples) == 0), counterexamples


def main():
    db_root = os.path.join(ROOT, "workspace", "projects", "op1_geometry")

    # Candidate background pairs to test, per surface.
    # Each entry: (label, list of (v, u)).
    candidates = {
        "S_1_2": [(2, 1), (7, 1), (8, 1), (22, 1), (1, 2), (2, 5),
                  (25, 1), (1, 7), (4, 1), (3, 1), (6, 1), (10, 1),
                  (11, 2), (21, 1), (13, 1)],
        "S_1_1": [],  # DL=K_2 always, no need
        "S_2_1": [(5, 1), (2, 1), (4, 1), (5, 2), (2, 5), (23, 2)],
    }

    surfaces = [
        ("S_1_2", 1, 2, os.path.join(db_root, "data_S_1_2.json")),
        ("S_2_1", 2, 1, os.path.join(db_root, "data_S_2_1.json")),
    ]

    out = {"per_surface": {}, "summary": {}}

    for label, g, n, path in surfaces:
        print(f"\n=== {label} ===", flush=True)
        eng = SurfaceEngine(g, n, database_path=path)
        cache = IntersectionCache(eng)
        f = cache.f

        out["per_surface"][label] = {}

        # Universe of α's at level >= 2.
        all_alphas = [i for i in range(cache.n) if f[i] >= 2]
        print(f"  total α (f≥2): {len(all_alphas)}", flush=True)

        per_pair = {}
        # Track per-α coverage across the candidate pair set.
        alpha_covered_by = defaultdict(list)  # α → list of (v,u) that work

        for (v, u) in candidates.get(label, []):
            t0 = time.time()
            print(f"\n  testing fixed pair (v={v}, u={u}) [f(v)={f[v]}, f(u)={f[u]}, i(v,u)={cache.i(v, u)}]",
                  flush=True)
            applicable_alphas = alphas_with_pair_in_DL(cache, v, u)
            print(f"    applicable α (with v,u ∈ DL): {len(applicable_alphas)} of {len(all_alphas)}",
                  flush=True)
            n_success = 0
            failures = []  # list of {alpha, counterexamples}
            for ai in applicable_alphas:
                ok, cex = test_pair_on_alpha(cache, ai, v, u)
                if ok is None:
                    continue
                if ok:
                    n_success += 1
                    alpha_covered_by[ai].append((v, u))
                else:
                    failures.append({
                        "alpha": ai, "level_alpha": f[ai],
                        "n_cex": len(cex), "cex": cex[:3],
                    })
            per_pair[f"({v},{u})"] = {
                "v": v, "u": u, "f_v": f[v], "f_u": f[u],
                "i_v_u": cache.i(v, u),
                "applicable_alphas": len(applicable_alphas),
                "successful_alphas": n_success,
                "failure_count": len(failures),
                "failures_sample": failures[:6],
            }
            elapsed = time.time() - t0
            rate = (n_success / max(1, len(applicable_alphas))) * 100
            print(f"    success: {n_success}/{len(applicable_alphas)} ({rate:.1f}%), "
                  f"failures: {len(failures)}, {elapsed:.1f}s",
                  flush=True)

        # Coverage analysis: is every α covered by SOME pair?
        covered = set(alpha_covered_by.keys())
        uncovered = [ai for ai in all_alphas if ai not in covered]
        print(f"\n  α covered by ≥1 candidate pair: {len(covered)}/{len(all_alphas)}",
              flush=True)
        print(f"  α uncovered: {len(uncovered)}", flush=True)
        # If small uncovered set, show them
        uncov_info = []
        for ai in uncovered[:8]:
            uncov_info.append({"alpha": ai, "level": f[ai]})

        out["per_surface"][label] = {
            "n_alphas_total": len(all_alphas),
            "n_covered": len(covered),
            "n_uncovered": len(uncovered),
            "uncovered_sample": uncov_info,
            "per_pair": per_pair,
        }

    out_path = os.path.join(os.path.dirname(__file__), "op1_step3_test.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
