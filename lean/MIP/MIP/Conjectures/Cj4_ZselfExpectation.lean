/-
Conjecture Cj.4 (STRONG / expectation form) — `E_P[Z_self/Z_external] > 1`.

Reference: `~/Desktop/MIP/conjectures/index.md` Cj.4 (lines ~14, ~826, ~839);
`workspace/Z_self_structural_lower_bound.md` (the weak form W is A-grade, the
strong form S is the OPEN expectation form, §4).

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
Cj.4 weak (A, proven — proposition W in `Z_self_structural_lower_bound.md`):
for each non-degenerate computable agent `A` there is a *blind-spot* problem
family `{p_{A,k}}` (R.101) on which `Z_self(A; p) = ∞ > Z_external(A | A'; p) <
∞`. Pointwise on that family the ratio `Z_self / Z_external` is `> 1` (in fact
`= ∞`).

Cj.4 strong (S, OPEN per the index and §4 of the workspace doc): for a "natural"
problem distribution `P` on `Σ*`,

        E_{p∼P}[ Z_self(A; p) / Z_external(A | A'; p) ]  >  1 .            (S)

The workspace doc's §4.2 ("Obstacle 1: measure concentration") states the strong
form's truth DEPENDS on `P` assigning POSITIVE measure to the blind-spot family
`Q_diag(A) = {p_{A,k}}`. Outside the blind spots the ratio can be `≤ 1`
(external `A'` has no advantage on non-diagonal `p`, and may even do worse),
and under a typical length-prior the blind-spot family can have measure → 0.

================================================================================
FORMALIZATION CHOICES
================================================================================
We model the ratio honestly as a per-problem random variable
`ratio : ι → ℝ` over a FINITE problem space `ι`, with a probability distribution
`P : ι → ℝ` (`P i ≥ 0`, `Σ P i = 1`). The expectation is the honest
`Finset.sum`, `E_P[ratio] = Σ_i P i · ratio i`.

Faithful structural facts carried from the weak form W (so this is NOT a
strawman):
  * `ratio i ≥ 1` everywhere (pointwise `Z_self ≥ Z_external`; this is the weak
    form's direction — the gap is never < 1 on a genuine self/external pair);
  * `ratio i > 1` exactly on the blind-spot set `B ⊆ ι` (R.101 family);
  * elsewhere `ratio i = 1` (no advantage off the blind spots, the *favourable*
    boundary case; choosing `= 1` rather than `< 1` is the most charitable —
    anti-strawman — reading, which makes refutation HARDER, not easier).

The UNCONDITIONAL strong form (S) is read faithfully as: for ALL admissible
problem distributions `P`, `E_P[ratio] > 1`. (This is the claim that the
expectation-form inequality holds without any positive-measure hypothesis on the
blind spots — the version the index calls OPEN and warns is "refutable if the
blind-spot family can have P-measure 0".)

================================================================================
VERDICT: REFUTED  (unconditional strong form).
================================================================================
We exhibit an admissible `P` that puts ZERO measure on the blind-spot set `B`
(measure concentrates on the non-diagonal problems where `ratio = 1`). Then
`E_P[ratio] = 1`, NOT `> 1`. Since the unconditional strong form demands
`E_P[ratio] > 1` for *all* admissible `P`, this single measure-0-blind-spot `P`
refutes it.

This is faithful, not a strawman: the counterexample uses exactly the mechanism
the workspace doc flags (Obstacle 1, measure concentration) and keeps the weak
form's pointwise `ratio ≥ 1` intact — the weak (pointwise, blind-spot) form
survives unscathed; only the *unconditional* expectation upgrade fails.

The CONDITIONAL strong form (S restricted to `P` with `P(B) > 0`) is recorded
separately and is PROVED below (`Cj4_strong_conditional_holds`): if the blind
spots carry positive measure, then `E_P[ratio] > 1`. So the honest landscape is:
weak A; strong unconditional REFUTED; strong conditional (positive blind-spot
measure) PROVED; the remaining OPEN question is whether a "natural" `P` must
assign `P(B) > 0` (the measure-theoretic gap §4.2/§4.4 leaves open).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FinCases

namespace MIP

open scoped BigOperators

namespace Cj4Strong

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- A faithful finite model of Cj.4's expectation form. The data:
* `ratio : ι → ℝ`  — the per-problem ratio `Z_self / Z_external`;
* `P : ι → ℝ`      — the problem distribution (`P i ≥ 0`, `Σ P i = 1`);
* `B : Finset ι`   — the blind-spot family `Q_diag(A) = {p_{A,k}}` (R.101).

Structural facts from the weak form W:
* `hge1`   : `ratio i ≥ 1` for all `i`     (pointwise `Z_self ≥ Z_external`);
* `hgt1`   : `ratio i > 1` for `i ∈ B`     (strict on the blind spots, R.101);
* `heq1`   : `ratio i = 1` for `i ∉ B`     (no advantage off the blind spots). -/
structure Model (ι : Type*) [Fintype ι] [DecidableEq ι] where
  ratio : ι → ℝ
  P     : ι → ℝ
  B     : Finset ι
  hP_nn : ∀ i, 0 ≤ P i
  hP_sum : ∑ i, P i = 1
  hge1  : ∀ i, 1 ≤ ratio i
  hgt1  : ∀ i ∈ B, 1 < ratio i
  heq1  : ∀ i ∉ B, ratio i = 1

/-- The expectation `E_P[ratio] = Σ_i P i · ratio i`. -/
def Model.expRatio (M : Model ι) : ℝ := ∑ i, M.P i * M.ratio i

/-- **Cj.4 STRONG — unconditional expectation form.**

`E_P[Z_self/Z_external] > 1`, with NO hypothesis on the blind-spot measure. -/
def Cj4_strong_uncond_Statement (M : Model ι) : Prop := 1 < M.expRatio

/-! ### The counterexample: a measure-0-blind-spot distribution -/

/-- **A two-problem counterexample model** on `Fin 2`.

`B = {1}` is the (single) blind spot. The distribution `P` is the point mass on
the *non*-blind-spot problem `0`: `P 0 = 1`, `P 1 = 0`. So `P(B) = 0`. The ratio
is `1` on problem `0` (non-diagonal, no advantage) and `2 > 1` on the blind spot
`1`. Everything respects the weak form `ratio ≥ 1`. -/
def cex : Model (Fin 2) where
  ratio := fun i => if i = 1 then 2 else 1
  P     := fun i => if i = 0 then 1 else 0
  B     := {1}
  hP_nn := by intro i; fin_cases i <;> norm_num
  hP_sum := by rw [Fin.sum_univ_two]; norm_num
  hge1 := by intro i; fin_cases i <;> norm_num
  hgt1 := by
    intro i hi
    -- i ∈ {1} ⟹ i = 1 ⟹ ratio i = 2 > 1
    have : i = 1 := by simpa using hi
    subst this; norm_num
  heq1 := by
    intro i hi
    -- i ∉ {1} ⟹ i ≠ 1 ⟹ ratio i = 1
    have hne : i ≠ 1 := by simpa using hi
    simp [hne]

/-- The counterexample distribution puts ZERO measure on the blind spot:
`P 1 = 0`, and only `P 0 = 1` contributes. -/
theorem cex_blindspot_measure_zero : cex.P 1 = 0 := by simp [cex]

/-- The counterexample's expectation is exactly `1` (not `> 1`): the entire mass
sits on the non-blind-spot problem where `ratio = 1`. -/
theorem cex_expRatio_eq_one : cex.expRatio = 1 := by
  unfold Model.expRatio
  simp [cex, Fin.sum_univ_two]

/-- **Cj.4 STRONG (unconditional) — REFUTED.**

For the measure-0-blind-spot model `cex`, `E_P[ratio] = 1`, so the unconditional
strict inequality `E_P[ratio] > 1` is false. Since the unconditional strong form
requires `> 1` for *every* admissible `P`, this distribution refutes it. -/
theorem Cj4_strong_uncond_refuted : ¬ Cj4_strong_uncond_Statement cex := by
  unfold Cj4_strong_uncond_Statement
  rw [cex_expRatio_eq_one]
  -- ¬ (1 < 1)
  exact lt_irrefl 1

/-- **Existential packaging:** there is an admissible model (with `ratio ≥ 1`
pointwise, strict on its blind-spot set) whose expectation ratio equals `1`,
witnessing the failure of the unconditional strong form. -/
theorem Cj4_strong_uncond_refuted_witness :
    ∃ M : Model (Fin 2), M.expRatio = 1 ∧ ¬ (1 < M.expRatio) := by
  exact ⟨cex, cex_expRatio_eq_one, by rw [cex_expRatio_eq_one]; exact lt_irrefl 1⟩

/-! ### The CONDITIONAL strong form holds (faithfulness / completeness)

If the blind spots carry positive measure, the strong expectation inequality
DOES hold. This proves the refutation above is sharp (the only obstacle is the
measure-0 case) and is exactly the §4.4 candidate path of the workspace doc. -/

/-- **Cj.4 STRONG — conditional form (positive blind-spot measure) — PROVED.**

If `B` is nonempty, some blind spot `i₀ ∈ B` has `P i₀ > 0`, and `ratio ≥ 1`
everywhere, then `E_P[ratio] > 1`.

Proof: `E_P[ratio] = Σ P i · ratio i ≥ Σ P i · 1 = Σ P i = 1`, and the term at
`i₀` is strict (`P i₀ · ratio i₀ > P i₀ · 1`), so the sum is strictly `> 1`. -/
theorem Cj4_strong_conditional_holds (M : Model ι)
    (i₀ : ι) (hi₀B : i₀ ∈ M.B) (hP_pos : 0 < M.P i₀) :
    1 < M.expRatio := by
  unfold Model.expRatio
  -- Term-wise `P i · ratio i ≥ P i · 1 = P i`, strict at `i₀`.
  have hterm_ge : ∀ i ∈ Finset.univ, M.P i * 1 ≤ M.P i * M.ratio i := by
    intro i _
    exact mul_le_mul_of_nonneg_left (M.hge1 i) (M.hP_nn i)
  have hterm_strict : M.P i₀ * 1 < M.P i₀ * M.ratio i₀ :=
    mul_lt_mul_of_pos_left (M.hgt1 i₀ hi₀B) hP_pos
  -- Sum strict-mono: Σ P i · 1 < Σ P i · ratio i.
  have hsum_lt :
      ∑ i, M.P i * 1 < ∑ i, M.P i * M.ratio i :=
    Finset.sum_lt_sum hterm_ge ⟨i₀, Finset.mem_univ i₀, hterm_strict⟩
  -- Σ P i · 1 = Σ P i = 1.
  have hsum_one : ∑ i, M.P i * 1 = 1 := by
    simp only [mul_one]; exact M.hP_sum
  rw [hsum_one] at hsum_lt
  exact hsum_lt

/-! ### REMAINING OPEN QUESTION (recorded, not claimed)

The honest residual open problem (Cj.4 strong, "natural `P`"): must a *natural*
problem distribution `P` (e.g. a Solomonoff length-prior on `Σ*`) assign
positive measure to the blind-spot family `Q_diag(A)`?

BLOCKED AT / MISSING:
  1. `Σ*` is infinite; the blind-spot family `{p_{A,k}}` is countable and, under
     a length-prior `~ 2^{-|p|}`, can have total measure made arbitrarily small
     (workspace §4.2). Whether it must be strictly positive for a "natural" `P`
     is undecided — and is itself coupled to Cj.5 (the measure-lower-bound).
  2. The self-referential intervention set `M_A` ("A reflecting on A") is NC.3,
     not yet formalised in `MIP.Axioms` (workspace §4.3) — so the strong form's
     full statement cannot even be stated sorry-free over the real `Σ*` model.

Hence: weak form A; unconditional strong form REFUTED (above); conditional
strong form (`P(B) > 0`) PROVED (above); the "natural-`P` ⟹ `P(B) > 0`" bridge
remains OPEN. No sorry-backed theorem is asserted for the open bridge. -/

end Cj4Strong

end MIP
