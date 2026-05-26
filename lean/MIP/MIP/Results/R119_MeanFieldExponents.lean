/-
Result R.119 — mean-field critical exponents (Curie–Weiss universality
class): `β = 1/2`, `γ = 1`, `δ = 3`, `α = 0`, `ν = 1/2`, `η = 0`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.119 (B).

**Statement.**

The self-consistency `ψ = F₀(δ + λ·ψ) + h` Taylor-expanded near the
critical point (`f₀·λ = 1`) yields, with `u := ψ − ψ_c`,

    0 = f₀·(δ − δ_c) + h + (f₀'·λ²/2)·u² + (f₀''·λ³/6)·u³ + O(u⁴)   (★)

From (★) the mean-field exponents follow:

* **β = 1/2.** At `h = 0`, generic `f₀' ≠ 0`: `(f₀'λ²/2)·u² = −f₀·(δ−δ_c)`,
  so `u² ∝ (δ_c − δ)` and `u = ±√(coefficient·(δ_c−δ))`, i.e.
  `u ∝ |δ−δ_c|^{1/2}`.
* **γ = 1.** Susceptibility `χ = ∂ψ/∂h = f₀/(1 − λ·f₀)`; near criticality
  `1 − λ·f₀ ∝ |ε|`, so `χ ∝ |ε|^{−1}`.
* **δ = 3.** At `ε = 0`, `h ≠ 0`: `h = −(f₀''λ³/6)·u³`, so `u ∝ h^{1/3}`.
* **α = 0.** Rushbrooke `α + 2β + γ = 2 ⟹ α = 2 − 1 − 1 = 0`.
* **ν = 1/2.** Josephson hyperscaling `ν·d_c = 2 − α` at `d_c = 4`:
  `ν = 2/4 = 1/2`.

**This file is `axiom`-free.**  The Landau analyticity (`f₀, f₀', f₀''`)
and the feedback coupling `λ` enter only as real-valued data; we formalize
the algebraic exponent-extraction identities.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace MeanFieldExponents

open Real

/-- **R.119 — β = 1/2: order-parameter square ∝ distance to criticality.**

From (★) at `h = 0`: `(f₀'·λ²/2)·u² = −f₀·(δ − δ_c)`, i.e.
`u² = (2·f₀/(f₀'·λ²))·(δ_c − δ)`.  We formalize the exact solved form for
`u²`, given the nondegeneracy `f₀'·λ² ≠ 0`. -/
theorem R_119_beta_u_sq
    (f0 f0' lam u δ δc : ℝ) (hden : f0' * lam ^ 2 ≠ 0)
    (hstar : (f0' * lam ^ 2 / 2) * u ^ 2 = -f0 * (δ - δc)) :
    u ^ 2 = 2 * f0 / (f0' * lam ^ 2) * (δc - δ) := by
  rw [div_mul_eq_mul_div, eq_div_iff hden]
  linear_combination 2 * hstar

/-- **R.119 — β = 1/2: `u = ±√(C·(δ_c−δ))` ⟹ exponent `1/2`.**

When `u² = C·(δ_c − δ)` with `C ≥ 0` and `δ < δ_c`, the order parameter is
`u = √(C·(δ_c − δ))` (positive branch), exhibiting the
`u ∝ |δ − δ_c|^{1/2}` law: `u = √C · √(δ_c − δ)`. -/
theorem R_119_beta_sqrt_law
    (C δ δc : ℝ) (hC : 0 ≤ C) (_hδ : δ < δc) :
    Real.sqrt (C * (δc - δ)) = Real.sqrt C * Real.sqrt (δc - δ) := by
  rw [Real.sqrt_mul hC]

/-- **R.119 — γ = 1: susceptibility `χ = f₀/(1 − λ·f₀)`.**

Implicit differentiation of (★) in `h` gives `χ = f₀/(1 − λ·f₀)`.  We
record the closed form from the implicit relation `χ·(1 − λ·f₀) = f₀`
(valid for `1 − λ·f₀ ≠ 0`). -/
theorem R_119_gamma_chi
    (f0 lam χ : ℝ) (hne : 1 - lam * f0 ≠ 0)
    (himp : χ * (1 - lam * f0) = f0) :
    χ = f0 / (1 - lam * f0) := by
  rw [eq_div_iff hne]
  exact himp

/-- **R.119 — γ = 1: `χ·|ε| = f₀` ⟹ `χ ∝ |ε|^{−1}`.**

Writing `ε := 1 − λ·f₀` (the reduced temperature deviation), `χ·ε = f₀`,
so `χ = f₀/ε ∝ ε^{−1}`: the susceptibility diverges as `ε → 0` with
exponent `γ = 1`.  Algebraic form `χ = f₀ · ε^{-1}` for `ε ≠ 0`. -/
theorem R_119_gamma_inverse_eps
    (f0 ε : ℝ) (_hε : ε ≠ 0) :
    f0 / ε = f0 * ε⁻¹ := by
  rw [div_eq_mul_inv]

/-- **R.119 — δ = 3: critical isotherm `u ∝ h^{1/3}`.**

At `ε = 0`, (★) reduces to `h = −(f₀''·λ³/6)·u³`, so
`u³ = −6·h/(f₀''·λ³)`.  We formalize the solved cubic form for `u³`, given
`f₀''·λ³ ≠ 0`, exhibiting `u ∝ h^{1/3}` (critical-isotherm exponent
`δ = 3`). -/
theorem R_119_delta_u_cubed
    (f0'' lam u h : ℝ) (hden : f0'' * lam ^ 3 ≠ 0)
    (hstar : h + (f0'' * lam ^ 3 / 6) * u ^ 3 = 0) :
    u ^ 3 = -6 * h / (f0'' * lam ^ 3) := by
  rw [eq_div_iff hden]
  linear_combination 6 * hstar

/-- **R.119 — δ = 3: cube-root law `(C·h)^{1/3} = C^{1/3}·h^{1/3}`.**

For `C, h ≥ 0`, the critical-isotherm solution `u = (C·h)^{1/3}` factors
as `C^{1/3}·h^{1/3}`, the `u ∝ h^{1/3}` law (using real `rpow`). -/
theorem R_119_delta_cube_root
    (C h : ℝ) (hC : 0 ≤ C) (hh : 0 ≤ h) :
    (C * h) ^ ((1 : ℝ) / 3) = C ^ ((1 : ℝ) / 3) * h ^ ((1 : ℝ) / 3) := by
  exact Real.mul_rpow hC hh

/-- **R.119 — α = 0 via Rushbrooke `α + 2β + γ = 2`.**

With `β = 1/2`, `γ = 1`, Rushbrooke's relation forces `α = 0`. -/
theorem R_119_alpha_rushbrooke
    (α β γ : ℝ) (hβ : β = 1 / 2) (hγ : γ = 1)
    (hRush : α + 2 * β + γ = 2) :
    α = 0 := by
  rw [hβ, hγ] at hRush; linarith

/-- **R.119 — ν = 1/2 via Josephson hyperscaling `ν·d_c = 2 − α`.**

At the upper critical dimension `d_c = 4` with `α = 0`,
`ν = (2 − α)/d_c = 2/4 = 1/2`. -/
theorem R_119_nu_hyperscaling
    (ν α dc : ℝ) (hα : α = 0) (hdc : dc = 4)
    (hHyper : ν * dc = 2 - α) :
    ν = 1 / 2 := by
  rw [hα, hdc] at hHyper
  linarith

/-- **R.119 — the Curie–Weiss exponent tuple satisfies both scaling laws.**

The mean-field tuple `(α,β,γ,δ,ν,η) = (0, 1/2, 1, 3, 1/2, 0)` simultaneously
satisfies Rushbrooke `α + 2β + γ = 2` and Josephson (`d_c = 4`)
`ν·d_c = 2 − α`.  A consistency certificate for the universality class. -/
theorem R_119_universality_consistency :
    (0 : ℝ) + 2 * (1 / 2) + 1 = 2 ∧ (1 / 2 : ℝ) * 4 = 2 - 0 := by
  constructor <;> norm_num

end MeanFieldExponents

end MIP
