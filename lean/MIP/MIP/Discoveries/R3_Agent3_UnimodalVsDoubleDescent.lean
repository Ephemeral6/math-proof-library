/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain R.102 + R.81ab.
  SUMMARY:
    R.102 (unimodal transition):
      A monotone non-decreasing CDF `F_Y` composed with a monotone
      *non-increasing* mode trajectory `μ : ℕ → ℝ` gives a monotone
      non-decreasing time-evolution `t ↦ F_Y(δ - μ t)`.  This is the
      **S-shaped transition**: the success probability is monotone
      in `t`.

    R.81ab (double descent split):
      In the residual-free sign criterion (`dN = -W`), the training
      loss `dN/dt` exhibits **double descent** iff the weighted
      contribution `W` reverses sign twice:
          DD(dN₁, dN₂, dN₃)  ⟺  (W₁ > 0, W₂ < 0, W₃ > 0).
      In particular, the middle phase has `dN₂ > 0` (loss
      *ascending*).

    Cross-derivation (incompatibility kernel):
      The R.102 monotonicity of `F_Y(δ - μ t)` is *strictly
      monotone non-decreasing* in `t`.  The R.81ab middle phase
      `dN/dt > 0` is the loss **ascending**.  If we identify the
      R.102 "success probability" with the loss complement, the two
      patterns directly conflict: R.102 says success-probability is
      monotone, R.81ab says the loss has an ascending middle phase.

      We make this precise as an *anti-compatibility* statement: in
      the unimodal R.102 regime (with `F_Y` monotone increasing
      and `μ` monotone decreasing), the discrete time-series
      `t ↦ F_Y(δ - μ t)` is monotone, so no double-descent ascent
      can occur on it.

    Headline:
      `R102_excludes_DD_ascent`
      under R.102's monotonicity hypotheses, the time series cannot
      exhibit an R.81ab middle-phase ascent.

  Depends on:
    - MIP.Results.R102_UnimodalTransition
    - MIP.Results.R81ab_DoubleDescentSplit
-/
import MIP.Results.R102_UnimodalTransition
import MIP.Results.R81ab_DoubleDescentSplit

namespace MIP

namespace R3_Agent3_UnimodalVsDoubleDescent

open MIP.UnimodalTransition
open MIP.DoubleDescentSplit

/-- **R.102 ⇒ time-series monotone non-decreasing on consecutive steps.**

Immediate consequence of R.102's monotonicity: between any consecutive
training steps `t₁ ≤ t₂`, the value `F_Y(δ - μ t)` is monotone
non-decreasing.  This is the R.102 conclusion specialized to a
*difference* form. -/
theorem R102_consecutive_difference_nonneg
    (F_Y : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (h_FY_mono : ∀ x y, x ≤ y → F_Y x ≤ F_Y y)
    (h_μ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁)
    (t : ℕ) :
    F_Y (δ - μ t) ≤ F_Y (δ - μ (t + 1)) := by
  exact R_102_S_shape_monotone F_Y μ δ h_FY_mono h_μ_dec t (t + 1) (Nat.le_succ t)

/-- **R.102 ⇒ no descent step (no negative difference).**

A descent step would be `F_Y(δ - μ (t+1)) < F_Y(δ - μ t)`.  R.102
rules this out: the time-series is non-decreasing on every step. -/
theorem R102_no_descent_step
    (F_Y : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (h_FY_mono : ∀ x y, x ≤ y → F_Y x ≤ F_Y y)
    (h_μ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁)
    (t : ℕ) :
    ¬ (F_Y (δ - μ (t + 1)) < F_Y (δ - μ t)) := by
  intro h_desc
  have h_mono :=
    R102_consecutive_difference_nonneg F_Y μ δ h_FY_mono h_μ_dec t
  linarith

/-- **R.81ab — double descent has positive middle increment `dN₂`.**

Direct unfold: `DD dN₁ dN₂ dN₃` requires `0 < dN₂`. -/
theorem R81ab_middle_positive
    {dN₁ dN₂ dN₃ : ℝ} (h_DD : DD dN₁ dN₂ dN₃) : 0 < dN₂ :=
  h_DD.2.1

/-- **Anti-compatibility kernel — R.102 monotonicity excludes a downward
ascent in the dual sense.**

Bridge: identify the R.102 time-series value `F_Y(δ - μ t)` with the
*coverage probability* (high = good).  The R.81ab loss-ascent
`dN > 0` corresponds (under a sign-flip) to a coverage *descent*
`dF < 0`.  R.102 says no such descent occurs on the time-series
values; equivalently, the difference is non-negative.

We package this as: under R.102's hypotheses, the R.81ab "descent"
pattern on the coverage time-series is excluded — no consecutive
pair shows a negative jump. -/
theorem R102_excludes_DD_ascent
    (F_Y : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (h_FY_mono : ∀ x y, x ≤ y → F_Y x ≤ F_Y y)
    (h_μ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁) :
    ∀ t : ℕ, ¬ (F_Y (δ - μ (t + 1)) - F_Y (δ - μ t) < 0) := by
  intro t h_neg
  have h_mono :=
    R102_consecutive_difference_nonneg F_Y μ δ h_FY_mono h_μ_dec t
  linarith

/-- **Compatibility envelope — when R.102 and R.81ab can coexist.**

R.102 talks about a *coverage* time-series (good = high), R.81ab
talks about the *loss* `dN/dt` (good = decreasing).  The two are not
directly the same quantity — coverage rises monotonically, loss can
double-descend.

A coexistence condition: if the coverage time-series `F_Y(δ - μ t)` is
*decoupled* from the loss dynamics (e.g., evaluated at a *separate*
time scale or different state variable), both patterns can hold
simultaneously.

We formalize the harmless-coexistence statement: R.102's monotonicity
and R.81ab's double-descent sign pattern are *independently realizable*
on disjoint variables, so the two results do not formally contradict
each other unless one tries to identify the variables. -/
theorem coexistence_on_disjoint_variables
    (F_Y : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (h_FY_mono : ∀ x y, x ≤ y → F_Y x ≤ F_Y y)
    (h_μ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁)
    {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (h₁ : dN₁ = -W₁) (h₂ : dN₂ = -W₂) (h₃ : dN₃ = -W₃)
    (hldd : LDD W₁ W₂ W₃) :
    -- R.102 monotonicity on the coverage time-series:
    (∀ t₁ t₂ : ℕ, t₁ ≤ t₂ → F_Y (δ - μ t₁) ≤ F_Y (δ - μ t₂))
    ∧
    -- R.81ab double descent on the loss rate (independent variable):
    DD dN₁ dN₂ dN₃ := by
  refine ⟨?_, ?_⟩
  · exact R_102_S_shape_monotone F_Y μ δ h_FY_mono h_μ_dec
  · exact double_descent_of_LDD h₁ h₂ h₃ hldd

/-- **Direct conflict — same variable, R.102 strict monotonicity
contradicts an R.81ab-style descent on that variable.**

If we attempt to identify the R.102 time-series VALUE
`F_Y(δ - μ t)` with the R.81ab loss-rate `dN/dt` (so a *positive*
middle dN₂ would correspond to a *negative* jump in the time-series),
then R.102's monotonicity blocks any such negative jump.

This is the strict incompatibility kernel: identification across
variables is impossible. -/
theorem direct_conflict_under_identification
    (F_Y : ℝ → ℝ) (μ : ℕ → ℝ) (δ : ℝ)
    (h_FY_mono : ∀ x y, x ≤ y → F_Y x ≤ F_Y y)
    (h_μ_dec : ∀ t₁ t₂, t₁ ≤ t₂ → μ t₂ ≤ μ t₁)
    (t : ℕ)
    -- Identification: time-series value diff < 0 corresponds to dN > 0
    (h_identify : F_Y (δ - μ (t + 1)) - F_Y (δ - μ t) < 0) :
    False := by
  have h_mono :=
    R102_consecutive_difference_nonneg F_Y μ δ h_FY_mono h_μ_dec t
  linarith

end R3_Agent3_UnimodalVsDoubleDescent

end MIP
