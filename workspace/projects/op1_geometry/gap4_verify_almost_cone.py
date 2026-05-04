"""
For each non-chordal-non-cone k=2 DL on S_{1,3}, S_{2,2}, S_{3,1}, verify
Lemma 7.1's (v_1, v_2, w) almost-cone structure exists.

Lemma 7.1: G has a vertex v_1 of degree |V|-2 (the "almost universal"),
its unique non-neighbour v_2 is dominated by some w in G.
"""
from __future__ import annotations
import sys, time
import curver
import networkx as nx
from collections import defaultdict


def find_almost_cone(G):
    """Find (v_1, v_2, w) triple satisfying Lemma 7.1 hypotheses, or None."""
    n = len(G)
    # Find degree (n-2) vertices
    candidates_v1 = [v for v in G.nodes() if G.degree(v) == n - 2]
    for v1 in candidates_v1:
        # Unique non-neighbour
        non_neighbours = [u for u in G.nodes() if u != v1 and not G.has_edge(v1, u)]
        if len(non_neighbours) != 1:
            continue
        v2 = non_neighbours[0]
        # Check v2 dominated by some w in N(v2)
        N_v2_closed = set(G.neighbors(v2)) | {v2}
        for w in G.neighbors(v2):
            if w == v2: continue
            N_w_closed = set(G.neighbors(w)) | {w}
            if N_v2_closed.issubset(N_w_closed):
                return (v1, v2, w)
    return None


def run_surface(g, n, depth, time_budget=300):
    print(f"\n{'='*78}\nSurface S_{g},{n}, depth {depth}\n{'='*78}")
    S = curver.load(g, n)
    gamma0_name = next(iter(S.curves.keys()))
    gamma0 = S.curves[gamma0_name]
    gen_names = list(S.curves.keys())

    visited = {}
    def add(c):
        key = tuple(c)
        if key not in visited:
            visited[key] = c
            return True
        return False

    seed = list(S.curves.values())
    queue = []
    for c in seed:
        if add(c):
            queue.append(c)

    t0 = time.time()
    for d in range(depth):
        new_queue = []
        for c in queue:
            if time.time() - t0 > time_budget:
                queue = []
                break
            for nm in gen_names:
                for sign in (+1, -1):
                    try:
                        twist = S(nm) if sign > 0 else S(nm).inverse()
                        c_new = twist(c)
                        if add(c_new):
                            new_queue.append(c_new)
                    except Exception:
                        pass
        queue = new_queue

    curves = list(visited.values())
    N = len(curves)
    f_vals = [None]*N
    for i, c in enumerate(curves):
        try: f_vals[i] = int(gamma0.intersection(c))
        except Exception: pass

    levels = defaultdict(list)
    for i, v in enumerate(f_vals):
        if v is not None: levels[v].append(i)

    def i_query(a, b):
        if a == b: return 0
        try: return int(curves[a].intersection(curves[b]))
        except Exception: return None

    print(f"Total curves: {N}, level distribution: {dict((k, len(v)) for k, v in sorted(levels.items()))}")

    neither = []
    for alpha_idx in levels.get(2, []):
        DL = []
        for j in range(N):
            if j == alpha_idx: continue
            if f_vals[j] is None or f_vals[j] >= 2: continue
            v = i_query(alpha_idx, j)
            if v is not None and v <= 1:
                DL.append(j)
        if len(DL) <= 1: continue
        G = nx.Graph(); G.add_nodes_from(DL)
        for ii, b1 in enumerate(DL):
            for b2 in DL[ii+1:]:
                v = i_query(b1, b2)
                if v is not None and v <= 1: G.add_edge(b1, b2)
        is_chord = nx.is_chordal(G)
        has_univ = any(G.degree(v) == len(DL) - 1 for v in DL)
        if (not is_chord) and (not has_univ):
            neither.append((alpha_idx, G))

    print(f"\nNon-chordal-non-cone k=2 alphas: {len(neither)}")
    pass_count = 0
    for alpha_idx, G in neither:
        triple = find_almost_cone(G)
        if triple is not None:
            v1, v2, w = triple
            n = len(G)
            print(f"  alpha={alpha_idx}, |V|={n}, |E|={G.number_of_edges()}, "
                  f"(v_1, v_2, w) = ({v1}, {v2}, {w}) PASS")
            pass_count += 1
        else:
            print(f"  alpha={alpha_idx}, |V|={len(G)}, |E|={G.number_of_edges()}, "
                  f"NO (v_1, v_2, w) FAIL")
    print(f"\nLemma 7.1 (almost-cone) verification: {pass_count}/{len(neither)} PASS")
    return pass_count, len(neither)


if __name__ == "__main__":
    results = []
    for g, n, depth in [(1, 3, 4), (2, 2, 3), (3, 1, 3)]:
        try:
            p, t = run_surface(g, n, depth)
            results.append((g, n, p, t))
        except Exception as e:
            print(f"FAILED on S_{g},{n}: {e}")
            results.append((g, n, None, None))

    print("\n" + "="*78)
    print("SUMMARY: Lemma 7.1 verification on Gap 4 phenomenon across surfaces")
    print("="*78)
    for g, n, p, t in results:
        if p is None:
            print(f"  S_{g},{n}: FAILED")
        else:
            print(f"  S_{g},{n}: {p}/{t} non-chordal-non-cone DLs admit (v_1, v_2, w)")
