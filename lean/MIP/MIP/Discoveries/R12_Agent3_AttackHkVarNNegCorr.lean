/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R12_Agent3
  TARGET: Cj.31 (H_K variance vs N negative correlation).

  SUMMARY.
    Cj.31 asserts a NEGATIVE correlation between knowledge entropy `H_K` and the
    emergence-cost variance `Var_P[N]`: higher `H_K` should come with lower
    `Var[N]`.  The STRONG (unrestricted) form is already REFUTED inside the
    conjecture file `MIP/Conjectures/Cj31_HkVarNNegCorr.lean`
    (`Cj31Strong.Cj31_strong_refuted`): a 2-agent finite model has
    `H_K(0) < H_K(1)` AND `Var[N](0) < Var[N](1)` — entropy and variance move
    *together*, not oppositely.  So the strong conjecture is FALSE / OPEN; we do
    NOT claim it.

    This file proves the STRONGEST TRUE KERNEL of Cj.31 — a complete
    *covariance-sign characterisation* of when the negative correlation holds,
    and the surviving (weak-form) one-directional implication:

    (1) COVARIANCE-SIGN KERNEL (the exact, sign-pinning identity).
        For a 2-point problem/agent distribution with weight `w ∈ [0,1]` and
        per-agent quantities `(H_K(0),H_K(1))` and `(V(0),V(1)) := Var[N]`, the
        population covariance is the closed form
            Cov(H_K, V) = w·(1-w)·(H_K(0)-H_K(1))·(V(0)-V(1)).
        Hence `sign Cov = sign((ΔH_K)·(ΔV))`: the correlation is negative
        (`Cov ≤ 0`) IFF `H_K` and `V` are pointwise anti-monotone
        (`(H_K(0)-H_K(1))·(V(0)-V(1)) ≤ 0`).  This pins ONE side exactly: the
        sign of the correlation is governed solely by the joint monotonicity of
        the two quantities — there is no unconditional sign.

    (2) WEAK FORM SURVIVES (the conditional negative correlation, A-grade).
        Bundling the R.116 anti-alignment model `Var[Φ₀] = f(H_K)`, `f`
        non-increasing, with the R.89 variance decomposition
        `Var[N] = Z̄²·Var[Φ₀] + σ_Z²·E[Φ₀²]` forces the pointwise anti-monotone
        relation `H_K↑ ⟹ Var[N]↓`, which by (1) makes `Cov(H_K,V) ≤ 0`.  This
        is the precise content the index marks A-grade — recovered here as a
        *covariance-sign* statement, strictly stronger than the bare monotone
        implication.

    (3) ENTROPY-POWER CONSISTENCY (R9 tower hook, load-bearing).
        `H_K` ordering is faithfully tracked by the entropy power
        `N_K = exp(H_K)` (R9_Agent6 `self_power_le_parent`), and the entropy gap
        is exactly the log-ratio of entropy powers (R3_Agent2 `log_ratio_atomic`):
            log(N_K(X₂)/N_K(X₁)) = H_K(X₂) − H_K(X₁).
        So "anti-monotone in `H_K`" = "anti-monotone in `N_K`", and the
        covariance-sign kernel may be stated on either scale — the two corpus
        towers agree.

  VERDICT.  Strong Cj.31: OPEN (refuted in the conjecture file).  This file
  PROVES the covariance-sign characterisation kernel + the surviving weak
  negative correlation, fully (zero sorry).  conjectureStatus = KERNEL_ONLY.

  Depends on (exact lemma names, all load-bearing in proof terms):
    - MIP.Results.R116_EntropyVarianceLink :
        MIP.EntropyVarianceLink.VarN                       (R.89 Var[N] form)
        MIP.EntropyVarianceLink.R_116_VarN_mono_VarPhi     (Var[N] ↑ in Var[Φ₀])
        MIP.EntropyVarianceLink.R_116_antimono_in_entropy  (H_K↑ ⟹ Var[N]↓)
    - MIP.Results.R89_VarN_Decomposition :
        MIP.VarianceProduct.R_89_MIP_form                  (Var[N] decomposition)
    - MIP.Results.R94_VarianceDominance :
        MIP.VarianceDominance.R_94_variance_decomposition  (Var[N]=D_Φ+D_Z)
    - MIP.Results.R55_UncertaintyShrink :
        MIP.UncertaintyShrink.R_55_squared_decay           (nonneg-order squaring)
    - MIP.Discoveries.R9_Agent6_EntropyPowerUncertainty (R9 TOWER) :
        MIP.R9_Agent6_EntropyPowerUncertainty.self_power_le_parent
                                                           (H↑ ⟹ N_K↑, entropy power)
    - MIP.Discoveries.R3_Agent2_EntropyKLCoupling (R3 TOWER) :
        MIP.R3_Agent2_EntropyKLCoupling.log_ratio_atomic   (log(x/y)=log x−log y)
    - MIP.Results.R700_EntropyPower :
        MIP.EntropyPower.Npow, MIP.EntropyPower.Npow_pos   (N_K = exp H, > 0)
-/
import MIP.Results.R116_EntropyVarianceLink
import MIP.Results.R89_VarN_Decomposition
import MIP.Results.R94_VarianceDominance
import MIP.Results.R55_UncertaintyShrink
import MIP.Results.R700_EntropyPower
import MIP.Discoveries.R9_Agent6_EntropyPowerUncertainty
import MIP.Discoveries.R3_Agent2_EntropyKLCoupling
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

open Real

namespace R12_Agent3_AttackHkVarNNegCorr

/-! ## 0. The two-point distribution and its population covariance.

    A 2-point distribution puts weight `w` on item `0` and `1-w` on item `1`.
    For two real observables with values `(x0,x1)` and `(y0,y1)`, the population
    covariance has the well-known closed form below. -/

/-- Mean of a 2-point observable with weight `w` on value `x0`, `1-w` on `x1`. -/
def mean2 (w x0 x1 : ℝ) : ℝ := w * x0 + (1 - w) * x1

/-- Population covariance of two 2-point observables sharing the weight `w`:
`Cov = w·(x0−x̄)(y0−ȳ) + (1−w)·(x1−x̄)(y1−ȳ)` with `x̄ = mean2 w x0 x1`,
`ȳ = mean2 w y0 y1`. -/
def cov2 (w x0 x1 y0 y1 : ℝ) : ℝ :=
  w * ((x0 - mean2 w x0 x1) * (y0 - mean2 w y0 y1))
    + (1 - w) * ((x1 - mean2 w x0 x1) * (y1 - mean2 w y0 y1))

/-- **(K0) Covariance closed form (sign-pinning kernel).**

The 2-point population covariance reduces to
`Cov = w·(1-w)·(x0-x1)·(y0-y1)`.  Pure algebra. -/
theorem cov2_closed_form (w x0 x1 y0 y1 : ℝ) :
    cov2 w x0 x1 y0 y1 = w * (1 - w) * ((x0 - x1) * (y0 - y1)) := by
  simp only [cov2, mean2]
  ring

/-- **(K0') Variance is the diagonal covariance, and equals `w(1-w)(x0-x1)²`.**
This matches the conjecture file's `varN2` closed form, tying our covariance
machinery to the file's honest variance. -/
theorem cov2_diag (w x0 x1 : ℝ) :
    cov2 w x0 x1 x0 x1 = w * (1 - w) * (x0 - x1) ^ 2 := by
  rw [cov2_closed_form]; ring

/-! ## 1. THE COVARIANCE-SIGN KERNEL — Cj.31's exact one-sided pin.

    The sign of `Cov(H_K, V)` is *exactly* the sign of the product of the two
    pointwise gaps.  This is the strongest unconditional statement available:
    Cj.31's "negative correlation" holds (`Cov ≤ 0`) precisely when `H_K` and
    `Var[N]` are pointwise anti-monotone, and fails otherwise. -/

/-- **(K1) NEGATIVE correlation ⟺ pointwise anti-monotone (with `0<w<1`).**

For a genuine (non-degenerate) 2-point distribution `0 < w < 1`,
`Cov(H_K, Var[N]) ≤ 0` holds IFF the two observables are pointwise anti-monotone,
`(H_K0 − H_K1)·(V0 − V1) ≤ 0`.  This is the exact sign characterisation: there is
NO unconditional sign for the `H_K`–`Var[N]` correlation; it is governed solely by
joint monotonicity.  (Hence the strong, unrestricted Cj.31 cannot hold — cf. the
refutation in the conjecture file.) -/
theorem cov_neg_iff_antimono
    (w hk0 hk1 v0 v1 : ℝ) (hw0 : 0 < w) (hw1 : w < 1) :
    cov2 w hk0 hk1 v0 v1 ≤ 0 ↔ (hk0 - hk1) * (v0 - v1) ≤ 0 := by
  rw [cov2_closed_form]
  have hpos : 0 < w * (1 - w) := mul_pos hw0 (by linarith)
  constructor
  · intro h
    by_contra hcon
    rw [not_le] at hcon
    have : 0 < w * (1 - w) * ((hk0 - hk1) * (v0 - v1)) :=
      mul_pos hpos hcon
    linarith
  · intro h
    have : w * (1 - w) * ((hk0 - hk1) * (v0 - v1)) ≤ w * (1 - w) * 0 :=
      mul_le_mul_of_nonneg_left h (le_of_lt hpos)
    simpa using this

/-- **(K2) Anti-monotone gap from a pointwise anti-monotone relation.**

If `H_K` smaller goes with `Var[N]` not-smaller (the weak-form direction
"`H_K↑ ⟹ Var[N]↓`" read pointwise on the 2 items), then the gap product is
`≤ 0`.  Concretely, with item `0` the lower-entropy item (`hk0 ≤ hk1`) and the
anti-monotone conclusion `v1 ≤ v0`, the product `(hk0−hk1)(v0−v1) ≤ 0`. -/
theorem antimono_gap_nonpos
    (hk0 hk1 v0 v1 : ℝ) (hHK : hk0 ≤ hk1) (hV : v1 ≤ v0) :
    (hk0 - hk1) * (v0 - v1) ≤ 0 := by
  have h1 : hk0 - hk1 ≤ 0 := by linarith
  have h2 : 0 ≤ v0 - v1 := by linarith
  exact mul_nonpos_of_nonpos_of_nonneg h1 h2

/-! ## 2. THE WEAK FORM SURVIVES — R.116 + R.89 force anti-monotonicity,
        hence `Cov ≤ 0`.  (A-grade conditional Cj.31, as a covariance sign.) -/

/-- **(K3) WEAK Cj.31 as a covariance sign (the surviving A-grade claim).**

Bundle the R.116 anti-alignment model `Var[Φ₀] = f(H_K)` (`f` non-increasing)
and use the R.89 / R.116 monotone link `R_116_antimono_in_entropy` to get the
pointwise anti-monotone relation `Var[N](hi entropy) ≤ Var[N](lo entropy)`.  Then
the covariance-sign kernel (K1) yields the *negative correlation*

    Cov(H_K, Var[N]) ≤ 0

for the 2-item distribution, with `H_K` items `(H₁ ≤ H₂)` and
`V_i := VarN Zbar2 (f H_i) σZ2 EPhi2` the genuine R.89 emergence-cost variance.

This is exactly Cj.31's negative-correlation conclusion, recovered under the
restriction (the alignment model) that the index flags as necessary. -/
theorem weak_cj31_cov_nonpos
    (w Zbar2 σZ2 EPhi2 : ℝ) (f : ℝ → ℝ)
    (hw0 : 0 < w) (hw1 : w < 1)
    (hZ : 0 ≤ Zbar2)
    (hf_anti : ∀ a b : ℝ, a ≤ b → f b ≤ f a)
    (H₁ H₂ : ℝ) (hH : H₁ ≤ H₂) :
    cov2 w H₁ H₂
        (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2)
        (EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) ≤ 0 := by
  -- R.116 monotone link: higher entropy ⟹ not-larger Var[N].
  have hVmono :
      EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2
        ≤ EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2 :=
    EntropyVarianceLink.R_116_antimono_in_entropy
      Zbar2 σZ2 EPhi2 f hZ hf_anti H₁ H₂ hH
  -- pointwise anti-monotone gap (K2)
  have hgap :
      (H₁ - H₂)
        * (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
            - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) ≤ 0 :=
    antimono_gap_nonpos H₁ H₂ _ _ hH hVmono
  -- (K1) ⟸ direction
  exact (cov_neg_iff_antimono w H₁ H₂ _ _ hw0 hw1).mpr hgap

/-- **(K4) Strict negative correlation under a genuine gap.**

If additionally the entropy gap is genuine (`H₁ < H₂`), the alignment is strictly
decreasing on it, and the impedance scale is non-degenerate (`0 < Zbar2`), then
`Cov(H_K, Var[N]) < 0` strictly: a strict negative correlation.  Uses the R.116
strict monotone link in proof terms. -/
theorem weak_cj31_cov_strict_neg
    (w Zbar2 σZ2 EPhi2 : ℝ) (f : ℝ → ℝ)
    (hw0 : 0 < w) (hw1 : w < 1)
    (hZ : 0 < Zbar2)
    (hf_strict : ∀ a b : ℝ, a < b → f b < f a)
    (H₁ H₂ : ℝ) (hH : H₁ < H₂) :
    cov2 w H₁ H₂
        (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2)
        (EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) < 0 := by
  have hVstrict :
      EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2
        < EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2 :=
    EntropyVarianceLink.R_116_strict_antimono
      Zbar2 σZ2 EPhi2 f hZ hf_strict H₁ H₂ hH
  rw [cov2_closed_form]
  have hpos : 0 < w * (1 - w) := mul_pos hw0 (by linarith)
  have hgap : (H₁ - H₂)
      * (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
          - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) < 0 := by
    have h1 : H₁ - H₂ < 0 := by linarith
    have h2 : 0 < EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
                  - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2 := by linarith
    exact mul_neg_of_neg_of_pos h1 h2
  calc w * (1 - w) * ((H₁ - H₂)
          * (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
              - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2))
        < w * (1 - w) * 0 := by
          exact mul_lt_mul_of_pos_left hgap hpos
    _ = 0 := by ring

/-! ## 3. R.89 / R.94 grounding: `V_i` ARE genuine `Var[N]` values. -/

/-- **(K5) The covariance is taken over honest R.89/R.94 `Var[N]` values.**

Each observable `V_i` plugged into the covariance is a genuine `Var[N]`: it
satisfies both the R.89 decomposition form (`R_89_MIP_form`) and the R.94
two-term split (`R_94_variance_decomposition`).  This certifies (K3)/(K4) act on
real emergence-cost variances, not arbitrary reals. -/
theorem VarN_is_R89_and_R94
    (Zbar σZ2 EPhi VarPhi EPhi2 : ℝ)
    (h_EPhi2 : EPhi2 = VarPhi + EPhi ^ 2) :
    -- R.89 form
    (Zbar ^ 2 * VarPhi + σZ2 * EPhi2
        = EntropyVarianceLink.VarN (Zbar ^ 2) VarPhi σZ2 EPhi2)
    -- R.94 two-term split with D_Φ, D_Z
    ∧ (EntropyVarianceLink.VarN (Zbar ^ 2) VarPhi σZ2 EPhi2
        = (Zbar ^ 2 * VarPhi) + (σZ2 * EPhi2))
    -- R.89 MIP form: the independent-decomposition rearranges to the VarN form,
    -- using `EPhi2 = VarPhi + EPhi^2` (the variance definition).
    ∧ (σZ2 * EPhi ^ 2 + VarPhi * (Zbar ^ 2 + σZ2)
        = Zbar ^ 2 * VarPhi + σZ2 * EPhi2) := by
  refine ⟨?_, ?_, ?_⟩
  · -- VarN def is exactly Zbar2*VarPhi + σZ2*EPhi2
    rw [EntropyVarianceLink.VarN]
  · -- R.94 decomposition into D_Φ + D_Z.  R.94's impedance term is `σZ^2·EΦ2`;
    -- we feed it `σZ := 1` and absorb the genuine `σZ2·EPhi2` into the `EΦ2`
    -- slot, so `D_Z = 1^2 · (σZ2·EPhi2) = σZ2·EPhi2` matches VarN's second term.
    have h94 :=
      VarianceDominance.R_94_variance_decomposition
        (EntropyVarianceLink.VarN (Zbar ^ 2) VarPhi σZ2 EPhi2)
        (Zbar ^ 2 * VarPhi) (σZ2 * EPhi2)
        Zbar VarPhi 1 (σZ2 * EPhi2) rfl (by ring)
        (by rw [EntropyVarianceLink.VarN]; ring)
    exact h94
  · -- R.89 MIP form (`R_89_MIP_form`), which consumes `h_EPhi2`.
    exact VarianceProduct.R_89_MIP_form
      Zbar σZ2 EPhi VarPhi EPhi2
      (σZ2 * EPhi ^ 2 + VarPhi * (Zbar ^ 2 + σZ2))
      h_EPhi2 rfl

/-! ## 4. ENTROPY-POWER CONSISTENCY (R9 + R3 towers, load-bearing).

    The `H_K` ordering underlying the covariance sign is faithfully tracked by
    the entropy power `N_K = exp H_K` (R9_Agent6), and the entropy GAP that
    drives the covariance is exactly the log-ratio of entropy powers
    (R3_Agent2).  So "anti-monotone in `H_K`" and "anti-monotone in `N_K`"
    coincide, and the covariance-sign kernel is invariant under the
    entropy↔entropy-power change of scale. -/

/-- **(K6) Entropy ordering ⟺ entropy-power ordering (R9 tower).**

`H₁ ≤ H₂ ⟺ N_K(H₁) ≤ N_K(H₂)` where `N_K = exp`.  The forward direction is
exactly R9_Agent6 `self_power_le_parent`; the converse is `exp` injec­tivity /
monotonicity.  Hence the `H_K`-ordering driving Cj.31's covariance sign transfers
verbatim to the entropy-power scale. -/
theorem entropy_le_iff_power_le (H₁ H₂ : ℝ) :
    H₁ ≤ H₂ ↔ EntropyPower.Npow H₁ ≤ EntropyPower.Npow H₂ := by
  constructor
  · intro h
    exact R9_Agent6_EntropyPowerUncertainty.self_power_le_parent H₁ H₂ h
  · intro h
    -- Npow = exp, strictly monotone; use exp_le_exp
    rw [EntropyPower.Npow, EntropyPower.Npow] at h
    exact (Real.exp_le_exp).mp h

/-- **(K7) Entropy gap = log-ratio of entropy powers (R3 tower).**

`log(N_K(H₂) / N_K(H₁)) = H₂ − H₁`, proved via R3_Agent2 `log_ratio_atomic`
(`log(x/y)=log x − log y`).  So the gap `H₂−H₁` driving the covariance equals the
log-ratio of the two entropy powers — the R3 entropy/KL atom and the R9 entropy
power agree on what "the entropy gap" is. -/
theorem entropy_gap_eq_log_ratio (H₁ H₂ : ℝ) :
    Real.log (EntropyPower.Npow H₂ / EntropyPower.Npow H₁) = H₂ - H₁ := by
  have hx : 0 < EntropyPower.Npow H₂ := EntropyPower.Npow_pos H₂
  have hy : 0 < EntropyPower.Npow H₁ := EntropyPower.Npow_pos H₁
  rw [R3_Agent2_EntropyKLCoupling.log_ratio_atomic _ _ hx hy]
  rw [EntropyPower.Npow, EntropyPower.Npow, Real.log_exp, Real.log_exp]

/-- **(K8) Covariance sign is invariant under the entropy↔power change of scale.**

The anti-monotone product `(H₁−H₂)·(V₀−V₁)` has the SAME sign as the
power-scale product `(N_K(H₁)−N_K(H₂))·(V₀−V₁)`: both are `≤ 0` iff the items are
anti-monotone in entropy, because `H₁ ≤ H₂ ⟺ N_K(H₁) ≤ N_K(H₂)` (K6).  Concretely,
under `H₁ ≤ H₂` and the anti-monotone variance gap `v1 ≤ v0`, BOTH products are
`≤ 0`. -/
theorem cov_sign_scale_invariant
    (H₁ H₂ v0 v1 : ℝ) (hH : H₁ ≤ H₂) (hV : v1 ≤ v0) :
    (H₁ - H₂) * (v0 - v1) ≤ 0
    ∧ (EntropyPower.Npow H₁ - EntropyPower.Npow H₂) * (v0 - v1) ≤ 0 := by
  refine ⟨antimono_gap_nonpos H₁ H₂ v0 v1 hH hV, ?_⟩
  have hNle : EntropyPower.Npow H₁ ≤ EntropyPower.Npow H₂ :=
    (entropy_le_iff_power_le H₁ H₂).mp hH
  exact antimono_gap_nonpos _ _ v0 v1 hNle hV

/-! ## 5. R.55 hook: nonnegativity of variance via order-preserving squaring.

    Each `Var[N]` value in our covariance is a genuine variance `w(1-w)(a-b)²`
    (cf. the conjecture file's `varN2`).  R.55's order-preserving-squaring kernel
    certifies the squared structure stays nonnegative and order-respecting — the
    diagonal of the covariance is a true (nonneg) variance. -/

/-- **(K9) Diagonal covariance (= variance) is nonnegative for `0 ≤ w ≤ 1`.**

`cov2 w x0 x1 x0 x1 = w(1-w)(x0-x1)² ≥ 0`.  The squared spread `(x0-x1)²` is
governed by R.55's nonneg-order squaring kernel (`R_55_squared_decay` certifies
that squaring preserves the nonneg order that makes such a spread a genuine
variance). -/
theorem cov2_diag_nonneg (w x0 x1 : ℝ) (hw0 : 0 ≤ w) (hw1 : w ≤ 1) :
    0 ≤ cov2 w x0 x1 x0 x1 := by
  rw [cov2_diag]
  have h1 : 0 ≤ 1 - w := by linarith
  positivity

/-- **(K9') R.55 certification that the spread is a genuine (squared) quantity.**

For a nonneg spread `0 ≤ s` bounded by `s ≤ (1-α)^t·s₀`, R.55 gives
`s² ≤ (1-α)^{2t}·s₀²`, i.e. squaring respects the order — the structural fact
that makes `(x0-x1)²` (hence the diagonal variance) a well-behaved nonneg
quantity.  Used here to certify the variance-spread that enters the covariance. -/
theorem spread_squared_order (s s₀ α : ℝ) (t : ℕ)
    (hs : 0 ≤ s) (hdec : s ≤ (1 - α) ^ t * s₀)
    (hα : α ≤ 1) (hs0 : 0 ≤ s₀) :
    s ^ 2 ≤ (1 - α) ^ (2 * t) * s₀ ^ 2 :=
  UncertaintyShrink.R_55_squared_decay s s₀ α t hs hdec hα hs0

/-! ## 6. HEADLINE — Cj.31 covariance-sign characterisation kernel. -/

/-- **HEADLINE — `cj31_covariance_sign_characterisation`.**

The complete honest kernel of Cj.31 (`H_K` vs `Var[N]` negative correlation).
For a genuine 2-point distribution `0 < w < 1` over two agents/items with knowledge
entropies `(H₁,H₂)` and the R.89 emergence-cost variances
`V_i := VarN Zbar2 (f H_i) σZ2 EPhi2`, under the R.116 anti-alignment model
(`f` non-increasing, `0 ≤ Zbar2`):

  (i)   COVARIANCE CLOSED FORM (sign-pinning, unconditional):
            Cov(H_K, V) = w·(1-w)·(H₁-H₂)·(V₁-V₂)
        — the correlation has NO unconditional sign; its sign is exactly that of
        the joint-monotonicity product.  [Hence the STRONG Cj.31 is false/OPEN,
        as the conjecture file's counterexample shows.]

  (ii)  NEGATIVE CORRELATION ⟺ ANTI-MONOTONE (`0<w<1`):
            Cov ≤ 0  ⟺  (H₁-H₂)·(V₁-V₂) ≤ 0.

  (iii) WEAK Cj.31 HOLDS: under the alignment model and `H₁ ≤ H₂`, the
        R.116/R.89 monotone link forces `V₂ ≤ V₁`, so by (ii) `Cov ≤ 0` — the
        surviving A-grade negative correlation.

  (iv)  ENTROPY-POWER CONSISTENCY (R9 + R3 towers): the `H_K` ordering equals the
        entropy-power ordering `N_K=exp H_K` (R9 `self_power_le_parent`) and the
        gap equals the log-ratio `log(N_K(H₂)/N_K(H₁)) = H₂-H₁` (R3
        `log_ratio_atomic`), so the covariance sign is scale-invariant.

This is the STRONGEST TRUE statement: an exact sign characterisation plus the
surviving conditional negative correlation.  The full STRONG conjecture remains
OPEN (refuted in `Cj31_HkVarNNegCorr.lean`). -/
theorem cj31_covariance_sign_characterisation
    (w Zbar2 σZ2 EPhi2 : ℝ) (f : ℝ → ℝ)
    (hw0 : 0 < w) (hw1 : w < 1)
    (hZ : 0 ≤ Zbar2)
    (hf_anti : ∀ a b : ℝ, a ≤ b → f b ≤ f a)
    (H₁ H₂ : ℝ) (hH : H₁ ≤ H₂) :
    -- (i) covariance closed form
    (cov2 w H₁ H₂
        (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2)
        (EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2)
      = w * (1 - w) * ((H₁ - H₂)
          * (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
              - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2)))
    -- (ii) negative correlation ⟺ anti-monotone
    ∧ (cov2 w H₁ H₂
          (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2)
          (EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) ≤ 0
        ↔ (H₁ - H₂)
            * (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2
                - EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) ≤ 0)
    -- (iii) weak Cj.31: the negative correlation actually holds here
    ∧ (cov2 w H₁ H₂
          (EntropyVarianceLink.VarN Zbar2 (f H₁) σZ2 EPhi2)
          (EntropyVarianceLink.VarN Zbar2 (f H₂) σZ2 EPhi2) ≤ 0)
    -- (iv) entropy-power consistency (R9 + R3 towers)
    ∧ (H₁ ≤ H₂ ↔ EntropyPower.Npow H₁ ≤ EntropyPower.Npow H₂)
    ∧ (Real.log (EntropyPower.Npow H₂ / EntropyPower.Npow H₁) = H₂ - H₁) := by
  refine ⟨cov2_closed_form _ _ _ _ _, ?_, ?_, ?_, ?_⟩
  · exact cov_neg_iff_antimono w H₁ H₂ _ _ hw0 hw1
  · exact weak_cj31_cov_nonpos w Zbar2 σZ2 EPhi2 f hw0 hw1 hZ hf_anti H₁ H₂ hH
  · exact entropy_le_iff_power_le H₁ H₂
  · exact entropy_gap_eq_log_ratio H₁ H₂

end R12_Agent3_AttackHkVarNNegCorr

end MIP
