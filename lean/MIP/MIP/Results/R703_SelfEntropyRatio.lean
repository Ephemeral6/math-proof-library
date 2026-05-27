/-
Result R.703 — Self-reference entropy-power ratio lower bound
(slot 007, EKI — tail of the R.700 entropy-power family).

Reference: `workspace/round3_exploration/slot_007.md` (R.703) and
`workspace/round3_exploration/work_slot_007.md` §5.3 (R.7.B / P.7.6,
"Self-Reference Z 下界").

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement.**  For a non-degenerate agent `Y` (R.86 condition) with a
self-reflective sub-kernel `A_Y^{self}` (D.1.11), the self-reference
emergent impedance dominates the external one in the precise quantitative
form

    Z_self(Y) / Z(Y)  ≥  N_K(Y) / N_K(A_Y^{self})  ≥  1,

where `N_K(W) := exp(H_K(W))` is the knowledge entropy power.  The right
inequality `N_K(Y)/N_K(self) ≥ 1` is the entropy-power form of R.701
(`H_K(A_Y^{self}) ≤ H_K(Y)`, conditional ≤ marginal entropy under the
semantic-preservation hypothesis SP).  The left inequality is the
*strengthened* R.86: the non-degeneracy of `Y` not only gives
`Z_self > Z` but pins the ratio to the entropy-power tax
`N_K(Y)/N_K(self)`.

**Bundled facts (entered as explicit hypotheses).**

* **(SP / R.701)** `Hself ≤ Hy`: self-reflective conditional entropy ≤
  parent marginal entropy (work_slot_007 §3.3, semantic-preservation).
* **(R.86 strengthened)** `Z(Y)·(N_K(Y)/N_K(self)) ≤ Z_self(Y)`: the
  non-degeneracy ratio bound (`hZ86`), the analytic content of R.86
  quantified by the entropy-power tax.

From these we derive the boxed ratio chain.  The deep R.86 / SP analytic
facts are bundled; what is proved is the exact passage to the ratio bound
and its consequence `Z_self ≥ Z`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace EntropyPowerTail

open Real

/-- Knowledge entropy power `N_K(H) := exp H` (same as the R.700 family). -/
noncomputable def Npow (H : ℝ) : ℝ := Real.exp H

@[simp] lemma Npow_pos (H : ℝ) : 0 < Npow H := Real.exp_pos H

/-- **R.701 entropy-power ratio ≥ 1 (the right inequality).**

The self-sub-kernel ceiling `H_K(A_Y^{self}) ≤ H_K(Y)` exponentiates to
`N_K(self) ≤ N_K(Y)`, hence `N_K(Y)/N_K(self) ≥ 1`: the self-reflective
sub-kernel is never *richer* than the parent, so the entropy-power tax is
at least one. -/
theorem Npow_ratio_ge_one (Hself Hy : ℝ) (h_le : Hself ≤ Hy) :
    1 ≤ Npow Hy / Npow Hself := by
  rw [le_div_iff₀ (Npow_pos Hself), one_mul]
  exact Real.exp_le_exp.mpr h_le

/-- **R.703 — self-reference entropy-power ratio lower bound (core).**

Given

* the entropy ordering `Hself ≤ Hy` (SP / R.701), and
* the strengthened R.86 bound `Z·(N_K(Y)/N_K(self)) ≤ Z_self` (`hZ86`)

with `0 < Z`, the impedance ratio is bounded below by the entropy-power
tax, which is itself at least one:

    Z_self / Z  ≥  N_K(Y)/N_K(self)  ≥  1. -/
theorem R_703_self_entropy_ratio
    (Hself Hy Z Zself : ℝ)
    (hZ : 0 < Z)
    (h_le : Hself ≤ Hy)
    (hZ86 : Z * (Npow Hy / Npow Hself) ≤ Zself) :
    Npow Hy / Npow Hself ≤ Zself / Z ∧ 1 ≤ Npow Hy / Npow Hself := by
  refine ⟨?_, Npow_ratio_ge_one Hself Hy h_le⟩
  rw [le_div_iff₀ hZ, mul_comm]
  exact hZ86

/-- **R.703 — chained ratio consequence `Z_self ≥ Z`.**

The two inequalities compose: the impedance ratio `Z_self/Z` is at least
the entropy-power tax `N_K(Y)/N_K(self) ≥ 1`, hence `Z_self ≥ Z`.  This is
the qualitative R.86 (`Z_self ≥ Z_external`) recovered as a corollary of
the sharpened ratio bound. -/
theorem R_703_Zself_ge_Z
    (Hself Hy Z Zself : ℝ)
    (hZ : 0 < Z)
    (h_le : Hself ≤ Hy)
    (hZ86 : Z * (Npow Hy / Npow Hself) ≤ Zself) :
    Z ≤ Zself := by
  obtain ⟨hratio, hge1⟩ := R_703_self_entropy_ratio Hself Hy Z Zself hZ h_le hZ86
  have h1 : (1 : ℝ) ≤ Zself / Z := le_trans hge1 hratio
  rw [le_div_iff₀ hZ, one_mul] at h1
  exact h1

end EntropyPowerTail

end MIP
