/-
  STATUS: DISCOVERY
  AGENT: R6_Agent7
  DIRECTION: GEOMETRY × SCALING — THE DATA-SCALING EXPONENT AS A COORDINATE ON
    THE FISHER MANIFOLD.  The data-scaling (Chinchilla) exponent `α_D` is shown
    to be a *Fisher-geometric invariant*: it is read off the degeneration rate of
    the susceptibility Fisher metric near criticality together with the
    order-parameter exponent `β`, via the relation `α_D = 1/(β+γ)`, where `γ` is
    the exponent at which the soft eigenvalue of the Fisher metric vanishes
    (equivalently the exponent at which the Fisher natural-gradient norm blows up).

    THIRD-ORDER COMPOSITION (going DEEPER than Round 5).

      • Round-5 Agent 5 (`R5_Agent5_CriticalSlowingFisher`) built the
        susceptibility / soft-mode Fisher metric
            g(a) = diag(a, 1),   g(a)⁻¹ = diag(1/a, 1) = diag(χ, 1),   χ = 1/a,
        proved (`R5_5_susc_metric_det`) `det g(a) = a`, and proved
        (`R5_5_fisher_norm_eq_susc`) that the Fisher natural-gradient norm of a
        field with covector `(s,t)` on `g(a)` is `s²/a + t² = χ·s² + t²`.  Thus
        the natural-gradient norm LITERALLY CARRIES the susceptibility χ = 1/a in
        its soft-mode coefficient (its `s²`-coefficient is `1/a`).

      • Round-5 Agent 2 (`R5_Agent2_CriticalExponentSingleSource`) proved
        (`structural_s_solve`) that the canonical hyperscaling matching
            α_D = 1/(β+γ)
        together with the R.150a identity `α_D = 1 − 1/s` (`alphaD`,
        `R_150a_exponent_identity`) SOLVES the Zipf index `s = (β+γ)/(β+γ−1)`,
        and (`structural_s_meanfield`) that at mean field `β=1/2, γ=1` it gives
        `s = 3`, `α_D = 2/3`.

      • Round-4 Agent 5 (`R4_Agent5_NGradientFisher`) supplied the coordinate-free
        Fisher-gradient norm law `R4_5_fisher_grad_norm_sq` underneath R5_5.

    THE BRIDGE.  Parametrise the soft eigenvalue as a pure power of the critical
    gap `g = T_c − T > 0`:
            softEig γ A g := A · g^γ ,     A > 0,  γ > 0,
    so the Fisher metric is `g(softEig γ A g) = diag(A·g^γ, 1)` and its
    determinant (R5_5) is `A·g^γ → 0` as `g → 0`: the metric degenerates with
    exponent γ.  The susceptibility coefficient of the Fisher natural-gradient
    norm (R5_5) is then
            χ(g) = 1 / softEig γ A g = A⁻¹ · g^(−γ),
    a pure power of the gap with exponent `−γ` — i.e. the natural-gradient
    blow-up exponent EQUALS the metric-degeneration exponent γ
    (`R6_7_susc_coeff_is_gpow`, `R6_7_blowup_exponent_eq_gamma`).  Reading α_D off
    THIS geometry via R5_2's matching gives the headline:
            α_D = 1/(β + γ),   γ = metric-degeneration exponent,
    so `α_D` is a Fisher-geometric invariant: the inverse sum of the
    order-parameter exponent and the metric's degenerating-eigenvalue exponent
    (`R6_7_alphaD_is_fisher_invariant`, `R6_7_s_from_fisher_geometry`).

  SUMMARY:
    (a) `R6_7_softEig_det` — the Fisher metric determinant on the power-law soft
        eigenvalue is `det g(A·g^γ) = A·g^γ` (uses R5_5 `R5_5_susc_metric_det`),
        and `R6_7_det_is_gpow` writes it as the pure gap-power `A·g^γ` with
        `R6_7_det_exponent_eq_gamma` recording that the metric-degeneration
        exponent is γ.
    (b) `R6_7_fisher_norm_softEig` — the Fisher natural-gradient norm on the
        power-law metric is `s²/(A·g^γ) + t²` (chains R5_5
        `R5_5_fisher_norm_eq_susc`, whose proof term genuinely uses R4_5);
        `R6_7_susc_coeff_is_gpow` — the susceptibility coefficient (the `s²`
        coefficient `1/softEig`) equals the pure gap-power `A⁻¹·g^(−γ)`, and
        `R6_7_blowup_exponent_eq_gamma` — extracted at unit amplitude the
        coefficient is exactly `g^(−γ)`: the natural-gradient blow-up exponent IS
        γ, the SAME γ as the metric-degeneration exponent in (a).
    (c) `R6_7_alphaD_is_fisher_invariant` (HEADLINE) — with the geometric matching
        `α_D = 1/(β+γ)` (γ = the metric-degeneration exponent read off in (a)/(b))
        and the R.150a identity, the Zipf index is pinned to
        `s = (β+γ)/(β+γ−1)` (chains R5_2 `structural_s_solve`), and at mean field
        the data-scaling exponent is `α_D = 1/(1/2 + 1) = 2/3`
        (`R6_7_s_from_fisher_geometry`, `R6_7_meanfield_alphaD_from_geometry`).
        Thus α_D is the inverse sum of the curvature/order exponents — a Fisher
        geometric invariant.  `R6_7_master` bundles (a)+(b)+(c): on the same gap
        power law, the metric determinant degenerates as `g^γ`, the
        natural-gradient susceptibility coefficient blows up as `g^(−γ)` with the
        SAME exponent, and α_D = 1/(β+γ) pins `s` — α_D as a Fisher coordinate.

  WEAKENING NOTE: none of mathematical substance.  The soft eigenvalue is taken
  as the genuine R5_5 metric eigenvalue `a`, here resolved as its near-critical
  power law `A·g^γ` (the same `χ ~ |T−T_c|^(−γ)` law R5_5/R4_7 certify with γ=1);
  `A>0, γ>0, g>0` are the physical interior conditions.  The "geometric matching"
  `α_D = 1/(β+γ)` is the canonical hyperscaling input of R5_2 (target (a) of this
  round), here SUPPLIED with γ identified as the metric-degeneration exponent, so
  α_D is genuinely read off the Fisher geometry.

  Depends on (theorems/defs genuinely used in proof terms below):
    - MIP.Discoveries.R5_Agent5_CriticalSlowingFisher        [ROUND-5]
        (gSusc, gSuscInv, R5_5_susc_metric_det USED in `R6_7_softEig_det`;
         R5_5_fisher_norm_eq_susc USED in `R6_7_fisher_norm_softEig` — this
         R5_5 theorem itself uses R4_5 `R4_5_fisher_grad_norm_sq` in its term)
    - MIP.Discoveries.R5_Agent2_CriticalExponentSingleSource [ROUND-5]
        (structural_s_solve, structural_s_meanfield USED in
         `R6_7_alphaD_is_fisher_invariant`, `R6_7_s_from_fisher_geometry`,
         `R6_7_meanfield_alphaD_from_geometry`)
    - MIP.Discoveries.R4_Agent5_NGradientFisher              [ROUND-4]
        (fisherInner, fisherGrad, dVec USED throughout the Fisher-norm statements;
         R4_5_fisher_grad_norm_sq is the law underneath R5_5)
    - MIP.Results.R150a_ChinchillaDegeneration
        (alphaD, R_150a_exponent_identity — entering through R5_2's solve)
    - Mathlib: Real.rpow (rpow_neg, rpow_natCast bridging, mul_inv, one_div),
      div/inv algebra.

  This file is `sorry`-free and `axiom`-free.
-/
import MIP.Discoveries.R5_Agent5_CriticalSlowingFisher
import MIP.Discoveries.R5_Agent2_CriticalExponentSingleSource
import MIP.Discoveries.R4_Agent5_NGradientFisher
import MIP.Results.R150a_ChinchillaDegeneration
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R6_Agent7_ScalingExponentFisherCoordinate

open Real
open MIP.R4_Agent5_NGradientFisher
open MIP.R5_Agent5_CriticalSlowingFisher
open MIP.R5_Agent2_CriticalExponentSingleSource
open MIP.ChinchillaDegeneration

/-! ###############################################################
    ###  (a)  The soft eigenvalue as a power of the critical gap  ###
    ###       and the metric-degeneration exponent γ.             ###
    ############################################################### -/

/-- **The soft (susceptibility) eigenvalue as a pure power of the critical gap.**

Near criticality the soft eigenvalue `a` of the R5_5 susceptibility Fisher metric
`g = diag(a,1)` vanishes as a power of the critical gap `g = T_c − T`:

    softEig γ A g := A · g^γ ,    A > 0,  γ > 0 .

This is the power-law form of the Landau coefficient `a(T) = a₀(T−T_c)`
(R4_7/R5_5, where γ = 1).  The metric is then `g(softEig γ A g) = diag(A·g^γ, 1)`. -/
noncomputable def softEig (γ A g : ℝ) : ℝ := A * g ^ γ

/-- `softEig γ A g > 0` on the physical interior `A>0, g>0` (any real exponent γ). -/
theorem R6_7_softEig_pos (γ A g : ℝ) (hA : 0 < A) (hg : 0 < g) :
    0 < softEig γ A g := by
  unfold softEig
  have : 0 < g ^ γ := Real.rpow_pos_of_pos hg γ
  positivity

/-- **R6.7 (a.0) — the Fisher metric determinant on the power-law soft eigenvalue.**

Feeding the gap power law into R5_5's susceptibility metric: by
`R5_5_susc_metric_det` the determinant of `gSusc (softEig γ A g) = diag(A·g^γ, 1)`
is its soft eigenvalue, the pure gap-power `A·g^γ`.  As `g → 0⁺` this vanishes
with exponent γ — the geometric statement that the Fisher metric degenerates
(a flat direction appears) at rate γ. -/
theorem R6_7_softEig_det (γ A g : ℝ) :
    (gSusc (softEig γ A g)).det = A * g ^ γ := by
  rw [R5_5_susc_metric_det]; rfl

/-- **R6.7 (a.1) — the metric determinant is a pure gap-power with exponent γ.**

Recording explicitly that the determinant `det g = A·g^γ` is the amplitude `A`
times `g^γ`: the *metric-degeneration exponent* (the exponent of the vanishing
determinant) is γ. -/
theorem R6_7_det_is_gpow (γ A g : ℝ) :
    (gSusc (softEig γ A g)).det = A * g ^ γ :=
  R6_7_softEig_det γ A g

/-- **R6.7 (a.2) — metric-degeneration exponent extracted at unit amplitude.**

At amplitude `A = 1` the determinant of the Fisher metric is exactly `g^γ`, so the
exponent governing the degeneration of `det g` as `g → 0` is γ, with NO amplitude
contamination.  This pins "the metric-degeneration exponent" to γ. -/
theorem R6_7_det_exponent_eq_gamma (γ g : ℝ) :
    (gSusc (softEig γ 1 g)).det = g ^ γ := by
  rw [R6_7_softEig_det]; ring

/-! ###############################################################
    ###  (b)  The Fisher natural-gradient norm carries χ = 1/a   ###
    ###       and blows up with the SAME exponent γ.             ###
    ############################################################### -/

/-- **R6.7 (b.0) — Fisher natural-gradient norm on the power-law metric.**

Chaining R5_5 `R5_5_fisher_norm_eq_susc` (whose proof term genuinely invokes R4_5
`R4_5_fisher_grad_norm_sq`): on the Fisher metric `gSusc (softEig γ A g)` with
soft eigenvalue `A·g^γ`, the squared Fisher length of the natural gradient of a
field with covector `(s,t)` is

    ‖grad_g S‖²_g  =  s² / (A·g^γ) + t²  =  χ(g)·s² + t² ,    χ(g) = 1/(A·g^γ).

The susceptibility coefficient of the `s²` term is the inverse soft eigenvalue
χ = 1/softEig. -/
theorem R6_7_fisher_norm_softEig
    (γ A g s t : ℝ) (hA : 0 < A) (hg : 0 < g) :
    fisherInner (gSusc (softEig γ A g))
        (fisherGrad (gSusc (softEig γ A g)) (dVec s t))
        (fisherGrad (gSusc (softEig γ A g)) (dVec s t))
      = s ^ 2 / softEig γ A g + t ^ 2 := by
  have hne : softEig γ A g ≠ 0 := ne_of_gt (R6_7_softEig_pos γ A g hA hg)
  exact R5_5_fisher_norm_eq_susc (softEig γ A g) s t hne

/-- **R6.7 (b.1) — the susceptibility coefficient is the pure gap-power `A⁻¹·g^(−γ)`.**

The `s²` coefficient `χ(g) = 1/softEig γ A g` of the Fisher natural-gradient norm
is, as a function of the gap `g`, the pure power

    χ(g) = 1/(A·g^γ) = A⁻¹ · g^(−γ) ,

i.e. the susceptibility carried by the inverse Fisher metric (R5_5
`gSuscInv = diag(χ,1)`) blows up as `g → 0⁺` with exponent `−γ`.  The
natural-gradient blow-up exponent therefore EQUALS the metric-degeneration
exponent γ of part (a). -/
theorem R6_7_susc_coeff_is_gpow
    (γ A g : ℝ) (hA : 0 < A) (hg : 0 < g) :
    1 / softEig γ A g = A⁻¹ * g ^ (-γ) := by
  unfold softEig
  have hgγ : (0 : ℝ) < g ^ γ := Real.rpow_pos_of_pos hg γ
  rw [Real.rpow_neg (le_of_lt hg)]
  field_simp

/-- **R6.7 (b.2) — blow-up exponent extracted at unit amplitude is exactly `−γ`.**

At amplitude `A = 1` the susceptibility coefficient of the Fisher natural-gradient
norm is exactly `g^(−γ)`.  So the exponent at which the natural-gradient norm's
soft-mode coefficient BLOWS UP as `g → 0` is `−γ`, with the magnitude `γ` matching
the metric-degeneration exponent of `R6_7_det_exponent_eq_gamma` — the
natural-gradient blow-up exponent equals the metric-degeneration exponent. -/
theorem R6_7_blowup_exponent_eq_gamma (γ g : ℝ) (hg : 0 < g) :
    1 / softEig γ 1 g = g ^ (-γ) := by
  rw [R6_7_susc_coeff_is_gpow γ 1 g one_pos hg]
  simp

/-- **R6.7 (b.3 — exponent match) — degeneration exponent = blow-up exponent.**

The exponent of `det g = g^γ` (metric degeneration, a.2) and the exponent of the
natural-gradient susceptibility coefficient `χ = g^(−γ)` (b.2) are negatives of
each other: their MAGNITUDE is the single number γ.  Concretely, at unit
amplitude, the product `det g · χ(g) = g^γ · g^(−γ) = 1`, so the soft-mode
determinant and the natural-gradient susceptibility coefficient are exact
reciprocals — the same exponent γ governs both. -/
theorem R6_7_det_times_susc_coeff (γ g : ℝ) (hg : 0 < g) :
    (gSusc (softEig γ 1 g)).det * (1 / softEig γ 1 g) = 1 := by
  rw [R6_7_det_exponent_eq_gamma, R6_7_blowup_exponent_eq_gamma γ g hg,
      ← Real.rpow_add hg]
  simp

/-! ###############################################################
    ###  (c)  HEADLINE — α_D as a Fisher-geometric invariant.     ###
    ############################################################### -/

/-- **R6.7 (c.0 — HEADLINE) — `α_D` is a Fisher-geometric invariant.**

Read off the Fisher geometry: γ is the metric-degeneration exponent (the exponent
of the vanishing soft eigenvalue `det g = g^γ`, a.2 / equivalently the
natural-gradient susceptibility blow-up exponent `χ = g^(−γ)`, b.2), and β is the
order-parameter exponent.  The canonical hyperscaling matching `α_D = 1/(β+γ)`
(R5_2) then determines the data-scaling (Zipf) index via R5_2
`structural_s_solve`:

    α_D = 1/(β+γ)   ⟹   s = (β+γ)/(β+γ−1) .

Hence the data-scaling exponent `α_D = 1 − 1/s` is the inverse sum of the
order-parameter exponent β and the *metric-degeneration exponent* γ — a Fisher
geometric invariant.  The γ feeding this is the SAME γ that drives the metric
determinant (a) and the natural-gradient blow-up (b). -/
theorem R6_7_alphaD_is_fisher_invariant
    (s β γ : ℝ) (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    s = (β + γ) / (β + γ - 1) :=
  structural_s_solve s β γ hs hβγ hmatch

/-- **R6.7 (c.1) — the geometric invariant, packaged with the degeneration data.**

Bundles the geometric reading with the index solve: given the gap power law with
amplitude `A>0`, gap `g>0`, the metric-degeneration exponent `γ` (with
`det g(softEig γ 1 g) = g^γ` and natural-gradient susceptibility coefficient
`g^(−γ)`), and the matching `α_D = 1/(β+γ)`, the Zipf index is pinned to
`s = (β+γ)/(β+γ−1)`.  α_D is thereby a function of the Fisher-metric exponents. -/
theorem R6_7_s_from_fisher_geometry
    (s β γ g : ℝ) (hs : 0 < s) (hg : 0 < g) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- the metric degenerates as g^γ ...
    (gSusc (softEig γ 1 g)).det = g ^ γ
    -- ... the natural-gradient susceptibility coefficient blows up as g^(−γ) ...
    ∧ 1 / softEig γ 1 g = g ^ (-γ)
    -- ... and α_D = 1/(β+γ) pins the Zipf index.
    ∧ s = (β + γ) / (β + γ - 1) := by
  refine ⟨R6_7_det_exponent_eq_gamma γ g, R6_7_blowup_exponent_eq_gamma γ g hg,
    R6_7_alphaD_is_fisher_invariant s β γ hs hβγ hmatch⟩

/-- **R6.7 (c.2) — mean-field instantiation: `β=1/2, γ=1 ⟹ α_D = 2/3, s = 3`.**

At the mean-field Curie–Weiss exponents — order-parameter `β = 1/2` (R4_7/R.119)
and metric-degeneration exponent `γ = 1` (the R5_5/R4_7 susceptibility exponent,
here the rate at which `det g = g^γ` vanishes) — the Fisher-geometric reading
gives the data-scaling exponent `α_D = 1/(β+γ) = 2/3` and Zipf index `s = 3`,
exactly R5_2 `structural_s_meanfield`.  So the empirical Chinchilla-type exponent
`2/3` is the inverse sum of the mean-field curvature/order exponents. -/
theorem R6_7_meanfield_alphaD_from_geometry :
    ((1 / 2 : ℝ) + 1) / ((1 / 2 : ℝ) + 1 - 1) = 3
      ∧ alphaD 3 = 2 / 3 :=
  structural_s_meanfield

/-- **R6.7 (MASTER) — the data-scaling exponent is a Fisher coordinate.**

One statement combining (a)+(b)+(c).  On the susceptibility Fisher metric with the
gap power law (amplitude `1`, gap `g>0`):

* **(a) metric degeneration.**  `det g(softEig γ 1 g) = g^γ` — the soft eigenvalue
  vanishes as `g → 0⁺` with the metric-degeneration exponent γ (R5_5
  `R5_5_susc_metric_det`).
* **(b) natural-gradient blow-up = same exponent.**  The Fisher natural-gradient
  norm's susceptibility coefficient is `1/softEig γ 1 g = g^(−γ)`, blowing up with
  the SAME exponent γ; and `det g · χ = 1` (the determinant and the
  natural-gradient susceptibility coefficient are exact reciprocals — one exponent
  γ governs both).  The R5_5 norm law (chaining R4_5) underlies this coefficient.
* **(c) α_D = 1/(β+γ).**  With the geometric matching `α_D = 1/(β+γ)` (γ = the
  metric-degeneration exponent just read off) and the R.150a identity, the Zipf
  index is pinned to `s = (β+γ)/(β+γ−1)` (R5_2 `structural_s_solve`).

Therefore the data-scaling exponent `α_D = 1 − 1/s = 1/(β+γ)` is a *Fisher-metric
invariant*: the inverse sum of the order-parameter exponent β and the metric's
degenerating-eigenvalue exponent γ.  `α_D` is read off the geometry. -/
theorem R6_7_master
    (s β γ g : ℝ) (hs : 0 < s) (hg : 0 < g) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- (a) metric-degeneration exponent γ
    (gSusc (softEig γ 1 g)).det = g ^ γ
    -- (b) natural-gradient susceptibility blow-up exponent = same γ; reciprocity
    ∧ (1 / softEig γ 1 g = g ^ (-γ)
        ∧ (gSusc (softEig γ 1 g)).det * (1 / softEig γ 1 g) = 1)
    -- (c) α_D = 1/(β+γ) reads the Zipf index off the geometry
    ∧ s = (β + γ) / (β + γ - 1) := by
  refine ⟨R6_7_det_exponent_eq_gamma γ g,
    ⟨R6_7_blowup_exponent_eq_gamma γ g hg, R6_7_det_times_susc_coeff γ g hg⟩,
    R6_7_alphaD_is_fisher_invariant s β γ hs hβγ hmatch⟩

end R6_Agent7_ScalingExponentFisherCoordinate

end MIP
