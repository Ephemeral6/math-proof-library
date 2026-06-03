/-
  STATUS: DISCOVERY
  AGENT: R2-8
  DIRECTION: A.4 — `behavEq X` is an equivalence relation on histories;
             prompt-equivalence quotient; `tokenReplace` of outside-K
             tokens descends to the identity on the quotient.
  SUMMARY:
    Per agent `X`, define
        behavEq X h₁ h₂ ↔ X h₁ = X h₂.
    This is trivially reflexive, symmetric, transitive: a `Setoid`
    instance.  The quotient `Quotient (behavSetoid X)` is the "prompt
    equivalence class" type per the user's specific ask.

    A.4 says: for `ω ∉ K X`, `behavEq X h (tokenReplace ω h)` — i.e. the
    syntactic operation `tokenReplace ω` is "equivalent to identity" on
    the X-quotient.  Lifting via `Quotient.lift`, the map
        Quotient.mk (behavSetoid X) ∘ tokenReplace ω
            = Quotient.mk (behavSetoid X)
    as functions `Str α → Quotient (behavSetoid X)`.

    We also state the iterated form: every `OutsideOrbit X h` element
    has the same behaviour as `h` (this packages
    `R2_Agent8_A4_OrderIndep.list_foldr_collapses_to_h` as a sub-orbit
    statement).
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent8_A4_BehavEq_Setoid

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) `behavEq X` and its `Setoid` instance. -/

/-- **Behavioural equality at agent `X`.**
`behavEq X h₁ h₂ ↔ X h₁ = X h₂`. -/
def behavEq (X : Agent α) (h₁ h₂ : Str α) : Prop := X h₁ = X h₂

@[simp] theorem behavEq_refl (X : Agent α) (h : Str α) : behavEq X h h := rfl

theorem behavEq_symm {X : Agent α} {h₁ h₂ : Str α}
    (h : behavEq X h₁ h₂) : behavEq X h₂ h₁ := h.symm

theorem behavEq_trans {X : Agent α} {h₁ h₂ h₃ : Str α}
    (h12 : behavEq X h₁ h₂) (h23 : behavEq X h₂ h₃) :
    behavEq X h₁ h₃ := h12.trans h23

/-- **Behavioural equality is an equivalence relation** (`Setoid`). -/
def behavSetoid (X : Agent α) : Setoid (Str α) where
  r := behavEq X
  iseqv := ⟨behavEq_refl X, behavEq_symm, behavEq_trans⟩

/-! ## (2) Prompt equivalence class (quotient). -/

/-- **Prompt equivalence class type** for agent `X`.  An element is an
equivalence class of histories under `behavEq X`. -/
def PromptEqClass (X : Agent α) : Type := Quotient (behavSetoid X)

/-- **Prompt equivalence class projection.**  Maps a syntactic history
to its class. -/
def promptClass (X : Agent α) (h : Str α) : PromptEqClass X :=
  Quotient.mk (behavSetoid X) h

/-! ## (3) A.4 in the new language. -/

/-- **A.4 in behavEq form.**  For `ω ∉ K X` and any `h`,
`behavEq X h (tokenReplace ω h)`. -/
theorem behavEq_tokenReplace_of_outK
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    behavEq X h (tokenReplace ω h) := Axioms.A4 X ω h hOut

/-- **A.4 — `tokenReplace ω` of an outside-K token descends to identity
on the quotient.** -/
theorem promptClass_tokenReplace_eq
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    promptClass X (tokenReplace ω h) = promptClass X h := by
  refine Quotient.sound ?_
  -- Need: behavSetoid X (tokenReplace ω h) h
  exact (Axioms.A4 X ω h hOut).symm

/-! ## (4) OutsideOrbit and its containment in the behavEq class. -/

/-- **OutsideOrbit X h**: histories reachable from `h` by a foldr of
outside-K(X) tokens.  Encoded existentially over the chosen list. -/
def OutsideOrbit (X : Agent α) (h : Str α) : Set (Str α) :=
  { h' | ∃ ωs : List Ω,
            (∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
            ∧ h' = ωs.foldr tokenReplace h }

/-- **A.4 list-iteration helper** (local). -/
private theorem outK_foldr_invariance
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

/-- **OutsideOrbit ⊆ behavEq class.**  Every element of `OutsideOrbit X h`
is behaviourally equal to `h`. -/
theorem outsideOrbit_subset_behavClass
    (X : Agent α) (h : Str α) :
    OutsideOrbit (Ω := Ω) X h ⊆ { h' | X h' = X h } := by
  rintro h' ⟨ωs, hOut, rfl⟩
  -- Goal: X (ωs.foldr tokenReplace h) = X h
  exact (outK_foldr_invariance X ωs h hOut).symm

/-- **OutsideOrbit projects to a single class.**  For every
`h' ∈ OutsideOrbit X h`, `promptClass X h' = promptClass X h`. -/
theorem promptClass_constant_on_outsideOrbit
    (X : Agent α) (h h' : Str α)
    (hh' : h' ∈ OutsideOrbit (Ω := Ω) X h) :
    promptClass X h' = promptClass X h := by
  refine Quotient.sound ?_
  exact outsideOrbit_subset_behavClass X h hh'

/-! ## (5) The quotient-identity packaging. -/

/-- **A.4 quotient identity.**  For any outside-K token `ω`, the
composition `promptClass X ∘ tokenReplace ω = promptClass X` as
functions on `Str α`.  Packages A.4 as "tokenReplace lives in the
kernel of the quotient projection on outside-K tokens". -/
theorem promptClass_comp_tokenReplace
    (X : Agent α) (ω : Ω)
    (hOut : ω ∉ (K X : Set Ω)) :
    (fun h => promptClass X (tokenReplace ω h))
      = (fun h => promptClass X h) := by
  funext h
  exact promptClass_tokenReplace_eq X ω h hOut

end R2_Agent8_A4_BehavEq_Setoid

end MIP
