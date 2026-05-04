"""External benchmark setup — collects ground truth and RTC data.

Part B (knots): for 10 prime knots, gather KnotInfo-convention ground truth
(signature, determinant, Alexander polynomial coefficients in normalized form),
plus the engine's RTC data (PD code + structural invariants).

Part C (graphs): for 5 graphs (Petersen, Karate, ER(15,0.3,seed=42/43/44)),
delete one edge (chosen reproducibly with random.Random(42)) and compute
ground truth for {is_connected, n_bridges, shortest_path(0, n-1)} via NetworkX.

Outputs `external_benchmark_setup.json` with all data.
"""
from __future__ import annotations

import hashlib
import json
import random
from pathlib import Path

import networkx as nx
import numpy as np
import snappy
from sympy import Matrix, Poly, symbols

# ---------------------------------------------------------------------------
# Part B: knots
# ---------------------------------------------------------------------------

KNOTS = ["3_1", "4_1", "5_1", "5_2", "6_1", "6_2", "6_3", "7_1", "7_2", "7_3"]

# KnotInfo / Stoimenov standard signatures (right-handed trefoil = -2 convention).
# Stoimenov tabulates with positive convention (3_1 = +2); KnotInfo and SnapPy
# Seifert-matrix-based signature give the negative. Source URL:
#   https://stoimenov.net/stoimeno/homepage/ptab/sig10.html  (positive sign)
# Convention used in this benchmark: KnotInfo / SnapPy => negate Stoimenov.
GT_SIGNATURE = {
    "3_1": -2, "4_1": 0, "5_1": -4, "5_2": -2,
    "6_1": 0,  "6_2": -2, "6_3": 0, "7_1": -6,
    "7_2": -2, "7_3": -4,
}

# Standard Alexander polynomial coefficients (lowest-to-highest degree).
# Source: https://stoimenov.net/stoimeno/homepage/ptab/a10.html
GT_ALEXANDER_RAW = {
    "3_1": [1, -1, 1],
    "4_1": [-1, 3, -1],
    "5_1": [1, -1, 1, -1, 1],
    "5_2": [2, -3, 2],
    "6_1": [-2, 5, -2],
    "6_2": [-1, 3, -3, 3, -1],
    "6_3": [1, -3, 5, -3, 1],
    "7_1": [1, -1, 1, -1, 1, -1, 1],
    "7_2": [3, -5, 3],
    "7_3": [2, -3, 3, -3, 2],
}

# Determinants = |Δ(-1)|.  Computed below; included for cross-check vs KnotInfo:
# 3_1=3, 4_1=5, 5_1=5, 5_2=7, 6_1=9, 6_2=11, 6_3=13, 7_1=7, 7_2=11, 7_3=13
GT_DETERMINANT = {
    "3_1": 3, "4_1": 5, "5_1": 5, "5_2": 7,
    "6_1": 9, "6_2": 11, "6_3": 13, "7_1": 7,
    "7_2": 11, "7_3": 13,
}


def normalize_alexander(coeffs):
    """Match KnotEngine._normalize_alexander: strip zeros + force positive head."""
    c = list(coeffs)
    while c and c[0] == 0:
        c.pop(0)
    while c and c[-1] == 0:
        c.pop()
    if not c:
        return [0]
    if c[0] < 0:
        c = [-x for x in c]
    return c


def alexander_eval_at_minus_1(coeffs):
    """Δ(-1) evaluated by interpreting coeffs as a polynomial.
    For symmetric (palindromic) polynomials |Δ(-1)| = determinant."""
    return sum(c * ((-1) ** i) for i, c in enumerate(coeffs))


def engine_invariants(name):
    """Run the same path KnotEngine takes: snappy.Link(name) → seifert_matrix → sig/det/alex."""
    L = snappy.Link(name)
    S_list = L.seifert_matrix()
    S = np.array(S_list, dtype=int)
    M = (S + S.T).astype(float)
    eig = np.linalg.eigvalsh(M)
    sig = int(np.sum(eig > 1e-9) - np.sum(eig < -1e-9))
    det = abs(int(round(float(np.linalg.det(M)))))

    t = symbols("t")
    Sm = Matrix(S.tolist())
    alex_expr = (t * Sm - Sm.T).det().expand()
    poly = Poly(alex_expr, t)
    coeffs = [int(c) for c in poly.all_coeffs()]  # highest-first
    norm = normalize_alexander(coeffs)
    pd = [list(c) for c in L.PD_code()]
    return {
        "name": name,
        "pd_code": pd,
        "n_crossings": len(L.crossings),
        "writhe": int(L.writhe()),
        "signature_engine": sig,
        "determinant_engine": det,
        "alexander_coeffs_engine_high_first": coeffs,
        "alexander_coeffs_normalized_engine": norm,
    }


def part_b():
    out = {}
    for name in KNOTS:
        eng = engine_invariants(name)
        gt_alex_low_first = GT_ALEXANDER_RAW[name]
        # Stoimenov gives lowest-first; engine gives highest-first.
        # Normalize both: strip + force positive head.
        gt_alex_norm = normalize_alexander(list(reversed(gt_alex_low_first)))
        # Cross-check: Δ(-1) on raw should give ±determinant
        det_check = abs(alexander_eval_at_minus_1(gt_alex_low_first))
        eng["alexander_gt_raw_low_first"] = gt_alex_low_first
        eng["alexander_gt_normalized"] = gt_alex_norm
        eng["signature_gt"] = GT_SIGNATURE[name]
        eng["determinant_gt"] = GT_DETERMINANT[name]
        eng["determinant_check_alex_minus_1"] = det_check
        # Sanity: engine vs GT
        eng["signature_match_engine_gt"] = eng["signature_engine"] == eng["signature_gt"]
        eng["determinant_match_engine_gt"] = eng["determinant_engine"] == eng["determinant_gt"]
        eng["alexander_match_engine_gt"] = (
            eng["alexander_coeffs_normalized_engine"] == gt_alex_norm
        )
        out[name] = eng
    return out


# ---------------------------------------------------------------------------
# Part C: graphs
# ---------------------------------------------------------------------------

GRAPHS = {
    "Petersen":   {"builder": lambda: nx.petersen_graph()},
    "Karate":     {"builder": lambda: nx.karate_club_graph()},
    "ER_15_03_42": {"builder": lambda: nx.erdos_renyi_graph(15, 0.3, seed=42)},
    "ER_15_03_43": {"builder": lambda: nx.erdos_renyi_graph(15, 0.3, seed=43)},
    "ER_15_03_44": {"builder": lambda: nx.erdos_renyi_graph(15, 0.3, seed=44)},
}


def part_c():
    out = {}
    for gname, info in GRAPHS.items():
        G = info["builder"]()
        # Re-key nodes to ints 0..n-1 (Karate club already uses ints)
        G = nx.convert_node_labels_to_integers(G, first_label=0, ordering="default")
        n = G.number_of_nodes()
        edges = sorted([tuple(sorted((int(u), int(v)))) for u, v in G.edges()])
        rng = random.Random(42)
        deleted_edge = rng.choice(edges)

        G_after = G.copy()
        G_after.remove_edge(*deleted_edge)

        is_connected_post = nx.is_connected(G_after)
        n_bridges_post = sum(1 for _ in nx.bridges(G_after))
        try:
            shortest_post = nx.shortest_path_length(G_after, source=0, target=n - 1)
        except nx.NetworkXNoPath:
            shortest_post = -1
        # all-pairs (used for engine RTC equivalent)
        if is_connected_post:
            all_pairs = dict(nx.all_pairs_shortest_path_length(G_after))
            apsp = {f"{u},{v}": all_pairs[u][v] for u in range(n) for v in range(u+1, n)}
        else:
            apsp = {}
            for u in range(n):
                for v in range(u+1, n):
                    try:
                        apsp[f"{u},{v}"] = nx.shortest_path_length(G_after, u, v)
                    except nx.NetworkXNoPath:
                        apsp[f"{u},{v}"] = -1

        # adjacency list representation for prompt
        adj = {i: sorted(G.neighbors(i)) for i in range(n)}

        out[gname] = {
            "name": gname,
            "n_vertices": n,
            "n_edges": len(edges),
            "edges": [list(e) for e in edges],
            "adjacency_list": {str(k): v for k, v in adj.items()},
            "deleted_edge": list(deleted_edge),
            "is_connected_pre": nx.is_connected(G),
            "is_connected_post_gt": bool(is_connected_post),
            "n_bridges_post_gt": int(n_bridges_post),
            "shortest_path_0_to_nminus1_post_gt": int(shortest_post),
            "all_pairs_shortest_paths_post": apsp,
        }
    return out


def main():
    data = {
        "schema": "external_benchmark_setup_v1",
        "knots": part_b(),
        "graphs": part_c(),
        "ground_truth_sources": {
            "knot_signature":   "https://stoimenov.net/stoimeno/homepage/ptab/sig10.html (Stoimenov +convention; negated for KnotInfo/SnapPy convention)",
            "knot_alexander":   "https://stoimenov.net/stoimeno/homepage/ptab/a10.html",
            "knot_determinant": "Computed as |Δ(-1)|; cross-checked with KnotInfo",
            "graph_ground_truth": "Independently computed via NetworkX 3.6.1 (this script)",
        },
        "script_sha1": hashlib.sha1(Path(__file__).read_bytes()).hexdigest()[:12],
    }
    out_path = Path(__file__).parent / "external_benchmark_setup.json"
    out_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    # Print a concise summary
    print("=== Part B (knots) — engine vs GT ===")
    for name, k in data["knots"].items():
        flags = "".join([
            "S" if k["signature_match_engine_gt"] else "s",
            "D" if k["determinant_match_engine_gt"] else "d",
            "A" if k["alexander_match_engine_gt"] else "a",
        ])
        print(f"  {name}: sig {k['signature_engine']} (gt {k['signature_gt']}), "
              f"det {k['determinant_engine']} (gt {k['determinant_gt']}), "
              f"alex_eng {k['alexander_coeffs_normalized_engine']} "
              f"alex_gt {k['alexander_gt_normalized']}  [{flags}]")
    print("\n=== Part C (graphs) — GT ===")
    for gname, g in data["graphs"].items():
        print(f"  {gname}: n={g['n_vertices']} m={g['n_edges']}, "
              f"deleted={g['deleted_edge']}, "
              f"connected_post={g['is_connected_post_gt']}, "
              f"bridges_post={g['n_bridges_post_gt']}, "
              f"sp(0,{g['n_vertices']-1})={g['shortest_path_0_to_nminus1_post_gt']}")
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
