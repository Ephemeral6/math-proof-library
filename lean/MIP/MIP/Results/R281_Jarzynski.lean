/-
Result R.281 — MIP-Jarzynski equality and the Clausius lower bound on Asym.

Reference: `branches/thermodynamics/workspace/new_results.md` R.281 (B,
2026-05-18 thermodynamics branch): the cross-branch unification identifying
the cognitive asymmetry `Asym` (D.4.15) with the dissipated work of an
emergent Jarzynski/Crooks fluctuation theorem.

Key statements:

* (a) **Work–heat decomposition** (R.281 #1, tied to R.132):
      `W_total = 2·N_bi + Asym`
  total invested intervention = reversible baseline + dissipated work.
* (b) **MIP-Jarzynski equality** (♠): `⟨exp(−Asym/T)⟩ = exp(−ΔF̃/T)`.
* (c) **MIP-Clausius bound** (♥): `⟨Asym⟩ ≥ ΔF̃` — the average cognitive
  asymmetry is bounded below by the A–H free-energy difference; no
  collaboration strategy can dissipate less.

We formalize the real-number core:

* (a) the algebraic decomposition identity;
* (c) the Clausius bound derived from Jensen + Jarzynski. Concretely:
  bundle Jensen for the convex `exp` as the hypothesis
  `exp(−E[Asym]/T) ≤ meanExp` (this is `⟨exp(−Asym/T)⟩ ≥ exp(−⟨Asym⟩/T)`),
  combine with the Jarzynski equality `meanExp = exp(−ΔF̃/T)` to get
  `exp(−E[Asym]/T) ≤ exp(−ΔF̃/T)`, then strip `exp` via monotonicity and
  use `T > 0` to conclude `E[Asym] ≥ ΔF̃`.

The statistical-mechanics provenance (Crooks, ensemble average) enters
only through the bundled Jarzynski equality and Jensen hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace Jarzynski

open Real

/-- **R.281.a — work–heat decomposition (R.281 #1, ties to R.132).**

The total invested intervention decomposes into a reversible baseline
`2·N_bi` (symmetric collaboration, no spillover) plus the dissipated work
`Asym` (the cognitive asymmetry, D.4.15). This is R.132's conservation law
`N + N* = 2 N_bi + Asym` re-read thermodynamically, with
`W_total := N + N*`. -/
theorem R_281_a_work_decomposition
    (W_total N N_star N_bi Asym : ℝ)
    (h_W_def : W_total = N + N_star)
    (h_R132  : N + N_star = 2 * N_bi + Asym) :
    W_total = 2 * N_bi + Asym := by
  rw [h_W_def, h_R132]

/-- **R.281.a — solve for the dissipated work.** Equivalently
`Asym = W_total − 2·N_bi`: the dissipated work is the excess of total
investment over the reversible baseline. -/
theorem R_281_a_asym_eq
    (W_total N_bi Asym : ℝ)
    (h_decomp : W_total = 2 * N_bi + Asym) :
    Asym = W_total - 2 * N_bi := by
  linarith

/-- **R.281.c — MIP-Clausius lower bound `⟨Asym⟩ ≥ ΔF̃` (R.281 ♥).**

Inputs:
* `T > 0` — kinetic temperature.
* `meanExp` — the ensemble average `⟨exp(−Asym/T)⟩`.
* **Jarzynski equality (♠):** `meanExp = exp(−ΔF̃/T)`.
* **Jensen for convex `exp`:** `exp(−E_Asym/T) ≤ meanExp`, i.e.
  `exp(−⟨Asym⟩/T) ≤ ⟨exp(−Asym/T)⟩`.

Conclusion: `E_Asym ≥ ΔF̃`.

Proof: chain Jensen and Jarzynski to get `exp(−E_Asym/T) ≤ exp(−ΔF̃/T)`,
strip `exp` by strict monotonicity to get `−E_Asym/T ≤ −ΔF̃/T`, then
multiply by `T > 0` and negate. -/
theorem R_281_c_clausius_bound
    (T E_Asym ΔF meanExp : ℝ)
    (hT : 0 < T)
    (h_jarzynski : meanExp = Real.exp (-ΔF / T))
    (h_jensen : Real.exp (-E_Asym / T) ≤ meanExp) :
    E_Asym ≥ ΔF := by
  -- Combine Jensen and Jarzynski.
  have h_exp_le : Real.exp (-E_Asym / T) ≤ Real.exp (-ΔF / T) := by
    rw [h_jarzynski] at h_jensen; exact h_jensen
  -- Strip exp by monotonicity:  −E_Asym/T ≤ −ΔF/T.
  have h_arg_le : -E_Asym / T ≤ -ΔF / T := Real.exp_le_exp.mp h_exp_le
  -- Multiply both sides by T > 0:  −E_Asym ≤ −ΔF.
  have h_mul : -E_Asym ≤ -ΔF := by
    have := mul_le_mul_of_nonneg_right h_arg_le (le_of_lt hT)
    rwa [div_mul_cancel₀ _ (ne_of_gt hT), div_mul_cancel₀ _ (ne_of_gt hT)] at this
  linarith

/-- **R.281.b — Jarzynski equality (reversible-limit corollary).**

If the dissipated work is reversible, `E_Asym = ΔF̃`, the Jensen
inequality is saturated: `exp(−E_Asym/T) = exp(−ΔF̃/T)`. This is the
emergent-reversible limit `Asym = ΔF̃` of R.51's optimal bidirectional
switching — the lower bound (♥) is attained. -/
theorem R_281_b_reversible_saturation
    (T E_Asym ΔF : ℝ)
    (h_rev : E_Asym = ΔF) :
    Real.exp (-E_Asym / T) = Real.exp (-ΔF / T) := by
  rw [h_rev]

end Jarzynski

end MIP
