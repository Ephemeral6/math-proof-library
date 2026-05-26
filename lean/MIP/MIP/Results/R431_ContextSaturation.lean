/-
Result R.431 — Context Saturation: critical threshold `κ·|K_eff|² > dim_C/c_∘`
and the inverted-U (unimodal) degradation of `N` in the token-injection budget.

Reference: `workspace/coe_mip_unification.md` §R.431 (graded **B** — the
superposition容量 plug-in is an external model assumption, carried here as an
explicit hypothesis; the MIP-internal parts (i) threshold and (iv) inverted-U
are formalized exactly).

**Statement (crisp core).**

(i) **Saturation threshold (critical manifold).** With `κ` the combinatorial
    closure, `Keff` the effective in-context knowledge count, `dim_C` the
    context-window capacity and `c` (= `c_∘ > 0`) the per-pair token cost, the
    context saturates when

        κ · Keff²  >  dim_C / c          (♦)

    equivalently `c · κ · Keff² > dim_C`.  The *critical manifold* is the
    equality boundary `κ · Keff² = dim_C / c`.

(iv) **Inverted-U of `N` in the injection budget `B`.** Bundle the
    superposition model as a hypothesis: the emergence cost as a function of
    injected tokens `B ≥ 0` has the locally-quadratic form

        Ncost(B) = info·(B - B*)² + N*           (info > 0)

    The §R.431 "inverted-U" is on the *performance* side; the dual statement
    on the **cost** `N` side is a *U-shape*: `N` first *decreases* (information
    gain dominates) up to the optimal injection `B* = c·dim_C/κ`, then
    *increases* (superposition interference dominates).  We formalize this
    U-shape of `Ncost`: a strict minimum at `B*`, with `HasDerivAt Ncost 0 B*`
    (stationary peak of the inverted-U), decreasing before and increasing
    after.

**This file is `axiom`-free.**  `κ, Keff, dim_C, c, info, B*` enter as explicit
real data; the superposition quadratic-response model is an explicit
hypothesis-bundle, and we encode the algebraic kernel (threshold + unimodality).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace ContextSaturation

/-! ### Part (i): the saturation threshold and critical manifold -/

/-- **R.431 (i) — saturation threshold ⟺ capacity exceeded.**

The context saturates, `κ·Keff² > dim_C/c`, **iff** the combinatorial
demand `c·κ·Keff²` exceeds the window capacity `dim_C`.  (`c = c_∘ > 0`.) -/
theorem R_431_threshold_iff
    (κ Keff dim_C c : ℝ) (hc : 0 < c) :
    κ * Keff ^ 2 > dim_C / c ↔ c * (κ * Keff ^ 2) > dim_C := by
  rw [gt_iff_lt, gt_iff_lt, div_lt_iff₀ hc]
  constructor
  · intro h; linarith [h]
  · intro h; nlinarith [h]

/-- **R.431 (i) — the critical injection budget `B* = c·dim_C/κ`.**

On the critical manifold `κ·Keff² = dim_C/c`, the demonstrated combinatorial
content uses exactly the window: `c·κ·Keff² = dim_C`.  Equivalently the
critical effective count squared is `Keff² = dim_C/(c·κ)`. -/
theorem R_431_critical_manifold
    (κ Keff dim_C c : ℝ) (hc : 0 < c) (hκ : 0 < κ)
    (h_crit : κ * Keff ^ 2 = dim_C / c) :
    Keff ^ 2 = dim_C / (c * κ) := by
  have hcκ : c * κ ≠ 0 := by positivity
  field_simp at h_crit ⊢
  linarith [h_crit]

/-- **R.431 (i) — above threshold the relation is strict.**

If `κ·Keff² > dim_C/c` and `κ, c > 0`, then the "excess demand"
`c·κ·Keff² − dim_C` is strictly positive — the quantitative saturation margin. -/
theorem R_431_excess_positive
    (κ Keff dim_C c : ℝ) (hc : 0 < c)
    (h_sat : κ * Keff ^ 2 > dim_C / c) :
    0 < c * (κ * Keff ^ 2) - dim_C := by
  have h := (R_431_threshold_iff κ Keff dim_C c hc).mp h_sat
  linarith

/-! ### Part (iv): the inverted-U / U-shaped degradation of `N` -/

/-- **Superposition quadratic-response model** for the emergence cost as a
function of injected tokens `B`.  `Ncost(B) = info·(B − B*)² + N*`, with
`info > 0` the (net) interference curvature and `B*` the optimal injection.

This bundles the §R.431 superposition assumption: near the optimum, the trade
-off between information gain and representational interference is locally
quadratic. -/
noncomputable def Ncost (info Bstar Nstar B : ℝ) : ℝ :=
  info * (B - Bstar) ^ 2 + Nstar

/-- **R.431 (iv) — stationary peak: `Ncost'(B*) = 0`.**

The inverted-U / U-shape is stationary at the optimal injection `B*`:
`HasDerivAt Ncost 0 B*`. -/
theorem R_431_hasDerivAt_at_peak
    (info Bstar Nstar : ℝ) :
    HasDerivAt (Ncost info Bstar Nstar) 0 Bstar := by
  -- inner s ↦ s - Bstar has derivative 1; its square derivative 2(B−B*).
  have hsub : HasDerivAt (fun s : ℝ => s - Bstar) (1 : ℝ) Bstar :=
    (hasDerivAt_id Bstar).sub_const Bstar
  have hsq : HasDerivAt (fun s : ℝ => (s - Bstar) ^ 2)
      (2 * (Bstar - Bstar) ^ 1 * 1) Bstar := hsub.pow 2
  have hmul : HasDerivAt (fun s : ℝ => info * (s - Bstar) ^ 2)
      (info * (2 * (Bstar - Bstar) ^ 1 * 1)) Bstar := hsq.const_mul info
  have hadd : HasDerivAt (fun s : ℝ => info * (s - Bstar) ^ 2 + Nstar)
      (info * (2 * (Bstar - Bstar) ^ 1 * 1)) Bstar := hmul.add_const Nstar
  have hfun : (fun s : ℝ => info * (s - Bstar) ^ 2 + Nstar)
      = Ncost info Bstar Nstar := by funext s; unfold Ncost; ring
  rw [hfun] at hadd
  convert hadd using 1
  ring

/-- **R.431 (iv) — derivative at a generic point** is `2·info·(B − B*)`. -/
theorem R_431_hasDerivAt_generic
    (info Bstar Nstar B : ℝ) :
    HasDerivAt (Ncost info Bstar Nstar) (2 * info * (B - Bstar)) B := by
  have hsub : HasDerivAt (fun s : ℝ => s - Bstar) (1 : ℝ) B :=
    (hasDerivAt_id B).sub_const Bstar
  have hsq : HasDerivAt (fun s : ℝ => (s - Bstar) ^ 2)
      (2 * (B - Bstar) ^ 1 * 1) B := hsub.pow 2
  have hmul : HasDerivAt (fun s : ℝ => info * (s - Bstar) ^ 2)
      (info * (2 * (B - Bstar) ^ 1 * 1)) B := hsq.const_mul info
  have hadd : HasDerivAt (fun s : ℝ => info * (s - Bstar) ^ 2 + Nstar)
      (info * (2 * (B - Bstar) ^ 1 * 1)) B := hmul.add_const Nstar
  have hfun : (fun s : ℝ => info * (s - Bstar) ^ 2 + Nstar)
      = Ncost info Bstar Nstar := by funext s; unfold Ncost; ring
  rw [hfun] at hadd
  convert hadd using 1
  ring

/-- **R.431 (iv) — `B*` is the strict global minimum (peak of the inverted-U).**

For `info > 0`, `Ncost(B) > Ncost(B*)` for every `B ≠ B*`; `Ncost(B*) = N*`.
Below `B*` injecting more lowers `N` (information gain); above `B*` it raises
`N` (superposition interference) — the inverted-U on performance is the
U-shape on cost. -/
theorem R_431_strict_min_at_peak
    (info Bstar Nstar B : ℝ) (h_info : 0 < info) (hB : B ≠ Bstar) :
    Ncost info Bstar Nstar Bstar < Ncost info Bstar Nstar B := by
  unfold Ncost
  have hsub : B - Bstar ≠ 0 := sub_ne_zero.mpr hB
  have hsq : 0 < (B - Bstar) ^ 2 := by positivity
  have : 0 < info * (B - Bstar) ^ 2 := mul_pos h_info hsq
  simp only [sub_self]
  nlinarith [this]

/-- **R.431 (iv) — decreasing branch (before the peak): `B₁ ≤ B₂ ≤ B*` ⟹
`Ncost B₂ ≤ Ncost B₁`.**

Left of the optimum, larger injection means lower cost. -/
theorem R_431_decreasing_before_peak
    (info Bstar Nstar B₁ B₂ : ℝ) (h_info : 0 < info)
    (h12 : B₁ ≤ B₂) (h2star : B₂ ≤ Bstar) :
    Ncost info Bstar Nstar B₂ ≤ Ncost info Bstar Nstar B₁ := by
  unfold Ncost
  -- On (-∞, B*], s ↦ (s−B*)² is non-increasing; both factors ≤ 0.
  have h1 : B₁ - Bstar ≤ 0 := by linarith
  have h2 : B₂ - Bstar ≤ 0 := by linarith
  have hsq : (B₂ - Bstar) ^ 2 ≤ (B₁ - Bstar) ^ 2 := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_left hsq (le_of_lt h_info)]

/-- **R.431 (iv) — increasing branch (after the peak): `B* ≤ B₁ ≤ B₂` ⟹
`Ncost B₁ ≤ Ncost B₂`.**

Right of the optimum, larger injection means higher cost (interference). -/
theorem R_431_increasing_after_peak
    (info Bstar Nstar B₁ B₂ : ℝ) (h_info : 0 < info)
    (hstar1 : Bstar ≤ B₁) (h12 : B₁ ≤ B₂) :
    Ncost info Bstar Nstar B₁ ≤ Ncost info Bstar Nstar B₂ := by
  unfold Ncost
  have h1 : 0 ≤ B₁ - Bstar := by linarith
  have h2 : 0 ≤ B₂ - Bstar := by linarith
  have hsq : (B₁ - Bstar) ^ 2 ≤ (B₂ - Bstar) ^ 2 := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_left hsq (le_of_lt h_info)]

end ContextSaturation

end MIP
