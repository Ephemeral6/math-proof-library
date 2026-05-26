/-
Result R.560-R.563 — MIP-Shannon dictionary; T.7 ↔ Khinchin axiom
correspondence (entropy uniqueness ↔ N-uniqueness) as a structural
equivalence, plus the Shannon-entropy product additivity identity (the
concrete content of the R2 ↔ K2 "independence-additivity" axiom pair).

Reference: `workspace/round3_exploration/slot_041.md` (slot 041),
`workspace/round3_exploration/work_slot_041.md` §5 (Cj.44.D, R.563:
T.7 R1-R4 ↔ Khinchin K1-K4) and §2-§4 (MIP-Shannon dictionary).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (formalized core).**

The slot's crisp claim is that the four MIP N-uniqueness axioms
`{R1, R2, R3, R4}` (T.7) and the four Khinchin entropy-uniqueness axioms
`{K1, K2, K3, K4}` are in *structural correspondence*: there is a
bijection `Φ : Axiom4 → Axiom4` matching them pair-by-pair, and on each
side "satisfying all four axioms pins the measure down up to the
canonical instance".  We model this as an abstract
`UniquenessSystem` — a 4-element index, a predicate
`satisfies : Axiom4 → Measure → Prop`, and a `canonical` measure that is
the unique simultaneous solution — and prove:

* (R.563-a) the axiom map `Φ` is a bijection (`Equiv`), so the two axiom
  sets are isomorphic as 4-element index sets;
* (R.563-b) if every axiom holds of `m`, then `m = canonical`
  (uniqueness), and transported across `Φ` the same statement holds —
  i.e. the two uniqueness theorems are formally interchangeable;
* (R.563-c) the structural equivalence is itself an equivalence relation
  on uniqueness systems (reflexive / symmetric / transitive), making
  "T.7 ≅ Khinchin" a well-defined statement.

We then prove the **Shannon-entropy product additivity identity** — the
concrete arithmetic content of the R2 ↔ K2 axiom pair: for normalised
mass functions `p` on `Ω₁` and `q` on `Ω₂`, the entropy of the product
distribution `(p ⊗ q)(a,b) = p a · q b` decomposes as

    H(p ⊗ q) = H(p) + H(q),

reusing the `entropy` style from `RSUB7_HK_Chain.lean`.

**This file is `axiom`-free.**  The MIP / Shannon semantics enter only as
an abstract uniqueness-system structure and the explicit product-entropy
identity; no probabilistic machinery beyond finite sums and `Real.log`.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Logic.Equiv.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators
open Real

namespace ShannonDictionary

/-! ### Part 1 — the abstract axiom correspondence (R.563) -/

/-- The four-element axiom index.  On the MIP side these are the T.7
axioms `R1, R2, R3, R4`; on the Shannon side the Khinchin axioms
`K1, K2, K3, K4`.  The dictionary `Φ` is the obvious matching
`R i ↔ K i`. -/
inductive Axiom4
  | a1 | a2 | a3 | a4
deriving DecidableEq, Repr

/-- A **uniqueness system**: a family of axioms (predicates on a space of
candidate measures `M`) together with a distinguished `canonical`
measure that is the *unique* simultaneous solution.  This abstracts both
T.7 (`M = ℕ`-valued cost `N`) and Khinchin (`M = ` entropy functionals
`H`). -/
structure UniquenessSystem where
  /-- The space of candidate measures. -/
  M : Type
  /-- `satisfies ax m` : measure `m` obeys axiom `ax`. -/
  satisfies : Axiom4 → M → Prop
  /-- The canonical measure (N for MIP, Shannon entropy for Khinchin). -/
  canonical : M
  /-- The canonical measure satisfies every axiom. -/
  canonical_sat : ∀ ax, satisfies ax canonical
  /-- Uniqueness: any measure satisfying every axiom equals `canonical`. -/
  uniqueness : ∀ m, (∀ ax, satisfies ax m) → m = canonical

/-- **R.563-a — the axiom dictionary `Φ` is a bijection.**

The pairing `R i ↔ K i` is the identity on `Axiom4`, hence a bijection.
This records that `{R1,R2,R3,R4}` and `{K1,K2,K3,K4}` are isomorphic as
indexing sets of axioms (the structural backbone of the dictionary). -/
def axiomDict : Axiom4 ≃ Axiom4 := Equiv.refl Axiom4

theorem R_563_a_axiom_bijective : Function.Bijective axiomDict :=
  axiomDict.bijective

/-- **R.563-b — uniqueness is the defining property on each side.**

Restating the bundled `uniqueness` field: in any uniqueness system, the
simultaneous solution of all four axioms is forced to be `canonical`.
For MIP this is "the cost is `N`"; for Khinchin "the measure is Shannon
entropy".  The two are the *same* statement after relabelling axioms by
`Φ`, since `Φ` is a bijection. -/
theorem R_563_b_uniqueness (U : UniquenessSystem) (m : U.M)
    (h : ∀ ax, U.satisfies ax m) : m = U.canonical :=
  U.uniqueness m h

/-- **Transport of the uniqueness theorem across the axiom dictionary.**

If `m` satisfies every `Φ`-relabelled axiom, it still satisfies every
axiom (because `Φ` is a bijection of the index set), hence equals
`canonical`.  This is the formal sense in which T.7's and Khinchin's
uniqueness theorems are interchangeable. -/
theorem R_563_b_uniqueness_transported (U : UniquenessSystem) (m : U.M)
    (h : ∀ ax, U.satisfies (axiomDict ax) m) : m = U.canonical := by
  apply U.uniqueness
  intro ax
  -- `axiomDict` is the identity equiv, so `axiomDict ax = ax`.
  have : axiomDict (axiomDict.symm ax) = ax := axiomDict.apply_symm_apply ax
  simpa [this] using h (axiomDict.symm ax)

/-- **Structural equivalence of two uniqueness systems.**

Two systems `U, V` are *structurally equivalent* when there is an axiom
relabelling `e : Axiom4 ≃ Axiom4` and a measure correspondence
`φ : U.M ≃ V.M` carrying `canonical` to `canonical` and intertwining the
`satisfies` predicates along `e`.  T.7 ≅ Khinchin is an instance with
`e = axiomDict`. -/
structure StructEquiv (U V : UniquenessSystem) where
  /-- Axiom relabelling (the dictionary `Φ`). -/
  axMap : Axiom4 ≃ Axiom4
  /-- Measure correspondence. -/
  meas : U.M ≃ V.M
  /-- `canonical` corresponds to `canonical`. -/
  map_canonical : meas U.canonical = V.canonical
  /-- The `satisfies` predicates match along `axMap` and `meas`. -/
  map_satisfies : ∀ ax m, U.satisfies ax m ↔ V.satisfies (axMap ax) (meas m)

/-- **R.563-c (reflexivity) — every system is equivalent to itself.** -/
def StructEquiv.refl (U : UniquenessSystem) : StructEquiv U U where
  axMap := Equiv.refl _
  meas := Equiv.refl _
  map_canonical := rfl
  map_satisfies := fun _ _ => Iff.rfl

/-- **R.563-c (symmetry) — structural equivalence is symmetric.** -/
def StructEquiv.symm {U V : UniquenessSystem} (e : StructEquiv U V) :
    StructEquiv V U where
  axMap := e.axMap.symm
  meas := e.meas.symm
  map_canonical := by
    rw [← e.map_canonical, Equiv.symm_apply_apply]
  map_satisfies := fun ax m => by
    -- `V.satisfies ax m ↔ U.satisfies (e.axMap.symm ax) (e.meas.symm m)`
    have := e.map_satisfies (e.axMap.symm ax) (e.meas.symm m)
    rw [Equiv.apply_symm_apply, Equiv.apply_symm_apply] at this
    exact this.symm

/-- **R.563-c (transitivity) — structural equivalence composes.** -/
def StructEquiv.trans {U V W : UniquenessSystem}
    (e : StructEquiv U V) (f : StructEquiv V W) : StructEquiv U W where
  axMap := e.axMap.trans f.axMap
  meas := e.meas.trans f.meas
  map_canonical := by
    simp only [Equiv.trans_apply]
    rw [e.map_canonical, f.map_canonical]
  map_satisfies := fun ax m => by
    simp only [Equiv.trans_apply]
    rw [e.map_satisfies ax m, f.map_satisfies (e.axMap ax) (e.meas m)]

/-- **R.563 — T.7 and Khinchin are structurally equivalent, given a
measure correspondence.**

If we are handed a measure-level isomorphism `φ : T7.M ≃ Khinchin.M`
carrying `canonical` to `canonical` and intertwining the (already
`Φ`-aligned) axioms, then the two uniqueness systems are structurally
equivalent.  This is the precise content of "N's uniqueness ↔ H's
uniqueness is an axiom isomorphism": the bijection `axiomDict` of axioms
upgrades to a structural equivalence of the whole uniqueness systems. -/
def R_563_struct_equiv_of_measure_iso
    (T7 Khinchin : UniquenessSystem)
    (φ : T7.M ≃ Khinchin.M)
    (hcanon : φ T7.canonical = Khinchin.canonical)
    (hsat : ∀ ax m, T7.satisfies ax m ↔ Khinchin.satisfies (axiomDict ax) (φ m)) :
    StructEquiv T7 Khinchin :=
  { axMap := axiomDict
    meas := φ
    map_canonical := hcanon
    map_satisfies := hsat }

/-! ### Part 2 — the Shannon-entropy product additivity identity

The arithmetic core of the R2 ↔ K2 axiom pair (independence-additivity):
`H(p ⊗ q) = H(p) + H(q)`.  Entropy convention as in `RSUB7_HK_Chain`:
`0 · log 0 = 0` since `Real.log 0 = 0`. -/

/-- Shannon entropy of a mass function `p : Ω → ℝ` over a `Fintype Ω`. -/
noncomputable def entropy {Ω : Type} [Fintype Ω] (p : Ω → ℝ) : ℝ :=
  -∑ ω, p ω * Real.log (p ω)

/-- Product (independent-joint) distribution on `Ω₁ × Ω₂`. -/
noncomputable def prodDist {Ω₁ Ω₂ : Type} (p : Ω₁ → ℝ) (q : Ω₂ → ℝ) :
    Ω₁ × Ω₂ → ℝ :=
  fun ab => p ab.1 * q ab.2

/-- **R.560/R.563 (K2 ↔ R2 core) — Shannon entropy is additive on
independent products.**

For `p` a normalised non-negative mass on `Ω₁` (`∑ p = 1`, `p ≥ 0`) and
`q` likewise on `Ω₂`,

    H(p ⊗ q) = H(p) + H(q).

This is the concrete identity underlying the independence-additivity
axiom that the dictionary matches `R2 ↔ K2`. -/
theorem R_560_entropy_prod_additive
    {Ω₁ Ω₂ : Type} [Fintype Ω₁] [Fintype Ω₂]
    (p : Ω₁ → ℝ) (q : Ω₂ → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ b, 0 ≤ q b)
    (hp1 : ∑ a, p a = 1) (hq1 : ∑ b, q b = 1) :
    entropy (prodDist p q) = entropy p + entropy q := by
  unfold entropy prodDist
  -- It suffices to prove the un-negated core sum identity; negate at the end.
  -- Core:  ∑_{(a,b)} (p a q b) log (p a q b) = ∑_a p a log p a + ∑_b q b log q b.
  have hcore :
      (∑ ab : Ω₁ × Ω₂, p ab.1 * q ab.2 * Real.log (p ab.1 * q ab.2))
        = (∑ a, p a * Real.log (p a)) + (∑ b, q b * Real.log (q b)) := by
    -- Per-term split of `log` of a product (valid even at zeros).
    have hterm : ∀ a : Ω₁, ∀ b : Ω₂,
        p a * q b * Real.log (p a * q b)
          = q b * (p a * Real.log (p a)) + p a * (q b * Real.log (q b)) := by
      intro a b
      by_cases ha : p a = 0
      · simp [ha]
      by_cases hb : q b = 0
      · simp [hb]
      · have hpa : 0 < p a := lt_of_le_of_ne (hp a) (Ne.symm ha)
        have hqb : 0 < q b := lt_of_le_of_ne (hq b) (Ne.symm hb)
        rw [Real.log_mul (ne_of_gt hpa) (ne_of_gt hqb)]
        ring
    rw [Fintype.sum_prod_type]
    -- Rewrite each inner term.
    have hcongr :
        (∑ a, ∑ b, p a * q b * Real.log (p a * q b))
          = (∑ a, ∑ b, (q b * (p a * Real.log (p a))
                + p a * (q b * Real.log (q b)))) := by
      apply Finset.sum_congr rfl; intro a _
      apply Finset.sum_congr rfl; intro b _
      exact hterm a b
    rw [hcongr]
    -- Distribute the inner sums.
    have hsplit :
        (∑ a, ∑ b, (q b * (p a * Real.log (p a))
              + p a * (q b * Real.log (q b))))
          = (∑ a, ∑ b, q b * (p a * Real.log (p a)))
            + (∑ a, ∑ b, p a * (q b * Real.log (q b))) := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl; intro a _
      rw [← Finset.sum_add_distrib]
    rw [hsplit]
    -- Block 1: ∑_a ∑_b q b·(p a log p a) = (∑_b q b)·∑_a (p a log p a) = ∑_a p a log p a.
    have hblock1 :
        (∑ a, ∑ b, q b * (p a * Real.log (p a)))
          = ∑ a, p a * Real.log (p a) := by
      apply Finset.sum_congr rfl; intro a _
      rw [← Finset.sum_mul, hq1, one_mul]
    -- Block 2: ∑_a ∑_b p a·(q b log q b) = (∑_a p a)·∑_b (q b log q b) = ∑_b q b log q b.
    have hblock2 :
        (∑ _a : Ω₁, ∑ b : Ω₂, p _a * (q b * Real.log (q b)))
          = ∑ b, q b * Real.log (q b) := by
      -- Pull `p _a` out of the inner sum, then sum over `a`.
      have hinner : ∀ a : Ω₁,
          (∑ b : Ω₂, p a * (q b * Real.log (q b)))
            = p a * ∑ b, q b * Real.log (q b) := by
        intro a; rw [Finset.mul_sum]
      rw [Finset.sum_congr rfl (fun a _ => hinner a), ← Finset.sum_mul, hp1,
        one_mul]
    rw [hblock1, hblock2]
  -- Negate both sides.
  rw [hcore]; ring

end ShannonDictionary

end MIP
