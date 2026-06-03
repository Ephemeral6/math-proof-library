/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.1 ∧ A.3 — Expert intervention redundancy when Phi0 = 0.
  SUMMARY:
    A.1 says Phi0 = 0 ↔ N = 0 (the problem is trivially solvable).  A.3
    says expert interventions admit metacognitive substitutes within
    Cₑ(e)·log(1/ε) steps.  Combining: if Phi0 X p = 0 (the problem is
    auto-solved by X), then A.3 STILL produces a meta-substitute for
    every expert intervention — even though no intervention is needed.

    This gives a *redundancy / non-monotonicity* corollary: when Phi0=0,
    the A.3 substitute exists but is informationally redundant.  We
    formalise the following statements (none in Corollaries/ or Results/):
      (i)  `phi0_zero_yet_A3_substitute_exists`: simultaneous A.1+A.3
           statement — Phi0=0 AND a metacognitive sequence for any expert
           intervention with covered knowledge.
      (ii) `expert_substitute_when_already_solved`: structural statement
           about the redundancy ratio — when N = 0, the A.3 substitute's
           length bound `Cₑ(e)·log(1/ε)` is an *overestimate* relative to
           the true required interventions (which is 0).
      (iii)`trivial_problem_meta_substitute`: specialisation to the
           always-true problem (`fun _ => true`), where `Phi0 = 0` is
           definitionally true (`Phi0_always_true`).  Direct A.1 input,
           direct A.3 application — clean stand-alone witness.

    The substantive content: A.1+A.3 give a "trivial-problem A.3" — the
    substitute exists without needing any A.2 coverage argument.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A1A3_RedundantExpert

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-- **A.1+A.3 — Simultaneous "already solved" and "expert substitute exists".**

Suppose `Phi0 X p = 0`, so by A.1 the problem is trivially solved
(`N p X = 0`).  Then for any expert intervention `e ∈ Σ* \ M` with
covered knowledge, A.3 still produces a metacognitive substitute of
length `≤ Cₑ(e)·log(1/ε)`.  The two statements coexist:

* No intervention is needed (A.1).
* If you nonetheless apply an expert one, a meta-substitute exists (A.3).

This is the A.1+A.3 redundancy theorem. -/
theorem phi0_zero_yet_A3_substitute_exists
    (X : Agent α) (e h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (p : Problem α)
    (hPhi : Phi0 X p = 0) :
    N p X = 0 ∧ ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  refine ⟨(Axioms.A1 p X).mpr hPhi, ?_⟩
  exact Axioms.A3 (Ω := Ω) X e h ε hε hMem hCover

/-- **A.1+A.3 — Trivial-problem (always-true) meta-substitute.**

Specialised to the always-true problem `p_T := fun _ => true`, where
`Phi0 X p_T = 0` is automatic by `Phi0_always_true`.  Hence `N p_T X = 0`
(A.1), and A.3 still provides a meta-substitute for any A.3-eligible
expert intervention.  No `Phi0`-hypothesis required. -/
theorem trivial_problem_meta_substitute
    (X : Agent α) (e h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)) :
    let p_T : Problem α := fun _ => true
    N p_T X = 0 ∧ ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (extendHist h e))
              (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  intro p_T
  have hPhi : Phi0 X p_T = 0 := Phi0_always_true X
  exact phi0_zero_yet_A3_substitute_exists (Ω := Ω) X e h ε hε hMem hCover p_T hPhi

/-- **A.1+A.3 — Redundancy via the substitute length bound.**

Even when `Phi0 = 0` (so zero interventions are required), A.3's
length bound `Cₑ(e)·log(1/ε)` is the *upper bound* on the meta-substitute
length, which is itself ≥ 0.  In particular, the bound is nonnegative
whenever ε ≤ 1 (so `log(1/ε) ≥ 0` and `Cₑ e ≥ 0` as an NNReal cast). -/
theorem A3_length_bound_nonneg_when_eps_le_one
    (e : Str α) (ε : NNReal)
    (hε_le : (ε : ℝ) ≤ 1) (hε_pos : 0 < ε) :
    0 ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ)) := by
  apply mul_nonneg
  · exact NNReal.coe_nonneg _
  · rw [Real.log_div one_ne_zero (by
      have : (0 : ℝ) < (ε : ℝ) := NNReal.coe_pos.mpr hε_pos
      linarith)]
    simp only [Real.log_one, zero_sub, neg_nonneg]
    exact Real.log_nonpos (NNReal.coe_nonneg _) hε_le

/-- **A.1+A.3 — Combined redundancy statement.**

The "redundancy" version of `phi0_zero_yet_A3_substitute_exists` that
also exposes the nonnegativity of the length bound.  Useful as a single
ready-to-use citation. -/
theorem phi0_zero_substitute_with_nonneg_bound
    (X : Agent α) (e h : Str α) (ε : NNReal) (hε : 0 < ε) (hε_le : (ε : ℝ) ≤ 1)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (p : Problem α)
    (hPhi : Phi0 X p = 0) :
    N p X = 0 ∧
      0 ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ)) ∧
      ∃ (ms : List (Str α)),
        (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
          ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
          ∧ tvDist
                (X (extendHist h e))
                (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  obtain ⟨hN, hSub⟩ :=
    phi0_zero_yet_A3_substitute_exists (Ω := Ω) X e h ε hε hMem hCover p hPhi
  exact ⟨hN, A3_length_bound_nonneg_when_eps_le_one e ε hε_le hε, hSub⟩

end Agent1_A1A3_RedundantExpert

end MIP
