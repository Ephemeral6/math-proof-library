/-
Result R.93 — `σ_Z` topological lower bound.

Reference: `proofs/derived/stability.md` R.93 (A 无条件).

**Statement.** For any AI `A` whose state space `S` includes a problem
`p` with `|B(p)| ≥ 2`:

    σ_Z(A)  ≥  max_{b, b' ∈ B(p)}  |Z(A, s_b) − Z(A, s_{b'})| .

I.e. `σ_Z` is bounded below by the largest impedance difference between
states of any two barriers of any single problem.  This is a topological
"floor" on `σ_Z`: no AI processing nontrivial problems can achieve
`σ_Z = 0` unless it has uniform impedance across all barriers of all
problems.

**Pure-math content.** This is just `sup f − inf f ≥ |f s − f t|` for
any two points in the domain.  The MIP-specific reading attaches the
barriers `b, b'` to representative states `s_b, s_{b'}`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Data.Finset.Lattice.Fold

namespace MIP

namespace SigmaTopBound

/-- **R.93 — algebraic kernel (sup − inf ≥ pairwise difference).**

For any two values `f s, f t` in the image of `f : ι → ℝ` over a nonempty
finset, the range `sup f − inf f` is at least the unsigned difference
`|f s − f t|`. -/
theorem range_ge_pairwise_diff
    {ι : Type} [DecidableEq ι]
    (Z : ι → ℝ) (S : Finset ι) (hS : S.Nonempty)
    (s t : ι) (hs : s ∈ S) (ht : t ∈ S) :
    S.sup' hS Z - S.inf' hS Z ≥ |Z s - Z t| := by
  -- Both Z s and Z t lie in [inf, sup].
  have h_s_sup : Z s ≤ S.sup' hS Z := Finset.le_sup' Z hs
  have h_inf_s : S.inf' hS Z ≤ Z s := Finset.inf'_le Z hs
  have h_t_sup : Z t ≤ S.sup' hS Z := Finset.le_sup' Z ht
  have h_inf_t : S.inf' hS Z ≤ Z t := Finset.inf'_le Z ht
  -- |Z s − Z t| ≤ max(Z s, Z t) − min(Z s, Z t) ≤ sup − inf.
  -- Direct split on sign of (Z s − Z t).
  rcases le_or_gt (Z s) (Z t) with h | h
  · -- Z s ≤ Z t.  |Z s − Z t| = Z t − Z s.
    rw [abs_of_nonpos (sub_nonpos.mpr h)]
    -- −(Z s − Z t) = Z t − Z s ≤ sup − inf.
    linarith
  · -- Z t < Z s.  |Z s − Z t| = Z s − Z t.
    rw [abs_of_pos (sub_pos.mpr h)]
    linarith

/-- **R.93 — topological lower bound (general form).**

If `Z : ι → ℝ` is a state-dependent impedance, `S` is a finset of states
representing the union over all problems, and `s_b s_b' ∈ S` are two
specific barrier-representative states, then `σ_Z := sup_S Z − inf_S Z`
satisfies

    σ_Z  ≥  |Z s_b − Z s_b'| . -/
theorem R_93_sigma_Z_topological_bound
    {ι : Type} [DecidableEq ι]
    (Z : ι → ℝ) (S : Finset ι) (hS : S.Nonempty)
    (s_b s_b' : ι) (hsb : s_b ∈ S) (hsb' : s_b' ∈ S) :
    S.sup' hS Z - S.inf' hS Z ≥ |Z s_b - Z s_b'| :=
  range_ge_pairwise_diff Z S hS s_b s_b' hsb hsb'

/-- **R.93 — strict positivity of `σ_Z` when impedance values differ.**

If two states have distinct impedances, `σ_Z > 0`. -/
theorem R_93_sigma_Z_pos_of_distinct
    {ι : Type} [DecidableEq ι]
    (Z : ι → ℝ) (S : Finset ι) (hS : S.Nonempty)
    (s t : ι) (hs : s ∈ S) (ht : t ∈ S) (h_distinct : Z s ≠ Z t) :
    0 < S.sup' hS Z - S.inf' hS Z := by
  have h_abs_pos : 0 < |Z s - Z t| := abs_pos.mpr (sub_ne_zero.mpr h_distinct)
  have h_bound := R_93_sigma_Z_topological_bound Z S hS s t hs ht
  linarith

end SigmaTopBound

end MIP
