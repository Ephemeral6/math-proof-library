/-
Result R.114 — `Z⁻¹` is not a monotone function of `|K|`
(`Cj.19` refutation of strict independence + sign-indefiniteness).

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.114
(攻击 #11, Cj.19 Z⁻¹ vs |K| 独立性, counterexample construction, "B").

**Statement.** Cj.19 claimed `Z⁻¹` is *independent* of `|K|` (no functional
relation).  R.114 refutes "strict independence" but shows the relation's
**sign is indefinite**: there is no monotone function `g` with
`Z⁻¹ = g(|K|)` across agents, because the data realises *both* signs of the
`|K| ↦ Z⁻¹` slope:

* **balanced training** (knowledge + collaboration): `|K| ↑ ⟹ Z ↓ ⟹ Z⁻¹ ↑`
  — positive correlation (frontier example 1:
  `(|K|,Z) = (100,10) → (1000,1)`, so `Z⁻¹ : 1/10 → 1`);
* **knowledge-overfit training**: `|K| ↑ ⟹ Z ↑ ⟹ Z⁻¹ ↓` — negative
  correlation (frontier example 2:
  `(|K|,Z) = (100,10) → (1000,100)`, so `Z⁻¹ : 1/10 → 1/100`).

So `|K|` increases in *both* scenarios while `Z⁻¹` moves in *opposite*
directions, which is incompatible with any monotone `g`.

**Pure-math content.** A monotone (here: non-decreasing) function cannot
send a pair `(x₁ < x₂)` to a strictly *decreasing* image; exhibiting one
non-decreasing instance and one strictly-decreasing instance over the same
ordered abscissa pair contradicts the existence of any single monotone `g`.
We encode the **counterexample kernel** with the frontier's explicit
numbers.

**This file is `axiom`-free.**  `Z` and `|K|` are plain reals; the two
training regimes are the two explicit data points.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace ZinvKappaNonMonotone

/-- The reciprocal-impedance observable `Z⁻¹`. -/
noncomputable def Zinv (Z : ℝ) : ℝ := Z⁻¹

/-- **R.114 (positive-correlation regime).**

Balanced training: `(|K|, Z) : (100, 10) → (1000, 1)`.  `|K|` increases and
`Z⁻¹` increases (`1/10 < 1`). -/
theorem R_114_balanced_positive :
    (100 : ℝ) < 1000 ∧ Zinv 10 < Zinv 1 := by
  refine ⟨by norm_num, ?_⟩
  unfold Zinv; norm_num

/-- **R.114 (negative-correlation regime).**

Knowledge-overfit training: `(|K|, Z) : (100, 10) → (1000, 100)`.  `|K|`
increases but `Z⁻¹` *decreases* (`1/100 < 1/10`). -/
theorem R_114_overfit_negative :
    (100 : ℝ) < 1000 ∧ Zinv 100 < Zinv 10 := by
  refine ⟨by norm_num, ?_⟩
  unfold Zinv; norm_num

/-- **R.114 — no monotone functional relation `Z⁻¹ = g(|K|)`.**

Suppose for contradiction a single non-decreasing `g : ℝ → ℝ` reproduced the
reciprocal impedance from `|K|` in *both* regimes, i.e. for the four
realised agents the value `Z⁻¹` equals `g(|K|)`.  Both regimes share the
abscissa pair `(100, 1000)` with `100 < 1000`, so monotonicity forces
`g 100 ≤ g 1000`.  But:

* balanced: `g 100 = Z⁻¹(Z=10) = 1/10`, `g 1000 = Z⁻¹(Z=1) = 1`;
* overfit:  `g 100 = Z⁻¹(Z=10) = 1/10`, `g 1000 = Z⁻¹(Z=100) = 1/100`.

The overfit regime needs `g 1000 = 1/100 < 1/10 = g 100`, contradicting
`g 100 ≤ g 1000`.  Hence **no** monotone `g` fits both regimes: the
`|K| ↦ Z⁻¹` relation is sign-indefinite. -/
theorem R_114_no_monotone_relation :
    ¬ ∃ g : ℝ → ℝ,
        (∀ x y : ℝ, x ≤ y → g x ≤ g y) ∧   -- g non-decreasing
        g 100 = Zinv 10 ∧                    -- shared low-|K| point
        g 1000 = Zinv 1 ∧                    -- balanced high-|K| point
        g 1000 = Zinv 100 := by              -- overfit high-|K| point
  rintro ⟨g, hmono, h_lo, h_bal, h_ovf⟩
  -- Monotone ⟹ g 100 ≤ g 1000.
  have hle : g 100 ≤ g 1000 := hmono 100 1000 (by norm_num)
  -- But g 100 = 1/10 and g 1000 = 1/100 (the overfit value), so g 100 > g 1000.
  rw [h_lo, h_ovf] at hle
  -- hle : Zinv 10 ≤ Zinv 100, i.e. 1/10 ≤ 1/100 — false.
  unfold Zinv at hle
  norm_num at hle

/-- **R.114 — the two regimes are genuinely distinct (slope sign flips).**

Quantitative restatement: the discrete slope
`Δ(Z⁻¹)/Δ|K| = (Z⁻¹(high) − Z⁻¹(low)) / (|K|_high − |K|_low)` is **positive**
in the balanced regime and **negative** in the overfit regime, over the
*same* `Δ|K| = 900 > 0`.  A monotone relation would force a single fixed
sign. -/
theorem R_114_slope_sign_flip :
    (Zinv 1 - Zinv 10) / (1000 - 100) > 0 ∧
    (Zinv 100 - Zinv 10) / (1000 - 100) < 0 := by
  unfold Zinv
  constructor
  · norm_num
  · norm_num

end ZinvKappaNonMonotone

end MIP
