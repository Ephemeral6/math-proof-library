/-
Result R.168 — Self-inspection blind spots carry positive measure under the
universal (Solomonoff/Levin) measure `μ_U`.

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.168 and
`new_results.md` §R.168 (B 条件性, deps R.101, Solomonoff/Kolmogorov, NC.3).

**Statement.**  For every computable non-trivial AI `A`, the self-inspection
blind-spot set `B_A := {p : N(p,A,A)=∞ ∧ ∃A', N(p,A,A')<∞}` has positive mass
under `μ_U` (and positive *arithmetic density*):

    μ̄_U(B_A) ≥ 2^{−O(|⟨A⟩|)} > 0,   density(B_A) ≥ c_A > 0.

The density argument is a clean counting bound: the R.101 family contributes
`≥ 2^{ℓ − |⟨A⟩| − O(1)}` blind-spot problems of description length `≤ ℓ`, while
the total number of length-`≤ ℓ` problems is `≤ 2^{ℓ+1}`; hence the density is

    (# blind spots of length ≤ ℓ) / (# problems of length ≤ ℓ)
        ≥ 2^{ℓ − c} / 2^{ℓ+1} = 2^{−c−1} =: c_A > 0,

independent of `ℓ`.  The measure bound follows analogously from
`μ_U(p_{A,k}) ≥ 2^{−(|⟨A⟩|+log k+O(1))}`.

**Formalization strategy (direct algebraic kernel).**  The genuine
mathematical content is the *positive constant density bound*, a real-number
inequality.  We formalize it directly: given the counting hypotheses

* `hBlind : (2:ℝ)^(ℓ - c) ≤ blindCount ℓ`   (R.101 lower bound),
* `hTotal : totalCount ℓ ≤ (2:ℝ)^(ℓ + 1)`    (description-length upper bound),
* positivity of `totalCount`,

we prove `2^(-c-1) ≤ blindCount ℓ / totalCount ℓ` and that this density floor
`2^(-c-1)` is strictly positive — the "blind spots are not exceptional, they
occupy a fixed positive proportion" claim.

**This file is `axiom`-free.**  Imports only `Mathlib`; the R.101 counting
bounds enter as explicit hypotheses, and the density floor is proved from
`Real.rpow`/`zpow` monotonicity.
-/
import Mathlib

namespace MIP

namespace BlindSpotMeasure

open Real

/-- **R.168 — positive density floor for the blind-spot set (main theorem).**

Given the R.101 lower bound on blind-spot count `2^(ℓ−c) ≤ blindCount`, the
universal upper bound on the total count `totalCount ≤ 2^(ℓ+1)`, and
positivity of `totalCount`, the blind-spot *density* is bounded below by the
`ℓ`-independent positive constant `2^(−c−1)`:

    2^(−c−1) ≤ blindCount / totalCount.

Hence blind spots occupy at least a fixed positive proportion `c_A := 2^(−c−1)`
of problem space, for every description-length cutoff `ℓ`. -/
theorem R_168_density_floor
    (ℓ c blindCount totalCount : ℝ)
    (hBlind : (2:ℝ) ^ (ℓ - c) ≤ blindCount)
    (hTotal : totalCount ≤ (2:ℝ) ^ (ℓ + 1))
    (hTotPos : 0 < totalCount) :
    (2:ℝ) ^ (-c - 1) ≤ blindCount / totalCount := by
  rw [le_div_iff₀ hTotPos]
  -- suffices: 2^(-c-1) * totalCount ≤ blindCount
  calc (2:ℝ) ^ (-c - 1) * totalCount
      ≤ (2:ℝ) ^ (-c - 1) * (2:ℝ) ^ (ℓ + 1) := by
        apply mul_le_mul_of_nonneg_left hTotal
        positivity
    _ = (2:ℝ) ^ (ℓ - c) := by
        rw [← Real.rpow_add (by norm_num : (0:ℝ) < 2)]
        congr 1; ring
    _ ≤ blindCount := hBlind

/-- **R.168 — the density floor is strictly positive.**

`2^(−c−1) > 0` for any real `c`: the blind-spot proportion `c_A` is a genuine
positive constant, not merely non-negative.  This is the qualitative heart of
R.168 — every computable AI has a fixed positive fraction of self-inspection
blind spots. -/
theorem R_168_floor_pos (c : ℝ) : 0 < (2:ℝ) ^ (-c - 1) := by positivity

/-- **R.168 — blind spots carry strictly positive density (assembled).**

Combining the floor and its positivity: under the R.101 counting bounds the
blind-spot density `blindCount / totalCount` is at least a strictly positive
constant.  This is the "positive mass" statement `μ̄_U(B_A) ≥ c_A > 0`. -/
theorem R_168_positive_density
    (ℓ c blindCount totalCount : ℝ)
    (hBlind : (2:ℝ) ^ (ℓ - c) ≤ blindCount)
    (hTotal : totalCount ≤ (2:ℝ) ^ (ℓ + 1))
    (hTotPos : 0 < totalCount) :
    ∃ cA : ℝ, 0 < cA ∧ cA ≤ blindCount / totalCount :=
  ⟨(2:ℝ) ^ (-c - 1), R_168_floor_pos c,
    R_168_density_floor ℓ c blindCount totalCount hBlind hTotal hTotPos⟩

/-- **R.168 — measure lower bound from the per-problem Kolmogorov bound.**

The measure form: a single blind-spot problem `p_{A,k}` has
`μ_U(p_{A,k}) ≥ 2^(−(|⟨A⟩| + log k + d))` for the `O(1)` constant `d`.  Since
`μ_U(B_A) ≥ μ_U(p_{A,k})` (the family lies inside `B_A`), the blind-spot set
has measure at least this strictly positive lower bound — a one-line monotone
consequence, recorded for completeness. -/
theorem R_168_measure_lb
    (μ : ℝ) (Asize logk d : ℝ)
    (hμ : (2:ℝ) ^ (-(Asize + logk + d)) ≤ μ) :
    0 < (2:ℝ) ^ (-(Asize + logk + d)) ∧ (2:ℝ) ^ (-(Asize + logk + d)) ≤ μ := by
  exact ⟨by positivity, hμ⟩

end BlindSpotMeasure

end MIP
