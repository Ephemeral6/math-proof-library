/-
Result R.95 (T.21) — MIP-internal scaling law (Heaps growth + κ-saturation
⟹ power-law decay of N in the data budget D).

Reference: `workspace/new_results.md` R.95 (T.21, B 级 — the algebraic
core is A-level; the Heaps and κ-saturation forms are bundled hypotheses).
Fifth batch.

**Statement interpretation used.**  Under the three bundled hypotheses
(all entering as explicit assumptions):

* **(a) Heaps law**            `|K(D)| = c_K · D^β`,  `β ∈ (0,1)`,
* **(b) κ-saturation**         `1 − κ(D) = c_κ · D^(−γκ)`,  `γκ > 0`,
* **(c) Z slowly varying**     `Z(D) → Zinf`,

R.95 derives, in the post-coverage asymptotic regime, the closed-form

    N(D)  =  c_N · D^(−γκ),    with   c_N := (r − 1) · c_κ · Zinf,

where the chain is
`Φ₀(D) ≈ (r−1)·|log κ(D)|`, `|log κ(D)| ≈ c_κ·D^(−γκ)` (first-order
Taylor of `−log(1 − x)`), and `N(D) ≈ Φ₀(D)·Zinf` (T.8 uniform-Z).

This file formalizes the **exact algebraic closed-form** by carrying the
linearized terms as explicit hypotheses (the Taylor step
`|log κ(D)| = c_κ·D^(−γκ)` and the Ohm step `N = Φ₀·Zinf` are taken as the
*stated* regime equalities, matching R.95's "渐近域内" derivation), and
proves:

* the **closed-form identity** `N(D) = c_N · D^(−γκ)` with
  `c_N = (r−1)·c_κ·Zinf`;
* the **Φ₀ linearization** step;
* the **coverage threshold** `D_cov` solving `c_K·D^β = r`, i.e.
  `D_cov = (r / c_K)^(1/β)` (`Real.rpow`), verifying `|K(D_cov)| = r`;
* the **power-law signature**: the log-log slope is exactly `−γκ`
  (`log N(D) = log c_N − γκ · log D`), the empirical scaling exponent;
* **monotone decay**: for `γκ > 0` and `c_N > 0`, `N` is strictly
  decreasing in `D` on `D > 0`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace ScalingLaw

open Real

/-- **R.95 (T.21) — scaling-law closed form.**

In the post-coverage asymptotic regime, with `Φ₀(D)` linearized to
`(r − 1)·c_κ·D^(−γκ)` (Heaps + κ-saturation + Taylor) and `N = Φ₀·Zinf`
(T.8 uniform impedance), the emergence cost obeys the power law

    N(D)  =  c_N · D^(−γκ),    c_N = (r − 1) · c_κ · Zinf .

Pure substitution of the bundled regime equalities. -/
theorem R_95_scaling_closed_form
    (N Φ₀ D r cκ Zinf γκ c_N : ℝ)
    (h_Φ₀ : Φ₀ = (r - 1) * (cκ * D ^ (-γκ)))
    (h_ohm : N = Φ₀ * Zinf)
    (h_cN : c_N = (r - 1) * cκ * Zinf) :
    N = c_N * D ^ (-γκ) := by
  rw [h_ohm, h_Φ₀, h_cN]; ring

/-- **R.95 — Φ₀ linearization (Taylor step made explicit).**

If `|log κ(D)| = c_κ·D^(−γκ)` (first-order Taylor of `−log(1 − x)` for
the small gap `x = c_κ·D^(−γκ)`), and `Φ₀(D) = (r − 1)·|log κ(D)|`
(R.61s asymptotic), then `Φ₀(D) = (r − 1)·c_κ·D^(−γκ)`. -/
theorem R_95_phi0_linearization
    (Φ₀ logκ_abs D r cκ γκ : ℝ)
    (h_taylor : logκ_abs = cκ * D ^ (-γκ))
    (h_R61s : Φ₀ = (r - 1) * logκ_abs) :
    Φ₀ = (r - 1) * (cκ * D ^ (-γκ)) := by
  rw [h_R61s, h_taylor]

/-- **R.95 — coverage threshold `D_cov` solves the Heaps equation.**

With `|K(D)| = c_K · D^β` (Heaps), the coverage condition `|K(D)| = r`
is met at `D_cov = (r / c_K)^(1/β)`.  We verify `c_K · D_cov^β = r`
(`Real.rpow`), for `c_K > 0`, `r ≥ 0`, `β ≠ 0`. -/
theorem R_95_coverage_threshold
    (cK r β : ℝ) (h_cK : 0 < cK) (h_r : 0 ≤ r) (h_β : β ≠ 0) :
    cK * ((r / cK) ^ (1 / β)) ^ β = r := by
  have h_rc_nonneg : 0 ≤ r / cK := div_nonneg h_r (le_of_lt h_cK)
  rw [← rpow_mul h_rc_nonneg, one_div, inv_mul_cancel₀ h_β, rpow_one]
  field_simp

/-- **R.95 — power-law signature (log-log slope = `−γκ`).**

The closed form `N(D) = c_N·D^(−γκ)` has the log-log relation

    log N(D)  =  log c_N  −  γκ · log D ,

i.e. a straight line of slope `−γκ` — the empirically observed scaling
exponent `α ↔ γκ`. -/
theorem R_95_loglog_slope
    (N c_N D γκ : ℝ) (hD : 0 < D) (h_cN : 0 < c_N)
    (hN : N = c_N * D ^ (-γκ)) :
    Real.log N = Real.log c_N - γκ * Real.log D := by
  rw [hN, Real.log_mul (ne_of_gt h_cN) (by positivity), Real.log_rpow hD]
  ring

/-- **R.95 — monotone decay in the data budget.**

For `γκ > 0` and `c_N > 0`, `N(D) = c_N·D^(−γκ)` is strictly decreasing
in `D` on `D > 0`: more data ⟹ smaller emergence cost. -/
theorem R_95_monotone_decay
    (c_N γκ D₁ D₂ : ℝ) (h_cN : 0 < c_N) (h_γ : 0 < γκ)
    (h_D₁ : 0 < D₁) (h_lt : D₁ < D₂) :
    c_N * D₂ ^ (-γκ) < c_N * D₁ ^ (-γκ) := by
  apply mul_lt_mul_of_pos_left _ h_cN
  exact Real.rpow_lt_rpow_of_neg h_D₁ h_lt (by linarith)

end ScalingLaw

end MIP
