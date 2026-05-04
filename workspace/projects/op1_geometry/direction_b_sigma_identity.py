"""
Direction B (analytic, identity hunt): given σ_α = canonical filler of an
induced 4-cycle in Lk^↓(α) on S_{1,2}, what is σ_α as a curve?

Empirical fact (from direction_b_bigon_analysis.py): for every β_i in
the cycle, i(σ_α, β_i) = i(α, β_i). And i(σ_α, α) = 0, f(σ_α) = k - 2.

Hypothesis: σ_α is obtained from α by a topological surgery along γ_0
that preserves intersection numbers with all β ∈ Lk(α) up to a controlled
homology shift.

Test for each non-chordal DL:
  1. Try σ_α = T_{γ_0}^n(α) for n ∈ {-3,...,3}.
  2. Try σ_α = T_{γ_0}^n T_α^m(γ_0) for small (n, m).
  3. Compute the homology class of σ_α relative to α, γ_0 (mod arbitrary
     basis): does [σ_α] - [α] equal a multiple of [γ_0]?
"""
import curver, json
from collections import defaultdict, Counter
from itertools import combinations, product

DATA_PATH = '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json'

S = curver.load(1, 2)
gamma0_name = 'a_0'
gamma0 = S.curves[gamma0_name]
data = json.load(open(DATA_PATH))
hashes = [tuple(h) for h in data['curves']]
curves = [S.lamination(list(h)) for h in hashes]
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
    key = frozenset((a, b))
    if key in edge_iv: return edge_iv[key]
    return curves[a].intersection(curves[b])

def build_dl_graph(alpha_idx, k):
    import networkx as nx
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph(); G.add_nodes_from(DL)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G, DL

def find_induced_4cycles(G):
    found = []
    nodes = list(G.nodes())
    for combo in combinations(nodes, 4):
        for perm in [(combo[1], combo[2], combo[3]),
                     (combo[1], combo[3], combo[2]),
                     (combo[2], combo[1], combo[3])]:
            o = (combo[0],) + perm
            edges_ok = (G.has_edge(o[0], o[1]) and G.has_edge(o[1], o[2]) and
                        G.has_edge(o[2], o[3]) and G.has_edge(o[3], o[0]))
            if not edges_ok: continue
            chord_ok = (not G.has_edge(o[0], o[2])) and (not G.has_edge(o[1], o[3]))
            if chord_ok:
                found.append(o); break
    return found


# Operators
T_g0 = S(gamma0_name)
T_g0_inv = T_g0.inverse()

# Find non-chordal DLs and their canonical fillers
records = []
for k_alpha in (4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G, DL = build_dl_graph(alpha_idx, k_alpha)
        cycles = find_induced_4cycles(G)
        if not cycles: continue
        for cyc in cycles:
            common = set(G.neighbors(cyc[0]))
            for v in cyc[1:]: common &= set(G.neighbors(v))
            common -= set(cyc)
            disjoint_target = [v for v in common
                                if f_vals[v] == k_alpha - 2 and i_query(alpha_idx, v) == 0]
            if disjoint_target:
                records.append((alpha_idx, k_alpha, cyc, disjoint_target[0]))

print("Direction B: identity hunt for σ_α.")
print("=" * 78)
print(f"Records (α, k, 4-cycle, σ_α): {len(records)}")
print()

# Group by (alpha, sigma) — the same σ may serve multiple cycles
unique_pairs = {}
for alpha_idx, k, cyc, sigma in records:
    unique_pairs[(alpha_idx, sigma, k)] = unique_pairs.get((alpha_idx, sigma, k), [])
    unique_pairs[(alpha_idx, sigma, k)].append(cyc)
print(f"Unique (α, σ_α) pairs: {len(unique_pairs)}")

# Examine first few pairs in detail
print()
print("--- Test 1: is σ_α = T_{γ_0}^n(α) for some n ∈ {-5,..,5}? ---")
identity_hits = Counter()
for (alpha_idx, sigma, k_alpha), cycs in unique_pairs.items():
    found_n = None
    for n in range(-5, 6):
        if n == 0: continue
        op = T_g0 if n > 0 else T_g0_inv
        c = curves[alpha_idx]
        for _ in range(abs(n)):
            c = op(c)
        if tuple(c) == hashes[sigma]:
            found_n = n; break
    identity_hits[found_n] += 1
print(f"Distribution: {dict(identity_hits)}")

print()
print("--- Test 2: T_{γ_0}^n applied to a CYCLE VERTEX β_i — does it produce σ_α? ---")
for (alpha_idx, sigma, k_alpha), cycs in list(unique_pairs.items())[:3]:
    print(f"\n(α={alpha_idx}, σ={sigma}, k={k_alpha}):")
    for cyc in cycs[:1]:  # one cycle per record
        print(f"  cycle = {cyc}")
        for β in cyc:
            for n in range(-3, 4):
                if n == 0: continue
                op = T_g0 if n > 0 else T_g0_inv
                c = curves[β]
                for _ in range(abs(n)):
                    c = op(c)
                if tuple(c) == hashes[sigma]:
                    print(f"    σ = T_{{γ_0}}^{n}(β_{β})")

print()
print("--- Test 3: homology classes of α, γ_0, σ_α on S_{1,2} ---")
print("(Compute algebraic intersection of each with a fixed basis for H_1)")
# Choose a basis: a_0, b_0 form a torus part. The 2 punctures contribute.
# H_1(S_{1,2}, ℤ) ≅ ℤ^4 (generators: a_0, b_0, two peripheral).
basis_names = list(S.curves.keys())
print(f"  Curver basis curves: {basis_names}")
basis_curves = [S.curves[n] for n in basis_names]

def alg_int(c1, c2):
    # algebraic intersection (signed), if curver supports it.
    # Use intersection_number; curver doesn't expose signed intersection directly,
    # but we can use abs only.
    return c1.intersection(c2)

for (alpha_idx, sigma, k_alpha), _ in list(unique_pairs.items())[:5]:
    α_c = curves[alpha_idx]; σ_c = curves[sigma]
    int_α  = [alg_int(α_c,  b) for b in basis_curves]
    int_σ  = [alg_int(σ_c,  b) for b in basis_curves]
    int_g0 = [alg_int(gamma0, b) for b in basis_curves]
    print(f"  α={alpha_idx} (k={k_alpha}), σ={sigma}:")
    print(f"    |i(α, basis)|  = {int_α}")
    print(f"    |i(γ_0, basis)|= {int_g0}")
    print(f"    |i(σ, basis)|  = {int_σ}")
    diff = [s - a for s, a in zip(int_σ, int_α)]
    print(f"    |i(σ)| - |i(α)| = {diff}  (target: a multiple of |i(γ_0)|?)")
