/-
Corollary C.2 — Solvability criterion.  Reference: `proofs/corollaries.md` C.2.

**Statement.** `N(p, A) = ∞  ⟹  R(p) ⊄ K(A)  ∨  p ∉ P_sol`.

**Kernel formalized here.** The mathematically load-bearing content is
the contrapositive of A.2's necessity (`⟹`) direction:

    N(p, X) = ⊤  ⟹  ¬ ∃ R' ∈ ℛ(p), R' ⊆ K(X).

This is `not_not`-free contraposition of `A.2`.  We then assemble the
NL disjunction.  Following the NL proof's two-case structure
(`p ∉ P_sol`, or `p ∈ P_sol ∧ N = ∞`), we model solvability as
`Psol p := ∃ s, p s = true`.  The disjunction is proved from the kernel
by classical case-split on `Psol p`: if `p ∉ P_sol` the right disjunct
holds; otherwise the kernel gives `¬∃R'∈ℛ(p), R'⊆K X`, the abductive
form of the left disjunct.

The bridge from "`¬∃ R'∈ℛ(p), R'⊆K X`" to the literal "`R(p) ⊄ K(A)`"
is provided under `R p ∈ ℛ(p)` (canonical demand admissible), exactly
as in C.1.

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms

namespace MIP

namespace Corollary_C2

variable {α : Type} {Ω : Type}

/-- `P_sol` (D.1.1): a problem is *solvable* iff some string is a
correct solution. -/
def Psol (p : Problem α) : Prop := ∃ s : Str α, p s = true

/-- **C.2 kernel (contrapositive of A.2 necessity).**

If `N(p, X) = ∞` then no admissible demand `R' ∈ ℛ(p)` is covered by
`K(X)`. -/
theorem no_cover_of_infinite
    (p : Problem α) (X : Agent α) (hInf : N p X = ⊤) :
    ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  intro h
  exact (Axioms.A2 (Ω := Ω) p X).mpr h hInf

/-- **C.2 (literal `R(p) ⊄ K(A)` form).**

Under `R p ∈ ℛ(p)` (canonical demand admissible), `N(p, X) = ∞` forces
the canonical demand `R(p)` not to be covered: `¬ (R p ⊆ K X)`. -/
theorem demand_not_covered_of_infinite
    (p : Problem α) (X : Agent α)
    (hAdm : (R p : Set Ω) ∈ (demandFamily p : Set (Set Ω)))
    (hInf : N p X = ⊤) :
    ¬ ((R p : Set Ω) ⊆ (K X : Set Ω)) := by
  intro hCov
  exact no_cover_of_infinite (Ω := Ω) p X hInf ⟨R p, hAdm, hCov⟩

/-- **C.2 (full disjunction form).**

`N(p, X) = ∞  ⟹  (R(p) ⊄ K(X))  ∨  ¬ Psol p`, under `R p ∈ ℛ(p)`.

Proof by the NL two-case structure: classical case split on `Psol p`.
The `p ∈ P_sol` branch invokes the A.2 kernel; the `p ∉ P_sol` branch
gives the right disjunct directly. -/
theorem solvability_criterion
    (p : Problem α) (X : Agent α)
    (hAdm : (R p : Set Ω) ∈ (demandFamily p : Set (Set Ω)))
    (hInf : N p X = ⊤) :
    (¬ ((R p : Set Ω) ⊆ (K X : Set Ω))) ∨ ¬ Psol p := by
  by_cases hSol : Psol p
  · exact Or.inl (demand_not_covered_of_infinite (Ω := Ω) p X hAdm hInf)
  · exact Or.inr hSol

end Corollary_C2

end MIP
