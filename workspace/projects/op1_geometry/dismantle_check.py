"""
Test dismantlability of descending links.

Definition: a finite graph G is DISMANTLABLE if there exists an ordering
v_1, ..., v_n of vertices such that for each i, in G - {v_1, ..., v_{i-1}},
the vertex v_i is DOMINATED by some other vertex w_i in the same graph,
meaning N_closed(v_i) ⊆ N_closed(w_i).

Theorem (Bandelt-Polat / standard): a graph is dismantlable iff its clique
complex (flag completion) is COLLAPSIBLE, hence contractible.

This script:
  1. For each level-k alpha in the dataset, builds Lk^down(alpha) as a graph
  2. Runs the dismantling algorithm
  3. Reports whether the graph is dismantlable
  4. If dismantlable, reports the dismantling sequence

Strategy: at each step, find ANY vertex v such that some other vertex w
satisfies N_closed(v) ⊆ N_closed(w); remove v; repeat. If we reach 1 vertex,
the graph is dismantlable.
"""
import curver, json, sys
from collections import defaultdict

def closed_nbhd(adj, v):
    return adj[v] | {v}

def find_dominated(vertices, adj):
    """Find any (v, w) such that N_closed(v) ⊆ N_closed(w). Returns (v, w) or None."""
    for v in vertices:
        Nv = closed_nbhd(adj, v)
        for w in vertices:
            if w == v: continue
            Nw = closed_nbhd(adj, w)
            if Nv <= Nw:
                return v, w
    return None

def dismantle(vertices, adj_in):
    """Try to dismantle the graph (vertices, adj). Returns (success, sequence_of_removals)."""
    V = set(vertices)
    adj = {v: set(adj_in[v]) & V for v in V}
    seq = []
    while len(V) > 1:
        result = find_dominated(V, adj)
        if result is None:
            return False, seq, V  # not dismantlable from this state
        v, w = result
        seq.append((v, w))
        # Remove v
        V.discard(v)
        for u in adj[v]:
            if u in adj: adj[u].discard(v)
        del adj[v]
    return True, seq, V

def run_on_dataset(g, n, data_path, k_values):
    print(f"\n{'='*70}\n=== S_{{{g},{n}}} ===\n{'='*70}", flush=True)
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
    for k in k_values:
        if k not in levels: continue
        sample = levels[k]
        print(f"\n[k={k}] checking all {len(sample)} alphas at this level")
        all_dis = True
        non_dis = []
        sequences = []
        for alpha_idx in sample:
            DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
            if len(DL) <= 1:
                continue
            # Build adjacency within DL
            dl_adj = defaultdict(set)
            for i, b1 in enumerate(DL):
                for b2 in DL[i+1:]:
                    if i_query(b1, b2) <= 1:
                        dl_adj[b1].add(b2); dl_adj[b2].add(b1)
            ok, seq, remaining = dismantle(DL, dl_adj)
            sequences.append((alpha_idx, len(DL), ok, len(remaining), seq[:5]))
            if not ok:
                all_dis = False
                non_dis.append((alpha_idx, len(DL), len(remaining)))
        print(f"  ALL dismantlable: {all_dis}")
        print(f"  Total sampled: {len(sample)}, all dismantlable: {sum(1 for _,_,ok,_,_ in sequences if ok)}, non-dismantlable: {len(non_dis)}")
        if non_dis:
            print(f"  Non-dismantlable alphas (sample): {non_dis[:5]}")
        summary[k] = {'total': len(sample), 'dismantlable': sum(1 for _,_,ok,_,_ in sequences if ok),
                      'non_dismantlable': non_dis}
    return summary

# Run
result = {}
result['S_1_2'] = run_on_dataset(1, 2,
    '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json',
    k_values=(2, 3, 4, 5, 6, 7, 8))
result['S_2_1'] = run_on_dataset(2, 1,
    '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json',
    k_values=(2, 3, 4))
result['S_1_1'] = run_on_dataset(1, 1,
    '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_1.json',
    k_values=(1, 2, 3, 4, 5))

with open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/dismantle_results.json', 'w') as f:
    json.dump(result, f, indent=2, default=str)
print("\nSaved dismantle_results.json")
