/-
  STATUS: DISCOVERY
  AGENT: R3-9
  DIRECTION: Compose R.270 (FDT `Var = T·χ`, `χ = 1/a`) with R.271
    (correlation length `ξ² = 1/(a₀·ε)`, `a·ξ² = 1`) into a single chain:
    near the critical point, the FDT response `χ` scales as `ξ²` (at the
    mean-field exponent `η = 0`, equivalently `2 − η = 2`).
  SUMMARY:
    R.270's susceptibility satisfies `χ·a = 1` (its defining algebraic
    identity).  R.271's correlation length satisfies `a·ξ² = 1` (the
    L_FDT algebraic kernel).  Equating the two reciprocals gives
    `χ = ξ²` (the mean-field FDT–OZ identity) and hence `Var = T·ξ²`
    (the FDT-fluctuation form expressed *directly* through the
    correlation length, the "thermometer through ξ²" identity).

    More: as ε → 0⁺ the correlation length ξ → ∞ (R.271 critical
    divergence), so the FDT relation forces the variance Var = T·χ
    = T·ξ² → ∞ as well (with `T > 0` fixed): a *fluctuation
    divergence* directly from the FDT chain.

    Headlines:

      (1) `R3_chi_eq_xi_sq` — mean-field FDT–OZ identity: under the
          R.270 χ-algebra and the R.271 ξ-algebra, `χ = ξ²`.

      (2) `R3_FDT_via_xi` — variance from correlation length:
          `Var = T · ξ²` (chains R.270 + R.271).

      (3) `R3_FDT_variance_diverges` — as the reduced temperature
          ε → 0⁺, the variance `Var(ε) = T · ξ(a₀, ε)²` diverges to
          `+∞` (the FDT–OZ critical divergence).

      (4) `R3_thermometer_through_xi` — the R.270 "thermometer"
          `Var/χ = T` reads through `χ = ξ²` as `Var/ξ² = T`: the
          variance per correlation volume *is* the temperature.

  Depends on:
    - MIP.Results.R270_FDT                 (R_270_susceptibility_def,
                                            R_270_fdt, R_270_thermometer)
    - MIP.Results.R271_CorrelationLength   (xi, R_271_xi_sq, R_271_L_FDT,
                                            R_271_critical_divergence)
-/
import MIP.Results.R270_FDT
import MIP.Results.R271_CorrelationLength
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace R3_Agent9_FDTCorrelationScaling

open MIP.FDT MIP.CorrelationLength
open Real Filter Topology

/-- **Composition (B.1) — mean-field FDT–OZ identity `χ = ξ²`.**

R.270 fixes `χ = 1/a` and R.271 fixes `a·ξ² = 1`.  Combining the two
gives `χ = ξ²` (equivalently the scaling χ ~ ξ^{2-η} with η = 0 at
mean-field, R.119).  Requires `a₀·ε > 0` (high-T side, R.271 domain).

Witness: with `a := a₀ · ε`, R.270 gives `χ · a = 1` ⇒ `χ = 1/a`;
R.271 gives `a · ξ² = 1` ⇒ `ξ² = 1/a`.  Hence `χ = ξ²`. -/
theorem R3_chi_eq_xi_sq
    (a₀ ε χ : ℝ) (h_pos : 0 < a₀ * ε)
    (h_χ : χ = 1 / (a₀ * ε)) :
    χ = (xi a₀ ε) ^ 2 := by
  -- R.271 ξ² = 1/(a₀·ε)
  have h_xi_sq : (xi a₀ ε) ^ 2 = 1 / (a₀ * ε) := R_271_xi_sq a₀ ε h_pos
  rw [h_χ, ← h_xi_sq]

/-- **Composition (B.2) — FDT through correlation length `Var = T·ξ²`.**

Combining R.270's FDT `Var = T · χ` with the composed identity
`χ = ξ²` from (B.1) gives the variance directly in terms of the OZ
correlation length:

    Var = T · ξ² .

The fluctuation amplitude reads off the squared correlation length
times temperature — no `a` parameter appears explicitly. -/
theorem R3_FDT_via_xi
    (a₀ ε T χ Var : ℝ) (h_pos : 0 < a₀ * ε)
    (h_χ : χ = 1 / (a₀ * ε))
    (h_var : Var = T * χ) :
    Var = T * (xi a₀ ε) ^ 2 := by
  rw [h_var, R3_chi_eq_xi_sq a₀ ε χ h_pos h_χ]

/-- **Composition (B.3) — thermometer identity through ξ²: `Var/ξ² = T`.**

R.270's thermometer `Var/χ = T` composes with `χ = ξ²` to give
`Var/ξ² = T`: the variance *per correlation volume* recovers the
kinetic temperature.  Requires the χ-form well-defined and ξ² ≠ 0
(away from criticality). -/
theorem R3_thermometer_through_xi
    (a₀ ε T χ Var : ℝ) (h_pos : 0 < a₀ * ε)
    (h_χ : χ = 1 / (a₀ * ε))
    (h_var : Var = T * χ) :
    Var / (xi a₀ ε) ^ 2 = T := by
  -- Substitute Var = T·ξ² and divide.
  have hxi_sq : (xi a₀ ε) ^ 2 = 1 / (a₀ * ε) := R_271_xi_sq a₀ ε h_pos
  have hne : (xi a₀ ε) ^ 2 ≠ 0 := by
    rw [hxi_sq]
    exact one_div_ne_zero (ne_of_gt h_pos)
  rw [R3_FDT_via_xi a₀ ε T χ Var h_pos h_χ h_var]
  rw [mul_div_assoc, div_self hne, mul_one]

/-- **Composition (B.4) — critical divergence of the FDT variance.**

As the reduced temperature ε → 0⁺ (criticality, R.271 divergence), the
correlation length ξ(a₀, ε) → +∞ (R.271).  Composing with the FDT
identity `Var = T·ξ²`, the variance diverges as well: the FDT
fluctuation amplitude blows up at the phase transition, the
microscopic content of "critical fluctuations dominate". -/
theorem R3_FDT_variance_diverges
    (a₀ T : ℝ) (h_a₀_pos : 0 < a₀) (hT : 0 < T) :
    Tendsto (fun ε => T * (xi a₀ ε) ^ 2) (𝓝[>] (0 : ℝ)) atTop := by
  -- ξ(a₀, ε) → +∞ as ε → 0⁺.
  have h_xi : Tendsto (fun ε => xi a₀ ε) (𝓝[>] (0 : ℝ)) atTop :=
    R_271_critical_divergence a₀ h_a₀_pos
  -- ξ² → +∞ since ξ → +∞ (and ξ > 0 eventually).
  have h_xi_sq : Tendsto (fun ε => (xi a₀ ε) ^ 2) (𝓝[>] (0 : ℝ)) atTop := by
    have hsq : Tendsto (fun x : ℝ => x ^ 2) atTop atTop :=
      tendsto_pow_atTop (by norm_num : 2 ≠ 0)
    exact hsq.comp h_xi
  -- Multiply by T > 0:  T·ξ² → +∞.
  exact Filter.Tendsto.const_mul_atTop hT h_xi_sq

/-- **Composition (B.5) — algebraic kernel `(a₀·ε)·Var = T`.**

Combining R.270's `χ = 1/(a₀·ε)` with R.270's FDT `Var = T·χ` and the
R.271 algebra `a·ξ² = 1`:

    `(a₀·ε) · Var  = (a₀·ε) · T/(a₀·ε) = T` ,

equivalently `Var = T/(a₀·ε)`.  The product `(a₀·ε)·Var = T` is the
direct algebraic content of "the variance is the inverse of the
Landau coefficient times the temperature" — the local form of FDT
expressed through R.271's reduced-temperature parameter. -/
theorem R3_a_var_eq_T
    (a₀ ε T χ Var : ℝ) (h_pos : 0 < a₀ * ε)
    (h_χ : χ = 1 / (a₀ * ε))
    (h_var : Var = T * χ) :
    (a₀ * ε) * Var = T := by
  rw [h_var, h_χ]
  have h_ne : a₀ * ε ≠ 0 := ne_of_gt h_pos
  rw [mul_one_div, mul_div_cancel₀ T h_ne]

end R3_Agent9_FDTCorrelationScaling

end MIP
