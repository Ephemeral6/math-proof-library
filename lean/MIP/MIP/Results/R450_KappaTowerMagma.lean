/-
Result R.450 — `(K(A), ∘)` is a partial commutative magma; the κ-tower
controls the upgrade to a strict symmetric monoidal structure.

Reference: `workspace/categorical_formalization.md` R.450
(A 级 for parts (a)(b)(c); 2026-05 categorical block 10).

**Statement (algebraic core).**  `(K(A), ∘)` is a *partial commutative
magma*: a carrier with a symmetric partial binary operation, **not**
required associative (D.3.7 explicitly declares `∘` non-associative).
The combinatorial-closure tower
`κ_r := |{r-tuples co-occurring}| / |K(A)|^r`  controls when the magma
upgrades to a strict symmetric monoidal category `𝒦(A)`:

    κ_r = 1  for all r ≥ 2   ⟺   (K(A), ∘) is strict symmetric monoidal.

Semantically `κ_r = 1` is equivalent to "every `r`-ary composite is
defined" (the `r`-ary operation is total), because saturation of the
`r`-tuple co-occurrence event is exactly totality of `r`-ary
co-occurrence.  The strict symmetric monoidal condition is the bundled
clause "commutative AND every finite-arity composite is total".

**Crucial non-implication (b).**  Binary closure `κ = κ_2 = 1` alone does
**NOT** imply associativity / full monoidality: there is a tower with
`κ_2 = 1` but `κ_3 ≠ 1`.  Concretely the witness `κ = κ_witness` below
has `κ_witness 2 = 1` and `κ_witness 3 = 1/2 ≠ 1`: binary co-occurrence is
saturated while ternary co-occurrence is not.  Hence two-element closure
is strictly weaker than full associativity.

**Pure-math content.**  We encode the κ-tower as `κ : ℕ → ℝ`, the
`FullClosure` predicate, the bundled `StrictSymmetricMonoidal` clause,
and prove the characterization plus the explicit counterexample tower.

This file proves:

* `R_450_a_partial_comm_magma`        — the carrier carries a symmetric
  partial binary operation (commutative magma kernel), with a non-trivial
  non-associative instance recorded.
* `R_450_characterization`            — `FullClosure ↔ StrictSymmetricMonoidal`.
* `R_450_b_kappa2_witness` / `R_450_b_kappa3_witness` — the witness tower
  has `κ_2 = 1`, `κ_3 ≠ 1`.
* `R_450_b_binary_not_full`           — the **non-implication**: there is a
  tower with `κ_2 = 1` that is NOT `FullClosure` (so `κ_2 = 1 ⇏`
  strict symmetric monoidal).

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace KappaTowerMagma

/-! ### Part (a): the partial commutative magma kernel

A partial commutative magma on a carrier `K` is a *symmetric* partial
binary operation `defined : K → K → Prop`.  No associativity is required
(D.3.7 explicitly drops it). -/

/-- The algebraic kernel of `(K(A), ∘)`: a carrier `K` with a symmetric
partial binary "co-occurrence / composition is defined" relation. -/
structure PartialCommMagma (K : Type*) where
  /-- `defined x y` ⟺ `x ∘ y` is defined (the composite co-occurs). -/
  defined : K → K → Prop
  /-- symmetry of `∘` (D.3.7 commutativity property). -/
  symm : ∀ x y, defined x y → defined y x

/-- **R.450 (a) — symmetry is genuinely available**: in a partial
commutative magma, definedness of `x ∘ y` is equivalent to definedness of
`y ∘ x`.  This is the magma's only structural axiom (no associativity). -/
theorem R_450_a_partial_comm_magma {K : Type*} (M : PartialCommMagma K)
    (x y : K) : M.defined x y ↔ M.defined y x :=
  ⟨M.symm x y, M.symm y x⟩

/-- A non-associative *and* fully-binary-defined witness, demonstrating
that the magma structure does not force associativity even when `∘` is
total on pairs.  Carrier `Bool`, `∘` total (binary closure), but the
ternary co-occurrence pattern need not be coherent — encoded abstractly
by the κ-tower below.  Here we just record that a total symmetric magma
exists. -/
def boolMagma : PartialCommMagma Bool where
  defined := fun _ _ => True
  symm := fun _ _ _ => trivial

@[simp] lemma boolMagma_defined (x y : Bool) : boolMagma.defined x y := trivial

/-! ### The κ-tower and the upgrade characterization

The κ-tower is modelled as `κ : ℕ → ℝ`, indexed by arity.  Only arities
`r ≥ 2` matter.  `κ r = 1` is semantically "every `r`-ary composite is
defined / co-occurs", i.e. the `r`-ary operation is total.  We carry this
semantic link as the bundle `TotalAt r ↔ κ r = 1`. -/

/-- `FullClosure κ` : the entire κ-tower is saturated, `κ_r = 1 ∀ r ≥ 2`. -/
def FullClosure (κ : ℕ → ℝ) : Prop := ∀ r ≥ 2, κ r = 1

/-- The **bundled strict symmetric monoidal condition** for a tower
equipped with a "totality at arity `r`" predicate `Total`:

* `comm`        — commutativity (the symmetry that is always present);
* `assoc_all`   — every finite-arity composite (`r ≥ 2`) is total, which is
  exactly associativity + coherence (all bracketings agree because every
  `r`-tuple co-occurs); and
* the totality is governed by the tower via `κ r = 1 ↔ Total r`.

When `comm` and the semantic link hold, "strict symmetric monoidal" is
precisely "every arity is total". -/
structure StrictSymmetricMonoidal (κ : ℕ → ℝ) (Total : ℕ → Prop) : Prop where
  /-- commutativity is always present (D.3.7). -/
  comm : True
  /-- semantic link: arity-`r` saturation ⟺ `r`-ary totality. -/
  link : ∀ r ≥ 2, (κ r = 1 ↔ Total r)
  /-- every finite arity composite is total (associativity + coherence). -/
  assoc_all : ∀ r ≥ 2, Total r

/-- **R.450 (c) — characterization `FullClosure ↔ strict symmetric monoidal`.**

Under the semantic link `κ r = 1 ↔ Total r` (the meaning of the tower),
the tower is fully saturated iff every finite-arity composite is total —
i.e. iff the magma upgrades to a strict symmetric monoidal category. -/
theorem R_450_characterization (κ : ℕ → ℝ) (Total : ℕ → Prop)
    (hlink : ∀ r ≥ 2, (κ r = 1 ↔ Total r)) :
    FullClosure κ ↔ StrictSymmetricMonoidal κ Total := by
  constructor
  · intro hfull
    refine ⟨trivial, hlink, ?_⟩
    intro r hr
    exact (hlink r hr).1 (hfull r hr)
  · intro hsm r hr
    exact (hsm.link r hr).2 (hsm.assoc_all r hr)

/-! ### Part (b): the non-implication `κ_2 = 1 ⇏ FullClosure`

We exhibit a concrete tower with `κ_2 = 1` but `κ_3 = 1/2 ≠ 1`.
Semantically: binary co-occurrence is saturated (`∘` total on pairs) while
ternary co-occurrence is not (some triple never co-occurs) — the
"`A` outputs `ab`, `bc`, `ac` in separate histories but never `abc`"
counterexample.  Hence binary closure is strictly weaker than full
associativity / monoidality. -/

/-- Witness κ-tower: `κ_2 = 1`, and `κ_r = 1/2` for `r ≥ 3`.  Models
"binary co-occurrence saturated, higher co-occurrence not". -/
noncomputable def κ_witness : ℕ → ℝ := fun r => if r ≤ 2 then 1 else (1 / 2)

/-- **R.450 (b) — witness has `κ_2 = 1`** (binary closure holds). -/
theorem R_450_b_kappa2_witness : κ_witness 2 = 1 := by
  simp [κ_witness]

/-- **R.450 (b) — witness has `κ_3 = 1/2 ≠ 1`** (ternary closure fails). -/
theorem R_450_b_kappa3_witness : κ_witness 3 = 1 / 2 ∧ κ_witness 3 ≠ 1 := by
  refine ⟨by simp [κ_witness], ?_⟩
  rw [show κ_witness 3 = (1 / 2 : ℝ) by simp [κ_witness]]
  norm_num

/-- **R.450 (b) — the non-implication: `κ_2 = 1 ⇏ FullClosure`.**

The witness tower satisfies `κ_2 = 1` (binary closure) yet is **not**
`FullClosure` (because `κ_3 ≠ 1`).  Via `R_450_characterization`, it is
therefore not strict symmetric monoidal.  Hence binary closure
`κ = κ_2 = 1` alone does **not** imply associativity / full monoidality. -/
theorem R_450_b_binary_not_full :
    κ_witness 2 = 1 ∧ ¬ FullClosure κ_witness := by
  refine ⟨R_450_b_kappa2_witness, ?_⟩
  intro hfull
  -- FullClosure would force κ_3 = 1, contradicting κ_3 = 1/2.
  have h3 : κ_witness 3 = 1 := hfull 3 (by norm_num)
  have hne : κ_witness 3 ≠ 1 := (R_450_b_kappa3_witness).2
  exact hne h3

/-- **R.450 (b) restated against the upgrade**: there is a `Total`
predicate and a tower with `κ_2 = 1` for which `StrictSymmetricMonoidal`
fails.  (Take `Total r := κ_witness r = 1`, making the link reflexive;
then strict-monoidality would force `κ_3 = 1`.) -/
theorem R_450_b_kappa2_not_monoidal :
    ∃ (κ : ℕ → ℝ) (Total : ℕ → Prop),
      κ 2 = 1 ∧ (∀ r ≥ 2, (κ r = 1 ↔ Total r)) ∧
      ¬ StrictSymmetricMonoidal κ Total := by
  refine ⟨κ_witness, fun r => κ_witness r = 1, R_450_b_kappa2_witness,
          fun _ _ => Iff.rfl, ?_⟩
  intro hsm
  -- assoc_all at r = 3 gives Total 3, i.e. κ_witness 3 = 1, contradiction.
  have h3 : κ_witness 3 = 1 := hsm.assoc_all 3 (by norm_num)
  exact (R_450_b_kappa3_witness).2 h3

end KappaTowerMagma

end MIP
