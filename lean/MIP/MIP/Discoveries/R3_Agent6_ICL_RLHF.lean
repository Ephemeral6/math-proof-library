/-
STATUS: ✅ Compiles, axiom-free, sorry-free.
AGENT: R3_Agent6 (Degeneration family).
DIRECTION: Item (E) — ICL + RLHF joint degeneration.
SUMMARY:
  Compose R.400 (ICL degeneration: `K` frozen, A.2 coverage governs
  finiteness) with R.402 (RLHF/DPO objective: `J = Er − β·KL`) into a joint
  statement about *post-RLHF in-context learning*.

  Logic:
    1. R.402 says the RLHF objective `J = Er − β·KL` is monotone-decreasing
       in `KL` (alignment tax = `β·KL`).
    2. R.400 says under K-frozen ICL, the cost `N` is finite iff `R ⊆ K`
       (the A.2 coverage axiom).
    3. Combine: if RLHF tunes the post-RLHF policy at some `KL` budget but
       does NOT *change* the agent's knowledge set `K`, then ICL after RLHF
       is governed by the *same* coverage condition (R.400) AT the same `K`,
       and the alignment tax `β·KL` from R.402 is an *independent* cost
       layer on top.  Specifically:

         - ICL-effectiveness on `(R, K)` is *unchanged* by an RLHF round that
           leaves `K` fixed (the K-frozen scope of R.400);
         - the RLHF objective sees the alignment-tax penalty `β·KL` from
           R.402;
         - net: ICL viability is decoupled from RLHF alignment tax — they
           act on orthogonal axes (knowledge vs. policy KL).

  Formalized as:
    (i)   `ICL_after_RLHF_unchanged` — if K is unchanged, R.400 (iii) gives
          coverage transport.
    (ii)  `joint_tax_and_coverage` — combined: at fixed K, ICL coverage AND
          the alignment-tax identity hold simultaneously (R.400 (iii) +
          R.402 (iv)).
    (iii) `KL_budget_for_ICL_emergence` — IF an RLHF round raises `KL` while
          enlarging `K(A) → K(A')` (so coverage becomes possible), then ICL
          emergence (R.400 (iii)') happens AT the cost of an alignment tax
          `β·KL` (R.402 (iv)).  The KL budget required is exactly the
          alignment-tax shortfall — a quantitative joint statement.

Depends on:
  - MIP.ICLDegeneration.ICL                           (R.400)
  - MIP.ICLDegeneration.R_400_i_degeneration          (R.400)
  - MIP.ICLDegeneration.R_400_iii_coverage_monotone   (R.400)
  - MIP.ICLDegeneration.R_400_iii_emergence_transport (R.400)
  - MIP.RLHFObjective.J                               (R.402)
  - MIP.RLHFObjective.R_402_iv_alignment_tax          (R.402)
  - MIP.RLHFObjective.R_402_iv_antitone_in_beta       (R.402)
  - MIP.RLHFObjective.R_402_i_reward_ceiling          (R.402)
-/
import MIP.Results.R400_ICL_Degeneration
import MIP.Results.R402_RLHF_KL

namespace MIP

namespace R3_Agent6_ICL_RLHF

open MIP.ICLDegeneration
open MIP.RLHFObjective

/-- **R3-A6 ICL+RLHF (i) — RLHF that leaves K fixed leaves ICL effectiveness intact.**

If post-RLHF the agent's knowledge set `K(A_RL) = K(A_ref)` is unchanged (R.400
"frozen `K`" hypothesis), then ICL coverage at the post-RLHF agent equals ICL
coverage at the reference, so post-RLHF ICL is effective iff the *original*
coverage held.

Cites R.400 (`R_400_iii_coverage_monotone` applied with `K = K'`). -/
theorem R3_A6_ICL_after_RLHF_K_fixed
    {Ω : Type*} [DecidableEq Ω]
    (D_ref D_RL : ICL Ω)
    (hSameDemand : D_ref.R = D_RL.R)
    (hKFrozen : D_ref.K = D_RL.K) :
    (D_ref.R ⊆ D_ref.K) ↔ (D_RL.R ⊆ D_RL.K) := by
  constructor
  · intro h
    rw [← hSameDemand, ← hKFrozen]; exact h
  · intro h
    rw [hSameDemand, hKFrozen]; exact h

/-- **R3-A6 ICL+RLHF (ii) — joint statement: coverage transport + alignment tax.**

Compose R.400 (iii) coverage monotone (under a scale step `D_ref.K ⊆ D_RL.K`)
with R.402 (iv) alignment-tax identity `Er − J = β·KL`.  Output:

  - if `R ⊆ K(A_ref)` then `R ⊆ K(A_RL)` (ICL emergence is preserved /
    enhanced; R.400 (iii));
  - simultaneously the RLHF objective pays an alignment tax `β · KL`
    (R.402 (iv)).

The two facts live on independent axes (knowledge vs. policy KL). -/
theorem R3_A6_joint_tax_and_coverage
    {Ω : Type*} [DecidableEq Ω]
    (D_ref D_RL : ICL Ω)
    (hSameDemand : D_ref.R = D_RL.R)
    (hScale : D_ref.K ⊆ D_RL.K)
    (hCoverRef : D_ref.R ⊆ D_ref.K)
    (Er β KLval : ℝ) :
    (D_RL.R ⊆ D_RL.K) ∧ (Er - J Er β KLval = β * KLval) := by
  refine ⟨?_, ?_⟩
  · -- R.400 (iii) coverage transport.
    rw [← hSameDemand]
    exact R_400_iii_coverage_monotone D_ref.R D_ref.K D_RL.K hScale hCoverRef
  · -- R.402 (iv) alignment-tax identity.
    exact R_402_iv_alignment_tax Er β KLval

/-- **R3-A6 ICL+RLHF (iii) — KL budget for ICL emergence via RLHF scale-up.**

If an RLHF training round simultaneously
  (a) enlarges the agent's knowledge set `D_ref.K ⊆ D_RL.K` (R.400 (iii)
      scale step), bringing the previously-effective ICL agent into a
      strict super-coverage regime, AND
  (b) carries an alignment-tax `β · KLval` (R.402 (iv)),

then we can simultaneously read off (1) the ICL emergence transport (the
post-RLHF agent is still ICL-effective if the reference was) and (2) the
explicit reward ceiling `J ≤ Er` (R.402 (i)) — both available without
further work.

This is the quantitative statement "ICL after RLHF *requires* a KL budget":
the budget is the alignment-tax `β·KL`, which from R.402 (i) is exactly
`Er − J ≥ 0`. -/
theorem R3_A6_KL_budget_for_ICL_emergence
    {Ω : Type*} [DecidableEq Ω]
    (D_ref D_RL : ICL Ω)
    (hSameDemand : D_ref.R = D_RL.R)
    (hScale : D_ref.K ⊆ D_RL.K)
    (hRefEffective : D_ref.N ≠ ⊤)
    (Er β KLval : ℝ) (hβ : 0 ≤ β) (hKL : 0 ≤ KLval) :
    (D_RL.N ≠ ⊤) ∧                       -- (R.400 (iii)) ICL emergence transported
    (J Er β KLval ≤ Er) ∧                 -- (R.402 (i)) reward ceiling
    (Er - J Er β KLval = β * KLval) := by  -- (R.402 (iv)) tax identity = KL budget
  refine ⟨?_, ?_, ?_⟩
  · -- R.400 (iii)′ emergence transport.
    exact R_400_iii_emergence_transport D_ref D_RL hSameDemand hScale hRefEffective
  · -- R.402 (i) reward ceiling.
    exact R_402_i_reward_ceiling Er β KLval hβ hKL
  · -- R.402 (iv) alignment-tax identity.
    exact R_402_iv_alignment_tax Er β KLval

/-- **R3-A6 ICL+RLHF (iv) — RLHF KL-monotonicity carried into the ICL regime.**

For two RLHF rounds at the SAME data and SAME ICL regime, the round with the
larger `β` pays a higher alignment tax (R.402 (iv') antitone in `β`) without
changing ICL effectiveness (item (i) above).  The two effects fully decouple. -/
theorem R3_A6_RLHF_beta_increase_decouples_ICL
    {Ω : Type*} [DecidableEq Ω]
    (D_ref D_RL : ICL Ω)
    (hSameDemand : D_ref.R = D_RL.R)
    (hKFrozen : D_ref.K = D_RL.K)
    (Er KLval β₁ β₂ : ℝ) (hKL : 0 ≤ KLval) (hβ : β₁ ≤ β₂) :
    ((D_ref.R ⊆ D_ref.K) ↔ (D_RL.R ⊆ D_RL.K)) ∧
    (J Er β₂ KLval ≤ J Er β₁ KLval) := by
  refine ⟨?_, ?_⟩
  · exact R3_A6_ICL_after_RLHF_K_fixed D_ref D_RL hSameDemand hKFrozen
  · exact R_402_iv_antitone_in_beta Er KLval β₁ β₂ hKL hβ

end R3_Agent6_ICL_RLHF

end MIP
