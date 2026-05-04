"""
Detailed analysis of the 6 alphas with no universal vertex in their descending link.
Goal: understand the topological structure of these DLs to see if they admit
a different deformation retraction to a contractible subcomplex.
"""
import curver, json
import gudhi
from collections import defaultdict, Counter

S = curver.load(1, 2)
gamma0 = S.curves['a_0']

data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
N = len(curves)
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

PROBLEM_ALPHAS = [25, 72, 149, 208, 217, 218]

for alpha_idx in PROBLEM_ALPHAS:
    print(f"\n{'='*60}")
    print(f"alpha_idx = {alpha_idx}")
    print(f"  f(alpha) = {f_vals[alpha_idx]}")
    print(f"{'='*60}")

    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2])
    print(f"DL = {DL}")
    print(f"|DL| = {len(DL)}")
    print(f"DL levels: {Counter(f_vals[b] for b in DL)}")

    # Build adjacency within DL
    dl_adj = defaultdict(set)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                dl_adj[b1].add(b2); dl_adj[b2].add(b1)
    print(f"DL adjacency degrees: {sorted([(b, len(dl_adj[b])) for b in DL], key=lambda x: -x[1])}")

    # Build flag complex and compute exact Betti
    st = gudhi.SimplexTree()
    for v in DL: st.insert([v])
    for b1 in DL:
        for b2 in dl_adj[b1]:
            if b2 > b1: st.insert([b1, b2])
    st.expansion(7)
    st.persistence(persistence_dim_max=True)
    bettis = st.betti_numbers()
    n_simp = st.num_simplices()
    print(f"Betti = {bettis}, num_simplices = {n_simp}")

    # Check: max-clique = dimension of complex
    # find maxinmal cliques in dl_adj
    def find_cliques():
        # Bron-Kerbosch
        max_clq = []
        def bk(R, P, X):
            nonlocal max_clq
            if not P and not X:
                if len(R) > len(max_clq): max_clq = list(R)
                return
            for v in list(P):
                bk(R | {v}, P & dl_adj[v], X & dl_adj[v])
                P = P - {v}; X = X | {v}
        bk(set(), set(DL), set())
        return max_clq
    mc = find_cliques()
    print(f"Max clique: size {len(mc)}, members: {mc}")

    # Identify "central" vertices (high-degree) — these would be cone-point candidates
    high_deg = sorted(DL, key=lambda b: -len(dl_adj[b]))[:3]
    print(f"Highest-degree vertices: {[(b, len(dl_adj[b])) for b in high_deg]}")

    # Check: is the complex a join of two contractible parts?
    # Vertices not adjacent to b are "complementary"
    for b in DL:
        non_nbrs = [c for c in DL if c != b and c not in dl_adj[b]]
        if not non_nbrs:
            print(f"  vertex {b} (level {f_vals[b]}): IS UNIVERSAL")

    # Print all edge intersections for human inspection
    print("\nEdge structure (showing pairs i(b1, b2)):")
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            iv = i_query(b1, b2)
            mark = "" if iv <= 1 else "  *"
            print(f"  i({b1:3d}, {b2:3d}) = {iv}{mark}")
