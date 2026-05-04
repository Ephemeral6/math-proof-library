"""
Extended verification: descending links for k = 1, 2, 3, 4, 5 on S_{1,2}.
Also checks S_{2,1}.
"""
import curver, json, sys, time, gudhi
from collections import defaultdict

def run(g, n, data_path, k_levels=(1, 2, 3, 4, 5), n_per_level=10):
    print(f"\n{'='*60}\n=== S_{{{g},{n}}} ===\n{'='*60}", flush=True)
    t0 = time.time()
    S = curver.load(g, n)
    named = list(S.curves.keys())
    print(f"Named curves: {named}")
    gamma0_name = named[0]
    gamma0 = S.curves[gamma0_name]
    print(f"gamma_0 = {gamma0_name}")
    data = json.load(open(data_path))
    hashes = [tuple(h) for h in data['curves']]
    curves = []
    for h in hashes:
        try: curves.append(S.lamination(list(h)))
        except: curves.append(None)
    N = len(curves)

    # find gamma_0 in dataset
    g0h = tuple(gamma0)
    if g0h in hashes:
        g0_idx = hashes.index(g0h)
    else:
        curves.append(gamma0); hashes.append(g0h); g0_idx = N; N += 1

    f_vals = [None]*N
    for i, c in enumerate(curves):
        if c is None: continue
        try: f_vals[i] = gamma0.intersection(c)
        except: pass

    levels = defaultdict(list)
    for i, v in enumerate(f_vals):
        if v is not None: levels[v].append(i)
    print(f"Level distribution: {[(k, len(levels[k])) for k in sorted(levels)[:12]]}")

    # build adjacency from edge data
    adj = defaultdict(set); edge_iv = {}
    for i, j in data['i0_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[(min(i,j),max(i,j))] = 0
    for i, j in data['i1_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[(min(i,j),max(i,j))] = 1
    if g0_idx == N - 1:  # gamma_0 added; compute its edges
        for j in range(N-1):
            if curves[j] is None: continue
            try:
                v = gamma0.intersection(curves[j])
            except: continue
            if v <= 1:
                adj[g0_idx].add(j); adj[j].add(g0_idx)
                edge_iv[(min(g0_idx,j),max(g0_idx,j))] = v

    summary = {}
    for k in k_levels:
        if k not in levels:
            print(f"\n[k={k}] no curves at this level"); continue
        sample = levels[k][:n_per_level]
        print(f"\n[k={k}] sampling {len(sample)} of {len(levels[k])} curves at this level")
        bettis_list = []
        for alpha_idx in sample:
            DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k]
            if len(DL) < 1:
                bettis_list.append(('empty', len(DL)))
                continue
            st = gudhi.SimplexTree()
            for v in DL: st.insert([v])
            for i in range(len(DL)):
                for j in range(i+1, len(DL)):
                    a, b = DL[i], DL[j]
                    key = (min(a,b),max(a,b))
                    if key in edge_iv: st.insert([a,b])
            st.expansion(min(5, len(DL)-1))
            st.persistence(persistence_dim_max=True)
            bettis = st.betti_numbers()
            bettis_list.append((bettis, len(DL), st.num_simplices()))
            print(f"  alpha={alpha_idx}: |DL|={len(DL)}, simplices={st.num_simplices()}, Betti={bettis}")
        summary[k] = bettis_list
    return summary

# S_{1,2}
res_S12 = run(1, 2, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json',
              k_levels=(1, 2, 3, 4, 5), n_per_level=10)

# S_{2,1}
res_S21 = run(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json',
              k_levels=(1, 2, 3, 4), n_per_level=8)

out = {'S_1_2': {str(k): v for k, v in res_S12.items()},
       'S_2_1': {str(k): v for k, v in res_S21.items()}}
with open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/descending_link_higher.json', 'w') as f:
    json.dump(out, f, indent=2, default=str)
print("\nSaved descending_link_higher.json")
