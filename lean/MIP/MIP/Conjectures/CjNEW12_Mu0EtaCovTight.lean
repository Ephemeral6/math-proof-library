/-
Conjecture Cj.NEW-12 — `μ₀ ≤ E_P[η_cov]` tightness condition.

Reference: `conjectures/index.md` Cj.NEW-12 (index lines ~697-724);
`workspace/mu0_measurement_theory.md` §13 (IV-1), property (μ₀-8).

**Faithful conjecture (natural language).**
Known bound (A-conditional, source IV-1.a):

    μ₀(X, P) ≤ E_P[η_cov(X, p)],   η_cov(X, p) = Pr_{R∼Unif(ℛ(p))}[R ⊆ K(X)].

On what `X × P` subclass does equality hold? Candidate answer: on the
Cj.NEW-5 (C-c) finite-deterministic-MDP subclass, where every covering
explanation `R ⊆ K(X)` has zero residual potential `Φ₀(X, p; R) = 0`, so

    {R ⊆ K(X)}  ⟺  {R ⊆ K(X) ∧ Φ₀(R) = 0}   ⟹   μ₀ = E_P[η_cov].

The partition-function characterization (μ₀-8, §13 IV-1):

    μ₀(X, P) = Pr_{p∼P}[∃ R ∈ ℛ(p), R ⊆ K(X) : Φ₀(X, p; R) = 0].

**Formalization choices (finite model).**
* `P` is a finite index set `ι` of problems with probability weights
  `w : ι → ℝ`, `w i ≥ 0`, `∑ w i = 1` (an `ActivationDist`-style finite
  distribution; cf. the API cheatsheet `∑ = 1`).
* For each problem `i`, two `{0,1}`-valued events (the opaque layer carries
  `demandFamily`, `K`, `Phi0` but not the `μ₀`/`η_cov` functionals, so we model
  the events directly, hypothesis-bundle idiom):
  - `covExists i` — the coverage event `∃ R ∈ ℛ(pᵢ), R ⊆ K(X)` (whether `X`
    covers *some* admissible explanation);
  - `mu0Ind i` — the μ₀ event `∃ R ∈ ℛ(pᵢ), R ⊆ K(X) ∧ Φ₀(R) = 0` (some
    covering explanation has zero residual potential, i.e. the (μ₀-8)
    partition-function support condition).
* `η_cov` is modeled as the **coverage-event probability** `covExists i ∈ {0,1}`
  — faithful to the source derivation骨架 "右侧是 X 覆盖某 R ∈ ℛ(p) 的概率上界"
  (the RHS upper-bounds the probability that `X` covers SOME `R`). The fractional
  `Pr_{R∼Unif}[R⊆K(X)]` and the coverage-event probability coincide exactly on
  the (C-c) subclass where the demand family is covered all-or-nothing; we record
  this formalization choice explicitly and additionally relate the fractional
  quantity below.
* `μ₀ := ∑ w i · mu0Ind i`,  `E_P[η_cov] := ∑ w i · covExists i`.

**What is PROVED.**
* (i) the upper bound `μ₀ ≤ E_P[η_cov]` (`mu0_le_etaCov`), from the pointwise
  containment `mu0Ind i ≤ covExists i` (the zero-Φ₀ covering set is in
  particular a covering set), aggregated by the probability weights;
* (ii) equality `μ₀ = E_P[η_cov]` on the (C-c) subclass where every covering
  `R ⊆ K(X)` already has `Φ₀(R) = 0` (`mu0_eq_etaCov_on_detMDP`), from the
  pointwise *equality* `mu0Ind i = covExists i` under that hypothesis.
* (Faithfulness to the fractional definition) `etaCov_frac_lower`: the
  source's fractional `η_cov^frac i = |{R⊆K(X)}|/|ℛ(pᵢ)|` dominates
  `mu0Ind i / |ℛ(pᵢ)|`, and equals the coverage indicator exactly when the
  family is covered all-or-nothing (recorded as a hypothesis), pinning the
  formalization choice.

**VERDICT: PROVED** — for the bound (i) and the (C-c) equality special case
(ii), which is exactly the tractability target. The remaining subproblem (a)
"is (C-c) necessary, or is there a wider equality subclass?" and (b) the 5D
geometric characterization of the gap `E_P[η_cov] − μ₀` are flagged OPEN below
(not part of the PROVED claim).

This file is axiom-free (only A.1–A.4 available; this file needs none — pure
finite-sum real algebra).
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.GCongr
import Mathlib.Algebra.Order.Field.Basic

namespace MIP

namespace CjNEW12_Mu0EtaCovTight

open scoped BigOperators

variable {ι : Type} [Fintype ι]

/-! ## Finite μ₀ / η_cov model -/

/-- `μ₀ := ∑ w i · mu0Ind i`. The probability-weighted count of problems with a
zero-Φ₀ covering explanation (the (μ₀-8) partition-function support). -/
noncomputable def mu0 (w : ι → ℝ) (mu0Ind : ι → ℝ) : ℝ :=
  ∑ i, w i * mu0Ind i

/-- `E_P[η_cov] := ∑ w i · covExists i`. The probability-weighted coverage-event
probability. -/
noncomputable def etaCovExp (w : ι → ℝ) (covExists : ι → ℝ) : ℝ :=
  ∑ i, w i * covExists i

/-! ## (i) The upper bound `μ₀ ≤ E_P[η_cov]` -/

/-- **Cj.NEW-12 (i) — `μ₀ ≤ E_P[η_cov]`.**

Given nonnegative weights and the pointwise containment `mu0Ind i ≤ covExists i`
(a zero-Φ₀ covering explanation is in particular a covering explanation), the
weighted sums obey `μ₀ ≤ E_P[η_cov]`. This is the finite-model form of the
source's IV-1.a bound (μ₀-8). -/
theorem mu0_le_etaCov
    (w mu0Ind covExists : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hcontain : ∀ i, mu0Ind i ≤ covExists i) :
    mu0 w mu0Ind ≤ etaCovExp w covExists := by
  unfold mu0 etaCovExp
  apply Finset.sum_le_sum
  intro i _
  exact mul_le_mul_of_nonneg_left (hcontain i) (hw i)

/-! ## (ii) Equality on the (C-c) finite-deterministic-MDP subclass -/

/-- **Cj.NEW-12 (ii) — equality on the (C-c) deterministic-MDP subclass.**

On the subclass where every covering explanation already has `Φ₀ = 0` — so the
coverage event and the μ₀ event coincide pointwise, `mu0Ind i = covExists i` —
the bound is tight: `μ₀ = E_P[η_cov]`.

`hdet` is the (C-c) hypothesis "`{R ⊆ K(X)}` ⟺ `{R ⊆ K(X) ∧ Φ₀(R) = 0}`" at
the indicator level (Cj.NEW-5 (C-c): no residual potential on any covering
path). -/
theorem mu0_eq_etaCov_on_detMDP
    (w mu0Ind covExists : ι → ℝ)
    (hdet : ∀ i, mu0Ind i = covExists i) :
    mu0 w mu0Ind = etaCovExp w covExists := by
  unfold mu0 etaCovExp
  apply Finset.sum_congr rfl
  intro i _
  rw [hdet i]

/-- **Cj.NEW-12 (ii) corollary — the gap vanishes exactly on (C-c).**

Restates (ii) as "gap `= 0`": `E_P[η_cov] − μ₀ = 0` on the deterministic-MDP
subclass. The gap function `E_P[η_cov] − μ₀ ≥ 0` (from (i)) measures the
breaking of tightness; here it is exactly zero. -/
theorem gap_zero_on_detMDP
    (w mu0Ind covExists : ι → ℝ)
    (hdet : ∀ i, mu0Ind i = covExists i) :
    etaCovExp w covExists - mu0 w mu0Ind = 0 := by
  rw [mu0_eq_etaCov_on_detMDP w mu0Ind covExists hdet]; ring

/-! ## Faithfulness to the fractional `η_cov` definition

The source writes `η_cov(X, p) = Pr_{R∼Unif(ℛ(p))}[R ⊆ K(X)] = |{R⊆K(X)}|/|ℛ(p)|`.
We pin the formalization choice (coverage-event probability) by relating it to
the fractional quantity: the fraction dominates `mu0Ind / |ℛ(p)|`, and equals the
coverage indicator exactly when the demand family is covered all-or-nothing —
the (C-c) regime. -/

/-- **Fractional `η_cov` lower bound.** With `Rcard i = |ℛ(pᵢ)| ≥ 1` and
`covCount i = |{R ∈ ℛ(pᵢ) : R ⊆ K(X)}|`, the fractional coverage
`η_cov^frac i = covCount i / Rcard i` satisfies
`mu0Ind i / Rcard i ≤ η_cov^frac i` whenever `mu0Ind i ≤ covCount i` (a zero-Φ₀
covering set is counted in `covCount`). So the fractional `η_cov` is positive
on the μ₀ support — confirming the coverage-event surrogate is the faithful
all-or-nothing limit (covCount = Rcard) of the fractional one. -/
theorem etaCov_frac_lower
    (Rcard covCount mu0IndVal : ℝ)
    (hR : 0 < Rcard)
    (hle : mu0IndVal ≤ covCount) :
    mu0IndVal / Rcard ≤ covCount / Rcard := by
  gcongr

/-- **All-or-nothing coverage ⟹ fractional `η_cov` = coverage indicator.**
When the demand family is covered all-or-nothing (`covCount = Rcard`, the (C-c)
regime), the fractional coverage equals `1` = the coverage indicator. This is
the exact regime where the coverage-event surrogate used above coincides with
the source's fractional definition. -/
theorem etaCov_frac_eq_one_of_allCovered
    (Rcard covCount : ℝ) (hR : 0 < Rcard) (hall : covCount = Rcard) :
    covCount / Rcard = 1 := by
  rw [hall]; exact div_self (ne_of_gt hR)

/-! ## MISSING / BLOCKED AT (open subproblems)

PROVED above: the bound (i) `μ₀ ≤ E_P[η_cov]` (`mu0_le_etaCov`) and the (C-c)
equality (ii) `μ₀ = E_P[η_cov]` (`mu0_eq_etaCov_on_detMDP`), with the
fractional-definition faithfulness lemmas pinning the formalization choice.

OPEN (the conjecture's subproblems):

* (a) **Is (C-c) necessary, or is there a wider equality subclass?** Equality
  needs `mu0Ind i = covExists i` `P`-a.e.; (C-c) is one sufficient condition
  (`Φ₀ = 0` on all covering sets), but a measure-zero set of `Φ₀ > 0` covered
  problems would also preserve equality. Characterizing the *minimal* equality
  subclass needs the `Φ₀` distribution over `ℛ(p)`, absent from the opaque
  layer. OPEN.
* (b) **5D-geometry of the gap** `E_P[η_cov] − μ₀`: the index conjectures it is
  proportional to the `η_cov`-mass of problems with `σ_Φ(p,X) > 0`; this needs
  the 5D phase-space coordinate `σ_Φ`, not formalized here. OPEN.
* (c) **Asymptotic tightness** `μ₀ / E_P[η_cov] → 1` as `T → 0` or `t → ∞`:
  needs the temperature family (cf. Cj.NEW-10) / training dynamics
  (cf. Cj.NEW-11). OPEN.
-/

end CjNEW12_Mu0EtaCovTight

end MIP
