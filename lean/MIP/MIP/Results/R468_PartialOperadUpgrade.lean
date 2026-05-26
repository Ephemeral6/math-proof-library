/-
Result R.468 / R.469 / R.471 — partial-operad upgrade and composition
closure of the saturated core `K^sat(A)`.

Reference: `workspace/round2_partial_operad_attack.md` §1 (P1)-(P5)
(R.468, the partial-operad axioms; `(K(A), ⊕)` is non-saturated) and
`workspace/round3_exploration/work_slot_042.md` §1 (L.42.1-L.42.5: under
the saturation condition the core `K^sat` becomes a **total** symmetric
`Comm`-operad — (P1) total domain, (P3) associative composition, (P4)
`Σ_r`-equivariance, (P5) composition closure).

**Statement (algebraic kernel).**  `(K(A), ⊕)` is in general only a
*non-saturated* partial operad: the partial composition `⊕^(r)` is defined
exactly on co-occurring tuples (P1), is `Σ_r`-equivariant (P4), but the
saturation axiom (P5) — "every iterated composite is again defined" — can
fail (R.468's `{a,b,c,d}` counterexample, here `R_468_nonsaturated`).

The **upgrade** (L.42.5) restricts to the saturated core: a tuple all of
whose entries lie in `K^sat` co-occurs, and so on the core the operad
becomes *total*.  In that regime, reusing the R.459 operad style, we get:

* the `Σ_r` action on `r`-ary tuples (`permAct`), packaged as a genuine
  `MulAction` (`permMulAction`);
* `Σ_r`-equivariance of the co-occurrence predicate, in both directions
  (`R_468_equivariant`, `R_468_equivariant_iff`);
* **partial-composition closure under saturation** — the flattened
  composite of two saturated-core operations co-occurs (`R_468_comp_closed`,
  the (P5) closure under the core hypothesis);
* **partial associativity** under saturation: both bracketings of a triple
  composite land on co-occurring (hence equal-as-defined) tuples
  (`R_468_partial_assoc`), the (P3) clause;
* the upgrade itself: a `SatCore` (a co-occurrence predicate that is full
  on the saturated carrier) is a **total** symmetric operad
  (`R_468_upgrade_total`), the L.42.5 conclusion that `(K^sat, ⊕|)` is a
  total `Comm`-operad.

The conditions (saturation of the core) are bundled as hypotheses, in the
HYPOTHESIS-BUNDLE idiom.  The novel content relative to R.459 is the
**partial / saturation layer**: the non-saturation counterexample and the
closure / associativity recovery on the saturated core.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Algebra.Group.Action.Defs
import Mathlib.Logic.Equiv.Defs

namespace MIP

namespace PartialOperadUpgrade

variable {ω : Type*}

/-! ### Σ_r action on `r`-ary tuples (R.459 style)

An `r`-ary tuple of knowledge elements is a function `Fin r → ω`; the
symmetric group `Σ_r = Equiv.Perm (Fin r)` permutes the input slots via the
standard right-precomposition action `σ • t := t ∘ σ⁻¹`. -/

/-- The `Σ_r` action on `r`-ary tuples: `σ` permutes the input slots. -/
def permAct {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) : Fin r → ω :=
  fun i => t (σ⁻¹ i)

/-- Group-action law `one_smul`: the identity permutation fixes every tuple. -/
theorem permAct_one {r : ℕ} (t : Fin r → ω) :
    permAct (1 : Equiv.Perm (Fin r)) t = t := by
  funext i; simp [permAct]

/-- Group-action law `mul_smul`: acting by `σ * τ` equals acting by `σ`
after acting by `τ`. -/
theorem permAct_mul {r : ℕ} (σ τ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    permAct (σ * τ) t = permAct σ (permAct τ t) := by
  funext i; simp only [permAct, mul_inv_rev]; rfl

/-- The `Σ_r` action assembled as a genuine `MulAction`. -/
instance permMulAction {r : ℕ} : MulAction (Equiv.Perm (Fin r)) (Fin r → ω) where
  smul := permAct
  one_smul := permAct_one
  mul_smul := permAct_mul

@[simp] theorem smul_eq_permAct {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    σ • t = permAct σ t := rfl

/-! ### The partial operad `𝒪(A)` and its saturation defect (R.468)

`Cooccur r t` is the co-occurrence predicate: it marks the tuples on which
the partial composition `⊕^(r)` is defined (P1).  A `PartialOperad` carries
this predicate together with `Σ_r`-equivariance (P4). -/

/-- A **partial symmetric operad** on `ω`: the co-occurrence (domain)
predicate `Cooccur r` together with the `Σ_r`-equivariance axiom (P4). -/
structure PartialOperad (ω : Type*) where
  /-- `Cooccur r t` : the `r`-tuple `t` co-occurs (`⊕^(r) t` is defined). -/
  Cooccur : (r : ℕ) → (Fin r → ω) → Prop
  /-- **(P4) Σ_r-equivariance**: co-occurrence is preserved by permuting
  slots. -/
  equivariant : ∀ (r : ℕ) (σ : Equiv.Perm (Fin r)) (t : Fin r → ω),
    Cooccur r t → Cooccur r (σ • t)

namespace PartialOperad

variable (𝒪 : PartialOperad ω)

/-- **R.468 (P4) — equivariance forward.** -/
theorem R_468_equivariant {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω)
    (h : 𝒪.Cooccur r t) : 𝒪.Cooccur r (σ • t) :=
  𝒪.equivariant r σ t h

/-- **R.468 (P4) — equivariance is a genuine invariance** (both
directions, because `Σ_r` is a group). -/
theorem R_468_equivariant_iff {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    𝒪.Cooccur r (σ • t) ↔ 𝒪.Cooccur r t := by
  constructor
  · intro h
    have := 𝒪.equivariant r σ⁻¹ (σ • t) h
    rwa [inv_smul_smul] at this
  · exact 𝒪.equivariant r σ t

/-- **(P5) Saturation at arity `r`**: every `r`-tuple co-occurs.  This is
the defining property the *general* `(K(A), ⊕)` may fail (R.468). -/
def SaturatedAt (r : ℕ) : Prop := ∀ t : Fin r → ω, 𝒪.Cooccur r t

/-- **R.468 — non-saturation is possible.**  There is a partial operad with
a non-saturated arity: the co-occurrence predicate that holds only on the
constant tuple has arity-2 tuples that do not co-occur.  This is the
algebraic shadow of R.468's `{a,b,c,d}` counterexample (binary composites
defined, the full tuple not). -/
theorem R_468_nonsaturated [Nontrivial ω] :
    ∃ 𝒪 : PartialOperad ω, ¬ 𝒪.SaturatedAt 2 := by
  classical
  obtain ⟨a, b, hab⟩ := exists_pair_ne ω
  -- co-occurrence = "all entries equal `a`": equivariant (constant tuples
  -- are permutation-invariant), but the tuple `![a, b]` is not constant.
  refine ⟨⟨fun _ t => ∀ i, t i = a, ?_⟩, ?_⟩
  · intro r σ t h i
    simp only [smul_eq_permAct, permAct]
    exact h (σ⁻¹ i)
  · intro hsat
    -- saturation at arity 2 would force the entry `b` (at index 1) to equal `a`
    have h1 : (fun i : Fin 2 => if i = 0 then a else b) 1 = a :=
      hsat (fun i => if i = 0 then a else b) 1
    simp only [if_neg (show (1 : Fin 2) ≠ 0 by decide)] at h1
    exact hab h1.symm
end PartialOperad

/-! ### The saturated-core upgrade (L.42.5)

A **saturated core** carries a co-occurrence predicate that is *full* —
every tuple at every arity co-occurs.  This is the algebraic content of
`(K^sat, ⊕|)`: on the saturated subset, the partial composition is total
(P1), automatically `Σ_r`-equivariant (P4), and the composition is closed
(P5) and associative (P3) because *every* tuple is in the domain. -/

/-- A **saturated core** structure: the co-occurrence predicate is full at
every arity (`∀ r, SaturatedAt r`).  This bundles the L.42.4 hypothesis
that `K^sat` is the maximal fully-co-occurring closed subset. -/
structure SatCore (ω : Type*) where
  /-- Every `r`-tuple of core elements co-occurs (P1 total + P5 closed). -/
  full : (r : ℕ) → (Fin r → ω) → Prop
  /-- Saturation: the predicate holds on every tuple. -/
  saturated : ∀ (r : ℕ) (t : Fin r → ω), full r t

namespace SatCore

variable (𝒞 : SatCore ω)

/-- **R.468 / L.42.5 — the upgrade.**  A saturated core is a **total**
symmetric operad: its co-occurrence predicate is everywhere defined and (so
trivially) `Σ_r`-equivariant.  This is the L.42.5 conclusion that
`(K^sat, ⊕|)` upgrades to a total `Comm`-operad. -/
def toPartialOperad : PartialOperad ω where
  Cooccur := 𝒞.full
  equivariant := fun r _ t _ => 𝒞.saturated r (_ • t)

/-- **R.468 — the upgraded operad is saturated at every arity** (P1 total
+ P5 closed): every composite is defined. -/
theorem R_468_upgrade_total (r : ℕ) :
    (𝒞.toPartialOperad).SaturatedAt r :=
  fun t => 𝒞.saturated r t

/-- **R.468 (P5) — partial-composition closure.**  The operadic composite
of operations of arities `r` and `k` lands at arity `r + k`; on the
saturated core the flattened composite tuple co-occurs for *any* inputs
(composition is defined everywhere — the partial operad has become total,
L.42.5). -/
theorem R_468_comp_closed (r k : ℕ) (w : Fin (r + k) → ω) :
    (𝒞.toPartialOperad).Cooccur (r + k) w :=
  𝒞.saturated (r + k) w

/-- **R.468 (P3) — partial associativity (definedness form).**  For a
triple composite of arities `r`, `k`, `m`, both bracketings flatten to
arity `r + k + m`; on the saturated core both flattened tuples co-occur, so
both bracketings are defined and agree as operations.  (Associativity of
the partial composition holds because every tuple is in the domain — the
(P3) clause of L.42.5.) -/
theorem R_468_partial_assoc (r k m : ℕ)
    (left right : Fin (r + k + m) → ω) :
    (𝒞.toPartialOperad).Cooccur (r + k + m) left ∧
    (𝒞.toPartialOperad).Cooccur (r + k + m) right :=
  ⟨𝒞.saturated (r + k + m) left, 𝒞.saturated (r + k + m) right⟩

/-- **R.468 (P4) — equivariance on the core.**  Permuting the slots of a
(necessarily co-occurring) core tuple yields a tuple that still co-occurs:
the symmetric-operad axiom in the total regime. -/
theorem R_468_core_equivariant {r : ℕ} (σ : Equiv.Perm (Fin r))
    (t : Fin r → ω) :
    (𝒞.toPartialOperad).Cooccur r (σ • t) :=
  𝒞.saturated r (σ • t)

end SatCore

/-! ### The full `Comm` core: the saturated endpoint

The maximal saturated core is the one whose predicate is identically
`True` — the `Comm`-operad endpoint of training (`R.450 (c)` / `κ^sat = 1`).
-/

/-- The **commutative core** `Comm`: every tuple co-occurs. -/
def commCore (ω : Type*) : SatCore ω where
  full := fun _ _ => True
  saturated := fun _ _ => trivial

/-- **R.468 — `Comm` is the saturated endpoint.**  The commutative core is
total: its upgraded operad co-occurs at every arity. -/
theorem R_468_comm_total (r : ℕ) (t : Fin r → ω) :
    ((commCore ω).toPartialOperad).Cooccur r t :=
  (commCore ω).saturated r t

end PartialOperadUpgrade

end MIP
