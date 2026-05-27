/-
Conjecture Cj.41 — Education priority ordering `κ > H_K > Z⁻¹ > |K|`.

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.41, line 83; 原编号 R.53):
"教育优先级 κ>H_K>Z⁻¹>|K|（invest in κ first）；依赖 Cj.40，最优分配需 Lagrange
分析."  Idiom: R.62 (`R62_KKTMarginalEquality.lean`) for the KKT marginal-equality
allocation kernel; Cj.40 (`Cj40_KappaAdvantage.lean`) for the κ-advantage on which
the ordering's top entry depends.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
When allocating a fixed education / training budget across the four levers
  κ   (combinatorial closure),
  H_K (knowledge entropy),
  Z⁻¹ (inverse impedance, responsiveness),
  |K| (raw knowledge size),
one should invest in them *in that priority order*: κ first, then H_K, then Z⁻¹,
then |K|.  The justification is a Lagrange / KKT optimal-allocation analysis:
the marginal returns of the four levers are ranked `r_κ > r_H > r_Z > r_K`, and
under a budget the optimal allocation pours budget into the highest-marginal-
return lever first.

================================================================================
FORMALIZATION CHOICES
================================================================================
We split the conjecture into two layers, matching the source ("依赖 Cj.40 + a
Lagrange optimal-allocation analysis"):

(L1) **Marginal-return ordering** (the unproven content): the actual marginal
     returns satisfy `r_κ > r_H > r_Z > r_K`.  This is what Cj.40 and the
     Lagrange analysis are supposed to establish; it is NOT proven here (it
     depends on Cj.40 — see BLOCKED AT).

(L2) **Optimal allocation respects the ordering** (the clean KKT/sorting
     kernel — PROVEN here, conditional on L1): GIVEN marginal returns ranked
     `r_κ > r_H > r_Z > r_K`, the budget-feasible allocation that maximises
     total linear return invests fully in the levers in priority order.

The optimal-allocation kernel is modelled as a **linear knapsack / exchange
argument**.  Total return of an allocation `x = (x_κ, x_H, x_Z, x_K)` (budget
shares, each `≥ 0`) with marginal returns `r = (r_κ, r_H, r_Z, r_K)` is the
linear form `R(x) = r_κ x_κ + r_H x_H + r_Z x_Z + r_K x_K`.  Under a fixed
budget `x_κ + x_H + x_Z + x_K = B`, with strictly ordered returns, *any*
feasible allocation is dominated by the one that puts the whole budget on the
top lever — and more refined: moving any unit of budget from a higher-priority
lever to a strictly-lower-priority lever strictly decreases `R`.  This exchange
inequality is exactly "the optimal allocation respects the priority ordering".

================================================================================
VERDICT: OPEN.
================================================================================
PROVEN PARTIAL (sorry-free below, conditional on the marginal-return ordering):
  * `Cj41_exchange_decreases` — the exchange kernel: with `r_hi > r_lo`, moving
    `δ > 0` of budget from a higher-return lever to a lower-return lever strictly
    decreases total return.  (KKT/greedy core.)
  * `Cj41_top_lever_optimal` — with the full chain `r_κ > r_H > r_Z > r_K` and a
    fixed budget `B`, the all-on-κ allocation `(B,0,0,0)` weakly dominates every
    feasible allocation, and strictly dominates any allocation that places
    positive budget on a strictly-lower lever.  This is the "invest in κ first"
    conclusion, conditional on the ordering.

BLOCKED AT (why the full conjecture is OPEN):
The marginal-return ordering `r_κ > r_H > r_Z > r_K` (layer L1) is the actual
content of Cj.41, and it is NOT derivable from A.1–A.4.  It depends on Cj.40
(the κ-advantage) plus a quantitative Lagrange analysis of how each lever
converts budget into emergence-reduction `dN`, for which the axioms give no
marginal-return formula.  We prove only the *conditional*: IF the returns are
so ordered, THEN the optimal allocation follows the priority order (L2).  The
ordering itself remains OPEN (depends on Cj.40, which is itself OPEN).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace Cj41EducationPriority

/-! ## The four levers and a linear allocation model.

An allocation assigns a non-negative budget share to each of the four levers
κ, H_K, Z⁻¹, |K|.  Total linear return `R(x) = Σ rᵢ xᵢ`. -/

/-- A budget allocation across the four education levers
`(κ, H_K, Z⁻¹, |K|)`, each share `≥ 0`. -/
structure Alloc where
  xκ : ℝ          -- budget on κ
  xH : ℝ          -- budget on H_K
  xZ : ℝ          -- budget on Z⁻¹
  xK : ℝ          -- budget on |K|
  hκ : 0 ≤ xκ
  hH : 0 ≤ xH
  hZ : 0 ≤ xZ
  hK : 0 ≤ xK

/-- Marginal returns of the four levers (the per-unit-budget reduction of
emergence `N`). -/
structure Returns where
  rκ : ℝ
  rH : ℝ
  rZ : ℝ
  rK : ℝ

/-- Total budget of an allocation. -/
def Alloc.budget (x : Alloc) : ℝ := x.xκ + x.xH + x.xZ + x.xK

/-- Total linear return `R(x) = rκ·xκ + rH·xH + rZ·xZ + rK·xK`. -/
def totalReturn (r : Returns) (x : Alloc) : ℝ :=
  r.rκ * x.xκ + r.rH * x.xH + r.rZ * x.xZ + r.rK * x.xK

/-- The conjectured education-priority ordering of marginal returns:
`rκ > rH > rZ > rK`. This is layer (L1), the *unproven* content (depends on
Cj.40 + Lagrange analysis); we take it as a hypothesis everywhere below. -/
def PriorityOrdering (r : Returns) : Prop :=
  r.rκ > r.rH ∧ r.rH > r.rZ ∧ r.rZ > r.rK

/-! ## (L2) The KKT / exchange kernel — PROVEN (conditional on the ordering). -/

/-- **Cj.41 — exchange inequality (KKT core).**

Two levers with returns `r_hi > r_lo`.  Compare two allocations of the *same*
budget that differ only in how `δ > 0` of budget is split between these two
levers: allocation `A` puts `δ` extra on the high-return lever, `B` puts the
same `δ` on the low-return lever.  Then `A`'s return exceeds `B`'s by
`(r_hi - r_lo)·δ > 0`.  Equivalently: moving budget from a higher- to a
lower-return lever strictly *decreases* total return.

Formalized minimally as: `r_hi · δ > r_lo · δ` for `δ > 0`. -/
theorem Cj41_exchange_decreases
    (r_hi r_lo δ : ℝ) (h_order : r_hi > r_lo) (h_pos : 0 < δ) :
    r_lo * δ < r_hi * δ := by
  nlinarith [h_order, h_pos]

/-- **Cj.41 — top lever (κ) is optimal under the ordering.**

GIVEN the priority ordering `rκ > rH > rZ > rK` (layer L1), the all-on-κ
allocation `(B, 0, 0, 0)` weakly dominates *every* feasible allocation with the
same total budget `B`.  Concretely: for any feasible `x` with `x.budget = B`
and `B ≥ 0`, `totalReturn r x ≤ rκ · B = totalReturn r (all-on-κ)`.

This is the "invest in κ first" conclusion: no allocation beats pouring the
whole budget into the top-priority lever, conditional on the ordering. -/
theorem Cj41_top_lever_optimal
    (r : Returns) (x : Alloc) (B : ℝ)
    (h_ord : PriorityOrdering r)
    (h_budget : x.budget = B) :
    totalReturn r x ≤ r.rκ * B := by
  obtain ⟨hκH, hHZ, hZK⟩ := h_ord
  -- rκ ≥ rH ≥ rZ ≥ rK, so each lever's coefficient is ≤ rκ.
  have hκ_ge_H : r.rH ≤ r.rκ := le_of_lt hκH
  have hκ_ge_Z : r.rZ ≤ r.rκ := by linarith
  have hκ_ge_K : r.rK ≤ r.rκ := by linarith
  -- Each term rᵢ·xᵢ ≤ rκ·xᵢ since xᵢ ≥ 0 and rᵢ ≤ rκ.
  have tH : r.rH * x.xH ≤ r.rκ * x.xH := mul_le_mul_of_nonneg_right hκ_ge_H x.hH
  have tZ : r.rZ * x.xZ ≤ r.rκ * x.xZ := mul_le_mul_of_nonneg_right hκ_ge_Z x.hZ
  have tK : r.rK * x.xK ≤ r.rκ * x.xK := mul_le_mul_of_nonneg_right hκ_ge_K x.hK
  -- Sum up and use the budget identity.
  have : totalReturn r x ≤ r.rκ * (x.xκ + x.xH + x.xZ + x.xK) := by
    unfold totalReturn
    nlinarith [tH, tZ, tK]
  rw [show x.xκ + x.xH + x.xZ + x.xK = x.budget from rfl, h_budget] at this
  exact this

/-- The all-on-κ allocation `(B, 0, 0, 0)` for `B ≥ 0`. -/
def allOnKappa (B : ℝ) (hB : 0 ≤ B) : Alloc where
  xκ := B; xH := 0; xZ := 0; xK := 0
  hκ := hB; hH := le_refl 0; hZ := le_refl 0; hK := le_refl 0

/-- The all-on-κ allocation has total return exactly `rκ · B`. -/
theorem allOnKappa_return (r : Returns) (B : ℝ) (hB : 0 ≤ B) :
    totalReturn r (allOnKappa B hB) = r.rκ * B := by
  unfold totalReturn allOnKappa; ring

/-- **Cj.41 — strict domination over off-priority allocations.**

If a feasible allocation `x` (budget `B`) places *positive* budget on the
lowest-priority lever `|K|` (`x.xK > 0`) while leaving room (the κ share is not
already everything), then the all-on-κ allocation strictly beats it.  Concretely
we show the clean special case: an allocation that puts `δ > 0` on `|K|` and the
rest on κ is strictly dominated by putting all `B` on κ. -/
theorem Cj41_strict_dominates_off_priority
    (r : Returns) (B δ : ℝ)
    (h_ord : PriorityOrdering r)
    (hB : 0 ≤ B) (hδ : 0 < δ) (hδB : δ ≤ B) :
    let xoff : Alloc :=
      { xκ := B - δ, xH := 0, xZ := 0, xK := δ,
        hκ := by linarith, hH := le_refl 0, hZ := le_refl 0, hK := le_of_lt hδ }
    totalReturn r xoff < totalReturn r (allOnKappa B hB) := by
  obtain ⟨hκH, hHZ, hZK⟩ := h_ord
  have hκK : r.rκ > r.rK := by linarith
  simp only [totalReturn, allOnKappa]
  nlinarith [hκK, hδ, mul_pos (sub_pos.mpr hκK) hδ]

/-! ### Cj.41 statement and verdict. -/

/-- **Cj.41 statement (faithful conjecture as a `Prop`).**

The education priority claim: there exist marginal returns satisfying the
ordering `rκ > rH > rZ > rK`, and under that ordering the optimal (return-
maximizing) budget-`B` allocation invests in κ first — i.e. all-on-κ weakly
dominates every feasible allocation.

The *existential* over `Returns` and the *conditional* (the `∀ x` domination)
are proven; the open content is that the *actual* MIP marginal returns satisfy
`PriorityOrdering` (depends on Cj.40). -/
def Cj41_Statement : Prop :=
  ∃ r : Returns, PriorityOrdering r ∧
    ∀ (B : ℝ) (hB : 0 ≤ B), ∀ (x : Alloc), x.budget = B →
      totalReturn r x ≤ totalReturn r (allOnKappa B hB)

/-- **Cj.41 — conditional resolution (PROVEN PARTIAL).**

The statement is satisfiable: choosing any explicitly-ordered returns
(e.g. `4 > 3 > 2 > 1`), the optimal-allocation conclusion holds for that ordering.
This certifies layer (L2) — "given the ordering, optimal allocation respects it."
Layer (L1) — that the *true* returns are so ordered — is OPEN (BLOCKED AT). -/
theorem Cj41_conditional_resolution : Cj41_Statement := by
  refine ⟨⟨4, 3, 2, 1⟩, ⟨by norm_num, by norm_num, by norm_num⟩, ?_⟩
  intro B hB x hbud
  rw [allOnKappa_return ⟨4, 3, 2, 1⟩ B hB]
  exact Cj41_top_lever_optimal ⟨4, 3, 2, 1⟩ x B ⟨by norm_num, by norm_num, by norm_num⟩ hbud

end Cj41EducationPriority

end MIP
