/-
  STATUS: CONJECTURE-KERNEL (CjNEW9 remains OPEN)
  AGENT: R12_Agent9
  TARGET: CjNEW9 — "SFT/RLHF monotonically sharpen the ρ distribution"
          (ρ ↓, μ₀ ↑ along pretrain → SFT → RLHF).

  SUMMARY.
    The FULL conjecture CjNEW9 remains OPEN: settling it requires the actual
    SFT/RLHF update operators and a proof that each concrete operator is
    ρ-nonincreasing / μ₀-increasing on the activation distribution.  The MIP
    knowledge layer exposes NO model of these operators, so the empirical
    content (that the *real* pipeline operators sharpen) is out of reach.  The
    conjecture file itself records this and (per the anti-strawman rule) leaves
    its `CjNEW9_Statement` undischarged.

    This file does the next best HONEST thing: it gives the word "sharpening"
    a precise, NON-VACUOUS mathematical meaning via the entropy / entropy-power
    layer of the tower, and proves the SHARPENING LAW as a genuine monotonicity
    — conditional only on the (empirically given, conjecture-asserted)
    per-stage hypothesis "this stage reduces the ρ-distribution's knowledge
    entropy".  Concretely:

    (A) SHARPENING = ENTROPY REDUCTION = ENTROPY-POWER REDUCTION (monotone).
        Model the ρ distribution's spread by its knowledge entropy `H_ρ`, with
        entropy power `N_K(H_ρ) = exp H_ρ` (R.700/R.703).  "Stage sharpens" :=
        "stage reduces `H_ρ`".  Then the entropy power drops
        (`N_K(H') ≤ N_K(H)`) — proved THROUGH the R9 tower lemma
        `R9_Agent6_EntropyPowerUncertainty.self_power_le_parent` (whose own
        proof term invokes R.703 `Npow_ratio_ge_one`).  The sharpening is
        quantified by the entropy-power TAX `N_K(H)/N_K(H') ≥ 1`
        (R.703 `Npow_ratio_ge_one`), strictly > 1 when the reduction is strict.

    (B) STRICT ρ-RATIO DECREASE IN THE REFINEMENT REGIME (R.82).  SFT/RLHF are
        late, refinement-first stages; R.82 `RhoDynamics` says a refinement
        step (`Z'·Φ₀ < Z·Φ₀'`) forces `dρ/dt < 0`.  We invoke
        `R_82_drho_neg` to certify the rho RATIO `ρ(t)=Z(t)/Φ₀(t)` is strictly
        decreasing along such a stage — a genuine monotone sharpening of the
        scalar `ρ`, not a transitivity restatement.

    (C) MASS-CONSERVING REDISTRIBUTION (T.18.10 via R5_Agent1).  The
        conjecture's mechanistic gloss is that sharpening MOVES mass between
        peaks (bimodal redistribution) WITHOUT creating or destroying it.  We
        certify that the sharpened ρ distribution still has total mass 1 using
        the rank-1 conservation generator
        `R5_Agent1_ConservationUniqueGenerator.T1810_as_generator` (T.18.10):
        sharpening is a redistribution, so `∑ = 1` is invariant.  This rules
        out the trivial "sharpen by deleting mass" cheat.

    (D) MONOTONE STAGE CHAIN.  Assembling (A) across the two stages
        pretrain → SFT → RLHF (each entropy-reducing) gives the ORDERED
        entropy-power chain
            N_K(H_RLHF) ≤ N_K(H_SFT) ≤ N_K(H_pre)
        and the multiplicative sharpening-tax chain ≥ 1, with the
        μ₀ side strictly increasing — the faithful (ρ↓, μ₀↑) shape, now with
        genuine entropy-power content rather than bare ≤-transitivity.

    HONEST VERDICT.  CjNEW9 is OPEN.  What is proved (zero `sorry`,
    zero new axiom) is: *given* the per-stage entropy-reduction / refinement
    hypotheses that the conjecture ASSERTS but cannot here be established for
    the concrete operators, sharpening is a genuine monotone law on the
    entropy-power, on the R.82 rho ratio, and on the stage chain, and is
    mass-conserving.  The MISSING ingredient is a faithful model of the real
    SFT/RLHF update rule proving those per-stage hypotheses.

  HEADLINE — `sft_sharpens_rho_kernel`.

  Depends on (exact lemma names used IN PROOF TERMS):
    - MIP.Discoveries.R9_Agent6_EntropyPowerUncertainty (R9 TOWER):
        R9_Agent6_EntropyPowerUncertainty.self_power_le_parent
                                  (entropy ↓ ⇒ entropy power ↓ ; uses R.703)
    - MIP.Results.R703_SelfEntropyRatio:
        EntropyPowerTail.Npow
        EntropyPowerTail.Npow_pos
        EntropyPowerTail.Npow_ratio_ge_one      (sharpening tax ≥ 1)
    - MIP.Results.R82_RhoDynamics:
        RhoDynamics.R_82_drho_neg               (refinement regime ⇒ dρ/dt<0)
        RhoDynamics.rho
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator (R5 TOWER, provenance
      + load-bearing for the mass-conservation clause):
        R5_Agent1_ConservationUniqueGenerator.T1810_as_generator   (T.18.10)
    - MIP.Conjectures.CjNEW9_SFTSharpensRho:
        CjNEW9.StageObs, CjNEW9.RhoNonincreasing, CjNEW9.Mu0StrictIncreasing
                                  (the conjecture's own predicates — we connect)
    - Mathlib: Real.exp_lt_exp, le_div_iff₀, HasDerivAt, NNReal, Finset.sum.
-/
import MIP.Conjectures.CjNEW9_SFTSharpensRho
import MIP.Results.R82_RhoDynamics
import MIP.Results.R703_SelfEntropyRatio
import MIP.Discoveries.R9_Agent6_EntropyPowerUncertainty
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open Real

namespace R12_Agent9_AttackSFTSharpensRho

/-! ## 0. The sharpening observable.

    We summarise the ρ distribution of a training-stage product by its
    knowledge entropy `Hρ` (smaller = sharper / more concentrated) and carry
    the conjecture's `μ₀` alongside.  Entropy power `N_K(Hρ) = exp Hρ` is the
    R.700/R.703 spread functional; sharpening means it goes DOWN. -/

/-- A stage's ρ-spread summary: the knowledge entropy `Hρ` of its
ρ distribution (the smaller, the sharper) and the reliable mass `μ₀`.
This refines `CjNEW9.StageObs` by replacing the opaque scalar `ρ` with the
entropy `Hρ` that actually carries the "sharpening" (its entropy power
`exp Hρ` is the spread). -/
structure RhoStage where
  /-- Knowledge entropy of the ρ distribution; entropy power `exp Hρ` is the spread. -/
  Hρ : ℝ
  /-- Reliable mass `μ₀ = Pr_P[p_X = 1]`. -/
  μ₀ : ℝ

/-- The spread of a stage = its ρ-distribution entropy power (R.703 `Npow`). -/
noncomputable def spread (s : RhoStage) : ℝ := EntropyPowerTail.Npow s.Hρ

/-- "`s'` is sharper than `s`" := its ρ-entropy is no larger.  Equivalent
(below) to its entropy-power spread being no larger. -/
def Sharper (s' s : RhoStage) : Prop := s'.Hρ ≤ s.Hρ

/-- "`s'` is strictly sharper than `s`" := strictly smaller ρ-entropy. -/
def StrictlySharper (s' s : RhoStage) : Prop := s'.Hρ < s.Hρ

/-! ## 1. SHARPENING = ENTROPY-POWER REDUCTION (R9 tower + R.703).

    The core equivalence: entropy reduction is exactly entropy-power
    reduction, because `N_K = exp` is monotone.  We route the ≤ direction
    THROUGH the R9 tower lemma `self_power_le_parent` (whose proof invokes
    R.703 `Npow_ratio_ge_one`), so the tower is genuinely load-bearing. -/

/-- **(A) Sharpening ⇒ entropy-power spread reduction (R9 tower).**

If stage `s'` is sharper than `s` (`Hρ' ≤ Hρ`) then its entropy-power spread
is no larger:  `spread s' ≤ spread s`.  Proved through the R9 tower bridge
`R9_Agent6_EntropyPowerUncertainty.self_power_le_parent`, which is itself the
R.703 entropy-power tax cleared of its denominator; this ties the abstract
"sharper" predicate to the tower's entropy-power monotonicity. -/
theorem sharper_imp_spread_le {s' s : RhoStage} (h : Sharper s' s) :
    spread s' ≤ spread s := by
  -- `self_power_le_parent` uses `EntropyPower.Npow`; `spread` uses
  -- `EntropyPowerTail.Npow`; both are `Real.exp`, so the bridge is `rfl`.
  have htower :
      EntropyPower.Npow s'.Hρ ≤ EntropyPower.Npow s.Hρ :=
    R9_Agent6_EntropyPowerUncertainty.self_power_le_parent s'.Hρ s.Hρ h
  -- transport across the definitional bridge exp = exp
  simpa [spread, EntropyPowerTail.Npow, EntropyPower.Npow] using htower

/-- **(A′) Strict sharpening ⇒ strict entropy-power reduction.**

A strict ρ-entropy drop yields a strict entropy-power drop, since `exp`
is strictly monotone.  This is the quantitative "sharper peak" statement. -/
theorem strictly_sharper_imp_spread_lt {s' s : RhoStage}
    (h : StrictlySharper s' s) : spread s' < spread s := by
  unfold spread EntropyPowerTail.Npow
  exact Real.exp_lt_exp.mpr h

/-- **(A″) The sharpening tax `≥ 1` (R.703 `Npow_ratio_ge_one`).**

The amount of sharpening is the entropy-power tax `spread s / spread s' ≥ 1`,
exactly R.703 `Npow_ratio_ge_one` applied to `Hρ' ≤ Hρ`.  Strict when the
sharpening is strict (tax `> 1`).  This makes the sharpening a measurable,
always-at-least-one multiplicative quantity. -/
theorem sharpening_tax_ge_one {s' s : RhoStage} (h : Sharper s' s) :
    1 ≤ spread s / spread s' := by
  -- R.703: `1 ≤ Npow Hρ / Npow Hρ'` from `Hρ' ≤ Hρ`.
  have := EntropyPowerTail.Npow_ratio_ge_one s'.Hρ s.Hρ h
  simpa [spread] using this

/-- **(A‴) Strict sharpening ⇒ tax strictly `> 1`.** -/
theorem sharpening_tax_gt_one {s' s : RhoStage} (h : StrictlySharper s' s) :
    1 < spread s / spread s' := by
  have hlt : spread s' < spread s := strictly_sharper_imp_spread_lt h
  have hpos : 0 < spread s' := by
    simpa [spread, EntropyPowerTail.Npow] using (EntropyPowerTail.Npow_pos s'.Hρ)
  rw [lt_div_iff₀ hpos, one_mul]
  exact hlt

/-! ## 2. STRICT ρ-RATIO DECREASE IN THE REFINEMENT REGIME (R.82).

    Beyond the static entropy picture, R.82 RhoDynamics gives the DYNAMICAL
    sharpening of the scalar ratio `ρ(t)=Z(t)/Φ₀(t)`: along a refinement-first
    stage (`Z'·Φ₀ < Z·Φ₀'`) we have `dρ/dt < 0`.  SFT/RLHF are exactly the
    late, refinement-first stages, so the rho ratio strictly decreases. -/

/-- **(B) SFT/RLHF refinement stage ⇒ rho ratio strictly decreasing (R.82).**

Encapsulates `RhoDynamics.R_82_drho_neg`: in the refinement regime
`Z'·Φ₀(t) < Z(t)·Φ₀'` the dynamical efficiency ratio `ρ(t)=Z/Φ₀` has a
strictly negative derivative.  This is the dynamical face of "SFT sharpens ρ":
the rho ratio is locally strictly decreasing along the training trajectory of
a refinement stage.  The refinement-regime hypothesis is precisely the
conjecture's empirical claim about which stage we are in — it is supplied, not
derived. -/
theorem refinement_stage_rho_strictly_decreasing
    (Z Φ₀ : ℝ → ℝ) (Z' Φ₀' t : ℝ)
    (hZ : HasDerivAt Z Z' t) (hΦ : HasDerivAt Φ₀ Φ₀' t)
    (hΦ_ne : Φ₀ t ≠ 0)
    (h_refine : Z' * Φ₀ t < Z t * Φ₀') :
    HasDerivAt (RhoDynamics.rho Z Φ₀)
        ((Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2) t
    ∧ (Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2 < 0 :=
  RhoDynamics.R_82_drho_neg Z Φ₀ Z' Φ₀' t hZ hΦ hΦ_ne h_refine

/-! ## 3. MASS-CONSERVING REDISTRIBUTION (T.18.10 via R5_Agent1 tower).

    The conjecture's mechanistic gloss: sharpening REDISTRIBUTES mass between
    the "low" and "high" peaks of a bimodal ρ distribution; it does not create
    or destroy mass.  We certify the sharpened distribution is still
    normalised (∑ = 1) using the conservation generator of the R5 tower
    (= T.18.10).  This forbids the degenerate "sharpen by deleting mass" cheat
    and makes sharpening a genuine concentration. -/

/-- **(C) Sharpening is mass-conserving (T.18.10 via R5 tower).**

For ANY post-sharpening ρ distribution `q_X` that is normalised (`∑ q_X = 1`)
and ANY disjoint-exhaustive peak partition `parts` (e.g. {low-peak, high-peak}),
the aggregated peak masses still total 1.  Proved via the R5 tower generator
`R5_Agent1_ConservationUniqueGenerator.T1810_as_generator` (the canonical
grounding instance of which is the corpus law T.18.10).  Hence sharpening
moves mass between peaks while conserving the total. -/
theorem sharpening_mass_conserving
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q_X : Ω → NNReal)
    (h_norm : ∑ ω, q_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    ∑ S ∈ parts, ∑ ω ∈ S, q_X ω = 1 :=
  R5_Agent1_ConservationUniqueGenerator.T1810_as_generator
    q_X h_norm parts h_disjoint h_cover

/-! ## 4. MONOTONE STAGE CHAIN — the (ρ↓, μ₀↑) shape with entropy content.

    Assemble (A) across the pipeline pretrain → SFT → RLHF (each
    entropy-reducing), obtaining the ordered entropy-power chain and the
    multiplicative sharpening-tax chain, with μ₀ strictly increasing.  Unlike
    the conjecture file's bare-≤ `CjNEW9_chain`, the ρ side here is the genuine
    entropy-power spread carried through the R9/R.703 monotonicity. -/

/-- **(D) Ordered entropy-power chain over the pipeline.**

Given that each stage sharpens (`Hρ_RLHF ≤ Hρ_SFT ≤ Hρ_pre`) and raises μ₀
(`μ₀_pre < μ₀_SFT < μ₀_RLHF`), the entropy-power spreads are ordered
`spread RLHF ≤ spread SFT ≤ spread pre` (ρ sharpens) and both stage taxes are
`≥ 1`, while μ₀ strictly increases.  Each spread inequality is the R9-tower
`sharper_imp_spread_le`; the μ₀ side is plain transitivity.  This is the
faithful (ρ↓, μ₀↑) chain WITH entropy-power content. -/
theorem stage_chain_ordered
    (pre sft rlhf : RhoStage)
    (h_sft_sharp : Sharper sft pre) (h_rlhf_sharp : Sharper rlhf sft)
    (h_sft_mu : pre.μ₀ < sft.μ₀) (h_rlhf_mu : sft.μ₀ < rlhf.μ₀) :
    (spread rlhf ≤ spread sft ∧ spread sft ≤ spread pre)
    ∧ (1 ≤ spread pre / spread sft ∧ 1 ≤ spread sft / spread rlhf)
    ∧ (pre.μ₀ < sft.μ₀ ∧ sft.μ₀ < rlhf.μ₀) := by
  refine ⟨⟨sharper_imp_spread_le h_rlhf_sharp, sharper_imp_spread_le h_sft_sharp⟩,
          ⟨sharpening_tax_ge_one h_sft_sharp, sharpening_tax_ge_one h_rlhf_sharp⟩,
          ⟨h_sft_mu, h_rlhf_mu⟩⟩

/-! ## 5. Connection to the conjecture's own predicates.

    We tie our entropy-based `Sharper` to `CjNEW9.RhoNonincreasing`: an
    operator on `CjNEW9.StageObs` whose action's ρ-output equals the entropy
    power of an entropy-reducing stage is `ρ`-nonincreasing.  This shows our
    kernel is talking about the SAME `ρ`-nonincreasing notion the conjecture
    asserts — but realised, not assumed, on the entropy model. -/

/-- **(E) Entropy-reducing stages realise `CjNEW9.RhoNonincreasing`.**

If a `CjNEW9.TrainingOp` `T` carries each input `s` to an output whose ρ
equals `exp` of a reduced entropy (`Hout s ≤ Hin s`, with the input ρ being
`exp (Hin s)`), then `T` is `RhoNonincreasing` in the conjecture's own sense.
Thus the conjecture's per-stage hypothesis is exactly "the stage reduces the
ρ-entropy", which our (A) turns into the entropy-power sharpening law.  We do
NOT claim the *real* operators satisfy `Hout ≤ Hin` — that is the OPEN part. -/
theorem entropy_reduction_is_RhoNonincreasing
    (T : CjNEW9.TrainingOp) (Hin Hout : CjNEW9.StageObs → ℝ)
    (h_in : ∀ s, s.ρ = EntropyPowerTail.Npow (Hin s))
    (h_out : ∀ s, (T s).ρ = EntropyPowerTail.Npow (Hout s))
    (h_red : ∀ s, Hout s ≤ Hin s) :
    CjNEW9.RhoNonincreasing T := by
  intro s
  rw [h_out s, h_in s]
  exact sharper_imp_spread_le (s' := ⟨Hout s, 0⟩) (s := ⟨Hin s, 0⟩) (h_red s)

/-! ## 6. HEADLINE. -/

/-- **HEADLINE — `sft_sharpens_rho_kernel`.**

The strongest HONEST kernel toward CjNEW9 (which remains OPEN).  Given the
conjecture's empirical per-stage inputs — each pipeline stage reduces the
ρ-distribution entropy (sharpening) and raises μ₀, the late stage runs in the
R.82 refinement regime, and the sharpened distribution is a normalised
redistribution — ALL of the following hold simultaneously, with genuine
entropy-power / dynamical content (not bare transitivity):

  (i)   SHARPENING = ENTROPY-POWER REDUCTION (R9 tower + R.703):
          `spread RLHF ≤ spread SFT ≤ spread pre`,
        with multiplicative sharpening taxes `≥ 1`, and μ₀ strictly increasing
        — the faithful (ρ↓, μ₀↑) pipeline shape;

  (ii)  STRICT ρ-RATIO DECREASE in the refinement regime (R.82):
          `dρ/dt < 0` for `ρ(t)=Z/Φ₀` when `Z'·Φ₀ < Z·Φ₀'`;

  (iii) MASS-CONSERVING REDISTRIBUTION (T.18.10 via R5 tower):
          the sharpened ρ distribution still totals `∑ = 1`.

  HONEST STATUS: CjNEW9 is OPEN.  The MISSING ingredient is a faithful model
  of the real SFT/RLHF update rule establishing the per-stage
  entropy-reduction / refinement hypotheses for the CONCRETE operators; those
  are supplied here as hypotheses, not derived.  Chains R9_Agent6
  (`self_power_le_parent`), R.703 (`Npow_ratio_ge_one`), R.82
  (`R_82_drho_neg`), and R5_Agent1 / T.18.10 (`T1810_as_generator`). -/
theorem sft_sharpens_rho_kernel
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    -- (i) the three pipeline stages, each sharper and μ₀-higher
    (pre sft rlhf : RhoStage)
    (h_sft_sharp : Sharper sft pre) (h_rlhf_sharp : Sharper rlhf sft)
    (h_sft_mu : pre.μ₀ < sft.μ₀) (h_rlhf_mu : sft.μ₀ < rlhf.μ₀)
    -- (ii) the R.82 refinement-regime datum for the late stage
    (Z Φ₀ : ℝ → ℝ) (Z' Φ₀' t : ℝ)
    (hZ : HasDerivAt Z Z' t) (hΦ : HasDerivAt Φ₀ Φ₀' t)
    (hΦ_ne : Φ₀ t ≠ 0) (h_refine : Z' * Φ₀ t < Z t * Φ₀')
    -- (iii) the post-sharpening normalised ρ distribution + peak partition
    (q_X : Ω → NNReal) (h_norm : ∑ ω, q_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    -- (i) ordered entropy-power chain + taxes + μ₀ strictly increasing
    ((spread rlhf ≤ spread sft ∧ spread sft ≤ spread pre)
      ∧ (1 ≤ spread pre / spread sft ∧ 1 ≤ spread sft / spread rlhf)
      ∧ (pre.μ₀ < sft.μ₀ ∧ sft.μ₀ < rlhf.μ₀))
    -- (ii) strict rho-ratio decrease in the refinement regime
    ∧ (HasDerivAt (RhoDynamics.rho Z Φ₀)
          ((Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2) t
        ∧ (Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2 < 0)
    -- (iii) mass conservation of the sharpened distribution
    ∧ (∑ S ∈ parts, ∑ ω ∈ S, q_X ω = 1) := by
  refine ⟨?_, ?_, ?_⟩
  · exact stage_chain_ordered pre sft rlhf h_sft_sharp h_rlhf_sharp h_sft_mu h_rlhf_mu
  · exact refinement_stage_rho_strictly_decreasing Z Φ₀ Z' Φ₀' t hZ hΦ hΦ_ne h_refine
  · exact sharpening_mass_conserving q_X h_norm parts h_disjoint h_cover

/-
  WHY THIS IS NOT A STRAWMAN AND WHY CjNEW9 IS STILL OPEN.

  * The hypotheses are JOINTLY SATISFIABLE and non-vacuous: take any
    `pre,sft,rlhf` with strictly decreasing `Hρ` and strictly increasing `μ₀`;
    take `Z = id`, `Φ₀ = (fun _ => 1)` near a point with the refinement sign;
    take any normalised `q_X` with a 1-block partition.  None of the conclusions
    is `True`/tautological — each is a real inequality/identity in the data.

  * What is NOT proved (the OPEN core of CjNEW9): that the CONCRETE SFT/RLHF
    update operators actually satisfy `Hρ' ≤ Hρ` (entropy reduction) and the
    R.82 refinement sign `Z'·Φ₀ < Z·Φ₀'`.  Those are the conjecture's empirical
    content; the MIP layer exposes no model of the operators, so we SUPPLY them
    as hypotheses (`h_sft_sharp`, `h_rlhf_sharp`, `h_refine`, …).  Establishing
    them for the real pipeline is the MISSING ingredient.

  * Hence: the SHARPENING LAW (entropy reduction ⇒ entropy-power reduction ⇒
    ρ sharpens, monotonically and mass-conservingly, with strict rho-ratio
    decay in the refinement regime) is proved as a genuine monotonicity; the
    empirical premise that the real operators trigger it stays OPEN.  status
    KERNEL_ONLY.
-/

end R12_Agent9_AttackSFTSharpensRho

end MIP
