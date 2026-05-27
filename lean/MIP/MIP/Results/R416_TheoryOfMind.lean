/-
Result R.416 — Theory of mind as a `K^ToM` coverage phase transition, with a
recursion-depth bound `depth ≤ log(WM) / log(Z_self / Z_external) ≤ 4-5`.

Reference: `C:/Users/12729/Desktop/MIP/workspace/multiagent_fep_mip.md` §R.416
("Theory of mind 作为 K^{ToM} 覆盖的退化"; deps R.408, R.131, R.134, R.79,
D.3.9, D.4.10; new concept `K^{ToM}`).

**Candidate / conditional note.**  The source marks R.416 **C 保持 / A 条件性**:
the formalization of `K^{ToM}` is an *open gap* (Cj.51), introduced as the new
hypothesis (F6); the depth bound is conditional on the self-vs-external
impedance premise `Z_self ≥ Z_external` (待定义 4).  This file is therefore a
**conditional formalization** bundling `K^{ToM}` and the impedance ratio; it
encodes the algebraic depth-bound kernel, not a definition of theory of mind.

**Statement (kernel).**  Recursive theory of mind nests
"I think that you think that I think …":
* **ToM-k** is `K^{ToM}` recursed `k` levels (D.3.9 self-referential
  degeneration: each extra nesting amplifies cognitive impedance by the factor
  `Z_self / Z_external ≥ 1`);
* a working memory of capacity `WM` can support at most a number of nestings
  whose total impedance fits in `WM`, giving the **MIP depth bound**

      `depth ≤ ⌊ log(WM) / log(Z_self / Z_external) ⌋`,

  which, under realistic constants (`WM ≈ 7`, `Z_self/Z_external ≈ 1.4-1.6`),
  evaluates to `≤ 4-5` (Dunbar 2014).

**HYPOTHESIS-BUNDLE.**  The un-formalizable primitive — the nested-knowledge
family `K^{ToM}` — enters as a bundled parameter: we model nesting level `k` by
the geometric impedance growth `(Z_self/Z_external)^k` (the D.3.9 amplification)
and require it to fit in the working-memory budget `WM`.  The self-vs-external
impedance premise `1 < Z_self/Z_external` (R.88 / 待定义 4) is bundled as a
hypothesis.  We then *derive* the logarithmic depth bound and the `≤ 5`
consequence by honest real arithmetic.  No psychology, no model of belief.

**This file is `sorry`-free and `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.Floor.Defs
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace TheoryOfMind

open Real

/- The bundled impedance ratio `ρ := Z_self / Z_external ≥ 1` (R.88 / D.3.9):
each extra ToM nesting multiplies cognitive impedance by `ρ`.  We carry `ρ` as
a real parameter `> 1` (strict, the realistic regime where deeper nesting is
strictly costlier), supplied to each theorem. -/

/-- **R.416 — admissibility of a nesting depth: the budget inequality.**

A nesting of depth `k` is *supportable* by working memory of capacity `WM` iff
its accumulated impedance `ρ^k` fits in the budget: `ρ^k ≤ WM`.  This is the
geometric (D.3.9 self-referential degeneration) model of recursive ToM cost. -/
def Supportable (ρ WM : ℝ) (k : ℕ) : Prop := ρ ^ k ≤ WM

/-- **R.416 — the logarithmic depth bound (continuous form).**

If a depth `k` is supportable (`ρ^k ≤ WM`) with `1 < ρ` and `0 < WM`, then

    `k ≤ log(WM) / log(Z_self / Z_external)`.

Proof: take `log` of `ρ^k ≤ WM` (monotone), use `log(ρ^k) = k·log ρ`, and
divide by `log ρ > 0` (positive since `ρ > 1`).  This is the MIP bound on ToM
nesting depth. -/
theorem R_416_depth_le_log_ratio
    (ρ WM : ℝ) (k : ℕ)
    (hρ : 1 < ρ) (_hWM : 0 < WM)
    (hsupp : Supportable ρ WM k) :
    (k : ℝ) ≤ Real.log WM / Real.log ρ := by
  have hρ0 : (0 : ℝ) < ρ := lt_trans one_pos hρ
  have hlogρ_pos : 0 < Real.log ρ := Real.log_pos hρ
  -- monotonicity of log on `ρ^k ≤ WM`
  have hpow_pos : 0 < ρ ^ k := pow_pos hρ0 k
  have hlog_le : Real.log (ρ ^ k) ≤ Real.log WM :=
    Real.log_le_log hpow_pos hsupp
  rw [Real.log_pow] at hlog_le
  -- `k * log ρ ≤ log WM`  ⟹  `k ≤ log WM / log ρ`
  rw [le_div_iff₀ hlogρ_pos]
  linarith [hlog_le]

/-- **R.416 — the integer depth bound (`⌊·⌋` form).**

The largest supportable nesting depth is at most
`⌊ log(WM) / log(Z_self/Z_external) ⌋`.  Immediate from the continuous bound by
`Nat.le_floor`. -/
theorem R_416_depth_le_floor
    (ρ WM : ℝ) (k : ℕ)
    (hρ : 1 < ρ) (hWM : 0 < WM)
    (hsupp : Supportable ρ WM k) :
    k ≤ ⌊ Real.log WM / Real.log ρ ⌋₊ := by
  apply Nat.le_floor
  exact R_416_depth_le_log_ratio ρ WM k hρ hWM hsupp

/-- **R.416 — the `≤ 5` consequence under realistic constants.**

With a coarse realistic working-memory capacity `WM ≤ 8` (Miller's 7±2) and an
impedance ratio `Z_self/Z_external ≥ 3/2` (the lower realistic end), any
supportable nesting depth satisfies `k ≤ 5`.

Proof: from the continuous bound `k ≤ log WM / log ρ`, monotonicity gives
`log WM ≤ log 8` and `log ρ ≥ log (3/2)`, and `log 8 / log (3/2) < 6`, so the
integer `k ≤ 5`.  This matches Dunbar's observed 4-5 layer human limit. -/
theorem R_416_depth_le_five
    (ρ WM : ℝ) (k : ℕ)
    (hρ : 3 / 2 ≤ ρ) (hWM_pos : 0 < WM) (hWM : WM ≤ 8)
    (hsupp : Supportable ρ WM k) :
    k ≤ 5 := by
  have hρ1 : 1 < ρ := by linarith
  have hbound : (k : ℝ) ≤ Real.log WM / Real.log ρ :=
    R_416_depth_le_log_ratio ρ WM k hρ1 hWM_pos hsupp
  -- log WM ≤ log 8  and  log ρ ≥ log (3/2) > 0
  have hlog8 : Real.log WM ≤ Real.log 8 := Real.log_le_log hWM_pos hWM
  have hlog32_pos : 0 < Real.log (3 / 2) := Real.log_pos (by norm_num)
  have hlogρ_pos : 0 < Real.log ρ := Real.log_pos hρ1
  have hlogρ_ge : Real.log (3 / 2) ≤ Real.log ρ :=
    Real.log_le_log (by norm_num) hρ
  -- log WM / log ρ ≤ log 8 / log (3/2)
  have hquot : Real.log WM / Real.log ρ ≤ Real.log 8 / Real.log (3 / 2) := by
    apply div_le_div₀ (by positivity) hlog8 hlog32_pos hlogρ_ge
  -- log 8 / log (3/2) < 6  (numeric):  log 8 ≈ 2.079, log 1.5 ≈ 0.405, quot ≈ 5.13
  have hnum : Real.log 8 / Real.log (3 / 2) < 6 := by
    rw [div_lt_iff₀ hlog32_pos]
    -- log 8 < 6 * log (3/2) = log ((3/2)^6) = log (729/64)
    have h6 : (6 : ℝ) * Real.log (3 / 2) = Real.log ((3 / 2) ^ 6) := by
      rw [Real.log_pow]; ring
    rw [h6]
    apply Real.log_lt_log (by norm_num)
    norm_num
  have : (k : ℝ) < 6 := by
    calc (k : ℝ) ≤ Real.log WM / Real.log ρ := hbound
      _ ≤ Real.log 8 / Real.log (3 / 2) := hquot
      _ < 6 := hnum
  -- (k : ℝ) < 6  ⟹  k ≤ 5
  have : k < 6 := by exact_mod_cast this
  omega

/-- **R.416 — packaged ToM depth-bound statement.**

Bundles the kernel: modelling recursive theory of mind by geometric impedance
growth `ρ = Z_self/Z_external > 1` under a working-memory budget `WM`, every
supportable nesting depth obeys the logarithmic bound `k ≤ log WM / log ρ`, and
under realistic constants (`WM ≤ 8`, `ρ ≥ 3/2`) this is `≤ 5` — the MIP
prediction matching Dunbar's 4-5 layer limit. -/
theorem R_416_ToM_depth_bound
    (ρ WM : ℝ) (k : ℕ)
    (hρ : 3 / 2 ≤ ρ) (hWM_pos : 0 < WM) (hWM : WM ≤ 8)
    (hsupp : Supportable ρ WM k) :
    ((k : ℝ) ≤ Real.log WM / Real.log ρ) ∧ k ≤ 5 := by
  have hρ1 : 1 < ρ := by linarith
  exact ⟨R_416_depth_le_log_ratio ρ WM k hρ1 hWM_pos hsupp,
         R_416_depth_le_five ρ WM k hρ hWM_pos hWM hsupp⟩

end TheoryOfMind

end MIP
