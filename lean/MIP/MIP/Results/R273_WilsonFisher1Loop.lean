/-
Result R.273 — Wilson-Fisher 1-loop ε-expansion critical exponents (MIP
thermodynamics analogy).

Reference: `branches/thermodynamics/workspace/new_results.md` §R.273
("Wilson-Fisher 一阶 ε 展开：MIP 临界指数在 d_eff < 4 的修正", B class,
2026-05-18 thermodynamics branch).

**Setup.** In effective dimension `d_eff < 4` the mean-field critical
exponents fail and the Wilson-Fisher 1-loop ε-expansion (`ε := 4 − d_eff`)
applies. The source records the closed-form 1-loop exponents:

    β = 1/2 − ε/6,   γ = 1 + ε/6,   ν = 1/2 + ε/12,
    η = ε²/54,        α = ε/6,       d_eff = 4 − ε .

**What is formalized.** Each exponent is a polynomial `def` of `ε`. We
prove the scaling / hyperscaling consistency relations the source states:

* **Rushbrooke** `α + 2β + γ = 2` — holds *exactly* (pure `ring` identity,
  the ε-terms cancel to all orders for these 1-loop forms).
* **Hyperscaling** `α = 2 − ν·d_eff` — holds to first order in ε: the
  discrepancy is exactly `ε²/12`, i.e. `O(ε²)`, matching the source's
  `α = 2 − ν·d_eff = ε/6 + O(ε²)`.
* **Susceptibility scaling** `γ = ν·(2 − η)` — at this 1-loop order η is
  `O(ε²)`, so `γ = ν·2` to first order; discrepancy `O(ε²)`.
* **β scaling** `β = ν·(d_eff − 2 + η)/2` to first order (discrepancy
  `O(ε²)`).

These are real-polynomial identities, discharged by `ring` / `linarith`.

**This file is `axiom`-free.** It states R.273 as a self-contained set of
polynomial identities over `ℝ`; the physics (RG flow, anomalous dimension,
S[ψ] field theory) enters only as the definitions of the exponent
polynomials.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace WilsonFisher1Loop

/-- Effective dimension `d_eff = 4 − ε`. -/
noncomputable def dEff (ε : ℝ) : ℝ := 4 - ε

/-- 1-loop order parameter exponent `β = 1/2 − ε/6`. -/
noncomputable def β (ε : ℝ) : ℝ := 1 / 2 - ε / 6

/-- 1-loop susceptibility exponent `γ = 1 + ε/6`. -/
noncomputable def γ (ε : ℝ) : ℝ := 1 + ε / 6

/-- 1-loop correlation-length exponent `ν = 1/2 + ε/12`. -/
noncomputable def ν (ε : ℝ) : ℝ := 1 / 2 + ε / 12

/-- 1-loop anomalous dimension `η = ε²/54` (note: `O(ε²)`, so vanishes at
1-loop order in ε). -/
noncomputable def η (ε : ℝ) : ℝ := ε ^ 2 / 54

/-- 1-loop specific-heat exponent `α = ε/6`. -/
noncomputable def α (ε : ℝ) : ℝ := ε / 6

/-- **R.273.a — Rushbrooke identity (exact).**

For the 1-loop exponent forms, `α + 2β + γ = 2` holds *exactly* (the ε
contributions `ε/6 − ε/3 + ε/6` cancel identically). -/
theorem rushbrooke (ε : ℝ) : α ε + 2 * β ε + γ ε = 2 := by
  unfold α β γ; ring

/-- **R.273.b — hyperscaling `α = 2 − ν·d_eff` to first order in ε.**

The exact discrepancy between `2 − ν·d_eff` and `α` is `ε²/12`, i.e. the
hyperscaling relation `α = 2 − ν·d_eff` is satisfied up to `O(ε²)`, exactly
as the source records (`α = 2 − ν·d_eff = ε/6 + O(ε²)`). -/
theorem hyperscaling_discrepancy (ε : ℝ) :
    (2 - ν ε * dEff ε) - α ε = ε ^ 2 / 12 := by
  unfold ν dEff α; ring

/-- Reformulation: `2 − ν·d_eff` equals `α` plus the `O(ε²)` remainder. -/
theorem hyperscaling_first_order (ε : ℝ) :
    2 - ν ε * dEff ε = α ε + ε ^ 2 / 12 := by
  have h := hyperscaling_discrepancy ε; linarith

/-- **R.273.c — susceptibility scaling `γ = ν·(2 − η)` to first order.**

Since `η = ε²/54` is `O(ε²)`, the relation `γ = ν·(2 − η)` holds to first
order in ε; the discrepancy `ν·(2 − η) − γ = −ε²/108 − ε³/648` is `O(ε²)`. -/
theorem susceptibility_scaling_discrepancy (ε : ℝ) :
    ν ε * (2 - η ε) - γ ε = -(ε ^ 2 / 108) - ε ^ 3 / 648 := by
  unfold ν η γ; ring

/-- At leading order `η ↦ 0`, the susceptibility relation `γ = ν·2` is exact. -/
theorem susceptibility_leading (ε : ℝ) : ν ε * 2 = γ ε := by
  unfold ν γ; ring

/-- **R.273.d — order-parameter scaling `β = ν·(d_eff − 2 + η)/2` to first
order.**

The discrepancy `ν·(d_eff − 2 + η)/2 − β` is `O(ε²)`, matching the source's
`β = (1/2)(1 + ε/6)(1 − ε/2) ≈ 1/2 − ε/6 + O(ε²)`. -/
theorem beta_scaling_discrepancy (ε : ℝ) :
    ν ε * (dEff ε - 2 + η ε) / 2 - β ε
      = -(ε ^ 2 / 27) + ε ^ 3 / 1296 := by
  unfold ν dEff η β; ring

/-- **R.273.e — numerical check at `d_eff = 3` (ε = 1).**

The source's table gives `ν = 7/12, β = 1/3, γ = 7/6, α = 1/6, η = 1/54`
at `ε = 1`. -/
theorem exponents_at_eps_one :
    ν 1 = 7 / 12 ∧ β 1 = 1 / 3 ∧ γ 1 = 7 / 6 ∧ α 1 = 1 / 6 ∧ η 1 = 1 / 54 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · unfold ν; norm_num
  · unfold β; norm_num
  · unfold γ; norm_num
  · unfold α; norm_num
  · unfold η; norm_num

end WilsonFisher1Loop

end MIP
