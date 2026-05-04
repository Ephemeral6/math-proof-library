"""
For the K_4-core vertices that find dominators in the extended set,
analyze the dominators:
  - What's their f-level?
  - i with alpha?
  - Are they single Dehn twists or composite operations?
  - Is there a uniform pattern?
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

# Generate 2 rounds of extended set
mcg_pos = list(S.pos_mapping_classes.keys())
twist_ops = [(nm, S(nm)) for nm in mcg_pos]
twist_ops_inv = [(nm + '^-1', S(nm).inverse()) for nm in mcg_pos]
all_ops = twist_ops + twist_ops_inv

# Extension: track depth of each curve
extended = {h: (curves_list[i], 0) for i, h in enumerate(hashes)}
print(f"Round 0: {len(extended)} curves", flush=True)
for round_num in range(2):
    new_curves = {}
    for h, (c, d) in list(extended.items()):
        for nm, op in all_ops:
            try:
                new_c = op(c)
                new_h = tuple(new_c)
                if new_h not in extended and new_h not in new_curves:
                    new_curves[new_h] = (new_c, d + 1)
            except: pass
    extended.update(new_curves)
    print(f"Round {round_num+1}: {len(extended)} curves", flush=True)
    if len(extended) > 8000: break

ext_curves = [(h, c, d) for h, (c, d) in extended.items()]
print(f"Total extended: {len(ext_curves)} [{time.time()-t0:.1f}s]\n", flush=True)

K4_alphas = [25, 72, 149, 208, 217, 218]

print("Analyzing dominators of K_4-core vertices:")
print("="*70, flush=True)

dominator_levels = Counter()
dominator_alpha_int = Counter()

for alpha_idx in K4_alphas:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2])
    DL_set = set(DL)
    dl_adj_in_DL = defaultdict(set)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                dl_adj_in_DL[b1].add(b2); dl_adj_in_DL[b2].add(b1)
    no_dom_core = []
    for v in DL:
        N_v = (dl_adj_in_DL[v]) | {v}
        has_dom = any(N_v <= ((dl_adj_in_DL[w]) | {w}) for w in DL if w != v)
        if not has_dom: no_dom_core.append(v)

    print(f"\n=== alpha={alpha_idx} ===")
    alpha = curves_list[alpha_idx]
    for v in no_dom_core:
        v_curve = curves_list[v]
        N_v = (dl_adj_in_DL[v]) | {v}
        # Find ALL dominators in extended set
        all_dominators = []
        for h, w_curve, d in ext_curves:
            try:
                f_w = gamma0.intersection(w_curve)
                if f_w >= 2: continue
                if alpha.intersection(w_curve) > 1: continue
                if v_curve.intersection(w_curve) > 1: continue
            except: continue
            ok = True
            for u in N_v:
                if u == v: continue
                try:
                    if curves_list[u].intersection(w_curve) > 1:
                        ok = False; break
                except:
                    ok = False; break
            if ok:
                i_alpha = alpha.intersection(w_curve)
                i_v = v_curve.intersection(w_curve)
                all_dominators.append({
                    'hash': h, 'depth': d, 'f_w': f_w,
                    'i(α,w)': i_alpha, 'i(v,w)': i_v,
                })
                if len(all_dominators) >= 5: break
        if all_dominators:
            f_set = set(d['f_w'] for d in all_dominators)
            depth_set = set(d['depth'] for d in all_dominators)
            i_alpha_set = set(d['i(α,w)'] for d in all_dominators)
            print(f"  v={v}: {len(all_dominators)} dominators sampled. f_w in {f_set}, depth in {depth_set}, i(α,w) in {i_alpha_set}")
            for d in all_dominators[:2]:
                print(f"    -> f_w={d['f_w']}, depth={d['depth']}, i(α,w)={d['i(α,w)']}, i(v,w)={d['i(v,w)']}")
                dominator_levels[d['f_w']] += 1
                dominator_alpha_int[d['i(α,w)']] += 1
        else:
            print(f"  v={v}: NO dominator found")

print(f"\n\nAggregate dominator profile:")
print(f"  f-level distribution: {dict(dominator_levels)}")
print(f"  i(α, w) distribution: {dict(dominator_alpha_int)}")
print(f"\nTotal time: {time.time()-t0:.1f}s")
