"""
Direction B: structure of the 6 non-chordal non-cone DLs on S_{2,1} k=2.

These are the only DLs (in our current dataset) where the "chordal or cone"
dichotomy fails. Investigate:
  1. Are they DOUBLE cones (suspensions)?
  2. Are they joins of two smaller graphs?
  3. Are they collapsible via some non-cone strong-collapsibility argument?
  4. Do they have a 2-vertex dominator pair?
"""
import curver, json, networkx as nx
from collections import defaultdict, Counter

DATA_PATH = '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_2_1.json'
S = curver.load(2, 1)
gamma0 = S.curves[list(S.curves.keys())[0]]
data = json.load(open(DATA_PATH))
hashes = [tuple(h) for h in data['curves']]
curves = []
for h in hashes:
    try: curves.append(S.lamination(list(h)))
    except: curves.append(None)
f_vals = [None] * len(curves)
for i, c in enumerate(curves):
    if c is None: continue
    try: f_vals[i] = gamma0.intersection(c)
    except: pass
levels = defaultdict(list)
for i, v in enumerate(f_vals):
    if v is not None: levels[v].append(i)

adj = defaultdict(set); edge_iv = {}
for i, j in data['i0_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 0
for i, j in data['i1_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 1

def i_query(a, b):
    if a == b: return 0
    key = frozenset((a, b))
    if key in edge_iv: return edge_iv[key]
    if curves[a] is None or curves[b] is None: return None
    return curves[a].intersection(curves[b])

def build_DL(alpha_idx, k):
    DL = sorted([b for b in adj[alpha_idx]
                 if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph(); G.add_nodes_from(DL)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            v = i_query(b1, b2)
            if v is not None and v <= 1:
                G.add_edge(b1, b2)
    return G, DL

# Find the 6 failures
failures = []
for alpha_idx in levels.get(2, []):
    G, DL = build_DL(alpha_idx, 2)
    if len(DL) <= 1: continue
    if nx.is_chordal(G): continue
    # has universal vertex?
    has_univ = any(G.degree(v) == len(DL) - 1 for v in DL)
    if has_univ: continue
    failures.append(alpha_idx)

print(f"6 failure cases on S_{{2,1}} k=2: {failures}")
print("=" * 78)

for alpha_idx in failures:
    G, DL = build_DL(alpha_idx, 2)
    print(f"\n=== α = {alpha_idx}, |DL| = {len(DL)} ===")
    levels_in_DL = Counter(f_vals[v] for v in DL)
    print(f"  Level distribution: {dict(levels_in_DL)}")
    print(f"  |E| = {G.number_of_edges()}")
    # max-degree vertex
    deg = sorted(G.degree(), key=lambda x: -x[1])
    print(f"  Top-5 degree: {deg[:5]}")
    # Density
    n = len(DL)
    print(f"  Density: {2*G.number_of_edges()/(n*(n-1)):.3f}")
    # Number of induced 4-cycles (sample for time)
    # count of "non-edges": pairs (u, v) with no edge
    nonedges = sum(1 for u in DL for v in DL if u < v and not G.has_edge(u, v))
    print(f"  Non-edges: {nonedges}")
    # Connected? Is it a join?
    print(f"  Connected: {nx.is_connected(G)}")
    # Test: is it a JOIN of two non-trivial subgraphs?
    # G is a join iff complement-graph is disconnected
    comp = nx.complement(G)
    cc = list(nx.connected_components(comp))
    print(f"  Complement connected components: {len(cc)} (sizes: {[len(c) for c in cc]})")
    if len(cc) > 1:
        print(f"    => G is a JOIN of {len(cc)} pieces")

    # Test: is it dismantlable? quick check via repeated dominated-vertex removal
    H = G.copy()
    seq = []
    while H.number_of_nodes() > 1:
        # find a dominated vertex
        nodes = list(H.nodes())
        found = None
        for u in nodes:
            Nu = set(H.neighbors(u)) | {u}
            for w in nodes:
                if w == u: continue
                Nw = set(H.neighbors(w)) | {w}
                if Nu <= Nw:
                    found = (u, w); break
            if found: break
        if not found:
            break
        seq.append(found)
        H.remove_node(found[0])
    print(f"  Dismantled: {H.number_of_nodes() <= 1}; steps: {len(seq)}")
    if H.number_of_nodes() > 1:
        print(f"    Stuck at: {list(H.nodes())[:10]}")

# Test: is the DL on these 6 alphas a JOIN G_0 * G_1?
print()
print("=" * 78)
print("If the DL is a join of two cones, it could still be contractible.")
print("Specifically: join of contractible is contractible.")
