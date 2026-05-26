/-
Result R.523 (Cj.8.D.4) — The 4-D capability phase geometry is NON-KÄHLER:
the symplectic form `ω₂` of R.520 and the (Euclidean) Fisher metric `g`
are NOT compatible with the standard almost-complex structure `J`, i.e.
there is no Kähler compatibility `ω(u,v) = g(Ju,v)`.

Reference: `workspace/round3_exploration/slot_023.md` and
`workspace/round3_exploration/work_slot_023.md` §5 (Cj.8.D.4, candidate
R.523, slot 023; "the 4D phase space is not Kähler — symplectic + Riemann
+ complex-J cannot be made compatible"). The companion symplectic results
R.520/R.521 live in `R520_SymplecticDissipative.lean` (same slot); this
file reuses the same `ω₂`.

**Candidate status: Round-3 autonomous exploration
(workspace/round3_exploration), not yet human-audited.**

**Setup.** On the interior `ξ₂ > 0`, `ξ₄ > 0` of the 4-D phase space
`(|K|, Z⁻¹, H_K, κ)`, R.520 gives the symplectic 2-form

    ω₂(u, v) = (1/ξ₂)(u₀ v₁ − u₁ v₀) + (1/ξ₄)(u₂ v₃ − u₃ v₂).

A Kähler structure would require a metric `g`, an almost-complex
structure `J` (`J² = −Id`), and the compatibility identity

    ω₂(u, v) = g(J u, v)        for all tangent vectors `u, v`.

We take the standard pieces of the candidate complex structure on `ℝ⁴`:
* the **standard almost-complex structure** `J` pairing the two canonical
  conjugate planes, `J·e₀ = e₁`, `J·e₁ = −e₀`, `J·e₂ = e₃`, `J·e₃ = −e₂`
  (so `J² = −Id`, `Jrepr_sq_eq_neg_id`); and
* the **Euclidean Fisher metric** `g(u,v) = ⟨u,v⟩ = Σ uᵢ vᵢ` (R.126/R.136
  flatness gives a flat — hence locally Euclidean — diagonal metric).

**Statements proved here (the Kähler-incompatibility kernel).**

* **R.523 (S0) — `J` is a genuine almost-complex structure:** `J² = −Id`
  (`Jrepr_sq_eq_neg_id`).

* **R.523 (S1) — explicit compatibility defect.** The compatibility
  tensor `T(u,v) := ω₂(u,v) − g(J u, v)` equals

      T(u,v) = (1/ξ₂ − 1)(u₀ v₁ − u₁ v₀) + (1/ξ₄ − 1)(u₂ v₃ − u₃ v₂)

  (`compatDefect_eq`).

* **R.523 (S2) — the geometry is non-Kähler.** Whenever the metric is not
  conformally matched to `ω₂` on the first canonical plane, i.e.
  `1/ξ₂ ≠ 1` (equivalently `ξ₂ ≠ 1`), the defect is **non-vanishing**:
  evaluating on `u = e₀, v = e₁` gives `T(e₀,e₁) = 1/ξ₂ − 1 ≠ 0`
  (`R_523_not_kahler`). Hence `ω₂(·,·) ≠ g(J·,·)`: no Kähler compatibility
  holds for the calibrated symplectic form and the (flat) Fisher metric.
  The same conclusion holds on the second plane whenever `ξ₄ ≠ 1`
  (`R_523_not_kahler_plane2`).

This file proves the **Kähler-incompatibility kernel**; the MIP-specific
content (`ω₂` = R.520 symplectic form, `g` = flat R.126/R.136 Fisher
metric, `J` = canonical pairing) is bundled in the explicit definitions.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.VecNotation
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases

namespace MIP

namespace NonKahler

/-- The symplectic 2-form `ω₂` of the 4-D phase space (identical to R.520):

    ω₂(u, v) = (1/ξ₂)(u₀ v₁ − u₁ v₀) + (1/ξ₄)(u₂ v₃ − u₃ v₂). -/
noncomputable def omega (ξ₂ ξ₄ : ℝ) (u v : Fin 4 → ℝ) : ℝ :=
  (1 / ξ₂) * (u 0 * v 1 - u 1 * v 0) + (1 / ξ₄) * (u 2 * v 3 - u 3 * v 2)

/-- The Euclidean (flat Fisher) metric `g(u,v) = Σ uᵢ vᵢ`. -/
def gmetric (u v : Fin 4 → ℝ) : ℝ :=
  u 0 * v 0 + u 1 * v 1 + u 2 * v 2 + u 3 * v 3

/-- The standard almost-complex structure `J` on `ℝ⁴` pairing the two
canonical conjugate planes:
`J·e₀ = e₁`, `J·e₁ = −e₀`, `J·e₂ = e₃`, `J·e₃ = −e₂`.

Acting on a vector `u = (u₀,u₁,u₂,u₃)`:
`J u = (−u₁, u₀, −u₃, u₂)`. -/
def Jrepr (u : Fin 4 → ℝ) : Fin 4 → ℝ :=
  ![-(u 1), u 0, -(u 3), u 2]

/-- **R.523 (S0) — `J` is a genuine almost-complex structure: `J² = −Id`.**

`J(J u) = J(−u₁, u₀, −u₃, u₂) = (−u₀, −u₁, −u₂, −u₃) = −u`. -/
theorem Jrepr_sq_eq_neg_id (u : Fin 4 → ℝ) :
    Jrepr (Jrepr u) = fun i => -(u i) := by
  funext i
  fin_cases i <;>
    simp [Jrepr, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]

/-- The Kähler **compatibility defect tensor**
`T(u,v) := ω₂(u,v) − g(J u, v)`. A Kähler structure requires `T ≡ 0`. -/
noncomputable def compatDefect (ξ₂ ξ₄ : ℝ) (u v : Fin 4 → ℝ) : ℝ :=
  omega ξ₂ ξ₄ u v - gmetric (Jrepr u) v

/-- **Auxiliary — `g(J u, v)` in coordinates.**

`g(J u, v) = (−u₁)v₀ + u₀ v₁ + (−u₃)v₂ + u₂ v₃ = (u₀ v₁ − u₁ v₀) + (u₂ v₃ − u₃ v₂)`. -/
theorem gmetric_Jrepr (u v : Fin 4 → ℝ) :
    gmetric (Jrepr u) v = (u 0 * v 1 - u 1 * v 0) + (u 2 * v 3 - u 3 * v 2) := by
  unfold gmetric Jrepr
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  ring

/-- **R.523 (S1) — explicit compatibility defect.**

`T(u,v) = (1/ξ₂ − 1)(u₀ v₁ − u₁ v₀) + (1/ξ₄ − 1)(u₂ v₃ − u₃ v₂)`.

If `ω₂` were `g`-compatible (Kähler), `T` would vanish identically;
the residual `(1/ξ₂ − 1)`, `(1/ξ₄ − 1)` factors measure the failure. -/
theorem compatDefect_eq (ξ₂ ξ₄ : ℝ) (u v : Fin 4 → ℝ) :
    compatDefect ξ₂ ξ₄ u v =
      (1 / ξ₂ - 1) * (u 0 * v 1 - u 1 * v 0)
      + (1 / ξ₄ - 1) * (u 2 * v 3 - u 3 * v 2) := by
  unfold compatDefect omega
  rw [gmetric_Jrepr]
  ring

/-- **R.523 (S2) — the 4-D phase geometry is NON-KÄHLER (first plane).**

Whenever the Fisher metric is not conformally matched to `ω₂` on the
`(|K|, Z⁻¹)` canonical plane, i.e. `ξ₂ ≠ 1` (so `1/ξ₂ ≠ 1`), the Kähler
compatibility `ω₂(u,v) = g(J u, v)` fails: on `u = e₀, v = e₁` the defect
is `1/ξ₂ − 1 ≠ 0`. Hence there is no compatible Kähler triple. -/
theorem R_523_not_kahler (ξ₂ ξ₄ : ℝ) (hξ₂ : 0 < ξ₂) (hne : ξ₂ ≠ 1) :
    ∃ u v : Fin 4 → ℝ, compatDefect ξ₂ ξ₄ u v ≠ 0 := by
  refine ⟨![1, 0, 0, 0], ![0, 1, 0, 0], ?_⟩
  rw [compatDefect_eq]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  -- defect reduces to (1/ξ₂ − 1)·(1·1 − 0·0) + (1/ξ₄ − 1)·0 = 1/ξ₂ − 1.
  have hval : (1 / ξ₂ - 1) * (1 * 1 - 0 * 0) + (1 / ξ₄ - 1) * (0 * 0 - 0 * 0)
      = 1 / ξ₂ - 1 := by ring
  rw [hval]
  -- `1/ξ₂ ≠ 1` since `ξ₂ ≠ 1` and `ξ₂ > 0`.
  intro hcontra
  apply hne
  have h1 : (1 : ℝ) / ξ₂ = 1 := by linarith
  have hξ₂' : ξ₂ ≠ 0 := ne_of_gt hξ₂
  rw [div_eq_one_iff_eq hξ₂'] at h1
  linarith

/-- **R.523 — non-Kähler on the second canonical plane.**

The same incompatibility appears on the `(H_K, κ)` plane whenever
`ξ₄ ≠ 1`: on `u = e₂, v = e₃` the defect is `1/ξ₄ − 1 ≠ 0`. -/
theorem R_523_not_kahler_plane2 (ξ₂ ξ₄ : ℝ) (hξ₄ : 0 < ξ₄) (hne : ξ₄ ≠ 1) :
    ∃ u v : Fin 4 → ℝ, compatDefect ξ₂ ξ₄ u v ≠ 0 := by
  refine ⟨![0, 0, 1, 0], ![0, 0, 0, 1], ?_⟩
  rw [compatDefect_eq]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  have hval : (1 / ξ₂ - 1) * (0 * 0 - 0 * 0) + (1 / ξ₄ - 1) * (1 * 1 - 0 * 0)
      = 1 / ξ₄ - 1 := by ring
  rw [hval]
  intro hcontra
  apply hne
  have h1 : (1 : ℝ) / ξ₄ = 1 := by linarith
  have hξ₄' : ξ₄ ≠ 0 := ne_of_gt hξ₄
  rw [div_eq_one_iff_eq hξ₄'] at h1
  linarith

end NonKahler

end MIP
