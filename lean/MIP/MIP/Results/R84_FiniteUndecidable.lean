/-
Result R.84 — `DECIDE-N-FINITE` is undecidable.

Reference: `proofs/derived/computation.md` R.84 (A 级, deps R.83, A.2).

**Statement.**  `DECIDE-N-FINITE`: given a finite description `(p, A)`, decide
whether `N(p, A) < ∞`.  This decision problem is **undecidable**.

**Source reduction (computation.md §R.84).**  Direct corollary of R.83.  The
R.83 construction `(T, x) ↦ (p_{T,x}, A*_{T,x})` satisfies

    `T` halts on `x`  ⟺  N(p_{T,x}, A*_{T,x}) < ∞,

so a decider `D` for `DECIDE-N-FINITE` would decide halting: on input `(T, x)`
build `(p, A)`, run `D`, output "halts" iff `D` answers "yes".  Since halting is
undecidable, `DECIDE-N-FINITE` is undecidable.

**Lean kernel (HYPOTHESIS-BUNDLE-REDUCTION; no Turing machines).**  This is the
same decidability-transfer kernel as R.83, applied to the `DECIDE-N-FINITE`
predicate `finiteN Nfun q :≡ Nfun q < ⊤`.  We re-prove the transfer self-
containedly (this file imports only `Mathlib`, not R83) and conclude

    `¬ IsDecidablePred (finiteN Nfun)`

from the bundled reduction hypotheses.  Because the reduction is the *identity
specialization* of R.83 (the target predicate is literally `N < ∞`), R.84 is
the clean restatement: undecidability of the very predicate R.83 reduces
halting to.

**Decidability, rigorously.**  As in R.83, `DecidablePred` is `Type`-valued and
not negatable; we use the `Prop`-valued surrogate `IsDecidablePred P`, the
existence of a total Boolean decider `f` with `f a = true ↔ P a`.

**This file is `axiom`-free.**  Imports only `Mathlib`; all Turing-machine
semantics are bundled into `Nfun`, `red`, and the reduction hypotheses.
-/
import Mathlib

namespace MIP

namespace FiniteUndecidable

/-- A total Boolean function `f` **decides** the predicate `P` when it returns
`true` exactly on `P`. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop :=
  ∀ a, f a = true ↔ P a

/-- `P` is **decidable** (the `Prop`-valued, negatable sense): a total Boolean
decider exists.  Undecidability is `¬ IsDecidablePred P`. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop :=
  ∃ f : α → Bool, Decides f P

/-- **Decidability-transfer kernel.**  Decidability pulls back along a reduction
`red` validating `Q` against `P`.  The real mathematical content. -/
theorem decidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hP : IsDecidablePred P) : IsDecidablePred Q := by
  obtain ⟨f, hf⟩ := hP
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), hval a]

/-- **Contrapositive transfer.**  `Q` undecidable and `Q ≤ P` ⟹ `P`
undecidable.  The rigorous "`Halt ≤ TARGET ⟹ TARGET undecidable". -/
theorem undecidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hQ : ¬ IsDecidablePred Q) : ¬ IsDecidablePred P :=
  fun hP => hQ (decidable_transfer red hval hP)

variable {ι : Type*}

/-- The `DECIDE-N-FINITE` predicate: `N(q) < ∞`, i.e. `Nfun q < ⊤` in `ℕ∞`. -/
def finiteN (Nfun : ι → ℕ∞) (q : ι) : Prop := Nfun q < ⊤

@[simp] theorem finiteN_def (Nfun : ι → ℕ∞) (q : ι) :
    finiteN Nfun q ↔ Nfun q < ⊤ := Iff.rfl

/-- **R.84 — `DECIDE-N-FINITE` is undecidable (main theorem).**

Direct application of the R.83 reduction.  Given the halting predicate, the
reduction `red`, the validity `halts m ↔ N(red m) < ∞`, and undecidability of
halting, the predicate `DECIDE-N-FINITE = finiteN Nfun` is undecidable. -/
theorem R_84_decide_finite_undecidable
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ finiteN Nfun (red m))
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (finiteN Nfun) :=
  undecidable_transfer (P := finiteN Nfun) (Q := halts) red hval h_halt_undec

/-- **R.84 — unfolded restatement.**

Same conclusion stated with the `< ⊤` predicate written out, matching the
literal `N(p, A) < ∞?` decision problem. -/
theorem R_84_decide_finite_undecidable'
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ Nfun (red m) < ⊤)
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (fun q => Nfun q < ⊤) :=
  undecidable_transfer (P := fun q => Nfun q < ⊤) (Q := halts) red hval h_halt_undec

/-- **R.84 — corollary in the contrapositive (the source's actual argument).**

`computation.md §R.84` argues: *if* `DECIDE-N-FINITE` had a decider `D`, *then*
halting would be decidable (run `D` on the reduced instance).  We state exactly
that implication: a decider for `finiteN Nfun` yields a decider for halting. -/
theorem R_84_decider_decides_halting
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → ι)
    (hval : ∀ m, halts m ↔ finiteN Nfun (red m))
    (hD : IsDecidablePred (finiteN Nfun)) :
    IsDecidablePred halts :=
  decidable_transfer (P := finiteN Nfun) (Q := halts) red hval hD

end FiniteUndecidable

end MIP
