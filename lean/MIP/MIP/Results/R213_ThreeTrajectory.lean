/-
Result R.213 — Geometric distinction of the three "optimal" training
trajectories.  Reference: `branches/geometry/workspace/new_results.md`
(old geom R.144).

**Statement.** On the flat (κ, ζ) Fisher manifold three notions of "optimal"
training give genuinely different curves from an interior start
`(u₀, v₀) = (log κ₀, log ζ₀)` (`s₀ = −u₀ > 0`):

  (i)   **Fisher geodesic** — straight line in `(u, v)`, reaching *any* chosen
        endpoint `(0, v_*)` on `Σ₀^{(κ)}`;
  (ii)  **N natural-gradient flow** — the parabola `v(s) = v₀ + (s₀²−s²)/(2αβ)`,
        terminating at `(0, v_∞)` with `v_∞ = v₀ + s₀²/(2αβ) > v₀`;
  (iii) **Σ₀ vertical shortest path** — moves only in `u`, terminating at
        `(0, v₀)` (the foot of the perpendicular), `v` unchanged.

The three **terminal `v`-values are distinct**: `v(iii) = v₀ < v_∞ = v(ii)`,
and the geodesic (i) can reach any `v_*` (a third, freely chosen value). The
flow (ii) "overshoots" in `ζ` (R.144.a: late-training over-optimisation of ζ).

**Kernel formalized here.**
  (a) **Endpoint of (ii) exceeds (iii).** `v_∞ − v₀ = s₀²/(2αβ) > 0` for an
      interior start (`s₀ > 0`, `α,β > 0`): natural-gradient flow ends at a
      strictly larger `ζ` than vertical descent — distinctness witness.
  (b) **Three pairwise-distinct endpoints** at a concrete sample
      (`α=β=1, s₀=2, v₀=0`): `v(iii)=0`, `v(ii)=2`, and a geodesic target
      `v_*=5` — all different (`decide`/`norm_num`).
  (c) **Path-shape distinction.** The flow image is curved (second `s`-difference
      `−1/(αβ) ≠ 0`) while the geodesic and vertical paths are straight (zero
      second difference) — the same curvature kernel as R.208.
  (d) **Overshoot monotonicity.** `v_∞` grows with the starting deficit `s₀`:
      a worse initial `κ` ⟹ larger ζ-overshoot (R.144.b: terminal state depends
      on initial condition).

**Bridge.** "The three optimal trajectories are geometrically different" is the
content of R.144; distinct terminal `v` + curved-vs-straight images are its
rigorous core.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.NormNum

namespace MIP

namespace R213_ThreeTrajectory

/-- Terminal `v`-coordinate of the **N natural-gradient flow** (trajectory ii):
`v_∞ = v₀ + s₀²/(2αβ)` (R.130/R.144). -/
noncomputable def vEndFlow (α β v0 s0 : ℝ) : ℝ := v0 + s0 ^ 2 / (2 * α * β)

/-- Terminal `v`-coordinate of the **Σ₀ vertical shortest path**
(trajectory iii): `v₀` unchanged (pure `u`-descent). -/
def vEndVertical (v0 : ℝ) : ℝ := v0

/-- **R.213 (a) — natural-gradient flow overshoots vertical descent in `ζ`.**

For an interior start (`s₀ > 0`, `α,β > 0`) the flow terminal exceeds the
vertical terminal: `v_∞ − v₀ = s₀²/(2αβ) > 0`.  Hence trajectories (ii) and
(iii) reach *different* points of `Σ₀^{(κ)}`: they are distinct. -/
theorem R_213_a_flow_overshoots
    (α β v0 s0 : ℝ) (hα : 0 < α) (hβ : 0 < β) (hs : 0 < s0) :
    vEndVertical v0 < vEndFlow α β v0 s0 := by
  unfold vEndVertical vEndFlow
  have hpos : 0 < s0 ^ 2 / (2 * α * β) := by positivity
  linarith

/-- **R.213 (a′) — exact overshoot magnitude.** `v_∞ − v₀ = s₀²/(2αβ)`. -/
theorem R_213_a_overshoot_value (α β v0 s0 : ℝ) :
    vEndFlow α β v0 s0 - vEndVertical v0 = s0 ^ 2 / (2 * α * β) := by
  unfold vEndFlow vEndVertical
  ring

/-- **R.213 (b) — three pairwise-distinct terminal `v`-values at a sample.**

With `α = β = 1`, `v₀ = 0`, `s₀ = 2`:
  * vertical (iii) terminal `v = 0`,
  * flow (ii) terminal `v = 0 + 4/(2·1·1) = 2`,
  * geodesic (i) can be aimed at any `v_* `, e.g. `v_* = 5`.
All three are different, so the three optimal trajectories are genuinely
distinct geometric objects. -/
theorem R_213_b_three_distinct :
    vEndVertical 0 ≠ vEndFlow 1 1 0 2 ∧
    vEndFlow 1 1 0 2 ≠ (5 : ℝ) ∧
    vEndVertical 0 ≠ (5 : ℝ) := by
  refine ⟨?_, ?_, ?_⟩
  · unfold vEndVertical vEndFlow; norm_num
  · unfold vEndFlow; norm_num
  · unfold vEndVertical; norm_num

/-- The phase image of the natural-gradient flow: `v` as a function of
`s = |u|`, `v(s) = v₀ + (s₀²−s²)/(2αβ)` (a parabola). -/
noncomputable def flowPhase (α β v0 s0 s : ℝ) : ℝ := v0 + (s0 ^ 2 - s ^ 2) / (2 * α * β)

/-- **R.213 (c) — the flow image is curved (nonzero second `s`-difference).**

The discrete second difference of `flowPhase` equals `−1/(αβ) ≠ 0`, so the
flow (ii) image is genuinely curved.  A geodesic (i) or vertical (iii) path is
straight in these coordinates (zero second difference).  This separates (ii)
from (i) and (iii) by *shape*, not only endpoint. -/
theorem R_213_c_flow_curved
    (α β v0 s0 : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    (flowPhase α β v0 s0 3 - flowPhase α β v0 s0 2)
      - (flowPhase α β v0 s0 2 - flowPhase α β v0 s0 1)
        = -(1 : ℝ) / (α * β) := by
  unfold flowPhase
  have hα' : α ≠ 0 := ne_of_gt hα
  have hβ' : β ≠ 0 := ne_of_gt hβ
  field_simp
  ring

theorem R_213_c_flow_curved_ne_zero
    (α β v0 s0 : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    (flowPhase α β v0 s0 3 - flowPhase α β v0 s0 2)
      - (flowPhase α β v0 s0 2 - flowPhase α β v0 s0 1) ≠ 0 := by
  rw [R_213_c_flow_curved α β v0 s0 hα hβ]
  have hpos : 0 < α * β := mul_pos hα hβ
  have : -(1 : ℝ) / (α * β) < 0 := by
    apply div_neg_of_neg_of_pos <;> [norm_num; exact hpos]
  linarith

/-- A straight path (geodesic or vertical) has zero second difference: its
`v`-coordinate is affine in the parameter, here represented by `v(s) = a + b·s`. -/
def straightPhase (a b s : ℝ) : ℝ := a + b * s

theorem R_213_c_straight_flat (a b : ℝ) :
    (straightPhase a b 3 - straightPhase a b 2)
      - (straightPhase a b 2 - straightPhase a b 1) = 0 := by
  unfold straightPhase
  ring

/-- **R.213 (d) — overshoot grows with the initial κ-deficit.**

If start (1) has a larger `s₀` (worse initial `κ`) than start (2), its
natural-gradient terminal `ζ` overshoots more: `v_∞(s₀¹) > v_∞(s₀²)` (same
`α, β, v₀`).  R.144.b: the trained terminal state depends on initial
conditions — different starts give different "completed AIs". -/
theorem R_213_d_overshoot_monotone
    (α β v0 s1 s2 : ℝ) (hα : 0 < α) (hβ : 0 < β)
    (hs2 : 0 ≤ s2) (h12 : s2 < s1) :
    vEndFlow α β v0 s2 < vEndFlow α β v0 s1 := by
  unfold vEndFlow
  have hden : 0 < 2 * α * β := by positivity
  have hsq : s2 ^ 2 < s1 ^ 2 := by nlinarith
  have hdiv : s2 ^ 2 / (2 * α * β) < s1 ^ 2 / (2 * α * β) := by
    gcongr
  linarith

end R213_ThreeTrajectory

end MIP
