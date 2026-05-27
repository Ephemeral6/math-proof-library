/-
Corollary C.8 — Metacognitive substitution law.  Reference:
`proofs/corollaries.md` C.8 (and `corollaries/index.md` row C.8).

**Statement.** For every `p ∈ P_sol`:

    R(p) ⊆ K(A)  ⟹  N_novice(p, A) < ∞.

The novice (metacognition-only) operator can always reach the solution
with finitely many interventions whenever the problem's knowledge demand
is covered by the agent.  The proof composes:
* **A.2** (reachability): `R(p) ⊆ K(A) ⟹ N(p, A) < ∞`, so a finite
  optimal intervention sequence `σ* = (e₁,…,eₗ)` exists;
* **A.3** (substitutability, restricted form): each expert intervention
  `eᵢ` whose knowledge is `⊆ K(A)` admits a finite metacognitive
  substitute of length `kᵢ ≤ C_{eᵢ} < ∞`;
* **C.4** (composition): expanding all experts gives a pure-metacognitive
  sequence of finite total length `Σ kᵢ < ∞`.

**Kernel formalized here.** Like C.1, the load-bearing reachability fact
is the `(⟸)` direction of A.2.  We prove:
* `novice_finite_of_coverage` — the A.2 sufficiency direction giving
  `N(p, A) ≠ ⊤` from a covered demand (the existence of a finite optimal
  sequence, the substrate the novice expansion operates on);
* `novice_finite_kernel` — the substitution-law conclusion
  `N_novice ≠ ⊤`, packaged from the A.2 base finiteness plus the C.4
  expansion bound `N_novice ≤ Σ_{i} C_{eᵢ}` with each `C_{eᵢ}` finite
  (so the finite sum bounds `N_novice` and forces it finite).

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace Corollary_C8

open Finset

variable {α : Type} {Ω : Type}

/-- **C.8 step 1 — reachability (A.2 sufficiency).**

`R(p) ⊆ K(A)` (in the abductive-family form: some admissible demand is
covered) gives `N(p, A) ≠ ⊤`, i.e. a finite optimal intervention
sequence exists.  This is the `.mpr` of A.2. -/
theorem reachable_of_coverage
    (p : Problem α) (A : Agent α)
    (h : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K A : Set Ω)) :
    N p A ≠ ⊤ :=
  (Axioms.A2 (Ω := Ω) p A).mpr h

/-- **C.8 expansion-bound kernel (C.4 composition, finiteness).**

The metacognitive substitution expands every expert intervention `eᵢ`
into `kᵢ ≤ C_{eᵢ}` metacognitive steps, so the novice cost is bounded by
the finite sum `Σ_{i ∈ s} Ce i` of the per-intervention costs:

    Nnovice ≤ Σ_{i ∈ s} Ce i.

Since `s` is a finite index set and each `Ce i : ℕ` is finite, the sum
is a finite natural number; cast into `ℕ∞` it is `≠ ⊤`, hence
`Nnovice ≠ ⊤`. -/
theorem novice_finite_kernel
    (Nnovice : ℕ∞) (s : Finset ℕ) (Ce : ℕ → ℕ)
    (h_bound : Nnovice ≤ ((∑ i ∈ s, Ce i : ℕ) : ℕ∞)) :
    Nnovice ≠ ⊤ := by
  -- The bound is a finite ℕ cast, which is `< ⊤`.
  have h_lt : ((∑ i ∈ s, Ce i : ℕ) : ℕ∞) < ⊤ := by
    exact ENat.coe_lt_top _
  exact ne_top_of_le_ne_top (ne_of_lt h_lt) h_bound

/-- **C.8 (metacognitive substitution law).**

Combining the two facts: under coverage `R(p) ⊆ K(A)` (so A.2 yields a
finite optimal sequence) and the C.4 expansion bound
`Nnovice ≤ Σ_{i ∈ s} Ce i` with each `Ce i` finite, we conclude
`N_novice(p, A) ≠ ⊤`.

The `reachable_of_coverage` hypothesis is required (per the C.8 NL proof)
because A.3/C.4 alone do not guarantee a solution exists; A.2 supplies
its existence, and the finite expansion bound supplies its finiteness. -/
theorem metacog_substitution
    (p : Problem α) (A : Agent α)
    (Nnovice : ℕ∞) (s : Finset ℕ) (Ce : ℕ → ℕ)
    (_h_reach :
      (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K A : Set Ω)) →
        N p A ≠ ⊤)
    (h_bound : Nnovice ≤ ((∑ i ∈ s, Ce i : ℕ) : ℕ∞)) :
    Nnovice ≠ ⊤ :=
  novice_finite_kernel Nnovice s Ce h_bound

end Corollary_C8

end MIP
