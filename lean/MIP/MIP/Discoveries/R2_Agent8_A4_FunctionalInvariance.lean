/-
  STATUS: DISCOVERY
  AGENT: R2-8
  DIRECTION: A.4 — every output functional `f : PMF (Str α) → β` is
             invariant under outside-K(X) `tokenReplace`.
  SUMMARY:
    A.4 gives `X h = X (tokenReplace ω h)` for `ω ∉ K X` — i.e. the X-output
    distribution is identical on both histories.  By congruence, ANY
    functional `f : PMF (Str α) → β` (mean, variance, KL, entropy,
    boolean predicate, ...) satisfies
        f (X h) = f (X (tokenReplace ω h)).

    Trivially `congrArg`-derivable but worth recording as a clean lemma:
    it packages A.4 in the "functional / observable" language.

    We prove:
      (1) functional_invariant_single        single token
      (2) functional_invariant_foldr         list of outside-K tokens
      (3) functional_invariant_two_tokens    two tokens (illustrative)
      (4) two specific instantiations: a boolean predicate, a real-valued
          functional, as sample applications.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent8_A4_FunctionalInvariance

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) Single-token functional invariance. -/

/-- **A.4 — functional invariance (single token).**

For any function `f : PMF (Str α) → β` and outside-K token `ω`,
`f (X h) = f (X (tokenReplace ω h))`. -/
theorem functional_invariant_single
    {β : Sort*} (f : PMF (Str α) → β)
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    f (X h) = f (X (tokenReplace ω h)) := by
  congr 1
  exact Axioms.A4 X ω h hOut

/-! ## (2) Two-token form. -/

/-- **A.4 — functional invariance (two tokens).** -/
theorem functional_invariant_two_tokens
    {β : Sort*} (f : PMF (Str α) → β)
    (X : Agent α) (ω₁ ω₂ : Ω) (h : Str α)
    (hOut₁ : ω₁ ∉ (K X : Set Ω))
    (hOut₂ : ω₂ ∉ (K X : Set Ω)) :
    f (X h) = f (X (tokenReplace ω₁ (tokenReplace ω₂ h))) := by
  have e1 : X h = X (tokenReplace ω₂ h) := Axioms.A4 X ω₂ h hOut₂
  have e2 : X (tokenReplace ω₂ h)
              = X (tokenReplace ω₁ (tokenReplace ω₂ h)) :=
    Axioms.A4 X ω₁ (tokenReplace ω₂ h) hOut₁
  congr 1
  exact e1.trans e2

/-! ## (3) List form. -/

private theorem X_h_eq_X_foldr
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X h = X (ωs.foldr tokenReplace h) := by
  induction ωs generalizing h with
  | nil => rfl
  | cons ω rest ih =>
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      calc
        X h = X (rest.foldr tokenReplace h) := ih h hRest
        _ = X (tokenReplace ω (rest.foldr tokenReplace h)) :=
              Axioms.A4 X ω _ hHead
        _ = X ((ω :: rest).foldr tokenReplace h) := rfl

/-- **A.4 — functional invariance (foldr of outside-K tokens).** -/
theorem functional_invariant_foldr
    {β : Sort*} (f : PMF (Str α) → β)
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    f (X h) = f (X (ωs.foldr tokenReplace h)) := by
  congr 1
  exact X_h_eq_X_foldr X ωs h hOut

/-! ## (4) Two concrete instantiations. -/

/-- **A.4 — boolean predicate on X-output is invariant.** -/
theorem bool_predicate_invariant
    (P : PMF (Str α) → Bool)
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    P (X h) = P (X (tokenReplace ω h)) :=
  functional_invariant_single P X ω h hOut

/-- **A.4 — real-valued functional on X-output is invariant.** -/
theorem real_functional_invariant
    (f : PMF (Str α) → ℝ)
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    f (X h) = f (X (tokenReplace ω h)) :=
  functional_invariant_single f X ω h hOut

/-- **A.4 — `Prop`-valued predicate on X-output is invariant.** -/
theorem prop_predicate_invariant
    (P : PMF (Str α) → Prop)
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    P (X h) ↔ P (X (tokenReplace ω h)) := by
  rw [Axioms.A4 X ω h hOut]

/-- **A.4 — TV distance to a fixed target is invariant.**
For any reference distribution `Y h₀`, the TV distance from `X h` to
`Y h₀` equals that from `X (tokenReplace ω h)` to `Y h₀` when
`ω ∉ K X`. -/
theorem tvDist_to_target_invariant
    (X Y : Agent α) (ω : Ω) (h h₀ : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    tvDist (X h) (Y h₀) = tvDist (X (tokenReplace ω h)) (Y h₀) := by
  congr 1
  exact Axioms.A4 X ω h hOut

/-- **A.4 — congruence with arbitrary binary operator on X-output.**
For any `g : PMF (Str α) → PMF (Str α) → β` and `ω ∉ K X`,
`g (X h₁) (X h₂) = g (X (tokenReplace ω h₁)) (X h₂)`. -/
theorem binary_functional_invariant_left
    {β : Sort*} (g : PMF (Str α) → PMF (Str α) → β)
    (X : Agent α) (ω : Ω) (h₁ h₂ : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    g (X h₁) (X h₂) = g (X (tokenReplace ω h₁)) (X h₂) := by
  rw [Axioms.A4 X ω h₁ hOut]

end R2_Agent8_A4_FunctionalInvariance

end MIP
