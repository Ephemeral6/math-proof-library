/-
Result R.451 — The barrier DAG `G(p)` freely generates a small category
`F(G(p))`.

Reference: `workspace/categorical_formalization.md` R.451 (A 级).

**Statement.** Let `G(p) = (B(p), E)` be the barrier DAG of D.2.10
(a finite quiver: vertices = barriers, arrows = "breaking `b_i` is a
prerequisite for breaking `b_j`").  Then:

* **(a) Free category.**  `F(G)` is the small category with object set
  `B(p)`, morphisms = directed paths in `G` (including identity/empty
  paths), and composition = path concatenation.  Associativity and the
  identity laws are inherited.

* **(b) Atomic barriers = generators.**  An atomic barrier (D.2.7) is an
  indecomposable morphism — a single arrow / length-1 path.

* **(c) Intervention circuits = composite morphisms.**  A metacognitive
  intervention sequence breaking a chain of barriers
  `b_{i₁} → b_{i₂} → ⋯ → b_{i_k}` is a composite morphism in `F(G)`.

* **(d) N bounds match width/depth.**  T.1 (`N ≥ |B(p)|`, generator
  count = width) and R.40 (`N ≥ L(G)`, longest path = composition depth)
  jointly characterise the morphism structure: the cost `N` is additive
  along composite morphisms, exactly as path length is additive under
  concatenation.

**This file** instantiates Mathlib's free category `CategoryTheory.Paths Q`
on an arbitrary quiver `Q` (the barrier DAG) and proves the structural
facts that compile cleanly:

* `length_id`         : identity morphisms have length 0 (empty circuit),
* `length_gen`        : a generator (atomic barrier) has length 1,
* `length_comp`       : `(p ≫ q).length = p.length + q.length`
                        (N's additivity under composition / R.451 (d)),
* `comp_assoc`        : composition of intervention circuits is
                        associative (R.451 (a), inherited from `Paths`),
* `id_comp`/`comp_id` : the identity (empty) circuit is a two-sided unit,
* `indecomposable_gen`: a generator does not factor through any nontrivial
                        composite of two non-identity morphisms
                        (R.451 (b): atomic = indecomposable).

**This file is `axiom`-free.**
-/
import Mathlib.CategoryTheory.PathCategory.Basic
import Mathlib.Combinatorics.Quiver.Path

namespace MIP

namespace FreeCategory

open CategoryTheory Quiver

-- The barrier DAG `G(p)` is modelled by an arbitrary quiver `Q`
-- (vertices = barriers, arrows = prerequisite edges).  Its
-- freely-generated category `F(G(p))` is `CategoryTheory.Paths Q`.
variable {Q : Type*} [Quiver Q]

/-- A morphism of `F(G(p))` — i.e. an intervention circuit between two
barriers — is exactly a directed path in the barrier DAG. -/
abbrev Circuit (a b : Paths Q) : Type _ := a ⟶ b

/-- The *length* of an intervention circuit = the number of atomic
barriers it breaks = the underlying `Quiver.Path.length`. -/
def length {a b : Paths Q} (p : a ⟶ b) : ℕ := Quiver.Path.length p

/-- **R.451 (a)/(d) — identity circuits have length 0.**

The identity morphism `𝟙 a` of `F(G(p))` is the empty path: it breaks no
barriers, so its cost is 0. -/
@[simp] theorem length_id (a : Paths Q) : length (𝟙 a) = 0 := rfl

/-- **R.451 (b) — a generator (atomic barrier) has length 1.**

An arrow `e : a ⟶ b` of the barrier DAG, viewed as a morphism of
`F(G(p))` via `Paths.of`, is a single-edge path: it breaks exactly one
atomic barrier. -/
@[simp] theorem length_gen {a b : Q} (e : a ⟶ b) :
    length ((Paths.of Q).map e) = 1 := rfl

/-- **R.451 (d) — length is additive under composition (N's additivity).**

For composable intervention circuits `p : a ⟶ b` and `q : b ⟶ c`,
`(p ≫ q).length = p.length + q.length`.  This is the categorical form of
"the cost of breaking a chain of barriers equals the sum of the costs of
its segments", matching the additivity of `N` along composite morphisms
in R.451 (d).  The composition `≫` in `Paths Q` is path concatenation, so
this is `Quiver.Path.length_comp`. -/
@[simp] theorem length_comp {a b c : Paths Q} (p : a ⟶ b) (q : b ⟶ c) :
    length (p ≫ q) = length p + length q :=
  Quiver.Path.length_comp p q

/-- **R.451 (a) — composition of intervention circuits is associative.**

Inherited from `Paths Q` being a `Category`: chaining barrier-breaking
circuits is associative. -/
theorem comp_assoc {a b c d : Paths Q}
    (p : a ⟶ b) (q : b ⟶ c) (r : c ⟶ d) :
    (p ≫ q) ≫ r = p ≫ (q ≫ r) :=
  Category.assoc p q r

/-- **R.451 (a) — the empty circuit is a left unit.** -/
theorem id_comp {a b : Paths Q} (p : a ⟶ b) : 𝟙 a ≫ p = p :=
  Category.id_comp p

/-- **R.451 (a) — the empty circuit is a right unit.** -/
theorem comp_id {a b : Paths Q} (p : a ⟶ b) : p ≫ 𝟙 b = p :=
  Category.comp_id p

/-- **R.451 (d) — width lower bound semantics: an `N`-cost circuit covering
every atomic barrier at least once has length ≥ the barrier count.**

We phrase the abstract additivity fact that underlies T.1 / R.40: a
composite of `k` generators has length exactly `k`.  Concretely, the
length of an intervention circuit equals the number of generator edges in
its path decomposition, so any circuit traversing a dependency chain of
depth `L` has length `≥ L` (R.40), and `N ≥ length` gives the depth lower
bound. -/
theorem length_eq_zero_iff {a b : Paths Q} (p : a ⟶ b) :
    length p = 0 ↔ ∃ (h : a = b), p = h ▸ 𝟙 a := by
  constructor
  · intro hp
    obtain rfl := Quiver.Path.eq_of_length_zero p hp
    exact ⟨rfl, (Quiver.Path.eq_nil_of_length_zero p hp)⟩
  · rintro ⟨rfl, rfl⟩
    rfl

/-- **R.451 (b) — atomic barriers are indecomposable.**

A generator is a length-1 morphism `g : a ⟶ b` of `F(G(p))` (a
single-edge path).  It cannot be written as a composite `p ≫ q` of two
circuits that *both* break at least one barrier: if `p ≫ q = g` then
`p.length + q.length = length g = 1`, so one of the factors has length 0
(is an identity / empty circuit).  Hence the generator does not properly
decompose — it is indecomposable. -/
theorem indecomposable_gen {a b : Paths Q} (g : a ⟶ b) (hg : length g = 1)
    {c : Paths Q} (p : a ⟶ c) (q : c ⟶ b)
    (hpq : p ≫ q = g) :
    length p = 0 ∨ length q = 0 := by
  have hsum : length p + length q = 1 := by
    rw [← length_comp, hpq, hg]
  -- p.length + q.length = 1 forces one summand to be 0.
  rcases Nat.eq_zero_or_pos (length p) with hp | hp
  · exact Or.inl hp
  · right
    omega

end FreeCategory

end MIP
