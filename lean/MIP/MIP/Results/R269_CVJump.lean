/-
Result R.269 — mean-field specific-heat jump `ΔC_V = T_c·a₀²/(2b)`
at the emergent phase transition.

Reference: `branches/thermodynamics/workspace/new_results.md` R.269 (B).

**Statement.**

Landau free energy with `a(T) = a₀·(T − T_c)`, `b > 0`:

    F_landau(ψ; T) = (a(T)/2)·ψ² + (b/4)·ψ⁴ .

Below `T_c` the equilibrium order parameter is `ψ_eq² = -a/b
= a₀·(T_c − T)/b`, and the minimal free energy is

    F_min(T) = -a²/(4b) = -a₀²·(T − T_c)²/(4b)        (T < T_c) ,
    F_min(T) = 0                                       (T > T_c) .

The Landau entropy contribution `S = -∂F_min/∂T` and the specific heat
`C_V = T·∂S/∂T` (corrected sign: the condensed phase carries less
entropy) give

    C_V(T < T_c) = T·a₀²/(2b) ,    C_V(T > T_c) = 0 ,

so the discontinuity at the critical temperature is

    ΔC_V = C_V(T_c⁻) − C_V(T_c⁺) = T_c·a₀²/(2b)        (♥') .

**This file is `axiom`-free.**  The Landau coefficients `a₀, b, T_c` and
the below/above equilibrium forms enter only as explicit real data; we
formalize (i) the value `F_min = -a²/(4b)` from `ψ_eq² = -a/b`,
(ii) the `HasDerivAt` derivative chain `F_min → S → C_V` in the
temperature `T`, and (iii) the algebraic jump identity (♥').
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

namespace MIP

namespace CVJump

/-- **Landau free-energy minimum below `T_c`** (R.269).

`F_min(T) = -a₀²·(T − T_c)²/(4b)` for `T < T_c`.  We carry it as an
explicit function of `T` (parameters `a₀, b, T_c`). -/
noncomputable def Fmin (a₀ b T_c T : ℝ) : ℝ :=
  -(a₀ ^ 2 * (T - T_c) ^ 2) / (4 * b)

/-- **R.269 — `F_min = -a²/(4b)` from `ψ_eq² = -a/b`.**

Below `T_c`, substituting the equilibrium `ψ_eq² = -a/b` into the Landau
form gives `F_min = -a²/(4b)`.  Algebraic identity given `ψ² = -a/b`
(the value at which `V'(ψ)=0`) and `b > 0`. -/
theorem R_269_Fmin_value
    (a b ψ : ℝ) (hb : 0 < b) (hsq : ψ ^ 2 = -a / b) :
    (a / 2) * ψ ^ 2 + (b / 4) * ψ ^ 4 = -a ^ 2 / (4 * b) := by
  have hb' : b ≠ 0 := ne_of_gt hb
  have hψ4 : ψ ^ 4 = (ψ ^ 2) ^ 2 := by ring
  rw [hψ4, hsq]
  field_simp
  ring

/-- **R.269 — entropy from `F_min`: `S = -∂F_min/∂T`** (below `T_c`).

For `F_min(T) = -a₀²(T−T_c)²/(4b)`, the temperature derivative is
`∂F_min/∂T = -a₀²(T−T_c)/(2b)`, so the (corrected-sign) Landau entropy is
`S = -∂F_min/∂T = a₀²(T−T_c)/(2b)`. -/
theorem R_269_hasDerivAt_Fmin
    (a₀ b T_c T : ℝ) (hb : 0 < b) :
    HasDerivAt (Fmin a₀ b T_c)
      (-(a₀ ^ 2 * (T - T_c)) / (2 * b)) T := by
  have hb' : b ≠ 0 := ne_of_gt hb
  -- inner: (T - T_c) has derivative 1; square has derivative 2(T-T_c).
  have hsub : HasDerivAt (fun s : ℝ => s - T_c) (1 : ℝ) T :=
    (hasDerivAt_id T).sub_const T_c
  have hsq : HasDerivAt (fun s : ℝ => (s - T_c) ^ 2)
      (2 * (T - T_c) ^ 1 * 1) T := hsub.pow 2
  -- multiply by the constant  -a₀²/(4b).
  have hmul : HasDerivAt
      (fun s : ℝ => (-(a₀ ^ 2) / (4 * b)) * (s - T_c) ^ 2)
      ((-(a₀ ^ 2) / (4 * b)) * (2 * (T - T_c) ^ 1 * 1)) T :=
    hsq.const_mul (-(a₀ ^ 2) / (4 * b))
  -- `Fmin` is definitionally this function (up to a ring rearrangement).
  have hfun : (fun s : ℝ => (-(a₀ ^ 2) / (4 * b)) * (s - T_c) ^ 2)
      = Fmin a₀ b T_c := by
    funext s; unfold Fmin; ring
  rw [hfun] at hmul
  convert hmul using 1
  field_simp
  ring

/-- **The Landau entropy (corrected sign)** below `T_c`:
`S_landau(T) = a₀²·(T − T_c)/(2b)` (negative for `T < T_c`, i.e. the
condensed phase carries less entropy than the background). -/
noncomputable def Slandau (a₀ b T_c T : ℝ) : ℝ :=
  a₀ ^ 2 * (T - T_c) / (2 * b)

/-- **R.269 — specific heat below `T_c`: `C_V = T·∂S/∂T`.**

`S_landau(T) = a₀²(T−T_c)/(2b)` has `∂S/∂T = a₀²/(2b)`, so the Landau
specific heat below the transition is `C_V = T·a₀²/(2b)`.  We give the
`HasDerivAt` for `S` (its slope is the bracketed constant). -/
theorem R_269_hasDerivAt_Slandau
    (a₀ b T_c T : ℝ) (hb : 0 < b) :
    HasDerivAt (Slandau a₀ b T_c) (a₀ ^ 2 / (2 * b)) T := by
  have hb' : b ≠ 0 := ne_of_gt hb
  have hsub : HasDerivAt (fun s : ℝ => s - T_c) (1 : ℝ) T :=
    (hasDerivAt_id T).sub_const T_c
  have hmul : HasDerivAt (fun s : ℝ => (a₀ ^ 2 / (2 * b)) * (s - T_c))
      ((a₀ ^ 2 / (2 * b)) * 1) T := hsub.const_mul (a₀ ^ 2 / (2 * b))
  have hfun : (fun s : ℝ => (a₀ ^ 2 / (2 * b)) * (s - T_c))
      = Slandau a₀ b T_c := by
    funext s; unfold Slandau; ring
  rw [hfun] at hmul
  convert hmul using 1
  ring

/-- **Specific heat (Landau part), as a function of temperature.**

`C_V(T) = T · ∂S/∂T`.  Below `T_c`: `T·a₀²/(2b)`.  Above `T_c`: `0`
(`S = 0`).  We model this with the explicit below/above values. -/
noncomputable def CV_below (a₀ b T : ℝ) : ℝ := T * (a₀ ^ 2 / (2 * b))

/-- **R.269 — the specific-heat jump `ΔC_V = T_c·a₀²/(2b)`** (♥').

At the transition the jump is `C_V(T_c⁻) − C_V(T_c⁺)
= T_c·a₀²/(2b) − 0 = T_c·a₀²/(2b)`.  Evaluating `CV_below` at `T_c` and
`CV_above = 0`. -/
theorem R_269_CV_jump (a₀ b T_c : ℝ) :
    CV_below a₀ b T_c - (0 : ℝ) = T_c * a₀ ^ 2 / (2 * b) := by
  unfold CV_below
  ring

/-- **R.269 — jump from generic below/above specific-heat hypotheses.**

If the specific heat just below `T_c` is `C_below = T_c·a₀²/(2b)` and
just above is `C_above = 0` (the mean-field Landau result), then the
discontinuity is exactly `ΔC_V = T_c·a₀²/(2b)`.  This is the robust
algebraic statement requested: given the below/above `C_V` expressions,
the jump is the claimed formula. -/
theorem R_269_jump_from_hyps
    (a₀ b T_c C_below C_above ΔC_V : ℝ)
    (h_below : C_below = T_c * a₀ ^ 2 / (2 * b))
    (h_above : C_above = 0)
    (h_jump : ΔC_V = C_below - C_above) :
    ΔC_V = T_c * a₀ ^ 2 / (2 * b) := by
  rw [h_jump, h_below, h_above]; ring

/-- **R.269 — jump positivity.**

`ΔC_V = T_c·a₀²/(2b) > 0` for `T_c > 0`, `a₀ ≠ 0`, `b > 0`: the condensed
phase has a strictly higher specific heat (second-order transition
signature). -/
theorem R_269_jump_pos
    (a₀ b T_c : ℝ) (hT : 0 < T_c) (ha : a₀ ≠ 0) (hb : 0 < b) :
    0 < T_c * a₀ ^ 2 / (2 * b) := by
  have ha2 : 0 < a₀ ^ 2 := by positivity
  have hnum : 0 < T_c * a₀ ^ 2 := mul_pos hT ha2
  have hden : 0 < 2 * b := by linarith
  exact div_pos hnum hden

end CVJump

end MIP
