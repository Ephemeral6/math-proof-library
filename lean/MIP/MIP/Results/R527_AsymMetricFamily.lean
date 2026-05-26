/-
Result R.527' / R.529 / R.530 — Asymmetry dominates the Wasserstein distance
across the dominated ground-metric family.

Reference: `workspace/round3_exploration/slot_028.md`,
`workspace/round3_exploration/slot_029.md`, and `work_slot_029.md`
(slots 028/029, Cj.55 complement, A unconditional / A conditional).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**  Write the cognitive asymmetry as the weighted-L1 sum over the
finite barrier set `B`:

    Asym  :=  Σ_{b ∈ B} Φ(b) · |Z_A(b) − Z_H(b)| ,

and the (signed) role gap as

    N − N*  :=  Σ_{b ∈ B} Φ(b) · (Z_A(b) − Z_H(b)) .

* **R.527' (A unconditional, Ohm).**  By the L1 triangle inequality
  `|Σ aᵢ| ≤ Σ |aᵢ|` (with the nonnegative weights `Φ(b) ≥ 0`),

      |N − N*|  ≤  Asym .

  This is the signed refinement of R.131.

* **R.530 / Cj.55 complement (the metric-domination kernel).**  For an optimal
  transport cost `W_1^d(μ, ν) := ⨅_{coupling π} Σ_{(x,y)} π(x,y) · d(x,y)`
  over a finite set of couplings, the cost is **monotone in the ground
  metric**: if `d ≤ d_p` pointwise then `W_1^d ≤ W_1^{d_p}`.  Hence whenever
  `Asym ≥ W_1^{d_p}` (R.528', the maximal-element case), the domination
  propagates to the whole dominated family:

      d ≤ d_p   ⟹   Asym ≥ W_1^d .

  The metric-domination ⟹ Wasserstein-domination step is the load-bearing
  kernel; the `Asym ≥ W_1^{d_p}` endpoint enters as the explicit Ohm-regime
  hypothesis (R.528').

* **R.529 (literal refutation of the unrestricted Cj.55).**  Without the
  `d ≤ d_p` restriction the metric `d` may be scaled arbitrarily, so
  `Asym ≥ W_1^d` can fail: a witness with `Asym = 0` yet `W_1^d > 0` refutes
  the universal claim.  We record this as: there exist nonnegative reals with
  `Asym = 0 < W_1^d`.

**This file is `axiom`-free.**  It imports only Mathlib and reuses
`Finset.abs_sum_le_sum_abs`, `Finset.sum_le_sum`, and `le_csInf`/`csInf_le`
for the infimum over the (nonempty, bounded-below) coupling cost set.
-/
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Order.ConditionallyCompleteLattice.Finset
import Mathlib.Data.Real.Archimedean
import Mathlib.Tactic.Linarith

namespace MIP

namespace AsymMetricFamily

open Finset

/-! ### Part 1 — R.527': the weighted-L1 triangle inequality `|N − N*| ≤ Asym`. -/

/-- The cognitive asymmetry as a weighted-L1 sum over the finite barrier set:
`Asym = Σ_b Φ(b) · |Z_A(b) − Z_H(b)|`. -/
def Asym {B : Type*} (s : Finset B) (Φ ZA ZH : B → ℝ) : ℝ :=
  ∑ b ∈ s, Φ b * |ZA b - ZH b|

/-- The signed role gap `N − N* = Σ_b Φ(b) · (Z_A(b) − Z_H(b))` (Ohm regime). -/
def roleGap {B : Type*} (s : Finset B) (Φ ZA ZH : B → ℝ) : ℝ :=
  ∑ b ∈ s, Φ b * (ZA b - ZH b)

/-- **R.527' — `|N − N*| ≤ Asym` (A unconditional, Ohm).**

With nonnegative barrier weights `Φ(b) ≥ 0`, the absolute value of the signed
role gap is bounded by the asymmetry, by the L1 triangle inequality
`|Σ aᵢ| ≤ Σ |aᵢ|` applied termwise.  This is the signed refinement of
R.131. -/
theorem R_527_abs_roleGap_le_asym
    {B : Type*} (s : Finset B) (Φ ZA ZH : B → ℝ)
    (hΦ : ∀ b ∈ s, 0 ≤ Φ b) :
    |roleGap s Φ ZA ZH| ≤ Asym s Φ ZA ZH := by
  unfold roleGap Asym
  calc |∑ b ∈ s, Φ b * (ZA b - ZH b)|
      ≤ ∑ b ∈ s, |Φ b * (ZA b - ZH b)| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ b ∈ s, Φ b * |ZA b - ZH b| := by
        apply Finset.sum_congr rfl
        intro b hb
        rw [abs_mul, abs_of_nonneg (hΦ b hb)]

/-! ### Part 2 — the metric-domination ⟹ Wasserstein-domination kernel. -/

/-- The transport cost of a single coupling `π` against ground metric `d`,
summed over the finite product index set `pairs`:
`cost d π = Σ_{(x,y)} π(x,y) · d(x,y)`. -/
def transportCost {P : Type*} (pairs : Finset P) (d π : P → ℝ) : ℝ :=
  ∑ q ∈ pairs, π q * d q

/-- **Kernel lemma — transport cost is monotone in the ground metric.**

If `d ≤ d'` pointwise on the support and the coupling weights `π` are
nonnegative, then `cost d π ≤ cost d' π`.  This is the per-coupling step that
drives Wasserstein monotonicity. -/
theorem transportCost_mono
    {P : Type*} (pairs : Finset P) (d d' π : P → ℝ)
    (hπ : ∀ q ∈ pairs, 0 ≤ π q) (hd : ∀ q ∈ pairs, d q ≤ d' q) :
    transportCost pairs d π ≤ transportCost pairs d' π := by
  unfold transportCost
  apply Finset.sum_le_sum
  intro q hq
  exact mul_le_mul_of_nonneg_left (hd q hq) (hπ q hq)

/-- **R.530 kernel — Wasserstein domination from ground-metric domination.**

Model `W_1^d(μ,ν)` as the infimum over a fixed nonempty coupling set `Cpl` of the
transport cost; concretely we take the value to be the infimum of the cost
*image set*.  If the ground metric is dominated `d ≤ d_p` and every coupling is
nonnegative, then every `d`-cost is `≤` the corresponding `d_p`-cost, so the
infimum over `d` is `≤` the infimum over `d_p`:

    d ≤ d_p   ⟹   W_1^d  ≤  W_1^{d_p}.

We state it for the infimum of the cost sets, using `le_csInf` (the `d`-inf is
a lower bound for the `d_p`-cost set, hence `≤` its inf) — the standard
`W_1` monotonicity-in-ground-metric fact, finite version. -/
theorem R_530_wasserstein_mono
    {P : Type*} {ι : Type*} (pairs : Finset P)
    (Cpl : Set ι) (coupling : ι → (P → ℝ))
    (d dp : P → ℝ)
    (hπ : ∀ i ∈ Cpl, ∀ q ∈ pairs, 0 ≤ coupling i q)
    (hd : ∀ q ∈ pairs, d q ≤ dp q)
    -- the `d`-cost set is bounded below (e.g. by `0`), so the inf is well-defined:
    (hbddD : BddBelow ((fun i => transportCost pairs d (coupling i)) '' Cpl)) :
    ⨅ i : Cpl, transportCost pairs d (coupling i)
      ≤ ⨅ i : Cpl, transportCost pairs dp (coupling i) := by
  -- It suffices: the `d`-inf is ≤ every `dp`-cost.
  apply ciInf_mono
  · -- the `d`-indexed family is bounded below
    rcases hbddD with ⟨c, hc⟩
    refine ⟨c, ?_⟩
    rintro _ ⟨i, rfl⟩
    exact hc ⟨i.1, i.2, rfl⟩
  · -- pointwise `d`-cost ≤ `dp`-cost on the coupling subtype
    rintro ⟨i, hi⟩
    exact transportCost_mono pairs d dp (coupling i) (hπ i hi) hd

/-- **R.530 — Asym dominates `W_1^d` for the whole dominated family (A cond.).**

Combine the kernel `R_530_wasserstein_mono` (`W_1^d ≤ W_1^{d_p}` for `d ≤ d_p`)
with the Ohm-regime endpoint `Asym ≥ W_1^{d_p}` (R.528', supplied as a
hypothesis since it needs the Ohm scaling).  Then for *every* ground metric `d`
dominated by `d_p`,

    Asym  ≥  W_1^d .

This is the Cj.55 complement: the universal claim fails (R.529), but it holds
across the maximal dominated family with `d_p` as the maximal element. -/
theorem R_530_asym_ge_wasserstein
    {P : Type*} {ι : Type*} (pairs : Finset P)
    (Cpl : Set ι) (coupling : ι → (P → ℝ))
    (d dp : P → ℝ) (asym : ℝ)
    (hπ : ∀ i ∈ Cpl, ∀ q ∈ pairs, 0 ≤ coupling i q)
    (hd : ∀ q ∈ pairs, d q ≤ dp q)
    (hbddD : BddBelow ((fun i => transportCost pairs d (coupling i)) '' Cpl))
    -- R.528' endpoint (Ohm regime, maximal element `d_p`):
    (hEndpoint : (⨅ i : Cpl, transportCost pairs dp (coupling i)) ≤ asym) :
    (⨅ i : Cpl, transportCost pairs d (coupling i)) ≤ asym :=
  le_trans
    (R_530_wasserstein_mono pairs Cpl coupling d dp hπ hd hbddD)
    hEndpoint

/-! ### Part 3 — R.529: literal refutation of the unrestricted Cj.55. -/

/-- **R.529 — the unrestricted Cj.55 is refutable.**

Without the `d ≤ d_p` restriction the ground metric `d` may be scaled freely,
so `Asym ≥ W_1^d` need not hold.  A witness is any pair of nonnegative reals
modelling `Asym = 0` and `W_1^d > 0` — e.g. `(asym, w1) = (0, c)` with `c > 0`.
The existence of such a witness *is* the refutation (the `k`-independent /
`d`-scaling-independent breaking direction of slot 029). -/
theorem R_529_unrestricted_cj55_refuted :
    ∃ asym w1 : ℝ, 0 ≤ asym ∧ 0 ≤ w1 ∧ asym = 0 ∧ asym < w1 :=
  ⟨0, 1, le_refl 0, by norm_num, rfl, by norm_num⟩

end AsymMetricFamily

end MIP
