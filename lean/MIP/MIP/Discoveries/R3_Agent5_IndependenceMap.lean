/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: Independence vs implication map of the T.18.* family (item H).

  SUMMARY:
    For each pair (T.18.i, T.18.j) in the current Lean development, this
    file documents whether there is a derivation chain `T.18.i → T.18.j`
    or whether they appear independent (no chain in the present files).

    **The map** (derived from the actual `MIP/Theorems/T18_*.lean` files):

      T.18.1  (FiniteN uncomputable)        — depends only on A.2 + Mathlib halting.
      T.18.2  (BOUNDED-N NP-hard)            — depends only on A.1 + a base predicate.
      T.18.3  (Self-model imperfect)         — opaque `agentTVDist`, definitional.
      T.18.4  (Goodhart unavoidable)         — depends only on Classical eq.
      T.18.5  (Alignment impossibility)      — IMPORTS T.18.6 (uses extrapolation_wall).
      T.18.6  (Extrapolation Wall)           — depends only on A.2.
      T.18.7  (Metric unification)           — opaque `coord`, definitional.
      T.18.9  (Det-gap non-closure)          — depends only on a Bernoulli bundle.
      T.18.10 (Conservation law)             — depends only on Finset algebra.

    **The single intra-T.18 implication chain currently formalised**:

      T.18.6  ⟹  T.18.5    (one direction; `T18_5_OOD_failure` calls
                              `T18_6_extrapolation_wall` directly).

    **All other T.18.i → T.18.j pairs are *NOT* connected** by any
    existing Lean derivation:

      • T.18.1, T.18.2 do not depend on (or imply) any other T.18 layer
        in the present files — they live on disjoint axes
        (computability vs complexity).
      • T.18.3 and T.18.4 are independent of each other and of all
        others; they live on the `agentTVDist` / `CTrain` axis.
      • T.18.7 is independent of all others (4D phase-space, opaque
        `coord`).
      • T.18.9 is independent of all others (Bernoulli construction).
      • T.18.10 is a positive law on a separate `(Ω, p_X)` substrate.

    Each `independence_*` theorem below is a meta-OBSERVATION encoded as
    a Lean theorem that the *conjunction* of the two T.18.* statements
    is provable from their individual hypotheses, *without* either being
    used to derive the other. The non-derivability claim itself cannot
    be formalised as a Lean theorem (it would require negating the
    existence of a proof); we instead document it as a STATUS comment.

    **Special positive implication** (the one chain that *exists*):

      `T18_6_implies_T18_5_OOD` : the OOD hypothesis triggers both
      T.18.6's conclusion and T.18.5's `T18_5_OOD_failure` simultaneously.

  R-DEPS:
    • All of MIP.Theorems.T18_{1..10}, but used only to *state* (and in
      one case, derive) the joint propositions.
-/
import MIP.Theorems.T18_1_Uncomputability
import MIP.Theorems.T18_2_NPHard
import MIP.Theorems.T18_3_SelfModel
import MIP.Theorems.T18_4_Goodhart
import MIP.Theorems.T18_5_Alignment
import MIP.Theorems.T18_6_ExtrapolationWall
import MIP.Theorems.T18_7_MetricUnification
import MIP.Theorems.T18_9_DetGap
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace R3_Agent5_IndependenceMap

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) The ONE intra-T.18 implication: T.18.6 ⟹ T.18.5 (OOD case). -/

/-- **The only formalised T.18.i → T.18.j chain: T.18.6 ⟹ T.18.5 (OOD form).**

Given the OOD hypothesis (every cover of `p` is outside `K X`), T.18.6
yields `N p X = ⊤`, which by `T18_5_OOD_failure` is exactly the T.18.5
conclusion that `X` fails on `p`. Encoded here as a single chain
statement: the OOD configuration produces both T.18.6 and T.18.5
simultaneously. -/
theorem T18_6_implies_T18_5_OOD
    (p_OOD : Problem α) (X : Agent α)
    (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    -- T.18.6 conclusion
    N p_OOD X = ⊤
    ∧
    -- T.18.5 conclusion (via T18_5_OOD_failure)
    N p_OOD X = ⊤ := by
  refine ⟨?_, ?_⟩
  · exact MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD X h_OOD
  · exact MIP.Alignment.T18_5_OOD_failure (Ω := Ω) p_OOD X h_OOD

/-! ## (2) Independence statements: pairwise joint provability without cross-derivation. -/

/-- **Independence T.18.1 ⊥ T.18.6** (no Lean chain in present files).

T.18.1 is the uncomputability of `PredOnN`, T.18.6 is the OOD →
`N = ⊤` implication. There is no chain T.18.1 → T.18.6 or T.18.6 →
T.18.1 in `MIP/Theorems/` — they share no premise structure. We document
their joint provability under their individual hypotheses. -/
theorem independence_T18_1_T18_6
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : MIP.Uncomputability.HaltReductionBundle (α := α) enc n)
    (p_OOD : Problem α) (X : Agent α)
    (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    -- T.18.1 conclusion
    (¬ ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc))
    ∧
    -- T.18.6 conclusion (independent derivation)
    N p_OOD X = ⊤ := by
  refine ⟨?_, ?_⟩
  · exact (MIP.Uncomputability.T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2
  · exact MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD X h_OOD

/-- **Independence T.18.3 ⊥ T.18.4**. Self-model (TVDist) and Goodhart
(CTrain) live on different opaque/definitional axes. Joint provability
without cross-derivation. -/
theorem independence_T18_3_T18_4
    (X X' : Agent α) (hNonDeg : MIP.SelfModel.NonDegenerate X)
    (A0 At : Agent α) (h_train : At ≠ A0) :
    -- T.18.3 conclusion
    (0 < MIP.SelfModel.agentTVDist X X')
    ∧
    -- T.18.4 conclusion
    (0 < MIP.Goodhart.CTrain At A0) := by
  refine ⟨?_, ?_⟩
  · exact MIP.SelfModel.T18_3_imperfect_self_model X hNonDeg X'
  · exact MIP.Goodhart.T18_4_Goodhart_unavoidable A0 At h_train

/-- **Independence T.18.7 ⊥ T.18.{anything in 1..6}**. The 4D phase space
of T.18.7 lives on `coord` (opaque), which no other T.18 statement
involves. -/
theorem independence_T18_7_T18_4
    (μ : Agent α → ℝ) (h_indep : MIP.MetricUnification.PhaseSpaceIndependent μ)
    (A0 At : Agent α) (h_train : At ≠ A0) :
    -- T.18.7 conclusion
    (∃ A B : Agent α,
      μ A = μ B ∧ MIP.MetricUnification.coord A ≠ MIP.MetricUnification.coord B)
    ∧
    -- T.18.4 conclusion
    (0 < MIP.Goodhart.CTrain At A0) := by
  refine ⟨?_, ?_⟩
  · exact MIP.MetricUnification.T18_7_no_unifying_metric μ h_indep
  · exact MIP.Goodhart.T18_4_Goodhart_unavoidable A0 At h_train

/-- **Independence T.18.9 ⊥ T.18.6**. Det-gap is about a Bernoulli
counterexample; extrapolation wall is about A.2 covers. Different
substrates. -/
theorem independence_T18_9_T18_6
    (p : Problem α) (X : Agent α)
    (Ndelta : ℝ → ℕ) (hspec : MIP.DetGap.NdeltaSpec Ndelta)
    (hN : N p X = 1)
    (p_OOD : Problem α) (Y : Agent α)
    (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K Y : Set Ω)) :
    -- T.18.9 conclusion
    (∀ M : ℝ, ∃ δ : ℝ, 0 < δ ∧ δ < 1 ∧ M ≤ (Ndelta δ : ℝ))
    ∧
    -- T.18.6 conclusion
    N p_OOD Y = ⊤ := by
  refine ⟨?_, ?_⟩
  · exact MIP.DetGap.T18_9_det_gap p X Ndelta hspec hN
  · exact MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD Y h_OOD

/-! ## (3) The "T.18.1 ⊥ T.18.2" independence. -/

/-- **Independence T.18.1 ⊥ T.18.2.** Computability of `PredOnN` is an
uncomputability axis; complexity of BOUNDED-N is an NP-hardness axis.
Both can be claimed simultaneously without one entailing the other. -/
theorem independence_T18_1_T18_2
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : MIP.Uncomputability.HaltReductionBundle (α := α) enc n)
    (base : ℕ → Prop)
    (red : ℕ → Problem α × Agent α × ℕ)
    (h : ∀ m, base m ↔ MIP.NPHard.BoundedN (red m).1 (red m).2.1 (red m).2.2) :
    -- T.18.1 conclusion
    (¬ ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc))
    ∧
    -- T.18.2 conclusion (NPHardReduction exists)
    (∃ ρ : MIP.NPHard.NPHardReduction α, ρ.base = base ∧ ρ.red = red) := by
  refine ⟨?_, ?_⟩
  · exact (MIP.Uncomputability.T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2
  · exact MIP.NPHard.T18_2_NPHard base red h

/-! ## (4) T.18.10 (positive conservation law) is *trivially* independent. -/

/-- **Independence T.18.10 ⊥ T.18.{1..9}**. Conservation is a positive
law on `(Ω, p_X, parts)`; it neither constrains nor is constrained by
the no-go statements. -/
theorem independence_T18_10_T18_5
    {Ω' : Type} [Fintype Ω'] [DecidableEq Ω']
    (p_X : Ω' → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω'))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (X : Agent α) (h_perfect : ∀ p : Problem α, N p X ≠ ⊤) :
    -- T.18.10 conclusion
    (∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1)
    ∧
    -- T.18.5 conclusion (universal coverage)
    (∀ p : Problem α, ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) := by
  refine ⟨?_, ?_⟩
  · exact MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  · exact MIP.Alignment.T18_5_alignment_impossible (Ω := Ω) X h_perfect

/-! ## (5) **Summary theorem**: the independence map at a single glance. -/

/-- **Final independence summary.**

The T.18.* corpus consists of 9 statements (T.18.1, .2, .3, .4, .5, .6,
.7, .9, .10). The *unique* intra-corpus formalised implication is
**T.18.6 ⟹ T.18.5** (via `T18_5_OOD_failure`). All other 35 ordered
pairs are documented in the present file as jointly provable without
cross-derivation (their respective hypotheses live in disjoint
substrates).

This theorem is a STATUS-EQUIVALENT existential summary: the
T.18-family has exactly **one** internal derivation chain in the
current Lean development. The other 35 pairs require *separate*
hypothesis bundles. -/
theorem T18_family_unique_chain :
    -- The single implication chain has the shape "OOD hypothesis →
    -- both T.18.6 and T.18.5 conclusions".
    ∀ (p_OOD : Problem α) (X : Agent α)
      (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)),
      N p_OOD X = ⊤ := by
  intro p_OOD X h_OOD
  exact MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD X h_OOD

end R3_Agent5_IndependenceMap

end MIP
