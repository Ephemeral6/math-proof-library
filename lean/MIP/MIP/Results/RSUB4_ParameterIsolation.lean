/-
Result R-SUB.4 — Parameter-isolation gives zero subdomain competition.

Reference: `workspace/subdomain_competition.md` §6.4 (A 条件 under T.34;
the pure set-theoretic kernel is A 无条件).

**Statement (set-theoretic kernel).** If `K_1, …, K_m` are pairwise
disjoint subdomains assembled into a "total" agent's knowledge space
`K_total := ⊔_i K_i`, then:

* Each `K_i` is a subset of `K_total` (parameter isolation).
* `K_i ∩ K_j = ∅` for `i ≠ j` (no transfer).
* `K_total = ⋃_i K_i` (disjoint cover).

The MIP-side consequence (training one `X_j` cannot affect `K(X_i)`) is
T.34's "bare-augmented decomposition" + A.4 (cognitive boundary).  Here
we only formalise the set-theoretic kernel.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.Set.Disjoint
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Lemmas

namespace MIP

namespace ParameterIsolation

/-- **R-SUB.4 set-theoretic core — disjoint subdomain inclusion.**

For pairwise disjoint subdomains `K : ι → Set Ω`, the union
`K_total := ⋃_i K i` contains each `K i`, and the pairwise intersections
are empty. -/
theorem R_SUB_4_disjoint_inclusion
    {ι Ω : Type*} (K : ι → Set Ω)
    (h_pairwise : ∀ i j, i ≠ j → Disjoint (K i) (K j)) :
    (∀ i, K i ⊆ Set.iUnion K) ∧
    (∀ i j, i ≠ j → K i ∩ K j = ∅) := by
  refine ⟨?_, ?_⟩
  · intro i x hx
    exact Set.mem_iUnion.mpr ⟨i, hx⟩
  · intro i j h_ne
    exact Set.disjoint_iff_inter_eq_empty.mp (h_pairwise i j h_ne)

/-- **R-SUB.4 — no transfer characterisation.**

For pairwise disjoint subdomains, the "transferable" set
`K i ∩ K j` is empty for any `i ≠ j`.  Hence no knowledge element
contributes to two distinct subdomain masses simultaneously. -/
theorem R_SUB_4_no_transfer
    {ι Ω : Type*} (K : ι → Set Ω)
    (h_pairwise : ∀ i j, i ≠ j → Disjoint (K i) (K j))
    (i j : ι) (h_ne : i ≠ j) :
    K i ∩ K j = ∅ :=
  Set.disjoint_iff_inter_eq_empty.mp (h_pairwise i j h_ne)

/-- **R-SUB.4 — finset / Finset form.**

Same statement for finsets, useful when the partition is finite. -/
theorem R_SUB_4_finset_disjoint
    {ι Ω : Type*} [DecidableEq Ω] (K : ι → Finset Ω)
    (h_pairwise : ∀ i j, i ≠ j → Disjoint (K i) (K j))
    (i j : ι) (h_ne : i ≠ j) :
    K i ∩ K j = ∅ :=
  Finset.disjoint_iff_inter_eq_empty.mp (h_pairwise i j h_ne)

end ParameterIsolation

end MIP
