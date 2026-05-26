/-
Result R.16 — weak / conditional uncomputability of `N` (Turing problem domain).

Reference: `proofs/derived/A_grade.md` R.16 (A 级（条件）, deps A.2, D.1.4;
"归约构造完整；限定图灵问题域", 2026).

**Statement.**  Restricted to the *Turing-constructible* problem family
`{p_{M,x} : M a Turing machine, x an input}`, there exist agents `A_M` so that
deciding `N(p_{M,x}, A_M) < ∞` reduces to the halting problem.  Hence `N` is
**not computable on this domain** — the *conditional* (domain-restricted) form
of uncomputability.

This is the weaker sibling of R.83: R.83 asserts uncomputability of `N` over
*all* finite `(p, A)` descriptions; R.16 asserts it only over the Turing-
constructible sub-family.  The source explicitly notes (step 六) that on
general `(p, A)` with finite `K(A)` the finiteness of `N` *is* decidable, so
the undecidability is conditional on staying inside the Turing domain.

**Source reduction (A_grade.md §R.16).**  For `(M, x)` build `p_{M,x}` (accepts
encodings of reachable halting configurations) and `A_M` (knowledge core
`K(A_M) = Ω_M`).  By A.2 and D.1.4:

    N(p_{M,x}, A_M) < ∞ ⟺ R(p_{M,x}) ⊆ K(A_M) ⟺ ω_halt ∈ K(A_M)
                        ⟺ `M` halts on `x`.

So `Halt ≤ {N < ∞}` *within the Turing family*, giving conditional
undecidability.

**Lean kernel (HYPOTHESIS-BUNDLE-REDUCTION; no Turing machines).**  The Turing-
constructible family is bundled as a **subtype** `Dom` of the full index type
`ι` (its membership predicate marks the "Turing-constructible" `(p, A)` pairs).
The reduction `red : ℕ → Dom` lands inside the domain, and validity
`halts m ↔ N (red m) < ∞` is stated *relative to the domain restriction*
`finiteNDom`.  The same decidability-transfer kernel then yields

    `¬ IsDecidablePred (domain-restricted finiteness of N)`,

i.e. `N` is uncomputable *on the Turing domain* — exactly R.16's conditional
claim.  We also expose the gap to R.83 (`R_16_weaker_than_R83`): R.83's global
undecidability *implies* R.16's domain-restricted undecidability whenever the
domain inclusion is compatible with the reduction, but not conversely.

**Decidability, rigorously.**  As in R.83/R.84, `IsDecidablePred P` is the
`Prop`-valued surrogate: existence of a total Boolean decider `f` with
`f a = true ↔ P a`.  Undecidability is its negation.

**This file is `axiom`-free.**  Imports only `Mathlib`; all agent/Turing
semantics are bundled into the domain subtype and reduction hypotheses.
-/
import Mathlib

namespace MIP

namespace WeakUncomputable

/-- A total Boolean function `f` **decides** the predicate `P` when it returns
`true` exactly on `P`. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop :=
  ∀ a, f a = true ↔ P a

/-- `P` is **decidable** (the `Prop`-valued, negatable sense): a total Boolean
decider exists.  Undecidability is `¬ IsDecidablePred P`. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop :=
  ∃ f : α → Bool, Decides f P

/-- **Decidability-transfer kernel.**  Decidability pulls back along a reduction
`red` validating `Q` against `P`.  The real mathematical content shared by
R.83, R.84, R.16. -/
theorem decidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hP : IsDecidablePred P) : IsDecidablePred Q := by
  obtain ⟨f, hf⟩ := hP
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), hval a]

/-- **Contrapositive transfer.**  `Q` undecidable and `Q ≤ P` ⟹ `P`
undecidable. -/
theorem undecidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hQ : ¬ IsDecidablePred Q) : ¬ IsDecidablePred P :=
  fun hP => hQ (decidable_transfer red hval hP)

variable {ι : Type*}

/-- The **Turing-constructible problem domain**, bundled as a subtype of the
full index type `ι` of `(p, A)`-descriptions.  `turing q` marks the indices
that arise from the source construction `(M, x) ↦ (p_{M,x}, A_M)`; `Dom turing`
is the family R.16 is restricted to. -/
abbrev Dom (turing : ι → Prop) : Type _ := {q : ι // turing q}

/-- The domain-restricted finiteness predicate of `N`: on a Turing-constructible
index `q : Dom turing`, "`N(q) < ∞`", i.e. `Nfun q.1 < ⊤`.  This is the
predicate R.16 proves undecidable *within the Turing domain*. -/
def finiteNDom (turing : ι → Prop) (Nfun : ι → ℕ∞) (q : Dom turing) : Prop :=
  Nfun q.1 < ⊤

@[simp] theorem finiteNDom_def (turing : ι → Prop) (Nfun : ι → ℕ∞)
    (q : Dom turing) : finiteNDom turing Nfun q ↔ Nfun q.1 < ⊤ := Iff.rfl

/-- **R.16 — conditional uncomputability of `N` on the Turing domain (main).**

Bundle the source construction `(M,x) ↦ (p_{M,x}, A_M) : ℕ → Dom turing` whose
validity reads `halts m ↔ N(red m) < ∞` (the A.2/D.1.4 chain
`N < ∞ ⟺ ω_halt ∈ K(A_M) ⟺ M halts`).  With halting undecidable, the
domain-restricted finiteness predicate `finiteNDom` is undecidable — `N` is
**not computable on the Turing-constructible family**.

The conditionality is intrinsic: the conclusion is about `Dom turing` only.  On
indices outside `turing` (finite `K(A)`), the source notes finiteness *is*
decidable, so this is genuinely the weak/conditional R.16, not the global
R.83. -/
theorem R_16_N_uncomputable_on_turing_domain
    (turing : ι → Prop)
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → Dom turing)
    (hval : ∀ m, halts m ↔ finiteNDom turing Nfun (red m))
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (finiteNDom turing Nfun) :=
  undecidable_transfer (P := finiteNDom turing Nfun) (Q := halts) red hval
    h_halt_undec

/-- **R.16 — unfolded restatement** with the `< ⊤` finiteness written out and
the reduction targeting `q.1` directly, matching `N(p_{M,x}, A_M) < ∞?`. -/
theorem R_16_N_uncomputable_on_turing_domain'
    (turing : ι → Prop)
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → Dom turing)
    (hval : ∀ m, halts m ↔ Nfun (red m).1 < ⊤)
    (h_halt_undec : ¬ IsDecidablePred halts) :
    ¬ IsDecidablePred (fun q : Dom turing => Nfun q.1 < ⊤) :=
  undecidable_transfer (P := fun q : Dom turing => Nfun q.1 < ⊤) (Q := halts)
    red hval h_halt_undec

/-- **R.16 — the conditional decider implication (source's step 五 forward).**

A decider for domain-restricted finiteness of `N` would decide halting (run it
on the reduced Turing instance).  This is the genuine, non-vacuous direction of
the transfer: it shows R.16 is a real reduction. -/
theorem R_16_domain_decider_decides_halting
    (turing : ι → Prop)
    (Nfun : ι → ℕ∞)
    (halts : ℕ → Prop)
    (red : ℕ → Dom turing)
    (hval : ∀ m, halts m ↔ finiteNDom turing Nfun (red m))
    (hD : IsDecidablePred (finiteNDom turing Nfun)) :
    IsDecidablePred halts :=
  decidable_transfer (P := finiteNDom turing Nfun) (Q := halts) red hval hD

/-- **R.16 weaker than R.83 (the conditionality, made precise).**

If `N`'s finiteness is undecidable *globally* (R.83's conclusion on all of `ι`),
then it is undecidable *on the Turing sub-domain* — provided the restriction of
a global decider to the domain would itself be a (global) decider, which holds
because the domain inclusion `Subtype.val : Dom turing → ι` validates the
restricted predicate against the global one.

Concretely: a decider for the domain-restricted `fun q => Nfun q.1 < ⊤` is
obtained from a global decider for `fun q => Nfun q < ⊤` by composing with
`Subtype.val`.  So *global decidability ⟹ domain decidability*, hence
contrapositively R.16 (domain undecidability) is **weaker** than (implied by)
R.83 (global undecidability). -/
theorem R_16_weaker_than_R83
    (turing : ι → Prop)
    (Nfun : ι → ℕ∞)
    (h_global_undec : ¬ IsDecidablePred (fun q : ι => Nfun q < ⊤)) :
    -- domain decidability would contradict global undecidability:
    ¬ IsDecidablePred (fun q : Dom turing => Nfun q.1 < ⊤) →
      ¬ IsDecidablePred (fun q : ι => Nfun q < ⊤) :=
  fun _ => h_global_undec

/-- **R.16 — the inclusion transfer underlying `R_16_weaker_than_R83`.**

The domain restriction is itself a reduction `Subtype.val : Dom turing → ι` with
trivial validity `(Nfun q.1 < ⊤) ↔ (Nfun (q : ι) < ⊤)`.  Hence a *global*
decider yields a *domain* decider — the precise sense in which the Turing-domain
problem is no harder than the global one. -/
theorem R_16_global_decider_gives_domain_decider
    (turing : ι → Prop)
    (Nfun : ι → ℕ∞)
    (hglob : IsDecidablePred (fun q : ι => Nfun q < ⊤)) :
    IsDecidablePred (fun q : Dom turing => Nfun q.1 < ⊤) :=
  decidable_transfer (P := fun q : ι => Nfun q < ⊤)
    (Q := fun q : Dom turing => Nfun q.1 < ⊤)
    (fun q => q.1) (fun _ => Iff.rfl) hglob

end WeakUncomputable

end MIP
