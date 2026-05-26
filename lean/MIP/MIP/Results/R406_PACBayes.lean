/-
Result R.406 — PAC-Bayes generalisation bound as the MIP free-energy +
complexity decomposition.

Reference: `workspace/theory_unification.md` §R.406 ("PAC-Bayes / Bayesian
DL as a KL_MIP generalisation bound", 2026-05-16 theory-unification
batch).

**Statement.** The classical PAC-Bayes bound (McAllester 1999, Catoni
2007, Dziugaite–Roy 2017),

    err  ≤  err_S  +  √( KL(Q‖P) / (2 m) ),

translates in MIP to a free-energy (empirical error) term plus a
complexity term `√(KL_MIP / (2 D))`, where `KL_MIP(A_t ‖ A_0)` is the
post-training-vs-pre-training drift and `D` is the data count (R.406 step
2). The
probabilistic step `err ≤ B` is bundled as the PAC-Bayes hypothesis; this
file proves the **analytic structure of the bound**

    B  :=  err_S  +  √( KL / (2 m) )

namely:

1. `errS_le_bound` — `err_S ≤ B` (the bound never undercuts empirical
   error; the complexity term is nonnegative).
2. `bound_mono_KL` — `B` is monotone *increasing* in `KL` (more drift /
   model complexity ⟹ looser bound).
3. `bound_antitone_m` — `B` is monotone *decreasing* in `m` (more data ⟹
   tighter bound), for `0 < m`.
4. `bound_nonneg` — `0 ≤ B` when `0 ≤ err_S`.
5. `tendsto_bound_errS` — `B → err_S` as `m → ∞` (`Filter.Tendsto`): in
   the infinite-data limit the complexity term vanishes and the bound
   collapses onto empirical error.

`err_S ≥ 0`, `KL ≥ 0`, `m > 0` and the probabilistic `err ≤ B` step enter
as explicit hypotheses; the file encodes only the real-analytic kernel of
the bound `B`.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

open Real Filter Topology

namespace PACBayes

/-- **The PAC-Bayes bound** `B(err_S, KL, m) := err_S + √(KL / (2 m))`.

`err_S` is the empirical (training) error / MIP free-energy term, `KL` is
the posterior-vs-prior divergence (MIP `KL_MIP(A_t ‖ A_0)`), and `m` is
the sample count (MIP data count `D`). -/
noncomputable def bound (errS KL m : ℝ) : ℝ :=
  errS + Real.sqrt (KL / (2 * m))

/-- **R.406 (1) — the bound dominates empirical error: `err_S ≤ B`.**

The complexity term `√(KL / (2m)) ≥ 0` is added on top of `err_S`, so the
PAC-Bayes bound can never fall below the empirical error. -/
theorem errS_le_bound (errS KL m : ℝ) : errS ≤ bound errS KL m := by
  unfold bound
  have h := Real.sqrt_nonneg (KL / (2 * m))
  linarith

/-- **R.406 — full PAC-Bayes inequality (probabilistic step bundled).**

Given the PAC-Bayes probabilistic guarantee `err ≤ B`, the true error is
sandwiched between empirical error and the bound:
`err_S ≤ B` and `err ≤ B`. -/
theorem pac_bayes_sandwich (err errS KL m : ℝ)
    (hPB : err ≤ bound errS KL m) :
    errS ≤ bound errS KL m ∧ err ≤ bound errS KL m :=
  ⟨errS_le_bound errS KL m, hPB⟩

/-- **R.406 (2) — monotone increasing in `KL`.**

With `m` fixed and positive, a larger divergence `KL` (more model
complexity / training drift) gives a larger bound: the bound is *looser*. -/
theorem bound_mono_KL (errS m : ℝ) (hm : 0 < m) {KL₁ KL₂ : ℝ}
    (hKL : KL₁ ≤ KL₂) :
    bound errS KL₁ m ≤ bound errS KL₂ m := by
  unfold bound
  have h2m : (0:ℝ) ≤ 2 * m := by positivity
  have hdiv : KL₁ / (2 * m) ≤ KL₂ / (2 * m) :=
    div_le_div_of_nonneg_right hKL h2m
  have hsqrt : Real.sqrt (KL₁ / (2 * m)) ≤ Real.sqrt (KL₂ / (2 * m)) :=
    Real.sqrt_le_sqrt hdiv
  linarith

/-- **R.406 (3) — monotone decreasing in `m` (more data ⟹ tighter).**

With `KL ≥ 0` fixed, increasing the sample count `m` (MIP data count `D`)
can only shrink the complexity term, so the bound is *antitone* in `m`:
more data gives a tighter generalisation guarantee. -/
theorem bound_antitone_m (errS KL : ℝ) (hKL : 0 ≤ KL) {m₁ m₂ : ℝ}
    (hm₁ : 0 < m₁) (hm : m₁ ≤ m₂) :
    bound errS KL m₂ ≤ bound errS KL m₁ := by
  unfold bound
  have hm₂ : 0 < m₂ := lt_of_lt_of_le hm₁ hm
  have h2m₁ : (0:ℝ) < 2 * m₁ := by positivity
  have h2m₂ : (0:ℝ) < 2 * m₂ := by positivity
  -- larger denominator ⟹ smaller quotient (numerator KL ≥ 0)
  have hden : 2 * m₁ ≤ 2 * m₂ := by linarith
  have hdiv : KL / (2 * m₂) ≤ KL / (2 * m₁) :=
    div_le_div_of_nonneg_left hKL h2m₁ hden
  have hsqrt : Real.sqrt (KL / (2 * m₂)) ≤ Real.sqrt (KL / (2 * m₁)) :=
    Real.sqrt_le_sqrt hdiv
  linarith

/-- **R.406 (4) — nonnegativity of the bound.** When `err_S ≥ 0` (errors
are nonnegative) the bound is nonnegative. -/
theorem bound_nonneg (errS KL m : ℝ) (hS : 0 ≤ errS) : 0 ≤ bound errS KL m := by
  unfold bound
  have h := Real.sqrt_nonneg (KL / (2 * m))
  linarith

/-- **R.406 (5) — `B → err_S` as `m → ∞`.**

In the infinite-data limit the complexity term `√(KL / (2m))` vanishes and
the PAC-Bayes bound collapses onto the empirical error `err_S`. Proof:
`KL / (2m) → 0`, `√·` is continuous at `0` with `√0 = 0`, so the term
tends to `0`, and adding the constant `err_S` gives the limit. -/
theorem tendsto_bound_errS (errS KL : ℝ) :
    Tendsto (fun m : ℝ => bound errS KL m) atTop (nhds errS) := by
  -- the argument of the square root: KL / (2 * m) → 0
  have hden : Tendsto (fun m : ℝ => 2 * m) atTop atTop :=
    Filter.Tendsto.const_mul_atTop (by norm_num) tendsto_id
  have harg : Tendsto (fun m : ℝ => KL / (2 * m)) atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hden
  -- √· continuous, √0 = 0, so √(KL/(2m)) → 0
  have hsqrt0 : Real.sqrt 0 = 0 := Real.sqrt_zero
  have hcomp : Tendsto (fun m : ℝ => Real.sqrt (KL / (2 * m))) atTop (nhds 0) := by
    have hc : Tendsto Real.sqrt (nhds 0) (nhds (Real.sqrt 0)) :=
      (Real.continuous_sqrt.tendsto 0)
    rw [hsqrt0] at hc
    exact hc.comp harg
  -- add the constant err_S
  have : Tendsto (fun m : ℝ => errS + Real.sqrt (KL / (2 * m))) atTop
      (nhds (errS + 0)) :=
    tendsto_const_nhds.add hcomp
  simpa [bound] using this

end PACBayes

end MIP
