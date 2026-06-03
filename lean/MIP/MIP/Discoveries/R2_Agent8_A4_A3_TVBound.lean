/-
  STATUS: DISCOVERY
  AGENT: R2-8
  DIRECTION: A.3 + A.4 — applying A.4 to a token in the augmented
             history preserves the A.3 ε-TV bound.
  SUMMARY:
    A.3 produces a meta-substitute `ms` for an A.3-eligible expert `e`
    such that
       tvDist (X (h ++ e)) (X (h ++ ms.flat)) ≤ ε.
    A.4 says: applying `tokenReplace ω` to ANY history `h'` (with
    `ω ∉ K X`) preserves `X h'`.

    Composition: if we apply A.4 to the *concatenated* history
    `h ++ e` (or `h ++ ms.flat`) with an outside-K token, we obtain a
    new history whose X-distribution is identical to the original.
    Substituting this into A.3's TV inequality preserves the ≤ ε bound.

    The cleanest statement:
       tvDist (X (h ++ e)) (X (h ++ ms.flat)) ≤ ε
         ⟹ tvDist (X (tokenReplace ω (h ++ e)))
                  (X (tokenReplace ω (h ++ ms.flat))) ≤ ε
    when `ω ∉ K X`.

    More generally, for a *list* of outside-K tokens applied in any
    way (foldr) to BOTH sides of A.3's TV-bound, the bound is
    preserved.

    The bound preservation under A.4 means: in the natural-language
    setting, "adding distractor / out-of-knowledge tokens to a prompt
    sequence does not weaken the meta-cognitive A.3-substitute ε
    guarantee".
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent8_A4_A3_TVBound

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) Single-token preservation. -/

/-- **A.4 — tokenReplace preserves X-output (sym form).**
For `ω ∉ K X`, `X (tokenReplace ω h') = X h'`. -/
private theorem X_tokenReplace_eq
    (X : Agent α) (ω : Ω) (h' : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    X (tokenReplace ω h') = X h' := (Axioms.A4 X ω h' hOut).symm

/-- **A.3 + A.4 — TV bound is preserved when tokenReplace applied to both
sides.**

If `tvDist (X u) (X v) ≤ ε` and we apply `tokenReplace ω` (outside-K) to
*both* `u` and `v`, the bound still holds. -/
theorem tvBound_preserved_single
    (X : Agent α) (ω : Ω) (u v : Str α) (ε : NNReal)
    (hOut : ω ∉ (K X : Set Ω))
    (hTV : tvDist (X u) (X v) ≤ ε) :
    tvDist (X (tokenReplace ω u)) (X (tokenReplace ω v)) ≤ ε := by
  rw [X_tokenReplace_eq X ω u hOut, X_tokenReplace_eq X ω v hOut]
  exact hTV

/-! ## (2) List form: foldr of outside-K tokens preserves TV bound. -/

/-- **A.4 — `X (foldr tokenReplace) = X` on outside-K lists.**
For `ωs` all outside `K X`, `X (ωs.foldr tokenReplace h') = X h'`. -/
private theorem X_foldr_eq
    (X : Agent α) (ωs : List Ω) (h' : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X (ωs.foldr tokenReplace h') = X h' := by
  induction ωs generalizing h' with
  | nil => rfl
  | cons ω rest ih =>
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      show X (tokenReplace ω (rest.foldr tokenReplace h')) = X h'
      have e1 : X (tokenReplace ω (rest.foldr tokenReplace h'))
                  = X (rest.foldr tokenReplace h') :=
        (Axioms.A4 X ω _ hHead).symm
      exact e1.trans (ih h' hRest)

/-- **A.3 + A.4 — TV bound preserved under foldr of outside-K tokens.** -/
theorem tvBound_preserved_foldr
    (X : Agent α) (ωs : List Ω) (u v : Str α) (ε : NNReal)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (hTV : tvDist (X u) (X v) ≤ ε) :
    tvDist (X (ωs.foldr tokenReplace u)) (X (ωs.foldr tokenReplace v)) ≤ ε := by
  rw [X_foldr_eq X ωs u hOut, X_foldr_eq X ωs v hOut]
  exact hTV

/-! ## (3) A.3 + A.4 — explicit substitute preservation. -/

/-- **A.3 + A.4 — A.3 substitute is robust to outside-K token insertion.**

Take any A.3 substitute `ms` for an eligible expert `e` with TV ≤ ε from
`X (h ++ e)`.  Then for any outside-K token `ω`, applying
`tokenReplace ω` to both augmented histories preserves the ε bound. -/
theorem A3_substitute_robust_under_A4_single
    (X : Agent α) (e h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (ω : Ω) (hOut : ω ∉ (K X : Set Ω)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (tokenReplace ω (extendHist h e)))
              (X (tokenReplace ω (extendHist h (ms.foldl List.append [])))) ≤ ε := by
  obtain ⟨ms, hMs, hLen, hTV⟩ := Axioms.A3 (Ω := Ω) X e h ε hε hMem hCover
  refine ⟨ms, hMs, hLen, ?_⟩
  exact tvBound_preserved_single X ω _ _ ε hOut hTV

/-- **A.3 + A.4 — A.3 substitute is robust to a foldr of outside-K
tokens.** -/
theorem A3_substitute_robust_under_A4_foldr
    (X : Agent α) (e h : Str α) (ε : NNReal) (hε : 0 < ε)
    (hMem : e ∉ (MetaSet : Set (Str α)))
    (hCover : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (ωs : List Ω) (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    ∃ (ms : List (Str α)),
      (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
        ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
        ∧ tvDist
              (X (ωs.foldr tokenReplace (extendHist h e)))
              (X (ωs.foldr tokenReplace (extendHist h (ms.foldl List.append [])))) ≤ ε := by
  obtain ⟨ms, hMs, hLen, hTV⟩ := Axioms.A3 (Ω := Ω) X e h ε hε hMem hCover
  refine ⟨ms, hMs, hLen, ?_⟩
  exact tvBound_preserved_foldr X ωs _ _ ε hOut hTV

end R2_Agent8_A4_A3_TVBound

end MIP
