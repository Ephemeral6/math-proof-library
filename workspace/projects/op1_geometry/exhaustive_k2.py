"""
Exhaustive verification on S_{1,2}: for ALL level-2 alphas in our 400-curve
sample, compute the descending link Lk^down(alpha) and:

(i) Verify Betti numbers are [1, 0, 0, 0, 0] (contractibility numerical check)
(ii) Test if a universal vertex exists in the descending link (cone test)
(iii) For alphas WITHOUT a universal in the sample: try enumerating MORE
     curves nearby (apply Dehn twists T_{gamma_0}^k to existing curves) and
     re-test whether universals appear
"""
import curver, json, time, gudhi
from collections import defaultdict
import sys

S = curver.load(1, 2)
gamma0_name = list(S.curves.keys())[0]
gamma0 = S.curves[gamma0_name]
print(f"gamma_0 = {gamma0_name}, intersection_self = {gamma0.intersection(gamma0)}", flush=True)

data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
N = len(curves)
print(f"N={N}", flush=True)

# Compute f
f_vals = [gamma0.intersection(c) for c in curves]
levels = defaultdict(list)
for i, v in enumerate(f_vals):
    levels[v].append(i)
print(f"Level distribution: {[(k, len(v)) for k, v in sorted(levels.items())[:10]]}", flush=True)

# Build adjacency from edges
adj = defaultdict(set); edge_iv = {}
for i, j in data['i0_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 0
for i, j in data['i1_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i,j))] = 1

def i_query(a, b):
    if a == b: return 0
    key = frozenset((a, b))
    if key in edge_iv: return edge_iv[key]
    return curves[a].intersection(curves[b])

# === (i) Exhaustive k=2 contractibility check ===
print(f"\n=== Exhaustive k=2 descending link contractibility (all {len(levels[2])} alphas) ===", flush=True)
betti_results = {'all_trivial': True, 'exceptions': [], 'sample_dl_sizes': []}
no_universal_alphas = []
universal_pattern = defaultdict(int)

for alpha_idx in levels[2]:
    DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2]
    if len(DL) < 2:
        # trivially contractible (point or pair of points if connected)
        if len(DL) == 0:
            betti_results['exceptions'].append((alpha_idx, 'empty_DL'))
        continue
    # Build flag complex
    st = gudhi.SimplexTree()
    for v in DL: st.insert([v])
    for i in range(len(DL)):
        for j in range(i+1, len(DL)):
            a, b = DL[i], DL[j]
            if frozenset((a,b)) in edge_iv:
                st.insert([a, b])
    st.expansion(min(5, len(DL)-1))
    st.persistence(persistence_dim_max=True)
    bettis = st.betti_numbers()
    if not all(b == 0 for b in bettis[1:]):
        betti_results['all_trivial'] = False
        betti_results['exceptions'].append((alpha_idx, bettis))
    betti_results['sample_dl_sizes'].append(len(DL))

    # Check for universal vertex
    universals = []
    for sigma in DL:
        ok = all(i_query(sigma, beta) <= 1 for beta in DL if beta != sigma)
        if ok: universals.append((sigma, f_vals[sigma]))
    if not universals:
        no_universal_alphas.append((alpha_idx, len(DL)))
    universal_pattern[(len(universals), tuple(sorted(set(u[1] for u in universals))) if universals else ())] += 1

print(f"Total k=2 alphas: {len(levels[2])}")
print(f"All have trivial Betti? {betti_results['all_trivial']}")
print(f"Exceptions: {betti_results['exceptions']}")
print(f"Alphas with NO universal in DL: {len(no_universal_alphas)}")
print(f"Universal pattern (#universals, levels) -> count: {dict(universal_pattern)}")
print(f"DL sizes: min={min(betti_results['sample_dl_sizes'])}, max={max(betti_results['sample_dl_sizes'])}, avg={sum(betti_results['sample_dl_sizes'])/len(betti_results['sample_dl_sizes']):.1f}")
print(f"\nAlphas without universal: {no_universal_alphas[:10]}", flush=True)

# === (ii) For no-universal alphas, expand search by Dehn-twist orbits ===
print("\n=== Expanding search via Dehn twists for no-universal alphas ===", flush=True)
mcg_pos_keys = list(S.pos_mapping_classes.keys())
print(f"MCG generators: {mcg_pos_keys}", flush=True)

# Try generating new curves by applying T_{gamma_0}, T_{gamma_0}^{-1}, T_{other}, etc.
# to each curve in the dataset, and check if any new curves serve as universal
# for the no-universal alphas.

extra_curves = {}  # hash -> curve
def chash(c): return tuple(c)
for h in hashes: extra_curves[h] = None  # mark existing

new_candidates = []
print("Generating extra curves via single Dehn twists...", flush=True)
for c in curves:
    for g_name in mcg_pos_keys:
        for inv in ('', '.inverse'):
            try:
                h_op = S(g_name + inv)
                new_c = h_op(c)
                ch = chash(new_c)
                if ch not in extra_curves:
                    extra_curves[ch] = new_c
                    new_candidates.append(new_c)
            except Exception:
                pass
print(f"New candidate curves generated: {len(new_candidates)}", flush=True)

# For each no-universal alpha, check if any new candidate is universal in its DL
print("\nChecking universal status with extended candidate set:", flush=True)
fixed = 0
still_no = []
for alpha_idx, dl_size in no_universal_alphas:
    DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2]
    alpha = curves[alpha_idx]
    found_universal = False
    for sigma in new_candidates:
        try:
            f_sigma = gamma0.intersection(sigma)
        except: continue
        if f_sigma >= 2: continue  # not in DL
        try:
            if alpha.intersection(sigma) > 1: continue  # not in Lk(alpha)
        except: continue
        # sigma is a candidate; check universality against existing DL
        ok = True
        for beta_idx in DL:
            try:
                if sigma.intersection(curves[beta_idx]) > 1:
                    ok = False; break
            except:
                ok = False; break
        if ok:
            found_universal = True
            break
    if found_universal:
        fixed += 1
    else:
        still_no.append((alpha_idx, dl_size))

print(f"\nFixed by extended search: {fixed}/{len(no_universal_alphas)}")
print(f"Still no universal: {len(still_no)}")
print(f"Still-no-universal alphas: {still_no[:10]}")

# Save results
out = {
    'k2_total': len(levels[2]),
    'all_betti_trivial': betti_results['all_trivial'],
    'no_universal_in_sample': len(no_universal_alphas),
    'no_universal_alphas': [(a, d) for a, d in no_universal_alphas],
    'fixed_by_extended_search': fixed,
    'still_no_universal': len(still_no),
    'still_no_universal_alphas': [(a, d) for a, d in still_no],
    'extra_candidates_generated': len(new_candidates),
}
with open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/exhaustive_k2.json', 'w') as f:
    json.dump(out, f, indent=2, default=str)
print("\nSaved exhaustive_k2.json")
