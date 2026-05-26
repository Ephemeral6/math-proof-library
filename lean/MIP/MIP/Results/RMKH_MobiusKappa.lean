/-
Result R.MKH.1–R.MKH.6 (slot 027) — the Möbius/Newton hierarchy of the
combinatorial co-occurrence saturations `κ_r`: the antitone chain
`κ_r ≤ κ_{r-1}`, and the binomial (Newton–Möbius) inversion `κ ⟺ ν`.

Reference: `workspace/round3_exploration/slot_027.md`,
`workspace/round3_exploration/work_slot_027.md` (R.MKH.1, R.MKH.2; ν_r and
the κ-generating function are recorded notation).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement (algebraic core).**

D.3.7' defines, for an agent `X` with knowledge set `K(X)` of size `n`,
the `r`-ary co-occurrence saturation
`κ_r(X) := |R_∘^(r) ∩ K(X)^r| / n^r ∈ [0,1]`, with `κ_0 = κ_1 = 1`.

* **R.MKH.1 (antitone chain).**  By P-mono (R.462) the projection
  `K^{r+1} → K^r` maps `R_∘^(r+1)` into `R_∘^(r)` with fibres of size `≤ n`,
  so `|R_∘^(r+1)| ≤ |R_∘^(r)|·n`, whence

      κ_{r+1}(X) ≤ κ_r(X)      (first A-unconditional horizontal chain).

  We prove this from the counting hypothesis directly, over `ℝ` with `n>0`.

* **R.MKH.2 (Newton–Möbius inversion).**  Defining the `r`-th irreducible
  co-occurrence layer

      ν_r := Σ_{k=0}^r (-1)^{r-k} C(r,k) κ_k     (r-th finite difference),

  the inverse (binomial) transform recovers

      κ_r = Σ_{k=0}^r C(r,k) ν_k,

  with `ν_0 = 1`, `ν_1 = 0`.  This is the Boolean-lattice Möbius pair; we
  prove it from the subset-of-subset identity `Nat.choose_mul` and
  `Int.alternating_sum_range_choose` (no Hausdorff/analytic input).

This file proves, all `axiom`-free:

* `R_MKH_1_chain`           — `κ_{r+1} ≤ κ_r` (and `R_MKH_1_le` over a span);
* `nu` / `R_MKH_2_nu0`, `R_MKH_2_nu1` — the irreducible-layer values;
* `R_MKH_2_inversion`       — `κ_r = Σ_{k≤r} C(r,k)·ν_k` (Newton–Möbius);
* `binomial_orthogonality`  — the load-bearing orthogonality
  `Σ_{k=m}^{r} (-1)^{k-m} C(r,k) C(k,m) = [r=m]`.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace MobiusKappa

open Finset

/-! ### R.MKH.1 — the antitone chain `κ_{r+1} ≤ κ_r`

We model the κ-tower by the integer co-occurrence counts `Rcount r`
(`= |R_∘^(r) ∩ K^r|`) and the cardinality `n = |K(X)| ≥ 1`, with
`κ r := Rcount r / n^r`.  The P-mono (R.462) projection bound is the
hypothesis `Rcount (r+1) ≤ Rcount r * n`. -/

/-- The κ-saturation tower from raw co-occurrence counts:
`κ r = Rcount r / n^r`. -/
noncomputable def kappa (Rcount : ℕ → ℕ) (n : ℕ) (r : ℕ) : ℝ :=
  (Rcount r : ℝ) / (n : ℝ) ^ r

/-- **R.MKH.1 — single-step antitone chain.**

If `n ≥ 1` and the P-mono projection bound `Rcount (r+1) ≤ Rcount r · n`
holds, then `κ_{r+1} ≤ κ_r`.  (Dividing the count bound by `n^{r+1}`.) -/
theorem R_MKH_1_chain (Rcount : ℕ → ℕ) (n : ℕ) (hn : 1 ≤ n) (r : ℕ)
    (hpmono : Rcount (r + 1) ≤ Rcount r * n) :
    kappa Rcount n (r + 1) ≤ kappa Rcount n r := by
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpow : (0 : ℝ) < (n : ℝ) ^ r := pow_pos hnpos r
  have hpow1 : (0 : ℝ) < (n : ℝ) ^ (r + 1) := pow_pos hnpos (r + 1)
  unfold kappa
  rw [div_le_div_iff₀ hpow1 hpow, pow_succ]
  -- goal: Rcount (r+1) * n^r ≤ Rcount r * (n^r * n)
  have hcast : (Rcount (r + 1) : ℝ) ≤ (Rcount r : ℝ) * (n : ℝ) := by
    exact_mod_cast hpmono
  calc (Rcount (r + 1) : ℝ) * (n : ℝ) ^ r
      ≤ ((Rcount r : ℝ) * (n : ℝ)) * (n : ℝ) ^ r :=
        mul_le_mul_of_nonneg_right hcast (le_of_lt hpow)
    _ = (Rcount r : ℝ) * ((n : ℝ) ^ r * (n : ℝ)) := by ring

/-- **R.MKH.1 — the full descending chain** `κ_r ≤ κ_s` for `s ≤ r`,
obtained by iterating the single-step bound (the recorded horizontal
chain `1/n ≤ … ≤ κ_2 ≤ κ_1 ≤ κ_0`). -/
theorem R_MKH_1_le (Rcount : ℕ → ℕ) (n : ℕ) (hn : 1 ≤ n)
    (hpmono : ∀ r, Rcount (r + 1) ≤ Rcount r * n)
    {s r : ℕ} (hsr : s ≤ r) :
    kappa Rcount n r ≤ kappa Rcount n s := by
  induction r with
  | zero => simp_all
  | succ r ih =>
    rcases Nat.lt_or_ge s (r + 1) with h | h
    · have hsr' : s ≤ r := Nat.lt_succ_iff.mp h
      exact le_trans (R_MKH_1_chain Rcount n hn r (hpmono r)) (ih hsr')
    · -- s = r + 1
      have : s = r + 1 := le_antisymm hsr h
      simp [this]

/-! ### R.MKH.2 — Newton–Möbius inversion `κ ⟺ ν`

`ν_r := Σ_{k=0}^r (-1)^{r-k} C(r,k) κ_k` (the `r`-th finite difference),
and the inverse transform `κ_r = Σ_{k=0}^r C(r,k) ν_k`.  Everything is over
`ℝ`; `κ : ℕ → ℝ` is an arbitrary sequence. -/

variable (κ : ℕ → ℝ)

/-- The **irreducible co-occurrence layer** `ν_r` (finite difference of `κ`):
`ν_r = Σ_{k≤r} (-1)^{r-k} C(r,k) κ_k`. -/
noncomputable def nu (r : ℕ) : ℝ :=
  ∑ k ∈ range (r + 1), (-1 : ℝ) ^ (r - k) * (r.choose k : ℝ) * κ k

/-- **R.MKH.2 — `ν_0 = κ_0`.** -/
theorem R_MKH_2_nu0 : nu κ 0 = κ 0 := by
  simp [nu]

/-- **R.MKH.2 — `ν_1 = κ_1 − κ_0`** (so `= 0` under `κ_0 = κ_1 = 1`). -/
theorem R_MKH_2_nu1 : nu κ 1 = κ 1 - κ 0 := by
  simp [nu, Finset.sum_range_succ]
  ring

/-- **Binomial orthogonality** (Boolean-lattice Möbius identity):
`Σ_{k=0}^{r} (-1)^{k-m} C(r,k) C(k,m) = [r = m]` (terms with `k < m` vanish
since `C(k,m)=0`).  Proved via the subset-of-subset identity
`C(r,k)C(k,m) = C(r,m)C(r-m,k-m)` and `Int.alternating_sum_range_choose`. -/
theorem binomial_orthogonality (r m : ℕ) (hmr : m ≤ r) :
    (∑ k ∈ range (r + 1), (-1 : ℤ) ^ (k - m) * (r.choose k) * (k.choose m))
      = if r = m then 1 else 0 := by
  -- split range (r+1) = Ico 0 m ⊎ Ico m (r+1); the first block vanishes.
  have hsplit : range (r + 1) = (Finset.Ico 0 m) ∪ (Finset.Ico m (r + 1)) := by
    rw [Finset.Ico_union_Ico_eq_Ico (Nat.zero_le m) (by omega : m ≤ r + 1),
        ← Finset.range_eq_Ico]
  have hdisj : Disjoint (Finset.Ico 0 m) (Finset.Ico m (r + 1)) :=
    Finset.Ico_disjoint_Ico_consecutive 0 m (r + 1)
  rw [hsplit, Finset.sum_union hdisj]
  -- first block: k < m ⟹ C(k,m) = 0
  have hzero : (∑ k ∈ Finset.Ico 0 m, (-1 : ℤ) ^ (k - m) * (r.choose k) * (k.choose m)) = 0 := by
    apply Finset.sum_eq_zero
    intro k hk
    rw [Finset.mem_Ico] at hk
    rw [Nat.choose_eq_zero_of_lt hk.2]
    simp
  rw [hzero, zero_add]
  -- second block: reindex k = m + j over Ico m (r+1) ↔ range (r-m+1)
  rw [Finset.sum_Ico_eq_sum_range]
  -- now Σ_{j < (r+1) - m} (-1)^(m+j-m) C(r, m+j) C(m+j, m)
  have hstep : ∀ j ∈ range ((r + 1) - m),
      (-1 : ℤ) ^ ((m + j) - m) * (r.choose (m + j)) * ((m + j).choose m)
        = (r.choose m : ℤ) * ((-1 : ℤ) ^ j * ((r - m).choose j)) := by
    intro j hj
    have hsk : m ≤ m + j := Nat.le_add_right m j
    have hcm : r.choose (m + j) * (m + j).choose m
        = r.choose m * (r - m).choose ((m + j) - m) := Nat.choose_mul hsk
    have hsub : (m + j) - m = j := by omega
    rw [hsub] at hcm ⊢
    have hcast : ((r.choose (m + j) : ℤ)) * ((m + j).choose m : ℤ)
        = (r.choose m : ℤ) * ((r - m).choose j : ℤ) := by exact_mod_cast hcm
    rw [show (-1 : ℤ) ^ j * (r.choose (m + j)) * ((m + j).choose m)
          = (-1 : ℤ) ^ j * ((r.choose (m + j) : ℤ) * ((m + j).choose m : ℤ)) by ring,
        hcast]
    ring
  rw [Finset.sum_congr rfl hstep, ← Finset.mul_sum]
  -- inner: Σ_{j < (r+1)-m} (-1)^j C(r-m, j) = if r-m = 0 then 1 else 0
  have hrange : (r + 1) - m = (r - m) + 1 := by omega
  rw [hrange]
  have halt : (∑ j ∈ range ((r - m) + 1), (-1 : ℤ) ^ j * ((r - m).choose j))
      = if r - m = 0 then 1 else 0 := Int.alternating_sum_range_choose
  rw [halt]
  by_cases hrm : r = m
  · subst hrm; simp
  · have : r - m ≠ 0 := by omega
    simp [this, hrm]

/-- **R.MKH.2 — Newton–Möbius inversion.**

With `ν` the finite-difference layers of `κ`, the binomial transform
recovers `κ`:  `κ_r = Σ_{k=0}^r C(r,k)·ν_k`. -/
theorem R_MKH_2_inversion (r : ℕ) :
    κ r = ∑ k ∈ range (r + 1), (r.choose k : ℝ) * nu κ k := by
  -- Expand ν_k and swap the double sum; the inner κ_m coefficient is
  -- Σ_{k=m}^r (-1)^{k-m} C(r,k) C(k,m) = [r=m] by orthogonality.
  have expand :
      (∑ k ∈ range (r + 1), (r.choose k : ℝ) * nu κ k)
        = ∑ k ∈ range (r + 1), ∑ m ∈ range (k + 1),
            (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ) * κ m) := by
    apply Finset.sum_congr rfl
    intro k _
    rw [nu, Finset.mul_sum]
  rw [expand]
  -- First extend the inner range from range (k+1) to range (r+1):
  -- the extra terms (m > k) vanish since C(k,m) = 0.
  have extend :
      (∑ k ∈ range (r + 1), ∑ m ∈ range (k + 1),
          (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ) * κ m))
        = ∑ k ∈ range (r + 1), ∑ m ∈ range (r + 1),
            (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ) * κ m) := by
    apply Finset.sum_congr rfl
    intro k hk
    rw [Finset.mem_range, Nat.lt_succ_iff] at hk
    have hsub : range (k + 1) ⊆ range (r + 1) :=
      Finset.range_subset_range.mpr (by omega : k + 1 ≤ r + 1)
    rw [← Finset.sum_subset hsub]
    intro m _ hm
    rw [Finset.mem_range, not_lt, Nat.succ_le_iff] at hm
    rw [Nat.choose_eq_zero_of_lt hm]; simp
  rw [extend, Finset.sum_comm]
  -- reorganize into Σ_m (Σ_k coeff) κ_m
  have key :
      (∑ m ∈ range (r + 1), ∑ k ∈ range (r + 1),
          (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ) * κ m))
        = ∑ m ∈ range (r + 1),
            (∑ k ∈ range (r + 1),
              (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ))) * κ m := by
    apply Finset.sum_congr rfl
    intro m _
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro k _
    ring
  rw [key]
  -- inner coefficient equals [r = m] via orthogonality (cast to ℝ)
  have coeff : ∀ m ∈ range (r + 1),
      (∑ k ∈ range (r + 1),
        (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ)))
        = if r = m then 1 else 0 := by
    intro m hm
    have hmr : m ≤ r := by simpa [Nat.lt_succ_iff] using hm
    have hint := binomial_orthogonality r m hmr
    have hcast :
        (∑ k ∈ range (r + 1),
          (r.choose k : ℝ) * ((-1 : ℝ) ^ (k - m) * (k.choose m : ℝ)))
          = ((∑ k ∈ range (r + 1),
              (-1 : ℤ) ^ (k - m) * (r.choose k) * (k.choose m) : ℤ) : ℝ) := by
      push_cast
      apply Finset.sum_congr rfl
      intro k _
      ring
    rw [hcast, hint]
    by_cases h : r = m <;> simp [h]
  -- collapse each outer summand using `coeff`, then the [r=m] indicator
  rw [Finset.sum_congr rfl (fun m hm => by rw [coeff m hm])]
  -- Σ_m (if r=m then 1 else 0) * κ_m = κ_r
  rw [Finset.sum_eq_single r]
  · simp
  · intro b _ hb
    simp [Ne.symm hb]
  · intro hb
    exact absurd (Finset.mem_range.mpr (Nat.lt_succ_self r)) hb

end MobiusKappa

end MIP
