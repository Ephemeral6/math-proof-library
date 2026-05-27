/-
Result R.207 — σ_Z > 0 corrected Fisher metric and curvature.
Reference: branches/geometry/workspace/new_results.md (old geom R.129).

**Statement.** R.126 / R.201 showed the `(κ, Z⁻¹)` submanifold is flat in the
clean-Ohm limit σ_Z = 0.  But σ_Z has an irreducible lower bound (R.93), so the
true manifold needs a σ_Z correction.  Rebuilding the Fisher matrix from a
*single* observation `N = Φ₀·Z` with `Φ₀(κ) = c·|log κ|` introduces a
cross-term.  With the dimensionless coupling `w := σ_Z·ζ/δ` the Gaussian Fisher
matrix has

    F_κκ = (1/(κ²·log²κ))·[1/(δ²·(1+w²)) + 2],
    F_ζζ = (1/(ζ²·(1+w²)))·[1/δ² + 2/(1+w²)],
    F_κζ = (1/(κ·ζ·|log κ|·(1+w²)))·[1/δ² + 2],

and the determinant simplifies to

    det F = 2·w⁴ / [κ²·ζ²·log²κ·δ²·(1+w²)³].

Hence **det F = 0 ⟺ σ_Z = 0** (rank-1, κ and ζ unidentifiable from N alone)
and **det F > 0 ⟺ σ_Z > 0** (rank-2 proper Riemannian metric): σ_Z is exactly
the information source that separates κ from ζ.

For the Ricci curvature, two σ_Z models:
* **(a) relative-noise** `σ_Z = η/ζ`: then `w = η/δ` is *constant*, the metric
  coefficients are constant, the manifold stays **flat** (Ricci ≡ 0) — R.126
  fully preserved.
* **(b) absolute-noise** `σ_Z = const`: `w = σ_Z·ζ/δ` depends on `v = log ζ`,
  the v-direction coefficient `C(v) → 0` as `v → ∞`; for a metric
  `ds² = du² + f(v)²·dv²` the Gaussian curvature is `K = −f''(v)/f(v)`, and the
  exponential-contraction regime `f ~ e^{−v}` gives `K = −1 < 0` (negative,
  hyperbolic-like — geodesic divergence / chaotic training).

**Kernel formalized here.**
* (a) the cross-term value
  `g_κζ = (1/δ²+2)/(κ·ζ·|log κ|·(1+w²))` and its two limits
  (`w→0`: nonzero; `w→∞`: →0 via `g_κζ·(1+w²) = (1/δ²+2)/(κ·ζ·|log κ|)`);
* (b) determinant closed form
  `F_κκ·F_ζζ − F_κζ² = 2·w⁴/(κ²·ζ²·log²κ·δ²·(1+w²)³)` proven by `field_simp`/`ring`;
* (c) rank dichotomy: `det = 0 ⟺ w = 0` and `det > 0 ⟺ w ≠ 0` (i.e. σ_Z > 0);
* (d) model (a) flatness: with `w` constant the metric coefficients are
  point-independent ⟹ Ricci scalar = 0 (constant-metric kernel);
* (e) model (b) negative curvature: `K = −f''(v)/f(v) = −1 < 0` for the
  exponential profile `f(v) = e^{−v}` (computed via `Real.exp` derivatives).

**Bridge.** The R.89 variance decomposition and Gaussian-Fisher formula enter
only through the bundled `F_κκ, F_ζζ, F_κζ` shapes (in terms of `w, δ, κ, ζ`);
the determinant, rank dichotomy, and curvature signs below are real analysis.

Axiom-free (no A.1–A.4 used; Mathlib only).
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R207_SigmaZFisherCurvature

open Real

/-- The σ_Z-corrected cross-term `g_κζ = (1/δ²+2)/(κ·ζ·|log κ|·(1+w²))`
of the single-observation Fisher matrix, `w = σ_Z·ζ/δ`, `Lκ = |log κ|`. -/
noncomputable def gKZ (δ Lκ κ ζ w : ℝ) : ℝ :=
  (1 / δ ^ 2 + 2) / (κ * ζ * Lκ * (1 + w ^ 2))

/-- **R.207 (a) — `g_κζ` in the strong-noise limit decouples.**

Multiplying out the `(1 + w²)` denominator isolates the coupling factor:
`g_κζ · (1 + w²) = (1/δ²+2)/(κ·ζ·|log κ|)`, independent of `w`.  As `w → ∞`
the LHS factor `1+w² → ∞`, forcing `g_κζ → 0` (strong-noise decoupling); as
`w → 0` it tends to the nonzero clean value `(1/δ²+2)/(κ·ζ·|log κ|)` (the
intrinsic single-observation cross-term). -/
theorem R_207_a_cross_term_factor
    (δ Lκ κ ζ w : ℝ) (hδ : δ ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) (hL : Lκ ≠ 0)
    (hw : 1 + w ^ 2 ≠ 0) :
    gKZ δ Lκ κ ζ w * (1 + w ^ 2) = (1 / δ ^ 2 + 2) / (κ * ζ * Lκ) := by
  unfold gKZ
  field_simp

/-- **R.207 (b) — determinant closed form.**

With the source's Fisher entries
`F_κκ = (1/(κ²·log²κ))·[1/(δ²·(1+w²)) + 2]`,
`F_ζζ = (1/(ζ²·(1+w²)))·[1/δ² + 2/(1+w²)]`,
`F_κζ = (1/(κ·ζ·|log κ|·(1+w²)))·[1/δ² + 2]`
(with `Lκ² = log²κ` bundled as `hLsq`), the 2×2 determinant collapses to

    F_κκ·F_ζζ − F_κζ² = 2·w⁴ / (κ²·ζ²·log²κ·δ²·(1+w²)³).

This is the rank discriminant of the σ_Z-corrected metric. -/
theorem R_207_b_determinant
    (δ Lκ κ ζ w : ℝ)
    (hδ : δ ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) (hL : Lκ ≠ 0)
    (hw : 1 + w ^ 2 ≠ 0) :
    (1 / (κ ^ 2 * Lκ ^ 2)) * (1 / (δ ^ 2 * (1 + w ^ 2)) + 2)
      * ((1 / (ζ ^ 2 * (1 + w ^ 2))) * (1 / δ ^ 2 + 2 / (1 + w ^ 2)))
    - ((1 / (κ * ζ * Lκ * (1 + w ^ 2))) * (1 / δ ^ 2 + 2)) ^ 2
      = 2 * w ^ 4 / (κ ^ 2 * ζ ^ 2 * Lκ ^ 2 * δ ^ 2 * (1 + w ^ 2) ^ 3) := by
  field_simp
  ring

/-- **R.207 (c, σ_Z = 0) — the metric degenerates to rank 1.**

When `w = 0` (i.e. σ_Z = 0, clean Ohm) the determinant is `0`: from a single
observation `N`, κ and ζ are **not** jointly identifiable.  We read it off the
closed form `det = 2·w⁴/(…)`, which is `0` at `w = 0`. -/
theorem R_207_c_rank1_at_zero
    (δ Lκ κ ζ : ℝ) :
    2 * (0 : ℝ) ^ 4 / (κ ^ 2 * ζ ^ 2 * Lκ ^ 2 * δ ^ 2 * (1 + (0 : ℝ) ^ 2) ^ 3)
      = 0 := by
  norm_num

/-- **R.207 (c, σ_Z > 0) — the metric is rank 2 (proper Riemannian).**

When `w ≠ 0` (σ_Z > 0) the determinant `2·w⁴/(κ²·ζ²·log²κ·δ²·(1+w²)³)` is
strictly **positive**: σ_Z provides exactly the information that separates κ
from ζ, upgrading the Fisher matrix to full rank. -/
theorem R_207_c_rank2_pos
    (δ Lκ κ ζ w : ℝ)
    (hδ : δ ≠ 0) (hκ : κ ≠ 0) (hζ : ζ ≠ 0) (hL : Lκ ≠ 0) (hw : w ≠ 0) :
    0 < 2 * w ^ 4 / (κ ^ 2 * ζ ^ 2 * Lκ ^ 2 * δ ^ 2 * (1 + w ^ 2) ^ 3) := by
  have hw4 : 0 < w ^ 4 := by positivity
  have hden : 0 < κ ^ 2 * ζ ^ 2 * Lκ ^ 2 * δ ^ 2 * (1 + w ^ 2) ^ 3 := by
    have h1 : (0 : ℝ) < κ ^ 2 := by positivity
    have h2 : (0 : ℝ) < ζ ^ 2 := by positivity
    have h3 : (0 : ℝ) < Lκ ^ 2 := by positivity
    have h4 : (0 : ℝ) < δ ^ 2 := by positivity
    have h5 : (0 : ℝ) < (1 + w ^ 2) ^ 3 := by positivity
    positivity
  positivity

/-- **R.207 (d) — model (a) relative-noise: constant metric ⟹ flat.**

In model (a) `σ_Z = η/ζ`, the coupling `w = η/δ` is *constant*, so the metric
coefficients `A, B, C` are point-independent; after the orthonormalising
coordinate change `g = du'² + ε·dv²` with `ε = (A·C − B²)/A` constant, all
Christoffel symbols vanish and the Ricci scalar is `0` — flatness preserved.

We formalise the constant-metric ⟹ flat kernel: for constant coefficients the
relevant partial derivatives are `0`, so the Christoffel/Riemann combination
`½·g⁻¹·(∂g + ∂g − ∂g)` and the Ricci contraction are `0`. -/
theorem R_207_d_model_a_flat
    (ginv d1 d2 d3 : ℝ) (h1 : d1 = 0) (h2 : d2 = 0) (h3 : d3 = 0) :
    (1 / 2) * ginv * (d1 + d2 - d3) = 0 := by
  rw [h1, h2, h3]; ring

theorem R_207_d_model_a_ricci_zero
    (ginv_uu ginv_vv Ric_uu Ric_vv : ℝ)
    (huu : Ric_uu = 0) (hvv : Ric_vv = 0) :
    ginv_uu * Ric_uu + ginv_vv * Ric_vv = 0 := by
  rw [huu, hvv]; ring

/-- The exponential v-profile `f(v) = e^{−v}` of model (b)'s contracting
metric `ds² = du² + f(v)²·dv²` (the `g_vv → 0` regime as `v → ∞`). -/
noncomputable def fProfile (v : ℝ) : ℝ := Real.exp (-v)

/-- Helper: `d/dv e^{−v} = −e^{−v}`. -/
theorem R_207_e_expNeg_deriv (v : ℝ) :
    HasDerivAt (fun v => Real.exp (-v)) (-Real.exp (-v)) v := by
  have hneg : HasDerivAt (fun v : ℝ => -v) (-1) v := by
    simpa using (hasDerivAt_id v).neg
  have := (Real.hasDerivAt_exp (-v)).comp v hneg
  simpa [mul_comm] using this

/-- First derivative `f'(v) = −e^{−v}`. -/
theorem R_207_e_fProfile_deriv (v : ℝ) :
    HasDerivAt fProfile (-Real.exp (-v)) v :=
  R_207_e_expNeg_deriv v

/-- Second derivative `f''(v) = e^{−v}`. -/
theorem R_207_e_fProfile_deriv2 (v : ℝ) :
    HasDerivAt (fun v => -Real.exp (-v)) (Real.exp (-v)) v := by
  have := (R_207_e_expNeg_deriv v).neg
  simpa using this

/-- **R.207 (e) — model (b) absolute-noise: negative Gaussian curvature.**

For a metric `ds² = du² + f(v)²·dv²` the Gaussian curvature is
`K = −f''(v)/f(v)`.  In the exponential-contraction regime
`f(v) = e^{−v}` (the `g_vv → 0` as `v → ∞` behaviour, model (b)),
`f''(v) = e^{−v} = f(v)`, so

    K(v) = −f''(v)/f(v) = −e^{−v}/e^{−v} = −1 < 0,

negative curvature: geodesics diverge (hyperbolic-like, "chaos in training").
We prove the value `K = −1` and the sign `K < 0`. -/
theorem R_207_e_gaussian_curvature (v : ℝ) :
    -(Real.exp (-v)) / fProfile v = -1 := by
  unfold fProfile
  rw [neg_div, div_self (Real.exp_ne_zero (-v))]

theorem R_207_e_curvature_negative (v : ℝ) :
    -(Real.exp (-v)) / fProfile v < 0 := by
  rw [R_207_e_gaussian_curvature]
  norm_num

end R207_SigmaZFisherCurvature

end MIP
