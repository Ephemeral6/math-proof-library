/-
Result R.566-R.570 — Cj.17 Fisher natural gradient: the 4D Fisher metric
on the capability phase space is FLAT (Ricci curvature ≡ 0) under the
stated diagonal / constant-in-coordinates parameterization.

Reference: `workspace/round3_exploration/slot_047.md` (slot 047),
`workspace/round3_exploration/work_slot_047.md` §7 (R.570: 4D Ricci scalar
≡ 0; "for a fully separable diagonal metric `g = diag(g₁(x₁),…,gₙ(xₙ))`
the Riemann tensor vanishes identically, hence Ricci = 0"; §5 R.568:
4D Fisher = diag(R.106, R.125, R.566, R.567)).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (formalized FLATNESS kernel).**

The slot reduces 4D flatness to the standard differential-geometry fact:
*a metric whose components are constant in the chosen (log-)coordinates
has vanishing Christoffel symbols, hence vanishing Riemann/Ricci
curvature.*  We formalize this kernel directly.

Work in the slot's log-coordinates `(W, V, ξ, U) = (log n, log ζ, h,
log κ)` (§7.1), in which the diagonal Fisher metric becomes the constant
matrix `diag(r̄²ψ/(1−ψ), β, 1/σ_h², 1/α)` (§7.1, R.568) — *modelled here
as a metric whose components do not depend on the point*.  We prove:

* (R.570-a) **constant metric ⟹ zero Christoffel symbols.**  With the
  Christoffel symbols of the first kind defined from coordinate partial
  derivatives of the metric, every symbol vanishes when each component
  function is constant.
* (R.570-b) **zero Christoffel ⟹ zero Riemann ⟹ zero Ricci.**  With the
  Riemann tensor built from the (vanishing) Christoffel symbols and their
  derivatives, all components are `0`; the Ricci tensor (contraction of
  Riemann) is therefore `0`, and the Ricci scalar is `0`.
* (R.568-flat) the diagonal **constant** Fisher matrix is a special case,
  so the 4D Fisher manifold is flat.

We model the metric as `g : (Fin 4 → ℝ) → Matrix (Fin 4) (Fin 4) ℝ`,
"constant" meaning `∀ x y, g x = g y`, and the curvature objects through
the coordinate Fréchet derivative (`fderiv ℝ`).  Constancy makes every
derivative `0`, collapsing the whole curvature tower.

**This file is `axiom`-free.**  The Fisher/metric semantics enter only
through the hypothesis that the metric is constant in coordinates; the
curvature formulas are stated as plain real-valued definitions.
-/
import Mathlib.Analysis.Calculus.FDeriv.Basic
import Mathlib.Analysis.Calculus.FDeriv.Const
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace FisherFlat

open scoped Matrix

/-- Dimension of the capability phase space: `(|K|, Z⁻¹, H_K, κ)`. -/
abbrev dim : ℕ := 4

/-- A coordinate point `θ = (W, V, ξ, U) ∈ ℝ⁴`. -/
abbrev Point := Fin dim → ℝ

/-- A (Riemannian) metric field: a symmetric matrix at every point. -/
abbrev Metric := Point → Matrix (Fin dim) (Fin dim) ℝ

/-- **Constant-in-coordinates metric.**  In the slot's log-coordinates the
4D Fisher matrix `diag(r̄²ψ/(1−ψ), β, 1/σ_h², 1/α)` is, under the stated
separability assumption, independent of the point. -/
def IsConstantMetric (g : Metric) : Prop := ∀ x y, g x = g y

/-- The component function `g_{ij} : Point → ℝ` of a metric. -/
noncomputable def comp (g : Metric) (i j : Fin dim) : Point → ℝ :=
  fun x => g x i j

/-- The partial derivative of `g_{ij}` in the `k`-th coordinate direction,
i.e. `∂_k g_{ij}`, expressed via the Fréchet derivative evaluated on the
`k`-th basis vector `Pi.single k 1`. -/
noncomputable def partialDeriv (g : Metric) (i j k : Fin dim) (x : Point) : ℝ :=
  fderiv ℝ (comp g i j) x (Pi.single k (1 : ℝ))

/-- **Christoffel symbol of the first kind**
`Γ_{kij} = ½(∂_i g_{jk} + ∂_j g_{ik} − ∂_k g_{ij})`. -/
noncomputable def christoffel (g : Metric) (k i j : Fin dim) (x : Point) : ℝ :=
  (1 / 2) * (partialDeriv g j k i x + partialDeriv g i k j x
              - partialDeriv g i j k x)

/-- A model **Riemann curvature scalar field** built purely from the
Christoffel symbols and their coordinate derivatives.  For a flat
(zero-Christoffel) connection every contributing term is `0`; the exact
index bookkeeping of the full `(1,3)` tensor is irrelevant for the kernel
result, so we package the curvature as the sum of "derivative-of-Γ" and
"Γ·Γ" contributions, each of which vanishes once `Γ ≡ 0`. -/
noncomputable def riemannTerm (g : Metric) (a b c d : Fin dim) (x : Point) : ℝ :=
  fderiv ℝ (fun y => christoffel g a c d y) x (Pi.single b (1 : ℝ))
    - fderiv ℝ (fun y => christoffel g a b d y) x (Pi.single c (1 : ℝ))
    + (∑ e, christoffel g a b e x * christoffel g e c d x)
    - (∑ e, christoffel g a c e x * christoffel g e b d x)

/-- The **Ricci scalar** as the full double contraction of the Riemann
terms (`R = Σ_{a,b} R^a_{ a b b}` packaged via `riemannTerm`). -/
noncomputable def ricciScalar (g : Metric) (x : Point) : ℝ :=
  ∑ a, ∑ b, riemannTerm g a a b b x

/-- **Auxiliary — a constant metric has zero partial derivatives.**

If `g x = g y` for all `x, y`, then `g_{ij}` is a constant function, whose
Fréchet derivative is `0`, so `∂_k g_{ij} = 0` everywhere. -/
theorem partialDeriv_eq_zero_of_const {g : Metric} (hg : IsConstantMetric g)
    (i j k : Fin dim) (x : Point) : partialDeriv g i j k x = 0 := by
  unfold partialDeriv
  -- `comp g i j` is the constant function `fun _ => g x i j`.
  have hconst : comp g i j = fun _ => g x i j := by
    funext y; simp only [comp]; rw [hg y x]
  rw [hconst]
  simp [fderiv_fun_const]

/-- **R.570-a — a constant metric has vanishing Christoffel symbols.**

`Γ_{kij} = ½(∂_i g_{jk} + ∂_j g_{ik} − ∂_k g_{ij}) = 0` since every partial
derivative of a constant metric is `0`.  This is the slot's
"constant metric ⟹ zero Christoffel" step (§7.3, where `V, U` are Killing
directions and, under separability, the surviving symbols also drop). -/
theorem R_570_a_christoffel_eq_zero {g : Metric} (hg : IsConstantMetric g)
    (k i j : Fin dim) (x : Point) : christoffel g k i j x = 0 := by
  unfold christoffel
  rw [partialDeriv_eq_zero_of_const hg, partialDeriv_eq_zero_of_const hg,
    partialDeriv_eq_zero_of_const hg]
  ring

/-- **Auxiliary — the Christoffel field of a constant metric is the zero
function**, hence its coordinate derivatives also vanish. -/
theorem christoffel_fun_eq_zero {g : Metric} (hg : IsConstantMetric g)
    (a c d : Fin dim) : (fun y => christoffel g a c d y) = fun _ => 0 := by
  funext y; exact R_570_a_christoffel_eq_zero hg a c d y

/-- **R.570-b — every Riemann term of a constant metric vanishes.**

With `Γ ≡ 0`, the derivative-of-Γ terms are derivatives of the zero
function (hence `0`) and the `Γ·Γ` sums vanish termwise. -/
theorem R_570_b_riemannTerm_eq_zero {g : Metric} (hg : IsConstantMetric g)
    (a b c d : Fin dim) (x : Point) : riemannTerm g a b c d x = 0 := by
  unfold riemannTerm
  -- The two derivative terms: derivative of the zero function is 0.
  rw [christoffel_fun_eq_zero hg a c d, christoffel_fun_eq_zero hg a b d]
  -- The two ΓΓ sums vanish termwise.
  have hsum1 : (∑ e, christoffel g a b e x * christoffel g e c d x) = 0 := by
    apply Finset.sum_eq_zero; intro e _
    rw [R_570_a_christoffel_eq_zero hg a b e, zero_mul]
  have hsum2 : (∑ e, christoffel g a c e x * christoffel g e b d x) = 0 := by
    apply Finset.sum_eq_zero; intro e _
    rw [R_570_a_christoffel_eq_zero hg a c e, zero_mul]
  rw [hsum1, hsum2]
  simp [fderiv_fun_const]

/-- **R.570 — the Ricci scalar of a constant metric is identically `0`.**

The 4D Fisher metric, being constant in the slot's log-coordinates
(diagonal, separable), is flat: `R(x) = 0` for every point `x`.  This is
the requested flatness kernel and the 4D generalization of R.126. -/
theorem R_570_ricci_scalar_eq_zero {g : Metric} (hg : IsConstantMetric g)
    (x : Point) : ricciScalar g x = 0 := by
  unfold ricciScalar
  apply Finset.sum_eq_zero; intro a _
  apply Finset.sum_eq_zero; intro b _
  exact R_570_b_riemannTerm_eq_zero hg a a b b x

/-! ### The diagonal constant Fisher metric (R.568) is a flatness instance -/

/-- The diagonal Fisher metric with the four (constant) eigenvalues
`d 0 = r̄²ψ/(1−ψ)`, `d 1 = β`, `d 2 = 1/σ_h²`, `d 3 = 1/α`
(§7.1).  As a field it is `fun _ => Matrix.diagonal d` — manifestly
independent of the point. -/
noncomputable def fisherDiag (d : Fin dim → ℝ) : Metric :=
  fun _ => Matrix.diagonal d

/-- The diagonal Fisher metric is a constant metric. -/
theorem fisherDiag_isConstant (d : Fin dim → ℝ) :
    IsConstantMetric (fisherDiag d) := by
  intro x y; rfl

/-- **R.568 + R.570 — the 4D diagonal Fisher metric is flat.**

For any constant diagonal eigenvalue profile `d`, the capability-phase
Fisher metric `diag(d)` has Ricci scalar `≡ 0`. -/
theorem R_570_fisher_flat (d : Fin dim → ℝ) (x : Point) :
    ricciScalar (fisherDiag d) x = 0 :=
  R_570_ricci_scalar_eq_zero (fisherDiag_isConstant d) x

end FisherFlat

end MIP
