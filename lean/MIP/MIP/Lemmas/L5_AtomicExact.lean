/-
Lemma L.5 — Atomic barrier measure is exactly `1`: `μ(b) = 1`.
Reference: `proofs/L2345.md` (L.5).

**Statement (NL).**  由 L.3 `μ(b) ≥ 1` 和 L.4 `μ(b) ≤ 1`, 得 `μ(b) = 1`。 □

Combining the lower bound (L.3, `μ(b) ≥ 1`) and the upper bound
(L.4, `μ(b) ≤ 1`) by antisymmetry gives the exact value
`μ(b) = 1` for every atomic barrier, where `μ(b)` is realised as the
cardinality `|atomicDecomp b|`.

**Kernel formalized here.**
* `atomicDecomp_card_eq` (BarrierData) and `legacy_card_eq`
  (legacy `Barrier`) — `|atomicDecomp b| = 1`, the integer realisation
  of `μ(b) = 1`, derived by antisymmetry from the L.3 and L.4 kernels
  re-proved inline.

Axiom-free (no new axioms; only A.1–A.4 transitively via the model).
-/
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Card

namespace MIP

namespace Lemma_L5

variable {α : Type}

/-- **L.5 — measure lower bound (re-proved inline, L.3 kernel).** -/
theorem card_lower (b : BarrierData α) : 1 ≤ b.atomicDecomp.card :=
  b.atomicDecomp_nonempty.card_pos

/-- **L.5 — measure upper bound (re-proved inline, L.4 kernel).** -/
theorem card_upper (b : BarrierData α) : b.atomicDecomp.card ≤ 1 := by
  unfold BarrierData.atomicDecomp
  rw [Finset.card_singleton]

/-- **L.5 — exact measure (`BarrierData`).**  Combining L.3
(`1 ≤ |atomicDecomp b|`) and L.4 (`|atomicDecomp b| ≤ 1`) by
antisymmetry yields `|atomicDecomp b| = 1`, the Lean image of
`μ(b) = 1` for every atomic barrier. -/
theorem atomicDecomp_card_eq (b : BarrierData α) :
    b.atomicDecomp.card = 1 :=
  le_antisymm (card_upper b) (card_lower b)

/-- **L.5 — legacy ℕ-indexed restatement.**  `|atomicDecomp b| = 1`
for the legacy `Barrier` carrier. -/
theorem legacy_card_eq (b : Barrier α) :
    (atomicDecomp b).card = 1 :=
  atomicDecomp_card b

end Lemma_L5

end MIP
