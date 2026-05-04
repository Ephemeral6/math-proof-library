# Optlib Benchmark — Theorem Selections

Mapping from the user's 13 requested items to concrete optlib theorems, with substitutions where optlib has no exact analogue.

| # | Layer | Requested | Chosen optlib theorem | File | Line | Substitution? |
|---|-------|-----------|-----------------------|------|------|---------------|
| 01 | 1 | Lipschitz function standard definition form | `lipschitz_continuous_upper_bound` | `Optlib/Function/Lsmooth.lean` | 49 | YES — optlib reuses Mathlib's `LipschitzWith`; this is the closest "Lipschitz inequality" baseline lemma in optlib. |
| 02 | 1 | Jensen inequality (convex) | `stronglyConvexOn_def` | `Optlib/Convex/StronglyConvex.lean` | 35 | YES — no Jensen lemma in optlib; this is the inequality form definition closest in spirit. |
| 03 | 1 | L-smooth descent lemma (quadratic upper bound) | `lipschitz_continuos_upper_bound'` | `Optlib/Function/Lsmooth.lean` | 146 | NO |
| 04 | 1 | Strongly convex quadratic lower bound | `Strong_Convex_lower` | `Optlib/Convex/StronglyConvex.lean` | 133 | NO |
| 05 | 1 | Gradient = 0 fixed-point / optimality | `first_order_unconstrained` | `Optlib/Optimality/OptimalityConditionOfUnconstrainedProblem.lean` | 99 | NO |
| 06 | 2 | Convex first-order characterization | `Convex_first_order_condition'` | `Optlib/Convex/ConvexFunction.lean` | 219 | NO |
| 07 | 2 | GD sufficient decrease lemma | `convex_lipschitz` | `Optlib/Algorithm/GD/GradientDescent.lean` | 133 | NO |
| 08 | 2 | Proximal operator nonexpansiveness | `prox_iff_subderiv` | `Optlib/Function/Proximal.lean` | 550 | YES — optlib has no prox-nonexpansive lemma; chose the prox/subdifferential characterization (a foundational identity at the same difficulty level). |
| 09 | 2 | Fenchel conjugate involution | `proximal_shift` | `Optlib/Function/Proximal.lean` | 414 | YES — no Fenchel conjugate in optlib at all; chose Moreau-style prox shift identity (the closest "involution-flavored" structural identity available). |
| 10 | 2 | Convex projection firm-nonexpansiveness | `proximal_add_sq` | `Optlib/Function/Proximal.lean` | 512 | YES — no projection theory in optlib; chose prox quadratic addition identity (the standard "completing the square" inequality). |
| 11 | 3 | GD O(1/T) for L-smooth convex | `gradient_method` | `Optlib/Algorithm/GD/GradientDescent.lean` | 198 | NO |
| 12 | 3 | Proximal gradient O(1/T) | `proximal_gradient_method_converge` | `Optlib/Algorithm/ProximalGradient.lean` | 39 | NO |
| 13 | 3 | Nesterov AGD O(1/T²) | `Nesterov_first_converge` | `Optlib/Algorithm/Nesterov/NesterovAccelerationFirst.lean` | 41 | NO |

## Notes

- Optlib does not redefine basic Mathlib concepts (Lipschitz, ConvexOn, projection). It depends on `Mathlib.Topology.MetricSpace.Lipschitz` etc. So items 1, 9, 10 have no exact ground truth — substitutions chosen are the closest-in-difficulty optlib lemma in the same domain.
- Items 4 ground truths overlap stylistically with items 2 (both involve quadratic inequalities for strongly-convex functions) — different-but-related lemmas.
- All chosen theorems are in optlib's `main` (HEAD), shallow-cloned 2026-04-28.

## Optlib commit pinned

Run `git -C ~/Desktop/Math/optlib rev-parse HEAD` to see exact commit at benchmark time.
