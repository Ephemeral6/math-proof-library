"""
Build flag complex from 1-skeleton (i <= 1 edges) and compute homology.

Usage: python3 analyze_complex.py <data_S_g_n.json>
"""
import json
import sys
import time
import gudhi
import networkx as nx
from itertools import combinations

if len(sys.argv) < 2:
    print("Usage: analyze_complex.py <data.json>")
    sys.exit(1)

data_path = sys.argv[1]
with open(data_path) as f:
    data = json.load(f)

N = data['num_curves']
edges = [(i, j) for i, j in data['i1_edges']] + [(i, j) for i, j in data['i0_edges']]
print(f"Surface: {data['surface']}, N={N} curves, |E|={len(edges)} (i<=1)", flush=True)

# 1. Connectivity
G = nx.Graph()
G.add_nodes_from(range(N))
G.add_edges_from(edges)
print(f"Connected components: {nx.number_connected_components(G)}", flush=True)
print(f"Largest component size: {max(len(c) for c in nx.connected_components(G))}", flush=True)
print(f"Diameter (largest cc): ", end='', flush=True)
largest_cc = max(nx.connected_components(G), key=len)
H = G.subgraph(largest_cc)
try:
    print(nx.diameter(H))
except Exception as e:
    print(f"could not compute (graph might be too large): {e}")

# 2. Build flag complex up to dimension 4
t0 = time.time()
adj = {i: set() for i in range(N)}
for u, v in edges:
    adj[u].add(v)
    adj[v].add(u)

# Find cliques up to size 5 (= dim 4 simplex)
print(f"Searching for cliques in N={N}, |E|={len(edges)} graph", flush=True)
all_cliques = list(nx.find_cliques(G))  # maximal cliques
max_clique_size = max((len(c) for c in all_cliques), default=0)
print(f"# maximal cliques: {len(all_cliques)}, max clique size: {max_clique_size}", flush=True)

# Histogram of max clique sizes
hist = {}
for c in all_cliques:
    hist[len(c)] = hist.get(len(c), 0) + 1
print(f"Maximal clique size distribution: {sorted(hist.items())}", flush=True)

# Build SimplexTree
st = gudhi.SimplexTree()
for i in range(N):
    st.insert([i])
for u, v in edges:
    st.insert([u, v])

# Expand to flag complex up to dim min(max_clique_size-1, 5)
DIM = min(max_clique_size - 1, 5)
st.expansion(DIM)
print(f"Flag complex up to dim {DIM}: simplices = {st.num_simplices()}", flush=True)

# Simplex counts per dimension
counts = {}
for simplex, _ in st.get_simplices():
    d = len(simplex) - 1
    counts[d] = counts.get(d, 0) + 1
print(f"Simplex counts by dim: {sorted(counts.items())}", flush=True)

# Euler characteristic
chi = sum((-1)**d * counts[d] for d in counts)
print(f"Euler characteristic χ = {chi}", flush=True)

# Compute homology (Z/2 coefficients via gudhi)
st.compute_persistence(homology_coeff_field=2)
betti = st.betti_numbers()
print(f"Betti numbers (Z/2 coefficients): {betti}", flush=True)

# Also try Z/3
st2 = gudhi.SimplexTree()
for i in range(N):
    st2.insert([i])
for u, v in edges:
    st2.insert([u, v])
st2.expansion(DIM)
st2.compute_persistence(homology_coeff_field=3)
betti3 = st2.betti_numbers()
print(f"Betti numbers (Z/3 coefficients): {betti3}", flush=True)

# Alexander dual / cohomology — gudhi only computes betti, not full integer.
print(f"\nSummary for {data['surface']}:")
print(f"  Vertices: {N}")
print(f"  i=0 edges: {len(data['i0_edges'])}, i=1 edges: {len(data['i1_edges'])}")
print(f"  Max clique: {max_clique_size}")
print(f"  Euler char: {chi}")
print(f"  Betti (Z/2): {betti}")
print(f"  Betti (Z/3): {betti3}")
print(f"  Connected: {nx.number_connected_components(G) == 1}")
print(f"[total time: {time.time()-t0:.1f}s]")
