/-
Result R.107 — Lagrangian and Noether conservation laws for the emergent
action `S = ∫ L dt`, `L = (Z/2)·Φ̇² − V(Φ)` (Cj.8).

Reference: `workspace/frontier_attacks.md` §R.107 (攻击 #2, Cj.8).
Status: B (under the R.67-continuation + Lagrangian working definitions).

**Statement.** With the working Lagrangian (`Z` constant)

    L(Φ, Φ̇) = (Z/2)·Φ̇² − V(Φ),

the Euler–Lagrange equation is

    d/dt(∂L/∂Φ̇) − ∂L/∂Φ = Z·Φ̈ + V'(Φ) = 0.

Noether's theorem yields three conserved quantities along EL solutions:

1. **Energy** (t-translation):  `E = Φ̇·∂L/∂Φ̇ − L = (Z/2)·Φ̇² + V(Φ)`,
   with `dE/dt = 0`.
2. **Momentum** (Φ-translation, `V ≡ 0`):  `p = Z·Φ̇`, with `dp/dt = 0`.
3. **Scale** ( (Φ,t) → (λΦ, λt) ):  `Q = Φ·Z·Φ̇ − t·Z·Φ̇²`.

This file encodes the **algebraic conservation kernels**. The "physical"
content — that `Φ` solves the EL equation `Z·Φ̈ + V'(Φ) = 0` and the
chain rule for `d/dt(V∘Φ) = V'(Φ)·Φ̇` — enters as explicit hypotheses
(`hEL`, `hV`); we prove that the named combinations have zero time
derivative.  The derivatives `Φ̇ = a`, `Φ̈ = j`, `(V∘Φ)' = vdot` enter
as scalars at a fixed instant (the bundled calculus facts), so the
conservation statements become the polynomial identities

* `dE/dt = Z·a·j + vdot = 0`           (energy),
* `dp/dt = Z·j = 0`                     (momentum, when `j = 0` forced by EL with `V'=0`),

derived from the EL relation `Z·j + Vprime = 0`.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace NoetherConservation

/-- **R.107 (1) — energy conservation along EL solutions.**

At a fixed instant write `a := Φ̇`, `j := Φ̈`, `Vprime := V'(Φ)`,
`vdot := d/dt(V∘Φ) = V'(Φ)·Φ̇` (chain rule, premise `hV`).  The energy
time-derivative is

    dE/dt = d/dt[ (Z/2)·Φ̇² + V(Φ) ] = Z·Φ̇·Φ̈ + V'(Φ)·Φ̇
          = Φ̇·( Z·Φ̈ + V'(Φ) ).

The Euler–Lagrange relation `Z·j + Vprime = 0` (premise `hEL`) makes the
bracket vanish, so `dE/dt = 0`: energy is conserved. -/
theorem R_107_energy_conserved
    (Z a j Vprime vdot dEdt : ℝ)
    (hV  : vdot = Vprime * a)
    (hEL : Z * j + Vprime = 0)
    (hdE : dEdt = Z * a * j + vdot) :
    dEdt = 0 := by
  rw [hdE, hV]
  -- Z·a·j + Vprime·a = a·(Z·j + Vprime) = a·0 = 0.
  have : Z * a * j + Vprime * a = a * (Z * j + Vprime) := by ring
  rw [this, hEL, mul_zero]

/-- **R.107 (2) — momentum conservation when `V ≡ 0`.**

If the potential vanishes (`Vprime = 0`), the EL relation forces
`Z·Φ̈ = 0`, so the conjugate momentum `p = Z·Φ̇` has time derivative
`dp/dt = Z·Φ̈ = 0`: the emergent "intervention momentum" is conserved
(Φ-translation symmetry). -/
theorem R_107_momentum_conserved
    (Z j dpdt : ℝ)
    (hEL0 : Z * j + 0 = 0)
    (hdp  : dpdt = Z * j) :
    dpdt = 0 := by
  rw [hdp]
  linarith [hEL0]

/-- **R.107 (energy value identity).**

The conserved energy along EL solutions equals the kinetic-plus-potential
form `E = (Z/2)·Φ̇² + V(Φ)`, obtained from the Legendre transform
`E = Φ̇·∂L/∂Φ̇ − L` with `∂L/∂Φ̇ = Z·Φ̇` and `L = (Z/2)·Φ̇² − V`. -/
theorem R_107_energy_legendre
    (Z a V : ℝ) :
    a * (Z * a) - ((Z / 2) * a ^ 2 - V) = (Z / 2) * a ^ 2 + V := by
  ring

/-- **R.107 (3) — scale (Noether) charge time-derivative.**

For the scale symmetry `(Φ,t) → (λΦ, λt)` of the kinetic Lagrangian, the
Noether charge is `Q = Φ·Z·Φ̇ − t·Z·Φ̇²`.  Differentiating (with
`Φ̇ = a`, `Φ̈ = j` at the instant, and `t` the explicit time) gives

    dQ/dt = (Φ̇·Z·Φ̇ + Φ·Z·Φ̈) − (Z·Φ̇² + t·Z·2·Φ̇·Φ̈)
          = Φ·Z·Φ̈ − 2 t·Z·Φ̇·Φ̈
          = Z·Φ̈·(Φ − 2 t·Φ̇).

When `V ≡ 0` the EL relation gives `Z·Φ̈ = 0`, so `dQ/dt = 0`: the scale
charge is conserved. We record the algebraic factorisation plus the
vanishing under `Z·j = 0`. -/
theorem R_107_scale_charge_factor
    (Z Phi t a j : ℝ) :
    (a * (Z * a) + Phi * (Z * j)) - (Z * a ^ 2 + t * (Z * (2 * a * j)))
      = (Z * j) * (Phi - 2 * t * a) := by
  ring

/-- **R.107 (3) — scale charge conserved when `V ≡ 0`.** -/
theorem R_107_scale_conserved
    (Z Phi t a j dQdt : ℝ)
    (hEL0 : Z * j + 0 = 0)
    (hdQ : dQdt = (Z * j) * (Phi - 2 * t * a)) :
    dQdt = 0 := by
  have hZj : Z * j = 0 := by linarith [hEL0]
  rw [hdQ, hZj, zero_mul]

end NoetherConservation

end MIP
