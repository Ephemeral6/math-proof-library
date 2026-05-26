/-
Result R.77 (T.13) — Explicit partial derivatives in the 4D phase space.

Reference: `workspace/new_results.md` R.77 (T.13)
(B 级 — 核心计算 (a)(b) 严格 A 级; (c)(d) 是 R.61 渐近域二阶近似. The
"asymptotic-domain" smoothness premise `R(p) ⊆ K(A)` is the bundled
assumption; we encode the calculus kernel.)

**Statement.** In the asymptotic domain (coverage complete), with the
compact R.61s form `N = c · r · |log κ| · Z` (and the bilinear base form
`N = Φ₀ · Z`), the partial derivatives are:

* base bilinear form:
  - `∂N/∂Φ₀ = Z`        (holding `Z` fixed),
  - `∂N/∂Z  = Φ₀`       (holding `Φ₀` fixed);
* (a) `∂N/∂Z⁻¹ = −c·r·|log κ|·Z² = −N·Z`  (writing `w = Z⁻¹`,
  `N = c·r·|log κ|/w`);
* (b) `∂N/∂κ = −c·r·Z/κ = −N/(κ·|log κ|)`  (on `κ ∈ (0,1)`, where
  `|log κ| = −log κ`).

**Pure-math content.** Each partial is an ordinary one-variable
derivative with the other phase-space coordinates frozen as constants.
We prove them with `HasDerivAt`: products with constants, the reciprocal
rule (`∂/∂w (A/w) = −A/w²`), and the log derivative
(`∂/∂κ (−log κ) = −1/κ`). The chain-rule simplifications `−N·Z` and
`−N/(κ·|log κ|)` follow by substituting the closed form back in.

The empirical premises (asymptotic domain, slow-varying coordinates)
enter only as the explicit functional forms; smoothness is bundled by
working at points where the elementary derivative lemmas apply
(`Z⁻¹ ≠ 0`, `κ > 0`).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace PartialDerivatives

open Real

/-- **R.77 base form — `∂N/∂Φ₀ = Z`.**

For the bilinear emergence cost `N = Φ₀ · Z`, with `Z` held fixed, the
partial in `Φ₀` is the constant `Z`: the map `φ ↦ φ · Z` has derivative
`Z` at every point. -/
theorem R_77_dN_dPhi (Z Φ₀ : ℝ) :
    HasDerivAt (fun φ => φ * Z) Z Φ₀ := by
  simpa using (hasDerivAt_id Φ₀).mul_const Z

/-- **R.77 base form — `∂N/∂Z = Φ₀`.**

Symmetric to the previous: with `Φ₀` held fixed, `Z ↦ Φ₀ · Z` has
derivative `Φ₀`. -/
theorem R_77_dN_dZ (Φ₀ Z : ℝ) :
    HasDerivAt (fun z => Φ₀ * z) Φ₀ Z := by
  simpa using (hasDerivAt_id Z).const_mul Φ₀

/-- **R.77 (a) — `∂N/∂Z⁻¹ = −c·r·|log κ|·Z²` (reciprocal-variable form).**

Write `A := c·r·|log κ|` (constant in the `Z⁻¹` direction) and let
`w = Z⁻¹` be the working variable, so `N = A / w`. At `w = Z⁻¹ ≠ 0` the
reciprocal rule gives

    ∂N/∂w = −A / w²  =  −A · Z² .

This is the raw derivative; the `−N·Z` simplification is the next
theorem. -/
theorem R_77_a_dN_dZinv_raw
    (A w : ℝ) (hw : w ≠ 0) :
    HasDerivAt (fun u => A / u) (-A / w ^ 2) w := by
  have h : HasDerivAt (fun u => A * u⁻¹) (A * (-(w ^ 2)⁻¹)) w :=
    (hasDerivAt_inv hw).const_mul A
  have hsimp : A * (-(w ^ 2)⁻¹) = -A / w ^ 2 := by
    field_simp
  rw [hsimp] at h
  -- `A * u⁻¹ = A / u` pointwise.
  have hfun : (fun u => A * u⁻¹) = (fun u => A / u) := by
    funext u; rw [div_eq_mul_inv]
  rwa [hfun] at h

/-- **R.77 (a) — chain-rule simplification `∂N/∂Z⁻¹ = −N·Z`.**

With `w = Z⁻¹` (so `Z = w⁻¹`, `w ≠ 0`), `A := c·r·|log κ|`, and the
closed form `N = A·Z = A·w⁻¹`, the raw derivative `−A/w² = −A·Z²` equals
`−N·Z`:

    −A·Z²  =  −(A·Z)·Z  =  −N·Z .

We state it with `N` and `Z` as the *named MIP quantities* tied to `A,w`
through the bundled relations `hZ : Z = w⁻¹` and `hN : N = A * Z`. -/
theorem R_77_a_dN_dZinv
    (A w N Z : ℝ) (hw : w ≠ 0)
    (hZ : Z = w⁻¹) (hN : N = A * Z) :
    HasDerivAt (fun u => A / u) (-N * Z) w := by
  have h := R_77_a_dN_dZinv_raw A w hw
  -- show  -A / w^2 = -N * Z.
  have hval : -A / w ^ 2 = -N * Z := by
    subst hZ hN
    field_simp
  rwa [hval] at h

/-- **R.77 (b) — `∂N/∂κ = −c·r·Z/κ` (log-derivative form).**

On `κ ∈ (0,1)` we have `|log κ| = −log κ`, so with `B := c·r·Z` constant
in the `κ` direction, `N = B·(−log κ)` and

    ∂N/∂κ = B·(−1/κ) = −B/κ .

We work at any `κ > 0` (where `log` is differentiable). -/
theorem R_77_b_dN_dkappa_raw
    (B κ : ℝ) (hκ : κ ≠ 0) :
    HasDerivAt (fun k => B * (-Real.log k)) (-B / κ) κ := by
  have hlog : HasDerivAt (fun k => Real.log k) κ⁻¹ κ := Real.hasDerivAt_log hκ
  have hneg : HasDerivAt (fun k => -Real.log k) (-(κ⁻¹)) κ := hlog.neg
  have h := hneg.const_mul B
  have hval : B * -(κ⁻¹) = -B / κ := by field_simp
  rwa [hval] at h

/-- **R.77 (b) — chain-rule simplification `∂N/∂κ = −N/(κ·|log κ|)`.**

With `B := c·r·Z`, `L := |log κ| = −log κ > 0` (so `κ ∈ (0,1)`), and the
closed form `N = B·L`, the raw derivative `−B/κ` rewrites as

    −B/κ  =  −(B·L)/(κ·L)  =  −N/(κ·L) .

Bundled: `hL : L = −log κ`, `hL_pos : 0 < L`, `hN : N = B * L`,
`hκ_pos : 0 < κ`. -/
theorem R_77_b_dN_dkappa
    (B κ N L : ℝ) (hκ_pos : 0 < κ)
    (hL_pos : 0 < L) (hN : N = B * L) :
    HasDerivAt (fun k => B * (-Real.log k)) (-N / (κ * L)) κ := by
  have hκ : κ ≠ 0 := ne_of_gt hκ_pos
  have h := R_77_b_dN_dkappa_raw B κ hκ
  -- show  -B / κ = -N / (κ * L).
  have hval : -B / κ = -N / (κ * L) := by
    subst hN
    field_simp
  rwa [hval] at h

end PartialDerivatives

end MIP
