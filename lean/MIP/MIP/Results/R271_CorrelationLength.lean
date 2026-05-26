/-
Result R.271 — Ornstein-Zernike correlation length and its critical divergence.

Reference: `branches/thermodynamics/workspace/new_results.md` R.271
(correlation function G(r), correlation length ξ ~ |ε|^{-1/2};
thermodynamics branch, 2026-05-18).

**Statement.** From the mean-field (Gaussian) two-point function
`G = T·(−∇² + a)⁻¹` (Helmholtz Green function), the Ornstein-Zernike
form has correlation length

    ξ := 1/√a = 1/√[a₀·(T − T_c)] = a₀^{-1/2}·|ε|^{-1/2},            (♠)

where `ε := (T − T_c)/T_c` is the reduced temperature and `a = a₀·(T−T_c)`.
This gives the mean-field exponent `ν = 1/2` directly. The susceptibility
is the integral of the correlation function (lemma L_FDT):
`χ = ∫ G(r) d^{d_eff} r = G̃(0)/T = 1/a`.

**This file is `axiom`-free.** It bundles the OZ Green-function form as
the definition of ξ and proves:
  (a) the scaling identity `ξ² = 1/(a₀·ε)` (here `ε > 0`, high-T side),
      equivalently `ξ = (a₀·ε)^{-1/2}` via `Real.sqrt`;
  (b) the L_FDT relation `χ = ξ²/... `, concretely `χ = 1/a` and `a = 1/ξ²`,
      i.e. `χ = ξ²` when `a₀ = 1` — stated as `a · ξ² = 1`;
  (c) the **critical divergence**: `Tendsto ξ (nhdsWithin 0 (Ioi 0)) atTop`
      as `ε → 0⁺` (the correlation length diverges at criticality).
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace CorrelationLength

open Real Filter Topology

/-- The Ornstein-Zernike correlation length
`ξ(a₀, ε) = 1/√(a₀·ε) = (a₀·ε)^{-1/2}`, on the high-T side where the
reduced temperature `ε > 0` and `a = a₀·ε > 0`. -/
noncomputable def xi (a₀ ε : ℝ) : ℝ := 1 / Real.sqrt (a₀ * ε)

/-- **R.271 (♠) — scaling identity `ξ² = 1/(a₀·ε)`.**

Squaring the OZ definition `ξ = 1/√(a₀·ε)` with `a₀·ε > 0` gives the
mean-field scaling `ξ² = 1/(a₀·ε)`, i.e. `ν = 1/2`. -/
theorem R_271_xi_sq
    (a₀ ε : ℝ) (h_pos : 0 < a₀ * ε) :
    (xi a₀ ε) ^ 2 = 1 / (a₀ * ε) := by
  unfold xi
  rw [div_pow, one_pow, Real.sq_sqrt (le_of_lt h_pos)]

/-- **R.271 (♠) — ξ as an `rpow`.**

The OZ correlation length equals `(a₀·ε)^(-1/2)` in `Real.rpow` form,
making the exponent `ν = 1/2` explicit. -/
theorem R_271_xi_rpow
    (a₀ ε : ℝ) (h_pos : 0 < a₀ * ε) :
    xi a₀ ε = (a₀ * ε) ^ (-(1 : ℝ) / 2) := by
  unfold xi
  rw [Real.rpow_div_two_eq_sqrt _ (le_of_lt h_pos)]
  rw [Real.rpow_neg_one, one_div]

/-- **R.271 — L_FDT in algebraic form: `a·ξ² = 1`.**

Since `ξ = 1/√a` (with `a = a₀·ε > 0`), we have `a·ξ² = 1`. Combined with
R.270's `χ = 1/a`, this gives `χ = ξ²` (when `a₀` normalised), the local
form of FDT (`χ = ∫G`, lemma L_FDT). -/
theorem R_271_L_FDT
    (a₀ ε : ℝ) (h_pos : 0 < a₀ * ε) :
    (a₀ * ε) * (xi a₀ ε) ^ 2 = 1 := by
  rw [R_271_xi_sq a₀ ε h_pos]
  rw [mul_one_div, div_self (ne_of_gt h_pos)]

/-- **R.271 — critical divergence of the correlation length.**

As the reduced temperature `ε → 0⁺` (criticality), the OZ correlation
length `ξ(a₀, ε) = 1/√(a₀·ε)` diverges to `+∞`, with `a₀ > 0` fixed:

    Tendsto (fun ε => ξ a₀ ε) (𝓝[>] 0) atTop .

This is the direct microscopic statement that correlations become
unbounded at the emergence transition (`ν = 1/2`). -/
theorem R_271_critical_divergence
    (a₀ : ℝ) (h_a₀_pos : 0 < a₀) :
    Tendsto (fun ε => xi a₀ ε) (𝓝[>] (0 : ℝ)) atTop := by
  -- a₀·ε → 0⁺ as ε → 0⁺
  have h_prod : Tendsto (fun ε : ℝ => a₀ * ε) (𝓝[>] (0 : ℝ)) (𝓝[>] (0 : ℝ)) := by
    apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
    · have : Tendsto (fun ε : ℝ => a₀ * ε) (𝓝 (0 : ℝ)) (𝓝 (a₀ * 0)) :=
        (tendsto_const_nhds.mul tendsto_id)
      simpa using this.mono_left nhdsWithin_le_nhds
    · filter_upwards [self_mem_nhdsWithin] with ε hε
      exact mul_pos h_a₀_pos hε
  -- √(a₀·ε) → 0⁺
  have h_sqrt : Tendsto (fun ε : ℝ => Real.sqrt (a₀ * ε)) (𝓝[>] (0 : ℝ)) (𝓝[>] (0 : ℝ)) := by
    apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
    · have h := (Real.continuous_sqrt.tendsto (0 : ℝ)).comp
        (h_prod.mono_right nhdsWithin_le_nhds)
      simpa using h
    · filter_upwards [h_prod self_mem_nhdsWithin] with ε hε
      exact Real.sqrt_pos.mpr hε
  -- 1/√(a₀·ε) → +∞
  have h_inv := tendsto_inv_nhdsGT_zero.comp h_sqrt
  simpa [xi, one_div, Function.comp] using h_inv

end CorrelationLength

end MIP
