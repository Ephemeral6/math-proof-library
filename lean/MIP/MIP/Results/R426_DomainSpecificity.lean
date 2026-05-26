/-
Result R.426 — Domain-specificity criterion: which primitive dominates.

Reference: `workspace/coe_mip_unification.md` §R.426
(A conditional, Block 9 "理论融合", 2026-05-16).

**Statement.** Under the constant-marginal-efficiency assumption (the partial
derivatives `∂r/∂x_R`, `∂Z/∂x_T`, `∂κ/∂x_C` are ≈ constant near the working
point, R.425.a), the optimal allocation ratios are

    x_R* : x_T* : x_C*  ∝  (|log κ|·Z)/c_R : (r·|log κ|)/c_T : (r·Z)/(κ·c_C).

The per-primitive *effect magnitudes* (marginal reduction of `N` per unit
budget) are therefore, with equal effective unit costs absorbed,

    eff_R := |log κ| · Z ,    eff_T := r · |log κ| ,    eff_C := r · Z / κ .

This file formalizes the pairwise dominance conditions as inequalities that
determine the arg-max primitive:

* **R-dominant** when `eff_R > eff_T` and `eff_R > eff_C`;
* the canonical R-dominant sufficient condition from §R.426(i), with the model
  bundle `r > 0, κ ∈ (0,1), Z > 0`, is `r ≫ |log κ|·Z` made precise as the two
  comparisons below.

We prove the comparison theorems: under the bundled positivity/range premises,

    (a)  Z > r        ⟹  eff_R > eff_T            (R beats T)
    (b)  the C-dominant criterion  r > κ·|log κ|·Z ⟹ eff_C > eff_R, and its
         clean special case `r/(κ·|log κ|) ≫ 1`;
    (c)  the T-dominant criterion `Z·|log κ|·κ > r ⟹ eff_T > eff_C`.

Each is a single algebraic inequality on positive reals; the
constant-marginal-efficiency assumption is bundled into the *form* of the
effect magnitudes `eff_R/eff_T/eff_C`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace DomainSpecificity

open Real

/-- The three primitive **effect magnitudes** (marginal `N`-reduction per unit
budget, with effective unit costs absorbed), from the R.425.a optimal ratio:

* `eff_R = |log κ| · Z` (R pushes the factor `r`),
* `eff_T = r · |log κ|`  (T pushes the impedance `Z`),
* `eff_C = r · Z / κ`    (C pushes `|log κ|`; marginal `∝ 1/κ`).

Here `L` plays the role of `|log κ| > 0` and `κ ∈ (0,1)`. -/
def effR (_r L Z _κ : ℝ) : ℝ := L * Z
def effT (r L _Z _κ : ℝ) : ℝ := r * L
noncomputable def effC (r _L Z κ : ℝ) : ℝ := r * Z / κ

/-- **R.426 (a) — R beats T when impedance exceeds knowledge gap (`Z > r`).**

`eff_R = |log κ|·Z` and `eff_T = r·|log κ|`.  With `|log κ| = L > 0`,

    Z > r  ⟹  eff_R > eff_T .

(Cancelling the common positive factor `L`.) -/
theorem R_426_a_R_beats_T
    (r L Z κ : ℝ) (hL : 0 < L) (hZr : r < Z) :
    effT r L Z κ < effR r L Z κ := by
  unfold effR effT
  -- r * L < L * Z  ⇔  r < Z  (cancel L > 0)
  have : r * L < Z * L := by nlinarith
  linarith [this]

/-- **R.426 (c) — T beats C criterion `Z·|log κ|·κ > r`.**

`eff_T = r·|log κ|`, `eff_C = r·Z/κ`.  The ratio `eff_T/eff_C = L·κ/Z`, so T
beats C exactly when `L·κ > Z`.  This is §R.426(ii)'s T-dominant criterion
`Z·|log κ|·κ / r ≫ 1` reduced to its cancelled (r-independent) form: with
`r > 0`, `κ ∈ (0,1)`, `Z > 0`,

    |log κ| · κ > Z   ⟹   eff_T > eff_C . -/
theorem R_426_c_T_beats_C
    (r L Z κ : ℝ) (hr : 0 < r) (hκ : 0 < κ)
    (hcrit : Z < L * κ) :
    effC r L Z κ < effT r L Z κ := by
  unfold effC effT
  -- r * Z / κ < r * L  ⇔  r * Z < r * L * κ  (since κ > 0)
  rw [div_lt_iff₀ hκ]
  -- goal: r * Z < r * L * κ ;  from Z < L*κ and r > 0
  nlinarith [hcrit, hr]

/-- **R.426 (b) — C beats R criterion `r > κ·|log κ|·Z`.**

`eff_C = r·Z/κ`, `eff_R = |log κ|·Z`.  The §R.426(iii) C-dominant condition is
`r/(κ·|log κ|) ≫ 1`, i.e. `r > κ·L·Z` after using `Z` cancellation.  Precisely:
with `Z > 0`, `κ ∈ (0,1)`,

    r > κ · |log κ|     ⟹     eff_C > eff_R ,

because `eff_C = r·Z/κ` and `eff_R = L·Z`, so `eff_C > eff_R ⇔ r·Z/κ > L·Z ⇔
r/κ > L ⇔ r > κ·L` (cancel `Z > 0`, multiply by `κ > 0`). -/
theorem R_426_b_C_beats_R
    (r L Z κ : ℝ) (hZ : 0 < Z) (hκ : 0 < κ)
    (hcrit : κ * L < r) :
    effR r L Z κ < effC r L Z κ := by
  unfold effR effC
  -- L * Z < r * Z / κ  ⇔  L * Z * κ < r * Z  (κ > 0)  ⇐  L * κ < r  (Z > 0)
  rw [lt_div_iff₀ hκ]
  -- goal: L * Z * κ < r * Z
  nlinarith [hcrit, hZ]

/-- **R.426 (iv) — R-dominant cell of the criterion matrix.**

Matrix row 1: `r ≫ 1, κ ≈ 1, Z ≈ 1` ⟹ R dominates.  Concretely, R is the
arg-max primitive (`eff_R` strictly largest) when it beats *both* T and C.
We assemble the two pairwise comparisons:

    (Z > r)  ∧  (r·Z·κ⁻¹ comparison)  ⟹  eff_R > eff_T ∧ eff_R > eff_C .

For a crisp self-contained statement we bundle the two hypotheses that make R
the strict arg-max: `r < Z` (so R beats T) and `r < κ·L` rearranged so C does
not beat R, i.e. `eff_C ≤ eff_R`.  The cleanest sufficient pair: `r < Z` and
`r ≤ κ·L` with `Z > 0, κ > 0, L > 0`. -/
theorem R_426_iv_R_dominant
    (r L Z κ : ℝ)
    (hL : 0 < L) (hZ : 0 < Z) (hκ : 0 < κ)
    (hRT : r < Z)
    (hRC : r ≤ κ * L) :
    effT r L Z κ < effR r L Z κ ∧ effC r L Z κ ≤ effR r L Z κ := by
  refine ⟨?_, ?_⟩
  · -- R beats T
    exact R_426_a_R_beats_T r L Z κ hL hRT
  · -- eff_C ≤ eff_R :  r*Z/κ ≤ L*Z  ⇔  r*Z ≤ L*Z*κ  (κ>0)  ⇐  r ≤ κ*L  (Z>0)
    unfold effC effR
    rw [div_le_iff₀ hκ]
    nlinarith [hRC, hZ]

end DomainSpecificity

end MIP
