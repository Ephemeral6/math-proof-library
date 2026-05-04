"""
Direction B (refined #2): Test the WEAKER form
    every non-chordal DL has SOME universal vertex (not necessarily at level k-2)
across all DLs on S_{1,2}, S_{2,1}, S_{1,1}.

If true: every non-chordal DL is a cone, hence contractible.
Combined with chordality for the rest, this closes contractibility.

This is exactly the "Lemma 11.4(b) (universal-vertex form)" the report
disproves. We're re-examining: maybe it's true for k≥4 specifically
(where chordality starts to fail).
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
    gamma0 = S.curves[list(S.curves.keys())[0]]
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

    n_chordal = n_nonchordal_cone = n_nonchordal_noncone = 0
    failure_records = []
    nonchordal_cone_levels = Counter()  # level of universal vertex relative to k

    for k in k_range:
        if k not in levels: continue
        for alpha_idx in levels[k]:
            G, DL = build_DL(alpha_idx, k)
            if len(DL) <= 1:
                # singleton or empty: trivially OK
                continue
            is_chordal = nx.is_chordal(G)
            if is_chordal:
                n_chordal += 1
                continue
            # Non-chordal: any universal vertex?
            univ = []
            for v in DL:
                degree = G.degree(v)
                if degree == len(DL) - 1:  # connected to all others
                    univ.append(v)
            if univ:
                n_nonchordal_cone += 1
                # record level of universal relative to k
                for v in univ:
                    nonchordal_cone_levels[(k, f_vals[v], k - f_vals[v])] += 1
                    break  # just one
            else:
                n_nonchordal_noncone += 1
                failure_records.append({
                    'alpha': alpha_idx, 'k': k,
                    'DL_size': len(DL),
                    'level_dist': Counter(f_vals[v] for v in DL),
                    'is_chordal': is_chordal,
                })

    print(f"  Chordal DLs: {n_chordal}")
    print(f"  Non-chordal DLs that ARE cones: {n_nonchordal_cone}")
    print(f"  Non-chordal DLs that are NOT cones: {n_nonchordal_noncone}")
    print(f"  Universal-vertex level relative to k (when cone):")
    for (k_a, lvl_v, diff), c in sorted(nonchordal_cone_levels.items()):
        print(f"    k={k_a}, level(σ)={lvl_v}, k-level(σ)={diff}: {c}")
    if failure_records:
        print(f"\n  NON-CHORDAL NON-CONE DLs (these break the strategy):")
        for f in failure_records[:5]:
            print(f"    α={f['alpha']}, k={f['k']}, |DL|={f['DL_size']}, levels={dict(f['level_dist'])}")
    return (n_chordal, n_nonchordal_cone, n_nonchordal_noncone, failure_records)


print("Direction B (refined #2): every non-chordal DL is a cone?")
print("=" * 78)
all_results = {}
for label, gn, path in DATA_PATHS:
    try:
        all_results[label] = run(label, gn, path, k_range=range(2, 9))
    except FileNotFoundError:
        print(f"\n{label}: data file not found, skipping.")

print()
print("=" * 78)
print("AGGREGATE")
print("=" * 78)
tc = tnc_c = tnc_nc = 0
for label, (c, nc_c, nc_nc, _) in all_results.items():
    tc += c; tnc_c += nc_c; tnc_nc += nc_nc
    print(f"  {label}: chordal={c}, non-chordal-cone={nc_c}, non-chordal-NON-cone={nc_nc}")
print(f"\nTotals: chordal={tc}, non-chordal-cone={tnc_c}, non-chordal-NON-cone={tnc_nc}")
print()
print(f"Strategy: chordal ⇒ PEO ⇒ dismantlable; non-chordal-cone ⇒ cone ⇒ contractible.")
print(f"Strategy works on: {tc + tnc_c} / {tc + tnc_c + tnc_nc} DLs.")
print(f"Strategy fails on: {tnc_nc} non-chordal non-cone DLs.")
