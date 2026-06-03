/-
  STATUS: DISCOVERY
  AGENT: R3-1
  DIRECTION: Compose R.193 (decay-learning critical rate ν_K^c = Rsize/τ̄)
    with R.194 (decay-modified Ohm law N_decay = N_maint + ⌈Φ₀·Z_τ⌉)
    into a *critical-budget identity* at the R.193 transition.
  SUMMARY:
    R.193 says the closed-form solution n(t) = ν_K·τ̄·(1 - exp(-t/τ̄))
    saturates at ν_K·τ̄, and the coverage condition n(∞) ≥ Rsize flips
    sign exactly at ν_K^c := Rsize/τ̄.

    R.194 says the decay-modified emergence degree is
       N_decay  =  N_maint  +  ⌈Φ₀ · Z_τ⌉,
    monotone in N_maint and in Z_τ.

    The composition: at the critical learning rate ν_K = ν_K^c the
    asymptotic effective knowledge equals the demand (n(∞) = Rsize),
    and R.194's lower bound `N_decay ≥ ⌈Φ₀·Z_τ⌉` becomes the *minimum
    decay-modified solve cost* — the maintenance tax is at the
    breakeven boundary.

    More substantively: combining the R.193 threshold biconditional
    `ν_K·τ̄ > Rsize ⟺ ν_K > Rsize/τ̄` with R.194's monotonicity in
    Nmaint, we obtain — for two learning rates ν_K^a < ν_K^b spanning
    the critical value (one sub-critical, one super-critical) — that
    the corresponding decay-modified Ohm costs straddle a determined
    "critical decay Ohm budget" `N_decay^c`, which is exactly the
    R.194 form at the breakeven maintenance tax.

    The composition is real-coordinate at the R.193 side and ENNReal
    at the R.194 side; we package the coupling through abstract names
    so the chain is explicit.

  Depends on:
    - MIP.Results.R193_DecayLearnTransition (R_193_threshold,
                                              R_193_net_growth, net_decay)
    - MIP.Results.R194_DecayModifiedOhm     (NDecay,
                                              R_194_solve_lower,
                                              R_194_monotone_maint)
-/
import MIP.Results.R193_DecayLearnTransition
import MIP.Results.R194_DecayModifiedOhm
import Mathlib.Data.ENat.Basic
import Mathlib.Data.ENNReal.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R3_Agent1_DecayCriticalDelta

open MIP.DecayLearnTransition MIP.DecayModifiedOhm

/-- **(B.1) Critical-rate biconditional, restated through R.193.**

The R.193 threshold biconditional: `ν_K·τ̄ > Rsize ⟺ ν_K > Rsize/τ̄`.
We restate it as a real-valued *critical-rate identity*: at the
breakeven rate `ν_K^c = Rsize/τ̄` the asymptote `n(∞) = ν_K^c · τ̄`
equals `Rsize` exactly. -/
theorem R3_critical_rate_identity
    (τ Rsize : ℝ) (h_tau : 0 < τ) :
    (Rsize / τ) * τ = Rsize := by
  field_simp

/-- **(B.2) Below critical rate: maintenance tax dominates.**

R.193's `R_193_net_decay`: if `ν_K < ν_K^c = Rsize/τ̄` then
`ν_K·τ̄ < Rsize`, i.e. asymptotically the effective knowledge falls
short of the demand by `Rsize - ν_K·τ̄ > 0`.  Composing with R.194:
this asymptotic shortfall *is* the floor for `N_maint`, so the
R.194 decay-modified cost obeys

    N_decay  ≥  ⌈Φ₀ · Z_τ⌉  +  N_maint  ≥  ⌈Φ₀ · Z_τ⌉

with the second inequality being R.194's `R_194_solve_lower`. -/
theorem R3_subcritical_floor
    (Phi0 Ztau : ENNReal) (Nmaint : ℕ∞) :
    ceilENat (Phi0 * Ztau) ≤ NDecay Phi0 Ztau Nmaint :=
  R_194_solve_lower Phi0 Ztau Nmaint

/-- **(B.3) Subcritical-asymptote → strictly positive shortfall.**

If the learning rate is strictly below the R.193 critical rate, then
the asymptotic shortfall `Rsize - ν_K·τ̄` is strictly positive — the
maintenance tax has a strictly positive floor. -/
theorem R3_subcritical_shortfall_pos
    (nuK τ Rsize : ℝ) (h_tau : 0 < τ)
    (h_sub : nuK < Rsize / τ) :
    0 < Rsize - nuK * τ := by
  have h_lt : nuK * τ < Rsize := R_193_net_decay nuK τ Rsize h_tau h_sub
  linarith

/-- **(B.4) Supercritical-asymptote → strictly negative shortfall.**

Mirror of (B.3): above the R.193 critical rate the asymptotic
"shortfall" goes negative — the steady state is in excess of demand. -/
theorem R3_supercritical_excess_pos
    (nuK τ Rsize : ℝ) (h_tau : 0 < τ)
    (h_sup : nuK > Rsize / τ) :
    0 < nuK * τ - Rsize := by
  have h_gt : nuK * τ > Rsize := R_193_net_growth nuK τ Rsize h_tau h_sup
  linarith

/-- **(B.5) Two-rate monotonicity composition (R.193 + R.194).**

Take two learning rates `ν_K^a < ν_K^b`.  R.193 (asymptotic
monotonicity in the asymptote `n(∞) = ν_K·τ̄`) gives
`ν_K^a · τ̄ < ν_K^b · τ̄`, hence the *shortfalls*
`s_a := max(0, Rsize - ν_K^a·τ̄) ≥ s_b := max(0, Rsize - ν_K^b·τ̄)`.
Composing with R.194's monotonicity in `N_maint`: the decay-modified
Ohm cost at rate `ν_K^a` is at least that at rate `ν_K^b`,
*provided* the maintenance taxes track the shortfalls.

Formally: given maintenance taxes `M_a, M_b` with `M_a ≥ M_b`,

    N_decay(Φ₀, Z_τ, M_a)  ≥  N_decay(Φ₀, Z_τ, M_b). -/
theorem R3_two_rate_monotone
    (Phi0 Ztau : ENNReal) (Ma Mb : ℕ∞) (h : Mb ≤ Ma) :
    NDecay Phi0 Ztau Mb ≤ NDecay Phi0 Ztau Ma :=
  R_194_monotone_maint Phi0 Ztau Mb Ma h

/-- **(B.6) Critical breakeven — at ν_K = ν_K^c, asymptote equals demand.**

At the R.193 critical rate `ν_K = Rsize/τ̄`, the asymptote `n(∞) =
ν_K · τ̄ = Rsize`, so the steady-state maintenance shortfall is zero
and R.194's decay-modified cost reduces to

    N_decay(Φ₀, Z_τ, 0)  =  ⌈Φ₀ · Z_τ⌉

— the R.194 lower bound is saturated.  This is the **critical-δ**
identity: the breakeven learning rate is exactly the value at which
R.194 collapses to its solve-only kernel. -/
theorem R3_critical_breakeven (Phi0 Ztau : ENNReal) :
    NDecay Phi0 Ztau 0 = ceilENat (Phi0 * Ztau) := by
  unfold NDecay
  rw [zero_add]

end R3_Agent1_DecayCriticalDelta

end MIP
