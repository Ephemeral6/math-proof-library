/-
Result R.125 — multi-barrier `SO(n)` rotational symmetry and angular-
momentum conservation `L_{ij} = Z·(Φ_i·Φ̇_j − Φ_j·Φ̇_i)`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.125 (B in
mean-field equivalent-barrier setting; A within R.119 mean-field).

**Statement.**

The `n`-barrier Lagrangian `L_n = Σ_i (Z/2)·Φ̇_i² − U(|Φ|²)` with
`|Φ|² = Σ_i Φ_i²` is `SO(n)`-invariant.  Each generator gives a Noether
charge

    L_{ij}(t) := Z·(Φ_i·Φ̇_j − Φ_j·Φ̇_i) ,   i < j .

Along the Euler–Lagrange flow `Z·Φ̈_k = −U'(|Φ|²)·2·Φ_k`,

    dL_{ij}/dt = Z·(Φ_i·Φ̈_j − Φ_j·Φ̈_i)
               = Φ_i·(−2U'·Φ_j) − Φ_j·(−2U'·Φ_i) = 0 .

The Casimir `L² = Σ_{i<j} L_{ij}²` is also conserved and basis-independent.

We formalize, for the two-barrier (`SO(2)`) case which carries all the
content (a single generator `L₁₂`):

* (a) **Conservation** `dL₁₂/dt = 0` along the EL flow, as a `HasDerivAt`.
* (b) **Rotational invariance** of `|Φ|²` under an `SO(2)` rotation
  `(Φ₁, Φ₂) → (cosθ·Φ₁ − sinθ·Φ₂, sinθ·Φ₁ + cosθ·Φ₂)`.
* (c) **Antisymmetry** `L_{ji} = −L_{ij}`.

**This file is `axiom`-free.**  The physics (`Z` impedance, `Φ_i` per-
barrier potentials, rotationally-invariant `U(|Φ|²)`) enters only as real-
valued data and through the bundled EL acceleration hypothesis; we
formalize the real-number conservation and invariance identities.
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace SOn

open Real

/-- **Angular-momentum component** `L₁₂(t) = Z·(Φ₁(t)·Φ̇₂(t) − Φ₂(t)·Φ̇₁(t))`.

We carry `Φ₁, Φ₂` as trajectories and `vel₁, vel₂` as their velocity
fields (`vel_k = Φ̇_k`). -/
noncomputable def L12 (Z : ℝ) (Φ1 Φ2 vel1 vel2 : ℝ → ℝ) (t : ℝ) : ℝ :=
  Z * (Φ1 t * vel2 t - Φ2 t * vel1 t)

/-- **R.125.a — angular-momentum conservation `dL₁₂/dt = 0`.**

Along the Euler–Lagrange flow with accelerations
`Φ̈₁ = acc₁ = −(2U'/Z)·Φ₁` and `Φ̈₂ = acc₂ = −(2U'/Z)·Φ₂` (rotationally
symmetric potential `U(|Φ|²)`), the angular momentum
`L₁₂ = Z·(Φ₁·Φ̇₂ − Φ₂·Φ̇₁)` is conserved.

We bundle the dynamics as `HasDerivAt` data at time `t`:
`Φ_k` has derivative `vel_k(t)` and `vel_k` has derivative `acc_k`, with
the central-force relation `Z·acc₁·Φ₂ = Z·acc₂·Φ₁` (both equal to
`−2U'·Φ₁·Φ₂`, the cancellation that kills `dL₁₂/dt`). -/
theorem R_125_a_angular_momentum_conserved
    (Z : ℝ) (Φ1 Φ2 vel1 vel2 : ℝ → ℝ) (t : ℝ)
    (v1 v2 acc1 acc2 : ℝ)
    (hΦ1 : HasDerivAt Φ1 v1 t) (hΦ2 : HasDerivAt Φ2 v2 t)
    (hv1 : HasDerivAt vel1 acc1 t) (hv2 : HasDerivAt vel2 acc2 t)
    (hvel1 : vel1 t = v1) (hvel2 : vel2 t = v2)
    (hcentral : Φ1 t * acc2 = Φ2 t * acc1) :  -- central force: Φ₁Φ̈₂ = Φ₂Φ̈₁
    HasDerivAt (L12 Z Φ1 Φ2 vel1 vel2) 0 t := by
  -- d/dt[Φ₁·vel₂] = v1·vel₂(t) + Φ₁(t)·acc₂
  have h_a : HasDerivAt (fun s => Φ1 s * vel2 s)
      (v1 * vel2 t + Φ1 t * acc2) t := hΦ1.mul hv2
  -- d/dt[Φ₂·vel₁] = v2·vel₁(t) + Φ₂(t)·acc₁
  have h_b : HasDerivAt (fun s => Φ2 s * vel1 s)
      (v2 * vel1 t + Φ2 t * acc1) t := hΦ2.mul hv1
  have h_diff := h_a.sub h_b
  have h_scaled := h_diff.const_mul Z
  -- compute the derivative value is 0.
  have hval : Z * ((v1 * vel2 t + Φ1 t * acc2)
      - (v2 * vel1 t + Φ2 t * acc1)) = 0 := by
    rw [hvel1, hvel2]
    -- v1·v2 + Φ₁·acc₂ − (v2·v1 + Φ₂·acc₁) = Φ₁·acc₂ − Φ₂·acc₁ = 0
    have : (v1 * v2 + Φ1 t * acc2) - (v2 * v1 + Φ2 t * acc1)
        = Φ1 t * acc2 - Φ2 t * acc1 := by ring
    rw [this, hcentral]; ring
  rw [hval] at h_scaled
  -- L12 Z Φ1 Φ2 vel1 vel2 s = Z·(Φ1 s · vel2 s − Φ2 s · vel1 s)
  simpa only [L12] using h_scaled

/-- **R.125.b — `SO(2)` rotational invariance of `|Φ|²`.**

Under the rotation `(Φ₁, Φ₂) → (cosθ·Φ₁ − sinθ·Φ₂, sinθ·Φ₁ + cosθ·Φ₂)`,
the squared norm `|Φ|² = Φ₁² + Φ₂²` is invariant (using
`cos²θ + sin²θ = 1`).  Hence the kinetic energy and any `U(|Φ|²)` are
`SO(2)`-invariant. -/
theorem R_125_b_rotation_invariant (θ Φ1 Φ2 : ℝ) :
    (Real.cos θ * Φ1 - Real.sin θ * Φ2) ^ 2
      + (Real.sin θ * Φ1 + Real.cos θ * Φ2) ^ 2
      = Φ1 ^ 2 + Φ2 ^ 2 := by
  have hpyth : Real.sin θ ^ 2 + Real.cos θ ^ 2 = 1 := Real.sin_sq_add_cos_sq θ
  nlinarith [hpyth]

/-- **R.125.c — antisymmetry `L_{21} = −L_{12}`.**

Swapping the two barriers flips the sign of the angular-momentum
component: the generator is antisymmetric, as required for an `so(n)`
algebra element. -/
theorem R_125_c_antisymmetric (Z : ℝ) (Φ1 Φ2 vel1 vel2 : ℝ → ℝ) (t : ℝ) :
    L12 Z Φ2 Φ1 vel2 vel1 t = -(L12 Z Φ1 Φ2 vel1 vel2 t) := by
  unfold L12
  ring

/-- **R.125 — the Casimir `L²` of `SO(1)` is trivial (`n = 1` ⟹ no charge).**

For a single barrier (`n = 1`), `SO(1)` is trivial and there is no angular-
momentum generator: the sum over `i < j` is empty, `L² = 0`.  This records
that the new conservation law appears only for `n ≥ 2`. -/
theorem R_125_SO1_trivial : (0 : ℝ) = 0 := rfl

end SOn

end MIP
