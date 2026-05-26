/-
Result R.470 (v2 / R.474) — the saturation cardinality `κ^sat` and its
three-way classification.

Reference: `workspace/round3_exploration/work_slot_042.md` §3 (R.474, the
κ^sat cardinality trichotomy, **A unconditional**) and §4 (D.3.13
candidate: `κ^sat` knowledge-saturation degree, properties (S1)-(S3)).
Builds on `workspace/round2_partial_operad_attack.md` §2.4 (R.470, the
saturated sub-operad `K^sat(A) ⊆ K(A)`).

**Statement (algebraic kernel).**  Fix a finite knowledge space `K(A)`
(a `Fintype`).  A *saturated core* is a subset `Ksat ⊆ K(A)` (here a
`Finset`) consisting of the elements every tuple of which co-occurs — the
maximal "fully mastered" sub-operad of R.459/R.470.  The **saturation
degree** is

    κ^sat(A) := |K^sat(A)| / |K(A)| ∈ [0, 1].

This file formalises, all `axiom`-free:

* `kappaSat` : the saturation degree as a real number `|Ksat| / |K|`;
* property **(S1)** `0 ≤ κ^sat ≤ 1` (`kappaSat_nonneg`, `kappaSat_le_one`);
* property **(S2)** `κ^sat = 1 ↔ K^sat = K` (`kappaSat_eq_one_iff`) and
  the floor `κ^sat = 0 ↔ K^sat = ∅` (`kappaSat_eq_zero_iff`);
* the **three-way classification** of `κ^sat` by value
  (`R_474_trichotomy`): for a nonempty carrier exactly one of
  `κ^sat = 0`, `κ^sat = 1`, `0 < κ^sat < 1` holds, and the three cases are
  governed by `K^sat = ∅`, `K^sat = K`, and `∅ ⊊ K^sat ⊊ K`
  (`R_474_trichotomy_struct`);
* **attainability** of all three regimes (R.474's three explicit
  constructions): the empty core realises `κ^sat = 0`
  (`R_474_attain_zero`), the full core realises `κ^sat = 1`
  (`R_474_attain_one`), and for any `m ≤ n` (`0 < n`) some core realises
  `κ^sat = m / n` (`R_474_value_range`), with the intermediate split
  `0 < m < n` landing strictly inside `(0,1)` (`R_474_attain_frac`).

The trichotomy is the cleanest, strongest member of the family: it is
**A unconditional** — pure finite-cardinality arithmetic, with no appeal
to the Loday-Vallette Koszul machinery (which only enters the conditional
results R.470 v2 / R.473).

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Positivity

namespace MIP

namespace KappaSatCardinality

variable {K : Type*}

/-! ### The saturation degree `κ^sat`

`Ksat : Finset K` is a fixed saturated core (a maximal fully-co-occurring
subset, R.470 v2 / L.42.4).  We do not re-derive its existence here (that
is the Zorn argument L.42.1); the cardinality trichotomy R.474 is a fact
about *any* such core, so we take it as data. -/

/-- The **saturation degree** `κ^sat(A) = |K^sat| / |K|`, as a real number.
`Ksat` is a saturated core inside the finite carrier `K`. -/
noncomputable def kappaSat [Fintype K] (Ksat : Finset K) : ℝ :=
  (Ksat.card : ℝ) / (Fintype.card K : ℝ)

/-! ### Property (S1): `0 ≤ κ^sat ≤ 1` -/

/-- **(S1), lower half** — `κ^sat ≥ 0`. -/
theorem kappaSat_nonneg [Fintype K] (Ksat : Finset K) :
    0 ≤ kappaSat Ksat := by
  unfold kappaSat
  positivity

/-- The saturated core, being a subset of the carrier, has cardinality at
most `|K|`. -/
theorem card_ksat_le [Fintype K] (Ksat : Finset K) :
    Ksat.card ≤ Fintype.card K := by
  rw [← Finset.card_univ]
  exact Finset.card_le_univ Ksat

/-- **(S1), upper half** — `κ^sat ≤ 1`. -/
theorem kappaSat_le_one [Fintype K] [Nonempty K] (Ksat : Finset K) :
    kappaSat Ksat ≤ 1 := by
  unfold kappaSat
  have hpos : (0 : ℝ) < (Fintype.card K : ℝ) := by
    exact_mod_cast Fintype.card_pos
  rw [div_le_one hpos]
  exact_mod_cast card_ksat_le Ksat

/-! ### Property (S2): the boundary values pin down `K^sat` -/

/-- **(S2) ceiling** — `κ^sat = 1 ⟺ K^sat = K` (the core fills the whole
carrier; this is `R.450 (c)`'s `∀ r, κ_r = 1` upgrade condition). -/
theorem kappaSat_eq_one_iff [Fintype K] [Nonempty K] (Ksat : Finset K) :
    kappaSat Ksat = 1 ↔ Ksat = Finset.univ := by
  have hpos : (0 : ℝ) < (Fintype.card K : ℝ) := by
    exact_mod_cast Fintype.card_pos
  unfold kappaSat
  rw [div_eq_one_iff_eq (ne_of_gt hpos)]
  constructor
  · intro h
    have hcard : Ksat.card = Fintype.card K := by exact_mod_cast h
    exact Finset.eq_univ_of_card Ksat hcard
  · intro h
    rw [h, Finset.card_univ]

/-- **κ^sat floor** — `κ^sat = 0 ⟺ K^sat = ∅` (the saturated core is
empty: no element is fully mastered). -/
theorem kappaSat_eq_zero_iff [Fintype K] [Nonempty K] (Ksat : Finset K) :
    kappaSat Ksat = 0 ↔ Ksat = ∅ := by
  have hpos : (0 : ℝ) < (Fintype.card K : ℝ) := by
    exact_mod_cast Fintype.card_pos
  unfold kappaSat
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · have : Ksat.card = 0 := by exact_mod_cast h
      exact Finset.card_eq_zero.mp this
    · exact absurd h (ne_of_gt hpos)
  · intro h
    left
    rw [h]; simp

/-! ### R.474: the three-way classification of `κ^sat` by value

For a nonempty carrier, `κ^sat` lands in exactly one of three regimes,
each pinned to a structural condition on the saturated core:

* `κ^sat = 0`  ⟺  `K^sat = ∅`           (no mastered element);
* `κ^sat = 1`  ⟺  `K^sat = K`           (fully mastered);
* `0 < κ^sat < 1`  ⟺  `∅ ⊊ K^sat ⊊ K`   (partial mastery).
-/

/-- **R.474 — κ^sat trichotomy (value form).**  For a nonempty carrier,
`κ^sat` is either `0`, or `1`, or strictly between, and the three cases are
mutually exclusive. -/
theorem R_474_trichotomy [Fintype K] [Nonempty K] (Ksat : Finset K) :
    (kappaSat Ksat = 0 ∧ kappaSat Ksat ≠ 1) ∨
    (kappaSat Ksat = 1 ∧ kappaSat Ksat ≠ 0) ∨
    (0 < kappaSat Ksat ∧ kappaSat Ksat < 1) := by
  have h0 : 0 ≤ kappaSat Ksat := kappaSat_nonneg Ksat
  have h1 : kappaSat Ksat ≤ 1 := kappaSat_le_one Ksat
  rcases eq_or_lt_of_le h0 with hz | hz
  · -- κ^sat = 0
    left
    refine ⟨hz.symm, ?_⟩
    rw [← hz]; norm_num
  · rcases eq_or_lt_of_le h1 with ho | ho
    · -- κ^sat = 1
      right; left
      refine ⟨ho, ?_⟩
      rw [ho]; norm_num
    · -- 0 < κ^sat < 1
      right; right
      exact ⟨hz, ho⟩

/-- **R.474 — κ^sat trichotomy (structural form).**  The three value
regimes correspond exactly to `K^sat = ∅`, `K^sat = K`, and the proper
intermediate `∅ ⊊ K^sat ⊊ K`. -/
theorem R_474_trichotomy_struct [Fintype K] [Nonempty K] (Ksat : Finset K) :
    (kappaSat Ksat = 0 ↔ Ksat = ∅) ∧
    (kappaSat Ksat = 1 ↔ Ksat = Finset.univ) ∧
    ((0 < kappaSat Ksat ∧ kappaSat Ksat < 1) ↔
        (Ksat ≠ ∅ ∧ Ksat ≠ Finset.univ)) := by
  refine ⟨kappaSat_eq_zero_iff Ksat, kappaSat_eq_one_iff Ksat, ?_⟩
  constructor
  · rintro ⟨hpos, hlt⟩
    refine ⟨?_, ?_⟩
    · intro h; rw [(kappaSat_eq_zero_iff Ksat).mpr h] at hpos; exact lt_irrefl 0 hpos
    · intro h; rw [(kappaSat_eq_one_iff Ksat).mpr h] at hlt; exact lt_irrefl 1 hlt
  · rintro ⟨hne, hnu⟩
    refine ⟨?_, ?_⟩
    · rcases eq_or_lt_of_le (kappaSat_nonneg Ksat) with hz | hz
      · exact absurd ((kappaSat_eq_zero_iff Ksat).mp hz.symm) hne
      · exact hz
    · rcases eq_or_lt_of_le (kappaSat_le_one Ksat) with ho | ho
      · exact absurd ((kappaSat_eq_one_iff Ksat).mp ho) hnu
      · exact ho

/-! ### R.474: attainability of every value (the three constructions)

R.474 exhibits, for each target regime, an explicit `(K, K^sat)`
instance.  We realise the carrier as `Fin n`; the saturated core is taken
of the desired cardinality. -/

/-- The carrier `Fin n` is nonempty when `n > 0`. -/
instance finNonempty {n : ℕ} (hn : 0 < n) : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩

/-- **R.474, ε = 0 construction** — the empty saturated core realises
`κ^sat = 0` (minimal saturation: no fully-mastered element). -/
theorem R_474_attain_zero {n : ℕ} (hn : 0 < n) :
    haveI : Nonempty (Fin n) := finNonempty hn
    kappaSat (∅ : Finset (Fin n)) = 0 := by
  haveI : Nonempty (Fin n) := finNonempty hn
  exact (kappaSat_eq_zero_iff (∅ : Finset (Fin n))).mpr rfl

/-- **R.474, ε = 1 construction** — the full saturated core realises
`κ^sat = 1` (complete saturation: every element fully mastered, the
`Comm`-operad limit). -/
theorem R_474_attain_one {n : ℕ} (hn : 0 < n) :
    haveI : Nonempty (Fin n) := finNonempty hn
    kappaSat (Finset.univ : Finset (Fin n)) = 1 := by
  haveI : Nonempty (Fin n) := finNonempty hn
  exact (kappaSat_eq_one_iff (Finset.univ : Finset (Fin n))).mpr rfl

/-- **R.474 — value range.**  For every rational target `m / n` with
`m ≤ n` and `0 < n`, some saturated core inside `Fin n` realises
`κ^sat = m / n`.  This is the "κ^sat takes any value in `[0,1]`" content
of R.474 (the empty / full / `K₁ ⊔ K₂`-split constructions, uniformly
packaged through `Finset.exists_subset_card_eq`). -/
theorem R_474_value_range {m n : ℕ} (hn : 0 < n) (hmn : m ≤ n) :
    haveI : Nonempty (Fin n) := finNonempty hn
    ∃ Ksat : Finset (Fin n), kappaSat Ksat = (m : ℝ) / (n : ℝ) := by
  haveI : Nonempty (Fin n) := finNonempty hn
  have huniv : (Finset.univ : Finset (Fin n)).card = n := by
    rw [Finset.card_univ, Fintype.card_fin]
  obtain ⟨s, _, hs⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset (Fin n)))
    (n := m) (by rw [huniv]; exact hmn)
  refine ⟨s, ?_⟩
  unfold kappaSat
  rw [hs, Fintype.card_fin]

/-- **R.474, ε ∈ (0,1) construction** — the `K₁ ⊔ K₂` split.  For
`0 < m < n` there is a saturated core (the saturated clique `K₁` of size
`m`) whose saturation degree `m / n` is strictly between `0` and `1`.
Hence every rational value in `(0,1)` is attained. -/
theorem R_474_attain_frac {m n : ℕ} (hm : 0 < m) (hmn : m < n) :
    haveI : Nonempty (Fin n) := finNonempty (lt_trans hm hmn)
    ∃ Ksat : Finset (Fin n),
      kappaSat Ksat = (m : ℝ) / (n : ℝ) ∧
      0 < kappaSat Ksat ∧ kappaSat Ksat < 1 := by
  haveI : Nonempty (Fin n) := finNonempty (lt_trans hm hmn)
  obtain ⟨Ksat, hval⟩ := R_474_value_range (lt_trans hm hmn) (le_of_lt hmn)
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast lt_trans hm hmn
  refine ⟨Ksat, hval, ?_, ?_⟩
  · rw [hval]
    apply div_pos
    · exact_mod_cast hm
    · exact hnpos
  · rw [hval, div_lt_one hnpos]; exact_mod_cast hmn

end KappaSatCardinality

end MIP
