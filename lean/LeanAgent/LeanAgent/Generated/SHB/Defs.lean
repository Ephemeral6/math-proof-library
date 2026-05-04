/-
SHB.Foundations.Defs — definitions for the Stochastic Heavy Ball iteration.

This module is intentionally lightweight: every consumer of SHB needs the iteration
itself and the basic feasibility regions, so we keep definitions decoupled from
norms / inner products where possible.

  * `shbStep` / `shbState` / `shbIter`             — deterministic SHB
  * `shbStochStep` / `shbStochState` / `shbStochIter` — stochastic SHB
  * `stabilityRegion`                              — Polyak stability set S
  * `goujaudFeasible`                              — cycling-free feasibility set F

The state of an SHB run is a pair `(xₜ, xₜ₋₁)`. We model the iteration as
iterated application of a single-step map on this pair, which makes the
recurrence both compositional (suitable for `Nat.rec` / `Function.iterate`) and
trivially decoupled from the future iterates.
-/
import Mathlib

namespace SHB
namespace Foundations

/-! ## Iteration -/

section Iter
variable {E : Type*} [AddCommGroup E] [Module ℝ E]

/--
Single deterministic SHB step.

Given current state `(xₜ, xₜ₋₁)`, returns `(xₜ₊₁, xₜ)` where
`xₜ₊₁ = xₜ - η • f'(xₜ) + β • (xₜ - xₜ₋₁)`.
-/
def shbStep (β η : ℝ) (f' : E → E) (p : E × E) : E × E :=
  (p.1 - η • f' p.1 + β • (p.1 - p.2), p.1)

@[simp] lemma shbStep_apply (β η : ℝ) (f' : E → E) (x xPrev : E) :
    shbStep β η f' (x, xPrev) = (x - η • f' x + β • (x - xPrev), x) := rfl

/--
Deterministic SHB state `(xₜ, xₜ₋₁)` after `t` iterations from initial pair
`(x₀, x₋₁)`.
-/
def shbState (β η : ℝ) (f' : E → E) (x₀ xPrev : E) : ℕ → E × E
  | 0     => (x₀, xPrev)
  | t + 1 => shbStep β η f' (shbState β η f' x₀ xPrev t)

@[simp] lemma shbState_zero (β η : ℝ) (f' : E → E) (x₀ xPrev : E) :
    shbState β η f' x₀ xPrev 0 = (x₀, xPrev) := rfl

@[simp] lemma shbState_succ (β η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) :
    shbState β η f' x₀ xPrev (t + 1) =
      shbStep β η f' (shbState β η f' x₀ xPrev t) := rfl

/-- Deterministic SHB iterate `xₜ`. -/
def shbIter (β η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) : E :=
  (shbState β η f' x₀ xPrev t).1

@[simp] lemma shbIter_zero (β η : ℝ) (f' : E → E) (x₀ xPrev : E) :
    shbIter β η f' x₀ xPrev 0 = x₀ := rfl

/--
Single stochastic SHB step with one noise sample `ξ : E`:
`xₜ₊₁ = xₜ - η • (f'(xₜ) + ξ) + β • (xₜ - xₜ₋₁)`.

The sign convention places `ξ` *inside* the gradient slot so that
`f'(xₜ) + ξ` plays the role of an unbiased noisy gradient estimator.
-/
def shbStochStep (β η : ℝ) (f' : E → E) (ξ : E) (p : E × E) : E × E :=
  (p.1 - η • (f' p.1 + ξ) + β • (p.1 - p.2), p.1)

@[simp] lemma shbStochStep_apply
    (β η : ℝ) (f' : E → E) (ξ : E) (x xPrev : E) :
    shbStochStep β η f' ξ (x, xPrev) =
      (x - η • (f' x + ξ) + β • (x - xPrev), x) := rfl

/--
Stochastic SHB state after `t` iterations driven by noise sequence `ξ : ℕ → E`.
-/
def shbStochState (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) :
    ℕ → E × E
  | 0     => (x₀, xPrev)
  | t + 1 => shbStochStep β η f' (ξ t) (shbStochState β η f' ξ x₀ xPrev t)

@[simp] lemma shbStochState_zero
    (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) :
    shbStochState β η f' ξ x₀ xPrev 0 = (x₀, xPrev) := rfl

@[simp] lemma shbStochState_succ
    (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) (t : ℕ) :
    shbStochState β η f' ξ x₀ xPrev (t + 1) =
      shbStochStep β η f' (ξ t) (shbStochState β η f' ξ x₀ xPrev t) := rfl

/-- Stochastic SHB iterate `xₜ`. -/
def shbStochIter (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) (t : ℕ) : E :=
  (shbStochState β η f' ξ x₀ xPrev t).1

@[simp] lemma shbStochIter_zero
    (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) :
    shbStochIter β η f' ξ x₀ xPrev 0 = x₀ := rfl

end Iter

/-! ## Feasibility regions

These regions live in `ℝ × ℝ` (the `(β, η)` parameter plane) and depend only on
the smoothness constant `L`. Membership is a pure pointwise inequality, so the
regions are definable without any vector-space structure.
-/

section Region

/--
Polyak stability region:
`S(L) = { (β, η) : 0 ≤ β < 1, 0 < η ≤ 2(1 + β) / L }`.

This is the parameter set on which the deterministic SHB iteration converges
linearly on quadratics with worst-case Lipschitz constant `L`.
-/
def stabilityRegion (L : ℝ) : Set (ℝ × ℝ) :=
  {p | 0 ≤ p.1 ∧ p.1 < 1 ∧ 0 < p.2 ∧ p.2 ≤ 2 * (1 + p.1) / L}

@[simp] lemma mem_stabilityRegion (L β η : ℝ) :
    (β, η) ∈ stabilityRegion L ↔
      0 ≤ β ∧ β < 1 ∧ 0 < η ∧ η ≤ 2 * (1 + β) / L := Iff.rfl

/--
Goujaud-style cycling-free feasibility region for SHB:
`F(L) = { (β, η) : 0 ≤ β < 1, 0 < η, η · L · (1 + β + β²) ≤ 2 (1 − β²) }`.

This is one common tightening of the stability region: it guarantees the absence
of two-cycle limit behaviour on smooth strongly-convex quadratics. Equivalent
form: `η ≤ 2(1+β)(1-β) / (L · (1 + β + β²))`. Note `F(L) ⊆ stabilityRegion L`.
-/
def goujaudFeasible (L : ℝ) : Set (ℝ × ℝ) :=
  {p | 0 ≤ p.1 ∧ p.1 < 1 ∧ 0 < p.2 ∧
        p.2 * L * (1 + p.1 + p.1 ^ 2) ≤ 2 * (1 - p.1 ^ 2)}

@[simp] lemma mem_goujaudFeasible (L β η : ℝ) :
    (β, η) ∈ goujaudFeasible L ↔
      0 ≤ β ∧ β < 1 ∧ 0 < η ∧
        η * L * (1 + β + β ^ 2) ≤ 2 * (1 - β ^ 2) := Iff.rfl

end Region

end Foundations
end SHB
