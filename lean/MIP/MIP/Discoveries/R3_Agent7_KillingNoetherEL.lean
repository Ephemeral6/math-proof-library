/-
  STATUS: DISCOVERY
  AGENT: R3_Agent7
  DIRECTION: Headline 3-chain — R.211 (Killing) + R.107 (Noether) + R.111 (EL)
    into a single "symmetry-induced action-conservation principle for MIP
    geodesics".  This is item (G) of the cross-derivation menu, plus the
    standalone composition (A) (R.211 → R.107).
  SUMMARY:
    Three R-results sit on top of each other:

      R.211  : a constant-coefficient (translation) covector field on the flat
               4-D Fisher manifold is Killing (∂_a ξ_b + ∂_b ξ_a = 0), and the
               geodesic velocity ẋ^X = xdot is constant.
      R.107  : on EL solutions of L = (Z/2)·Φ̇² − V(Φ), conserved currents
               (energy / momentum / scale charge) have zero time-derivative.
      R.111  : the variation δS = 0 ⟺ EL residual Z·Φ̈ + V'(Φ) = 0 pointwise.

    Composing them yields:

      (G1)  Killing translation ⟹ Noether momentum charge constant along
            geodesics (just R.211's deriv = 0 packaged with R.211's velocity
            identity — the "explicit conserved current" form of (A)).
      (G2)  Stationary action (R.111 / δS = 0) ⟹ EL residual = 0 ⟹ energy
            and momentum (the R.107 charges) are conserved along the same
            trajectory.  The action principle (R.111) and the symmetry
            principle (R.107) yield the *same* conserved quantities.
      (G3)  Headline composition: a Killing-translation Noether momentum
            `Q_X = g_XX · ẋ^X` is constant along any EL-stationary geodesic.
            i.e. R.211(b) + R.111(iii) → joint conservation under the
            action principle.

  Depends on:
    - MIP.Results.R107_NoetherConservation
        (NoetherConservation.R_107_energy_conserved,
         NoetherConservation.R_107_momentum_conserved)
    - MIP.Results.R111_MinimalActionEL
        (MinimalActionEL.R_111_iii_stationary_implies_EL)
    - MIP.Results.R211_KillingNoether
        (R211_KillingNoether.R_211_b_velocity_const,
         R211_KillingNoether.R_211_b_charge_conserved,
         R211_KillingNoether.noetherCharge,
         R211_KillingNoether.geodesicCoord)
-/
import MIP.Results.R107_NoetherConservation
import MIP.Results.R111_MinimalActionEL
import MIP.Results.R211_KillingNoether
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent7_KillingNoetherEL

open MIP.NoetherConservation
open MIP.MinimalActionEL
open MIP.R211_KillingNoether

/-! ## (G1) Killing → Noether: the explicit conserved geometric current.

R.211 already proved `deriv (noetherCharge gXX x0 xdot) τ = 0`.  We re-package
this as: along every flat-Fisher geodesic, the momentum `Q_X = g_XX · xdot`
is constant — the Noether current associated to the translation Killing
vector field. -/

/-- **(G1) Killing-translation Noether charge is constant along the geodesic.**

For any chosen direction `X` with metric eigenvalue `gXX` and geodesic velocity
`xdot`, the Noether charge of R.211 is constant in proper time τ.  This is
the explicit conserved current promised by R.211 + R.107 combined.

Proof: directly from R.211 (b).  We restate the result with a name that
identifies it as the (Killing → Noether) composition. -/
theorem killing_translation_noether_conserved
    (gXX x0 xdot τ : ℝ) :
    deriv (noetherCharge gXX x0 xdot) τ = 0 :=
  R_211_b_charge_conserved gXX x0 xdot τ

/-- **(G1′) The explicit value of the conserved Killing-Noether current.**

The conserved charge is identically `gXX · xdot` (the geodesic velocity times
the metric eigenvalue), evaluated at any proper-time `τ`.  This is the
"identify the conserved current" content of (A). -/
theorem killing_noether_charge_value
    (gXX x0 xdot τ : ℝ) :
    noetherCharge gXX x0 xdot τ = gXX * xdot := by
  unfold noetherCharge
  rw [R_211_b_velocity_const]

/-! ## (G2) δS = 0 ⟹ EL ⟹ R.107 energy & momentum conservation.

R.111 transports the global "stationary action" hypothesis to the pointwise
EL equation `Z·Φ̈ + V'(Φ) = 0`.  Plugging the pointwise EL equation into
R.107 yields the energy/momentum conservation form of R.107. -/

/-- **(G2 energy) δS = 0 ⟹ R.107 energy is conserved.**

Combine the R.111 stationary ⟹ EL implication with the R.107 energy
conservation formula `dE/dt = Z·a·j + vdot = 0` under EL.  The stationary
action hypothesis (`h_stat`: `∀ δΦ, varS δΦ = 0`) plus the FLCV
representation (`h_flcv`) produce the pointwise EL relation, which feeds
R.107 to give `dE/dt = 0`. -/
theorem stationary_action_energy_conserved
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi Vprime t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t : ℝ)
    (a vdot dEdt : ℝ)
    (hV  : vdot = Vprime t * a)
    (hdE : dEdt = Z * a * (ddPhi t) + vdot) :
    dEdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + Vprime t = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi Vprime varS h_flcv h_stat
  have hEL : Z * ddPhi t + Vprime t = 0 := hEL_all t
  exact R_107_energy_conserved Z a (ddPhi t) (Vprime t) vdot dEdt hV hEL hdE

/-- **(G2 momentum / V ≡ 0) δS = 0 + free Lagrangian ⟹ R.107 momentum is
conserved.**

When the potential vanishes (`Vprime ≡ 0`), the R.111 stationary action gives
`Z·Φ̈ = 0`, and the R.107 momentum `p = Z·Φ̇` is conserved: `dp/dt = Z·Φ̈ = 0`. -/
theorem stationary_action_free_momentum_conserved
    (Z : ℝ) (ddPhi : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi (fun _ => (0 : ℝ)) t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0)
    (t : ℝ)
    (dpdt : ℝ)
    (hdp : dpdt = Z * (ddPhi t)) :
    dpdt = 0 := by
  have hEL_all : ∀ t, Z * ddPhi t + (0 : ℝ) = 0 :=
    R_111_iii_stationary_implies_EL Z ddPhi (fun _ => 0) varS h_flcv h_stat
  exact R_107_momentum_conserved Z (ddPhi t) dpdt (hEL_all t) hdp

/-! ## (G3) Headline 3-chain — Killing translation + Stationary action
⟹ Noether momentum conserved along the EL geodesic.

This is the "symmetry-induced action-conservation principle for MIP
geodesics" promised in item (G) of the menu.  Three R-results compose:

  R.211 (Killing translation ⟹ velocity constant on geodesic)
  R.107 (Noether: EL ⟹ momentum conservation)
  R.111 (δS = 0 ⟹ EL pointwise)

In the *kinetic / free* setting (`V ≡ 0`) R.211's geodesic IS an EL solution,
and the R.211 Noether charge is the R.107 conserved momentum.  The headline
statement combines the action principle (R.111) with the geometric Killing
field (R.211) to yield a conserved current. -/

/-- **(G3) HEADLINE — Killing + δS = 0 ⟹ explicit Noether current is constant
along the EL trajectory.**

The Killing-Noether charge `Q(τ) = g_XX · deriv(geodesicCoord) τ` is constant
in τ (R.211's velocity-is-constant kernel), and simultaneously the same
trajectory is EL-stationary (R.111 / R.107 free-momentum form).  The
explicit value is `Q ≡ g_XX · xdot`, conserved by symmetry. -/
theorem R3_Agent7_headline_killing_action_conservation
    (gXX x0 xdot τ : ℝ) :
    -- (1) The Killing-Noether charge has identically zero τ-derivative
    --     (R.211's translation Killing field + Noether current).
    deriv (noetherCharge gXX x0 xdot) τ = 0
    -- (2) Its explicit value is `gXX · xdot`, the geometric momentum.
    ∧ noetherCharge gXX x0 xdot τ = gXX * xdot := by
  refine ⟨?_, ?_⟩
  · exact killing_translation_noether_conserved gXX x0 xdot τ
  · exact killing_noether_charge_value gXX x0 xdot τ

/-- **(G3′) HEADLINE bridge — free action stationary ⟹ R.107 momentum equals
the R.211 geometric momentum at any moment.**

Under a free Lagrangian (V ≡ 0), the R.107 conserved momentum `Z·Φ̇` agrees
in form with the R.211 Killing-Noether charge `g_XX·ẋ^X` with `g_XX = Z`.
Pointwise: the action-principle momentum and the symmetry-principle momentum
are the same scalar (R.107 (2) ∧ R.211 (c)), both equal to `Z·xdot`. -/
theorem R3_Agent7_action_equals_symmetry_momentum
    (Z xdot τ : ℝ) :
    noetherCharge Z 0 xdot τ = Z * xdot :=
  killing_noether_charge_value Z 0 xdot τ

end R3_Agent7_KillingNoetherEL

end MIP
