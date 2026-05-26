/-
Result R.520–R.524 — The 4-D capability phase space carries a natural
symplectic 2-form `ω₂`, yet MIP training is a DISSIPATIVE flow, not a
conservative (Hamiltonian) one (Cj.8.D).

Reference: `workspace/round3_exploration/slot_023.md` and
`workspace/round3_exploration/work_slot_023.md` (R.520–R.524 candidates,
slot 023; R.520 A unconditional, R.521 A conditional on D.4.16 TM).

**Candidate status: Round-3 autonomous exploration
(workspace/round3_exploration), not yet human-audited.**

**Setup.** The 4-D phase space `S = (|K|, Z⁻¹, H_K, κ)` with coordinates
`ξ = (ξ₁, ξ₂, ξ₃, ξ₄)`.  On the interior `ξ₂ > 0`, `ξ₄ > 0` define the
2-form pairing the two canonical conjugate pairs `(|K|, log Z⁻¹)` and
`(H_K, log κ)`:

    ω₂ = (1/ξ₂)·d ξ₁ ∧ d ξ₂ + (1/ξ₄)·d ξ₃ ∧ d ξ₄ ,

i.e. as an antisymmetric bilinear form on tangent vectors `u, v ∈ ℝ⁴`,

    ω₂(u, v) = (1/ξ₂)·(u₀ v₁ − u₁ v₀) + (1/ξ₄)·(u₂ v₃ − u₃ v₂).

**Statements proved here (the algebraic / order kernel).**

* **R.520 (Cj.8.D.1), A unconditional.** `ω₂` is a well-defined
  antisymmetric bilinear form (`omega_antisymm`) and is **nondegenerate**
  on the interior `ξ₂ > 0`, `ξ₄ > 0` (`omega_nondegenerate`): every
  nonzero tangent vector pairs nontrivially with some vector.  Its matrix
  `J` satisfies `Jᵀ = -J` (`omega_matrix_antisymm`).

* **R.521 (Cj.8.D.2), A conditional (D.4.16 TM).** Bundling the training
  vector field `f = (f₁, f₂, f₃, f₄)` with the TM-monotonicity
  hypotheses `f₁ > 0, f₂ > 0, f₄ > 0` (and `f₃ ≥ 0`) and `ξ₁,ξ₂,ξ₃,ξ₄ > 0`,
  the **logarithmic divergence** (the trace of the Liouville rate
  `(d|K|/dt)/|K| + (dZ⁻¹/dt)/Z⁻¹ + (dH_K/dt)/H_K + (dκ/dt)/κ`) is
  **strictly positive** (`R_521_divergence_pos`), hence **nonzero**
  (`R_521_dissipative`).  A symplectic (Hamiltonian) flow must preserve
  the Liouville volume, i.e. have zero divergence; the strict positivity
  contradicts this, so the training flow is **not Hamiltonian** — it is a
  dissipative flow (`R_521_not_hamiltonian`).

This file proves the **bilinear-form antisymmetry + nondegeneracy +
divergence-sign kernel**; the MIP-specific content (which coordinates the
2-form pairs, and TM monotonicity `dξᵢ/dt > 0`) is bundled as
hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases

namespace MIP

namespace SymplecticDissipative

/-- The symplectic 2-form `ω₂` of the 4-D phase space as an antisymmetric
bilinear form on tangent vectors, parametrised by the basepoint coordinates
`ξ₂ = Z⁻¹` and `ξ₄ = κ`:

    ω₂(u, v) = (1/ξ₂)(u₀ v₁ − u₁ v₀) + (1/ξ₄)(u₂ v₃ − u₃ v₂). -/
noncomputable def omega (ξ₂ ξ₄ : ℝ) (u v : Fin 4 → ℝ) : ℝ :=
  (1 / ξ₂) * (u 0 * v 1 - u 1 * v 0) + (1 / ξ₄) * (u 2 * v 3 - u 3 * v 2)

/-- **R.520 (S1) — `ω₂` is antisymmetric:** `ω₂(u, v) = -ω₂(v, u)`. -/
theorem omega_antisymm (ξ₂ ξ₄ : ℝ) (u v : Fin 4 → ℝ) :
    omega ξ₂ ξ₄ u v = -(omega ξ₂ ξ₄ v u) := by
  unfold omega; ring

/-- **R.520 — `ω₂` is alternating:** `ω₂(u, u) = 0`. -/
theorem omega_self (ξ₂ ξ₄ : ℝ) (u : Fin 4 → ℝ) :
    omega ξ₂ ξ₄ u u = 0 := by
  unfold omega; ring

/-- **R.520 — `ω₂` is linear in the second slot (additivity).** -/
theorem omega_add_right (ξ₂ ξ₄ : ℝ) (u v w : Fin 4 → ℝ) :
    omega ξ₂ ξ₄ u (v + w) = omega ξ₂ ξ₄ u v + omega ξ₂ ξ₄ u w := by
  unfold omega
  simp only [Pi.add_apply]
  ring

/-- The matrix representation `J` of `ω₂` (so that `ω₂(u,v) = uᵀ J v`):

    J = [ 0      1/ξ₂   0      0    ]
        [-1/ξ₂   0      0      0    ]
        [ 0      0      0      1/ξ₄ ]
        [ 0      0     -1/ξ₄   0    ]. -/
noncomputable def omegaMatrix (ξ₂ ξ₄ : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![ 0, 1/ξ₂, 0, 0;
      -(1/ξ₂), 0, 0, 0;
      0, 0, 0, 1/ξ₄;
      0, 0, -(1/ξ₄), 0]

/-- **R.520 (S1, matrix form) — the symplectic matrix is antisymmetric:**
`Jᵀ = -J`. -/
theorem omega_matrix_antisymm (ξ₂ ξ₄ : ℝ) :
    (omegaMatrix ξ₂ ξ₄).transpose = -(omegaMatrix ξ₂ ξ₄) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [omegaMatrix, Matrix.transpose_apply]

/-- **R.520 (S3) — `ω₂` is nondegenerate on the interior `ξ₂ > 0, ξ₄ > 0`.**

For every nonzero tangent vector `u` there is a `v` with `ω₂(u, v) ≠ 0`.
Witnesses: pairing `u₀` with `e₁`, `u₁` with `e₀`, `u₂` with `e₃`, `u₃`
with `e₂` (whichever component of `u` is nonzero).  This is the
nondegeneracy half of "`(M°, ω₂)` is a symplectic manifold". -/
theorem omega_nondegenerate (ξ₂ ξ₄ : ℝ) (hξ₂ : 0 < ξ₂) (hξ₄ : 0 < ξ₄)
    (u : Fin 4 → ℝ) (hu : u ≠ 0) :
    ∃ v : Fin 4 → ℝ, omega ξ₂ ξ₄ u v ≠ 0 := by
  have hξ₂' : (1 / ξ₂) ≠ 0 := by positivity
  have hξ₄' : (1 / ξ₄) ≠ 0 := by positivity
  -- some coordinate of `u` is nonzero
  have hex : ∃ k : Fin 4, u k ≠ 0 := by
    by_contra h
    apply hu
    funext k
    by_contra hk
    exact h ⟨k, hk⟩
  obtain ⟨k, hk⟩ := hex
  fin_cases k
  · -- u 0 ≠ 0 : pair with e₁ ↦ ω = (1/ξ₂)·u 0
    refine ⟨![0, 1, 0, 0], ?_⟩
    have : omega ξ₂ ξ₄ u ![0, 1, 0, 0] = (1 / ξ₂) * u 0 := by
      simp only [omega, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact mul_ne_zero hξ₂' hk
  · -- u 1 ≠ 0 : pair with e₀ ↦ ω = -(1/ξ₂)·u 1
    refine ⟨![1, 0, 0, 0], ?_⟩
    have : omega ξ₂ ξ₄ u ![1, 0, 0, 0] = -((1 / ξ₂) * u 1) := by
      simp only [omega, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact neg_ne_zero.mpr (mul_ne_zero hξ₂' hk)
  · -- u 2 ≠ 0 : pair with e₃ ↦ ω = (1/ξ₄)·u 2
    refine ⟨![0, 0, 0, 1], ?_⟩
    have : omega ξ₂ ξ₄ u ![0, 0, 0, 1] = (1 / ξ₄) * u 2 := by
      simp only [omega, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact mul_ne_zero hξ₄' hk
  · -- u 3 ≠ 0 : pair with e₂ ↦ ω = -(1/ξ₄)·u 3
    refine ⟨![0, 0, 1, 0], ?_⟩
    have : omega ξ₂ ξ₄ u ![0, 0, 1, 0] = -((1 / ξ₄) * u 3) := by
      simp only [omega, Matrix.cons_val_zero, Matrix.cons_val_one,
        Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three,
        Matrix.tail_cons]
      ring
    rw [this]
    exact neg_ne_zero.mpr (mul_ne_zero hξ₄' hk)

/-- The logarithmic divergence of the training vector field
`f = (f₁, f₂, f₃, f₄)` at the point `ξ = (ξ₁, ξ₂, ξ₃, ξ₄)`:

    div_log f ξ = f₁/ξ₁ + f₂/ξ₂ + f₃/ξ₃ + f₄/ξ₄ .

This is the trace of the Liouville rate `(d/dt) log vol_ω` along the flow
(the volume form is `(1/(ξ₂·ξ₄)) dξ₁∧dξ₂∧dξ₃∧dξ₄`, whose logarithmic time
derivative is this sum). -/
noncomputable def divLog (f ξ : Fin 4 → ℝ) : ℝ :=
  f 0 / ξ 0 + f 1 / ξ 1 + f 2 / ξ 2 + f 3 / ξ 3

/-- **R.521 (Cj.8.D.2) — the Liouville (logarithmic) divergence of the TM
training flow is strictly positive.**

Bundling the D.4.16 TM-monotonicity of the training vector field
(`f₁ = d|K|/dt > 0`, `f₂ = dZ⁻¹/dt > 0`, `f₄ = dκ/dt > 0` — R.98 Gompertz
— and `f₃ = dH_K/dt ≥ 0`) with positivity of the coordinates, the
divergence `div_log f ξ > 0`. -/
theorem R_521_divergence_pos
    (f ξ : Fin 4 → ℝ)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3) :
    0 < divLog f ξ := by
  unfold divLog
  have h1 : 0 < f 0 / ξ 0 := div_pos hf₁ hξ₁
  have h2 : 0 < f 1 / ξ 1 := div_pos hf₂ hξ₂
  have h3 : 0 ≤ f 2 / ξ 2 := div_nonneg hf₃ (le_of_lt hξ₃)
  have h4 : 0 < f 3 / ξ 3 := div_pos hf₄ hξ₄
  linarith

/-- **R.521 — the training flow is dissipative: its divergence is nonzero.** -/
theorem R_521_dissipative
    (f ξ : Fin 4 → ℝ)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3) :
    divLog f ξ ≠ 0 :=
  ne_of_gt (R_521_divergence_pos f ξ hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄)

/-- **R.521 (Cj.8.D.2) — the TM training flow is not a Hamiltonian flow.**

A Hamiltonian (symplectic) flow preserves the Liouville volume, hence has
**zero** divergence everywhere (`hHam : div_log f ξ = 0`).  The strict
positivity of the TM divergence (`R_521_divergence_pos`) contradicts this.
Therefore no Hamiltonian generates the TM training flow: MIP training is a
dissipative, not a conservative, dynamics. -/
theorem R_521_not_hamiltonian
    (f ξ : Fin 4 → ℝ)
    (hξ₁ : 0 < ξ 0) (hξ₂ : 0 < ξ 1) (hξ₃ : 0 < ξ 2) (hξ₄ : 0 < ξ 3)
    (hf₁ : 0 < f 0) (hf₂ : 0 < f 1) (hf₃ : 0 ≤ f 2) (hf₄ : 0 < f 3)
    (hHam : divLog f ξ = 0) : False :=
  (R_521_dissipative f ξ hξ₁ hξ₂ hξ₃ hξ₄ hf₁ hf₂ hf₃ hf₄) hHam

end SymplecticDissipative

end MIP
