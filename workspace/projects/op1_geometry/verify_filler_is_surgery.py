"""
Verify hypothesis: the level-(k-2) W4-filler in the descending link of α
(with f(α) = k) is the Hatcher surgery of α along γ_0.

To test this, compare the medium-level filler against Dehn-twist orbits
of α and other potential surgery constructions.
"""
import curver, json, networkx as nx
from collections import defaultdict, Counter
from itertools import combinations

S = curver.load(1, 2)
gamma0 = S.curves['a_0']
data = json.load(open('/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_2.json'))
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
    key = frozenset((a,b))
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
        for ordering in [(combo[0], combo[1], combo[2], combo[3]),
                         (combo[0], combo[1], combo[3], combo[2]),
                         (combo[0], combo[2], combo[1], combo[3])]:
            o = ordering
            edges_ok = (G.has_edge(o[0], o[1]) and G.has_edge(o[1], o[2]) and
                        G.has_edge(o[2], o[3]) and G.has_edge(o[3], o[0]))
            if not edges_ok: continue
            chord_ok = (not G.has_edge(o[0], o[2])) and (not G.has_edge(o[1], o[3]))
            if chord_ok:
                found.append(o); break
    return found

# Generate Dehn-twist orbits of α for comparison
T_g0 = S('a_0'); T_g0_i = T_g0.inverse()

# For each non-chordal DL, identify the level-(k-2) filler and test if it's
# a "surgery-related" curve (Dehn twist or composite).
print("Test: Is the level-(k-2) filler the Hatcher surgery σ_α of α along γ_0?")
print("=" * 70)

results_by_alpha = []
for k_alpha in (4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    target_filler_level = k_alpha - 2
    for alpha_idx in levels[k_alpha]:
        G, DL = build_dl_graph(alpha_idx, k_alpha)
        cycles = find_induced_4cycles(G)
        if not cycles: continue
        # Get common neighbors at target level
        for cyc in cycles:
            common = set(G.neighbors(cyc[0]))
            for v in cyc[1:]: common &= set(G.neighbors(v))
            common -= set(cyc)
            target_fillers = [v for v in common if f_vals[v] == target_filler_level]
            if not target_fillers: continue
            # For each, check: does the filler share many γ_0-intersections with α?
            alpha_curve = curves[alpha_idx]
            for filler in target_fillers:
                f_curve = curves[filler]
                # Check Dehn twist orbits
                t_alpha = T_g0(alpha_curve); t_alpha_h = tuple(t_alpha)
                t_alpha_i = T_g0_i(alpha_curve); t_alpha_i_h = tuple(t_alpha_i)
                if hashes[filler] == t_alpha_h:
                    label = "T_g0(α)"
                elif hashes[filler] == t_alpha_i_h:
                    label = "T_g0^-1(α)"
                else:
                    # Maybe T_β where β is one of the cycle vertices?
                    label = f"OTHER (i(α,filler)={i_query(alpha_idx, filler)}, f={f_vals[filler]})"
                results_by_alpha.append({
                    'k': k_alpha, 'alpha': alpha_idx, 'cycle': cyc,
                    'filler': filler, 'label': label,
                })
                break  # one filler per cycle

print(f"\nTotal target-level fillers analyzed: {len(results_by_alpha)}")
labels = Counter(r['label'].split('(')[0].strip() if 'OTHER' not in r['label'] else 'OTHER' for r in results_by_alpha)
print(f"Label distribution: {dict(labels)}")

# Check the OTHER category in detail
others = [r for r in results_by_alpha if 'OTHER' in r['label']]
print(f"\nOTHER category details: {len(others)}")
for r in others[:10]:
    print(f"  k={r['k']}, α={r['alpha']}, cycle={r['cycle']}, filler={r['filler']}: {r['label']}")

# Are the fillers MCG-related to α? Let's check by computing distance in the
# Cayley graph of MCG / orbits.
print("\n--- Test: how MCG-related is the filler to α? ---")
# Compute T_g0^k(alpha) for various k and see if filler matches any
sample = others[:5]
for r in sample:
    alpha_idx = r['alpha']; filler = r['filler']
    print(f"\nα={alpha_idx}, filler={filler}, target_level={r['k']-2}")
    cur = curves[alpha_idx]
    found = None
    for n in range(-3, 4):
        if n == 0: continue
        op = T_g0 if n > 0 else T_g0_i
        c = curves[alpha_idx]
        for _ in range(abs(n)):
            c = op(c)
        if tuple(c) == hashes[filler]:
            found = f"T_g0^{n}(α)"; break
    print(f"  T_g0^k(α) match (k=-3..3): {found if found else 'NONE'}")
    # Try T_alpha(γ_0)
    Talp = S(curves[alpha_idx].mcg_name() if hasattr(curves[alpha_idx], 'mcg_name') else None)
    # Skip — α probably doesn't have a name
    # Try the 4-cycle vertices' twists
    for cyc_v in r['cycle']:
        try:
            cv_curve = curves[cyc_v]
            # T_β(α) using the MCG action on curves
            # Actually we need a way to apply T_β to α; in curver this is not direct
            pass
        except: pass
