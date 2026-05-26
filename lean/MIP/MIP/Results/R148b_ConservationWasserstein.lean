/-
Result R.148.a — Wasserstein restatement of the R.132 conservation law.

Reference: `workspace/asym_wasserstein_bridge.md` §3 R.148.a and §6
("R.132 的 Wasserstein 重述（最终形式）", 2026-05-16).

**Statement.** Combining

* **R.132** (role-conservation, Ohm regime):
      `N + N*  =  2·N_bi + Asym`,
* **R.148** (formal bridge):
      `Asym  =  W_1^{d_AH}(μ_A^aux, μ_H^aux)`,

the conservation law acquires an optimal-transport restatement

    N + N*  =  2·N_bi  +  W_1^{d_AH}(μ_A^aux, μ_H^aux) .

Interpretation (§6): the total cost of the two one-directional strategies
`N + N*` splits into an *incompressible* bidirectional-optimal part
`2·N_bi` (no Wasserstein interpretation: it comes from `min(u,v)`, not from
an `inf` over couplings) plus a *compressible* part — the Wasserstein
asymmetry tax `W_1^{d_AH}`, the minimal transport distance between the two
agents' cost distributions.

We additionally record the **Type-S degeneracy** (§6 (iii)):
`W_1^{d_AH} = 0` iff `N + N* = 2·N_bi` (the auxiliary cost distributions
coincide), i.e. symmetric collaboration.

**Bundled facts.** R.132 (an algebraic identity, Ohm regime) and R.148
(the `Asym = W_1` bridge proved in `R148_AsymWassersteinBridge.lean`) enter
as explicit real-valued hypotheses. The proof is pure substitution.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace ConservationWasserstein

/-- **R.148.a — Wasserstein restatement of R.132.**

Given the R.132 conservation identity `N + N* = 2·N_bi + Asym` and the
R.148 bridge `Asym = W1` (with `W1 := W_1^{d_AH}(μ_A^aux, μ_H^aux)`), the
conservation law becomes

    N + N*  =  2·N_bi + W1.

Pure substitution. -/
theorem R_148a_conservation_W1
    (N N_star N_bi Asym W1 : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1) :
    N + N_star = 2 * N_bi + W1 := by
  rw [h_R132, h_R148]

/-- **R.148.a — Wasserstein asymmetry tax (solved form).**

The "symmetry-breaking tax" is exactly the Wasserstein distance:

    W1  =  (N + N*) − 2·N_bi. -/
theorem R_148a_tax_eq_W1
    (N N_star N_bi Asym W1 : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1) :
    W1 = (N + N_star) - 2 * N_bi := by
  rw [← h_R148]; linarith

/-- **R.148.a — Type-S degeneracy** (§6 (iii)).

The Wasserstein tax vanishes iff the total one-directional cost equals
twice the bidirectional optimum:

    W1 = 0  ↔  N + N* = 2·N_bi.

This is the symmetric-collaboration case (`μ_A^aux = μ_H^aux`), where the
two agents' auxiliary cost distributions coincide. -/
theorem R_148a_typeS_iff
    (N N_star N_bi Asym W1 : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1) :
    W1 = 0 ↔ N + N_star = 2 * N_bi := by
  constructor
  · intro hW0
    rw [h_R132, h_R148, hW0]; ring
  · intro hNN
    have : Asym = 0 := by rw [h_R132] at hNN; linarith
    rw [← h_R148, this]

/-- **R.148.a — nonnegativity of the Wasserstein tax.**

Since `W1 = Asym` and `Asym ≥ 0` (a Wasserstein distance / weighted-L1 is
nonnegative — R.148.a pseudometric nonnegativity), the symmetry-breaking
tax is nonnegative, giving the R.142 bound `2·N_bi ≤ N + N*`. -/
theorem R_148a_tax_nonneg
    (N N_star N_bi Asym W1 : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1)
    (h_Asym_nonneg : 0 ≤ Asym) :
    0 ≤ W1 ∧ 2 * N_bi ≤ N + N_star := by
  refine ⟨h_R148 ▸ h_Asym_nonneg, ?_⟩
  linarith

end ConservationWasserstein

end MIP
