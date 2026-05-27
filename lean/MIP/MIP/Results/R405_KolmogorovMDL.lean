/-
Result R.405 — Kolmogorov complexity / MDL / AIXI as the
(Universal AI, Solomonoff prior) degeneration of MIP.

Reference: `C:/Users/12729/Desktop/MIP/workspace/theory_unification.md` §R.405
("Kolmogorov 复杂度作为 (Universal AI, Solomonoff prior) 极限"; deps A.2, A.1,
T.8, R.61, R.83, R.148, D.3.1, D.4.10, D.1.4, D.4.9, R.62).

**Candidate / conditional note.**  The source grades R.405 **A** but lists
explicit idealization caveats: (K1) the Universal AI `A_U` is idealized,
(K2) the Solomonoff prior `2^{-K(x)}` does not hold exactly for a real AI, and
(K3) `log|M|` is a channel-capacity upper bound.  This formalization is
**conditional** on the bundled universal-machine facts; it encodes the
information-theoretic *kernel* (minimality + the MDL ↔ MIP-cost bound), not a
Kolmogorov machine.

**Statement (kernel).**  With `K(·)` the Kolmogorov complexity, `U` a universal
machine, `x*` the optimal target:

* **(K-min) universal minimality**: `K(x)` is the length of the *shortest*
  program producing `x`, so for any program/description `p` with `U(p) = x`,
  `K(x) ≤ |p|`;
* **(K-inv) invariance up to `O(1)`**: for two universal machines `U, U'`,
  `|K_U(x) − K_{U'}(x)| ≤ c_{U,U'}`;
* **(MDL↔MIP) cost degeneration**: each metacognitive intervention carries
  `≤ log|M|` bits, and `N` interventions reconstruct the target, so the
  conditional complexity is bounded by the MIP cost,
      `K(p | X) ≤ N · log|M| + c`,
  equivalently the information-theoretic lower bound `N ≥ (K(p|X) − c)/log|M|`
  (the R.405 form of R.173's Ohm bound).

**HYPOTHESIS-BUNDLE.**  The un-formalizable primitive — the Kolmogorov
complexity `K` and the universal machine `U` — enters as bundled hypotheses:
the minimality inequality `K x ≤ descLen` (entered as `hmin`) and the
two-machine difference bounds (entered as `h₁, h₂`) for invariance.  We then
*derive* the MDL ↔ MIP-cost bound and the `O(1)` invariance by honest
arithmetic.  This mirrors `R173_KolmogorovLowerBound.lean`, which carries the
same quantities as abstract reals.

**This file is `sorry`-free and `axiom`-free.**  It imports only `Mathlib`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.AbsoluteValue.Basic
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Tactic.Linarith

namespace MIP

namespace KolmogorovMDL

/-! ### (K-min) — universal minimality of `K` -/

/-- **R.405 (K-min) — minimality inequality (bundled).**

By definition `K(x)` is the length of the shortest program with `U(p) = x`, so
`K(x)` is `≤` the length of *any* valid description.  We record the bundled
minimality fact `K x ≤ descLen`: Kolmogorov complexity lower-bounds every
description length.  (This is the structural property that makes `K` the MDL
optimum.) -/
theorem R_405_minimality
    (Kx descLen : ℝ) (hmin : Kx ≤ descLen) :
    Kx ≤ descLen := hmin

/-- **R.405 (K-min) — MDL optimality among a finite family of descriptions.**

Given a nonempty finite family of valid description lengths `d : Fin (n+1) → ℝ`
each of which is an upper bound for `K x` (minimality applied pointwise), the
complexity `K x` is `≤` the *minimum* description length — the MDL principle:
the best two-part code length is bounded by `K`. -/
theorem R_405_mdl_le_min
    {n : ℕ} (Kx : ℝ) (d : Fin (n + 1) → ℝ)
    (hmin : ∀ i, Kx ≤ d i) :
    Kx ≤ Finset.univ.inf' Finset.univ_nonempty d := by
  apply Finset.le_inf'
  intro i _
  exact hmin i

/-! ### (MDL ↔ MIP) — the cost-degeneration bound -/

/-- **R.405 (MDL ↔ MIP) — conditional complexity bounded by MIP cost.**

Each of the `N` metacognitive interventions carries at most `log|M|` bits, and
together with `X` they reconstruct `p`, so the conditional Kolmogorov
complexity obeys the MDL ↔ MIP-cost bound

    `K(p | X) ≤ N · log|M| + c`.

Bundled facts (source §R.405 steps 1, 3):
* `hchan : KpX ≤ Nbits + c` — the description-via-interventions bound, where
  `Nbits` is the total intervention information;
* `hcap : Nbits ≤ N * logM` — the channel-capacity bound `≤ log|M|` per step.

We derive the boxed inequality. -/
theorem R_405_mdl_mip_bound
    (KpX Nbits N logM c : ℝ)
    (hchan : KpX ≤ Nbits + c)
    (hcap : Nbits ≤ N * logM) :
    KpX ≤ N * logM + c := by
  linarith

/-- **R.405 (MDL ↔ MIP) — information-theoretic Ohm lower bound on `N`.**

Rearranging the cost-degeneration bound `K(p|X) ≤ N·log|M| + c` with
`log|M| > 0` gives the lower bound

    `N ≥ (K(p|X) − c) / log|M|`,

the R.405 form of R.173's information-theoretic Ohm law.  Since `K(p|X)` is
itself uncomputable, this re-derives (R.405 step 5) the uncomputability of `N`
through the information-theoretic route. -/
theorem R_405_info_ohm_lower
    (KpX Nbits N logM c : ℝ)
    (hlogM_pos : 0 < logM)
    (hchan : KpX ≤ Nbits + c)
    (hcap : Nbits ≤ N * logM) :
    (KpX - c) / logM ≤ N := by
  have hbound : KpX ≤ N * logM + c :=
    R_405_mdl_mip_bound KpX Nbits N logM c hchan hcap
  rw [div_le_iff₀ hlogM_pos]
  linarith

/-! ### (K-inv) — invariance up to an additive constant -/

/-- **R.405 (K-inv) — invariance up to `O(1)`.**

Two universal machines simulate each other with a constant-length prefix, so
`|K_U(x) − K_{U'}(x)| ≤ c_{U,U'}`.  Given the two mutual-compression bounds
`K_U ≤ K_{U'} + c` and `K_{U'} ≤ K_U + c` (the cross-compiler prefixes), the
absolute difference is bounded by `c`.  This is the algorithmic-information
invariance theorem (and the analogue of R.173's Levin invariance for `N`). -/
theorem R_405_invariance
    (KU KU' c : ℝ)
    (h₁ : KU ≤ KU' + c)
    (h₂ : KU' ≤ KU + c) :
    |KU - KU'| ≤ c := by
  rw [abs_sub_le_iff]
  constructor <;> linarith

/-- **R.405 — packaged degeneration statement.**

Bundles the kernel: under the bundled universal-machine facts (minimality,
channel capacity, mutual compression), MIP degenerates to the
Kolmogorov/MDL/AIXI picture — `K` is a description lower bound, the MIP cost
upper-bounds the conditional complexity (`N ≥ (K(p|X) − c)/log|M|`), and `K` is
machine-invariant up to `O(1)`. -/
theorem R_405_degeneration
    (Kx descLen KpX Nbits N logM c KU KU' cinv : ℝ)
    (hlogM_pos : 0 < logM)
    (hmin : Kx ≤ descLen)
    (hchan : KpX ≤ Nbits + c)
    (hcap : Nbits ≤ N * logM)
    (h₁ : KU ≤ KU' + cinv)
    (h₂ : KU' ≤ KU + cinv) :
    (Kx ≤ descLen) ∧ ((KpX - c) / logM ≤ N) ∧ (|KU - KU'| ≤ cinv) :=
  ⟨hmin,
   R_405_info_ohm_lower KpX Nbits N logM c hlogM_pos hchan hcap,
   R_405_invariance KU KU' cinv h₁ h₂⟩

end KolmogorovMDL

end MIP
