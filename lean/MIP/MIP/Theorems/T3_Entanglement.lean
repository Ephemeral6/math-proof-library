/-
Theorem T.3 — Entanglement degree lower bound.

Reference: `proofs/T3.md`.

**Statement.** `T(p, A) := N(p, A) / |B(p)| ≥ 1`.

**Proof.** Immediate from T.1 (`N ≥ |B(p)|`) and `|B(p)| > 0`.

**STATUS: PARTIAL via T.1.** Same dependency as T.1: a `Barrier` /
`AtomicBarrier` API is required.
-/
import MIP.Axioms

namespace MIP

namespace Entanglement

/-- Cardinality of `B(p)` — opaque pending barrier theory. -/
opaque barrierCard {α : Type} : Problem α → ℕ

/-- Entanglement degree `T(p, A) := N(p, A) / |B(p)|`.

We define this only when `|B(p)| > 0`; the general definition uses a
careful convention for the `|B(p)| = 0` case. -/
noncomputable def entanglement {α : Type} (p : Problem α) (X : Agent α) : ℝ :=
  (N p X).toNat / ((barrierCard p : ℕ) : ℝ)

/-- **T.3 (Entanglement Lower Bound).**

Given T.1 (`N ≥ |B(p)|`) and `|B(p)| > 0`, we have `T ≥ 1`. The MIP-
specific premise is T.1, currently sorried (see `T1_LowerBound.lean`). -/
theorem T3_entanglement_ge_one
    {α : Type} (p : Problem α) (X : Agent α)
    (hBpos : 0 < barrierCard p)
    (hN_finite : N p X ≠ ⊤)
    (hT1 : ((barrierCard p : ℕ) : ℕ∞) ≤ N p X) :
    1 ≤ entanglement p X := by
  unfold entanglement
  have hcast : ((barrierCard p : ℕ) : ℝ) > 0 := by exact_mod_cast hBpos
  have hnle : (barrierCard p : ℕ) ≤ (N p X).toNat := by
    -- N p X ≠ ⊤ means N p X = some n for some n; then toNat = n.
    rcases hN_eq : N p X with _ | n
    · exact absurd hN_eq hN_finite
    · -- hT1 : (barrierCard p : ℕ∞) ≤ (n : ℕ∞)
      rw [hN_eq] at hT1
      have : (barrierCard p : ℕ∞) ≤ (n : ℕ∞) := hT1
      have hnat : barrierCard p ≤ n := by exact_mod_cast this
      simp
      exact hnat
  rw [le_div_iff₀ hcast, one_mul]
  exact_mod_cast hnle

end Entanglement

end MIP
