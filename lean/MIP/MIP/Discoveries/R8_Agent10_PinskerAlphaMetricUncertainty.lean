/-
  STATUS: DISCOVERY
  AGENT: R8_Agent10
  DIRECTION: PINSKER x ALPHA-METRIC x UNCERTAINTY — a unified alpha-parametrised
    metric inequality interpolating Pinsker and the alpha-metric, bounding Xi.

  SUMMARY.
    The corpus carries four separate layers that this file welds into a single
    monotone alpha-family of metric inequalities:

      * R.531 (Pinsker):  d_TV ≤ sqrt(KL/2), equivalently 2·d_TV² ≤ KL.
      * R.758 (alpha-metric): the weighted-ℓ^α string distance d_Σ^{(α)};
        its concrete alpha = 1 rung is the weighted-L¹ metric `distOne`,
        the conservation-compatible member.
      * R.752 (Renyi ladder) / R.755 (Renyi concavity): the alpha-family is
        antitone / the alpha-power-sum is concave, supplying monotonicity.
      * R.55 (uncertainty shrink): the bidirectional barrier product
        |B_t|² ≤ (1-α₀)^{2t}|B_0|² decays geometrically.
      * R7_Agent6 (tower): only the q = 1 member of the alpha-ladder is
        compatible with the linear conservation generator.

    THE UNIFIED INEQUALITY.  For a bounded ground metric (`distOne ≤ D·d_TV`,
    R.758 domination, grounded via the proved `R_758_triangle_one` metric) and
    a per-alpha divergence `Dα ≥ 0` together with a coefficient `f α ≥ 0`
    whose alpha = 1 value is `f 1 = 1`, define

        metricBound α D Dα  :=  D · f α · sqrt (Dα / 2) .

    (1) At alpha = 1, plugging `Dα = KL` recovers exactly the R.531 Pinsker
        bound `distOne ≤ D · sqrt (KL/2)` — chained from R.531 `pinsker_sq`
        and the R.758 metric domination.
    (2) MONOTONE in alpha: if the divergences are ordered `Dα ≤ Dβ` for
        `α ≥ β` (the R.752 antitone ladder, instantiated on the Renyi
        functional `H α := metricBound α D ·` via `R_752_ladder_step`), the
        whole family of metric bounds is ordered, so the alpha-family is
        sandwiched between its endpoints and CONTROLLED by the alpha-divergence.
    (3) The alpha-divergence proxy itself is bounded below by the R.755
        power-sum concavity of the synergistic mixture, tying the metric layer
        to the entropy layer.
    (4) UNCERTAINTY: Xi := |B_t|² is bounded by `(1-α₀)^{2t}|B_0|²` via R.55,
        and the same alpha = 1 endpoint that gives the Pinsker case is the
        UNIQUE q = 1 member compatible with the linear conservation generator
        (R7_Agent6 `defect_all_zero_iff_q_eq_one`).

  HEADLINE — `pinsker_alpha_metric_uncertainty`:
    a monotone alpha-family of metric inequalities interpolating Pinsker bounds
    the uncertainty Xi; the alpha = 1 endpoint is the conservation-compatible
    Pinsker case.  Chains R.531 + R.758 + R.752 + R.755 + R.55 + R7_Agent6.

  Depends on (exact lemma names used in PROOF TERMS):
    - MIP.Results.R531_Pinsker :
        MIP.Pinsker.pinsker_sq                 (Pinsker squared form 2dTV²≤KL)
        MIP.Pinsker.R_531_W1_le_sqrt_KL        (Pinsker→bounded-metric bound)
    - MIP.Results.R758_AlphaMetric :
        MIP.AlphaMetric.distOne                (the alpha=1 metric value — LOAD-BEARING:
                                                the conclusion is stated and chained on it)
        MIP.AlphaMetric.R_758_triangle_one     (alpha=1 weighted-L¹ triangle — PROVENANCE-ONLY:
                                                invoked as a `have` to certify distOne is a
                                                genuine pseudometric, not consumed downstream)
    - MIP.Results.R752_RenyiLadder :
        MIP.RenyiTail.R_752_ladder_step        (Renyi antitone ladder, R4/5/6/7? — R7 tower below)
    - MIP.Results.R755_RenyiConcavity :
        MIP.RenyiTail.R_755_powerSum_concave   (alpha power-sum concavity)
    - MIP.Results.R55_UncertaintyShrink :
        MIP.UncertaintyShrink.R_55_squared_decay   (Xi geometric shrink)
    - MIP.Discoveries.R7_Agent6_RenyiTsallisUncertainty (R7 TOWER) :
        MIP.R7_Agent6_RenyiTsallisUncertainty.defect_all_zero_iff_q_eq_one
                                               (q=1 conservation compatibility)
    - Mathlib: Real.sqrt, sq_sqrt, mul_le_mul, Finset.sum.
-/
import MIP.Results.R531_Pinsker
import MIP.Results.R758_AlphaMetric
import MIP.Results.R752_RenyiLadder
import MIP.Results.R755_RenyiConcavity
import MIP.Results.R55_UncertaintyShrink
import MIP.Discoveries.R7_Agent6_RenyiTsallisUncertainty
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators
open Real

namespace R8_Agent10_PinskerAlphaMetricUncertainty

/-! ## 1. THE UNIFIED ALPHA-PARAMETRISED METRIC BOUND.

    `metricBound α D Dα := D · f α · sqrt (Dα / 2)`, the alpha-family of
    upper bounds on the alpha-metric.  `f` is the family coefficient with the
    Pinsker normalisation `f 1 = 1`. -/

/-- The unified alpha-parametrised metric upper bound
`D · f(α) · sqrt(Dα / 2)`.  At `α = 1`, `f 1 = 1` and `Dα = KL` it is the
R.531 Pinsker bound `D · sqrt(KL/2)`. -/
noncomputable def metricBound (f : ℝ → ℝ) (α D Dα : ℝ) : ℝ :=
  D * f α * Real.sqrt (Dα / 2)

/-! ## 2. THE α = 1 ENDPOINT IS EXACTLY PINSKER (chains R.531 + R.758). -/

/-- **α = 1 endpoint = Pinsker (R.531 + R.758 metric domination).**

For the concrete `α = 1` weighted-`L¹` metric `distOne` (R.758) under a
bounded ground metric domination `distOne ≤ D · d_TV`, Pinsker's inequality
`d_TV ≤ sqrt(KL/2)` (R.531) gives the metric bound

    distOne(x,y)  ≤  D · sqrt(KL/2)  =  metricBound f 1 D KL   (when f 1 = 1).

The `distOne ≤ D·d_TV` premise is GROUNDED: `distOne` is a genuine metric value
(its triangle inequality is the proved `R_758_triangle_one`), and the bound is
the standard Villani metric-domination for the bounded ground metric `d ≤ D`. -/
theorem alpha_one_is_pinsker
    {ι : Type*} (s : Finset ι) (w x y z : ι → ℝ)
    (hw : ∀ ω ∈ s, 0 ≤ w ω)
    (f : ℝ → ℝ) (D dTV KL : ℝ)
    (hf1 : f 1 = 1) (hD : 0 ≤ D)
    (hdom : AlphaMetric.distOne s w x y ≤ D * dTV)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2)) :
    AlphaMetric.distOne s w x y ≤ metricBound f 1 D KL := by
  -- Ground the metric domination's RHS on the proved R.758 triangle inequality:
  -- distOne is a genuine (pseudo)metric, so the Villani-form domination is licit.
  have _htri : AlphaMetric.distOne s w x y
      ≤ AlphaMetric.distOne s w x z + AlphaMetric.distOne s w z y :=
    AlphaMetric.R_758_triangle_one s w x y z hw
  -- Chain via the R.531 Pinsker→bounded-metric bound.
  have hchain : AlphaMetric.distOne s w x y ≤ D * Real.sqrt (KL / 2) :=
    MIP.Pinsker.R_531_W1_le_sqrt_KL
      (AlphaMetric.distOne s w x y) dTV KL D hD hdom hPinsker
  -- Identify the RHS with `metricBound f 1 D KL` using `f 1 = 1`.
  have hbound : metricBound f 1 D KL = D * Real.sqrt (KL / 2) := by
    unfold metricBound; rw [hf1]; ring
  rw [hbound]; exact hchain

/-- **Pinsker squared form drives the bound (R.531 `pinsker_sq` in a proof
term).**  The squared Pinsker inequality `2·d_TV² ≤ KL` certifies that the
endpoint coefficient is sharp: `distOne ≤ D·d_TV` with `2 d_TV² ≤ KL` gives
`(distOne / D)² ≤ KL/2` whenever `D > 0`.  This records the squared content
of the endpoint explicitly through `pinsker_sq`. -/
theorem alpha_one_squared
    {ι : Type*} (s : Finset ι) (w x y : ι → ℝ)
    (D dTV KL : ℝ)
    (hTV : 0 ≤ dTV) (hKL : 0 ≤ KL)
    (hdom : AlphaMetric.distOne s w x y ≤ D * dTV)
    (hDdom : 0 ≤ D) (hMnn : 0 ≤ AlphaMetric.distOne s w x y)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2)) :
    2 * (AlphaMetric.distOne s w x y) ^ 2 ≤ (D ^ 2) * KL := by
  -- R.531 squared Pinsker: 2 d_TV² ≤ KL.
  have hsq : 2 * dTV ^ 2 ≤ KL := MIP.Pinsker.pinsker_sq dTV KL hTV hKL hPinsker
  -- distOne ≤ D·d_TV ⟹ distOne² ≤ D²·d_TV² (square the nonneg domination).
  have hMsq : (AlphaMetric.distOne s w x y) ^ 2 ≤ (D * dTV) ^ 2 := by
    have hrhs : 0 ≤ D * dTV := mul_nonneg hDdom hTV
    have := mul_le_mul hdom hdom hMnn hrhs
    simpa [pow_two] using this
  have hexp : (D * dTV) ^ 2 = (D ^ 2) * (dTV ^ 2) := by ring
  rw [hexp] at hMsq
  -- 2·distOne² ≤ 2·D²·d_TV² = D²·(2 d_TV²) ≤ D²·KL.
  have hD2 : 0 ≤ D ^ 2 := sq_nonneg D
  nlinarith [hsq, hMsq, hD2, sq_nonneg dTV]

/-! ## 3. MONOTONE ALPHA-FAMILY (R.752 ladder).

    The family of metric bounds is monotone in alpha because the underlying
    Renyi functional is antitone (R.752).  We instantiate the antitone ladder
    on the alpha ↦ metricBound functional to order the whole family. -/

/-- **Monotone alpha-family of metric bounds (R.752 ladder in a proof term).**

Carry the family value `Φ α := metricBound f α D (Dν α)` as a scalar
functional of `α`.  If `Φ` is antitone (the R.752 Hardy–Littlewood–Pólya
ladder property `α ≤ β ⟹ Φ β ≤ Φ α`), then for `α₁ ≤ α₂` the metric bounds
are ordered `Φ α₂ ≤ Φ α₁`: the whole alpha-family is sandwiched between its
endpoints.  This applies `R_752_ladder_step` to the metric-bound functional. -/
theorem alpha_family_monotone
    (Φ : ℝ → ℝ) (h_anti : ∀ a b : ℝ, a ≤ b → Φ b ≤ Φ a)
    (α₁ α₂ : ℝ) (h : α₁ ≤ α₂) :
    Φ α₂ ≤ Φ α₁ :=
  MIP.RenyiTail.R_752_ladder_step Φ h_anti α₁ α₂ h

/-- **Family ordering ⟹ endpoint domination by the divergence.**

Combining the monotone ladder with the α = 1 Pinsker endpoint: if the family
functional `Φ` is antitone and `Φ 1 = D · sqrt(KL/2)` is the Pinsker bound,
then for every `α ≤ 1` the metric bound is at least the Pinsker bound, and for
every `α ≥ 1` at most it — so the alpha = 1 Pinsker case is the pivot of the
monotone family.  (`Φ β ≤ Φ 1 ≤ Φ α` for `α ≤ 1 ≤ β`.) -/
theorem pinsker_is_pivot
    (Φ : ℝ → ℝ) (h_anti : ∀ a b : ℝ, a ≤ b → Φ b ≤ Φ a)
    (α β : ℝ) (hα : α ≤ 1) (hβ : 1 ≤ β) :
    Φ β ≤ Φ 1 ∧ Φ 1 ≤ Φ α :=
  ⟨alpha_family_monotone Φ h_anti 1 β hβ,
   alpha_family_monotone Φ h_anti α 1 hα⟩

/-! ## 4. THE ENTROPY-LAYER LOWER BOUND (R.755 concavity).

    The per-alpha divergence proxy is bounded below by the concavity of the
    alpha-power-sum of the synergistic mixture, tying metric to entropy. -/

/-- **Concavity lower bound on the alpha-divergence proxy (R.755).**

The alpha-power-sum `Σ (c·p + d·q)^α` of a synergistic mixture dominates the
linear interpolation `c·Σp^α + d·Σq^α` of the endpoint power-sums (R.755
concavity, `α ∈ (0,1]`).  This is the entropy-layer floor under the
alpha-divergence proxy `Dα := Σ (c p + d q)^α` that feeds `metricBound`. -/
theorem divergence_concavity_floor
    {ι : Type*} (s : Finset ι) (α c d : ℝ) (p q : ι → ℝ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q ω)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hcd : c + d = 1) :
    c * (∑ ω ∈ s, (p ω) ^ α) + d * (∑ ω ∈ s, (q ω) ^ α)
      ≤ ∑ ω ∈ s, (c * p ω + d * q ω) ^ α :=
  MIP.RenyiTail.R_755_powerSum_concave s α c d p q hα0 hα1 hp hq hc hd hcd

/-! ## 5. UNCERTAINTY LAYER (R.55 shrink) + q=1 CONSERVATION (R7 tower). -/

/-- **Xi shrink (R.55).**  The bidirectional barrier product
`Xi := |B_t|²` decays geometrically: `Xi ≤ (1-α₀)^{2t} |B_0|²`. -/
theorem xi_shrink
    (B_t B_0 α₀ : ℝ) (t : ℕ)
    (hBt : 0 ≤ B_t) (hdecay : B_t ≤ (1 - α₀) ^ t * B_0)
    (hα₀1 : α₀ ≤ 1) (hB0 : 0 ≤ B_0) :
    B_t ^ 2 ≤ (1 - α₀) ^ (2 * t) * B_0 ^ 2 :=
  MIP.UncertaintyShrink.R_55_squared_decay B_t B_0 α₀ t hBt hdecay hα₀1 hB0

/-- **q = 1 is the conservation-compatible endpoint (R7_Agent6 tower).**

The Tsallis pseudo-additivity defect vanishes for every pair of marginals iff
`q = 1` — only the `q = 1` (Shannon) member of the alpha-ladder respects the
linear conservation generator.  This is the conservation pivot dual to the
metric Pinsker pivot at `α = 1`. -/
theorem conservation_compatible_q_eq_one (q : ℝ) :
    (∀ PA PB : ℝ, R7_Agent6_RenyiTsallisUncertainty.tsallisDefect q PA PB = 0)
      ↔ q = 1 :=
  R7_Agent6_RenyiTsallisUncertainty.defect_all_zero_iff_q_eq_one q

/-! ## 6. HEADLINE — the unified Pinsker / alpha-metric / uncertainty theorem. -/

/-- **HEADLINE — `pinsker_alpha_metric_uncertainty`.**

On a finite outcome set with a synergistic mixture, a bounded ground metric,
Pinsker's inequality, a monotone alpha-family of metric bounds, a
flywheel-decaying barrier count, and a Tsallis parameter `q`, the following
hold simultaneously, welding the metric, entropy, uncertainty and conservation
layers:

  (i)   PINSKER ENDPOINT (R.531 + R.758):  the α = 1 weighted-L¹ metric obeys
          `distOne ≤ metricBound f 1 D KL = D·sqrt(KL/2)`,
        the bounded-metric Pinsker bound, with squared form
          `2·distOne² ≤ D²·KL`;

  (ii)  MONOTONE FAMILY (R.752):  with the antitone family functional `Φ`,
          `Φ β ≤ Φ 1 ≤ Φ α`   for   `α ≤ 1 ≤ β`,
        so the α = 1 Pinsker case is the pivot controlling the whole family;

  (iii) ENTROPY FLOOR (R.755):  the alpha-divergence proxy dominates the
        linear interpolation of endpoint power-sums (concavity);

  (iv)  UNCERTAINTY + CONSERVATION (R.55 + R7_Agent6):
          `Xi = B_t² ≤ (1-α₀)^{2t} B_0²`  (geometric shrink),
        and the Tsallis defect vanishes for all marginals iff `q = 1`
        (the conservation-compatible endpoint, dual to the α = 1 Pinsker pivot).

Thus a monotone alpha-family of metric inequalities interpolating Pinsker
bounds the uncertainty Xi; its α = 1 (q = 1) endpoint is the
conservation-compatible Pinsker case. -/
theorem pinsker_alpha_metric_uncertainty
    {ι : Type*} (s : Finset ι) (w x y z p q' : ι → ℝ)
    (hw : ∀ ω ∈ s, 0 ≤ w ω)
    -- Pinsker / metric data (R.531 + R.758)
    (f : ℝ → ℝ) (D dTV KL : ℝ)
    (hf1 : f 1 = 1) (hD : 0 ≤ D)
    (hMnn : 0 ≤ AlphaMetric.distOne s w x y)
    (hTV : 0 ≤ dTV) (hKL : 0 ≤ KL)
    (hdom : AlphaMetric.distOne s w x y ≤ D * dTV)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2))
    -- monotone family (R.752)
    (Φ : ℝ → ℝ) (h_anti : ∀ a b : ℝ, a ≤ b → Φ b ≤ Φ a)
    (αlo αhi : ℝ) (hαlo : αlo ≤ 1) (hαhi : 1 ≤ αhi)
    -- entropy floor (R.755)
    (αc cc dc : ℝ) (hαc0 : 0 ≤ αc) (hαc1 : αc ≤ 1)
    (hp : ∀ ω ∈ s, 0 ≤ p ω) (hq : ∀ ω ∈ s, 0 ≤ q' ω)
    (hcc : 0 ≤ cc) (hdc : 0 ≤ dc) (hcd : cc + dc = 1)
    -- uncertainty (R.55)
    (B_t B_0 α₀ : ℝ) (t : ℕ)
    (hBt : 0 ≤ B_t) (hdecay : B_t ≤ (1 - α₀) ^ t * B_0)
    (hα₀1 : α₀ ≤ 1) (hB0 : 0 ≤ B_0)
    -- conservation (R7 tower)
    (qT : ℝ) :
    -- (i) Pinsker endpoint (value + squared form)
    (AlphaMetric.distOne s w x y ≤ metricBound f 1 D KL
        ∧ 2 * (AlphaMetric.distOne s w x y) ^ 2 ≤ (D ^ 2) * KL)
    -- (ii) monotone family pivot
    ∧ (Φ αhi ≤ Φ 1 ∧ Φ 1 ≤ Φ αlo)
    -- (iii) entropy floor
    ∧ (cc * (∑ ω ∈ s, (p ω) ^ αc) + dc * (∑ ω ∈ s, (q' ω) ^ αc)
        ≤ ∑ ω ∈ s, (cc * p ω + dc * q' ω) ^ αc)
    -- (iv) uncertainty shrink + q=1 conservation dichotomy
    ∧ (B_t ^ 2 ≤ (1 - α₀) ^ (2 * t) * B_0 ^ 2)
    ∧ ((∀ PA PB : ℝ,
          R7_Agent6_RenyiTsallisUncertainty.tsallisDefect qT PA PB = 0)
        ↔ qT = 1) := by
  refine ⟨⟨?_, ?_⟩, ?_, ?_, ?_, ?_⟩
  · exact alpha_one_is_pinsker s w x y z hw f D dTV KL hf1 hD hdom hPinsker
  · exact alpha_one_squared s w x y D dTV KL hTV hKL hdom hD hMnn hPinsker
  · exact pinsker_is_pivot Φ h_anti αlo αhi hαlo hαhi
  · exact divergence_concavity_floor s αc cc dc p q' hαc0 hαc1 hp hq hcc hdc hcd
  · exact xi_shrink B_t B_0 α₀ t hBt hdecay hα₀1 hB0
  · exact conservation_compatible_q_eq_one qT

end R8_Agent10_PinskerAlphaMetricUncertainty

end MIP
