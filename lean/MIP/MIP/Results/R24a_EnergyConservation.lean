/-
Result R.24a — Energy conservation along the optimal trajectory.

Reference: `proofs/derived/A_grade.md` R.24a (A 部分 — Ohm law +
energy conservation strict; temperature-entropy stays B).

**Statement (energy conservation).** Along the optimal sequence of
interventions `m_1, …, m_n` solving `p` with `Φ(s_0) = Φ₀` and
`Φ(s_n) = 0`, the per-step potential drops sum to the initial
potential:

    Σ_{i=1}^n (Φ(s_{i-1}) − Φ(s_i))  =  Φ(s_0) − Φ(s_n)  =  Φ₀ .

This is the "energy is conserved" statement of the thermodynamic
analogy: total work done across all interventions equals the initial
potential energy.

**Pure-math content.** Telescoping sum identity:

    Σ_{i=1}^n (f(i-1) − f(i))  =  f(0) − f(n)

for any function `f : ℕ → ℝ`.

This file proves the **telescoping kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace EnergyConservation

open scoped BigOperators

/-- **Telescoping sum identity (R.24a kernel).**

For `f : ℕ → ℝ` and `n : ℕ`,

    Σ_{i ∈ Finset.range n} (f i − f (i+1))  =  f 0 − f n . -/
theorem telescoping_sum (f : ℕ → ℝ) (n : ℕ) :
    ∑ i ∈ Finset.range n, (f i - f (i + 1)) = f 0 - f n := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ]
    rw [ih]
    ring

/-- **R.24a — energy conservation along solution path.**

If a sequence of states `s : ℕ → State` has potentials `Φ ∘ s` with
`Φ(s 0) = Φ₀` and `Φ(s n) = 0`, then the sum of per-step potential
drops equals `Φ₀`. -/
theorem R_24a_energy_conservation
    (Φ : ℕ → ℝ) (n : ℕ)
    (h_final : Φ n = 0) :
    ∑ i ∈ Finset.range n, (Φ i - Φ (i + 1)) = Φ 0 := by
  rw [telescoping_sum Φ n, h_final, sub_zero]

/-- **R.24a — Ohm-law form (energy / impedance product).**

When the trajectory has a uniform per-step "voltage drop"
`ΔΦ_avg := Φ₀ / N`, the total path "work" `N · ΔΦ_avg = Φ₀` — the
analog of `V = I · R` (which is T.8 itself, with N = Φ₀ · Z giving
ΔΦ_avg = 1/Z, hence N · ΔΦ_avg = Φ₀ identically).  Stated as a pure
algebra identity. -/
theorem R_24a_ohm_form
    (Phi0 N Z : ℝ) (h_T8 : N = Phi0 * Z)
    (h_Z_ne : Z ≠ 0) :
    N / Z = Phi0 := by
  rw [h_T8, mul_div_assoc, div_self h_Z_ne, mul_one]

end EnergyConservation

end MIP
