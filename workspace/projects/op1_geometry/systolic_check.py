"""
Check 6-large condition (no induced 4- or 5-cycles) on all DLs.

Theorem (Januszkiewicz-Świątkowski 2006): A flag complex that is simply connected
and 6-large (i.e., locally 6-large at every link, equivalently the 1-skeleton has
no induced 4-cycle or 5-cycle) is contractible.

If every DL is 6-large: contractibility follows from this standard theorem.

Result expected: NO (we know some DLs have induced 4-cycles).

But let's also check WEAKLY modular: for every edge uv and every w, ∃ x adjacent
to both u and v with d(x,w) ≤ min(d(u,w), d(v,w)).

Weakly modular graphs are dismantlable (Chepoi-Osajda 2014).
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
    G = nx.Graph()
    G.add_nodes_from(DL)
    for i, b1 in enumerate(DL):
        for b2 in DL[i+1:]:
            if i_query(b1, b2) <= 1:
                G.add_edge(b1, b2)
    return G

def has_induced_cycle_of_length(G, length):
    """Check if G has an induced cycle of length exactly `length`."""
    nodes = list(G.nodes())
    for combo in combinations(nodes, length):
        # Try all rotations to find a cyclic ordering with edges between consecutive
        # but no chords
        for start in range(length):
            ordered = [combo[(start + i) % length] for i in range(length)]
            edges_ok = all(G.has_edge(ordered[i], ordered[(i+1) % length]) for i in range(length))
            if edges_ok:
                # Check no chords
                no_chord = True
                for i in range(length):
                    for j in range(i+2, length):
                        if (i, j) == (0, length-1): continue
                        if (j - i) % length == 1: continue
                        if G.has_edge(ordered[i], ordered[j]):
                            no_chord = False; break
                    if not no_chord: break
                if no_chord:
                    return True, ordered
    return False, None

def is_weakly_modular(G):
    """G is weakly modular iff for every edge {u,v} and every w with d(u,w)=d(v,w),
    there exists x adjacent to both u and v with d(x,w) = d(u,w) - 1.
    Plus the second axiom about triples u,v,w with d(u,v)=1 and d(u,w)=d(v,w)+1.
    For practical check, we only check the first (triangle) axiom.
    """
    if not nx.is_connected(G): return None  # only meaningful on connected
    sp = dict(nx.all_pairs_shortest_path_length(G))
    nodes = list(G.nodes())
    for (u, v) in G.edges():
        for w in nodes:
            if w == u or w == v: continue
            du = sp[u].get(w, float('inf'))
            dv = sp[v].get(w, float('inf'))
            if du == dv:
                # Look for x adjacent to both u and v with d(x,w) = du - 1
                common = set(G.neighbors(u)) & set(G.neighbors(v))
                if not any(sp[x].get(w, float('inf')) == du - 1 for x in common):
                    return False, (u, v, w, du)
    return True, None

print("=" * 70)
print("Test 6-large (no induced 4-cycles or 5-cycles)")
print("=" * 70)

results = defaultdict(lambda: {'tested': 0, 'has_4cycle': 0, 'has_5cycle': 0})
for k_alpha in (2, 3, 4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G = build_dl_graph(alpha_idx, k_alpha)
        if G.number_of_nodes() <= 4: continue
        results[k_alpha]['tested'] += 1
        h4, _ = has_induced_cycle_of_length(G, 4)
        if h4: results[k_alpha]['has_4cycle'] += 1
        if not h4 and G.number_of_nodes() >= 5:
            h5, _ = has_induced_cycle_of_length(G, 5)
            if h5: results[k_alpha]['has_5cycle'] += 1

print("\nInduced 4-cycle / 5-cycle counts in DLs of S_{1,2}:")
for k, stats in sorted(results.items()):
    is_6large_count = stats['tested'] - stats['has_4cycle'] - stats['has_5cycle']
    print(f"  k={k}: {is_6large_count}/{stats['tested']} are 6-large; with induced 4-cycle: {stats['has_4cycle']}; with induced 5-cycle (no 4-cycle): {stats['has_5cycle']}")

# Also test S_{1,1} and S_{2,1}
print("\n--- Weakly modular check on other surfaces ---")
def run_wm_on_surface(g, n, data_path, k_values):
    S2 = curver.load(g, n)
    g0 = S2.curves[list(S2.curves.keys())[0]]
    d2 = json.load(open(data_path))
    h2 = [tuple(h) for h in d2['curves']]
    c2 = [S2.lamination(list(h)) for h in h2]
    f2 = [g0.intersection(c) for c in c2]
    lev2 = defaultdict(list)
    for i, v in enumerate(f2): lev2[v].append(i)
    a2 = defaultdict(set); ev2 = {}
    for i, j in d2['i0_edges']:
        a2[i].add(j); a2[j].add(i); ev2[frozenset((i,j))] = 0
    for i, j in d2['i1_edges']:
        a2[i].add(j); a2[j].add(i); ev2[frozenset((i,j))] = 1
    def iq(a, b):
        if a == b: return 0
        k = frozenset((a,b))
        if k in ev2: return ev2[k]
        return c2[a].intersection(c2[b])
    print(f"\n  Surface S_{{{g},{n}}}:")
    for k_alpha in k_values:
        if k_alpha not in lev2: continue
        wm_count = 0; total = 0; not_wm = []
        for alpha_idx in lev2[k_alpha]:
            DL = sorted([b for b in a2[alpha_idx] if f2[b] is not None and f2[b] < k_alpha])
            if len(DL) <= 2: continue
            G = nx.Graph(); G.add_nodes_from(DL)
            for i, b1 in enumerate(DL):
                for b2 in DL[i+1:]:
                    if iq(b1, b2) <= 1: G.add_edge(b1, b2)
            if not nx.is_connected(G): continue
            total += 1
            ok, _ = is_weakly_modular(G)
            if ok: wm_count += 1
            else: not_wm.append(alpha_idx)
        print(f"    k={k_alpha}: {wm_count}/{total} weakly modular" + (f"  [not_wm: {not_wm[:5]}]" if not_wm else ""))

run_wm_on_surface(1, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_1_1.json',
                  k_values=(2, 3, 4, 5, 6, 7, 8))
run_wm_on_surface(2, 1, '/mnt/c/Users/12729/Desktop/Math/workspace/op1_scripts/data_S_2_1.json',
                  k_values=(2, 3, 4))

print("\n" + "=" * 70)
print("Test weakly modular condition (Chepoi-Osajda) on DLs")
print("=" * 70)

results_wm = defaultdict(lambda: {'tested': 0, 'wm': 0, 'not_wm': []})
for k_alpha in (2, 3, 4, 5, 6, 7, 8):
    if k_alpha not in levels: continue
    for alpha_idx in levels[k_alpha]:
        G = build_dl_graph(alpha_idx, k_alpha)
        if G.number_of_nodes() <= 2 or not nx.is_connected(G): continue
        results_wm[k_alpha]['tested'] += 1
        ok, witness = is_weakly_modular(G)
        if ok: results_wm[k_alpha]['wm'] += 1
        else:
            results_wm[k_alpha]['not_wm'].append((alpha_idx, witness))

print("\nWeakly modular counts in DLs of S_{1,2}:")
for k, stats in sorted(results_wm.items()):
    print(f"  k={k}: {stats['wm']}/{stats['tested']} weakly modular")
    if stats['not_wm']:
        print(f"    Counterexamples: {[x[0] for x in stats['not_wm'][:5]]}")
