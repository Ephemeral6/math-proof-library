/-
Result R.31w — Combinatorial-closure degree κ is independent of knowledge
size |K| (four-quadrant free-variation, weak form A).

Reference: `C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md`
R.31w / Cj.19 (升 A; 2026 derived branch, deps R.61, C.9).

**Statement.** The combinatorial-closure degree `κ` of an AI system is not
a function of its knowledge-set size `|K|`: the two attributes vary freely.
Concretely, one can exhibit AI systems spanning all *four quadrants* of the
`(|K|, κ)` plane — small/large `|K|` crossed with low/high `κ` — because
`|K|` is set by the scaling mechanism (parameters/data) while `κ` is set by
a distinct mechanism (combinatorial-closure training).  Hence there is no
function `f` with `κ = f(|K|)`:

* there are two systems with the **same** `|K|` but **different** `κ`
  (so `κ` is not determined by `|K|`); and
* there are two systems with the **same** `κ` but **different** `|K|`
  (so `|K|` is not determined by `κ`).

**Witness (four corners of the `(|K|, κ)` plane).**

| system | mechanism                       | `|K|` | `κ` |
|--------|---------------------------------|-------|-----|
| A₁     | small base + closure training   | small | high|
| A₂     | small base, no closure training | small | low |
| A₃     | large base + closure training   | large | high|
| A₄     | large base, no closure training | large | low |

We index a pool by `Fin 4`, give each system the two real attributes
`Kcard, κ : Fin 4 → ℝ` with explicit numeric values, exhibit all four
quadrant corners, and prove the two non-functional-dependence facts.

**This file is `axiom`-free.**  We posit a finite pool with two
real-valued attributes and prove independence via explicit numeric
witnesses (matching the R.19 witness/counterexample style).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace KappaIndependence

/-- A finite pool of AI systems, each carrying two real-valued attributes:

* `Kcard a` — the size `|K(a)|` of agent `a`'s knowledge set (scaling axis);
* `κ a`     — the combinatorial-closure degree of agent `a` (closure axis).

Per the source (R.61, C.9) these are set by independent training
mechanisms, hence are independent observables. -/
structure SystemPool (ι : Type*) where
  /-- Knowledge-set cardinality `|K(a)|` (large = more scaling). -/
  Kcard : ι → ℝ
  /-- Combinatorial-closure degree `κ(a)` (high = better closure). -/
  κ     : ι → ℝ

variable {ι : Type*}

/-- `a` lies in the *low-`Kcard`, high-`κ`* quadrant relative to thresholds
`(k₀, κ₀)`: small knowledge but high closure. -/
def InQuadrantLoHi (pool : SystemPool ι) (k₀ κ₀ : ℝ) (a : ι) : Prop :=
  pool.Kcard a < k₀ ∧ κ₀ < pool.κ a

/-- `a` lies in the *low-`Kcard`, low-`κ`* quadrant. -/
def InQuadrantLoLo (pool : SystemPool ι) (k₀ κ₀ : ℝ) (a : ι) : Prop :=
  pool.Kcard a < k₀ ∧ pool.κ a < κ₀

/-- `a` lies in the *high-`Kcard`, high-`κ`* quadrant. -/
def InQuadrantHiHi (pool : SystemPool ι) (k₀ κ₀ : ℝ) (a : ι) : Prop :=
  k₀ < pool.Kcard a ∧ κ₀ < pool.κ a

/-- `a` lies in the *high-`Kcard`, low-`κ`* quadrant. -/
def InQuadrantHiLo (pool : SystemPool ι) (k₀ κ₀ : ℝ) (a : ι) : Prop :=
  k₀ < pool.Kcard a ∧ pool.κ a < κ₀

/-- **R.31w — abstract independence.**

If two agents `a b` agree on `Kcard` but differ on `κ`, then `κ` cannot be
a function of `Kcard`: any `f` with `κ = f ∘ Kcard` would force
`κ a = f (Kcard a) = f (Kcard b) = κ b`, contradicting `κ a ≠ κ b`. -/
theorem R_31w_kappa_not_function_of_K
    (pool : SystemPool ι) (a b : ι)
    (hK : pool.Kcard a = pool.Kcard b)
    (hκ : pool.κ a ≠ pool.κ b) :
    ¬ ∃ f : ℝ → ℝ, ∀ x, pool.κ x = f (pool.Kcard x) := by
  rintro ⟨f, hf⟩
  apply hκ
  rw [hf a, hf b, hK]

/-- **R.31w — abstract independence (other direction).**

If two agents `a b` agree on `κ` but differ on `Kcard`, then `Kcard`
cannot be a function of `κ`. -/
theorem R_31w_K_not_function_of_kappa
    (pool : SystemPool ι) (a b : ι)
    (hκ : pool.κ a = pool.κ b)
    (hK : pool.Kcard a ≠ pool.Kcard b) :
    ¬ ∃ f : ℝ → ℝ, ∀ x, pool.Kcard x = f (pool.κ x) := by
  rintro ⟨f, hf⟩
  apply hK
  rw [hf a, hf b, hκ]

/-- **R.31w — concrete four-quadrant witness pool.**

`Fin 4`-indexed pool with thresholds `(k₀, κ₀) = (5, 5)`:

| idx | system | `Kcard` | `κ` | quadrant            |
|-----|--------|---------|-----|---------------------|
| 0   | A₁     | 1       | 9   | small `|K|`, high κ |
| 1   | A₂     | 1       | 1   | small `|K|`, low κ  |
| 2   | A₃     | 9       | 9   | large `|K|`, high κ |
| 3   | A₄     | 9       | 1   | large `|K|`, low κ  |

`Kcard` takes only `{1, 9}` and `κ` takes only `{1, 9}`, and all four
combinations occur — the plane is fully covered. -/
def witnessPool : SystemPool (Fin 4) where
  Kcard := fun a => if a.val < 2 then 1 else 9   -- 0,1 ↦ 1; 2,3 ↦ 9
  κ     := fun a => if a.val % 2 = 0 then 9 else 1 -- even ↦ 9; odd ↦ 1

/-- A₁ (`idx 0`) occupies the small-`|K|`, high-`κ` quadrant. -/
theorem R_31w_witness_A1_LoHi :
    InQuadrantLoHi witnessPool 5 5 0 := by
  constructor <;> · simp only [witnessPool]; norm_num

/-- A₂ (`idx 1`) occupies the small-`|K|`, low-`κ` quadrant. -/
theorem R_31w_witness_A2_LoLo :
    InQuadrantLoLo witnessPool 5 5 1 := by
  constructor <;> · simp only [witnessPool]; norm_num

/-- A₃ (`idx 2`) occupies the large-`|K|`, high-`κ` quadrant. -/
theorem R_31w_witness_A3_HiHi :
    InQuadrantHiHi witnessPool 5 5 2 := by
  constructor <;> · simp only [witnessPool]; norm_num

/-- A₄ (`idx 3`) occupies the large-`|K|`, low-`κ` quadrant. -/
theorem R_31w_witness_A4_HiLo :
    InQuadrantHiLo witnessPool 5 5 3 := by
  constructor <;> · simp only [witnessPool]; norm_num

/-- **R.31w — all four quadrants are occupied (full plane coverage).**

There exist four systems `a₁ a₂ a₃ a₄` realising every quadrant corner of
the `(|K|, κ)` plane. -/
theorem R_31w_four_quadrants_covered :
    ∃ a₁ a₂ a₃ a₄ : Fin 4,
      InQuadrantLoHi witnessPool 5 5 a₁ ∧
      InQuadrantLoLo witnessPool 5 5 a₂ ∧
      InQuadrantHiHi witnessPool 5 5 a₃ ∧
      InQuadrantHiLo witnessPool 5 5 a₄ :=
  ⟨0, 1, 2, 3,
    R_31w_witness_A1_LoHi, R_31w_witness_A2_LoLo,
    R_31w_witness_A3_HiHi, R_31w_witness_A4_HiLo⟩

/-- **R.31w — `κ` is not a function of `|K|` (concrete).**

A₁ and A₂ share `Kcard = 1` but have `κ = 9` vs `κ = 1`, so no `f` gives
`κ = f(|K|)`. -/
theorem R_31w_kappa_independent_of_K :
    ¬ ∃ f : ℝ → ℝ, ∀ x, witnessPool.κ x = f (witnessPool.Kcard x) := by
  apply R_31w_kappa_not_function_of_K witnessPool 0 1
  · simp only [witnessPool]; norm_num
  · simp only [witnessPool]; norm_num

/-- **R.31w — `|K|` is not a function of `κ` (concrete).**

A₁ and A₃ share `κ = 9` but have `Kcard = 1` vs `Kcard = 9`, so no `f`
gives `|K| = f(κ)`. -/
theorem R_31w_K_independent_of_kappa :
    ¬ ∃ f : ℝ → ℝ, ∀ x, witnessPool.Kcard x = f (witnessPool.κ x) := by
  apply R_31w_K_not_function_of_kappa witnessPool 0 2
  · simp only [witnessPool]; norm_num
  · simp only [witnessPool]; norm_num

/-- **R.31w — full independence statement.**

The combinatorial-closure degree `κ` and the knowledge size `|K|` vary
freely: all four quadrants of the `(|K|, κ)` plane are occupied, and
neither coordinate is a function of the other. -/
theorem R_31w_independence :
    (∃ a₁ a₂ a₃ a₄ : Fin 4,
      InQuadrantLoHi witnessPool 5 5 a₁ ∧
      InQuadrantLoLo witnessPool 5 5 a₂ ∧
      InQuadrantHiHi witnessPool 5 5 a₃ ∧
      InQuadrantHiLo witnessPool 5 5 a₄) ∧
    (¬ ∃ f : ℝ → ℝ, ∀ x, witnessPool.κ x = f (witnessPool.Kcard x)) ∧
    (¬ ∃ f : ℝ → ℝ, ∀ x, witnessPool.Kcard x = f (witnessPool.κ x)) :=
  ⟨R_31w_four_quadrants_covered,
   R_31w_kappa_independent_of_K,
   R_31w_K_independent_of_kappa⟩

end KappaIndependence

end MIP
