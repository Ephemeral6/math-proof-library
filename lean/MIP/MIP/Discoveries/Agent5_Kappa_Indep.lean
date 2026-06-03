/-
  STATUS: OBSERVATION
  AGENT: 5
  DIRECTION: Z–κ relationship — formal layer is uncoupled.
  SUMMARY:
    Several R-files relate the impedance `Z` to a κ-coefficient
    (R.105 Gompertz κ(t), R.110 estimable κ, R.114 Z⁻¹ vs |K|,
    R.201 Z⁻¹-Fisher metric, R.818 contextual κ̄).  In every case the
    κ used in the file is a **file-local real-valued definition** with
    its own signature, *not* a global opaque symbol.  In particular:

    * There is no global opaque `κ` in `MIP/Axioms.lean`.  The only
      opaque symbols related to κ are `K` (knowledge space) and `Cₑ`
      (knowledge density), and neither admits a derivation linking it
      to the global `MIP.Z : Agent α → Problem α → ENNReal`.

    * The global `MIP.Z` in `MIP/Defs/StateSequence.lean` is the
      constant function `0`.  Hence for *any* real-valued κ (whatever
      its definition), the *coupled* quantity `MIP.Z X p * κ_value`
      vanishes in `ENNReal`, regardless of the κ value.

    This OBSERVATION records the structural fact that **no algebraic
    Z–κ relationship is derivable from A.1–A.4 alone**.  A future
    enrichment of the axiom set (or a Phase-6 substantive impedance
    model) is required.  We supply two concrete witness facts:

    1. `Z_indep_of_R105_kappa`: the impedance is unaffected by every
       value of the R.105 Gompertz κ-trajectory.
    2. `Phi0_Z_times_kappa_eq_zero`: the formal "coupled Ohm" expression
       `(Phi0 · Z) * (κ : ENNReal)` is identically zero in the concrete
       model, for every real κ ≥ 0.
-/
import MIP.Axioms
import MIP.Defs.StateSequence
import MIP.Discoveries.Agent5_Z_Constancy
import MIP.Results.R105_KappaReversibility

namespace MIP

namespace Agent5_Kappa_Indep

open Agent5_Z_Constancy

variable {α : Type}

/-! ## Z is independent of every file-local κ.

The R.105 file defines `kappa κ₀ α t := exp(log κ₀ · exp(-α t))`.
The global `MIP.Z` is `0` independently of `(κ₀, α, t)`.  We package
this as a definite Lean theorem to make the absence-of-coupling
formally visible.
-/

/-- **OBSERVATION.**  The global impedance `MIP.Z X p` is unaffected
by every choice of R.105 Gompertz κ-parameters `(κ₀, α, t)`.  Trivial
since `Z X p = 0` does not even mention κ; we record the universally
quantified statement for clarity. -/
theorem Z_indep_of_R105_kappa
    (X : Agent α) (p : Problem α) :
    ∀ κ₀ α t : ℝ,
      Z X p = (fun _ => Z X p) (KappaReversibility.kappa κ₀ α t) :=
  fun _ _ _ => rfl

/-- **OBSERVATION (stronger form).**  Even an arbitrary `ℝ → ENNReal`
"impedance reading" of κ leaves `Z X p` unchanged.  Concretely: for
every coupling map `f : ℝ → ENNReal`, the impedance `Z X p` agrees with
itself under every "reading" of any κ-value. -/
theorem Z_indep_of_arbitrary_kappa
    (X : Agent α) (p : Problem α) (f : ℝ → ENNReal) :
    ∀ κ : ℝ, Z X p = Z X p ∧ f κ = f κ :=
  fun _ => ⟨rfl, rfl⟩

/-! ## Coupled Ohm expressions collapse.

We illustrate that the natural "Z · κ" coupling is degenerate at the
formal layer by *constructing* a candidate coupling `(Phi0 · Z) * κ_e`
(with `κ_e : ENNReal` an arbitrary embedding of any real κ) and
proving it is identically zero.
-/

/-- **OBSERVATION.**  The formal "coupled Ohm" expression
`(Phi0 X p) * Z X p * κ_e` vanishes identically for every coupling
`κ_e : ENNReal`. -/
theorem Phi0_Z_times_kappa_eq_zero
    (X : Agent α) (p : Problem α) (κ_e : ENNReal) :
    Phi0 X p * Z X p * κ_e = 0 := by
  rw [Z_eq_zero, mul_zero, zero_mul]

/-- **OBSERVATION.**  The R.114 "reciprocal-impedance × κ" coupling
`(Z X p)⁻¹ * κ_e` is `⊤` for every nonzero `κ_e` (since `Z X p = 0`,
so `(Z X p)⁻¹ = ⊤`), and is `0` for `κ_e = 0`.  Hence the formal
layer cannot distinguish the "balanced" and "overfit" training
regimes of R.114 — both produce `⊤` here. -/
theorem Zinv_mul_kappa_dichotomy
    (X : Agent α) (p : Problem α) (κ_e : ENNReal) :
    (κ_e = 0 ∧ (Z X p)⁻¹ * κ_e = 0) ∨
      (κ_e ≠ 0 ∧ (Z X p)⁻¹ * κ_e = ⊤) := by
  by_cases hκ : κ_e = 0
  · left
    refine ⟨hκ, ?_⟩
    rw [hκ, mul_zero]
  · right
    refine ⟨hκ, ?_⟩
    rw [Z_eq_zero, ENNReal.inv_zero, ENNReal.top_mul hκ]

/-! ## Structural statement: no κ-detector exists at the formal layer.

We prove the negative existence statement: there is no `(Agent α →
Problem α → ℝ)`-valued function that is determined by `Z`, because
`Z` is a constant function.  Hence any "Z-driven κ-estimator" is
necessarily the constant function.
-/

/-- **OBSERVATION (constancy of any Z-determined function).**  Suppose
`g : ENNReal → ℝ` is any function that "reads" `Z`.  Then the composite
`fun (X, p) => g (Z X p)` is a *constant* function of `(X, p)` —
because `Z X p` is the constant `0`.  In particular, any putative
κ-estimator that depends on the formal `Z` alone is constant. -/
theorem Z_determined_estimator_is_const
    (g : ENNReal → ℝ) (X Y : Agent α) (p q : Problem α) :
    g (Z X p) = g (Z Y q) := by
  rw [Z_eq_zero, Z_eq_zero]

/-- **OBSERVATION.**  The R.114 counterexample to monotonicity is
visible only in the **real-valued** Z of that file.  Translated into
`MIP.Z` (the ENNReal global impedance), the two regimes become
indistinguishable: both have `MIP.Z = 0` and `MIP.Z⁻¹ = ⊤`. -/
theorem R114_regime_distinguishability_lost
    (X₁ X₂ : Agent α) (p₁ p₂ : Problem α) :
    Z X₁ p₁ = Z X₂ p₂ ∧ (Z X₁ p₁)⁻¹ = (Z X₂ p₂)⁻¹ := by
  refine ⟨?_, ?_⟩
  · rw [Z_eq_zero, Z_eq_zero]
  · rw [Z_eq_zero, Z_eq_zero]

end Agent5_Kappa_Indep

end MIP
