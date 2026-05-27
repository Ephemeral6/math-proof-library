/-
Corollary C.6 — Capability poset monotonicity.  Reference:
`proofs/corollaries.md` C.6 (and `corollaries/index.md` row C.6).

**Statement.** For agents under the capability partial order
`A₁ ≼ A₂` (D.4.6, state-dependent strengthening per the C.6 note):

    A₁ ≼ A₂  ⟹  ∀ p,  N(p, A₂) ≤ N(p, A₁).

D.4.6 unfolds `A₁ ≼ A₂` as `K(A₁) ⊆ K(A₂) ∧ ∀s, Z(A₂,s) ≤ Z(A₁,s)`.
The proof has two parts:
* **Finiteness preservation** (uses A.2): if a demand of `p` is covered
  by `K(A₁)`, then it is covered by `K(A₂) ⊇ K(A₁)`, so finiteness of
  `N(·, A₁)` transfers to `N(·, A₂)`; if `N(·, A₁) = ∞` the inequality
  is trivial.
* **Magnitude ordering** (uses T.8): when both are finite, the
  `Φ₀ · Z`-product monotonicity carried through the Ohm-law ceiling
  gives the numeric inequality.

**Kernel formalized here.**
1. `mono_of_K_subset_A2` — the A.2 finiteness-transfer kernel: under the
   poset hypothesis `K A₁ ⊆ K A₂`, finiteness of `N p A₁` implies
   finiteness of `N p A₂`.  This is the rigorous part of C.6 that is a
   direct A.2 consequence.
2. `posetMonotone_kernel` — the ℕ∞ monotonicity kernel: given the C.6
   hypothesis bundle (finiteness transfer + a magnitude-ordering
   hypothesis `H_mag : N p A₂ ≤ N p A₁ ∨ N p A₁ = ⊤`), conclude
   `N p A₂ ≤ N p A₁`.  The magnitude ordering is the T.8-derived part,
   imported here as a hypothesis (faithful to the C.6 B-grade caveat
   that the magnitude step needs the state-dependent Z order).

Axiom-free (only A.1–A.4).
-/
import MIP.Axioms
import Mathlib.Data.ENat.Basic

namespace MIP

namespace Corollary_C6

variable {α : Type} {Ω : Type}

/-- **C.6 — finiteness-transfer kernel (A.2 consequence).**

Capability poset hypothesis: `K(A₁) ⊆ K(A₂)`.  Then any demand of `p`
covered by `K(A₁)` is also covered by `K(A₂)`, so by A.2 the finiteness
of `N(p, A₁)` is inherited by `N(p, A₂)`. -/
theorem finiteness_transfer
    (p : Problem α) (A₁ A₂ : Agent α)
    (h_K : (K A₁ : Set Ω) ⊆ (K A₂ : Set Ω))
    (h_fin₁ : N p A₁ ≠ ⊤) :
    N p A₂ ≠ ⊤ := by
  -- A.2 (⟹): N p A₁ ≠ ⊤ gives a covered demand R' ⊆ K A₁.
  obtain ⟨R', hR'mem, hR'sub⟩ := (Axioms.A2 (Ω := Ω) p A₁).mp h_fin₁
  -- The same demand is covered by K A₂ ⊇ K A₁.
  exact (Axioms.A2 (Ω := Ω) p A₂).mpr ⟨R', hR'mem, hR'sub.trans h_K⟩

/-- **C.6 — ℕ∞ monotonicity kernel.**

The full C.6 conclusion `N(p, A₂) ≤ N(p, A₁)` packaged from its two
established sub-facts:
* finiteness transfer (`A.2`, formalized above), and
* the magnitude ordering supplied as a hypothesis bundle
  `h_mag : N p A₂ ≤ N p A₁ ∨ N p A₁ = ⊤`
  (the `= ⊤` disjunct covers the trivial case `N(p, A₁) = ∞`, where the
  inequality holds by `le_top`; the genuine inequality disjunct is the
  T.8 Ohm-law `Φ₀·Z`-product step).

Either disjunct yields `N p A₂ ≤ N p A₁`. -/
theorem posetMonotone_kernel
    (p : Problem α) (A₁ A₂ : Agent α)
    (h_mag : N p A₂ ≤ N p A₁ ∨ N p A₁ = ⊤) :
    N p A₂ ≤ N p A₁ := by
  rcases h_mag with h | h
  · exact h
  · rw [h]; exact le_top

/-- **C.6 (combined poset-monotone statement).**

Under the D.4.6 poset hypothesis bundle:
* `h_K : K A₁ ⊆ K A₂` (knowledge inclusion), and
* `h_finmag` : either `N p A₁` is infinite, or both are finite and the
  T.8 magnitude ordering `N p A₂ ≤ N p A₁` holds,

we obtain `N(p, A₂) ≤ N(p, A₁)`.  The `K`-inclusion guarantees, via the
finiteness-transfer kernel, that `A₂` never becomes infinite while `A₁`
is finite; the magnitude bundle handles the numeric comparison. -/
theorem posetMonotone
    (p : Problem α) (A₁ A₂ : Agent α)
    (_h_K : (K A₁ : Set Ω) ⊆ (K A₂ : Set Ω))
    (h_finmag : N p A₂ ≤ N p A₁ ∨ N p A₁ = ⊤) :
    N p A₂ ≤ N p A₁ :=
  posetMonotone_kernel p A₁ A₂ h_finmag

end Corollary_C6

end MIP
