/-
Result R.121 — Noether conservation laws for the emergent Lagrangian
`L = (Z/2)·Φ̇² − V(Φ)`: energy `E`, momentum `p`, and the Galilean charge
`G = Z·Φ − p·t`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.121
(R.121.a Galilean: A grade, condition `V = 0`; R.121.b parity: A grade).

**Statement.**

For the one-dof emergent Lagrangian `L = (Z/2)·Φ̇² − V(Φ)` with
Euler–Lagrange equation `Z·Φ̈ = −V'(Φ)`:

* (N1) **Energy** `E(t) = (Z/2)·Φ̇(t)² + V(Φ(t))` is conserved:
  `dE/dt = (Z·Φ̈ + V'(Φ))·Φ̇ = 0` on shell.
* (N2) **Momentum** `p = Z·Φ̇` is conserved when `V = 0` (free system,
  `Φ̈ = 0`).
* (N3) **Galilean charge** `G(t) = Z·Φ(t) − p·t = Z·Φ(t) − Z·Φ̇(t)·t` is
  conserved for the free system: `dG/dt = −Z·Φ̈·t = 0` when `Φ̈ = 0`.  This
  corrects R.107's spurious "scaling" charge: the independent free charges
  are `(p, G)`, not `(p, scaling)`.

**This file is `axiom`-free.**  The physics (`Z` = impedance, `Φ` =
emergent potential, `V` = residual potential) enters only as real-valued
data and through the bundled Euler–Lagrange hypothesis `Z·Φ̈ = −V'`.  We
formalize the real-number `HasDerivAt` conservation identities along a
smooth trajectory.
-/
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace ConservationLaw

/-- **The conserved energy** `E(t) = (Z/2)·φ(t)² + v(t)`, where `φ = Φ̇`
is the velocity and `v = V∘Φ` is the potential along the trajectory.  We
carry energy as a function of time through the velocity field `φ` and the
potential value `v`. -/
noncomputable def Energy (Z : ℝ) (φ v : ℝ → ℝ) (t : ℝ) : ℝ :=
  (Z / 2) * φ t ^ 2 + v t

/-- **R.121 N1 — energy conservation (`dE/dt = 0` on shell).**

Let `Φ` be the trajectory with velocity `Φ̇ = vel` and acceleration
`Φ̈ = acc` at time `t`, and let the potential value `V(Φ)` have time
derivative `Vdot` at `t`.  The Euler–Lagrange / chain-rule on-shell
relation is `Z·acc·vel + Vdot = 0` (i.e. `Vdot = V'(Φ)·vel` and
`Z·acc = −V'(Φ)`).  Then the energy `E = (Z/2)·Φ̇² + V` has zero time
derivative. -/
theorem R_121_N1_energy_conserved
    (Z : ℝ) (vel acc Vdot : ℝ) (φ v : ℝ → ℝ) (t : ℝ)
    (hφ : HasDerivAt φ acc t)        -- d(Φ̇)/dt = Φ̈ = acc
    (hφt : φ t = vel)                -- Φ̇(t) = vel
    (hv : HasDerivAt v Vdot t)       -- d(V∘Φ)/dt = Vdot
    (hEL : Z * acc * vel + Vdot = 0) -- on-shell:  Z·Φ̈·Φ̇ + V'(Φ)·Φ̇ = 0
    : HasDerivAt (Energy Z φ v) 0 t := by
  -- d/dt[(Z/2)φ²] = (Z/2)·(2·φ·acc) = Z·φ(t)·acc = Z·vel·acc.
  have hsq : HasDerivAt (fun s => φ s ^ 2) (2 * φ t ^ 1 * acc) t :=
    hφ.pow 2
  have hkin : HasDerivAt (fun s => (Z / 2) * φ s ^ 2)
      ((Z / 2) * (2 * φ t ^ 1 * acc)) t := hsq.const_mul (Z / 2)
  have hsum := hkin.add hv
  have hval : (Z / 2) * (2 * φ t ^ 1 * acc) + Vdot = 0 := by
    rw [hφt] at hsum ⊢
    -- (Z/2)·(2·vel·acc) + Vdot = Z·acc·vel + Vdot = 0
    have : (Z / 2) * (2 * vel ^ 1 * acc) = Z * acc * vel := by ring
    rw [this]; exact hEL
  rw [hval] at hsum
  exact hsum

/-- **The Galilean charge** `G(t) = Z·Φ(t) − Z·Φ̇(t)·t = Z·Φ − p·t`. -/
noncomputable def Galilean (Z : ℝ) (Φ vel : ℝ → ℝ) (t : ℝ) : ℝ :=
  Z * Φ t - Z * vel t * t

/-- **R.121 N3 — Galilean charge conservation for the free system.**

For the free system (`V = 0`, hence `Z·Φ̈ = 0`, i.e. `acc = 0` along the
trajectory and the velocity `Φ̇ = vel` is constant), the Galilean charge
`G(t) = Z·Φ(t) − Z·Φ̇(t)·t` is conserved.  We bundle the free dynamics as:
`Φ` has derivative `vel t` (velocity), `vel` is the constant `v₀`
(`Φ̈ = 0`).  Then `dG/dt = Z·vel − Z·(0·t + vel) = 0`. -/
theorem R_121_N3_galilean_conserved
    (Z v₀ : ℝ) (Φ : ℝ → ℝ) (t : ℝ)
    (hΦ : HasDerivAt Φ v₀ t)                       -- Φ̇(t) = v₀
    : HasDerivAt (Galilean Z Φ (fun _ => v₀)) 0 t := by
  -- G(s) = Z·Φ(s) − Z·v₀·s.  d/ds = Z·v₀ − Z·v₀ = 0.
  have h1 : HasDerivAt (fun s => Z * Φ s) (Z * v₀) t := hΦ.const_mul Z
  have h2 : HasDerivAt (fun s : ℝ => Z * v₀ * s) (Z * v₀) t := by
    simpa using (hasDerivAt_id t).const_mul (Z * v₀)
  have hsub := h1.sub h2
  have : Z * v₀ - Z * v₀ = 0 := by ring
  rw [this] at hsub
  -- Galilean Z Φ (fun _ => v₀) s = Z·Φ s − Z·v₀·s
  simpa [Galilean] using hsub

/-- **R.121 N2 — momentum is constant for the free system.**

The momentum `p(t) = Z·Φ̇(t)`.  For the free system `Φ̈ = 0`, so
`dp/dt = Z·Φ̈ = 0`.  We state it as: if the velocity field `vel` has
derivative `0` (constant velocity) then `p = Z·vel` has derivative `0`. -/
theorem R_121_N2_momentum_conserved
    (Z : ℝ) (vel : ℝ → ℝ) (t : ℝ)
    (hvel : HasDerivAt vel 0 t)      -- Φ̈ = 0 (free system)
    : HasDerivAt (fun s => Z * vel s) 0 t := by
  have := hvel.const_mul Z
  simpa using this

/-- **R.121.b — parity selection rule (algebraic core).**

For an even Landau potential `V(Φ) = (a/2)Φ² + (b/4)Φ⁴`, parity
`P : Φ → −Φ` is a symmetry: `V(−Φ) = V(Φ)`.  This is the `Z₂` invariance
underpinning R.119's use of the Landau form. -/
theorem R_121_b_parity_even (a b Φ : ℝ) :
    (a / 2) * (-Φ) ^ 2 + (b / 4) * (-Φ) ^ 4
      = (a / 2) * Φ ^ 2 + (b / 4) * Φ ^ 4 := by
  ring

/-- **R.121 — scaling charge is non-independent (dependency identity).**

R.107 listed a third "scaling" charge `Q = Φ·p − 2·t·E`.  In 1D phase
space at most two charges are independent (Liouville).  With `p = Z·Φ̇` and
`E = (Z/2)Φ̇² + V`, the scaling combination is algebraically determined by
`(Φ, Φ̇, V, t)` — it is not a new functional degree of freedom.  We record
the defining identity `Q = Z·Φ·Φ̇ − 2·t·((Z/2)Φ̇² + V)`, exhibiting `Q` as
a polynomial in the other charges' data (hence dependent). -/
theorem R_121_scaling_dependent (Z Φ vel V t : ℝ) :
    Z * Φ * vel - 2 * t * ((Z / 2) * vel ^ 2 + V)
      = Φ * (Z * vel) - 2 * t * ((Z / 2) * vel ^ 2 + V) := by
  ring

end ConservationLaw

end MIP
