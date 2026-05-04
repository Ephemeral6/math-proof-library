"""
Test the QUADRANGLE Condition (QC) along with Triangle Condition.

QC (Chepoi): For any u, v, x, y with d(u,v) = 2, d(x,u) = d(x,v) = 1,
d(y,u) = d(y,v) = 1 (so {x, y} are common neighbors of u and v but x ≠ y not
necessarily adjacent), if d(x, y) <= 2, then ∃ w adjacent to both x and y
with d(u, w) = d(v, w) = 1 OR ...

The clean formulation:
QC: for every 4-tuple x, u, v, y with d(x, u) = d(x, v) = 1, d(u, y) = d(v, y) = 1,
d(x, y) = 2 (i.e., x and y at distance 2, both adjacent to u and to v),
there exists z adj to all of u, v, x, y... no, that's K_5.

Actually, simpler: Chepoi-Bandelt define WEAKLY MODULAR = TC + QC. Let me use:

Triangle Condition (TC): d(x,y) = d(x,z) = 1, d(y,z) = 2 ⇒ ∃ w: w~y, w~z, w~x or w=x.
Quadrangle Condition (QC): d(x,y) = d(x,z) = k+1, d(x,w) = k, d(w,y) = d(w,z) = 1, d(y,z) = 2 ⇒ ∃ v: v~y, v~z, d(x,v) = k.

Equivalently for k=1 (the most common case to check):
d(x,y) = d(x,z) = 2, x~w, w~y, w~z, d(y,z) = 2 ⇒ ∃ v ~ y, v ~ z, x~v.

This is hard to verify in general. Let me also try the simpler:

STRONGER CONDITION: every induced 4-cycle in DL has a common neighbor (= the
diamond is "filled" by a 5th vertex). This implies the flag complex on the 4
vertices is contractible (it's the boundary of a 2-disk).
"""
import curver, json, networkx as nx
from collections import defaultdict
from itertools import combinations

def build_dl_graph(adj, f_vals, edge_iv, alpha_idx, k, curves_for_iquery):
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph()
    G.add_nodes_from(DL)
    def i_local(a, b):
        if a == b: return 0
        key = frozenset((a, b))
        if key in edge_iv: return edge_iv[key]
        return curves_for_iquery[a].intersection(curves_for_iquery[b])
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_local(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G

def induced_4cycles(G):
    """Find all induced 4-cycles."""
    found = []
    nodes = list(G.nodes())
    for combo in combinations(nodes, 4):
        # Check if combo forms an induced 4-cycle in some cyclic order
        n = 4
        for start in range(1):  # one rotation suffices
            ordered = [combo[(start + i) % n] for i in range(n)]
            # We want 4 cyclic edges, no chord
            for perm_a in [combo[0]]:
                # Try fixing combo[0] and trying orderings of the others
                for ordering in [(combo[1], combo[2], combo[3]),
                                 (combo[1], combo[3], combo[2]),
                                 (combo[2], combo[1], combo[3])]:
                    o = (combo[0],) + ordering
                    edges_ok = (G.has_edge(o[0], o[1]) and G.has_edge(o[1], o[2]) and
                                G.has_edge(o[2], o[3]) and G.has_edge(o[3], o[0]))
                    if not edges_ok: continue
                    chord_ok = (not G.has_edge(o[0], o[2])) and (not G.has_edge(o[1], o[3]))
                    if chord_ok:
                        found.append(o); break
            if found and found[-1][0] == combo[0]: break
    return found

def has_common_neighbor(G, vertices):
    """True iff there's a vertex adj to all in `vertices`."""
    if not vertices: return True
    common = set(G.neighbors(vertices[0]))
    for v in vertices[1:]:
        common &= set(G.neighbors(v))
        if not common: return False
    return True

def induced_4cycles_with_common_neighbor(G):
    cycles = induced_4cycles(G)
    if not cycles: return None  # no induced 4-cycles, so vacuously OK
    all_have = True; details = []
    for cyc in cycles:
        has = has_common_neighbor(G, cyc)
        details.append((cyc, has))
        if not has: all_have = False
    return all_have, details

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

    print(f"\n=== {label}: induced-4-cycles, common-neighbor filling ===")
    for k_alpha in k_values:
        if k_alpha not in lv: continue
        n_total = 0; n_no4 = 0; n_4_filled = 0; n_4_unfilled = 0
        unfilled_list = []
        for alpha_idx in lv[k_alpha]:
            G = build_dl_graph(adj, f_v, edge_iv, alpha_idx, k_alpha, c_list)
            if G.number_of_nodes() <= 3: continue
            if not nx.is_connected(G): continue
            n_total += 1
            cyc_count = len(induced_4cycles(G))
            if cyc_count == 0:
                n_no4 += 1
                continue
            # Has induced 4-cycles
            res = induced_4cycles_with_common_neighbor(G)
            all_filled, details = res
            if all_filled:
                n_4_filled += 1
            else:
                n_4_unfilled += 1
                unfilled_list.append((alpha_idx, [d for c, d in details if not d][:1]))
        print(f"  k={k_alpha}: {n_total} total, {n_no4} no induced 4-cycle, {n_4_filled} 4-cycle(s) filled, {n_4_unfilled} unfilled")
        if unfilled_list:
            print(f"    Unfilled: {unfilled_list[:3]}")

run(1, 2, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json',
    (2,3,4,5,6,7,8), 'S_{1,2}')
run(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json',
    (2,3,4), 'S_{2,1}')
