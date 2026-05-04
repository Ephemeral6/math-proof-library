"""
Analyze the dismantling sequences. Look for a uniform rule:
  * Hypothesis 1: at each step, the highest-level vertex (largest f(beta)) is dominated.
  * Hypothesis 2: at each step, a vertex with smallest closed neighborhood is dominated.
  * Hypothesis 3: any level-1 vertex is dominated by some level-0 vertex (when level-0
    vertices exist).

Test these on all 64 k=2 DLs of S_{1,2}.
"""
import curver, json
from collections import defaultdict, Counter

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

# === Hypothesis 3 test: is every level-1 vertex β in DL dominated by some level-0 vertex σ in DL? ===
print("="*70)
print("HYPOTHESIS: in every DL of every level-k alpha (k≥2),")
print("            every level-(k-1) vertex β is dominated by SOME vertex of strictly lower level.")
print("="*70)

# Wait, this doesn't quite work because the lowest level in DL might be 0 (if a level-0
# vertex β exists with i(β, α) ≤ 1).
# Better hypothesis: the MAX-level vertices in DL are dominated by lower-level vertices.

print("\n--- Hypothesis A: Max-level vertices dominated by some lower-level vertex ---")

def closed_nbhd(v, V, adj_in):
    return (adj_in[v] & V) | {v}

problems = []
for k_alpha in (2, 3, 4, 5, 6):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
        if len(DL) <= 1: continue
        DL_set = set(DL)
        dl_adj = defaultdict(set)
        for i, b1 in enumerate(DL):
            for b2 in DL[i+1:]:
                if i_query(b1, b2) <= 1:
                    dl_adj[b1].add(b2); dl_adj[b2].add(b1)

        # Look at max-level vertices in DL
        DL_levels = [f_vals[b] for b in DL]
        max_lvl = max(DL_levels)
        max_lvl_verts = [b for b in DL if f_vals[b] == max_lvl]
        # For each, check if dominated by some vertex of lower level
        for v in max_lvl_verts:
            Nv = closed_nbhd(v, DL_set, dl_adj)
            dominated_by_lower = False
            for w in DL:
                if w == v: continue
                if f_vals[w] >= max_lvl: continue
                Nw = closed_nbhd(w, DL_set, dl_adj)
                if Nv <= Nw:
                    dominated_by_lower = True; break
            if not dominated_by_lower:
                problems.append((k_alpha, alpha_idx, v, max_lvl))

print(f"Problems (max-level vertex NOT dominated by lower-level vertex): {len(problems)}")
if problems:
    print(f"Sample: {problems[:5]}")
else:
    print("HYPOTHESIS A VERIFIED for all DLs!")

# === Hypothesis B: at each step of dismantling, max-level vertex is dominated. ===
print("\n--- Hypothesis B: ITERATIVE max-level dominance — repeat until single vertex ---")

def iterative_max_level_dismantle(DL, dl_adj, f_vals):
    """Try to dismantle by always removing a max-level dominated vertex.
    Returns (success, sequence)."""
    V = set(DL)
    adj = {v: set(dl_adj[v]) & V for v in V}
    seq = []
    while len(V) > 1:
        # Find max level among remaining vertices
        max_lvl = max(f_vals[v] for v in V)
        candidates = [v for v in V if f_vals[v] == max_lvl]
        # Try to dismantle: any v in candidates dominated by some w in V (any level)?
        found = False
        for v in candidates:
            Nv = (adj[v]) | {v}
            for w in V:
                if w == v: continue
                Nw = (adj[w]) | {w}
                if Nv <= Nw:
                    seq.append((v, w, f_vals[v], f_vals[w]))
                    V.discard(v)
                    for u in adj[v]: adj[u].discard(v)
                    del adj[v]
                    found = True; break
            if found: break
        if not found:
            return False, seq, V
    return True, seq, V

problems_B = []
for k_alpha in (2, 3, 4, 5, 6):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
        if len(DL) <= 1: continue
        dl_adj = defaultdict(set)
        for i, b1 in enumerate(DL):
            for b2 in DL[i+1:]:
                if i_query(b1, b2) <= 1:
                    dl_adj[b1].add(b2); dl_adj[b2].add(b1)
        ok, seq, rem = iterative_max_level_dismantle(DL, dl_adj, f_vals)
        if not ok:
            problems_B.append((k_alpha, alpha_idx, len(rem), len(seq)))

print(f"Problems (iterative max-level dismantling fails): {len(problems_B)}")
if problems_B:
    print(f"Sample: {problems_B[:5]}")
else:
    print("HYPOTHESIS B VERIFIED for all DLs!")

# === Sample dismantling sequences for inspection ===
print("\n--- Sample dismantling sequences (level pairs (v_lvl, w_lvl)) ---")
for k_alpha in (2, 3, 4, 5, 6):
    if k_alpha not in levels: continue
    print(f"\nk_alpha = {k_alpha}:")
    sample_count = 0
    for alpha_idx in levels[k_alpha]:
        DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
        if len(DL) <= 1: continue
        dl_adj = defaultdict(set)
        for i, b1 in enumerate(DL):
            for b2 in DL[i+1:]:
                if i_query(b1, b2) <= 1:
                    dl_adj[b1].add(b2); dl_adj[b2].add(b1)
        ok, seq, _ = iterative_max_level_dismantle(DL, dl_adj, f_vals)
        if ok and sample_count < 3:
            level_seq = [(s[2], s[3]) for s in seq]
            print(f"  alpha={alpha_idx}, |DL|={len(DL)}, seq levels: {level_seq}")
            sample_count += 1
