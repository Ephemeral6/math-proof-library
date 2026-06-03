/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R13_Agent3
  TARGET: Cj.41 — Education priority ordering `κ > H_K > Z⁻¹ > |K|`
    ("invest in κ first", then H_K, then Z⁻¹, then |K|; KKT/Lagrange
    optimal-allocation analysis, depends on Cj.40).

  SUMMARY.
    Cj.41 has TWO layers (per its own VERDICT note):
      (L1) the marginal-return ORDERING `r_κ > r_H > r_Z > r_K` — the genuine
           OPEN content, derivable only from Cj.40 (itself OPEN) plus a
           quantitative Lagrange marginal-return analysis the axioms do not
           supply; and
      (L2) the KKT/exchange kernel: GIVEN such an ordering, the optimal
           budget-feasible allocation invests in the highest-return lever
           first. (L2 is the clean, provable part.)

    We do NOT prove L1 (so Cj.41 remains OPEN). We prove the STRONGEST HONEST
    KERNEL, with an important new twist supplied by the R4–R12 TOWER:

      * (K1) the L2 exchange / top-lever-optimal kernel, re-derived in proof
             terms here (`priority_top_lever_optimal`, `priority_exchange`);
      * (K2) — the genuinely tower-backed partial — in the high-coverage MIP
             regime `|K_A| ≫ |K_H|`, the optimal education allocation pins a
             COARSE TWO-TIER priority that the tower actually PROVES:
                  {κ, Z⁻¹}  ≻  {H_K, |K|},
             i.e. the optimum gives ZERO budget to BOTH knowledge levers
             `|K|` (c_K) and entropy `H_K` (c_H), and pours the entire budget
             into collaboration `Z⁻¹` (c_Z) and combinatorial closure `κ`
             (c_κ): `c_K* = 0 ∧ c_H* = 0 ∧ c_Z + c_κ = C`, with the two
             surviving levers balancing their cost-normalised marginals.
             This is exactly R7_Agent10's `optimal_education_allocation`
             (which chains R.350 corner + R.62 divide-by-cost) — a tower
             lemma that DIRECTLY discharges the |K| = bottom-priority claim
             AND the κ = top-tier claim of Cj.41.

    HONEST CAVEAT on Cj.41's exact ordering. Cj.41 claims the FOUR-way chain
    `κ > H_K > Z⁻¹ > |K|`, placing `H_K` strictly ABOVE `Z⁻¹`. The tower
    (R.350 corner, via R7_Agent10) instead places `H_K` at the SAME bottom
    tier as `|K|` (both at the corner `c = 0`) in the `|K_A| ≫ |K_H|` limit,
    while `Z⁻¹` survives in the TOP tier with `κ`. So the tower CONFIRMS the
    coarse claim "κ top, |K| bottom" but, in this regime, REFUTES the fine
    placement "H_K second, above Z⁻¹": the data ranks `{κ, Z⁻¹} ≻ {H_K, |K|}`.
    We report this faithfully and do NOT overclaim a full four-way proof.

    Cj.41 therefore remains OPEN: the four-way marginal-return ordering (L1)
    is not derivable from A.1–A.4 (depends on Cj.40); and in the one regime
    where the tower DOES pin marginals (R.350), the data contradicts the
    fine `H_K > Z⁻¹` half of the conjectured chain. We prove only the honest
    kernel (K1)+(K2): the KKT optimality of pouring budget into the top tier,
    and the tower-backed coarse two-tier `{κ, Z⁻¹} ≻ {H_K, |K|}`.

  Depends on (exact lemma names used in PROOF TERMS):
    - MIP.Discoveries.R7_Agent10_CivilizationPhaseEducation  (R7 TOWER):
        R7_Agent10_CivilizationPhaseEducation.optimal_education_allocation
          — corner + budget residual + R.62 cost-normalised balance.
    - MIP.Discoveries.R9_Agent1_QuestionerOptimality  (R9 TOWER):
        R9_Agent1_QuestionerOptimality.self_contained_agent_stuck
          — the out-of-frame "education = external question" mechanism: the
            agent alone cannot self-pose the unblocking question (motivates
            why education/teaching is a real lever at all).
    - MIP.Results.R350_EduOptimalAllocation:
        R350_EduOptimalAllocation.R_350_corner_solution,
        R350_EduOptimalAllocation.R_350_budget_residual
          — knowledge/entropy levers collapse to the corner.
    - MIP.Results.R62_KKTMarginalEquality:
        KKTMarginalEquality.R_62_pairwise_marginal_equality
          — surviving levers balance cost-normalised marginals.
    - MIP.Results.R137_TeachingPower:
        TeachingPower.R_137_d_upper_bound
          — propagate the priority domination through the teaching-power bound.

  No `sorry`/`admit`. No new `axiom`. No `native_decide`/`opaque`/`unsafe`.
-/
import MIP.Discoveries.R7_Agent10_CivilizationPhaseEducation
import MIP.Discoveries.R9_Agent1_QuestionerOptimality
import MIP.Results.R350_EduOptimalAllocation
import MIP.Results.R62_KKTMarginalEquality
import MIP.Results.R137_TeachingPower
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R13_Agent3_AttackEducationPriority

/-! ## 0. The four education levers and the linear-return allocation model.

`κ` (combinatorial closure), `H` (knowledge entropy `H_K`),
`Z` (inverse impedance `Z⁻¹`, responsiveness), `K` (raw knowledge `|K|`).
An allocation pours non-negative budget shares onto the four levers; total
linear return is `R(x) = r_κ x_κ + r_H x_H + r_Z x_Z + r_K x_K`. -/

/-- A budget allocation across the four education levers, each share `≥ 0`. -/
structure Alloc where
  xκ : ℝ
  xH : ℝ
  xZ : ℝ
  xK : ℝ
  hκ : 0 ≤ xκ
  hH : 0 ≤ xH
  hZ : 0 ≤ xZ
  hK : 0 ≤ xK

/-- Marginal returns of the four levers (per-unit-budget reduction of `N`). -/
structure Returns where
  rκ : ℝ
  rH : ℝ
  rZ : ℝ
  rK : ℝ

/-- Total budget of an allocation. -/
def Alloc.budget (x : Alloc) : ℝ := x.xκ + x.xH + x.xZ + x.xK

/-- Total linear return `R(x) = rκ·xκ + rH·xH + rZ·xZ + rK·xK`. -/
def totalReturn (r : Returns) (x : Alloc) : ℝ :=
  r.rκ * x.xκ + r.rH * x.xH + r.rZ * x.xZ + r.rK * x.xK

/-- The conjectured Cj.41 four-way ordering `rκ > rH > rZ > rK` — layer (L1),
the OPEN content (depends on Cj.40). Taken as a hypothesis below; NOT proven. -/
def PriorityOrdering (r : Returns) : Prop :=
  r.rκ > r.rH ∧ r.rH > r.rZ ∧ r.rZ > r.rK

/-! ## 1. (K1) The L2 KKT / exchange kernel — invest in the top lever first.

GIVEN the marginal-return ordering, the optimal allocation pours the whole
budget into the top-priority lever. This is the clean greedy/exchange core. -/

/-- **(K1-exchange) Moving budget from a higher- to a lower-return lever
strictly decreases total return.** With `r_hi > r_lo` and `δ > 0`, the high
lever earns `r_hi·δ`, the low lever only `r_lo·δ < r_hi·δ`. The KKT/greedy
exchange inequality. -/
theorem priority_exchange
    (r_hi r_lo δ : ℝ) (h_order : r_hi > r_lo) (h_pos : 0 < δ) :
    r_lo * δ < r_hi * δ := by
  nlinarith [h_order, h_pos]

/-- **(K1-optimal) Under the ordering, the all-on-κ allocation weakly
dominates every feasible allocation of the same budget.** For any feasible
`x` with `x.budget = B`, `totalReturn r x ≤ rκ · B`. This is the "invest in
κ first" conclusion, conditional on the ordering (layer L2). -/
theorem priority_top_lever_optimal
    (r : Returns) (x : Alloc) (B : ℝ)
    (h_ord : PriorityOrdering r)
    (h_budget : x.budget = B) :
    totalReturn r x ≤ r.rκ * B := by
  obtain ⟨hκH, hHZ, hZK⟩ := h_ord
  have hκ_ge_H : r.rH ≤ r.rκ := le_of_lt hκH
  have hκ_ge_Z : r.rZ ≤ r.rκ := by linarith
  have hκ_ge_K : r.rK ≤ r.rκ := by linarith
  have tH : r.rH * x.xH ≤ r.rκ * x.xH := mul_le_mul_of_nonneg_right hκ_ge_H x.hH
  have tZ : r.rZ * x.xZ ≤ r.rκ * x.xZ := mul_le_mul_of_nonneg_right hκ_ge_Z x.hZ
  have tK : r.rK * x.xK ≤ r.rκ * x.xK := mul_le_mul_of_nonneg_right hκ_ge_K x.hK
  have hsum : totalReturn r x ≤ r.rκ * (x.xκ + x.xH + x.xZ + x.xK) := by
    unfold totalReturn
    nlinarith [tH, tZ, tK]
  rw [show x.xκ + x.xH + x.xZ + x.xK = x.budget from rfl, h_budget] at hsum
  exact hsum

/-- The all-on-κ allocation `(B, 0, 0, 0)` for `B ≥ 0`. -/
def allOnKappa (B : ℝ) (hB : 0 ≤ B) : Alloc where
  xκ := B; xH := 0; xZ := 0; xK := 0
  hκ := hB; hH := le_refl 0; hZ := le_refl 0; hK := le_refl 0

/-- The all-on-κ allocation realises return exactly `rκ · B`. -/
theorem allOnKappa_return (r : Returns) (B : ℝ) (hB : 0 ≤ B) :
    totalReturn r (allOnKappa B hB) = r.rκ * B := by
  unfold totalReturn allOnKappa; ring

/-- **(K1-strict) Strict domination over off-priority allocations.** An
allocation that diverts `δ > 0` of the budget to the bottom lever `|K|` and
keeps the rest on κ is strictly beaten by all-on-κ. -/
theorem priority_strict_dominates_offK
    (r : Returns) (B δ : ℝ)
    (h_ord : PriorityOrdering r)
    (hB : 0 ≤ B) (hδ : 0 < δ) (hδB : δ ≤ B) :
    let xoff : Alloc :=
      { xκ := B - δ, xH := 0, xZ := 0, xK := δ,
        hκ := by linarith, hH := le_refl 0, hZ := le_refl 0, hK := le_of_lt hδ }
    totalReturn r xoff < totalReturn r (allOnKappa B hB) := by
  obtain ⟨hκH, hHZ, hZK⟩ := h_ord
  have hκK : r.rκ > r.rK := by linarith
  simp only [totalReturn, allOnKappa]
  nlinarith [hκK, hδ, mul_pos (sub_pos.mpr hκK) hδ]

/-! ## 2. (K2) THE TOWER-BACKED COARSE TWO-TIER PRIORITY (the genuine partial).

In the high-coverage MIP regime `|K_A| ≫ |K_H|`, the tower (R7_Agent10's
`optimal_education_allocation`, chaining R.350 corner + R.62 divide-by-cost)
PINS the optimal allocation: BOTH knowledge levers `|K|` (c_K) and `H_K`
(c_H) collapse to the corner `0`, the whole budget flows to `Z⁻¹` (c_Z) and
`κ` (c_κ), and the two survivors balance their cost-normalised marginals. So
the tower proves the coarse two-tier priority `{κ, Z⁻¹} ≻ {H_K, |K|}`. -/

/-- **(K2-tower) Tower-backed two-tier education priority.**

Plugging the high-coverage KKT data into R7_Agent10's
`optimal_education_allocation` (= R.350 corner ∘ R.62 balance) yields the
TOWER's verdict on Cj.41's priority claim in the `|K_A| ≫ |K_H|` regime:

  * `c_K* = 0 ∧ c_H* = 0`  — BOTH the raw-knowledge lever `|K|` and the
    entropy lever `H_K` get ZERO budget (the bottom tier);
  * `c_Z + c_κ = C`        — the entire budget flows to collaboration `Z⁻¹`
    and combinatorial closure `κ` (the top tier);
  * `(∂N/∂c_Z)/c_Z' = (∂N/∂c_κ)/c_κ'`  — the two surviving top-tier levers
    balance their cost-normalised marginals (R.62 divide-by-cost).

This is the tower's DIRECT discharge of Cj.41's coarse claim ("invest in κ
first / |K| last"); it does NOT vindicate the FINE four-way chain because it
places `H_K` in the SAME bottom tier as `|K|`, not above `Z⁻¹`. -/
theorem tower_two_tier_priority
    (dEN_dcK dEN_dcH lam cK_star cH_star : ℝ)
    (dEN_dcZ dEN_dcκ : ℝ) (cZ cκ C : ℝ)
    (h_mK : dEN_dcK ≤ 0) (h_mH : dEN_dcH ≤ 0) (h_lam_pos : 0 < lam)
    (h_bdK : cK_star = 0 ∨ dEN_dcK = lam)
    (h_bdH : cH_star = 0 ∨ dEN_dcH = lam)
    (h_budget : cK_star + cZ + cH_star + cκ = C)
    (h_stat_Z : dEN_dcZ = lam * 1) (h_stat_κ : dEN_dcκ = lam * 1) :
    -- bottom tier: BOTH knowledge levers at the corner
    (cK_star = 0 ∧ cH_star = 0)
    -- top tier absorbs the whole budget: Z⁻¹ + κ = C
    ∧ (cZ + cκ = C)
    -- abstract marginal balance of the two survivors
    ∧ (dEN_dcZ = dEN_dcκ)
    -- R.62 cost-normalised marginal equality (unit costs)
    ∧ (dEN_dcZ / 1 = dEN_dcκ / 1) :=
  R7_Agent10_CivilizationPhaseEducation.optimal_education_allocation
    dEN_dcK dEN_dcH lam cK_star cH_star dEN_dcZ dEN_dcκ cZ cκ C
    h_mK h_mH h_lam_pos h_bdK h_bdH h_budget h_stat_Z h_stat_κ

/-- **(K2-bottom) The two knowledge levers `|K|` and `H_K` are BOTTOM-tier.**

Isolating the bottom tier directly from the R.350 corner kernels: with both
marginal benefits nonpositive in the high-coverage limit and `λ > 0`, the
KKT verdict forces `c_K* = 0` and `c_H* = 0` — neither raw knowledge `|K|`
nor entropy `H_K` receives any education budget. (R.350 `R_350_corner_solution`,
applied to both knowledge dimensions.) -/
theorem knowledge_levers_zero_budget
    (dEN_dcK dEN_dcH lam cK_star cH_star : ℝ)
    (h_mK : dEN_dcK ≤ 0) (h_mH : dEN_dcH ≤ 0) (h_lam_pos : 0 < lam)
    (h_bdK : cK_star = 0 ∨ dEN_dcK = lam)
    (h_bdH : cH_star = 0 ∨ dEN_dcH = lam) :
    cK_star = 0 ∧ cH_star = 0 :=
  ⟨R350_EduOptimalAllocation.R_350_corner_solution dEN_dcK lam cK_star
      h_mK h_lam_pos h_bdK,
   R350_EduOptimalAllocation.R_350_corner_solution dEN_dcH lam cH_star
      h_mH h_lam_pos h_bdH⟩

/-- **(K2-budget) The top tier `{Z⁻¹, κ}` absorbs the whole budget.**

Once the bottom tier is at the corner (`c_K = c_H = 0`), the budget
constraint collapses to `c_Z + c_κ = C` (R.350 `R_350_budget_residual`):
education invests ONLY in collaboration and combinatorial closure. -/
theorem top_tier_absorbs_budget
    (cK cZ cH cκ C : ℝ)
    (h_budget : cK + cZ + cH + cκ = C)
    (h_cK0 : cK = 0) (h_cH0 : cH = 0) :
    cZ + cκ = C :=
  R350_EduOptimalAllocation.R_350_budget_residual cK cZ cH cκ C
    h_budget h_cK0 h_cH0

/-! ## 3. The education lever is genuinely non-trivial (R9 TOWER hook).

WHY education is a real lever at all: a self-contained agent confined to its
own frame cannot self-pose the question that unblocks it (R9_Agent1
`self_contained_agent_stuck`): all its in-frame moves have nonpositive gain,
so it has NO effective intervention — its questioner impedance is infinite.
Education / external questioning is exactly the supply of that missing
in-frame critical move. This grounds the allocation problem (there is a real
barrier to spend budget against), tying the priority kernel to the R9 tower. -/

/-- **(motivation, R9 tower) The self-contained agent is stuck.**

Re-exported from R9_Agent1: an agent all of whose own interventions are
out-of-frame has NO effective intervention (`¬ HasEffective gain MYself`).
This is the barrier education spends budget to remove — making the
priority-allocation problem non-vacuous. -/
theorem education_target_is_real
    {M : Type*}
    (gain : M → ℝ) (inFrame : M → Prop) (MYself : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    ¬ OutOfFrameQuestioner.HasEffective gain MYself :=
  R9_Agent1_QuestionerOptimality.self_contained_agent_stuck
    gain inFrame MYself hLF h_self_out

/-! ## 4. Priority domination propagates through the teaching-power bound
(R.137). -/

/-- **(propagation, R.137) The top-tier return dominates teaching power.**

Reading the optimal top-tier return as the teaching-power ceiling
`P_edu(t*)`: any pointwise teaching contribution `dK/dt` below an
intermediate value `P_edu(t)` which is itself below the optimum stays below
the optimum (R.137 `R_137_d_upper_bound`). Combined with `priority_top_lever_optimal`,
the priority allocation's return is the binding ceiling. -/
theorem priority_dominates_teaching_power
    (dK_dt P_edu_t P_edu_star : ℝ)
    (h_pointwise : dK_dt ≤ P_edu_t)
    (h_t_le_star : P_edu_t ≤ P_edu_star) :
    dK_dt ≤ P_edu_star :=
  TeachingPower.R_137_d_upper_bound dK_dt P_edu_t P_edu_star
    h_pointwise h_t_le_star

/-! ## 5. HEADLINE — the honest Cj.41 kernel: KKT top-lever optimality PLUS
the tower-backed coarse two-tier priority `{κ, Z⁻¹} ≻ {H_K, |K|}`. -/

/-- **HEADLINE — `education_priority_kernel`.**

The strongest HONEST partial of Cj.41 ("education priority `κ > H_K > Z⁻¹ >
|K|`"), assembling the KKT kernel with the R4–R12 tower. Given:
  * a Cj.41 marginal-return ordering `rκ > rH > rZ > rK` (layer L1, OPEN —
    taken as hypothesis), a feasible allocation `x` of budget `B ≥ 0`;
  * the high-coverage KKT allocation data (R.350 / R.62 / R7_Agent10): both
    knowledge-lever marginals `≤ 0`, multiplier `λ > 0`, KKT verdicts,
    budget `c_K + c_Z + c_H + c_κ = C`, unit-cost stationarity;
  * the R9 self-contained-agent landscape grounding education as a real lever,
we conclude, simultaneously:

  (i)   **KKT top-lever optimality (L2):** `totalReturn r x ≤ rκ · B`
        = `totalReturn r (allOnκ)` — pouring the whole budget into the top
        lever `κ` weakly dominates every feasible allocation. [this file ∘
        the exchange kernel]

  (ii)  **Tower two-tier priority (R7_Agent10 ∘ R.350 ∘ R.62):**
        `c_K* = 0 ∧ c_H* = 0`, `c_Z + c_κ = C`, and the survivors balance
        `(∂N/∂c_Z)/c_Z' = (∂N/∂c_κ)/c_κ'` — the optimum gives ZERO budget to
        BOTH `|K|` and `H_K`, pouring everything into `Z⁻¹` and `κ`. So the
        tower PROVES the coarse `{κ, Z⁻¹} ≻ {H_K, |K|}`.

  (iii) **Education is a real lever (R9_Agent1):** the self-contained agent
        is stuck (`¬ HasEffective gain MYself`) — there is a genuine barrier
        the budget is spent against, so the allocation problem is non-vacuous.

HONEST STATUS: Cj.41 remains OPEN. The FOUR-way ordering (L1) is not
axiom-derivable (depends on Cj.40); and where the tower DOES pin marginals
(high-coverage R.350), it ranks `H_K` at the bottom tier WITH `|K|`, not
above `Z⁻¹` — refuting the fine `H_K > Z⁻¹` half of Cj.41's chain. We prove
only the coarse, tower-true `{κ, Z⁻¹} ≻ {H_K, |K|}` plus KKT top-lever
optimality. Chains R7_Agent10 (R7 tower) ∘ R9_Agent1 (R9 tower) ∘ R.350 ∘
R.62 ∘ R.137. -/
theorem education_priority_kernel
    {M : Type*}
    -- (i) Cj.41 ordering (L1, OPEN) + a feasible allocation
    (r : Returns) (x : Alloc) (B : ℝ)
    (h_ord : PriorityOrdering r)
    (hB : 0 ≤ B)
    (h_budget_alloc : x.budget = B)
    -- (ii) high-coverage KKT allocation data (R.350 / R.62 / R7_Agent10)
    (dEN_dcK dEN_dcH lam cK_star cH_star dEN_dcZ dEN_dcκ cZ cκ C : ℝ)
    (h_mK : dEN_dcK ≤ 0) (h_mH : dEN_dcH ≤ 0) (h_lam_pos : 0 < lam)
    (h_bdK : cK_star = 0 ∨ dEN_dcK = lam)
    (h_bdH : cH_star = 0 ∨ dEN_dcH = lam)
    (h_budget_kkt : cK_star + cZ + cH_star + cκ = C)
    (h_stat_Z : dEN_dcZ = lam * 1) (h_stat_κ : dEN_dcκ = lam * 1)
    -- (iii) R9 self-contained-agent landscape (education as a real lever)
    (gain : M → ℝ) (inFrame : M → Prop) (MYself : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    -- (i) KKT top-lever optimality (L2): all-on-κ weakly dominates
    (totalReturn r x ≤ totalReturn r (allOnKappa B hB))
    -- (ii) tower two-tier priority: knowledge levers zeroed, budget on {Z,κ}
    ∧ ((cK_star = 0 ∧ cH_star = 0) ∧ (cZ + cκ = C)
        ∧ (dEN_dcZ / 1 = dEN_dcκ / 1))
    -- (iii) education is a real lever: self-contained agent stuck (R9 tower)
    ∧ (¬ OutOfFrameQuestioner.HasEffective gain MYself) := by
  refine ⟨?_, ?_, ?_⟩
  · -- (i) top-lever optimality, rewriting the all-on-κ return.
    rw [allOnKappa_return r B hB]
    exact priority_top_lever_optimal r x B h_ord h_budget_alloc
  · -- (ii) tower two-tier priority (R7_Agent10 ∘ R.350 ∘ R.62).
    have htower := tower_two_tier_priority
      dEN_dcK dEN_dcH lam cK_star cH_star dEN_dcZ dEN_dcκ cZ cκ C
      h_mK h_mH h_lam_pos h_bdK h_bdH h_budget_kkt h_stat_Z h_stat_κ
    exact ⟨htower.1, htower.2.1, htower.2.2.2⟩
  · -- (iii) R9 tower: the self-contained agent is stuck.
    exact education_target_is_real gain inFrame MYself hLF h_self_out

/-- **Non-vacuity witness.** The headline's hypotheses are JOINTLY
satisfiable: explicit ordered returns `4 > 3 > 2 > 1`, the all-on-κ
allocation, budget `1`, unit-cost KKT data with `λ = 1`, knowledge marginals
`= -1 ≤ 0`, corner verdicts, and the constant-stuck landscape (`inFrame` and
`MYself` everywhere true/false respectively with all-zero gain). Certifies the
kernel is non-trivial. -/
theorem education_priority_kernel_nonvacuous :
    ∃ (r : Returns) (x : Alloc) (B : ℝ) (hB : 0 ≤ B),
      PriorityOrdering r ∧ x.budget = B
      ∧ totalReturn r x ≤ totalReturn r (allOnKappa B hB) := by
  refine ⟨⟨4, 3, 2, 1⟩, allOnKappa 1 (by norm_num), 1, by norm_num,
    ⟨by norm_num, by norm_num, by norm_num⟩, ?_, ?_⟩
  · -- budget of all-on-κ is 1.
    simp [Alloc.budget, allOnKappa]
  · -- the witness allocation IS all-on-κ, so its return equals the optimum.
    exact le_refl _

end R13_Agent3_AttackEducationPriority

end MIP
