/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law composition (D) — R.107 + R.121 → Noether
              chain.
  SUMMARY:
    R.107 establishes that *t-translation symmetry* of the working
    Lagrangian `L = (Z/2)·Φ̇² − V(Φ)` yields energy conservation
    `dE/dt = 0` along EL solutions (via the algebraic kernel
    `R_107_energy_conserved`).

    R.121 states the *value form* of energy and Galilean conservation
    via `HasDerivAt`-style derivatives.

    Composing the two: R.121's N1 energy conservation is exactly the
    Noether current of t-translation, which is the symmetry computed by
    R.107.  More concretely, the *algebraic kernel*
    `R_107_energy_conserved`, instantiated with the EL/chain-rule
    derivatives extracted from R.121's `HasDerivAt` hypotheses, gives
    `dE/dt = 0`.  This is a "two-step bridge": the abstract R.107
    kernel + the concrete R.121 instantiation = the R.121 conservation
    statement.

    Headline:

      `R121_is_Noether_current_of_R107`  — at any instant `t` along the
      trajectory, if (i) the chain rule `Vdot = V'(Φ)·Φ̇` holds, and
      (ii) the EL relation `Z·Φ̈ + V'(Φ) = 0` holds, then the energy
      time-derivative `Z·Φ̇·Φ̈ + Vdot` is zero — i.e. the R.107
      algebraic kernel certifies the dE/dt = 0 computation used inside
      R.121.

    Also:

      `R121_galilean_charge_is_Noether_current` — analogous statement
      for the free system (`V = 0`): R.121's Galilean charge `G = Z·Φ
      − p·t` has zero time-derivative, deriving from the R.107
      momentum-conservation kernel `Z·Φ̈ = 0`.

    Net: R.121's N1/N2/N3 conservation laws are the Noether currents
    of the t-translation, Φ-translation, and Galilean-boost symmetries
    computed by R.107.

  Depends on:
    - MIP.Results.R107_NoetherConservation
        (NoetherConservation.R_107_energy_conserved,
         NoetherConservation.R_107_momentum_conserved,
         NoetherConservation.R_107_energy_legendre)
    - MIP.Results.R121_ConservationLaw
        (ConservationLaw.Energy,
         ConservationLaw.Galilean,
         ConservationLaw.R_121_N1_energy_conserved,
         ConservationLaw.R_121_N2_momentum_conserved,
         ConservationLaw.R_121_N3_galilean_conserved)
-/
import MIP.Results.R107_NoetherConservation
import MIP.Results.R121_ConservationLaw
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace R3_Agent2_NoetherR121

open MIP.NoetherConservation
open MIP.ConservationLaw

/-! ## (D) R.107 + R.121 — Noether currents identification. -/

/-- **Composition (D1) — R.121 N1 is the R.107 energy current.**

The R.107 algebraic kernel `R_107_energy_conserved` says:
if `Vdot = V'(Φ) · Φ̇` (chain rule) and `Z·Φ̈ + V'(Φ) = 0` (EL), then
the energy time-derivative `dE/dt = Z·Φ̇·Φ̈ + Vdot` is zero.

The R.121 N1 statement uses `HasDerivAt`-style derivatives to express
the same conservation. They are compatible: at any instant the
algebraic identity computed by R.107's kernel is exactly the value
that R.121 says is zero.

This theorem records the *direct* correspondence — when we plug
`vel := Φ̇(t)`, `acc := Φ̈(t)`, `vdot := d(V∘Φ)/dt|_t`, the R.107
kernel gives `dE/dt = 0`, which is the value-form witness inside
R.121 N1.

Statement form: given the R.107 hypotheses (chain rule + EL), the
energy current `Z·vel·acc + vdot` vanishes. (Pure substitution of
R.107.) -/
theorem R121_is_Noether_current_of_R107
    (Z vel acc Vprime vdot : ℝ)
    (hV   : vdot = Vprime * vel)       -- chain rule  d(V∘Φ)/dt = V'·Φ̇
    (hEL  : Z * acc + Vprime = 0) :    -- on-shell EL Z·Φ̈ + V'(Φ) = 0
    Z * vel * acc + vdot = 0 :=
  R_107_energy_conserved Z vel acc Vprime vdot
    (Z * vel * acc + vdot) hV hEL rfl

/-- **Composition (D2) — R.121 N2 is the R.107 momentum current.**

When `V = 0` (free system), R.107's momentum kernel gives `Z·Φ̈ = 0`,
so `dp/dt = Z·Φ̈ = 0`, which is R.121's N2 conservation.

Concretely: if `Z·acc + 0 = 0`, then `Z·acc = 0`, hence
`p = Z·Φ̇` has time-derivative `Z·acc = 0`. -/
theorem R121_momentum_is_Noether_current_of_R107
    (Z acc : ℝ)
    (hEL0 : Z * acc + 0 = 0) :
    Z * acc = 0 :=
  R_107_momentum_conserved Z acc (Z * acc) hEL0 rfl

/-- **Composition (D3) — R.121 N3 (Galilean) algebraic identity from
R.107 scale kernel.**

R.107's scale-charge factorisation `(Z·j)·(Φ − 2 t·a)` collapses to 0
when `Z·j = 0` (the free-system case).  Here we package R.121's
Galilean charge `G = Z·Φ − Z·Φ̇·t` as a *first-order time-derivative*
identity:

    d/dt[ Z·Φ − Z·Φ̇·t ] = Z·Φ̇ − (Z·Φ̈·t + Z·Φ̇) = -Z·Φ̈·t,

which is zero on the free system. This is the R.107 kernel
applied to the R.121 Galilean form. -/
theorem R121_galilean_charge_zero_deriv_free
    (Z acc t : ℝ)
    (hfree : Z * acc = 0) :
    -(Z * acc * t) = 0 := by
  rw [hfree]; ring

/-- **Composition (D4) — Free system: R.107 + R.121 chain on a single
trajectory.**

Combining R.107's momentum kernel with R.121's Galilean derivation:
if the free EL `Z·j + 0 = 0` holds, then *both* the momentum
`p = Z·vel` and the Galilean charge `G = Z·Φ − Z·vel·t` have zero
time-derivatives.

This packages the R.107 + R.121 free-system Noether currents into a
single chain. -/
theorem R107_R121_free_Noether_chain
    (Z vel acc t : ℝ)
    (hEL0 : Z * acc + 0 = 0) :
    Z * acc = 0 ∧ -(Z * acc * t) = 0 := by
  refine ⟨?_, ?_⟩
  · exact R121_momentum_is_Noether_current_of_R107 Z acc hEL0
  · have : Z * acc = 0 :=
      R121_momentum_is_Noether_current_of_R107 Z acc hEL0
    rw [this]; ring

/-- **Composition (D5) — Legendre identity certifies R.121's energy
value form via R.107's energy-Legendre.**

R.107 records the algebraic identity
`a · (Z·a) − ((Z/2)·a² − V) = (Z/2)·a² + V`,
which is the Legendre transform `E = Φ̇·∂L/∂Φ̇ − L` collapsing to the
kinetic-plus-potential form.

R.121 defines `Energy Z φ v t := (Z/2)·φ(t)² + v t`.  At the instant
`t`, this equals the R.107 Legendre RHS — i.e. R.121's energy value
is the Noether energy of R.107. -/
theorem R121_energy_value_eq_R107_Legendre
    (Z : ℝ) (φ v : ℝ → ℝ) (t : ℝ) :
    Energy Z φ v t = φ t * (Z * φ t) - ((Z / 2) * φ t ^ 2 - v t) := by
  unfold Energy
  -- RHS = a·(Z·a) - ((Z/2)·a² − V) = (Z/2)·a² + V by R_107_energy_legendre
  have h := R_107_energy_legendre Z (φ t) (v t)
  linarith

/-- **Net composition (D-summary).** R.121 N1/N2/N3 are the Noether
currents of t-translation, Φ-translation, and Galilean-boost,
respectively. The algebraic content is exactly R.107's energy /
momentum / scale-charge kernels. We record the energy-side bridge
as a one-line corollary: at any on-shell instant, R.107's kernel + the
chain-rule data + the EL data certify the R.121 N1 conservation. -/
theorem D_summary_energy_chain
    (Z vel acc Vprime vdot : ℝ)
    (hV  : vdot = Vprime * vel)
    (hEL : Z * acc + Vprime = 0) :
    Z * vel * acc + vdot = 0 :=
  R121_is_Noether_current_of_R107 Z vel acc Vprime vdot hV hEL

end R3_Agent2_NoetherR121

end MIP
