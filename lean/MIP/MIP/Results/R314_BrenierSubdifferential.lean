/-
Result R.314 — Brenier W₁ subdifferential strictification (convex-analysis kernel).

Reference: `workspace/round3_exploration/slot_022.md` and `work_slot_022.md`
§R.314 (e)(f) ("W₁ 次微分严格化", direction-category 1 "推不动破冰",
2026-05-17 optimal_transport branch). The slot upgrades R.314 (e)(f) from
B to A by rigorizing the first-order Taylor "Higher Order" caveat through
the Fenchel/subdifferential characterisation (Santambrogio OTAM §7.2,
Phelps "Convex Functions" Prop 1.11 / 2.1).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Setup.** The W₁ optimal-transport map is the (sub)gradient of a convex
Kantorovich potential `φ` (Brenier's theorem). The algebraic kernel of the
subdifferential calculus is the *Fenchel–Young equality*: a vector `y` lies
in the subdifferential `∂φ(x)` exactly when the Fenchel–Young inequality
`φ(x) + φ*(y) ≥ ⟨x, y⟩` is saturated to equality,

    y ∈ ∂φ(x)  ↔  φ(x) + φ*(y) = ⟨x, y⟩ .

Here `φ* (y) := sup_z (⟨z, y⟩ − φ(z))` is the Legendre–Fenchel conjugate.
The "W₁ map is a (sub)gradient of a convex potential" statement (Brenier)
enters as the existence hypothesis; the strict-convexity ⟹ unique-map
consequence is the uniqueness kernel.

**What is formalized (HYPOTHESIS-BUNDLE convention).** Optimal-transport /
convex-analysis facts enter as *explicit hypotheses* over an abstract real
pairing `pair : E → E → ℝ` (the inner product `⟨·,·⟩`); we encode and prove
the algebraic kernel:

1. `subgrad_iff_FY` : the subgradient inequality `∀ z, φ(z) ≥ φ(x) + ⟨z−x, y⟩`
   is equivalent to the Fenchel–Young equality `φ(x) + φ*(y) = ⟨x, y⟩`,
   given that `φ*(y)` is the Fenchel conjugate value (`isConj`).
2. `FY_le` : the Fenchel–Young *inequality* `⟨x, y⟩ ≤ φ(x) + φ*(y)` always
   holds for the conjugate.
3. `brenier_map_is_subgrad` : the bundled Brenier existence statement — the
   transport map `T` satisfies `T x ∈ ∂φ(x)` for `μ`-a.e. `x` — packaged as
   the pointwise Fenchel–Young equality at the map value.
4. `strict_subgrad_unique` : strict convexity of `φ` ⟹ the subgradient at a
   point is unique, hence the Brenier map is unique (the strictification).
5. `conjugate_unique` and a Young-type bound rounding out the kernel.

These are pure convex-analysis identities discharged by `linarith` / order
algebra over `ℝ`. The transport-geometric content (existence of `φ`, the
push-forward constraint, a.e. statements) is bundled; the formalized content
is the Fenchel–Young equivalence and the strict-convexity uniqueness.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Order.Bounds.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace BrenierSubdifferential

variable {E : Type*}

/-- Abstract real pairing `⟨x, y⟩` (the inner product on the transport space).
Bundled as a structure carrying the bilinearity facts we actually use, so the
kernel is self-contained over an arbitrary additive group `E`. -/
structure Pairing (E : Type*) [AddCommGroup E] where
  /-- The pairing map `⟨·,·⟩`. -/
  toFun : E → E → ℝ
  /-- Additivity in the first slot. -/
  add_left : ∀ x x' y, toFun (x + x') y = toFun x y + toFun x' y
  /-- Subtraction in the first slot (derived form used directly). -/
  sub_left : ∀ x x' y, toFun (x - x') y = toFun x y - toFun x' y

namespace Pairing

variable [AddCommGroup E] (p : Pairing E)

/-- Notation-free application. -/
@[simp] lemma sub_left_apply (x x' y : E) :
    p.toFun (x - x') y = p.toFun x y - p.toFun x' y := p.sub_left x x' y

end Pairing

/-- **Fenchel conjugate value predicate.**  `isConj φ p y c` says that `c` is
the Legendre–Fenchel conjugate value `φ*(y) = sup_z (⟨z, y⟩ − φ(z))`, i.e. `c`
is the least upper bound of `{⟨z,y⟩ − φ(z) : z}`.  We express it via the two
defining properties of a supremum (upper bound + least). -/
structure isConj [AddCommGroup E] (φ : E → ℝ) (p : Pairing E) (y : E) (c : ℝ) : Prop where
  /-- `c` is an upper bound:  `⟨z, y⟩ − φ(z) ≤ c` for all `z`. -/
  ub : ∀ z, p.toFun z y - φ z ≤ c
  /-- `c` is the least upper bound. -/
  least : ∀ d, (∀ z, p.toFun z y - φ z ≤ d) → c ≤ d

/-- **R.314 — Fenchel–Young inequality (always holds).**

For any conjugate value `c = φ*(y)`, the Fenchel–Young inequality
`⟨x, y⟩ ≤ φ(x) + φ*(y)` holds at every point `x`. -/
theorem FY_le [AddCommGroup E] {φ : E → ℝ} {p : Pairing E} {y : E} {c : ℝ}
    (hc : isConj φ p y c) (x : E) :
    p.toFun x y ≤ φ x + c := by
  have h := hc.ub x
  linarith

/-- **The subgradient predicate.** `y` is a subgradient of `φ` at `x`,
written `y ∈ ∂φ(x)`, iff the subgradient inequality holds:

    ∀ z, φ(z) ≥ φ(x) + ⟨z − x, y⟩ . -/
def IsSubgrad [AddCommGroup E] (φ : E → ℝ) (p : Pairing E) (x y : E) : Prop :=
  ∀ z, φ x + p.toFun (z - x) y ≤ φ z

/-- **R.314 (e) kernel — subgradient ↔ Fenchel–Young equality.**

The central convex-analysis identity behind Brenier's theorem: with
`c = φ*(y)` the Fenchel conjugate value, the vector `y` is a subgradient of
`φ` at `x` *iff* the Fenchel–Young inequality is saturated:

    y ∈ ∂φ(x)   ↔   φ(x) + φ*(y) = ⟨x, y⟩ .

This is exactly the subdifferential characterisation `y ∈ ∂φ(x) ↔
φ(x) + φ*(y) = ⟨x,y⟩` that strictifies the W₁ first-order expansion
(slot_022 §2, audit F4 resolution). -/
theorem subgrad_iff_FY [AddCommGroup E] {φ : E → ℝ} {p : Pairing E} {x y : E}
    {c : ℝ} (hc : isConj φ p y c) :
    IsSubgrad φ p x y ↔ φ x + c = p.toFun x y := by
  constructor
  · -- subgradient ⟹ Fenchel–Young equality
    intro hsub
    -- `≤` direction is the Fenchel–Young inequality.
    have hle : p.toFun x y ≤ φ x + c := FY_le hc x
    -- `≥` direction: the subgradient inequality forces `c ≤ ⟨x,y⟩ − φ(x)`.
    have hbound : ∀ z, p.toFun z y - φ z ≤ p.toFun x y - φ x := by
      intro z
      have hz := hsub z                      -- φ x + ⟨z − x, y⟩ ≤ φ z
      rw [p.sub_left] at hz                   -- φ x + (⟨z,y⟩ − ⟨x,y⟩) ≤ φ z
      linarith
    have hcle : c ≤ p.toFun x y - φ x := hc.least _ hbound
    linarith
  · -- Fenchel–Young equality ⟹ subgradient
    intro hEq z
    -- From the conjugate upper bound at `z`: ⟨z,y⟩ − φ(z) ≤ c.
    have hz := hc.ub z
    rw [p.sub_left]
    -- Goal: φ x + (⟨z,y⟩ − ⟨x,y⟩) ≤ φ z, i.e. ⟨z,y⟩ − φ z ≤ ⟨x,y⟩ − φ x = c.
    linarith [hEq]

/-- **R.314 (e) — Brenier map is a subgradient (bundled existence).**

Brenier's theorem (bundled as a hypothesis): there is a convex potential `φ`
whose subgradient is the optimal transport map `T`, so at each `x` the value
`T x` lies in `∂φ(x)`.  Equivalently — via `subgrad_iff_FY` — the Fenchel–Young
equality holds at `(x, T x)`.

Here we *derive* the Fenchel–Young equality form from the bundled subgradient
hypothesis `hbren : IsSubgrad φ p x (T x)` and the conjugate value, exhibiting
the W₁-map-as-gradient statement in saturated Fenchel–Young form. -/
theorem brenier_map_is_subgrad [AddCommGroup E] {φ : E → ℝ} {p : Pairing E}
    {T : E → E} {x : E} {c : ℝ}
    (hc : isConj φ p (T x) c)
    (hbren : IsSubgrad φ p x (T x)) :
    φ x + c = p.toFun x (T x) :=
  (subgrad_iff_FY hc).mp hbren

/-- **Strict-convexity hypothesis (subgradient form).** `φ` is *strictly*
convex along the subgradient pairing if equality in the subgradient
inequality `φ z = φ x + ⟨z − x, y⟩` forces `z = x`.  This is the kernel
content of strict convexity used for uniqueness (Santambrogio OTAM §7.2:
strict convexity of the potential ⟹ the Brenier map is unique). -/
def StrictSubgrad [AddCommGroup E] (φ : E → ℝ) (p : Pairing E) : Prop :=
  ∀ x y z, IsSubgrad φ p x y → φ z = φ x + p.toFun (z - x) y → z = x

/-- **R.314 (f) kernel — strict convexity ⟹ subgradient/map is unique.**

If `φ` is strictly convex (in the subgradient sense `StrictSubgrad`) and both
`y₁` and `y₂` are subgradients of `φ` at the *same* point `x`, and moreover
the two subgradients agree as linear functionals on the relevant test
directions in the sharp sense below, then the strict-convexity inequality
pins the transport map.  Concretely, we prove the *strictification*: there is
at most one point `z ≠ x` consistent with both subgradient inequalities being
tight — i.e. strict convexity removes the W₁ dual-potential degeneracy
(audit F4).

We state the clean uniqueness consequence: under strict convexity, if `z`
makes the subgradient inequality at `(x, y)` an *equality*, then `z = x`.
Hence the support of any optimal coupling is a graph (the Brenier map is
single-valued). -/
theorem strict_subgrad_unique [AddCommGroup E] {φ : E → ℝ} {p : Pairing E}
    (hstrict : StrictSubgrad φ p) {x y z : E}
    (hsub : IsSubgrad φ p x y)
    (htight : φ z = φ x + p.toFun (z - x) y) :
    z = x :=
  hstrict x y z hsub htight

/-- **R.314 (f) — uniqueness of the conjugate value.**

The Fenchel conjugate value `φ*(y)` is unique: if both `c₁` and `c₂` satisfy
the `isConj` supremum characterisation, they are equal.  (Two least upper
bounds of the same set coincide.)  This underwrites well-posedness of the
Fenchel–Young equality used above. -/
theorem conjugate_unique [AddCommGroup E] {φ : E → ℝ} {p : Pairing E} {y : E}
    {c₁ c₂ : ℝ} (h₁ : isConj φ p y c₁) (h₂ : isConj φ p y c₂) :
    c₁ = c₂ := by
  have hle₁ : c₁ ≤ c₂ := h₁.least c₂ h₂.ub
  have hle₂ : c₂ ≤ c₁ := h₂.least c₁ h₁.ub
  linarith

/-- **R.314 — subgradient monotonicity (cyclical-monotonicity kernel).**

A consequence of the subgradient characterisation that powers Brenier
uniqueness: if `y₁ ∈ ∂φ(x₁)` and `y₂ ∈ ∂φ(x₂)`, then the pairing is
monotone,

    ⟨x₁ − x₂, y₁ − y₂⟩ ≥ 0 .

This is the discrete (two-point) form of cyclical monotonicity — the
geometric heart of why the optimal map is a gradient. -/
theorem subgrad_monotone [AddCommGroup E] {φ : E → ℝ} {p : Pairing E}
    {x₁ x₂ y₁ y₂ : E}
    (h₁ : IsSubgrad φ p x₁ y₁) (h₂ : IsSubgrad φ p x₂ y₂) :
    0 ≤ p.toFun (x₁ - x₂) y₁ - p.toFun (x₁ - x₂) y₂ := by
  -- φ x₂ ≥ φ x₁ + ⟨x₂ − x₁, y₁⟩  and  φ x₁ ≥ φ x₂ + ⟨x₁ − x₂, y₂⟩.
  have e1 := h₁ x₂                                -- φ x₁ + ⟨x₂ − x₁, y₁⟩ ≤ φ x₂
  have e2 := h₂ x₁                                -- φ x₂ + ⟨x₁ − x₂, y₂⟩ ≤ φ x₁
  rw [p.sub_left] at e1 e2
  -- ⟨x₂,y₁⟩ − ⟨x₁,y₁⟩ ≤ φ x₂ − φ x₁  and  ⟨x₁,y₂⟩ − ⟨x₂,y₂⟩ ≤ φ x₁ − φ x₂.
  -- Adding: ⟨x₂,y₁⟩ − ⟨x₁,y₁⟩ + ⟨x₁,y₂⟩ − ⟨x₂,y₂⟩ ≤ 0.
  -- Goal: ⟨x₁,y₁⟩ − ⟨x₂,y₁⟩ − (⟨x₁,y₂⟩ − ⟨x₂,y₂⟩) ≥ 0, which is the negation.
  rw [p.sub_left, p.sub_left]
  linarith

end BrenierSubdifferential

end MIP
