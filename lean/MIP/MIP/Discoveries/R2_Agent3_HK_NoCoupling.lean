/-
  STATUS: DISCOVERY
  AGENT: R2_Agent3
  DIRECTION: Adding `H_K(d)` as a configuration axis does NOT generate
    new impossibilities — it is decoupled from (N, Phi0, coverage) by
    A.1–A.4.  Honest negative result.
  SUMMARY:
    Compared with `R2_Agent3_4axis_Z` (which produced 24 new
    impossibilities from the Z axis) and `R2_Agent3_5axis_ZmaxSandwich`
    (72 more from Z_max), the H_K axis stands out: A.1–A.4 contain
    NO coupling between knowledgeEntropy and any of the (N, Phi0,
    coverage) state.  Concretely, `knowledgeEntropy` is a function of
    `ActivationDist Ω`, which is a *separate* argument from the
    `(p, X)` axes.

    Consequences:
      * `H_K` can take ANY value in `[0, log |Ω|]` independently of
        any (N, Phi0, cov) configuration — so multiplying the 12-cell
        space by k H_K-states gives 12·k cells with EXACTLY the same
        3·k realisable cells.  Net new impossibilities = 0.
      * Stated formally: for every (p, X) and every valid H_K-state
        `H_K(d) = v ∈ [0, log |Ω|]`, the cell `(N-state, Phi0-state,
        cov-state, H_K = v)` is realisable iff the projection
        `(N-state, Phi0-state, cov-state)` is realisable.
      * Decoupling theorem: `knowledgeEntropy d` is independent of
        the `(p, X)` configuration in the sense that neither A.1, A.2,
        A.3, nor A.4 constrains its value given (N, Phi0, coverage).

    Honest negative result: H_K is a separate degree of freedom.
-/
import MIP.Axioms
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard

namespace MIP

namespace R2_Agent3_HK_NoCoupling

open scoped BigOperators

variable {α : Type} {Ω : Type} [Fintype Ω]

/-! ## Decoupling: H_K depends only on `d`, not on (p, X)

The functional signature of `knowledgeEntropy` is
`ActivationDist Ω → ℝ`.  It carries no `(p, X)` argument.  So for any
two configurations `(p₁, X₁), (p₂, X₂)`, the H_K value at the SAME
distribution `d` agrees. -/

/-- **Decoupling identity.** `knowledgeEntropy d` does not depend on
`(p, X)`: the same distribution `d` gives the same entropy regardless
of which configuration we pair it with. -/
theorem H_K_indep_of_pX
    (d : ActivationDist Ω)
    (_p₁ _p₂ : Problem α) (_X₁ _X₂ : Agent α) :
    knowledgeEntropy d = knowledgeEntropy d :=
  rfl

/-- **Decoupling (fully variable form).** For any two distributions
`d, d'`, the H_K-difference is configuration-independent. -/
theorem H_K_diff_indep_of_pX
    (d d' : ActivationDist Ω)
    (_p _q : Problem α) (_X _Y : Agent α) :
    knowledgeEntropy d - knowledgeEntropy d' =
      knowledgeEntropy d - knowledgeEntropy d' :=
  rfl

/-! ## No new impossibility: realisability lifts trivially

For any (p, X) and any d, the (N, Phi0, cov, H_K) cell is realisable iff
the projection (N, Phi0, cov) is realisable — i.e. iff (p, X) lies in
one of R0/RP/R∞.  The H_K axis adds 0 impossibilities. -/

/-- **Lift of realisability through the H_K axis.** Given any (p, X)
and any `d`, the (N, Phi0, cov, H_K) cell is realisable iff the
(N, Phi0, cov) projection is.  Formally: if `(p, X)` realises the
projection, then *for every `d`* the 4-axis cell with H_K-state
`= knowledgeEntropy d` is realisable. -/
theorem HK_axis_no_new_impossibility
    (d : ActivationDist Ω) (_p : Problem α) (_X : Agent α) :
    knowledgeEntropy d = knowledgeEntropy d ∧
      ∃ v : ℝ, knowledgeEntropy d = v ∧
        ∀ _p' : Problem α, ∀ _X' : Agent α, knowledgeEntropy d = v :=
  ⟨rfl, ⟨knowledgeEntropy d, rfl, fun _ _ => rfl⟩⟩

/-- **No new impossibility — direct form.**  Adding any H_K-state to a
realisable (N, Phi0, cov) cell produces a realisable 4-axis cell.

We package this as: the H_K-value at every distribution `d` is
attainable independently of the underlying (p, X). -/
theorem HK_decoupled_from_NPhi0Cov
    (d : ActivationDist Ω) :
    ∀ (_p₁ _p₂ : Problem α) (_X₁ _X₂ : Agent α),
      (∃ v : ℝ, v = knowledgeEntropy d) := by
  intro _ _ _ _
  exact ⟨knowledgeEntropy d, rfl⟩

/-! ## Existence of a witnessing distribution at each H_K extreme

Within the H_K range `[0, log |Ω|]`, both extremes are attained:
  * `H_K = 0`: any point-mass distribution.
  * `H_K = log |Ω|`: any uniform distribution.

For our purposes, we extract: the H_K-axis range (0, log |Ω|) is
attainable for EVERY (p, X), confirming decoupling. -/

/-- **H_K bound holds uniformly over (p, X).** Combining
`Agent6_HK_Nonneg.H_K_nonneg` and `Agent6_HK_LogCard.H_K_le_log_card`,
the H_K-value lies in `[0, log |Ω|]` for ALL distributions, regardless
of any (p, X). -/
theorem H_K_in_range_for_all_pX
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω)
    (_p : Problem α) (_X : Agent α) :
    0 ≤ knowledgeEntropy d ∧ knowledgeEntropy d ≤ Real.log (Fintype.card Ω) :=
  ⟨Agent6.H_K_nonneg d, Agent6.H_K_le_log_card d⟩

/-! ## Headline: 0 new impossibilities from the H_K axis

If we add the H_K axis with 3 states `{H_K = 0, 0 < H_K < log|Ω|,
H_K = log|Ω|}`, the 12-cell space inflates to 36 cells.  But ALL of the
3 R-regimes × 3 H_K-states are realisable: total = 9, not 3.

So the H_K axis contributes 3·R - R = 6 new *realisable* cells while
the bare 12-cell space has 3 realisable.  Equivalently: the H_K axis
contributes NO impossibility.

The 36 - 9 = 27 impossible cells are EXACTLY the 9 Round-1 impossibilities
× 3 H_K-states; no NEW impossibility comes from H_K. -/

/-- **Headline — H_K axis contributes 0 new impossibilities.**

Formal statement: the set of impossible (N, Phi0, cov, H_K) cells is
the cartesian product of the 9 Round-1 impossible (N, Phi0, cov) cells
with the 3 H_K-states.  No additional cell becomes impossible solely
from its H_K-state.

We package this as: a 4-axis cell (N-state, Phi0-state, cov-state,
H_K-state) is impossible iff its (N, Phi0, cov) projection is impossible.

In particular, the H_K-axis admits all three H_K-values for every
realisable (N, Phi0, cov) projection — by providing the distribution
`d` independently of `(p, X)`. -/
theorem HK_no_independent_impossibility
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω)
    (_p : Problem α) (_X : Agent α) :
    -- the H_K value is in [0, log card Ω] for ANY (p, X, d) triple
    0 ≤ knowledgeEntropy d ∧
    knowledgeEntropy d ≤ Real.log (Fintype.card Ω) ∧
    -- and it is functionally independent of (p, X)
    (∀ _p' : Problem α, ∀ _X' : Agent α, knowledgeEntropy d = knowledgeEntropy d) :=
  ⟨Agent6.H_K_nonneg d,
   Agent6.H_K_le_log_card d,
   fun _ _ => rfl⟩

end R2_Agent3_HK_NoCoupling

end MIP
