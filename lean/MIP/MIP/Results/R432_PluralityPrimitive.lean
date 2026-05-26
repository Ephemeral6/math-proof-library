/-
Result R.432 — The fourth primitive P (Plurality / multi-representation):
`H_K ↑ ⟹ ΔVar[N] < 0`, with `E[N]` first-order invariant.

Reference: `workspace/coe_mip_unification.md` §R.432 (graded **B** — parts (i)-(ii)
strict; (iii) strict within the R.89/R.109 variance-decomposition framework,
which is carried here as the explicit algebraic model).

**Statement.** Using the R.89 variance decomposition (file
`R89_VarN_Decomposition.lean`):

    Var[N]  =  Z̄² · Var[Φ₀]  +  σ_Z² · E[Φ₀²] ,        E[N]  =  Z̄ · E[Φ₀] .

The Plurality primitive P injects multiple equivalent representations of the
same knowledge element.  Modelled as *diversity reduces dispersion*:
`Var[Φ₀]` and/or `σ_Z²` strictly decrease, while the **means** `Z̄`, `E[Φ₀]`
are unchanged (multi-representation does not add new ω, raise/lower impedance,
or move first moments).  Then:

(i)  **`E[N]` first-order invariant**: `E[N]_P = Z̄·E[Φ₀] = E[N]` exactly.
(ii) **`Var[N]` strictly decreases**: any strict drop in `Var[Φ₀]` or in
     `σ_Z²` (with the other non-increasing, and the relevant coefficient
     positive) yields `Var[N]_P < Var[N]`.

This is the structural distinction of P from R/T/C: R/T/C reduce the *mean*
`E[N]`; P reduces the *variance* `Var[N]` while leaving the mean fixed
(one-order-invariance).

**This file is `axiom`-free.**  All quantities are explicit reals; the
"diversity reduces dispersion" mechanism enters as explicit inequality
hypotheses, and we prove the mean-invariance + variance-decrease kernel.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace PluralityPrimitive

/-- **Mean of `N = Z·Φ₀`** for independent `Z, Φ₀`: `E[N] = Z̄ · E[Φ₀]`. -/
def meanN (Z_bar EPhi : ℝ) : ℝ := Z_bar * EPhi

/-- **Variance of `N = Z·Φ₀`** (R.89 form):
`Var[N] = Z̄²·Var[Φ₀] + σ_Z²·E[Φ₀²]`. -/
def varN (Z_bar VarPhi σ_Z2 EPhi2 : ℝ) : ℝ :=
  Z_bar ^ 2 * VarPhi + σ_Z2 * EPhi2

/-- **R.432 (i) — P leaves `E[N]` first-order invariant.**

P does not move the first moments `Z̄`, `E[Φ₀]` (multi-representation adds no
new ω and does not change impedance), so `E[N]_P = Z̄·E[Φ₀] = E[N]`. -/
theorem R_432_mean_invariant
    (Z_bar EPhi : ℝ) :
    meanN Z_bar EPhi = meanN Z_bar EPhi := rfl

/-- **R.432 (i, stated) — explicit mean equality under unchanged means.**

If P keeps `Z̄_P = Z̄` and `E[Φ₀]_P = E[Φ₀]`, then `E[N]_P = E[N]`. -/
theorem R_432_mean_unchanged
    (Z_bar EPhi Z_bar_P EPhi_P : ℝ)
    (h_Z : Z_bar_P = Z_bar) (h_EPhi : EPhi_P = EPhi) :
    meanN Z_bar_P EPhi_P = meanN Z_bar EPhi := by
  unfold meanN; rw [h_Z, h_EPhi]

/-- **R.432 (ii) — reducing `Var[Φ₀]` strictly lowers `Var[N]`.**

If `Z̄ ≠ 0` (so `Z̄² > 0`) and P strictly reduces `Var[Φ₀]`
(`VarPhi_P < VarPhi`) while leaving `σ_Z²`, `E[Φ₀²]` fixed, then
`Var[N]_P < Var[N]`. -/
theorem R_432_var_decrease_via_VarPhi
    (Z_bar VarPhi VarPhi_P σ_Z2 EPhi2 : ℝ)
    (h_Z : Z_bar ≠ 0)
    (h_dec : VarPhi_P < VarPhi) :
    varN Z_bar VarPhi_P σ_Z2 EPhi2 < varN Z_bar VarPhi σ_Z2 EPhi2 := by
  unfold varN
  have hZ2 : 0 < Z_bar ^ 2 := by positivity
  nlinarith [mul_lt_mul_of_pos_left h_dec hZ2]

/-- **R.432 (ii') — reducing `σ_Z²` strictly lowers `Var[N]`.**

If `E[Φ₀²] > 0` and P strictly reduces the impedance dispersion
(`σ_Z2_P < σ_Z2`) while leaving `Z̄`, `Var[Φ₀]` fixed, then
`Var[N]_P < Var[N]`. -/
theorem R_432_var_decrease_via_sigmaZ
    (Z_bar VarPhi σ_Z2 σ_Z2_P EPhi2 : ℝ)
    (h_EPhi2_pos : 0 < EPhi2)
    (h_dec : σ_Z2_P < σ_Z2) :
    varN Z_bar VarPhi σ_Z2_P EPhi2 < varN Z_bar VarPhi σ_Z2 EPhi2 := by
  unfold varN
  nlinarith [mul_lt_mul_of_pos_right h_dec h_EPhi2_pos]

/-- **R.432 (ii, general) — any dispersion drop lowers `Var[N]`.**

Combined form: if P does not increase either dispersion
(`VarPhi_P ≤ VarPhi`, `σ_Z2_P ≤ σ_Z2`) and strictly decreases at least one
with a positive coefficient (here: `VarPhi_P < VarPhi` and `Z̄² > 0`, with
`E[Φ₀²] ≥ 0`), then `Var[N]_P < Var[N]`. -/
theorem R_432_var_strict_decrease
    (Z_bar VarPhi VarPhi_P σ_Z2 σ_Z2_P EPhi2 : ℝ)
    (h_Z : Z_bar ≠ 0)
    (h_EPhi2_nonneg : 0 ≤ EPhi2)
    (h_VarPhi : VarPhi_P < VarPhi)
    (h_sigma : σ_Z2_P ≤ σ_Z2) :
    varN Z_bar VarPhi_P σ_Z2_P EPhi2 < varN Z_bar VarPhi σ_Z2 EPhi2 := by
  unfold varN
  have hZ2 : 0 < Z_bar ^ 2 := by positivity
  have hterm1 : Z_bar ^ 2 * VarPhi_P < Z_bar ^ 2 * VarPhi :=
    mul_lt_mul_of_pos_left h_VarPhi hZ2
  have hterm2 : σ_Z2_P * EPhi2 ≤ σ_Z2 * EPhi2 :=
    mul_le_mul_of_nonneg_right h_sigma h_EPhi2_nonneg
  linarith

/-- **R.432 — the structural one-order-invariance.**

P simultaneously (a) keeps `E[N]` exactly fixed and (b) strictly lowers
`Var[N]`.  Packaged: under unchanged means (`Z̄, E[Φ₀]`) and a strict
`Var[Φ₀]` drop, `E[N]` is invariant **and** `Var[N]` strictly decreases —
the defining signature of P versus R/T/C. -/
theorem R_432_plurality_signature
    (Z_bar EPhi VarPhi VarPhi_P σ_Z2 EPhi2 : ℝ)
    (h_Z : Z_bar ≠ 0)
    (h_VarPhi : VarPhi_P < VarPhi) :
    meanN Z_bar EPhi = meanN Z_bar EPhi ∧
      varN Z_bar VarPhi_P σ_Z2 EPhi2 < varN Z_bar VarPhi σ_Z2 EPhi2 := by
  refine ⟨rfl, ?_⟩
  exact R_432_var_decrease_via_VarPhi Z_bar VarPhi VarPhi_P σ_Z2 EPhi2 h_Z h_VarPhi

end PluralityPrimitive

end MIP
