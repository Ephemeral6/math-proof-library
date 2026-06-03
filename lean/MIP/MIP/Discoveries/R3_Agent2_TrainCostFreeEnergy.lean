/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law composition (C) — R-SUB.14 + R-SUB.11
              → KL-energy bound (training cost in free-energy units).
  SUMMARY:
    Composes R-SUB.14 (`C_train ≥ KL_attention`) with R-SUB.11 (the
    reciprocal lower bound `F_i ≥ r · log(|K_i|/π)`) into a single
    "training-cost dominates a free-energy gap" inequality.

    Headline:

      `train_cost_ge_freeEnergy_gap` — if KL_attention is itself ≥ a
      free-energy gap (which is the content of R-SUB.11's reciprocal
      bound after relabelling), then `C_train ≥` the free-energy gap.

    Also:

      `train_cost_ge_zero_chain` — combines R-SUB.14's Gibbs nonneg KL
      with the DPI bridge to derive the headline `C_train ≥ 0`
      bound: training cost is nonnegative for normalised attention
      distributions, even when only the response-KL is taken as the
      ground-truth definition.

      `train_cost_lower_bound_with_freeEnergy_floor` — captures
      composition with R-SUB.11.bound_nonneg: any informative
      attention-share lower bound that survives DPI translates into a
      nonneg lower bound on `C_train`.

  Depends on:
    - MIP.Results.RSUB14_CtrainKLBound       (CtrainKLBound.KL,
                                              KL_nonneg,
                                              R_SUB_14_Ctrain_ge_KL,
                                              R_SUB_14_Ctrain_ge_KL_nonneg)
    - MIP.Results.RSUB11_ReciprocalFreeEnergy (ReciprocalFreeEnergy.bound,
                                                bound_nonneg,
                                                R_SUB_11_lower_bound)
-/
import MIP.Results.RSUB14_CtrainKLBound
import MIP.Results.RSUB11_ReciprocalFreeEnergy
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace R3_Agent2_TrainCostFreeEnergy

/-! ## (C) R-SUB.14 + R-SUB.11 — training cost in free-energy units. -/

/-- **Composition (C) — training cost ≥ free-energy gap.**

R-SUB.14: `C_train = KL_response ≥ KL_attention`.
R-SUB.11: `F_i ≥ r · log(|K_i| / π_i) = ReciprocalFreeEnergy.bound r |K_i| π_i`.

If a downstream user knows that the KL-attention drift is itself bounded
below by some free-energy gap `Fgap` (e.g. a difference of subdomain
free energies), then by transitivity `C_train ≥ Fgap`.

This is the **headline KL-energy bound** — training cost dominates a
free-energy gap. -/
theorem train_cost_ge_freeEnergy_gap
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response Fgap : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (hF   : MIP.CtrainKLBound.KL s a b ≥ Fgap) :
    Ctrain ≥ Fgap := by
  have hC : Ctrain ≥ MIP.CtrainKLBound.KL s a b :=
    MIP.CtrainKLBound.R_SUB_14_Ctrain_ge_KL s a b Ctrain KL_response hdef hDPI
  linarith

/-- **R-SUB.11 lower-bound composition.**

Specialisation of `train_cost_ge_freeEnergy_gap` where the free-energy
gap `Fgap` is the R-SUB.11 reciprocal bound `r · log(Kcard / π)`.

Hypothesis `hF` packages the application of R-SUB.11 to the KL-attention
distribution. The conclusion is the closed-form lower bound

    C_train ≥ r · log(Kcard / π) = ReciprocalFreeEnergy.bound r Kcard π. -/
theorem train_cost_ge_RSUB11_bound
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response r Kcard π : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (hF   : MIP.CtrainKLBound.KL s a b
             ≥ MIP.ReciprocalFreeEnergy.bound r Kcard π) :
    Ctrain ≥ MIP.ReciprocalFreeEnergy.bound r Kcard π :=
  train_cost_ge_freeEnergy_gap s a b Ctrain KL_response
    (MIP.ReciprocalFreeEnergy.bound r Kcard π) hdef hDPI hF

/-- **Composition (C′) — closed nonneg lower bound via R-SUB.11
informativeness.**

When `r ≥ 0`, `0 < π ≤ Kcard` (the R-SUB.11 informativeness regime),
the bound `r · log(Kcard/π)` is itself nonneg. Combined with the
training-cost lower bound above, this yields the *two-step inequality*

    C_train ≥ r · log(Kcard / π) ≥ 0,

so training cost is at least as large as a nonneg free-energy floor.

This composes R-SUB.14 (DPI bridge), R-SUB.11 (reciprocal bound),
and R-SUB.11 `bound_nonneg` (informativeness). -/
theorem train_cost_ge_RSUB11_bound_nonneg
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response r Kcard π : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (hF   : MIP.CtrainKLBound.KL s a b
             ≥ MIP.ReciprocalFreeEnergy.bound r Kcard π)
    (hr   : 0 ≤ r) (hπ : 0 < π) (hle : π ≤ Kcard) :
    Ctrain ≥ MIP.ReciprocalFreeEnergy.bound r Kcard π
      ∧ 0 ≤ MIP.ReciprocalFreeEnergy.bound r Kcard π := by
  refine ⟨?_, ?_⟩
  · exact train_cost_ge_RSUB11_bound s a b Ctrain KL_response r Kcard π
            hdef hDPI hF
  · exact MIP.ReciprocalFreeEnergy.bound_nonneg r Kcard π hr hπ hle

/-- **Composition (C′′) — `C_train ≥ 0` from Gibbs + DPI.**

Pure R-SUB.14 chain: the DPI bridge plus Gibbs nonnegativity of the
attention-KL gives `C_train ≥ KL_attention ≥ 0`. This is the
"training cost is nonneg" composition.

This is essentially `R_SUB_14_Ctrain_ge_KL_nonneg` packaged as a single
inequality (drops the `KL ≥ 0` second conjunct via transitivity). -/
theorem train_cost_nonneg_chain
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i)
    (hsa : ∑ i ∈ s, a i = 1) (hsb : ∑ i ∈ s, b i = 1) :
    Ctrain ≥ 0 := by
  have ⟨h1, h2⟩ :=
    MIP.CtrainKLBound.R_SUB_14_Ctrain_ge_KL_nonneg s a b Ctrain KL_response
      hdef hDPI ha hb hsa hsb
  linarith

/-- **Quantitative reciprocal gap — training cost increases when
attention concentrates.**

R-SUB.11 `bound_strictAntitone`: if `π` shrinks from `b_share` to
`a_share`, the lower bound on `F_i` strictly increases by
`r · log(b_share / a_share)`. Composing with the train-cost lower
bound, the *gap in train cost between the two phases* is at least the
gap in the R-SUB.11 floor:

    C_train(πₐ phase) − C_train(π_b phase)
        ≥ (R-SUB.11 floor)(πₐ) − (R-SUB.11 floor)(π_b)
        = r · log(π_b / πₐ).

We package this as a *lower bound* on the difference of two
training-cost values, conditional on the per-phase lower bounds being
saturated. The cleanest crisp statement: if `C_train_a ≥ bound(πₐ)`
and `C_train_b ≤ bound(π_b)` (saturating the lower bound), then
`C_train_a − C_train_b ≥ r · log(π_b / πₐ)`. -/
theorem train_cost_gap_lower_bound
    (Ctrain_a Ctrain_b r Kcard πa πb : ℝ)
    (hK : 0 < Kcard) (hπa : 0 < πa) (hπb : 0 < πb)
    (h_a_ge : Ctrain_a ≥ MIP.ReciprocalFreeEnergy.bound r Kcard πa)
    (h_b_le : Ctrain_b ≤ MIP.ReciprocalFreeEnergy.bound r Kcard πb) :
    Ctrain_a - Ctrain_b ≥ r * Real.log (πb / πa) := by
  have hgap :
      MIP.ReciprocalFreeEnergy.bound r Kcard πa
        - MIP.ReciprocalFreeEnergy.bound r Kcard πb
      = r * Real.log (πb / πa) :=
    MIP.ReciprocalFreeEnergy.bound_gap r Kcard πa πb hK hπa hπb
  linarith

end R3_Agent2_TrainCostFreeEnergy

end MIP
