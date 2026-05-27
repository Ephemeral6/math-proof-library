/-
Result R.753 — Amari α-divergence: non-negativity and α ↔ 1−α duality
(slot 033, LRA).

Reference: `workspace/round3_exploration/slot_033.md` and
`workspace/round3_exploration/work_slot_033.md` §2.4 (R.753, A 无条件).
Source statement.  For agents `X, Y` with normalised distributions
`p_X, p_Y` on `K(X) ∪ K(Y)` and `α ∈ (0,1) ∪ (1,∞)`, the Amari
α-divergence is

    D_α(p ‖ q) := 1 / (α(α−1)) · log( Σ_ω p(ω)^α · q(ω)^{1−α} ) .

The slot establishes:

* **(a) non-negativity** `D_α(p ‖ q) ≥ 0`, equality iff `p = q`
  (the Csiszár / Jensen f-divergence fact, bundled);
* **(b) duality** `D_{1−α}(q ‖ p) = D_α(p ‖ q)` (pure algebra);
* **(c)/(d)** the `α → 1` / `α → 0` limits give `KL(p‖q)` / `KL(q‖p)`
  (limit statements, not formalised here).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

We formalise the **duality identity in full** (it is an exact algebraic
identity in the power-sum and the prefactor) and the **non-negativity**
with the convexity/Jensen step bundled as a hypothesis on the
power-sum, namely `log(Σ p^α q^{1−α}) ≤ 0` on the relevant α-range,
together with the sign of the prefactor `1/(α(α−1)) > 0` for `α > 1` and
`< 0` for `α ∈ (0,1)` — both yielding `D_α ≥ 0`.

All powers use `Real.rpow`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators
open Real

namespace AlphaDivergence

variable {ι : Type*}

/-- The α-power-sum `Σ_ω p(ω)^α · q(ω)^{1−α}` over the finite support `s`.
This is the Hellinger / Chernoff integrand whose log is the divergence. -/
noncomputable def powerSum (s : Finset ι) (α : ℝ) (p q : ι → ℝ) : ℝ :=
  ∑ ω ∈ s, (p ω) ^ α * (q ω) ^ (1 - α)

/-- The Amari α-divergence `D_α(p ‖ q) = 1/(α(α−1)) · log(Σ p^α q^{1−α})`. -/
noncomputable def Dalpha (s : Finset ι) (α : ℝ) (p q : ι → ℝ) : ℝ :=
  (1 / (α * (α - 1))) * Real.log (powerSum s α p q)

/-- **Power-sum symmetry under `α ↦ 1−α` with arguments swapped.**

`Σ q(ω)^{1−α} · p(ω)^{1−(1−α)} = Σ p(ω)^α · q(ω)^{1−α}`, since
`1 − (1 − α) = α` and multiplication commutes.  This is the algebraic
heart of the duality. -/
theorem powerSum_swap (s : Finset ι) (α : ℝ) (p q : ι → ℝ) :
    powerSum s (1 - α) q p = powerSum s α p q := by
  unfold powerSum
  apply Finset.sum_congr rfl
  intro ω _
  have h : (1 : ℝ) - (1 - α) = α := by ring
  rw [h, mul_comm]

/-- **R.753 (b) — α-divergence duality `D_{1−α}(q ‖ p) = D_α(p ‖ q)`.**

The prefactors agree: `(1−α)·((1−α)−1) = (1−α)·(−α) = α·(α−1)`, and the
power-sums agree by `powerSum_swap`.  Hence the two divergences are
equal — the classical α ↔ 1−α duality.  The identity is structural and
holds for every `α` (at the endpoints `α ∈ {0,1}` both sides share the
same — vacuous — prefactor `1/0 = 0`, so equality persists). -/
theorem R_753_duality
    (s : Finset ι) (α : ℝ) (p q : ι → ℝ) :
    Dalpha s (1 - α) q p = Dalpha s α p q := by
  unfold Dalpha
  rw [powerSum_swap]
  congr 1
  have hpref : (1 - α) * ((1 - α) - 1) = α * (α - 1) := by ring
  rw [hpref]

/-- **R.753 (a) — non-negativity, `α > 1` branch.**

For `α > 1` the prefactor `1/(α(α−1)) > 0`.  The Csiszár/Jensen fact for
this branch is `log(Σ p^α q^{1−α}) ≥ 0` (bundled as `h_jensen`); the
product of two nonnegatives is nonnegative, so `D_α ≥ 0`. -/
theorem R_753_nonneg_gt_one
    (s : Finset ι) (α : ℝ) (p q : ι → ℝ)
    (hα : 1 < α) (h_jensen : 0 ≤ Real.log (powerSum s α p q)) :
    0 ≤ Dalpha s α p q := by
  unfold Dalpha
  apply mul_nonneg _ h_jensen
  apply le_of_lt
  apply div_pos one_pos
  apply mul_pos (by linarith) (by linarith)

/-- **R.753 (a) — non-negativity, `α ∈ (0,1)` branch.**

For `0 < α < 1` the prefactor `1/(α(α−1)) < 0` (since `α−1 < 0`).  The
Csiszár/Jensen fact for this branch is `log(Σ p^α q^{1−α}) ≤ 0` (bundled
as `h_jensen`); the product of two nonpositives is nonnegative, so
`D_α ≥ 0`. -/
theorem R_753_nonneg_lt_one
    (s : Finset ι) (α : ℝ) (p q : ι → ℝ)
    (hα0 : 0 < α) (hα1 : α < 1)
    (h_jensen : Real.log (powerSum s α p q) ≤ 0) :
    0 ≤ Dalpha s α p q := by
  unfold Dalpha
  have hpref : (1 / (α * (α - 1))) ≤ 0 := by
    apply div_nonpos_of_nonneg_of_nonpos (by norm_num)
    apply mul_nonpos_of_nonneg_of_nonpos (le_of_lt hα0) (by linarith)
  -- product of two nonpositives is nonnegative: a·b = (−a)·(−b) ≥ 0
  have : (1 / (α * (α - 1))) * Real.log (powerSum s α p q)
        = (-(1 / (α * (α - 1)))) * (-(Real.log (powerSum s α p q))) := by ring
  rw [this]
  exact mul_nonneg (by linarith) (by linarith)

end AlphaDivergence

end MIP
