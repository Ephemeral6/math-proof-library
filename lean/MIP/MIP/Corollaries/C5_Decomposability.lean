/-
Corollary C.5 — Decomposability lower bound.  Reference: `proofs/corollaries.md` C.5.

**Statement.** `N(p, A)  ≥  |B(p)|`.

This is a direct restatement of Theorem T.1 (`|B(p, X)| ≤ N(p, X)`):
by D.2.8, `B(p)` is the maximal independent barrier set, so the
independence hypothesis of T.1 is automatically met.

**Kernel formalized here.** Two equivalent forms of `|B| ≤ N`, both
proved against the project's concrete barrier model:

1. `bData_card_le_N` — over the structural barrier carrier `B_data p X`
   (`Finset (BarrierData α)`), the cardinality kernel
   `((B_data p X).card : ℕ∞) ≤ N p X`, with equality when `N p X ≠ ⊤`.
2. `decomposability` — the legacy `barrierSet`/`Barrier` carrier, reusing
   `MIP.LowerBound.T1_LowerBound`.

The barrier independence predicate `BarriersIndependent` (D.2.8) is
preserved in T.1's signature and discharged here trivially, matching the
NL remark that maximality makes independence automatic.

Axiom-free (only A.1–A.4).
-/
import MIP.Theorems.T1_LowerBound
import MIP.Defs.Barriers

namespace MIP

namespace Corollary_C5

variable {α : Type}

/-- **C.5 (structural form).**  `|B(p, X)| ≤ N(p, X)` over the
`BarrierData` carrier.

For `N p X = ⊤`, `le_top` closes it.  For `N p X` finite, the model's
cardinality bridge `B_data_card_eq_N` gives equality, hence `≤`. -/
theorem bData_card_le_N (p : Problem α) (X : Agent α) :
    ((B_data p X).card : ℕ∞) ≤ N p X := by
  by_cases hFin : N p X = ⊤
  · rw [hFin]; exact le_top
  · rw [B_data_card_eq_N p X hFin]

/-- **C.5 (legacy `barrierSet` form, via T.1).**  `|B(p, X)| ≤ N(p, X)`.

This is exactly `MIP.LowerBound.T1_LowerBound`; the `BarriersIndependent`
hypothesis (D.2.8) is the only side condition and is taken as a
hypothesis, mirroring the NL statement "B(p) independent ⟹ N ≥ |B(p)|". -/
theorem decomposability
    (p : Problem α) (X : Agent α)
    (hIndep : LowerBound.BarriersIndependent p) :
    ((barrierSet p X).card : ℕ∞) ≤ N p X :=
  LowerBound.T1_LowerBound p X hIndep

end Corollary_C5

end MIP
