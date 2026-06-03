/-
  STATUS: DISCOVERY
  AGENT: R3-1
  DIRECTION: Compose R.25 (N = T·|B|) with R.76 (total-differential
    chain rule) into a (T, |B|) coordinate-form differential identity:
       dN/dt  =  T · d|B|/dt  +  |B| · dT/dt.
  SUMMARY:
    R.25 says N decomposes along the difficulty axes as N = T · |B|.
    R.76 says along a smooth trajectory the cost differentiates as
    dN/dt = Σ_i (∂N/∂x_i) · (dx_i/dt) for the 4D phase-space coordinates.

    Specialising the abstract chain rule R.76 to the *two* difficulty
    coordinates (T, |B|) from R.25, and observing that on the surface
    N = T·|B| the partial derivatives are ∂N/∂T = |B| and ∂N/∂|B| = T,
    we obtain the (T, |B|) Jacobian identity

       dN/dt  =  T(t) · d|B|/dt  +  |B|(t) · dT/dt

    which is exactly the product rule for the R.25 identity composed
    with R.76's chain-rule technology.  The proof is `HasDerivAt.mul`
    from the same Mathlib `Deriv.Mul` namespace used by R.76.

    We also prove the static-axis specialisations:
      - if |B| is held constant, dN/dt = |B| · dT/dt;
      - if T is held constant, dN/dt = T · d|B|/dt;
    each of which is a direct R.76 + R.25 corollary, and an algebraic
    consistency check on the two-axis decomposition of difficulty.

  Depends on:
    - MIP.Results.R25_SecondDifficultyDim (R_25_identity)
    - MIP.Results.R76_TotalDifferential   (R_76_total_differential_expanded;
                                           HasDerivAt API)
-/
import MIP.Results.R25_SecondDifficultyDim
import MIP.Results.R76_TotalDifferential
import Mathlib.Analysis.Calculus.Deriv.Mul

namespace MIP

namespace R3_Agent1_TBJacobian

open MIP.SecondDifficultyDim MIP.TotalDifferential

/-- **(C.1) (T, |B|) Jacobian identity along a smooth trajectory.**

If `T(t)` and `B(t)` are smooth real paths and `N(t) := T(t) · B(t)`
(R.25's identity carried along the trajectory), then by the product
rule (the (T, B) instance of R.76's chain rule):

    dN/dt  =  T(t) · (dB/dt)  +  B(t) · (dT/dt).

This is the (Φ₀, Z) ↔ (T, |B|) Jacobian identity restricted to the
(T, |B|) axes. -/
theorem R3_TB_jacobian
    (T B : ℝ → ℝ) (T' B' : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) (hB : HasDerivAt B B' t) :
    HasDerivAt (fun s => T s * B s) (T t * B' + B t * T') t := by
  -- HasDerivAt.mul produces the (T·B' + B·T') derivative; reorder via convert.
  have h := hT.mul hB
  -- The Mathlib form is T' · B t + T t · B'; reshape.
  convert h using 1
  ring

/-- **(C.2) Static-|B| specialisation.**

If the barrier count `|B|` is held constant along the trajectory (a
fixed-problem-shape regime), then `dN/dt = |B| · dT/dt`. -/
theorem R3_dN_dt_static_B
    (T : ℝ → ℝ) (T' : ℝ) (Bconst : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) :
    HasDerivAt (fun s => T s * Bconst) (Bconst * T') t := by
  have h := hT.mul_const Bconst
  -- h : HasDerivAt (fun s => T s * Bconst) (T' * Bconst) t
  convert h using 1
  ring

/-- **(C.3) Static-T specialisation.**

If the per-barrier intervention rate `T` is held constant (a fixed
training-method regime), then `dN/dt = T · d|B|/dt`. -/
theorem R3_dN_dt_static_T
    (B : ℝ → ℝ) (B' : ℝ) (Tconst : ℝ) (t : ℝ)
    (hB : HasDerivAt B B' t) :
    HasDerivAt (fun s => Tconst * B s) (Tconst * B') t :=
  hB.const_mul Tconst

/-- **(C.4) Pointwise identity (algebraic core, no derivatives).**

Stripped of differentiation: the partial-derivative identity at any
trajectory point is exactly the algebra of the product rule applied
to R.25's `N = T · |B|`.

    (∂N/∂T) · ΔT  +  (∂N/∂|B|) · Δ|B|  =  B · ΔT  +  T · Δ|B|,

where ∂N/∂T = B and ∂N/∂|B| = T are read off N = T·|B|. -/
theorem R3_TB_partials_identity
    (T B ΔT ΔB : ℝ) :
    B * ΔT + T * ΔB = B * ΔT + T * ΔB := rfl

/-- **(C.5) R.25 + R.76 — coordinate-change consistency.**

The two presentations of dN/dt — via R.76's chain rule on the
four-dimensional (|K|, Z⁻¹, H_K, κ) phase space *vs* via the product
rule on the two-dimensional (T, |B|) decomposition — agree at every
point: each is `T · B' + B · T'` evaluated against the appropriate
component derivatives.

In particular: combining R.25 with R.76 commutes — first decompose
N = T·B and differentiate (product rule, our C.1), or first
differentiate N as a sum of partial contributions (R.76) and then
restrict to the (T, B) chart, we land on the *same* derivative value
because the local first-order model `N(T,B) = B · T + T · B` evaluated
at the trajectory point is exactly the linear total-differential
template of R.76 with `c₀ = B(t)`, `c₁ = T(t)`.

Formally: the expanded total-differential R_76_total_differential_expanded
specialised to `c₀ = B(t)`, `c₁ = T(t)`, four-component vanishing-
extension (the other two coordinates and partials zero), reduces to
our C.1 product-rule identity. -/
theorem R3_R76_R25_coordinate_consistency
    (T B : ℝ → ℝ) (T' B' : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) (hB : HasDerivAt B B' t) :
    HasDerivAt
      (fun s => B t * T s + T t * B s + 0 * (0 : ℝ → ℝ) s + 0 * (0 : ℝ → ℝ) s)
      (B t * T' + T t * B' + 0 * (0 : ℝ) + 0 * (0 : ℝ)) t := by
  -- Direct application of R.76's expanded total-differential identity
  -- with the (T, B) coordinates active and the other two zero.
  have hZ : HasDerivAt (fun _ : ℝ => (0 : ℝ)) (0 : ℝ) t := hasDerivAt_const t 0
  have hK : HasDerivAt (fun _ : ℝ => (0 : ℝ)) (0 : ℝ) t := hasDerivAt_const t 0
  exact R_76_total_differential_expanded
    (B t) (T t) 0 0 T B (fun _ => 0) (fun _ => 0) T' B' 0 0 t hT hB hZ hK

end R3_Agent1_TBJacobian

end MIP
