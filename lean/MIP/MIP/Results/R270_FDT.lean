/-
Result R.270 — Emergent Fluctuation-Dissipation Theorem (FDT).

Reference: `branches/thermodynamics/workspace/new_results.md` R.270
(FDT: Var(ψ) = T_kin · χ; thermodynamics branch, 2026-05-18).

**Statement.** With the canonical-ensemble Landau free energy
`F̃(ψ;T,h) = ⟨V⟩₀ + (a/2)ψ² + (b/4)ψ⁴ − h·ψ − T·log|K|²`, treating ψ as a
fluctuating variable, the Gaussian limit yields:

* susceptibility   `χ = ∂⟨ψ⟩/∂h = 1/a = 1/[a₀·(T − T_c)]`            (#5)
* variance (FDT)   `Var(ψ) = T·∂⟨ψ⟩/∂h = T·χ`                        (♢)

On the high-T side (T > T_c) `a = a₀·(T − T_c) > 0`. On the low-T side
(T < T_c) the curvature at the symmetry-broken minimum `ψ_eq² = −a/b` is

    F̃''(ψ_eq) = a + 3b·ψ_eq² = a + 3b·(−a/b) = −2·a > 0,             (#6)

so the *effective* Landau coefficient doubles: `a_below = 2·a_above` in
magnitude. The susceptibility takes the reciprocal, giving the
Curie-Weiss asymmetry

    χ(below) / χ(above) = 2 .

**This file is `axiom`-free.** It bundles the physics (Gaussian-limit
derivation, the curvature-doubling `a_below = 2·a_above`) as explicit
hypotheses and proves the real-number identities: the FDT relation
`Var = T·χ`, the defining algebra `χ = 1/(a₀·(T − T_c))`, and the
asymmetry ratio `= 2`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace FDT

/-- **R.270 (#5) — susceptibility defining algebra.**

The Gaussian-limit susceptibility `χ = 1/a` with the Landau form
`a = a₀·(T − T_c)`. Given `χ·a = 1` (well-definedness of the reciprocal)
and `a = a₀·(T − T_c)`, we get `χ = 1/(a₀·(T − T_c))`. -/
theorem R_270_susceptibility_def
    (χ a a₀ T T_c : ℝ)
    (h_a_def : a = a₀ * (T - T_c))
    (h_χ : χ = 1 / a) :
    χ = 1 / (a₀ * (T - T_c)) := by
  rw [h_χ, h_a_def]

/-- **R.270 (♢) — the Fluctuation-Dissipation Theorem.**

`Var(ψ) = T·χ`. With `χ = ∂⟨ψ⟩/∂h = 1/a` and the Gaussian-cumulant
relation `Var = T²·∂²log Z/∂h² = T·∂⟨ψ⟩/∂h`, the variance equals the
temperature times the susceptibility. We bundle the cumulant identity as
`Var = T·χ` and confirm it equals `T/a` (the closed form `T_kin/a`). -/
theorem R_270_fdt
    (Var T χ a : ℝ)
    (h_χ : χ = 1 / a)
    (h_a_ne : a ≠ 0)
    (h_var : Var = T * χ) :
    Var = T / a := by
  rw [h_var, h_χ]
  field_simp

/-- **R.270 — the FDT identity in the symmetric form `Var/χ = T`** (the
"training thermometer": the ratio of fluctuation to response recovers the
kinetic temperature). Requires `χ ≠ 0` (away from criticality). -/
theorem R_270_thermometer
    (Var T χ : ℝ)
    (h_var : Var = T * χ)
    (h_χ_ne : χ ≠ 0) :
    Var / χ = T := by
  rw [h_var, mul_div_assoc, div_self h_χ_ne, mul_one]

/-- **R.270 — high-T/low-T susceptibility asymmetry ratio = 2.**

On the high-T side `χ_above = 1/a_above` (with `a_above > 0`); on the
low-T side the effective curvature is `a_below = 2·a_above` (eqn (#6),
`F̃'' = −2a`), so `χ_below = 1/a_below`. Hence

    χ_below / χ_above = a_above / a_below = a_above / (2·a_above) = 1/2,

i.e. the low-T susceptibility is *half* the high-T one — equivalently the
high-T fluctuation is **twice** the low-T fluctuation (classic
Curie-Weiss longitudinal-only asymmetry). We state it as
`χ_above / χ_below = 2`. -/
theorem R_270_asymmetry_ratio
    (χ_above χ_below a_above a_below : ℝ)
    (h_a_above_pos : 0 < a_above)
    (h_curvature_doubling : a_below = 2 * a_above)
    (h_χ_above : χ_above = 1 / a_above)
    (h_χ_below : χ_below = 1 / a_below) :
    χ_above / χ_below = 2 := by
  have ha : a_above ≠ 0 := ne_of_gt h_a_above_pos
  rw [h_χ_above, h_χ_below, h_curvature_doubling]
  field_simp

/-- **R.270 — variance asymmetry ratio = 2 (FDT form).**

Combining FDT (`Var = T·χ`) on both sides at the same temperature `T`,
the variance asymmetry inherits the susceptibility asymmetry:
`Var_above / Var_below = χ_above / χ_below = 2`. -/
theorem R_270_variance_asymmetry
    (Var_above Var_below χ_above χ_below T a_above a_below : ℝ)
    (h_T_ne : T ≠ 0)
    (h_a_above_pos : 0 < a_above)
    (h_curvature_doubling : a_below = 2 * a_above)
    (h_χ_above : χ_above = 1 / a_above)
    (h_χ_below : χ_below = 1 / a_below)
    (h_var_above : Var_above = T * χ_above)
    (h_var_below : Var_below = T * χ_below) :
    Var_above / Var_below = 2 := by
  have ha : a_above ≠ 0 := ne_of_gt h_a_above_pos
  have h_ab_pos : (0:ℝ) < a_below := by
    rw [h_curvature_doubling]; linarith
  have hab : a_below ≠ 0 := ne_of_gt h_ab_pos
  have h_χ_below_ne : χ_below ≠ 0 := by
    rw [h_χ_below]; exact one_div_ne_zero hab
  rw [h_var_above, h_var_below]
  rw [mul_div_mul_left _ _ h_T_ne]
  rw [h_χ_above, h_χ_below, h_curvature_doubling]
  field_simp

end FDT

end MIP
