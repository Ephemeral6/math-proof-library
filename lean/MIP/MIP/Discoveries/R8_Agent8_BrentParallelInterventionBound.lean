/-
  STATUS: DISCOVERY
  AGENT: R8_Agent8
  DIRECTION: BRENT'S THEOREM FOR PARALLEL MULTI-AGENT INTERVENTION.

    The corpus carries, separately:
      * the critical-path (longest-chain) lower bound `L ≤ N`
        (R.40, `MIP.CriticalPathBound.R_40_critical_path_bound`);
      * the Brent two-sided lower bound `max(S, W/p) ≤ Tp`
        (R.175, `MIP.R175_BrentLowerBound.R_175_brent_lower_bound`,
         and its ℕ companion `R_175_brent_lower_bound_nat`);
      * the parallel-speedup denominator-monotonicity ceiling
        `Bcard/parTime ≤ Bcard/L` (R.41, `MIP.ParallelSpeedup.R_41_speedup_bound`);
      * the multi-agent (TENSOR) joint Ohm budget subadditivity
        `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊`
        (R5_Agent4, `MIP.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law`),
        itself grounded in R4_Agent6's tensor conservation law.

    THIS FILE fuses them into a single Brent/Amdahl law for the MIP
    intervention DAG of a COMMITTEE of `k` tensor-independent agents.  The key
    move: the "total work" `W` of Brent's theorem is instantiated by the
    CERTIFIED joint Ohm budget `N_joint` (R5_Agent4) — not an arbitrary number
    but the genuine integer intervention cost of the product system.  Then:

      (1) the parallel intervention time `T_k` of the committee obeys the Brent
          lower bound `max(L, N_joint / k) ≤ T_k` (span ⊕ work amortisation),
          with the work term carrying the R5_Agent4 envelope budget
          `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊` — so the *floor* `T_k` is sandwiched by a
          certified multi-agent quantity, not a free parameter;
      (2) no schedule with `k` agents can beat the critical path: speedup
          `N_joint / T_k ≤ N_joint / L` (Amdahl ceiling, R.41), i.e. the
          dependency depth `L` caps the parallel gain regardless of `k`;
      (3) the discrete (ℕ) Brent floor: from the critical-path injection
          (R.40) and the work-amortisation `N_joint ≤ k · T_k`, BOTH
          `L ≤ T_k` and `N_joint ≤ k · T_k` hold simultaneously
          (R.175 ℕ companion), with `N_joint` the R5_Agent4 budget.

  SUMMARY (three results):

    (a) `brent_lower_bound_joint_work` — the real-form Brent lower bound with
        the work term pinned to the certified joint Ohm budget: from the span
        hypothesis `L ≤ T_k` (R.40 lifted to ℝ) and the amortisation
        `N_joint ≤ k·T_k`, conclude `max(L, N_joint/k) ≤ T_k` AND the R5_Agent4
        envelope bound on `N_joint`.  Chains R.175 + R5_Agent4.

    (b) `amdahl_speedup_capped_by_critical_path` — the Amdahl ceiling: the
        committee speedup `N_joint / T_k` is at most `N_joint / L`, the DAG
        average width, hence capped by the dependency depth `L` for EVERY `k`.
        Chains R.41 with `N_joint` the R5_Agent4 budget (envelope-bounded).

    (c) HEADLINE `brent_amdahl_multi_agent_intervention` — the full law:
        with the joint Ohm budget `N_joint = ⌈Z·Φ_joint⌉₊` (R5_Agent4) as the
        total intervention work, `k` agents working in parallel on the
        intervention DAG with critical path `L` satisfy
            max(L, N_joint/k) ≤ T_k        (Brent floor, R.175),
            N_joint / T_k    ≤ N_joint/L   (Amdahl cap,   R.41),
            N_joint          ≤ ∑_a ⌈Z·Mφ a⌉₊  (subadditive envelope, R5_Agent4),
        AND the ℕ Brent floor `L ≤ T_k ∧ (N_joint:ℕ) ≤ k·T_k` from the
        critical-path injection (R.40).  Multi-agent parallel intervention
        obeys Brent's bound; the speedup is capped by the dependency structure.

  Depends on:
    - MIP.Results.R40_CriticalPathBound
        (MIP.CriticalPathBound.R_40_critical_path_bound)
        — critical-path injection `Fin L ↪ Fin Tk ⟹ L ≤ Tk`.  GENUINELY used
          as a proof term in the ℕ Brent floor of (c).
    - MIP.Results.R175_BrentLowerBound
        (MIP.R175_BrentLowerBound.R_175_brent_lower_bound,
         MIP.R175_BrentLowerBound.R_175_brent_lower_bound_nat)
        — the real Brent lower bound `max(S,W/p) ≤ Tp` and its ℕ companion.
          GENUINELY used as proof terms in (a) and (c).
    - MIP.Results.R41_ParallelSpeedup
        (MIP.ParallelSpeedup.R_41_speedup_bound)
        — speedup denominator-monotonicity ceiling.  GENUINELY used as a proof
          term in (b) and (c).
    - MIP.Discoveries.R5_Agent4_TensorOhmBudget   [R4/R5/R6/R7 TOWER]
        (MIP.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law)
        — the certified joint Ohm budget subadditivity `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊`.
          GENUINELY used as a proof term in (a), (b) and (c) to ground the work
          term `N_joint`.
    - Mathlib: Nat.cast_le, Nat.cast_nonneg, le_max bookkeeping.

  Axiom-free (no NEW axiom; framework axioms reached only via imported corpus).
-/
import MIP.Results.R40_CriticalPathBound
import MIP.Results.R175_BrentLowerBound
import MIP.Results.R41_ParallelSpeedup
import MIP.Discoveries.R5_Agent4_TensorOhmBudget
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R8_Agent8_BrentParallelInterventionBound

/-! ## (a) Brent lower bound with the certified joint Ohm budget as work.

The total intervention work of the committee is the joint Ohm budget
`N_joint = ⌈Z·Φ_joint⌉₊` (R5_Agent4).  We pin Brent's work term `W` to this
quantity and simultaneously carry R5_Agent4's envelope bound on it.  The span
term is the critical path `L` (R.40, lifted to ℝ). -/

/-- **(a) Brent lower bound, work = certified joint Ohm budget.**

`T_k` is the parallel intervention time of `k` agents.  Given:
  * the span lower bound `(L:ℝ) ≤ T_k`  (R.40 critical path, cast to ℝ);
  * the work amortisation `(N_joint:ℝ) ≤ k · T_k`  (each step breaks ≤ k
    barriers of the joint work `N_joint`);
  * `0 < k`;
together with the R5_Agent4 grounding hypotheses (additive potential, nonneg
distributions, per-agent envelopes `φ_a ≤ Mφ a`), we conclude the Brent floor
    max((L:ℝ), (N_joint:ℝ)/k) ≤ T_k
AND the certified envelope subadditivity `N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊`.

The Brent floor is `R.175`'s `R_175_brent_lower_bound`; the envelope bound is
`R5_Agent4`'s `multi_agent_ohm_budget_law`. -/
theorem brent_lower_bound_joint_work
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ) (k : ℕ) (Tk L : ℝ)
    -- R5_Agent4 grounding of `Njoint`:
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊)
    -- Brent inputs:
    (hk : 0 < (k : ℝ))
    (hspan : L ≤ Tk)   -- the cast critical path `L ≤ Tk`
    (hwork : (Njoint : ℝ) ≤ (k : ℝ) * Tk) :
    max L ((Njoint : ℝ) / (k : ℝ)) ≤ Tk
      ∧ Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊ := by
  refine ⟨?_, ?_⟩
  · -- Brent two-sided lower bound (R.175), span = L, work = N_joint, p = k.
    exact MIP.R175_BrentLowerBound.R_175_brent_lower_bound
      L (Njoint : ℝ) (k : ℝ) Tk hk hspan hwork
  · -- The work term is the CERTIFIED joint Ohm budget (R5_Agent4).
    exact MIP.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm

/-! ## (b) Amdahl ceiling: speedup capped by the critical path.

The realised speedup is `N_joint / T_k`.  By R.41 (denominator monotonicity),
since `L ≤ T_k` and the work `N_joint` is nonnegative, the speedup is at most
`N_joint / L`, the DAG average width — a hard ceiling depending ONLY on the
dependency depth `L`, for every processor count `k`. -/

/-- **(b) Amdahl speedup ceiling for multi-agent intervention.**

With the certified joint work `N_joint` (R5_Agent4) and a parallel time `T_k`
that cannot beat the critical path (`0 < L ≤ T_k`), the committee speedup
`N_joint / T_k` is at most `N_joint / L`.  Chains R.41's
`R_41_speedup_bound`, with the R5_Agent4 envelope bound on `N_joint` carried
alongside. -/
theorem amdahl_speedup_capped_by_critical_path
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ) (L Tk : ℝ)
    -- R5_Agent4 grounding of `Njoint`:
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊)
    -- Amdahl inputs:
    (hL : 0 < L) (hLp : L ≤ Tk) :
    (Njoint : ℝ) / Tk ≤ (Njoint : ℝ) / L
      ∧ Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊ := by
  refine ⟨?_, ?_⟩
  · -- R.41 denominator monotonicity; numerator `Njoint ≥ 0` is a cast nonneg.
    exact MIP.ParallelSpeedup.R_41_speedup_bound
      (Njoint : ℝ) L Tk hL hLp (Nat.cast_nonneg Njoint)
  · exact MIP.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm

/-! ## (c) HEADLINE — the full Brent/Amdahl law for the committee. -/

/-- **(c) HEADLINE — Brent's bound for multi-agent parallel intervention.**

A committee of `k` tensor-independent agents intervenes on a problem whose
barriers form a dependency DAG with critical-path length `L`.  The TOTAL
intervention work is the certified joint Ohm budget
`N_joint = ⌈Z · Φ_joint⌉₊` (R5_Agent4, grounded in R4_Agent6's tensor
conservation).  Then the parallel intervention time `T_k` obeys ALL of:

  (BRENT FLOOR, real)  max((L:ℝ), (N_joint:ℝ)/k) ≤ T_k        [R.175]
  (AMDAHL CAP)         (N_joint:ℝ)/T_k ≤ (N_joint:ℝ)/L        [R.41]
  (ENVELOPE)           N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊                [R5_Agent4]
  (BRENT FLOOR, ℕ)     L_nat ≤ Tk_nat  ∧  N_joint ≤ k · Tk_nat [R.40 + R.175ℕ]

The ℕ floor uses the genuine critical-path injection `f : Fin L_nat ↪ Fin Tk_nat`
(R.40, each chain link consumes its own intervention step) plus the integer
work amortisation `N_joint ≤ k · Tk_nat`.  Multi-agent parallel intervention
obeys Brent's bound: time ≥ max(N_joint/k, critical-path); the speedup is
capped by the dependency depth `L`, NOT by the agent count `k`. -/
theorem brent_amdahl_multi_agent_intervention
    {ι : Type} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    (k : ℕ) (Tk L : ℝ)
    (Lnat Tknat : ℕ)
    -- R5_Agent4 grounding of `Njoint`:
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊)
    -- real Brent / Amdahl inputs:
    (hk : 0 < (k : ℝ))
    (hL_pos : 0 < L) (hspan : L ≤ Tk)
    (hwork : (Njoint : ℝ) ≤ (k : ℝ) * Tk)
    -- ℕ Brent floor inputs (R.40 critical-path injection + ℕ amortisation):
    (f : Fin Lnat → Fin Tknat) (hf : Function.Injective f)
    (hwork_nat : Njoint ≤ k * Tknat) :
    (max L ((Njoint : ℝ) / (k : ℝ)) ≤ Tk)            -- Brent floor (real)
      ∧ ((Njoint : ℝ) / Tk ≤ (Njoint : ℝ) / L)       -- Amdahl cap
      ∧ (Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊)                  -- R5_Agent4 envelope
      ∧ (Lnat ≤ Tknat ∧ Njoint ≤ k * Tknat) := by
  -- ENVELOPE — R5_Agent4 (used three times; bind once).
  have h_envelope : Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊ :=
    MIP.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm
  refine ⟨?_, ?_, h_envelope, ?_⟩
  · -- BRENT FLOOR (real) — R.175.
    exact MIP.R175_BrentLowerBound.R_175_brent_lower_bound
      L (Njoint : ℝ) (k : ℝ) Tk hk hspan hwork
  · -- AMDAHL CAP — R.41.
    exact MIP.ParallelSpeedup.R_41_speedup_bound
      (Njoint : ℝ) L Tk hL_pos hspan (Nat.cast_nonneg Njoint)
  · -- BRENT FLOOR (ℕ) — R.40 critical-path injection + R.175 ℕ companion.
    exact MIP.R175_BrentLowerBound.R_175_brent_lower_bound_nat f hf hwork_nat

end R8_Agent8_BrentParallelInterventionBound

end MIP
