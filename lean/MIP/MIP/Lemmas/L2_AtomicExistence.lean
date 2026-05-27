/-
Lemma L.2 — Atomic barrier existence / decomposition.
Reference: `proofs/L2345.md` (L.2).

**Statement (NL).**  设 `b` 非原子，存在分解 `b = b₁ ∪ b₂`。由 (R2),
`μ(b) = μ(b₁) + μ(b₂)`。由 (R3)(R4), `μ(bᵢ) ≥ 1`, 故 `μ(bᵢ) ≤ μ(b) − 1`。
继续分解, `μ` 值严格递减。由 (R4), ℕ₀ 中严格递减序列必有限步终止。 □

Concretely: every barrier admits a finite, non-empty *atomic
decomposition* — a finite set of atomic barriers whose existence is
guaranteed because the strictly-decreasing `μ`-recursion over `ℕ`
terminates.  In the concrete T.7-uniqueness model
(`MIP.Defs.Barriers`) this terminating recursion bottoms out at the
singleton `{b}` (every barrier is atomic, `IsAtomic := True`), so the
decomposition exists, is non-empty, and consists of atomic barriers.

**Kernel formalized here.**
* `atomicDecomp_exists` / `atomicDecomp_nonempty` — the atomic
  decomposition of any `BarrierData` exists and is non-empty.
* `atomicDecomp_atomic` — every member of it is atomic.
* `termination_of_strictly_decreasing` — the abstract well-foundedness
  fact underwriting the NL termination argument: any strictly
  decreasing `ℕ`-valued sequence is bounded in length (no infinite
  strictly-descending chain in `ℕ`).

Axiom-free (no new axioms; only A.1–A.4 transitively via the model).
-/
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Order.WellFounded

namespace MIP

namespace Lemma_L2

variable {α : Type}

/-- **L.2 — atomic decomposition exists.**  Every barrier `b` has a
non-empty finite atomic decomposition.  (In the concrete model it is
the singleton `{b}`; the NL proof guarantees existence via the
terminating `μ`-recursion.) -/
theorem atomicDecomp_exists (b : BarrierData α) :
    ∃ D : Finset (BarrierData α), D.Nonempty ∧ ∀ a ∈ D, a.IsAtomic := by
  refine ⟨b.atomicDecomp, b.atomicDecomp_nonempty, ?_⟩
  exact b.atomicDecomp_atomic

/-- **L.2 — the atomic decomposition is non-empty.** -/
theorem atomicDecomp_nonempty (b : BarrierData α) :
    b.atomicDecomp.Nonempty :=
  b.atomicDecomp_nonempty

/-- **L.2 — every member of the atomic decomposition is atomic.** -/
theorem atomicDecomp_atomic (b : BarrierData α) :
    ∀ a ∈ b.atomicDecomp, a.IsAtomic :=
  b.atomicDecomp_atomic

/-- **L.2 — termination kernel.**  The mathematical heart of the NL
proof: a strictly decreasing `ℕ`-valued recursion terminates, because
`<` on `ℕ` is well-founded.  Hence the repeated splitting
`μ(bᵢ) ≤ μ(b) − 1` cannot continue forever — there is no infinite
strictly-descending chain of `μ`-values.  Stated as: for any function
`μ : β → ℕ`, the relation `μ a < μ b` is well-founded. -/
theorem termination_of_strictly_decreasing {β : Type} (μ : β → ℕ) :
    WellFounded (fun a b : β => μ a < μ b) :=
  InvImage.wf μ Nat.lt_wfRel.wf

/-- **L.2 — legacy ℕ-indexed restatement.**  The legacy atomic
decomposition `atomicDecomp b = {b}` is non-empty and atomic. -/
theorem legacy_atomicDecomp_nonempty (b : Barrier α) :
    (atomicDecomp b).Nonempty := by
  unfold atomicDecomp
  exact Finset.singleton_nonempty b

theorem legacy_atomicDecomp_atomic (b : Barrier α) :
    ∀ a ∈ atomicDecomp b, IsAtomic a :=
  L2_decomp_atomic b

end Lemma_L2

end MIP
