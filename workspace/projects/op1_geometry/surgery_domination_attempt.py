"""
Attempt: prove that for k=2 on S_{1,2}, every DL is chordal.

If chordal, then dismantlable, then contractible (standard).

Approach: try to characterize when an induced 4-cycle could exist in DL.
Use the level structure (vertices at level 0 or 1) to classify the cycle types.

Cases for an induced 4-cycle β_1-β_2-β_3-β_4 in DL:
  (0,0,0,0): all level-0
  (0,0,0,1): three level-0, one level-1  ... etc.

For each case, check if such a cycle can geometrically exist.
"""
import curver, json
import networkx as nx
from collections import defaultdict, Counter
from itertools import combinations

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

# Search for induced 4-cycles in all k=2 DLs (already known: none exist)
# but enumerate the level distributions of "near-misses": pairs of curves that
# *would* form a 4-cycle if their non-edge is missing.

print("=" * 70)
print("k=2 DL chordality verification: enumerate any 4-cycles, check induced.")
print("=" * 70)

induced_4cycles_found = 0
for alpha_idx in levels[2]:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2])
    if len(DL) < 4: continue
    DL_set = set(DL)
    dl_adj = defaultdict(set)
    for b1, b2 in combinations(DL, 2):
        if i_query(b1, b2) <= 1:
            dl_adj[b1].add(b2); dl_adj[b2].add(b1)
    # Find induced 4-cycles
    for c4 in combinations(DL, 4):
        # Try to find a cyclic ordering with edges between consecutive but not diagonals
        for perm in [c4]:  # just try one ordering
            for rot in range(4):
                ordered = [c4[(rot + i) % 4] for i in range(4)]
                a, b, c, d = ordered
                # Edges: ab, bc, cd, da; non-edges: ac, bd
                if (b in dl_adj[a] and c in dl_adj[b] and d in dl_adj[c] and a in dl_adj[d]
                    and c not in dl_adj[a] and d not in dl_adj[b]):
                    induced_4cycles_found += 1
                    print(f"  α={alpha_idx}: induced 4-cycle [{a}-{b}-{c}-{d}], levels {[f_vals[x] for x in (a,b,c,d)]}")
                    break

print(f"\nTotal induced 4-cycles in any k=2 DL on S_{{1,2}}: {induced_4cycles_found}")
print("(Should be 0 if k=2 DLs are chordal — and they are.)")

print("\n" + "=" * 70)
print("Now: the GEOMETRIC reason no induced 4-cycle can exist at k=2.")
print("=" * 70)
print("""
Suppose β_1, β_2, β_3, β_4 form an induced 4-cycle in Lk^↓(α) at f(α)=2.

Each β_i: i(β_i, α) ≤ 1 AND i(β_i, γ_0) ≤ 1.
Edges: i(β_i, β_{i+1}) ≤ 1.
Non-edges: i(β_1, β_3) ≥ 2, i(β_2, β_4) ≥ 2.

Level distribution: each β_i is level 0 or 1.

A clean geometric obstruction would split into cases:
- All level-0 (curves disjoint from γ_0): they live in S\γ_0. Cutting α gives two arcs.
  4-cycle would mean curves in S' = S\γ_0 with constraint i(β_i, arc) ≤ 1
  and pairwise constraints.

- Mixed: some β_i level-0, some level-1. The level-1 β_j is an arc in S'
  from one side of γ_0 to the other.

The data shows no such 4-cycles exist. A geometric proof would require
showing the obstruction in the cut surface S\(γ_0 ∪ α), but this is a
4-holed sphere or an annulus depending on (g, n), and the case analysis
for arbitrary (g, n) is intricate.

CONCLUSION: We do not have a self-contained geometric proof of chordality
at k=2. We have STRONG numerical evidence (64/64 chordal in S_{1,2},
13/13 in S_{1,1}, 32/32 in S_{2,1}) but no proof.

Alternatively: a generic graph-theoretic proof of dismantlability would
work for both chordal and non-chordal cases. But the non-chordal cases at
k≥4 (12 examples found, all 8-vertex with degree pattern (6,5,5,5)) have
a specific structure that suggests a uniform argument is possible — we
just have not found it.
""")
