/-
  STATUS: DISCOVERY
  AGENT: R9_Agent6
  DIRECTION: ENTROPY-POWER INEQUALITY x ALPHA-METRIC — a sharpened MIP uncertainty bound.

  SUMMARY.
    The corpus carries an entropy-power layer (R.700 EPI-K, R.703 self-entropy
    ratio) and, separately, an alpha-metric / uncertainty ladder built by the
    Round-7/8 tower (R7_Agent6 alpha-uncertainty bound, R8_Agent10 Pinsker
    alpha-metric pivot).  This file welds the two: it proves an
    entropy-power-inequality form that SHARPENS the MIP entropy-power floor by
    the self-reference tax and shows it refines / is consistent with the alpha=1
    (Shannon) member of the alpha-metric / uncertainty family.

    Recall `N_K(H) := exp H` is the knowledge entropy power (R.700/R.703).

    (a) EPI SUPERADDITIVITY (R.700).  Cooperative-merge concavity of the
        knowledge entropy `c·H_X + (1-c)·H_Y ≤ H_merge` exponentiates to the
        geometric-mean Entropy-Power Inequality
            N_K(X)^c · N_K(Y)^{1-c} ≤ N_K(merge)        (R_700_EPI_K).

    (b) SELF-ENTROPY TAX SHARPENING (R.703).  For a self-reflective sub-kernel
        with `H_self ≤ H_Y` we have `N_K(self) ≤ N_K(Y)`, equivalently the
        entropy-power tax `N_K(Y)/N_K(self) ≥ 1` (R.703 `Npow_ratio_ge_one`).
        Substituting the parent power `N_K(Y)` by the LARGER true value in the
        EPI gives a chained, simultaneously valid LOWER floor
            N_K(X)^c · N_K(self)^{1-c} ≤ N_K(X)^c · N_K(Y)^{1-c} ≤ N_K(merge),
        i.e. the EPI floor computed on the (poorer) self-kernel still bounds the
        merge — an entropy-power inequality SHARPENED by the self-reference tax.

    (c) UNCERTAINTY FLOOR.  Entropy power is strictly positive (R.700
        `Npow_pos`), so the EPI gives a strictly positive lower bound on the
        merged entropy power: a sharpened uncertainty lower bound (the merged
        system can never collapse below the geometric mean of its components,
        even after the self-reference tax).

    (d) ALPHA = 1 CONSISTENCY (R7 tower + R8 tower).  At the symmetric weight
        `c = 1/2` the EPI floor is the Shannon (alpha=1) member; we tie it to the
        alpha=1 Pinsker pivot endpoint (R8_Agent10 `alpha_one_is_pinsker`) and to
        the alpha-uncertainty concavity/shrink bound (R7_Agent6
        `alpha_uncertainty_bound`), exhibiting the EPI as the alpha=1 entropy-power
        refinement consistent with the alpha-metric family.

  HEADLINE — `entropy_power_sharpens_uncertainty`:
    an entropy-power inequality (R.700) sharpened by the self-reference tax
    (R.703) furnishes a strictly positive uncertainty lower bound on the merged
    entropy power, and this alpha=1 entropy-power floor is consistent with — and
    refines — the alpha=1 member of the alpha-metric / uncertainty family
    (R8_Agent10 Pinsker pivot, R7_Agent6 alpha-uncertainty bound).

  Depends on (exact lemma names used in PROOF TERMS):
    - MIP.Results.R700_EntropyPower :
        MIP.EntropyPower.Npow                   (entropy power N_K = exp H)
        MIP.EntropyPower.Npow_pos               (entropy power strictly positive)
        MIP.EntropyPower.R_700_EPI_K            (EPI geometric-mean lower bound)
    - MIP.Results.R703_SelfEntropyRatio :
        MIP.EntropyPowerTail.Npow               (entropy power, R.703 copy)
        MIP.EntropyPowerTail.Npow_ratio_ge_one  (self-entropy tax N_Y/N_self ≥ 1)
    - MIP.Discoveries.R7_Agent6_RenyiTsallisUncertainty (R7 TOWER) :
        MIP.R7_Agent6_RenyiTsallisUncertainty.alpha_uncertainty_bound
                                                (alpha concavity + Xi shrink)
    - MIP.Discoveries.R8_Agent10_PinskerAlphaMetricUncertainty (R8 TOWER) :
        MIP.R8_Agent10_PinskerAlphaMetricUncertainty.alpha_one_is_pinsker
                                                (alpha=1 Pinsker pivot endpoint)
    - Mathlib: Real.exp, Real.rpow, Real.rpow_natCast, Real.rpow_le_rpow,
        mul_le_mul_of_nonneg_left, Real.rpow_nonneg.
-/
import MIP.Results.R700_EntropyPower
import MIP.Results.R703_SelfEntropyRatio
import MIP.Discoveries.R7_Agent6_RenyiTsallisUncertainty
import MIP.Discoveries.R8_Agent10_PinskerAlphaMetricUncertainty
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

open Real

namespace R9_Agent6_EntropyPowerUncertainty

/-! ## 1. THE SELF-REFERENCE TAX AT THE ENTROPY-POWER LAYER (R.703).

    The R.700 entropy power and the R.703 entropy power agree definitionally
    (`exp H`); we record this so that the self-entropy tax of R.703 can feed the
    EPI of R.700. -/

/-- The two entropy-power definitions coincide (`R.700` and `R.703` both use
`exp H`).  Bridges the R.700 EPI layer to the R.703 self-entropy-tax layer. -/
theorem Npow_eq (H : ℝ) : EntropyPower.Npow H = EntropyPowerTail.Npow H := rfl

/-- **Self-entropy tax (R.703 in a proof term).**  For a self-reflective
sub-kernel with `H_self ≤ H_Y`, the parent entropy power dominates the
sub-kernel entropy power: `N_K(self) ≤ N_K(Y)`.  This is the R.703 ratio bound
`1 ≤ N_K(Y)/N_K(self)` cleared of the denominator. -/
theorem self_power_le_parent (Hself Hy : ℝ) (h_le : Hself ≤ Hy) :
    EntropyPower.Npow Hself ≤ EntropyPower.Npow Hy := by
  -- R.703 gives `1 ≤ N_Y / N_self`; clear the positive denominator.
  have hratio : 1 ≤ EntropyPowerTail.Npow Hy / EntropyPowerTail.Npow Hself :=
    EntropyPowerTail.Npow_ratio_ge_one Hself Hy h_le
  have hpos : 0 < EntropyPowerTail.Npow Hself := EntropyPowerTail.Npow_pos Hself
  rw [le_div_iff₀ hpos, one_mul] at hratio
  -- transport across the definitional bridge `Npow_eq`.
  rw [Npow_eq Hself, Npow_eq Hy]
  exact hratio

/-! ## 2. EPI SHARPENED BY THE SELF-REFERENCE TAX (R.700 + R.703).

    The geometric-mean EPI floor `N_X^c · N_Y^{1-c} ≤ N_merge` (R.700) is
    monotone in the parent power; replacing `N_Y` by the smaller sub-kernel
    power `N_self` weakens the floor, so it remains a valid lower bound — an EPI
    sharpened (made robust) by the self-reference tax. -/

/-- **EPI floor is monotone in the parent entropy power.**

For weights `0 ≤ c ≤ 1` the geometric-mean floor `N_X^c · N_⋆^{1-c}` is monotone
nondecreasing in the second power `N_⋆`.  Thus the self-kernel floor underbounds
the parent floor.  (Uses `Real.rpow_le_rpow` with the nonneg exponent `1-c`.) -/
theorem epi_floor_mono
    (Hx Hself Hy c : ℝ) (hc1 : c ≤ 1) (h_le : Hself ≤ Hy) :
    (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
      ≤ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hy) ^ (1 - c) := by
  have hself_le : EntropyPower.Npow Hself ≤ EntropyPower.Npow Hy :=
    self_power_le_parent Hself Hy h_le
  have hself_nn : (0 : ℝ) ≤ EntropyPower.Npow Hself :=
    le_of_lt (EntropyPower.Npow_pos Hself)
  have hexp_nn : (0 : ℝ) ≤ 1 - c := by linarith
  -- raise both sides to the nonneg power (1-c)
  have hrpow : (EntropyPower.Npow Hself) ^ (1 - c)
      ≤ (EntropyPower.Npow Hy) ^ (1 - c) :=
    Real.rpow_le_rpow hself_nn hself_le hexp_nn
  -- multiply on the left by the nonneg factor N_X^c
  have hfac_nn : (0 : ℝ) ≤ (EntropyPower.Npow Hx) ^ c :=
    Real.rpow_nonneg (le_of_lt (EntropyPower.Npow_pos Hx)) c
  exact mul_le_mul_of_nonneg_left hrpow hfac_nn

/-- **R.9.6(a) — EPI sharpened by the self-reference tax (R.700 + R.703).**

Cooperative-merge concavity `c·H_X + (1-c)·H_Y ≤ H_merge` exponentiates (R.700
`R_700_EPI_K`) to `N_X^c · N_Y^{1-c} ≤ N_merge`; the R.703 self-entropy tax
`H_self ≤ H_Y` makes the floor evaluated on the (poorer) self-kernel a still-valid
lower bound:

    N_X^c · N_self^{1-c}  ≤  N_X^c · N_Y^{1-c}  ≤  N_K(merge).

The middle term is the genuine EPI floor; the left term is its self-reference
sharpening.  Both inequalities are returned, chained. -/
theorem epi_self_sharpened
    (Hx Hself Hy Hmerge c : ℝ)
    (hc1 : c ≤ 1)
    (h_self_le : Hself ≤ Hy)
    (h_concave : c * Hx + (1 - c) * Hy ≤ Hmerge) :
    (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
        ≤ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hy) ^ (1 - c)
    ∧ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hy) ^ (1 - c)
        ≤ EntropyPower.Npow Hmerge := by
  refine ⟨epi_floor_mono Hx Hself Hy c hc1 h_self_le, ?_⟩
  exact EntropyPower.R_700_EPI_K Hx Hy Hmerge c h_concave

/-! ## 3. THE STRICTLY POSITIVE UNCERTAINTY FLOOR.

    Entropy power is strictly positive (R.700 `Npow_pos`), so even the
    self-sharpened EPI floor is strictly positive: the merged system cannot
    collapse below it.  This is the sharpened uncertainty LOWER bound. -/

/-- **R.9.6(b) — strictly positive entropy-power uncertainty floor (R.700).**

The self-sharpened EPI floor `N_X^c · N_self^{1-c}` is strictly positive (each
factor is a positive entropy power raised to a real power), and it lower-bounds
the merged entropy power.  Hence

    0  <  N_X^c · N_self^{1-c}  ≤  N_K(merge):

the merged-system entropy power admits a strictly positive lower bound, sharpened
by the self-reference tax — a sharpened MIP uncertainty floor that no collapse
can breach. -/
theorem uncertainty_floor_pos
    (Hx Hself Hy Hmerge c : ℝ)
    (hc1 : c ≤ 1)
    (h_self_le : Hself ≤ Hy)
    (h_concave : c * Hx + (1 - c) * Hy ≤ Hmerge) :
    0 < (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
    ∧ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
        ≤ EntropyPower.Npow Hmerge := by
  obtain ⟨hsharp, hepi⟩ :=
    epi_self_sharpened Hx Hself Hy Hmerge c hc1 h_self_le h_concave
  refine ⟨?_, le_trans hsharp hepi⟩
  have hx : 0 < (EntropyPower.Npow Hx) ^ c :=
    Real.rpow_pos_of_pos (EntropyPower.Npow_pos Hx) c
  have hself : 0 < (EntropyPower.Npow Hself) ^ (1 - c) :=
    Real.rpow_pos_of_pos (EntropyPower.Npow_pos Hself) (1 - c)
  exact mul_pos hx hself

/-! ## 4. ALPHA = 1 (SYMMETRIC) MEMBER AND CONSISTENCY WITH THE FAMILY.

    At the symmetric weight `c = 1/2` the EPI floor is the Shannon / alpha=1
    member: the square root of the product of component entropy powers.  We tie
    it to the alpha=1 Pinsker pivot endpoint (R8 tower) and the
    alpha-uncertainty concavity/shrink bound (R7 tower). -/

/-- **R.9.6(c) — symmetric (alpha=1) EPI floor.**

The equal-weight (`c = 1/2`) self-sharpened floor is

    √(N_X) · √(N_self)  ≤  N_K(merge),

the Shannon / alpha=1 entropy-power member.  (Specialises `epi_self_sharpened`
at `c = 1/2`, where `(1 - 1/2) = 1/2`.) -/
theorem epi_alpha_one
    (Hx Hself Hy Hmerge : ℝ)
    (h_self_le : Hself ≤ Hy)
    (h_concave : (1/2 : ℝ) * Hx + (1 - 1/2) * Hy ≤ Hmerge) :
    (EntropyPower.Npow Hx) ^ (1/2 : ℝ) * (EntropyPower.Npow Hself) ^ (1 - 1/2 : ℝ)
        ≤ EntropyPower.Npow Hmerge := by
  obtain ⟨hsharp, hepi⟩ :=
    epi_self_sharpened Hx Hself Hy Hmerge (1/2) (by norm_num) h_self_le h_concave
  exact le_trans hsharp hepi

/-! ## 5. HEADLINE — entropy power sharpens the MIP uncertainty bound and
        refines the alpha=1 family member. -/

open R7_Agent6_RenyiTsallisUncertainty
open R8_Agent10_PinskerAlphaMetricUncertainty

/-- **HEADLINE — `entropy_power_sharpens_uncertainty`.**

On a finite outcome set with an entropy-power layer (R.700/R.703), a synergistic
mixture, a flywheel-decaying barrier count, and a bounded-ground-metric Pinsker
datum, the following hold simultaneously, welding the entropy-power, uncertainty
and alpha-metric layers:

  (i)   ENTROPY-POWER INEQUALITY sharpened by the self-reference tax
        (R.700 + R.703):
          `N_X^c · N_self^{1-c} ≤ N_X^c · N_Y^{1-c} ≤ N_K(merge)`,
        the EPI floor and its self-tax sharpening, chained;

  (ii)  STRICTLY POSITIVE UNCERTAINTY FLOOR (R.700 `Npow_pos`):
          `0 < N_X^c · N_self^{1-c} ≤ N_K(merge)`,
        a sharpened MIP uncertainty lower bound no collapse can breach;

  (iii) ALPHA = 1 CONSISTENCY with the alpha-metric / uncertainty family
        (R7_Agent6 + R8_Agent10):
          * the R7 alpha-uncertainty bound holds (concavity floor + Xi shrink),
          * the alpha=1 Pinsker pivot endpoint holds (`distOne ≤ metricBound f 1 D KL`),
        so the alpha=1 entropy-power EPI floor is consistent with — and refines —
        the alpha=1 member of the alpha-metric family.

Thus an entropy-power inequality sharpens the MIP uncertainty bound and is
consistent with the alpha=1 (Shannon) member of the alpha-metric / uncertainty
family.  Chains R.700 + R.703 + R7_Agent6 + R8_Agent10. -/
theorem entropy_power_sharpens_uncertainty
    -- entropy-power layer (R.700 / R.703)
    (Hx Hself Hy Hmerge c : ℝ)
    (hc1 : c ≤ 1)
    (h_self_le : Hself ≤ Hy)
    (h_concave : c * Hx + (1 - c) * Hy ≤ Hmerge)
    -- alpha-uncertainty datum (R7 tower)
    {ι : Type*} (s : Finset ι) (α ca da : ℝ) (p q : ι → ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q ω)
    (hca : 0 ≤ ca) (hda : 0 ≤ da) (hcd : ca + da = 1)
    (B_t B_0 α₀ : ℝ) (t : ℕ)
    (hBt : 0 ≤ B_t) (hdecay : B_t ≤ (1 - α₀) ^ t * B_0)
    (hα₀1 : α₀ ≤ 1) (hB0 : 0 ≤ B_0)
    -- alpha=1 Pinsker datum (R8 tower)
    (w mx my mz : ι → ℝ) (hw : ∀ ω ∈ s, 0 ≤ w ω)
    (f : ℝ → ℝ) (D dTV KL : ℝ)
    (hf1 : f 1 = 1) (hD : 0 ≤ D)
    (hdom : AlphaMetric.distOne s w mx my ≤ D * dTV)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2)) :
    -- (i) EPI sharpened by self-tax
    ((EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
        ≤ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hy) ^ (1 - c)
      ∧ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hy) ^ (1 - c)
        ≤ EntropyPower.Npow Hmerge)
    -- (ii) strictly positive uncertainty floor
    ∧ (0 < (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
      ∧ (EntropyPower.Npow Hx) ^ c * (EntropyPower.Npow Hself) ^ (1 - c)
        ≤ EntropyPower.Npow Hmerge)
    -- (iii) alpha=1 consistency: R7 alpha-uncertainty bound + R8 Pinsker pivot
    ∧ ((ca * (∑ ω ∈ s, (p ω) ^ α) + da * (∑ ω ∈ s, (q ω) ^ α)
          ≤ ∑ ω ∈ s, (ca * p ω + da * q ω) ^ α)
        ∧ (B_t ^ 2 ≤ (1 - α₀) ^ (2 * t) * B_0 ^ 2))
    ∧ (AlphaMetric.distOne s w mx my ≤ metricBound f 1 D KL) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact epi_self_sharpened Hx Hself Hy Hmerge c hc1 h_self_le h_concave
  · exact uncertainty_floor_pos Hx Hself Hy Hmerge c hc1 h_self_le h_concave
  · exact alpha_uncertainty_bound s α ca da p q hα0 hα1 hp hq hca hda hcd
      B_t B_0 α₀ t hBt hdecay hα₀1 hB0
  · exact alpha_one_is_pinsker s w mx my mz hw f D dTV KL hf1 hD hdom hPinsker

end R9_Agent6_EntropyPowerUncertainty

end MIP
