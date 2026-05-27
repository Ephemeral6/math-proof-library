/-
Result R.756 — Tsallis q-entropy pseudo-additivity (slot 033, LRA).

Reference: `workspace/round3_exploration/slot_033.md` and
`workspace/round3_exploration/work_slot_033.md` §2.6 (R.756, A 条件
product).  Source statement:

    S_q(A ⊗ B) = S_q(A) + S_q(B) + (1 - q) · S_q(A) · S_q(B) ,

the Tsallis non-extensive composition law, where for a finite
distribution `p` the Tsallis q-entropy is

    S_q(p) := (1 - Σ_ω p(ω)^q) / (q - 1) ,   q ≠ 1 .

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

This is a *pure algebraic identity*.  The only structural input is the
product (independence) assumption on the joint distribution, namely the
factorisation of the power sum

    Σ_{(ω,ω')} (p(ω)·r(ω'))^q  =  (Σ_ω p(ω)^q) · (Σ_{ω'} r(ω')^q) ,

which holds for a product distribution.  We bundle that factorisation as
a hypothesis and prove the pseudo-additivity law exactly; we also prove
the factorisation itself for a genuine product over finite index types,
so the law is established end-to-end.

`q = 1` recovers Shannon additivity in the limit (not formalised here —
it is a limit statement); for `q ≠ 1` the `(1 - q)·S_q(A)·S_q(B)`
correction is the Tsallis deformation.

All powers use `Real.rpow`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace MIP

open scoped BigOperators
open Real

namespace TsallisAdditivity

/-- The Tsallis `q`-entropy of a distribution whose power-sum is `P`
(`P := Σ_ω p(ω)^q`).  We work with the scalar power-sum directly:

    S_q = (1 - P) / (q - 1) .

This is the standard Tsallis entropy `S_q(p) = (1 - Σ p^q)/(q-1)`. -/
noncomputable def Sq (q P : ℝ) : ℝ := (1 - P) / (q - 1)

/-- **Power-sum factorisation for a product distribution.**

For finite index types `ι, κ`, distributions `p : ι → ℝ`, `r : κ → ℝ`
and any exponent `q`, the joint power-sum over the product
`(p(i)·r(j))` factorises:

    Σ_{(i,j)} (p i · r j)^q  =  (Σ_i p i ^ q) · (Σ_j r j ^ q) ,

provided each `p i, r j ≥ 0` (so that `(p i · r j)^q = p i ^ q · r j ^ q`
under `Real.rpow`).  This is the independence input behind R.756. -/
theorem product_powersum_factor
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (p : ι → ℝ) (r : κ → ℝ) (q : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hr : ∀ j, 0 ≤ r j) :
    (∑ i, ∑ j, (p i * r j) ^ q)
      = (∑ i, p i ^ q) * (∑ j, r j ^ q) := by
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  rw [Real.mul_rpow (hp i) (hr j)]

/-- **R.756 (Tsallis pseudo-additivity, power-sum form).**

Given the two marginal power-sums `PA := Σ p^q`, `PB := Σ r^q` and the
joint power-sum `PAB := Σ (p·r)^q = PA · PB` (the product factorisation),
the Tsallis entropies obey the non-extensive composition law

    S_q(A⊗B) = S_q(A) + S_q(B) + (1 - q)·S_q(A)·S_q(B) ,

for every `q ≠ 1`.  This is a pure algebraic identity in `PA, PB, q`. -/
theorem R_756_pseudo_additive
    (q PA PB PAB : ℝ) (hq : q ≠ 1) (hfac : PAB = PA * PB) :
    Sq q PAB = Sq q PA + Sq q PB + (1 - q) * (Sq q PA) * (Sq q PB) := by
  have hq' : q - 1 ≠ 0 := sub_ne_zero.mpr hq
  unfold Sq
  rw [hfac]
  field_simp
  ring

/-- **R.756 (end-to-end, genuine product distribution).**

Combining `product_powersum_factor` with the algebraic law: for finite
index types and nonnegative marginals `p, r`, writing the Tsallis
entropies through their power-sums, the joint Tsallis entropy of the
product distribution `(i,j) ↦ p i · r j` satisfies the pseudo-additivity
law.  No factorisation hypothesis is needed — it is proved internally. -/
theorem R_756_product
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (p : ι → ℝ) (r : κ → ℝ) (q : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hr : ∀ j, 0 ≤ r j) (hq : q ≠ 1) :
    Sq q (∑ i, ∑ j, (p i * r j) ^ q)
      = Sq q (∑ i, p i ^ q) + Sq q (∑ j, r j ^ q)
        + (1 - q) * (Sq q (∑ i, p i ^ q)) * (Sq q (∑ j, r j ^ q)) :=
  R_756_pseudo_additive q (∑ i, p i ^ q) (∑ j, r j ^ q)
    (∑ i, ∑ j, (p i * r j) ^ q) hq
    (product_powersum_factor p r q hp hr)

end TsallisAdditivity

end MIP
