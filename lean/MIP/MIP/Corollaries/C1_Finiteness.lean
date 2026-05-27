/-
Corollary C.1 — Finiteness.  Reference: `proofs/corollaries.md` C.1.

**Statement.** `R(p) ⊆ K(A)  ⟹  N(p, A) < ∞`.

More precisely, in the abductive-family formulation of A.2: if *some*
admissible demand `R' ∈ ℛ(p)` is covered by the agent's knowledge,
`R' ⊆ K(X)`, then `N(p, X) < ∞` (i.e. `N p X ≠ ⊤`).

**Kernel formalized here.** The `(⟸)` (sufficiency) direction of A.2.
`A.2` reads `N p X ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K X`; C.1 is exactly its
`.mpr`.  We additionally record the literal-statement form
(`R p ⊆ K X ⟹ N p X ≠ ⊤`) under the hypothesis that the canonical
demand `R p` is itself an admissible member of `ℛ(p)` — the standard
case in which `ℛ(p) = {R(p)}` or `R(p) ∈ ℛ(p)`.

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms

namespace MIP

namespace Corollary_C1

variable {α : Type} {Ω : Type}

/-- **C.1 (Finiteness, abductive-family form).**

If some admissible demand `R' ∈ ℛ(p)` is covered by `K(X)`, then
`N(p, X) < ∞`.  This is precisely the sufficiency (`⟸`) direction of
Axiom A.2. -/
theorem finiteness
    (p : Problem α) (X : Agent α)
    (h : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :
    N p X ≠ ⊤ :=
  (Axioms.A2 (Ω := Ω) p X).mpr h

/-- **C.1 (Finiteness, literal `R(p) ⊆ K(X)` form).**

Under the standard hypothesis that the canonical knowledge demand
`R(p)` is itself an admissible explanation (`R p ∈ ℛ(p)`), the literal
NL statement `R(p) ⊆ K(X) ⟹ N(p, X) < ∞` follows from A.2 by taking
`R' := R p`. -/
theorem finiteness_literal
    (p : Problem α) (X : Agent α)
    (hAdm : (R p : Set Ω) ∈ (demandFamily p : Set (Set Ω)))
    (hCov : (R p : Set Ω) ⊆ (K X : Set Ω)) :
    N p X ≠ ⊤ :=
  (Axioms.A2 (Ω := Ω) p X).mpr ⟨R p, hAdm, hCov⟩

end Corollary_C1

end MIP
