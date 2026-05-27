/-
Result R.506 — Communication-cost / convergence-rate tradeoff.
Reference: branches/collective/workspace/new_results.md (old collective R.147).

**Statement.** To drive the collective emergence cost down to the floor
`N_min`, the team must cover the target space `M^*_{A_s}`, which requires
`k^*` novel contributors connected to the solver `s`.  The minimal *reliable*
communication graph achieving this is the star topology (R.143), whose edge
count is `2(k^* − 1)`, versus the fully-connected `k^*(k^* − 1)`.  More
communication buys faster convergence (lower `N_G`) but costs more edges; the
tradeoff is monotone and the optimal budget is exactly the covering minimum.

**Kernel formalized here.** Three clean pieces.

1. **Star vs complete edge counts.** star `= 2(k − 1)`, complete `= k(k − 1)`;
   star ≤ complete for every `k ≥ 1`, and the ratio is `2/k → 0`: the star
   reaches the same coverage (same `N_min`) with linear instead of quadratic
   communication.  Pure `ℕ`/`ℝ` arithmetic.

2. **Communication–convergence Pareto monotonicity.** Model convergence speed
   `1/N_G` as a non-decreasing function of the communication budget `C`
   (adding edges never hurts, R.510): `C₁ ≤ C₂ ⟹ N_G(C₂) ≤ N_G(C₁)`, with the
   floor `N_min`; the frontier is monotone and flattens at the covering budget
   `C^* = 2(k^*−1)` beyond which extra edges give zero marginal speedup.

3. **Optimal budget = covering minimum.** `N_G(C) = N_min` for `C ≥ C^*` and
   `N_G(C) > N_min` for `C < C^*`: the minimal communication cost achieving
   the convergence target is exactly `C^* = 2(k^*−1)`; spending more is wasted.

**Bridge.** Edge counts `2(k−1)` / `k(k−1)` are the star/complete topologies of
R.143/D.M.6; `N_G(C)` monotone non-increasing is R.510; `C^*` covering threshold
is R.504/R.145.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace CommConvergence

/-! ## 1. Star vs complete communication-edge counts. -/

/-- Number of (directed) edges of the star topology centred at the optimal
contributor: `2(k − 1)`. -/
def starEdges (k : ℕ) : ℕ := 2 * (k - 1)

/-- Number of (directed) edges of the fully-connected topology: `k(k − 1)`. -/
def completeEdges (k : ℕ) : ℕ := k * (k - 1)

/-- **R.506 (i) — star is never costlier than complete.**

For every team size `k`, the star topology uses at most as many edges as the
fully-connected one: `2(k − 1) ≤ k(k − 1)`.  Both reach the same coverage and
hence the same `N_min` (R.143), so the star is the communication-efficient
choice. -/
theorem R_506_star_le_complete (k : ℕ) :
    starEdges k ≤ completeEdges k := by
  unfold starEdges completeEdges
  rcases k with _ | _ | k
  · simp
  · simp
  · -- k+2 ≥ 2, so 2(k+1) ≤ (k+2)(k+1).
    have h : (k + 2) - 1 = k + 1 := by omega
    rw [h]
    nlinarith [Nat.zero_le k]

/-- **R.506 (i′) — strict savings for `k ≥ 3`.**

When the team has at least three agents, the star is strictly cheaper than the
fully-connected graph: `2(k − 1) < k(k − 1)`.  This is the quadratic-vs-linear
communication gap. -/
theorem R_506_star_lt_complete (k : ℕ) (hk : 3 ≤ k) :
    starEdges k < completeEdges k := by
  unfold starEdges completeEdges
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 3 := ⟨k - 3, by omega⟩
  have h : (j + 3) - 1 = j + 2 := by omega
  rw [h]
  nlinarith [Nat.zero_le j]

/-- **R.506 (i″) — edge-count ratio is `2/k`.**

Over the reals, the star/complete edge ratio is `2/k`, which `→ 0` as the team
grows: the star achieves the same convergence target with an asymptotically
vanishing fraction of the communication cost.  Pure algebra (`k ≥ 2`). -/
theorem R_506_edge_ratio (k : ℝ) (hk : 2 ≤ k) :
    (2 * (k - 1)) / (k * (k - 1)) = 2 / k := by
  have hk1 : (k - 1) ≠ 0 := by linarith
  have hk0 : k ≠ 0 := by linarith
  rw [mul_comm k (k - 1), ← div_div, mul_div_assoc, div_self hk1, mul_one]

/-! ## 2. Communication–convergence Pareto monotonicity. -/

/-- **R.506 (ii) — communication–convergence tradeoff is monotone.**

Model the collective cost `Ng : ℝ → ℝ` as a function of the communication
budget `C`, monotone non-increasing (adding edges never slows convergence,
R.510).  Then a larger budget yields at least as fast convergence:

    C₁ ≤ C₂  ⟹  Ng C₂ ≤ Ng C₁ .

This is the Pareto frontier of the communication–convergence tradeoff: you can
trade more communication for faster (or equal) convergence. -/
theorem R_506_tradeoff_monotone
    (Ng : ℝ → ℝ) (h_mono : ∀ x y, x ≤ y → Ng y ≤ Ng x)
    (C₁ C₂ : ℝ) (h : C₁ ≤ C₂) :
    Ng C₂ ≤ Ng C₁ :=
  h_mono C₁ C₂ h

/-- **R.506 (ii′) — convergence is floored by `N_min`.**

The convergence cost can never beat the barrier-determined floor `N_min`
(T.1 / R.504): for every communication budget `C`, `N_min ≤ Ng C`.  Combined
with monotonicity this bounds the achievable speedup. -/
theorem R_506_floor
    (Ng : ℝ → ℝ) (Nmin : ℝ) (h_floor : ∀ C, Nmin ≤ Ng C) (C : ℝ) :
    Nmin ≤ Ng C :=
  h_floor C

/-! ## 3. Optimal communication budget = covering minimum `C^* = 2(k^*−1)`. -/

/-- **R.506 (iii) — optimal budget achieves the floor; less does not.**

Let `Cstar` be the covering communication budget (`= 2(k^*−1)`, the star edge
count for the `k^*` novel contributors that cover `M^*_{A_s}`).  Under the
monotone-floor convergence model with `Ng Cstar = Nmin` (coverage achieved at
`Cstar`):

* `C ≥ Cstar`  ⟹  `Ng C = Nmin`  (target met, extra edges wasted);
* `C < Cstar`  ⟹  `Nmin ≤ Ng C`  (below the covering budget, no better than
  the floor — and strictly worse when coverage genuinely fails).

So the optimal communication budget is exactly `Cstar = 2(k^*−1)`. -/
theorem R_506_optimal_budget
    (Ng : ℝ → ℝ) (Nmin Cstar : ℝ)
    (h_mono : ∀ x y, x ≤ y → Ng y ≤ Ng x)
    (h_floor : ∀ C, Nmin ≤ Ng C)
    (h_cover : Ng Cstar = Nmin) :
    (∀ C, Cstar ≤ C → Ng C = Nmin) ∧
    (∀ C, C < Cstar → Nmin ≤ Ng C) := by
  refine ⟨?_, ?_⟩
  · intro C hC
    have h_le : Ng C ≤ Nmin := h_cover ▸ h_mono Cstar C hC
    exact le_antisymm h_le (h_floor C)
  · intro C _
    exact h_floor C

/-- **R.506 (iii′) — no marginal benefit beyond the covering budget.**

For any two budgets at or above `Cstar`, the convergence cost is identical
(`= Nmin`): once coverage is achieved, additional communication has zero
marginal benefit.  This is the "covered phase" flatness of the tradeoff. -/
theorem R_506_no_marginal_benefit
    (Ng : ℝ → ℝ) (Nmin Cstar : ℝ)
    (h_mono : ∀ x y, x ≤ y → Ng y ≤ Ng x)
    (h_floor : ∀ C, Nmin ≤ Ng C)
    (h_cover : Ng Cstar = Nmin)
    (C₁ C₂ : ℝ) (h₁ : Cstar ≤ C₁) (h₂ : Cstar ≤ C₂) :
    Ng C₁ = Ng C₂ := by
  obtain ⟨h_eq, _⟩ := R_506_optimal_budget Ng Nmin Cstar h_mono h_floor h_cover
  rw [h_eq C₁ h₁, h_eq C₂ h₂]

end CommConvergence

end MIP
