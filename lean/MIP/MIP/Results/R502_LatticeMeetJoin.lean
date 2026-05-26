/-
Result R.502 / R.503 — Lattice algebra of the minimal-intervention measure
`N` over the problem lattice `(P, ∧, ∨)`: the join-cost formula
`N(p₁ ∨ p₂) = min(N(p₁), N(p₂))` (Cj.8.B) and strict supermodularity
`N(p₁) + N(p₂) ≤ N(p₁ ∨ p₂) + N(p₁ ∧ p₂)`.

Reference: `workspace/round3_exploration/slot_001.md` and
`workspace/round3_exploration/work_slot_001.md` (R.502 / R.503 candidates,
slot 001, A unconditional).

**Candidate status: Round-3 autonomous exploration
(workspace/round3_exploration), not yet human-audited.**

**Statement.** On the distributive problem lattice `(P, ∧, ∨)` (pointwise
`(p₁ ∧ p₂)(x) = p₁(x)·p₂(x)`, `(p₁ ∨ p₂)(x) = max(p₁(x), p₂(x))`), the
minimal-intervention measure `N : P → ℕ∞` satisfies:

* **R.502 (Cj.8.B), the join-cost formula.**
      `N(p₁ ∨ p₂) = min (N p₁) (N p₂)`.
  Upper bound `L.B.3`: solving either disjunct solves the join, so
  `N(p₁∨p₂) ≤ N pᵢ`, hence `≤ min`. Lower bound `L.B.4`: a join-solving
  event splits (by event subadditivity `Pr[A∪B] ≤ Pr[A]+Pr[B]`) into a
  positive-probability single-disjunct event, so `min ≤ N(p₁∨p₂)`.

* **R.503, strict supermodularity.**
      `N p₁ + N p₂ ≤ N(p₁ ∨ p₂) + N(p₁ ∧ p₂)`.
  Combine R.502 (`N(p₁∨p₂) = min`) with the meet lower bound `L.B.6`
  (`max (N p₁) (N p₂) ≤ N(p₁ ∧ p₂)`): then
  `N(p₁∨p₂) + N(p₁∧p₂) = min + N(∧) ≥ min + max = N p₁ + N p₂`.

* **R.503 corollary, failure of submodularity** (constructive
  counterexample): with two problems sharing no common solution,
  `N(p₁∧p₂) = ⊤`, so `N p₁ + N p₂ < N(p₁∨p₂) + N(p₁∧p₂)` strictly while
  the reverse submodular inequality fails.

This file proves the **lattice / order kernels** on `ℕ∞`: the
join-cost = min equation, supermodularity, the meet/join chain
inequality, and the non-submodular witness.  The MIP-specific content
(event subadditivity, pointwise dominations) is bundled as order
hypotheses (`L.B.3`, `L.B.4`, `L.B.6`).

**This file is `axiom`-free.**
-/
import Mathlib.Data.ENat.Basic
import Mathlib.Order.Lattice
import Mathlib.Algebra.Order.Monoid.Unbundled.Basic

namespace MIP

namespace LatticeMeetJoin

open scoped ENat

/-- **R.502 — join-cost formula (Cj.8.B): `N(p₁ ∨ p₂) = min(N p₁, N p₂)`.**

Bundling the two MIP-side order facts as hypotheses:
* `hUpper` (`L.B.3`): `N_join ≤ N₁` and `N_join ≤ N₂` — solving either
  disjunct solves the join;
* `hLower` (`L.B.4`): `min N₁ N₂ ≤ N_join` — a positive-probability
  join-solving event splits into a positive-probability single-disjunct
  event (event subadditivity);

the join-cost equals the minimum. -/
theorem R_502_join_eq_min
    (N₁ N₂ N_join : ℕ∞)
    (hUpper₁ : N_join ≤ N₁) (hUpper₂ : N_join ≤ N₂)
    (hLower : min N₁ N₂ ≤ N_join) :
    N_join = min N₁ N₂ :=
  le_antisymm (le_min hUpper₁ hUpper₂) hLower

/-- **R.502 — upper bound packaging (`L.B.3`).**

From the two single-disjunct upper bounds, `N_join ≤ min N₁ N₂`. -/
theorem R_502_join_le_min
    (N₁ N₂ N_join : ℕ∞)
    (hUpper₁ : N_join ≤ N₁) (hUpper₂ : N_join ≤ N₂) :
    N_join ≤ min N₁ N₂ :=
  le_min hUpper₁ hUpper₂

/-- **R.503 — strict supermodularity: `N p₁ + N p₂ ≤ N(p₁∨p₂) + N(p₁∧p₂)`.**

Inputs:
* `hJoin` (R.502): `N_join = min N₁ N₂`;
* `hMeet` (`L.B.6`): `max N₁ N₂ ≤ N_meet` — solving the meet solves each
  conjunct, so the meet costs at least the larger.

Then `N_join + N_meet = min N₁ N₂ + N_meet ≥ min N₁ N₂ + max N₁ N₂
= N₁ + N₂` (the last step is `min + max = a + b` on `ℕ∞`). -/
theorem R_503_supermodular
    (N₁ N₂ N_join N_meet : ℕ∞)
    (hJoin : N_join = min N₁ N₂)
    (hMeet : max N₁ N₂ ≤ N_meet) :
    N₁ + N₂ ≤ N_join + N_meet := by
  rw [hJoin]
  -- min N₁ N₂ + max N₁ N₂ = N₁ + N₂  (split on which is smaller)
  rcases le_total N₁ N₂ with h | h
  · rw [max_eq_right h] at hMeet
    rw [min_eq_left h]
    exact add_le_add (le_refl N₁) hMeet
  · rw [max_eq_left h] at hMeet
    rw [min_eq_right h]
    calc N₁ + N₂ = N₂ + N₁ := add_comm N₁ N₂
      _ ≤ N₂ + N_meet := add_le_add (le_refl N₂) hMeet

/-- **R.502/R.503 — the meet/join chain inequality.**

Splicing `L.B.3`/`L.B.4` (`N_join = min`), `L.B.6` (`max ≤ N_meet`), and
R.99 (`N_meet ≤ N₁ + N₂`) gives the full chain

    N_join = min N₁ N₂ ≤ max N₁ N₂ ≤ N_meet ≤ N₁ + N₂. -/
theorem R_502_503_chain
    (N₁ N₂ N_join N_meet : ℕ∞)
    (hJoin : N_join = min N₁ N₂)
    (hMeet : max N₁ N₂ ≤ N_meet)
    (hR99 : N_meet ≤ N₁ + N₂) :
    N_join ≤ min N₁ N₂ ∧ min N₁ N₂ ≤ max N₁ N₂ ∧
      max N₁ N₂ ≤ N_meet ∧ N_meet ≤ N₁ + N₂ := by
  refine ⟨le_of_eq hJoin, min_le_max, hMeet, hR99⟩

/-- **R.503 corollary — failure of submodularity (constructive witness).**

The "orthogonal problems" instance: `p₁(x) = [x = a]`, `p₂(x) = [x = b]`
with `a ≠ b` have no common solution, so `N_meet = ⊤` while `N₁ = N₂ = 1`
and `N_join = 1`.  Then the supermodular inequality is strict and the
reverse (submodular) inequality `N₁ + N₂ ≥ N_join + N_meet` fails:
`2 = N₁ + N₂ < N_join + N_meet = ⊤`. -/
theorem R_503_not_submodular_witness :
    ∃ (N₁ N₂ N_join N_meet : ℕ∞),
      N_join = min N₁ N₂ ∧ max N₁ N₂ ≤ N_meet ∧
      N₁ + N₂ < N_join + N_meet := by
  refine ⟨1, 1, 1, ⊤, ?_, ?_, ?_⟩
  · simp
  · simp
  · -- 1 + 1 = 2 < ⊤ = 1 + ⊤
    rw [show (⊤ : ℕ∞) = (1 : ℕ∞) + ⊤ from (WithTop.add_top _).symm]
    exact lt_top_iff_ne_top.mpr (by decide)

end LatticeMeetJoin

end MIP
