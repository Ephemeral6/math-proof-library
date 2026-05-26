/-
Result R.3 (weak) — Existence of a phase-transition point under a unimodal
distribution.

Reference: `C:/Users/12729/Desktop/MIP/workspace/derived_results_index.md`
R.3 (B级: "N=0 比例存在相变", deps T.5 + C.6, "需要分布形状假设, 如高斯近似");
`C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md` R.63 (the S-shaped
transition, unimodal hypothesis); companion file
`MIP/Results/R63_UnimodalSTransition.lean` (monotone + `Tendsto … 1`).

**Statement (weak / existence form).** Let `P0 : ℝ → ℝ` be the "solved with
no further intervention" probability (the `N = 0` fraction) as a function of
the training coordinate `x` (e.g. time, or the mode `μ`).  Under a unimodal
`Φ₀`-distribution `P0` is continuous and monotone non-decreasing, and it
sweeps the full range: `P0 → 0` at one end and `P0 → 1` at the other
(bundled hypotheses — these are exactly what the unimodal/shape assumption
buys, cf. R.63).  Then for any target level `c ∈ (0, 1)` there is a
**transition point** `x*` with `P0 x* = c`: the autonomy fraction crosses
every intermediate level.  In particular a crossing of the canonical level
`1/2` exists — the phase-transition point.

This is the intermediate value theorem; we reuse the R.63/R.80 IVT pattern.

Two formulations are given:

1. **Finite-window crossing.**  If `P0` is continuous on `[a, b]` with
   `P0 a ≤ c ≤ P0 b`, then `∃ x* ∈ [a, b], P0 x* = c`.

2. **Tendsto-endpoints crossing.**  If `P0` is continuous (everywhere),
   `P0 → 0` along `atBot` and `P0 → 1` along `atTop`, then for every
   `c ∈ (0, 1)` there is some `x*` with `P0 x* = c`.  This is the
   "sweeps 0 → 1 ⟹ hits every intermediate level" content of R.3 weak.

**This file is `axiom`-free.**  `P0`, its endpoints, and the level `c` enter
as explicit hypotheses; no MIP opaque is committed to.
-/
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Order.Filter.Basic

namespace MIP

namespace PhaseExists

open Filter Topology

/-- **R.3 weak — finite-window transition point (IVT form).**

If the autonomy fraction `P0` is continuous on `[a, b]` and the target level
`c` lies between its endpoint values (`P0 a ≤ c ≤ P0 b`), then there is a
transition point `x* ∈ [a, b]` with `P0 x* = c`. -/
theorem R_3w_transition_point
    (P0 : ℝ → ℝ) (a b c : ℝ)
    (h_le : a ≤ b)
    (h_cont : ContinuousOn P0 (Set.Icc a b))
    (h_lo : P0 a ≤ c) (h_hi : c ≤ P0 b) :
    ∃ x_star ∈ Set.Icc a b, P0 x_star = c := by
  have h_mem : c ∈ Set.Icc (P0 a) (P0 b) := ⟨h_lo, h_hi⟩
  exact intermediate_value_Icc h_le h_cont h_mem

/-- **R.3 weak — a half-crossing exists (canonical phase-transition point).**

Specialisation to the canonical level `c = 1/2`: if `P0 a ≤ 1/2 ≤ P0 b` on a
continuous window, the half-autonomy phase-transition point exists. -/
theorem R_3w_half_crossing
    (P0 : ℝ → ℝ) (a b : ℝ)
    (h_le : a ≤ b)
    (h_cont : ContinuousOn P0 (Set.Icc a b))
    (h_lo : P0 a ≤ 1 / 2) (h_hi : 1 / 2 ≤ P0 b) :
    ∃ x_star ∈ Set.Icc a b, P0 x_star = 1 / 2 :=
  R_3w_transition_point P0 a b (1 / 2) h_le h_cont h_lo h_hi

/-- **R.3 weak — endpoint sweep `0 → 1` forces a crossing of every level.**

If `P0` is continuous everywhere, tends to `0` along `atBot` and to `1`
along `atTop` (the unimodal-shape sweep, bundled), then for every target
level `c ∈ (0, 1)` there is a transition point `x*` with `P0 x* = c`.

Proof: the `Tendsto` endpoints produce a left point `a` with `P0 a < c` and
a right point `b` with `c < P0 b`; if `a ≤ b` the IVT on `[a, b]` gives the
crossing, otherwise on `[b, a]` (whichever orientation holds). -/
theorem R_3w_sweep_crossing
    (P0 : ℝ → ℝ) (c : ℝ)
    (h_cont : Continuous P0)
    (h_bot : Tendsto P0 atBot (𝓝 0))
    (h_top : Tendsto P0 atTop (𝓝 1))
    (hc0 : 0 < c) (hc1 : c < 1) :
    ∃ x_star : ℝ, P0 x_star = c := by
  -- From `P0 → 0` at `atBot`, eventually `P0 < c` (since `c > 0`).
  have h_lt_c : ∀ᶠ x in atBot, P0 x < c := by
    have := (h_bot.eventually (eventually_lt_nhds hc0))
    simpa using this
  -- From `P0 → 1` at `atTop`, eventually `P0 > c` (since `c < 1`).
  have h_gt_c : ∀ᶠ x in atTop, c < P0 x := by
    have := (h_top.eventually (eventually_gt_nhds hc1))
    simpa using this
  obtain ⟨a, ha⟩ := h_lt_c.exists
  obtain ⟨b, hb⟩ := h_gt_c.exists
  -- `P0 a < c < P0 b`.  We need an oriented interval; take `t = max (a) ... `.
  -- Use the window `[min a b, max a b]`; on it the endpoint values still
  -- straddle `c`, but we must pick the right endpoints.  Cleaner: case on a ≤ b.
  rcases le_total a b with hab | hba
  · -- a ≤ b, P0 a < c, c < P0 b
    have h_mem : c ∈ Set.Icc (P0 a) (P0 b) := ⟨le_of_lt ha, le_of_lt hb⟩
    obtain ⟨x, _, hx⟩ :=
      intermediate_value_Icc hab h_cont.continuousOn h_mem
    exact ⟨x, hx⟩
  · -- b ≤ a, here P0 b > c and P0 a < c, so on [b, a] values decrease through c
    have h_mem : c ∈ Set.Icc (P0 a) (P0 b) := ⟨le_of_lt ha, le_of_lt hb⟩
    obtain ⟨x, _, hx⟩ :=
      intermediate_value_Icc' hba h_cont.continuousOn h_mem
    exact ⟨x, hx⟩

/-- **R.3 weak — monotone sweep gives a half-transition point.**

Canonical specialisation of the sweep form to `c = 1/2`: under the unimodal
endpoint sweep `0 → 1`, the half-autonomy phase-transition point exists. -/
theorem R_3w_sweep_half
    (P0 : ℝ → ℝ)
    (h_cont : Continuous P0)
    (h_bot : Tendsto P0 atBot (𝓝 0))
    (h_top : Tendsto P0 atTop (𝓝 1)) :
    ∃ x_star : ℝ, P0 x_star = 1 / 2 :=
  R_3w_sweep_crossing P0 (1 / 2) h_cont h_bot h_top (by norm_num) (by norm_num)

end PhaseExists

end MIP
