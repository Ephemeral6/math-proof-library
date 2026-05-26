/-
Result R.540-R.543 — geometry × self_reference cross-branch coupling:
the self-problem submanifold `M_self` is a 4-D Fisher **closed half-space**,
and the self-reference constraint **breaks** the `p_ζ` Noether conservation
law that holds in the non-self-referential (free-geodesic) case.

Reference: `workspace/round3_exploration/slot_040.md` (slot 040, "geometry ×
self_reference"),  `workspace/round3_exploration/work_slot_040.md`
§2 (R.540: `M_self(A) = {(u,v,w,h) ∈ ℝ⁴ : v ≤ v_max(ε_avg)}` is a closed
half-space; metric inherited flat `g̃_4D = diag(1/α, β, ξ²/2, λ²/2)`) and
§3 (R.541: the four translation Killing fields `ξ_κ=∂_u, ξ_ζ=∂_v,
ξ_{|K|}=∂_w, ξ_{H_K}=∂_h` give Noether momenta `p_κ, p_ζ, p_{|K|}, p_{H_K}`;
on `M_self` the boundary `∂M_self = {v = v_max}` **breaks** `ξ_ζ`, so the
momentum `p_ζ = β·dv/dτ` is **not conserved** — `dp_ζ/dτ ≠ 0` at a
boundary reflection — while the other three remain conserved).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (formalized geometry × self-reference kernel).**

We work in the slot's log-coordinates `(u, v, w, h) = (log κ, log ζ,
log|K|, H_K)` on the flat 4-D Fisher manifold (R.136 / R.566).

* **(R.540) `M_self` is a closed convex half-space.**  The self-reference
  ceiling `v ≤ v_max` (= `log(1 − ε_avg)`, R.185) cuts the manifold to the
  half-space `M_self = {x ∈ ℝ⁴ : ⟨a, x⟩ ≤ c}` where the cutting covector is
  `a = e_v` (the v-coordinate functional) and `c = v_max`.  We prove, for an
  *arbitrary* covector `a` and level `c`, that `{x : ⟨a,x⟩ ≤ c}` is closed
  (`isClosed_le`) and convex (affine sublevel set), and specialise to the
  `v`-functional to obtain `M_self`.

* **(R.541) `p_ζ` conservation is broken.**  The Noether momentum of the
  `ξ_ζ = ∂_v` translation is `p_ζ(τ) = β · v̇(τ)`.  Along a *free* Fisher
  geodesic the v-velocity is constant (`v̈ = 0`), so `dp_ζ/dτ = β·v̈ = 0`
  (Noether conservation, the R.107/R.121 free-charge case).  At a boundary
  reflection on `∂M_self` the v-velocity is *not* constant (`v̈ ≠ 0`); with
  `β ≠ 0` this forces `dp_ζ/dτ = β·v̈ ≠ 0` — **the conservation law fails**.
  We formalise both: conservation in the free case and its breaking under a
  non-vanishing v-acceleration.

* **Contrast with the other three momenta.**  `p_κ, p_{|K|}, p_{H_K}` are the
  momenta of `∂_u, ∂_w, ∂_h`, whose flows leave `v` fixed; on the
  free-geodesic those velocities stay constant and the momenta are conserved.
  We record the conservation of an `∂_u`-type momentum as the contrast.

**This file is `axiom`-free.**  The Fisher / self-reference semantics enter
only as real-valued data and through bundled hypotheses (the cutting
covector `a`, the level `c = v_max`, the metric coefficient `β`, and the
trajectory's velocity / acceleration via `HasDerivAt`).  All curvature- and
transport-level facts are stated as plain real analysis statements.
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Convex.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Order.OrderClosed
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FunProp

namespace MIP

namespace FisherHalfSpace

open scoped BigOperators

/-- Dimension of the capability phase space `(κ, ζ, |K|, H_K)`. -/
abbrev dim : ℕ := 4

/-- A coordinate point `(u, v, w, h) = (log κ, log ζ, log|K|, H_K)`. -/
abbrev Point := Fin dim → ℝ

/-- The `v = log ζ` coordinate index (the second coordinate). -/
def vIdx : Fin dim := 1

/-! ### Part (a) — `M_self` as a 4-D Fisher closed half-space (R.540) -/

/-- **A linear half-space** `{x : ⟨a, x⟩ ≤ c}` cut by covector `a` at level
`c`, with the inner product written as the coordinate sum `∑ aᵢ xᵢ`. -/
def halfSpace (a : Point) (c : ℝ) : Set Point :=
  {x : Point | (∑ i, a i * x i) ≤ c}

/-- **R.540 (closedness) — a linear half-space is closed.**

`{x : ∑ aᵢ xᵢ ≤ c}` is the sublevel set of the continuous linear functional
`x ↦ ∑ aᵢ xᵢ`, hence closed by `isClosed_le`. -/
theorem halfSpace_isClosed (a : Point) (c : ℝ) :
    IsClosed (halfSpace a c) := by
  unfold halfSpace
  apply isClosed_le
  · fun_prop
  · fun_prop

/-- **R.540 (convexity) — a linear half-space is convex.**

The map `x ↦ ∑ aᵢ xᵢ` is linear, so its sublevel set is convex: for
`x, y` in the set and `s + t = 1`, `s, t ≥ 0`,
`∑ aᵢ (s•x + t•y)ᵢ = s·(∑ aᵢ xᵢ) + t·(∑ aᵢ yᵢ) ≤ s·c + t·c = c`. -/
theorem halfSpace_convex (a : Point) (c : ℝ) :
    Convex ℝ (halfSpace a c) := by
  intro x hx y hy s t hs ht hst
  simp only [halfSpace, Set.mem_setOf_eq] at hx hy ⊢
  have key : (∑ i, a i * (s • x + t • y) i)
      = s * (∑ i, a i * x i) + t * (∑ i, a i * y i) := by
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  rw [key]
  calc s * (∑ i, a i * x i) + t * (∑ i, a i * y i)
      ≤ s * c + t * c :=
        add_le_add (mul_le_mul_of_nonneg_left hx hs)
          (mul_le_mul_of_nonneg_left hy ht)
    _ = c := by rw [← add_mul, hst, one_mul]

/-- **`M_self` — the self-problem submanifold** as the half-space cut by the
`v = log ζ` coordinate at the self-reference ceiling `v_max = log(1−ε_avg)`
(R.185).  Concretely `M_self(v_max) = {x : x_v ≤ v_max}`, using the basis
covector `e_v = Pi.single vIdx 1`. -/
def M_self (vmax : ℝ) : Set Point :=
  halfSpace (Pi.single vIdx (1 : ℝ)) vmax

/-- The cutting functional of `M_self` reduces to the bare `v`-coordinate:
`∑ i, (e_v)ᵢ · xᵢ = x_v`. -/
theorem M_self_functional (x : Point) :
    (∑ i, (Pi.single vIdx (1 : ℝ) : Point) i * x i) = x vIdx := by
  rw [Finset.sum_eq_single vIdx]
  · rw [Pi.single_eq_same, one_mul]
  · intro i _ hi
    rw [Pi.single_eq_of_ne hi, zero_mul]
  · intro h; exact absurd (Finset.mem_univ vIdx) h

/-- **R.540 — `M_self` is exactly the `v`-ceiling slab** `{x : x_v ≤ v_max}`. -/
theorem M_self_eq (vmax : ℝ) :
    M_self vmax = {x : Point | x vIdx ≤ vmax} := by
  unfold M_self halfSpace
  ext x
  simp only [Set.mem_setOf_eq, M_self_functional x]

/-- **R.540 — `M_self` is a 4-D Fisher closed half-space.** -/
theorem M_self_isClosed (vmax : ℝ) : IsClosed (M_self vmax) :=
  halfSpace_isClosed _ _

/-- **R.540 — `M_self` is convex.**  Together with closedness this is the
"closed convex half-space" of slot 040 §2. -/
theorem M_self_convex (vmax : ℝ) : Convex ℝ (M_self vmax) :=
  halfSpace_convex _ _

/-- **C.540.1 — `Σ₀^(Z) = {v → +∞}` is unreachable inside `M_self`.**

No point of `M_self(v_max)` can have `v`-coordinate strictly above the
ceiling; in particular the "zero-impedance" direction `v → +∞` never meets
`M_self`.  Formally: if `x ∈ M_self(v_max)` then `x_v ≤ v_max`, so any `r`
with `r > v_max` is not attained by `x_v`. -/
theorem M_self_v_le (vmax : ℝ) {x : Point} (hx : x ∈ M_self vmax) :
    x vIdx ≤ vmax := by
  rw [M_self_eq] at hx; exact hx

/-! ### Part (b) — `p_ζ` Noether conservation breaking (R.541) -/

/-- **The `p_ζ` Noether momentum** of the `ξ_ζ = ∂_v` translation along a
Fisher geodesic: `p_ζ(τ) = β · v̇(τ)`, where `β = g_vv` (R.125) and `vel`
is the v-velocity field `v̇`. -/
noncomputable def p_zeta (β : ℝ) (vel : ℝ → ℝ) (τ : ℝ) : ℝ :=
  β * vel τ

/-- **R.541 (conserved case) — `p_ζ` is conserved on a FREE geodesic.**

Away from the boundary (interior of `M_self`, or any non-self-referential
task) the metric is flat and translation-invariant in `v`, so the geodesic
v-velocity is constant: `v̈ = 0`.  Then `dp_ζ/dτ = β · v̈ = 0` — the
R.107/R.121 Noether conservation. -/
theorem R_541_p_zeta_conserved_free
    (β : ℝ) (vel : ℝ → ℝ) (τ : ℝ)
    (hvel : HasDerivAt vel 0 τ)        -- v̈ = 0 (free Fisher geodesic)
    : HasDerivAt (p_zeta β vel) 0 τ := by
  unfold p_zeta
  have := hvel.const_mul β
  simpa using this

/-- **R.541 (BREAKING) — `p_ζ` conservation FAILS at a boundary reflection.**

When the geodesic meets `∂M_self = {v = v_max}` the self-reference ceiling
forbids `v > v_max`; the trajectory reflects, so the v-velocity is *not*
locally constant: `v̈ = acc` with `acc ≠ 0`.  With a genuine metric
(`β ≠ 0`) the momentum derivative is
`dp_ζ/dτ = β · v̈ = β · acc ≠ 0`,
i.e. the `ξ_ζ` Killing symmetry is broken and `p_ζ` is **not conserved**.

This is the slot's conservation-law-breaking statement, formalised as a
non-vanishing derivative `dp_ζ/dτ ≠ 0`, in direct contrast with R.107/R.121
where the free system has `dp/dt = 0`. -/
theorem R_541_p_zeta_not_conserved
    (β acc : ℝ) (vel : ℝ → ℝ) (τ : ℝ)
    (hβ : β ≠ 0) (hacc : acc ≠ 0)
    (hvel : HasDerivAt vel acc τ)      -- v̈ = acc ≠ 0 (boundary reflection)
    : HasDerivAt (p_zeta β vel) (β * acc) τ ∧ β * acc ≠ 0 := by
  refine ⟨?_, mul_ne_zero hβ hacc⟩
  unfold p_zeta
  exact hvel.const_mul β

/-- **R.541 (uniqueness of the breaking value) — the broken momentum
derivative is exactly `β·acc`, hence nonzero, hence `≠ 0`.**

A convenience corollary: under the breaking hypotheses there is *no* value
`d` for which `p_ζ` has derivative `0`; the unique derivative is `β·acc ≠ 0`.
This pins down that the Noether conservation literally cannot hold. -/
theorem R_541_p_zeta_deriv_ne_zero
    (β acc : ℝ) (vel : ℝ → ℝ) (τ : ℝ)
    (hβ : β ≠ 0) (hacc : acc ≠ 0)
    (hvel : HasDerivAt vel acc τ)
    : ¬ HasDerivAt (p_zeta β vel) 0 τ := by
  intro h0
  obtain ⟨h, hne⟩ := R_541_p_zeta_not_conserved β acc vel τ hβ hacc hvel
  -- two derivatives of the same function at the same point agree
  exact hne (h0.unique h).symm

/-! ### Contrast — the other three Noether momenta stay conserved (R.541) -/

/-- **The `p_u`-type Noether momentum** of a translation `∂_u, ∂_w, ∂_h`
that does NOT involve `v`: `p(τ) = g · q̇(τ)` with metric coefficient `g`
(e.g. `1/α` for `p_κ`).  Its conservation is the contrast partner of the
broken `p_ζ`. -/
noncomputable def p_other (g : ℝ) (qvel : ℝ → ℝ) (τ : ℝ) : ℝ :=
  g * qvel τ

/-- **R.541 (contrast) — `p_κ, p_{|K|}, p_{H_K}` remain conserved.**

The flows of `∂_u, ∂_w, ∂_h` leave the `v`-coordinate fixed, so the
self-reference ceiling `{v ≤ v_max}` does not obstruct them; on the free
geodesic those velocities are constant (`q̈ = 0`) and the momentum is
conserved `dp/dτ = 0`.  Thus on `M_self` the conservation count drops from 4
to 3 (only `p_ζ` is lost), matching C.541.2. -/
theorem R_541_p_other_conserved
    (g : ℝ) (qvel : ℝ → ℝ) (τ : ℝ)
    (hqvel : HasDerivAt qvel 0 τ)      -- q̈ = 0, flow fixes v
    : HasDerivAt (p_other g qvel) 0 τ := by
  unfold p_other
  have := hqvel.const_mul g
  simpa using this

/-! ### Concrete witness — the breaking is realised (R.541) -/

/-- **R.541 (concrete witness) — a realised conservation-breaking
trajectory.**

Take the slot's reflecting v-trajectory `v(τ) = v_max − (τ − τ₀)²` (a
parabolic turn-around at the boundary `∂M_self` at time `τ₀`), so the
velocity is `vel(τ) = −2(τ − τ₀)` with constant acceleration `v̈ = −2 ≠ 0`.
With a genuine metric `β = β₀ > 0`, the `p_ζ` momentum has derivative
`dp_ζ/dτ = −2β₀ ≠ 0` at `τ₀` — conservation explicitly fails, while the
free-geodesic counterpart (`vel` constant) would give `0`. -/
theorem R_541_breaking_witness (β₀ τ₀ : ℝ) (hβ : 0 < β₀) :
    HasDerivAt (p_zeta β₀ (fun τ => -2 * (τ - τ₀))) (β₀ * (-2)) τ₀
      ∧ β₀ * (-2) ≠ 0 := by
  have hvel : HasDerivAt (fun τ => -2 * (τ - τ₀)) (-2) τ₀ := by
    have hid : HasDerivAt (fun τ : ℝ => τ - τ₀) 1 τ₀ :=
      (hasDerivAt_id τ₀).sub_const τ₀
    simpa using hid.const_mul (-2 : ℝ)
  exact R_541_p_zeta_not_conserved β₀ (-2) _ τ₀ (ne_of_gt hβ)
    (by norm_num) hvel

end FisherHalfSpace

end MIP
