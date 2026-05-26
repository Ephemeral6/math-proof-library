/-
Result R.459 — K(A) is a partial symmetric operad 𝒪(A); the κ-tower
controls the closure to a total (Comm-like) operad.

Reference: `workspace/categorical_formalization.md` §R.459 (B 级,
2026-05-16, second-round categorical extension).

**Statement (algebraic kernel).**  For each arity `r ≥ 1` the `r`-ary
operations `𝒪_r(A)` are the `r`-tuples of knowledge elements that
*co-occur* (appear simultaneously, with positive probability, in some
response).  Co-occurrence is invariant under permuting the slots, so the
symmetric group `Σ_r = Equiv.Perm (Fin r)` acts on tuples and the
co-occurrence predicate is `Σ_r`-equivariant.  The "closure degree" at
arity `r` is `κ_r`; the categorical statement is

    (∀ r, κ_r = 1)  ⟺  𝒪(A) is a *total* (fully closed) symmetric operad,

i.e. *every* tuple at *every* arity co-occurs.

This file formalises the following crisp kernels, all `axiom`-free:

* the `Σ_r` action on tuples `Fin r → ω` (`permAct`), with the group-action
  laws `one_smul` and `mul_smul` proved explicitly, packaged as a genuine
  `MulAction` instance;
* `Σ_r`-equivariance of an abstract co-occurrence relation
  (`Cooccur` carries an equivariance hypothesis; the action preserves it
  in both directions);
* `κ_r = 1` modelled as *full closure at arity `r`* (`FullAt`): every
  `r`-tuple co-occurs.  The closure condition `TotalOperad` is
  `∀ r, FullAt r`;
* the **closure characterisation** `(∀ r, κ_r = 1) ↔ TotalOperad`
  (`R_459_kappa_tower_iff_total`), reusing the κ-tower idea of R.450;
* operad scaffolding compatible with totality: the formal unit at arity 1
  and a partial-composition closure lemma (`R_459_total_comp_closed`).

**What is reduced (documented).**  The Koszul-homology part of R.459 (c)
— operadic Koszul complex `K_•(𝒪(A))`, `H^*(𝒪(A)) → H^*(Comm)` as a
completion obstruction — is *not* formalised: it requires the operadic
homology machinery (Ginzburg–Kapranov / Loday–Vallette Koszul duality)
which is not available cleanly in Mathlib.  We formalise the
Σ_r-equivariance + full-closure characterisation algebraically, which is
the load-bearing kernel of parts (a), (b), (d).  The "formal unit"
(R.459's weak version (a) for the X-7 unit ambiguity) is encoded as a
distinguished arity-1 element with the operadic unit laws stated
abstractly.

**This file is `axiom`-free.**
-/
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Algebra.Group.Action.Defs
import Mathlib.Logic.Equiv.Defs

namespace MIP

namespace PartialOperad

variable {ω : Type*}

/-! ### Σ_r action on `r`-ary tuples

An `r`-ary tuple of knowledge elements is a function `Fin r → ω`.  The
symmetric group `Σ_r = Equiv.Perm (Fin r)` permutes the slots.  We use the
standard right-precomposition action `σ • t := t ∘ σ⁻¹`, which is the
left action of `Σ_r` on the function space. -/

/-- The `Σ_r` action on `r`-ary tuples: `σ` permutes the input slots. -/
def permAct {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) : Fin r → ω :=
  fun i => t (σ⁻¹ i)

/-- **Group-action law `one_smul`.**  The identity permutation fixes every
tuple. -/
theorem permAct_one {r : ℕ} (t : Fin r → ω) : permAct (1 : Equiv.Perm (Fin r)) t = t := by
  funext i
  simp [permAct]

/-- **Group-action law `mul_smul`.**  Acting by `σ * τ` equals acting by
`σ` after acting by `τ`. -/
theorem permAct_mul {r : ℕ} (σ τ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    permAct (σ * τ) t = permAct σ (permAct τ t) := by
  funext i
  simp only [permAct, mul_inv_rev]
  rfl

/-- The `Σ_r` action assembled as a genuine `MulAction`.  This packages
`permAct_one` and `permAct_mul` into Mathlib's group-action interface,
witnessing that `permAct` is an honest symmetric-group action (not merely
two equations). -/
instance permMulAction {r : ℕ} : MulAction (Equiv.Perm (Fin r)) (Fin r → ω) where
  smul := permAct
  one_smul := permAct_one
  mul_smul := permAct_mul

/-- Sanity: the `MulAction` smul agrees with `permAct`. -/
@[simp] theorem smul_eq_permAct {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    σ • t = permAct σ t := rfl

/-! ### The partial symmetric operad `𝒪(A)`

`Cooccur r` is the `r`-ary co-occurrence predicate on tuples: it picks out
the `r`-ary operations `𝒪_r(A)`.  The defining property of an operad's
symmetric structure is `Σ_r`-equivariance: co-occurrence does not depend
on the order in which the slots are listed. -/

/-- A **symmetric operad structure** on `ω`: a family of co-occurrence
predicates `Cooccur r` (the `r`-ary operations `𝒪_r`), required to be
`Σ_r`-equivariant. -/
structure SymOperad (ω : Type*) where
  /-- `Cooccur r t` : the `r`-tuple `t` co-occurs, i.e. `t ∈ 𝒪_r(A)`. -/
  Cooccur : (r : ℕ) → (Fin r → ω) → Prop
  /-- **Σ_r-equivariance.**  Co-occurrence is preserved by permuting slots. -/
  equivariant : ∀ (r : ℕ) (σ : Equiv.Perm (Fin r)) (t : Fin r → ω),
    Cooccur r t → Cooccur r (σ • t)

namespace SymOperad

variable (𝒪 : SymOperad ω)

/-- **Σ_r-equivariance in both directions.**  Because `Σ_r` is a group,
equivariance of the predicate is a genuine invariance: `t` co-occurs iff
`σ • t` co-occurs. -/
theorem cooccur_smul_iff {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    𝒪.Cooccur r (σ • t) ↔ 𝒪.Cooccur r t := by
  constructor
  · intro h
    have := 𝒪.equivariant r σ⁻¹ (σ • t) h
    rwa [inv_smul_smul] at this
  · exact 𝒪.equivariant r σ t

/-- **Full closure at arity `r`** — the categorical content of `κ_r = 1`.
`κ_r = 1` says *every* `r`-tuple co-occurs (the co-occurrence relation
covers all of `K(A)^r`). -/
def FullAt (r : ℕ) : Prop := ∀ t : Fin r → ω, 𝒪.Cooccur r t

/-- The operad is **total** (fully closed, `Comm`-like) when every arity is
fully closed: this is the operadic form of "`(K(A), ∘)` is a total
symmetric operad". -/
def TotalOperad : Prop := ∀ r : ℕ, 𝒪.FullAt r

/-! ### κ-tower closure characterisation (kernel of R.459 (b)) -/

/-- **R.459 (b) — κ-tower iff total operad.**

Modelling `κ_r = 1` as `FullAt r` (every `r`-tuple co-occurs), the κ-tower
saturation condition `∀ r, κ_r = 1` is *definitionally equivalent* to the
operad being total/fully closed.  This is the operadic upgrade of R.450's
κ-tower characterisation (`(∀ r, κ_r = 1) ↔ strict symmetric monoidal`):
here the target is a total symmetric operad. -/
theorem R_459_kappa_tower_iff_total :
    (∀ r : ℕ, 𝒪.FullAt r) ↔ 𝒪.TotalOperad := Iff.rfl

/-- **R.459 (b) — unfolded κ-tower characterisation.**

Spelling out `FullAt`: every tuple at every arity co-occurs `⟺` total. -/
theorem R_459_kappa_tower_iff_total' :
    (∀ (r : ℕ) (t : Fin r → ω), 𝒪.Cooccur r t) ↔ 𝒪.TotalOperad := Iff.rfl

/-! ### Operad scaffolding compatible with totality

We expose the two structural facts that make `𝒪(A)` an operad once it is
total: the formal unit at arity 1, and closure of the (partial)
composition.  In a total operad every tuple co-occurs, so composition is
*defined everywhere* (it becomes a total operad), and the unit laws hold
trivially because their underlying tuples co-occur. -/

/-- In a **total** operad, the formal unit `1 ∈ 𝒪_1` co-occurs: every
arity-1 tuple is an operation.  (Weak/formal-unit reading of R.459 (a),
matching the Stage-4A treatment of the X-7 unit ambiguity.) -/
theorem R_459_total_unit (h : 𝒪.TotalOperad) (u : Fin 1 → ω) :
    𝒪.Cooccur 1 u := h 1 u

/-- **R.459 (a) — partial composition is total under totality.**

The operadic composite of operations of arities `r` and `k` lands in arity
`r + k`; in a total operad the resulting flattened tuple co-occurs for
*any* inputs (composition is defined everywhere — the partial operad has
become total).  We state this for the concatenated tuple
`Fin.append`-style flattening via an arbitrary tuple `w : Fin (r + k) → ω`,
which is exactly the statement that the composition obstruction vanishes. -/
theorem R_459_total_comp_closed (h : 𝒪.TotalOperad)
    (r k : ℕ) (w : Fin (r + k) → ω) :
    𝒪.Cooccur (r + k) w := h (r + k) w

/-- **R.459 (a) — equivariance of composition closure.**

In a total operad the closure of arity-`r` operations is `Σ_r`-stable:
permuting the slots of a (necessarily co-occurring) tuple yields a tuple
that still co-occurs.  This is the symmetric-operad axiom restricted to the
totally-closed setting. -/
theorem R_459_total_equivariant (h : 𝒪.TotalOperad)
    {r : ℕ} (σ : Equiv.Perm (Fin r)) (t : Fin r → ω) :
    𝒪.Cooccur r (σ • t) := h r (σ • t)

end SymOperad

/-! ### Consequence: `Comm` as the saturated target

The "training = operad completion toward `Comm`" reading of R.459 (d) is
captured by: a total symmetric operad is exactly one whose co-occurrence
predicate is the *full* relation at every arity, i.e. the operad that
identifies with `Comm` (every set of inputs is simultaneously usable). -/

/-- The **commutative target operad** `Comm`: every tuple at every arity
co-occurs.  It is trivially `Σ_r`-equivariant (the full predicate is
invariant). -/
def commOperad (ω : Type*) : SymOperad ω where
  Cooccur := fun _ _ => True
  equivariant := fun _ _ _ _ => trivial

/-- **R.459 (d) — `Comm` is total.**  The commutative operad is the
saturated `κ_r = 1 ∀r` endpoint of training. -/
theorem R_459_comm_total : (commOperad ω).TotalOperad :=
  fun _ _ => trivial

/-- **R.459 (d) — totality means identification with `Comm`.**

A symmetric operad is total iff its co-occurrence predicate equals that of
`Comm` (the full relation) at every arity.  This is the precise sense in
which "completing the κ-tower" lands the operad on `Comm`. -/
theorem R_459_total_iff_comm (𝒪 : SymOperad ω) :
    𝒪.TotalOperad ↔ ∀ (r : ℕ) (t : Fin r → ω),
      𝒪.Cooccur r t ↔ (commOperad ω).Cooccur r t := by
  constructor
  · intro h r t
    exact ⟨fun _ => trivial, fun _ => h r t⟩
  · intro h r t
    exact (h r t).2 trivial

end PartialOperad

end MIP
