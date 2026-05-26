/-
Result R-SUB.11 — Reciprocal relation between subdomain attention π_i
and subdomain free energy F_i.

Reference: `workspace/subdomain_competition.md` §6.11 (B 条件).

**Statement.** Under a `κ_r`-independence approximation, the subdomain
free energy is bounded below by a logarithmic function of the attention
share `π_i` and the subdomain size `|K_i|`:

    F_i(X, p)  ≳  r_i(p) · log(|K_i(X)| / π_i),

where `r_i(p) = min_{R ∈ ℛ_i(p)} |R| ≥ 0`, `0 < π_i ≤ 1`, and
`|K_i| ≥ 1`.

The `κ_r`-independence step that produces the bound
`F_i ≥ r_i · log(|K_i|/π_i)` is opaque at the MIP-axiom level, so we
take that *reduction* as a hypothesis and formalize its **algebraic /
monotone consequences**:

* the lower bound itself, `F_i ≥ r_i · log(|K_i|/π_i)`, follows
  immediately from the hypothesis (a definitional repackaging);
* the bound functional `g(π) := r · log(|K_i|/π)` is **strictly
  decreasing in π** on `(0, ∞)` whenever `r > 0` — this is the precise
  "reciprocal" content: shrinking the attention share π_i forces a
  *larger* free-energy lower bound;
* `g` is **nonnegative** when `π ≤ |K_i|` (in particular when
  `0 < π ≤ 1 ≤ |K_i|`), so the bound is informative.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

namespace MIP

open Real

namespace ReciprocalFreeEnergy

/-- The free-energy lower-bound functional
`g(π) := r · log(Kcard / π)` arising from the `κ_r`-independence
approximation of R-SUB.11. -/
noncomputable def bound (r Kcard π : ℝ) : ℝ := r * Real.log (Kcard / π)

/-- **R-SUB.11 lower bound (repackaging of the reduction hypothesis).**

Taking the `κ_r`-independence reduction `F_i ≥ r_i · log(|K_i|/π_i)` as
a hypothesis, the free-energy lower bound holds verbatim. -/
theorem R_SUB_11_lower_bound
    (F r Kcard π : ℝ)
    (hreduction : F ≥ r * Real.log (Kcard / π)) :
    F ≥ bound r Kcard π := by
  unfold bound
  exact hreduction

/-- **Reciprocal monotonicity (strict).** With a positive minimal path
length `r > 0`, subdomain size `Kcard > 0`, the bound functional
`g(π) = r · log(Kcard / π)` is **strictly antitone** in `π` on the
positive reals: a smaller attention share `π` yields a strictly larger
free-energy lower bound.

This is the precise "reciprocal" content of R-SUB.11. -/
theorem bound_strictAntitone
    (r Kcard : ℝ) (hr : 0 < r) (hK : 0 < Kcard) :
    StrictAntiOn (bound r Kcard) (Set.Ioi (0 : ℝ)) := by
  intro a ha b hb hab
  simp only [Set.mem_Ioi] at ha hb
  unfold bound
  -- log (K/b) < log (K/a)  since  K/b < K/a  (a < b, both positive).
  have hlt : Kcard / b < Kcard / a := by
    apply div_lt_div_of_pos_left hK ha hab
  have hloglt : Real.log (Kcard / b) < Real.log (Kcard / a) :=
    Real.log_lt_log (by positivity) hlt
  exact mul_lt_mul_of_pos_left hloglt hr

/-- **Quantitative reciprocal gap.** For `0 < a < b` and `r ≥ 0`,
halving the attention share from `b` down to `a` increases the lower
bound by exactly `r · log(b/a) ≥ 0`. -/
theorem bound_gap
    (r Kcard a b : ℝ) (hK : 0 < Kcard) (ha : 0 < a) (hb : 0 < b) :
    bound r Kcard a - bound r Kcard b = r * Real.log (b / a) := by
  unfold bound
  rw [← mul_sub]
  congr 1
  rw [← Real.log_div (by positivity) (by positivity)]
  congr 1
  field_simp

/-- The reciprocal gap is **nonnegative** when the share decreases
(`a ≤ b`) and `r ≥ 0`: shrinking attention never lowers the free-energy
floor. -/
theorem bound_gap_nonneg
    (r Kcard a b : ℝ) (hr : 0 ≤ r) (hK : 0 < Kcard)
    (ha : 0 < a) (hb : 0 < b) (hab : a ≤ b) :
    0 ≤ bound r Kcard a - bound r Kcard b := by
  rw [bound_gap r Kcard a b hK ha hb]
  apply mul_nonneg hr
  apply Real.log_nonneg
  rw [le_div_iff₀ ha]
  linarith

/-- **Informativeness / nonnegativity of the bound.** When the
attention share does not exceed the subdomain size (`0 < π ≤ Kcard`) and
`r ≥ 0`, the lower bound is itself nonnegative — in particular this holds
in the MIP regime `0 < π ≤ 1 ≤ Kcard`. -/
theorem bound_nonneg
    (r Kcard π : ℝ) (hr : 0 ≤ r) (hπ : 0 < π) (hle : π ≤ Kcard) :
    0 ≤ bound r Kcard π := by
  unfold bound
  apply mul_nonneg hr
  apply Real.log_nonneg
  rw [le_div_iff₀ hπ]
  linarith

end ReciprocalFreeEnergy

end MIP
