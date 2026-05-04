"""
For each level-k alpha (k>=2), find candidate surgery curves sigma_alpha
(level-0 curves with i(sigma, alpha) <= 1) and check if any is universal
in the descending link Lk^down(alpha).

A universal sigma means: i(sigma, beta) <= 1 for every beta in DL.

If yes for all alpha, k>=2, the descending link is always a cone, contractible.
"""
import curver, json, time
from collections import defaultdict

def run(g, n, data_path):
    print(f"\n=== S_{{{g},{n}}} ===", flush=True)
    S = curver.load(g, n)
    gamma0 = S.curves[list(S.curves.keys())[0]]
    data = json.load(open(data_path))
    hashes = [tuple(h) for h in data['curves']]
    curves = [S.lamination(list(h)) for h in hashes]
    N = len(curves)
    f_vals = [gamma0.intersection(c) for c in curves]
    levels = defaultdict(list)
    for i, v in enumerate(f_vals): levels[v].append(i)

    # Build adjacency from edges
    adj = defaultdict(set); edge_iv = {}
    for i, j in data['i0_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 0
    for i, j in data['i1_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 1

    def i_query(a, b):
        if a == b: return 0
        key = frozenset((a, b))
        if key in edge_iv: return edge_iv[key]
        # not in stored edges -> compute on the fly
        return curves[a].intersection(curves[b])

    print(f"Levels: {[(k, len(levels[k])) for k in sorted(levels)[:10]]}")

    summary = {}
    for k in (2, 3, 4, 5, 6):
        if k not in levels: continue
        sample = levels[k][:20]
        print(f"\n[k={k}] testing {len(sample)} alphas:")
        results = []
        for alpha_idx in sample:
            DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k]
            # Find candidate sigma's: level-0 vertices in DL = curves with f=0 and i(alpha, sigma)<=1
            # Among DL, find any level-< vertex (lowest level) that's universal in DL
            # Test all members of DL as potential cone points
            universals = []
            for sigma in DL:
                # check sigma connects to every other DL vertex
                ok = True
                for beta in DL:
                    if beta == sigma: continue
                    if i_query(sigma, beta) > 1:
                        ok = False; break
                if ok: universals.append((sigma, f_vals[sigma]))
            print(f"  alpha={alpha_idx}: |DL|={len(DL)}, universal vertices in DL: {len(universals)}, levels: {sorted(set(u[1] for u in universals))}")
            results.append({'alpha': alpha_idx, 'DL_size': len(DL),
                            'num_universals': len(universals),
                            'universal_levels': sorted(set(u[1] for u in universals))})
        summary[k] = results
        # check coverage: any alpha with NO universal?
        no_univ = [r for r in results if r['num_universals'] == 0]
        if no_univ:
            print(f"  [k={k}] WARNING: {len(no_univ)} alphas have NO universal in DL")
    return summary

t0 = time.time()
res = {}
res['S_1_2'] = run(1, 2, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json')
res['S_2_1'] = run(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json')
print(f"\nTotal time: {time.time()-t0:.1f}s")
with open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/sigma_universal.json', 'w') as f:
    json.dump(res, f, indent=2, default=str)
