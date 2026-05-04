"""
For each induced 4-cycle in each DL, find the W4-filler vertex(es) and
characterize them: f-level, i(α, ·), i(γ_0, ·), and how they relate to
the 4-cycle vertices.

Goal: extract a uniform construction recipe.
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

# Look at non-chordal cases (these have induced 4-cycles)
print("Characterizing W4 fillers for induced 4-cycles in DLs:")
print("=" * 70)

filler_stats = Counter()
filler_examples = []

for k_alpha in (4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G, DL = build_dl_graph(alpha_idx, k_alpha)
        cycles = find_induced_4cycles(G)
        if not cycles: continue

        for cyc in cycles:
            # Find ALL common neighbors of the 4 cycle vertices in DL
            common_nbrs = set(G.neighbors(cyc[0]))
            for v in cyc[1:]:
                common_nbrs &= set(G.neighbors(v))
            common_nbrs -= set(cyc)
            if not common_nbrs:
                print(f"  α={alpha_idx} (k={k_alpha}), cycle {cyc}: NO FILLER (W4 fails!)")
                continue
            # Characterize each filler
            for filler in common_nbrs:
                f_filler = f_vals[filler]
                cycle_levels = [f_vals[c] for c in cyc]
                pattern = f"f_filler={f_filler}, cycle_levels={sorted(cycle_levels)}"
                filler_stats[pattern] += 1
                if len(filler_examples) < 20:
                    filler_examples.append({
                        'alpha': alpha_idx,
                        'k': k_alpha,
                        'cycle': cyc,
                        'cycle_levels': cycle_levels,
                        'filler': filler,
                        'f_filler': f_filler,
                        'i(α,filler)': i_query(alpha_idx, filler),
                        'i(γ_0,filler)': f_filler,
                    })

print("\nFiller pattern counts:")
for p, c in filler_stats.most_common():
    print(f"  {p}: {c}")

print("\nFiller examples (first 10):")
for ex in filler_examples[:10]:
    print(f"  α={ex['alpha']} k={ex['k']}: cycle {ex['cycle']} levels {ex['cycle_levels']} → filler {ex['filler']} (level {ex['f_filler']}, i(α)={ex['i(α,filler)']})")
