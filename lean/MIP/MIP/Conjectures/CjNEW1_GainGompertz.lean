/-
Conjecture Cj.NEW-1 — Gain is Gompertz in training depth, inflection late.

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.NEW-1, lines ~419-435);
`workspace/partition_function_theorem.md` §4.4.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
During training, the path-synergy gain `Gain(X_D, p)` grows as a Gompertz curve
in depth `D`:

    Gain(X_D, p) ≈ G∞ · exp(-exp(-α (D - D_Gain)))

and its inflection point `D_Gain` is LATER than the κ-curve inflection `D_κ`:

    D_Gain > D_κ.

Intuition: training has two phases — first learn single-path success (drives κ
growth), then learn to use multiple paths in parallel (drives Gain growth).

================================================================================
FORMALIZATION CHOICES
================================================================================
TM-family training dynamics (D.4.16) is not in `MIP.Axioms`, so the *dynamical*
content (that real `Gain(X_D)` follows a Gompertz law, and `D_Gain > D_κ`) is
not formalizable here. What IS a clean, self-contained mathematical fact is the
**inflection-point property of the Gompertz function**, which is the structural
backbone of the conjecture.

We define `gompertz G∞ α D_G t := G∞ · exp(-exp(-α (t - D_G)))` and prove, for
`G∞ > 0`, `α > 0`:
  * `gompertz_hasDerivAt`  : its first derivative everywhere;
  * `gompertz_deriv_hasDerivAt` : the derivative of the first derivative (i.e.
    the second derivative) everywhere;
  * `gompertz_inflection` : the second derivative is `> 0` for `t < D_G`,
    `= 0` at `t = D_G`, and `< 0` for `t > D_G`. Hence `t = D_G` is the unique
    inflection point (convex→concave transition), which is the meaning of
    "`D_Gain` is the Gompertz inflection".

================================================================================
VERDICT: OPEN.
================================================================================
PROVED (sorry-free): the Gompertz inflection-point lemma `gompertz_inflection`
(plus the two derivative lemmas it rests on). This is the clean calculus partial
the source flags as tractable.

BLOCKED AT: (i) showing the *actual* dynamics `D ↦ Gain(X_D, p)` follow a
Gompertz law; (ii) the ordering `D_Gain > D_κ`.
MISSING:
  1. A formalization of the TM-family training dynamics (D.4.16) and of
     `Gain(X_D, p)` as a measurable function of training depth `D` — absent from
     `MIP.Axioms`.
  2. A two-timescale separation argument (κ-inflection precedes Gain-inflection)
     linking the κ growth curve (R.98 dκ/dt Gompertz) to the Gain curve — this
     needs the full training-dynamics model, not just the static Gompertz shape.
We do NOT claim the dynamical conjecture; only the static inflection lemma.
-/
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Pow

namespace MIP

open Real

namespace CjNEW1

/-- The Gompertz growth curve `G∞ · exp(-exp(-α (t - D_G)))`. -/
noncomputable def gompertz (Ginf α D_G t : ℝ) : ℝ :=
  Ginf * Real.exp (-Real.exp (-α * (t - D_G)))

/-- The "inner" exponential `u(t) = exp(-α (t - D_G)) > 0`. -/
noncomputable def gompertzU (α D_G t : ℝ) : ℝ := Real.exp (-α * (t - D_G))

lemma gompertzU_pos (α D_G t : ℝ) : 0 < gompertzU α D_G t := Real.exp_pos _

/-- **First derivative of the Gompertz curve.**

`G'(t) = G∞ · exp(-u) · α · u`, where `u = exp(-α(t-D_G))`. Since the
amplitude and `α·u` are positive, `G` is strictly increasing (`G' > 0`). -/
theorem gompertz_hasDerivAt (Ginf α D_G t : ℝ) :
    HasDerivAt (gompertz Ginf α D_G)
      (Ginf * (Real.exp (-Real.exp (-α * (t - D_G))) *
        (α * Real.exp (-α * (t - D_G))))) t := by
  unfold gompertz
  -- inner: -α*(t-D_G), derivative -α.
  have h1 : HasDerivAt (fun t : ℝ => -α * (t - D_G)) (-α) t := by
    have : HasDerivAt (fun t : ℝ => t - D_G) (1 : ℝ) t :=
      (hasDerivAt_id t).sub_const D_G
    simpa using this.const_mul (-α)
  -- u(t) = exp(-α*(t-D_G)), derivative exp(...)*(-α).
  have h2 : HasDerivAt (fun t : ℝ => Real.exp (-α * (t - D_G)))
      (Real.exp (-α * (t - D_G)) * (-α)) t := h1.exp
  -- -u(t), derivative -(exp*(-α)) = exp*α.
  have h3 : HasDerivAt (fun t : ℝ => -Real.exp (-α * (t - D_G)))
      (-(Real.exp (-α * (t - D_G)) * (-α))) t := h2.neg
  -- exp(-u(t)), derivative exp(-u)*(-(exp*(-α))) = exp(-u)*(α*exp(...)).
  have h4 : HasDerivAt (fun t : ℝ => Real.exp (-Real.exp (-α * (t - D_G))))
      (Real.exp (-Real.exp (-α * (t - D_G))) *
        (-(Real.exp (-α * (t - D_G)) * (-α)))) t := h3.exp
  have h5 := h4.const_mul Ginf
  convert h5 using 1
  ring

/-- The first-derivative function. -/
noncomputable def gompertzD1 (Ginf α D_G t : ℝ) : ℝ :=
  Ginf * (Real.exp (-Real.exp (-α * (t - D_G))) * (α * Real.exp (-α * (t - D_G))))

/-- **`deriv` of the Gompertz curve equals `gompertzD1`.** -/
theorem gompertz_deriv (Ginf α D_G t : ℝ) :
    deriv (gompertz Ginf α D_G) t = gompertzD1 Ginf α D_G t :=
  (gompertz_hasDerivAt Ginf α D_G t).deriv

/-- **`G` is strictly increasing** when `G∞ > 0, α > 0`: its derivative is
positive everywhere. -/
theorem gompertz_deriv_pos (Ginf α D_G t : ℝ) (hG : 0 < Ginf) (hα : 0 < α) :
    0 < gompertzD1 Ginf α D_G t := by
  unfold gompertzD1
  have hexp1 : 0 < Real.exp (-Real.exp (-α * (t - D_G))) := Real.exp_pos _
  have hexp2 : 0 < Real.exp (-α * (t - D_G)) := Real.exp_pos _
  positivity

/-- **Second derivative of the Gompertz curve.**

`G''(t) = G∞ · α² · exp(-u) · u · (u - 1)`, where `u = exp(-α(t-D_G))`.

We prove `gompertzD1` has this as its derivative. The sign of `G''` is the sign
of `(u - 1)` (everything else positive), which is the inflection mechanism. -/
theorem gompertzD1_hasDerivAt (Ginf α D_G t : ℝ) :
    HasDerivAt (gompertzD1 Ginf α D_G)
      (Ginf * (α^2 * (Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1))))) t := by
  unfold gompertzD1
  -- Let E1 := exp(-exp(-α(t-D_G))), E2 := exp(-α(t-D_G)). Product is E1 * (α*E2).
  have h1 : HasDerivAt (fun t : ℝ => -α * (t - D_G)) (-α) t := by
    have : HasDerivAt (fun t : ℝ => t - D_G) (1 : ℝ) t :=
      (hasDerivAt_id t).sub_const D_G
    simpa using this.const_mul (-α)
  -- E2 = exp(-α(t-D_G)), E2' = E2 * (-α).
  have hE2 : HasDerivAt (fun t : ℝ => Real.exp (-α * (t - D_G)))
      (Real.exp (-α * (t - D_G)) * (-α)) t := h1.exp
  -- E1 = exp(-E2), E1' = E1 * (-(E2 * (-α))) = E1 * (α * E2).
  have hE1 : HasDerivAt (fun t : ℝ => Real.exp (-Real.exp (-α * (t - D_G))))
      (Real.exp (-Real.exp (-α * (t - D_G))) *
        (-(Real.exp (-α * (t - D_G)) * (-α)))) t := (hE2.neg).exp
  -- (α * E2) as a function, derivative α * (E2 * (-α)).
  have hαE2 : HasDerivAt (fun t : ℝ => α * Real.exp (-α * (t - D_G)))
      (α * (Real.exp (-α * (t - D_G)) * (-α))) t := hE2.const_mul α
  -- product E1 * (α*E2):
  have hprod := hE1.mul hαE2
  -- multiply by Ginf:
  have hfull := hprod.const_mul Ginf
  convert hfull using 1
  ring

/-- **Inflection point of the Gompertz curve (CORE CALCULUS LEMMA).**

For `G∞ > 0, α > 0`, the second derivative `G''(t)` satisfies:
  * `G''(t) > 0`  for `t < D_G`   (curve is convex — accelerating growth),
  * `G''(D_G) = 0`                (inflection),
  * `G''(t) < 0`  for `t > D_G`   (curve is concave — decelerating growth).

Hence `t = D_G` is the unique inflection point: the convex→concave transition.
This is exactly the sense in which `D_Gain` is "the Gompertz inflection". -/
theorem gompertz_inflection (Ginf α D_G : ℝ) (hG : 0 < Ginf) (hα : 0 < α) :
    (∀ t < D_G, 0 < deriv (gompertzD1 Ginf α D_G) t) ∧
    deriv (gompertzD1 Ginf α D_G) D_G = 0 ∧
    (∀ t > D_G, deriv (gompertzD1 Ginf α D_G) t < 0) := by
  -- Abbreviate the second-derivative value.
  have hval : ∀ t : ℝ, deriv (gompertzD1 Ginf α D_G) t =
      Ginf * (α^2 * (Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1)))) :=
    fun t => (gompertzD1_hasDerivAt Ginf α D_G t).deriv
  refine ⟨?_, ?_, ?_⟩
  · -- t < D_G ⟹ -α(t-D_G) > 0 ⟹ u = exp(...) > 1 ⟹ u - 1 > 0 ⟹ G'' > 0.
    intro t ht
    rw [hval t]
    have hu : 1 < Real.exp (-α * (t - D_G)) := by
      have hpos : 0 < -α * (t - D_G) := by nlinarith [hα, sub_neg.mpr ht]
      exact Real.one_lt_exp_iff.mpr hpos
    have hE1 : 0 < Real.exp (-Real.exp (-α * (t - D_G))) := Real.exp_pos _
    have hE2 : 0 < Real.exp (-α * (t - D_G)) := Real.exp_pos _
    have hα2 : 0 < α^2 := by positivity
    have hfac : 0 < Real.exp (-α * (t - D_G)) - 1 := by linarith
    have hpos : 0 < Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1) :=
      mul_pos hE2 hfac
    have hE1pos : 0 < Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1)) :=
      mul_pos hE1 hpos
    have hα2pos : 0 < α^2 * (Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1))) :=
      mul_pos hα2 hE1pos
    exact mul_pos hG hα2pos
  · -- t = D_G ⟹ -α*0 = 0 ⟹ u = exp 0 = 1 ⟹ u - 1 = 0 ⟹ G'' = 0.
    rw [hval D_G]
    have h0 : -α * (D_G - D_G) = 0 := by ring
    rw [h0, Real.exp_zero]; ring
  · -- t > D_G ⟹ -α(t-D_G) < 0 ⟹ u < 1 ⟹ u - 1 < 0 ⟹ G'' < 0.
    intro t ht
    rw [hval t]
    have hu : Real.exp (-α * (t - D_G)) < 1 := by
      have : -α * (t - D_G) < 0 := by nlinarith [hα, sub_pos.mpr ht]
      exact Real.exp_lt_one_iff.mpr this
    have hE1 : 0 < Real.exp (-Real.exp (-α * (t - D_G))) := Real.exp_pos _
    have hE2 : 0 < Real.exp (-α * (t - D_G)) := Real.exp_pos _
    have hα2 : 0 < α^2 := by positivity
    have hfac : Real.exp (-α * (t - D_G)) - 1 < 0 := by linarith
    -- product Ginf * (α² * (E1 * (E2 * neg))) < 0
    have hneg : Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1) < 0 :=
      mul_neg_of_pos_of_neg hE2 hfac
    have hE1neg : Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1)) < 0 :=
      mul_neg_of_pos_of_neg hE1 hneg
    have hα2neg : α^2 * (Real.exp (-Real.exp (-α * (t - D_G))) *
        (Real.exp (-α * (t - D_G)) * (Real.exp (-α * (t - D_G)) - 1))) < 0 :=
      mul_neg_of_pos_of_neg hα2 hE1neg
    exact mul_neg_of_pos_of_neg hG hα2neg

/-! ### Statement of Cj.NEW-1 (dynamical form) — recorded, NOT proved.

The full conjecture asserts the existence of Gompertz parameters fitting the
actual `Gain(X_D, p)` curve, with inflection `D_Gain > D_κ`. We record it as a
`Prop` parameterised over an abstract `Gain : ℝ → ℝ` and a κ-inflection `D_κ`;
no theorem proves it (see VERDICT / BLOCKED AT). -/
def CjNEW1_Statement (Gain : ℝ → ℝ) (D_kappa : ℝ) : Prop :=
  ∃ (Ginf α D_Gain : ℝ), 0 < Ginf ∧ 0 < α ∧
    (Gain = gompertz Ginf α D_Gain) ∧ D_kappa < D_Gain

end CjNEW1

end MIP
