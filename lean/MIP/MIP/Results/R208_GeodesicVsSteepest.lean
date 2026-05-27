/-
Result R.208 — Fisher geodesic vs the N steepest-descent flow:
geometric distinction of three "optimal" training trajectories.
Reference: `branches/geometry/workspace/new_results.md` (old geom R.130).

**Statement.** On the flat (κ, ζ) Fisher manifold (R.126), three "natural"
training dynamics are *distinct*:

  (i)   the Fisher **geodesic** — a straight line in `(u, v) = (log κ, log ζ)`,
        velocity `(du/dτ, dv/dτ) = (a, b)` constant;
  (ii)  the **Gompertz κ-only** flow `dκ/dt = −α·κ·log κ` — natural gradient
        of the surrogate loss `(log κ)²/2`, moving only in the `u` direction;
  (iii) the **N steepest-descent / natural-gradient flow** (R.128), in
        `(u, v)` coordinates
            du/dt = α·c·e^{−v},   dv/dt = c·|u|·e^{−v}/β,
        whose phase-plane image is the **parabola** `v(s) = v₀ + (s₀²−s²)/(2αβ)`
        with `s = −u > 0` — *not* a straight line, hence *not* a geodesic image.

**Kernel formalized here.** The three direction vectors at a concrete interior
sample point are pairwise unequal (a distinctness witness proved by `norm_num`),
and the steepest-descent phase slope `dv/ds = −s/(αβ)` is non-constant (depends
on `s`), so its image is genuinely curved (second derivative `≠ 0`) — it cannot
be the straight geodesic. The Gompertz flow has zero `v`-component, separating
it from both. We also record the exact direction-ratio identity
`(∇_nat N)^v / (∇_nat N)^u = |u|/(α·β)` (R.130).

**Bridge.** The three geometric objects (geodesic line, Gompertz κ-axis flow,
N-natural-gradient parabola) are the same three "optimal" trajectories of the
NL result; distinctness at a sample point + curvature of (iii) is the rigorous
core of "they are pairwise different".

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

namespace MIP

namespace R208_GeodesicVsSteepest

open Real

/-- The N natural-gradient (steepest-descent) velocity in `(u, v)` coordinates
(R.128/R.130).  With `s := -u > 0` the components are
`du/dt = α·c·e^{−v}` and `dv/dt = c·s·e^{−v}/β`. -/
noncomputable def steepestU (α c v : ℝ) : ℝ := α * c * Real.exp (-v)
noncomputable def steepestV (β c s v : ℝ) : ℝ := c * s * Real.exp (-v) / β

/-- **R.208 (1) — exact direction ratio of the N natural-gradient flow.**

The phase-plane slope of the steepest-descent flow is
`(dv/dt)/(du/dt) = s/(α·β)` with `s = |u|`.  This is the R.130 identity
`(∇_nat N)^v / (∇_nat N)^u = |u|/(α·β)`. -/
theorem R_208_steepest_ratio
    (α β c s v : ℝ) (hα : α ≠ 0) (hβ : β ≠ 0) (hc : c ≠ 0) :
    steepestV β c s v / steepestU α c v = s / (α * β) := by
  unfold steepestU steepestV
  have he : Real.exp (-v) ≠ 0 := Real.exp_ne_zero _
  field_simp

/-- The phase-trajectory of the N steepest-descent flow: `v` as a quadratic
function of `s` (R.130 integration `v(s) = v₀ + (s₀² − s²)/(2αβ)`). -/
noncomputable def steepestPhase (α β v0 s0 s : ℝ) : ℝ := v0 + (s0 ^ 2 - s ^ 2) / (2 * α * β)

/-- **R.208 (2) — the steepest-descent image is curved (a parabola).**

`d(v)/ds = −s/(α·β)` is *non-constant* in `s`: the slope at `s = 1` differs
from the slope at `s = 2` (for positive `α, β`).  A straight geodesic image has
constant slope, so the steepest-descent flow is NOT a geodesic image.  We
exhibit the slope difference directly. -/
theorem R_208_phase_slope_nonconstant
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    -(1 : ℝ) / (α * β) ≠ -(2 : ℝ) / (α * β) := by
  have hpos : 0 < α * β := mul_pos hα hβ
  have hne : (α * β) ≠ 0 := ne_of_gt hpos
  intro h
  have h2 : (-(1 : ℝ)) = -(2 : ℝ) := by
    field_simp at h
    linarith
  norm_num at h2

/-- **R.208 (3) — the parabola is strictly convex (second `s`-derivative ≠ 0).**

The discrete second difference of `steepestPhase` in `s`,
`[φ(s+1) − φ(s)] − [φ(s) − φ(s−1)] = −1/(α·β) ≠ 0`, is nonzero, certifying
genuine curvature of the steepest-descent image — a straight line has zero
second difference.  Computed at a sample base point. -/
theorem R_208_phase_curved
    (α β v0 s0 : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    (steepestPhase α β v0 s0 3 - steepestPhase α β v0 s0 2)
      - (steepestPhase α β v0 s0 2 - steepestPhase α β v0 s0 1)
        = -(1 : ℝ) / (α * β) := by
  unfold steepestPhase
  have hα' : α ≠ 0 := ne_of_gt hα
  have hβ' : β ≠ 0 := ne_of_gt hβ
  field_simp
  ring

theorem R_208_phase_curved_ne_zero
    (α β v0 s0 : ℝ) (hα : 0 < α) (hβ : 0 < β) :
    (steepestPhase α β v0 s0 3 - steepestPhase α β v0 s0 2)
      - (steepestPhase α β v0 s0 2 - steepestPhase α β v0 s0 1) ≠ 0 := by
  rw [R_208_phase_curved α β v0 s0 hα hβ]
  have hpos : 0 < α * β := mul_pos hα hβ
  have : -(1 : ℝ) / (α * β) < 0 := by
    apply div_neg_of_neg_of_pos <;> [norm_num; exact hpos]
  linarith

/-- A trajectory direction in `(u, v)` coordinates is a pair `(du, dv)`. -/
abbrev Dir := ℝ × ℝ

/-- Geodesic direction: an arbitrary constant velocity `(a, b)` (a straight
line in log-coordinates, R.126 flatness). -/
def geodesicDir (a b : ℝ) : Dir := (a, b)

/-- Gompertz κ-only direction: moves only in `u`, `v`-component is `0`. -/
def gompertzDir (du : ℝ) : Dir := (du, 0)

/-- N steepest-descent direction at `(s, v)`: `(α·c·e^{−v}, c·s·e^{−v}/β)`. -/
noncomputable def steepestDir (α β c s v : ℝ) : Dir := (steepestU α c v, steepestV β c s v)

/-- **R.208 (4) — the three trajectory directions are pairwise distinct at a
concrete interior sample point.**

Take `α = β = c = 1`, sample point `s = 1`, `v = 0` (so `e^{−v} = 1`):
  * geodesic direction (choose `(a, b) = (1, 0)`),
  * Gompertz direction `(du, 0)` with `du = 1`,
  * steepest-descent direction `(1, 1)`.
The steepest-descent direction has a *nonzero* `v`-component (`= 1`), whereas
both the chosen geodesic and the Gompertz direction have `v`-component `0`, and
the geodesic/Gompertz coincidence is broken by choosing different geodesic
velocity below.  This is the distinctness witness. -/
theorem R_208_steepest_ne_gompertz :
    steepestDir 1 1 1 1 0 ≠ gompertzDir 1 := by
  unfold steepestDir gompertzDir steepestU steepestV
  simp only [ne_eq, Prod.mk.injEq, not_and]
  intro _
  norm_num

/-- **R.208 (4′) — steepest-descent distinct from a generic geodesic.**

With geodesic velocity `(a, b) = (1, 0)` (the natural "κ-only geodesic"), the
steepest-descent direction `(1, 1)` differs in the `v`-component. -/
theorem R_208_steepest_ne_geodesic :
    steepestDir 1 1 1 1 0 ≠ geodesicDir 1 0 := by
  unfold steepestDir geodesicDir steepestU steepestV
  simp only [ne_eq, Prod.mk.injEq, not_and]
  intro _
  norm_num

/-- **R.208 (4″) — geodesic distinct from Gompertz when the geodesic has a
nonzero `v`-velocity.**

A geodesic with `b ≠ 0` moves in `v`; the Gompertz flow never does.  Hence the
three are genuinely three different objects (the only way geodesic = Gompertz
is the measure-zero coincidence `b = 0`). -/
theorem R_208_geodesic_ne_gompertz (a b du : ℝ) (hb : b ≠ 0) :
    geodesicDir a b ≠ gompertzDir du := by
  unfold geodesicDir gompertzDir
  simp only [ne_eq, Prod.mk.injEq, not_and]
  intro _
  exact hb

end R208_GeodesicVsSteepest

end MIP
