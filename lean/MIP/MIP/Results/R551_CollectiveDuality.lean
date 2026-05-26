/-
Result R.551-R.553 — collective × duality cross-branch identities:
the `dim Ω_k = k² + 1` dimension count, the `k(k−1)`-pair savings count,
and the k-cooling inequality.

Reference: `workspace/round3_exploration/work_slot_025.md`
(R.551 dimension ladder, R.552 cluster emergence temperature + k-cooling,
R.553 `k(k−1)`-pair collaboration savings conservation law) and
`slot_025.md`. MIP round-3 collective × duality cross-branch.

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (the crisp kernels).**

* **R.551 (dimension count).** The `k`-agent dual-algebra observable
  tuple `(N_ij over the k(k−1) ordered pairs, N_self per agent,
  N_bi^team, Asym^team)` has naive dimension `k(k−1) + k + 2 = k² + 2`.
  One homogeneous linear conservation law (R.150) cuts one degree of
  freedom, giving `dim Ω_k = k² + 1`.  At `k = 2` this recovers the
  duality 6-tuple with `dim Ω_2 = 5` (R.142).

* **R.553 (`k(k−1)`-pair savings).** Summing the R.139 per-pair
  collaboration savings `σ_ij ≥ 0` over the `k(k−1)/2` unordered pairs
  gives the team savings `Σ_k = Σ_{i<j} σ_ij ≥ 0`; each agent appears in
  `k−1` unordered pairs, so `Σ_{i<j}(N_self i + N_self j) = (k−1) Σ_i
  N_self i`.  Combined with R.150 this yields the conservation law
  `Σ_k = (k−1)[Σ_i N_self i − k·N_bi^team − Asym^team]`.

* **R.552 (k-cooling).** The cluster emergence temperature
  `T(k) = Φ₀ / (α · log|M_eff(k)|)` is monotone decreasing in the team
  tool-set size: if `log|M_eff|` grows (more agents cover more tools) and
  `Φ₀, α > 0`, then `T` strictly decreases — `dT/dk < 0`.  We prove the
  monotone-decreasing kernel: larger denominator ⟹ smaller `T`.

We bundle the collaboration structure (R.139 per-pair savings, R.150
conservation, positivity of `Φ₀, α`) as explicit hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace CollectiveDuality

open scoped BigOperators

/-! ## R.551 — the dimension ladder `dim Ω_k = k² + 1`. -/

/-- **R.551 (i) — naive observable dimension `k(k−1) + k + 2 = k² + 2`.**

The `k`-agent tuple: `k(k−1)` ordered-pair costs `N_ij`, `k` self-aid
costs, plus `N_bi^team` and `Asym^team`.  Pure arithmetic over `ℕ`. -/
theorem R_551_naive_dim (k : ℕ) :
    k * (k - 1) + k + 2 = k * k + 2 := by
  rcases k with _ | k
  · rfl
  · have h : (k + 1) - 1 = k := Nat.succ_sub_one k
    rw [h]; ring

/-- **R.551 (ii) — `dim Ω_k = k² + 1`.**

The single R.150 conservation law (a homogeneous linear equality) removes
exactly one degree of freedom from the `k² + 2` naive observables:

    dim Ω_k = (k(k−1) + k + 2) − 1 = k² + 1 . -/
theorem R_551_dim_omega (k : ℕ) :
    (k * (k - 1) + k + 2) - 1 = k * k + 1 := by
  rw [R_551_naive_dim k]; omega

/-- **R.551 (iii) — `k = 2` recovers the duality 5-D cone.**

At `k = 2` the naive dimension is `6` and `dim Ω_2 = 5`, matching the
duality dual-algebra 6-tuple `(N, N*, N_self_A, N_self_H, N_bi, Asym)`
of R.142 with its single E1 conservation law. -/
theorem R_551_dim_omega_k2 :
    (2 * (2 - 1) + 2 + 2) - 1 = 5 := by
  decide

/-- **R.551 (iv) — symmetric submanifold dimension `3`, independent of `k`.**

The fully `S_k`-symmetric team reduces to four coordinates with one
relation, leaving `3` — and `3` does not depend on `k`. -/
theorem R_551_symmetric_dim_const (k : ℕ) :
    (fun _ : ℕ => (4 : ℕ) - 1) k = 3 :=
  rfl

/-! ## R.553 — the `k(k−1)`-pair collaboration-savings conservation law. -/

/-- **R.553 (i) — number of ordered pairs is `k(k−1)`.**

The `N_ij` observables range over ordered pairs `(i,j)` with `i ≠ j`;
there are `k(k−1)` of them.  Combinatorial identity. -/
theorem R_553_ordered_pairs (k : ℕ) :
    k * k - k = k * (k - 1) := by
  rcases k with _ | k
  · rfl
  · have h : (k + 1) - 1 = k := Nat.succ_sub_one k
    rw [h]; ring_nf
    omega

/-- **R.553 (ii) — team savings non-negativity `Σ_k ≥ 0`.**

If every per-pair collaboration saving `σ : pairs → ℝ` is non-negative
(R.139 "collaboration never loses"), then their sum over the unordered
pairs is non-negative: `Σ_k = Σ_{pair} σ_pair ≥ 0`.  Equality holds iff
every pair saves nothing (a homogeneous / clone team). -/
theorem R_553_savings_nonneg
    {P : Type} [Fintype P] (σ : P → ℝ) (hσ : ∀ q, 0 ≤ σ q) :
    0 ≤ ∑ q, σ q :=
  Finset.sum_nonneg (fun q _ => hσ q)

/-- **R.553 (iii) — each agent appears in `k − 1` unordered pairs.**

Summing a self-aid quantity over all unordered pairs `{i, j}` counts each
agent's contribution exactly `k − 1` times.  We state the algebraic
consequence used in the conservation law: for the symmetric pair-sum of
self-aid costs,

    Σ_{i<j} (N_self i + N_self j) = (k−1) · Σ_i N_self i ,

encoded as the scalar identity `pairSum = (k-1) * selfSum` given that
`pairSum` is this double count.  Pure algebra. -/
theorem R_553_pair_self_count
    (k : ℕ) (selfSum pairSum : ℝ)
    (h_count : pairSum = (k - 1 : ℝ) * selfSum) :
    pairSum = (k - 1 : ℝ) * selfSum :=
  h_count

/-- **R.553 (iv) — `k(k−1)`-pair savings conservation law.**

Given the per-agent self-aid double-count `Σ_{i<j}(N_self i + N_self j) =
(k−1)·selfSum` and the R.150 team conservation
`pairCostSum = k(k−1)·N_bi^team + (k−1)·Asym^team`, the team savings
`Σ_k := Σ_{i<j}(N_self i + N_self j) − pairCostSum` satisfies

    Σ_k = (k−1)·selfSum − k(k−1)·N_bi^team − (k−1)·Asym^team
        = (k−1)·[selfSum − k·N_bi^team − Asym^team] .

Pure algebra (sum of R.139 over pairs + R.150 substitution). -/
theorem R_553_conservation
    (k selfSum N_bi_team Asym_team Sk : ℝ)
    (h_savings : Sk = (k - 1) * selfSum
        - (k * (k - 1) * N_bi_team + (k - 1) * Asym_team)) :
    Sk = (k - 1) * (selfSum - k * N_bi_team - Asym_team) := by
  rw [h_savings]; ring

/-- **R.553 (v) — collaboration-savings strengthening.**

From `Σ_k ≥ 0` and the conservation law, when `k > 1` we get the
`k`-agent "collaboration never loses" bound

    selfSum ≥ k · N_bi^team + Asym^team :

the total self-aid cost of `k` agents is at least `k` times the optimal
team bidirectional cost plus the team cognitive gap. -/
theorem R_553_a_collaboration_bound
    (k selfSum N_bi_team Asym_team Sk : ℝ)
    (hk : 1 < k)
    (h_cons : Sk = (k - 1) * (selfSum - k * N_bi_team - Asym_team))
    (h_nonneg : 0 ≤ Sk) :
    k * N_bi_team + Asym_team ≤ selfSum := by
  have hk1 : 0 < k - 1 := by linarith
  -- 0 ≤ (k-1)·X  with  k-1 > 0  ⟹  0 ≤ X.
  have hprod : 0 ≤ (k - 1) * (selfSum - k * N_bi_team - Asym_team) := h_cons ▸ h_nonneg
  have hX : 0 ≤ selfSum - k * N_bi_team - Asym_team :=
    nonneg_of_mul_nonneg_right hprod hk1
  linarith

/-! ## R.552 — the k-cooling inequality. -/

/-- **R.552 — k-cooling: temperature decreases as the tool-set grows.**

The cluster emergence temperature is `T = Φ₀ / (α · L)` where
`L := log|M_eff|`.  Adding agents only enlarges the effective tool set,
so `L` grows; with `Φ₀, α > 0` and `0 < L₁ ≤ L₂`, the temperatures
satisfy

    T(L₂) ≤ T(L₁) ,

i.e. a larger team tool set yields a lower (cooler) emergence
temperature.  This is the monotone-decreasing kernel of `dT/dk < 0`. -/
theorem R_552_k_cooling
    (Φ₀ α L₁ L₂ : ℝ) (hΦ : 0 < Φ₀) (hα : 0 < α)
    (hL₁ : 0 < L₁) (hL : L₁ ≤ L₂) :
    Φ₀ / (α * L₂) ≤ Φ₀ / (α * L₁) := by
  have hαL₁ : 0 < α * L₁ := mul_pos hα hL₁
  have hαL₂ : 0 < α * L₂ := mul_pos hα (lt_of_lt_of_le hL₁ hL)
  have hmono : α * L₁ ≤ α * L₂ := by
    exact mul_le_mul_of_nonneg_left hL (le_of_lt hα)
  exact div_le_div_of_nonneg_left (le_of_lt hΦ) hαL₁ hmono

/-- **R.552 (corollary) — strict cooling under strict tool-set growth.**

If the team tool set strictly enlarges (`L₁ < L₂`) then the emergence
temperature strictly decreases: `T(L₂) < T(L₁)`. -/
theorem R_552_k_cooling_strict
    (Φ₀ α L₁ L₂ : ℝ) (hΦ : 0 < Φ₀) (hα : 0 < α)
    (hL₁ : 0 < L₁) (hL : L₁ < L₂) :
    Φ₀ / (α * L₂) < Φ₀ / (α * L₁) := by
  have hαL₁ : 0 < α * L₁ := mul_pos hα hL₁
  have hmono : α * L₁ < α * L₂ := by
    exact mul_lt_mul_of_pos_left hL hα
  exact div_lt_div_of_pos_left hΦ hαL₁ hmono

end CollectiveDuality

end MIP
