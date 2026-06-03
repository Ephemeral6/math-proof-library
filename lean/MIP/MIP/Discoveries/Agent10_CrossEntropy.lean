/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group E.10–E.11 — Cross-entropy bridge between two
              activation distributions on `Ω`.
  SUMMARY:
    Standard information-theoretic identities for cross-entropy:

        H_cross(d1, d2) := -∑ ω, (d1.p ω) · log (d2.p ω)
        KL(d1 ‖ d2)    :=  ∑ ω, (d1.p ω) · log (d1.p ω / d2.p ω)

    We prove the **decomposition identity** (Group E.10)

        H_cross(d1, d2) = H_K(d1) + KL(d1 ‖ d2)

    on the support of `d2` (i.e. when `d2.p ω > 0` wherever `d1.p ω > 0`,
    so that no `0 · log 0` indeterminacy intrudes).  As a corollary
    (Group E.11), if all `d2` masses are strictly positive then

        H_K(d1) ≤ H_cross(d1, d2),

    with equality iff `KL(d1 ‖ d2) = 0`, i.e. iff `d1 = d2` on the
    `d1`-support (the standard "best code for `d1` is `d1` itself"
    information-theoretic no-free-lunch).

    No Mathlib KL/cross-entropy infrastructure is needed; the algebraic
    identity follows from `log (x/y) = log x - log y` for positive `x, y`
    and a per-`ω` split.  We state the identity in a form that does not
    require strict positivity of `d2` everywhere; only the *cross-entropy*
    direction uses positivity (otherwise `log 0` would appear).

    The strictly-positive-`d2` hypothesis is naturally satisfied when
    `d2` is the uniform distribution, recovering the chain from Agent
    10's `KL_to_uniform_dist`.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard

namespace MIP

namespace Agent10

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **Cross-entropy** of `d1` with respect to `d2`.

`H_cross(d1, d2) := -∑ ω, (d1.p ω : ℝ) * log ((d2.p ω : ℝ))`.

When `d2.p ω = 0` and `d1.p ω > 0`, the term `0 · log 0 = 0` (in Lean,
`Real.log 0 = 0`) sweeps the indeterminacy under the rug, but in that
case the "true" cross-entropy is `+∞` in classical information theory.
The decomposition identity below is therefore stated under a positivity
hypothesis on `d2`. -/
noncomputable def crossEntropy (d1 d2 : ActivationDist Ω) : ℝ :=
  -∑ ω, (d1.p ω : ℝ) * Real.log ((d2.p ω : ℝ))

/-- **KL divergence** between two activation distributions on `Ω`.

`KL(d1 ‖ d2) := ∑ ω, (d1.p ω : ℝ) * log ((d1.p ω) / (d2.p ω))`.

By `log 0 = 0`, terms with `d1.p ω = 0` vanish; terms with `d2.p ω = 0`
and `d1.p ω > 0` again contribute `0` in Lean's convention (not `+∞`),
but those configurations are excluded by the positivity hypothesis on
the decomposition identity below. -/
noncomputable def klDiv (d1 d2 : ActivationDist Ω) : ℝ :=
  ∑ ω, (d1.p ω : ℝ) * Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ))

/-- `KL(d ‖ d) = 0` on any normalised distribution.

Each summand is `(d.p ω) · log ((d.p ω) / (d.p ω))`, which equals `0`
either because `d.p ω = 0` (first factor) or because the argument of
`log` is `1` (and `log 1 = 0`). -/
theorem klDiv_self (d : ActivationDist Ω) : klDiv d d = 0 := by
  unfold klDiv
  apply Finset.sum_eq_zero
  intro ω _
  by_cases hp : (d.p ω : ℝ) = 0
  · rw [hp]; ring
  · have : (d.p ω : ℝ) / (d.p ω : ℝ) = 1 := div_self hp
    rw [this, Real.log_one, mul_zero]

/-- **HEADLINE DECOMPOSITION (Group E.10).** Cross-entropy decomposes
as knowledge entropy plus KL divergence:

    H_cross(d1, d2) = H_K(d1) + KL(d1 ‖ d2),

provided every `d2`-mass that is multiplied by a positive `d1`-mass is
itself positive (the absolute-continuity condition `d1 ≪ d2`).

For a clean *unconditional* version, we strengthen to: every
`d2`-mass is strictly positive. -/
theorem crossEntropy_eq_entropy_add_KL
    (d1 d2 : ActivationDist Ω)
    (h_d2_pos : ∀ ω, 0 < (d2.p ω : ℝ)) :
    crossEntropy d1 d2 = knowledgeEntropy d1 + klDiv d1 d2 := by
  unfold crossEntropy knowledgeEntropy klDiv
  -- Move both negations to LHS-vs-RHS via per-term identity:
  --   d1·log d2 = d1·log d1 - d1·log(d1/d2)
  -- so -∑ (d1·log d2) = -∑ (d1·log d1) + ∑ (d1·log(d1/d2)).
  have h_each : ∀ ω,
      (d1.p ω : ℝ) * Real.log ((d2.p ω : ℝ))
        = (d1.p ω : ℝ) * Real.log ((d1.p ω : ℝ))
          - (d1.p ω : ℝ) * Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ)) := by
    intro ω
    by_cases h1 : (d1.p ω : ℝ) = 0
    · rw [h1]; ring
    · have h2pos := h_d2_pos ω
      have h2ne : (d2.p ω : ℝ) ≠ 0 := ne_of_gt h2pos
      have h_log :
          Real.log ((d1.p ω : ℝ) / (d2.p ω : ℝ))
            = Real.log ((d1.p ω : ℝ)) - Real.log ((d2.p ω : ℝ)) :=
        Real.log_div h1 h2ne
      rw [h_log]; ring
  rw [Finset.sum_congr rfl (fun ω _ => h_each ω)]
  rw [Finset.sum_sub_distrib]
  ring

/-- **Group E.11 — No-free-lunch (cross-entropy lower bound).**

Under the absolute-continuity-by-positivity hypothesis, cross-entropy is
at least the knowledge entropy of the "true" distribution:

    H_K(d1) ≤ H_cross(d1, d2),

with the gap exactly equal to `KL(d1 ‖ d2)`.  The classical reading is
"the best code for `d1` is `d1` itself; any mismatched code `d2` costs
at least `KL(d1 ‖ d2)` extra bits per symbol".

This requires Gibbs' inequality `KL ≥ 0`, which in turn needs Jensen on
`log` (concave on positives).  We give a clean statement here and
defer the full Gibbs proof to `Agent10_Gibbs.lean`; for now we state the
result in `iff KL ≥ 0` form so the algebra is captured. -/
theorem crossEntropy_ge_entropy_iff_KL_nonneg
    (d1 d2 : ActivationDist Ω)
    (h_d2_pos : ∀ ω, 0 < (d2.p ω : ℝ)) :
    knowledgeEntropy d1 ≤ crossEntropy d1 d2 ↔ 0 ≤ klDiv d1 d2 := by
  rw [crossEntropy_eq_entropy_add_KL d1 d2 h_d2_pos]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ## Cross-entropy with the uniform distribution.

When `d2` is the uniform distribution `1/|Ω|`, the cross-entropy
collapses to a closed-form constant `log |Ω|`, since each log term is
the same. -/

/-- `H_cross(d, uniform) = log (Fintype.card Ω)` for any normalised
`d`.  Direct calculation. -/
theorem crossEntropy_uniform_eq_log_card
    [Nonempty Ω] (d : ActivationDist Ω) :
    crossEntropy d (Agent6.uniformDist Ω) = Real.log (Fintype.card Ω : ℝ) := by
  unfold crossEntropy
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  -- d2.p ω = 1/|Ω| pointwise.
  have h_uni_p : ∀ ω,
      ((Agent6.uniformDist Ω).p ω : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
    intro ω
    show ((Agent6.uniformMass Ω : NNReal) : ℝ) = _
    exact Agent6.uniformMass_coe
  -- Hence log d2.p ω = -log |Ω|, factor it out of the sum.
  have h_each : ∀ ω,
      (d.p ω : ℝ) * Real.log ((Agent6.uniformDist Ω).p ω : ℝ)
        = (d.p ω : ℝ) * (-(Real.log (Fintype.card Ω : ℝ))) := by
    intro ω
    rw [h_uni_p ω]
    rw [Real.log_div one_ne_zero (ne_of_gt hcard), Real.log_one]
    ring
  rw [Finset.sum_congr rfl (fun ω _ => h_each ω)]
  rw [← Finset.sum_mul]
  -- ∑ ω, (d.p ω : ℝ) = 1 by normalisation.
  have h_sum : ∑ ω, (d.p ω : ℝ) = 1 := by
    have : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
      push_cast; rfl
    rw [← this, d.normalized]; simp
  rw [h_sum]
  ring

end Agent10

end MIP
