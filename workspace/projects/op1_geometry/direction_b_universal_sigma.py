"""
Direction B (analytic, breakthrough): Test the conjecture
    For every α on S_{1,2} or S_{2,1} with f(α) = k ≥ 4, the descending
    link Lk^↓(α) has a *universal vertex* σ_α at level k-2 disjoint from α.

If true, this gives a clean cone structure on every k≥4 DL and closes
OP-1 cleanly:
  - k = 1: universal γ_0 (rigorous, Lemma 11.4a).
  - k = 2,3: DL is chordal (verified) ⇒ dismantlable via PEO.
  - k ≥ 4: DL has universal σ_α at level k-2 ⇒ cone, contractible.

This script tests the conjecture exhaustively over both surfaces, all
levels k = 1, ..., max, including chordal as well as non-chordal DLs.

For each DL where the conjecture holds, we record:
  - σ_α index, level f(σ_α), i(α, σ_α)
  - Number of universal candidates at level k-2.
For each DL where it fails, we record the failure and the closest
candidate (level k-2 vertex with smallest violation count).
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

    print(f"Level distribution: { {k: len(levels[k]) for k in sorted(levels) if k <= 10} }")

    summary = {}
    for k in k_range:
        if k not in levels: continue
        ok = 0; bad = 0; total = 0
        bad_examples = []; ok_examples = []
        for alpha_idx in levels[k]:
            DL = sorted([b for b in adj[alpha_idx]
                         if f_vals[b] is not None and f_vals[b] < k])
            if len(DL) == 0:
                continue
            total += 1
            # Look for σ at level k-2 (or 0 if k-2 < 0):
            target_level = max(k - 2, 0)
            candidates = [v for v in DL
                          if f_vals[v] == target_level
                          and i_query(alpha_idx, v) == 0]
            if not candidates:
                # Try level k-2 even if not disjoint, just to log
                soft_candidates = [v for v in DL if f_vals[v] == target_level]
                bad += 1
                if len(bad_examples) < 5:
                    bad_examples.append({
                        'alpha': alpha_idx, 'k': k, 'reason': 'no level-(k-2) disjoint candidate',
                        'soft_candidates': soft_candidates[:5],
                    })
                continue
            # Test each candidate for universality
            universal_ones = []
            for sigma in candidates:
                # σ must be adjacent to EVERY β ∈ DL \ {σ}, i.e. i(σ, β) ≤ 1
                is_univ = True
                violations = []
                for β in DL:
                    if β == sigma: continue
                    iσ_β = i_query(sigma, β)
                    if iσ_β is None or iσ_β > 1:
                        is_univ = False
                        violations.append((β, iσ_β))
                if is_univ:
                    universal_ones.append(sigma)
            if universal_ones:
                ok += 1
                if len(ok_examples) < 5:
                    ok_examples.append({
                        'alpha': alpha_idx, 'k': k,
                        'sigma_candidates': universal_ones[:3],
                        'DL_size': len(DL),
                        'level_dist': Counter(f_vals[v] for v in DL),
                    })
            else:
                bad += 1
                if len(bad_examples) < 5:
                    # find one with fewest violations
                    least_violation = None
                    for sigma in candidates:
                        viols = sum(1 for β in DL
                                    if β != sigma and (i_query(sigma, β) or 0) > 1)
                        if least_violation is None or viols < least_violation[1]:
                            least_violation = (sigma, viols)
                    bad_examples.append({
                        'alpha': alpha_idx, 'k': k,
                        'reason': 'no universal candidate at level k-2',
                        'closest_candidate': least_violation,
                        'DL_size': len(DL),
                        'level_dist': Counter(f_vals[v] for v in DL if v is not None),
                    })

        summary[k] = (ok, bad, total)
        print(f"  k = {k}: {ok}/{total} have universal σ at level {max(k-2,0)} disjoint from α; {bad} fail")
        if ok_examples:
            print(f"    OK example(s):")
            for e in ok_examples[:2]:
                print(f"      α={e['alpha']}, σ candidates={e['sigma_candidates']}, |DL|={e['DL_size']}, levels={dict(e['level_dist'])}")
        if bad_examples:
            print(f"    FAIL example(s):")
            for e in bad_examples[:2]:
                print(f"      α={e['alpha']}: {e['reason']}")
                if 'closest_candidate' in e:
                    print(f"         closest σ: {e['closest_candidate']}, |DL|={e['DL_size']}, levels={dict(e['level_dist'])}")
                if 'soft_candidates' in e:
                    print(f"         all level-(k-2) candidates (no disjointness): {e['soft_candidates']}")

    return summary


print("Direction B: TEST UNIVERSAL σ_α CONJECTURE EXHAUSTIVELY")
print("=" * 78)
all_summary = {}
for label, gn, path in DATA_PATHS:
    try:
        all_summary[label] = run(label, gn, path, k_range=range(2, 9))
    except FileNotFoundError as e:
        print(f"\n{label}: data file not found ({path}); skipping.")

print()
print("=" * 78)
print("AGGREGATE RESULT")
print("=" * 78)
overall_ok = 0; overall_bad = 0; overall_total = 0
for label, summary in all_summary.items():
    print(f"\n{label}:")
    for k, (ok, bad, total) in sorted(summary.items()):
        print(f"  k = {k}: {ok}/{total} have universal σ_α (disjoint from α, level k-2)")
        overall_ok += ok; overall_bad += bad; overall_total += total
print(f"\nOVERALL: {overall_ok}/{overall_total} DLs have a universal σ_α "
      f"(at level max(k-2, 0), disjoint from α)")
