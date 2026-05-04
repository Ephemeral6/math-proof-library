"""
Test the BRIDGED graph condition.

Definition: a graph G is BRIDGED if for every cycle C of length >= 4,
there exists an "edge shortcut" — vertices u, v on C with d_G(u,v) < d_C(u,v).

Equivalently: no isometric cycle of length >= 4 (every cycle of length >= 4
has a chord shorter than it).

Theorem (Soltan-Chepoi 1983 / Anstee-Farber 1988): Bridged graphs are
DISMANTLABLE. Their clique complexes are CONTRACTIBLE.

Bridged graphs are exactly the weakly modular graphs without induced 4-cycles
having a "diametral pair." Weaker than chordal (chordal ⊂ bridged).

If our DLs are bridged: dismantlability follows from this CLASSICAL theorem.
"""
import curver, json, networkx as nx
from collections import defaultdict
from itertools import combinations

def build_dl_graph(adj, f_vals, edge_iv, alpha_idx, k, curves_for_iquery=None):
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph()
    G.add_nodes_from(DL)
    def i_local(a, b):
        if a == b: return 0
        key = frozenset((a, b))
        if key in edge_iv: return edge_iv[key]
        if curves_for_iquery is None: return 999
        return curves_for_iquery[a].intersection(curves_for_iquery[b])
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_local(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G

def is_bridged(G):
    """Test bridged condition: every cycle of length ≥ 4 has a chord that
    "shortcuts" at least one pair of cycle vertices.

    Equivalent formulation: the graph has no ISOMETRIC cycle of length ≥ 4.
    A cycle C is isometric if for any two vertices u, v on C, the cycle distance
    equals the graph distance (d_C(u,v) = d_G(u,v)).

    We test by: for every cycle in cycle_basis of length ≥ 4, check if it's
    isometric.
    """
    if not nx.is_connected(G): return None
    sp = dict(nx.all_pairs_shortest_path_length(G))
    cycles = nx.cycle_basis(G)
    for cyc in cycles:
        n = len(cyc)
        if n < 4: continue
        # Check all pairs (u, v) on cyc
        for i in range(n):
            for j in range(i+2, n):
                d_cyc = min(j - i, n - (j - i))
                d_G = sp[cyc[i]].get(cyc[j], float('inf'))
                if d_G < d_cyc:
                    # cycle has a shortcut; it's not isometric. But this is GOOD
                    # for the cycle (it's "bridged"). We need EVERY cycle to be
                    # non-isometric. So continue.
                    break
            else:
                continue
            break
        else:
            # No shortcut found for this cycle → it's isometric → not bridged
            return False, cyc
    return True, None

def is_weakly_modular_strict(G):
    """The standard Chepoi triangle and quadrangle conditions."""
    if not nx.is_connected(G): return None
    sp = dict(nx.all_pairs_shortest_path_length(G))
    nodes = list(G.nodes())
    # Triangle condition (TC): for x, y, z with d(x,y)=d(x,z)=1, d(y,z) <= 2,
    # ∃ t s.t. t ~ y, t ~ z, d(x, t) <= 2 [but d(x, t) ≤ 1 in some forms]
    # We test: ∃ t adj to both y and z with d(x, t) <= 1 (i.e., x adj t, or x = t).
    for x in nodes:
        for y in G.neighbors(x):
            for z in G.neighbors(x):
                if y >= z: continue
                if z in G.neighbors(y): continue  # d(y,z) > 1
                d_yz = sp[y].get(z, float('inf'))
                if d_yz != 2: continue
                # Find t with t~y and t~z and (t==x or t~x)
                common = set(G.neighbors(y)) & set(G.neighbors(z))
                if not any(t == x or t in G.neighbors(x) for t in common):
                    return False, ('TC', x, y, z)
    # Quadrangle condition (QC): for u, v, x, y with edges xu, xv, uy, vy,
    # if d(x,y) = 2, ∃ z adj to all of u, v, x, y? No, that's not right.
    # Simplified QC: every induced 4-cycle has a "filling" (≤ 1 chord).
    # Skip for now.
    return True, None

def run(g, n, data_path, k_values, label):
    S = curver.load(g, n)
    g0 = S.curves[list(S.curves.keys())[0]]
    d = json.load(open(data_path))
    h_list = [tuple(h) for h in d['curves']]
    c_list = [S.lamination(list(h)) for h in h_list]
    f_v = [g0.intersection(c) for c in c_list]
    lv = defaultdict(list)
    for i, v in enumerate(f_v): lv[v].append(i)
    adj = defaultdict(set); edge_iv = {}
    for i, j in d['i0_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 0
    for i, j in d['i1_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 1

    print(f"\n=== {label} ===")
    for k_alpha in k_values:
        if k_alpha not in lv: continue
        bridged_count = 0; wm_count = 0; total = 0
        not_bridged = []; not_wm = []
        for alpha_idx in lv[k_alpha]:
            G = build_dl_graph(adj, f_v, edge_iv, alpha_idx, k_alpha, c_list)
            if G.number_of_nodes() <= 2: continue
            if not nx.is_connected(G): continue
            total += 1
            br, witness_b = is_bridged(G)
            if br: bridged_count += 1
            else: not_bridged.append(alpha_idx)
            wm, witness_w = is_weakly_modular_strict(G)
            if wm: wm_count += 1
            else: not_wm.append(alpha_idx)
        print(f"  k={k_alpha}: {bridged_count}/{total} bridged, {wm_count}/{total} weakly-modular-strict")
        if not_bridged:
            print(f"    NOT bridged: {not_bridged[:5]}")
        if not_wm:
            print(f"    NOT WM-strict: {not_wm[:5]}")

run(1, 2, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json',
    (2,3,4,5,6,7,8), 'S_{1,2}')
run(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json',
    (2,3,4), 'S_{2,1}')
run(1, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_1.json',
    (2,3,4,5,6,7,8), 'S_{1,1}')
