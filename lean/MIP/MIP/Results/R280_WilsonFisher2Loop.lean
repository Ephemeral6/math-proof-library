/-
Result R.280 — Wilson-Fisher 2-loop ε² critical-exponent corrections (MIP
thermodynamics analogy).

Reference: `branches/thermodynamics/workspace/new_results.md` §R.280
("Wilson-Fisher 2-loop ε² 修正", B class, 2026-05-18 thermodynamics branch).

**Setup.** Extending R.273's 1-loop ε-expansion to 2-loop order shrinks the
deviation from the measured 3D-Ising exponents. The source records the
2-loop exponents (`ε := 4 − d_eff`):

    ν = 1/2 + ε/12 + 7ε²/162,
    γ = 1 + ε/6  + 25ε²/324,
    α = ε/6 − 29ε²/324,
    η = ε²/54   (unchanged from 1-loop at this order).

**What is formalized.** Each exponent is a polynomial `def` of `ε`. We
prove the 2-loop scaling / consistency relations the source derives:

* **2-loop consistency** `ν(2loop) = ν(1loop) + 7ε²/162` — the 2-loop
  correction is exactly the stated `7ε²/162` (pure `ring`).
* **Hyperscaling** `α = 2 − ν·d_eff` with `d_eff = 4 − ε`, to `O(ε²)`: the
  source's explicit computation gives `2 − ν·d_eff = ε/6 − 29ε²/324 + O(ε³)`;
  we prove the discrepancy `(2 − ν·d_eff) − α = 7ε³/162`, i.e. the relation
  holds to second order in ε.
* **Susceptibility scaling** `γ = ν·(2 − η)` to `O(ε²)`: discrepancy is
  `O(ε³)`, reproducing the source's `γ = 1 + ε/6 + 25ε²/324 + O(ε³)`.

These are real-polynomial identities, discharged by `ring` / `linarith`.

**This file is `axiom`-free.** It states R.280 as self-contained polynomial
identities over `ℝ`; the 2-loop RG physics enters only as the definitions of
the exponent polynomials.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace WilsonFisher2Loop

/-- Effective dimension `d_eff = 4 − ε`. -/
noncomputable def dEff (ε : ℝ) : ℝ := 4 - ε

/-- 1-loop correlation-length exponent `ν₁ = 1/2 + ε/12` (from R.273). -/
noncomputable def ν1 (ε : ℝ) : ℝ := 1 / 2 + ε / 12

/-- 2-loop correlation-length exponent `ν = 1/2 + ε/12 + 7ε²/162`. -/
noncomputable def ν (ε : ℝ) : ℝ := 1 / 2 + ε / 12 + 7 * ε ^ 2 / 162

/-- 2-loop susceptibility exponent `γ = 1 + ε/6 + 25ε²/324`. -/
noncomputable def γ (ε : ℝ) : ℝ := 1 + ε / 6 + 25 * ε ^ 2 / 324

/-- 2-loop specific-heat exponent `α = ε/6 − 29ε²/324`. -/
noncomputable def α (ε : ℝ) : ℝ := ε / 6 - 29 * ε ^ 2 / 324

/-- Anomalous dimension `η = ε²/54` (unchanged from 1-loop at `O(ε²)`). -/
noncomputable def η (ε : ℝ) : ℝ := ε ^ 2 / 54

/-- **R.280.a — 2-loop consistency with 1-loop.**

The 2-loop `ν` equals the 1-loop `ν` plus the stated `7ε²/162` correction. -/
theorem nu_two_loop_correction (ε : ℝ) : ν ε = ν1 ε + 7 * ε ^ 2 / 162 := by
  unfold ν ν1; ring

/-- **R.280.b — hyperscaling `α = 2 − ν·d_eff` to second order in ε.**

The exact discrepancy between `2 − ν·d_eff` and `α` is `7ε³/162`, i.e. the
hyperscaling relation `α = 2 − ν·d_eff` holds up to `O(ε³)`, exactly
reproducing the source's `α = 2 − ν·d_eff = ε/6 − 29ε²/324 + O(ε³)`. -/
theorem hyperscaling_discrepancy (ε : ℝ) :
    (2 - ν ε * dEff ε) - α ε = 7 * ε ^ 3 / 162 := by
  unfold ν dEff α; ring

/-- Reformulation: `2 − ν·d_eff` equals `α` plus the `O(ε³)` remainder. -/
theorem hyperscaling_second_order (ε : ℝ) :
    2 - ν ε * dEff ε = α ε + 7 * ε ^ 3 / 162 := by
  have h := hyperscaling_discrepancy ε; linarith

/-- **R.280.c — susceptibility scaling `γ = ν·(2 − η)` to second order.**

With `η = ε²/54`, the discrepancy `ν·(2 − η) − γ = −ε³/648 − 7ε⁴/8748` is
`O(ε³)`, so the 2-loop `γ = ν·(2 − η)` relation holds up to `O(ε³)`, matching
the source's `γ = (1/2 + ε/12 + 7ε²/162)(2 − ε²/54) = 1 + ε/6 + 25ε²/324`. -/
theorem susceptibility_scaling_discrepancy (ε : ℝ) :
    ν ε * (2 - η ε) - γ ε = -(ε ^ 3 / 648) - 7 * ε ^ 4 / 8748 := by
  unfold ν η γ; ring

/-- **R.280.d — numerical check at `d_eff = 3` (ε = 1).**

The source's table gives the 2-loop values
`ν ≈ 0.626 = 169/270` (= 1/2 + 1/12 + 7/162),
`γ = 1 + 1/6 + 25/324`, `α = 1/6 − 29/324`. -/
theorem exponents_at_eps_one :
    ν 1 = 1 / 2 + 1 / 12 + 7 / 162 ∧
    γ 1 = 1 + 1 / 6 + 25 / 324 ∧
    α 1 = 1 / 6 - 29 / 324 := by
  refine ⟨?_, ?_, ?_⟩
  · unfold ν; norm_num
  · unfold γ; norm_num
  · unfold α; norm_num

end WilsonFisher2Loop

end MIP
