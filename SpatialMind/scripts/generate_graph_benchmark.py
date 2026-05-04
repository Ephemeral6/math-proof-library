"""Generate the 100-pair benchmark for graph_connectivity (terminal 5, dimension 2).

20 random graphs (8-12 vertices, edge prob 0.4-0.6) x 5 edge deletions each.
Each case carries a RelationComparison with the bridge / non-bridge data
that lets the agent see whether a deletion was a critical step or not.

Outputs benchmarks/graph_connectivity/level_1.json ... level_5.json
mirroring the surface_topology / knot_theory layout.
"""

from __future__ import annotations

import random
import sys
import time
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
MATH_ROOT = ROOT.parent
for p in (str(ROOT), str(MATH_ROOT)):
    if p not in sys.path:
        sys.path.insert(0, p)

from SpatialMind.core.benchmark import ExperimentCase, build_benchmark_suite
from SpatialMind.core.counterfactual import CounterfactualInput
from SpatialMind.domains.graph_connectivity.counterfactual import (
    GraphCounterfactualGenerator,
)
from SpatialMind.domains.graph_connectivity.engine import GraphEngine

N_GRAPHS = 20
TRIALS_PER_GRAPH = 5
SEED = 2026


def main():
    random.seed(SEED)
    engine = GraphEngine(seed=SEED)

    all_cases: list[ExperimentCase] = []
    bridge_count = 0
    non_bridge_count = 0
    connectivity_lost_count = 0

    t0 = time.time()
    graph_idx = 0
    attempts = 0
    # Use a sparse model: random spanning tree + a few extra edges. This
    # guarantees connectivity and produces a roughly even mix of bridge vs
    # non-bridge edges (Erdos-Renyi with high p crowds out bridges).
    while graph_idx < N_GRAPHS and attempts < N_GRAPHS * 10:
        attempts += 1
        n = random.randint(8, 12)
        # Build random spanning tree via random Prufer sequence.
        if n == 1:
            tree_edges = []
        elif n == 2:
            tree_edges = [(0, 1)]
        else:
            prufer = [random.randint(0, n - 1) for _ in range(n - 2)]
            degree = [1] * n
            for v in prufer:
                degree[v] += 1
            tree_edges = []
            for v in prufer:
                for u in range(n):
                    if degree[u] == 1:
                        tree_edges.append((min(u, v), max(u, v)))
                        degree[u] -= 1
                        degree[v] -= 1
                        break
            leaves = [u for u in range(n) if degree[u] == 1]
            if len(leaves) >= 2:
                u, v = leaves[0], leaves[1]
                tree_edges.append((min(u, v), max(u, v)))

        # Add a few extra edges (creating cycles -> non-bridge edges).
        n_extra = random.randint(2, max(2, n // 2))
        extra = set()
        possible = [(i, j) for i in range(n) for j in range(i + 1, n)
                    if (i, j) not in set(tree_edges)]
        random.shuffle(possible)
        for e in possible[:n_extra]:
            extra.add(e)
        edges = sorted(set(tree_edges) | extra)
        G = engine.construct({
            "n_vertices": n, "edges": [list(e) for e in edges],
            "object_id": f"R{graph_idx:02d}_n{n}",
        })

        if len(G.edges) < TRIALS_PER_GRAPH:
            continue

        # Pick TRIALS_PER_GRAPH distinct edges to delete.
        edge_choices = random.sample(list(G.edges), k=TRIALS_PER_GRAPH)

        for trial, edge in enumerate(edge_choices):
            tr = engine.transform(G, {"type": "delete_edge", "edge": list(edge)})
            G_after = engine.construct({
                "n_vertices": G.n_vertices,
                "edges": [list(e) for e in G.edges if e != edge],
                "object_id": f"{G.object_id}-del-{edge[0]}-{edge[1]}-t{trial}",
            })
            cmp = engine.compare(G, G, G_after, tr, detail_level=4)
            ec = ExperimentCase(
                case_id=f"{G.object_id}-t{trial}",
                object_a_id=G.object_id,
                object_b_id=G.object_id,
                transformed_a_id=G_after.object_id,
                transform_result=tr,
                comparison=cmp,
                metadata={
                    "graph_idx": graph_idx,
                    "n_vertices": G.n_vertices,
                    "n_edges_before": len(G.edges),
                    "deleted_edge": list(edge),
                    "trial": trial,
                    # is_bridge / connectivity_lost intentionally NOT in metadata
                    # so condition 000 doesn't trivially leak the answer; this
                    # info appears in transform_trace (T) / detailed_comparison (R).
                },
            )
            all_cases.append(ec)
            if tr.trace.delta["is_bridge"]:
                bridge_count += 1
            else:
                non_bridge_count += 1
            if tr.trace.delta["connectivity_lost"]:
                connectivity_lost_count += 1

        graph_idx += 1
        print(f"  graph {graph_idx-1:02d}: n={n}, m={len(G.edges)}, "
              f"connected={engine.invariants(G)['is_connected']}, "
              f"bridges={engine.invariants(G)['n_bridges']}")

    t1 = time.time()
    print(f"\nTotal: {len(all_cases)} cases in {t1 - t0:.1f}s")
    print(f"  bridge deletions: {bridge_count}")
    print(f"  non-bridge deletions: {non_bridge_count}")
    print(f"  connectivity lost: {connectivity_lost_count}")

    # ------ Counterfactual generation on a representative graph ------
    # Use the first graph that has at least 1 bridge and 1 non-bridge edge.
    cf_cases = []
    cf_gen = GraphCounterfactualGenerator(engine=engine, seed=SEED)
    for ec in all_cases:
        G_ref = engine.construct({
            "n_vertices": ec.metadata["n_vertices"],
            "edges": [list(e) for e in [ec.transform_result.trace.before_state] if False] or
                     # Reconstruct from case metadata
                     [],
            "object_id": ec.object_a_id,
        })
        # Simpler: just reconstruct by re-running random gen with same seed.
        # Actually easier: pick a fresh graph deterministically.
        break
    # Reconstruct first graph by name.
    # For CF we can use a clean small one.
    G_cf = engine.construct({
        "n_vertices": 6,
        "edges": [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [1, 3], [2, 4]],
        "object_id": "CF_demo",
    })
    cf_cases = cf_gen.generate(CounterfactualInput(
        engine=engine, object_a=G_cf, object_b=G_cf,
        operation={"type": "delete_edge"}, conditions={},
    ))
    n_critical = sum(1 for c in cf_cases if c.condition_is_critical)
    print(f"\nCounterfactual: {len(cf_cases)} cases, {n_critical} critical")
    for c in cf_cases:
        flag = "CRIT" if c.condition_is_critical else "    "
        print(f"  [{flag}] {c.strategy.value}: delta={c.delta}")

    # ------ Build & save the 5-level benchmark ------
    suite = build_benchmark_suite("graph_connectivity", all_cases, cf_cases)
    out_dir = ROOT / "benchmarks" / "graph_connectivity"
    suite.save_all(out_dir)
    print(f"\nBenchmark saved to {out_dir}:")
    for level in range(1, 6):
        bl = suite.levels[level]
        path = out_dir / f"level_{level}.json"
        size = path.stat().st_size
        print(f"  Level {level}: {bl.n_cases} cases, "
              f"{len(bl.counterfactual)} CF, {size:,} bytes")

    # ------ Quick stats summary ------
    n_v = Counter(ec.metadata["n_vertices"] for ec in all_cases)
    print(f"\nVertex count distribution: {dict(sorted(n_v.items()))}")
    bridge_dist = Counter((bool(ec.transform_result.trace.delta["is_bridge"]),
                           bool(ec.transform_result.trace.delta["connectivity_lost"]))
                          for ec in all_cases)
    print(f"(is_bridge, connectivity_lost): {dict(bridge_dist)}")


if __name__ == "__main__":
    main()
