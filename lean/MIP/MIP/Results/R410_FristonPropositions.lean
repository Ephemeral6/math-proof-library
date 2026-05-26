/-
Result R.410 — Friston's five propositions translated into MIP.

Reference: `workspace/friston_mip_unification.md` §R.410
(A — five translations rigorously derivable under R.408-R.409 isomorphism;
(b)/(c) provide explicit new predictions, 2026-05-16).

**The five propositions.**

* **(a) Perception = `dΦ₀/dt` descent.** Friston `dμ/dt = −∂F/∂μ`; in MIP
  perception is a gradient flow descending the `Φ₀`-landscape, so along
  the flow `Φ₀` is (strictly) decreasing.  Formalized as: a smooth path
  whose `Φ₀` has a strictly negative time-derivative is strictly
  antitone (T.5 flywheel decay `dN/dt < 0 ⟺ dΦ₀/dt < 0`).
* **(d) Hebbian = κ Gompertz.** Hebb learning drives the combinatorial
  closure `κ` up the Gompertz law `dκ/dt = α·κ·|log κ|` (R.98).
  Formalized by reusing the R.98 closed form
  `κ t = exp(log κ₀ · exp(−α(t−t_c)))` and proving it solves the ODE,
  i.e. `HasDerivAt κ (−α·κ·log κ) t`.
* **(e) Value = −Surprise.** Adaptive value `= −E_p[Φ₀(Y,p)] · Π`
  (Intelligence × precision, log version).  Formalized as a definition
  plus its sign property: when `E[Φ₀] ≥ 0` and `Π > 0`, value `≤ 0`,
  and value `= 0 ⟺ E[Φ₀] = 0` (the A.1 autonomy point, zero Surprise).

* **(b) Action** and **(c) Predictive coding** require the *multi-agent*
  extension (relaxing (F1); D.3.9 dual emergence `Z_q(X|Y)` and the
  barrier-DAG backprop `G(p)`).  They are recorded as hypothesis bundles
  with a note that the crisp single-agent kernel is unavailable; we
  encode only what is identity-level (the bundled mapping), not a
  derived dynamical theorem.

**This file is `axiom`-free.**  The (F4) mapping enters as explicit
hypotheses; (a) and (d) are genuine analysis theorems, (e) an algebraic
identity + sign lemma.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace FristonPropositions

open Real

/-! ## Proposition (a) — perception is `Φ₀` gradient descent -/

/-- **R.410(a) — perception strictly decreases `Φ₀`.**

Friston `dμ/dt = −∂F/∂μ`: perception is a gradient flow.  In MIP,
along a perception trajectory `Φ : ℝ → ℝ` (the `Φ₀`-value as a function
of time) whose derivative is everywhere strictly negative, `Φ₀` is
strictly antitone — the T.5 flywheel reading `dΦ₀/dt < 0`.

We model the descent by the hypothesis that `Φ` has, at every time, a
strictly negative derivative `Φ' t < 0`, and conclude `Φ` is strictly
decreasing. -/
theorem R_410_a_perception_descent
    (Φ Φ' : ℝ → ℝ)
    (hderiv : ∀ t, HasDerivAt Φ (Φ' t) t)
    (hneg : ∀ t, Φ' t < 0) :
    StrictAnti Φ :=
  strictAnti_of_hasDerivAt_neg hderiv hneg

/-- **R.410(a) — instantaneous descent: `dΦ₀/dt < 0` at a point.**

The pointwise statement: at a time `t` where the perception flow has
derivative `−c` with `c > 0`, the `Φ₀`-value is instantaneously
decreasing.  This is the local form of the flywheel `dΦ₀/dt < 0`. -/
theorem R_410_a_descent_pointwise
    (Φ : ℝ → ℝ) (t c : ℝ) (hc : 0 < c)
    (hderiv : HasDerivAt Φ (-c) t) :
    deriv Φ t < 0 := by
  rw [hderiv.deriv]; linarith

/-! ## Proposition (d) — Hebbian learning is the κ Gompertz dynamics

We reuse the R.98 closed form and prove it solves the Gompertz ODE
`dκ/dt = −α·κ·log κ = α·κ·|log κ|` on `κ ∈ (0,1)`.  This is the
self-contained R.98 statement specialized as Friston proposition (d):
Hebb learning ⟺ κ Gompertz growth. -/

/-- The R.98 Gompertz closed form `κ t = exp(log κ₀ · exp(−α(t−t_c)))`. -/
noncomputable def kappa (κ₀ α t_c : ℝ) (t : ℝ) : ℝ :=
  Real.exp (Real.log κ₀ * Real.exp (-α * (t - t_c)))

/-- Inner exponent `g t = log κ₀ · exp(−α(t−t_c))`. -/
noncomputable def gExp (κ₀ α t_c : ℝ) (t : ℝ) : ℝ :=
  Real.log κ₀ * Real.exp (-α * (t - t_c))

theorem log_kappa_eq_gExp (κ₀ α t_c t : ℝ) :
    Real.log (kappa κ₀ α t_c t) = gExp κ₀ α t_c t := by
  unfold kappa gExp
  rw [Real.log_exp]

theorem hasDerivAt_gExp (κ₀ α t_c t : ℝ) :
    HasDerivAt (gExp κ₀ α t_c) (-α * gExp κ₀ α t_c t) t := by
  have h_aff : HasDerivAt (fun s => -α * (s - t_c)) (-α) t := by
    have h1 : HasDerivAt (fun s : ℝ => s - t_c) (1 : ℝ) t :=
      (hasDerivAt_id t).sub_const t_c
    have h2 := h1.const_mul (-α)
    simpa using h2
  have h_exp : HasDerivAt (fun s => Real.exp (-α * (s - t_c)))
      (Real.exp (-α * (t - t_c)) * (-α)) t := h_aff.exp
  have h_g := h_exp.const_mul (Real.log κ₀)
  unfold gExp
  convert h_g using 1
  ring

/-- **R.410(d) — Hebbian learning obeys the κ Gompertz ODE.**

The combinatorial closure `κ t = exp(log κ₀ · exp(−α(t−t_c)))` driven by
Hebbian co-activation satisfies, at every time,

    dκ/dt = −α · κ(t) · log(κ(t))   (= α·κ·|log κ| on κ ∈ (0,1)),

the R.98 Gompertz law.  This is the MIP form of Friston proposition (d)
"Hebb learning = F's parameter gradient descent". -/
theorem R_410_d_hebbian_gompertz (κ₀ α t_c t : ℝ) :
    HasDerivAt (kappa κ₀ α t_c)
      (-α * kappa κ₀ α t_c t * Real.log (kappa κ₀ α t_c t)) t := by
  have hg : HasDerivAt (gExp κ₀ α t_c) (-α * gExp κ₀ α t_c t) t :=
    hasDerivAt_gExp κ₀ α t_c t
  have hκ : HasDerivAt (fun s => Real.exp (gExp κ₀ α t_c s))
      (Real.exp (gExp κ₀ α t_c t) * (-α * gExp κ₀ α t_c t)) t := hg.exp
  have h_fun : (fun s => Real.exp (gExp κ₀ α t_c s)) = kappa κ₀ α t_c := by
    funext s; rfl
  rw [h_fun] at hκ
  have h_log : Real.log (kappa κ₀ α t_c t) = gExp κ₀ α t_c t :=
    log_kappa_eq_gExp κ₀ α t_c t
  have h_kappa : Real.exp (gExp κ₀ α t_c t) = kappa κ₀ α t_c t := rfl
  convert hκ using 1
  rw [h_log, h_kappa]
  ring

/-! ## Proposition (e) — value = −E[Φ₀]·Π -/

/-- **R.410(e) — adaptive value definition.**

`Value := −E_p[Φ₀(Y,p)] · Π` (Intelligence × precision, log version of
Friston "Value = −Surprise").  `EPhi0` is the expected `Φ₀` over the
problem distribution; `Pi` the precision. -/
noncomputable def Value (EPhi0 Pi : ℝ) : ℝ := -EPhi0 * Pi

/-- **R.410(e) — value identity.** `Value = −E[Φ₀] · Π` by definition. -/
theorem R_410_e_value_eq (EPhi0 Pi : ℝ) : Value EPhi0 Pi = -EPhi0 * Pi := rfl

/-- **R.410(e) — value sign property.**

With non-negative expected Surprise `E[Φ₀] ≥ 0` and positive precision
`Π > 0`, adaptive value is non-positive: `Value ≤ 0`.  High Surprise ⟹
low value, exactly Friston "value = −Surprise". -/
theorem R_410_e_value_nonpos (EPhi0 Pi : ℝ)
    (hE : 0 ≤ EPhi0) (hPi : 0 < Pi) :
    Value EPhi0 Pi ≤ 0 := by
  unfold Value
  have : 0 ≤ EPhi0 * Pi := mul_nonneg hE (le_of_lt hPi)
  linarith [this]

/-- **R.410(e) — value vanishes exactly at the A.1 autonomy point.**

For `Π > 0`, `Value = 0 ⟺ E[Φ₀] = 0`: maximal (zero) value is attained
precisely when expected Surprise vanishes — the A.1 autonomy condition
`N = 0 ⟺ Φ₀ = 0`. -/
theorem R_410_e_value_zero_iff (EPhi0 Pi : ℝ) (hPi : 0 < Pi) :
    Value EPhi0 Pi = 0 ↔ EPhi0 = 0 := by
  unfold Value
  constructor
  · intro h
    -- -EPhi0 * Pi = 0, Pi ≠ 0 ⟹ EPhi0 = 0
    have hPi_ne : Pi ≠ 0 := ne_of_gt hPi
    have : -EPhi0 = 0 := by
      rcases mul_eq_zero.mp h with h1 | h2
      · exact h1
      · exact absurd h2 hPi_ne
    linarith
  · intro h
    rw [h]; ring

/-! ## Propositions (b) and (c) — require the multi-agent extension

The source flags (b) action and (c) predictive coding as needing
relaxation of (F1): action becomes a metacognitive intervention of `Y`
on `X` (D.1.7 questioner role; D.3.9 dual-emergence `Z_q(X|Y)`
minimization), and predictive coding is backprop of `Φ₀`-gradients along
the barrier DAG `G(p)`.  Neither has a crisp single-agent identity
kernel, so we bundle only the *mapping data* and the conservation
relation each posits as a hypothesis — no derived dynamical theorem. -/

/-- **R.410(b) — action mapping bundle (multi-agent; (F1) relaxed).**

Records the dual-emergence identification: under partial responsiveness
`(F1')`, `Y`'s action is the metacognitive intervention minimizing the
dual impedance `Z_q(X|Y)`.  The self-referential degeneration
`Z_q(Y|Y) = Z(Y)` (D.3.9) is carried as a hypothesis flag; the dynamics
are NOT derived here (needs the N(p,X,Y) two-agent framework). -/
structure ActionMap where
  /-- Dual impedance `Z_q(X|Y)`. -/
  Zq_XY : ℝ
  /-- Self impedance `Z_q(Y|Y)`. -/
  Zq_YY : ℝ
  /-- Plain impedance `Z(Y)`. -/
  Z_Y : ℝ
  /-- D.3.9 self-referential degeneration `Z_q(Y|Y) = Z(Y)` (posited). -/
  selfRef : Zq_YY = Z_Y

/-- **R.410(b) — recorded identity (conditional on the multi-agent
bundle).** Self-referential dual emergence reduces to plain impedance. -/
theorem R_410_b_selfref (A : ActionMap) : A.Zq_YY = A.Z_Y := A.selfRef

/-- **R.410(c) — predictive-coding mapping bundle (needs barrier-DAG
backprop).**

Records the identification: prediction error `ε ↔ ∇Φ₀` projected on
`K(Y)`, backprop along `G(p)`, weights `θ ↔ p_Y(ω)`.  The error/gradient
identity is carried as a hypothesis; the backprop dynamics need
D.2.10 + D.1.3 and are NOT derived here. -/
structure PredictiveCodingMap where
  /-- Prediction error `ε`. -/
  epsilon : ℝ
  /-- `Φ₀`-gradient (local projection onto `K(Y)`). -/
  gradPhi0 : ℝ
  /-- Posited error ↔ gradient identification. -/
  errGrad : epsilon = gradPhi0

/-- **R.410(c) — recorded identity (conditional on the PC bundle).**
Prediction error equals the local `Φ₀`-gradient. -/
theorem R_410_c_errGrad (P : PredictiveCodingMap) : P.epsilon = P.gradPhi0 :=
  P.errGrad

end FristonPropositions

end MIP
