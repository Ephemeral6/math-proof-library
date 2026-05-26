/-
Result R.278 — Arrhenius bound for the catastrophic-forgetting rate.

Reference: `branches/thermodynamics/workspace/new_results.md` R.278 (B,
2026-05-18 thermodynamics branch): the probabilistic relaxation (TM_ε) of
the training-monotonicity operator, with cumulative breakdown rate

    δ_N ≤ N · exp(−Φ_protect / T_kin)                              (#2)

an Arrhenius-type catastrophic-forgetting rate, together with the
almost-monotone H-theorem `dS_B/dt ≥ −γ(ε)` (◆').

**Statement.** Define the Arrhenius forgetting bound

    δ_N(N, Φ, T) := N · exp(−Φ / T) .

We formalize the BOUND properties of this real-valued function:

* (a) **Range.** For `N ≥ 0`, `Φ ≥ 0`, `T > 0` we have `0 ≤ δ_N ≤ N`
  (the cumulative breakdown probability is non-negative and never exceeds
  the trivial union bound `N`).
* (b) **Monotone in protection.** As a function of the protection barrier
  `Φ`, `δ_N` is `StrictAnti` (strictly decreasing) for fixed `N > 0`,
  `T > 0`: more protection ⟹ strictly less forgetting.
* (c) **Derivative.** `d δ_N / dΦ = −(N/T)·exp(−Φ/T) ≤ 0`, the explicit
  negative-slope witness of (b).
* (d) **Almost-monotone H-theorem core.** The bundled (◆') hypothesis
  `S₂ − S₁ ≥ −γ` is exactly `S₂ ≥ S₁ − γ`; with `γ ≥ 0` small this is the
  probabilistic relaxation of `dS_B/dt ≥ 0`.

The physics of (TM_ε), R.122 entropy, and the Boltzmann form of `β_e`
enters only through the explicit functional form of `δ_N`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace ArrheniusForgetting

open Real

/-- The Arrhenius catastrophic-forgetting bound
`δ_N(N, Φ, T) = N · exp(−Φ / T)` (R.278 #2). -/
noncomputable def deltaN (N Φ T : ℝ) : ℝ :=
  N * Real.exp (-Φ / T)

/-- **R.278.a — non-negativity of the forgetting bound.**

For `N ≥ 0`, the bound `δ_N = N·exp(−Φ/T)` is non-negative, since the
exponential is always positive. -/
theorem R_278_a_nonneg
    (N Φ T : ℝ) (hN : 0 ≤ N) :
    0 ≤ deltaN N Φ T := by
  unfold deltaN
  exact mul_nonneg hN (le_of_lt (Real.exp_pos _))

/-- **R.278.a — upper bound by the trivial union bound `N`.**

For `N ≥ 0`, `Φ ≥ 0`, `T > 0`, the protection factor `exp(−Φ/T) ≤ 1`
(because `−Φ/T ≤ 0`), so `δ_N ≤ N`. The cumulative breakdown probability
never exceeds the naive `N · max_e β_e` union bound at full breakdown. -/
theorem R_278_a_le_N
    (N Φ T : ℝ) (hN : 0 ≤ N) (hΦ : 0 ≤ Φ) (hT : 0 < T) :
    deltaN N Φ T ≤ N := by
  unfold deltaN
  -- exp(−Φ/T) ≤ 1 since the argument −Φ/T ≤ 0.
  have h_arg : -Φ / T ≤ 0 := by
    rw [div_nonpos_iff]
    right
    exact ⟨by linarith, le_of_lt hT⟩
  have h_exp_le_one : Real.exp (-Φ / T) ≤ 1 := by
    calc Real.exp (-Φ / T) ≤ Real.exp 0 := Real.exp_le_exp.mpr h_arg
      _ = 1 := Real.exp_zero
  calc N * Real.exp (-Φ / T) ≤ N * 1 :=
        mul_le_mul_of_nonneg_left h_exp_le_one hN
    _ = N := by ring

/-- **R.278.a — full range statement `0 ≤ δ_N ≤ N`.** -/
theorem R_278_a_range
    (N Φ T : ℝ) (hN : 0 ≤ N) (hΦ : 0 ≤ Φ) (hT : 0 < T) :
    0 ≤ deltaN N Φ T ∧ deltaN N Φ T ≤ N :=
  ⟨R_278_a_nonneg N Φ T hN, R_278_a_le_N N Φ T hN hΦ hT⟩

/-- **R.278.b — strict monotone decrease in the protection barrier.**

For fixed `N > 0`, `T > 0`, the forgetting bound `Φ ↦ N·exp(−Φ/T)` is
`StrictAnti`: a larger protection barrier `Φ` strictly reduces the
catastrophic-forgetting probability. This is the Arrhenius "higher barrier
⟹ exponentially less escape" law. -/
theorem R_278_b_strictAnti_in_protection
    (N T : ℝ) (hN : 0 < N) (hT : 0 < T) :
    StrictAnti (fun Φ => deltaN N Φ T) := by
  intro Φ₁ Φ₂ h12
  unfold deltaN
  -- Want: N·exp(−Φ₂/T) < N·exp(−Φ₁/T).
  apply mul_lt_mul_of_pos_left _ hN
  apply Real.exp_lt_exp.mpr
  -- −Φ₂/T < −Φ₁/T  ⟺  Φ₁ < Φ₂  (since T > 0).
  rw [div_lt_div_iff_of_pos_right hT]
  linarith

/-- **R.278.c — derivative of the forgetting bound in `Φ`.**

`d/dΦ [ N·exp(−Φ/T) ] = −(N/T)·exp(−Φ/T)`. The slope is `≤ 0` for
`N ≥ 0`, `T > 0`, the analytic witness of the `StrictAnti` property. -/
theorem R_278_c_deriv
    (N T : ℝ) (hT : T ≠ 0) (Φ : ℝ) :
    HasDerivAt (fun Φ => deltaN N Φ T)
      (-(N / T) * Real.exp (-Φ / T)) Φ := by
  -- Inner affine map  Φ ↦ −Φ/T  has derivative  −1/T.
  have h_aff : HasDerivAt (fun Φ : ℝ => -Φ / T) (-1 / T) Φ := by
    have h_id : HasDerivAt (fun Φ : ℝ => -Φ) (-1 : ℝ) Φ := by
      simpa using (hasDerivAt_id Φ).neg
    simpa using h_id.div_const T
  -- exp of it:  derivative  exp(−Φ/T) · (−1/T).
  have h_exp : HasDerivAt (fun Φ => Real.exp (-Φ / T))
      (Real.exp (-Φ / T) * (-1 / T)) Φ := h_aff.exp
  -- Multiply by the constant N.
  have h_N := h_exp.const_mul N
  -- Reshape derivative value:  N · (exp · (−1/T)) = −(N/T)·exp.
  unfold deltaN
  convert h_N using 1
  field_simp

/-- **R.278.c — the slope is non-positive.** Direct corollary: for
`N ≥ 0`, `T > 0` the derivative value `−(N/T)·exp(−Φ/T) ≤ 0`. -/
theorem R_278_c_deriv_nonpos
    (N T : ℝ) (hN : 0 ≤ N) (hT : 0 < T) (Φ : ℝ) :
    -(N / T) * Real.exp (-Φ / T) ≤ 0 := by
  have h1 : 0 ≤ N / T := div_nonneg hN (le_of_lt hT)
  have h2 : 0 ≤ Real.exp (-Φ / T) := le_of_lt (Real.exp_pos _)
  nlinarith [h1, h2]

/-- **R.278.d — almost-monotone H-theorem core (◆').**

The probabilistic relaxation of R.122's `dS_B/dt ≥ 0`: under (◆) the
entropy satisfies `S_B(t₂) ≥ S_B(t₁) − γ(ε)`. We record the trivial but
load-bearing equivalence with the difference form `S₂ − S₁ ≥ −γ`, and
note that for `γ ≥ 0` the relaxed bound is implied by exact monotonicity
`S₂ ≥ S₁`. -/
theorem R_278_d_almost_monotone
    (S₁ S₂ γ : ℝ) :
    (S₂ - S₁ ≥ -γ) ↔ (S₂ ≥ S₁ - γ) := by
  constructor <;> intro h <;> linarith

/-- **R.278.d — exact monotonicity ⟹ relaxed monotonicity.**

If the entropy is (strictly/weakly) monotone `S₁ ≤ S₂` and `γ ≥ 0`, then
the relaxed H-theorem `S₂ ≥ S₁ − γ` holds a fortiori. The (TM_0) limit
`γ = 0` recovers exact monotonicity. -/
theorem R_278_d_monotone_implies_relaxed
    (S₁ S₂ γ : ℝ) (h_mono : S₁ ≤ S₂) (hγ : 0 ≤ γ) :
    S₂ ≥ S₁ - γ := by
  linarith

end ArrheniusForgetting

end MIP
