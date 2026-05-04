"""
Check whether p_1 (likely peripheral) on S_{1,2} acts as a cone point in C_1.
A cone point would have i(p_1, w) <= 1 for ALL other w.
"""
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

# Find which curve index is p_1: it's the one initialized as a named curve.
# Reload via curver to identify.
import curver
g, n = data['g'], data['n']
S = curver.load(g, n)

# Get the canonical hash of p_1 (or each named curve)
named_hashes = {nm: tuple(S.curves[nm]) for nm in S.curves}
print(f"Named curves and their canonical hashes:")
for nm, h in named_hashes.items():
    print(f"  {nm}: {h}")

# Find them in our enumerated list
all_hashes = [tuple(c) for c in data['curves']]
indices = {}
for nm, h in named_hashes.items():
    if h in all_hashes:
        indices[nm] = all_hashes.index(h)
print(f"\nNamed curve indices in our enumeration: {indices}")

# For each named curve, count its connections (i<=1) and its non-connections (i>=2)
N = data['num_curves']
edges = set()
for u, v in data['i1_edges']:
    edges.add(frozenset([u, v]))
for u, v in data['i0_edges']:
    edges.add(frozenset([u, v]))

print(f"\nFor each named curve, count of i=0/1 neighbors among the {N} vertices:")
for nm, idx in indices.items():
    nbrs = sum(1 for v in range(N) if v != idx and frozenset([idx, v]) in edges)
    non_nbrs = N - 1 - nbrs
    print(f"  {nm} (idx {idx}): {nbrs} neighbors / {non_nbrs} non-neighbors out of {N-1}")
    # If non_nbrs = 0, it's a cone point
    if non_nbrs == 0:
        print(f"    ^^^ {nm} IS a cone point (universal vertex)!")
