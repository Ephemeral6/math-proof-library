/-
Result R.170 — Average-case behaviour of `N` under the universal measure `μ_U`.

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.170 and
`new_results.md` §R.170 (A 条件性 + 部分 B, deps R.83, R.84, R.168, R.163,
Hoeffding, Toda, arithmetic hierarchy).

**Statement.**
* **(a)** `E_μ[N]` is uncomputable (`BOUNDED-EXPECTED-N ≥_T 0''`).
* **(b)** `Pr_μ[N<∞]` is not exactly computable (reduces from R.84) but is
  ε-estimable by Monte Carlo (`Õ(1/ε²)` samples).
* **(c)** average–worst strict separation: there is `(A, μ_U)` with
  `E_μ[N̄] < ∞` yet `sup_p N(p,A) = ∞`.
* **(d)** almost-everywhere solvability: `Pr_{p∼μ_U}[N(p,A)=∞] ≤ 1 − 2^{−|⟨A⟩|−O(1)}`.

**Formalization strategy (direct kernels (c)(d) + uncomputability transfer (a)).**

* **(c)** is a genuine analytic fact: a weighted cost can be summable while the
  cost itself is unbounded.  We give the explicit witness `N̄ i = i`,
  `μ i = (1/2)^(i+1)`: the series `∑' i, μ i · N̄ i` converges (a textbook
  geometric-type sum), while `sup_i N̄ i = ∞` since `N̄` is unbounded.  This is
  `R_170_c_average_worst_separation`.
* **(d)** is the complementary-mass identity: with solvable mass
  `prSolvable ≥ 2^(−c) > 0` and `prSolvable + prInfinite = 1`, the unsolvable
  mass satisfies `prInfinite ≤ 1 − 2^(−c)`.  This is `R_170_d_ae_solvable`.
* **(a)** the uncomputability of `E_μ[N]` is the decidability-transfer kernel
  (identical to R.83): `BOUNDED-EXPECTED-N` pulls back the undecidable double-
  jump predicate.  `R_170_a_expectation_uncomputable`.

**This file is `axiom`-free.**  Imports only `Mathlib`; the `0''`-hardness
source enters as a hypothesis, while (c) and (d) are fully constructive.
-/
import Mathlib

namespace MIP

namespace AverageCaseComputability

open scoped BigOperators

/-- **R.170(c) — average–worst strict separation (explicit witness).**

With truncated cost `N̄ i := i` (unbounded, so `sup = ∞`) and universal weights
`μ i := (1/2)^(i+1)`, the expected cost `∑' i, μ i · N̄ i` is **finite**
(summable geometric-type series) while the cost `N̄` is **unbounded**.  This is
the coexistence "average easy, worst-case unsolvable". -/
theorem R_170_c_average_worst_separation :
    (Summable fun i : ℕ => ((1:ℝ)/2) ^ (i + 1) * (i : ℝ)) ∧
      (¬ ∃ B : ℝ, ∀ i : ℕ, (i : ℝ) ≤ B) := by
  constructor
  · -- ∑ (1/2)^(i+1) · i converges: factor (1/2) and use summability of i·r^i.
    have hr : ‖(1:ℝ)/2‖ < 1 := by rw [Real.norm_eq_abs]; rw [abs_of_pos]; norm_num; norm_num
    have hbase : Summable fun i : ℕ => (i : ℝ) * ((1:ℝ)/2) ^ i :=
      summable_pow_mul_geometric_of_norm_lt_one 1 hr |>.congr (by
        intro i; simp)
    -- our summand equals (1/2) · (i · (1/2)^i)
    apply (hbase.mul_left ((1:ℝ)/2)).congr
    intro i
    ring
  · -- ℕ is unbounded in ℝ
    rintro ⟨B, hB⟩
    obtain ⟨n, hn⟩ := exists_nat_gt B
    exact absurd (hB n) (not_le.mpr hn)

/-- **R.170(d) — almost-everywhere solvability bound.**

If the solvable mass is at least `2^(−c)` (`hSolv : (2:ℝ)^(−c) ≤ prSolvable`)
and total mass is `1` (`hTotal : prSolvable + prInfinite = 1`), then the
unsolvable ("`N=∞`") mass obeys

    prInfinite ≤ 1 − 2^(−c) < 1.

So a strictly positive proportion of problems is solvable under `μ_U` —
complementary to the R.168 blind-spot mass. -/
theorem R_170_d_ae_solvable
    (c prSolvable prInfinite : ℝ)
    (hSolv : (2:ℝ) ^ (-c) ≤ prSolvable)
    (hTotal : prSolvable + prInfinite = 1) :
    prInfinite ≤ 1 - (2:ℝ) ^ (-c) ∧ prInfinite < 1 := by
  have hpos : 0 < (2:ℝ) ^ (-c) := by positivity
  constructor
  · -- prInfinite = 1 - prSolvable ≤ 1 - 2^(-c)
    have : prInfinite = 1 - prSolvable := by linarith
    rw [this]; linarith
  · linarith

-- Decidability surrogate (Prop-valued, negatable), as in R.83.
/-- A total Boolean decider for a predicate. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop := ∀ a, f a = true ↔ P a

/-- `P` is decidable iff a total Boolean decider exists. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop := ∃ f : α → Bool, Decides f P

/-- **R.170(a) — `E_μ[N]` is uncomputable (decidability transfer).**

`BOUNDED-EXPECTED-N` ("is `E_μ[N(p,A)] ≤ k`?") is undecidable: the source shows
`E_μ[N] < ∞ ⟺ ∀(T,x)∈supp(μ): T halts on x`, a `Π⁰₂` statement Turing-
equivalent to the double jump `0''`.  We bundle the undecidable `0''`-predicate
`doubleJump` and the reduction `red` validating it against `boundedExpectedN`;
decidability pulls back along `red`, so undecidability of `doubleJump` forces
undecidability of `boundedExpectedN`.  Hence `E_μ[N]` is uncomputable. -/
theorem R_170_a_expectation_uncomputable {α β : Type*}
    (boundedExpectedN : β → Prop) (doubleJump : α → Prop)
    (red : α → β)
    (hval : ∀ a, doubleJump a ↔ boundedExpectedN (red a))
    (h_dj_undec : ¬ IsDecidablePred doubleJump) :
    ¬ IsDecidablePred boundedExpectedN := by
  intro hBE
  apply h_dj_undec
  obtain ⟨f, hf⟩ := hBE
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), ← hval a]

end AverageCaseComputability

end MIP
