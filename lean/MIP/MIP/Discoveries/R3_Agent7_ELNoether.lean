/-
  STATUS: DISCOVERY
  AGENT: R3_Agent7
  DIRECTION: Item (E) — R.111 (Euler-Lagrange) + R.107 (Noether) →
    "stationary trajectories of EL admit Noether conservation in the form of
    R.107's currents".  Pure formal composition.
  SUMMARY:
    R.111 says: stationary action `δS = 0 ⟺ EL residual Z·Φ̈ + V'(Φ) = 0`
                pointwise.
    R.107 says: under the EL relation, the energy `E = (Z/2)·Φ̇² + V(Φ)`,
                the momentum `p = Z·Φ̇` (when `V ≡ 0`), and the scale
                charge `Q = Φ·Z·Φ̇ − t·Z·Φ̇²` (when `V ≡ 0`) all have zero
                time derivative.

    Compose: from the stationary action principle alone (R.111's δS = 0),
    all three R.107 conserved currents (E, p, Q) follow with zero time
    derivative.  We make the chain explicit:

       (E1)  δS = 0  →[R.111]→  Z·Φ̈ + V'(Φ) = 0  →[R.107(1)]→  dE/dt = 0
       (E2)  δS = 0  +  V ≡ 0  →[R.111]→  Z·Φ̈ = 0  →[R.107(2)]→  dp/dt = 0
       (E3)  δS = 0  +  V ≡ 0  →[R.111]→  Z·Φ̈ = 0  →[R.107(3)]→  dQ/dt = 0

    This is a pure formal composition — each step is just substitution
    of one R-result's conclusion into the next R-result's hypothesis,
    yielding a chain "action principle ⟹ three Noether currents".

  Depends on:
    - MIP.Results.R107_NoetherConservation
        (NoetherConservation.R_107_energy_conserved,
         NoetherConservation.R_107_momentum_conserved,
         NoetherConservation.R_107_scale_conserved)
    - MIP.Results.R111_MinimalActionEL
        (MinimalActionEL.elResidual,
         MinimalActionEL.R_111_iii_stationary_implies_EL)
-/
import MIP.Results.R107_NoetherConservation
import MIP.Results.R111_MinimalActionEL
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent7_ELNoether

open MIP.NoetherConservation
open MIP.MinimalActionEL

/-! ## (E1) Action principle ⟹ energy conservation. -/

/-- **(E1) Stationary action ⟹ energy conservation.**

If the action is stationary (`∀ δΦ, varS δΦ = 0`) and the variational
representation premise `h_flcv` is supplied, then by R.111 (iii) the EL
residual vanishes pointwise; feeding this into R.107 (1) at any instant
yields `dE/dt = 0`. -/
theorem stationary_implies_energy_conservation
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi Vprime t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t a vdot dEdt : ℝ)
    (hV  : vdot = Vprime t * a)
    (hdE : dEdt = Z * a * (ddPhi t) + vdot) :
    dEdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + Vprime t = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi Vprime varS h_flcv h_stat
  exact R_107_energy_conserved Z a (ddPhi t) (Vprime t) vdot dEdt hV
    (hEL_all t) hdE

/-! ## (E2) Action principle + V ≡ 0 ⟹ momentum conservation. -/

/-- **(E2) Stationary action + V ≡ 0 ⟹ momentum conservation.**

For the free Lagrangian (`Vprime ≡ 0`), R.111 gives `Z·Φ̈ = 0` from
δS = 0, and R.107 (2) turns this into `dp/dt = 0` for the conjugate
momentum `p = Z·Φ̇`. -/
theorem stationary_implies_momentum_conservation
    (Z : ℝ) (ddPhi : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi (fun _ => (0 : ℝ)) t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t dpdt : ℝ)
    (hdp : dpdt = Z * (ddPhi t)) :
    dpdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + (0 : ℝ) = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi (fun _ => 0) varS h_flcv h_stat
  exact R_107_momentum_conserved Z (ddPhi t) dpdt (hEL_all t) hdp

/-! ## (E3) Action principle + V ≡ 0 ⟹ scale charge conservation. -/

/-- **(E3) Stationary action + V ≡ 0 ⟹ scale charge conservation.**

For the free Lagrangian, R.111 gives `Z·Φ̈ = 0` from δS = 0, and R.107 (3)
turns this into `dQ/dt = 0` for the scale Noether charge
`Q = Φ·Z·Φ̇ − t·Z·Φ̇²`. -/
theorem stationary_implies_scale_conservation
    (Z : ℝ) (ddPhi : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi (fun _ => (0 : ℝ)) t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t Phi a dQdt : ℝ)
    (hdQ : dQdt = (Z * (ddPhi t)) * (Phi - 2 * t * a)) :
    dQdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + (0 : ℝ) = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi (fun _ => 0) varS h_flcv h_stat
  exact R_107_scale_conserved Z Phi t a (ddPhi t) dQdt (hEL_all t) hdQ

/-! ## Headline (E) — three Noether currents from one action principle. -/

/-- **HEADLINE (E)** — A single stationary action principle (R.111's δS = 0)
implies *three* Noether-conservation laws (R.107 energy, momentum, scale
charge) simultaneously, in the free-Lagrangian regime V ≡ 0.

This packages items (E1, E2, E3) into one statement.  Each component
follows by a single substitution of the R.111 conclusion into the
corresponding R.107 conservation theorem. -/
theorem R3_Agent7_HEADLINE_three_noether_currents
    (Z : ℝ) (ddPhi : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi (fun _ => (0 : ℝ)) t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t Phi a vdot dEdt dpdt dQdt : ℝ)
    (hV  : vdot = 0 * a)
    (hdE : dEdt = Z * a * (ddPhi t) + vdot)
    (hdp : dpdt = Z * (ddPhi t))
    (hdQ : dQdt = (Z * (ddPhi t)) * (Phi - 2 * t * a)) :
    -- (E1) energy conservation
    dEdt = 0
    -- (E2) momentum conservation
    ∧ dpdt = 0
    -- (E3) scale-charge conservation
    ∧ dQdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + (0 : ℝ) = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi (fun _ => 0) varS h_flcv h_stat
  refine ⟨?_, ?_, ?_⟩
  · exact R_107_energy_conserved Z a (ddPhi t) 0 vdot dEdt hV (hEL_all t) hdE
  · exact R_107_momentum_conserved Z (ddPhi t) dpdt (hEL_all t) hdp
  · exact R_107_scale_conserved Z Phi t a (ddPhi t) dQdt (hEL_all t) hdQ

end R3_Agent7_ELNoether

end MIP
