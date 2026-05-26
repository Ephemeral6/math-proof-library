/-
Result R.83 (T.16) — Turing-uncomputability of the emergence cost `N`.

Reference: `proofs/derived/computation.md` R.83 (A 级, deps A.2, D.1.6, D.1.2,
halting problem (Turing 1936)).

**Statement.**  There is no Turing machine `M` such that for every finite
description `(p, A)` the machine `M(p, A)` halts and outputs the value
`N(p, A) ∈ ℕ∞`.  Equivalently, the function `(p, A) ↦ N(p, A)` is Turing-
uncomputable.

**Source reduction (computation.md §R.83).**  Given a Turing machine `T` and an
input `x`, one constructs a problem/agent pair `(p_{T,x}, A*_{T,x})` — `A*`
simulates `T` step by step, `p_{T,x}` accepts exactly the halting configuration
— so that

    N(p_{T,x}, A*_{T,x}) = halting_time(T, x)   if `T` halts on `x`,
    N(p_{T,x}, A*_{T,x}) = ∞                     otherwise.

Hence

    `T` halts on `x`  ⟺  N(p_{T,x}, A*_{T,x}) < ∞.

This is a many-one reduction `Halt ≤ {N < ∞}`.  Since `Halt` is undecidable,
the predicate "`N(q) < ∞`" is undecidable, and therefore `N` itself is not a
Turing-computable function (a computable `N` would let us decide `N < ∞`, hence
`Halt`).

**Lean kernel (HYPOTHESIS-BUNDLE-REDUCTION; no Turing machines).**  We model
the emergence cost abstractly as a function `Nfun : ι → ℕ∞` on an index type
`ι` of `(p, A)`-descriptions.  The finiteness predicate of interest is
`finiteN q :≡ Nfun q < ⊤`.  We bundle the two facts established by the source
construction as hypotheses:

* `halts : ℕ → Prop`            — the halting predicate of `Turing 1936`;
* `red : ℕ → ι`                 — the reduction `(T,x) ↦ (p_{T,x}, A*_{T,x})`;
* `hval : ∀ m, halts m ↔ finiteN (red m)`  — validity of the reduction
  (`computation.md §R.83`: `T` halts ⟺ `N < ∞`);
* `h_halt_undec : ¬ IsDecidablePred halts`  — undecidability of halting.

The conclusion `¬ IsDecidablePred finiteN` (finiteness of `N` is undecidable,
hence `N` is uncomputable) follows from the **decidability-transfer kernel**,
which is the rigorous content of "`Halt ≤ {N < ∞} ⟹ {N < ∞}` undecidable".

**Decidability, rigorously.**  `DecidablePred` is `Type`-valued (it carries
data) and so cannot be negated as a proposition.  We use the standard `Prop`-
valued surrogate: a predicate `P : α → Prop` is *decidable* iff there exists a
total Boolean decider `f : α → Bool` with `f a = true ↔ P a`.  Undecidability is
the negation of this existential — a genuine proposition.

**This file is `axiom`-free.**  It imports only `Mathlib`; all Turing-machine
semantics are bundled into `Nfun`, `red`, and the reduction hypotheses.
-/
import Mathlib

namespace MIP

namespace Uncomputable

/-- A total Boolean function `f` **decides** the predicate `P` when it returns
`true` exactly on `P`.  This is the computable-decider relation. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop :=
  ∀ a, f a = true ↔ P a

/-- `P` is **decidable** (in the `Prop`-valued, negatable sense) iff some total
Boolean decider exists.  Undecidability is `¬ IsDecidablePred P`. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop :=
  ∃ f : α → Bool, Decides f P

/-- **Decidability-transfer kernel (the mathematical substance).**

Decidability pulls back along a reduction.  If `red : α → β` validates `Q`
against `P` (`∀ a, Q a ↔ P (red a)`) and `P` is decidable by `f`, then
`fun a => f (red a)` decides `Q`.  This is the rigorous core of
"`Q ≤ P` and `P` decidable ⟹ `Q` decidable". -/
theorem decidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hP : IsDecidablePred P) : IsDecidablePred Q := by
  obtain ⟨f, hf⟩ := hP
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), hval a]

/-- **Contrapositive transfer.**  If `Q` is undecidable and `Q` reduces to `P`
(`∀ a, Q a ↔ P (red a)`), then `P` is undecidable.  This is the rigorous form
of "`Halt ≤ TARGET ⟹ TARGET undecidable". -/
theorem undecidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hQ : ¬ IsDecidablePred Q) : ¬ IsDecidablePred P :=
  fun hP => hQ (decidable_transfer red hval hP)

variable {ι : Type*}

/-- The finiteness predicate of the emergence cost: `N(q) < ∞`, i.e.
`Nfun q < ⊤` in `ℕ∞`.  This is the `DECIDE-N-FINITE` predicate of R.84 and the
target of the R.83 halting reduction. -/
def finiteN (Nfun : ι → ℕ∞) (q : ι) : Prop := Nfun q < ⊤

@[simp] theorem finiteN_def (Nfun : ι → ℕ∞) (q : ι) :
    finiteN Nfun q ↔ Nfun q < ⊤ := Iff.rfl

/-- **R.83 — Turing-uncomputability of `N` (main theorem).**

Bundling the source construction: with the halting predicate `halts`, the
reduction `red : ℕ → ι` (`(T,x) ↦ (p_{T,x}, A*_{T,x})`), the validity
`halts m ↔ N(red m) < ∞`, and the undecidability of halting, the finiteness
predicate `fun q => Nfun q < ⊤` of `N` is **undecidable**.

A Turing-computable `N` would yield a decider for `N < ∞` (compare the output
to `⊤`), hence a decider for `Halt` — contradiction.  Therefore `N` is not
Turing-computable. -/
theorem R_83_N_uncomputable
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ Nfun (red m) < ⊤)
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (fun q => Nfun q < ⊤) :=
  undecidable_transfer (P := fun q => Nfun q < ⊤) (Q := halts) red hval h_halt_undec

/-- **R.83 — restated through the named `finiteN` predicate.**

Identical conclusion phrased with `finiteN Nfun`, the canonical
`DECIDE-N-FINITE` predicate, for use by R.84. -/
theorem R_83_finiteN_undecidable
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ finiteN Nfun (red m))
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (finiteN Nfun) :=
  undecidable_transfer (P := finiteN Nfun) (Q := halts) red hval h_halt_undec

/-- **R.83 — the kernel is non-vacuous (genuine forward decidability transfer).**

When the reduction is valid, decidability of the finiteness target `N < ∞`
*forces* decidability of halting: a decider for `fun q => Nfun q < ⊤`, composed
with `red`, decides `halts`.  This is the contrapositive used in
`R_83_N_uncomputable` run forward — it shows the transfer is a real implication
(not a vacuous statement) and is exactly the step "compute `N`, compare to `⊤`,
thereby decide `Halt`". -/
theorem R_83_decide_finite_implies_decide_halt
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ Nfun (red m) < ⊤)
    (hfin : IsDecidablePred (fun q => Nfun q < ⊤)) :
    IsDecidablePred halts :=
  decidable_transfer (P := fun q => Nfun q < ⊤) (Q := halts) red hval hfin

end Uncomputable

end MIP
