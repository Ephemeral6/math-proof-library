"""
Direction B (analytic, profile): Does the identity
    i(σ_α, β) = i(α, β)
hold for ALL β ∈ Lk^↓(α), or only for β in the induced 4-cycle?

This determines the strength of the structural claim:
  - If it holds for all β ∈ Lk^↓(α), then σ_α is "intersection-equivalent"
    to α from the perspective of the descending link — a much stronger
    property than just W4-filling.
  - If it holds only for cycle vertices, then there's a special compatibility
    between the cycle and the surgery; the proof of (W4) would need to
    construct σ_α per-cycle.

Test on each of the 6 unique (α, σ_α) pairs from non-chordal DLs on S_{1,2}.
"""
import curver, json, networkx as nx
from collections import defaultdict, Counter
from itertools import combinations

DATA_PATH = '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json'

S = curver.load(1, 2)
gamma0 = S.curves['a_0']
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


# Find non-chordal DLs and their canonical σ_α
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

unique_pairs = {}
for alpha_idx, k, cyc, sigma in records:
    unique_pairs[(alpha_idx, sigma, k)] = unique_pairs.get((alpha_idx, sigma, k), [])
    unique_pairs[(alpha_idx, sigma, k)].append(cyc)

print("Direction B: σ_α intersection profile across the WHOLE descending link.")
print("=" * 78)
print()

table_global = Counter()
table_cycle  = Counter()
table_noncyc = Counter()

for (alpha_idx, sigma, k_alpha), cycs in unique_pairs.items():
    G, DL = build_dl_graph(alpha_idx, k_alpha)
    cycle_vertices = set()
    for c in cycs: cycle_vertices.update(c)
    print(f"\n=== α = {alpha_idx} (k={k_alpha}), σ = {sigma}, |DL| = {len(DL)} ===")
    print(f"    cycle vertices: {sorted(cycle_vertices)}")
    print(f"    {'β':>5} {'iα':>4} {'iσ':>4} {'fβ':>4} {'in 4-cyc?':>10}")
    print(f"    " + "-" * 35)

    bumps = 0
    for β in DL:
        iα_β = i_query(alpha_idx, β)
        iσ_β = i_query(sigma, β)
        in_cyc = β in cycle_vertices
        flag = "  bump!" if iσ_β > iα_β else ""
        print(f"    {β:>5} {iα_β:>4} {iσ_β:>4} {f_vals[β]:>4} {('yes' if in_cyc else 'no'):>10}{flag}")
        table_global[(iα_β, iσ_β)] += 1
        if in_cyc:
            table_cycle[(iα_β, iσ_β)] += 1
        else:
            table_noncyc[(iα_β, iσ_β)] += 1
        if iσ_β > iα_β:
            bumps += 1
    print(f"    cases where iσ > iα: {bumps}")

print()
print("=" * 78)
print("AGGREGATE (across all 6 unique (α, σ_α) pairs):")
print()
print(f"All DL vertices ({sum(table_global.values())} total):")
for (a, s), c in sorted(table_global.items()):
    print(f"  iα={a}, iσ={s}: {c}")
print(f"\nCycle vertices ({sum(table_cycle.values())} total):")
for (a, s), c in sorted(table_cycle.items()):
    print(f"  iα={a}, iσ={s}: {c}")
print(f"\nNon-cycle vertices ({sum(table_noncyc.values())} total):")
for (a, s), c in sorted(table_noncyc.items()):
    print(f"  iα={a}, iσ={s}: {c}")

# What about EVEN MORE general β? Take a sample of 30 random β not in DL,
# check the bound iσ_β ≤ iα_β + (something).
print()
print("--- Test: σ vs α intersection profile on a SAMPLE outside DL ---")
import random
random.seed(0)
for (alpha_idx, sigma, k_alpha), cycs in list(unique_pairs.items())[:1]:
    DL = sorted([b for b in adj[alpha_idx] if f_vals[b] is not None and f_vals[b] < k_alpha])
    candidates = [b for b in range(len(curves)) if b != alpha_idx and b != sigma and b not in DL]
    sample = random.sample(candidates, min(30, len(candidates)))
    print(f"\nα = {alpha_idx} (k={k_alpha}), σ = {sigma}")
    print(f"  {'β':>5} {'iα':>4} {'iσ':>4} {'fβ':>4} {'iα+iγ0':>7}")
    bumps = 0; very_high_iσ = 0
    for β in sample:
        iα_β = i_query(alpha_idx, β)
        iσ_β = i_query(sigma, β)
        sum_b = iα_β + f_vals[β]
        flag = ""
        if iσ_β > sum_b: flag = "  >> SUM!"
        if iσ_β > iα_β + 2: very_high_iσ += 1
        print(f"  {β:>5} {iα_β:>4} {iσ_β:>4} {f_vals[β]:>4} {sum_b:>7}{flag}")
    print(f"  cases iσ > iα + iγ0: {bumps}, cases iσ > iα + 2: {very_high_iσ}")
