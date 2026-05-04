"""GraphConnectivityEngine — 图的边删除过程中的连通性相变。

construct(spec) -> GraphObject
  spec = {"n_vertices": 8, "edges": [[0,1],[1,2],...]} or
  spec = {"type": "random", "n": 10, "p": 0.5, "seed": 42}

relate(G1, G2, detail_level) -> RelationData
  L1: n_components, is_connected, n_edges
  L2: + per-vertex degree, bridge edges (deleting them increases components)
  L3: + connected component membership, articulation points

transform(G, operation) -> TransformResult
  operation = {"type": "delete_edge", "edge": [u, v]}
  trace: which edge was deleted, components before/after, was it a bridge

compare(G, G', G_after_delete, ...) -> RelationComparison

invariants(G) -> n_components, is_connected, n_bridges, n_articulation_points
"""

from __future__ import annotations

import random
from collections import deque
from dataclasses import dataclass

from SpatialMind.core.relation import RelationData
from SpatialMind.core.transform import TransformResult, TransformTrace
from SpatialMind.core.comparison import RelationComparison, compute_summary_delta


@dataclass(frozen=True)
class GraphObject:
    object_id: str
    n_vertices: int
    edges: tuple  # tuple of (u, v) pairs (canonicalized: u < v)

    def to_json(self) -> dict:
        return {
            "object_id": self.object_id,
            "n_vertices": self.n_vertices,
            "edges": [list(e) for e in self.edges],
            "n_edges": len(self.edges),
        }


def _canon_edge(e) -> tuple:
    u, v = int(e[0]), int(e[1])
    return (u, v) if u <= v else (v, u)


class GraphEngine:
    domain_name = "graph_connectivity"

    def __init__(self, seed: int | None = None):
        if seed is not None:
            random.seed(seed)

    def construct(self, spec: dict) -> GraphObject:
        if "edges" in spec:
            n = int(spec["n_vertices"])
            edges = tuple(sorted({_canon_edge(e) for e in spec["edges"]}))
        elif spec.get("type") == "random":
            n = int(spec["n"])
            p = float(spec.get("p", 0.5))
            seed = spec.get("seed")
            rng = random.Random(seed) if seed is not None else random
            edge_set = set()
            for i in range(n):
                for j in range(i + 1, n):
                    if rng.random() < p:
                        edge_set.add((i, j))
            edges = tuple(sorted(edge_set))
        else:
            raise ValueError(f"Unknown spec: {spec}")

        oid = spec.get("object_id") or f"G{n}_{len(edges)}"
        return GraphObject(object_id=oid, n_vertices=n, edges=edges)

    # ---- internal graph routines --------------------------------------------
    def _adjacency(self, G: GraphObject) -> dict:
        adj = {i: set() for i in range(G.n_vertices)}
        for u, v in G.edges:
            adj[u].add(v)
            adj[v].add(u)
        return adj

    def _components(self, G: GraphObject) -> list[set]:
        adj = self._adjacency(G)
        visited = set()
        components = []
        for start in range(G.n_vertices):
            if start in visited:
                continue
            comp = set()
            queue = deque([start])
            while queue:
                node = queue.popleft()
                if node in visited:
                    continue
                visited.add(node)
                comp.add(node)
                for nb in adj[node]:
                    if nb not in visited:
                        queue.append(nb)
            components.append(comp)
        return components

    def _bridges(self, G: GraphObject) -> list[tuple]:
        """All bridge edges (deleting them increases component count)."""
        n_comp = len(self._components(G))
        bridges = []
        for i, e in enumerate(G.edges):
            remaining = tuple(x for j, x in enumerate(G.edges) if j != i)
            G2 = GraphObject(object_id="_tmp", n_vertices=G.n_vertices,
                             edges=remaining)
            if len(self._components(G2)) > n_comp:
                bridges.append(e)
        return bridges

    def _articulation_points(self, G: GraphObject) -> list[int]:
        """All articulation points (their removal disconnects an existing component)."""
        comps = self._components(G)
        n_comp = len(comps)
        points = []
        for v in range(G.n_vertices):
            # Strip all edges incident to v; the vertex itself becomes isolated.
            # An articulation point increases the *non-isolated* component count.
            remaining = tuple(e for e in G.edges if v not in e)
            G2 = GraphObject(object_id="_tmp", n_vertices=G.n_vertices,
                             edges=remaining)
            comps_after = self._components(G2)
            # Discount the isolated v itself (its component shrinks to {v}).
            non_iso_comps_before = sum(1 for c in comps if len(c) > 1 or v not in c)
            # Equivalent simpler check: did v's neighbors split into more than one component?
            adj = self._adjacency(G)
            nbrs = adj[v]
            if not nbrs:
                continue
            # BFS in G \ {v} restricted to nbrs
            adj2 = {i: set() for i in range(G.n_vertices)}
            for u, w in remaining:
                adj2[u].add(w); adj2[w].add(u)
            seen = set()
            n_nbr_comps = 0
            for s in nbrs:
                if s in seen:
                    continue
                n_nbr_comps += 1
                stack = [s]
                while stack:
                    x = stack.pop()
                    if x in seen:
                        continue
                    seen.add(x)
                    for y in adj2[x]:
                        if y not in seen:
                            stack.append(y)
            if n_nbr_comps > 1:
                points.append(v)
        return points

    def _degrees(self, G: GraphObject) -> dict:
        deg = {i: 0 for i in range(G.n_vertices)}
        for u, v in G.edges:
            deg[u] += 1
            deg[v] += 1
        return deg

    def _all_pairs_shortest_paths(self, G: GraphObject) -> dict:
        """BFS from every vertex; return {(u,v): dist} for u<v. -1 means disconnected."""
        adj = self._adjacency(G)
        n = G.n_vertices
        result = {}
        for src in range(n):
            dist = {src: 0}
            q = deque([src])
            while q:
                x = q.popleft()
                for y in adj[x]:
                    if y not in dist:
                        dist[y] = dist[x] + 1
                        q.append(y)
            for tgt in range(src + 1, n):
                result[(src, tgt)] = dist.get(tgt, -1)
        return result

    def _diameter(self, G: GraphObject) -> int:
        """Longest finite shortest-path distance. -1 if disconnected (no finite diameter)."""
        sp = self._all_pairs_shortest_paths(G)
        finite = [d for d in sp.values() if d >= 0]
        if not finite:
            return -1
        return max(finite)

    def _average_path_length(self, G: GraphObject) -> float:
        """Mean of finite shortest-path distances over all unordered connected pairs."""
        sp = self._all_pairs_shortest_paths(G)
        finite = [d for d in sp.values() if d >= 0]
        if not finite:
            return -1.0
        return sum(finite) / len(finite)

    # ---- relate --------------------------------------------------------------
    def relate(self, obj_a: GraphObject, obj_b: GraphObject,
               detail_level: int = 1) -> RelationData:
        comps_a = self._components(obj_a)
        comps_b = self._components(obj_b)

        summary = {
            "n_components_a": len(comps_a),
            "n_components_b": len(comps_b),
            "is_connected_a": len(comps_a) == 1,
            "is_connected_b": len(comps_b) == 1,
            "n_edges_a": len(obj_a.edges),
            "n_edges_b": len(obj_b.edges),
            "n_vertices_a": obj_a.n_vertices,
            "n_vertices_b": obj_b.n_vertices,
        }

        rel = RelationData(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            summary=summary,
        )
        if detail_level <= 1:
            return rel

        bridges_a = self._bridges(obj_a)
        bridges_b = self._bridges(obj_b)
        sp_a = self._all_pairs_shortest_paths(obj_a)
        sp_b = self._all_pairs_shortest_paths(obj_b)
        rel.detailed = {
            "degrees_a": self._degrees(obj_a),
            "degrees_b": self._degrees(obj_b),
            "bridges_a": [list(e) for e in bridges_a],
            "bridges_b": [list(e) for e in bridges_b],
            "n_bridges_a": len(bridges_a),
            "n_bridges_b": len(bridges_b),
            "all_pairs_shortest_paths_a": {f"{u},{v}": d for (u, v), d in sp_a.items()},
            "all_pairs_shortest_paths_b": {f"{u},{v}": d for (u, v), d in sp_b.items()},
            "diameter_a": self._diameter(obj_a),
            "diameter_b": self._diameter(obj_b),
            "average_path_length_a": self._average_path_length(obj_a),
            "average_path_length_b": self._average_path_length(obj_b),
        }
        if detail_level <= 2:
            return rel

        rel.structural = {
            "components_a": [sorted(c) for c in comps_a],
            "components_b": [sorted(c) for c in comps_b],
            "articulation_points_a": self._articulation_points(obj_a),
            "articulation_points_b": self._articulation_points(obj_b),
            "edges_a": [list(e) for e in obj_a.edges],
            "edges_b": [list(e) for e in obj_b.edges],
        }
        return rel

    # ---- transform -----------------------------------------------------------
    def transform(self, obj: GraphObject, operation: dict) -> TransformResult:
        op_type = operation.get("type", "delete_edge")
        if op_type == "delete_edge":
            return self._transform_delete_edge(obj, operation)
        if op_type == "add_edge":
            return self._transform_add_edge(obj, operation)
        raise ValueError(f"Unsupported operation type: {op_type}")

    def _transform_delete_edge(self, obj: GraphObject, operation: dict) -> TransformResult:
        edge = _canon_edge(operation["edge"])
        if edge not in obj.edges:
            raise ValueError(f"Edge {list(edge)} not in graph {obj.object_id}")

        remaining = tuple(e for e in obj.edges if e != edge)
        new_obj = GraphObject(
            object_id=f"{obj.object_id}_del_{edge[0]}_{edge[1]}",
            n_vertices=obj.n_vertices,
            edges=remaining,
        )

        comps_before = self._components(obj)
        comps_after = self._components(new_obj)
        is_bridge = len(comps_after) > len(comps_before)

        deg_before = self._degrees(obj)
        deg_after = self._degrees(new_obj)

        inv_before = self.invariants(obj)
        inv_after = self.invariants(new_obj)

        trace = TransformTrace(
            operation_name="delete_edge",
            operation_params={"edge": list(edge)},
            before_state={
                "n_edges": len(obj.edges),
                "n_components": len(comps_before),
                "is_connected": len(comps_before) == 1,
            },
            after_state={
                "n_edges": len(remaining),
                "n_components": len(comps_after),
                "is_connected": len(comps_after) == 1,
            },
            delta={
                "n_edges_delta": -1,
                "components_change": len(comps_after) - len(comps_before),
                "is_bridge": is_bridge,
                "connectivity_lost": (len(comps_before) == 1
                                      and len(comps_after) > 1),
            },
            region_affected={
                "deleted_edge": list(edge),
                "endpoint_degrees_before": [deg_before[edge[0]], deg_before[edge[1]]],
                "endpoint_degrees_after": [deg_after[edge[0]], deg_after[edge[1]]],
            },
        )
        return TransformResult(
            original_id=obj.object_id,
            transformed_id=new_obj.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta={
                k: inv_after[k] - inv_before[k]
                for k in inv_before
                if isinstance(inv_before[k], (int, float)) and not isinstance(inv_before[k], bool)
            },
            invariants_preserved={k: inv_before[k] == inv_after[k] for k in inv_before},
        )

    def _transform_add_edge(self, obj: GraphObject, operation: dict) -> TransformResult:
        edge = _canon_edge(operation["edge"])
        if edge in obj.edges:
            raise ValueError(f"Edge {list(edge)} already in graph {obj.object_id}")
        if edge[0] == edge[1]:
            raise ValueError(f"Self-loops not supported: {edge}")

        new_edges = tuple(sorted(set(obj.edges) | {edge}))
        new_obj = GraphObject(
            object_id=f"{obj.object_id}_add_{edge[0]}_{edge[1]}",
            n_vertices=obj.n_vertices,
            edges=new_edges,
        )

        comps_before = self._components(obj)
        comps_after = self._components(new_obj)
        merged = len(comps_after) < len(comps_before)

        deg_before = self._degrees(obj)
        deg_after = self._degrees(new_obj)

        inv_before = self.invariants(obj)
        inv_after = self.invariants(new_obj)

        trace = TransformTrace(
            operation_name="add_edge",
            operation_params={"edge": list(edge)},
            before_state={
                "n_edges": len(obj.edges),
                "n_components": len(comps_before),
                "is_connected": len(comps_before) == 1,
            },
            after_state={
                "n_edges": len(new_edges),
                "n_components": len(comps_after),
                "is_connected": len(comps_after) == 1,
            },
            delta={
                "n_edges_delta": +1,
                "components_change": len(comps_after) - len(comps_before),
                "merged_components": merged,
                "connectivity_gained": (len(comps_before) > 1
                                        and len(comps_after) == 1),
            },
            region_affected={
                "added_edge": list(edge),
                "endpoint_degrees_before": [deg_before[edge[0]], deg_before[edge[1]]],
                "endpoint_degrees_after": [deg_after[edge[0]], deg_after[edge[1]]],
            },
        )
        return TransformResult(
            original_id=obj.object_id,
            transformed_id=new_obj.object_id,
            trace=trace,
            invariants_before=inv_before,
            invariants_after=inv_after,
            invariants_delta={
                k: inv_after[k] - inv_before[k]
                for k in inv_before
                if isinstance(inv_before[k], (int, float)) and not isinstance(inv_before[k], bool)
            },
            invariants_preserved={k: inv_before[k] == inv_after[k] for k in inv_before},
        )

    # ---- invariants ----------------------------------------------------------
    def invariants(self, obj: GraphObject) -> dict:
        comps = self._components(obj)
        bridges = self._bridges(obj)
        return {
            "n_components": len(comps),
            "is_connected": len(comps) == 1,
            "n_edges": len(obj.edges),
            "n_bridges": len(bridges),
            "n_articulation_points": len(self._articulation_points(obj)),
        }

    # ---- compare -------------------------------------------------------------
    def compare(self, obj_a: GraphObject, obj_b: GraphObject,
                transformed_a: GraphObject,
                transform_result: TransformResult,
                detail_level: int = 4) -> RelationComparison:
        pre = self.relate(obj_a, obj_b, detail_level=min(detail_level, 3))
        post = self.relate(transformed_a, obj_b, detail_level=min(detail_level, 3))

        cmp = RelationComparison(
            object_a_id=obj_a.object_id,
            object_b_id=obj_b.object_id,
            transformed_a_id=transformed_a.object_id,
            pre=pre,
            post=post,
            summary_delta=compute_summary_delta(pre, post),
            transform_trace=transform_result.trace.to_json(),
        )

        # detailed_comparison: bridge stats and op effect
        cmp.detailed_comparison = {
            "n_edges_pre": len(obj_a.edges),
            "n_edges_post": len(transformed_a.edges),
            "n_bridges_pre": pre.detailed.get("n_bridges_a", 0),
            "n_bridges_post": post.detailed.get("n_bridges_a", 0),
            "deleted_edge_was_bridge":
                transform_result.trace.delta.get("is_bridge", False),
            "connectivity_lost":
                transform_result.trace.delta.get("connectivity_lost", False),
            "n_components_pre": pre.summary.get("n_components_a", 1),
            "n_components_post": post.summary.get("n_components_a", 1),
        }

        # reference_in_transform_region: deleted edge endpoints + their degree change
        cmp.reference_in_transform_region = transform_result.trace.region_affected

        # structural_comparison: full topological state
        cmp.structural_comparison = {
            "components_pre": pre.structural.get("components_a", []),
            "components_post": post.structural.get("components_a", []),
            "articulation_points_pre":
                pre.structural.get("articulation_points_a", []),
            "articulation_points_post":
                post.structural.get("articulation_points_a", []),
            "is_connected_pre": pre.summary.get("is_connected_a", False),
            "is_connected_post": post.summary.get("is_connected_a", False),
            "is_connected_preserved":
                pre.summary.get("is_connected_a") == post.summary.get("is_connected_a"),
            "n_components_preserved":
                pre.summary.get("n_components_a") == post.summary.get("n_components_a"),
            "all_pairs_shortest_paths_pre":
                pre.detailed.get("all_pairs_shortest_paths_a", {}),
            "all_pairs_shortest_paths_post":
                post.detailed.get("all_pairs_shortest_paths_a", {}),
            "diameter_pre": pre.detailed.get("diameter_a", -1),
            "diameter_post": post.detailed.get("diameter_a", -1),
            "average_path_length_pre": pre.detailed.get("average_path_length_a", -1.0),
            "average_path_length_post": post.detailed.get("average_path_length_a", -1.0),
        }

        return cmp


# Self-test
if __name__ == "__main__":
    e = GraphEngine(seed=42)
    # path 0-1-2-3-4 plus an extra edge 1-3
    G = e.construct({
        "n_vertices": 5,
        "edges": [[0, 1], [1, 2], [2, 3], [3, 4], [1, 3]],
    })
    print(f"Graph: {G.n_vertices} vertices, {len(G.edges)} edges")
    print(f"  edges: {list(G.edges)}")
    print(f"  invariants: {e.invariants(G)}")
    print(f"  bridges: {e._bridges(G)}")
    print(f"  articulation points: {e._articulation_points(G)}")
    print(f"  components: {e._components(G)}")

    # delete bridge edge (0,1)
    tr = e.transform(G, {"type": "delete_edge", "edge": [0, 1]})
    print(f"\nDelete (0,1): bridge={tr.trace.delta['is_bridge']}, "
          f"components {tr.trace.before_state['n_components']} -> "
          f"{tr.trace.after_state['n_components']}, "
          f"connectivity_lost={tr.trace.delta['connectivity_lost']}")

    # delete non-bridge edge (1,3)
    tr2 = e.transform(G, {"type": "delete_edge", "edge": [1, 3]})
    print(f"Delete (1,3): bridge={tr2.trace.delta['is_bridge']}, "
          f"components {tr2.trace.before_state['n_components']} -> "
          f"{tr2.trace.after_state['n_components']}, "
          f"connectivity_lost={tr2.trace.delta['connectivity_lost']}")

    # add edge (0,4)
    tr3 = e.transform(G, {"type": "add_edge", "edge": [0, 4]})
    print(f"Add (0,4): merged={tr3.trace.delta['merged_components']}, "
          f"components {tr3.trace.before_state['n_components']} -> "
          f"{tr3.trace.after_state['n_components']}")

    # full compare on bridge deletion
    G_after = e.construct({
        "n_vertices": G.n_vertices,
        "edges": [list(x) for x in G.edges if x != (0, 1)],
        "object_id": "G_after_bridge_del",
    })
    cmp = e.compare(G, G, G_after, tr, detail_level=4)
    print(f"\nCompare summary_delta: {cmp.summary_delta}")
    print(f"Compare detailed: {cmp.detailed_comparison}")
    print(f"Compare structural keys: {list(cmp.structural_comparison.keys())}")
