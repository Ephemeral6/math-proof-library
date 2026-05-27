/-
Lemma L.3 — Atomic barrier measure lower bound `μ(b) ≥ 1`.
Reference: `proofs/L2345.md` (L.3).

**Statement (NL).**  构造零壁垒问题 `p₀` (`μ = 0`) 和单壁垒问题 `pₓ`
(只含 `b`)。由 (R3), `|B(pₓ)| = 1 > 0 = |B(p₀)|`, 故 `μ(pₓ) > 0`。由 (R4),
`μ(pₓ) ≥ 1`。由 (R2), `μ(pₓ) = μ(b)`。故 `μ(b) ≥ 1`。 □

The metric `μ(b)` of an atomic barrier is the cardinality of its
atomic decomposition `|atomicDecomp b|`.  L.3 asserts this is at least
`1`: the single-barrier problem `pₓ` containing only `b` has a
strictly positive barrier count, and by integrality (R4) that count is
`≥ 1`.

**Kernel formalized here.**
* `atomicDecomp_card_lower` (BarrierData) and `legacy_card_lower`
  (legacy `Barrier`) — `1 ≤ |atomicDecomp b|`, the integer measure
  lower bound that is the Lean image of `μ(b) ≥ 1`.

Axiom-free (no new axioms; only A.1–A.4 transitively via the model).
-/
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Card

namespace MIP

namespace Lemma_L3

variable {α : Type}

/-- **L.3 — measure lower bound (`BarrierData`).**  The atomic
decomposition of any barrier has cardinality `≥ 1`.  This is the
integer-valued realisation of the NL bound `μ(b) ≥ 1` (with
`μ(b) := |atomicDecomp b|`), obtained from non-emptiness via
`Finset.Nonempty.card_pos`. -/
theorem atomicDecomp_card_lower (b : BarrierData α) :
    1 ≤ b.atomicDecomp.card :=
  b.atomicDecomp_nonempty.card_pos

/-- **L.3 — legacy ℕ-indexed restatement.**  `1 ≤ |atomicDecomp b|`
for the legacy `Barrier` carrier. -/
theorem legacy_card_lower (b : Barrier α) :
    1 ≤ (atomicDecomp b).card := by
  rw [atomicDecomp_card]

end Lemma_L3

end MIP
