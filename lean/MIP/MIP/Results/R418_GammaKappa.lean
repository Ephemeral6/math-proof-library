/-
Result R.418 — γ_κ = β · η  (γ_κ partial resolution of Cj.50).

Reference: `workspace/gamma_kappa_rederivation.md` §5 (candidate R.418,
A-conditional: Heaps + residual-completion (b-IV) + Z slowly varying +
coverage complete).  Resolves the Chinchilla mismatch by routing γ_κ
through the *combinatorial* growth of the composable-pair set rather than
the (incompatible) Gompertz t-dynamics.

**Statement interpretation used.**  Under the four bundled hypotheses
(all entering as explicit assumptions):

* **(a) Heaps**            `|K(t)| = c_K · t^β`,  `β ∈ (0,1)`,
* **(b-IV) residual**      `|K(t)|² − |R∘ ∩ K(t)²| = c_R · |K(t)|^(2−η)`,
                            i.e. `1 − κ(t) = c_R · |K(t)|^(−η)`,  `η ∈ (0,2]`,
* **(c) Z slowly varying** `Z(t) → Z∞`,
* **(d) coverage**         `t > t_cov`,

R.418 derives the closed form

    1 − κ(t)  =  c_R · |K(t)|^(−η)  =  c_R · c_K^(−η) · t^(−β·η),

so the κ-saturation power-law exponent obeys the **algebraic identity**

    γ_κ  =  β · η.

This file formalizes:

* the **chain identity** `γ_κ = β·η` together with the closed-form decay
  `1 − κ(t) = c_R · c_K^(−η) · t^(−γ_κ)` (pure `Real.rpow` substitution);
* the **gap closed form** `1 − κ(t) = c_R · |K(t)|^(−η)` from the (b-IV)
  residual count divided by `|K(t)|²`;
* the **range consequence** `γ_κ ∈ (0,1)` whenever `β,η ∈ (0,1)`
  (the scaling exponent is a genuine sub-linear power);
* **monotonicity in η** (deeper residual decay ⟹ faster saturation) and
  the special values `η = 1 ⟹ γ_κ = β` (Chinchilla match) and
  `η = 2 ⟹ γ_κ = 2β`;
* **monotone saturation**: for `γ_κ > 0`, `1 − κ(t)` is strictly
  decreasing in `t` on `t > 0` (κ → 1).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace GammaKappa

open Real

/-- **R.418 — the γ_κ identity and closed-form κ-gap decay.**

With Heaps `|K(t)| = c_K · t^β` and residual completion
`1 − κ(t) = c_R · |K(t)|^(−η)`, substituting the Heaps form and the
identity `γκ = β·η` yields the data-budget power law

    1 − κ(t)  =  c_R · c_K^(−η) · t^(−γκ),    γκ = β·η.

Pure substitution of the bundled regime equalities (`c_K, t > 0`). -/
theorem R_418_gamma_kappa_identity
    (κgap cR cK t β η γκ : ℝ)
    (h_cK : 0 < cK) (h_t : 0 < t)
    (h_gap : κgap = cR * (cK * t ^ β) ^ (-η))
    (h_γκ : γκ = β * η) :
    κgap = cR * cK ^ (-η) * t ^ (-γκ) := by
  -- Expand (c_K · t^β)^(−η) = c_K^(−η) · (t^β)^(−η) = c_K^(−η) · t^(−β·η).
  rw [h_gap, h_γκ,
      Real.mul_rpow (le_of_lt h_cK) (le_of_lt (Real.rpow_pos_of_pos h_t β)),
      ← Real.rpow_mul (le_of_lt h_t)]
  -- now (t^β)^(−η) became t^(β·(−η)); reconcile with t^(−(β·η)).
  ring_nf

/-- **R.418 — residual-completion gap closed form (b-IV step).**

If the residual (non-composable) pair count is
`|K|² − |R∘ ∩ K²| = c_R · |K|^(2−η)` and `κ = |R∘ ∩ K²| / |K|²`, then
the κ-gap is `1 − κ = c_R · |K|^(−η)` (divide the residual count by the
total pair count `|K|²`). -/
theorem R_418_residual_gap_form
    (Kc Rcap residual cR η : ℝ)
    (h_Kpos : 0 < Kc)
    (_h_residual : residual = Kc ^ 2 - Rcap)
    (h_bIV : residual = cR * Kc ^ (2 - η))
    (κgap : ℝ) (h_gapdef : κgap = residual / Kc ^ 2) :
    κgap = cR * Kc ^ (-η) := by
  rw [h_gapdef, h_bIV]
  -- Convert the integer power Kc² to rpow Kc^(2:ℝ) to combine exponents.
  rw [show (Kc ^ 2 : ℝ) = Kc ^ (2 : ℝ) by
        rw [← Real.rpow_natCast Kc 2]; norm_num]
  -- c_R · Kc^(2−η) / Kc^2 = c_R · Kc^((2−η) − 2) = c_R · Kc^(−η).
  rw [mul_div_assoc, ← Real.rpow_sub h_Kpos]
  ring_nf

/-- **R.418 — scaling exponent lies in `(0,1)`.**

If `β, η ∈ (0,1)` then `γ_κ = β·η ∈ (0,1)`: the κ-saturation exponent is a
genuine strictly-sublinear power, so `1 − κ(t) ~ t^(−γκ)` decays slower
than `1/t` (consistent with the empirically small Chinchilla exponents). -/
theorem R_418_gamma_kappa_in_unit
    (β η γκ : ℝ)
    (h_γκ : γκ = β * η)
    (h_β0 : 0 < β) (h_β1 : β < 1)
    (h_η0 : 0 < η) (h_η1 : η < 1) :
    0 < γκ ∧ γκ < 1 := by
  refine ⟨?_, ?_⟩
  · rw [h_γκ]; positivity
  · rw [h_γκ]
    calc β * η < 1 * 1 := by
          apply mul_lt_mul' (le_of_lt h_β1) h_η1 (le_of_lt h_η0)
          linarith
      _ = 1 := by ring

/-- **R.418 — monotonicity in the residual exponent `η`.**

`γ_κ = β·η` is strictly increasing in `η` for `β > 0`: a deeper residual
decay (larger `η`) ⟹ a larger saturation exponent ⟹ faster `κ → 1`. -/
theorem R_418_gamma_kappa_mono_in_eta
    (β η₁ η₂ : ℝ) (h_β : 0 < β) (h_lt : η₁ < η₂) :
    β * η₁ < β * η₂ :=
  mul_lt_mul_of_pos_left h_lt h_β

/-- **R.418 — special value `η = 1 ⟹ γ_κ = β`** (the Chinchilla match:
with `β ≈ 0.34` this gives `γ_κ ≈ 0.34 ≈ α_D`). -/
theorem R_418_eta_one_gives_beta (β γκ : ℝ) (h_γκ : γκ = β * 1) :
    γκ = β := by rw [h_γκ]; ring

/-- **R.418 — special value `η = 2 ⟹ γ_κ = 2β`** (independent-pairing
"area" decay regime). -/
theorem R_418_eta_two_gives_two_beta (β γκ : ℝ) (h_γκ : γκ = β * 2) :
    γκ = 2 * β := by rw [h_γκ]; ring

/-- **R.418 — monotone saturation in the data budget.**

For `γ_κ > 0` and `c > 0`, the κ-gap `1 − κ(t) = c · t^(−γκ)` is strictly
decreasing in `t` on `t > 0`: more training data ⟹ κ closer to 1. -/
theorem R_418_saturation_monotone
    (c γκ t₁ t₂ : ℝ) (h_c : 0 < c) (h_γ : 0 < γκ)
    (h_t₁ : 0 < t₁) (h_lt : t₁ < t₂) :
    c * t₂ ^ (-γκ) < c * t₁ ^ (-γκ) := by
  apply mul_lt_mul_of_pos_left _ h_c
  exact Real.rpow_lt_rpow_of_neg h_t₁ h_lt (by linarith)

end GammaKappa

end MIP
