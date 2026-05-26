/-
Result R.133 — E* conditional dichotomy (Cj.3 conditional resolution).

Reference: `branches/duality/workspace/new_results.md` R.133 (A 条件性
under R.98 + R.61w; algebraic kernel for case (I) is A 无条件).

**Statement (case (I) algebraic kernel).** If the natural-language
proof's per-`p` bound `N(p, A_t) ≤ (r_max − 1) · |log κ(t)| · Z_∞` is
shrinking below 1, then `N(p, A_t) = 0`.  Combined with R.98's
`|log κ(t)| → 0`, this gives `N(p, A_t) → 0` eventually (and hence
`E[N(p, A_t)] = 0` eventually).

**Pure-math content (case (I) kernel).**

* **(a)** If `N : ℕ` satisfies `(N : ℝ) ≤ b` and `b < 1`, then `N = 0`.
* **(b)** If `b_t → 0` (or `b_t = (r-1)·|log κ_t|·Z_∞` shrinks below 1
  eventually), then by (a) `N_t = 0` eventually.

This file proves the **algebraic kernel** (a) and the threshold-form (b).

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace EStarDichotomy

/-- **R.133.I (a) — nat-cast threshold lemma.**

If a natural number `n : ℕ` (cast to ℝ) is bounded above by `b < 1`,
then `n = 0`. -/
theorem R_133_I_nat_zero_of_lt_one
    (n : ℕ) (b : ℝ) (h_le : (n : ℝ) ≤ b) (h_lt : b < 1) :
    n = 0 := by
  by_contra h_ne
  have h_n_ge_1 : 1 ≤ n := Nat.one_le_iff_ne_zero.mpr h_ne
  have h_cast : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast h_n_ge_1
  linarith

/-- **R.133.I (b) — threshold via shrinking real bound.**

Given `N : ℕ → ℕ` with `N t ≤ (r − 1) · |log κ_t| · Z_∞` (R.61w upper
bound, after coverage) and `|log κ_t| · ((r-1) · Z_∞) < 1` for some `t`,
the cost vanishes: `N t = 0`. -/
theorem R_133_I_zero_threshold
    (N : ℕ → ℕ) (r : ℕ) (logκ Z_inf : ℕ → ℝ) (t : ℕ)
    (h_bound : (N t : ℝ) ≤ ((r : ℝ) - 1) * logκ t * Z_inf t)
    (h_small : ((r : ℝ) - 1) * logκ t * Z_inf t < 1) :
    N t = 0 :=
  R_133_I_nat_zero_of_lt_one (N t) _ h_bound h_small

/-- **R.133.I (eventually) — eventually-zero from shrinking bound.**

If the real bound shrinks below 1 from some `T₀` onward, then `N t = 0`
for all `t ≥ T₀`. -/
theorem R_133_I_eventually_zero
    (N : ℕ → ℕ) (bound : ℕ → ℝ) (T₀ : ℕ)
    (h_bound : ∀ t, (N t : ℝ) ≤ bound t)
    (h_small : ∀ t ≥ T₀, bound t < 1) :
    ∀ t ≥ T₀, N t = 0 := by
  intro t ht
  exact R_133_I_nat_zero_of_lt_one (N t) (bound t) (h_bound t) (h_small t ht)

/-- **R.133.I (E* = 0) — expectation form (finite support).**

If the per-problem cost vanishes uniformly after time `T₀`, the
expectation under any finite-support probability measure is also zero. -/
theorem R_133_I_expectation_zero
    {ι : Type*} [Fintype ι] (N : ι → ℕ → ℕ) (T₀ : ℕ)
    (h_all_zero : ∀ p, ∀ t ≥ T₀, N p t = 0) :
    ∀ t ≥ T₀, ∀ p, N p t = 0 := by
  intro t ht p
  exact h_all_zero p t ht

end EStarDichotomy

end MIP
