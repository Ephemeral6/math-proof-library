/-
Result R.201 — Z⁻¹-dimension Fisher metric.
Reference: branches/geometry/workspace/new_results.md (old geom R.125).

**Statement.** Treat the AI as a statistical model with scalar parameter
`ζ = Z⁻¹` and observable `N`.  By the emergent Ohm law (T.8)
`E_P[N | ζ] = Φ̄ / ζ`, so `∂E[N]/∂ζ = −Φ̄/ζ²`.  By the variance decomposition
(R.89) `Var[N | ζ] = Var[Φ₀]/ζ² + σ_Z²·E[Φ₀²]`.  The Cramér–Rao Fisher
information about `ζ` is

    F(ζ) = (∂E[N]/∂ζ)² / Var[N|ζ]
         = Φ̄² / (ζ²·Var[Φ₀] + ζ⁴·σ_Z²·E[Φ₀²]).

In the clean-Ohm limit (σ_Z = 0, R.90) this collapses to the metric component

    g_ζζ(ζ) = β / ζ²,     β := Φ̄² / Var[Φ₀]  (signal-to-noise of Φ₀).

In the log-coordinate `v = log ζ` (so `dζ = ζ·dv`) the line element pulls back
to the constant `g_vv = β`, mirroring the κ-dimension duality (R.106:
`1/(α·κ²)` with log-coordinate constant `1/α`).

**Kernel formalized here.**
* (a) the general Cramér–Rao Fisher value
  `F(ζ) = Φ̄² / (ζ²·Var[Φ₀] + ζ⁴·σ_Z²·E[Φ₀²])` from the bundled
  `∂E[N]/∂ζ = −Φ̄/ζ²` and `Var[N|ζ] = Var[Φ₀]/ζ² + σ_Z²·E[Φ₀²]`;
* (b) the clean-Ohm reduction `F(ζ)|_{σ_Z=0} = β/ζ²` with `β = Φ̄²/Var[Φ₀]`;
* (c) the log-coordinate pullback `g_ζζ·(ζ·dv)² = β·dv²` (constant `g_vv = β`);
* (d) positivity of `g_ζζ` on the interior `ζ > 0`, `β > 0`.

**Bridge.** The Fisher-information / Cramér–Rao geometry of the (T.8, R.89,
R.90) statistical model enters only through the bundled mean-derivative and
variance shapes; everything below is the resulting real-algebra identity.

Axiom-free (no A.1–A.4 used; Mathlib only).
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace R201_ZInvFisherMetric

open Real

/-- The clean-Ohm `Z⁻¹`-dimension Fisher metric component `g_ζζ(ζ) = β / ζ²`,
with `β` the signal-to-noise ratio `Φ̄²/Var[Φ₀]` of the problem distribution. -/
noncomputable def gMetric (β ζ : ℝ) : ℝ := β / ζ ^ 2

/-- **R.201 (a) — Cramér–Rao Fisher information about `ζ = Z⁻¹`.**

With the emergent-Ohm mean derivative `∂E[N]/∂ζ = −Φ̄/ζ²` (premise `hMean`)
and the R.89 conditional variance `Var[N|ζ] = Var[Φ₀]/ζ² + σ_Z²·E[Φ₀²]`
(premise `hVar`, with value `varN`), the Fisher information
`F(ζ) = (∂E[N]/∂ζ)² / Var[N|ζ]` equals

    Φ̄² / (ζ²·Var[Φ₀] + ζ⁴·σ_Z²·E[Φ₀²]).

The denominator is nonzero on the interior (`hden`). -/
theorem R_201_a_fisher_value
    (ζ Φbar varPhi σZ EPhi2 dMean varN : ℝ)
    (hζ : ζ ≠ 0)
    (hMean : dMean = -Φbar / ζ ^ 2)
    (hVar : varN = varPhi / ζ ^ 2 + σZ ^ 2 * EPhi2)
    (hvarN : varN ≠ 0)
    (hden : ζ ^ 2 * varPhi + ζ ^ 4 * (σZ ^ 2 * EPhi2) ≠ 0) :
    dMean ^ 2 / varN
      = Φbar ^ 2 / (ζ ^ 2 * varPhi + ζ ^ 4 * (σZ ^ 2 * EPhi2)) := by
  subst hMean hVar
  rw [div_eq_div_iff hvarN hden]
  field_simp

/-- **R.201 (b) — clean-Ohm reduction `F(ζ) = β/ζ²`.**

In the σ_Z = 0 regime (R.90, strict Ohm) the variance is `Var[Φ₀]/ζ²`, so the
Fisher information reduces to `Φ̄²/(ζ²·Var[Φ₀]) = β/ζ²` with the
signal-to-noise ratio `β = Φ̄²/Var[Φ₀]` (premise `hβ`).  This is the
`Z⁻¹`-dimension Fisher metric component `g_ζζ`. -/
theorem R_201_b_clean_ohm
    (ζ Φbar varPhi β dMean varN : ℝ)
    (hζ : ζ ≠ 0) (hvarPhi : varPhi ≠ 0)
    (hMean : dMean = -Φbar / ζ ^ 2)
    (hVar : varN = varPhi / ζ ^ 2)          -- σ_Z = 0
    (hβ : β = Φbar ^ 2 / varPhi) :
    dMean ^ 2 / varN = gMetric β ζ := by
  subst hMean hVar hβ
  unfold gMetric
  rw [div_eq_div_iff (by positivity) (by positivity)]
  field_simp

/-- **R.201 (c) — log-coordinate pullback is the constant `β`.**

Under `v = log ζ` (so `dζ = ζ·dv`, premise `hdζ`), the line element
`g_ζζ·dζ²` becomes `(β/ζ²)·(ζ·dv)² = β·dv²`: the transformed metric
coefficient `g_vv = β` is **constant**, independent of `ζ`.  This is the
`Z⁻¹` analogue of the κ-dimension `g_uu = 1/α` (R.106). -/
theorem R_201_c_log_coord_constant
    (β ζ dζ dv : ℝ) (hζ : ζ ≠ 0)
    (hdζ : dζ = ζ * dv) :
    gMetric β ζ * dζ ^ 2 = β * dv ^ 2 := by
  unfold gMetric
  rw [hdζ]
  field_simp

/-- **R.201 (d) — metric positivity / well-posedness.**

On the interior `ζ > 0` with positive signal-to-noise `β > 0`, the Fisher
metric component `g_ζζ = β/ζ²` is strictly positive, so it is a genuine
(positive-definite) Riemannian metric in the `Z⁻¹` direction. -/
theorem R_201_d_metric_pos (β ζ : ℝ) (hβ : 0 < β) (hζ : 0 < ζ) :
    0 < gMetric β ζ := by
  unfold gMetric
  positivity

end R201_ZInvFisherMetric

end MIP
