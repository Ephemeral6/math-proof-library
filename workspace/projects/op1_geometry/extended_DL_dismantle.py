"""
Run the dismantle algorithm on the EXTENDED descending link of α=25 (and others).
The extended DL includes all curves from the 11,438-curve extended dataset that
satisfy the DL conditions: i(·, α) ≤ 1 and f(·) < 2.

Question: Is the extended DL still dismantlable? Does every max-level β now have
an immediate dominator?

If the extended DL is BIGGER than the truncated DL but still dismantlable, AND
every max-level β has a dominator in extended DL, we have very strong evidence
that the cleanest form of the lemma holds in the limit.
"""
import curver, json, time
from collections import defaultdict, Counter

t0 = time.time()
S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves_list = [S.lamination(list(h)) for h in hashes]
N = len(curves_list)
f_vals_orig = [gamma0.intersection(c) for c in curves_list]

# Generate extended set
mcg_pos = list(S.pos_mapping_classes.keys())
all_ops = [S(nm) for nm in mcg_pos] + [S(nm).inverse() for nm in mcg_pos]
extended = {h: curves_list[i] for i, h in enumerate(hashes)}
print(f"Round 0: {len(extended)} curves", flush=True)
for round_num in range(2):
    new_curves = {}
    for h, c in list(extended.items()):
        for op in all_ops:
            try:
                new_c = op(c)
                new_h = tuple(new_c)
                if new_h not in extended and new_h not in new_curves:
                    new_curves[new_h] = new_c
            except: pass
    extended.update(new_curves)
    print(f"Round {round_num+1}: {len(extended)} curves [{time.time()-t0:.1f}s]", flush=True)
    if len(extended) > 8000: break

ext_hashes = list(extended.keys())
ext_curves_list = list(extended.values())
ext_N = len(ext_curves_list)

# Compute f-values for all extended curves
print("Computing f for extended set...", flush=True)
ext_f = [gamma0.intersection(c) for c in ext_curves_list]
ext_levels_dist = Counter(ext_f)
print(f"  Level distribution: {dict(sorted(ext_levels_dist.items())[:10])}", flush=True)

# For α=25 (and a few others), build EXTENDED DL
K4_alphas = [25, 72, 149, 208, 217, 218]

for alpha_idx in K4_alphas:
    alpha = curves_list[alpha_idx]
    print(f"\n=== α={alpha_idx} ===", flush=True)
    # Extended DL: indices in extended set with i(α, ·) ≤ 1 and f < 2
    # Use ext_curves_list. Need to compute i(α, ext_c) for each ext_c.
    # This is N x 1 = 11k computations — fast.
    DL_ext = []
    for i, c in enumerate(ext_curves_list):
        try:
            if alpha.intersection(c) <= 1 and ext_f[i] < 2:
                DL_ext.append(i)
        except: pass
    print(f"  Extended DL size: {len(DL_ext)} (vs. original truncated DL: 8)", flush=True)

    # Build adjacency in extended DL (i ≤ 1 between any two DL members)
    # This is |DL_ext|^2 / 2 computations — could be expensive
    if len(DL_ext) > 80:
        print(f"  Skipping adjacency build (too large: {len(DL_ext)}^2)")
        continue
    print(f"  Computing adjacency...", flush=True)
    dl_adj = defaultdict(set)
    t1 = time.time()
    for i, idx_a in enumerate(DL_ext):
        ca = ext_curves_list[idx_a]
        for idx_b in DL_ext[i+1:]:
            cb = ext_curves_list[idx_b]
            try:
                if ca.intersection(cb) <= 1:
                    dl_adj[idx_a].add(idx_b); dl_adj[idx_b].add(idx_a)
            except: pass
    print(f"    [{time.time()-t1:.1f}s]", flush=True)

    # Run dismantle
    def dismantle_check(V, adj_in):
        V = set(V)
        adj = {v: set(adj_in[v]) & V for v in V}
        steps = 0
        while len(V) > 1:
            found = None
            for v in V:
                Nv = (adj[v]) | {v}
                for w in V:
                    if w == v: continue
                    Nw = (adj[w]) | {w}
                    if Nv <= Nw:
                        found = (v, w); break
                if found: break
            if not found: return False, len(V), steps
            v, w = found
            V.discard(v);
            for u in adj[v]:
                if u in adj: adj[u].discard(v)
            del adj[v]
            steps += 1
        return True, 0, steps

    ok, remaining, steps = dismantle_check(DL_ext, dl_adj)
    print(f"  Dismantlable: {ok}, steps: {steps}, remaining: {remaining}", flush=True)

    # Check if every max-level vertex has a dominator
    DL_levels = [ext_f[v] for v in DL_ext]
    max_lvl = max(DL_levels)
    max_verts = [v for v in DL_ext if ext_f[v] == max_lvl]
    print(f"  Max level = {max_lvl}, # max-level vertices = {len(max_verts)}", flush=True)
    no_dom = 0
    for v in max_verts:
        Nv = (dl_adj[v]) | {v}
        has = any(Nv <= ((dl_adj[w]) | {w}) for w in DL_ext if w != v)
        if not has: no_dom += 1
    print(f"  Max-level vertices with NO dominator in extended DL: {no_dom} / {len(max_verts)}", flush=True)

print(f"\nTotal time: {time.time()-t0:.1f}s")
