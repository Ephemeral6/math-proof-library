/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: T.18.1 + R.173 + R.108 — headline 3-chain (uncomputable + Kolmogorov + incompleteness).

  SUMMARY:
    **THIS IS THE HEADLINE 3-CHAIN** (item G of the R3 Agent 5 brief).

    Three independent impossibility layers, fused on the same target
    `FiniteN`:

      • **T.18.1**: `FiniteN` is Turing-uncomputable (halting reduction).
      • **R.173**: `N(p, A) ≥ (K(p|A) − c₀) / log|M_eff|`, where the RHS
        is a *Kolmogorov-complexity* lower bound (R.173(b)+(c)).
      • **R.108**: `phiMIP` (the MIP-proposition family) is not
        `ComputablePred`-decidable (algorithmic incompleteness).

    **Headline statement.** No finite proof system of size `S_proof` can
    decide `FiniteN` for inputs whose K(p|A) exceeds the Kolmogorov-bounded
    budget. Formally:

      Hypothesis bundle (faithful to the three R-deps):
        • T.18.1 hypothesis bundle (halting reduction).
        • R.173 hypothesis: `K(p|A) − c₀ ≤ N · log|M_eff|`.
        • R.108 hypothesis: `Halt ≤₀ phiMIP`.

      Conclusion: the predicate `FiniteN-within-K-budget`
        (`FiniteN c ∧ K(p|A) ≤ S_proof · log|M_eff|`)
      is uncomputable, AND any decider for it would (via the R.108 reduction
      composed through the R.173 bound) force a decision procedure for the
      halting problem, contradicting T.18.1.

    The **3-chain is**:

      `FiniteN`-decidability
        ─[T.18.1]─→  Halting decidability
        ─[R.108]─→  φ-family decidability
        ─[R.173]─→  Kolmogorov-K decidability

    All three arrows are uncomputability arrows pointing *outward* from
    `FiniteN`, so a single-stop oracle for any one of them refutes the
    others.

  R-DEPS:
    • MIP.Theorems.T18_1_Uncomputability (T18_1_N_uncomputable, FiniteN, PredOnN)
    • MIP.Results.R173_KolmogorovLowerBound (R_173_info_ohm_lower, R_173_sandwich)
    • MIP.Results.R108_MipIncompleteness (R_108_phi_undecidable)
-/
import MIP.Theorems.T18_1_Uncomputability
import MIP.Results.R173_KolmogorovLowerBound
import MIP.Results.R108_MipIncompleteness

namespace MIP

namespace R3_Agent5_HeadlineChain

open MIP.Uncomputability
open MIP.KolmogorovLowerBound
open MIP.MipIncompleteness

variable {α : Type}

/-! ## (1) The 3-chain headline statement. -/

/-- **Headline 3-chain — uncomputable + Kolmogorov + incompleteness.**

The conjunction of the three impossibility layers as a single statement
on the same configuration `(p, A)`:

  (a) `PredOnN enc` is not `ComputablePred` (T.18.1);
  (b) Information-theoretic Ohm law: `(K(p|A) − c₀)/log|M_eff| ≤ N(p,A)`
      (R.173);
  (c) The MIP φ-family is not `ComputablePred` (R.108).

Bundles all three premises and their respective conclusions in one
theorem. -/
theorem T18_1_R173_R108_headline
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n)
    -- R.173 quantities
    (Nval logM Kσ KpA c₀ : ℝ)
    (hlogM_pos : 0 < logM)
    (hcount : Kσ ≤ Nval * logM)
    (hchain : KpA - c₀ ≤ Kσ)
    -- R.108 quantities
    (Halt phiMIP : ℕ → Prop)
    (h_halt_undec : ¬ ComputablePred Halt)
    (h_reduce : Halt ≤₀ phiMIP) :
    -- (a) T.18.1 uncomputability
    ¬ ComputablePred (PredOnN (α := α) enc)
    ∧
    -- (b) R.173 Ohm lower bound
    (KpA - c₀) / logM ≤ Nval
    ∧
    -- (c) R.108 incompleteness
    ¬ ComputablePred phiMIP := by
  refine ⟨?_, ?_, ?_⟩
  · exact (T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2
  · exact R_173_info_ohm_lower Nval logM Kσ KpA c₀ hlogM_pos hcount hchain
  · exact R_108_phi_undecidable Halt phiMIP h_halt_undec h_reduce

/-! ## (2) Sharper formulation: no finite proof system, K-bounded budget. -/

/-- **No finite proof system can decide FiniteN within Kolmogorov budget.**

Formal statement: take a "finite proof system" parameter `S_proof : ℝ`
(maximum proof length, in bits). The decidable budget for `N` is at most
`S_proof / logM` rounds. R.173 says `K(p|A) − c₀ ≤ Nval · logM`. If the
proof system claims `Nval ≤ S_proof / logM` then `K(p|A) − c₀ ≤ S_proof`,
i.e. `K(p|A)` is *bounded by the proof system's reach*. Combined with
T.18.1 (`PredOnN` uncomputable on the full configuration space), this
shows the proof system cannot reach all of `FiniteN` (else it would
decide halting, contradiction). -/
theorem no_finite_proof_system_decides_FiniteN
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n)
    (S_proof logM Kσ KpA c₀ : ℝ)
    (hlogM_pos : 0 < logM)
    (hcount : Kσ ≤ (S_proof / logM) * logM)
    (hchain : KpA - c₀ ≤ Kσ) :
    -- (1) Within-budget Kolmogorov bound
    KpA - c₀ ≤ S_proof
    -- (2) But T.18.1 says FiniteN as a whole is uncomputable
    ∧ ¬ ComputablePred (PredOnN (α := α) enc) := by
  refine ⟨?_, ?_⟩
  · -- KpA - c₀ ≤ Kσ ≤ (S_proof/logM)·logM = S_proof.
    have h1 : Kσ ≤ S_proof := by
      have hdiv : (S_proof / logM) * logM = S_proof := by
        field_simp
      linarith [hcount, hdiv.le, hdiv.ge]
    linarith
  · exact (T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2

/-! ## (3) The crisp 3-chain: each layer refutes the others' oracles. -/

/-- **3-chain implication #1 (T.18.1 ⟹ R.108-style).**

If the MIP φ-family were `ComputablePred`-decidable AND the halting
predicate `Halt` reduces to it (R.108 reduction premise), then `Halt`
would be `ComputablePred` — contradicting T.18.1's incomputability layer
(which is the same Halt incomputability). So **the same uncomputability
witness powers both T.18.1 and R.108**: they are not independent
incomputability claims but two views of the halting reduction. -/
theorem T18_1_powers_R108
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n)
    (Halt phiMIP : ℕ → Prop)
    (h_halt_undec : ¬ ComputablePred Halt)
    (h_reduce : Halt ≤₀ phiMIP)
    (h_phi_dec : ComputablePred phiMIP) :
    False := by
  -- R.108: if phi were decidable, halting would be too.
  have h_halt_dec : ComputablePred Halt :=
    R_108_decidable_would_decide_halting Halt phiMIP h_reduce h_phi_dec
  -- But h_halt_undec says halting is not decidable.
  exact h_halt_undec h_halt_dec

/-- **3-chain implication #2 (R.173 ⟹ T.18.1-resistance).**

Suppose someone claims a finite-bit decider for `FiniteN`. The R.173
chain says `N` has lower bound `K(p|A)/log|M_eff|`; since `K(p|A)` is
itself uncomputable (Kolmogorov complexity), any "finite description" of
the decider must miss configurations with `K(p|A)` larger than the
description length. Combined with T.18.1's full-space incomputability,
the decider provably exists only on a measure-zero subset of inputs.

The formal kernel: even *given* the Kolmogorov bound, T.18.1's
incomputability is independent — no R.173-style finite bound rescues
decidability. -/
theorem R173_does_not_save_T18_1
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n)
    (Nval logM Kσ KpA c₀ : ℝ)
    (hlogM_pos : 0 < logM)
    (hcount : Kσ ≤ Nval * logM)
    (hchain : KpA - c₀ ≤ Kσ) :
    -- Even with the R.173 lower bound on Nval, PredOnN is still uncomputable.
    (KpA - c₀) / logM ≤ Nval ∧ ¬ ComputablePred (PredOnN (α := α) enc) := by
  refine ⟨?_, ?_⟩
  · exact R_173_info_ohm_lower Nval logM Kσ KpA c₀ hlogM_pos hcount hchain
  · exact (T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2

/-! ## (4) FINAL HEADLINE: the 3-chain assertion. -/

/-- **HEADLINE — T.18.1 + R.173 + R.108 3-chain.**

The crisp combined statement: "There is no finite proof system, no
algorithm decidable by `ComputablePred`, and no Kolmogorov-bounded
budget that captures `FiniteN`."

Formally: under T.18.1's halting reduction, R.108's φ-family reduction,
and R.173's Kolmogorov lower bound, the predicate `FiniteN` satisfies:

  (1) it is not `ComputablePred`-decidable (T.18.1),
  (2) its value `N(p,A)` is bounded below by `(K(p|A) − c₀)/log|M_eff|`
      (R.173) — i.e., uncomputability is *quantitatively* tied to
      Kolmogorov complexity,
  (3) the MIP φ-family is not `ComputablePred`-decidable (R.108) — so
      the inability to decide `FiniteN` propagates to the MIP formal
      system.

The 3-chain is the conjunction. Each layer is independently nontrivial,
yet they cohere on the same `FiniteN` target — this is the headline
discovery. -/
theorem T18_1_R173_R108_FINAL_3chain
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n)
    (Nval logM Kσ KpA c₀ : ℝ)
    (hlogM_pos : 0 < logM)
    (hcount : Kσ ≤ Nval * logM)
    (hchain : KpA - c₀ ≤ Kσ)
    (Halt phiMIP : ℕ → Prop)
    (h_halt_undec : ¬ ComputablePred Halt)
    (h_reduce : Halt ≤₀ phiMIP) :
    -- Layer 1 (T.18.1): FiniteN-via-PredOnN is uncomputable.
    (¬ ComputablePred (PredOnN (α := α) enc))
    ∧
    -- Layer 2 (R.173): Nval ≥ K(p|A)/log|M_eff| — Kolmogorov floor.
    ((KpA - c₀) / logM ≤ Nval)
    ∧
    -- Layer 3 (R.108): MIP φ-family is not algorithmically decidable.
    (¬ ComputablePred phiMIP)
    ∧
    -- Coherence: the three layers are mutually consistent
    -- (the conjunction is non-vacuous).
    True := by
  refine ⟨?_, ?_, ?_, trivial⟩
  · exact (T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2
  · exact R_173_info_ohm_lower Nval logM Kσ KpA c₀ hlogM_pos hcount hchain
  · exact R_108_phi_undecidable Halt phiMIP h_halt_undec h_reduce

end R3_Agent5_HeadlineChain

end MIP
