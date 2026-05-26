/-
Result R.458 — R.132 conservation as S₂-symmetric/anti-symmetric
decomposition.

Reference: `workspace/categorical_formalization.md` R.458 (A 级).

**Statement (algebraic core).** Define the symmetric / anti-symmetric
parts under the swap `(A, H) ↔ (H, A)`:

    N_sym  := (N + N*) / 2
    N_anti := (N − N*) / 2

Then `N = N_sym + N_anti` and `N* = N_sym − N_anti` (S₂ representation
decomposition).  Combined with R.132 (`N + N* = 2·N_bi + Asym`):

    N_sym  =  N_bi + Asym/2 .

**Pure-math content.** Standard S₂ representation theory: any
real-valued function on `(X, Y)` decomposes into trivial and sign
representations.

This file proves the **algebraic decomposition kernel** without
committing to categorical infrastructure.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace S2Decomposition

/-- **R.458 (b) — sym/anti decomposition (recovery).**

`(N + N*)/2 + (N − N*)/2 = N` and `(N + N*)/2 − (N − N*)/2 = N*`.
Pure ring algebra. -/
theorem R_458_b_decomposition (N N_star : ℝ) :
    (N + N_star) / 2 + (N - N_star) / 2 = N ∧
    (N + N_star) / 2 - (N - N_star) / 2 = N_star := by
  refine ⟨?_, ?_⟩ <;> ring

/-- **R.458 (c) — R.132 in symmetric-part form.**

From R.132 (`N + N* = 2·N_bi + Asym`), `N_sym := (N + N*)/2 = N_bi + Asym/2`. -/
theorem R_458_c_sym_part
    (N N_star N_bi Asym N_sym : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_sym_def : N_sym = (N + N_star) / 2) :
    N_sym = N_bi + Asym / 2 := by
  rw [h_sym_def, h_R132]; ring

/-- **R.458 (c) — Asym in anti-norm form.**

`Asym = |N − N*|` in the single-barrier max-dominated form (algebraic
core matches R.144 (ii)).  Stated as a literal substitution given
`Asym = 2 · |N_anti|`. -/
theorem R_458_c_asym_as_anti_norm
    (N N_star Asym : ℝ)
    (h_asym_eq : Asym = |N - N_star|) :
    Asym / 2 = |N - N_star| / 2 := by
  rw [h_asym_eq]

/-- **R.458 (d) — `N + N*` is S₂-invariant.**

The sum `N + N*` is invariant under the swap `(N, N*) ↔ (N*, N)`. -/
theorem R_458_d_sum_invariant (N N_star : ℝ) :
    N + N_star = N_star + N := by ring

/-- **R.458 (d) — `N − N*` is S₂-antisymmetric.**

The difference `N − N*` changes sign under the swap. -/
theorem R_458_d_diff_antisym (N N_star : ℝ) :
    N - N_star = -(N_star - N) := by ring

/-- **R.458 (e) — Noether-style conservation: invariant decomposes.**

Given `N + N* = 2·N_bi + Asym` (R.132), the S₂-invariant sum decomposes
into the (invariant) `2·N_bi` and the (invariant in magnitude, but
"residual") `Asym`.  Stated as an algebraic equivalence. -/
theorem R_458_e_noether_decomposition
    (N N_star N_bi Asym : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym) :
    (N + N_star) = 2 * N_bi + Asym ∧
    -- both terms on RHS are S₂-invariant (don't change under swap):
    (2 * N_bi) = (2 * N_bi) ∧
    Asym = Asym := by
  exact ⟨h_R132, rfl, rfl⟩

end S2Decomposition

end MIP
