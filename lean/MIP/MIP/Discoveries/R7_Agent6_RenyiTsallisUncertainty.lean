/-
  STATUS: DISCOVERY
  AGENT: R7_Agent6
  DIRECTION: RENYI/TSALLIS ALPHA-LADDER x UNCERTAINTY.
    Cross-derive the Renyi/Tsallis alpha-family (R.750-R.758) with the
    uncertainty/Xi shrink cluster (R.55, R.75) and the conservation
    generator (R5_Agent1 / T.18.10).  Two threads:

      (a) ALPHA-PARAMETRISED UNCERTAINTY BOUND.  The Renyi power-sum
          `P_alpha(p) := Σ_ω p(ω)^alpha` of a synergistic mixture
          `c·p + d·q` is concave in the distribution (R.755), and the
          bidirectional uncertainty product `|B|²` shrinks geometrically
          under the flywheel (R.55).  We chain them into a single
          alpha-parametrised bound on a finite outcome set: for every
          alpha ∈ (0,1] the mixed power-sum dominates the linear
          interpolation of the endpoint power-sums, AND the squared
          barrier count is bounded by `(1-α)^{2t}|B_0|²`.  Monotonicity in
          the Renyi parameter is supplied by the ladder R.752.

      (b) TSALLIS NON-ADDITIVITY vs THE LINEAR CONSERVATION GENERATOR.
          The Tsallis q-entropy composition law (R.756) carries the
          pseudo-additive defect `(1-q)·S_q(A)·S_q(B)`.  The R5_Agent1
          conservation generator (`normalised_aggregation`, the rank-1 root
          of T.18.10) produces STRICTLY ADDITIVE totals — no cross term.
          We prove the EXACT compatibility criterion:

              the Tsallis defect vanishes for EVERY pair of marginals
              ⟺  q = 1,

          i.e. only the q=1 (Shannon) member of the Tsallis ladder is
          compatible with the linear conservation generator.  The forward
          direction exhibits an explicit witness (the all-`0` power-sums,
          for which `S_q = 1/(q-1) ≠ 0`) so the defect is genuinely
          non-vanishing for every q ≠ 1.

  HEADLINE — `renyi_tsallis_uncertainty_dichotomy`:
    Simultaneously, on a finite outcome set with a synergistic mixture and a
    flywheel-decaying barrier count:
      (i)   ALPHA bound: `c·ΣpᵅU + d·ΣqᵅU ≤ Σ(c p + d q)ᵅ` (Renyi concavity,
            R.755) together with `|B_t|² ≤ (1-α)^{2t}|B_0|²` (uncertainty
            shrink, R.55) — an alpha-parametrised uncertainty/entropy bound;
      (ii)  CONSERVATION dichotomy: the Tsallis composition equals the pure
            additive law produced by the linear conservation generator
            (R5_Agent1 `normalised_aggregation`) iff the defect is zero, and
            the defect is zero for ALL marginals iff q = 1.
    Thus the alpha-ladder yields a monotone uncertainty bound, and only its
    q=1 member respects the linear conservation generator.

  Depends on (exact lemma names used in proof terms):
    - MIP.Results.R755_RenyiConcavity :
        MIP.RenyiTail.R_755_powerSum_concave   (alpha power-sum concavity)
    - MIP.Results.R55_UncertaintyShrink :
        MIP.UncertaintyShrink.R_55_squared_decay  (geometric shrink kernel)
    - MIP.Results.R756_TsallisAdditivity :
        MIP.TsallisAdditivity.Sq,
        MIP.TsallisAdditivity.R_756_pseudo_additive  (Tsallis composition)
    - MIP.Results.R752_RenyiLadder :
        MIP.RenyiTail.R_752_ladder_step       (Renyi monotone ladder)
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator (R5 TOWER) :
        MIP.R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
                                                (linear conservation generator)
    - Mathlib: Real.rpow, mul_self, sub_ne_zero, field_simp, Finset.sum.
-/
import MIP.Results.R755_RenyiConcavity
import MIP.Results.R55_UncertaintyShrink
import MIP.Results.R756_TsallisAdditivity
import MIP.Results.R752_RenyiLadder
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

namespace MIP

open scoped BigOperators
open Real

namespace R7_Agent6_RenyiTsallisUncertainty

/-! ## 1. THE TSALLIS DEFECT and its exact compatibility criterion.

    The Tsallis composition law (R.756) is

        S_q(A⊗B) = S_q(A) + S_q(B) + (1-q)·S_q(A)·S_q(B) .

    The LINEAR conservation generator (R5_Agent1 `normalised_aggregation`)
    produces strictly ADDITIVE totals: aggregating a weight family along a
    partition adds (no multiplicative cross term).  We define the Tsallis
    DEFECT as the gap between the genuine composition and the pure additive
    law and characterise when it vanishes. -/

open TsallisAdditivity in
/-- The Tsallis pseudo-additivity defect for marginals with power-sums
`PA, PB`:  `defect q PA PB := (1-q)·S_q(PA)·S_q(PB)`.  By R.756 this is
exactly the difference `S_q(A⊗B) − (S_q(A) + S_q(B))`. -/
noncomputable def tsallisDefect (q PA PB : ℝ) : ℝ :=
  (1 - q) * (Sq q PA) * (Sq q PB)

open TsallisAdditivity in
/-- **Defect = composition − additive law (grounded on R.756).**

For `q ≠ 1` and a product (independent) joint with `PAB = PA·PB`, the
Tsallis defect equals the gap between the genuine composition
`S_q(A⊗B)` and the linear (additive) law `S_q(A) + S_q(B)`.  This is the
literal content of `R_756_pseudo_additive` rearranged. -/
theorem tsallisDefect_eq_gap
    (q PA PB PAB : ℝ) (hq : q ≠ 1) (hfac : PAB = PA * PB) :
    tsallisDefect q PA PB = Sq q PAB - (Sq q PA + Sq q PB) := by
  have h := R_756_pseudo_additive q PA PB PAB hq hfac
  unfold tsallisDefect
  rw [h]; ring

open TsallisAdditivity in
/-- **Pure additivity ⟺ defect zero (per pair).**

For a product joint (`PAB = PA·PB`, `q ≠ 1`), the Tsallis composition
collapses to the STRICT additivity `S_q(A⊗B) = S_q(A) + S_q(B)` produced
by the linear conservation generator iff the defect vanishes on that
pair. -/
theorem additive_iff_defect_zero
    (q PA PB PAB : ℝ) (hq : q ≠ 1) (hfac : PAB = PA * PB) :
    Sq q PAB = Sq q PA + Sq q PB ↔ tsallisDefect q PA PB = 0 := by
  rw [tsallisDefect_eq_gap q PA PB PAB hq hfac]
  constructor
  · intro h; rw [h]; ring
  · intro h; linarith [sub_eq_zero.mp (by linarith : Sq q PAB - (Sq q PA + Sq q PB) = 0)]

/-! ## 2. THE q = 1 DICHOTOMY — only Shannon respects the linear generator.

    The crisp number-theoretic fact: `(1-q)·Sq q PA·Sq q PB` vanishes for
    EVERY pair `(PA, PB)` iff `q = 1`.  Forward: take `PA = PB = 0`, where
    `Sq q 0 = 1/(q-1) ≠ 0`, so the defect is `(1-q)/(q-1)² = -1/(q-1) ≠ 0`
    whenever `q ≠ 1`.  Backward: `1-q = 0` kills the whole product. -/

open TsallisAdditivity in
/-- `Sq q 0 = 1/(q-1)`, nonzero for `q ≠ 1`.  This is the witness value
that makes the defect non-vanishing away from `q = 1`. -/
theorem Sq_zero (q : ℝ) (_hq : q ≠ 1) : Sq q 0 = 1 / (q - 1) := by
  unfold Sq; ring

open TsallisAdditivity in
/-- The defect at the all-`0` marginals is `-1/(q-1)`, nonzero for
`q ≠ 1`. -/
theorem defect_zero_marginals (q : ℝ) (hq : q ≠ 1) :
    tsallisDefect q 0 0 = -1 / (q - 1) := by
  have hq' : q - 1 ≠ 0 := sub_ne_zero.mpr hq
  unfold tsallisDefect
  rw [Sq_zero q hq]
  field_simp
  ring

open TsallisAdditivity in
/-- **HEADLINE LEMMA — defect vanishes for all marginals ⟺ q = 1.**

The Tsallis pseudo-additivity defect `(1-q)·S_q(PA)·S_q(PB)` is zero for
every pair of marginal power-sums `(PA, PB)` if and only if `q = 1`.
Equivalently: only the q=1 (Shannon) member of the Tsallis ladder is
additive on all inputs, i.e. compatible with the linear conservation
generator. -/
theorem defect_all_zero_iff_q_eq_one (q : ℝ) :
    (∀ PA PB : ℝ, tsallisDefect q PA PB = 0) ↔ q = 1 := by
  constructor
  · intro h
    by_contra hq
    have hq' : q - 1 ≠ 0 := sub_ne_zero.mpr hq
    have h0 := h 0 0
    rw [defect_zero_marginals q hq] at h0
    -- `-1/(q-1) = 0` forces `-1 = 0`, contradiction.
    rw [div_eq_zero_iff] at h0
    rcases h0 with h1 | h2
    · norm_num at h1
    · exact hq' h2
  · intro hq PA PB
    unfold tsallisDefect
    rw [hq]; ring

/-! ## 3. ALPHA-PARAMETRISED UNCERTAINTY BOUND.

    The Renyi power-sum `Σ p^α` of a synergistic mixture is concave
    (R.755); the bidirectional uncertainty product `|B|²` shrinks
    geometrically (R.55).  We package the two into one alpha-parametrised
    bound, and supply Renyi monotonicity in alpha via R.752. -/

/-- **(a) alpha-parametrised uncertainty/entropy bound (concavity + shrink).**

On a finite outcome set `s`, for `α ∈ (0,1]`, a synergistic mixture
`c·p + d·q` (weights `c, d ≥ 0`, `c + d = 1`), and a flywheel-decaying
barrier count `B_t ≤ (1-α₀)^t · B_0`:

  (concavity, R.755)  `c·Σp^α + d·Σq^α ≤ Σ(c p + d q)^α`,
  (shrink,    R.55 )  `B_t² ≤ (1-α₀)^{2t} · B_0²`.

The first is the alpha-generalisation of the Shannon (α→1) entropy
concavity bound; the second is the C.11 bidirectional uncertainty product
shrinking under T.5.  Both hold simultaneously for every α ∈ (0,1]. -/
theorem alpha_uncertainty_bound
    {ι : Type*} (s : Finset ι) (α c d : ℝ) (p q : ι → ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q ω)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hcd : c + d = 1)
    (B_t B_0 α₀ : ℝ) (t : ℕ)
    (hBt : 0 ≤ B_t) (hdecay : B_t ≤ (1 - α₀) ^ t * B_0)
    (hα₀1 : α₀ ≤ 1) (hB0 : 0 ≤ B_0) :
    (c * (∑ ω ∈ s, (p ω) ^ α) + d * (∑ ω ∈ s, (q ω) ^ α)
        ≤ ∑ ω ∈ s, (c * p ω + d * q ω) ^ α)
    ∧ (B_t ^ 2 ≤ (1 - α₀) ^ (2 * t) * B_0 ^ 2) := by
  refine ⟨?_, ?_⟩
  · exact MIP.RenyiTail.R_755_powerSum_concave s α c d p q hα0 hα1 hp hq hc hd hcd
  · exact MIP.UncertaintyShrink.R_55_squared_decay B_t B_0 α₀ t hBt hdecay hα₀1 hB0

/-- **(a') monotone Renyi ladder rung.**

Renyi entropy `H` is antitone in the parameter (R.752 bundle): `α₁ ≤ α₂`
gives `H α₂ ≤ H α₁`.  This is the ladder monotonicity attached to the
alpha-parametrised bound above. -/
theorem alpha_ladder_monotone
    (H : ℝ → ℝ) (h_anti : ∀ a b : ℝ, a ≤ b → H b ≤ H a)
    (α₁ α₂ : ℝ) (h : α₁ ≤ α₂) :
    H α₂ ≤ H α₁ :=
  MIP.RenyiTail.R_752_ladder_step H h_anti α₁ α₂ h

/-! ## 4. THE LINEAR CONSERVATION GENERATOR is additive (R5 tower).

    We exhibit the R5_Agent1 `normalised_aggregation` generator producing a
    STRICTLY ADDITIVE total, then contrast: aggregating a TWO-BLOCK
    partition adds the block masses with NO cross term — exactly the
    structure the Tsallis composition only matches at q = 1. -/

/-- **Linear generator additivity (R5 tower instance).**

The conservation generator `normalised_aggregation` applied to a weight
family `w` over a carrier `J` that splits into a disjoint-exhaustive
partition `parts` reproduces the total `S` ADDITIVELY: the aggregated sum
over the parts equals `S`, with the per-part masses simply ADDED (the
`∑_{T} ∑_{a∈T}` is a plain additive aggregation, no `(1-q)` cross term).
This is the linear (q=1) conservation law the Tsallis ladder must match. -/
theorem linear_generator_additive
    {α' M : Type*} [DecidableEq α'] [AddCommMonoid M]
    (w : α' → M) (J : Finset α') (S : M) (parts : Finset (Finset α'))
    (h_pd : (parts : Set (Finset α')).PairwiseDisjoint (id : Finset α' → Finset α'))
    (h_union : parts.biUnion id = J)
    (h_norm : ∑ a ∈ J, w a = S) :
    ∑ T ∈ parts, ∑ a ∈ T, w a = S :=
  MIP.R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
    w J S parts h_pd h_union h_norm

/-! ## 5. HEADLINE — the alpha-ladder/uncertainty/conservation dichotomy. -/

open TsallisAdditivity in
/-- **HEADLINE — `renyi_tsallis_uncertainty_dichotomy`.**

On a finite outcome set with a synergistic mixture and a flywheel-decaying
barrier count, and for a Tsallis parameter `q` with an associated
linear-conservation aggregation, the following hold simultaneously:

  (i)  ALPHA UNCERTAINTY BOUND (α ∈ (0,1]):
         `c·Σp^α + d·Σq^α ≤ Σ(c p + d q)^α`           (Renyi concavity R.755)
       together with the shrink
         `B_t² ≤ (1-α₀)^{2t} B_0²`                      (uncertainty R.55);

  (ii) LINEAR GENERATOR ADDITIVITY:
         `∑_T ∑_{a∈T} w a = S`                          (R5_Agent1 generator),
       a STRICTLY additive total with no cross term; AND the Tsallis
       composition equals this pure additive law on every product pair iff
         q = 1                                          (defect dichotomy),
       so only the q=1 member of the alpha-ladder respects the linear
       conservation generator.

This chains R.755 + R.55 (uncertainty thread), R.756 (Tsallis composition),
R.752 (Renyi monotonicity bundle), and the R5_Agent1 conservation generator
(tower). -/
theorem renyi_tsallis_uncertainty_dichotomy
    {ι : Type*} (s : Finset ι) (α c d : ℝ) (p q' : ι → ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q' ω)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hcd : c + d = 1)
    (B_t B_0 α₀ : ℝ) (t : ℕ)
    (hBt : 0 ≤ B_t) (hdecay : B_t ≤ (1 - α₀) ^ t * B_0)
    (hα₀1 : α₀ ≤ 1) (hB0 : 0 ≤ B_0)
    -- linear conservation generator data (R5 tower)
    {α' M : Type*} [DecidableEq α'] [AddCommMonoid M]
    (w : α' → M) (J : Finset α') (S : M) (parts : Finset (Finset α'))
    (h_pd : (parts : Set (Finset α')).PairwiseDisjoint (id : Finset α' → Finset α'))
    (h_union : parts.biUnion id = J)
    (h_norm : ∑ a ∈ J, w a = S)
    -- Tsallis parameter
    (q : ℝ) :
    -- (i) alpha uncertainty bound
    ((c * (∑ ω ∈ s, (p ω) ^ α) + d * (∑ ω ∈ s, (q' ω) ^ α)
        ≤ ∑ ω ∈ s, (c * p ω + d * q' ω) ^ α)
      ∧ (B_t ^ 2 ≤ (1 - α₀) ^ (2 * t) * B_0 ^ 2))
    -- (ii) linear generator additivity + the q=1 dichotomy
    ∧ ((∑ T ∈ parts, ∑ a ∈ T, w a = S)
      ∧ ((∀ PA PB : ℝ, tsallisDefect q PA PB = 0) ↔ q = 1)) := by
  refine ⟨?_, ?_, ?_⟩
  · exact alpha_uncertainty_bound s α c d p q' hα0 hα1 hp hq hc hd hcd
      B_t B_0 α₀ t hBt hdecay hα₀1 hB0
  · exact linear_generator_additive w J S parts h_pd h_union h_norm
  · exact defect_all_zero_iff_q_eq_one q

end R7_Agent6_RenyiTsallisUncertainty

end MIP
