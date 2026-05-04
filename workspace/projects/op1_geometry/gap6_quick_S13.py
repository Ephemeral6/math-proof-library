"""
Quick S_{1,3} feasibility test for Gap 6:
- Does curver.load(1, 3) work?
- How many MCG generators does it produce?
- BFS depth 3, count level-1 / level-2 vertex sets.
- For each level-2 alpha at depth <= 3, build Lk^down(alpha) and check chordal-or-cone.
"""
from __future__ import annotations
import sys, time
import curver
import networkx as nx
from collections import defaultdict

S = curver.load(1, 3)
print(f"S_1_3 loaded.")
print(f"Named curves (basis): {list(S.curves.keys())}")
print(f"S type: {type(S).__name__}")

# Use a_0 as gamma_0 if it exists
gamma0_name = next(iter(S.curves.keys()))
gamma0 = S.curves[gamma0_name]
print(f"gamma_0 = {gamma0_name}")

# BFS over MCG generators
t0 = time.time()
visited = {}
def add(c):
    h = c.weight()  # weight tuple as hashable key
    key = tuple(c)
    if key not in visited:
        visited[key] = c
        return True
    return False

# Seed: gamma_0 + each Lickorish generator's twist
seed = [gamma0]
for nm in S.curves.keys():
    if nm != gamma0_name:
        seed.append(S.curves[nm])

queue = []
for c in seed:
    if add(c):
        queue.append(c)

print(f"Seed: {len(visited)} curves")

# Use Dehn twists along named curves as MCG generators
gen_names = list(S.curves.keys())
print(f"Using Dehn twists along {gen_names} as MCG generators")

DEPTH = int(sys.argv[1]) if len(sys.argv) > 1 else 3
TIME_BUDGET = int(sys.argv[2]) if len(sys.argv) > 2 else 90
for d in range(DEPTH):
    new_queue = []
    for c in queue:
        if time.time() - t0 > TIME_BUDGET:
            print(f"Time budget exceeded at depth {d}")
            queue = []
            break
        for nm in gen_names:
            for sign in (+1, -1):
                try:
                    twist = S(nm) if sign > 0 else S(nm).inverse()
                    c_new = twist(c)
                    if add(c_new):
                        new_queue.append(c_new)
                except Exception:
                    pass
        else:
            continue
        break
    queue = new_queue
    print(f"After depth {d+1}: {len(visited)} curves, queue {len(queue)} new, elapsed {time.time()-t0:.1f}s")
    if time.time() - t0 > TIME_BUDGET:
        break

# Compute levels
curves = list(visited.values())
N = len(curves)
print(f"\nTotal: {N} curves found in {time.time()-t0:.1f}s")

f_vals = []
for c in curves:
    try:
        f_vals.append(int(gamma0.intersection(c)))
    except Exception:
        f_vals.append(None)

levels = defaultdict(list)
for i, v in enumerate(f_vals):
    if v is not None:
        levels[v].append(i)

print(f"Level distribution: {dict((k, len(v)) for k, v in sorted(levels.items()))}")

# For each level-2 alpha, build Lk^down and check
def i_query(a, b):
    if a == b: return 0
    try:
        return int(curves[a].intersection(curves[b]))
    except Exception:
        return None

results = []
for alpha_idx in levels.get(2, []):
    if time.time() - t0 > TIME_BUDGET + 60:
        break
    DL = []
    for j in range(N):
        if j == alpha_idx: continue
        if f_vals[j] is None or f_vals[j] >= 2: continue
        v = i_query(alpha_idx, j)
        if v is not None and v <= 1:
            DL.append(j)
    if len(DL) <= 1:
        results.append((alpha_idx, len(DL), 'trivial', None))
        continue

    G = nx.Graph()
    G.add_nodes_from(DL)
    for ii, b1 in enumerate(DL):
        for b2 in DL[ii+1:]:
            v = i_query(b1, b2)
            if v is not None and v <= 1:
                G.add_edge(b1, b2)

    is_chord = nx.is_chordal(G)
    has_univ = any(G.degree(v) == len(DL) - 1 for v in DL)

    if is_chord:
        cls = 'chordal'
    elif has_univ:
        cls = 'cone'
    else:
        cls = 'NEITHER'

    results.append((alpha_idx, len(DL), cls, G.number_of_edges()))

n_trivial = sum(1 for r in results if r[2] == 'trivial')
n_chordal = sum(1 for r in results if r[2] == 'chordal')
n_cone = sum(1 for r in results if r[2] == 'cone')
n_neither = sum(1 for r in results if r[2] == 'NEITHER')
print(f"\nDichotomy test on S_1_3, k=2 (truncated BFS depth {DEPTH}):")
print(f"  Total alphas tested: {len(results)}")
print(f"  Trivial (|DL| <= 1): {n_trivial}")
print(f"  Chordal: {n_chordal}")
print(f"  Cone: {n_cone}")
print(f"  Non-chordal-non-cone (Gap 4 phenomenon): {n_neither}")

if n_neither > 0:
    print(f"\nNeither cases:")
    for r in results:
        if r[2] == 'NEITHER':
            print(f"  alpha={r[0]}, |DL|={r[1]}, |E|={r[3]}")
