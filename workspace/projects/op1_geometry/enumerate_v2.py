"""
Better curve enumeration: BFS by Dehn twist neighbors + random walks.

For surface S_{g,n}:
- Start with named curves
- For each known curve, apply each generator (and inverse) to get new curves
- BFS until we have N_TARGET curves OR we've expanded a fixed depth

Usage:
  python3 enumerate_v2.py <g> <n> <depth> <max_curves>
"""
import curver
import random
import json
import time
import sys
from collections import deque

random.seed(7)

g = int(sys.argv[1])
n = int(sys.argv[2])
DEPTH = int(sys.argv[3]) if len(sys.argv) > 3 else 4
MAX_CURVES = int(sys.argv[4]) if len(sys.argv) > 4 else 200
SURFACE_TAG = f"S_{g}_{n}"

S = curver.load(g, n)
print(f"Loaded {SURFACE_TAG}: zeta={S.zeta}", flush=True)

named_curves = {nm: S.curves[nm] for nm in S.curves}
mcg_pos = list(S.pos_mapping_classes.keys())
print(f"Named curves: {list(named_curves.keys())}, MCG generators: {mcg_pos}", flush=True)

def chash(c):
    return tuple(c)

# BFS
known = {}  # hash -> curve
for nm, c in named_curves.items():
    known[chash(c)] = c

frontier = deque(known.values())
depth_count = 0
t0 = time.time()
visited_at = {h: 0 for h in known}

while frontier and len(known) < MAX_CURVES:
    next_frontier = deque()
    while frontier and len(known) < MAX_CURVES:
        c = frontier.popleft()
        ch = chash(c)
        d = visited_at[ch]
        if d >= DEPTH:
            continue
        for g_name in mcg_pos:
            for inv in ('', '.inverse'):
                try:
                    h = S(g_name + inv)
                    new_c = h(c)
                    nh = chash(new_c)
                except Exception:
                    continue
                if nh not in known:
                    known[nh] = new_c
                    visited_at[nh] = d + 1
                    next_frontier.append(new_c)
                    if len(known) >= MAX_CURVES:
                        break
            if len(known) >= MAX_CURVES:
                break
    if len(known) % 50 < 30:
        print(f"  depth done: {len(known)} curves [{time.time()-t0:.1f}s]", flush=True)
    frontier = next_frontier
    depth_count += 1

print(f"BFS produced {len(known)} curves at depth {depth_count} [{time.time()-t0:.1f}s]", flush=True)

# Compute pairwise intersections
curves_list = list(known.values())
hashes = list(known.keys())
N = len(curves_list)
print(f"Pairwise intersections on N={N} curves: {N*(N-1)//2} pairs", flush=True)
t1 = time.time()
edges_i1 = []
edges_i0 = []
intersection_dist = {}
for i in range(N):
    for j in range(i+1, N):
        try:
            ij = curves_list[i].intersection(curves_list[j])
        except Exception:
            continue
        intersection_dist[ij] = intersection_dist.get(ij, 0) + 1
        if ij == 0:
            edges_i0.append([i, j])
        elif ij == 1:
            edges_i1.append([i, j])
print(f"Intersections done [{time.time()-t1:.1f}s]", flush=True)
print(f"i=0 (disjoint): {len(edges_i0)}, i=1: {len(edges_i1)}", flush=True)
print(f"Distribution: {sorted(intersection_dist.items())[:30]}", flush=True)

out = {
    'surface': SURFACE_TAG,
    'g': g, 'n': n, 'zeta': S.zeta,
    'num_curves': N,
    'curves': [list(h) for h in hashes],
    'i1_edges': edges_i1,
    'i0_edges': edges_i0,
    'intersection_dist': sorted(intersection_dist.items()),
}
out_path = f'/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_{SURFACE_TAG}.json'
with open(out_path, 'w') as f:
    json.dump(out, f)
print(f"Saved {out_path}", flush=True)
