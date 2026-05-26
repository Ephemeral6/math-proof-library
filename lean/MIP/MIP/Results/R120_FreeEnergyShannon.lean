/-
Result R.120 — emergent free energy `F = E − T·S_κ` with the Shannon
entropy `S_κ = −κ·log κ − (1−κ)·log(1−κ)`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.120 (B,
domain `κ ∈ (0, 1/2)`).

**Statement.**

With Noether energy `E = ⟨(Z/2)Φ̇²⟩ + ⟨V⟩`, kinetic temperature
`T = T_kin = Z·⟨Φ̇²⟩` (equipartition `⟨(Z/2)Φ̇²⟩ = T/2`), and Shannon
entropy `S_κ`, the Helmholtz free energy is

    F := E − T·S_κ = ⟨V⟩ + (T/2) − T·S_κ = ⟨V⟩ + T·(1/2 − S_κ)   (★★)

We formalize:

* (a) **Free-energy identity** `F = ⟨V⟩ + T·(1/2 − S_κ)` from
  `E = T/2 + ⟨V⟩`.
* (b) **Equilibrium = EL fixed point.** The Landau potential
  `Vpot ψ = (a/2)ψ² + (b/4)ψ⁴` has `V'(ψ) = aψ + bψ³`; minimising `F` over
  `Φ` at fixed `T` gives `V'(Φ_eq) = 0` (the static EL solution).
* (c) **Low-`T` limit.** `T → 0 ⟹ F → ⟨V⟩`: the entropy term vanishes and
  `F` is governed by the potential minimum (the grokked steady state).
* (d) **First law** `dE = T·dS_κ + dW`, `dW := ⟨V'·dΦ⟩`: trivially
  `dE = T·dS + dW` rearranges to `dW = dE − T·dS`.

**This file is `axiom`-free.**  The physics (equipartition, ensemble
average `⟨·⟩`, the `κ ∈ (0,1/2)` H-theorem domain) enters only as
real-valued data; we formalize the algebraic free-energy identity, the
`HasDerivAt` of the Landau potential, and the limit/first-law rearrangements.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace FreeEnergyShannon

open Real

/-- **Shannon entropy of the closure fraction** `κ`:
`S_κ = −κ·log κ − (1−κ)·log(1−κ)` (R.105 / R.120). -/
noncomputable def Skappa (κ : ℝ) : ℝ :=
  -κ * Real.log κ - (1 - κ) * Real.log (1 - κ)

/-- **Helmholtz free energy** `F = E − T·S_κ` (R.120). -/
noncomputable def F (E T Sk : ℝ) : ℝ := E - T * Sk

/-- **The Landau potential** `Vpot ψ = (a/2)ψ² + (b/4)ψ⁴`. -/
noncomputable def Vpot (a b ψ : ℝ) : ℝ := (a / 2) * ψ ^ 2 + (b / 4) * ψ ^ 4

/-- **R.120.a — free-energy identity `F = ⟨V⟩ + T·(1/2 − S_κ)`** (★★).

With `E = T/2 + ⟨V⟩` (equipartition), `F = E − T·S_κ` rewrites as
`⟨V⟩ + T·(1/2 − S_κ)`. -/
theorem R_120_a_F_identity
    (Vavg T Sk E : ℝ) (hE : E = T / 2 + Vavg) :
    F E T Sk = Vavg + T * (1 / 2 - Sk) := by
  unfold F
  rw [hE]; ring

/-- **R.120.b — derivative of the Landau potential.**

`Vpot ψ = (a/2)ψ² + (b/4)ψ⁴` has derivative `V'(ψ) = a·ψ + b·ψ³`.  Since
the entropy term `T·(1/2 − S_κ)` is `Φ`-independent, `∂F/∂Φ|_T = V'(Φ)`,
so minimising `F` at fixed `T` is exactly `V'(Φ_eq) = 0`. -/
theorem R_120_b_hasDerivAt_Vpot (a b ψ : ℝ) :
    HasDerivAt (Vpot a b) (a * ψ + b * ψ ^ 3) ψ := by
  have h2 : HasDerivAt (fun x : ℝ => (a / 2) * x ^ 2)
      ((a / 2) * (2 * ψ ^ 1)) ψ := (hasDerivAt_pow 2 ψ).const_mul (a / 2)
  have h4 : HasDerivAt (fun x : ℝ => (b / 4) * x ^ 4)
      ((b / 4) * (4 * ψ ^ 3)) ψ := (hasDerivAt_pow 4 ψ).const_mul (b / 4)
  have hsum := h2.add h4
  unfold Vpot
  convert hsum using 1
  ring

/-- **R.120.b — equilibrium is the static EL fixed point.**

The Landau equilibrium `V'(Φ_eq) = 0` admits the trivial solution
`Φ_eq = 0` for any `a, b`. -/
theorem R_120_b_equilibrium_zero (a b : ℝ) :
    a * (0 : ℝ) + b * (0 : ℝ) ^ 3 = 0 := by ring

/-- **R.120.c — low-temperature limit `F → ⟨V⟩` as `T → 0`.**

At `T = 0` the entropy term vanishes and the free energy equals the
potential energy `⟨V⟩` (using `E = T/2 + ⟨V⟩`, so `E = ⟨V⟩` at `T = 0`):
`F = ⟨V⟩`. -/
theorem R_120_c_low_T_limit (Vavg Sk E : ℝ) (hE : E = (0 : ℝ) / 2 + Vavg) :
    F E 0 Sk = Vavg := by
  unfold F
  rw [hE]; ring

/-- **R.120.d — first law (emergent), rearrangement.**

`dE = T·dS_κ + dW` with `dW = ⟨V'·dΦ⟩` is equivalent to
`dW = dE − T·dS_κ`: energy change = heat (entropy flow) + emergence work.
We record the algebraic equivalence. -/
theorem R_120_d_first_law (dE T dS dW : ℝ) :
    (dE = T * dS + dW) ↔ (dW = dE - T * dS) := by
  constructor <;> intro h <;> linarith

/-- **R.120 — Shannon entropy is symmetric about `κ = 1/2`.**

`S_κ(κ) = S_κ(1 − κ)`: the Shannon entropy is symmetric, peaking at
`κ = 1/2` (maximal uncertainty), an algebraic property used in the
high-`T` (max-entropy `κ ≈ 1/2`) regime. -/
theorem R_120_Skappa_symmetric (κ : ℝ) :
    Skappa κ = Skappa (1 - κ) := by
  unfold Skappa
  have h : (1 : ℝ) - (1 - κ) = κ := by ring
  rw [h]
  ring

end FreeEnergyShannon

end MIP
