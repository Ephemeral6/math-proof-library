/-
  STATUS: DISCOVERY
  AGENT: 10
  DIRECTION: Group B.3, B.4, I.14 — KL divergence of an activation
              distribution `d` to the uniform distribution on `Ω`,
              and the headline information-theoretic identity
                  H_K(d) + KL(d ‖ uniform_Ω) = log |Ω|.
  SUMMARY:
    Agent 3 stated KL-to-uniform at the **partition** level
    (`Agent3_KLToUniform.KL_to_uniform := log m - H_π`). We do the
    analogous construction at the **distribution** level:

        KL(d ‖ uniform_Ω) := log |Ω|  -  knowledgeEntropy d        (def)

    and obtain four named consequences:

      • `H_K_plus_KL_to_uniform_eq_log_card`  — Group I.14, headline.
          `knowledgeEntropy d + KL_to_uniform d = log (Fintype.card Ω)`.
          A clean rearrangement-form identity.
      • `KL_to_uniform_dist_nonneg`           — Group B.3 (Gibbs).
          `0 ≤ KL_to_uniform d`.
      • `KL_to_uniform_dist_eq_zero_iff`      — Group B.4.
          `KL_to_uniform d = 0 ↔ d is the uniform distribution`.
      • `KL_to_uniform_dist_le_log_card`      — bracket upper bound.
          `KL_to_uniform d ≤ log (Fintype.card Ω)`, saturated at point
          mass (`knowledgeEntropy d = 0`).

    The standard KL form `∑ p log (p / (1/m)) = ∑ p log p + log m` is
    what justifies the algebraic definition: since `∑ p ω = 1`, the
    constant `+ log m` term separates out.

    All four results follow from Agent 6's `H_K_nonneg`,
    `H_K_le_log_card`, and `H_K_eq_log_card_iff_uniform` by pure linear
    arithmetic.  No new Mathlib lemma is required.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard
import MIP.Discoveries.Agent6_HK_Uniform_Saturation

namespace MIP

namespace Agent10

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **KL divergence of an activation distribution to the uniform
distribution on `Ω`.**

`KL_to_uniform_dist d := log |Ω| - knowledgeEntropy d`.

This is the standard Gibbs form `∑ p log (p / (1/m))` rewritten using
`∑ p = 1` (normalisation):

  ∑ p ω · log (p ω / (1/m))
    = ∑ p ω · log (p ω)  +  log m · ∑ p ω
    = -H_K(d)            +  log m.

The companion partition-level definition is in
`Agent3_KLToUniform.KL_to_uniform`. -/
noncomputable def KL_to_uniform_dist (d : ActivationDist Ω) : ℝ :=
  Real.log (Fintype.card Ω : ℝ) - knowledgeEntropy d

/-- **HEADLINE (Group I.14).** Knowledge entropy plus the KL divergence
to the uniform distribution equals `log (Fintype.card Ω)`.

This is the rearrangement of the definition; phrased as an
information-theoretic identity it certifies the meaning of `H_K` as a
"residual uncertainty after specialisation", with `KL(d ‖ uniform)`
playing the role of the "specialisation gap". -/
theorem H_K_plus_KL_to_uniform_eq_log_card (d : ActivationDist Ω) :
    knowledgeEntropy d + KL_to_uniform_dist d
      = Real.log (Fintype.card Ω : ℝ) := by
  unfold KL_to_uniform_dist
  ring

/-- **Group B.3 (Gibbs at the distribution level).**

`0 ≤ KL_to_uniform_dist d`.  Immediate from `H_K_le_log_card`. -/
theorem KL_to_uniform_dist_nonneg
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    0 ≤ KL_to_uniform_dist d := by
  unfold KL_to_uniform_dist
  linarith [Agent6.H_K_le_log_card d]

/-- **Bracket upper bound.**

`KL_to_uniform_dist d ≤ log (Fintype.card Ω)`, since `H_K ≥ 0`. The
upper bound is saturated exactly when `H_K = 0`, i.e. at point-mass
distributions (cf. `Agent6.H_K_eq_zero_iff_point_mass`). -/
theorem KL_to_uniform_dist_le_log_card (d : ActivationDist Ω) :
    KL_to_uniform_dist d ≤ Real.log (Fintype.card Ω : ℝ) := by
  unfold KL_to_uniform_dist
  linarith [Agent6.H_K_nonneg d]

/-- **Group B.4 — KL-to-uniform vanishes iff `d` is uniform.**

The KL divergence from `d` to the uniform distribution on `Ω` equals
zero iff every mass of `d` equals `1 / |Ω|`. This is the
distribution-level Gibbs equality case, lifted from
`Agent6.H_K_eq_log_card_iff_uniform`. -/
theorem KL_to_uniform_dist_eq_zero_iff
    [Nonempty Ω] [DecidableEq Ω] (d : ActivationDist Ω) :
    KL_to_uniform_dist d = 0 ↔
      ∀ ω, (d.p ω : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
  unfold KL_to_uniform_dist
  constructor
  · intro hzero
    have h_HK : knowledgeEntropy d = Real.log (Fintype.card Ω : ℝ) := by
      linarith
    exact (Agent6.H_K_eq_log_card_iff_uniform d).mp h_HK
  · intro h_uni
    have h_HK : knowledgeEntropy d = Real.log (Fintype.card Ω : ℝ) :=
      (Agent6.H_K_eq_log_card_iff_uniform d).mpr h_uni
    linarith

/-- **Saturation at point mass.** When `knowledgeEntropy d = 0`
(point-mass / pure-expert distribution), the KL-to-uniform attains its
maximum value `log (Fintype.card Ω)`. -/
theorem KL_to_uniform_dist_max_at_point_mass
    (d : ActivationDist Ω) (h_pm : knowledgeEntropy d = 0) :
    KL_to_uniform_dist d = Real.log (Fintype.card Ω : ℝ) := by
  unfold KL_to_uniform_dist
  rw [h_pm]; ring

/-- **Sanity: KL of uniform to uniform = 0.**

When `H_K = log |Ω|` (uniform distribution), the KL divergence to
uniform is zero — the natural sanity check. -/
theorem KL_to_uniform_dist_zero_at_uniform
    (d : ActivationDist Ω) (h_uni : knowledgeEntropy d = Real.log (Fintype.card Ω : ℝ)) :
    KL_to_uniform_dist d = 0 := by
  unfold KL_to_uniform_dist
  rw [h_uni]; ring

end Agent10

end MIP
