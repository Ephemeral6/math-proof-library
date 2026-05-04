"""
More thorough chordality check.

Focus: characterize the few non-chordal DLs at k≥4 on S_{1,2}.
Are they small? Do they have specific structure (like induced C_4 or C_5)?

Also: analyze whether non-chordal DLs are STILL dismantlable via a non-PEO route.
"""
import curver, json
import networkx as nx
from collections import defaultdict, Counter

S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
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

def build_dl_graph(alpha_idx, k):
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph()
    G.add_nodes_from(DL)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G

print("=" * 70)
print("Detailed structure of non-chordal DLs (find induced cycles)")
print("=" * 70)

non_chordal = []
for k_alpha in (2, 3, 4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G = build_dl_graph(alpha_idx, k_alpha)
        if G.number_of_nodes() <= 1:
            continue
        if not nx.is_chordal(G):
            non_chordal.append((k_alpha, alpha_idx, G))

print(f"\nTotal non-chordal DLs across all k: {len(non_chordal)}")

# For each non-chordal DL, find an induced cycle of length ≥ 4
def find_induced_cycle_len_at_least_4(G):
    """Find one induced cycle of length ≥ 4."""
    nodes = list(G.nodes())
    # Try cycles in cycle_basis
    cb = nx.cycle_basis(G)
    cb.sort(key=len)
    for cyc in cb:
        if len(cyc) >= 4:
            # Check if it's induced
            n = len(cyc)
            is_induced = True
            for i in range(n):
                for j in range(i+2, n):
                    if (i, j) == (0, n-1): continue  # adjacent in cycle
                    if (j - i) % n == 1: continue
                    if (i - j) % n == 1: continue
                    if G.has_edge(cyc[i], cyc[j]):
                        is_induced = False; break
                if not is_induced: break
            if is_induced:
                return cyc
    # Brute force: try chordless 4, 5 cycles
    from itertools import combinations
    for length in (4, 5, 6):
        for combo in combinations(nodes, length):
            # Check if combo forms a cycle in some order
            # Try all rotations
            for perm in [list(combo)]:
                pass
    return None

for i, (k_alpha, alpha_idx, G) in enumerate(non_chordal):
    n, e = G.number_of_nodes(), G.number_of_edges()
    cyc = find_induced_cycle_len_at_least_4(G)
    print(f"\n[{i+1}] k={k_alpha}, α={alpha_idx}: |V|={n}, |E|={e}")
    if cyc:
        print(f"    induced cycle of length {len(cyc)}: {cyc}")
        for v in cyc:
            print(f"        f({v}) = {f_vals[v]}, deg = {G.degree(v)}")
    # Is it dismantlable?
    def dismantle(G_in):
        G = G_in.copy()
        seq = []
        while G.number_of_nodes() > 1:
            found = None
            for v in list(G.nodes()):
                Nv = set(G.neighbors(v)) | {v}
                for w in G.nodes():
                    if w == v: continue
                    Nw = set(G.neighbors(w)) | {w}
                    if Nv <= Nw:
                        found = (v, w); break
                if found: break
            if not found:
                return False, seq
            v, w = found
            seq.append((v, w))
            G.remove_node(v)
        return True, seq
    ok, seq = dismantle(G)
    print(f"    Dismantlable: {ok}, sequence length = {len(seq)}")
