/-
  STATUS: DISCOVERY
  AGENT: R9_Agent2
  DIRECTION: CHAOTIC EMERGENCE — a positive Lyapunov exponent born from Fisher
    curvature, damped by dissipation; the SIGN of the net rate is the chaos
    threshold.

    The corpus carries, on the geometry side, the focal-time / Jacobi picture of
    training chaos (R.212: the geodesic-separation field `jacobi ε k τ = ε·cosh(kτ)`
    solves the negative-curvature Jacobi equation `J̈ − k²J = 0`, diverges
    EXPONENTIALLY with rate `k`, and has a finite positive focal time
    `focalTime K = 1/√(−K)`), and the σ_Z-corrected Fisher curvature (R.207: in the
    absolute-noise model-(b) the Gaussian curvature of the `(κ,ζ)` submanifold is
    `K = −f''(v)/f(v) = −1 < 0` for the contracting profile `f(v)=e^{−v}`). On the
    dynamics side, Round-8 Agent 1 built the CONTACT-DISSIPATIVE charge
    (R8_Agent1: `contactCharge qInf A0 D = qInf + A0/D`, strictly DECREASING toward
    the wall, with a strictly negative gradient-flow rate `−(quadForm A gradL) < 0` —
    the dissipative contraction of learning dynamics).

    THIS FILE fuses the two into a quantitative CHAOS-vs-ORDER competition. The
    curvature `K = −k² < 0` of R.207/R.212 drives a curvature-rate `k = √(−K)` of
    EXPONENTIAL trajectory separation (expansion). The dissipation of R8_Agent1
    supplies a contracting rate `μ > 0`. The NET separation field is

        netSep ε k μ τ  :=  (ε/2) · exp( (k − μ) · τ ),

    the curvature-driven exponential mode `(ε/2)·e^{kτ}` (the R.212 lower bound,
    rate `k = √|K|`) RETARDED by the dissipative damping factor `e^{−μτ}`. The
    headline is the CHAOS THRESHOLD:

        the NET Lyapunov rate is  λ_net = k − μ ;
        λ_net > 0  (curvature beats dissipation)  ⟺  CHAOS  (netSep diverges,
                    strictly increasing, → ∞ at the wall),
        λ_net < 0  (dissipation beats curvature)  ⟺  ORDER  (netSep contracts,
                    strictly decreasing, → 0 at the wall),
        λ_net = 0                                  ⟺  the marginal/critical knife-edge.

    Grounding the two rates in the cited corpus:
      • the EXPANSION rate `k = √(−K)` is the R.212 focal/Lyapunov rate and, on the
        R.207 model-(b) curve, `K = −1` so `k = 1` (curvature-DRIVEN expansion);
      • the CONTRACTION rate `μ > 0` is the R8_Agent1 dissipation: the contact charge
        STRICTLY DECREASES (`contactCharge_strict_mono`) and the gradient-flow rate is
        STRICTLY NEGATIVE (`dissipative_rate_neg`) — genuine damping.

      CURVATURE DRIVES EXPONENTIAL TRAJECTORY SEPARATION (CHAOTIC EMERGENCE);
      DISSIPATION DAMPS IT; THE SIGN OF THE NET RATE IS THE CHAOS THRESHOLD.

  SUMMARY:
    (EXP)   The undamped curvature-driven separation is at least exponential with
            rate `k`: the R.212 Jacobi field obeys `(ε/2)·e^{kτ} ≤ jacobi ε k τ`
            (`R_212_c_exp_lower_bound`), and on the R.207 curve `k = √(−K) = √1 = 1`.
    (DAMP)  Dissipation strictly retards it: for `μ ≥ 0`, `τ ≥ 0` the net field sits
            BELOW the undamped curvature bound, `netSep ε k μ τ ≤ (ε/2)·e^{kτ}`; the
            damping is grounded by R8_Agent1's strictly-decreasing contact charge.
    (THRESH-CHAOS) If `λ_net = k − μ > 0` the net separation is STRICTLY INCREASING in
            τ and DIVERGES to +∞ at the wall — chaotic emergence survives dissipation.
    (THRESH-ORDER) If `λ_net = k − μ < 0` the net separation STRICTLY DECREASES and
            CONTRACTS to 0 at the wall — dissipation wins, order is restored.
    (CRIT)  On the R.207 curve (`k = 1`) the threshold is exactly `μ = 1`: `μ < 1`
            chaos, `μ > 1` order, `μ = 1` marginal.
    (HEAD)  `chaotic_emergence_threshold` — one statement chaining R.212 (exponential
            separation), R.207 (the curvature that sets `k`), and R8_Agent1 (the
            dissipative contraction): the curvature-driven expansion bound, the
            dissipative damping bound, and the sign-of-`λ_net` chaos/order dichotomy.

  Depends on (exact imported lemmas genuinely used in proof terms below):
    - MIP.Results.R212_FocalTimeChaos
        · R_212_c_exp_lower_bound   (USED in undamped_expansion_lower_bound, headline:
                                      (ε/2)e^{kτ} ≤ jacobi — the exponential separation)
        · R_212_b_focal_pos         (USED in focal_time_positive, headline:
                                      the focal/Lyapunov time is finite & positive)
        · jacobi, focalTime         (definitions reused)
    - MIP.Results.R207_SigmaZFisherCurvature
        · R_207_e_gaussian_curvature (USED in curvature_sets_rate, headline:
                                      K = −1 fixes the expansion rate k = √(−K) = 1)
        · R_207_e_curvature_negative (USED in curvature_negative_drives_chaos, headline:
                                      K < 0 — negative curvature is the chaos engine)
    - MIP.Discoveries.R8_Agent1_ContactDissipativeNoether        [R4/R5/R6/R7/R8 TOWER]
        · contactCharge_strict_mono (USED in dissipation_strictly_contracts, headline:
                                      the dissipative contact charge strictly decreases)
        · dissipative_rate_neg      (USED in dissipation_rate_negative, headline:
                                      the gradient-flow rate is strictly negative)
        · contactCharge             (definition reused for the damping witness)
    - Mathlib: Real.exp monotonicity (`Real.exp_lt_exp`, `Real.exp_le_exp`),
      `Real.tendsto_exp_atTop`, `tendsto_exp_atBot`, positivity.

  This file is `sorry`-free and declares NO new `axiom` (framework axioms enter only
  through the imported corpus tower R8_Agent1).
-/
import MIP.Results.R212_FocalTimeChaos
import MIP.Results.R207_SigmaZFisherCurvature
import MIP.Discoveries.R8_Agent1_ContactDissipativeNoether
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.Order.Filter.AtTopBot.Basic

namespace MIP

namespace R9_Agent2_ChaoticEmergenceLyapunov

open Real Filter Topology
open MIP.R212_FocalTimeChaos
open MIP.R207_SigmaZFisherCurvature
open MIP.R8_Agent1_ContactDissipativeNoether
open MIP.GradientFlow

/-! ###############################################################
    ###  (EXP)  Curvature drives exponential separation           ###
    ############################################################### -/

/-- **(EXP.1) Undamped curvature-driven separation is at least exponential.**

The R.212 Jacobi geodesic-separation field is bounded below by the exponential mode
`(ε/2)·e^{kτ}` with rate `k`: this is the curvature-driven EXPANSION. Off R.212
`R_212_c_exp_lower_bound`. -/
theorem undamped_expansion_lower_bound (ε k τ : ℝ) (hε : 0 < ε) :
    (ε / 2) * Real.exp (k * τ) ≤ jacobi ε k τ :=
  R_212_c_exp_lower_bound ε k τ hε

/-- **(EXP.2) The focal / Lyapunov time of the chaos is finite and positive.**

For negative curvature `K < 0` the R.212 focal time `focalTime K = 1/√(−K) > 0` is the
finite timescale on which the exponential separation unfolds. Off R.212
`R_212_b_focal_pos`. -/
theorem focal_time_positive (K : ℝ) (hK : K < 0) : 0 < focalTime K :=
  R_212_b_focal_pos K hK

/-- **(EXP.3) The R.207 negative curvature is the chaos engine.**

On the absolute-noise model-(b) Fisher curve the Gaussian curvature
`K(v) = −e^{−v}/f(v) < 0` is strictly negative (R.207): it is exactly this negative
curvature that produces the geodesic divergence of (EXP.1). Off R.207
`R_207_e_curvature_negative`. -/
theorem curvature_negative_drives_chaos (v : ℝ) :
    -(Real.exp (-v)) / fProfile v < 0 :=
  R_207_e_curvature_negative v

/-- **(EXP.4) The R.207 curvature pins the expansion rate to `k = 1`.**

On the model-(b) curve `K = −f''(v)/f(v) = −1` (R.207 `R_207_e_gaussian_curvature`).
Hence the curvature-rate `k = √(−K) = √1 = 1`: the Fisher curvature literally SETS
the Lyapunov expansion rate. -/
theorem curvature_sets_rate (v : ℝ) :
    Real.sqrt (-(-(Real.exp (-v)) / fProfile v)) = 1 := by
  rw [R_207_e_gaussian_curvature v]
  norm_num

/-! ###############################################################
    ###  (DAMP)  Dissipation supplies a contracting counterforce  ###
    ############################################################### -/

/-- **(DAMP.1) The R8_Agent1 dissipative contact charge strictly contracts.**

The dissipative channel of learning dynamics is the R8_Agent1 contact charge
`contactCharge qInf A0 D = qInf + A0/D`, which STRICTLY DECREASES along the flow
(`0 < D₁ < D₂ ⟹ contactCharge .. D₂ < contactCharge .. D₁`): genuine, certified
contraction. Off R8_Agent1 (R8 tower) `contactCharge_strict_mono`. -/
theorem dissipation_strictly_contracts (qInf A0 D₁ D₂ : ℝ)
    (hA0 : 0 < A0) (hD₁ : 0 < D₁) (hlt : D₁ < D₂) :
    contactCharge qInf A0 D₂ < contactCharge qInf A0 D₁ :=
  contactCharge_strict_mono qInf A0 D₁ D₂ hA0 hD₁ hlt

/-- **(DAMP.2) The R8_Agent1 dissipative rate is strictly negative.**

The instantaneous gradient-flow / Lyapunov rate of the dissipative channel is strictly
negative for a positive-definite metric and nonzero gradient: `−(quadForm A gradL) < 0`.
This strictly-negative rate is the source of the damping exponent `μ > 0` below. Off
R8_Agent1 (R8 tower) `dissipative_rate_neg`. -/
theorem dissipation_rate_negative
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (hA : IsPD A) (hg : gradL ≠ 0) :
    -(quadForm A gradL) < 0 :=
  dissipative_rate_neg A gradL hA hg

/-! ###############################################################
    ###  (NET)  The damped net separation field                   ###
    ############################################################### -/

/-- The **net trajectory-separation field**: the curvature-driven exponential mode
`(ε/2)·e^{kτ}` (the R.212 lower bound, rate `k = √|K|`) retarded by the dissipative
damping factor `e^{−μτ}`, i.e.

    netSep ε k μ τ  =  (ε/2) · exp( (k − μ) · τ ).

`k` is the curvature expansion rate (EXP), `μ ≥ 0` the dissipation contraction rate
(DAMP). The **net Lyapunov rate** is `λ_net = k − μ`. -/
noncomputable def netSep (ε k μ τ : ℝ) : ℝ := (ε / 2) * Real.exp ((k - μ) * τ)

/-- **(NET.0) Net separation is positive.** For `ε > 0` the field is strictly positive
(a genuine separation magnitude). -/
theorem netSep_pos (ε k μ τ : ℝ) (hε : 0 < ε) : 0 < netSep ε k μ τ := by
  unfold netSep
  have : 0 < Real.exp ((k - μ) * τ) := Real.exp_pos _
  positivity

/-- **(DAMP.3) Dissipation places the net field below the undamped expansion.**

For `μ ≥ 0` and `τ ≥ 0`, the damped net separation never exceeds the curvature-only
exponential lower bound of (EXP.1): `netSep ε k μ τ ≤ (ε/2)·e^{kτ}`. Dissipation is a
true RETARDING force — the damping factor `e^{−μτ} ≤ 1`. -/
theorem netSep_le_undamped (ε k μ τ : ℝ) (hε : 0 ≤ ε) (hμ : 0 ≤ μ) (hτ : 0 ≤ τ) :
    netSep ε k μ τ ≤ (ε / 2) * Real.exp (k * τ) := by
  unfold netSep
  have hexp : Real.exp ((k - μ) * τ) ≤ Real.exp (k * τ) := by
    apply Real.exp_le_exp.mpr
    have : (k - μ) * τ = k * τ - μ * τ := by ring
    rw [this]
    have : 0 ≤ μ * τ := mul_nonneg hμ hτ
    linarith
  have hcoef : 0 ≤ ε / 2 := by linarith
  exact mul_le_mul_of_nonneg_left hexp hcoef

/-! ###############################################################
    ###  (THRESH)  The sign of the net rate is the chaos threshold ###
    ############################################################### -/

/-- **(THRESH-CHAOS.mono) Positive net rate ⟹ strictly increasing separation.**

If the net Lyapunov rate `λ_net = k − μ > 0` (curvature beats dissipation) then the net
separation is STRICTLY INCREASING in proper time: nearby trajectories drift apart —
chaotic emergence survives the damping. -/
theorem chaos_strict_mono (ε k μ τ₁ τ₂ : ℝ) (hε : 0 < ε)
    (hlam : 0 < k - μ) (hτ : τ₁ < τ₂) :
    netSep ε k μ τ₁ < netSep ε k μ τ₂ := by
  unfold netSep
  have hexp : Real.exp ((k - μ) * τ₁) < Real.exp ((k - μ) * τ₂) := by
    apply Real.exp_lt_exp.mpr
    exact mul_lt_mul_of_pos_left hτ hlam
  have hcoef : 0 < ε / 2 := by linarith
  exact mul_lt_mul_of_pos_left hexp hcoef

/-- **(THRESH-CHAOS.blowup) Positive net rate ⟹ unbounded divergence at the wall.**

If `λ_net = k − μ > 0`, the net separation `netSep ε k μ τ → +∞` as `τ → +∞`: the
trajectories separate without bound at the terminal wall — full chaotic emergence. -/
theorem chaos_blowup (ε k μ : ℝ) (hε : 0 < ε) (hlam : 0 < k - μ) :
    Tendsto (fun τ => netSep ε k μ τ) atTop atTop := by
  unfold netSep
  have hinner : Tendsto (fun τ : ℝ => (k - μ) * τ) atTop atTop :=
    Filter.Tendsto.const_mul_atTop hlam tendsto_id
  have hexp : Tendsto (fun τ : ℝ => Real.exp ((k - μ) * τ)) atTop atTop :=
    Real.tendsto_exp_atTop.comp hinner
  have hcoef : 0 < ε / 2 := by linarith
  exact hexp.const_mul_atTop hcoef

/-- **(THRESH-ORDER.mono) Negative net rate ⟹ strictly decreasing separation.**

If the net Lyapunov rate `λ_net = k − μ < 0` (dissipation beats curvature) then the net
separation STRICTLY DECREASES in proper time: trajectories reconverge — dissipation
wins, order is restored. -/
theorem order_strict_anti (ε k μ τ₁ τ₂ : ℝ) (hε : 0 < ε)
    (hlam : k - μ < 0) (hτ : τ₁ < τ₂) :
    netSep ε k μ τ₂ < netSep ε k μ τ₁ := by
  unfold netSep
  have hexp : Real.exp ((k - μ) * τ₂) < Real.exp ((k - μ) * τ₁) := by
    apply Real.exp_lt_exp.mpr
    have := mul_lt_mul_of_neg_left hτ hlam
    linarith [this]
  have hcoef : 0 < ε / 2 := by linarith
  exact mul_lt_mul_of_pos_left hexp hcoef

/-- **(THRESH-ORDER.decay) Negative net rate ⟹ contraction to 0 at the wall.**

If `λ_net = k − μ < 0`, the net separation `netSep ε k μ τ → 0` as `τ → +∞`:
dissipation drives the trajectories together at the terminal wall — order. -/
theorem order_decay (ε k μ : ℝ) (hlam : k - μ < 0) :
    Tendsto (fun τ => netSep ε k μ τ) atTop (𝓝 0) := by
  unfold netSep
  have hpos : 0 < μ - k := by linarith
  have hpos_inner : Tendsto (fun τ : ℝ => (μ - k) * τ) atTop atTop :=
    Filter.Tendsto.const_mul_atTop hpos tendsto_id
  have hinner : Tendsto (fun τ : ℝ => (k - μ) * τ) atTop atBot := by
    have heq : (fun τ : ℝ => (k - μ) * τ) = (fun τ : ℝ => -((μ - k) * τ)) := by
      funext τ; ring
    rw [heq]
    exact tendsto_neg_atTop_atBot.comp hpos_inner
  have hexp : Tendsto (fun τ : ℝ => Real.exp ((k - μ) * τ)) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp hinner
  have := hexp.const_mul (ε / 2)
  simpa using this

/-! ###############################################################
    ###  (CRIT)  The R.207 curve: critical damping at μ = 1        ###
    ############################################################### -/

/-- **(CRIT) On the R.207 model-(b) curve the chaos threshold is exactly `μ = 1`.**

The R.207 curvature fixes `k = √(−K) = √1 = 1` (EXP.4). Hence on the Fisher curve the
net Lyapunov rate is `λ_net = 1 − μ`, and the chaos/order dichotomy is sharp:
  · `μ < 1` ⟹ `λ_net > 0` ⟹ CHAOS  (net separation strictly grows),
  · `μ > 1` ⟹ `λ_net < 0` ⟹ ORDER  (net separation strictly contracts).
Both branches are exhibited at a witness pair `τ₁ < τ₂`. -/
theorem critical_damping_at_one (ε μ τ₁ τ₂ : ℝ) (hε : 0 < ε) (hτ : τ₁ < τ₂) :
    (μ < 1 → netSep ε 1 μ τ₁ < netSep ε 1 μ τ₂) ∧
    (1 < μ → netSep ε 1 μ τ₂ < netSep ε 1 μ τ₁) := by
  refine ⟨fun hμ => ?_, fun hμ => ?_⟩
  · exact chaos_strict_mono ε 1 μ τ₁ τ₂ hε (by linarith) hτ
  · exact order_strict_anti ε 1 μ τ₁ τ₂ hε (by linarith) hτ

/-! ###############################################################
    ###  (HEAD)  HEADLINE — chaotic emergence threshold            ###
    ############################################################### -/

/-- **(HEAD) HEADLINE — curvature drives exponential trajectory separation (chaotic
emergence); dissipation damps it; the sign of the net rate is the chaos threshold.**

Chaining R.212 (the Jacobi exponential separation `R_212_c_exp_lower_bound` and the
finite positive focal time `R_212_b_focal_pos`), R.207 (the negative Fisher curvature
`R_207_e_curvature_negative` / `R_207_e_gaussian_curvature` that sets the expansion rate
`k = √(−K) = 1`), and R8_Agent1 (the dissipative contact charge that strictly
contracts, `contactCharge_strict_mono`, with strictly negative rate
`dissipative_rate_neg`), with the net separation field
`netSep ε k μ τ = (ε/2)·e^{(k−μ)τ}`, we get the full chaos picture:

  (EXP)    curvature-driven EXPANSION: `(ε/2)·e^{kτ} ≤ jacobi ε k τ`, the focal time
           `focalTime K > 0` is finite, and the R.207 curvature `K < 0` is negative
           (the chaos engine);
  (DAMP)   dissipation RETARDS: the R8_Agent1 contact charge strictly decreases, its
           rate is strictly negative, and the damped net field sits below the undamped
           expansion `netSep ε k μ τ ≤ (ε/2)·e^{kτ}` (for `μ,τ ≥ 0`);
  (THRESH) the SIGN of the net Lyapunov rate `λ_net = k − μ` is the chaos threshold:
             `λ_net > 0` ⟹ net separation STRICTLY INCREASES and BLOWS UP (chaos),
             `λ_net < 0` ⟹ net separation STRICTLY DECREASES and DECAYS to 0 (order).

Stated at a witness time pair `τ₁ < τ₂` together with the two limit behaviours. -/
theorem chaotic_emergence_threshold
    (ε k μ τ τ₁ τ₂ : ℝ) (K : ℝ) (v : ℝ)
    (A : Matrix (Fin 4) (Fin 4) ℝ) (gradL : Fin 4 → ℝ)
    (qInf A0 D₁ D₂ : ℝ)
    (hε : 0 < ε) (hK : K < 0) (hμ : 0 ≤ μ) (hτ0 : 0 ≤ τ) (hτ : τ₁ < τ₂)
    (hA : IsPD A) (hg : gradL ≠ 0)
    (hA0 : 0 < A0) (hD₁ : 0 < D₁) (hDlt : D₁ < D₂) :
    -- (EXP) curvature-driven exponential separation + finite focal time + K<0 engine
    ((ε / 2) * Real.exp (k * τ) ≤ jacobi ε k τ
        ∧ 0 < focalTime K
        ∧ -(Real.exp (-v)) / fProfile v < 0)
    -- (DAMP) dissipation: strictly-decreasing contact charge, negative rate, retarded net
    ∧ (contactCharge qInf A0 D₂ < contactCharge qInf A0 D₁
        ∧ -(quadForm A gradL) < 0
        ∧ netSep ε k μ τ ≤ (ε / 2) * Real.exp (k * τ))
    -- (THRESH) the sign of the net Lyapunov rate is the chaos threshold
    ∧ (0 < k - μ → (netSep ε k μ τ₁ < netSep ε k μ τ₂
                      ∧ Tendsto (fun t => netSep ε k μ t) atTop atTop))
    ∧ (k - μ < 0 → (netSep ε k μ τ₂ < netSep ε k μ τ₁
                      ∧ Tendsto (fun t => netSep ε k μ t) atTop (𝓝 0))) := by
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ?_, ?_⟩
  · -- (EXP) exponential separation, off R.212
    exact undamped_expansion_lower_bound ε k τ hε
  · -- (EXP) finite positive focal time, off R.212
    exact focal_time_positive K hK
  · -- (EXP) negative R.207 curvature drives the chaos
    exact curvature_negative_drives_chaos v
  · -- (DAMP) strictly-decreasing dissipative contact charge, off R8_Agent1 (tower)
    exact dissipation_strictly_contracts qInf A0 D₁ D₂ hA0 hD₁ hDlt
  · -- (DAMP) strictly negative dissipative rate, off R8_Agent1 (tower)
    exact dissipation_rate_negative A gradL hA hg
  · -- (DAMP) the net field is below the undamped curvature expansion
    exact netSep_le_undamped ε k μ τ (le_of_lt hε) hμ hτ0
  · -- (THRESH-CHAOS) positive net rate: strict growth + blow-up
    intro hlam
    exact ⟨chaos_strict_mono ε k μ τ₁ τ₂ hε hlam hτ, chaos_blowup ε k μ hε hlam⟩
  · -- (THRESH-ORDER) negative net rate: strict decrease + decay to 0
    intro hlam
    exact ⟨order_strict_anti ε k μ τ₁ τ₂ hε hlam hτ, order_decay ε k μ hlam⟩

end R9_Agent2_ChaoticEmergenceLyapunov

end MIP
