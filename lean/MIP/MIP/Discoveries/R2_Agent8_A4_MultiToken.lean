/-
  STATUS: DISCOVERY
  AGENT: R2-8
  DIRECTION: A.4 — iterated invariance over multi-token sequences and
             finsets of outside-K(X) tokens.
  SUMMARY:
    A.4 says that a single token `ω ∉ K X` is behaviourally inert:
    `X h = X (tokenReplace ω h)`. By composing the axiom we can iterate:
    a *pair* of outside tokens, a *list* of outside tokens, and even a
    `Finset` of outside tokens (via `Finset.toList`) all leave the
    response distribution untouched. We record the explicit forms

       two_token_invariance      — two outside tokens, any order on the
                                   substitution stack
       list_invariance_foldr     — `ωs.foldr tokenReplace h`
       list_invariance_foldl     — `ωs.foldl (flip tokenReplace) h`
       finset_invariance         — same statement via `F.toList`.

    The Finset form does NOT depend on the order in which tokens are
    enumerated, since the conclusion `X h = X (...)` is by repeated
    rewrites through A.4, and A.4 is order-blind on the X-output side
    (see also `R2_Agent8_A4_OrderIndep`).  The list / finset versions
    subsume Agent 1's `behavEq_of_A4_list` (we restate the list form
    here for self-containment).
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent8_A4_MultiToken

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## Single-token reminder (just A.4). -/

/-- **A.4 — single token form, restated.**
For any `ω ∉ K X` and any history `h`,
`X h = X (tokenReplace ω h)`. -/
theorem one_token_invariance
    (X : Agent α) (ω : Ω) (h : Str α)
    (hOut : ω ∉ (K X : Set Ω)) :
    X h = X (tokenReplace ω h) := Axioms.A4 X ω h hOut

/-! ## Two-token form. -/

/-- **A.4 — two-token invariance.**
For any two outside tokens `ω₁, ω₂ ∉ K X`,
`X h = X (tokenReplace ω₁ (tokenReplace ω₂ h))`. -/
theorem two_token_invariance
    (X : Agent α) (ω₁ ω₂ : Ω) (h : Str α)
    (hOut₁ : ω₁ ∉ (K X : Set Ω))
    (hOut₂ : ω₂ ∉ (K X : Set Ω)) :
    X h = X (tokenReplace ω₁ (tokenReplace ω₂ h)) := by
  calc
    X h
        = X (tokenReplace ω₂ h) := Axioms.A4 X ω₂ h hOut₂
    _ = X (tokenReplace ω₁ (tokenReplace ω₂ h)) :=
          Axioms.A4 X ω₁ (tokenReplace ω₂ h) hOut₁

/-! ## List form via foldr. -/

/-- **A.4 — list-iterated invariance (foldr form).**
For any list `ωs` of outside tokens,
`X h = X (ωs.foldr tokenReplace h)`. -/
theorem list_invariance_foldr
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

/-! ## List form via foldl. -/

/-- **A.4 — list-iterated invariance (foldl form).**
For any list `ωs` of outside tokens,
`X h = X (ωs.foldl (fun s ω => tokenReplace ω s) h)`.
This is the "left-fold" version: tokens are consumed left-to-right
and stacked onto `h`.  Proven by induction on `ωs` while generalising
the starting history. -/
theorem list_invariance_foldl
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X h = X (ωs.foldl (fun s ω => tokenReplace ω s) h) := by
  induction ωs generalizing h with
  | nil => rfl
  | cons ω rest ih =>
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      -- LHS one step: X h = X (tokenReplace ω h) by A.4.
      have step : X h = X (tokenReplace ω h) := Axioms.A4 X ω h hHead
      -- Apply ih at the new history `tokenReplace ω h`.
      calc
        X h = X (tokenReplace ω h) := step
        _ = X (rest.foldl (fun s ω' => tokenReplace ω' s) (tokenReplace ω h)) :=
              ih (tokenReplace ω h) hRest
        _ = X ((ω :: rest).foldl (fun s ω' => tokenReplace ω' s) h) := rfl

/-! ## Finset form. -/

/-- **A.4 — Finset-iterated invariance (via toList).**
For any finset `F : Finset Ω` of tokens all outside `K X`,
`X h = X (F.toList.foldr tokenReplace h)`.
The membership hypothesis is given over `F`; coercion to list membership
is via `Finset.mem_toList`. -/
theorem finset_invariance
    (X : Agent α) (F : Finset Ω) (h : Str α)
    (hOut : ∀ ω ∈ F, ω ∉ (K X : Set Ω)) :
    X h = X (F.toList.foldr tokenReplace h) := by
  apply list_invariance_foldr X F.toList h
  intro ω hω
  exact hOut ω ((Finset.mem_toList).mp hω)

/-- **A.4 — Finset-iterated invariance via complement hypothesis.**
Variant where the outside-K hypothesis is expressed as
`(F : Set Ω) ⊆ (K X)ᶜ`. -/
theorem finset_invariance_compl
    (X : Agent α) (F : Finset Ω) (h : Str α)
    (hOut : (F : Set Ω) ⊆ ((K X : Set Ω))ᶜ) :
    X h = X (F.toList.foldr tokenReplace h) := by
  apply finset_invariance X F h
  intro ω hω
  exact hOut (by exact_mod_cast hω)

end R2_Agent8_A4_MultiToken

end MIP
