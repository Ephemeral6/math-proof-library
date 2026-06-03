/-
  STATUS: DISCOVERY
  AGENT: R2-8
  DIRECTION: A.4 — order independence of multi-token replacement
             *at the X-output level*.
  SUMMARY:
    For any two outside-K(X) tokens `ω₁, ω₂`, the syntactic histories
    `tokenReplace ω₁ (tokenReplace ω₂ h)` and `tokenReplace ω₂ (tokenReplace ω₁ h)`
    may differ — `tokenReplace` is opaque, so there is no commutation
    law. But A.4 says BOTH equal `X h`, so

         X (tokenReplace ω₁ (tokenReplace ω₂ h))
       = X h
       = X (tokenReplace ω₂ (tokenReplace ω₁ h)).

    Crisply: composition of `tokenReplace`s lives in a normal subgroup
    of `(Str α → Str α)` w.r.t. the equivalence "agrees on every X-output".

    We record:
      pair_swap_invariance           — the two-token swap.
      pair_swap_invariance_chain     — both equal X h (intermediate).
      list_perm_invariance           — any two foldr orders of an
                                       outside-K token list collapse to
                                       the SAME X-output.

    The list-permutation form is the genuinely new content.  Note that
    Mathlib's `List.Perm` cannot pass through `foldr tokenReplace`
    syntactically (no commutativity), but PASSES through after wrapping
    in `X (·)` thanks to A.4.
-/
import MIP.Axioms
import Mathlib.Data.List.Perm.Basic

namespace MIP

namespace R2_Agent8_A4_OrderIndep

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## Two-token swap. -/

/-- **A.4 — pair swap collapses to `X h`.**

For any two outside-K tokens `ω₁, ω₂`:
`X (tokenReplace ω₁ (tokenReplace ω₂ h)) = X h`. -/
theorem two_token_collapses_to_h
    (X : Agent α) (ω₁ ω₂ : Ω) (h : Str α)
    (hOut₁ : ω₁ ∉ (K X : Set Ω))
    (hOut₂ : ω₂ ∉ (K X : Set Ω)) :
    X (tokenReplace ω₁ (tokenReplace ω₂ h)) = X h := by
  have h1 : X h = X (tokenReplace ω₂ h) := Axioms.A4 X ω₂ h hOut₂
  have h2 : X (tokenReplace ω₂ h)
              = X (tokenReplace ω₁ (tokenReplace ω₂ h)) :=
    Axioms.A4 X ω₁ (tokenReplace ω₂ h) hOut₁
  exact (h1.trans h2).symm

/-- **A.4 — pair swap order independence.**

`X (tokenReplace ω₁ (tokenReplace ω₂ h)) = X (tokenReplace ω₂ (tokenReplace ω₁ h))`
for any two outside-K tokens `ω₁, ω₂`. -/
theorem pair_swap_invariance
    (X : Agent α) (ω₁ ω₂ : Ω) (h : Str α)
    (hOut₁ : ω₁ ∉ (K X : Set Ω))
    (hOut₂ : ω₂ ∉ (K X : Set Ω)) :
    X (tokenReplace ω₁ (tokenReplace ω₂ h))
      = X (tokenReplace ω₂ (tokenReplace ω₁ h)) := by
  rw [two_token_collapses_to_h X ω₁ ω₂ h hOut₁ hOut₂,
      two_token_collapses_to_h X ω₂ ω₁ h hOut₂ hOut₁]

/-! ## List form (helper, then permutation invariance). -/

/-- **A.4 — foldr collapses to `X h`.**

For any list `ωs` of outside-K tokens,
`X (ωs.foldr tokenReplace h) = X h`. -/
theorem list_foldr_collapses_to_h
    (X : Agent α) (ωs : List Ω) (h : Str α)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X (ωs.foldr tokenReplace h) = X h := by
  induction ωs generalizing h with
  | nil => rfl
  | cons ω rest ih =>
      have hHead : ω ∉ (K X : Set Ω) := hOut ω (List.mem_cons_self ..)
      have hRest : ∀ ω' ∈ rest, ω' ∉ (K X : Set Ω) :=
        fun ω' hω' => hOut ω' (List.mem_cons_of_mem _ hω')
      -- `(ω :: rest).foldr f h = f ω (rest.foldr f h)`
      show X (tokenReplace ω (rest.foldr tokenReplace h)) = X h
      have step1 : X (tokenReplace ω (rest.foldr tokenReplace h))
                     = X (rest.foldr tokenReplace h) :=
        (Axioms.A4 X ω (rest.foldr tokenReplace h) hHead).symm
      have step2 : X (rest.foldr tokenReplace h) = X h := ih h hRest
      exact step1.trans step2

/-- **A.4 — permutation invariance on X-output.**

For two lists `ωs, ωs'` that are permutations of each other, all of
whose tokens are outside K X, the two foldr-substituted histories give
the same X-output (because both collapse to `X h`). -/
theorem list_perm_invariance
    (X : Agent α) (ωs ωs' : List Ω) (h : Str α)
    (hPerm : ωs.Perm ωs')
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω)) :
    X (ωs.foldr tokenReplace h) = X (ωs'.foldr tokenReplace h) := by
  have hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω) := by
    intro ω hω
    exact hOut ω (hPerm.symm.mem_iff.mp hω)
  rw [list_foldr_collapses_to_h X ωs h hOut,
      list_foldr_collapses_to_h X ωs' h hOut']

/-! ## Three-token order independence as a corollary. -/

/-- **A.4 — three-token any order.** Any one of the six orderings of
`tokenReplace ω₁, ω₂, ω₃` gives the same X-output. -/
theorem three_token_order_indep
    (X : Agent α) (ω₁ ω₂ ω₃ : Ω) (h : Str α)
    (hOut₁ : ω₁ ∉ (K X : Set Ω))
    (hOut₂ : ω₂ ∉ (K X : Set Ω))
    (hOut₃ : ω₃ ∉ (K X : Set Ω)) :
    X (tokenReplace ω₁ (tokenReplace ω₂ (tokenReplace ω₃ h)))
      = X (tokenReplace ω₃ (tokenReplace ω₂ (tokenReplace ω₁ h))) := by
  have hL : X (tokenReplace ω₁ (tokenReplace ω₂ (tokenReplace ω₃ h))) = X h := by
    have e1 : X h = X (tokenReplace ω₃ h) := Axioms.A4 X ω₃ h hOut₃
    have e2 : X (tokenReplace ω₃ h)
                = X (tokenReplace ω₂ (tokenReplace ω₃ h)) :=
      Axioms.A4 X ω₂ _ hOut₂
    have e3 : X (tokenReplace ω₂ (tokenReplace ω₃ h))
                = X (tokenReplace ω₁ (tokenReplace ω₂ (tokenReplace ω₃ h))) :=
      Axioms.A4 X ω₁ _ hOut₁
    exact ((e1.trans e2).trans e3).symm
  have hR : X (tokenReplace ω₃ (tokenReplace ω₂ (tokenReplace ω₁ h))) = X h := by
    have e1 : X h = X (tokenReplace ω₁ h) := Axioms.A4 X ω₁ h hOut₁
    have e2 : X (tokenReplace ω₁ h)
                = X (tokenReplace ω₂ (tokenReplace ω₁ h)) :=
      Axioms.A4 X ω₂ _ hOut₂
    have e3 : X (tokenReplace ω₂ (tokenReplace ω₁ h))
                = X (tokenReplace ω₃ (tokenReplace ω₂ (tokenReplace ω₁ h))) :=
      Axioms.A4 X ω₃ _ hOut₃
    exact ((e1.trans e2).trans e3).symm
  rw [hL, hR]

end R2_Agent8_A4_OrderIndep

end MIP
