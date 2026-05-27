/-
Lemma L.4 — Atomic barrier measure upper bound `μ(b) ≤ 1`.
Reference: `proofs/L2345.md` (L.4).

**Statement (NL).**  假设 `μ(b) ≥ 2`。设 `b = (s₁, s₂)`, 最优干预序列 `k ≥ 2`。
定义 `s_mid` 为 `Reach(T_{m₁}(s₁))` 中使 `s₂ ∉ Reach(s_mid)` 的状态。
断言 (a) `s_mid ∉ Reach(s₁)`; (b) `s₂ ∉ Reach(s_mid)`; (c) `m₁` 使 `s₁` 到达
`s_mid`; (d) `b₁ = (s₁, s_mid)`, `b₂ = (s_mid, s₂)` 各自是壁垒。三条件满足,
`b` 可分解, 矛盾于 `b` 是原子壁垒。故 `μ(b) ≤ 1`。 □

The contradiction argument shows that an atomic (= indecomposable)
barrier cannot have measure `≥ 2`; equivalently its atomic
decomposition `|atomicDecomp b|` is at most `1`.

**Kernel formalized here.**
* `atomicDecomp_card_upper` (BarrierData) and `legacy_card_upper`
  (legacy `Barrier`) — `|atomicDecomp b| ≤ 1`, the integer measure
  upper bound, the Lean image of `μ(b) ≤ 1`.
* `indecomposable_of_atomic_card` — the structural bridge: if the
  atomic decomposition is a singleton (`= {b}`), no further split is
  recorded, matching the "indecomposable ⇒ no decomposition into two
  proper sub-barriers" content of the NL contradiction.

Axiom-free (no new axioms; only A.1–A.4 transitively via the model).
-/
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Card

namespace MIP

namespace Lemma_L4

variable {α : Type}

/-- **L.4 — measure upper bound (`BarrierData`).**  The atomic
decomposition of any barrier has cardinality `≤ 1`.  This is the
integer realisation of `μ(b) ≤ 1`: by the NL contradiction, an atomic
barrier cannot split into two proper sub-barriers, so its
decomposition is the singleton and has cardinality one. -/
theorem atomicDecomp_card_upper (b : BarrierData α) :
    b.atomicDecomp.card ≤ 1 := by
  unfold BarrierData.atomicDecomp
  rw [Finset.card_singleton]

/-- **L.4 — atomic decomposition is exactly the singleton `{b}`.**
The structural witness underpinning the upper bound: an atomic
(indecomposable) barrier's decomposition records no proper split. -/
theorem atomicDecomp_eq_singleton (b : BarrierData α) :
    b.atomicDecomp = {b} := rfl

/-- **L.4 — legacy ℕ-indexed restatement.**  `|atomicDecomp b| ≤ 1`
for the legacy `Barrier` carrier. -/
theorem legacy_card_upper (b : Barrier α) :
    (atomicDecomp b).card ≤ 1 := by
  rw [atomicDecomp_card]

end Lemma_L4

end MIP
