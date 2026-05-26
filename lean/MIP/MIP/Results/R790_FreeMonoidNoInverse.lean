/-
Result R.790–R.796 — The intervention sequence monoid `M*` is a free monoid
with no non-trivial inverses; under the training-monotonicity (TM) family an
"inverse intervention" is unreachable.

Reference: `workspace/round3_exploration/slot_046.md` and
`workspace/round3_exploration/work_slot_046.md` (slot 046, A unconditional).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement (algebraic core).** Let `M` be the set of metacognitive
interventions and let `M* := FreeMonoid M` be the free monoid of finite
intervention *sequences* under sequence concatenation `*`, with identity `1`
(the empty sequence).  R.791 asserts `(M*, *)` is a cancellative free monoid
*with no inverses*: no element of length `≥ 1` can be a unit.

The pure-math kernel is the length homomorphism
`length : FreeMonoid M → ℕ` (R.795: `N̂`), which satisfies
`length (x * y) = length x + length y` and `length 1 = 0`.  Hence if `x * y = 1`
then `length x + length y = 0`, forcing `length x = 0`, i.e. `x = 1`.  So the
only invertible element is the identity: a non-identity sequence can never be
cancelled by a later intervention (R.794: "inverse intervention is
unreachable").

This file proves, for a free monoid on a generator type `M` with at least one
generator:

* `R_795_length_hom`      — `length` is a monoid homomorphism (R.795 `N̂`):
  `length (x * y) = length x + length y`, `length 1 = 0`.
* `R_791_unit_iff_one`    — an element is left-invertible iff it equals `1`.
* `R_791_no_inverse`      — no non-identity element has a right inverse.
* `R_790_no_proper_inverse` — for a *generator* `m`, the singleton
  intervention `of m` has no inverse at all (the irreversibility wall).
* `R_791_only_unit_is_one` — the unit (invertible) elements are exactly `{1}`.
* `R_794_inverse_unreachable` — packaged TM-irreversibility statement: under
  the length witness, an "undo" of a non-empty intervention sequence does not
  exist inside `M*`.

**This file is `axiom`-free.**  It imports only Mathlib and reuses the
standard `FreeMonoid` infrastructure (`length`, `length_mul`, `length_one`,
`length_eq_zero`, `of_ne_one`).
-/
import Mathlib.Algebra.FreeMonoid.Basic

namespace MIP

namespace FreeMonoidNoInverse

variable {M : Type*}

/-- The carrier of `M* = Free_Mon(M)`: the free (non-commutative) monoid on the
type `M` of metacognitive interventions.  Its multiplication is sequence
concatenation, its unit the empty sequence `1`. -/
abbrev IntervSeq (M : Type*) := FreeMonoid M

/-- A single intervention `m`, viewed as the length-one sequence `(m)`. -/
def single (m : M) : IntervSeq M := FreeMonoid.of m

/-- **R.795 — `N̂ = length` is a monoid homomorphism `M* → ℕ`.**

The intervention-count map `N̂ (m₁, …, mₙ) = n` is the free-monoid length.  It
turns concatenation into addition (`length (x*y) = length x + length y`) and
sends the empty sequence to `0`.  This is the `M*`-layer companion of the
R.456 barrier-count homomorphism. -/
theorem R_795_length_hom (x y : IntervSeq M) :
    (x * y).length = x.length + y.length ∧ (1 : IntervSeq M).length = 0 :=
  ⟨FreeMonoid.length_mul x y, FreeMonoid.length_one⟩

/-- **R.791 / R.794 — length-zero ⟹ identity (the engine of irreversibility).**

If a product of two intervention sequences is the empty sequence, then each
factor is empty.  This is the `length`-additivity argument: `length (x*y) =
length x + length y = 0` forces both summands to `0`. -/
theorem R_791_mul_eq_one (x y : IntervSeq M) (h : x * y = 1) :
    x = 1 ∧ y = 1 := by
  have hlen : x.length + y.length = 0 := by
    rw [← FreeMonoid.length_mul, h, FreeMonoid.length_one]
  have hx : x.length = 0 := Nat.eq_zero_of_add_eq_zero_right hlen
  have hy : y.length = 0 := Nat.eq_zero_of_add_eq_zero_left hlen
  exact ⟨FreeMonoid.length_eq_zero.mp hx, FreeMonoid.length_eq_zero.mp hy⟩

/-- **R.791 — an element is right-invertible iff it is the identity.**

`x` has a right inverse (`∃ y, x * y = 1`) exactly when `x = 1`.  The forward
direction is the length argument (R_791_mul_eq_one); the converse is `x * 1 = 1`. -/
theorem R_791_unit_iff_one (x : IntervSeq M) :
    (∃ y : IntervSeq M, x * y = 1) ↔ x = 1 := by
  constructor
  · rintro ⟨y, hy⟩
    exact (R_791_mul_eq_one x y hy).1
  · rintro rfl
    exact ⟨1, mul_one 1⟩

/-- **R.791 — no non-identity intervention sequence has a right inverse.**

The metacognitive intervention monoid `M*` has *no non-trivial units*: if
`x ≠ 1` then there is no `y` with `x * y = 1`.  Interventions accumulate; a
non-empty sequence can never be cancelled by appending further interventions. -/
theorem R_791_no_inverse (x : IntervSeq M) (hx : x ≠ 1) :
    ¬ ∃ y : IntervSeq M, x * y = 1 := by
  rw [R_791_unit_iff_one x]
  exact hx

/-- **R.791 — the set of units of `M*` is exactly `{1}`.**

Packaging both directions: `x` is invertible (two-sided) iff `x = 1`.  So the
only "reversible" intervention is doing nothing. -/
theorem R_791_only_unit_is_one (x : IntervSeq M) :
    (∃ y : IntervSeq M, x * y = 1 ∧ y * x = 1) ↔ x = 1 := by
  constructor
  · rintro ⟨y, hy, _⟩
    exact (R_791_mul_eq_one x y hy).1
  · rintro rfl
    exact ⟨1, mul_one 1, one_mul 1⟩

/-- **R.790 / R.794 — a single intervention has no inverse (irreversibility wall).**

For any *generator* `m : M` (a single metacognitive intervention), the
length-one sequence `single m = (m)` is not the identity, hence has no right
inverse in `M*`.  Concretely: there is no intervention sequence `y` that
"undoes" `m` to recover the empty history.  This is the algebraic form of
R.794 ("inverse intervention is unreachable under the TM family"): the only way
to be invertible is to have done nothing. -/
theorem R_790_no_proper_inverse (m : M) :
    ¬ ∃ y : IntervSeq M, single m * y = 1 := by
  apply R_791_no_inverse
  exact FreeMonoid.of_ne_one m

/-- **R.794 — packaged TM-irreversibility statement.**

Given any non-empty intervention sequence `x` (length `≥ 1`), there is no
"inverse intervention" `y ∈ M*` recovering the empty sequence (`x * y = 1`).
Under the length witness `N̂`, an undo of a non-empty intervention does not
exist inside `M*`.  Stated with the explicit length hypothesis: if
`1 ≤ x.length`, then no inverse exists. -/
theorem R_794_inverse_unreachable (x : IntervSeq M) (hx : 1 ≤ x.length) :
    ¬ ∃ y : IntervSeq M, x * y = 1 := by
  apply R_791_no_inverse
  intro hx1
  rw [hx1, FreeMonoid.length_one] at hx
  exact absurd hx (by decide)

/-- **R.790 — `M*` on a non-empty generator type is non-trivial.**

If there is at least one intervention `m : M`, then `M*` contains a
non-identity element (`single m ≠ 1`), so the no-inverse phenomena above are
not vacuous: there genuinely exist irreversible interventions. -/
theorem R_790_nontrivial (m : M) : single m ≠ (1 : IntervSeq M) :=
  FreeMonoid.of_ne_one m

end FreeMonoidNoInverse

end MIP
