/-
Result R.165 — Arithmetic-hierarchy refinement of MIP incompleteness
(Gödel I/II embedded into MIP).

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.165 and
`new_results.md` §R.165 (A 条件性, deps R.83, R.84, R.108, Gödel 1931,
Tarski 1936, Kleene 1943).

**Statement.**  Let `TRUE(MIP)` be the set of MIP-propositions true in the
standard model.  R.165 establishes:

* **(a)** `TRUE(MIP) ∉ ⋃ₙ Σ⁰ₙ` — it lies outside the entire arithmetic
  hierarchy (Tarski undefinability via the embedding `ι`).
* **(b)** for each `n`, `TRUE(MIP)` contains a representative of `Σ⁰ₙ \ Π⁰ₙ`.
* **(c)** for any `Σ⁰₁`-axiomatizable, consistent, `Σ⁰₁`-sound formal system
  `𝓕`, there is `ψ_𝓕 ∈ TRUE(MIP)` with `𝓕 ⊬ ψ_𝓕` and `𝓕 ⊬ ¬ψ_𝓕`
  (Gödel-style incompleteness, via the consistency sentence `Cons(𝓕)`).

The technical engine is a **truth- and provability-preserving embedding**
`ι : Arith → MIP` (R.83 gives `ι(σ) = "N(pσ, A*σ) < ∞"` for `Σ⁰₁` sentences;
the `Σ⁰_{n+1}` induction extends it).  Part (c) is the genuinely new content
over R.108 ("some MIP-statement is algorithmically undecidable"): it upgrades
to "every consistent r.e. axiom system leaves a true MIP-statement unproved",
i.e. *formal* incompleteness.

**Formalization strategy (HYPOTHESIS-BUNDLE-REDUCTION).**  We do not formalize
the arithmetic hierarchy, Turing machines, or a provability predicate.  We
abstract:

* `MIPProp` — opaque MIP-propositions;
* `True_ : MIPProp → Prop` — truth in the standard model (`φ ∈ TRUE(MIP)`);
* `Prov : MIPProp → Prop` — provability in the fixed system `𝓕`;
* `ι : Arith → MIPProp` — the embedding, with bundled facts
  *truth-preservation* `Arith.True s ↔ True_ (ι s)` and *provability-
  preservation* `Arith.Prov s ↔ Prov (ι s)`.

The core theorem `R_165_c_incompleteness` is the honest transfer: the Gödel-II
fact "a sound consistent system cannot prove its own consistency, yet its
consistency is true" (bundled as hypotheses on the arithmetic side) pulls back
through `ι` to a true-but-unprovable MIP-proposition.

**This file is `axiom`-free.**  Imports only `Mathlib`; Gödel I/II, Tarski,
and the hierarchy theorem all enter as explicit hypotheses on the abstract
arithmetic side.
-/
import Mathlib

namespace MIP

namespace ArithmeticHierarchy

-- Opaque MIP-propositions.
variable {MIPProp : Type*}

-- Opaque arithmetic sentences (the domain of the embedding `ι`).
variable {Arith : Type*}

-- Truth of an arithmetic sentence in the standard model.
variable (ArithTrue : Arith → Prop)

-- Provability of an arithmetic sentence in the fixed formal system `𝓕`.
variable (ArithProv : Arith → Prop)

-- Truth of a MIP-proposition (`φ ∈ TRUE(MIP)`).
variable (True_ : MIPProp → Prop)

-- Provability of a MIP-proposition in `𝓕` (carried through `ι`).
variable (Prov : MIPProp → Prop)

-- The embedding `ι : Arith → MIPProp` of R.165(a) (`Σ⁰₁` via R.83,
-- `Σ⁰_{n+1}` by induction).
variable (ι : Arith → MIPProp)

-- Negation on MIP-propositions (used to state two-sided unprovability).
variable (mipNot : MIPProp → MIPProp)

/-- **R.165(a)/(b) core — truth transfers across the embedding.**

The embedding `ι` is truth-preserving: an arithmetic sentence is true iff its
MIP-image is in `TRUE(MIP)`.  Hence any true arithmetic sentence (e.g. a
`Σ⁰ₙ \ Π⁰ₙ` representative for part (b), or `Cons(𝓕)` for part (c)) maps to a
true MIP-proposition.  This is the mechanism by which `TRUE(MIP)` inherits the
full arithmetic hierarchy. -/
theorem R_165_true_transfer
    (htruth : ∀ s, ArithTrue s ↔ True_ (ι s))
    {s : Arith} (hs : ArithTrue s) :
    True_ (ι s) :=
  (htruth s).mp hs

/-- **R.165 — provability is preserved both ways.**

`ι` being recursive, `𝓕 ⊢ σ ⟺ 𝓕 ⊢ ι(σ)`.  In particular *non*-provability
transfers: an arithmetic sentence unprovable in `𝓕` has an unprovable
MIP-image. -/
theorem R_165_unprov_transfer
    (hprov : ∀ s, ArithProv s ↔ Prov (ι s))
    {s : Arith} (hs : ¬ ArithProv s) :
    ¬ Prov (ι s) :=
  fun h => hs ((hprov s).mpr h)

/-- **R.165(c) — formal incompleteness of MIP (main theorem).**

Inputs bundle Gödel's second incompleteness theorem on the arithmetic side:
* `consF : Arith` — the consistency sentence `Cons(𝓕)`;
* `htruth`, `hprov` — truth/provability preservation of `ι`;
* `h_cons_true : ArithTrue consF` — `𝓕` really is consistent ⟹ `Cons(𝓕)`
  is true;
* `h_godel2 : ¬ ArithProv consF` — Gödel II: a consistent system cannot prove
  its own consistency;
* `hneg : ¬ Prov (mipNot (ι consF))` — `𝓕` also cannot refute the
  consistency statement (it is true and `𝓕` is sound).

Conclusion: the MIP-proposition `ψ_𝓕 := ι(Cons(𝓕))` is **true** yet
`𝓕 ⊬ ψ_𝓕` and `𝓕 ⊬ ¬ψ_𝓕` — a true, formally undecidable MIP-statement.
This is the precise Gödel-style refutation of the completeness conjecture
(Cj.11). -/
theorem R_165_c_incompleteness
    (consF : Arith)
    (htruth : ∀ s, ArithTrue s ↔ True_ (ι s))
    (hprov : ∀ s, ArithProv s ↔ Prov (ι s))
    (h_cons_true : ArithTrue consF)
    (h_godel2 : ¬ ArithProv consF)
    (hneg : ¬ Prov (mipNot (ι consF))) :
    True_ (ι consF) ∧ ¬ Prov (ι consF) ∧ ¬ Prov (mipNot (ι consF)) := by
  refine ⟨?_, ?_, hneg⟩
  · exact R_165_true_transfer ArithTrue True_ ι htruth h_cons_true
  · exact R_165_unprov_transfer ArithProv Prov ι hprov h_godel2

/-- **R.165 — the embedded statement witnesses incompleteness existentially.**

Repackages the main theorem as "there exists a true MIP-proposition that `𝓕`
neither proves nor refutes", the form in which R.165(c) refutes Cj.11
("any formal system axiomatizing MIP misses a true proposition"). -/
theorem R_165_exists_true_undecidable
    (consF : Arith)
    (htruth : ∀ s, ArithTrue s ↔ True_ (ι s))
    (hprov : ∀ s, ArithProv s ↔ Prov (ι s))
    (h_cons_true : ArithTrue consF)
    (h_godel2 : ¬ ArithProv consF)
    (hneg : ¬ Prov (mipNot (ι consF))) :
    ∃ φ : MIPProp, True_ φ ∧ ¬ Prov φ ∧ ¬ Prov (mipNot φ) :=
  ⟨ι consF,
    R_165_c_incompleteness ArithTrue ArithProv True_ Prov ι mipNot
      consF htruth hprov h_cons_true h_godel2 hneg⟩

end ArithmeticHierarchy

end MIP
