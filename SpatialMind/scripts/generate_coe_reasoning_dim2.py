"""CoE Geometric Reasoning Benchmark — Dimension 2 (graph connectivity).

16 questions on bridges, components, articulation points. Each question has
3 sub-parts; engine outputs (`GraphEngine`) provide ground truth, and CoE
bundles are scrubbed of any directly-answering field.
"""

from __future__ import annotations

import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.domains.graph_connectivity.engine import GraphEngine
from SpatialMind.scripts.coe_reasoning_common import make_question, write_benchmark

OUT_DIR = os.path.join(
    _ROOT, "SpatialMind", "benchmarks", "coe_reasoning", "dim2_graph"
)


# ---------------------------------------------------------------- helpers

def _adj_dict(G):
    adj = {i: [] for i in range(G.n_vertices)}
    for u, v in G.edges:
        adj[u].append(v)
        adj[v].append(u)
    return {i: sorted(neis) for i, neis in adj.items()}


def _R_for_graph(engine, G, neighbour_label="adjacency"):
    """Adjacency + degree only; no bridge / component summary."""
    deg = engine._degrees(G)
    return {
        "n_vertices": G.n_vertices,
        "n_edges": len(G.edges),
        "edges": [list(e) for e in G.edges],
        "degrees": dict(sorted(deg.items())),
        "adjacency_list": _adj_dict(G),
        "note": (
            "Adjacency list is the raw structure; bridge / component "
            "info is intentionally NOT included — derive it yourself."
        ),
    }


def _T_for_delete(engine, G, edge):
    """Transform: delete the given edge; trace shows is_bridge and component change."""
    tr = engine.transform(G, {"type": "delete_edge", "edge": list(edge)})
    return {
        "operation": "delete_edge",
        "deleted_edge": list(edge),
        "before": {
            "n_edges": tr.trace.before_state["n_edges"],
            "is_connected": tr.trace.before_state["is_connected"],
            "n_components": tr.trace.before_state["n_components"],
        },
        "after": {
            "n_edges": tr.trace.after_state["n_edges"],
            "is_connected": tr.trace.after_state["is_connected"],
            "n_components": tr.trace.after_state["n_components"],
        },
        "delta": {
            "is_bridge": tr.trace.delta["is_bridge"],
            "components_change": tr.trace.delta["components_change"],
            "connectivity_lost": tr.trace.delta["connectivity_lost"],
        },
        "note": (
            "Trace tells you what the deletion did. To answer questions about "
            "OTHER potential bridges, examine the adjacency list directly."
        ),
    }


def _C_for_graph(engine, G, bridge_edge=None, non_bridge_edge=None):
    """Counterfactual: contrast deleting a bridge vs a non-bridge."""
    cases = []
    if bridge_edge:
        tr_b = engine.transform(G, {"type": "delete_edge", "edge": list(bridge_edge)})
        cases.append({
            "alternative_deleted_edge": list(bridge_edge),
            "result": {
                "is_bridge": tr_b.trace.delta["is_bridge"],
                "components_change": tr_b.trace.delta["components_change"],
            },
        })
    if non_bridge_edge:
        tr_n = engine.transform(G, {"type": "delete_edge", "edge": list(non_bridge_edge)})
        cases.append({
            "alternative_deleted_edge": list(non_bridge_edge),
            "result": {
                "is_bridge": tr_n.trace.delta["is_bridge"],
                "components_change": tr_n.trace.delta["components_change"],
            },
        })
    return {
        "alternative_deletions": cases,
        "note": (
            "Each entry shows what would happen if a DIFFERENT edge were "
            "deleted instead — provides bridge-vs-non-bridge contrast."
        ),
    }


def _components_after(engine, G, edge):
    e = tuple(sorted(edge))
    remaining = tuple(x for x in G.edges if x != e)
    G2 = type(G)(object_id="_tmp", n_vertices=G.n_vertices, edges=remaining)
    return engine._components(G2)


# -------------------------------------------------------------- questions

def make_q_bridge_test(qid, engine, edges, n_vertices, deleted_edge,
                       cf_bridge=None, cf_nonbridge=None):
    """Type A: given G and deletion of edge e, ask is-bridge / components / total bridges."""
    G = engine.construct({"n_vertices": n_vertices, "edges": edges})
    deleted = tuple(sorted(deleted_edge))
    is_bridge = deleted in [tuple(e) for e in engine._bridges(G)]
    comps_after = _components_after(engine, G, deleted)
    total_bridges = len(engine._bridges(G))

    stem = (
        f"给定无向图 G：顶点 {{0, ..., {n_vertices - 1}}}，边集\n"
        f"  E = {[list(e) for e in G.edges]}\n"
        f"现在考虑从 G 中删除一条边 e = {list(deleted)}。"
    )
    subqs = [
        {"label": "(a)", "text": f"删除 e={list(deleted)} 之后，G 是否仍连通？请回答 1（连通）或 0（不连通）。",
         "answer_type": "integer", "answer": int(len(comps_after) == 1)},
        {"label": "(b)", "text": "删除 e 之后图有多少个连通分量？",
         "answer_type": "integer", "answer": len(comps_after)},
        {"label": "(c)", "text": "原图 G 中总共有多少条桥边（删去后会增加分量数的边）？",
         "answer_type": "integer", "answer": total_bridges},
    ]
    R = _R_for_graph(engine, G)
    T = _T_for_delete(engine, G, deleted)
    C = _C_for_graph(engine, G, cf_bridge, cf_nonbridge)
    gt = {
        "edges": [list(e) for e in G.edges],
        "deleted_edge": list(deleted),
        "is_bridge": is_bridge,
        "n_components_after": len(comps_after),
        "total_bridges": total_bridges,
    }
    return make_question(qid, "bridge_test", stem, subqs, gt, R, T, C)


def make_q_global_topology(qid, engine, edges, n_vertices, anchor_edge):
    """Type B: given G, predict (a) #components in G, (b) #bridges, (c) #articulation points."""
    G = engine.construct({"n_vertices": n_vertices, "edges": edges})
    inv = engine.invariants(G)
    stem = (
        f"给定无向图 G：顶点 {{0, ..., {n_vertices - 1}}}，边集\n"
        f"  E = {[list(e) for e in G.edges]}"
    )
    subqs = [
        {"label": "(a)", "text": "G 有多少个连通分量？",
         "answer_type": "integer", "answer": inv["n_components"]},
        {"label": "(b)", "text": "G 有多少条桥边？",
         "answer_type": "integer", "answer": inv["n_bridges"]},
        {"label": "(c)", "text": "G 有多少个割点（articulation points，删去后增加分量数的顶点）？",
         "answer_type": "integer", "answer": inv["n_articulation_points"]},
    ]
    R = _R_for_graph(engine, G)
    T = _T_for_delete(engine, G, anchor_edge)
    C = _C_for_graph(engine, G)
    gt = {
        "edges": [list(e) for e in G.edges],
        "n_components": inv["n_components"],
        "n_bridges": inv["n_bridges"],
        "n_articulation_points": inv["n_articulation_points"],
    }
    return make_question(qid, "global_topology", stem, subqs, gt, R, T, C)


# ------------------------------------------------------------------ main

def main():
    e = GraphEngine()

    questions = []

    # Q1-Q8: bridge_test on small graphs (8-10 vertices). Mix of bridge / non-bridge deletions.
    bridge_specs = [
        # (edges, n, deleted, cf_bridge, cf_nonbridge)
        ([[0,1],[1,2],[2,3],[3,4],[4,0],[2,5],[5,6]], 7, [5, 6], [5, 6], [0, 1]),
        ([[0,1],[1,2],[2,3],[3,0],[0,2],[3,4]], 5, [3, 4], [3, 4], [0, 2]),
        ([[0,1],[1,2],[2,0],[0,3],[3,4],[4,5],[5,3]], 6, [0, 3], [0, 3], [0, 1]),
        ([[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]], 8, [3, 4], [3, 4], None),
        ([[0,1],[1,2],[2,3],[3,4],[4,0],[1,3]], 5, [1, 3], None, [1, 3]),
        ([[0,1],[1,2],[0,2],[3,4],[4,5],[3,5],[2,3]], 6, [2, 3], [2, 3], [0, 1]),
        ([[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7]], 8, [0, 4], [0, 4], None),  # star, every edge is a bridge
        ([[0,1],[1,2],[2,3],[3,0],[1,3]], 4, [1, 3], None, [1, 3]),  # K4 minus 2 edges, no bridges
    ]
    for k, (edges, n, deleted, cf_b, cf_n) in enumerate(bridge_specs, 1):
        questions.append(make_q_bridge_test(
            f"dim2_q{k:02d}", e, edges, n, deleted, cf_b, cf_n))

    # Q9-Q16: global_topology on slightly larger graphs.
    global_specs = [
        ([[0,1],[1,2],[2,3],[3,4],[4,5],[5,0],[1,4]], 6, [1, 4]),  # cycle with chord
        ([[0,1],[2,3],[4,5]], 6, [0, 1]),  # 3 components
        ([[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,0]], 8, [0, 1]),  # 8-cycle
        ([[0,1],[1,2],[2,3],[0,3],[3,4],[4,5],[5,6],[4,6]], 7, [3, 4]),  # 2 cycles joined by bridge
        ([[0,1],[1,2],[1,3],[1,4],[2,5],[3,5],[4,5]], 6, [0, 1]),  # 0--1, 1 to {2,3,4}, all to 5
        ([[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,9],[9,0]], 10, [0, 1]),  # 10-cycle
        ([[0,1],[2,3],[3,4],[4,5],[2,5],[5,6],[6,7],[7,8],[6,8]], 9, [2, 3]),  # disconnected: {0,1} | {2..8}
        ([[0,1],[0,2],[1,2],[2,3],[3,4],[3,5],[4,5],[5,6],[6,7],[6,8],[7,8]], 9, [2, 3]),
    ]
    for k, (edges, n, anchor) in enumerate(global_specs, 1):
        questions.append(make_q_global_topology(
            f"dim2_q{k+8:02d}", e, edges, n, anchor))

    write_benchmark(OUT_DIR, dimension=2, dimension_name="graph_connectivity",
                    questions=questions,
                    summary_keys=["is_bridge", "n_components_after", "total_bridges",
                                  "n_components", "n_bridges", "n_articulation_points"])


if __name__ == "__main__":
    main()
