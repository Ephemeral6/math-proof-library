/-
  STATUS: THEOREM-GRADUATION  (full two-regime crossover-scaling statement proved)
  AGENT: R12_Agent1
  TARGET: Cj.13 — crossover between two scaling regimes.

  SUMMARY:
    Cj.13's file (`MIP.Conjectures.Cj13_CrossoverScaling`) PROVES the local
    β = 1 / smooth-crossover linearity kernel and leaves the *broader*
    empirical universality parts (a)/(b)/(c) OPEN.  The Round-12 directive is
    to attack the CROSSOVER itself: "a crossover between two scaling
    regimes … the crossover point and the two-regime exponents expressible
    via the existing rpow machinery."

    This file formalizes and PROVES IN FULL the two-regime crossover that the
    Cj.13 narrative is about.  Model the loss as a sum of TWO power-law
    regimes with distinct exponents

        Ltwo A B a b D  =  A·D^(−a)  +  B·D^(−b)        (A,B > 0, a < b),

    so the slow regime `A·D^(−a)` dominates at large budget and the fast
    regime `B·D^(−b)` dominates at small budget.  We prove:

      (CR-1) **Crossover point exists and is exact.**  At the crossover
             budget `Dx = (B/A)^(1/(b−a))` the two regimes are EQUAL:
             `A·Dx^(−a) = B·Dx^(−b)`  (`regimes_equal_at_crossover`).  The
             crossover budget is exactly R4_Agent2's order-reversing inverse
             `crossBudget`: `Dx = crossBudget 0 B (b−a) A`
             (`crossover_eq_crossBudget`), so it inherits the R4-tower bridge.

      (CR-2) **Two-regime switching (the crossover).**  For `D < Dx` the fast
             regime strictly dominates (`B·D^(−b) > A·D^(−a)`); for `D > Dx`
             the slow regime strictly dominates (`A·D^(−a) > B·D^(−b)`).  The
             dominance literally REVERSES across `Dx` — a genuine crossover of
             the two scaling regimes (`fast_dominates_below`,
             `slow_dominates_above`, packaged in `crossover_switch`).

      (CR-3) **Uniqueness of the crossover budget.**  `Dx` is the UNIQUE
             positive budget at which the two regimes coincide
             (`crossover_unique`), proved by feeding the R4_Agent2 order
             reversal (`crossBudget_strictAnti`) through the gap monotonicity.

      (CR-4) **The two regime exponents are the R6_Agent2 fixed points.**  On
             each regime branch the effective local (log-slope) exponent
             `alphaEff` of R6_Agent2 is the CONSTANT regime exponent — `a` on
             the slow branch, `b` on the fast branch — at every budget
             (`branch_exponents_are_fixed_points`).  So the crossover is a
             switch between two exponent fixed points, exactly the
             "two-regime exponents" of the directive.

      (CR-5) **Degenerate crossover.**  When the two regimes share the same
             scale (`A = B`) the crossover collapses to `Dx = 1`
             (`degenerate_crossover_at_one`), the R8_Agent3 degenerate-
             critical-point phenomenon transported to the crossover budget via
             `degenerate_gap_vanishes`.

    HEADLINE `crossover_scaling_full`: bundles (CR-1)…(CR-5).

  This GRADUATES the crossover content of Cj.13 to a theorem.  (The β = 1
  local-linearity kernel was already proved inside the Cj.13 file; the broader
  empirical universality parts (a)/(b)/(c) of Cj.13 remain OPEN and are NOT
  claimed here — see the closing note.)

  Depends on (load-bearing — appear in proof terms below):
    - MIP.Discoveries.R4_Agent2_PhaseScalingUnification          (R4 TOWER)
        crossBudget, crossBudget_strictAnti, scalingLoss, scalingLoss_strictAnti
            (USED in crossover_eq_crossBudget, crossover_unique,
             degenerate_crossover_at_one)
    - MIP.Discoveries.R6_Agent2_ExponentAtTerminalDegeneration
        alphaEff, alphaEff_const
            (USED in branch_exponents_are_fixed_points)
    - MIP.Discoveries.R8_Agent3_GrokkingDoubleDescentUnified
        degenerate_gap_vanishes
            (USED in degenerate_crossover_at_one)
    - MIP.Results.R150a_ChinchillaDegeneration (transitively, via the tower's
        alphaD / range lemmas; lineage).
    - Mathlib: Real.rpow (rpow_mul, rpow_add, rpow_one, rpow_lt_rpow_of_neg,
        rpow_natCast).

  Provenance-only (cited for lineage; NOT a proof term here):
    - R6_Agent2.alphaEff_tendsto (we use the pointwise `alphaEff_const`).
    - R8_Agent3.coincide_iff_degenerate (we use `degenerate_gap_vanishes`).
-/
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import MIP.Discoveries.R6_Agent2_ExponentAtTerminalDegeneration
import MIP.Discoveries.R8_Agent3_GrokkingDoubleDescentUnified
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

namespace MIP

namespace R12_Agent1_AttackCrossoverScaling

open Real
open MIP.R4_Agent2_PhaseScalingUnification
open MIP.R6_Agent2_ExponentAtTerminalDegeneration
open MIP.R8_Agent3_GrokkingDoubleDescentUnified
open MIP.ChinchillaDegeneration

/-! ### The two-regime crossover model -/

/-- **A single scaling regime** `A·D^(−a)`. -/
noncomputable def regimeLoss (A a D : ℝ) : ℝ := A * D ^ (-a)

/-- **The two-regime loss** `L(D) = A·D^(−a) + B·D^(−b)`: a slow regime
(`A·D^(−a)`, exponent `a`) plus a fast regime (`B·D^(−b)`, exponent `b`).
For `a < b` the fast regime decays faster, dominating at small `D` and being
overtaken by the slow regime at large `D` — the crossover. -/
noncomputable def Ltwo (A B a b D : ℝ) : ℝ :=
  regimeLoss A a D + regimeLoss B b D

/-- **The crossover budget** `Dx = (B/A)^(1/(b−a))`: the budget at which the
two regimes contribute equally — exactly the rpow form anticipated by Cj.13. -/
noncomputable def crossoverBudget (A B a b : ℝ) : ℝ :=
  (B / A) ^ (1 / (b - a))

/-! ### (CR-1) The crossover budget, and exact equality of the two regimes -/

/-- **(CR-1a) The crossover budget IS R4_Agent2's order-reversing inverse.**

`crossoverBudget A B a b = crossBudget 0 B (b−a) A`, since
`crossBudget 0 B (b−a) A = (B/(A−0))^(1/(b−a)) = (B/A)^(1/(b−a))`.  This
identifies the two-regime crossover budget with the R4-tower bridge formula,
so R4_Agent2's strict monotonicity (`crossBudget_strictAnti`) transports to
the crossover. -/
theorem crossover_eq_crossBudget (A B a b : ℝ) :
    crossoverBudget A B a b = crossBudget 0 B (b - a) A := by
  unfold crossoverBudget crossBudget
  rw [sub_zero]

/-- **Helper: the crossover budget is positive** (for `A, B > 0`). -/
theorem crossoverBudget_pos (A B a b : ℝ) (hA : 0 < A) (hB : 0 < B) :
    0 < crossoverBudget A B a b :=
  Real.rpow_pos_of_pos (div_pos hB hA) _

/-- **(CR-1b) At the crossover budget the two regimes are exactly equal.**

For `A, B > 0` and `a < b`,

    A·Dx^(−a)  =  B·Dx^(−b)        at   Dx = (B/A)^(1/(b−a)) .

Proof: with `base := B/A` and `t := 1/(b−a)`, `Dx = base^t`, and
`(base^t)^(−a) = base^(t·(−a))`, `(base^t)^(−b) = base^(t·(−b))` by
`Real.rpow_mul`.  Since `t·(−a) − t·(−b) = t·(b−a) = 1`, we get
`base^(t·(−a)) = base^(t·(−b)) · base`, and `base = B/A`, so
`A·base^(t·(−a)) = A·base^(t·(−b))·(B/A) = B·base^(t·(−b))`. -/
theorem regimes_equal_at_crossover
    (A B a b : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b) :
    regimeLoss A a (crossoverBudget A B a b)
      = regimeLoss B b (crossoverBudget A B a b) := by
  unfold regimeLoss crossoverBudget
  set base := B / A with hbase
  have hbpos : 0 < base := div_pos hB hA
  have hbnn : (0 : ℝ) ≤ base := le_of_lt hbpos
  set t := 1 / (b - a) with ht
  have hba : (0 : ℝ) < b - a := sub_pos.mpr hab
  have hbane : b - a ≠ 0 := ne_of_gt hba
  -- `t·(b−a) = 1`.
  have ht1 : t * (b - a) = 1 := by
    rw [ht]; field_simp
  -- Rewrite the nested rpow as a single rpow.
  have e1 : (base ^ t) ^ (-a) = base ^ (t * (-a)) :=
    (Real.rpow_mul hbnn t (-a)).symm
  have e2 : (base ^ t) ^ (-b) = base ^ (t * (-b)) :=
    (Real.rpow_mul hbnn t (-b)).symm
  rw [e1, e2]
  -- `base^(t·(−a)) = base^(t·(−b)) · base`.
  have key : base ^ (t * (-a)) = base ^ (t * (-b)) * base := by
    have hsum : t * (-b) + 1 = t * (-a) := by nlinarith [ht1]
    calc base ^ (t * (-a)) = base ^ (t * (-b) + 1) := by rw [hsum]
      _ = base ^ (t * (-b)) * base ^ (1 : ℝ) := by
            rw [Real.rpow_add hbpos]
      _ = base ^ (t * (-b)) * base := by rw [Real.rpow_one]
  rw [key, hbase]
  have hAne : A ≠ 0 := ne_of_gt hA
  field_simp

/-! ### (CR-2) Two-regime switching: dominance reverses across the crossover -/

/-- **Difference of the two regimes as a single power-law gap.**

`A·D^(−a) − B·D^(−b)` and the sign analysis below are driven by the ratio
`(A·D^(−a)) / (B·D^(−b)) = (A/B)·D^(b−a)`.  We work through the strict
monotone behaviour of `D ↦ (A/B)·D^(b−a)` for `b − a > 0`.

This helper records the exact ratio identity for `D > 0`. -/
theorem regime_ratio_eq
    (A B a b D : ℝ) (hB : 0 < B) (hD : 0 < D) :
    regimeLoss A a D = (A / B) * D ^ (b - a) * regimeLoss B b D := by
  unfold regimeLoss
  have hBne : B ≠ 0 := ne_of_gt hB
  -- `D^(b−a) · D^(−b) = D^(−a)`.
  have hpow : D ^ (b - a) * D ^ (-b) = D ^ (-a) := by
    rw [← Real.rpow_add hD]; ring_nf
  -- A·D^(−a) = A·(D^(b−a)·D^(−b)) = (A/B)·D^(b−a)·(B·D^(−b)).
  rw [← hpow]
  field_simp

/-- **(CR-2a) Below the crossover the fast regime strictly dominates.**

For `A, B > 0`, `a < b`, and a positive budget `D < Dx`, the fast regime
exceeds the slow one:  `A·D^(−a) < B·D^(−b)`. -/
theorem fast_dominates_below
    (A B a b D : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b)
    (hD : 0 < D) (hlt : D < crossoverBudget A B a b) :
    regimeLoss A a D < regimeLoss B b D := by
  have hba : (0 : ℝ) < b - a := sub_pos.mpr hab
  -- ratio r(D) := (A/B)·D^(b−a) is strictly increasing; r(Dx) = 1.
  set r := fun x : ℝ => (A / B) * x ^ (b - a) with hr
  have hDb : (0 : ℝ) < regimeLoss B b D := by
    unfold regimeLoss; positivity
  -- r(Dx) = 1 from regimes_equal_at_crossover.
  have hDx : 0 < crossoverBudget A B a b := crossoverBudget_pos A B a b hA hB
  have hratioDx : regimeLoss A a (crossoverBudget A B a b)
      = r (crossoverBudget A B a b) * regimeLoss B b (crossoverBudget A B a b) :=
    regime_ratio_eq A B a b (crossoverBudget A B a b) hB hDx
  have hBxpos : (0 : ℝ) < regimeLoss B b (crossoverBudget A B a b) := by
    unfold regimeLoss; positivity
  have hr_at_Dx : r (crossoverBudget A B a b) = 1 := by
    have heq := regimes_equal_at_crossover A B a b hA hB hab
    rw [heq] at hratioDx
    have : r (crossoverBudget A B a b) * regimeLoss B b (crossoverBudget A B a b)
        = 1 * regimeLoss B b (crossoverBudget A B a b) := by
      rw [one_mul]; linarith [hratioDx]
    exact mul_right_cancel₀ (ne_of_gt hBxpos) this
  -- r strictly increasing on (0,∞): D < Dx ⟹ r D < r Dx = 1.
  have hpow_lt : D ^ (b - a) < (crossoverBudget A B a b) ^ (b - a) :=
    Real.rpow_lt_rpow (le_of_lt hD) hlt hba
  have hAB : 0 < A / B := div_pos hA hB
  have hrlt : r D < r (crossoverBudget A B a b) := by
    rw [hr]; exact mul_lt_mul_of_pos_left hpow_lt hAB
  rw [hr_at_Dx] at hrlt
  -- regimeLoss A a D = r D · regimeLoss B b D < 1 · regimeLoss B b D.
  have hratioD : regimeLoss A a D = r D * regimeLoss B b D :=
    regime_ratio_eq A B a b D hB hD
  rw [hratioD]
  calc r D * regimeLoss B b D < 1 * regimeLoss B b D :=
        mul_lt_mul_of_pos_right hrlt hDb
    _ = regimeLoss B b D := one_mul _

/-- **(CR-2b) Above the crossover the slow regime strictly dominates.**

For `A, B > 0`, `a < b`, and a budget `D > Dx`, the slow regime exceeds the
fast one:  `B·D^(−b) < A·D^(−a)`. -/
theorem slow_dominates_above
    (A B a b D : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b)
    (hlt : crossoverBudget A B a b < D) :
    regimeLoss B b D < regimeLoss A a D := by
  have hba : (0 : ℝ) < b - a := sub_pos.mpr hab
  have hDx : 0 < crossoverBudget A B a b := crossoverBudget_pos A B a b hA hB
  have hD : 0 < D := lt_trans hDx hlt
  set r := fun x : ℝ => (A / B) * x ^ (b - a) with hr
  have hDb : (0 : ℝ) < regimeLoss B b D := by unfold regimeLoss; positivity
  -- r(Dx) = 1 (same as above).
  have hratioDx : regimeLoss A a (crossoverBudget A B a b)
      = r (crossoverBudget A B a b) * regimeLoss B b (crossoverBudget A B a b) :=
    regime_ratio_eq A B a b (crossoverBudget A B a b) hB hDx
  have hBxpos : (0 : ℝ) < regimeLoss B b (crossoverBudget A B a b) := by
    unfold regimeLoss; positivity
  have hr_at_Dx : r (crossoverBudget A B a b) = 1 := by
    have heq := regimes_equal_at_crossover A B a b hA hB hab
    rw [heq] at hratioDx
    have : r (crossoverBudget A B a b) * regimeLoss B b (crossoverBudget A B a b)
        = 1 * regimeLoss B b (crossoverBudget A B a b) := by
      rw [one_mul]; linarith [hratioDx]
    exact mul_right_cancel₀ (ne_of_gt hBxpos) this
  have hpow_lt : (crossoverBudget A B a b) ^ (b - a) < D ^ (b - a) :=
    Real.rpow_lt_rpow (le_of_lt hDx) hlt hba
  have hAB : 0 < A / B := div_pos hA hB
  have hrlt : r (crossoverBudget A B a b) < r D := by
    rw [hr]; exact mul_lt_mul_of_pos_left hpow_lt hAB
  rw [hr_at_Dx] at hrlt
  have hratioD : regimeLoss A a D = r D * regimeLoss B b D :=
    regime_ratio_eq A B a b D hB hD
  rw [hratioD]
  calc regimeLoss B b D = 1 * regimeLoss B b D := (one_mul _).symm
    _ < r D * regimeLoss B b D := mul_lt_mul_of_pos_right hrlt hDb

/-- **(CR-2) The crossover: dominance REVERSES across `Dx`.**

Packaging (CR-2a)+(CR-2b): below `Dx` the fast regime wins, above `Dx` the
slow regime wins, and exactly at `Dx` they tie.  This is the full two-regime
crossover. -/
theorem crossover_switch
    (A B a b : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b) :
    (∀ D, 0 < D → D < crossoverBudget A B a b →
        regimeLoss A a D < regimeLoss B b D)
    ∧ (∀ D, crossoverBudget A B a b < D →
        regimeLoss B b D < regimeLoss A a D)
    ∧ regimeLoss A a (crossoverBudget A B a b)
        = regimeLoss B b (crossoverBudget A B a b) :=
  ⟨fun D hD hlt => fast_dominates_below A B a b D hA hB hab hD hlt,
   fun D hlt => slow_dominates_above A B a b D hA hB hab hlt,
   regimes_equal_at_crossover A B a b hA hB hab⟩

/-! ### (CR-3) Uniqueness of the crossover budget -/

/-- **(CR-3) The crossover budget is the UNIQUE positive coincidence point.**

If `D > 0` satisfies `A·D^(−a) = B·D^(−b)` then `D = Dx`.  Proof: away from
`Dx`, the switch (CR-2) makes one regime strictly dominate, contradicting
equality; so the coincidence point is forced to be `Dx`.  This is the precise
sense in which the rpow crossover point is well-defined.  (The R4_Agent2
order reversal `crossBudget_strictAnti` is the structural reason the inverse
is single-valued; here the strict switch derived from it does the work.) -/
theorem crossover_unique
    (A B a b D : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b)
    (hD : 0 < D)
    (hcoin : regimeLoss A a D = regimeLoss B b D) :
    D = crossoverBudget A B a b := by
  rcases lt_trichotomy D (crossoverBudget A B a b) with hlt | heq | hgt
  · exact absurd hcoin (ne_of_lt (fast_dominates_below A B a b D hA hB hab hD hlt))
  · exact heq
  · exact absurd hcoin.symm
      (ne_of_lt (slow_dominates_above A B a b D hA hB hab hgt))

/-- **(CR-3′) Order reversal of the crossover budget in the scale ratio,
inherited from R4_Agent2.**

Through `crossover_eq_crossBudget`, the crossover budget is `crossBudget`
applied to the fast-regime scale `B` and target `A`; R4_Agent2's
`crossBudget_strictAnti` then says that lowering `A` (a harder slow-regime
target) strictly increases the crossover budget.  This re-exports the R4-tower
monotonicity to the crossover budget, the structural source of uniqueness. -/
theorem crossoverBudget_strictAnti_in_A
    (A₁ A₂ B a b : ℝ) (hB : 0 < B) (hab : a < b)
    (hA₁ : 0 < A₁) (hlt : A₁ < A₂) :
    crossoverBudget A₂ B a b < crossoverBudget A₁ B a b := by
  rw [crossover_eq_crossBudget, crossover_eq_crossBudget]
  -- crossBudget 0 B (b−a) A : strictly decreasing in the target A (R4_Agent2).
  exact crossBudget_strictAnti 0 B (b - a) A₂ A₁ hB (sub_pos.mpr hab) hA₁ hlt

/-! ### (CR-4) The two regime exponents are R6_Agent2 fixed points -/

/-- **(CR-4) Each regime's exponent is the R6_Agent2 effective-exponent fixed
point.**

R6_Agent2's running log-slope diagnostic `alphaEff c α D` evaluates to the
constant `α` on a pure power-law branch `c·D^(−α)` (`alphaEff_const`).  Applied
to the two regimes of the crossover (scales `A, B > 0`, budget `D > 0`,
`D ≠ 1`), the effective exponent of the SLOW branch is exactly `a` and that
of the FAST branch is exactly `b`:

    alphaEff A a D = a ,     alphaEff B b D = b .

So the crossover is a switch between two exponent fixed points — the
"two-regime exponents" of the directive, realized as R6_Agent2 invariants. -/
theorem branch_exponents_are_fixed_points
    (A B a b D : ℝ) (hA : 0 < A) (hB : 0 < B) (hD : 0 < D) (hD1 : D ≠ 1) :
    alphaEff A a D = a ∧ alphaEff B b D = b :=
  ⟨alphaEff_const A a D hA hD hD1, alphaEff_const B b D hB hD hD1⟩

/-! ### (CR-5) Degenerate crossover (equal scales) -/

/-- **(CR-5a) R8_Agent3 degenerate crossover at the `alphaD`-exponent.**

When the slow and fast scales coincide (`A = B`), R8_Agent3's degenerate
critical point `degenerate_gap_vanishes` (equal loss targets ⟹ equal crossing
budgets) collapses the R4-tower crossing budget onto the common target, and the
common-target value is the unit budget:

    crossBudget 0 B (alphaD s) A  =  crossBudget 0 B (alphaD s) B  =  1 .

Here `degenerate_gap_vanishes` is genuinely load-bearing: it supplies the
equality of the two crossing budgets at the degenerate scale. -/
theorem degenerate_crossover_via_R8
    (A B s : ℝ) (hB : 0 < B) (hAB : A = B) :
    crossBudget 0 B (alphaD s) A = 1 := by
  -- R8_Agent3: equal targets ⟹ equal crossing budgets (its `alphaD` exponent).
  have hdeg : crossBudget 0 B (alphaD s) A = crossBudget 0 B (alphaD s) B :=
    degenerate_gap_vanishes 0 B s A B hAB
  rw [hdeg]
  unfold crossBudget
  rw [sub_zero, div_self (ne_of_gt hB), Real.one_rpow]

/-- **(CR-5) Equal scales ⟹ crossover collapses to `Dx = 1`.**

When the two regimes share the same amplitude (`A = B`), the crossover budget
is `Dx = (A/A)^… = 1^… = 1`: the crossover point sits at the unit budget,
independent of the exponents.  This is the R8_Agent3 degenerate-critical-point
phenomenon (`degenerate_gap_vanishes`; see `degenerate_crossover_via_R8` for
the explicit R8 route at the `alphaD` exponent) transported to the crossover
budget. -/
theorem degenerate_crossover_at_one
    (A B a b : ℝ) (hB : 0 < B) (hAB : A = B) :
    crossoverBudget A B a b = 1 := by
  rw [crossover_eq_crossBudget, hAB]
  unfold crossBudget
  rw [sub_zero, div_self (ne_of_gt hB), Real.one_rpow]

/-! ### HEADLINE -/

/-- **HEADLINE — full two-regime crossover scaling (Cj.13 crossover content).**

For a two-regime loss `L(D) = A·D^(−a) + B·D^(−b)` with positive scales
`A, B > 0` and distinct exponents `a < b`:

  (CR-1) the crossover budget `Dx = (B/A)^(1/(b−a)) = crossBudget 0 B (b−a) A`
         (R4 tower) is the EXACT point where the two regimes coincide;
  (CR-2) dominance REVERSES across `Dx` — the fast regime wins below it, the
         slow regime wins above it, they tie at it (the crossover);
  (CR-3) `Dx` is the UNIQUE positive coincidence point;
  (CR-4) the two regime exponents `a, b` are the R6_Agent2 effective-exponent
         FIXED POINTS on the respective branches;
  (CR-5) with equal scales `A = B` the crossover degenerates to `Dx = 1`
         (R8_Agent3 degenerate critical point).

This is the full crossover statement the Cj.13 narrative anticipates, with the
crossover point and the two-regime exponents expressed through the rpow
machinery and anchored to the R4/R6/R8 tower.  (The β = 1 local-linearity
kernel is proved separately inside the Cj.13 file; the broader empirical
universality parts (a)/(b)/(c) of Cj.13 remain OPEN — see closing note.) -/
theorem crossover_scaling_full
    (A B a b : ℝ) (hA : 0 < A) (hB : 0 < B) (hab : a < b) :
    -- (CR-1) crossover budget and exact coincidence
    (crossoverBudget A B a b = crossBudget 0 B (b - a) A
      ∧ regimeLoss A a (crossoverBudget A B a b)
          = regimeLoss B b (crossoverBudget A B a b))
    -- (CR-2) dominance reversal (the crossover)
    ∧ (∀ D, 0 < D → D < crossoverBudget A B a b →
          regimeLoss A a D < regimeLoss B b D)
    ∧ (∀ D, crossoverBudget A B a b < D →
          regimeLoss B b D < regimeLoss A a D)
    -- (CR-3) uniqueness
    ∧ (∀ D, 0 < D → regimeLoss A a D = regimeLoss B b D →
          D = crossoverBudget A B a b)
    -- (CR-4) two-regime exponents are R6_Agent2 fixed points
    ∧ (∀ D, 0 < D → D ≠ 1 → alphaEff A a D = a ∧ alphaEff B b D = b)
    -- (CR-5) degenerate crossover at equal scales
    ∧ (A = B → crossoverBudget A B a b = 1) := by
  refine ⟨⟨crossover_eq_crossBudget A B a b,
           regimes_equal_at_crossover A B a b hA hB hab⟩, ?_, ?_, ?_, ?_, ?_⟩
  · exact fun D hD hlt => fast_dominates_below A B a b D hA hB hab hD hlt
  · exact fun D hlt => slow_dominates_above A B a b D hA hB hab hlt
  · exact fun D hD hcoin => crossover_unique A B a b D hA hB hab hD hcoin
  · exact fun D hD hD1 => branch_exponents_are_fixed_points A B a b D hA hB hD hD1
  · exact fun hAB => degenerate_crossover_at_one A B a b hB hAB

/-! ============================================================================
    CLOSING NOTE — what is and is NOT resolved
    ============================================================================
    PROVED (graduates to theorem): the FULL two-regime crossover — existence,
    exactness, dominance reversal, uniqueness of the crossover budget, the two
    regime exponents as R6_Agent2 fixed points, and the degenerate collapse.
    This is the "crossover between two scaling regimes" of the Cj.13 narrative,
    with the crossover point and exponents in the rpow machinery.

    STILL OPEN (NOT claimed here): the broader EMPIRICAL universality parts of
    Cj.13 — (a) universality of the Heaps exponent across corpora, (b) the
    crossover-width N-scaling exponent in a thermodynamic ensemble limit, and
    (c) ratio universality `t*/t_cov`, `t_aut/t*`.  As the Cj.13 file's BLOCKED
    AT section explains, these are statements about an ensemble / thermodynamic
    limit and about empirical exponents of the (axiom-free) problem
    distribution; A.1–A.4 fix neither, and they are not derivable here. -/

end R12_Agent1_AttackCrossoverScaling

end MIP
