"""
Strategy E: Reverse-engineer the dominator w.

For each (α, β, w) triple where:
  - α has f(α) = k ≥ 2
  - β ∈ Lk↓(α), f(β) = max-level in DL
  - w ∈ Lk↓(α), w dominates β

test which of these candidates equals w (or its image under MCG):
  T_{γ₀}(β), T_{γ₀}^{-1}(β)   -- single Dehn twist about γ₀
  T_α(β), T_α^{-1}(β)         -- single Dehn twist about α
  T_{γ₀}(α), T_{γ₀}^{-1}(α)   -- twist of α (the surgery candidate from Hatcher)
  general surgery curves obtained from α ∩ γ₀

The hash representation in curver is canonical (vector on triangulation), so we
can compare directly.
"""
import curver, json
from collections import defaultdict, Counter
import time

t0 = time.time()
S = curver.load(1, 2)
gamma0_name = list(S.curves.keys())[0]
gamma0 = S.curves[gamma0_name]
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
hash_to_idx = {h: i for i, h in enumerate(hashes)}
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

# Pre-compute the 5 MCG operations on each curve in the dataset:
#   T_{a_0}, T_{a_0}^{-1}, T_{b_0}, T_{b_0}^{-1}, T_{p_1}, T_{p_1}^{-1}, etc.
# We care most about T_{a_0} = T_{gamma_0} and T_{α} for each alpha in DL.

print("Computing T_gamma0 and T_gamma0^-1 of all curves...", flush=True)
T_g0   = S('a_0')        # Dehn twist about gamma_0 = a_0
T_g0_i = T_g0.inverse()

twist_g0   = [tuple(T_g0(c)) for c in curves]
twist_g0_i = [tuple(T_g0_i(c)) for c in curves]
print(f"Done [{time.time()-t0:.1f}s]", flush=True)

# For each k=2 alpha, examine max-level β's and their dominators
k_alpha = 2
print(f"\n=== Reverse-engineering dominators for k = {k_alpha} on S_{{1,2}} ===", flush=True)

stats = Counter()
detail = []
for alpha_idx in levels[k_alpha]:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
    if len(DL) <= 1: continue
    DL_set = set(DL)
    # Build adjacency in DL
    dl_adj = defaultdict(set)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                dl_adj[b1].add(b2); dl_adj[b2].add(b1)

    DL_levels = [f_vals[b] for b in DL]
    max_lvl = max(DL_levels)
    max_lvl_verts = [b for b in DL if f_vals[b] == max_lvl]

    for beta_idx in max_lvl_verts:
        # Find ANY dominator w in DL
        N_beta = (dl_adj[beta_idx]) | {beta_idx}
        dominators = []
        for w in DL:
            if w == beta_idx: continue
            N_w = (dl_adj[w]) | {w}
            if N_beta <= N_w:
                dominators.append(w)
        if not dominators:
            stats['no_dominator'] += 1
            continue

        # For each dominator, identify which "construction" it is
        for w in dominators:
            # Check if w = T_g0(beta) or T_g0^-1(beta)
            beta_h = hashes[beta_idx]
            w_h = hashes[w]
            t1 = twist_g0[beta_idx]
            tn1 = twist_g0_i[beta_idx]
            label = []
            if w_h == t1: label.append("T_g0(β)")
            if w_h == tn1: label.append("T_g0^-1(β)")
            if not label:
                # Check if w is a surgery candidate from alpha: T_g0(α) or T_g0^-1(α)
                ta = twist_g0[alpha_idx]
                tan1 = twist_g0_i[alpha_idx]
                if w_h == ta: label.append("T_g0(α)")
                if w_h == tan1: label.append("T_g0^-1(α)")
            if not label:
                # Try iterated twists T_g0^k(β) for small k
                for kk in (-2, 2, -3, 3):
                    h_op = T_g0 if kk > 0 else T_g0_i
                    bb = curves[beta_idx]
                    for _ in range(abs(kk)):
                        bb = h_op(bb)
                    if tuple(bb) == w_h:
                        label.append(f"T_g0^{kk}(β)")
                        break
            if not label:
                # Check the levels and intersection patterns
                f_w = f_vals[w]
                f_b = f_vals[beta_idx]
                ibw = i_query(beta_idx, w)
                iaw = i_query(alpha_idx, w)
                label.append(f"OTHER(f_w={f_w}, f_β={f_b}, i(β,w)={ibw}, i(α,w)={iaw})")
            detail.append((alpha_idx, beta_idx, w, label[0]))
            for l in label: stats[l] += 1
            break  # only record the first dominator

print(f"\nDominator identification stats (per (α, β, first-dominator)):")
for k, v in stats.most_common():
    print(f"  {k}: {v}")
print(f"\nSample details (first 30):")
for d in detail[:30]:
    print(f"  α={d[0]}, β={d[1]}, w={d[2]}, type: {d[3]}")
