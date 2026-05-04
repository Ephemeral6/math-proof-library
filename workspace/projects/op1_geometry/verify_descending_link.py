"""
Verify the Bestvina-Brady descending-link strategy numerically on S_{1,2}.

For a fixed non-separating curve gamma_0:
  * stratify all curves by f(alpha) = i(alpha, gamma_0)
  * for level-1 curves: check descending link is a cone over gamma_0
  * for level-2 curves: check descending link is contractible numerically
    (Betti numbers via gudhi flag expansion)
  * also: produce a surgery curve sigma_alpha for level-2 curves and verify
    sigma_alpha is in the descending link
"""
import curver
import json
import sys
import time
import numpy as np
import gudhi
from collections import defaultdict

DATA = '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'
OUT  = '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/descending_link_S_1_2.json'

t0 = time.time()
S = curver.load(1, 2)
named = list(S.curves.keys())
print(f"Loaded S_{{1,2}}, named curves: {named}")
gamma0_name = named[0]            # pick first named non-separating curve
gamma0 = S.curves[gamma0_name]
print(f"Using gamma_0 = {gamma0_name}, intersection-self = {gamma0.intersection(gamma0)}")

# Reload all 400 curves from the existing dataset
data = json.load(open(DATA))
hashes = [tuple(h) for h in data['curves']]
print(f"Loaded {len(hashes)} curves from dataset", flush=True)

# Reconstruct curver curves from raw vectors
def from_hash(h):
    # hash is tuple of integers -- the curve's vector on the triangulation
    return S.lamination(list(h))

curves = []
for h in hashes:
    try:
        curves.append(from_hash(h))
    except Exception as e:
        curves.append(None)
N = len(curves)
print(f"Reconstructed {sum(c is not None for c in curves)} / {N} curves [{time.time()-t0:.1f}s]", flush=True)

# Find index of gamma_0 in dataset (or add it)
gamma0_h = tuple(gamma0)
if gamma0_h in hashes:
    gamma0_idx = hashes.index(gamma0_h)
    print(f"gamma_0 found at index {gamma0_idx}")
else:
    curves.append(gamma0); hashes.append(gamma0_h)
    gamma0_idx = len(curves) - 1
    print(f"gamma_0 added at index {gamma0_idx}")

# Compute f(alpha) = i(alpha, gamma_0) for each alpha
print("Computing f(alpha) = i(alpha, gamma_0)...", flush=True)
f_vals = []
t1 = time.time()
for i, c in enumerate(curves):
    if c is None:
        f_vals.append(None); continue
    try:
        v = gamma0.intersection(c)
    except Exception:
        v = None
    f_vals.append(v)
print(f"f computed [{time.time()-t1:.1f}s]")
level_count = defaultdict(int)
for v in f_vals:
    level_count[v] += 1
print(f"Level distribution: {dict(sorted(level_count.items())[:15])}", flush=True)

# Compute the full pairwise intersection matrix (or just for what we need)
# We actually have edges from data['i0_edges'] and data['i1_edges'].
# But we need pairwise i for ALL pairs to enumerate descending links correctly
# (descending link of alpha is a flag complex on { beta : i(alpha,beta)<=1, f(beta)<f(alpha) })
# and within that link we still need pairwise i<=1 between any two vertices.

# Use stored edges to build adjacency: i<=1 edges
adj = defaultdict(set)
edge_iv = {}
for i, j in data['i0_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[(min(i,j), max(i,j))] = 0
for i, j in data['i1_edges']:
    adj[i].add(j); adj[j].add(i); edge_iv[(min(i,j), max(i,j))] = 1

# If gamma_0 was added, compute its edges to all other curves
if gamma0_idx == N:
    print("Computing gamma_0 edges to all curves...", flush=True)
    for j in range(N):
        if curves[j] is None: continue
        try:
            v = gamma0.intersection(curves[j])
        except Exception:
            continue
        if v <= 1:
            adj[gamma0_idx].add(j); adj[j].add(gamma0_idx)
            edge_iv[(min(gamma0_idx, j), max(gamma0_idx, j))] = v

# === Case k=1 verification ===
print("\n=== CASE k=1: descending link should be a cone over gamma_0 ===", flush=True)
level1 = [i for i, v in enumerate(f_vals) if v == 1]
print(f"Level-1 curves: {len(level1)}")
sample1 = level1[:20]   # check 20 of them

results_k1 = []
for alpha_idx in sample1:
    # descending link: { beta : (alpha,beta) is edge, f(beta) < 1 }
    DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 1]
    # check gamma_0 is in DL
    has_gamma0 = gamma0_idx in DL
    # check gamma_0 connects to every other vertex of DL
    gamma0_universal = True
    if has_gamma0:
        for b in DL:
            if b == gamma0_idx: continue
            key = (min(b, gamma0_idx), max(b, gamma0_idx))
            if key not in edge_iv:
                gamma0_universal = False; break
    results_k1.append({
        'alpha': alpha_idx,
        'DL_size': len(DL),
        'has_gamma0': has_gamma0,
        'gamma0_universal': gamma0_universal,
    })
    print(f"  alpha={alpha_idx}: |DL|={len(DL)}, gamma_0 in DL: {has_gamma0}, universal: {gamma0_universal}")

# === Case k=2 verification ===
print("\n=== CASE k=2: descending link contractibility numerical check ===", flush=True)
level2 = [i for i, v in enumerate(f_vals) if v == 2]
print(f"Level-2 curves: {len(level2)}")
sample2 = level2[:15]   # check 15

results_k2 = []
for alpha_idx in sample2:
    DL = [b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < 2]
    if len(DL) < 2:
        results_k2.append({'alpha': alpha_idx, 'DL_size': len(DL), 'note': 'too small'})
        continue
    # Build flag complex on DL
    st = gudhi.SimplexTree()
    for v in DL:
        st.insert([v])
    for i in range(len(DL)):
        for j in range(i+1, len(DL)):
            a, b = DL[i], DL[j]
            key = (min(a,b), max(a,b))
            if key in edge_iv:
                st.insert([a, b])
    st.expansion(4)
    # Compute Betti
    persist = st.persistence(persistence_dim_max=True)
    bettis = st.betti_numbers()
    n_simp = st.num_simplices()
    results_k2.append({
        'alpha': alpha_idx,
        'DL_size': len(DL),
        'num_simplices': n_simp,
        'bettis': bettis,
    })
    print(f"  alpha={alpha_idx}: |DL|={len(DL)}, |simplices|={n_simp}, Betti={bettis}")

# === Surgery verification: build sigma_alpha for level-2 curves ===
print("\n=== Surgery: try to find sigma_alpha for level-2 alpha (i(sigma,gamma0)=0, i(sigma,alpha)<=1) ===", flush=True)
results_surg = []
for alpha_idx in sample2[:5]:
    alpha = curves[alpha_idx]
    if alpha is None: continue
    # Find all level-0 curves that are in adj[alpha_idx]
    # i.e., curves disjoint from gamma_0 AND with i<=1 with alpha
    candidates = [b for b in adj[alpha_idx] if f_vals[b] == 0]
    print(f"  alpha={alpha_idx}: {len(candidates)} candidate sigma_alpha curves (i(sigma,gamma_0)=0, i(sigma,alpha)<=1)")
    results_surg.append({'alpha': alpha_idx, 'num_candidates': len(candidates), 'sample': candidates[:5]})

# Save
out = {
    'gamma0_name': gamma0_name,
    'gamma0_idx': gamma0_idx,
    'level_distribution': dict(sorted(level_count.items())[:15]),
    'k1_results': results_k1,
    'k2_results': results_k2,
    'surgery_results': results_surg,
    'time_total': time.time() - t0,
}
with open(OUT, 'w') as f:
    json.dump(out, f, indent=2, default=str)
print(f"\nSaved {OUT} [total: {time.time()-t0:.1f}s]")
