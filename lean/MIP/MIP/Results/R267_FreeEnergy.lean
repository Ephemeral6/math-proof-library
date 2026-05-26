/-
Result R.267 — Helmholtz free energy `F̃ = ⟨V⟩ − T_kin·log Z_part`
and the Landau-potential extremization at equilibrium.

Reference: `branches/thermodynamics/workspace/new_results.md` R.267
(A 条件 D.4.16 TM family).

**Statement.**

The MIP canonical-ensemble free energy (R.267 (♠''')) is

    F̃ = ⟨V⟩ − T_kin · log Z_part ,        Z_part := κ · |K|²  = N_comp ,

with `Z_part` the emergent partition function (= reachable-composition-pair
count `N_comp = e^{S_B}`).  Equivalently the full free energy adds the
equipartition zero-point kinetic energy `T_kin/2`:

    F = F̃ + T_kin/2 = E − T_kin · log Z_part .

The equilibrium order parameter is the stationary point of the Landau
potential (R.119 / R.269)

    Vpot ψ = (a/2)·ψ² + (b/4)·ψ⁴ ,

whose derivative is `V'(ψ) = a·ψ + b·ψ³`.  Stationarity `V'(ψ) = 0` gives
`ψ = 0` always, and for `a < 0`, `b > 0` the nonzero equilibrium
`ψ² = -a/b` (i.e. `a·ψ + b·ψ³ = 0`).

**This file is `axiom`-free.**  The physics inputs (partition-function
form `Z_part = κ·|K|²`, Landau coefficients `a, b`, equipartition
`⟨(Z/2)Φ̇²⟩ = T_kin/2`) enter only as explicit real-valued data; we
formalize the resulting real-number identities and the `HasDerivAt`
derivative of the Landau potential.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

namespace MIP

namespace FreeEnergy

open Real

/-- **Canonical free energy `F̃ = ⟨V⟩ − T_kin·log Z_part`** (R.267 (♠''')).

`Vavg = ⟨V(Φ)⟩` is the ensemble-averaged residual potential, `T = T_kin`
the kinetic temperature, `Zpart = κ·|K|²` the emergent partition
function. -/
noncomputable def F (Vavg T Zpart : ℝ) : ℝ :=
  Vavg - T * Real.log Zpart

/-- **The Landau potential** `Vpot ψ = (a/2)ψ² + (b/4)ψ⁴`.  -/
noncomputable def Vpot (a b ψ : ℝ) : ℝ :=
  (a / 2) * ψ ^ 2 + (b / 4) * ψ ^ 4

/-- **R.267 — partition-function reading of the free energy.**

With `Zpart = κ·|K|²` the free energy `F̃` reads
`F̃ = ⟨V⟩ − T·(log κ + 2·log|K|)`, i.e. `log Z_part = log κ + 2·log|K|`
(this is `S_B`, R.122).  Requires `κ > 0`, `|K| > 0`. -/
theorem R_267_logZpart_split
    (Vavg T κ Kabs : ℝ) (hκ : 0 < κ) (hK : 0 < Kabs) :
    F Vavg T (κ * Kabs ^ 2)
      = Vavg - T * (Real.log κ + 2 * Real.log Kabs) := by
  unfold F
  have hK2 : (0 : ℝ) < Kabs ^ 2 := by positivity
  rw [Real.log_mul (ne_of_gt hκ) (ne_of_gt hK2),
      Real.log_pow]
  push_cast
  ring

/-- **R.267 — full free energy vs canonical free energy** (R.267 (♠'')).

`F = E − T·log Z_part` with `E = T/2 + ⟨V⟩` (equipartition E.1) equals
`F̃ + T/2`.  Algebraic identity given `E = T/2 + Vavg`. -/
theorem R_267_F_full_eq_canonical_plus_kinetic
    (Vavg T Zpart E : ℝ) (hE : E = T / 2 + Vavg) :
    E - T * Real.log Zpart = F Vavg T Zpart + T / 2 := by
  unfold F
  rw [hE]; ring

/-- **R.267 — `S_B = −∂F̃/∂T` Maxwell relation, algebraic form** (R.267 (♣)).

For the canonical `F̃ = ⟨V⟩ − T·log Z_part`, differentiating in `T` at
fixed `⟨V⟩` and `Z_part` gives `∂F̃/∂T = −log Z_part = −S_B`.  We state
this as the `HasDerivAt` identity in the temperature variable. -/
theorem R_267_dFdT_eq_neglogZpart
    (Vavg Zpart T : ℝ) :
    HasDerivAt (fun s => F Vavg s Zpart) (-(Real.log Zpart)) T := by
  -- F̃(s) = Vavg − s·log Zpart, linear in s.
  have h1 : HasDerivAt (fun s : ℝ => s * Real.log Zpart)
      (Real.log Zpart) T := by
    simpa using (hasDerivAt_id T).mul_const (Real.log Zpart)
  have h2 : HasDerivAt (fun s : ℝ => Vavg - s * Real.log Zpart)
      (0 - Real.log Zpart) T := (hasDerivAt_const T Vavg).sub h1
  simpa [F, sub_eq_add_neg] using h2

/-- **R.267 — derivative of the Landau potential.**

`Vpot ψ = (a/2)ψ² + (b/4)ψ⁴` has derivative `V'(ψ) = a·ψ + b·ψ³`. -/
theorem R_267_hasDerivAt_Vpot (a b ψ : ℝ) :
    HasDerivAt (Vpot a b) (a * ψ + b * ψ ^ 3) ψ := by
  have h2 : HasDerivAt (fun x : ℝ => (a / 2) * x ^ 2)
      ((a / 2) * (2 * ψ ^ 1)) ψ :=
    (hasDerivAt_pow 2 ψ).const_mul (a / 2)
  have h4 : HasDerivAt (fun x : ℝ => (b / 4) * x ^ 4)
      ((b / 4) * (4 * ψ ^ 3)) ψ :=
    (hasDerivAt_pow 4 ψ).const_mul (b / 4)
  have hsum := h2.add h4
  unfold Vpot
  convert hsum using 1
  ring

/-- **R.267 — `ψ = 0` is always stationary.**

`V'(0) = 0` for any Landau coefficients `a, b`. -/
theorem R_267_zero_stationary (a b : ℝ) :
    a * (0 : ℝ) + b * (0 : ℝ) ^ 3 = 0 := by
  ring

/-- **R.267 — nonzero equilibrium for `a < 0`.**

For `a < 0`, `b > 0`, the value `ψ² = -a/b > 0` is a real stationary point:
`a·ψ + b·ψ³ = 0` whenever `ψ² = -a/b` and `ψ ≠ 0`.  (This is the ordered
phase `ψ_eq² = -a/b` of R.119/R.269.) -/
theorem R_267_ordered_stationary
    (a b ψ : ℝ) (hb : 0 < b) (hsq : ψ ^ 2 = -a / b) :
    a * ψ + b * ψ ^ 3 = 0 := by
  have hb' : b ≠ 0 := ne_of_gt hb
  -- a·ψ + b·ψ³ = ψ·(a + b·ψ²); substitute ψ² = -a/b ⇒ a + b·(-a/b) = 0.
  have : a + b * ψ ^ 2 = 0 := by
    rw [hsq]; field_simp; ring
  calc a * ψ + b * ψ ^ 3
      = ψ * (a + b * ψ ^ 2) := by ring
    _ = ψ * 0 := by rw [this]
    _ = 0 := by ring

/-- **R.267 — existence of the ordered equilibrium for `a < 0 < b`.**

For `a < 0` and `b > 0` there exists `ψ ≠ 0` with `ψ² = -a/b` and
`V'(ψ) = 0`.  Witness `ψ = √(-a/b)`. -/
theorem R_267_ordered_exists
    (a b : ℝ) (ha : a < 0) (hb : 0 < b) :
    ∃ ψ : ℝ, ψ ≠ 0 ∧ ψ ^ 2 = -a / b ∧ a * ψ + b * ψ ^ 3 = 0 := by
  have hpos : 0 < -a / b := div_pos (by linarith) hb
  refine ⟨Real.sqrt (-a / b), ?_, ?_, ?_⟩
  · exact ne_of_gt (Real.sqrt_pos.mpr hpos)
  · rw [Real.sq_sqrt (le_of_lt hpos)]
  · exact R_267_ordered_stationary a b _ hb (Real.sq_sqrt (le_of_lt hpos))

end FreeEnergy

end MIP
