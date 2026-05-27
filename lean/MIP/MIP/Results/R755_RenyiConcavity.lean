/-
Result R.755 — Rényi α-concavity on (0,1], EPI-K generalisation
(slot 033, LRA).

Reference: `workspace/round3_exploration/slot_033.md` and
`workspace/round3_exploration/work_slot_033.md` §2.6 (R.755, B 条件).
Source statement (corrected).  For agents `X, Y`, a mixing weight
`λ ∈ (0,1)` and `α ∈ (0,1]`:

    H_α(X ⊞_λ Y) ≥ c·H_α(X) + (1−c)·H_α(Y) ,

i.e. the Rényi α-entropy is **concave under the synergistic mixture**
`X ⊞_λ Y` (`p_{X⊞Y} = c·p_X + (1−c)·p_Y`).  At `α = 1` this recovers the
Shannon concavity of R.700 (EPI-K); for `α > 1` it reverses (not an EPI).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

The mathematical engine, identified in the slot, is the **concavity of
`x ↦ x^α` on `[0,∞)` for `α ∈ [0,1]`** (slot §2.6: "subadditivity of
`x ↦ x^α`").  This is the *crisp inequality* of R.755 and we prove it
outright via `Real.concaveOn_rpow`, in two forms:

* the **two-point** weighted concavity
  `(c·a + (1−c)·b)^α ≥ c·a^α + (1−c)·b^α`;
* its **per-outcome summed** form, the power-sum concavity that drives
  the Rényi mixture concavity
  `Σ (c·p + (1−c)·q)^α ≥ c·Σ p^α + (1−c)·Σ q^α`.

The passage from the power-sum inequality to the entropy inequality
`H_α ≥ c H_α + (1−c) H_α` (a monotone `log`/`1/(1−α)` reparametrisation)
is the B-conditional normalisation step bundled in the slot; the crisp
inequality itself is the content proved here.

All powers use `Real.rpow`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.Convex.SpecificFunctions.Pow
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith

namespace MIP

namespace RenyiTail

open scoped BigOperators
open Real

/-- **R.755 (two-point α-concavity, `α ∈ (0,1]`).**

For `a, b ≥ 0`, weights `c, d ≥ 0` with `c + d = 1`, and `α ∈ [0,1]`:

    (c·a + d·b) ^ α  ≥  c · a^α + d · b^α .

This is the concavity of `x ↦ x^α` on `[0,∞)` (`Real.concaveOn_rpow`),
the crisp inequality at the heart of R.755. -/
theorem R_755_rpow_concave
    (α a b c d : ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hcd : c + d = 1) :
    c * a ^ α + d * b ^ α ≤ (c * a + d * b) ^ α := by
  have hconc := Real.concaveOn_rpow (p := α) hα0 hα1
  exact hconc.2 (Set.mem_Ici.mpr ha) (Set.mem_Ici.mpr hb) hc hd hcd

/-- **R.755 (power-sum α-concavity, `α ∈ (0,1]`).**

Summing the two-point concavity over a finite outcome set `s`: for
nonnegative `p, q`, weights `c, d ≥ 0` with `c + d = 1`, and `α ∈ [0,1]`:

    Σ_ω (c·p_ω + d·q_ω)^α  ≥  c · Σ_ω p_ω^α  +  d · Σ_ω q_ω^α .

This is the power-sum concavity driving the Rényi mixture concavity
(the `Σ p^α` term inside `H_α`).  The `log / (1−α)` reparametrisation to
the entropy statement is the bundled normalisation step. -/
theorem R_755_powerSum_concave
    {ι : Type*} (s : Finset ι) (α c d : ℝ) (p q : ι → ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q ω)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hcd : c + d = 1) :
    c * (∑ ω ∈ s, (p ω) ^ α) + d * (∑ ω ∈ s, (q ω) ^ α)
      ≤ ∑ ω ∈ s, (c * p ω + d * q ω) ^ α := by
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro ω hω
  exact R_755_rpow_concave α (p ω) (q ω) c d hα0 hα1 (hp ω hω) (hq ω hω) hc hd hcd

end RenyiTail

end MIP
