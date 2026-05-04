# OptLib2 — Optimization theory in Lean 4

A self-contained library for first-order optimization theory in Lean 4.
**Depends only on Mathlib** — no `optlib`. All theorems are axiom-clean
(`[propext, Classical.choice, Quot.sound]` only).

## Directory structure

```
LeanAgent/
├── OptLib2.lean                          (21 LOC) — root, imports all submodules
└── OptLib2/
    ├── README.md                                  — this file
    ├── Basic/
    │   ├── Defs.lean                     (53 LOC) — IsLSmooth, HasSubgradientAt, SubderivAt
    │   ├── Smoothness.lean               (159 LOC) — descent lemma in FDeriv and gradient form
    │   └── Convexity.lean                (144 LOC) — first-order condition for convex functions
    ├── Proximal/
    │   ├── Defs.lean                     (27 LOC) — prox_prop
    │   └── Properties.lean               (109 LOC) — prox_iff_subderiv
    └── Algorithms/
        ├── GradientDescent.lean          (216 LOC) — GD class + O(1/T) convergence
        ├── ProximalGradient.lean         (293 LOC) — PGD class + O(1/T) convergence
        └── Nesterov.lean                 (349 LOC) — Nesterov class + zSeq + O(1/T²) convergence
```

**Total: 1371 lines.**

## File summaries

### `Basic/Defs.lean`
Foundational definitions: `IsLSmooth f f' L` (gradient `f'` is `L`-Lipschitz);
`HasSubgradientAt f g x` (`g` is a subgradient of `f` at `x`);
`SubderivAt f x` (the subdifferential as a `Set E`); plus `mem_SubderivAt`
unfolding lemma tagged `@[simp]`.

### `Basic/Smoothness.lean`
The classical **descent lemma** for `L`-smooth functions:
`f y ≤ f x + ⟨∇f x, y - x⟩ + L/2 ‖y - x‖²`. Proved first in Fréchet-derivative
form (`descent_lemma_fderiv`) using the mean-value theorem
`image_le_of_deriv_right_le_deriv_boundary`; then transported to
inner-product / gradient form (`descent_lemma_gradient_form`) via Riesz
representation `InnerProductSpace.toDual`. Convenience corollary
`IsLSmooth.descent_lemma` for the structured `IsLSmooth` predicate.

### `Basic/Convexity.lean`
**First-order condition for convex functions**
(`convex_first_order_condition`): if `f` is convex on `s` and has gradient
at `x ∈ s`, then `f x + ⟨∇f x, y - x⟩ ≤ f y` for every `y ∈ s`. Proof uses
the Fréchet-derivative remainder estimate plus a contradiction-via-convex-
combination argument. Note: only the gradient at the central point is required.

### `Proximal/Defs.lean`
`prox_prop f x u`: `u` minimises the proximal objective
`z ↦ f z + ‖z - x‖² / 2`.

### `Proximal/Properties.lean`
**Proximal-subgradient characterisation** (`prox_iff_subderiv`): for `f`
convex, `prox_prop f x u ↔ x - u ∈ SubderivAt f u`. The forward direction
is proved by a contradiction argument exploiting a convex combination of `u`
and `y` (the supposed counter-example); the reverse direction is direct
algebraic manipulation using polarisation.

### `Algorithms/GradientDescent.lean`
Class `Gradient_Descent_fix_stepsize` packaging fixed-stepsize gradient
descent. **`gd_sufficient_decrease`** — single-step `f(x - a • f' x) ≤ f x - (a/2) ‖f' x‖²`
when `a ≤ 1/L`. **`gradient_method`** — `O(1/T)` convergence
`f (x (k+1)) - f x* ≤ ‖x₀ - x*‖² / (2 (k+1) a)` for an `L`-smooth convex
objective.

### `Algorithms/ProximalGradient.lean`
Class `proximal_gradient_method` for fixed-stepsize PGD on `min f + h`.
**`proximal_gradient_method_converge`** — `O(1/T)` convergence
`(f + h)(x k) - (f + h)(x*) ≤ ‖x₀ - x*‖² / (2 k t)` for `f` convex `L`-smooth
and `h` convex. Internal lemmas: `phi_three_point` (per-step three-point
inequality), `phi_monotone` (`φ` monotone non-increasing), `phi_distance`
(polarisation step), `sum_phi_bound` (telescope).

### `Algorithms/Nesterov.lean`
Class `Nesterov_first` packaging Nesterov's accelerated proximal gradient.
Auxiliary sequence `zSeq` with `z 0 = x 0`, `z (k+1) = x k + (1/γ k) • (x (k+1) - x k)`.
Two key bridge identities: `xkk1_eq_combine` (`x (k+1)` as convex combination
of `x k` and `z (k+1)`) and `y_eq_combine` (`y k` as convex combination of
`x k` and `z k`, proved via `match_scalars`). Per-step Lyapunov inequality
`per_step_ineq`, telescope `W_bound`, and the main result
**`Nesterov_first_converge`** giving `O(1/k²)` convergence.

## Theorem list

| Module | Theorem | One-line statement |
|--------|---------|---------------------|
| `Basic/Smoothness.lean`     | `descent_lemma_fderiv`           | `f y ≤ f x + (f' x) (y - x) + L/2 ‖y - x‖²` (FDeriv form) |
| `Basic/Smoothness.lean`     | `descent_lemma_gradient_form`    | `f y ≤ f x + ⟨∇f x, y - x⟩ + L/2 ‖y - x‖²` (gradient form) |
| `Basic/Smoothness.lean`     | `IsLSmooth.descent_lemma`        | descent lemma packaged for the `IsLSmooth` predicate |
| `Basic/Convexity.lean`      | `convex_first_order_condition`   | `f x + ⟨∇f x, y - x⟩ ≤ f y` for `f` convex with gradient at `x` |
| `Proximal/Properties.lean`  | `prox_iff_subderiv`              | `prox_prop f x u ↔ x - u ∈ SubderivAt f u` for `f` convex |
| `Algorithms/GradientDescent.lean`     | `gd_sufficient_decrease`             | one GD step decreases `f` by `(a/2) ‖f' x‖²` |
| `Algorithms/GradientDescent.lean`     | `gradient_method`                    | `O(1/T)` convergence of GD for `L`-smooth convex `f` |
| `Algorithms/ProximalGradient.lean`    | `proximal_gradient_method_converge`  | `O(1/T)` convergence of PGD for composite `f + h` |
| `Algorithms/Nesterov.lean`            | `Nesterov_first_converge`            | `O(1/k²)` convergence of Nesterov accelerated PGD |

## Compile / verify

```pwsh
$env:PATH = "$env:USERPROFILE\.elan\bin;$env:PATH"
$env:LEAN_PATH = "$pwd\.lake\build\lib\lean;$pwd\.lake\packages\mathlib\.lake\build\lib\lean;..."   # all package .lake/build/lib/lean dirs
lean LeanAgent\OptLib2.lean
```

Or, if `git` is in your `PATH`:

```bash
lake build LeanAgent.OptLib2
```

### Axiom verification

All 9 named theorems close over only `[propext, Classical.choice, Quot.sound]`
— the trusted core of Lean's logic. No `sorryAx` or any custom axiom.

```
'LeanAgent.OptLib2.descent_lemma_fderiv'           depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.descent_lemma_gradient_form'    depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.IsLSmooth.descent_lemma'        depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.convex_first_order_condition'   depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.prox_iff_subderiv'              depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.gd_sufficient_decrease'         depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.gradient_method'                depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.proximal_gradient_method_converge' depends on axioms: [propext, Classical.choice, Quot.sound]
'LeanAgent.OptLib2.Nesterov_first_converge'        depends on axioms: [propext, Classical.choice, Quot.sound]
```

## Compile status

| File | Status |
|------|--------|
| `OptLib2.lean`                          | OK |
| `OptLib2/Basic/Defs.lean`               | OK |
| `OptLib2/Basic/Smoothness.lean`         | OK (1 deprecation warning, harmless) |
| `OptLib2/Basic/Convexity.lean`          | OK (1 deprecation warning, harmless) |
| `OptLib2/Proximal/Defs.lean`            | OK |
| `OptLib2/Proximal/Properties.lean`      | OK (1 deprecation warning, harmless) |
| `OptLib2/Algorithms/GradientDescent.lean`     | OK (1 unused-tactic warning) |
| `OptLib2/Algorithms/ProximalGradient.lean`    | OK |
| `OptLib2/Algorithms/Nesterov.lean`            | OK |

**Build summary**: 9 modules, 1371 LOC, 0 sorries, 9 named theorems, all
axiom-clean. Mathlib version: `v4.30.0-rc2`.

## Design notes

* The library is self-contained: every definition (`IsLSmooth`, `prox_prop`,
  `HasSubgradientAt`, the algorithm classes) lives inside `LeanAgent.OptLib2`.
* No dependency on `optlib`: every theorem in the algorithms files invokes
  only Mathlib lemmas + lemmas defined elsewhere in this library.
* The `IsLSmooth` predicate is provided as a structured packaging
  (`structure ... : Prop`); the algorithm classes do not require it (they
  take `HasGradientAt` + `LipschitzWith` directly), but
  `IsLSmooth.descent_lemma` is offered for users who prefer the bundled form.
* The `Nesterov` proof uses the Lyapunov-function pattern with the
  auxiliary `zSeq` defined as a top-level `noncomputable def`. This was
  validated as a workable pattern for accelerated-method analyses.

## Dependencies (only Mathlib)

* `Mathlib.Analysis.Calculus.Gradient.Basic` (`HasGradientAt`)
* `Mathlib.Analysis.Calculus.MeanValue` (`image_le_of_deriv_right_le_deriv_boundary`)
* `Mathlib.Analysis.Calculus.FDeriv.{Basic, Add}` (Fréchet derivatives)
* `Mathlib.Analysis.InnerProductSpace.{Basic, Dual}` (Riesz `toDual`)
* `Mathlib.Analysis.Convex.Function` (`ConvexOn`, `ConvexOn.smul`)
* `Mathlib.Topology.EMetricSpace.Lipschitz` (`LipschitzWith`)
* `Mathlib.Algebra.BigOperators.Group.Finset.Basic` (`Finset.sum`)
* `Mathlib.Order.Monotone.Basic`
* `Mathlib.Tactic` (the standard tactic suite)
