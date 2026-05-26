/-
Result R.137 (i) — Teaching power peaks at `t*` (co-peak of |M_eff| and ψ).

Reference: `branches/duality/workspace/new_results.md` R.137 (A 条件性 ITA,
2026-05-16 duality branch).

**Statement (algebraic core).** Define `P_edu(t) := α_H · M_eff(t) · ψ(t) / Φ₀`.
Under R.134's ITA hypothesis, both `M_eff(t)` and `ψ(t)` attain their
maximum at the same `t*`.  Then `P_edu(t) ≤ P_edu(t*)` for all `t`.

**Pure-math content.** If `f, g : ℕ → ℝ` are both non-negative and both
attain maximum at the same point `t*`, then their product `t ↦ f t · g t`
also attains maximum at `t*`.

**Proof sketch.** `f(t)·g(t) ≤ f(t*)·g(t)` (since `f t ≤ f t*` and
`g t ≥ 0`), then `f(t*)·g(t) ≤ f(t*)·g(t*)` (since `g t ≤ g t*` and
`f t* ≥ 0`).  Compose.

This file proves the **co-peak product kernel** plus the explicit
`P_edu(t*)` formula in the R.137 (i) form.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace TeachingPower

/-- **R.137 (i) — co-peak product peaks at the same point.**

If `f, g : ι → ℝ` both attain maximum at `t* ∈ ι` and are non-negative
everywhere, then the product `t ↦ f t · g t` also attains maximum at
`t*`. -/
theorem R_137_i_copeak_product
    {ι : Type*} (f g : ι → ℝ) (t_star : ι)
    (h_f_max : ∀ t, f t ≤ f t_star)
    (h_g_max : ∀ t, g t ≤ g t_star)
    (h_f_nonneg : ∀ t, 0 ≤ f t)
    (h_g_nonneg : ∀ t, 0 ≤ g t) :
    ∀ t, f t * g t ≤ f t_star * g t_star := by
  intro t
  have h_f_star_nonneg : 0 ≤ f t_star := h_f_nonneg t_star
  calc f t * g t
      ≤ f t_star * g t :=
        mul_le_mul_of_nonneg_right (h_f_max t) (h_g_nonneg t)
    _ ≤ f t_star * g t_star :=
        mul_le_mul_of_nonneg_left (h_g_max t) h_f_star_nonneg

/-- **R.137 (i) — explicit `P_edu(t*)` formula.**

`P_edu(t*) = α_H · M_eff(t*) · ψ(t*) / Φ₀(H, p)`.  Pure substitution. -/
theorem R_137_i_P_edu_value
    (α_H M_eff_star ψ_star Phi0 P_edu_star : ℝ)
    (h_def : P_edu_star = α_H * M_eff_star * ψ_star / Phi0) :
    P_edu_star = α_H * M_eff_star * ψ_star / Phi0 :=
  h_def

/-- **R.137.d — teaching power upper bound.**

`dK(H)/dt ≤ P_edu(t*)` by R.137 (i).  Pure inequality propagation. -/
theorem R_137_d_upper_bound
    (dK_dt P_edu_t P_edu_star : ℝ)
    (h_pointwise : dK_dt ≤ P_edu_t)
    (h_t_le_star : P_edu_t ≤ P_edu_star) :
    dK_dt ≤ P_edu_star :=
  le_trans h_pointwise h_t_le_star

end TeachingPower

end MIP
