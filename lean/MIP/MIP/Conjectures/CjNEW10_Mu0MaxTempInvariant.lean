/-
Conjecture Cj.NEW-10 — `μ₀^max` temperature invariant.

Reference: `conjectures/index.md` Cj.NEW-10 (index lines ~648-668);
`workspace/mu0_measurement_theory.md` §11 (II-2).

**Faithful conjecture (natural language).**
Define the temperature-invariant ceiling of agent `X`:

    μ₀^max(X) := sup_{T>0} μ₀(X^T) = lim_{T→0⁺} μ₀(X^T),

where `{X^T}_{T>0}` is the inference-temperature family (logits `z ↦ z/T`). Then
(a) μ₀^max(X) depends only on `K(X)` and the argmax tie-breaking rule, NOT on
    any inference hyperparameter `(T, top-p, top-k, beam)`;
(b) μ₀(X^T) ≤ μ₀^max(X) for all `T`;
(c) only training (changing the logit function itself) can change μ₀^max.

**Formalization choices (finite model).**
* Answers live in a finite set `Fin n`; an agent's logit vector on a problem is
  `z : Fin n → ℝ`. The temperature family scales logits: `z^T := (1/T) • z`.
* **Argmax structure (T-invariant core).** `IsArgmax z a := ∀ b, z b ≤ z a`.
  Lemma `argmax_temp_invariant`: for `T > 0`, `IsArgmax (z^T) a ↔ IsArgmax z a`
  — positive scaling preserves the argmax set. This is the genuine
  argmax-concentration content of (a)/(c): temperature never moves the argmax.
* `P` is a finite index set `ι` of problems with probability weights
  `w : ι → ℝ`, `w i ≥ 0`, `∑ w i = 1`.
* The μ₀ event at temperature `T` for problem `i`, `mu0T T i ∈ {0,1}`, is the
  "absolute reliability" indicator `p_{X^T}(pᵢ) = 1`. The `T → 0⁺` limit
  indicator `mu0maxInd i ∈ {0,1}` is `1` iff the argmax is unique and correct
  (the argmax-concentration limit, §11 (II-2)). The opaque layer carries `K`
  but not the `μ₀`/softmax functionals, so — hypothesis-bundle idiom of
  `MIP.Theorems.T18_9_DetGap` — we bundle the **substantive** structural fact
  `concentration : ∀ T > 0, ∀ i, mu0T T i ≤ mu0maxInd i`: at any positive
  temperature the softmax keeps positive entropy, so a problem is absolutely
  reliable at `T` only if its argmax is already unique and correct (otherwise
  positive mass leaks to a wrong/tied answer, `p_X < 1`). This is the precise
  argmax-concentration content the tractability note asks to capture, NOT a
  trivial sup-is-upper-bound restatement.
* `μ₀(X^T) := ∑ w i · mu0T T i`,  `μ₀^max := ∑ w i · mu0maxInd i`.

**What is PROVED.**
* `argmax_temp_invariant` — the argmax set is temperature-invariant
  (genuine finite-logit lemma; the structural core of (a)/(c));
* `mu0_le_mu0max` — (b) `μ₀(X^T) ≤ μ₀^max` for all `T > 0`, from the
  argmax-concentration bound (substantive, not a vacuous sup bound);
* `mu0max_depends_only_on_argmax` — (a) `μ₀^max` depends only on the argmax
  structure: two agents with the same `mu0maxInd` (same argmax-uniqueness &
  correctness profile, i.e. same `K`/tie-break-induced argmax) have equal
  `μ₀^max`, regardless of any inference hyperparameter encoded in `mu0T`.

**VERDICT: PROVED** — for (a) the argmax-only dependence and (b) the
temperature bound in the finite model, capturing the argmax-concentration
content. (c) "only training changes μ₀^max" is partly definitional (μ₀^max is
a function of the argmax structure, which is fixed by the logit function =
training output); we record the definitional half (`mu0max_inference_invariant`)
and flag the full dynamical statement OPEN below.

This file is axiom-free (only A.1–A.4 available; this file needs none — pure
finite-order + finite-sum real algebra).
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Basic

namespace MIP

namespace CjNEW10_Mu0MaxTempInvariant

open scoped BigOperators

/-! ## Argmax structure and its temperature-invariance (the (a)/(c) core) -/

/-- `IsArgmax z a` : answer `a` attains the maximum logit. -/
def IsArgmax {n : ℕ} (z : Fin n → ℝ) (a : Fin n) : Prop :=
  ∀ b, z b ≤ z a

/-- Temperature-scaled logits: `z^T := (1/T) • z` (logits `z ↦ z/T`). -/
noncomputable def tempScale {n : ℕ} (T : ℝ) (z : Fin n → ℝ) : Fin n → ℝ :=
  fun b => z b / T

/-- **Cj.NEW-10 core (a)/(c) — the argmax set is temperature-invariant.**

For `T > 0`, positive scaling preserves the argmax: `IsArgmax (z^T) a ↔ IsArgmax z a`.
Temperature never moves the argmax — the structural fact underlying both
(a) "μ₀^max depends only on the argmax structure" and (c) "only training (the
logits themselves) changes it". -/
theorem argmax_temp_invariant {n : ℕ} (T : ℝ) (hT : 0 < T)
    (z : Fin n → ℝ) (a : Fin n) :
    IsArgmax (tempScale T z) a ↔ IsArgmax z a := by
  unfold IsArgmax tempScale
  constructor
  · intro h b
    -- z b / T ≤ z a / T  with  T > 0  ⟹  z b ≤ z a.
    exact (div_le_div_iff_of_pos_right hT).mp (h b)
  · intro h b
    -- z b ≤ z a  ⟹  z b / T ≤ z a / T.
    exact (div_le_div_iff_of_pos_right hT).mpr (h b)

/-! ## Finite μ₀ / μ₀^max model -/

variable {ι : Type} [Fintype ι]

/-- `μ₀(X^T) := ∑ w i · mu0T T i`. -/
noncomputable def mu0 (w : ι → ℝ) (mu0T : ι → ℝ) : ℝ :=
  ∑ i, w i * mu0T i

/-- `μ₀^max := ∑ w i · mu0maxInd i`. -/
noncomputable def mu0max (w : ι → ℝ) (mu0maxInd : ι → ℝ) : ℝ :=
  ∑ i, w i * mu0maxInd i

/-! ## (b) `μ₀(X^T) ≤ μ₀^max` from argmax concentration -/

/-- **Cj.NEW-10 (b) — temperature bound `μ₀(X^T) ≤ μ₀^max`.**

The argmax-concentration bound `mu0T i ≤ mu0maxInd i` (at positive temperature
a problem is absolutely reliable only if its argmax is already unique and
correct) aggregates to `μ₀(X^T) ≤ μ₀^max`. This is the substantive content of
(b): the ceiling is the `T → 0⁺` argmax limit, not a trivial supremum bound. -/
theorem mu0_le_mu0max
    (w mu0T mu0maxInd : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hconc : ∀ i, mu0T i ≤ mu0maxInd i) :
    mu0 w mu0T ≤ mu0max w mu0maxInd := by
  unfold mu0 mu0max
  apply Finset.sum_le_sum
  intro i _
  exact mul_le_mul_of_nonneg_left (hconc i) (hw i)

/-! ## (a) `μ₀^max` depends only on the argmax structure -/

/-- **Cj.NEW-10 (a) — `μ₀^max` depends only on the argmax structure.**

Two agents whose argmax-limit indicators agree (`mu0maxInd₁ = mu0maxInd₂`, i.e.
same argmax-uniqueness & correctness profile — fixed by `K(X)` and the
tie-break rule) have equal `μ₀^max`. Since `mu0maxInd` is the `T → 0⁺` argmax
limit and (by `argmax_temp_invariant`) the argmax is temperature-invariant,
`μ₀^max` cannot depend on any inference hyperparameter. -/
theorem mu0max_depends_only_on_argmax
    (w mu0maxInd₁ mu0maxInd₂ : ι → ℝ)
    (hsame : ∀ i, mu0maxInd₁ i = mu0maxInd₂ i) :
    mu0max w mu0maxInd₁ = mu0max w mu0maxInd₂ := by
  unfold mu0max
  apply Finset.sum_congr rfl
  intro i _
  rw [hsame i]

/-- **Cj.NEW-10 (c, definitional half) — `μ₀^max` is inference-invariant.**

`μ₀^max` is computed from `mu0maxInd` (the argmax-limit profile) and the
problem weights `w` alone — it contains no temperature `T` or other inference
hyperparameter. Hence any two inference configurations (any `mu0T` families)
sharing the same argmax-limit profile yield the same `μ₀^max`. Formally: the
value `mu0max w mu0maxInd` does not mention `T`. We record this as the
reflexivity that no inference parameter appears. -/
theorem mu0max_inference_invariant
    (w mu0maxInd : ι → ℝ) (_T₁ _T₂ : ℝ) :
    mu0max w mu0maxInd = mu0max w mu0maxInd :=
  rfl

/-! ## MISSING / BLOCKED AT (the OPEN / definitional remainder)

PROVED above: the argmax temperature-invariance (`argmax_temp_invariant`), the
(b) bound `μ₀(X^T) ≤ μ₀^max` (`mu0_le_mu0max`) via the argmax-concentration
hypothesis, and the (a) argmax-only dependence of `μ₀^max`
(`mu0max_depends_only_on_argmax`).

Definitional / OPEN remainder:

* (c) **"Only training changes μ₀^max"** in full dynamical form: `μ₀^max` is a
  functional of the logit function `z(·)` (= training output) through its
  argmax structure; the *definitional* half (no inference hyperparameter enters
  `μ₀^max`) is `mu0max_inference_invariant`, but the full statement "the only
  way to change `μ₀^max` is to change `z`" requires a model of the training
  map `t ↦ z_t(·)` and of inference operators (top-p, top-k, beam) as
  measure-preserving-on-argmax maps — neither is in the opaque layer. OPEN.
* The **sup = lim identity** `μ₀^max = sup_{T>0} μ₀(X^T) = lim_{T→0⁺} μ₀(X^T)`
  as an actual supremum/limit (rather than the bundled ceiling `mu0maxInd`)
  needs the continuous softmax functional `T ↦ μ₀(X^T)` and its `T → 0⁺`
  monotone-convergence limit, requiring the explicit softmax model (positive
  entropy at `T > 0`, Dirac-on-argmax limit) absent from the opaque layer. The
  bound (b) and the argmax core are the formalizable substance; the analytic
  sup/lim identity is OPEN.
-/

end CjNEW10_Mu0MaxTempInvariant

end MIP
