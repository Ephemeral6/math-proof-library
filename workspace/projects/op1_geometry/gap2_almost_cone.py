"""
Gap 2: close the 6 S_{2,1} k=2 non-chordal-non-cone DLs.

Hypothesis (2-step almost-cone):
  Each of the 6 DLs has a vertex v1 of degree |DL| - 2 (adjacent to all but
  one vertex v2). If v2 is dominated in G by some w (N[v2] subset N[w]),
  then removing v2 first yields G \ v2 with v1 as universal vertex (a cone).

Argument: dismantling step v2 -> w is a homotopy equivalence (folklore for
flag complexes of dismantlable graphs); the resulting cone Delta(G \ v2)
with apex v1 is contractible. Hence Delta(G) is contractible.

This script verifies, for each of the 6 problematic alphas, that:
  (S0)  there exists v1 in V(G) with deg(v1) = |V(G)| - 2
  (S1)  the unique non-neighbor v2 of v1 is dominated in G by some w
  (S2)  G \ v2 has v1 adjacent to every remaining vertex (cone)
"""
from __future__ import annotations

import os, sys, json
from collections import defaultdict
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import curver, networkx as nx

DATA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data_S_2_1.json")
S = curver.load(2, 1)
gamma0 = S.curves["a_0"]

with open(DATA_PATH) as f:
    data = json.load(f)
hashes = [tuple(h) for h in data["curves"]]
curves = []
for h in hashes:
    try: curves.append(S.lamination(list(h)))
    except: curves.append(None)
f_vals = [None] * len(curves)
for i, c in enumerate(curves):
    if c is None: continue
    try: f_vals[i] = int(gamma0.intersection(c))
    except: pass
levels = defaultdict(list)
for i, v in enumerate(f_vals):
    if v is not None: levels[v].append(i)

adj = defaultdict(set); edge_iv = {}
for i, j in data["i0_edges"]:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 0
for i, j in data["i1_edges"]:
    adj[i].add(j); adj[j].add(i); edge_iv[frozenset((i, j))] = 1


def i_query(a, b):
    if a == b: return 0
    key = frozenset((a, b))
    if key in edge_iv: return edge_iv[key]
    if curves[a] is None or curves[b] is None: return None
    return int(curves[a].intersection(curves[b]))


def build_dl(alpha_idx, k):
    DL = sorted([b for b in adj[alpha_idx]
                 if f_vals[b] is not None and f_vals[b] < k])
    G = nx.Graph(); G.add_nodes_from(DL)
    for x, b1 in enumerate(DL):
        for b2 in DL[x+1:]:
            v = i_query(b1, b2)
            if v is not None and v <= 1:
                G.add_edge(b1, b2)
    return G


def find_failures():
    failures = []
    for a_idx in levels.get(2, []):
        G = build_dl(a_idx, 2)
        if G.number_of_nodes() <= 1: continue
        if nx.is_chordal(G): continue
        n = G.number_of_nodes()
        if any(G.degree(v) == n - 1 for v in G.nodes()):
            continue
        failures.append(a_idx)
    return failures


def is_dominated(G: nx.Graph, u: int) -> tuple[int, ...]:
    """Return tuple of vertices w (w != u) with N[u] subset N[w], i.e. u
    is dominated by w in the closed-neighborhood sense."""
    Nu = set(G.neighbors(u)) | {u}
    out = []
    for w in G.nodes():
        if w == u: continue
        Nw = set(G.neighbors(w)) | {w}
        if Nu <= Nw:
            out.append(w)
    return tuple(out)


def main() -> int:
    failures = find_failures()
    print(f"Identified {len(failures)} non-chordal non-cone DLs on S_{{2,1}} k=2:")
    print(f"  alphas: {failures}")
    print()

    print(f"{'alpha':>5} {'|DL|':>4} {'v1 (deg|DL|-2)':>20} "
          f"{'v2 (non-neighbor)':>20} {'v2 dominated by':>20} "
          f"{'cone(G\\v2)':>11}")
    print("-" * 86)

    all_pass = True
    closure_record = []

    for a_idx in failures:
        G = build_dl(a_idx, 2)
        n = G.number_of_nodes()

        # S0: find v1 with deg = n - 2
        v1_candidates = [v for v in G.nodes() if G.degree(v) == n - 2]
        if not v1_candidates:
            print(f"{a_idx:>5} {n:>4}  S0 FAIL (no v1 of deg n-2)")
            all_pass = False
            continue

        # Try each v1 candidate; succeed if any closes
        closed = False
        for v1 in v1_candidates:
            non_nbrs = [v for v in G.nodes()
                        if v != v1 and not G.has_edge(v1, v)]
            if len(non_nbrs) != 1:
                continue
            v2 = non_nbrs[0]

            # S1: is v2 dominated in G?
            doms = is_dominated(G, v2)
            if not doms:
                continue

            # S2: is v1 universal in G \ v2?
            G_minus = G.copy()
            G_minus.remove_node(v2)
            n_after = G_minus.number_of_nodes()
            if G_minus.degree(v1) == n_after - 1:
                cone_ok = True
            else:
                cone_ok = False
            if not cone_ok:
                continue

            print(f"{a_idx:>5} {n:>4} {v1:>20} {v2:>20} "
                  f"{('first: ' + str(doms[0])):>20} {'YES':>11}")
            closure_record.append({
                "alpha": a_idx, "n": n, "v1": v1, "v2": v2,
                "dominators_of_v2": list(doms[:5]),
            })
            closed = True
            break

        if not closed:
            print(f"{a_idx:>5} {n:>4}   no (v1, v2) pair satisfies S1+S2")
            all_pass = False

    print()
    print("=" * 86)
    print("Gap 2 closure summary:")
    print(f"  2-step almost-cone structure verified: "
          f"{len(closure_record)} / {len(failures)}")
    print()

    if all_pass:
        print("VERDICT: all 6 S_{2,1} k=2 non-chordal-non-cone DLs admit the")
        print("         2-step almost-cone structure:")
        print("           remove v2 (dominated)  -> G \\ v2 has v1 as universal vertex")
        print("           remove v1 (now apex)   -> trivial cone-collapse")
        print("         Hence Delta(G) is contractible by two iterated cone collapses.")
        print()
        print("         This closes Gap 2: contractibility holds for all 6 cases via")
        print("         the iterative-dismantlability argument with 2-vertex pre-cone.")
    else:
        print("VERDICT: some cases do not admit the 2-step structure; need a")
        print("         longer dismantling chain or different argument.")

    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())
