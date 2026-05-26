/-
Result R.166 — Parameterized complexity of BOUNDED-N: k-BOUNDED-N is
W[2]-complete.

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.166 and
`new_results.md` §R.166 (A 条件性, deps R.164(e), k-Set-Cover W[2]-completeness
(Downey–Fellows 1995), Courcelle).

**Statement.**  Under the parameter `k` (step bound), with succinct
deterministic input, `k-BOUNDED-N` is **W[2]-complete**, via the two FPT
reductions

    k-Set-Cover  ≤_FPT  k-BOUNDED-N      (W[2]-hardness)
    k-BOUNDED-N  ≤_FPT  k-Set-Cover      (W[2]-membership)

(R.164(e): a length-`k` intervention sequence solves `BOUNDED-N` iff `k`
sets cover `R(p)`).  Other parameterizations (`|B(p)|`, `(k,|M|)`, `|R(p)|+k`,
treewidth via Courcelle) are FPT.

**Formalization strategy (HYPOTHESIS-BUNDLE-REDUCTION; R.85 idiom for the
parameterized world).**  We do not build kernels, branching trees, or the
W-hierarchy.  We abstract:

* `Prob` — parameterized decision problems;
* `fptReduces : Prob → Prob → Prop` — the FPT many-one reducibility preorder
  `≤_FPT`, carried with its structural laws (reflexive, transitive) as
  hypotheses where needed;
* `InW2 : Prob → Prop` — membership in W[2];
* `W2Hard P := ∀ Q, InW2 Q → fptReduces Q P` — W[2]-hardness;
* `W2Complete P := InW2 P ∧ W2Hard P`.

The genuine content is twofold and proved honestly from transitivity of
`≤_FPT`:
1. hardness transfer `Q ≤_FPT P, Q W[2]-hard ⟹ P W[2]-hard`;
2. membership transfer `P ≤_FPT Q, Q ∈ W[2] ⟹ P ∈ W[2]` (W[2] closed under
   FPT reductions).
Their conjunction over the two bundled reductions yields W[2]-completeness of
`k-BOUNDED-N`.

**This file is `axiom`-free.**  Imports only `Mathlib`; the two FPT reductions
and W[2]-hardness/closure of k-Set-Cover enter as explicit hypotheses.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace ParameterizedComplexity

-- Opaque type of parameterized decision problems.
variable {Prob : Type*}

-- FPT many-one reducibility `≤_FPT`: `fptReduces Q P` means "Q reduces to P
-- by an FPT many-one reduction preserving the parameter".
variable (fptReduces : Prob → Prob → Prop)

-- Membership in the parameterized class W[2] (opaque).
variable (InW2 : Prob → Prop)

/-- A problem is **W[2]-hard** iff every W[2] problem FPT-reduces to it. -/
def W2Hard (P : Prob) : Prop := ∀ Q, InW2 Q → fptReduces Q P

/-- A problem is **W[2]-complete** iff it is in W[2] and W[2]-hard. -/
def W2Complete (P : Prob) : Prop := InW2 P ∧ W2Hard fptReduces InW2 P

/-- **R.166 core — W[2]-hardness transfers across an FPT reduction.**

If `A ≤_FPT B` and `A` is W[2]-hard, then `B` is W[2]-hard.  (For any
`Q ∈ W[2]`: hardness of `A` gives `Q ≤_FPT A`; compose with `A ≤_FPT B`.)
This is the FPT-world analogue of R.85's hardness transfer and is the content
of "k-Set-Cover `≤_FPT` k-BOUNDED-N makes k-BOUNDED-N W[2]-hard". -/
theorem R_166_hardness_transfer
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    {A B : Prob}
    (hred : fptReduces A B)
    (hA : W2Hard fptReduces InW2 A) :
    W2Hard fptReduces InW2 B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.166 core — W[2]-membership transfers across an FPT reduction.**

W[2] is closed under FPT reductions: if `A ≤_FPT B` and `B ∈ W[2]` then
`A ∈ W[2]`.  This is the content of "k-BOUNDED-N `≤_FPT` k-Set-Cover ∈ W[2]
places k-BOUNDED-N in W[2]"; we carry closure as the hypothesis
`hClosure`. -/
theorem R_166_membership_transfer
    (hClosure : ∀ {A B : Prob}, fptReduces A B → InW2 B → InW2 A)
    {A B : Prob}
    (hred : fptReduces A B)
    (hB : InW2 B) :
    InW2 A :=
  hClosure hred hB

/-- **R.166 — k-BOUNDED-N is W[2]-complete (main theorem).**

Combines the two bundled FPT reductions:
* `hHardRed : kSetCover ≤_FPT kBoundedN` and W[2]-hardness of k-Set-Cover give
  W[2]-hardness of `kBoundedN`;
* `hMemRed : kBoundedN ≤_FPT kSetCover` with k-Set-Cover ∈ W[2] and closure
  give `kBoundedN ∈ W[2]`.

Conclusion: `W2Complete kBoundedN`. -/
theorem R_166_kBoundedN_W2complete
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    (hClosure : ∀ {A B : Prob}, fptReduces A B → InW2 B → InW2 A)
    (kSetCover kBoundedN : Prob)
    (hSC_hard : W2Hard fptReduces InW2 kSetCover)
    (hSC_mem : InW2 kSetCover)
    (hHardRed : fptReduces kSetCover kBoundedN)
    (hMemRed : fptReduces kBoundedN kSetCover) :
    W2Complete fptReduces InW2 kBoundedN := by
  refine ⟨?_, ?_⟩
  · exact R_166_membership_transfer fptReduces InW2 hClosure hMemRed hSC_mem
  · exact R_166_hardness_transfer fptReduces InW2 htrans hHardRed hSC_hard

/-- **R.166 — FPT parameterizations: an FPT problem stays FPT under FPT
reduction.**

For the tractable parameterizations (`|B(p)|`, `(k,|M|)`, treewidth via
Courcelle), the class FPT is also closed under FPT reductions; modelling
membership in FPT by `InFPT`, an FPT reduction into an FPT problem keeps the
source in FPT.  This records the "other rows are FPT" half of R.166's table as
the same closure principle. -/
theorem R_166_FPT_closure
    (InFPT : Prob → Prop)
    (hFPTClosure : ∀ {A B : Prob}, fptReduces A B → InFPT B → InFPT A)
    {A B : Prob}
    (hred : fptReduces A B) (hB : InFPT B) :
    InFPT A :=
  hFPTClosure hred hB

end ParameterizedComplexity

end MIP
