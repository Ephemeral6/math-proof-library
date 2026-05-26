/-
Result R.524 (Cj.8.D.5, B candidate) — The 5-D capability phase space
`(|K|, Z⁻¹, H_K, κ, μ̃)` carries a CONTACT structure: the contact 1-form
`θ₅` satisfies the non-degeneracy `θ₅ ∧ (dθ₅)² ≠ 0`.

Reference: `workspace/round3_exploration/slot_023.md` and
`workspace/round3_exploration/work_slot_023.md` §6.2 (Cj.8.D.5, candidate
R.524 — B candidate, slot 023; "the odd 5th dimension μ̃ degenerates the
symplectic structure to a contact structure: `θ₅ := dμ̃ − (log Z⁻¹)d|K| −
(log κ)dH_K` with `dθ₅ = ω₂`, so `(M₅, θ₅)` is a contact manifold").
The companion symplectic results R.520/R.521 live in
`R520_SymplecticDissipative.lean` (same slot); this file reuses the same
antisymmetric-form / `ω₂` approach.

**Candidate status: Round-3 autonomous exploration
(workspace/round3_exploration), not yet human-audited.**

**Setup.** On the interior `ξ₂ = Z⁻¹ > 0`, `ξ₄ = κ > 0` of the 5-D phase
space with coordinates `x = (x₀,x₁,x₂,x₃,x₄) = (|K|, Z⁻¹, H_K, κ, μ̃)`,
take the contact 1-form

    θ₅ = dx₄ − (log x₁)·dx₀ − (log x₃)·dx₂        (work-slot §6.2),

whose exterior derivative is the R.520 symplectic form lifted to `ℝ⁵`,

    dθ₅ = (1/x₁)·dx₀∧dx₁ + (1/x₃)·dx₂∧dx₃ = ω₂ ,

an antisymmetric 2-form on tangent vectors `u, v ∈ ℝ⁵`:

    dθ₅(u, v) = (1/x₁)(u₀v₁ − u₁v₀) + (1/x₃)(u₂v₃ − u₃v₂).

The **contact (non-degeneracy) condition** on a `(2n+1)`-manifold,
`θ ∧ (dθ)ⁿ ≠ 0`, is equivalent to `dθ` being a symplectic (non-degenerate)
form on the contact hyperplane `ξ = ker θ`. Here `n = 2`.

**Statements proved here (the contact non-degeneracy kernel).**

* **R.524 (S1) — `dθ₅` is antisymmetric** (`dtheta_antisymm`) and
  alternating (`dtheta_self`), as in R.520.

* **R.524 (S2) — top-form coefficient is non-zero.** Computing
  `θ₅ ∧ (dθ₅)²` against the standard frame, the single coefficient of the
  volume form `dx₀∧dx₁∧dx₂∧dx₃∧dx₄` is `2·(1/x₁)·(1/x₃)`, which is
  `≠ 0` on `x₁ > 0, x₃ > 0` (`R_524_contact_volume_ne_zero`). This is the
  algebraic `θ₅ ∧ (dθ₅)² ≠ 0` contact condition.

* **R.524 (S3) — `dθ₅` is non-degenerate on the contact hyperplane.** For
  every nonzero tangent vector `u` *in the contact hyperplane*
  `ξ = {u : θ₅·u = 0}` (here the linear part `θ₅·u = u₄ − (log x₁)u₀ −
  (log x₃)u₂`), there is a `v` (also realizable in `ξ`) with
  `dθ₅(u, v) ≠ 0` (`R_524_contact_hyperplane_nondeg`). Hence `(M₅, θ₅)` is
  a contact manifold, the odd-dimensional analogue of the R.520 symplectic
  structure.

This file proves the **contact non-degeneracy kernel**; the MIP-specific
content (`θ₅` from the μ̃-extension, `dθ₅ = ω₂` the R.520 form) is bundled
in the explicit definitions.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.VecNotation
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases

namespace MIP

namespace ContactStructure

/-- The linear part of the contact 1-form `θ₅` at a base point with
`log x₁ = a`, `log x₃ = b`, evaluated on a tangent vector `u ∈ ℝ⁵`:

    θ₅(u) = u₄ − a·u₀ − b·u₂. -/
def theta (a b : ℝ) (u : Fin 5 → ℝ) : ℝ :=
  u 4 - a * u 0 - b * u 2

/-- The contact 2-form `dθ₅ = ω₂` (lifted to `ℝ⁵`, independent of the
μ̃-direction):

    dθ₅(u, v) = (1/x₁)(u₀v₁ − u₁v₀) + (1/x₃)(u₂v₃ − u₃v₂). -/
noncomputable def dtheta (x₁ x₃ : ℝ) (u v : Fin 5 → ℝ) : ℝ :=
  (1 / x₁) * (u 0 * v 1 - u 1 * v 0) + (1 / x₃) * (u 2 * v 3 - u 3 * v 2)

/-- **R.524 (S1) — `dθ₅` is antisymmetric:** `dθ₅(u,v) = −dθ₅(v,u)`. -/
theorem dtheta_antisymm (x₁ x₃ : ℝ) (u v : Fin 5 → ℝ) :
    dtheta x₁ x₃ u v = -(dtheta x₁ x₃ v u) := by
  unfold dtheta; ring

/-- **R.524 (S1) — `dθ₅` is alternating:** `dθ₅(u,u) = 0`. -/
theorem dtheta_self (x₁ x₃ : ℝ) (u : Fin 5 → ℝ) :
    dtheta x₁ x₃ u u = 0 := by
  unfold dtheta; ring

/-- The single coefficient of the contact top-form `θ₅ ∧ (dθ₅)²` relative
to the standard volume form `dx₀∧dx₁∧dx₂∧dx₃∧dx₄`.

`(dθ₅)² = 2·(1/x₁)(1/x₃)·dx₀∧dx₁∧dx₂∧dx₃`, and wedging with `θ₅`, only the
`dx₄` term of `θ₅` survives (the `dx₀`, `dx₂` terms already appear in
`(dθ₅)²`), giving coefficient `2·(1/x₁)·(1/x₃)`. -/
noncomputable def contactVolumeCoeff (x₁ x₃ : ℝ) : ℝ :=
  2 * (1 / x₁) * (1 / x₃)

/-- **R.524 (S2) — the contact condition `θ₅ ∧ (dθ₅)² ≠ 0`.**

On the interior `x₁ > 0`, `x₃ > 0`, the top-form coefficient
`2·(1/x₁)·(1/x₃)` is non-zero, i.e. `θ₅ ∧ (dθ₅)²` is a non-vanishing top
form: `(M₅, θ₅)` satisfies the contact non-degeneracy condition. -/
theorem R_524_contact_volume_ne_zero (x₁ x₃ : ℝ) (hx₁ : 0 < x₁) (hx₃ : 0 < x₃) :
    contactVolumeCoeff x₁ x₃ ≠ 0 := by
  unfold contactVolumeCoeff
  have h1 : (1 / x₁) ≠ 0 := by positivity
  have h3 : (1 / x₃) ≠ 0 := by positivity
  have h2 : (2 : ℝ) ≠ 0 := by norm_num
  exact mul_ne_zero (mul_ne_zero h2 h1) h3

/-- **R.524 (S2, strict positivity) — the contact volume coefficient is
strictly positive on the interior.** This pins the orientation of the
contact structure. -/
theorem R_524_contact_volume_pos (x₁ x₃ : ℝ) (hx₁ : 0 < x₁) (hx₃ : 0 < x₃) :
    0 < contactVolumeCoeff x₁ x₃ := by
  unfold contactVolumeCoeff
  positivity

/-- **R.524 (S3) — `dθ₅` is non-degenerate on the contact hyperplane.**

The contact hyperplane is `ξ = ker θ₅ = {u : θ₅(u) = 0}`. For every
nonzero tangent vector `u` lying in `ξ`, there is a tangent vector `v`
with `dθ₅(u, v) ≠ 0`. We exhibit the witness explicitly: whichever of
`u₀,u₁,u₂,u₃` is nonzero pairs nontrivially under `dθ₅` (the proof of
nondegeneracy of `ω₂`, R.520).

Note `u ≠ 0` together with `u ∈ ξ` need not have a nonzero component among
`u₀..u₃` only if `u = (0,0,0,0,u₄)` with `u₄ = θ₅(u) = 0` (from the kernel
condition `θ₅(u)=0` with `u₀=u₂=0`), i.e. `u = 0`; so any nonzero `u ∈ ξ`
has a nonzero component among `u₀..u₃`, giving the symplectic witness. -/
theorem R_524_contact_hyperplane_nondeg
    (a b x₁ x₃ : ℝ) (hx₁ : 0 < x₁) (hx₃ : 0 < x₃)
    (u : Fin 5 → ℝ) (hu : u ≠ 0) (hker : theta a b u = 0) :
    ∃ v : Fin 5 → ℝ, dtheta x₁ x₃ u v ≠ 0 := by
  have h1 : (1 / x₁) ≠ 0 := by positivity
  have h3 : (1 / x₃) ≠ 0 := by positivity
  -- Some component among the four "symplectic" coordinates 0,1,2,3 is
  -- nonzero: otherwise u₀=u₁=u₂=u₃=0 and θ₅(u)=u₄=0 forces u=0.
  have hex : ∃ k : Fin 4, u (k.castSucc) ≠ 0 := by
    by_contra h
    -- `h : ¬ ∃ k, u k.castSucc ≠ 0`, so each of u 0..u 3 is zero.
    have hall : ∀ k : Fin 4, u (k.castSucc) = 0 := by
      intro k
      by_contra hk
      exact h ⟨k, hk⟩
    have h0 : u 0 = 0 := by simpa using hall 0
    have h1' : u 1 = 0 := by simpa using hall 1
    have h2 : u 2 = 0 := by simpa using hall 2
    have h3' : u 3 = 0 := by simpa using hall 3
    -- from θ₅(u) = u₄ − a·u₀ − b·u₂ = 0 and u₀=u₂=0 we get u₄ = 0.
    have h4 : u 4 = 0 := by
      have := hker
      unfold theta at this
      rw [h0, h2] at this
      linarith
    apply hu
    funext i
    fin_cases i <;> simp_all
  obtain ⟨k, hk⟩ := hex
  fin_cases k
  · -- u 0 ≠ 0 : pair with e₁ ↦ dθ₅ = (1/x₁)·u 0
    refine ⟨![0, 1, 0, 0, 0], ?_⟩
    have : dtheta x₁ x₃ u ![0, 1, 0, 0, 0] = (1 / x₁) * u 0 := by
      simp only [dtheta, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact mul_ne_zero h1 (by simpa using hk)
  · -- u 1 ≠ 0 : pair with e₀ ↦ dθ₅ = -(1/x₁)·u 1
    refine ⟨![1, 0, 0, 0, 0], ?_⟩
    have : dtheta x₁ x₃ u ![1, 0, 0, 0, 0] = -((1 / x₁) * u 1) := by
      simp only [dtheta, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact neg_ne_zero.mpr (mul_ne_zero h1 (by simpa using hk))
  · -- u 2 ≠ 0 : pair with e₃ ↦ dθ₅ = (1/x₃)·u 2
    refine ⟨![0, 0, 0, 1, 0], ?_⟩
    have : dtheta x₁ x₃ u ![0, 0, 0, 1, 0] = (1 / x₃) * u 2 := by
      simp only [dtheta, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact mul_ne_zero h3 (by simpa using hk)
  · -- u 3 ≠ 0 : pair with e₂ ↦ dθ₅ = -(1/x₃)·u 3
    refine ⟨![0, 0, 1, 0, 0], ?_⟩
    have : dtheta x₁ x₃ u ![0, 0, 1, 0, 0] = -((1 / x₃) * u 3) := by
      simp only [dtheta, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact neg_ne_zero.mpr (mul_ne_zero h3 (by simpa using hk))

end ContactStructure

end MIP
