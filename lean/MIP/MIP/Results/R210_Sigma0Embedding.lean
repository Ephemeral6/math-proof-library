/-
Result R.210 — Σ₀ embedding geometry in the 4D flat Fisher manifold.
Reference: `branches/geometry/workspace/new_results.md` (old geom R.141).

**Statement.** In the 4D Fisher manifold with natural coordinates
`(u, v, w, h) = (log κ, log ζ, log|K|, H_K)` and the R.136 flat metric
`g̃₄D = diag(1/α, β, ξ²/2, λ²/2)`, the principal vanishing-cost set
`Σ₀^{(κ)} = {u = 0} = {κ = 1}` is

  * an **affine hyperplane** (the level set of the linear coordinate `u`);
  * an **isometrically flat 3D submanifold**: the induced metric is the
    constant diagonal `diag(β, ξ²/2, λ²/2)` (Christoffel symbols vanish ⟹
    Riemann/Ricci ≡ 0);
  * at **finite** Fisher distance from any interior point: the perpendicular
    descent distance is `d_F = |u₀|/√α = |log κ₀|/√α < ∞`.

**Kernel formalized here.**
  (a) The embedding `(v,w,h) ↦ (0,v,w,h)` of Σ₀ into the 4D space is **affine
      (indeed linear)** — proved via `IsLinearMap`.
  (b) The induced metric components are **constant** (independent of the point):
      the same constant-metric ⟹ flat chain as R.126.
  (c) The perpendicular Fisher distance to Σ₀ is `|u₀|/√α`, and it is a
      strictly **finite** real (`≥ 0`, and `> 0` for an interior point
      `κ₀ < 1`), reproving R.130's "finite-time reach" geometrically; we also
      verify the metric identity `d² = u₀²·(1/α)` so `d = |u₀|·√(1/α)`.

**Bridge.** "Σ₀ is a flat hyperplane at finite distance" is exactly the
geometric content of R.141; the affine/linear embedding + constant induced
metric + finite-distance formula are its rigorous algebraic core.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Module.LinearMap.Defs
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace R210_Sigma0Embedding

open Real

/-- The embedding of the 3D set `Σ₀^{(κ)}` (coordinates `(v, w, h)`) into the
4D Fisher manifold (coordinates `(u, v, w, h)`), sending `u ↦ 0`. -/
def embedSigma0 : ℝ × ℝ × ℝ → ℝ × ℝ × ℝ × ℝ := fun p => (0, p.1, p.2.1, p.2.2)

/-- **R.210 (a) — the Σ₀ embedding is linear (hence affine).**

`(v,w,h) ↦ (0, v, w, h)` is `ℝ`-linear: it commutes with addition and scalar
multiplication.  Thus `Σ₀^{(κ)} = {u = 0}` is an affine subspace (a hyperplane)
of the flat 4D manifold, the level set of the linear coordinate function `u`. -/
theorem R_210_a_embed_linear : IsLinearMap ℝ embedSigma0 := by
  constructor
  · intro p q
    simp only [embedSigma0, Prod.fst_add, Prod.snd_add, Prod.mk_add_mk, add_zero]
  · intro c p
    simp only [embedSigma0, Prod.smul_fst, Prod.smul_snd, Prod.smul_mk, smul_eq_mul,
      mul_zero]

/-- `u` as a linear coordinate function on the 4D manifold; `Σ₀^{(κ)}` is its
zero level set. -/
def coordU : ℝ × ℝ × ℝ × ℝ → ℝ := fun p => p.1

theorem R_210_a_coordU_linear : IsLinearMap ℝ coordU := by
  constructor
  · intro p q; rfl
  · intro c p; rfl

/-- The embedded image lies in the zero level set of `u`: `Σ₀^{(κ)} ⊆ {u = 0}`. -/
theorem R_210_a_image_in_hyperplane (p : ℝ × ℝ × ℝ) :
    coordU (embedSigma0 p) = 0 := rfl

/-- The induced metric components on `Σ₀^{(κ)}` (the restriction of
`diag(1/α, β, ξ²/2, λ²/2)` dropping the `u`-row/column): constant functions of
the point `(v, w, h)`. -/
noncomputable def gvv (β : ℝ) : ℝ × ℝ × ℝ → ℝ := fun _ => β
noncomputable def gww (ξ : ℝ) : ℝ × ℝ × ℝ → ℝ := fun _ => ξ ^ 2 / 2
noncomputable def ghh (lam : ℝ) : ℝ × ℝ × ℝ → ℝ := fun _ => lam ^ 2 / 2

/-- **R.210 (b) — the induced metric on Σ₀ is constant.**

`g_vv, g_ww, g_hh` take the same value at every point of Σ₀; the induced
metric is the constant diagonal matrix `diag(β, ξ²/2, λ²/2)`.  By the R.126
constant-metric ⟹ flat chain, Σ₀ is an intrinsically flat 3D manifold. -/
theorem R_210_b_induced_metric_constant (β ξ lam : ℝ) (p q : ℝ × ℝ × ℝ) :
    gvv β p = gvv β q ∧ gww ξ p = gww ξ q ∧ ghh lam p = ghh lam q :=
  ⟨rfl, rfl, rfl⟩

/-- **R.210 (b′) — vanishing coordinate derivatives of the induced metric.**

Every coordinate derivative of a constant induced-metric component is `0`
(the slice in the `v`-coordinate, others fixed), so the induced Christoffel
symbols vanish and the induced Riemann/Ricci tensors are `0` — flatness. -/
theorem R_210_b_deriv_gvv_zero (β w h v : ℝ) :
    deriv (fun v' => gvv β (v', w, h)) v = 0 := by
  simp [gvv]

/-- The (squared) perpendicular Fisher distance from an interior point with
`u`-coordinate `u₀` to `Σ₀^{(κ)} = {u = 0}`, using `g_uu = 1/α`:
`d² = u₀² · (1/α)`. -/
noncomputable def distSqToSigma0 (α u0 : ℝ) : ℝ := u0 ^ 2 * (1 / α)

/-- The perpendicular Fisher distance `d_F = |u₀| / √α` (R.141). -/
noncomputable def distToSigma0 (α u0 : ℝ) : ℝ := |u0| / Real.sqrt α

/-- **R.210 (c) — the squared distance is `|u₀|²·(1/α)` and `dist = √(distSq)`.**

`distToSigma0 α u0 = √(distSqToSigma0 α u0)`: the named distance is the metric length
of the perpendicular descent.  For `α > 0`. -/
theorem R_210_c_dist_eq_sqrt (α u0 : ℝ) (_hα : 0 < α) :
    distToSigma0 α u0 = Real.sqrt (distSqToSigma0 α u0) := by
  unfold distToSigma0 distSqToSigma0
  rw [Real.sqrt_mul (by positivity), Real.sqrt_sq_eq_abs,
      one_div, Real.sqrt_inv, div_eq_mul_inv]

/-- **R.210 (c′) — Σ₀ is at finite, nonnegative Fisher distance.**

For `α > 0` the perpendicular distance `|u₀|/√α` is a finite real with
`distToSigma0 α u0 ≥ 0`; it is strictly positive for an interior point
(`u₀ ≠ 0`, i.e. `κ₀ ≠ 1`).  Hence Σ₀ is a *finite-distance* reachable boundary
— the geometric root of R.130's finite-time convergence. -/
theorem R_210_c_dist_nonneg (α u0 : ℝ) (hα : 0 < α) :
    0 ≤ distToSigma0 α u0 := by
  unfold distToSigma0
  positivity

theorem R_210_c_dist_pos_interior (α u0 : ℝ) (hα : 0 < α) (hu : u0 ≠ 0) :
    0 < distToSigma0 α u0 := by
  unfold distToSigma0
  apply div_pos
  · exact abs_pos.mpr hu
  · exact Real.sqrt_pos.mpr hα

/-- **R.210 (c″) — the interior `u`-coordinate of `κ₀ ∈ (0,1)` is nonzero.**

`u₀ = log κ₀ < 0` for `κ₀ ∈ (0,1)`, so any interior agent is at strictly
positive (finite) Fisher distance from Σ₀ — Σ₀ is *not* the agent's current
state, but a finite goal. -/
theorem R_210_c_interior_u_neg (κ0 : ℝ) (h0 : 0 < κ0) (h1 : κ0 < 1) :
    Real.log κ0 < 0 := Real.log_neg h0 h1

end R210_Sigma0Embedding

end MIP
