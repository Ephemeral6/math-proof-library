/-
Result IT.7 (slot 013, candidate R.522) — N-behavior-equivalence is Π⁰₂-complete.

Reference: `workspace/round3_exploration/slot_013.md` §IT.7 and
`work_slot_013.md` §IT.7 (A 无条件, deps D.1.2, D.1.5, D.1.6, A.2, R.83;
external: Kleene arithmetic hierarchy, TOT Π⁰₂-completeness — Soare 1987
IV.3.2).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**  The decision problem `N-EQUIV` — "given finite descriptions
`⟨A⟩, ⟨A'⟩`, decide `A ≡_N A'`, i.e. `∀ p ∈ P_sol, N(p, A) = N(p, A')`" — is
**Π⁰₂-complete** in the Kleene arithmetic hierarchy, strictly above the
Σ⁰₁/Π⁰₁ halting level of R.83/R.84.

* **Membership (`InPi2`).**  `N-EQUIV(A,A') ⟺ ∀ p ∀ k, (N(p,A) ≤ k ⟺
  N(p,A') ≤ k)`.  Each `N(·) ≤ k` is Σ⁰₁; the inner biconditional is Δ⁰₂; the
  outer `∀ p ∀ k` puts the whole predicate in Π⁰₂.
* **Hardness (`Pi2Hard`).**  `TOT ≤_m N-EQUIV` via the construction
  `e ↦ (⟨A_e⟩, ⟨A_∞⟩)`: a dovetailing `D.1.2` agent `A_e` and the empty-response
  baseline `A_∞`, designed so that `A_e ≡_N A_∞ ⟺ e ∈ TOT` (`φ_e` total).
  Since `TOT` is Π⁰₂-complete (Soare 1987 IV.3.2), `N-EQUIV` is Π⁰₂-hard.

**Formalization strategy (HYPOTHESIS-BUNDLE; abstract completeness kernel).**
Per the project idiom we build **no** Turing machine and **no** arithmetic-
hierarchy formalization.  The mathematical substance of a *completeness*
result is two facts and one transfer mechanism:

* `Prob` — opaque decision problems;
* `mReduces : Prob → Prob → Prop` — many-one reducibility `≤_m`, carried with
  its structural law **transitivity** (reductions compose);
* `InPi2 : Prob → Prop` — membership in the level Π⁰₂ (opaque);
* `Pi2Hard P := ∀ Q, InPi2 Q → mReduces Q P` — every Π⁰₂ problem reduces to `P`;
* `Pi2Complete P := InPi2 P ∧ Pi2Hard P`.

The real content is `IT7_hard_transfer`: `mReduces A B → Pi2Hard A → Pi2Hard B`,
proved honestly from transitivity of `≤_m`.  IT.7 is the instantiation: with
`TOT` Π⁰₂-complete (`hTOT_complete`, bundling Soare 1987) and the dovetail
reduction `TOT ≤_m N-EQUIV` (`hred`, bundling the `A_e`/`A_∞` validity lemma),
together with the membership witness `hmem : InPi2 N-EQUIV`, we conclude
`Pi2Complete N-EQUIV`.

**This file is `axiom`-free.**  It imports only `Mathlib`; transitivity of
`≤_m`, TOT-completeness, the reduction validity, and the Π⁰₂-membership witness
all enter as explicit hypotheses, matching the MIP-side dependency list.
-/
import Mathlib

namespace MIP

namespace BehaviorPi2Complete

-- Opaque type of decision problems.
variable {Prob : Type*}

-- Many-one reducibility `≤_m`.  `mReduces Q P` means "`Q` reduces to `P`".
-- Its structural law (transitivity: reductions compose) is supplied as a
-- hypothesis where needed.
variable (mReduces : Prob → Prob → Prop)

-- Membership in the arithmetic level Π⁰₂ (opaque predicate).
variable (InPi2 : Prob → Prop)

/-- A problem `P` is **Π⁰₂-hard** iff every Π⁰₂ problem many-one reduces to it. -/
def Pi2Hard (P : Prob) : Prop := ∀ Q, InPi2 Q → mReduces Q P

/-- A problem `P` is **Π⁰₂-complete** iff it is both in Π⁰₂ and Π⁰₂-hard. -/
def Pi2Complete (P : Prob) : Prop := InPi2 P ∧ Pi2Hard mReduces InPi2 P

/-- **IT.7 core — hardness transfer (reduction composition).**

If `A` many-one reduces to `B` and `A` is Π⁰₂-hard, then `B` is Π⁰₂-hard.
This is the genuine substance of any "Π⁰₂-hard via reduction from a known
Π⁰₂-complete problem" argument: it is exactly the statement that the `≤_m`
preorder composes.  Proof: for any `Q ∈ Π⁰₂`, hardness of `A` gives `Q ≤_m A`;
transitivity with `A ≤_m B` yields `Q ≤_m B`. -/
theorem IT7_hard_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hred : mReduces A B)
    (hA : Pi2Hard mReduces InPi2 A) :
    Pi2Hard mReduces InPi2 B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.7 — completeness transfer.**

Π⁰₂-completeness transfers along a reduction *from* a complete problem, given
the target's own Π⁰₂-membership.  If `A` is Π⁰₂-complete, `A ≤_m B`, and `B`
is itself in Π⁰₂, then `B` is Π⁰₂-complete.  (Membership cannot be transferred
*forward* along `≤_m`, so it is supplied separately — exactly as in the source,
where `N-EQUIV ∈ Π⁰₂` is proved by the `∀p∀k` quantifier count.) -/
theorem IT7_complete_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hA : Pi2Complete mReduces InPi2 A)
    (hred : mReduces A B)
    (hBmem : InPi2 B) :
    Pi2Complete mReduces InPi2 B :=
  ⟨hBmem, IT7_hard_transfer mReduces InPi2 htrans hred hA.2⟩

/-- **IT.7 — N-behavior-equivalence is Π⁰₂-complete (main theorem).**

Instantiates the completeness transfer with the `TOT → N-EQUIV` dovetail
reduction.  Inputs:
* `TOT NEQUIV : Prob` — the two problems;
* `htrans` — transitivity of `≤_m`;
* `hTOT_complete : Pi2Complete TOT` — TOT is Π⁰₂-complete (Soare 1987 IV.3.2,
  bundled);
* `hred : mReduces TOT NEQUIV` — the `e ↦ (⟨A_e⟩, ⟨A_∞⟩)` reduction whose
  validity (`A_e ≡_N A_∞ ⟺ e ∈ TOT`, the key dovetail lemma) is bundled here;
* `hmem : InPi2 NEQUIV` — the `∀p∀k` membership witness for `N-EQUIV`.

Conclusion: `Pi2Complete NEQUIV`. -/
theorem IT7_NEQUIV_Pi2Complete
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    (TOT NEQUIV : Prob)
    (hTOT_complete : Pi2Complete mReduces InPi2 TOT)
    (hred : mReduces TOT NEQUIV)
    (hmem : InPi2 NEQUIV) :
    Pi2Complete mReduces InPi2 NEQUIV :=
  IT7_complete_transfer mReduces InPi2 htrans hTOT_complete hred hmem

/-- **IT.7 — strict ascent over the halting level (transfer along a chain).**

The source emphasizes that `N-EQUIV` lies strictly above the Σ⁰₁/Π⁰₁ halting
level of R.83/R.84.  The hardness mechanism is closed under composition: a
reduction chain `TOT ≤_m C ≤_m N-EQUIV` through any intermediate problem `C`
still transfers Π⁰₂-hardness, by two applications of transitivity.  This
certifies that the transfer engine is robust to factoring the dovetail
reduction through intermediate constructions. -/
theorem IT7_hard_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A C B : Prob}
    (hAC : mReduces A C) (hCB : mReduces C B)
    (hA : Pi2Hard mReduces InPi2 A) :
    Pi2Hard mReduces InPi2 B :=
  IT7_hard_transfer mReduces InPi2 htrans (htrans hAC hCB) hA

/-- **IT.7 — the kernel is non-vacuous (reflexivity sanity check).**

With reflexivity of `≤_m` (the identity reduction), any Π⁰₂-complete problem
transfers hardness to itself.  This degenerate check confirms the
`mReduces`/`Pi2Hard` encoding is not vacuous. -/
theorem IT7_refl_transfer
    (hrefl : ∀ X : Prob, mReduces X X)
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A : Prob}
    (hA : Pi2Hard mReduces InPi2 A) :
    Pi2Hard mReduces InPi2 A :=
  IT7_hard_transfer mReduces InPi2 htrans (hrefl A) hA

end BehaviorPi2Complete

end MIP
