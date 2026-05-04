"""
For the 30 max-level β with no dominator in our 400-curve sample at k=2,
search a much larger curve set (multiple rounds of Dehn twists) to see if
dominators exist in the full C_1 but were just missing from our sample.

If yes for all 30: the issue is purely a sample artifact, and the underlying
DL in the full C_1 has more structure than our truncated DL.
"""
import curver, json, time
from collections import defaultdict, Counter
import sys

t0 = time.time()
S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves_list = [S.lamination(list(h)) for h in hashes]
N = len(curves_list)
f_vals = [gamma0.intersection(c) for c in curves_list]

adj = defaultdict(set); edge_iv = {}
for i, j in data['i0_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 0
for i, j in data['i1_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 1

def i_query(a, b):
    if a == b: return 0
    key = frozenset((a,b))
    if key in edge_iv: return edge_iv[key]
    return curves_list[a].intersection(curves_list[b])

# K_4 core alphas at k=2 with no-dominator cores
K4_alphas = [25, 72, 149, 208, 217, 218]

# Generate a large extended set: 3 rounds of Dehn twists on the dataset
print("Generating 3-round Dehn-twist extension of dataset...", flush=True)
mcg_pos = list(S.pos_mapping_classes.keys())
twist_ops = []
for nm in mcg_pos:
    h = S(nm); twist_ops.append((nm, h))
    twist_ops.append((nm + '^-1', h.inverse()))

extended = {}
for h in hashes: extended[h] = curves_list[hashes.index(h)]

# Round 1
print(f"  Starting size: {len(extended)} [{time.time()-t0:.1f}s]", flush=True)
prev_size = 0
for round_num in range(3):
    if len(extended) > 5000:
        print(f"  Stopping early — sample exceeds 5000")
        break
    new_curves = {}
    for h, c in list(extended.items()):
        for nm, op in twist_ops:
            try:
                new_c = op(c)
                new_h = tuple(new_c)
                if new_h not in extended and new_h not in new_curves:
                    new_curves[new_h] = new_c
            except: pass
    extended.update(new_curves)
    print(f"  After round {round_num+1}: {len(extended)} curves [{time.time()-t0:.1f}s]", flush=True)
    if len(extended) == prev_size: break
    prev_size = len(extended)

ext_curves = list(extended.values())
ext_hashes = list(extended.keys())
ext_N = len(ext_curves)

print(f"\nExtended set: {ext_N} curves total\n", flush=True)

# For each K_4-core alpha, get its DL core vertices and check if extended set has a dominator
for alpha_idx in K4_alphas:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2])
    DL_set = set(DL)
    dl_adj_in_DL = defaultdict(set)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                dl_adj_in_DL[b1].add(b2); dl_adj_in_DL[b2].add(b1)
    # Identify core: vertices with NO dominator in DL_set
    no_dom_core = []
    for v in DL:
        N_v = (dl_adj_in_DL[v]) | {v}
        has_dom = False
        for w in DL:
            if w == v: continue
            N_w = (dl_adj_in_DL[w]) | {w}
            if N_v <= N_w:
                has_dom = True; break
        if not has_dom: no_dom_core.append(v)

    print(f"=== alpha = {alpha_idx} ===")
    print(f"  Core (no dominator in 400-sample DL): {no_dom_core}")
    if not no_dom_core: continue

    # For each core vertex v, look for a dominator in the extended set
    alpha = curves_list[alpha_idx]
    print(f"  Testing dominators in extended set...", flush=True)
    for v in no_dom_core:
        v_curve = curves_list[v]
        N_v = (dl_adj_in_DL[v]) | {v}
        # We need w with: i(w, alpha) <= 1, i(w, gamma_0) < 2, AND for every u in N_v, i(w, u) <= 1
        # Iterate ext_curves
        candidates_found = 0
        for w_curve in ext_curves:
            try:
                if alpha.intersection(w_curve) > 1: continue
                if gamma0.intersection(w_curve) >= 2: continue
                if v_curve.intersection(w_curve) > 1: continue
            except: continue
            # check w covers N_v
            ok = True
            for u in N_v:
                if u == v: continue
                try:
                    if curves_list[u].intersection(w_curve) > 1:
                        ok = False; break
                except:
                    ok = False; break
            if ok:
                candidates_found += 1
                if candidates_found >= 1: break  # found at least one
        status = "FOUND DOMINATOR" if candidates_found > 0 else "NO DOMINATOR"
        print(f"    v={v}: {status}", flush=True)
    print()

print(f"Total time: {time.time()-t0:.1f}s")
