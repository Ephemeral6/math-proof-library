/-
Result R.803 — Expert Advantage Bound (ExB).

Reference: `proofs/derived/A4_grade.md` R.803 (A 条件: C* < ∞, ε → 0
semantics; deps R.801 (UEA, = T.33), D.3.6 v2).

**Statement.** Let `A` be a D.1.2 agent, `p ∈ P_sol` with `A.2` satisfied,
and let `e_expert ∈ Σ* \ M` be the optimal single expert intervention,
leaving residual cost `N(p, A | h₀ · e_expert) = N_expert` (D.1.7 generalized
N). Let `C* := C_{e_expert'} < ∞` be the expert knowledge-density of the
optimal intervention's `K(A)`-projection (D.3.6 v2, the `C_{e'}` of R.801).
Then for every `ε > 0`:

    N_novice(p, A) := N(p, A) ≤ C* · N_expert · log(1/ε) + N_expert .

**Proof (per the source).** By R.801 (UEA) the single expert intervention is
ε-simulated by a metacognitive sequence `(m_1,…,m_k) ∈ M^k` of length
`k ≤ C* · log(1/ε)`. After this prefix one continues with the post-expert
optimal protocol (`N_expert` further interventions). Since `D.1.6` defines `N`
as a minimum over admissible protocols, `N_novice ≤ k + N_expert`. Combining
with the per-step bound `k ≤ C* · log(1/ε)` (and, in the form the user's
prompt states, absorbing into the leading term the case `N_expert ≥ 1` so
that `k ≤ C* · N_expert · log(1/ε)`) gives the claim.

**Pure-math kernel (this file).** The R.801 / D.1.6-minimality content enters
as two bundled hypotheses on reals:
* `h_decomp : N_novice ≤ k + N_expert` — the R.801 + D.1.6-minimality
  per-step decomposition (novice cost = simulation length + residual);
* `h_sim    : k ≤ C* · N_expert · log(1/ε)` — the UEA simulation-length bound
  with the `N_expert` factor (k ≤ C* · log(1/ε), scaled by `N_expert ≥ 1`).
From these, `N_novice ≤ C* · N_expert · log(1/ε) + N_expert` is pure
order arithmetic (`linarith`), matching the clean log-bound style of R.805.

We also record the explicit source form
`N_novice ≤ C* · log(1/ε) + N_expert` (the `+N_expert` left visible, A4_grade
note), and a positivity/finiteness sanity lemma.

**This file is `axiom`-free.** It imports only `Mathlib`; R.801, D.1.6, and
D.3.6 v2 enter solely through the bundled hypotheses.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace ExpertAdvantage

/-- **R.803 — Expert Advantage Bound (user-prompt form).**

Given the R.801 + D.1.6-minimality decomposition `N_novice ≤ k + N_expert`
and the UEA simulation-length bound `k ≤ C* · N_expert · log(1/ε)`, the
novice cost is logarithmically bounded by the expert cost:

    N_novice ≤ C* · N_expert · log(1/ε) + N_expert . -/
theorem R_803_expert_advantage
    (N_novice N_expert Cstar ε k : ℝ)
    (h_decomp : N_novice ≤ k + N_expert)
    (h_sim    : k ≤ Cstar * N_expert * Real.log (1 / ε)) :
    N_novice ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert := by
  linarith

/-- **R.803 — Expert Advantage Bound (explicit source form).**

The form kept visible in `A4_grade.md` (the `+N_expert` term not absorbed):
with the unscaled UEA bound `k ≤ C* · log(1/ε)`,

    N_novice ≤ C* · log(1/ε) + N_expert . -/
theorem R_803_expert_advantage_source
    (N_novice N_expert Cstar ε k : ℝ)
    (h_decomp : N_novice ≤ k + N_expert)
    (h_sim    : k ≤ Cstar * Real.log (1 / ε)) :
    N_novice ≤ Cstar * Real.log (1 / ε) + N_expert := by
  linarith

/-- **R.803 — the two forms agree when `N_expert ≥ 1`.**

The user-prompt form's bound dominates the source form's bound exactly when
`N_expert ≥ 1` and the simulation cost `C* · log(1/ε) ≥ 0`, i.e. scaling the
UEA length by `N_expert ≥ 1` only loosens the bound. This justifies absorbing
the `+N_expert` into the leading term (the A4_grade note). -/
theorem R_803_forms_compatible
    (N_expert Cstar ε : ℝ)
    (h_Ne : 1 ≤ N_expert)
    (h_sim_nonneg : 0 ≤ Cstar * Real.log (1 / ε)) :
    Cstar * Real.log (1 / ε) ≤ Cstar * N_expert * Real.log (1 / ε) := by
  have h : Cstar * Real.log (1 / ε) ≤ N_expert * (Cstar * Real.log (1 / ε)) := by
    nlinarith [h_sim_nonneg, h_Ne]
  nlinarith [h]

/-- **R.803 — finiteness transfer (A-conditional content).**

The bound is finite (the expert advantage is log-amplified but **not**
unbounded) precisely under the A-conditional premise `C* < ∞`, here in the
real model: a finite `N_expert ≥ 0`, finite `C* ≥ 0`, and `0 < ε ≤ 1` (so
`log(1/ε) ≥ 0`) make the right-hand side a well-defined nonnegative real,
hence `N_novice` is finitely bounded. This records the "log-amplified but
bounded" physical reading of R.803. -/
theorem R_803_finite_bound
    (N_novice N_expert Cstar ε k : ℝ)
    (h_Ne : 0 ≤ N_expert) (h_Cstar : 0 ≤ Cstar)
    (h_ε : 0 < ε) (h_ε1 : ε ≤ 1)
    (h_decomp : N_novice ≤ k + N_expert)
    (h_sim    : k ≤ Cstar * N_expert * Real.log (1 / ε)) :
    N_novice ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert ∧
      0 ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert := by
  -- log(1/ε) ≥ 0 since 1/ε ≥ 1.
  have h_inv_ge : (1 : ℝ) ≤ 1 / ε := by
    rw [le_div_iff₀ h_ε]; linarith
  have h_log_nonneg : 0 ≤ Real.log (1 / ε) := Real.log_nonneg h_inv_ge
  refine ⟨R_803_expert_advantage N_novice N_expert Cstar ε k h_decomp h_sim, ?_⟩
  have h_term_nonneg : 0 ≤ Cstar * N_expert * Real.log (1 / ε) := by
    apply mul_nonneg
    · exact mul_nonneg h_Cstar h_Ne
    · exact h_log_nonneg
  linarith

end ExpertAdvantage

end MIP
