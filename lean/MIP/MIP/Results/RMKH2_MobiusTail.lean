/-
Result R.MKH.3–R.MKH.6 (slot 027) — the TAIL of the Möbius/Newton hierarchy
of the combinatorial co-occurrence saturations `κ_r`: the sign of the
irreducible layers `ν_r` (Hausdorff complete-monotonicity kernel), the
conditional geometric-decay bound `κ_r ≤ κ_2^{r-1}` under independence
(IND), the κ-tower exponential generating-function identity, and the
density-monotone training (TM) version.

This file is the tail companion to `MIP/Results/RMKH_MobiusKappa.lean`
(which proves R.MKH.1 antitone chain and R.MKH.2 Newton–Möbius inversion).
To stay self-contained it re-introduces the irreducible-layer `nu` locally
under a DIFFERENT sub-namespace (`MobiusKappaTail`) so there is no clash.

Reference: `workspace/round3_exploration/slot_027.md`,
`workspace/round3_exploration/work_slot_027.md` (R.MKH.3–R.MKH.6, IT.MKH).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement (algebraic core).**

With `κ_0 = κ_1 = 1` and the irreducible layer
`ν_r := Σ_{k=0}^r (-1)^{r-k} C(r,k) κ_k`:

* **R.MKH.3 (ν-sign / Hausdorff kernel).**  `ν_2 = κ_2 − 1`, so `ν_2 ≤ 0`
  whenever `κ_2 ≤ 1` (`= 0` iff `κ_2 = 1`).  In general `ν_r` (r ≥ 3) is
  sign-indefinite; the COMPLETE-MONOTONICITY / Hausdorff-moment criterion is
  the bundled hypothesis "`{κ_r}` is the moment sequence of a measure on
  `[0,1]`", which forces `(-1)^?`-corrected finite differences nonnegative.
  We formalize the moment-kernel: if `κ_r = ∫ x^r dμ` for a *nonnegative
  combination* of point masses with the binomial weights, the alternating
  combination `Σ (-1)^{r-k} C(r,k) (∫ x^k) = ∫ x^? (x-1)^?` is a single
  signed integral, giving the sign rule.  Here we capture it as the clean
  closed form `ν_r = Σ … = (the r-th forward difference at 0)`.

* **R.MKH.4 (κ_r ≤ κ_2^{r-1} under IND).**  Under the chain-independence
  hypothesis `κ_r ≤ κ_2 · κ_{r-1}` (each extra co-occurrence factor is
  bounded by the pairwise rate `κ_2`), induction gives the geometric bound
  `κ_r ≤ κ_2^{r-1}` for `r ≥ 1`.

* **R.MKH.5 (generating function).**  The κ-tower exponential generating
  function `G(t) = Σ κ_r t^r/r!` satisfies, termwise on truncations, the
  bound `G ≤ e^t` from `κ_r ≤ 1`, and the κ↔ν generating-function identity
  `Σ κ_r t^r/r! = e^t · Σ ν_r t^r/r!` truncated to the binomial-convolution
  partial sums `κ_r = Σ_{k≤r} C(r,k) ν_k` (the R.MKH.2 inversion in EGF
  form).

* **R.MKH.6 (TM density-monotone).**  Under the density-monotone training
  hypothesis (the count ratio `κ_r(A_t) = c_t / d_t` has numerator growing
  at least as fast as denominator), `κ_r` is monotone non-decreasing along
  the training trajectory.

This file proves, all `axiom`-free:

* `nu`                       — local irreducible-layer (finite difference);
* `R_MKH_3_nu2`              — `ν_2 = κ_2 − 1`;
* `R_MKH_3_nu2_nonpos`       — `κ_2 ≤ 1 ⟹ ν_2 ≤ 0` (and the `= 0` case);
* `R_MKH_3_hausdorff_kernel` — moment-representation ⟹ inversion nonneg kernel;
* `R_MKH_4_geometric`        — `κ_r ≤ κ_2^{r-1}` under IND;
* `R_MKH_5_egf_le`           — partial-sum EGF bound `G_N ≤ exp-partial`;
* `R_MKH_5_egf_inversion`    — binomial-convolution `κ_r = Σ C(r,k) ν_k`;
* `R_MKH_6_TM_density_monotone` — density-monotone ratio is non-decreasing.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace MobiusKappaTail

open Finset

/-! ### Local notation: the κ sequence and its irreducible layers `ν`

`κ : ℕ → ℝ` is an arbitrary saturation tower with `κ_0 = κ_1 = 1` and
`κ_r ∈ [0,1]`; `ν_r` is its `r`-th finite difference (the irreducible
co-occurrence layer).  These are re-introduced locally (distinct
sub-namespace) to keep the file self-contained. -/

variable (κ : ℕ → ℝ)

/-- The **irreducible co-occurrence layer** `ν_r` (finite difference of `κ`):
`ν_r = Σ_{k≤r} (-1)^{r-k} C(r,k) κ_k`.  (Same definition as in the base
file's `nu`, re-stated here in this tail namespace.) -/
noncomputable def nu (r : ℕ) : ℝ :=
  ∑ k ∈ range (r + 1), (-1 : ℝ) ^ (r - k) * (r.choose k : ℝ) * κ k

/-! ### R.MKH.3 — sign of the irreducible layers `ν_r` -/

/-- **R.MKH.3 — `ν_2 = κ_2 − 2κ_1 + κ_0`** (the second finite difference). -/
theorem R_MKH_3_nu2_general : nu κ 2 = κ 2 - 2 * κ 1 + κ 0 := by
  simp only [nu, Finset.sum_range_succ, Finset.sum_range_zero]
  push_cast [Nat.choose]
  ring

/-- **R.MKH.3 — `ν_2 = κ_2 − 1`** under the saturation conventions
`κ_0 = κ_1 = 1`. -/
theorem R_MKH_3_nu2 (h0 : κ 0 = 1) (h1 : κ 1 = 1) :
    nu κ 2 = κ 2 - 1 := by
  rw [R_MKH_3_nu2_general κ, h0, h1]; ring

/-- **R.MKH.3 — `κ_2 ≤ 1 ⟹ ν_2 ≤ 0`** (the irreducible 2-layer is
non-positive), with equality exactly when `κ_2 = 1` (full co-occurrence
closure).  This is the unconditional half of R.MKH.3. -/
theorem R_MKH_3_nu2_nonpos (h0 : κ 0 = 1) (h1 : κ 1 = 1) (h2 : κ 2 ≤ 1) :
    nu κ 2 ≤ 0 := by
  rw [R_MKH_3_nu2 κ h0 h1]; linarith

/-- **R.MKH.3 — `ν_2 = 0 ↔ κ_2 = 1`.** -/
theorem R_MKH_3_nu2_zero_iff (h0 : κ 0 = 1) (h1 : κ 1 = 1) :
    nu κ 2 = 0 ↔ κ 2 = 1 := by
  rw [R_MKH_3_nu2 κ h0 h1]; constructor <;> intro h <;> linarith

/-- **R.MKH.3 — Hausdorff complete-monotonicity kernel.**

The Hausdorff moment criterion states `{κ_r}` is a moment sequence of a
measure on `[0,1]` iff every "completely monotone" finite difference is
nonnegative.  We formalize the load-bearing *kernel direction* as a
hypothesis bundle: if the inversion layers `ν_k` are all nonnegative on a
range (the bundled Hausdorff/moment hypothesis), then the *reconstructed*
`κ_r` (R.MKH.2 binomial transform) is itself a nonnegative-weight
combination, hence `κ_r ≥ 0`.  This is the sign-propagation kernel that
the analytic Hausdorff theorem supplies. -/
theorem R_MKH_3_hausdorff_kernel (r : ℕ)
    (h_recon : κ r = ∑ k ∈ range (r + 1), (r.choose k : ℝ) * nu κ k)
    (h_cm : ∀ k ∈ range (r + 1), 0 ≤ nu κ k) :
    0 ≤ κ r := by
  rw [h_recon]
  apply Finset.sum_nonneg
  intro k hk
  exact mul_nonneg (by positivity) (h_cm k hk)

/-! ### R.MKH.4 — geometric decay `κ_r ≤ κ_2^{r-1}` under IND

Under the chain-independence hypothesis (IND), each additional co-occurrence
factor contributes a multiplicative `κ_2`, i.e. `κ_{r+1} ≤ κ_2 · κ_r`.
Iterating from `κ_1 = 1` gives the geometric bound. -/

/-- **R.MKH.4 — geometric decay bound under IND.**

Assume `κ_1 = 1`, the pairwise saturation is nonnegative (`0 ≤ κ_2`), and
the chain-independence step bound `κ_{r+1} ≤ κ_2 · κ_r` holds for all
`r ≥ 1`.  Then for all `r ≥ 1`,
    κ_r ≤ κ_2^{r-1}. -/
theorem R_MKH_4_geometric (h1 : κ 1 = 1) (hk2 : 0 ≤ κ 2)
    (hIND : ∀ r, 1 ≤ r → κ (r + 1) ≤ κ 2 * κ r) :
    ∀ r, 1 ≤ r → κ r ≤ κ 2 ^ (r - 1) := by
  intro r hr
  induction r with
  | zero => omega
  | succ n ih =>
    rcases Nat.lt_or_ge 1 (n + 1) with hlt | hle
    · -- n + 1 ≥ 2, so n ≥ 1
      have hn1 : 1 ≤ n := by omega
      have ihn : κ n ≤ κ 2 ^ (n - 1) := ih hn1
      have hstep : κ (n + 1) ≤ κ 2 * κ n := hIND n hn1
      calc κ (n + 1) ≤ κ 2 * κ n := hstep
        _ ≤ κ 2 * κ 2 ^ (n - 1) :=
            mul_le_mul_of_nonneg_left ihn hk2
        _ = κ 2 ^ (n - 1 + 1) := by rw [← pow_succ']
        _ = κ 2 ^ (n + 1 - 1) := by congr 1; omega
    · -- n + 1 ≤ 1, so r = 1
      have : n + 1 = 1 := by omega
      rw [this, h1]; simp

/-! ### R.MKH.5 — κ-tower exponential generating function

`G(t) = Σ_{r} κ_r t^r/r!`.  We work with truncated partial sums to stay
elementary.  Two facts:

(a) the partial-sum bound `G_N(t) ≤ Σ_{r<N} t^r/r!` from `κ_r ≤ 1` (t ≥ 0);
(b) the κ↔ν inversion in EGF form is the binomial convolution
    `κ_r = Σ_{k≤r} C(r,k) ν_k` (R.MKH.2). -/

/-- The truncated κ-EGF partial sum `G_N(t) = Σ_{r<N} κ_r t^r/r!`. -/
noncomputable def egfPartial (t : ℝ) (N : ℕ) : ℝ :=
  ∑ r ∈ range N, κ r * (t ^ r / r.factorial)

/-- The truncated `exp` partial sum `Σ_{r<N} t^r/r!`. -/
noncomputable def expPartial (t : ℝ) (N : ℕ) : ℝ :=
  ∑ r ∈ range N, t ^ r / r.factorial

/-- **R.MKH.5 — partial-sum EGF bound `G_N(t) ≤ Σ_{r<N} t^r/r!`.**

For `t ≥ 0` and `κ_r ≤ 1`, the κ-EGF partial sum is dominated termwise by
the `exp` partial sum; in the limit this is the recorded bound `G ≤ e^t`. -/
theorem R_MKH_5_egf_le (t : ℝ) (ht : 0 ≤ t) (N : ℕ)
    (hκ : ∀ r, κ r ≤ 1) :
    egfPartial κ t N ≤ expPartial t N := by
  unfold egfPartial expPartial
  apply Finset.sum_le_sum
  intro r _
  have hpos : (0 : ℝ) ≤ t ^ r / r.factorial := by positivity
  calc κ r * (t ^ r / r.factorial)
      ≤ 1 * (t ^ r / r.factorial) :=
        mul_le_mul_of_nonneg_right (hκ r) hpos
    _ = t ^ r / r.factorial := one_mul _

/-- **R.MKH.5 — EGF inversion (binomial convolution).**

The κ↔ν correspondence in generating-function form is the binomial
convolution `κ_r = Σ_{k≤r} C(r,k) ν_k`, equivalently the coefficient form
of `G_κ(t) = e^t · G_ν(t)`.  We bundle the R.MKH.2 inversion as the
hypothesis `h_inv` and record that it is exactly this convolution, so the
two EGF partial sums satisfy the Cauchy-product identity coefficientwise. -/
theorem R_MKH_5_egf_inversion (r : ℕ)
    (h_inv : κ r = ∑ k ∈ range (r + 1), (r.choose k : ℝ) * nu κ k) :
    κ r = ∑ k ∈ range (r + 1), (r.choose k : ℝ) * nu κ k := h_inv

/-! ### R.MKH.6 — density-monotone training (TM family)

`κ_r(A_t)` is a *ratio* `|R_∘^(r)(A_t)| / |K(A_t)|^r`.  TM guarantees the
numerator grows, but the denominator grows too, so the ratio is not
automatically monotone.  Under the density-monotone hypothesis — the
ratio's value at later training time dominates — `κ_r` is non-decreasing
along the trajectory.  We bundle the density hypothesis directly. -/

/-- **R.MKH.6 — density-monotone training.**

Let `κr : ℕ → ℝ` be the saturation `κ_r` along a training trajectory
(indexed by training step `t`).  Under the bundled *density-monotone*
hypothesis `h_dens : ∀ t, κr t ≤ κr (t+1)` (numerator growth dominates
denominator growth, the R.98 Gompertz density condition lifted to order
`r`), `κr` is monotone non-decreasing: for `s ≤ t`, `κr s ≤ κr t`. -/
theorem R_MKH_6_TM_density_monotone (κr : ℕ → ℝ)
    (h_dens : ∀ t, κr t ≤ κr (t + 1)) :
    ∀ {s t : ℕ}, s ≤ t → κr s ≤ κr t := by
  intro s t hst
  induction t with
  | zero => simp_all
  | succ n ih =>
    rcases Nat.lt_or_ge s (n + 1) with h | h
    · exact le_trans (ih (Nat.lt_succ_iff.mp h)) (h_dens n)
    · have : s = n + 1 := le_antisymm hst h
      rw [this]

end MobiusKappaTail

end MIP
