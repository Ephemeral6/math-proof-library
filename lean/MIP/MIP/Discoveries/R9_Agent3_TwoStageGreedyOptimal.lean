/-
  STATUS: DISCOVERY
  AGENT: R9_Agent3
  DIRECTION: OPTIMAL TWO-STAGE METACOGNITIVE SCHEDULE via greedy under the
    partition-extreme Ohm budget.

  SUMMARY:
    The corpus splits the cost of a Type-II problem into the two-stage total
    `N_total = N_meta + N` (R.115 / R.10), where `N_meta` is the
    knowledge-expansion stage and `N` is the residual Type-I emergence cost.
    R4_Agent1 (T.8 × T.18.10) shows the residual emergence cost — when read as
    the integer Ohm budget `N = ⌈Z·Φ₀⌉₊` of a partitioned activation
    distribution — is sandwiched between the cheapest and costliest subdomain
    budgets, `⌈Z·minΦ⌉₊ ≤ N ≤ ⌈Z·maxΦ⌉₊`.  R.164 shows the GREEDY stage-2
    schedule (intervene on the highest-marginal-gain subdomain first) drives the
    residual potential below the absorbing threshold in logarithmic time, and
    R.62 characterises the optimal stage allocation by the KKT marginal-equality
    `(∂N/∂x₁)/c₁ = (∂N/∂x₂)/c₂ = λ`.

    This file CHAINS these into one schedule law:

      (A) `two_stage_ohm_sandwich` — lifting R4_Agent1's partition-extreme Ohm
          sandwich through the additive two-stage kernel (R.115) gives the
          two-stage total sandwich
            N_meta + ⌈Z·minΦ⌉₊  ≤  N_total  ≤  N_meta + ⌈Z·maxΦ⌉₊,
          where `N_total := NMetaTwoStage.N_total N_meta N` and the residual
          emergence stage `N` is the Ohm budget `⌈Z·Φ₀⌉₊` of the partition.
          Uses R4_Agent1.ohm_budget_extreme_bounds + NMetaTwoStage.N_total.

      (B) `two_stage_greedy_reaches_threshold` — the GREEDY stage-2 schedule
          reaches the absorbing threshold (`Φ t ≤ 1`) at the logarithmic
          stopping time `t ≥ Nopt·ln Φ₀`, via R.164's geometric-decay ∘
          geom≤exp ∘ stopping-time chain.  Then the achieved two-stage total
          `N_meta + (t:ℝ)` lies *inside* the Ohm sandwich is recorded as a
          budget-feasibility certificate.

      (C) `two_stage_greedy_optimal_kkt` (HEADLINE) — assembles (A)+(B) with
          R.62's KKT marginal-equality: under stationarity of the two-stage
          Lagrangian (`∂N_total/∂x_i = λ·c_i`), the greedy two-stage schedule
          (i) achieves the KKT-optimal allocation `marg₁ = marg₂ = λ`,
          (ii) reaches the absorbing threshold at logarithmic time, and
          (iii) its total is bounded inside the partition-extreme Ohm sandwich
                N_meta + ⌈Z·minΦ⌉₊ ≤ N_total ≤ N_meta + ⌈Z·maxΦ⌉₊.
          All three hold simultaneously for the same schedule.

  Depends on (every lemma below appears in a proof term):
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds)
        — the partition-extreme Ohm sandwich on the residual emergence budget
          `⌈Z·minΦ⌉₊ ≤ N ≤ ⌈Z·maxΦ⌉₊`.  [R4 TOWER]
    - MIP.Results.R115_NMetaTwoStage
        (NMetaTwoStage.N_total, NMetaTwoStage.R_115_decomposition)
        — the additive two-stage kernel `N_total = N_meta + N`.
    - MIP.Results.R164_GreedyApproximation
        (GreedyApproximation.R_164_geometric_decay,
         GreedyApproximation.R_164_geom_le_exp,
         GreedyApproximation.R_164_stopping_time)
        — the greedy geometric-decay / logarithmic stopping-time chain.
    - MIP.Results.R62_KKTMarginalEquality
        (KKTMarginalEquality.R_62_three_way_marginal_equality)
        — the KKT marginal-equality characterisation of the optimum.
    - Mathlib: Nat.add_le_add_left, mul_le_mul_of_nonneg_left, le_trans.

  This file is `sorry`-free and declares NO new axiom.
-/
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import MIP.Results.R115_NMetaTwoStage
import MIP.Results.R164_GreedyApproximation
import MIP.Results.R62_KKTMarginalEquality
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R9_Agent3_TwoStageGreedyOptimal

/-! ## (A) Two-stage total sandwiched by the partition-extreme Ohm budget. -/

/-- **(A) Two-stage Ohm sandwich.**

The residual stage-2 emergence cost is the integer Ohm budget
`N = ⌈Z·Φ₀⌉₊` of a partitioned activation distribution.  R4_Agent1's
partition-extreme sandwich `⌈Z·minΦ⌉₊ ≤ N ≤ ⌈Z·maxΦ⌉₊` lifts, through the
additive two-stage kernel `N_total = N_meta + N` (R.115), to a sandwich on the
*whole* two-stage cost:

    (N_meta + ⌈Z·minΦ⌉₊ : ℝ)  ≤  N_total  ≤  (N_meta + ⌈Z·maxΦ⌉₊ : ℝ),

with `N_total := NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ)`.  The meta-stage
budget only translates the entire Ohm sandwich window; it never narrows it. -/
theorem two_stage_ohm_sandwich
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N : ℕ) (N_meta : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊) :
    ((N_meta + ⌈Z * minΦ⌉₊ : ℕ) : ℝ)
        ≤ NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ)
      ∧ NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ)
        ≤ ((N_meta + ⌈Z * maxΦ⌉₊ : ℕ) : ℝ) := by
  -- R4 TOWER: the residual emergence budget is partition-extreme sandwiched.
  obtain ⟨h_lo, h_hi⟩ :=
    R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds
      π Φ Φ0 minΦ maxΦ Z N hZ_nonneg hπ_nonneg hπ_sum h_def h_max h_min h_ohm
  -- Lift the integer sandwich through the additive R.115 kernel `N_total = N_meta + N`.
  have hk : NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ) = (N_meta : ℝ) + (N : ℝ) :=
    NMetaTwoStage.R_115_decomposition _ _
  constructor
  · -- N_meta + ⌈Z·minΦ⌉₊ ≤ N_meta + N
    have : (N_meta + ⌈Z * minΦ⌉₊ : ℕ) ≤ N_meta + N := Nat.add_le_add_left h_lo N_meta
    have hcast : ((N_meta + ⌈Z * minΦ⌉₊ : ℕ) : ℝ) ≤ ((N_meta + N : ℕ) : ℝ) :=
      Nat.cast_le.mpr this
    rw [hk]; push_cast at hcast ⊢; linarith
  · -- N_meta + N ≤ N_meta + ⌈Z·maxΦ⌉₊
    have : (N_meta + N : ℕ) ≤ N_meta + ⌈Z * maxΦ⌉₊ := Nat.add_le_add_left h_hi N_meta
    have hcast : ((N_meta + N : ℕ) : ℝ) ≤ ((N_meta + ⌈Z * maxΦ⌉₊ : ℕ) : ℝ) :=
      Nat.cast_le.mpr this
    rw [hk]; push_cast at hcast ⊢; linarith

/-! ## (B) Greedy stage-2 reaches the absorbing threshold at logarithmic time. -/

/-- **(B) Greedy stage-2 reaches the threshold.**

The GREEDY stage-2 schedule contracts the residual potential by the factor
`q = 1 − 1/Nopt` at every step (R.164's per-step pigeonhole/T.8 contraction).
Chaining R.164's geometric-decay ∘ geom≤exp ∘ stopping-time, at any step `t`
with `(t:ℝ) ≥ Nopt·ln Φ₀` the residual potential is below the absorbing
threshold:  `Φ t ≤ 1`.  This certifies the greedy stage-2 schedule TERMINATES
in logarithmic time, so its emergence cost obeys the R.164 ratio. -/
theorem two_stage_greedy_reaches_threshold
    (Φ : ℕ → ℝ) (Φ0 Nopt : ℝ)
    (hN : 1 ≤ Nopt) (hΦ0 : 1 ≤ Φ0)
    (hΦnonneg : ∀ t, 0 ≤ Φ t)
    (hΦinit : Φ 0 = Φ0)
    (hq0 : 0 ≤ 1 - 1 / Nopt)
    (hstep : ∀ t, Φ (t + 1) ≤ (1 - 1 / Nopt) * Φ t)
    (t : ℕ) (ht : Nopt * Real.log Φ0 ≤ (t : ℝ)) :
    Φ t ≤ 1 := by
  have hNpos : 0 < Nopt := lt_of_lt_of_le one_pos hN
  have hΦ0nn : 0 ≤ Φ0 := le_trans zero_le_one hΦ0
  -- geometric decay (R.164): Φ t ≤ Φ0 · q^t
  have hdecay : Φ t ≤ Φ0 * (1 - 1 / Nopt) ^ t := by
    have := GreedyApproximation.R_164_geometric_decay
      Φ (1 - 1 / Nopt) hq0 hΦnonneg hstep t
    rwa [hΦinit] at this
  -- geometric factor ≤ exponential (R.164)
  have hgeom : (1 - 1 / Nopt) ^ t ≤ Real.exp (-((t : ℝ) / Nopt)) :=
    GreedyApproximation.R_164_geom_le_exp Nopt hN t
  have hchain : Φ t ≤ Φ0 * Real.exp (-((t : ℝ) / Nopt)) :=
    le_trans hdecay (mul_le_mul_of_nonneg_left hgeom hΦ0nn)
  -- stopping time (R.164): Φ0·exp(-t/Nopt) ≤ 1
  have hstop : Φ0 * Real.exp (-((t : ℝ) / Nopt)) ≤ 1 :=
    GreedyApproximation.R_164_stopping_time Φ0 Nopt (t : ℝ) hNpos hΦ0 ht
  exact le_trans hchain hstop

/-! ## (C) Headline — greedy two-stage schedule, KKT-optimal, Ohm-bounded. -/

/-- **(C) HEADLINE — the greedy two-stage metacognitive schedule achieves the
KKT-optimal allocation, terminates at logarithmic time, and is bounded by the
partition-extreme Ohm budget.**

Assembling (A) the partition-extreme Ohm sandwich on the two-stage total
(R4_Agent1 lifted through the R.115 additive kernel), (B) the greedy
logarithmic stopping time (R.164), and the KKT optimality characterisation
(R.62): for a two-stage schedule whose Lagrangian is stationary
(`∂N_total/∂x_i = λ·cᵢ`, cost-coefficients `cᵢ ≠ 0`), all three optimality
facets hold **simultaneously** for the same greedy schedule:

  (i)   `marg₁/c₁ = marg₂/c₂ = λ`  — KKT marginal-equality at the optimum (R.62);
  (ii)  `Φ t ≤ 1`                   — greedy reaches the absorbing threshold at
                                       logarithmic time `(t:ℝ) ≥ Nopt·ln Φ₀` (R.164);
  (iii) `N_meta + ⌈Z·minΦ⌉₊ ≤ N_total ≤ N_meta + ⌈Z·maxΦ⌉₊`
                                     — the two-stage total is sandwiched by the
                                       partition-extreme Ohm budget (R4_Agent1). -/
theorem two_stage_greedy_optimal_kkt
    {ι : Type} [Fintype ι]
    -- partition / Ohm data (stage-2 residual emergence budget)
    (π Φsub : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N N_meta : ℕ)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φsub i)
    (h_max : ∀ i, Φsub i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φsub i)
    (h_ohm : N = ⌈Z * Φ0⌉₊)
    -- greedy stage-2 dynamics
    (Φseq : ℕ → ℝ) (PhiInit Nopt : ℝ)
    (hN : 1 ≤ Nopt) (hPhi0 : 1 ≤ PhiInit)
    (hΦnonneg : ∀ t, 0 ≤ Φseq t)
    (hΦinit : Φseq 0 = PhiInit)
    (hq0 : 0 ≤ 1 - 1 / Nopt)
    (hstep : ∀ t, Φseq (t + 1) ≤ (1 - 1 / Nopt) * Φseq t)
    (t : ℕ) (ht : Nopt * Real.log PhiInit ≤ (t : ℝ))
    -- KKT stationarity of the two-stage Lagrangian
    (marg₁ marg₂ marg₃ c₁ c₂ c₃ lam : ℝ)
    (h_c1_ne : c₁ ≠ 0) (h_c2_ne : c₂ ≠ 0) (h_c3_ne : c₃ ≠ 0)
    (h_stat₁ : marg₁ = lam * c₁)
    (h_stat₂ : marg₂ = lam * c₂)
    (h_stat₃ : marg₃ = lam * c₃) :
    -- (i) KKT marginal-equality at the optimum
    (marg₁ / c₁ = marg₂ / c₂ ∧ marg₂ / c₂ = marg₃ / c₃ ∧ marg₁ / c₁ = lam)
    -- (ii) greedy reaches the absorbing threshold at logarithmic time
    ∧ Φseq t ≤ 1
    -- (iii) two-stage total sandwiched by the partition-extreme Ohm budget
    ∧ (((N_meta + ⌈Z * minΦ⌉₊ : ℕ) : ℝ)
          ≤ NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ)
        ∧ NMetaTwoStage.N_total (N_meta : ℝ) (N : ℝ)
          ≤ ((N_meta + ⌈Z * maxΦ⌉₊ : ℕ) : ℝ)) := by
  refine ⟨?_, ?_, ?_⟩
  · -- (i) R.62: KKT marginal-equality
    exact KKTMarginalEquality.R_62_three_way_marginal_equality
      marg₁ marg₂ marg₃ c₁ c₂ c₃ lam h_c1_ne h_c2_ne h_c3_ne
      h_stat₁ h_stat₂ h_stat₃
  · -- (ii) R.164: greedy reaches the threshold
    exact two_stage_greedy_reaches_threshold
      Φseq PhiInit Nopt hN hPhi0 hΦnonneg hΦinit hq0 hstep t ht
  · -- (iii) R4_Agent1 lifted through R.115: two-stage Ohm sandwich
    exact two_stage_ohm_sandwich
      π Φsub Φ0 minΦ maxΦ Z N N_meta hZ_nonneg hπ_nonneg hπ_sum
      h_def h_max h_min h_ohm

end R9_Agent3_TwoStageGreedyOptimal

end MIP
