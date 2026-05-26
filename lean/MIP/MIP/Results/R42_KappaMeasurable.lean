/-
Result R.42 — Combinatorial closure `κ` is measurable via pairwise
co-occurrence frequency.

Reference: `proofs/derived/A_grade.md` R.42 (A, B→A 2nd round, under
D.3.7 candidate-C `∘` formalization).

**Statement.** `κ(X) = |{(ω₁,ω₂) : ω₁∘ω₂ ∈ K(X)}| / |K(X)|²` (D.3.7) is
measurable: the plug-in estimator built from empirical pairwise-prevalence
frequencies converges to `κ`.  The algorithm (R.42 step 4–5): estimate, for
each pair, the co-occurrence probability `p̂ₙ`; threshold/aggregate into
`κ̂ₙ`; by Glivenko–Cantelli `p̂ₙ → p`, and since `κ` is a *continuous
functional of finitely many probabilities*, `κ̂ₙ → κ`.

**Pure-math kernel (Hypothesis-Bundle encoding).** The empirical frequency
vector is `p_hat : ℕ → (Fin k → ℝ)` (the `k` pairwise-prevalence frequencies),
with the bundled LLN/Glivenko–Cantelli hypothesis

    Filter.Tendsto p_hat atTop (nhds p)        (p = true frequency vector).

The κ-functional `κfun : (Fin k → ℝ) → ℝ` is **continuous** (it is a finite
arithmetic combination of the frequencies — a ratio of finite sums, the
plug-in `|{composable}| / k`).  Then the plug-in estimate

    κ_hat n := κfun (p_hat n)

is consistent:

    Filter.Tendsto κ_hat atTop (nhds (κfun p))    i.e.   κ_hat n → κ ,

by `Continuous.tendsto` composed with the frequency convergence
(`Filter.Tendsto.comp`).

**This file is `axiom`-free.**  The MIP-side machinery (D.3.7 `∘`
formalization, D.4.11 `extract`, the threshold rule) enters only through the
explicit continuity of `κfun` and the bundled frequency-convergence
hypothesis.
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Constructions
import Mathlib.Topology.ContinuousOn
import Mathlib.Order.Filter.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace KappaMeasurable

open Filter Topology

variable {k : ℕ}

/-- **R.42 — `κ` is measurable: the plug-in estimator is consistent.**

Let `κfun : (Fin k → ℝ) → ℝ` be the κ-functional, *continuous* in the
finitely many pairwise frequencies (D.3.7: `κ` is a ratio of finite sums of
the co-occurrence probabilities).  Let `p_hat : ℕ → (Fin k → ℝ)` be the
empirical-frequency sequence with the bundled LLN hypothesis
`p_hat n → p`.  Then the plug-in estimate `κ_hat n := κfun (p_hat n)` is
consistent:

    κ_hat n → κfun p   ( = κ )    as `n → ∞`. -/
theorem R_42_kappa_measurable
    (κfun : (Fin k → ℝ) → ℝ) (p : Fin k → ℝ) (p_hat : ℕ → (Fin k → ℝ))
    (h_cont : Continuous κfun)
    (h_LLN : Tendsto p_hat atTop (nhds p)) :
    Tendsto (fun n => κfun (p_hat n)) atTop (nhds (κfun p)) :=
  (h_cont.tendsto p).comp h_LLN

/-- **R.42 (named-plug-in form).**

The same statement with the plug-in estimator named `κ_hat := κfun ∘ p_hat`
and the true value named `κ := κfun p`, matching the R.42 notation
`κ̂ₙ → κ`. -/
theorem R_42_plugin_consistent
    (κfun : (Fin k → ℝ) → ℝ) (p : Fin k → ℝ) (p_hat : ℕ → (Fin k → ℝ))
    (κ : ℝ) (κ_hat : ℕ → ℝ)
    (h_cont : Continuous κfun)
    (h_LLN : Tendsto p_hat atTop (nhds p))
    (h_true  : κ = κfun p)
    (h_plugin : ∀ n, κ_hat n = κfun (p_hat n)) :
    Tendsto κ_hat atTop (nhds κ) := by
  have h := (h_cont.tendsto p).comp h_LLN
  rw [h_true]
  refine h.congr' ?_
  filter_upwards with n
  exact (h_plugin n).symm

end KappaMeasurable

end MIP
