/-
Result R.275 — Double descent as two C_V jumps from a dual-sequence Landau
free energy (MIP thermodynamics analogy).

Reference: `branches/thermodynamics/workspace/new_results.md` §R.275
("Double Descent 的两次 C_V 跳跃 = 两次相变", B class, 2026-05-18
thermodynamics branch).

**Setup.** Double descent is modelled by a *dual-order-parameter* Landau
free energy in `ψ = θ_train` (training solve-ratio) and `φ = θ_test` (test
solve-ratio), coupled through a generalization coupling `λ·(ψ − φ)²`:

    F̃(ψ, φ) = (a₁/2)·ψ² + (b₁/4)·ψ⁴
             + (a₂/2)·φ² + (b₂/4)·φ⁴
             + (λ/2)·(ψ − φ)²
             − h·ψ − h'·φ .

Extremizing gives the coupled stationary equations (source #2):

    ∂F̃/∂ψ = (a₁ + λ)·ψ + b₁·ψ³ − λ·φ − h  = 0
    ∂F̃/∂φ = (a₂ + λ)·φ + b₂·φ³ − λ·ψ − h' = 0 .

The two critical lines arise from the two quadratic coefficients changing
sign independently: `C₁ : a₁ + λ = 0` (interpolation threshold `r_c¹`) and
`C₂ : a₂ + λ = 0` (grokking threshold `κ_c²`) — TWO distinct transitions.

**What is formalized.**

1. `partial_psi` / `partial_phi`: the partial derivatives of `F̃` computed as
   `HasDerivAt` statements, proving the gradient equals the source's #2 RHS.
2. `gradient_zero_system`: the algebraic stationarity system (both partials
   = 0) is equivalent to the two source equations.
3. `two_critical_loci`: at the homogeneous symmetric point `ψ = φ = 0,
   h = h' = 0`, the linearized gradient vanishes, and the two quadratic
   coefficients `a₁ + λ` and `a₂ + λ` are independent — giving two distinct
   critical loci `a₁ = −λ` and `a₂ = −λ`, which are distinct whenever
   `a₁ ≠ a₂`.

These are real-analytic / polynomial identities discharged by `HasDerivAt`
lemmas and `ring` / `linarith`.

**This file is `axiom`-free.** The physics (training dynamics, C_V jumps,
the t₁ < t₂ ordering) enters only as the choice of free energy; the
formalized content is the gradient identity and the two-root structure.
-/
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace DoubleDescent

/-- The dual-sequence Landau free energy `F̃(ψ, φ)` with training-test
coupling `λ·(ψ − φ)²`. -/
noncomputable def F (a₁ a₂ b₁ b₂ lam h h' ψ φ : ℝ) : ℝ :=
  (a₁ / 2) * ψ ^ 2 + (b₁ / 4) * ψ ^ 4
    + (a₂ / 2) * φ ^ 2 + (b₂ / 4) * φ ^ 4
    + (lam / 2) * (ψ - φ) ^ 2
    - h * ψ - h' * φ

/-- **R.275.a — partial derivative `∂F̃/∂ψ`.**

As a `HasDerivAt` statement: the ψ-derivative of `F̃(·, φ)` at `ψ` equals
the source's #2 RHS `(a₁ + λ)·ψ + b₁·ψ³ − λ·φ − h`. -/
theorem partial_psi (a₁ a₂ b₁ b₂ lam h h' ψ φ : ℝ) :
    HasDerivAt (fun x => F a₁ a₂ b₁ b₂ lam h h' x φ)
      ((a₁ + lam) * ψ + b₁ * ψ ^ 3 - lam * φ - h) ψ := by
  unfold F
  have e1 : HasDerivAt (fun x : ℝ => (a₁ / 2) * x ^ 2) ((a₁ / 2) * (2 * ψ ^ 1)) ψ :=
    (hasDerivAt_pow 2 ψ).const_mul (a₁ / 2)
  have e2 : HasDerivAt (fun x : ℝ => (b₁ / 4) * x ^ 4) ((b₁ / 4) * (4 * ψ ^ 3)) ψ :=
    (hasDerivAt_pow 4 ψ).const_mul (b₁ / 4)
  have e3 : HasDerivAt (fun x : ℝ => (lam / 2) * (x - φ) ^ 2)
      ((lam / 2) * (2 * (ψ - φ) ^ 1 * 1)) ψ :=
    (((hasDerivAt_id ψ).sub_const φ).pow 2).const_mul (lam / 2)
  have e4 : HasDerivAt (fun x : ℝ => h * x) h ψ := by
    simpa using (hasDerivAt_id ψ).const_mul h
  -- assemble matching F's left-associated tree (φ-only terms via add_const)
  have hsum :=
    ((((((e1.add e2).add_const ((a₂ / 2) * φ ^ 2)).add_const ((b₂ / 4) * φ ^ 4)).add e3).sub
      e4).sub_const (h' * φ))
  convert hsum using 1
  ring

/-- **R.275.b — partial derivative `∂F̃/∂φ`.**

As a `HasDerivAt` statement: the φ-derivative of `F̃(ψ, ·)` at `φ` equals
the source's #2 RHS `(a₂ + λ)·φ + b₂·φ³ − λ·ψ − h'`. -/
theorem partial_phi (a₁ a₂ b₁ b₂ lam h h' ψ φ : ℝ) :
    HasDerivAt (fun y => F a₁ a₂ b₁ b₂ lam h h' ψ y)
      ((a₂ + lam) * φ + b₂ * φ ^ 3 - lam * ψ - h') φ := by
  unfold F
  have hsq : HasDerivAt (fun y : ℝ => (ψ - y) ^ 2) (2 * (ψ - φ) ^ 1 * (-1)) φ := by
    have := (((hasDerivAt_const φ ψ).sub (hasDerivAt_id φ)).pow 2)
    simpa using this
  have e1 : HasDerivAt (fun y : ℝ => (a₂ / 2) * y ^ 2) ((a₂ / 2) * (2 * φ ^ 1)) φ :=
    (hasDerivAt_pow 2 φ).const_mul (a₂ / 2)
  have e2 : HasDerivAt (fun y : ℝ => (b₂ / 4) * y ^ 4) ((b₂ / 4) * (4 * φ ^ 3)) φ :=
    (hasDerivAt_pow 4 φ).const_mul (b₂ / 4)
  have e3 : HasDerivAt (fun y : ℝ => (lam / 2) * (ψ - y) ^ 2)
      ((lam / 2) * (2 * (ψ - φ) ^ 1 * (-1))) φ := hsq.const_mul (lam / 2)
  have e4 : HasDerivAt (fun y : ℝ => h' * y) h' φ := by
    simpa using (hasDerivAt_id φ).const_mul h'
  -- assemble matching F's left-associated tree (ψ-only terms via const / sub_const)
  have hsum :=
    (((((((hasDerivAt_const φ ((a₁ / 2) * ψ ^ 2)).add_const ((b₁ / 4) * ψ ^ 4)).add
      e1).add e2).add e3).sub_const (h * ψ)).sub e4)
  convert hsum using 1
  ring

/-- **R.275.c — stationarity system.**

The pair of stationary equations `∂F̃/∂ψ = 0 ∧ ∂F̃/∂φ = 0` (with the partials
computed above) is exactly the source's #2 coupled system. This restates the
gradient-zero condition algebraically. -/
theorem gradient_zero_system (a₁ a₂ b₁ b₂ lam h h' ψ φ : ℝ) :
    ((a₁ + lam) * ψ + b₁ * ψ ^ 3 - lam * φ - h = 0 ∧
     (a₂ + lam) * φ + b₂ * φ ^ 3 - lam * ψ - h' = 0)
    ↔
    ((a₁ + lam) * ψ + b₁ * ψ ^ 3 = lam * φ + h ∧
     (a₂ + lam) * φ + b₂ * φ ^ 3 = lam * ψ + h') := by
  constructor
  · rintro ⟨hψ, hφ⟩; exact ⟨by linarith, by linarith⟩
  · rintro ⟨hψ, hφ⟩; exact ⟨by linarith, by linarith⟩

/-- **R.275.d — symmetric vacuum is a critical point.**

At the homogeneous symmetric point `ψ = φ = 0` with no source fields
`h = h' = 0`, both gradient components vanish for *any* coefficients —
this is the disordered reference state from which both transitions
nucleate. -/
theorem symmetric_vacuum_critical (a₁ a₂ b₁ b₂ lam : ℝ) :
    ((a₁ + lam) * 0 + b₁ * (0 : ℝ) ^ 3 - lam * 0 - 0 = 0 ∧
     (a₂ + lam) * 0 + b₂ * (0 : ℝ) ^ 3 - lam * 0 - 0 = 0) := by
  constructor <;> ring

/-- **R.275.e — two distinct critical loci.**

The two transitions are governed by the *independent* quadratic
coefficients `a₁ + λ` (line `C₁`, interpolation) and `a₂ + λ` (line `C₂`,
grokking). The critical loci are `a₁ = −λ` and `a₂ = −λ`; they are
*distinct* exactly when `a₁ ≠ a₂`. Hence the dual-Landau model produces TWO
separate critical points, the structural origin of double descent. -/
theorem two_critical_loci (a₁ a₂ lam : ℝ) (hne : a₁ ≠ a₂) :
    (a₁ + lam = 0 ↔ a₁ = -lam) ∧
    (a₂ + lam = 0 ↔ a₂ = -lam) ∧
    ((a₁ + lam = 0 ∧ a₂ + lam = 0) → False) := by
  refine ⟨?_, ?_, ?_⟩
  · constructor <;> intro h <;> linarith
  · constructor <;> intro h <;> linarith
  · rintro ⟨h1, h2⟩; exact hne (by linarith)

end DoubleDescent

end MIP
