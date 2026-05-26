/-
Result R.456 — T.7 uniqueness is the universal property of the free
commutative monoid.

Reference: `workspace/categorical_formalization.md` R.456 (A 级).

**Statement (algebraic core).** Let `M(p) := Free_CommMon(B_atom(p))` be
the free commutative monoid on the set of atomic barriers.  Mathlib
models this exactly by `Multiset (atomic barrier)`: the commutative-monoid
operation is multiset addition (`+`), the unit is the empty multiset
`0`, and an element is a finite multiset of atomic barriers
(= the "atomic-barrier multiplicity vector").

T.7 proves that the only measure `μ` satisfying R1–R4 is `N`.  The
categorical reading: `N = |·|_ℕ ∘ dec`, the *sum-of-coefficients* /
word-length map, and it is the **unique** monoid homomorphism
`M(p) → ℕ` sending every generator (atomic barrier) to `1`.  This is the
universal property of the free commutative monoid: a homomorphism out of
it is freely and uniquely determined by its values on generators, and
the normalisation R3+R4 forces each generator to `1`.

**Pure-math content.** The free commutative monoid `Multiset α` has the
universal property that `AddMonoidHom (Multiset α) M` is determined by
its restriction to singletons; the "send every generator to 1" hom is
exactly `Multiset.card` (`= Multiset.cardHom`), and it is unique with
that generator behaviour.

This file proves:

* `R_456_card_of_generator`  — `cardHom` sends each generator `{b}` to `1`.
* `R_456_card_is_sum_of_coeffs` — `cardHom s = Σ` of generator
  multiplicities (sum-of-coefficients / word length), via the
  decomposition `s = Σ {a}`.
* `R_456_universal_property` — the universal property: a hom is
  determined by its generator values (`φ.comp ... = id`-style
  factorisation through singletons).
* `R_456_uniqueness` — **T.7 uniqueness**: any `AddMonoidHom (Multiset α) ℕ`
  sending every generator to `1` equals `cardHom`.
* `R_456_T7` — the packaged "N = unique cardinality map" statement: there
  exists a unique monoid hom with the generator behaviour, namely `cardHom`.

**This file is `axiom`-free.**  It imports only Mathlib and reuses the
standard `Multiset` / `AddMonoidHom` infrastructure.
-/
import Mathlib.Algebra.BigOperators.Group.Multiset.Basic
import Mathlib.Algebra.Group.Hom.Defs
import Mathlib.Data.Multiset.Basic

namespace MIP

namespace FreeMonoidUniversal

/-- The carrier of `M(p) = Free_CommMon(B_atom(p))`: the free commutative
monoid on the type of atomic barriers `B` is `Multiset B`.  Its
additive-monoid operation is multiset union, its unit the empty multiset. -/
abbrev FreeBarrierMonoid (B : Type*) := Multiset B

/-- The atomic-barrier generators: the singleton multiset `{b}`. -/
def gen {B : Type*} (b : B) : FreeBarrierMonoid B := {b}

/-- **R.456 — `N = |·|_ℕ ∘ dec` is the sum-of-coefficients / word-length map.**

`Multiset.cardHom : Multiset B →+ ℕ` is the bundled monoid homomorphism
counting elements with multiplicity.  This is the candidate `N`. -/
def N {B : Type*} : FreeBarrierMonoid B →+ ℕ := Multiset.cardHom

@[simp] lemma N_apply {B : Type*} (s : FreeBarrierMonoid B) :
    N s = Multiset.card s := rfl

/-- **R.456 (d) — `N` sends every generator (atomic barrier) to `1`.**

This is the R3+R4 normalisation: each atomic barrier has measure exactly
`1`. -/
theorem R_456_card_of_generator {B : Type*} (b : B) : N (gen b) = 1 := by
  simp [N, gen]

/-- **R.456 — `N` is the sum-of-coefficients map.**

Every element of the free commutative monoid is the (multiset) sum of its
generators: `s = Σ_{a ∈ s} {a}`.  Hence `N s = Σ_{a ∈ s} N {a}
            = Σ_{a ∈ s} 1`, the word length / total multiplicity. -/
theorem R_456_card_is_sum_of_coeffs {B : Type*} (s : FreeBarrierMonoid B) :
    N s = (s.map (fun a => N (gen a))).sum := by
  -- each generator value is 1, so the RHS sum is `card`
  have h1 : (s.map (fun a => N (gen a))) = s.map (fun _ => 1) := by
    apply Multiset.map_congr rfl
    intro a _
    exact R_456_card_of_generator a
  rw [h1, N_apply]
  -- `(s.map (fun _ => 1)).sum = card s`
  induction s using Multiset.induction_on with
  | empty => simp
  | cons a s _ => simp [Multiset.card_cons, Nat.add_comm]

/-- **R.456 (d) — universal property (factorisation through generators).**

The defining feature of the free commutative monoid: every element `s`
is the sum of its generators, `s = Σ_{a ∈ s} {a}`.  Consequently any
`AddMonoidHom` out of `Multiset B` is *determined* on all of `Multiset B`
by its values on the generators `{a}`.  We record the decomposition that
drives this. -/
theorem R_456_universal_property {B : Type*} (s : FreeBarrierMonoid B) :
    s = (s.map (fun a => gen a)).sum := by
  simp only [gen]
  exact (Multiset.sum_map_singleton s).symm

/-- **R.456 — value of any generator-normalised hom on an arbitrary element.**

If `φ : Multiset B →+ ℕ` sends every generator `{a}` to `1`, then on any
`s` it equals the sum of `1`'s over the elements of `s`, i.e. `card s`.
This is the universal property made explicit and is the engine of the
uniqueness theorem below. -/
theorem R_456_hom_eq_card_on
    {B : Type*} (φ : FreeBarrierMonoid B →+ ℕ)
    (hφ : ∀ b : B, φ (gen b) = 1) (s : FreeBarrierMonoid B) :
    φ s = Multiset.card s := by
  induction s using Multiset.induction_on with
  | empty => simp
  | cons a s ih =>
      -- a ::ₘ s = {a} + s = gen a + s
      have hcons : (a ::ₘ s) = gen a + s := by
        simp [gen, Multiset.singleton_add]
      rw [hcons, map_add, hφ a, ih, Multiset.card_add]
      simp [gen]

/-- **R.456 (e) — T.7 uniqueness.**

Any `AddMonoidHom (Multiset B) ℕ` (= monoid hom `M(p) → ℕ`, with ℕ as the
free commutative monoid on one generator) that sends every atomic-barrier
generator to `1` **equals** `N = cardHom`.  This is precisely the
universal property of the free commutative monoid, and it is the
algebraic content of the T.7 uniqueness theorem: `N` is the unique
cardinality / length map. -/
theorem R_456_uniqueness
    {B : Type*} (φ : FreeBarrierMonoid B →+ ℕ)
    (hφ : ∀ b : B, φ (gen b) = 1) :
    φ = N := by
  apply AddMonoidHom.ext
  intro s
  rw [R_456_hom_eq_card_on φ hφ s, N_apply]

/-- **R.456 — packaged universal-property statement (existence + uniqueness).**

T.7 = the universal property of the free commutative monoid: there is a
**unique** monoid homomorphism `M(p) → ℕ` sending every generator to `1`,
and it is the cardinality / word-length map `N`.  We state existence and
uniqueness together: `N` works, and any hom with the same generator
behaviour coincides with `N`. -/
theorem R_456_T7 {B : Type*} :
    ∃! φ : FreeBarrierMonoid B →+ ℕ, ∀ b : B, φ (gen b) = 1 := by
  refine ⟨N, R_456_card_of_generator, ?_⟩
  intro ψ hψ
  exact R_456_uniqueness ψ hψ

end FreeMonoidUniversal

end MIP
