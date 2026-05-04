"""
Enumerate simple closed curves on S_{1,2} and build C_1 graph.

Approach:
1. Start from named curves a_0, b_0, p_1 in curver.load(1, 2).
2. Apply random words in the MCG to generate orbit curves.
3. Deduplicate by canonical hash (the curve's edge weight tuple).
4. Compute pairwise intersection numbers.
5. Build the 1-skeleton: edge iff i(α, β) <= 1 (we'll restrict to non-isotopic curves, so i = 1).
6. Build flag complex.
7. Compute Betti numbers via gudhi.
"""
import curver
import random
import json
import time
import sys
from itertools import combinations

random.seed(42)

S = curver.load(1, 2)
print(f"S_{{1,2}}: zeta={S.zeta}", flush=True)

named_curves = {n: S.curves[n] for n in S.curves}
print(f"Named curves: {list(named_curves.keys())}", flush=True)

# canonical hash for a curve: tuple of integer weights
def chash(c):
    return tuple(c)

# Initialize known curves (dict: hash -> curve object)
known = {}
for name, c in named_curves.items():
    known[chash(c)] = c

# random word generator using MCG
mcg_names = list(S.pos_mapping_classes.keys())  # generators

NUM_WORDS = int(sys.argv[1]) if len(sys.argv) > 1 else 800
MAX_LEN = int(sys.argv[2]) if len(sys.argv) > 2 else 5

t0 = time.time()
for trial in range(NUM_WORDS):
    L = random.randint(1, MAX_LEN)
    word = '.'.join(random.choice(mcg_names) + ('' if random.random() < 0.5 else '.inverse')
                    for _ in range(L))
    try:
        h = S(word)
    except Exception:
        continue
    # apply to one of the seed curves
    seed = random.choice(list(named_curves.values()))
    try:
        new_c = h(seed)
    except Exception:
        continue
    nh = chash(new_c)
    if nh not in known:
        known[nh] = new_c
    if (trial+1) % 200 == 0:
        print(f"  trial {trial+1}: {len(known)} curves [{time.time()-t0:.1f}s]", flush=True)

print(f"Found {len(known)} distinct simple closed curves [{time.time()-t0:.1f}s]", flush=True)

# Compute pairwise intersection numbers
curves_list = list(known.values())
hashes = list(known.keys())
N = len(curves_list)
print(f"Computing pairwise intersections on {N} curves: {N*(N-1)//2} pairs", flush=True)

edges = []  # i(a,b) = 1
disjoint = []  # i(a,b) = 0
inter_dist = {}
t1 = time.time()
ckpt = N * (N-1) // 2 // 10 if N > 50 else 50
counter = 0
for i in range(N):
    for j in range(i+1, N):
        try:
            ij = curves_list[i].intersection(curves_list[j])
        except Exception as e:
            continue
        inter_dist[ij] = inter_dist.get(ij, 0) + 1
        if ij == 0:
            disjoint.append((i, j))
        elif ij == 1:
            edges.append((i, j))
        counter += 1
        if counter % ckpt == 0:
            print(f"  pair {counter}: edges={len(edges)} disjoint={len(disjoint)} [{time.time()-t1:.1f}s]", flush=True)

print(f"DONE intersections [{time.time()-t1:.1f}s]", flush=True)
print(f"Intersection distribution: {sorted(inter_dist.items())[:20]}", flush=True)
print(f"Edges (i=1): {len(edges)}", flush=True)
print(f"Disjoint (i=0): {len(disjoint)}", flush=True)

# Save
out = {
    'surface': 'S_1_2',
    'num_curves': N,
    'curves': [list(h) for h in hashes],
    'i1_edges': edges,
    'i0_edges': disjoint,
    'intersection_dist': sorted(inter_dist.items()),
}
with open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S12.json', 'w') as f:
    json.dump(out, f)
print("Saved data_S12.json", flush=True)
