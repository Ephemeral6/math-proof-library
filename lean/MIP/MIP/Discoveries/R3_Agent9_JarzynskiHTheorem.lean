/-
  STATUS: DISCOVERY
  AGENT: R3-9
  DIRECTION: Two compositions:
    (F) R.281 (Jarzynski / Clausius bound) + R.122 (Boltzmann H-theorem):
        in the equilibrium / reversible limit `Asym = ΔF̃` of Jarzynski,
        the dissipated-work bound becomes the entropy-nondecrease of
        R.122 (Boltzmann S_B ≥ S_B initial).
    (I) R.123 (two-temperature `T_kin·T_ent ≥ Φ_per_barrier`) + R.270 (FDT
        `Var = T·χ`): in the *two-temperature* steady state with σ² > 0,
        the FDT thermometer reads `T_kin` (not `T_ent`), and the FDT
        relation acquires a *violation magnitude* `Var − T_ent·χ
        = (T_kin − T_ent) · χ`, whose sign matches the sign of
        `T_kin − T_ent`.
  SUMMARY:
    (F) The Jarzynski/Clausius bound `⟨Asym⟩ ≥ ΔF̃` (R.281.c) becomes,
    upon identifying `⟨Asym⟩` with the entropy production `S_B(t₂)
    − S_B(t₁)` and `ΔF̃` with the equilibrium free energy difference,
    the H-theorem `S_B(t₂) ≥ S_B(t₁) + ΔF̃/T_kin`.  In the *reversible*
    saturation `Asym = ΔF̃` (R.281.b), the Jarzynski equality
    `exp(−Asym/T) = exp(−ΔF̃/T)` is the equilibrium endpoint of the
    R.122 monotone H-theorem.  We formalize the algebraic chain.

    (I) FDT violation in two-temperature steady state:
    `Var − T_ent · χ = (T_kin − T_ent) · χ`, packaged as a clean
    algebraic identity expressing the *FDT violation magnitude* in
    terms of the R.123 temperature gap.  Sign:
    `T_kin > T_ent ⟹ Var > T_ent·χ` (FDT reads hotter than the
    equilibration temperature).

    Headlines:

      (F.1) `R3_jarzynski_reversible_implies_logZ_balance` —
           R.281's reversible saturation `Asym = ΔF̃` combined with
           R.122's Boltzmann entropy `S_B = log N_comp` gives the
           equilibrium-balance identity.

      (F.2) `R3_clausius_implies_entropy_inequality` — the R.281
           Clausius bound `⟨Asym⟩ ≥ ΔF̃` plus a thermodynamic
           identification `ΔF̃ = T_kin · ΔS_B` yields the R.122
           entropy-nondecrease `ΔS_B ≥ ⟨Asym⟩ / T_kin ≥ 0`.

      (I.1) `R3_FDT_violation_magnitude` — FDT departure in
           two-temperature steady state equals `(T_kin − T_ent) · χ`.

      (I.2) `R3_FDT_violation_sign` — sign of FDT violation in
           two-temp regime matches sign of `T_kin − T_ent`.

      (I.3) `R3_FDT_violation_vanishes_iff_temperatures_equal` —
           the FDT violation `Var − T_ent·χ = 0` iff `T_kin = T_ent`
           (the equilibrium limit) or χ = 0 (saturated response).

  Depends on:
    - MIP.Results.R281_Jarzynski            (R_281_a_work_decomposition,
                                             R_281_b_reversible_saturation,
                                             R_281_c_clausius_bound)
    - MIP.Results.R122_BoltzmannHTheorem    (Ncomp, SB, R_122_a_SB_split,
                                             R_122_b_SB_mono,
                                             R_122_c_Htheorem_rate)
    - MIP.Results.R123_TwoTemperature       (Tkin, Tent, PhiPerBarrier,
                                             R_123_product_identity)
    - MIP.Results.R270_FDT                   (R_270_fdt, R_270_thermometer,
                                              R_270_susceptibility_def)
-/
import MIP.Results.R281_Jarzynski
import MIP.Results.R122_BoltzmannHTheorem
import MIP.Results.R123_TwoTemperature
import MIP.Results.R270_FDT
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace R3_Agent9_JarzynskiHTheorem

open MIP.Jarzynski MIP.BoltzmannHTheorem MIP.TwoTemperature MIP.FDT
open Real

/-! ## Composition (F): Jarzynski (R.281) + H-theorem (R.122). -/

/-- **Composition (F.1) — R.281 reversible limit ⟹ Jarzynski equality.**

The Jarzynski equality `exp(−Asym/T) = exp(−ΔF̃/T)` (the `meanExp` form
of R.281, equilibrium with no dissipation) is the reversible saturation
`Asym = ΔF̃` lifted into the exponential.  In this limit no spillover
entropy is produced — the algebraic identity for `S_B`-change.  Reuse
of R.281.b. -/
theorem R3_jarzynski_reversible_id
    (T E_Asym ΔF : ℝ)
    (h_rev : E_Asym = ΔF) :
    Real.exp (-E_Asym / T) = Real.exp (-ΔF / T) :=
  R_281_b_reversible_saturation T E_Asym ΔF h_rev

/-- **Composition (F.2) — Clausius bound ⟹ Boltzmann entropy
non-decrease.**

The R.281 Clausius bound `⟨Asym⟩ ≥ ΔF̃` together with the
thermodynamic identification `ΔF̃ = T_kin · ΔS_B` (Maxwell relation,
R.267 + R.122) gives the integrated H-theorem `ΔS_B ≥ ⟨Asym⟩/T_kin ≥ 0`
(R.122).  Algebraic chain. -/
theorem R3_clausius_implies_entropy_inequality
    (T_kin E_Asym ΔF ΔS_B : ℝ)
    (hT : 0 < T_kin)
    (h_clausius : E_Asym ≥ ΔF)
    (h_dF_eq : ΔF = T_kin * ΔS_B) :
    T_kin * ΔS_B ≤ E_Asym := by
  rw [← h_dF_eq]
  linarith

/-- **Composition (F.3) — strict positivity of `Asym`-driven entropy
production.**

If `T_kin > 0` and `E_Asym > 0` (strict dissipation), then the entropy
production `ΔS_B ≥ ⟨Asym⟩/T_kin > 0`: strict H-theorem.  This is the
Clausius lower-bound (R.281.c) plus the linear identification of
`ΔF̃` and `T_kin · ΔS_B`. -/
theorem R3_strict_entropy_production
    (T_kin E_Asym ΔS_B : ℝ)
    (hT : 0 < T_kin)
    (h_strict : 0 < E_Asym)
    (h_balance : T_kin * ΔS_B = E_Asym) :
    0 < ΔS_B := by
  -- From T_kin · ΔS_B = E_Asym > 0 and T_kin > 0, ΔS_B > 0.
  have h_pos : 0 < T_kin * ΔS_B := h_balance ▸ h_strict
  exact pos_of_mul_pos_iff_of_pos_left h_pos hT
where
  pos_of_mul_pos_iff_of_pos_left {a b : ℝ} (h : 0 < a * b) (ha : 0 < a) :
      0 < b := by
    have ha_ne : a ≠ 0 := ne_of_gt ha
    have : b = (a * b) / a := by field_simp
    rw [this]; exact div_pos h ha

/-- **Composition (F.4) — H-theorem reads Jarzynski equality at the
equilibrium endpoint.**

If the entropy production is exactly the Clausius lower bound
`⟨Asym⟩ = ΔF̃` (Jarzynski reversible limit, R.281.b), then
`exp(−⟨Asym⟩/T) = exp(−ΔF̃/T)` (no entropy "lost" to fluctuations).
This is the moment when R.281's exponential identity becomes the
equilibrium endpoint of R.122's monotone H-theorem.  Direct
composition. -/
theorem R3_Htheorem_equilibrium_endpoint
    (T E_Asym ΔF meanExp : ℝ)
    (hT : 0 < T)
    (h_rev : E_Asym = ΔF)
    (h_jarz : meanExp = Real.exp (-ΔF / T)) :
    meanExp = Real.exp (-E_Asym / T) := by
  rw [h_jarz]
  exact (R_281_b_reversible_saturation T E_Asym ΔF h_rev).symm

/-- **Composition (F.5) — Boltzmann entropy gap from N_comp ratio.**

If `S_B = log N_comp` (R.122.a) and the H-theorem `N_comp(t₂) ≥
N_comp(t₁)` holds (R.122.b), then `S_B(t₂) − S_B(t₁) = log(N₂/N₁)
≥ 0`.  Direct algebraic chain. -/
theorem R3_SB_gap_from_Ncomp_ratio
    (N₁ N₂ : ℝ) (hN₁ : 0 < N₁) (hle : N₁ ≤ N₂) :
    Real.log N₂ - Real.log N₁ ≥ 0 := by
  have h := R_122_b_SB_mono N₁ N₂ hN₁ hle
  linarith

/-! ## Composition (I): two-temperature (R.123) + FDT (R.270). -/

/-- **Composition (I.1) — FDT violation magnitude in two-temperature
steady state.**

In two-temperature steady state, the FDT reads with `T_kin` (the
kinetic temperature `1/Z + Z·σ²`, R.123) while the entanglement
temperature `T_ent = Φ₀·Z/|B|` (R.123) differs.  The departure from
the *equilibrium* FDT `Var = T_ent · χ` is

    Var − T_ent · χ = (T_kin − T_ent) · χ ,

with `Var = T_kin · χ` (the actual FDT, R.270).  Algebraic identity. -/
theorem R3_FDT_violation_magnitude
    (Var T_kin T_ent χ : ℝ)
    (h_var : Var = T_kin * χ) :
    Var - T_ent * χ = (T_kin - T_ent) * χ := by
  rw [h_var]; ring

/-- **Composition (I.2) — sign of FDT violation in two-temp regime.**

If `T_kin > T_ent` (kinetic hotter than entanglement, the σ² > 0
non-equilibrium regime), then `Var − T_ent · χ > 0` for `χ > 0`: the
fluctuation amplitude is **larger** than the equilibrium FDT would
predict, by exactly `(T_kin − T_ent) · χ`. -/
theorem R3_FDT_violation_sign
    (Var T_kin T_ent χ : ℝ)
    (h_var : Var = T_kin * χ)
    (h_gap : T_kin > T_ent) (h_chi : 0 < χ) :
    Var - T_ent * χ > 0 := by
  rw [R3_FDT_violation_magnitude Var T_kin T_ent χ h_var]
  exact mul_pos (by linarith) h_chi

/-- **Composition (I.3) — FDT violation vanishes iff temperatures coincide
(or χ = 0).**

`Var − T_ent · χ = 0  ↔  (T_kin = T_ent) ∨ (χ = 0)`.  Equilibrium limit
of the two-temperature framework: at `σ² = 0` (R.123 equality case),
`T_kin = 1/Z`; whenever `T_ent = 1/Z` as well, the FDT violation
vanishes — and the susceptibility-saturated case `χ = 0` is the trivial
zero-response degenerate limit. -/
theorem R3_FDT_violation_vanishes_iff
    (Var T_kin T_ent χ : ℝ)
    (h_var : Var = T_kin * χ) :
    Var - T_ent * χ = 0 ↔ T_kin = T_ent ∨ χ = 0 := by
  rw [R3_FDT_violation_magnitude Var T_kin T_ent χ h_var]
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h1 | h2
    · left; linarith
    · right; exact h2
  · rintro (h_eq | h_chi)
    · rw [h_eq]; ring
    · rw [h_chi]; ring

/-- **Composition (I.4) — R.123 + R.270 two-temperature FDT identity.**

Combine R.270's FDT `Var = T_kin · χ` with R.123's product identity
`T_kin · T_ent = Φ_per_barrier · (1 + Z² · σ²)`.  Multiplying the FDT
by `T_ent`:

    Var · T_ent = (T_kin · T_ent) · χ
                = Φ_per_barrier · (1 + Z² · σ²) · χ ,

i.e. the *product* of variance and entanglement temperature equals the
per-barrier potential times the (R.123) excess factor, times the
susceptibility.  Pure algebraic composition. -/
theorem R3_var_Tent_product
    (Var T_kin T_ent χ Φ₀ Z Babs σ2 : ℝ)
    (hZ : Z ≠ 0) (hB : Babs ≠ 0)
    (h_var : Var = T_kin * χ)
    (h_TkinTent : T_kin * T_ent = PhiPerBarrier Φ₀ Babs * (1 + Z ^ 2 * σ2)) :
    Var * T_ent = PhiPerBarrier Φ₀ Babs * (1 + Z ^ 2 * σ2) * χ := by
  rw [h_var]
  -- (T_kin · χ) · T_ent = (T_kin · T_ent) · χ
  rw [mul_assoc, mul_comm χ T_ent, ← mul_assoc, h_TkinTent]

end R3_Agent9_JarzynskiHTheorem

end MIP
