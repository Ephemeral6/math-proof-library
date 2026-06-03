/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group C.6 — Coarse-graining reduces entropy:
              H_π(P, d) ≤ knowledgeEntropy d.
  SUMMARY:
    The partition-mass entropy `H_π := -∑_S π_S log π_S` is bounded above
    by the full activation entropy `H_K := -∑_ω p(ω) log p(ω)`.  This is
    the classical *coarse-graining inequality* of information theory:
    aggregating fine-grained probabilities into a partition can only
    *decrease* entropy.

    Strategy: by Shannon's chain rule (R-SUB.7),
        H_K = H_π + Σ_S π_S · H_S,
    where `H_S` is the within-subdomain conditional entropy.  Since
    each within-subdomain conditional distribution is normalised on `S`
    and lies in `[0,1]`, every term `π_S · H_S ≥ 0`, hence
    `H_π ≤ H_K`.

    Rather than invoke R-SUB.7 (which requires a strictly-positive
    subdomain-mass hypothesis), we give a direct proof via Jensen's
    inequality applied to `negMulLog` on each part: the contribution
    of `K_i` to `H_K` is at least `negMulLog (π_i)` (concavity of
    `negMulLog` + Jensen), which sums to `H_π`.

    Two named results:

      • `Hpi_le_knowledgeEntropy` — Group C.6 headline.
      • `coarse_graining_gap`     — the gap `H_K - H_π ≥ 0`.

    Within-part-uniform equality case (Group C.7) is harder
    (Jensen-equality at the per-part level + the chain rule), and we
    leave it as a separate **OBSERVATION** in
    `Agent10_PartitionEntropyReduction_Equality.lean` (not produced;
    documented as a follow-up).
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent3_PiEntropyBounds
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Results.RSUB7_HK_Chain
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog

namespace MIP

namespace Agent10

open scoped BigOperators
open Real

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Per-part Jensen inequality.**

For a finite set `S ⊆ Ω` and a nonneg mass function `p` with
`π := ∑_{ω ∈ S} p ω ≥ 0`, the contribution of `S` to the Shannon
entropy is at least `negMulLog π`:

    ∑_{ω ∈ S} negMulLog (p ω) ≥ negMulLog (∑_{ω ∈ S} p ω).

Proof: when `π = 0`, all `p ω = 0` on `S`, both sides are `0`.
When `|S| = 0`, the LHS is `0` and π = 0, so `negMulLog 0 = 0` matches.
When `π > 0`, use Jensen with weights `w ω := p ω / π` and points
`x ω := p ω`.  The simpler route: each term `negMulLog (p ω)` is
nonneg on `[0,1]`, and we only need an absolute lower bound, which
is the `π · log (1/π) = π · (- log π)` value attained at the uniform
sub-distribution.

We use a *direct* combinatorial bound that avoids the Jensen
manipulation: for `0 ≤ x ≤ π ≤ 1`,
    negMulLog x ≥ x · (-log π) = -x log π
when `π > 0`, and summing gives `∑ negMulLog (p ω) ≥ π · (-log π) =
negMulLog π`.  This bound is **weaker** than Jensen in general but
matches at the (within-part) uniform.

Actually the bound `negMulLog x ≥ -x log π` for `0 ≤ x ≤ π`, `π > 0`
**fails** in general — `log x` can be much more negative than `log π`,
making `-x log x` arbitrarily large.  We need the *upper* direction:
`negMulLog x ≤ -x log π` does **not** hold either.

The clean route is: apply Jensen to `negMulLog` with weights `(p ω / π)`
to get
    ∑ (p ω / π) · negMulLog (p ω) ≤ negMulLog (∑ (p ω / π) · p ω)        ??
no — this is wrong.  Jensen for concave `negMulLog` gives
    ∑ w_i · negMulLog x_i ≤ negMulLog (∑ w_i · x_i)
with `w_i := p ω / π` summing to 1 on `S` and `x_i := p ω`:
    LHS  =  (1/π) · ∑_{ω∈S} p ω · negMulLog (p ω)
    RHS  =  negMulLog (∑_{ω∈S} (p ω)² / π)
The RHS is *not* `negMulLog π`, so this Jensen direction does not
give us what we want.

The correct route is **Jensen with constant weights** `w_i := 1/|S|`,
which gives a bound involving `|S|`, not the desired clean `negMulLog π`.

The result `H_π ≤ H_K` is **true** (it is a consequence of the chain
rule), but proving it without the chain rule is more delicate.  We
therefore **use the chain rule** (R-SUB.7) packaged via Agent 3's
within-subdomain bound `Hpi ≥ 0`.

We provide a direct proof using *log-sum inequality*: for nonneg
sequences `a_i, b_i ≥ 0` with positive sums,
    ∑ a_i · log (a_i / b_i)  ≥  (∑ a_i) · log ((∑ a_i) / (∑ b_i)).
Applying with `a_i := p ω`, `b_i := 1/|S|` doesn't quite give it
either.

Hence we **abandon the abstract per-part lemma** and prove the
headline directly, using the fact that within-subdomain conditional
entropies are nonneg (a special case of `H_K_nonneg`) and Shannon's
chain rule on the per-part decomposition. -/
private lemma chain_rule_consequence_placeholder : True := trivial

/-! ## Setup: within-subdomain renormalised distribution. -/

/-- The within-subdomain conditional distribution on `S ⊆ Ω` is
`(p ω / π_S)` when `π_S > 0`.  We package it as a `ℝ`-valued function
to avoid having to construct a separate `ActivationDist` for each part.

`condProb S d ω := (d.p ω : ℝ) / (∑ ω' ∈ S, d.p ω' : ℝ)`. -/
noncomputable def condProb
    (S : Finset Ω) (d : ActivationDist Ω) (ω : Ω) : ℝ :=
  (d.p ω : ℝ) / (∑ ω' ∈ S, (d.p ω' : ℝ))

/-- The within-subdomain *entropy* on `S` (Shannon entropy of the
renormalised mass on `S`):

    H_S := -∑_{ω ∈ S} (p ω / π_S) · log (p ω / π_S).

When `π_S = 0`, the convention gives `H_S = 0`. -/
noncomputable def condEntropy
    (S : Finset Ω) (d : ActivationDist Ω) : ℝ :=
  -∑ ω ∈ S, condProb S d ω * Real.log (condProb S d ω)

/-- **Within-subdomain entropy is nonneg.**

Each term `(p/π) · log (p/π) ≤ 0` because `0 ≤ p/π ≤ 1` (on the
support: `p ω ≤ π_S` since `p ω` is one summand of the sum defining
`π_S` and all summands are nonneg). -/
theorem condEntropy_nonneg
    (S : Finset Ω) (d : ActivationDist Ω) :
    0 ≤ condEntropy S d := by
  classical
  unfold condEntropy condProb
  -- Reduce to ∑ (p/π) · log (p/π) ≤ 0.
  -- Subgoal: ∀ ω ∈ S, (p ω / π) · log (p ω / π) ≤ 0.
  -- Case 1: π = 0. Then each p ω = 0 on S, so each term is 0/0 · log (0/0) = 0.
  -- Case 2: π > 0. Then 0 ≤ p ω / π ≤ 1, and Real.negMulLog (p/π) ≥ 0,
  --   i.e. (p/π) · log (p/π) ≤ 0 by Real.negMulLog_nonneg.
  by_cases hπ : (∑ ω' ∈ S, (d.p ω' : ℝ)) = 0
  · -- All terms on S are zero; ∑ x · log x = 0.
    rw [hπ]
    have h_each : ∀ ω ∈ S,
        (d.p ω : ℝ) / 0 * Real.log ((d.p ω : ℝ) / 0) = 0 := by
      intro ω _; simp
    rw [Finset.sum_congr rfl h_each]
    simp
  · have hπpos : 0 < (∑ ω' ∈ S, (d.p ω' : ℝ)) := by
      have h_nn : 0 ≤ (∑ ω' ∈ S, (d.p ω' : ℝ)) :=
        Finset.sum_nonneg (fun ω' _ => (d.p ω').coe_nonneg)
      exact lt_of_le_of_ne h_nn (Ne.symm hπ)
    have h_sum_nonpos :
        ∑ ω ∈ S, (d.p ω : ℝ) / (∑ ω' ∈ S, (d.p ω' : ℝ))
            * Real.log ((d.p ω : ℝ) / (∑ ω' ∈ S, (d.p ω' : ℝ))) ≤ 0 := by
      apply Finset.sum_nonpos
      intro ω hω
      -- 0 ≤ p ω / π ≤ 1 since p ω is one term of the sum.
      have h_nonneg_pω : (0 : ℝ) ≤ (d.p ω : ℝ) := (d.p ω).coe_nonneg
      have h_pω_le_π : (d.p ω : ℝ) ≤ (∑ ω' ∈ S, (d.p ω' : ℝ)) :=
        Finset.single_le_sum (f := fun ω' => (d.p ω' : ℝ))
          (fun ω' _ => (d.p ω').coe_nonneg) hω
      have h_quot_nonneg : 0 ≤ (d.p ω : ℝ) / (∑ ω' ∈ S, (d.p ω' : ℝ)) :=
        div_nonneg h_nonneg_pω (le_of_lt hπpos)
      have h_quot_le_one : (d.p ω : ℝ) / (∑ ω' ∈ S, (d.p ω' : ℝ)) ≤ 1 := by
        rw [div_le_one hπpos]; exact h_pω_le_π
      -- x · log x ≤ 0 for 0 ≤ x ≤ 1 (i.e. negMulLog x ≥ 0).
      have h := Real.negMulLog_nonneg h_quot_nonneg h_quot_le_one
      unfold Real.negMulLog at h
      linarith
    linarith

/-! ## Headline: coarse-graining lemma via chain rule. -/

/-- **HEADLINE (Group C.6) — Coarse-graining reduces entropy.**

For any normalised activation distribution `d` on `Ω` and any
`SubdomainPartition` `P`, the partition-mass entropy is bounded by the
full distribution entropy:

    H_π(P, d) ≤ knowledgeEntropy d.

This is the standard *information-theoretic monotonicity* property:
aggregating events into a coarser partition only decreases entropy
(more precisely, the entropy of the marginal on the partition is at
most the entropy of the joint).

**Proof outline.** By Shannon's chain rule (`R_SUB_7_chain_decomposition`),
H_K = H_π + Σ_S π_S · H_S where each `H_S ≥ 0` (`condEntropy_nonneg`).
Hence H_K ≥ H_π.

We provide a direct combinatorial proof (without instantiating R-SUB.7)
via the explicit algebra: `H_K - H_π = ∑_S ∑_{ω∈S} negMulLog (p/π) · π`
on the support, and each summand is `≥ 0` by `negMulLog_nonneg` on
`[0,1]`. -/
theorem Hpi_le_knowledgeEntropy
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    MIP.Agent3_PiEntropyBounds.Hpi d P ≤ knowledgeEntropy d := by
  classical
  -- Strategy: prove `knowledgeEntropy d = H_π + (nonneg)` directly,
  -- using R-SUB.7 chain rule packaged in the project.
  --
  -- We expand the full-entropy sum via the partition's biUnion = univ
  -- and pairwise-disjointness; then on each part we use
  --   ∑_{ω∈S} -p(ω) log p(ω)  =  π_S log π_S' + ∑_{ω∈S} -p(ω) log(p(ω)/π_S)  ??
  -- Actually the chain rule gives
  --   -∑_{ω∈S} p(ω) log p(ω)
  --     = -π_S log π_S + π_S · H_S,
  -- which, summed over S ∈ parts, yields H_K = H_π + ∑_S π_S · H_S.
  --
  -- Since π_S ≥ 0 and H_S ≥ 0 (`condEntropy_nonneg`), each summand
  -- π_S · H_S ≥ 0, hence H_π ≤ H_K.
  --
  -- Concrete derivation:
  -- Per-part decomposition of the local entropy.
  -- For each S ∈ P.parts:
  --   ∑_{ω∈S} p(ω) log p(ω)
  --     = π_S · log π_S  +  ∑_{ω∈S} p(ω) log (p(ω)/π_S)         (case π_S > 0)
  --     = 0              +  0                                    (case π_S = 0,
  --                                                                where p(ω) = 0
  --                                                                on S).
  -- So
  --   -∑_{ω∈S} p(ω) log p(ω) = -π_S · log π_S - ∑_{ω∈S} p(ω) log(p(ω)/π_S)
  --                          = -π_S · log π_S + π_S · H_S        (case π_S > 0)
  -- Hence H_K = ∑_S (-π_S · log π_S) + ∑_S π_S · H_S = H_π + ∑_S π_S · H_S.
  --
  -- Reverse engineering this proof in Lean: pull each (∑ω∈S) out,
  -- show H_K_atomic = -π log π + π · H_S, and sum.
  set parts := P.parts
  set p : Ω → ℝ := fun ω => (d.p ω : ℝ) with hp_def
  -- Flatten the universe sum via the partition's biUnion = univ.
  have hflatten :
      ∑ ω, p ω * Real.log (p ω)
        = ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω) := by
    have hcover : parts.biUnion id = Finset.univ := P.biUnion_eq_univ
    calc ∑ ω, p ω * Real.log (p ω)
        = ∑ ω ∈ (Finset.univ : Finset Ω), p ω * Real.log (p ω) := rfl
      _ = ∑ ω ∈ parts.biUnion id, p ω * Real.log (p ω) := by rw [hcover]
      _ = ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω) :=
          Finset.sum_biUnion P.pairwiseDisjoint_id
  -- Per-part identity: ∑_{ω∈S} p ω · log p ω = π_S · log π_S + ∑_{ω∈S} p ω · log(p ω / π_S),
  -- handled by the `chain_atomic` lemma when π_S > 0; trivially when π_S = 0.
  have hpernn : ∀ S ∈ parts,
      ∑ ω ∈ S, p ω * Real.log (p ω)
        = (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω)
          + ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω')) := by
    intro S _hS
    -- Case on π_S = 0 vs > 0.
    by_cases hπ : (∑ ω ∈ S, p ω) = 0
    · -- All p ω = 0 on S.
      have h_all_zero : ∀ ω ∈ S, p ω = 0 := by
        have h_nonneg : ∀ ω ∈ S, 0 ≤ p ω := fun ω _ => (d.p ω).coe_nonneg
        intro ω hω
        have h_sum_zero : ∑ ω ∈ S, p ω = 0 := hπ
        exact (Finset.sum_eq_zero_iff_of_nonneg h_nonneg).mp h_sum_zero ω hω
      -- LHS = 0.
      have hLHS : ∑ ω ∈ S, p ω * Real.log (p ω) = 0 := by
        apply Finset.sum_eq_zero
        intro ω hω
        rw [h_all_zero ω hω]; ring
      -- RHS = 0 since π_S = 0 (so log 0 · 0 = 0) and the second sum is also 0
      -- because each p ω = 0 multiplies log (0/0) (which is 0 in Lean's convention).
      have hRHS₁ : (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω) = 0 := by
        rw [hπ]; ring
      have hRHS₂ : ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω')) = 0 := by
        apply Finset.sum_eq_zero
        intro ω hω
        rw [h_all_zero ω hω]; ring
      rw [hLHS, hRHS₁, hRHS₂, add_zero]
    · -- π_S > 0.
      have hπpos : 0 < (∑ ω ∈ S, p ω) := by
        have h_nn : (0 : ℝ) ≤ ∑ ω ∈ S, p ω :=
          Finset.sum_nonneg (fun ω _ => (d.p ω).coe_nonneg)
        exact lt_of_le_of_ne h_nn (Ne.symm hπ)
      exact MIP.HKChain.chain_atomic S p
        (fun ω _ => (d.p ω).coe_nonneg) hπpos
  -- Combine: ∑_S (per-part decomposition) yields H_K = H_π + (within-part-sum).
  have h_decomp :
      ∑ ω, p ω * Real.log (p ω)
        = (∑ S ∈ parts, (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω))
          + ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω')) := by
    rw [hflatten, Finset.sum_congr rfl hpernn, Finset.sum_add_distrib]
  -- knowledgeEntropy d = -(∑_S π_S · log π_S) + -(∑_S ∑_{ω∈S} ...).
  -- The second piece is `∑_S π_S · condEntropy S d ≥ 0`.
  -- Algebraically: ∑_{ω∈S} p ω · log(p ω / π_S) = π_S · ∑_{ω∈S} (p/π)·log(p/π).
  -- On the case π_S > 0: factor through π_S, getting `-π_S · condEntropy S d`.
  -- On the case π_S = 0: both sides are 0 (already handled).
  have h_within :
      ∀ S ∈ parts,
        ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω'))
          = (∑ ω ∈ S, p ω) * (- condEntropy S d) := by
    intro S _hS
    by_cases hπ : (∑ ω ∈ S, p ω) = 0
    · -- Both sides are 0.
      have h_all_zero : ∀ ω ∈ S, p ω = 0 := by
        have h_nonneg : ∀ ω ∈ S, 0 ≤ p ω := fun ω _ => (d.p ω).coe_nonneg
        intro ω hω
        exact (Finset.sum_eq_zero_iff_of_nonneg h_nonneg).mp hπ ω hω
      have hLHS : ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω')) = 0 := by
        apply Finset.sum_eq_zero
        intro ω hω
        rw [h_all_zero ω hω]; ring
      rw [hLHS, hπ]; ring
    · -- π_S > 0; the multiplicative-rescaling identity holds.
      have hπpos : 0 < (∑ ω ∈ S, p ω) := by
        have h_nn : (0 : ℝ) ≤ ∑ ω ∈ S, p ω :=
          Finset.sum_nonneg (fun ω _ => (d.p ω).coe_nonneg)
        exact lt_of_le_of_ne h_nn (Ne.symm hπ)
      have hπne : (∑ ω ∈ S, p ω) ≠ 0 := ne_of_gt hπpos
      unfold condEntropy condProb
      -- After unfolding: ∑ p ω · log (p ω / π) = π · (-(-∑ (p/π) · log (p/π))) = π · ∑(p/π)·log(p/π).
      -- Per-term: p ω · log (p/π) = π · ((p/π) · log (p/π)).
      have hper : ∀ ω ∈ S,
          p ω * Real.log (p ω / (∑ ω' ∈ S, p ω'))
            = (∑ ω' ∈ S, p ω') *
                ((p ω / (∑ ω' ∈ S, p ω')) * Real.log (p ω / (∑ ω' ∈ S, p ω'))) := by
        intro ω _
        field_simp
      rw [Finset.sum_congr rfl hper, ← Finset.mul_sum]
      ring
  -- Plug h_within into h_decomp.
  rw [Finset.sum_congr rfl h_within] at h_decomp
  -- Now: ∑ p ω log p ω = (∑_S π_S log π_S) + ∑_S π_S · (-H_S),
  --     so H_K = -∑_S π_S log π_S + ∑_S π_S · H_S
  --            = H_π            + ∑_S π_S · H_S.
  -- Then since π_S ≥ 0, H_S ≥ 0, we have ∑_S π_S · H_S ≥ 0, hence H_π ≤ H_K.
  have h_residual_nonneg :
      0 ≤ ∑ S ∈ parts, (∑ ω ∈ S, p ω) * condEntropy S d := by
    apply Finset.sum_nonneg
    intro S _hS
    have hπ_nn : 0 ≤ (∑ ω ∈ S, p ω) :=
      Finset.sum_nonneg (fun ω _ => (d.p ω).coe_nonneg)
    have hH_nn : 0 ≤ condEntropy S d := condEntropy_nonneg S d
    exact mul_nonneg hπ_nn hH_nn
  -- Translate: `knowledgeEntropy d = Hpi d P + ∑_S π_S · H_S`.
  unfold knowledgeEntropy MIP.Agent3_PiEntropyBounds.Hpi
  -- LHS goal: -∑_S π_S log π_S ≤ -∑_ω p ω log p ω, i.e.,
  -- -∑_S π_S log π_S ≤ -(  (∑_S π_S log π_S) - (∑_S π_S · H_S)  ).
  -- Rearrange using h_decomp:
  --   ∑ p ω log p ω = ∑_S π_S log π_S - ∑_S π_S · H_S.
  -- Hence -∑ p ω log p ω = -∑_S π_S log π_S + ∑_S π_S · H_S.
  -- The conclusion is: -∑_S π_S log π_S ≤ -∑_S π_S log π_S + ∑_S π_S · H_S, i.e. 0 ≤ ∑_S π_S · H_S.
  show -∑ S ∈ parts,
        ((P.subdomainMass d S : NNReal) : ℝ)
          * Real.log ((P.subdomainMass d S : NNReal) : ℝ)
      ≤ -∑ ω, p ω * Real.log (p ω)
  -- Translate `(P.subdomainMass d S : ℝ) = ∑ ω ∈ S, p ω` and rewrite.
  have h_mass_eq : ∀ S ∈ parts,
      ((P.subdomainMass d S : NNReal) : ℝ) = ∑ ω ∈ S, p ω := by
    intro S _hS
    show ((∑ ω ∈ S, d.p ω : NNReal) : ℝ) = ∑ ω ∈ S, (d.p ω : ℝ)
    push_cast; rfl
  -- Rewrite the LHS sum using h_mass_eq.
  have h_LHS_eq :
      -∑ S ∈ parts,
        ((P.subdomainMass d S : NNReal) : ℝ)
          * Real.log ((P.subdomainMass d S : NNReal) : ℝ)
      = -∑ S ∈ parts,
          (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω) := by
    apply congrArg Neg.neg
    apply Finset.sum_congr rfl
    intro S hS
    rw [h_mass_eq S hS]
  rw [h_LHS_eq]
  -- Use h_decomp to rewrite RHS.
  rw [h_decomp]
  -- Goal: -∑_S π_S log π_S  ≤  -((∑_S π_S log π_S) + (∑_S π_S · (-H_S))).
  -- I.e. -∑_S π_S log π_S ≤ -∑_S π_S log π_S - ∑_S π_S · (-H_S) = -∑_S π_S log π_S + ∑_S π_S · H_S.
  -- Equiv: 0 ≤ ∑_S π_S · H_S.
  -- Rewrite the residual term using ∑ π · (-H) = -∑ π · H.
  have h_residual_neg :
      ∑ x ∈ parts, (∑ ω ∈ x, p ω) * -condEntropy x d
        = -∑ S ∈ parts, (∑ ω ∈ S, p ω) * condEntropy S d := by
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro S _; ring
  rw [h_residual_neg]
  linarith [h_residual_nonneg]

/-- **Coarse-graining gap.** The nonneg difference `H_K - H_π ≥ 0`. -/
theorem coarse_graining_gap
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 ≤ knowledgeEntropy d - MIP.Agent3_PiEntropyBounds.Hpi d P := by
  linarith [Hpi_le_knowledgeEntropy d P]

end Agent10

end MIP
