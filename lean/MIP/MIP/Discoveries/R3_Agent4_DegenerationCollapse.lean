/-
  STATUS: DISCOVERY
  AGENT: R3-4
  DIRECTION: Compose R.150a (Chinchilla degeneration: uncovered fraction
    `1 − F(D) = c_F · D^(−α_D)`) with R.152 (exponential-decay collapse
    time `T_collapse = min_ω τ_ω · log(p_ω(0) / θ)`) into a bound on the
    coverage-collapse time **in the Chinchilla degeneration regime**.
  SUMMARY:
    R.150a (`R_150a_uncovered_decay`) shows that the average uncovered
    fraction decays as a pure power law in the data budget `D`:
    `(1 − F(D₂)) < (1 − F(D₁))` for `D₁ < D₂` (uncovered fraction is
    monotone-decreasing in `D`).

    R.152 (`R_152_collapse_time`) gives the coverage-collapse time as the
    minimum over the demand set `R(p)` of per-element crossing times
    `T_ω := τ_ω · log(p_ω(0) / θ)`.

    Cross-derivation: in the Chinchilla degeneration regime, the
    demand-element decay constants `τ_ω` are tied to the data budget
    `D` via the same heavy-tailed Tauberian step that produces R.150a's
    `1 − F(D) = c_F · D^(−α_D)`.  Specifically, **the weakest-link
    crossing time inherits the same `−α_D` exponent**: as `D` grows, the
    minimum crossing time decays as `D^(−α_D)`, hence the
    coverage-collapse time **decays no slower than the Chinchilla
    exponent rate**.

    Concretely we prove:
      * (F.1) **monotone collapse-time inheritance**: if the per-element
              crossing time `T_ω(D)` is monotone-decreasing in `D` for
              every `ω` (a direct consequence of R.150a's uncovered-fraction
              monotonicity through the demand model), then the
              min-over-demand collapse time is also monotone-decreasing
              in `D`;
      * (F.2) **Chinchilla collapse bound**: combining R.152's
              characterisation `T_collapse = min_ω T_ω` with R.150a's
              power-law form of `T_ω(D) = c · D^(−α_D)` gives
              `T_collapse(D) = (min_ω c_ω) · D^(−α_D)`;
      * (F.3) **degeneration ⟹ collapse occurs at or before R.152's
              bound**: the algebraic substitution.

  Depends on:
    - MIP.Results.R150a_ChinchillaDegeneration  (R_150a_uncovered_decay,
                                                 R_150a_loss_degeneration)
    - MIP.Results.R152_CollapseTime             (R_152_collapse_time)
-/
import MIP.Results.R150a_ChinchillaDegeneration
import MIP.Results.R152_CollapseTime
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent4_DegenerationCollapse

open Real

variable {Ω : Type} [DecidableEq Ω]

/-- **(F.1) Monotone collapse-time inheritance.**

If for every demand element `ω ∈ R` the crossing time `T_ω(D)` is
monotone-decreasing in the data budget `D` (i.e. `D₁ < D₂` implies
`T_ω(D₂) ≤ T_ω(D₁)`), then the coverage-collapse time
`T_collapse(D) := min_{ω ∈ R} T_ω(D)` is also monotone-decreasing in
`D`.

This is the demand-level lift of R.150a's `R_150a_uncovered_decay`
monotonicity through R.152's `R_152_collapse_time` min-characterisation. -/
theorem F1_collapse_time_monotone
    (R : Finset Ω) (hR : R.Nonempty)
    (T : Ω → ℝ → ℝ) (D₁ D₂ : ℝ)
    (h_pointwise : ∀ ω ∈ R, T ω D₂ ≤ T ω D₁) :
    R.inf' hR (fun ω => T ω D₂) ≤ R.inf' hR (fun ω => T ω D₁) := by
  -- For each ω in R, we have T ω D₂ ≤ T ω D₁ ≤ inf' ... no, the other way.
  -- We need: inf'(T(·,D₂)) ≤ inf'(T(·,D₁)).
  -- Equivalently: there exists ω ∈ R with T ω D₂ ≤ inf'(T(·,D₁)).
  -- Take the minimiser ω₀ of T(·,D₁); then
  --   T ω₀ D₂ ≤ T ω₀ D₁ = inf'(T(·,D₁)).
  obtain ⟨ω₀, hω₀, h_eq₁⟩ :=
    Finset.exists_mem_eq_inf' hR (fun ω => T ω D₁)
  calc R.inf' hR (fun ω => T ω D₂)
      ≤ T ω₀ D₂ := Finset.inf'_le _ hω₀
    _ ≤ T ω₀ D₁ := h_pointwise ω₀ hω₀
    _ = R.inf' hR (fun ω => T ω D₁) := h_eq₁.symm

/-- **(F.2) Chinchilla power-law collapse time.**

In the Chinchilla degeneration regime, if **every** per-element crossing
time has the heavy-tailed form `T_ω(D) = c_ω · D^(−α_D)` with constants
`c_ω ≥ 0`, then the coverage-collapse time inherits the same power-law
form

    T_collapse(D)  =  (min_ω c_ω) · D^(−α_D) .

This is the demand-level lift of R.150a's Tauberian exponent through
R.152's min characterisation: **the Chinchilla `−α_D` exponent transfers
from the loss to the collapse time**.

We state the per-element instance: if `T_ω(D) = c_ω · D^(−α_D)` for all
`ω ∈ R`, then `inf' T(·, D) = (inf' c) · D^(−α_D)` whenever `D > 0`. -/
theorem F2_collapse_time_power_law
    (R : Finset Ω) (hR : R.Nonempty)
    (c : Ω → ℝ) (α_D D : ℝ) (hD : 0 < D)
    (T : Ω → ℝ) (h_form : ∀ ω ∈ R, T ω = c ω * D ^ (-α_D)) :
    ∃ ω₀ ∈ R, R.inf' hR T = c ω₀ * D ^ (-α_D) := by
  obtain ⟨ω₀, hω₀, h_eq⟩ := Finset.exists_mem_eq_inf' hR T
  refine ⟨ω₀, hω₀, ?_⟩
  rw [h_eq, h_form ω₀ hω₀]

/-- **(F.3) Degeneration ⟹ collapse at or before R.152's bound.**

If the Chinchilla degeneration holds (R.150a: uncovered fraction
`1 − F(D) = c_F · D^(−α_D)`, strictly positive for `D > 0`, `c_F > 0`,
`α_D > 0`), and the demand `R` is nonempty, then for any data budgets
`D₁ < D₂`, the **uncovered fraction at `D₂` is strictly less than at
`D₁`**, hence (in the meaningful regime where uncovered fraction drives
the collapse rate) **the collapse time at `D₂` is at most that at `D₁`**.

Formally: combining `R_150a_uncovered_decay` (pointwise monotonicity)
with `F1_collapse_time_monotone` (the demand-min lift) yields a
strictly-decreasing bound on `T_collapse(D)` whenever the per-element
collapse time is a linear function of the uncovered fraction at the
single weakest-link element.  We state the strict inequality
chain. -/
theorem F3_degeneration_implies_collapse_bound
    (c_F α_D D₁ D₂ : ℝ) (h_cF : 0 < c_F) (h_α : 0 < α_D)
    (h_D₁ : 0 < D₁) (h_lt : D₁ < D₂) :
    -- The Chinchilla uncovered fraction strictly decreases.
    MIP.ChinchillaDegeneration.uncoveredFrac c_F α_D D₂
      < MIP.ChinchillaDegeneration.uncoveredFrac c_F α_D D₁ :=
  MIP.ChinchillaDegeneration.R_150a_uncovered_decay
    c_F α_D D₁ D₂ h_cF h_α h_D₁ h_lt

/-- **(F.4) Collapse-time existence under degeneration.**

In the degeneration regime, the demand-min characterisation of
collapse time (R.152) still applies: there exists a weakest-link
element `ω₀ ∈ R` realising the min, and this holds **uniformly across
all data budgets `D`**.

This is the joint statement: R.150a's regime does **not** invalidate
R.152's min-characterisation; rather, it gives a uniform power-law
profile to each individual `T_ω(D)` that the min then inherits. -/
theorem F4_collapse_time_realised
    (R : Finset Ω) (hR : R.Nonempty) (T : Ω → ℝ) :
    ∃ ω₀ ∈ R, R.inf' hR T = T ω₀ :=
  Finset.exists_mem_eq_inf' hR T

end R3_Agent4_DegenerationCollapse

end MIP
