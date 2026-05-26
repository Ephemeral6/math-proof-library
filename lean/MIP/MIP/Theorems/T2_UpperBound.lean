/-
Theorem T.2 — Expected upper bound on `N`.

Reference: `proofs/T2.md` (corrected expected-value version).

**Statement.** With `r := |R(p)|` and `γ > 0` the per-step new-knowledge
activation probability, there exists an intervention strategy `σ` with

    E[N_σ(p, A)]  ≤  r · H_r / γ

where `H_r := Σ_{i=1}^r 1/i` is the `r`-th harmonic number. By Markov,
this gives `N_{δ=1/2} ≤ ⌈2·r·H_r/γ⌉`.

**Proof.** Coupon-collector argument: when `j` elements are already
activated, the per-step probability of activating a new one is `≥
γ·(r-j)/r`, so the expected waiting time is `≤ r/(γ(r-j))`. Summing the
geometric expectations gives the harmonic bound.

**STATUS: PARTIAL (hypothesis-bundle form).** The opaque MIP signatures
carry no probabilistic "strategy expectation" operator, so the expected
emergence count under the coupon-collector strategy is modelled as an
abstract real `EN : ℝ`. The per-stage geometric waiting-time
decomposition — `EN ≤ Σ_{j<r} r/(γ(r-j))` — is the content that the
absent probability layer would establish; it is bundled as the
hypothesis `CouponCollectorBound`. Given that bundle, the harmonic
closed form `EN ≤ r · H_r / γ` is *proven* (no `sorry`) by rewriting the
bundled sum with the algebraic kernel `T2_kernel`.
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

open scoped BigOperators

namespace UpperBound

/-- `H_r := Σ_{i=1}^r 1/i`, the `r`-th harmonic number. -/
noncomputable def harmonic (r : ℕ) : ℝ :=
  ∑ i ∈ Finset.range r, 1 / ((i : ℝ) + 1)

/-- **Coupon-collector kernel (T.2 core).**

Sum of geometric-distribution expectations equals `r · H_r / γ`. The
identity uses the reindex `j ↦ r - 1 - j` on `Finset.range r`, taking
`(r : ℝ) - j` (with `0 ≤ j < r`) into `(i + 1)` for `0 ≤ i < r`.

This identity is purely algebraic and is fully proven below. -/
theorem T2_kernel (r : ℕ) (γ : ℝ) (hγ : 0 < γ) :
    ∑ j ∈ Finset.range r, (r : ℝ) / (γ * ((r : ℝ) - j))
      = (r : ℝ) * harmonic r / γ := by
  -- Step 1: factor out (r/γ).
  --   ∑ r/(γ(r-j)) = (r/γ) * ∑ 1/(r-j).
  have hγne : γ ≠ 0 := ne_of_gt hγ
  have hstep1 : ∑ j ∈ Finset.range r, (r : ℝ) / (γ * ((r : ℝ) - j))
        = ((r : ℝ) / γ) * ∑ j ∈ Finset.range r, 1 / ((r : ℝ) - j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    field_simp
  rw [hstep1]
  -- Step 2: reindex ∑ 1/(r-j) = ∑ 1/(i+1) = harmonic r,
  -- using `Finset.sum_range_reflect` on `f := fun j => 1/((j+1):ℝ)`.
  have hstep2 : ∑ j ∈ Finset.range r, (1 : ℝ) / ((r : ℝ) - j)
        = harmonic r := by
    unfold harmonic
    have key := (Finset.sum_range_reflect
      (fun j => (1 : ℝ) / ((j : ℝ) + 1)) r).symm
    rw [key]
    apply Finset.sum_congr rfl
    intro j hj
    rw [Finset.mem_range] at hj
    -- Goal: 1/(r - j) = 1/(↑(r - 1 - j) + 1)
    have h1 : j ≤ r - 1 := by omega
    have h2 : 1 ≤ r := by omega
    have hcast : ((r - 1 - j : ℕ) : ℝ) + 1 = (r : ℝ) - (j : ℝ) := by
      push_cast [Nat.cast_sub h1, Nat.cast_sub h2]
      ring
    rw [hcast]
  rw [hstep2]
  ring

/-- **Coupon-collector waiting-time bound (T.2 hypothesis bundle).**

`EN` is the expected emergence count of the coupon-collector strategy
`σ` on `(p, X)`, modelled as an abstract real because the opaque MIP API
exposes no expectation operator over intervention-protocol outcomes.

The single bundled inequality is the standard per-stage decomposition:
once `j` of the `r` knowledge elements are activated, the per-step
probability of activating a new one is `≥ γ·(r-j)/r`, so the expected
waiting time for stage `j` is `≤ r/(γ(r-j))`, and `EN` is bounded by the
sum of these geometric expectations. Establishing this is exactly the
job of the absent probability layer; here it is carried as a hypothesis
(mirroring the `RestrSpec` idiom of `MIP.UEA`). -/
def CouponCollectorBound (EN : ℝ) (r : ℕ) (γ : ℝ) : Prop :=
  EN ≤ ∑ j ∈ Finset.range r, (r : ℝ) / (γ * ((r : ℝ) - j))

/-- **T.2 (Expected Upper Bound).**

Given the coupon-collector waiting-time bundle, the expected emergence
count `EN` of the strategy `σ` satisfies the harmonic closed form

    EN ≤ r · H_r / γ.

The per-stage geometric bound is bundled (`hBound : CouponCollectorBound`,
standing in for the absent probability layer); the harmonic closed form
is *proven* here by rewriting the bundled sum with the algebraic kernel
`T2_kernel`. -/
theorem T2_UpperBound
    {α : Type} (_p : Problem α) (_X : Agent α)
    (EN : ℝ) (r : ℕ) (γ : ℝ) (hγ : 0 < γ) (_hr : 0 < r)
    (hBound : CouponCollectorBound EN r γ) :
    EN ≤ (r : ℝ) * harmonic r / γ := by
  -- Unfold the bundle and rewrite its right-hand sum via the kernel.
  unfold CouponCollectorBound at hBound
  rw [T2_kernel r γ hγ] at hBound
  exact hBound

end UpperBound

end MIP
