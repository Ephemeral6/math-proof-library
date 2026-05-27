/-
Result R.531 — Pinsker-type bound for the Cj.55 weak version
(slot 029, Cj.55.B — bounded-metric Wasserstein vs KL residual).

Reference: `workspace/round3_exploration/slot_029.md` (R.531) and
`workspace/round3_exploration/work_slot_029.md` §4.3 (L.55.3, Cj.55.B 弱版本,
B 条件).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement.**  The crisp analytic core is **Pinsker's inequality** for
total variation against Kullback–Leibler divergence,

    ‖p − q‖_TV  ≤  sqrt(KL(p ‖ q) / 2).

Mathlib (v4.30.0-rc2) does not ship a directly reusable real-valued
discrete Pinsker bound in the form needed here, so — per the project
HYPOTHESIS-BUNDLE convention — Pinsker is entered as the analytic
hypothesis `hPinsker`, and the **MIP application** it implies is derived:
for a bounded ground metric `d ≤ D` on `supp(μ_A) ∪ supp(μ_H)`, the
classical bound `W_1^d ≤ D · d_TV` (`hWTV`) chains with Pinsker to give

    W_1^d(μ_A, μ_H)  ≤  D · sqrt(KL(μ_H ‖ μ_A) / 2).

This is the Cj.55.B weak-version bridge.  Because the **residual KL term**
of the source (`KL_res`, the un-pinned part of `KL(μ_H ‖ μ_A)` after the
R.144 chain rule peels off `Φ_0`) is genuinely *unpinned* in the MIP
axioms, we keep the clean Pinsker-form bound with `KL` (or the residual)
bundled and document the gap, rather than asserting the unverified
`Asym ≥ …` lower bound of R.531's full statement.

**Bundled facts (entered as explicit hypotheses).**

* **(Pinsker)** `dTV ≤ sqrt(KL / 2)`  (`hPinsker`).
* **(metric domination)** `W1 ≤ D · dTV` for the bounded metric `d ≤ D`
  (`hWTV`, Villani 2009 standard fact).

We prove the chained bound, plus the trivial-but-load-bearing positivity
facts.  The R.144 KL-residual decomposition (`KL = Φ_0 + KL_res`) is
recorded as a separate hypothesis-driven lemma showing the Wasserstein
bound in terms of the *pinnable* `Φ_0` plus the *unpinned* residual.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.NNReal
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace Pinsker

open Real

/-- **R.531 — Pinsker → bounded-metric Wasserstein bound (core).**

Given Pinsker's inequality `d_TV ≤ sqrt(KL/2)` (`hPinsker`) and the
metric-domination fact `W_1 ≤ D · d_TV` for a bounded ground metric
(`hWTV`) with `D ≥ 0`, the 1-Wasserstein cost is controlled by the KL
divergence:

    W_1^d(μ_A, μ_H)  ≤  D · sqrt(KL(μ_H ‖ μ_A) / 2). -/
theorem R_531_W1_le_sqrt_KL
    (W1 dTV KL D : ℝ)
    (hD : 0 ≤ D)
    (hWTV : W1 ≤ D * dTV)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2)) :
    W1 ≤ D * Real.sqrt (KL / 2) := by
  refine le_trans hWTV ?_
  exact mul_le_mul_of_nonneg_left hPinsker hD

/-- **Pinsker's inequality, squared form.**

The equivalent squared statement `2 · d_TV² ≤ KL`, recovered from the
square-root form for `KL ≥ 0` and `d_TV ≥ 0`.  (This is the form used to
combine with the R.144 chain rule.) -/
theorem pinsker_sq
    (dTV KL : ℝ)
    (hTV : 0 ≤ dTV) (hKL : 0 ≤ KL)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2)) :
    2 * dTV ^ 2 ≤ KL := by
  have hsq : dTV ^ 2 ≤ (Real.sqrt (KL / 2)) ^ 2 := by
    have := mul_le_mul hPinsker hPinsker hTV (Real.sqrt_nonneg _)
    simpa [pow_two] using this
  have hsqrt_sq : (Real.sqrt (KL / 2)) ^ 2 = KL / 2 :=
    Real.sq_sqrt (by positivity)
  rw [hsqrt_sq] at hsq
  linarith

/-- **R.531 — KL-residual form (R.144 chain rule).**

The R.144 KL chain rule decomposes the response-distribution divergence as
`KL(μ_H ‖ μ_A) = Φ_0 + KL_res`, where `Φ_0` is the pinnable emergent
potential and `KL_res` is the *unpinned residual* (the genuine gap of the
B-conditional R.531).  Bundling this decomposition (`hchain`) with the
Pinsker→Wasserstein bound gives the bound in terms of the pinnable
quantity plus the residual:

    W_1^d  ≤  D · sqrt((Φ_0 + KL_res) / 2).

The residual `KL_res` remains bundled — this is exactly the documented
"un-pinned KL residual" of the source. -/
theorem R_531_W1_le_sqrt_residual
    (W1 dTV KL Φ₀ KLres D : ℝ)
    (hD : 0 ≤ D)
    (hWTV : W1 ≤ D * dTV)
    (hPinsker : dTV ≤ Real.sqrt (KL / 2))
    (hchain : KL = Φ₀ + KLres) :
    W1 ≤ D * Real.sqrt ((Φ₀ + KLres) / 2) := by
  have h := R_531_W1_le_sqrt_KL W1 dTV KL D hD hWTV hPinsker
  rwa [hchain] at h

end Pinsker

end MIP
