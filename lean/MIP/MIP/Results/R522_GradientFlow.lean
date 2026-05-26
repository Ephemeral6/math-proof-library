/-
Result R.522 (Cj.8.D.3) — The 4-D capability-phase training flow is the
NEGATIVE GRADIENT FLOW of the loss `L` under a calibrated metric `g^{adj}`:

    dθ/dt = − g^{adj}(θ) · ∇L(θ) .

Reference: `workspace/round3_exploration/slot_023.md` and
`workspace/round3_exploration/work_slot_023.md` §4 (Cj.8.D.3, candidate
R.522, slot 023; "training flow is the negative gradient flow of `V = N`
in the calibrated Fisher metric `g^{adj}`"). The companion symplectic
results R.520/R.521 live in `R520_SymplecticDissipative.lean` (same slot).

**Candidate status: Round-3 autonomous exploration
(workspace/round3_exploration), not yet human-audited.**

**Setup.** A trajectory `θ : ℝ → ℝ⁴` in the 4-D phase space
`(|K|, Z⁻¹, H_K, κ)` evolves by the gradient-flow ODE

    θ'(t)  =  − A(θ(t)) · ∇L(θ(t)) ,

where `A = g^{adj}` is the (symmetric, positive-definite) calibrated
metric tensor, `∇L : ℝ⁴ → ℝ⁴` is the loss gradient, and `A · v` denotes
`Matrix.mulVec`. The composite loss along the flow is `t ↦ L(θ(t))`,
and we assume `HasDerivAt L` realizes the chain rule, i.e.
`(d/dt) L(θ(t)) = ⟨∇L(θ(t)), θ'(t)⟩` (the standard gradient identity,
bundled here as the differentiability hypothesis).

Positive-(semi)definiteness of the calibrated metric is bundled as a
hypothesis on its quadratic form `Q_A(v) = ⟨v, A·v⟩` directly: PSD as
`∀ v, 0 ≤ Q_A(v)` and PD as `∀ v ≠ 0, 0 < Q_A(v)`. This is exactly the
Riemannian-metric positivity that calibrates `g^{adj}`, stated in the
form the descent argument consumes.

**Statements proved here (the gradient-flow descent kernel).**

* **R.522 (S1) — instantaneous descent rate.** Along the flow,

      dL/dt  =  − ⟨∇L, A·∇L⟩          (`R_522_loss_deriv`).

* **R.522 (S2) — monotone Lyapunov descent.** When `A` is positive
  semidefinite the quadratic form `⟨∇L, A·∇L⟩ ≥ 0`, hence
  `dL/dt ≤ 0` (`R_522_loss_decreasing`): `L` is a Lyapunov function for
  the training flow.

* **R.522 (S3) — strict descent off equilibria.** When `A` is positive
  definite and the gradient is nonzero (`∇L ≠ 0`), the descent is
  strict, `dL/dt < 0` (`R_522_strict_descent`). Equivalently, `dL/dt = 0`
  forces `∇L = 0` (`R_522_critical_iff`): the flow rests exactly at
  critical points of `L`.

This file proves the **gradient-flow descent kernel**; the MIP-specific
content (that `L = N` and that `g^{adj}` is the calibrated Fisher metric
of R.106/R.125) is bundled as the metric/gradient hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace GradientFlow

open scoped Matrix

/-- The Euclidean inner product `⟨u, v⟩ = Σ uᵢ vᵢ` on `ℝ⁴`. -/
def inner4 (u v : Fin 4 → ℝ) : ℝ := ∑ i, u i * v i

/-- The quadratic form `Q_A(v) = ⟨v, A·v⟩` of a metric matrix `A`. -/
noncomputable def quadForm (A : Matrix (Fin 4) (Fin 4) ℝ) (v : Fin 4 → ℝ) : ℝ :=
  inner4 v (A.mulVec v)

/-- **Positive-semidefinite metric (bundled).** The calibrated metric is
PSD iff its quadratic form is nonnegative on every tangent vector. -/
def IsPSD (A : Matrix (Fin 4) (Fin 4) ℝ) : Prop := ∀ v, 0 ≤ quadForm A v

/-- **Positive-definite metric (bundled).** The calibrated metric is PD
iff its quadratic form is strictly positive on every nonzero vector. This
is the Riemannian positivity that calibrates `g^{adj}`. -/
def IsPD (A : Matrix (Fin 4) (Fin 4) ℝ) : Prop := ∀ v, v ≠ 0 → 0 < quadForm A v

/-- **R.522 (S1) — the loss derivative along the gradient flow.**

Bundling
* the chain-rule hypothesis `hL : (d/dt) L(θ(t)) = ⟨gradL, θ'(t)⟩`
  (`HasDerivAt` of the composite at the value `inner4 gradL θ'`), and
* the gradient-flow ODE `hflow : θ'(t) = − A · gradL`,

the instantaneous loss derivative equals `− ⟨gradL, A·gradL⟩`. -/
theorem R_522_loss_deriv
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL θ' : Fin 4 → ℝ)
    (Lcomp : ℝ → ℝ) (t : ℝ)
    (hL : HasDerivAt Lcomp (inner4 gradL θ') t)
    (hflow : θ' = -(A.mulVec gradL)) :
    HasDerivAt Lcomp (-(quadForm A gradL)) t := by
  have hval : inner4 gradL θ' = -(quadForm A gradL) := by
    rw [hflow]
    unfold inner4 quadForm inner4
    -- ⟨gradL, -(A·gradL)⟩ = -⟨gradL, A·gradL⟩ : pull the negation out of
    -- each summand and then out of the sum.
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro i _
    simp only [Pi.neg_apply, mul_neg]
  rwa [hval] at hL

/-- **R.522 (S2) — monotone Lyapunov descent.**

With a positive-semidefinite calibrated metric `A`, the loss derivative
along the gradient flow is `≤ 0`: the loss is non-increasing, i.e. a
Lyapunov function for the MIP training dynamics. -/
theorem R_522_loss_decreasing
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (hA : IsPSD A) :
    (-(quadForm A gradL)) ≤ 0 := by
  have h := hA gradL
  linarith

/-- **R.522 (S3) — strict descent off equilibria.**

With a positive-definite calibrated metric `A` and a nonzero loss
gradient (`gradL ≠ 0`, i.e. the trajectory is not at a critical point),
the loss derivative along the gradient flow is strictly negative:
`dL/dt = − ⟨gradL, A·gradL⟩ < 0`. -/
theorem R_522_strict_descent
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (hA : IsPD A) (hg : gradL ≠ 0) :
    (-(quadForm A gradL)) < 0 := by
  have h := hA gradL hg
  linarith

/-- **Auxiliary — the quadratic form vanishes at the zero gradient.** -/
theorem quadForm_zero (A : Matrix (Fin 4) (Fin 4) ℝ) :
    quadForm A 0 = 0 := by
  unfold quadForm inner4
  simp

/-- **R.522 — the flow rests exactly at critical points.**

For a positive-definite calibrated metric the instantaneous descent rate
`−⟨gradL, A·gradL⟩` vanishes **iff** the loss gradient vanishes. Combined
with S3 this says the gradient flow strictly decreases `L` away from the
critical set `{∇L = 0}` and is stationary precisely on it. -/
theorem R_522_critical_iff
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (hA : IsPD A) :
    (-(quadForm A gradL)) = 0 ↔ gradL = 0 := by
  constructor
  · intro h
    by_contra hg
    have hpos := hA gradL hg
    -- `-(quadForm) = 0` forces `quadForm = 0`, contradicting positivity.
    have : quadForm A gradL = 0 := by linarith
    linarith
  · intro h
    subst h
    rw [quadForm_zero]
    ring

end GradientFlow

end MIP
