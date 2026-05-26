/-
Result R.462 — Vietoris–Rips-type complex `Δ_∘(K(A))`: construction and
(P-mono) monotonicity.

Reference: `workspace/k_a_simplicial_homology.md` §0 (R.462)
(A 无条件 / A-unconditional, 2026-05-16 categorical-formalization block).

**Statement (combinatorial kernel).** For a finite knowledge space `K(A)`
with co-occurrence relations `R_∘^(r)`, the Vietoris–Rips-type abstract
simplicial complex `Δ_∘(K(A))` has as its `r`-simplices the `(r+1)`-element
subsets `σ ⊆ K(A)` with `R_∘^(r+1)(σ) = 1` ("`A` can simultaneously use the
elements of `σ`").

The defining structural property is **(P-mono)**: removing any element of a
co-occurring tuple keeps it co-occurring (`⊑` is monotone under subsets,
D.1.3). Hence `Δ_∘(K(A))` is *downward closed* — a face of a simplex is a
simplex — so it is a well-defined abstract simplicial complex *without any new
axiom*.

This file formalises the **combinatorial kernel** of R.462:

* `Complex` — an abstract simplicial complex over a vertex type as a
  downward-closed family of `Finset`s (membership = "is a face").
* the canonical Vietoris–Rips complex `rips R` built from a co-occurrence
  predicate `R` that already satisfies (P-mono); we prove the family it
  produces is genuinely downward closed (`rips_downwardClosed`).
* the monotonicity property **(P-mono ⇒ complex monotonicity)**:
  `K(A) ⊆ K(A') ⟹ Δ_∘(K(A)) ⊆ Δ_∘(K(A'))`, i.e. enlarging the
  co-occurrence predicate enlarges the complex
  (`R_462_Pmono_monotone`).

The "heavy" homology (chain groups, `∂² = 0`, `H_n`) is *reduced away*: we
keep only the crisp combinatorial layer (face complex + monotonicity), which
is the part the source marks **A-unconditional**.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Order.SetNotation

namespace MIP

namespace VietorisRips

variable {V : Type*}

/-- An **abstract simplicial complex** on vertices of type `V`, represented by
its set of faces (each a `Finset V`), required to be *downward closed*: every
subset of a face is a face. This is the combinatorial datum underlying
`Δ_∘(K(A))`; we deliberately do not require nonemptiness or all singletons,
keeping the kernel minimal. -/
structure Complex (V : Type*) where
  /-- The faces of the complex. -/
  faces : Set (Finset V)
  /-- Downward closure: any subset of a face is a face (the (P-mono) shape). -/
  downward_closed : ∀ {σ τ : Finset V}, σ ∈ faces → τ ⊆ σ → τ ∈ faces

namespace Complex

/-- `σ` is a face of `K`. -/
def IsFace (K : Complex V) (σ : Finset V) : Prop := σ ∈ K.faces

/-- Inclusion of complexes: every face of `K` is a face of `L`. -/
def Subset (K L : Complex V) : Prop := K.faces ⊆ L.faces

instance : HasSubset (Complex V) := ⟨Subset⟩

@[simp] lemma subset_def {K L : Complex V} : K ⊆ L ↔ K.faces ⊆ L.faces := Iff.rfl

/-- A face of a simplex is a simplex (restatement of `downward_closed` via
`IsFace`). -/
theorem face_of_subset (K : Complex V) {σ τ : Finset V}
    (hσ : K.IsFace σ) (hτσ : τ ⊆ σ) : K.IsFace τ :=
  K.downward_closed hσ hτσ

end Complex

/-- **(P-mono) for a co-occurrence predicate.**

A predicate `R : Finset V → Prop` (read: "`R σ` ⟺ the elements of `σ`
co-occur", i.e. `R_∘^(|σ|)(σ) = 1`) satisfies **(P-mono)** when removing
elements preserves co-occurrence: every subset of a co-occurring set
co-occurs. This is exactly the source's monotonicity of `⊑` along subsets
(D.1.3), an *unconditional* consequence of the co-occurrence semantics. -/
def Pmono (R : Finset V → Prop) : Prop :=
  ∀ {σ τ : Finset V}, R σ → τ ⊆ σ → R τ

/-- **The Vietoris–Rips complex `Δ_∘` of a (P-mono) co-occurrence predicate.**

Faces are exactly the sets `σ` with `R σ`. The face set is downward closed
precisely because `R` satisfies (P-mono). -/
def rips (R : Finset V → Prop) (h : Pmono R) : Complex V where
  faces := { σ | R σ }
  downward_closed hσ hτσ := h hσ hτσ

@[simp] lemma mem_rips {R : Finset V → Prop} {h : Pmono R} {σ : Finset V} :
    σ ∈ (rips R h).faces ↔ R σ := Iff.rfl

/-- `σ` is a simplex of `Δ_∘(R)` iff `R σ` (it co-occurs). -/
@[simp] lemma rips_isFace {R : Finset V → Prop} {h : Pmono R} {σ : Finset V} :
    (rips R h).IsFace σ ↔ R σ := Iff.rfl

/-- **The Vietoris–Rips face family is downward closed** (sanity check that
`rips` is a genuine abstract simplicial complex). -/
theorem rips_downwardClosed (R : Finset V → Prop) (h : Pmono R) :
    ∀ {σ τ : Finset V}, (rips R h).IsFace σ → τ ⊆ σ → (rips R h).IsFace τ :=
  fun hσ hτσ => h hσ hτσ

/-- **R.462 (P-mono) monotonicity — the headline kernel.**

If the co-occurrence predicate grows (`R σ → R' σ` for all `σ`, i.e.
`K(A) ⊆ K(A')` enlarges co-occurrence), then the Vietoris–Rips complex grows:
`Δ_∘(K(A)) ⊆ Δ_∘(K(A'))`. Every simplex of the smaller complex is a simplex
of the larger one. -/
theorem R_462_Pmono_monotone
    (R R' : Finset V → Prop) (hR : Pmono R) (hR' : Pmono R')
    (hsub : ∀ σ, R σ → R' σ) :
    rips R hR ⊆ rips R' hR' := by
  intro σ hσ
  exact hsub σ hσ

/-- **R.462 monotonicity, simplex form.**

Restated at the level of individual simplices: under the same hypotheses,
every face of `Δ_∘(K(A))` is a face of `Δ_∘(K(A'))`. -/
theorem R_462_face_monotone
    (R R' : Finset V → Prop) (hR : Pmono R) (hR' : Pmono R')
    (hsub : ∀ σ, R σ → R' σ) {σ : Finset V}
    (hσ : (rips R hR).IsFace σ) : (rips R' hR').IsFace σ :=
  hsub σ hσ

/-- **R.462 — (P-mono) is preserved when restricting a vertex set.**

A concrete instance of how the kernel composes: if `R` is (P-mono) then so is
its restriction `fun σ => R σ ∧ σ ⊆ S` to a fixed vertex subset `S`. (Removing
a vertex keeps both `R` — by (P-mono) — and the containment in `S`.) This
witnesses that `Δ_∘` is functorial along induced subcomplexes. -/
theorem Pmono_restrict (R : Finset V → Prop) (h : Pmono R) (S : Finset V) :
    Pmono (fun σ => R σ ∧ σ ⊆ S) := by
  intro σ τ hσ hτσ
  exact ⟨h hσ.1 hτσ, hτσ.trans hσ.2⟩

/-- **R.462 — the induced subcomplex on `S` is a subcomplex of `Δ_∘(R)`.** -/
theorem rips_restrict_subset (R : Finset V → Prop) (h : Pmono R) (S : Finset V) :
    rips (fun σ => R σ ∧ σ ⊆ S) (Pmono_restrict R h S) ⊆ rips R h := by
  intro σ hσ
  exact hσ.1

end VietorisRips

end MIP
