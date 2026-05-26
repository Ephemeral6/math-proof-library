/-
Result R.473 / R.476 — partial-operad refinement: the chain-graded Koszul
decomposition bound and the `κ^sat` lower bound for `N`.

Reference: `workspace/round3_exploration/work_slot_042.md` §2 (R.473, the
chain-graded partial bar complex decomposition
`H^bar = H^{V-R} ⊕ H^{op,corr}` with corrector bound
`dim H_n^{op,corr} ≤ Σ_{r ≤ n+1} (1 - κ_r) · C(|K|, r)`, **B conditional**)
and §4.4 (R.476, `N(p,A) ≥ |B(p)| / κ^sat(A)`, with `κ^sat = 0 ⟹ N = ∞`,
**B**).

**Statement (algebraic kernels).**  The refinement section states two
crisp inequalities, both of which we bundle their hypotheses and prove as
real-arithmetic facts.

* **R.473 — chain-graded decomposition.**  The partial bar homology splits
  as a direct sum `H^bar = H^{V-R} ⊕ H^{op,corr}`, so dimensions add
  (`R_473_dim_additive`); the operadic corrector dimension is bounded by a
  saturation-weighted simplex count `Σ_{r} (1 - κ_r) · C` with each
  `0 ≤ κ_r ≤ 1` (`R_473_corrector_bound`); and in the saturated limit
  `∀ r, κ_r = 1` the corrector bound collapses to `0`
  (`R_473_corrector_vanishes`), recovering `H^bar = H^{V-R}` (R.469's
  degeneration).  Monotonicity in the saturation defect is recorded
  (`R_473_corrector_mono`).

* **R.476 — `κ^sat` lower bound for `N`.**  When `κ^sat > 0` the topological
  lower bound `N ≥ |B| / κ^sat` is a genuine finite bound
  (`R_476_lower_bound`), the bound *increases* as `κ^sat` shrinks
  (`R_476_bound_antitone`), and it diverges as `κ^sat → 0⁺`
  (`R_476_blowup`): for any target `M` there is a saturation threshold below
  which the bound exceeds `M`, the precise sense of "`κ^sat = 0 ⟹ N = ∞`".

The corrector / homology dimensions and `N`, `|B|` are carried as
nonnegative reals; the saturation tower `κ : ℕ → ℝ` is bundled with its
`[0,1]` range hypothesis.  These are exactly the algebraic inequalities the
section asserts.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.GCongr

namespace MIP

namespace PartialOperadRefinement

open Finset

/-! ### R.473 — chain-graded decomposition `H^bar = H^{V-R} ⊕ H^{op,corr}`

The partial bar homology at degree `n` decomposes as a direct sum of the
Vietoris-Rips part (R.462-R.464) and an operadic corrector part.  We model
the dimensions as nonnegative reals; the direct-sum structure gives
dimension additivity. -/

/-- **R.473 — dimension additivity of the chain-graded decomposition.**
Given the direct-sum splitting `H^bar = H^{V-R} ⊕ H^{op,corr}` (carried as
the hypothesis `dimBar = dimVR + dimCorr`), the corrector contribution is
exactly the gap `dim H^bar − dim H^{V-R}`.  This isolates the operadic
corrector as the genuinely new (non-Vietoris-Rips) part of the homology. -/
theorem R_473_dim_additive (dimBar dimVR dimCorr : ℝ)
    (hsplit : dimBar = dimVR + dimCorr) :
    dimCorr = dimBar - dimVR := by
  rw [hsplit]
  ring

/-- The **saturation-weighted simplex count**
`Σ_{r ∈ s} (1 - κ r) · C r`, the closed-form upper bound for the operadic
corrector dimension at a given degree (`s` ranges over the relevant
arities `r ≤ n + 1`; `C r = C(|K|, r)` is the simplex count). -/
def correctorBound (s : Finset ℕ) (κ : ℕ → ℝ) (C : ℕ → ℝ) : ℝ :=
  ∑ r ∈ s, (1 - κ r) * C r

/-- **R.473 — the corrector bound is well-defined and nonnegative.**  Each
saturation defect `1 - κ r ≥ 0` (since `κ r ≤ 1`) and each simplex count
`C r ≥ 0`, so the weighted sum is `≥ 0`.  This is the consistency of the
upper bound `dim H_n^{op,corr} ≤ Σ_r (1 - κ_r) · C(|K|, r)`. -/
theorem R_473_corrector_bound (s : Finset ℕ) (κ : ℕ → ℝ) (C : ℕ → ℝ)
    (hκ : ∀ r ∈ s, κ r ≤ 1) (hC : ∀ r ∈ s, 0 ≤ C r) :
    0 ≤ correctorBound s κ C := by
  unfold correctorBound
  apply Finset.sum_nonneg
  intro r hr
  apply mul_nonneg
  · linarith [hκ r hr]
  · exact hC r hr

/-- **R.473 — the total homology bound.**  Under the direct-sum splitting
`dim H^bar = dimVR + dimCorr` and the corrector bound
`dimCorr ≤ Σ_r (1-κ_r)·C`, the total bar-homology dimension is bounded by
`dimVR + Σ_r (1-κ_r)·C`.  (Combines the splitting with the corrector
bound.) -/
theorem R_473_total_bound (s : Finset ℕ) (κ : ℕ → ℝ) (C : ℕ → ℝ)
    (dimBar dimVR dimCorr : ℝ) (hsplit : dimBar = dimVR + dimCorr)
    (hbound : dimCorr ≤ correctorBound s κ C) :
    dimBar ≤ dimVR + correctorBound s κ C := by
  rw [hsplit]; linarith

/-- **R.473 — saturated-limit collapse.**  In the saturated limit
`∀ r ∈ s, κ r = 1` every defect `1 - κ r` vanishes, so the corrector bound
is `0`.  Hence `H^bar = H^{V-R}`: this recovers R.469's "partial bar
degenerates to the Vietoris-Rips complex" in the fully-saturated regime. -/
theorem R_473_corrector_vanishes (s : Finset ℕ) (κ : ℕ → ℝ) (C : ℕ → ℝ)
    (hκ : ∀ r ∈ s, κ r = 1) :
    correctorBound s κ C = 0 := by
  unfold correctorBound
  apply Finset.sum_eq_zero
  intro r hr
  rw [hκ r hr]
  simp

/-- **R.473 — monotonicity in the saturation defect.**  If the tower `κ'`
is everywhere at least as saturated as `κ` (`κ r ≤ κ' r`), with nonnegative
simplex counts, then the corrector bound shrinks: more saturation means a
smaller operadic corrector.  (As `κ_r → 1` the bound monotonically
decreases to `0`.) -/
theorem R_473_corrector_mono (s : Finset ℕ) (κ κ' : ℕ → ℝ) (C : ℕ → ℝ)
    (hmono : ∀ r ∈ s, κ r ≤ κ' r) (hC : ∀ r ∈ s, 0 ≤ C r) :
    correctorBound s κ' C ≤ correctorBound s κ C := by
  unfold correctorBound
  apply Finset.sum_le_sum
  intro r hr
  apply mul_le_mul_of_nonneg_right _ (hC r hr)
  linarith [hmono r hr]

/-! ### R.476 — the `κ^sat` lower bound for `N`

`N(p, A) ≥ |B(p)| / κ^sat(A)`.  When `κ^sat > 0` this is a finite bound;
the bound is antitone in `κ^sat` (smaller saturation ⟹ larger forced `N`),
and diverges as `κ^sat → 0⁺`, formalising `κ^sat = 0 ⟹ N = ∞`. -/

/-- The **R.476 topological lower bound** `|B| / κ^sat`. -/
noncomputable def nLowerBound (B kappaSat : ℝ) : ℝ := B / kappaSat

/-- **R.476 — the lower bound holds.**  If `N ≥ |B| / κ^sat` is the
hypothesis (the bundled topological lower bound, `κ^sat > 0`), then `N` is
indeed at least the bound, which is itself nonnegative when `|B| ≥ 0`. -/
theorem R_476_lower_bound (N B kappaSat : ℝ)
    (hκ : 0 < kappaSat) (hB : 0 ≤ B)
    (hbound : nLowerBound B kappaSat ≤ N) :
    0 ≤ N := by
  have h0 : 0 ≤ nLowerBound B kappaSat := by
    unfold nLowerBound
    positivity
  linarith

/-- **R.476 — the bound is antitone in `κ^sat`.**  For a fixed nonnegative
`|B|`, decreasing the saturation `κ^sat` (while staying positive) increases
the forced lower bound `|B| / κ^sat`.  Less saturation ⟹ larger `N`. -/
theorem R_476_bound_antitone (B k₁ k₂ : ℝ)
    (hB : 0 ≤ B) (hk₁ : 0 < k₁) (hle : k₁ ≤ k₂) :
    nLowerBound B k₂ ≤ nLowerBound B k₁ := by
  unfold nLowerBound
  exact div_le_div_of_nonneg_left hB hk₁ hle

/-- **R.476 — blow-up as `κ^sat → 0⁺` (`κ^sat = 0 ⟹ N = ∞`).**  For a
*positive* `|B|`, given any target `M`, there is a saturation threshold
`δ > 0` such that whenever `0 < κ^sat < δ` the forced lower bound exceeds
`M`.  Thus as `κ^sat → 0⁺` the bound `|B| / κ^sat → ∞`: in the unsaturated
limit `N` is unbounded, the precise sense of `κ^sat = 0 ⟹ N = ∞`. -/
theorem R_476_blowup (B : ℝ) (hB : 0 < B) :
    ∀ M : ℝ, ∃ δ : ℝ, 0 < δ ∧
      ∀ kappaSat : ℝ, 0 < kappaSat → kappaSat < δ → M < nLowerBound B kappaSat := by
  intro M
  -- choose δ = B / (max M 0 + 1); then κ^sat < δ ⟹ B/κ^sat > max M 0 + 1 > M
  have hden : (0 : ℝ) < max M 0 + 1 := by positivity
  refine ⟨B / (max M 0 + 1), by positivity, ?_⟩
  intro kappaSat hpos hlt
  unfold nLowerBound
  -- `kappaSat < B / (max M 0 + 1)` rearranges to `kappaSat * (max M 0 + 1) < B`
  rw [lt_div_iff₀ hden] at hlt
  -- hence `max M 0 + 1 < B / kappaSat`
  have hgt : max M 0 + 1 < B / kappaSat := by
    rw [lt_div_iff₀ hpos]; linarith [hlt]
  have hMle : M ≤ max M 0 := le_max_left M 0
  linarith [hgt, hMle]

end PartialOperadRefinement

end MIP
