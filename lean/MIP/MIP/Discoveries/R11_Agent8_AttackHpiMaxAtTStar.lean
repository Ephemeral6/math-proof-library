/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R11_Agent8
  TARGET: Cj.NEW-13 — `argmax_t H(π) ≈ t*` (collaboration golden window).

  SUMMARY:
    Cj.NEW-13 conjectures that, along a training curve, the subdomain
    dispersion `H(π)(X_t)` is MAXIMIZED near the second (collaboration)
    phase transition `t* := inf{ t : K^M(A_t) ⊇ K^M(H) }`.  The full
    conjecture has two halves:

      (max)  for all t,  H(π)(X_t) ≤ H(π)(X_{t*})        [maximum];
      (loc)  the maximizer time is t*                     [location].

    The (max) half rests on the static geometric core proven in the
    target file: `H(π) ≤ log m` with EQUALITY iff π is uniform
    (`MIP.CjNEW13.CjNEW13_entropy_le_log` + `CjNEW13_uniform_attains`).
    The (loc) half needs a model of the training trajectory `t ↦ X_t`
    and the metacognitive coverage threshold `t*` — UNAVAILABLE in the
    MIP knowledge layer, so the conjecture remains OPEN in full.

    NEW CONTRIBUTION (this file).  We supply the missing LOCATION of `t*`
    from the corpus.  R4_Agent2 pins the middle (collaboration) phase to a
    concrete *crossing budget* `D_* = crossBudget L_∞ C α_D ℓ_*` and proves
    it lies strictly between the coverage and autonomy budgets
    (`crossBudget_strictAnti`, repackaged through T.30's
    `T30_strict_ordering_kernel`).  We then state the conjecture's exact
    extremal content CONDITIONALLY on the one genuinely-dynamical premise
    the MIP layer cannot yet supply — "the trajectory's activation profile
    is uniform exactly at the budget `D_*`" — and PROVE, fully and
    sorry-free:

      THE GOLDEN-WINDOW THEOREM (`golden_window_argmax_at_tstar`).
      Let the activation profile along the trajectory be `prof : ℝ → ι → ℝ`
      (a probability vector at each budget), with `D_* := crossBudget …`
      the middle-phase budget.  Assume only that `prof` is uniform at
      `D_*` (`hat_tstar`).  Then:
        (i)  H(π)(prof D_*) = log m                     [peak value],
        (ii) ∀ D, H(π)(prof D) ≤ H(π)(prof D_*)         [GLOBAL MAX at D_*],
       (iii) D_cov < D_* < D_aut                        [D_* IS the middle
                                                          phase, via T.30],
        (iv) L(D_*) = ℓ_*                               [bridge identity].

    Thus, *conditional only on the trajectory visiting the uniform
    (generalist) profile at the corpus-pinned collaboration budget*, the
    argmax of `H(π)` is exactly `t* = D_*`, sitting strictly inside the
    coverage→autonomy window.  This is the strongest honest realization of
    Cj.NEW-13's "golden window" claim that the present axiom/definition
    layer permits.

    HONEST STATUS.  Cj.NEW-13 remains OPEN in full: the premise `hat_tstar`
    (uniform-at-`D_*`) is exactly the unproven dynamical step
    `argmax_t H(π) ≈ t*` reduced to its geometric witness; we do NOT derive
    it from the trajectory (no `t ↦ X_t` model exists).  We PROVE the
    extremal/location package GIVEN that witness — a faithful kernel, not a
    resolution.

  Depends on (genuine proof-term use):
    - MIP.Conjectures.CjNEW13_HpiMaxAtTStar
        (Hpi, CjNEW13_entropy_le_log, CjNEW13_uniform_attains)   [target]
    - MIP.Discoveries.R4_Agent2_PhaseScalingUnification  [TOWER]
        (crossBudget, crossBudget_strictAnti, bridge_solves, scalingLoss,
         alphaD)
    - MIP.Theorems.T30_PhaseTransition
        (T30_strict_ordering_kernel)
    - MIP.Results.R150a_ChinchillaDegeneration
        (R_150a_exponent_range)   [via R4_Agent2]
-/
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import MIP.Theorems.T30_PhaseTransition
import MIP.Results.R150a_ChinchillaDegeneration
import Mathlib.Tactic.Linarith

namespace MIP

namespace R11_Agent8_AttackHpiMaxAtTStar

open scoped BigOperators
open Real
open MIP.CjNEW13
open MIP.R4_Agent2_PhaseScalingUnification
open MIP.PhaseTransition
open MIP.ChinchillaDegeneration

variable {ι : Type} [Fintype ι] [DecidableEq ι] [Nonempty ι]

/-! ### Helper: H(π) is globally bounded by `log m` on the simplex. -/

/-- The uniform profile attains `H(π) = log m`, the *global maximum* of
`H(π)` over the probability simplex.  Pure repackaging of the target
file's `CjNEW13_entropy_le_log` (upper bound) and `CjNEW13_uniform_attains`
(attainment): the uniform profile is a maximizer. -/
theorem uniform_is_global_max
    (q : ι → ℝ) (h_nonneg : ∀ i, 0 ≤ q i) (h_sum : ∑ i, q i = 1) :
    Hpi q ≤ Hpi (fun _ : ι => 1 / (Fintype.card ι : ℝ)) := by
  -- H(q) ≤ log m   (CjNEW13_entropy_le_log)
  have h_le : Hpi q ≤ Real.log (Fintype.card ι) :=
    CjNEW13_entropy_le_log q h_nonneg h_sum
  -- H(uniform) = log m   (CjNEW13_uniform_attains)
  have h_eq : Hpi (fun _ : ι => 1 / (Fintype.card ι : ℝ))
      = Real.log (Fintype.card ι) :=
    CjNEW13_uniform_attains
  rw [h_eq]
  exact h_le

/-! ### The golden-window theorem (conditional realization of Cj.NEW-13). -/

/-- **GOLDEN-WINDOW THEOREM — Cj.NEW-13 extremal/location kernel.**

Setup.  A training trajectory carries an activation profile
`prof : ℝ → ι → ℝ`, a probability vector at every data budget
(`prof_nonneg`, `prof_sum`).  The corpus (R4_Agent2) pins the three phase
budgets to crossing budgets

    D_cov := crossBudget L∞ C α_D ℓ_cov,
    D_*   := crossBudget L∞ C α_D ℓ_*,
    D_aut := crossBudget L∞ C α_D ℓ_aut,     α_D := alphaD s,

ordered by the loss-thresholds `ℓ_cov > ℓ_* > ℓ_aut > L∞`.  The sole
DYNAMICAL premise — the geometric witness of `argmax_t H(π) ≈ t*` — is
`hat_tstar`: the profile is UNIFORM exactly at the collaboration budget
`D_*`.

Conclusion (the conjecture's extremal content, conditional on `hat_tstar`):
  (i)   `H(π)(prof D_*) = log m`                        — peak value;
  (ii)  `∀ D, H(π)(prof D) ≤ H(π)(prof D_*)`            — GLOBAL MAX at D_*;
  (iii) `D_cov < D_* ∧ D_* < D_aut`                     — D_* is the middle
        phase budget, strictly inside the coverage→autonomy window
        (T.30 via `T30_strict_ordering_kernel`, fed by R4_Agent2's
        `crossBudget_strictAnti`);
  (iv)  `scalingLoss L∞ C α_D D_* = ℓ_*`                — bridge identity.

So, GIVEN the trajectory visits the generalist (uniform) profile at the
corpus-pinned collaboration budget, the argmax of `H(π)` is exactly that
budget `t* = D_*`, located strictly between coverage and autonomy.

Cj.NEW-13 stays OPEN in full: `hat_tstar` is assumed, not derived (no
`t ↦ X_t` model). -/
theorem golden_window_argmax_at_tstar
    (Linf C s : ℝ) (ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (prof : ℝ → ι → ℝ)
    (prof_nonneg : ∀ D i, 0 ≤ prof D i)
    (prof_sum : ∀ D, ∑ i, prof D i = 1)
    -- the single dynamical witness of `argmax ≈ t*`:
    (hat_tstar :
      prof (crossBudget Linf C (alphaD s) ℓ_star)
        = (fun _ : ι => 1 / (Fintype.card ι : ℝ))) :
    let αD := alphaD s
    let D_cov := crossBudget Linf C αD ℓ_cov
    let D_star := crossBudget Linf C αD ℓ_star
    let D_aut := crossBudget Linf C αD ℓ_aut
    -- (i) peak value
    (Hpi (prof D_star) = Real.log (Fintype.card ι))
    -- (ii) global maximum at D_star
    ∧ (∀ D, Hpi (prof D) ≤ Hpi (prof D_star))
    -- (iii) D_star is the middle phase, strictly inside the window
    ∧ (D_cov < D_star ∧ D_star < D_aut)
    -- (iv) bridge identity at the middle phase
    ∧ (scalingLoss Linf C αD D_star = ℓ_star) := by
  intro αD D_cov D_star D_aut
  -- α_D > 0 from the genuine heavy-tail regime (R.150a via R4_Agent2).
  have hrange : 0 < αD ∧ αD < 1 := R_150a_exponent_range s h_s
  have hα : 0 < αD := hrange.1
  -- D_star = the crossing budget; at it, prof is uniform (hat_tstar).
  have h_uniform : prof D_star = (fun _ : ι => 1 / (Fintype.card ι : ℝ)) :=
    hat_tstar
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (i) peak value = log m, by CjNEW13_uniform_attains at the uniform profile.
    rw [h_uniform]
    exact CjNEW13_uniform_attains
  · -- (ii) for every budget D, H(prof D) ≤ H(prof D_star) = H(uniform) = log m.
    intro D
    have h_le_uniform :
        Hpi (prof D) ≤ Hpi (fun _ : ι => 1 / (Fintype.card ι : ℝ)) :=
      uniform_is_global_max (prof D) (prof_nonneg D) (prof_sum D)
    rw [h_uniform]
    exact h_le_uniform
  · -- (iii) D_cov < D_star < D_aut, via R4_Agent2's crossBudget ordering,
    --       packaged through T.30's strict-ordering kernel.
    have h1 : D_cov < D_star :=
      crossBudget_strictAnti Linf C αD ℓ_cov ℓ_star hC hα (by linarith) h_cov
    have h2 : D_star < D_aut :=
      crossBudget_strictAnti Linf C αD ℓ_star ℓ_aut hC hα h_aut h_star
    obtain ⟨_, h_first, h_second⟩ := T30_strict_ordering_kernel D_cov D_star D_aut h1 h2
    exact ⟨h_first, h_second⟩
  · -- (iv) bridge identity L(D_star) = ℓ_star (R4_Agent2 `bridge_solves`).
    exact bridge_solves Linf C αD ℓ_star hC hα (by linarith)

/-! ### Corollary: the window is non-degenerate (strict, jointly satisfiable). -/

/-- **Non-degeneracy / joint satisfiability.**  The golden window has
STRICTLY positive width: `D_cov < D_star` and `D_star < D_aut` are both
strict, so `t* = D_*` lies in the *interior* of the coverage→autonomy
interval, and `H(π)(prof D_*) = log m > 0` whenever `m ≥ 2`.  This rules
out a vacuous reading: the maximizer is a genuine interior peak.

We extract the strict interior-location from the headline; positivity of
the peak for `m ≥ 2` follows from `Real.log` monotonicity. -/
theorem golden_window_nondegenerate
    (Linf C s : ℝ) (ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (prof : ℝ → ι → ℝ)
    (prof_nonneg : ∀ D i, 0 ≤ prof D i)
    (prof_sum : ∀ D, ∑ i, prof D i = 1)
    (hat_tstar :
      prof (crossBudget Linf C (alphaD s) ℓ_star)
        = (fun _ : ι => 1 / (Fintype.card ι : ℝ)))
    (hm2 : 2 ≤ Fintype.card ι) :
    let αD := alphaD s
    crossBudget Linf C αD ℓ_cov < crossBudget Linf C αD ℓ_star
      ∧ crossBudget Linf C αD ℓ_star < crossBudget Linf C αD ℓ_aut
      ∧ 0 < Hpi (prof (crossBudget Linf C αD ℓ_star)) := by
  intro αD
  obtain ⟨h_peak, _, ⟨h_lo, h_hi⟩, _⟩ :=
    golden_window_argmax_at_tstar Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s h_aut h_star h_cov prof prof_nonneg prof_sum hat_tstar
  refine ⟨h_lo, h_hi, ?_⟩
  -- peak value = log m, and log m > 0 for m ≥ 2.
  rw [h_peak]
  have hm1 : (1 : ℝ) < (Fintype.card ι : ℝ) := by
    have : (2 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hm2
    linarith
  exact Real.log_pos hm1

end R11_Agent8_AttackHpiMaxAtTStar

end MIP
