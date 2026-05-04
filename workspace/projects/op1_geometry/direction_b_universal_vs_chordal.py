"""
Direction B (refinement): the dichotomy between chordal and non-chordal DLs.

Conjecture: every DL is either
  (a) chordal — dismantlable via PEO (perfect elimination ordering), or
  (b) non-chordal — has a universal vertex σ_α at level (k-2)
                    disjoint from α (a cone, hence contractible).

If true, this gives a clean rigorous proof of dismantlability per case.
"""
import curver, json, networkx as nx, sys
from collections import defaultdict, Counter

DATA_PATHS = [
    ('S_1_2', (1, 2),
     '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_2.json'),
    ('S_2_1', (2, 1),
     '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_2_1.json'),
    ('S_1_1', (1, 1),
     '/mnt/c/Users/12729/Desktop/Math/workspace/projects/op1_geometry/data_S_1_1.json'),
]


def run(label, gn, data_path, k_range):
    g, n = gn
    print(f"\n{'='*78}\n=== {label} ===")
    S = curver.load(g, n)
    gamma0_name = list(S.curves.keys())[0]
    gamma0 = S.curves[gamma0_name]
    data = json.load(open(data_path))
    hashes = [tuple(h) for h in data['curves']]
    curves = []
    for h in hashes:
        try: curves.append(S.lamination(list(h)))
        except: curves.append(None)
    f_vals = [None] * len(curves)
    for i, c in enumerate(curves):
        if c is None: continue
        try: f_vals[i] = gamma0.intersection(c)
        except: pass
    levels = defaultdict(list)
    for i, v in enumerate(f_vals):
        if v is not None: levels[v].append(i)

    adj = defaultdict(set); edge_iv = {}
    for i, j in data['i0_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 0
    for i, j in data['i1_edges']:
        adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 1

    def i_query(a, b):
        if a == b: return 0
        key = frozenset((a, b))
        if key in edge_iv: return edge_iv[key]
        if curves[a] is None or curves[b] is None: return None
        return curves[a].intersection(curves[b])

    def build_DL(alpha_idx, k):
        DL = sorted([b for b in adj[alpha_idx]
                     if f_vals[b] is not None and f_vals[b] < k])
        G = nx.Graph(); G.add_nodes_from(DL)
        for i, b1 in enumerate(DL):
            for b2 in DL[i+1:]:
                v = i_query(b1, b2)
                if v is not None and v <= 1:
                    G.add_edge(b1, b2)
        return G, DL

    print(f"k_range = {list(k_range)}")
    n_chordal = n_nonchordal_with_univ = n_nonchordal_no_univ = 0
    failures = []

    for k in k_range:
        if k not in levels: continue
        for alpha_idx in levels[k]:
            G, DL = build_DL(alpha_idx, k)
            if len(DL) == 0: continue
            is_chordal = nx.is_chordal(G)
            if is_chordal:
                n_chordal += 1
                continue
            # Non-chordal: search for universal σ at level k-2 disjoint from α
            target_level = max(k - 2, 0)
            found_univ = False
            best_failure = None
            for v in DL:
                if f_vals[v] != target_level: continue
                if i_query(alpha_idx, v) != 0: continue
                # Universality test
                violation = 0
                for w in DL:
                    if w == v: continue
                    iv = i_query(v, w)
                    if iv is None or iv > 1:
                        violation += 1
                if violation == 0:
                    found_univ = True; break
                if best_failure is None or violation < best_failure[1]:
                    best_failure = (v, violation)
            if found_univ:
                n_nonchordal_with_univ += 1
            else:
                # broader search: any universal σ in DL (any level)?
                any_univ = []
                for v in DL:
                    bad = sum(1 for w in DL
                              if w != v and ((i_query(v, w) or 0) > 1))
                    if bad == 0:
                        any_univ.append((v, f_vals[v]))
                n_nonchordal_no_univ += 1
                failures.append({
                    'alpha': alpha_idx, 'k': k,
                    'DL_size': len(DL),
                    'closest_at_k-2': best_failure,
                    'level_dist': Counter(f_vals[v] for v in DL),
                    'any_universal': any_univ[:5],
                })

    print(f"  Chordal: {n_chordal}")
    print(f"  Non-chordal with universal σ at level k-2 (disjoint from α): {n_nonchordal_with_univ}")
    print(f"  Non-chordal WITHOUT such universal σ: {n_nonchordal_no_univ}")
    if failures:
        print(f"\n  Non-chordal failures (sample):")
        for f in failures[:5]:
            print(f"    α={f['alpha']}, k={f['k']}, |DL|={f['DL_size']}")
            print(f"      closest_σ_at_k-2_disjoint: {f['closest_at_k-2']}")
            print(f"      level dist of DL: {dict(f['level_dist'])}")
            print(f"      ANY universal vertex in DL: {f['any_universal']}")
    return (n_chordal, n_nonchordal_with_univ, n_nonchordal_no_univ, failures)


print("Direction B: chordal vs non-chordal DL dichotomy")
print("=" * 78)
total_results = {}
for label, gn, path in DATA_PATHS:
    try:
        total_results[label] = run(label, gn, path, k_range=range(2, 9))
    except FileNotFoundError:
        print(f"  {label}: data file not found; skipping.")

print()
print("=" * 78)
print("AGGREGATE")
print("=" * 78)
total_c = total_nc_u = total_nc_nu = 0
for label, (c, nc_u, nc_nu, _) in total_results.items():
    total_c += c; total_nc_u += nc_u; total_nc_nu += nc_nu
    print(f"  {label}: chordal={c}, nonchordal-with-σ={nc_u}, nonchordal-no-σ={nc_nu}")
print(f"\nTotals: chordal={total_c}, nonchordal-with-σ={total_nc_u}, nonchordal-no-σ={total_nc_nu}")
print(f"\nKey claim: every NON-CHORDAL DL admits a universal σ_α at level k-2.")
print(f"  Verified: {total_nc_u}/{total_nc_u + total_nc_nu}.")
print(f"  Counterexamples: {total_nc_nu}.")
