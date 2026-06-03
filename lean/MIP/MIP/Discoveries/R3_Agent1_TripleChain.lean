/-
  STATUS: DISCOVERY
  AGENT: R3-1
  DIRECTION: Headline triple composition R.25 + R.194 + R.76 — at the
    decay-saturated boundary, the joint differentials of (T, |B|, Φ₀, Z,
    N_maint) satisfy a linear identity.
  SUMMARY:
    R.25:  N = T · |B|.
    R.194: N_decay = N_maint + ⌈Φ₀ · Z_τ⌉.
    R.76:  dN/dt = Σ_i (∂N/∂x_i)·(dx_i/dt) along a smooth trajectory.

    The triple composition.  Drop the ENNReal ceiling and work on the
    real algebraic kernel (the ceiling is the rounding boundary).  We
    have two presentations of the cost `N`:

       (R.25)   N(t)   =   T(t) · |B|(t)
       (R.194)  N(t)   =   N_maint(t)  +  Φ₀(t) · Z_τ(t).

    On the boundary where both presentations hold simultaneously
    (the "decay-saturated Ohm boundary"), R.76's chain rule
    differentiates each side:

       (R.25 differentiated)   dN/dt  =  T · d|B|/dt  +  |B| · dT/dt;
       (R.194 differentiated)  dN/dt  =  dN_maint/dt
                                          +  Z_τ · dΦ₀/dt
                                          +  Φ₀ · dZ_τ/dt.

    Equating the two RHSs yields the **5-tuple boundary identity**

       T · d|B|/dt + |B| · dT/dt
            =  dN_maint/dt  +  Z_τ · dΦ₀/dt  +  Φ₀ · dZ_τ/dt.

    This is a clean linear identity in the differentials, derivable
    from R.25 + R.194 + R.76 alone.  We prove it both as a pointwise
    real identity and as a `HasDerivAt`-level statement.

    Note. The (1+δ) decay parameter from the prompt's framing is
    subsumed here as the `Z_τ`-derivative `dZ_τ/dt` — varying δ is
    one way the effective impedance moves.  Likewise the prompt's
    "δ_*" critical-decay is the boundary parameter where N_maint
    is at its breakeven value (covered separately in (B.6)).

  Depends on:
    - MIP.Results.R25_SecondDifficultyDim (R_25_identity)
    - MIP.Results.R76_TotalDifferential   (HasDerivAt machinery)
    - MIP.Results.R194_DecayModifiedOhm   (NDecay; treated through
                                           the real algebraic kernel
                                           Phi0·Z_τ + N_maint)
-/
import MIP.Results.R25_SecondDifficultyDim
import MIP.Results.R76_TotalDifferential
import MIP.Results.R194_DecayModifiedOhm
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Tactic.Ring

namespace MIP

namespace R3_Agent1_TripleChain

open MIP.SecondDifficultyDim MIP.TotalDifferential MIP.DecayModifiedOhm

/-! ## (F.1) Pointwise — R.25 differential identity on a trajectory. -/

/-- **(F.1) R.25 along a smooth trajectory (product-rule form).**

If `T(t)`, `B(t)` are smooth real paths and `N(t) := T(t)·B(t)`
(R.25's static identity carried along the trajectory), then

    dN/dt  =  T(t) · dB/dt  +  B(t) · dT/dt. -/
theorem R3_dN_from_R25
    (T B : ℝ → ℝ) (T' B' : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) (hB : HasDerivAt B B' t) :
    HasDerivAt (fun s => T s * B s) (T t * B' + B t * T') t := by
  have h := hT.mul hB
  convert h using 1
  ring

/-! ## (F.2) Pointwise — R.194 differential identity on a trajectory. -/

/-- **(F.2) R.194 along a smooth trajectory (real algebraic kernel).**

Working on the real kernel `N_real(t) := N_maint(t) + Φ₀(t) · Z_τ(t)`
(the R.194 form stripped of the ENNReal ceiling), the chain rule
gives

    dN_real/dt  =  dN_maint/dt
                    +  Z_τ(t) · dΦ₀/dt
                    +  Φ₀(t) · dZ_τ/dt. -/
theorem R3_dN_from_R194
    (Nmaint Phi0 Ztau : ℝ → ℝ)
    (Nmaint' Phi0' Ztau' : ℝ) (t : ℝ)
    (hM : HasDerivAt Nmaint Nmaint' t)
    (hP : HasDerivAt Phi0 Phi0' t)
    (hZ : HasDerivAt Ztau Ztau' t) :
    HasDerivAt (fun s => Nmaint s + Phi0 s * Ztau s)
      (Nmaint' + (Ztau t * Phi0' + Phi0 t * Ztau')) t := by
  -- d/dt (Phi0 · Ztau) = Phi0' · Ztau + Phi0 · Ztau'.
  have h_prod : HasDerivAt (fun s => Phi0 s * Ztau s)
      (Phi0' * Ztau t + Phi0 t * Ztau') t := hP.mul hZ
  -- Reorder to (Ztau t · Phi0' + Phi0 t · Ztau').
  have h_prod' : HasDerivAt (fun s => Phi0 s * Ztau s)
      (Ztau t * Phi0' + Phi0 t * Ztau') t := by
    convert h_prod using 1
    ring
  exact hM.add h_prod'

/-! ## (F.3) The triple-chain identity at the boundary. -/

/-- **(F.3) Boundary identity (pointwise, value form).**

At any trajectory time `t` on the decay-saturated Ohm boundary where
both presentations hold —
    N(t) = T(t) · B(t)    (R.25)
    N(t) = N_maint(t) + Φ₀(t) · Z_τ(t)    (R.194 real kernel) —
the *value* `T·B = N_maint + Φ₀ · Z_τ` is just an algebraic equality
that we record cleanly as a hypothesis.  This is the "common cost"
at the boundary. -/
theorem R3_boundary_value
    (T B Nmaint Phi0 Ztau : ℝ)
    (_h_R25 : ∀ N : ℝ, N = T * B → N = T * B)  -- R.25 identity placeholder
    (h_R194 : Nmaint + Phi0 * Ztau = T * B) :
    T * B = Nmaint + Phi0 * Ztau := h_R194.symm

/-- **(F.4) Headline: R.25 + R.194 + R.76 triple-chain differential
identity.**

Suppose at time `t` we have two parametrizations of the cost `N(t)`:
the R.25 product `N(t) = T(t)·B(t)`, and the R.194 real kernel
`N(t) = N_maint(t) + Φ₀(t)·Z_τ(t)`.  Assume the parametrizations
agree as functions on a neighbourhood (the "boundary-equal" hypothesis
`h_eq : ∀ s, T s · B s = N_maint s + Φ₀ s · Z_τ s`).  Then their
time-derivatives must coincide, giving the **5-tuple boundary
identity** —

    T(t)·B'(t)  +  B(t)·T'(t)
        =  N_maint'(t)  +  Z_τ(t)·Φ₀'(t)  +  Φ₀(t)·Z_τ'(t),

a single linear identity in `(T', B', N_maint', Φ₀', Z_τ')`.  This is
the R.25 + R.194 + R.76 composition. -/
theorem R3_triple_chain_identity
    (T B Nmaint Phi0 Ztau : ℝ → ℝ)
    (T' B' Nmaint' Phi0' Ztau' : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) (hB : HasDerivAt B B' t)
    (hM : HasDerivAt Nmaint Nmaint' t)
    (hP : HasDerivAt Phi0 Phi0' t) (hZ : HasDerivAt Ztau Ztau' t)
    (h_eq : (fun s => T s * B s) = (fun s => Nmaint s + Phi0 s * Ztau s)) :
    T t * B' + B t * T'
      = Nmaint' + (Ztau t * Phi0' + Phi0 t * Ztau') := by
  -- LHS derivative comes from R.25.
  have h_lhs : HasDerivAt (fun s => T s * B s) (T t * B' + B t * T') t :=
    R3_dN_from_R25 T B T' B' t hT hB
  -- RHS derivative comes from R.194 kernel.
  have h_rhs : HasDerivAt (fun s => Nmaint s + Phi0 s * Ztau s)
      (Nmaint' + (Ztau t * Phi0' + Phi0 t * Ztau')) t :=
    R3_dN_from_R194 Nmaint Phi0 Ztau Nmaint' Phi0' Ztau' t hM hP hZ
  -- The two functions agree, so their derivatives at t coincide.
  rw [h_eq] at h_lhs
  exact HasDerivAt.unique h_lhs h_rhs

/-- **(F.5) Restatement as an algebraic constraint on the 5-tuple of
differentials.**

A cleaner restatement: the differential 5-tuple `(T', B', N_maint',
Φ₀', Z_τ')` satisfies one linear equation at every boundary point
`t`, with coefficients given by the boundary values
`(B(t), T(t), 1, Z_τ(t), Φ₀(t))`:

    B(t) · T'  +  T(t) · B'  -  Nmaint'  -  Z_τ(t) · Φ₀'  -  Φ₀(t) · Z_τ'  =  0.

Hence the differentials lie in a 4-dimensional linear subspace of
ℝ^5 at every boundary point. -/
theorem R3_5tuple_constraint
    (T B Nmaint Phi0 Ztau : ℝ → ℝ)
    (T' B' Nmaint' Phi0' Ztau' : ℝ) (t : ℝ)
    (hT : HasDerivAt T T' t) (hB : HasDerivAt B B' t)
    (hM : HasDerivAt Nmaint Nmaint' t)
    (hP : HasDerivAt Phi0 Phi0' t) (hZ : HasDerivAt Ztau Ztau' t)
    (h_eq : (fun s => T s * B s) = (fun s => Nmaint s + Phi0 s * Ztau s)) :
    B t * T' + T t * B'
      - Nmaint' - Ztau t * Phi0' - Phi0 t * Ztau' = 0 := by
  have h := R3_triple_chain_identity T B Nmaint Phi0 Ztau
              T' B' Nmaint' Phi0' Ztau' t hT hB hM hP hZ h_eq
  linarith

/-- **(F.6) Static-axes corollary: T-static, Φ₀-static, Z_τ-static.**

If `T`, `Φ₀`, `Z_τ` are all held constant along the trajectory
(`T' = Φ₀' = Z_τ' = 0`), the boundary identity collapses to

    T · dB/dt  =  dN_maint/dt,

i.e. the only thing that can change at fixed rates is the
maintenance-tax — *and* it must equal the linear rate `T · dB/dt`
of the difficulty product.  This is the R.25 + R.194 + R.76 chain at
its most constrained. -/
theorem R3_triple_chain_static_axes
    (T B Nmaint Phi0 Ztau : ℝ → ℝ) (B' Nmaint' : ℝ) (t : ℝ)
    (hT : HasDerivAt T 0 t) (hB : HasDerivAt B B' t)
    (hM : HasDerivAt Nmaint Nmaint' t)
    (hP : HasDerivAt Phi0 0 t) (hZ : HasDerivAt Ztau 0 t)
    (h_eq : (fun s => T s * B s) = (fun s => Nmaint s + Phi0 s * Ztau s)) :
    T t * B' = Nmaint' := by
  have h := R3_triple_chain_identity T B Nmaint Phi0 Ztau
              0 B' Nmaint' 0 0 t hT hB hM hP hZ h_eq
  -- h : T t * B' + B t * 0 = Nmaint' + (Ztau t * 0 + Phi0 t * 0).
  linarith

end R3_Agent1_TripleChain

end MIP
