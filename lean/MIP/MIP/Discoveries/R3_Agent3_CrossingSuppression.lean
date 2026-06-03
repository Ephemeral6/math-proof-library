/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain R.79 + R.80 + R.518.
  SUMMARY:
    R.79 (basic grokking): coverage indicator `f(t)` has a threshold
        `t* := inf{t : f(t) = 1}` with `f<1` before, `f=1` after.
    R.80 (geometric grokking crossing): if `K_t : ℝ → ℝ` is continuous
        on `[t₀, t₁]`, starts below the coverage threshold `Rsup` and
        ends above, then there is a crossing time `t* ∈ [t₀, t₁]`
        with `K_t t* = Rsup`.
    R.518 (decay suppression): if the mean half-life `τ̄` is strictly
        below the critical decay rate `τ̄_c = 2/(α |log κ_c²|)`, then
        `κ_eff^∞ < κ_c²` — the grokking surface is *never* reached.

    Composition: under the R.518 suppression hypothesis the R.80
    crossing premise fails for the closure trajectory.  Concretely:
    if `κ_t` is bounded above by `κ_eff^∞` and `κ_eff^∞ < κ_c²`, then
    `κ_t < κ_c²` at every time — the R.80 intermediate-value argument
    has no `t₁` with `K_t t₁ ≥ Rsup`, so no crossing time exists.
    This is the **R.80 crossing point doesn't exist** under above-
    threshold decay.

    Headline:
      `crossing_point_suppressed_by_decay`
      decay τ̄ below R.518 threshold + closure bounded by steady state
      ⟹ R.80 crossing premise unsatisfiable
      ⟹ no grokking crossing time in any interval.

  Depends on:
    - MIP.Results.R79_Grokking      (threshold dichotomy)
    - MIP.Results.R80_GrokkingCrossing (coverage crossing IVT)
    - MIP.Results.R518_DecayGrokkingSuppression (decay suppression)
-/
import MIP.Results.R79_Grokking
import MIP.Results.R80_GrokkingCrossing
import MIP.Results.R518_DecayGrokkingSuppression

namespace MIP

namespace R3_Agent3_CrossingSuppression

open MIP.GrokkingCrossing
open MIP.DecayGrokkingSuppression

/-- **R.80 + R.518 — crossing point suppressed by decay.**

If the closure trajectory `κ_t : ℝ → ℝ` is pointwise bounded above by
the decay steady state `κ_eff^∞`, and the half-life `τ̄` is strictly
below the R.518 critical rate (so `κ_eff^∞ < κ_c²`), then the R.80
coverage-crossing premise fails: no time `t` satisfies `κ_c² ≤ κ_t t`,
hence the R.80 crossing argument cannot produce a crossing time.

(In R.80 language: the trajectory never reaches the coverage hyper-
surface `Π_cov = {κ = κ_c²}`.) -/
theorem crossing_point_suppressed_by_decay
    (κ_t : ℝ → ℝ) (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    ∀ t, κ_t t < κc2 := by
  intro t
  exact R_520_never_reached (κ_t t) α τ_bar κc2
    h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt (h_bound t)

/-- **R.80 + R.518 — R.80 crossing premise is unsatisfiable.**

The R.80 crossing theorem requires a `t₁` with `Rsup ≤ K_t t₁`.
Under the suppression hypothesis the bound `κ_t t < κc2` holds at
*every* time, so no such `t₁` exists.  This is the strict
"R.80's crossing point doesn't exist" headline. -/
theorem R80_crossing_premise_fails
    (κ_t : ℝ → ℝ) (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    ¬ ∃ t, κc2 ≤ κ_t t := by
  intro ⟨t, h_t⟩
  have h_strict : κ_t t < κc2 :=
    crossing_point_suppressed_by_decay κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound t
  linarith

/-- **R.80 + R.518 — no `covered` time under suppression.**

R.80 defines `covered K_t Rsup t := Rsup ≤ K_t t`.  Under R.518
suppression the `covered` predicate is universally false: the closure
trajectory is always strictly below the grokking surface.  Hence the
"covered set" `{t : covered t}` is empty. -/
theorem covered_set_empty_under_decay
    (κ_t : ℝ → ℝ) (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    ∀ t, ¬ covered κ_t κc2 t := by
  intro t h_cov
  unfold covered at h_cov
  have : κ_t t < κc2 :=
    crossing_point_suppressed_by_decay κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound t
  linarith

/-- **R.79 + R.518 — discrete grokking threshold suppressed.**

R.79's `R_79_threshold_dichotomy` constructs the grokking threshold
`t_star := Nat.find` of a monotone coverage predicate, *provided* the
eventually-covered hypothesis `∃ t₀, cov t₀` holds.  Under R.518
decay suppression, the discrete coverage indicator
`cov_discrete t := κc2 ≤ κ_t (t : ℝ)` is universally false, so the
eventually-covered hypothesis fails — the R.79 threshold construction
has no input.

This is the **discrete analog** of crossing-suppression: at the
combinatorial / phase-indicator level, R.518 voids R.79's threshold
existence. -/
theorem R79_threshold_no_input_under_decay
    (κ_t : ℝ → ℝ) (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    ¬ ∃ t₀ : ℕ, κc2 ≤ κ_t (t₀ : ℝ) := by
  intro ⟨t₀, h_t₀⟩
  have h_strict : κ_t (t₀ : ℝ) < κc2 :=
    crossing_point_suppressed_by_decay κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound (t₀ : ℝ)
  linarith

/-- **R.79 + R.80 + R.518 — headline three-chain.**

This is the 3-result composition:
  • R.79 says grokking = first time coverage holds,
  • R.80 says the geometric crossing is required for grokking,
  • R.518 says decay below threshold prevents the closure from
    reaching the grokking surface.

Therefore the grokking transition does not occur under decay:
neither (i) the R.80 coverage-crossing time, nor (ii) the R.79
discrete threshold, can be realized.  We package this as a joint
"no grokking" statement: under R.518's hypothesis, *both* the
geometric (R.80) and combinatorial (R.79) grokking witnesses fail. -/
theorem grokking_suppressed_three_chain
    (κ_t : ℝ → ℝ) (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf α τ_bar) :
    (¬ ∃ t, κc2 ≤ κ_t t)            -- R.80 crossing premise fails
    ∧ (∀ t, ¬ covered κ_t κc2 t)    -- R.80 covered set empty
    ∧ (¬ ∃ t₀ : ℕ, κc2 ≤ κ_t (t₀ : ℝ))  -- R.79 threshold input fails
    := by
  refine ⟨?_, ?_, ?_⟩
  · exact R80_crossing_premise_fails κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound
  · exact covered_set_empty_under_decay κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound
  · exact R79_threshold_no_input_under_decay κ_t α τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt h_bound

end R3_Agent3_CrossingSuppression

end MIP
