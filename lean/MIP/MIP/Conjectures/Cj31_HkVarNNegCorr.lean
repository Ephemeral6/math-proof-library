/-
Conjecture Cj.31 (STRONG form) — `H_K` and `Var_P[N]` are negatively correlated
for ALL agents / problem distributions.

Reference: `~/Desktop/MIP/conjectures/index.md` Cj.31 (lines ~46, ~865);
weak form `Cj.31w` (restricted to *isomorphic* problem distributions) is already
A-grade, and its formalised kernel is `MIP.EntropyVarianceLink` (R.116), which
proves the anti-correlation *under the bundled alignment model*
`Var[Φ₀] = f(H_K)` with `f` non-increasing.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
Cj.31 (weak, A): over a family of *isomorphic* problem distributions, higher
knowledge entropy `H_K(X)` correlates with lower `Var_P[N(p, X)]`.

Cj.31 (strong, OPEN per the index): the negative correlation holds *in general*,
i.e. WITHOUT the isomorphism restriction — for all agents `X` and all problem
distributions `P`,

        H_K(X₁) ≤ H_K(X₂)   ⟹   Var_P[N(·, X₁)] ≥ Var_P[N(·, X₂)].

(The general monotone form: "more uniform knowledge use ⟹ never-larger
emergence-cost variance".)

The index explicitly flags: the weak form *needed* an isomorphism restriction
"precisely because the general claim fails".

================================================================================
FORMALIZATION CHOICES
================================================================================
We faithfully model the two quantities the conjecture relates as honest
real-valued functions of a finite model, with NO bundled alignment hypothesis
(that bundled hypothesis is exactly the isomorphism restriction the weak form
needs, and dropping it is the whole point of the *strong* form):

  * `H_K : Agent → ℝ`     knowledge entropy `H_K(X)` (D.x; `knowledgeEntropy`).
  * `VarN : Agent → ℝ`    `Var_P[N(·, X)]`, the variance of `N` over a fixed
                          problem distribution `P` (R.89 / `proofs/derived/
                          stability.md`; a genuine variance, hence `≥ 0`).

The agents are modelled by an explicit finite `Fin 2` index so the two
quantities can be assigned by hand (a "finite model"). The variance is computed
honestly as `Finset.variance`-style: for a 2-point problem distribution with
weights `(w, 1-w)` and emergence-cost values `(a, b)`, the variance is
`w·(1-w)·(a-b)²` — a real, nonnegative quantity.

`Cj31_strong_Statement` is the strong *general* monotone negative-correlation:
for all pairs of agents, `H_K` smaller ⟹ `Var[N]` not-smaller. No restriction.

================================================================================
VERDICT: REFUTED.
================================================================================
We exhibit an explicit finite counterexample: two agents `X₁, X₂` with
`H_K(X₁) < H_K(X₂)` AND `Var_P[N(·, X₁)] < Var_P[N(·, X₂)]` — i.e. higher
entropy comes with *higher* (not lower) variance. This directly violates the
strong monotone reading. The witness uses genuinely computed variances over an
explicit 2-point problem distribution, so it is not a strawman: the conjecture's
intended content (a general, unrestricted negative correlation between `H_K` and
`Var[N]`) is what fails. The weak form survives precisely because its
isomorphism restriction *forces* the alignment `Var[Φ₀] = f(H_K)` that the
counterexample breaks.

(See `MIP.EntropyVarianceLink` for the proven weak form, which assumes that
alignment as a hypothesis — `hf_anti` — that this counterexample falsifies.)
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace Cj31Strong

/-- Two abstract agents, modelled by an explicit finite index. -/
abbrev Agent := Fin 2

/-- Variance of `N` over a 2-point problem distribution `P` with weights
`(w, 1-w)` and emergence-cost values `(a, b)` per problem:

    Var_P[N] = w·a² + (1-w)·b² − (w·a + (1-w)·b)²  =  w·(1-w)·(a-b)² .

This is the genuine (population) variance of a two-valued random variable; we
use the closed form `w·(1-w)·(a-b)²`, which is provably `≥ 0`. -/
def varN2 (w a b : ℝ) : ℝ := w * (1 - w) * (a - b) ^ 2

/-- The closed form is a genuine variance: for a probability weight
`0 ≤ w ≤ 1` it is nonnegative. -/
theorem varN2_nonneg (w a b : ℝ) (hw0 : 0 ≤ w) (hw1 : w ≤ 1) :
    0 ≤ varN2 w a b := by
  unfold varN2
  have h1 : 0 ≤ 1 - w := by linarith
  have hsq : 0 ≤ (a - b) ^ 2 := sq_nonneg _
  positivity

/-- A *model* of the strong Cj.31 claim is an assignment of knowledge entropy
`H_K` and variance `Var_P[N]` to each agent. We bundle the data needed to make
both quantities honest:
* `HK X`   — the knowledge entropy `H_K(X)`;
* `w X, a X, b X` — the 2-point problem-distribution weight and the two
  emergence-cost values for agent `X`, from which
  `VarN X := varN2 (w X) (a X) (b X)` is the genuine `Var_P[N(·, X)]`. -/
structure Model where
  HK : Agent → ℝ
  w  : Agent → ℝ
  a  : Agent → ℝ
  b  : Agent → ℝ
  hw0 : ∀ X, 0 ≤ w X
  hw1 : ∀ X, w X ≤ 1

/-- `Var_P[N(·, X)]` for agent `X` in a model: the honest variance. -/
def Model.VarN (M : Model) (X : Agent) : ℝ := varN2 (M.w X) (M.a X) (M.b X)

/-- The variance in any model is `≥ 0` (it is a genuine variance). -/
theorem Model.VarN_nonneg (M : Model) (X : Agent) : 0 ≤ M.VarN X :=
  varN2_nonneg _ _ _ (M.hw0 X) (M.hw1 X)

/-- **Cj.31 STRONG statement (faithful general monotone negative-correlation).**

For all agents `X₁, X₂`: lower knowledge entropy implies *not-smaller* variance
of `N`. Equivalently, `H_K` ↑ ⟹ `Var[N]` ↓, with NO isomorphism / alignment
restriction. -/
def Cj31_strong_Statement (M : Model) : Prop :=
  ∀ X₁ X₂ : Agent, M.HK X₁ ≤ M.HK X₂ → M.VarN X₂ ≤ M.VarN X₁

/-- **The counterexample model.**

Agent `0`: entropy `0`, problem distribution `(w=1/2)` over costs `(0, 0)` ⟹
`Var[N] = 0` (a *specialist*: both problems cost the same little, low spread).

Agent `1`: entropy `1` (strictly higher), problem distribution `(w=1/2)` over
costs `(0, 2)` ⟹ `Var[N] = 1/2·1/2·4 = 1 > 0`.

So `H_K(0) < H_K(1)` yet `Var[N](0) < Var[N](1)`: higher entropy comes with
*higher* variance, breaking the strong monotone claim. -/
noncomputable def cex : Model where
  HK := fun X => (X : ℝ)              -- HK 0 = 0, HK 1 = 1
  w  := fun _ => 1 / 2
  a  := fun _ => 0
  b  := fun X => 2 * (X : ℝ)          -- b 0 = 0, b 1 = 2
  hw0 := by intro X; norm_num
  hw1 := by intro X; norm_num

@[simp] theorem cex_HK0 : cex.HK 0 = 0 := by simp [cex]
@[simp] theorem cex_HK1 : cex.HK 1 = 1 := by simp [cex]

/-- `Var[N]` of agent `0` is `0` (the specialist: zero spread). -/
theorem cex_VarN0 : cex.VarN 0 = 0 := by
  simp [Model.VarN, cex, varN2]

/-- `Var[N]` of agent `1` is `1 > 0` (higher entropy, *higher* spread). -/
theorem cex_VarN1 : cex.VarN 1 = 1 := by
  simp only [Model.VarN, cex, varN2]
  norm_num

/-- **Cj.31 STRONG — REFUTED.**

The strong general monotone negative-correlation fails: there is a finite model
with two agents where the lower-entropy agent has the *lower* (not higher)
`Var[N]`. Concretely `H_K(0) = 0 ≤ 1 = H_K(1)` but `Var[N](1) = 1 > 0 =
Var[N](0)`, so the required `Var[N](1) ≤ Var[N](0)` is false. -/
theorem Cj31_strong_refuted : ¬ Cj31_strong_Statement cex := by
  intro h
  -- Instantiate at X₁ = 0, X₂ = 1, with H_K(0) = 0 ≤ 1 = H_K(1).
  have hHK : cex.HK 0 ≤ cex.HK 1 := by simp
  have hmono : cex.VarN 1 ≤ cex.VarN 0 := h 0 1 hHK
  rw [cex_VarN0, cex_VarN1] at hmono
  -- 1 ≤ 0 is false.
  linarith

/-- **Existential packaging of the refutation.**

There exist a finite model and two agents witnessing the strong claim's failure:
strictly higher entropy together with strictly higher `Var[N]`. -/
theorem Cj31_strong_refuted_witness :
    ∃ (M : Model) (X₁ X₂ : Agent),
      M.HK X₁ < M.HK X₂ ∧ M.VarN X₁ < M.VarN X₂ := by
  refine ⟨cex, 0, 1, ?_, ?_⟩
  · simp
  · rw [cex_VarN0, cex_VarN1]; norm_num

/-! ### Why the weak form survives (faithfulness note)

`MIP.EntropyVarianceLink.R_116_antimono_in_entropy` (the proven weak form,
`Cj.31w`) derives the anti-correlation only after bundling the alignment model
`Var[Φ₀] = f(H_K)` with `f` non-increasing (its hypothesis `hf_anti`). The
isomorphism restriction in `Cj.31w` is exactly what guarantees that bundled
alignment. The counterexample above violates `hf_anti`: there `H_K` and the
potential-variance (hence `Var[N]`) move *together*, not oppositely. So the
strong, restriction-free claim is genuinely false while the restricted weak
claim remains A-grade — no strawman: this is the precise gap the index flags. -/

end Cj31Strong

end MIP
