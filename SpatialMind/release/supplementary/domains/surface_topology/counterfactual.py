"""Surface topology counterfactual generator.

Three strategies (boundary_relaxation is fully implemented; the other two
return [] when the database is unavailable so the AutoCounterfactualGenerator
can skip them gracefully).

  boundary_relaxation:
      Original condition:  i(α, β) ≤ 1   (β in descending link of α)
      Relaxed:             find a β with i(α, β) = 2 (not in DL)
      Run the same Hatcher surgery; check whether net_change(α→σ_α, β) ≠ 0.

  condition_removal:
      Original:  level(β) < level(α)
      Relaxed:   pick a β with level(β) ≥ level(α) and i(α, β) ≤ 1.

  operation_perturbation:
      Original:  σ_α uses a γ_0-arc to replace α's short arc.
      Perturbed: replace with the arc of a non-γ_0 curve.

Inputs are now CounterfactualInput objects (see core/counterfactual.py).
"""

from __future__ import annotations

from typing import Any

from SpatialMind.core.counterfactual import (
    CounterfactualCase,
    CounterfactualInput,
    CFStrategy,
)


class SurfaceCounterfactualGenerator:
    """Surface-topology specific counterfactual cases."""

    def generate(
        self,
        input: CounterfactualInput,
        strategy: CFStrategy | None = None,
    ) -> list[CounterfactualCase]:
        if strategy is None:
            out: list[CounterfactualCase] = []
            for s in CFStrategy:
                try:
                    out.extend(self.generate(input, s))
                except NotImplementedError:
                    continue
            return out

        if strategy == CFStrategy.BOUNDARY_RELAXATION:
            return self._boundary_relaxation(input)
        if strategy == CFStrategy.CONDITION_REMOVAL:
            return self._condition_removal(input)
        if strategy == CFStrategy.OPERATION_PERTURBATION:
            return self._operation_perturbation(input)
        raise NotImplementedError(strategy)

    # ----------------------------------------------------------------
    # boundary_relaxation: i(α, β) ≤ K → i(α, β) = K+1
    # ----------------------------------------------------------------

    def _boundary_relaxation(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine = input.engine
        alpha = input.object_a
        beta_pos = input.object_b
        operation = dict(input.operation or {"type": "hatcher_surgery"})
        bound = int(input.conditions.get("intersection_bound", 1))
        target_intersection = bound + 1

        # Original positive surgery and intersection-with-β baseline.
        rel_pos = engine.relate(alpha, beta_pos, detail_level=1)
        i_pos = rel_pos.summary["intersection_number"]

        try:
            tr_pos = engine.transform(alpha, operation)
        except Exception as e:
            return [self._failed_case(
                CFStrategy.BOUNDARY_RELAXATION,
                {"intersection_bound": bound, "i(alpha, beta)": i_pos},
                {"intersection_bound": target_intersection},
                error=str(e),
            )]

        sigma = engine.construct({
            "surface": [engine.g, engine.n],
            "weights": tr_pos.trace.after_state["sigma_weights"],
            "object_id": tr_pos.transformed_id,
        })
        rel_sigma_pos = engine.relate(sigma, beta_pos, detail_level=1)
        net_pos = rel_sigma_pos.summary["intersection_number"] - i_pos

        beta_cf = self._find_beta_with_intersection(
            engine, alpha, target_intersection,
            exclude_ids={beta_pos.object_id},
        )
        if beta_cf is None:
            return [self._failed_case(
                CFStrategy.BOUNDARY_RELAXATION,
                {"intersection_bound": bound, "i(alpha, beta)": i_pos},
                {"intersection_bound": target_intersection},
                error=f"no β found with i(α, β) = {target_intersection}",
            )]

        rel_cf = engine.relate(alpha, beta_cf, detail_level=1)
        rel_sigma_cf = engine.relate(sigma, beta_cf, detail_level=1)
        net_cf = rel_sigma_cf.summary["intersection_number"] \
            - rel_cf.summary["intersection_number"]

        critical = (net_pos == 0 and net_cf != 0)

        return [CounterfactualCase(
            strategy=CFStrategy.BOUNDARY_RELAXATION,
            original_condition={
                "intersection_bound": bound,
                "beta_id": beta_pos.object_id,
                "i(alpha, beta)": int(i_pos),
            },
            modified_condition={
                "intersection_bound": target_intersection,
                "beta_id": beta_cf.object_id,
                "i(alpha, beta)": int(rel_cf.summary["intersection_number"]),
            },
            original_result={"net_change": int(net_pos)},
            counterfactual_result={"net_change": int(net_cf)},
            delta={"net_change": int(net_cf - net_pos)},
            condition_is_critical=critical,
            explanation=(
                f"Relaxed i(α, β) ≤ {bound} to i(α, β) = {target_intersection}. "
                f"Original net_change={net_pos}, counterfactual net_change={net_cf}. "
                f"{'Critical: bound is load-bearing.' if critical else 'Bound may not be tight here.'}"
            ),
        )]

    # ----------------------------------------------------------------
    # condition_removal
    # ----------------------------------------------------------------

    def _condition_removal(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine = input.engine
        if engine._db is None:
            return []
        alpha = input.object_a
        beta_pos = input.object_b
        operation = dict(input.operation or {"type": "hatcher_surgery"})

        try:
            tr_pos = engine.transform(alpha, operation)
        except Exception:
            return []
        sigma = engine.construct({
            "surface": [engine.g, engine.n],
            "weights": tr_pos.trace.after_state["sigma_weights"],
            "object_id": tr_pos.transformed_id,
        })

        gamma0 = engine.S.curves["a_0"]
        alpha_lam = engine._lam(alpha)
        k_alpha = int(gamma0.intersection(alpha_lam))
        beta_cf_idx = None
        for idx, c in enumerate(engine._db["curves"]):
            if int(gamma0.intersection(c)) < k_alpha:
                continue
            ia = int(alpha_lam.intersection(c))
            if ia == 0 or ia > 1:
                continue
            beta_cf_idx = idx
            break
        if beta_cf_idx is None:
            return []
        beta_cf = engine.construct({
            "surface": [engine.g, engine.n],
            "curve_index": beta_cf_idx,
        })

        rel_pos = engine.relate(alpha, beta_pos, detail_level=1)
        rel_pos_sigma = engine.relate(sigma, beta_pos, detail_level=1)
        net_pos = rel_pos_sigma.summary["intersection_number"] \
            - rel_pos.summary["intersection_number"]

        rel_cf = engine.relate(alpha, beta_cf, detail_level=1)
        rel_cf_sigma = engine.relate(sigma, beta_cf, detail_level=1)
        net_cf = rel_cf_sigma.summary["intersection_number"] \
            - rel_cf.summary["intersection_number"]

        critical = (net_pos == 0 and net_cf != 0)
        return [CounterfactualCase(
            strategy=CFStrategy.CONDITION_REMOVAL,
            original_condition={"descending_link_required": True,
                                "level_beta_lt_level_alpha": True,
                                "beta_id": beta_pos.object_id},
            modified_condition={"descending_link_required": False,
                                "level_beta_lt_level_alpha": False,
                                "beta_id": beta_cf.object_id},
            original_result={"net_change": int(net_pos)},
            counterfactual_result={"net_change": int(net_cf)},
            delta={"net_change": int(net_cf - net_pos)},
            condition_is_critical=critical,
            explanation=(
                f"Dropped 'β in descending link' constraint. "
                f"Original net_change={net_pos}, counterfactual={net_cf}."
            ),
        )]

    # ----------------------------------------------------------------
    # operation_perturbation
    # ----------------------------------------------------------------

    def _operation_perturbation(
        self, input: CounterfactualInput
    ) -> list[CounterfactualCase]:
        engine = input.engine
        if engine._db is None:
            return []
        alpha = input.object_a
        beta_pos = input.object_b
        try:
            tr_pos = engine.transform(alpha, {"type": "hatcher_surgery",
                                              "gamma0": "a_0"})
        except Exception:
            return []
        sigma = engine.construct({
            "surface": [engine.g, engine.n],
            "weights": tr_pos.trace.after_state["sigma_weights"],
            "object_id": tr_pos.transformed_id,
        })
        rel_pos = engine.relate(alpha, beta_pos, detail_level=1)
        rel_pos_sigma = engine.relate(sigma, beta_pos, detail_level=1)
        net_pos = rel_pos_sigma.summary["intersection_number"] \
            - rel_pos.summary["intersection_number"]

        alpha_lam = engine._lam(alpha)
        alt_idx = None
        for idx, c in enumerate(engine._db["curves"]):
            if int(alpha_lam.intersection(c)) >= 2:
                alt_idx = idx
                break
        if alt_idx is None:
            return []
        try:
            tr_cf = engine.transform(alpha, {"type": "hatcher_surgery",
                                             "gamma0": engine._db["curves"][alt_idx]})
        except Exception:
            return [CounterfactualCase(
                strategy=CFStrategy.OPERATION_PERTURBATION,
                original_condition={"surgery_curve": "a_0"},
                modified_condition={"surgery_curve": f"c{alt_idx}"},
                original_result={"net_change": int(net_pos)},
                counterfactual_result={"net_change": None,
                                       "error": "perturbed surgery undefined"},
                delta={},
                condition_is_critical=True,
                explanation="Hatcher surgery is undefined when γ₀ is replaced by a generic curve.",
            )]

        sigma_cf = engine.construct({
            "surface": [engine.g, engine.n],
            "weights": tr_cf.trace.after_state["sigma_weights"],
            "object_id": tr_cf.transformed_id,
        })
        rel_cf_sigma = engine.relate(sigma_cf, beta_pos, detail_level=1)
        net_cf = rel_cf_sigma.summary["intersection_number"] \
            - rel_pos.summary["intersection_number"]
        critical = (net_pos == 0 and net_cf != 0)
        return [CounterfactualCase(
            strategy=CFStrategy.OPERATION_PERTURBATION,
            original_condition={"surgery_curve": "a_0"},
            modified_condition={"surgery_curve": f"c{alt_idx}"},
            original_result={"net_change": int(net_pos)},
            counterfactual_result={"net_change": int(net_cf)},
            delta={"net_change": int(net_cf - net_pos)},
            condition_is_critical=critical,
            explanation=(
                f"Replaced γ_0 with c{alt_idx}. "
                f"Original net_change={net_pos}, counterfactual={net_cf}."
            ),
        )]

    # ----------------------------------------------------------------
    # Helpers
    # ----------------------------------------------------------------

    def _find_beta_with_intersection(self, engine, alpha,
                                     target: int,
                                     exclude_ids: set | None = None):
        exclude_ids = exclude_ids or set()
        alpha_lam = engine._lam(alpha)

        for name, c in engine.S.curves.items():
            if name in exclude_ids:
                continue
            if int(alpha_lam.intersection(c)) == target:
                return engine.construct({
                    "surface": [engine.g, engine.n],
                    "curve_name": name,
                })

        if engine._db is not None:
            for idx, c in enumerate(engine._db["curves"]):
                obj_id = f"c{idx}"
                if obj_id in exclude_ids:
                    continue
                if int(alpha_lam.intersection(c)) == target:
                    return engine.construct({
                        "surface": [engine.g, engine.n],
                        "curve_index": idx,
                    })
        return None

    def _failed_case(self, strategy, original, modified, error: str):
        return CounterfactualCase(
            strategy=strategy,
            original_condition=original,
            modified_condition=modified,
            original_result={},
            counterfactual_result={"error": error},
            delta={},
            condition_is_critical=False,
            explanation=f"Counterfactual generation failed: {error}",
        )
