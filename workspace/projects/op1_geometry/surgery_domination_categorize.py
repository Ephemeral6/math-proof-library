"""
For each k=2 alpha on S_{1,2}, for EACH max-level β in DL:
  test whether there exists a dominator of TYPE T:
  T1 = level-0 disjoint from α: w with f(w)=0 and i(α,w)=0
  T2 = level-0 with i(α,w)=1: w with f(w)=0 and i(α,w)=1
  T3 = T_{γ_0}^{±1}(β)
  T4 = T_{α}^{±1}(β)
  T5 = level-1 disjoint from β: w with f(w)=1 and i(β,w)=0
  T6 = anything else

Goal: identify ONE TYPE that always works.
"""
import curver, json
from collections import defaultdict, Counter
import time

t0 = time.time()
S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
N = len(curves)
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

T_g0 = S('a_0'); T_g0_i = T_g0.inverse()
print(f"Computing twists of all curves [{time.time()-t0:.1f}s]...", flush=True)
twist_g0   = {tuple(c): tuple(T_g0(c)) for c in curves}
twist_g0_i = {tuple(c): tuple(T_g0_i(c)) for c in curves}
hash_to_idx = {h: i for i, h in enumerate(hashes)}
print(f"Done [{time.time()-t0:.1f}s]", flush=True)

print("\n=== Categorizing dominators for k=2 max-level β ===\n", flush=True)

per_beta_summary = []
for alpha_idx in levels[2]:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2])
    if len(DL) <= 1: continue
    DL_set = set(DL)
    dl_adj = defaultdict(set)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                dl_adj[b1].add(b2); dl_adj[b2].add(b1)

    DL_levels = [f_vals[b] for b in DL]
    max_lvl = max(DL_levels)
    max_lvl_verts = [b for b in DL if f_vals[b] == max_lvl]

    for beta_idx in max_lvl_verts:
        N_beta = (dl_adj[beta_idx]) | {beta_idx}
        # Find ALL dominators
        dominators = []
        for w in DL:
            if w == beta_idx: continue
            N_w = (dl_adj[w]) | {w}
            if N_beta <= N_w:
                dominators.append(w)
        types_found = set()
        for w in dominators:
            f_w = f_vals[w]
            i_aw = i_query(alpha_idx, w)
            i_bw = i_query(beta_idx, w)
            if f_w == 0 and i_aw == 0:
                types_found.add('T1')
            if f_w == 0 and i_aw == 1:
                types_found.add('T2')
            # Check Tg0
            tg0_b = twist_g0.get(hashes[beta_idx])
            tg0_b_i = twist_g0_i.get(hashes[beta_idx])
            if hashes[w] == tg0_b: types_found.add('T3+')
            if hashes[w] == tg0_b_i: types_found.add('T3-')
            if f_w == 1 and i_bw == 0:
                types_found.add('T5')
        per_beta_summary.append({
            'alpha': alpha_idx, 'beta': beta_idx,
            'has_dom': bool(dominators),
            'types': sorted(types_found) if dominators else 'NONE',
            'num_dom': len(dominators),
        })

# Aggregate
print("Per (α, β) summary:")
print(f"  Total max-level β: {len(per_beta_summary)}")
print(f"  Has any dominator: {sum(1 for x in per_beta_summary if x['has_dom'])}")
print(f"  No dominator at all: {sum(1 for x in per_beta_summary if not x['has_dom'])}")
print()

# How often each TYPE works
type_counts = Counter()
for x in per_beta_summary:
    if x['has_dom']:
        for t in x['types']: type_counts[t] += 1

print("Frequency of each dominator type (per max-level β with dominator):")
total_with_dom = sum(1 for x in per_beta_summary if x['has_dom'])
for t, c in sorted(type_counts.items()):
    print(f"  {t}: {c} / {total_with_dom} = {100*c/total_with_dom:.1f}%")

# CRUCIAL: check if SOME single type covers ALL max-level β
# (i.e., a uniform dominator construction)
for t in sorted(type_counts.keys()):
    works_for = [x for x in per_beta_summary if x['has_dom'] and t in x['types']]
    works_for_all = (len(works_for) == total_with_dom)
    print(f"  Type {t} works for: {len(works_for)} / {total_with_dom} = {100*len(works_for)/total_with_dom:.1f}%, universal? {works_for_all}")

# What about T1 OR T3 OR T5? Or other unions?
combos = [('T1',), ('T2',), ('T1', 'T2'), ('T1', 'T2', 'T3+', 'T3-'),
          ('T1', 'T2', 'T5'), ('T1', 'T5'), ('T1', 'T3+', 'T3-'),
          ('T5', 'T3+', 'T3-'), ('T1', 'T2', 'T3+', 'T3-', 'T5')]
print("\nUnion of types — does it cover ALL?")
for combo in combos:
    covered = sum(1 for x in per_beta_summary if x['has_dom'] and any(t in x['types'] for t in combo))
    print(f"  {combo}: covers {covered} / {total_with_dom} ({100*covered/total_with_dom:.1f}%)")

# CASES where SOME max-level β has no dominator at all (these need special analysis)
no_dom = [x for x in per_beta_summary if not x['has_dom']]
print(f"\n{len(no_dom)} max-level β's have NO dominator. Sample (first 10):")
for x in no_dom[:10]:
    print(f"  α={x['alpha']}, β={x['beta']}")
