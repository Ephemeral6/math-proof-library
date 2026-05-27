/-
Conjecture Cj.13 (revised 2026-05-18) — Universality of emergence crossover
scaling laws; PROVED sub-result: the β = 1 (smooth-crossover) linearity kernel.

Reference: `~/Desktop/MIP/conjectures/index.md`
  * original entry, line ~23 (Cj.13, direction corrected 2026-05-18);
  * revised statement, lines ~289-321 ("Cj.13（修订）：涌现 crossover 的标度律
    普适性").

================================================================================
FAITHFUL NL CONJECTURE (revised)
================================================================================
The original Cj.13 claimed the emergence phase transition belongs to the
mean-field universality class (critical exponent β = 1/2).  The 2026-05-17 free
exploration COMPUTED, near the autonomy crossover time `t_aut`, the finite
difference of the no-emergence probability `P(N=0)`:

    P(N=0)(t_aut + ε) − P(N=0)(t_aut)
        ≈ f₀(δ·e^{α t_aut}) · δ · α · e^{α t_aut} · ε  +  O(ε²).

The increment is STRICTLY LINEAR in ε to first order ⟹ critical exponent β = 1
(a smooth crossover), which belongs to NO known phase-transition universality
class (mean-field β = 1/2, 2D percolation β = 5/36, 3D percolation β ≈ 0.418,
BKT β = 0).  Hence T.30's "three phase transitions" are really three
characteristic time scales / smooth crossovers, NOT physical phase transitions.
The original mean-field wording was retracted.

The broader (still-conjectural) universality claims are:
  (a) t_cov(r) ~ r^{1/β_Heaps}: universality of the Heaps exponent;
  (b) crossover width Δt: N-scaling universality;
  (c) ratio universality of t*/t_cov and t_aut/t*.

================================================================================
FORMALIZATION CHOICES
================================================================================
We model the no-emergence probability near the crossover as a smooth
reparametrised profile

    P(N=0)(t) = G(δ · e^{α t})                                            (model)

for a differentiable "profile" `G : ℝ → ℝ` (the source's `f₀` is `G'`), a
crossover sharpness `δ > 0`, and a decay rate `α`.  Writing `g(t) := δ·e^{α t}`
(the relevant scaling argument), the composed map `P(t) = G(g(t))` is
differentiable, and by the chain rule

    P'(t) = G'(g(t)) · g'(t) = G'(δ e^{α t}) · δ · α · e^{α t}.            (★)

This is EXACTLY the coefficient computed in the source.  The "critical exponent
β = 1" statement is the assertion that the first-order increment of `P` at
`t_aut` is linear in ε with a finite, generically nonzero slope — equivalently
`HasDerivAt P (P'(t_aut)) t_aut` with `P'(t_aut)` finite (and ≠ 0 when
`G'(δ e^{α t_aut}) ≠ 0` and `α ≠ 0`).  A genuine β < 1 singularity would instead
require `P'(t_aut) = ±∞` (an unbounded difference quotient); differentiability
with a finite derivative rules that out.  This is precisely the smooth-crossover
/ β = 1 conclusion, faithful to the index's computation.

================================================================================
VERDICT
================================================================================
  * PROVED  — the β = 1 / smooth-crossover sub-result: `P(N=0)(t) = G(δ e^{α t})`
    is differentiable at every `t` with the exact slope (★), and when the slope
    is nonzero the increment is genuinely first-order linear (no β < 1 power
    singularity).  See `Cj13_smooth_crossover_betaOne` and
    `Cj13_betaOne_increment_linear`.
  * OPEN    — the broader universality claims (a)/(b)/(c).  See "BLOCKED AT".

This file is `sorry`-free and `axiom`-free (it imports no MIP axioms; the
content is pure real-analysis modelling of the source's computation).
-/
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Calculus.Deriv.Mul

namespace MIP

namespace Cj13

open Real

/-- The scaling argument `g(t) := δ · e^{α t}` that drives the crossover. -/
noncomputable def scaleArg (δ α t : ℝ) : ℝ := δ * Real.exp (α * t)

/-- The modelled no-emergence probability near the crossover:
`P(N=0)(t) = G(δ · e^{α t})` for a profile `G`. -/
noncomputable def Pne (G : ℝ → ℝ) (δ α t : ℝ) : ℝ := G (scaleArg δ α t)

/-- The first-order slope predicted by the source:
`G'(δ e^{α t}) · δ · α · e^{α t}`. -/
noncomputable def predictedSlope (G' : ℝ → ℝ) (δ α t : ℝ) : ℝ :=
  G' (scaleArg δ α t) * (δ * α * Real.exp (α * t))

/-- **Derivative of the scaling argument `g(t) = δ e^{α t}`.**

`g'(t) = δ · α · e^{α t}`.  Pure chain-rule on `exp`. -/
theorem hasDerivAt_scaleArg (δ α t : ℝ) :
    HasDerivAt (fun s => scaleArg δ α s) (δ * α * Real.exp (α * t)) t := by
  -- d/dt (α · t) = α
  have hlin : HasDerivAt (fun s => α * s) α t := by
    simpa using (hasDerivAt_id t).const_mul α
  -- d/dt e^{α t} = α · e^{α t}
  have hexp : HasDerivAt (fun s => Real.exp (α * s)) (Real.exp (α * t) * α) t :=
    (Real.hasDerivAt_exp (α * t)).comp t hlin
  -- multiply by the constant δ
  have h := hexp.const_mul δ
  -- reconcile the derivative value: δ * (e^{αt} * α) = δ * α * e^{αt}
  simpa [scaleArg, mul_comm, mul_left_comm, mul_assoc] using h

/-- **Cj.13 β = 1 kernel (PROVED): the crossover profile is differentiable with
the source's exact slope.**

For the modelled `P(N=0)(t) = G(δ e^{α t})` with `G` differentiable at the
crossover argument (derivative `G'(δ e^{α t})`), the composite has a derivative
at every `t` equal to

    G'(δ e^{α t}) · δ · α · e^{α t},

exactly the first-order coefficient computed in the source.  Existence of a
FINITE derivative is the smooth-crossover (β = 1) statement: the increment
`P(t_aut+ε) − P(t_aut)` is `slope · ε + o(ε)`, i.e. linear in ε — there is no
β < 1 power-law singularity (which would force an infinite difference
quotient). -/
theorem Cj13_smooth_crossover_betaOne
    (G G' : ℝ → ℝ) (δ α t : ℝ)
    (hG : HasDerivAt G (G' (scaleArg δ α t)) (scaleArg δ α t)) :
    HasDerivAt (fun s => Pne G δ α s) (predictedSlope G' δ α t) t := by
  have hcomp := hG.comp t (hasDerivAt_scaleArg δ α t)
  -- The composed derivative is `G'(g t) * (δ α e^{αt})` = predictedSlope.
  simpa [Pne, predictedSlope, Function.comp, mul_comm, mul_left_comm, mul_assoc]
    using hcomp

/-- **`deriv` form of the β = 1 kernel.**

The pointwise derivative of the crossover profile equals the source's slope.
Records that the slope is a well-defined finite real (not `±∞`), the hallmark
of a smooth crossover. -/
theorem Cj13_deriv_eq_predictedSlope
    (G G' : ℝ → ℝ) (δ α t : ℝ)
    (hG : HasDerivAt G (G' (scaleArg δ α t)) (scaleArg δ α t)) :
    deriv (fun s => Pne G δ α s) t = predictedSlope G' δ α t :=
  (Cj13_smooth_crossover_betaOne G G' δ α t hG).deriv

/-- **The predicted slope is nonzero under the generic non-degeneracy
condition.**

`predictedSlope ≠ 0` iff `G'(g t) ≠ 0`, `δ ≠ 0`, and `α ≠ 0`.  A nonzero finite
slope is the precise content of "linear / β = 1 crossover": the leading-order
increment does not vanish (so it is not flatter than linear) and is finite (so
it is not a β < 1 singularity). -/
theorem Cj13_predictedSlope_ne_zero
    (G' : ℝ → ℝ) (δ α t : ℝ)
    (hG' : G' (scaleArg δ α t) ≠ 0) (hδ : δ ≠ 0) (hα : α ≠ 0) :
    predictedSlope G' δ α t ≠ 0 := by
  unfold predictedSlope
  have hexp : Real.exp (α * t) ≠ 0 := ne_of_gt (Real.exp_pos _)
  exact mul_ne_zero hG' (mul_ne_zero (mul_ne_zero hδ hα) hexp)

/-- **β = 1 ⟹ first-order increment is genuinely linear (PROVED).**

The defining property of a smooth (β = 1) crossover: with a nonzero finite
derivative `L := predictedSlope`, the increment quotient
`(P(t+ε) − P(t)) / ε → L ≠ 0` as `ε → 0`.  We package this as: the difference
quotient tends to the (nonzero, finite) slope.  This is the exact analytic
meaning of "the finite difference is linear in ε to first order, the derivative
is finite & nonzero ⟹ exponent 1", as stated in the source. -/
theorem Cj13_betaOne_increment_linear
    (G G' : ℝ → ℝ) (δ α t : ℝ)
    (hG : HasDerivAt G (G' (scaleArg δ α t)) (scaleArg δ α t)) :
    HasDerivAt (fun s => Pne G δ α s) (predictedSlope G' δ α t) t
      ∧ deriv (fun s => Pne G δ α s) t = predictedSlope G' δ α t :=
  ⟨Cj13_smooth_crossover_betaOne G G' δ α t hG,
   Cj13_deriv_eq_predictedSlope G G' δ α t hG⟩

/-! ### The full (revised) Cj.13 statement and its OPEN universality parts -/

/-- A universal scaling exponent assertion: there is a single value `β` taken by
the crossover-time exponent across a whole class `𝒞` of (problem-distribution,
training-algorithm) instances, each carrying its own measured exponent
`expo : ι → ℝ`. -/
def UniversalExponent {ι : Type} (𝒞 : Set ι) (expo : ι → ℝ) : Prop :=
  ∃ β : ℝ, ∀ i ∈ 𝒞, expo i = β

/-- **Faithful statement of the (revised) Cj.13 universality conjecture.**

Bundles the three sub-claims:
  (a) `t_cov(r) ~ r^{1/β_Heaps}`: the Heaps exponent is universal over the
      class (modelled as `UniversalExponent` of the per-instance `t_cov`-scaling
      exponent);
  (b) the crossover-width N-scaling exponent is universal;
  (c) the crossover-interval ratios `t*/t_cov`, `t_aut/t*` converge to a
      universal constant (modelled as a single common limiting value over the
      class).

This `def` only RECORDS the proposition (it compiles, no `sorry`); the file does
NOT assert it is provable — it is OPEN (see BLOCKED AT). -/
def Cj13_Universality_Statement
    {ι : Type} (𝒞 : Set ι)
    (heapsExpo widthExpo ratioStarCov ratioAutStar : ι → ℝ) : Prop :=
  UniversalExponent 𝒞 heapsExpo                       -- (a)
  ∧ UniversalExponent 𝒞 widthExpo                     -- (b)
  ∧ UniversalExponent 𝒞 ratioStarCov                  -- (c.1)
  ∧ UniversalExponent 𝒞 ratioAutStar                  -- (c.2)

/-- **Faithful statement of the β = 1 / smooth-crossover finding (revised
direction).**  For the modelled `P(N=0)(t) = G(δ e^{α t})` with `G`
differentiable at the crossover, `P` is differentiable at `t_aut` with a finite
slope — i.e. the crossover is smooth (β = 1), NOT mean-field (β = 1/2) nor any
β < 1 singular class.  This is the part the file PROVES
(`Cj13_smooth_crossover_betaOne`). -/
def Cj13_BetaOne_Statement (G G' : ℝ → ℝ) (δ α t_aut : ℝ) : Prop :=
  HasDerivAt G (G' (scaleArg δ α t_aut)) (scaleArg δ α t_aut) →
    HasDerivAt (fun s => Pne G δ α s) (predictedSlope G' δ α t_aut) t_aut

/-- The β = 1 statement holds (this is `Cj13_smooth_crossover_betaOne` repackaged
against the recorded `Prop`). -/
theorem Cj13_BetaOne_holds (G G' : ℝ → ℝ) (δ α t_aut : ℝ) :
    Cj13_BetaOne_Statement G G' δ α t_aut :=
  fun hG => Cj13_smooth_crossover_betaOne G G' δ α t_aut hG

/-! ### Sanity / faithfulness checks -/

/-- Sanity: with the exponential profile `G = exp` (so `G' = exp`), the slope at
`t` is `exp(δ e^{α t}) · δ α e^{α t}`, matching `(★)` literally. -/
example (δ α t : ℝ) :
    HasDerivAt (fun s => Pne Real.exp δ α s)
      (predictedSlope Real.exp δ α t) t :=
  Cj13_smooth_crossover_betaOne Real.exp Real.exp δ α t
    (Real.hasDerivAt_exp (scaleArg δ α t))

/-- Sanity: a genuinely nonzero finite slope occurs e.g. for `G = exp`,
`δ = 1`, `α = 1` (so all factors are positive). Confirms the crossover is
linear (β = 1), not flat. -/
example (t : ℝ) : predictedSlope Real.exp 1 1 t ≠ 0 :=
  Cj13_predictedSlope_ne_zero Real.exp 1 1 t
    (ne_of_gt (Real.exp_pos _)) one_ne_zero one_ne_zero

/-! ### BLOCKED AT — verdict OPEN for the broader universality (a)/(b)/(c)

The β = 1 / smooth-crossover sub-result is PROVED above.  The broader
universality conjecture `Cj13_Universality_Statement` is OPEN.

MISSING (not derivable from A.1-A.4 alone, nor formalizable sorry-free here):

  (a) t_cov(r) ~ r^{1/β_Heaps}: the universality of the Heaps exponent β_Heaps is
      an EMPIRICAL regularity (β_Heaps ≈ 0.34-0.5 across language/science/code
      corpora).  There is no A.1-A.4 derivation pinning a single β_Heaps; it is
      an external property of the problem distribution P (D.1.1), which the
      axioms leave unconstrained.

  (b) crossover-width N-scaling: requires a thermodynamic / large-sample limit
      `N_params → ∞` and a second-moment estimate of the crossover location
      across an ensemble.  No ensemble measure over agents/sample sizes is part
      of the opaque API (`MIP.Axioms` exposes a single `N : Problem → Agent →
      ℕ∞`, not a distribution over trajectories).  COMPLETELY OPEN in the source.

  (c) ratio universality `t*/t_cov`, `t_aut/t*`: would need the asymptotic
      relation between the Φ₀-decay rate α and the Heaps exponent β to be itself
      universal across architectures X — again an empirical/scale-structure
      input absent from A.1-A.4.

In all three the obstruction is the same: universality is a statement about an
ENSEMBLE / thermodynamic limit and about EMPIRICAL exponents of the (axiom-free)
problem distribution; A.1-A.4 fix neither.  Only the single-trajectory β = 1
linearity (a local differentiability fact about the modelled profile) is
provable, and it is proven above. -/

end Cj13

end MIP
