/-
Result R.10 — Type-II two-stage decomposition: `N_total = N_meta + N`.

Reference: `C:/Users/12729/Desktop/MIP/workspace/derived_results_index.md`
R.10 (B级: "第二类问题两阶段：N_meta+N", deps C.9 + Cj.20, "N_meta 待形式化");
`C:/Users/12729/Desktop/MIP/results/R_master_index.md` R.10 / Part-2 note
("N_meta 实际应为'专家干预 e 的计数 N_E'：M-干预由 D.1.5 不能扩展 K，Type II
必须使用 E := Σ* \ M").

**Statement.** A Type-II problem (`R(p) ⊄ K(A)`, by C.9) cannot be solved by
meta-cognitive interventions alone — those cannot expand `K(A)` (D.1.5).  It
is solved in two stages: first `N_meta` expert/augmentation interventions
expand `K(A)` so that `R(p) ⊆ K(A)`, turning the problem into Type I; then
the ordinary emergence cost `N := N(p, A)` solves it.  The total cost is the
additive decomposition

    N_total = N_meta + N .

`N_meta` is the un-formalised primitive (the count of knowledge-expanding
interventions `N_E`, with `E := Σ* \ M`; NC.2 pending).  We therefore
**bundle `N_meta` as a given non-negative quantity** and prove the additive
decomposition together with its basic consequences:

* (R.10) `N_total = N_meta + N`                         (definition / decomposition);
* (lower bound) `N ≤ N_total`                           (the two-stage cost dominates the Type-I cost);
* (meta lower bound) `N_meta ≤ N_total`;
* (monotone in `N_meta`) larger expansion cost ⟹ larger total;
* (monotone in `N`) larger emergence cost ⟹ larger total;
* (strict) if `N_meta > 0` (genuinely Type-II) then `N < N_total`.

All quantities are non-negative reals.

**This file is `axiom`-free.**  `N_meta` enters as an explicit given
primitive (`0 ≤ N_meta`); no MIP opaque is committed to.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace TypeIITwoStage

/-- **R.10 — Type-II two-stage decomposition.**

Given the bundled expansion cost `N_meta ≥ 0` and emergence cost `N ≥ 0`,
the total cost is defined to be their sum. -/
def N_total (N_meta N : ℝ) : ℝ := N_meta + N

/-- **R.10 — the additive decomposition holds by definition.** -/
theorem R_10_decomposition (N_meta N : ℝ) :
    N_total N_meta N = N_meta + N := rfl

/-- **R.10 — the two-stage total dominates the Type-I emergence cost `N`.**

Since the meta-stage cost `N_meta ≥ 0`, the total cost is at least the bare
emergence cost: solving a Type-II problem never costs less than the Type-I
cost it reduces to. -/
theorem R_10_total_ge_N (N_meta N : ℝ) (h_meta : 0 ≤ N_meta) :
    N ≤ N_total N_meta N := by
  unfold N_total; linarith

/-- **R.10 — the total dominates the meta-stage cost.** -/
theorem R_10_total_ge_meta (N_meta N : ℝ) (h_N : 0 ≤ N) :
    N_meta ≤ N_total N_meta N := by
  unfold N_total; linarith

/-- **R.10 — the total is non-negative.** -/
theorem R_10_total_nonneg (N_meta N : ℝ)
    (h_meta : 0 ≤ N_meta) (h_N : 0 ≤ N) :
    0 ≤ N_total N_meta N := by
  unfold N_total; linarith

/-- **R.10 — monotonicity in the meta-stage cost.**

A more expensive knowledge-expansion stage (larger `N_meta`) yields a larger
total, the emergence cost held fixed. -/
theorem R_10_mono_meta (N_meta₁ N_meta₂ N : ℝ) (h : N_meta₁ ≤ N_meta₂) :
    N_total N_meta₁ N ≤ N_total N_meta₂ N := by
  unfold N_total; linarith

/-- **R.10 — monotonicity in the emergence cost.**

A harder residual Type-I problem (larger `N`) yields a larger total, the
expansion stage held fixed. -/
theorem R_10_mono_N (N_meta N₁ N₂ : ℝ) (h : N₁ ≤ N₂) :
    N_total N_meta N₁ ≤ N_total N_meta N₂ := by
  unfold N_total; linarith

/-- **R.10 — strict gap for a genuine Type-II problem.**

If the meta-stage is genuinely needed (`N_meta > 0`, i.e. `R(p) ⊄ K(A)` so
knowledge must be expanded), then the two-stage total strictly exceeds the
bare emergence cost. -/
theorem R_10_strict_total_gt_N (N_meta N : ℝ) (h_meta : 0 < N_meta) :
    N < N_total N_meta N := by
  unfold N_total; linarith

end TypeIITwoStage

end MIP
