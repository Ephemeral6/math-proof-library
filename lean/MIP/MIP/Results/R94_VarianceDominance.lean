/-
Result R.94 — Two-dimensional variance phase dichotomy by the criterion `τ`.

Reference: `workspace/new_results.md` R.94 ("σ_Z 与 Var[Φ₀] 的二维训练阶段图",
B 级, fourth batch).  The algebraic / arithmetic core is formalized here;
the empirical "training stage" interpretation is the MIP-side narrative.

**Statement interpretation used.**  R.94 builds on the R.89 variance
decomposition

    Var[N]  =  Z̄²·Var[Φ₀]  +  σ_Z²·E[Φ₀²]      (two leading terms),

and defines the *variance criterion*

    τ  :=  (σ_Z²·E[Φ₀²]) / (Z̄²·Var[Φ₀]).

R.94's dichotomy is then:
* `τ > 1`  ⟺  the impedance-heterogeneity term `σ_Z²·E[Φ₀²]` dominates
            (so training should reduce `σ_Z`);
* `τ < 1`  ⟺  the problem-difficulty term `Z̄²·Var[Φ₀]` dominates
            (so training should balance the data);
* `τ = 1`  ⟺  the two terms are equal (marginal returns equal).

This file formalizes:
* the **decomposition identity** `Var[N] = D_Φ + D_Z` with
  `D_Φ := Z̄²·Var[Φ₀]`, `D_Z := σ_Z²·E[Φ₀²]`, and `τ = D_Z / D_Φ`;
* the **dichotomy** as exact equivalences between `τ ≷ 1` and `D_Z ≷ D_Φ`
  (given the natural positivity of the denominator term `D_Φ > 0`);
* the **scale invariance** of `τ` under common rescaling of the variance
  budget (`D_Φ, D_Z ↦ c·D_Φ, c·D_Z`), as the MIP narrative requires.

All hypotheses (R.89 decomposition, the definitions of `τ`, `D_Φ`, `D_Z`)
enter as explicit real-valued bundle hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace VarianceDominance

/-- **R.94 / R.89 variance decomposition (identity).**

With `D_Φ := Z̄²·Var[Φ₀]` and `D_Z := σ_Z²·E[Φ₀²]`, the variance of `N`
splits into the two leading terms:

    Var[N] = D_Φ + D_Z .

Pure substitution. -/
theorem R_94_variance_decomposition
    (VarN D_Φ D_Z Zbar VarΦ σZ EΦ2 : ℝ)
    (h_DΦ : D_Φ = Zbar ^ 2 * VarΦ)
    (h_DZ : D_Z = σZ ^ 2 * EΦ2)
    (h_R89 : VarN = Zbar ^ 2 * VarΦ + σZ ^ 2 * EΦ2) :
    VarN = D_Φ + D_Z := by
  rw [h_DΦ, h_DZ, h_R89]

/-- **R.94 — `τ` is the ratio of the two variance terms.**

By definition `τ := (σ_Z²·E[Φ₀²]) / (Z̄²·Var[Φ₀]) = D_Z / D_Φ`. -/
theorem R_94_tau_is_ratio
    (τ D_Φ D_Z Zbar VarΦ σZ EΦ2 : ℝ)
    (h_DΦ : D_Φ = Zbar ^ 2 * VarΦ)
    (h_DZ : D_Z = σZ ^ 2 * EΦ2)
    (h_τ : τ = (σZ ^ 2 * EΦ2) / (Zbar ^ 2 * VarΦ)) :
    τ = D_Z / D_Φ := by
  rw [h_τ, h_DΦ, h_DZ]

/-- **R.94 dichotomy (case τ > 1): impedance term dominates.**

When the denominator term `D_Φ > 0`, `τ > 1 ⟺ D_Z > D_Φ`, i.e. the
impedance-heterogeneity term `σ_Z²·E[Φ₀²]` strictly dominates. -/
theorem R_94_dichotomy_tau_gt_one
    (τ D_Φ D_Z : ℝ)
    (h_τ : τ = D_Z / D_Φ) (h_DΦ_pos : 0 < D_Φ) :
    1 < τ ↔ D_Φ < D_Z := by
  rw [h_τ]
  rw [lt_div_iff₀ h_DΦ_pos, one_mul]

/-- **R.94 dichotomy (case τ < 1): difficulty term dominates.**

When `D_Φ > 0`, `τ < 1 ⟺ D_Z < D_Φ`, i.e. the problem-difficulty term
`Z̄²·Var[Φ₀]` strictly dominates. -/
theorem R_94_dichotomy_tau_lt_one
    (τ D_Φ D_Z : ℝ)
    (h_τ : τ = D_Z / D_Φ) (h_DΦ_pos : 0 < D_Φ) :
    τ < 1 ↔ D_Z < D_Φ := by
  rw [h_τ]
  rw [div_lt_one h_DΦ_pos]

/-- **R.94 dichotomy (case τ = 1): equal marginal returns.**

When `D_Φ > 0`, `τ = 1 ⟺ D_Z = D_Φ` (the two variance terms are equal). -/
theorem R_94_dichotomy_tau_eq_one
    (τ D_Φ D_Z : ℝ)
    (h_τ : τ = D_Z / D_Φ) (h_DΦ_pos : 0 < D_Φ) :
    τ = 1 ↔ D_Z = D_Φ := by
  rw [h_τ]
  rw [div_eq_one_iff_eq (ne_of_gt h_DΦ_pos)]

/-- **R.94 — trichotomy (totality of the phase classification).**

Exactly one of the three regimes holds: `τ < 1`, `τ = 1`, or `1 < τ`.
This is the "two-dimensional phase diagram is exhaustive" claim. -/
theorem R_94_trichotomy (τ : ℝ) :
    τ < 1 ∨ τ = 1 ∨ 1 < τ := lt_trichotomy τ 1

/-- **R.94 — scale invariance of `τ` under common rescaling.**

If both variance terms are scaled by a common positive factor `c`
(`D_Φ ↦ c·D_Φ`, `D_Z ↦ c·D_Z`), the criterion `τ = D_Z / D_Φ` is
unchanged.  This is the "τ is scale-invariant" property the MIP
narrative relies on (the phase classification does not depend on the
absolute variance budget). -/
theorem R_94_tau_scale_invariant
    (D_Φ D_Z c : ℝ) (h_c_ne : c ≠ 0) :
    (c * D_Z) / (c * D_Φ) = D_Z / D_Φ := by
  rw [mul_div_mul_left D_Z D_Φ h_c_ne]

/-- **R.94 — scale-invariance corollary (dichotomy verdict preserved).**

Under common positive rescaling, the strict dominance comparison
`D_Φ < D_Z` (equivalently `τ > 1`) is preserved.  Hence the phase
verdict is invariant under rescaling of the variance budget. -/
theorem R_94_verdict_scale_invariant
    (D_Φ D_Z c : ℝ) (h_c_pos : 0 < c) :
    D_Φ < D_Z ↔ c * D_Φ < c * D_Z :=
  (mul_lt_mul_iff_of_pos_left h_c_pos).symm

end VarianceDominance

end MIP
