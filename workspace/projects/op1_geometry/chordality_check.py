"""
Test chordality and other structural properties of descending links.

Chordal graph = every cycle of length ≥ 4 has a chord.
Chordal => dismantlable (via perfect elimination ordering).

If DLs are chordal, we have a clean structural argument.

Also test: cop-win number, max independent set structure.
"""
import curver, json
import networkx as nx
from collections import defaultdict

S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
f_vals = [gamma0.intersection(c) for c in curves]

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

levels = defaultdict(list)
for i, v in enumerate(f_vals): levels[v].append(i)

def build_dl_graph(alpha_idx, k):
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph()
    G.add_nodes_from(DL)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G

print("="*70)
print("Chordality test on all DLs of S_{1,2}")
print("="*70)

non_chordal = []
for k_alpha in (2, 3, 4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    nc_at_k = []
    n_total = 0
    for alpha_idx in levels[k_alpha]:
        G = build_dl_graph(alpha_idx, k_alpha)
        if G.number_of_nodes() <= 1:
            continue
        n_total += 1
        if not nx.is_chordal(G):
            nc_at_k.append((alpha_idx, G.number_of_nodes()))
    print(f"k={k_alpha}: {n_total - len(nc_at_k)}/{n_total} chordal; non-chordal: {len(nc_at_k)}")
    if nc_at_k:
        print(f"  examples: {nc_at_k[:3]}")
        non_chordal.extend([(k_alpha, *x) for x in nc_at_k])

print(f"\nTotal non-chordal DLs: {len(non_chordal)}")

# If non-chordal, look at the cycle structure
if non_chordal:
    k_alpha, alpha_idx, n = non_chordal[0]
    G = build_dl_graph(alpha_idx, k_alpha)
    print(f"\nExample non-chordal DL: alpha={alpha_idx}, |V|={n}, |E|={G.number_of_edges()}")
    # Find chordless cycle
    try:
        cycles = nx.cycle_basis(G)
        # Filter to length ≥ 4 and chordless
        chordless = [c for c in cycles if len(c) >= 4]
        if chordless:
            print(f"  Chordless cycles found: {chordless[:3]}")
    except: pass

print("\n")

# Try a different angle: numbers of induced 4-cycles vs 4-cliques
print("="*70)
print("Structural diagnostic: 4-cliques and induced 4-cycles in DLs")
print("="*70)
print("\nA strongly-collapsible (= dismantlable) flag complex has a particularly")
print("simple structure. Let's see what we have in DLs.")

# Test if DLs are "Helly graphs" (related to dismantlability)
# Helly graph = every family of pairwise-intersecting balls has a common intersection
# Alternative: graphs where N_closed(v) is convex.

# Easier test: is the DL a JOIN of two contractible graphs?
def is_join(G):
    """Test if G = G1 + G2 where every vertex of G1 connects to every vertex of G2."""
    n = len(G)
    if n < 2: return False
    nodes = list(G.nodes())
    # G is a join iff its complement is disconnected
    Gc = nx.complement(G)
    return not nx.is_connected(Gc) if Gc.number_of_edges() > 0 else False

print("\n--- Are DLs joins? ---")
join_count = defaultdict(int)
for k_alpha in (2, 3, 4, 5, 6):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G = build_dl_graph(alpha_idx, k_alpha)
        if G.number_of_nodes() <= 1: continue
        if is_join(G):
            join_count[k_alpha] += 1
        else:
            join_count[(k_alpha, 'not_join')] += 1
print(f"join_count: {dict(join_count)}")
