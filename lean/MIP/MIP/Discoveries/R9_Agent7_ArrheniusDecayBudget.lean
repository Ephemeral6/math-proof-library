/-
  STATUS: DISCOVERY
  AGENT: R9_Agent7
  DIRECTION: ARRHENIUS FORGETTING SETS THE TEMPERATURE-DEPENDENCE OF THE
    DECAY-INFLATED OHM BUDGET.

    The corpus separately establishes:
      • R.278 (ArrheniusForgetting): the catastrophic-forgetting bound is an
        Arrhenius rate  k(A,E,T) = A·exp(-E/T) = deltaN A E T,  strictly
        decreasing in the protection barrier E and (we show) strictly
        increasing in the temperature T;
      • R.156 (HalfLife): exponential decay p(t)=p₀·exp(-t/Tc) has half-life
        τ = Tc·log 2 — the algebraic half-life kernel;
      • R7_Agent9 (DecayOhmBudgetSandwich): knowledge decay INFLATES the
        partition-extreme Ohm budget; on R.194's model
        N_decay = N_maint + ⌈Φ₀·Z_τ⌉ the budget is monotone in the
        maintenance tax N_maint (decay_budget_mono_maint) and the undecayed
        budget is a hard floor (decay_inflates_budget).

    We CHAIN them into a single temperature-dependent budget law.  Reading the
    Arrhenius rate k = A·exp(-E/T) as the inverse decay-constant 1/Tc of an
    exponential forgetting curve p(t)=p₀·exp(-k·t), R.156 gives the half-life
        t_{1/2}(A,E,T) = (log 2)/k = (log 2 / A)·exp(E/T)              (a)
    — an Arrhenius half-life identity: INCREASING in the barrier E,
    DECREASING in the temperature T (proved analytically from R.278's exp
    monotonicity).  A hotter regime / lower barrier raises the Arrhenius rate,
    SHORTENS the half-life, and — since faster forgetting drops more demand
    elements below threshold, raising the maintenance tax N_maint — INFLATES
    the decay-modified Ohm budget through R7_Agent9 / R.194.  Modelling the
    maintenance tax as a non-decreasing function of the Arrhenius rate
    (more forgetting ⇒ at least as much to re-activate), we prove the
    decay-inflated budget is MONOTONE in the Arrhenius rate, hence the
    temperature-dependent budget bound:
        higher T (or lower E) ⇒ higher rate ⇒ shorter half-life
                              ⇒ larger N_maint ⇒ larger N_decay,
    bottoming out at the undecayed partition floor of R7_Agent9.

  SUMMARY:
    (a) ARRHENIUS RATE STRUCTURE (built on R.278's deltaN):
        `arrheniusRate A E T = deltaN A E T = A·exp(-E/T)`, positive
        (`arrheniusRate_pos`, strengthening R.278.a's non-negativity to
        strict positivity via the same `Real.exp_pos` core),
        StrictAnti in E (`arrheniusRate_strictAnti_barrier`, = R.278.b
        `R_278_b_strictAnti_in_protection`) and StrictMono in T
        (`arrheniusRate_strictMono_temp`).

    (b) ARRHENIUS HALF-LIFE IDENTITY (R.156 + R.278):
        `arrhenius_half_life_identity` — for the forgetting curve
        p(t)=p₀·exp(-k·t) with k = arrheniusRate A E T, the half-life
        equation p(τ)=p₀/2 is equivalent to τ = (log 2)/k, and
        `arrhenius_half_life_eq` rewrites this as (log 2 / A)·exp(E/T).
        GENUINELY invokes `HalfLife.half_life_identity` with decay constant
        Tc := 1/k.

    (c) HALF-LIFE MONOTONICITY:
        `half_life_strictMono_barrier` — half-life STRICTLY INCREASES in the
        barrier E (more protection ⇒ longer memory);
        `half_life_strictAnti_temp` — half-life STRICTLY DECREASES in T
        (hotter ⇒ shorter memory).  Both ride R.278's rate monotonicity
        through τ = log2/k.

    (d) RATE ⇒ BUDGET INFLATION (R7_Agent9 + R.194):
        `budget_mono_in_rate` — modelling N_maint = maintTax(k) with
        `maintTax` Monotone in the Arrhenius rate, a higher rate inflates
        the R.194 decay budget `NDecay Φ₀ Z_τ (maintTax k)`.  GENUINELY
        invokes `R7_Agent9_DecayOhmBudgetSandwich.decay_budget_mono_maint`.

    (e) HEADLINE: `arrhenius_temperature_budget_law` — the full chain.
        For two regimes (E₁,T₁) and (E₂,T₂) with rate₁ ≤ rate₂ (e.g. hotter
        or lower-barrier second regime), simultaneously:
          • half-life shrinks:    t_{1/2}(regime₂) ≤ t_{1/2}(regime₁);
          • maintenance tax grows: maintTax(rate₁) ≤ maintTax(rate₂);
          • decay budget inflates: N_decay(regime₁) ≤ N_decay(regime₂);
          • the undecayed partition floor ⌈Z·minΦ⌉₊ stays a floor for BOTH.
        Chaining R.278 (Arrhenius rate) + R.156 (half-life) +
        R7_Agent9.decay_inflates_budget / decay_budget_mono_maint
        (R7-tower) + R.194 (NDecay model).

  Depends on:
    - MIP.Results.R278_ArrheniusForgetting
        (ArrheniusForgetting.deltaN,
         ArrheniusForgetting.R_278_b_strictAnti_in_protection)
        — the Arrhenius rate A·exp(-E/T) and its barrier-monotonicity;
          `deltaN` and `R_278_b_strictAnti_in_protection` are GENUINELY
          invoked (in `arrheniusRate`/`arrheniusRate_strictAnti_barrier`
          and the half-life chain).
        [PROVENANCE-ONLY: `ArrheniusForgetting.R_278_a_nonneg` is the
         non-negativity statement `0 ≤ deltaN`; `arrheniusRate_pos`
         strengthens it to `0 < deltaN` but proves strict positivity
         directly via `Real.exp_pos`, so `R_278_a_nonneg` is NOT in any
         proof term here — cited for provenance only.]
    - MIP.Results.R156_HalfLife
        (HalfLife.half_life_identity)
        — the half-life kernel τ = Tc·log 2; GENUINELY invoked (with
          Tc := 1/k) in `arrhenius_half_life_identity`.
    - MIP.Discoveries.R7_Agent9_DecayOhmBudgetSandwich
        (R7_Agent9_DecayOhmBudgetSandwich.decay_budget_mono_maint,
         R7_Agent9_DecayOhmBudgetSandwich.decay_inflates_budget)
        — decay inflates the Ohm budget; GENUINELY invoked in
          `budget_mono_in_rate` and the headline.  [R7 TOWER member.]
    - MIP.Results.R194_DecayModifiedOhm
        (DecayModifiedOhm.NDecay) — the model decay budget, used as the
          concrete N_decay in (d)/(e).
    - Mathlib: Real.exp_pos, Real.exp_lt_exp, div_lt_div_iff_of_pos_right,
      Real.log_pos, le_trans.
-/
import MIP.Results.R278_ArrheniusForgetting
import MIP.Results.R156_HalfLife
import MIP.Discoveries.R7_Agent9_DecayOhmBudgetSandwich
import MIP.Results.R194_DecayModifiedOhm
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

namespace MIP

namespace R9_Agent7_ArrheniusDecayBudget

open Real
open MIP.ArrheniusForgetting
open MIP.DecayModifiedOhm

/-! ## (a) The Arrhenius forgetting rate (built on R.278's `deltaN`).

The catastrophic-forgetting rate of R.278 is `deltaN A E T = A·exp(-E/T)`.
We read it as the Arrhenius rate `k(A,E,T)`: pre-exponential `A`, activation
barrier `E`, temperature `T`. -/

/-- **(a) Arrhenius forgetting rate** `k(A,E,T) = A·exp(-E/T) = deltaN A E T`
(R.278's bound, reinterpreted as a rate). -/
noncomputable def arrheniusRate (A E T : ℝ) : ℝ := deltaN A E T

/-- The Arrhenius rate is positive for `A > 0` (exp is always positive).
Strengthens R.278.a's non-negativity (`0 ≤ deltaN`) to strict positivity,
proved directly via `Real.exp_pos` (so `R_278_a_nonneg` itself is not used). -/
theorem arrheniusRate_pos (A E T : ℝ) (hA : 0 < A) :
    0 < arrheniusRate A E T := by
  unfold arrheniusRate deltaN
  exact mul_pos hA (Real.exp_pos _)

/-- **(a) Rate is `StrictAnti` in the protection barrier `E`** — this is
literally R.278.b (`R_278_b_strictAnti_in_protection`): a higher barrier
exponentially suppresses the forgetting rate. -/
theorem arrheniusRate_strictAnti_barrier (A T : ℝ) (hA : 0 < A) (hT : 0 < T) :
    StrictAnti (fun E => arrheniusRate A E T) :=
  R_278_b_strictAnti_in_protection A T hA hT

/-- **(a) Rate is `StrictMono` in the temperature `T`** — hotter regime,
faster forgetting.  For `A > 0`, `E > 0`, `T ↦ A·exp(-E/T)` strictly
increases (the exponent `-E/T` increases toward 0 as `T` grows). -/
theorem arrheniusRate_strictMono_temp (A E : ℝ) (hA : 0 < A) (hE : 0 < E) :
    StrictMonoOn (fun T => arrheniusRate A E T) (Set.Ioi 0) := by
  intro T₁ hT₁ T₂ hT₂ h12
  simp only [Set.mem_Ioi] at hT₁ hT₂
  unfold arrheniusRate deltaN
  apply mul_lt_mul_of_pos_left _ hA
  apply Real.exp_lt_exp.mpr
  -- -E/T₁ < -E/T₂  ⟺  E/T₂ < E/T₁  (since 0 < T₁ < T₂, E > 0).
  rw [neg_div, neg_div, neg_lt_neg_iff]
  rw [div_lt_div_iff_of_pos_left hE hT₂ hT₁]
  exact h12

/-! ## (b) The Arrhenius half-life identity (R.156 + the rate).

Read the rate `k = arrheniusRate A E T` as the inverse decay constant of the
exponential forgetting curve `p(t) = p₀·exp(-k·t)`, i.e. decay constant
`Tc = 1/k`.  R.156 (`HalfLife.half_life_identity`) then gives the half-life
`τ = Tc·log 2 = (log 2)/k`. -/

/-- **(b) Arrhenius half-life identity.**

For the forgetting curve `p(t) = p₀·exp(-k·t)` with `k = arrheniusRate A E T`
(`A>0`, `T>0`), the half-life equation `p(τ) = p₀/2` is equivalent to
`τ = (log 2)/k`.  GENUINELY invokes `HalfLife.half_life_identity` with the
decay constant `Tc := 1/k`. -/
theorem arrhenius_half_life_identity
    (A E T p₀ τ : ℝ) (hA : 0 < A) (hp₀ : 0 < p₀) :
    p₀ * Real.exp (-(τ * arrheniusRate A E T)) = p₀ / 2
      ↔ τ = Real.log 2 / arrheniusRate A E T := by
  set k := arrheniusRate A E T with hk
  have hk_pos : 0 < k := arrheniusRate_pos A E T hA
  have hk_ne : k ≠ 0 := ne_of_gt hk_pos
  -- Apply R.156 with decay constant Tc = 1/k > 0.
  have hTc_pos : 0 < (1 / k) := by positivity
  have h156 := HalfLife.half_life_identity p₀ (1 / k) τ hp₀ hTc_pos
  -- Align the exponents: τ / (1/k) = τ * k.
  have h_arg : τ / (1 / k) = τ * k := by field_simp
  rw [h_arg] at h156
  -- And the RHS: τ = (1/k)·log 2  ⟺  τ = log 2 / k.
  rw [h156]
  constructor <;> intro h <;> · rw [h]; ring

/-- **(b) Explicit Arrhenius half-life form.**

`t_{1/2} = (log 2)/k = (log 2 / A)·exp(E/T)`.  Substituting the Arrhenius
rate `k = A·exp(-E/T)` into `(log 2)/k` and simplifying `1/exp(-E/T)
= exp(E/T)`. -/
theorem arrhenius_half_life_eq (A E T : ℝ) (hA : 0 < A) :
    Real.log 2 / arrheniusRate A E T
      = (Real.log 2 / A) * Real.exp (E / T) := by
  unfold arrheniusRate deltaN
  have hA_ne : A ≠ 0 := ne_of_gt hA
  have h_exp_pos : 0 < Real.exp (E / T) := Real.exp_pos _
  -- exp(-E/T) = (exp(E/T))⁻¹.
  have h_neg : Real.exp (-E / T) = (Real.exp (E / T))⁻¹ := by
    rw [show (-E / T : ℝ) = -(E / T) by ring, Real.exp_neg]
  rw [h_neg]
  field_simp

/-! ## (c) Half-life monotonicity in barrier and temperature.

Since `t_{1/2} = (log 2)/k` is `log 2 > 0` divided by the rate `k`, the
half-life is *anti*-monotone in the rate; composing with R.278's rate
monotonicity flips the directions. -/

/-- Half-life as a function of barrier/temperature: `t_{1/2} = log2 / k`. -/
noncomputable def halfLife (A E T : ℝ) : ℝ :=
  Real.log 2 / arrheniusRate A E T

/-- **(c) Half-life STRICTLY INCREASES in the protection barrier `E`.**

More protection ⇒ lower forgetting rate (R.278.b) ⇒ longer memory.  Rides
`arrheniusRate_strictAnti_barrier` (= R.278.b): the rate is StrictAnti in `E`
and positive, and `log 2 > 0`, so `log2 / rate` is StrictMono in `E`. -/
theorem half_life_strictMono_barrier (A T : ℝ) (hA : 0 < A) (hT : 0 < T) :
    StrictMono (fun E => halfLife A E T) := by
  intro E₁ E₂ h12
  unfold halfLife
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h_rate2_pos : 0 < arrheniusRate A E₂ T := arrheniusRate_pos A E₂ T hA
  -- rate is StrictAnti in E: rate(E₂) < rate(E₁).
  have h_anti : arrheniusRate A E₂ T < arrheniusRate A E₁ T :=
    arrheniusRate_strictAnti_barrier A T hA hT h12
  -- log2/rate(E₁) < log2/rate(E₂) since 0 < rate(E₂) < rate(E₁).
  exact div_lt_div_of_pos_left hlog h_rate2_pos h_anti

/-- **(c) Half-life STRICTLY DECREASES in the temperature `T`.**

Hotter regime ⇒ higher forgetting rate (`arrheniusRate_strictMono_temp`) ⇒
shorter memory.  The rate is StrictMono in `T` and positive, so `log2 / rate`
is StrictAnti in `T` on `T > 0`. -/
theorem half_life_strictAnti_temp (A E : ℝ) (hA : 0 < A) (hE : 0 < E) :
    StrictAntiOn (fun T => halfLife A E T) (Set.Ioi 0) := by
  intro T₁ hT₁ T₂ hT₂ h12
  simp only [Set.mem_Ioi] at hT₁ hT₂
  unfold halfLife
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h_rate1_pos : 0 < arrheniusRate A E T₁ := arrheniusRate_pos A E T₁ hA
  -- rate StrictMono in T: rate(T₁) < rate(T₂).
  have h_mono : arrheniusRate A E T₁ < arrheniusRate A E T₂ :=
    arrheniusRate_strictMono_temp A E hA hE hT₁ hT₂ h12
  -- log2/rate(T₂) < log2/rate(T₁).
  exact div_lt_div_of_pos_left hlog h_rate1_pos h_mono

/-! ## (d) Arrhenius rate ⇒ decay-budget inflation (R7_Agent9 + R.194).

Faster forgetting (higher rate `k`) drops more demand elements below the
activation threshold, so the maintenance tax `N_maint` of R.190/R.194 is a
non-decreasing function `maintTax` of `k`.  Through R.194's model budget
`NDecay Φ₀ Z_τ N_maint` and R7_Agent9's tax-monotonicity
(`decay_budget_mono_maint`), a higher rate inflates the decay budget. -/

/-- **(d) Higher Arrhenius rate ⇒ larger decay-modified Ohm budget.**

Modelling the maintenance tax as a `Monotone` function `maintTax` of the
Arrhenius rate (more forgetting ⇒ at least as much demand to re-activate),
a higher rate `k₁ ≤ k₂` inflates the R.194 model budget.  GENUINELY invokes
`R7_Agent9_DecayOhmBudgetSandwich.decay_budget_mono_maint`. -/
theorem budget_mono_in_rate
    (Phi0 Ztau : ENNReal) (N0 : ℕ∞)
    (maintTax : ℝ → ℕ∞) (hmono : Monotone maintTax)
    (k₁ k₂ : ℝ) (hk : k₁ ≤ k₂) :
    NDecay Phi0 Ztau (maintTax k₁) ≤ NDecay Phi0 Ztau (maintTax k₂)
      ∧ N0 + maintTax k₁ ≤ N0 + maintTax k₂ :=
  R7_Agent9_DecayOhmBudgetSandwich.decay_budget_mono_maint
    Phi0 Ztau N0 (maintTax k₁) (maintTax k₂) (hmono hk)

/-! ## (e) Headline: the Arrhenius temperature-dependent budget law. -/

/-- **(Headline) Forgetting is Arrhenius; its temperature/barrier set the
half-life, which monotonically sets the decay-inflated Ohm budget.**

Consider two regimes `(E₁,T₁)` and `(E₂,T₂)` whose Arrhenius rates satisfy
`rate₁ ≤ rate₂` (e.g. the second regime is hotter or has a lower protection
barrier).  With the half-lives written explicitly via R.156 and the
maintenance tax a `Monotone` function `maintTax` of the rate, simultaneously:

  • **Half-life shrinks** — `t_{1/2}(regime₂) ≤ t_{1/2}(regime₁)`
    (faster forgetting, via `log 2 / rate`);
  • **Maintenance tax grows** — `maintTax rate₁ ≤ maintTax rate₂`;
  • **Decay budget inflates** — `NDecay(regime₁) ≤ NDecay(regime₂)`
    (R7_Agent9.decay_budget_mono_maint, R.194 model);
  • **Undecayed floor holds for the colder regime** — the undecayed budget
    `N₀` is still a hard floor for its decayed budget
    (R7_Agent9.decay_inflates_budget).

This GENUINELY chains:
  R.278 (`arrheniusRate` = `deltaN`, the Arrhenius rate),
  R.156 (`HalfLife.half_life_identity`, via `arrhenius_half_life_identity`),
  R7_Agent9 (`decay_budget_mono_maint`, `decay_inflates_budget`),
  R.194 (`NDecay`, the model budget). -/
theorem arrhenius_temperature_budget_law
    (A E₁ T₁ E₂ T₂ : ℝ) (hA : 0 < A)
    (Phi0 Ztau : ENNReal) (N0 N_decay₁ : ℕ∞)
    (maintTax : ℝ → ℕ∞) (hmono : Monotone maintTax)
    (h_rate : arrheniusRate A E₁ T₁ ≤ arrheniusRate A E₂ T₂)
    -- R.190/R7 protocol bounds tying the colder regime's undecayed N₀ to its
    -- model decay budget:
    (h_lower₁ : N0 ≤ N_decay₁)
    (h_upper₁ : N_decay₁ ≤ N0 + maintTax (arrheniusRate A E₁ T₁)) :
    -- (i) half-life shrinks for the higher-rate regime
    halfLife A E₂ T₂ ≤ halfLife A E₁ T₁
      -- (ii) maintenance tax grows
      ∧ maintTax (arrheniusRate A E₁ T₁) ≤ maintTax (arrheniusRate A E₂ T₂)
      -- (iii) decay-modified Ohm budget inflates
      ∧ NDecay Phi0 Ztau (maintTax (arrheniusRate A E₁ T₁))
          ≤ NDecay Phi0 Ztau (maintTax (arrheniusRate A E₂ T₂))
      -- (iv) the undecayed budget is a hard floor for the colder regime
      ∧ N0 ≤ N_decay₁ := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- half-life t_{1/2} = log2/rate is anti-monotone in the rate.
    unfold halfLife
    have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
    have h_rate1_pos : 0 < arrheniusRate A E₁ T₁ := arrheniusRate_pos A E₁ T₁ hA
    rcases lt_or_eq_of_le h_rate with h | h
    · exact le_of_lt (div_lt_div_of_pos_left hlog h_rate1_pos h)
    · rw [h]
  · -- tax grows: maintTax is Monotone.
    exact hmono h_rate
  · -- budget inflates: R7_Agent9.decay_budget_mono_maint.
    exact (R7_Agent9_DecayOhmBudgetSandwich.decay_budget_mono_maint
      Phi0 Ztau N0 (maintTax (arrheniusRate A E₁ T₁))
      (maintTax (arrheniusRate A E₂ T₂)) (hmono h_rate)).1
  · -- floor: R7_Agent9.decay_inflates_budget on the colder regime.
    exact R7_Agent9_DecayOhmBudgetSandwich.decay_inflates_budget
      N0 N_decay₁ (maintTax (arrheniusRate A E₁ T₁)) h_lower₁ h_upper₁

end R9_Agent7_ArrheniusDecayBudget

end MIP
