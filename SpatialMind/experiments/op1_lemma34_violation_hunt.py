"""Hunt for violations of JOIN-or-G* dichotomy via aggressive Dehn-twist
generation + investigate topological invariant distinguishing G* from JOIN.
"""

from __future__ import annotations

import os, sys, time, json
from collections import Counter, defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import IntersectionCache, build_descending_link
from SpatialMind.experiments.op1_lemma34_extend import build_DL_with_pool
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def is_join_or_gstar(DL, adj):
    """Return ('JOIN', m_cones) or ('G_star', None) or ('VIOLATION', info)."""
    n_v = len(DL)
    cones = [v for v in DL if len(adj[v]) == n_v - 1]
    near = [v for v in DL if len(adj[v]) == n_v - 2]
    if cones:
        # JOIN test
        cones_clique = all(c2 in adj[c1] for c1 in cones for c2 in cones if c1 != c2)
        cones_join = all(v in adj[c] for c in cones for v in DL if v != c)
        if cones_clique and cones_join:
            return ('JOIN', len(cones))
    if n_v == 8 and len(near) == 4 and not cones:
        # G* test
        k4 = all(b in adj[a] for a in near for b in near if a != b)
        paired = True
        for nc in near:
            missed = [v for v in DL if v not in adj[nc] and v != nc]
            if len(missed) != 1:
                paired = False; break
        if k4 and paired:
            return ('G_star', None)
    return ('VIOLATION', {'V': n_v, 'cones': len(cones), 'near': len(near)})


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    pool = list(eng._db['curves'])
    gamma0 = eng.S.curves['a_0']
    f = [int(gamma0.intersection(c)) for c in pool]
    twists = {n: eng.S.curves[n].encode_twist() for n in ['a_0', 'b_0', 'p_1']}

    # Fast generation: pick a few seeds, apply random twist sequences.
    seeds = [13, 25, 40, 42, 68, 113, 121, 122, 127, 145, 170, 216, 322, 359]
    n_join = 0
    n_gstar = 0
    n_violation = 0
    seen = set()
    weights_to_alpha_invariant = defaultdict(list)  # store G* invariants
    g_star_alphas = []
    join_alphas = []
    n_total = 0
    target = 500

    t0 = time.time()
    for seed_idx, seed in enumerate(seeds):
        if n_total >= target: break
        rep_lam = pool[seed]
        # BFS up to depth 4, all twist combinations
        queue = [(rep_lam, 0)]
        while queue and n_total < target:
            cur, depth = queue.pop(0)
            if depth >= 4: continue
            for tw_name, T in twists.items():
                if n_total >= target: break
                # Try powers 1..4
                cur_pow = cur
                for power in range(1, 5):
                    if n_total >= target: break
                    cur_pow = T(cur_pow)
                    w_new = tuple(int(x) for x in tuple(cur_pow))
                    if w_new in seen: continue
                    seen.add(w_new)
                    k_new = int(gamma0.intersection(cur_pow))
                    if k_new != 2:
                        if depth < 4: queue.append((cur_pow, depth + 1))
                        continue
                    DL, adj = build_DL_with_pool(eng, cur_pow, pool)
                    if DL is None or not DL: continue
                    if not all(int(cur_pow.intersection(pool[b])) == 1 for b in DL): continue
                    n_total += 1
                    result = is_join_or_gstar(DL, adj)
                    if result[0] == 'JOIN':
                        n_join += 1
                        join_alphas.append({'w': list(w_new), 'm': result[1]})
                    elif result[0] == 'G_star':
                        n_gstar += 1
                        g_star_alphas.append({'w': list(w_new)})
                    else:
                        n_violation += 1
                        print(f"VIOLATION: w={list(w_new)} info={result[1]}",
                              flush=True)
                    if depth < 4:
                        queue.append((cur_pow, depth + 1))

    elapsed = time.time() - t0
    print(f"\n=== Mass test ({elapsed:.0f}s) ===")
    print(f"Total: {n_total}")
    print(f"  JOIN: {n_join}")
    print(f"  G*:   {n_gstar}")
    print(f"  VIOLATION: {n_violation}")
    print(f"Dichotomy holds: {(n_join + n_gstar) == n_total}")

    # Investigate G* characterization via weights
    if g_star_alphas:
        print(f"\n=== G* α weight pattern ({len(g_star_alphas)} cases) ===")
        for r in g_star_alphas[:15]:
            w = r['w']
            print(f"  weights = {w}, sum = {sum(w)}")
        # Look for common features
        # sum, parity, max, min
        sums = Counter(sum(r['w']) for r in g_star_alphas)
        print(f"  weight sum distribution: {dict(sorted(sums.items()))}")
    if join_alphas[:3]:
        print(f"\n=== JOIN α first 3 (for comparison) ===")
        for r in join_alphas[:3]:
            w = r['w']
            print(f"  weights = {w}, sum = {sum(w)}, m_cones = {r['m']}")


if __name__ == "__main__":
    main()
