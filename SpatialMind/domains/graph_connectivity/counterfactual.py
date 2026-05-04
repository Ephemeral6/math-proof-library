"""GraphCounterfactualGenerator — counterfactuals for edge-deletion connectivity.

Two strategies:

  BOUNDARY_RELAXATION: positive case deletes a non-bridge edge (connectivity
    preserved); counterfactual deletes a bridge edge (connectivity breaks).

  OPERATION_PERTURBATION: positive case deletes an edge; counterfactual
    adds an edge (the reverse operation, which can only merge components,
    never split them).

(CONDITION_REMOVAL is not used here — there is no analogue of "drop
planarity"; the graph data itself has no condition that can be silently
dropped without becoming a different problem class.)
"""

from __future__ import annotations

import random

from SpatialMind.core.counterfactual import (
    CFStrategy,
    CounterfactualCase,
    CounterfactualInput,
)

from .engine import GraphEngine, GraphObject


class GraphCounterfactualGenerator:
    """Domain-specific counterfactual generator for graph connectivity."""

    def __init__(self, engine: GraphEngine | None = None,
                 seed: int | None = None):
        self.engine = engine or GraphEngine()
        self.rng = random.Random(seed)

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        if strategy is None:
            return (
                self._boundary_relaxation(input)
                + self._operation_perturbation(input)
            )
        if strategy == CFStrategy.BOUNDARY_RELAXATION:
            return self._boundary_relaxation(input)
        if strategy == CFStrategy.OPERATION_PERTURBATION:
            return self._operation_perturbation(input)
        if strategy == CFStrategy.CONDITION_REMOVAL:
            return []  # not applicable for this domain
        return []

    # ---- BOUNDARY_RELAXATION (non-bridge -> bridge) -------------------------
    def _boundary_relaxation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        G: GraphObject = input.object_a
        engine = self.engine

        if not engine.invariants(G)["is_connected"]:
            return []

        bridges = engine._bridges(G)
        non_bridges = [e for e in G.edges if e not in set(bridges)]
        if not bridges or not non_bridges:
            return []

        # Pick one of each
        nb_edge = self.rng.choice(non_bridges)
        br_edge = self.rng.choice(bridges)

        tr_pos = engine.transform(G, {"type": "delete_edge", "edge": list(nb_edge)})
        tr_cf  = engine.transform(G, {"type": "delete_edge", "edge": list(br_edge)})

        inv_pre  = engine.invariants(G)
        inv_pos = tr_pos.invariants_after
        inv_cf  = tr_cf.invariants_after

        delta = {
            "n_components_delta_positive":
                inv_pos["n_components"] - inv_pre["n_components"],
            "n_components_delta_counterfactual":
                inv_cf["n_components"] - inv_pre["n_components"],
            "connectivity_lost_positive":
                tr_pos.trace.delta["connectivity_lost"],
            "connectivity_lost_counterfactual":
                tr_cf.trace.delta["connectivity_lost"],
        }

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "deleted_edge_is_bridge": False,
                "deleted_edge": list(nb_edge),
            },
            modified_condition={
                "deleted_edge_is_bridge": True,
                "deleted_edge": list(br_edge),
            },
            original_result={
                "is_connected_after": inv_pos["is_connected"],
                "n_components_after": inv_pos["n_components"],
            },
            counterfactual_result={
                "is_connected_after": inv_cf["is_connected"],
                "n_components_after": inv_cf["n_components"],
            },
            delta=delta,
            condition_is_critical=(inv_pos["is_connected"] != inv_cf["is_connected"]),
            explanation=(
                "Deleting a non-bridge edge keeps the graph connected; "
                "deleting a bridge edge disconnects it. The bridge property "
                "(no alternative path between endpoints) is what determines "
                "whether connectivity is preserved under edge deletion."
            ),
        )]

    # ---- OPERATION_PERTURBATION (delete -> add) ------------------------------
    def _operation_perturbation(self, input: CounterfactualInput) -> list[CounterfactualCase]:
        G: GraphObject = input.object_a
        engine = self.engine

        if not G.edges:
            return []

        # Positive: delete a bridge (so connectivity drops).
        bridges = engine._bridges(G)
        if not bridges:
            return []
        br_edge = self.rng.choice(bridges)
        tr_pos = engine.transform(G, {"type": "delete_edge", "edge": list(br_edge)})

        # Counterfactual: add an edge instead. Pick a vertex pair not currently connected by an edge.
        existing = set(G.edges)
        candidates = []
        for i in range(G.n_vertices):
            for j in range(i + 1, G.n_vertices):
                if (i, j) not in existing:
                    candidates.append((i, j))
        if not candidates:
            return []
        add_edge = self.rng.choice(candidates)
        tr_cf = engine.transform(G, {"type": "add_edge", "edge": list(add_edge)})

        inv_pre = engine.invariants(G)
        inv_pos = tr_pos.invariants_after
        inv_cf  = tr_cf.invariants_after

        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={
                "operation": "delete_edge",
                "edge": list(br_edge),
            },
            modified_condition={
                "operation": "add_edge",
                "edge": list(add_edge),
            },
            original_result={
                "n_components_after": inv_pos["n_components"],
                "components_change": tr_pos.trace.delta["components_change"],
            },
            counterfactual_result={
                "n_components_after": inv_cf["n_components"],
                "components_change": tr_cf.trace.delta["components_change"],
            },
            delta={
                "components_change_positive":
                    tr_pos.trace.delta["components_change"],
                "components_change_counterfactual":
                    tr_cf.trace.delta["components_change"],
                "directional_asymmetry": (
                    tr_pos.trace.delta["components_change"] >= 0
                    and tr_cf.trace.delta["components_change"] <= 0
                ),
            },
            condition_is_critical=True,
            explanation=(
                "Edge deletion can only increase or preserve component count; "
                "edge addition can only decrease or preserve it. The two "
                "operations are not symmetric, and a bridge under deletion "
                "has no analogue under addition (every cut vertex is created "
                "by deletion, not addition)."
            ),
        )]
