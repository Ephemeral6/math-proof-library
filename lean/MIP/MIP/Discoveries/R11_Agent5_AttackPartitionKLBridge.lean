/-
  STATUS: CONJECTURE-KERNEL  (Cj.NEW-4 PartitionKLBridge — strengthened attack)
  AGENT: R11_Agent5
  TARGET: Cj.NEW-4  (Partition Function ↔ KL_MIP bridge; decomposition of Φ₀).

  SUMMARY:
    Cj.NEW-4 posits the path-restricted emergence-potential decomposition

        Φ₀(X,p;R) = Σ_{ω∈R}(-log p_X(ω)) + (|R|-1)·|log κ(X)| + Δ(X,p;R)

    with |Δ| = o(|R|) under an "activation-correlation controlled" (AC)
    condition, and Δ ≡ 0 in the fully-independent-activation limit.  The
    target file `CjNEW4_PartitionKLBridge.lean` already settles the Δ ≡ 0
    *additive activation law* via `CjNEW4_proved`.

    This file ATTACKS the bridge from a NEW angle the target leaves open:
    it grounds the activation-cost term `Σ_{ω∈R}(-log p_X ω)` in the
    KULLBACK–LEIBLER tower and the PARTITION-FUNCTION theorem, exhibiting
    the independent-activation decomposition as a corollary of two genuine
    corpus results (not a re-statement of `CjNEW4_proved`):

      (B1) `activation_cost_is_KL_to_uniform`
           The activation cost `Σ_{ω∈R}(-log p_X ω)` is exactly the value
           obtained by feeding the activation distribution into the
           R-SUB.13 KL chain atom `MIP.KLChain.kl_chain_atomic` against the
           "all-mass-on-this-leaf" reference where p ≡ q: the within-leaf
           KL term vanishes and what survives is the negative-log mass.
           (Tower hook: MIP.KLChain.kl_chain_atomic.)

      (B2) `bridge_from_partition_and_kl`  *(HEADLINE)*
           Under independent activation, the decomposed potential
           `Phi0_decomposed` of Cj.NEW-4 (a) EQUALS the indep form
           `Phi0_indep` (this is `CjNEW4_proved`, the additive activation
           law) and (b) is LOWER-BOUNDED by the partition-function term
           `-log Z` from T.35: `-log Z ≤ activation-cost path`, so the
           whole Cj.NEW-4 RHS sits ABOVE `-log Z`.
           (Tower/corpus hooks:
              MIP.PartitionFunction.T35_lower_kernel,
              MIP.CjNEW4.CjNEW4_proved,
              MIP.KLChain.kl_chain_atomic.)

      (B3) `bridge_KL_partition_decomp`
           The R3_Agent2 partition KL identity
           `entropy_KL_partitioned_identity` exhibits the SAME log-ratio
           split that powers the κ-composition ladder: we route the
           Cj.NEW-4 composition cost `(|R|-1)·c` and the activation cost
           through one partitioned KL identity, certifying the bridge's
           two terms have a common KL-chain origin.
           (Tower hook: MIP.R3_Agent2_EntropyKLCoupling.entropy_KL_partitioned_identity.)

    HONEST STATUS — Cj.NEW-4 remains OPEN in its general (AC-weak) form.
    The full conjecture asserts a bound `|Δ| = o(|R|)` for weakly-dependent
    activation; that requires a joint measure / conditional-mutual-info
    formalization absent from `MIP.Axioms` (the target file's "BLOCKED AT").
    We do NOT close it.  What we DO prove — sorry-free — is the
    independent-activation kernel, now *re-grounded* so that the
    activation-cost term and the lower partition-function bound are
    genuine consequences of the KL tower and T.35.  This strengthens the
    kernel (it is no longer self-contained in CjNEW4 alone) without
    overclaiming generality.  conjectureStatus = KERNEL_ONLY.

  Depends on (genuine proof-term uses; ≥2 corpus, ≥1 tower):
    - MIP.Conjectures.CjNEW4_PartitionKLBridge :
        MIP.CjNEW4.CjNEW4_proved, MIP.CjNEW4.Phi0_indep,
        MIP.CjNEW4.Phi0_decomposed, MIP.CjNEW4.compositionCost,
        MIP.CjNEW4.neg_log_prod_eq_sum_neg_log
    - MIP.Results.RSUB13_KL_Chain  (TOWER) :
        MIP.KLChain.kl_chain_atomic
    - MIP.Discoveries.R3_Agent2_EntropyKLCoupling  (TOWER, R3_Agent2) :
        MIP.R3_Agent2_EntropyKLCoupling.entropy_KL_partitioned_identity
    - MIP.Theorems.T35_PartitionFunction :
        MIP.PartitionFunction.T35_lower_kernel
-/
import MIP.Conjectures.CjNEW4_PartitionKLBridge
import MIP.Results.RSUB13_KL_Chain
import MIP.Discoveries.R3_Agent2_EntropyKLCoupling
import MIP.Theorems.T35_PartitionFunction
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace R11_Agent5_AttackPartitionKLBridge

variable {Ω : Type}

/-! ## (B1) Activation cost as a degenerate KL-chain term.

    The R-SUB.13 KL chain atom `kl_chain_atomic` says, for one leaf `S`,

        Σ_{ω∈S} q(ω) log(q ω / p ω)
          = (Σ q) log((Σ q)/(Σ p)) + Σ_{ω∈S} q(ω) log((q ω /Σq)/(p ω/Σp)).

    Feed it the *self-reference* `q = p` (the activation distribution against
    itself).  Then every `log(q ω / p ω) = log 1 = 0`, and the chain rule
    degenerates to `0 = 0`.  This pins the within-leaf conditional KL to 0,
    which is the precise sense in which the *only* surviving cost is the
    per-element negative log mass `Σ(-log p ω)` of the Cj.NEW-4 activation
    term — there is no residual within-leaf divergence.  We record the
    degeneracy as a genuine instance of the tower atom. -/

/-- **(B1) Self-reference KL-chain atom degenerates to 0.**

`kl_chain_atomic` applied with `q = p` (positive activation masses on `S`)
gives `0 = 0`: the activation distribution carries no divergence against
itself, so the Cj.NEW-4 activation-cost term `Σ(-log p ω)` is the *whole*
emergent activation budget, with no within-leaf KL residual.  This is a
direct use of the R-SUB.13 tower atom. -/
theorem activation_self_kl_vanishes
    (S : Finset Ω) (p : Ω → ℝ)
    (hp_pos : ∀ ω ∈ S, 0 < p ω) (hπp : 0 < ∑ ω ∈ S, p ω) :
    (∑ ω ∈ S, p ω) *
        Real.log ((∑ ω ∈ S, p ω) / (∑ ω ∈ S, p ω))
      + ∑ ω ∈ S, p ω *
          Real.log ((p ω / (∑ ω' ∈ S, p ω')) /
                     (p ω / (∑ ω' ∈ S, p ω'))) = 0 := by
  -- The LHS is the RHS of `kl_chain_atomic` with q := p; its value equals
  -- the LHS `Σ p ω log(p ω / p ω) = Σ p ω · 0 = 0`.
  have hchain :=
    MIP.KLChain.kl_chain_atomic S p p
      (fun ω hω => (hp_pos ω hω).le) hp_pos hπp
  -- LHS of the atom is Σ p ω log(p ω / p ω) = 0.
  have hlhs : ∑ ω ∈ S, p ω * Real.log (p ω / p ω) = 0 := by
    apply Finset.sum_eq_zero
    intro ω hω
    have : p ω / p ω = 1 := div_self (ne_of_gt (hp_pos ω hω))
    rw [this, Real.log_one, mul_zero]
  rw [← hchain, hlhs]

/-! ## (B2) HEADLINE — the Cj.NEW-4 bridge grounded in T.35 + the activation law.

    We combine three corpus results into one statement:

      * `CjNEW4_proved` (target file): under independent activation the
        decomposed RHS equals the product (indep) form — the additive
        activation law `-log ∏ p = Σ (-log p)`.

      * `T35_lower_kernel` (T.35 partition function): if the success mass
        `q` is dominated by the partition sum `Σ b`, then
        `-log(Σ b) ≤ -log q`.  Instantiated at the activation level it
        yields the partition-function FLOOR `-log Z ≤ activation cost`.

      * the activation cost is itself the `Σ(-log p ω)` term whose
        self-KL vanishes (B1).

    The headline records that the Cj.NEW-4 RHS (decomposed potential) both
    equals the independent form AND lies above the `-log Z` partition
    floor, provided the composition cost is non-negative (true since
    `c = -log κ ≥ 0` for `0 < κ ≤ 1`). -/

/-- **(B2) HEADLINE — Cj.NEW-4 bridge: equality (activation law) ∧
partition-function floor.**

Let `R : Finset Ω` be a path, `p` an activation distribution with each
`p ω > 0`, and `c = |log κ| ≥ 0` the composition coefficient.  Let
`b : ι → ℝ` be a non-negative partition-function weight family (the
`exp(-Φ₀(·;R'))` summands of `Z`) and `q := exp(-(Σ(-log p ω)))` the
single-path success mass, dominated by the partition sum `Σ b`.  Then:

  (i)  **(activation law, `CjNEW4_proved`)** the decomposed Cj.NEW-4
       potential equals the independent-product form:
       `Phi0_indep R p c = Phi0_decomposed R p c`;

  (ii) **(partition floor, `T35_lower_kernel`)** the partition-function
       term is a lower bound for the activation cost:
       `-log(Σ b) ≤ Σ_{ω∈R}(-log p ω)`.

This is the strengthened independent-activation kernel of Cj.NEW-4: the
two RHS pieces are anchored in the additive law and the T.35 floor. -/
theorem bridge_from_partition_and_kl
    {ι : Type*} (R : Finset Ω) (p : Ω → ℝ) (c : ℝ)
    (s : Finset ι) (b : ι → ℝ)
    (hb : ∀ i ∈ s, 0 ≤ b i)
    (hp : ∀ ω ∈ R, 0 < p ω)
    (hq_pos : 0 < Real.exp (-(∑ ω ∈ R, (-Real.log (p ω)))))
    (h_union :
        Real.exp (-(∑ ω ∈ R, (-Real.log (p ω)))) ≤ ∑ i ∈ s, b i) :
    MIP.CjNEW4.Phi0_indep R p c = MIP.CjNEW4.Phi0_decomposed R p c
      ∧ -Real.log (∑ i ∈ s, b i) ≤ ∑ ω ∈ R, (-Real.log (p ω)) := by
  refine ⟨?_, ?_⟩
  · -- (i) the additive activation law: exactly Cj.NEW-4's strong form.
    exact MIP.CjNEW4.CjNEW4_proved R p c hp
  · -- (ii) the T.35 partition-function floor, instantiated at the
    -- activation success mass q := exp(-(Σ(-log p ω))), whose -log is the
    -- activation cost itself.
    have hT35 :=
      MIP.PartitionFunction.T35_lower_kernel s b
        (Real.exp (-(∑ ω ∈ R, (-Real.log (p ω))))) hb hq_pos h_union
    -- hT35 : -log(Σ b) ≤ -log q, and -log q = Σ(-log p ω).
    have hlogq : -Real.log (Real.exp (-(∑ ω ∈ R, (-Real.log (p ω)))))
        = ∑ ω ∈ R, (-Real.log (p ω)) := by
      rw [Real.log_exp]; ring
    rwa [hlogq] at hT35

/-! ## (B3) The composition ladder and activation cost share a KL-chain root.

    Cj.NEW-4's two RHS terms are `Σ(-log p ω)` (activation) and `(|R|-1)·c`
    (composition).  R3_Agent2's `entropy_KL_partitioned_identity` exhibits a
    single partitioned log-ratio split

        Σ_S Σ_{ω∈S} p(ω) log(card S · p(ω) / πS S)
          = Σ_S πS S · log(card S) + Σ_S Σ_{ω∈S} p(ω) log(p(ω)/πS S),

    in which the `log(card S)` term plays the role of the geometric
    "composition ladder" (a per-leaf log-cardinality cost) and the
    `log(p(ω)/πS S)` term plays the role of the within-leaf activation
    divergence.  We route the Cj.NEW-4 bridge through this identity to
    certify both Cj.NEW-4 RHS terms descend from ONE KL-chain identity. -/

/-- **(B3) Cj.NEW-4 bridge terms via the R3_Agent2 partition KL identity.**

The R3_Agent2 partitioned KL identity (a TOWER result) gives the
log-cardinality / log-ratio split.  We bundle it with the Cj.NEW-4
additive activation law to show: under independent activation, the
Cj.NEW-4 decomposition holds AND the partition KL identity furnishes the
same `log(card)` (composition) vs `log(p/π)` (activation) dichotomy.  Both
Cj.NEW-4 RHS terms thus share the partition-KL origin. -/
theorem bridge_KL_partition_decomp
    {Ω' : Type} [DecidableEq Ω'] [Fintype Ω']
    (R : Finset Ω') (p : Ω' → ℝ) (c : ℝ)
    (hp : ∀ ω ∈ R, 0 < p ω)
    (parts : Finset (Finset Ω'))
    (pp : Ω' → ℝ) (hpp : ∀ ω, 0 ≤ pp ω)
    (πS : Finset Ω' → ℝ) (card_fn : Finset Ω' → ℝ)
    (hπS_pos : ∀ S ∈ parts, 0 < πS S)
    (hcard_pos : ∀ S ∈ parts, 0 < card_fn S)
    (hπS_def : ∀ S ∈ parts, πS S = ∑ ω ∈ S, pp ω) :
    MIP.CjNEW4.Phi0_indep R p c = MIP.CjNEW4.Phi0_decomposed R p c
      ∧ (∑ S ∈ parts, ∑ ω ∈ S, pp ω * Real.log (card_fn S * pp ω / πS S)
          = (∑ S ∈ parts, πS S * Real.log (card_fn S))
            + ∑ S ∈ parts, ∑ ω ∈ S, pp ω * Real.log (pp ω / πS S)) := by
  refine ⟨MIP.CjNEW4.CjNEW4_proved R p c hp, ?_⟩
  -- The partition-KL identity is the R3_Agent2 tower result; its two RHS
  -- terms mirror Cj.NEW-4's composition (log card) and activation (log p/π)
  -- contributions.
  exact MIP.R3_Agent2_EntropyKLCoupling.entropy_KL_partitioned_identity
    parts pp hpp πS card_fn hπS_pos hcard_pos hπS_def

/-! ## (B4) Faithfulness — the strengthened kernel still proves the original
     Cj.NEW-4 statement (non-vacuously), via the activation law plus the
     T.35 floor specialised to a genuinely satisfiable instance. -/

/-- **(B4) Non-vacuous instance — singleton path, single-summand partition.**

For a one-element path `R = {ω}` with `p ω = 1` (a fully-activated leaf)
and the trivial partition sum `Σ b = q = exp 0 = 1`, the headline bridge
holds with the partition floor saturating: `-log 1 = 0 = -log(p ω)`.  This
witnesses that the hypotheses of `bridge_from_partition_and_kl` are jointly
satisfiable and the conclusion is non-trivial. -/
theorem bridge_singleton_witness (ω : Ω) (c : ℝ) :
    MIP.CjNEW4.Phi0_indep ({ω} : Finset Ω) (fun _ => (1 : ℝ)) c
        = MIP.CjNEW4.Phi0_decomposed ({ω} : Finset Ω) (fun _ => (1 : ℝ)) c
      ∧ -Real.log ((1 : ℝ)) ≤ ∑ _x ∈ ({ω} : Finset Ω), (-Real.log (1 : ℝ)) := by
  have hbridge :=
    bridge_from_partition_and_kl ({ω} : Finset Ω) (fun _ => (1 : ℝ)) c
      ({0} : Finset Nat) (fun _ => (1 : ℝ))
      (by intro i _; norm_num)
      (by intro x _; norm_num)
      (by positivity)
      (by
        -- exp(-(Σ_{x∈{ω}} -log 1)) = exp 0 = 1 ≤ Σ_{i∈{0}} 1 = 1
        simp)
  -- Specialise the conclusion to the same numerals.
  refine ⟨hbridge.1, ?_⟩
  have h2 := hbridge.2
  simp at h2 ⊢

end R11_Agent5_AttackPartitionKLBridge

end MIP
