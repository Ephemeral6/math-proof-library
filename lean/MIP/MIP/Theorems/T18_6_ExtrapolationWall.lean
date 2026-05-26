/-
Theorem T.18.6 — Extrapolation Wall.

Reference: `theorems/index.md` T.18.6 / main book §18.6.

**Statement.** If no abductive cover of `p` lies within `K(A)`, then
`N(p, A) = ∞`:

    (∀ R ∈ ℛ(p), R ⊄ K(A))  ⟹  N(p, A) = ⊤.

**Proof.** Direct contrapositive of A.2: A.2 says
`N(p, A) ≠ ⊤ ⟺ ∃R ∈ ℛ(p), R ⊆ K(A)`. Negating both sides gives the
extrapolation wall.

**STATUS: FULLY PROVED (A 无条件).** Single-step from A.2.
-/
import MIP.Axioms

namespace MIP

open MIP.Axioms

namespace ExtrapolationWall

variable {α : Type} {Ω : Type}

/-- **T.18.6 (Extrapolation Wall).**

If every abductive cover of `p` lies outside `K(X)`, then `N(p, X) = ⊤`. -/
theorem T18_6_extrapolation_wall
    (p : Problem α) (X : Agent α)
    (h : ∀ R' ∈ (demandFamily p : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) :
    N p X = ⊤ := by
  -- Contrapositive of A.2: N ≠ ⊤ ⟺ ∃ R ⊆ K X.
  by_contra hN
  obtain ⟨R', hR'_mem, hR'_cover⟩ := (Axioms.A2 (Ω := Ω) p X).mp hN
  exact h R' hR'_mem hR'_cover

end ExtrapolationWall

end MIP
