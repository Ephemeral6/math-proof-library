"""
Test: at the START of dismantling (before any vertex removal), does every
max-level vertex β have a strictly-lower-level dominator w?

This is the cleanest form of "Surgery Domination" and would give the cleanest
inductive proof.
"""
import curver, json
from collections import defaultdict, Counter

def run(g, n, data_path, k_values):
    print(f"\n=== S_{{{g},{n}}} ===", flush=True)
    S = curver.load(g, n)
    gamma0 = S.curves[list(S.curves.keys())[0]]
    data = json.load(open(data_path))
    hashes = [tuple(h) for h in data['curves']]
    curves = [S.lamination(list(h)) for h in hashes]
    f_vals = [gamma0.intersection(c) for c in curves]
    levels = defaultdict(list)
    for i, v in enumerate(f_vals): levels[v].append(i)

    adj = defaultdict(set); edge_iv = {}
    for i, j in data['i0_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 0
    for i, j in data['i1_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 1

    def i_query(a, b):
        if a == b: return 0
        key = frozenset((a,b))
        if key in edge_iv: return edge_iv[key]
        return curves[a].intersection(curves[b])

    summary = {}
    for k_alpha in k_values:
        if k_alpha not in levels: continue
        n_total = 0
        n_strictly_lower_dom = 0  # all max-level vertices have strictly-lower-level dominator
        n_lower_dom_some = 0      # at least one max-level vertex has strictly-lower-level dominator
        n_no_lower_dom_for_any = 0  # no max-level vertex has strictly-lower-level dominator
        for alpha_idx in levels[k_alpha]:
            DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
            if len(DL) <= 1: continue
            n_total += 1
            DL_set = set(DL)
            dl_adj = defaultdict(set)
            for i, b1 in enumerate(DL):
                for b2 in DL[i+1:]:
                    if i_query(b1, b2) <= 1:
                        dl_adj[b1].add(b2); dl_adj[b2].add(b1)
            DL_levels = [f_vals[b] for b in DL]
            max_lvl = max(DL_levels)
            max_lvl_verts = [b for b in DL if f_vals[b] == max_lvl]
            # For each max-level vertex β, look for strictly-lower-level dominator
            count_with_lower_dom = 0
            for v in max_lvl_verts:
                Nv = (dl_adj[v]) | {v}
                has_lower_dom = False
                for w in DL:
                    if w == v: continue
                    if f_vals[w] >= max_lvl: continue  # strictly lower
                    Nw = (dl_adj[w]) | {w}
                    if Nv <= Nw:
                        has_lower_dom = True; break
                if has_lower_dom:
                    count_with_lower_dom += 1
            if count_with_lower_dom == len(max_lvl_verts):
                n_strictly_lower_dom += 1
            if count_with_lower_dom >= 1:
                n_lower_dom_some += 1
            else:
                n_no_lower_dom_for_any += 1
        print(f"k={k_alpha}: total={n_total}, all max-lvl have strict-lower-dom={n_strictly_lower_dom}, some max-lvl has={n_lower_dom_some}, NONE has={n_no_lower_dom_for_any}")
        summary[k_alpha] = {'total': n_total, 'all': n_strictly_lower_dom, 'some': n_lower_dom_some, 'none': n_no_lower_dom_for_any}
    return summary

results = {}
results['S_1_2'] = run(1, 2, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json', (2, 3, 4, 5, 6, 7, 8))
results['S_2_1'] = run(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json', (2, 3, 4))
results['S_1_1'] = run(1, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_1.json', (2, 3, 4, 5))

print("\n=== Summary ===")
for surface, by_k in results.items():
    print(f"\n{surface}:")
    for k, stats in by_k.items():
        print(f"  k={k}: {stats}")
