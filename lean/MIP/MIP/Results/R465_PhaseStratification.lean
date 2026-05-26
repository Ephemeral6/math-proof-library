/-
Result R.465 — training phase transitions as `H_n` birth–death stratification.

Reference: `workspace/k_a_simplicial_homology.md` §2.4 (R.465)
(A 条件性 / conditional-A: built on R.464 + T.30 three-layer stratification).

**Statement.** In the persistent-homology picture each homology class `[γ]` has
a *birth* time `b(γ)` (when it first appears) and a *death* time `d(γ)` (when it
is filled), with `b(γ) < d(γ)`. The training timeline then carries a natural
stratification by the ordered extinction times
```
    t_0 < t_1 < t_2 < ⋯ ,        t_n := death time of all n-holes,
```
giving a candidate topological reading of "grokking" / emergent abilities (each
emergence = one `H_n` extinction event). The source asks for a clean
*ordering / partition* theorem.

We reduce to the **order-theoretic kernel**: we formalise a finite barcode
(`Bar` = a birth–death pair with `birth < death`) and a strictly increasing
family of stratum boundaries `t : Fin (m+1) → ℝ`, and prove

* every barcode has positive lifetime and lies between its birth and death
  (`Bar.birth_lt_death`, `Bar.mem_lifetime`);
* the boundaries induce half-open strata `[t i, t (i+1))` that are pairwise
  disjoint (`R_465_strata_disjoint`) and whose union is `[t 0, t (last))`
  (`R_465_strata_cover`) — a genuine partition of the training interval;
* the ordering `t_0 < t_1 < ⋯` is exactly strict monotonicity of `t`
  (`R_465_strata_ordered`).

The homological *content* (which class dies at which `t_n`) is documented but
not asserted; only the partition/ordering skeleton is proved.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Order.SetNotation
import Mathlib.Data.Set.Lattice
import Mathlib.Data.Fin.Basic
import Mathlib.Order.Fin.Basic
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Finset.Max
import Mathlib.Tactic.Linarith

namespace MIP

namespace PhaseStratification

/-- A **persistence barcode** for a homology class: a birth time strictly below
its death time. `Δ := death − birth > 0` is the lifetime (persistence). -/
structure Bar where
  /-- Birth time `b(γ)`: when `[γ]` first appears in `H_n`. -/
  birth : ℝ
  /-- Death time `d(γ)`: when `[γ]` is filled. -/
  death : ℝ
  /-- A class is born strictly before it dies. -/
  birth_lt_death : birth < death

namespace Bar

/-- The lifetime (persistence) `d(γ) − b(γ) > 0`. -/
def lifetime (β : Bar) : ℝ := β.death - β.birth

/-- **R.465 — lifetime is positive.** -/
theorem lifetime_pos (β : Bar) : 0 < β.lifetime := by
  unfold lifetime; linarith [β.birth_lt_death]

/-- **R.465 — a class is alive on `[birth, death)`.** Membership form: any time
`t` with `birth ≤ t < death` lies in the lifetime window. -/
theorem mem_lifetime (β : Bar) {t : ℝ} (h₁ : β.birth ≤ t) (h₂ : t < β.death) :
    t ∈ Set.Ico β.birth β.death := ⟨h₁, h₂⟩

end Bar

/-- A **stratification** of the training timeline: `m+1` strictly increasing
boundary times `t_0 < t_1 < ⋯ < t_m`. Each `t i` is an extinction threshold;
the open strata between consecutive boundaries are the training phases. -/
structure Strat (m : ℕ) where
  /-- The stratum boundary times. -/
  t : Fin (m + 1) → ℝ
  /-- Boundaries are strictly increasing: `t_0 < t_1 < ⋯`. -/
  strictMono : StrictMono t

namespace Strat

variable {m : ℕ}

/-- The `i`-th half-open stratum `[t_i, t_{i+1})` (for `i : Fin m`). -/
def stratum (S : Strat m) (i : Fin m) : Set ℝ :=
  Set.Ico (S.t i.castSucc) (S.t i.succ)

/-- **R.465 — strata are ordered.** Restatement that boundaries increase:
`t i < t j` whenever `i < j`. This is the `t_0 < t_1 < t_2 < ⋯` ordering of
extinction times. -/
theorem R_465_strata_ordered (S : Strat m) {i j : Fin (m + 1)} (h : i < j) :
    S.t i < S.t j := S.strictMono h

/-- **R.465 — consecutive boundaries are strictly ordered.** -/
theorem R_465_boundary_lt (S : Strat m) (i : Fin m) :
    S.t i.castSucc < S.t i.succ :=
  S.strictMono (by
    rw [Fin.lt_def, Fin.val_succ, Fin.val_castSucc]
    omega)

/-- **R.465 — distinct strata are disjoint.**

For `i < j` (as elements of `Fin m`), the strata `[t_i, t_{i+1})` and
`[t_j, t_{j+1})` are disjoint: every point of the earlier stratum is `< t_j`,
which is the left end of the later one. -/
theorem R_465_strata_disjoint (S : Strat m) {i j : Fin m} (hij : i < j) :
    Disjoint (S.stratum i) (S.stratum j) := by
  rw [Set.disjoint_left]
  rintro x ⟨_, hx_lt⟩ ⟨hx_ge, _⟩
  -- hx_lt : x < t (i.succ),  hx_ge : t (j.castSucc) ≤ x
  -- i.succ ≤ j.castSucc because i < j
  have hle : S.t i.succ ≤ S.t j.castSucc := by
    have hval : (i.succ : Fin (m + 1)) ≤ j.castSucc := by
      rw [Fin.le_iff_val_le_val, Fin.val_succ, Fin.val_castSucc]
      have : (i : ℕ) < (j : ℕ) := hij
      omega
    rcases lt_or_eq_of_le hval with h | h
    · exact le_of_lt (S.strictMono h)
    · exact le_of_eq (congrArg S.t h)
  linarith

/-- **R.465 — the strata cover the training interval `[t_0, t_m)`.**

The union of all half-open strata `[t_i, t_{i+1})` over `i : Fin m` equals the
full half-open interval `[t_0, t_m)` between the first and last boundary. This
is the "the strata partition time" claim. -/
theorem R_465_strata_cover (S : Strat m) :
    (⋃ i : Fin m, S.stratum i) = Set.Ico (S.t 0) (S.t (Fin.last m)) := by
  ext x
  simp only [Set.mem_iUnion, stratum, Set.mem_Ico]
  constructor
  · rintro ⟨i, hge, hlt⟩
    refine ⟨?_, ?_⟩
    · -- t 0 ≤ t (i.castSucc) ≤ x
      refine le_trans ?_ hge
      rcases eq_or_lt_of_le (Fin.zero_le i.castSucc) with h | h
      · exact le_of_eq (congrArg S.t h)
      · exact le_of_lt (S.strictMono h)
    · -- x < t (i.succ) ≤ t (last)
      refine lt_of_lt_of_le hlt ?_
      rcases eq_or_lt_of_le (Fin.le_last i.succ) with h | h
      · exact le_of_eq (congrArg S.t h)
      · exact le_of_lt (S.strictMono h)
  · rintro ⟨hge, hlt⟩
    classical
    -- Work at the value level.  Let `P j := j ≤ m ∧ S.t ⟨j,_⟩ ≤ x`.  We search
    -- for the largest natural `j ≤ m` with `S.t ⟨j, _⟩ ≤ x`.  Define the
    -- monotone-in-`x` boundary-value function on ℕ via `Fin.ofNat`-free access.
    -- Helper: value of t at a nat index `j ≤ m`.
    let f : ℕ → ℝ := fun j => if h : j < m + 1 then S.t ⟨j, h⟩ else x + 1
    have hf0 : f 0 = S.t 0 := by simp only [f]; rw [dif_pos (Nat.zero_lt_succ m)]; rfl
    -- The set of j ≤ m with f j ≤ x is a nonempty, bounded set of naturals.
    let Q : ℕ → Prop := fun j => j ≤ m ∧ f j ≤ x
    have hQ0 : Q 0 := ⟨Nat.zero_le m, by rw [hf0]; exact hge⟩
    -- Greatest such j via the bounded predicate (finite search up to m).
    obtain ⟨j, hjQ, hjmax⟩ :
        ∃ j, Q j ∧ ∀ j', Q j' → j' ≤ j := by
      -- among {0,…,m} pick the max satisfying Q; use Finset.max' on the filter.
      let s : Finset ℕ := (Finset.range (m + 1)).filter Q
      have hs_ne : s.Nonempty := ⟨0, by
        simp only [s, Finset.mem_filter, Finset.mem_range]
        exact ⟨Nat.zero_lt_succ m, hQ0⟩⟩
      refine ⟨s.max' hs_ne, ?_, ?_⟩
      · have := s.max'_mem hs_ne
        simp only [s, Finset.mem_filter, Finset.mem_range] at this
        exact this.2
      · intro j' hj'
        apply s.le_max'
        simp only [s, Finset.mem_filter, Finset.mem_range]
        exact ⟨Nat.lt_succ_of_le hj'.1, hj'⟩
    obtain ⟨hjm, hfj⟩ := hjQ
    -- j ≠ m, since f m = S.t (last) > x.
    have hfm : f m = S.t (Fin.last m) := by
      simp only [f]; rw [dif_pos (Nat.lt_succ_self m)]; rfl
    have hj_ne_m : j ≠ m := by
      intro h; subst h
      rw [hfm] at hfj
      exact absurd hfj (not_le.mpr hlt)
    have hj_lt_m : j < m := lt_of_le_of_ne hjm hj_ne_m
    -- The stratum index is ⟨j, hj_lt_m⟩.
    refine ⟨⟨j, hj_lt_m⟩, ?_, ?_⟩
    · -- t (castSucc) = t ⟨j,_⟩ = f j ≤ x
      have hcast : (⟨j, hj_lt_m⟩ : Fin m).castSucc = ⟨j, Nat.lt_succ_of_lt hj_lt_m⟩ :=
        by apply Fin.ext; rfl
      rw [hcast]
      have : S.t ⟨j, Nat.lt_succ_of_lt hj_lt_m⟩ = f j := by
        simp only [f]; rw [dif_pos (Nat.lt_succ_of_lt hj_lt_m)]
      rw [this]; exact hfj
    · -- x < t (succ) = f (j+1), else j+1 ∈ Q contradicting maximality.
      have hsucc : (⟨j, hj_lt_m⟩ : Fin m).succ = ⟨j + 1, Nat.succ_lt_succ hj_lt_m⟩ :=
        by apply Fin.ext; rfl
      rw [hsucc]
      have hval : S.t ⟨j + 1, Nat.succ_lt_succ hj_lt_m⟩ = f (j + 1) := by
        simp only [f]; rw [dif_pos (Nat.succ_lt_succ hj_lt_m)]
      rw [hval]
      by_contra hc
      rw [not_lt] at hc  -- hc : f (j+1) ≤ x
      have : j + 1 ≤ j := hjmax (j + 1) ⟨hj_lt_m, hc⟩
      omega

end Strat

end PhaseStratification

end MIP
