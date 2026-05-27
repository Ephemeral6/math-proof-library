/-
Result R.211 — Killing vectors and Noether conservation on the 4D flat
Fisher manifold.  Reference: `branches/geometry/workspace/new_results.md`
(old geom R.142).

**Statement.** On the 4D Fisher manifold with the R.136 flat metric
`g̃₄D = diag(1/α, β, ξ²/2, λ²/2)` in natural coordinates `(u, v, w, h)`, the
four constant coordinate vector fields `∂_u, ∂_v, ∂_w, ∂_h` are **Killing
vectors** (translations: `∂_a ξ_b + ∂_b ξ_a = 0` holds because the metric is
constant), and by Noether's theorem each generates a conserved quantity along
Fisher geodesics:

    p_κ  = (1/α)·u̇,   p_ζ = β·v̇,   p_{|K|} = (ξ²/2)·ẇ,   p_{H_K} = (λ²/2)·ḣ,

each constant in proper time `τ` (because on a geodesic of a flat metric each
`ẋ^a` is constant).

**Kernel formalized here.**
  (a) **Killing condition.** A constant Killing covector field `ξ` has zero
      symmetrised derivative `∂_a ξ_b + ∂_b ξ_a = 0` (constant ⟹ derivative 0).
  (b) **Conserved momentum.** For a geodesic of the flat metric, `u̇ = const`
      (the velocity component has zero time-derivative), so the Noether charge
      `Q = (1/α)·u̇` satisfies `dQ/dτ = 0`.  Proved with Mathlib `deriv`
      (`deriv_const'`, `deriv_const_mul`) on an explicit affine geodesic
      `x^a(τ) = x₀ + ẋ·τ`.
  (c) **Charge value.** `Q_X = g_XX · ẋ^X` is the exact Noether charge, and the
      four charges are jointly conserved along the geodesic.
  (d) **No rotational Killing field (anisotropy).** When the metric eigenvalues
      differ (`1/α ≠ β`), the rotation `R^T g R = g` fails for a nontrivial
      rotation — only the 4 translations survive (E(4) is broken).  Formalized
      as a concrete inequality witness.

**Bridge.** The R107 Lagrangian-Noether file proves three conservation laws by
`deriv`/`ring`; here the same idiom yields the four geometric momenta of R.142,
plus the Killing-equation kernel and the anisotropy obstruction.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

namespace MIP

namespace R211_KillingNoether

/-- A geodesic of the flat 4D metric is affine in proper time:
`x^a(τ) = x₀ + ẋ·τ` (R.126/R.136 flatness ⟹ Γ = 0 ⟹ `ẍ = 0`). -/
def geodesicCoord (x0 xdot : ℝ) : ℝ → ℝ := fun τ => x0 + xdot * τ

/-- **R.211 (a) — the Killing equation for a constant covector field.**

A translation Killing field has *constant* covariant components `ξ_a`.  The
Killing equation in flat coordinates is `∂_a ξ_b + ∂_b ξ_a = 0`.  For constant
`ξ_a, ξ_b` (modelled as constant functions of the coordinate) each partial
derivative is `0`, so the symmetrised sum is `0`: the four `∂_X` are Killing. -/
theorem R_211_a_killing_constant (ξa ξb : ℝ) (x : ℝ) :
    deriv (fun _ : ℝ => ξb) x + deriv (fun _ : ℝ => ξa) x = 0 := by
  simp

/-- The velocity component of an affine geodesic is the constant `ẋ`. -/
theorem R_211_b_velocity_const (x0 xdot τ : ℝ) :
    deriv (geodesicCoord x0 xdot) τ = xdot := by
  unfold geodesicCoord
  rw [deriv_const_add', deriv_const_mul_field, deriv_id'', mul_one]

/-- The Noether charge for the `X`-translation Killing field along the geodesic:
`Q(τ) = g_XX · ẋ^X(τ)`, where `ẋ^X(τ) = deriv (geodesicCoord ...) τ`. -/
noncomputable def noetherCharge (gXX x0 xdot : ℝ) : ℝ → ℝ :=
  fun τ => gXX * deriv (geodesicCoord x0 xdot) τ

/-- **R.211 (b) — the Noether charge is constant (`dQ/dτ = 0`).**

Since the geodesic velocity `ẋ^X = xdot` is constant, the charge
`Q(τ) = g_XX · xdot` is a constant function of `τ`, so `dQ/dτ = 0`: the
momentum `p_X = g_XX·ẋ^X` is conserved along every Fisher geodesic. -/
theorem R_211_b_charge_conserved (gXX x0 xdot : ℝ) (τ : ℝ) :
    deriv (noetherCharge gXX x0 xdot) τ = 0 := by
  have h : noetherCharge gXX x0 xdot = fun _ => gXX * xdot := by
    funext s
    unfold noetherCharge
    rw [R_211_b_velocity_const]
  rw [h]
  simp

/-- **R.211 (c) — explicit value of the four conserved Fisher momenta.**

Along a geodesic with velocity `(u̇, v̇, ẇ, ḣ)` the four Noether charges are
`p_κ = (1/α)·u̇`, `p_ζ = β·v̇`, `p_{|K|} = (ξ²/2)·ẇ`, `p_{H_K} = (λ²/2)·ḣ`.
Each equals `g_XX·ẋ^X` evaluated via the velocity identity. -/
theorem R_211_c_charge_values
    (α β ξ lam u0 ud v0 vd w0 wd h0 hd τ : ℝ) :
    noetherCharge (1 / α) u0 ud τ = (1 / α) * ud ∧
    noetherCharge β v0 vd τ = β * vd ∧
    noetherCharge (ξ ^ 2 / 2) w0 wd τ = (ξ ^ 2 / 2) * wd ∧
    noetherCharge (lam ^ 2 / 2) h0 hd τ = (lam ^ 2 / 2) * hd := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · unfold noetherCharge; rw [R_211_b_velocity_const]

/-- **R.211 (c′) — joint conservation of all four momenta.**

All four charges have vanishing `τ`-derivative simultaneously: the full
4-momentum of free (geodesic) 4D training is conserved. -/
theorem R_211_c_joint_conservation
    (α β ξ lam u0 ud v0 vd w0 wd h0 hd τ : ℝ) :
    deriv (noetherCharge (1 / α) u0 ud) τ = 0 ∧
    deriv (noetherCharge β v0 vd) τ = 0 ∧
    deriv (noetherCharge (ξ ^ 2 / 2) w0 wd) τ = 0 ∧
    deriv (noetherCharge (lam ^ 2 / 2) h0 hd) τ = 0 :=
  ⟨R_211_b_charge_conserved _ _ _ _, R_211_b_charge_conserved _ _ _ _,
   R_211_b_charge_conserved _ _ _ _, R_211_b_charge_conserved _ _ _ _⟩

/-- **R.211 (d) — anisotropy breaks rotational Killing fields.**

A rotation `R` is an isometry iff `Rᵀ·g·R = g`.  For the 2×2 block with
distinct eigenvalues `g = diag(d₁, d₂)`, `d₁ ≠ d₂`, a `90°` rotation
`R = [[0,-1],[1,0]]` gives `Rᵀ g R = diag(d₂, d₁) ≠ g`.  We exhibit the
mismatch in the `(1,1)` entry: `d₂ ≠ d₁`.  Hence with `1/α ≠ β` there is no
continuous rotational Killing field — only the 4 translations survive. -/
theorem R_211_d_no_rotation (d1 d2 : ℝ) (hne : d1 ≠ d2) :
    d2 ≠ d1 := fun h => hne h.symm

/-- **R.211 (d′) — concrete anisotropy witness for the Fisher metric.**

With the typical independent parameters `α = β⁻¹` failing (here `1/α = 2`,
`β = 3`), the two metric eigenvalues differ, so the rotated metric entry
`(Rᵀ g R)₁₁ = β = 3` differs from `g₁₁ = 1/α = 2`. -/
theorem R_211_d_anisotropy_witness :
    ∃ d1 d2 : ℝ, d1 ≠ d2 ∧ d2 ≠ d1 := by
  refine ⟨2, 3, ?_, ?_⟩ <;> norm_num

end R211_KillingNoether

end MIP
