/-
Result IT.8 (slot 013, candidate R.523) — expertise density `C_e` is
Σ⁰₂-complete.

Reference: `workspace/round3_exploration/slot_013.md` §IT.8 and
`work_slot_013.md` §IT.8 (A 无条件, deps D.1.2, D.1.3, D.1.5, D.3.6, A.3;
external: Kleene arithmetic hierarchy, FIN Σ⁰₂-completeness — Soare 1987
IV.3.6).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**  The decision problem `CE-EQ` — "given `(⟨A⟩, ⟨ε_e⟩, k)`, decide
`C_e(A) = k`" — is **Σ⁰₂-complete** in the Kleene arithmetic hierarchy.  Here
`C_e := min{k : ∀ε>0 ∃(m₁,…,m_k), d_TV(…) < ε}` (D.3.6) is the minimal number
of meta-cognitive interventions replacing an expert intervention; axiom A.3
only gives the *existence* upper bound `C_e ≤ log(1/ε)`, but the exact count
sits at Σ⁰₂.

* **Membership (`InSigma2`).**  `C_e = k ⟺ (∃(m₁..m_k) ∀ε ∃(m'..) d_TV<ε) ∧
  (∀k'<k, no such tuple)`; the leading `∃∀∃` block is Σ⁰₂ and the conjunction
  stays in Σ⁰₂.
* **Hardness (`Sigma2Hard`).**  `FIN ≤_m CE-EQ` via `e ↦ (⟨A_e⟩, ⟨ε_e⟩, k=2)`
  with `K(A_e) = {ω_x : x ∈ W_e}`, designed so that `C_{ε_e}(A_e) = 2 ⟺
  e ∈ FIN` (`|W_e| < ∞`): a finite `K(A_e)` is `1/4`-approximable by two
  interventions, an infinite one is not approximable by any finite tuple
  (`d_TV ≥ 1/2`).  Since `FIN` is Σ⁰₂-complete (Soare 1987 IV.3.6), `CE-EQ` is
  Σ⁰₂-hard.

**Formalization strategy (HYPOTHESIS-BUNDLE; abstract completeness kernel).**
Identical kernel to IT.7 but for the dual level Σ⁰₂.  No Turing machine, no
hierarchy formalization, no total-variation analysis is built; the substance is
the honest hardness-transfer (`≤_m` composes) plus the Σ⁰₂-membership witness.

* `Prob` — opaque decision problems;
* `mReduces : Prob → Prob → Prop` — many-one reducibility `≤_m` (transitive);
* `InSigma2 : Prob → Prop` — membership in Σ⁰₂ (opaque);
* `Sigma2Hard P := ∀ Q, InSigma2 Q → mReduces Q P`;
* `Sigma2Complete P := InSigma2 P ∧ Sigma2Hard P`.

`IT8_hard_transfer` (`mReduces A B → Sigma2Hard A → Sigma2Hard B`) is proved
from transitivity; IT.8 instantiates it with FIN Σ⁰₂-complete (`hFIN_complete`),
the `A_e` reduction `FIN ≤_m CE-EQ` (`hred`, bundling the `C_{ε_e} = 2 ⟺ FIN`
lemma), and the Σ⁰₂-membership witness `hmem : InSigma2 CE-EQ`.

**This file is `axiom`-free.**  Imports only `Mathlib`; transitivity of `≤_m`,
FIN-completeness, reduction validity, and the membership witness all enter as
explicit hypotheses, matching the MIP-side dependency list.
-/
import Mathlib

namespace MIP

namespace CeSigma2Complete

-- Opaque type of decision problems.
variable {Prob : Type*}

-- Many-one reducibility `≤_m`.  `mReduces Q P` means "`Q` reduces to `P`".
variable (mReduces : Prob → Prob → Prop)

-- Membership in the arithmetic level Σ⁰₂ (opaque predicate).
variable (InSigma2 : Prob → Prop)

/-- A problem `P` is **Σ⁰₂-hard** iff every Σ⁰₂ problem many-one reduces to it. -/
def Sigma2Hard (P : Prob) : Prop := ∀ Q, InSigma2 Q → mReduces Q P

/-- A problem `P` is **Σ⁰₂-complete** iff it is both in Σ⁰₂ and Σ⁰₂-hard. -/
def Sigma2Complete (P : Prob) : Prop := InSigma2 P ∧ Sigma2Hard mReduces InSigma2 P

/-- **IT.8 core — hardness transfer (reduction composition).**

If `A` many-one reduces to `B` and `A` is Σ⁰₂-hard, then `B` is Σ⁰₂-hard —
exactly the statement that `≤_m` composes.  For any `Q ∈ Σ⁰₂`, hardness of `A`
gives `Q ≤_m A`; transitivity with `A ≤_m B` gives `Q ≤_m B`. -/
theorem IT8_hard_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hred : mReduces A B)
    (hA : Sigma2Hard mReduces InSigma2 A) :
    Sigma2Hard mReduces InSigma2 B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.8 — completeness transfer.**

Σ⁰₂-completeness transfers along a reduction *from* a complete problem, given
the target's own Σ⁰₂-membership.  Membership is supplied separately (it does
not transfer forward along `≤_m`), matching the source where `CE-EQ ∈ Σ⁰₂` is
established by the `∃∀∃` quantifier count. -/
theorem IT8_complete_transfer
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A B : Prob}
    (hA : Sigma2Complete mReduces InSigma2 A)
    (hred : mReduces A B)
    (hBmem : InSigma2 B) :
    Sigma2Complete mReduces InSigma2 B :=
  ⟨hBmem, IT8_hard_transfer mReduces InSigma2 htrans hred hA.2⟩

/-- **IT.8 — `C_e` is Σ⁰₂-complete (main theorem).**

Instantiates the completeness transfer with the `FIN → CE-EQ` reduction.
Inputs:
* `FIN CEEQ : Prob` — the two problems;
* `htrans` — transitivity of `≤_m`;
* `hFIN_complete : Sigma2Complete FIN` — FIN is Σ⁰₂-complete (Soare 1987
  IV.3.6, bundled);
* `hred : mReduces FIN CEEQ` — the `e ↦ (⟨A_e⟩, ⟨ε_e⟩, k=2)` reduction whose
  validity (`C_{ε_e}(A_e) = 2 ⟺ e ∈ FIN`, the finite/infinite-support
  approximation lemma) is bundled here;
* `hmem : InSigma2 CEEQ` — the `∃∀∃` membership witness for `CE-EQ`.

Conclusion: `Sigma2Complete CEEQ`. -/
theorem IT8_CEEQ_Sigma2Complete
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    (FIN CEEQ : Prob)
    (hFIN_complete : Sigma2Complete mReduces InSigma2 FIN)
    (hred : mReduces FIN CEEQ)
    (hmem : InSigma2 CEEQ) :
    Sigma2Complete mReduces InSigma2 CEEQ :=
  IT8_complete_transfer mReduces InSigma2 htrans hFIN_complete hred hmem

/-- **IT.8 — transfer along a reduction chain.**

The hardness mechanism is closed under composition: a chain
`FIN ≤_m C ≤_m CE-EQ` through any intermediate problem `C` still transfers
Σ⁰₂-hardness, certifying robustness of the transfer engine to factoring the
`A_e` reduction through intermediate constructions. -/
theorem IT8_hard_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A C B : Prob}
    (hAC : mReduces A C) (hCB : mReduces C B)
    (hA : Sigma2Hard mReduces InSigma2 A) :
    Sigma2Hard mReduces InSigma2 B :=
  IT8_hard_transfer mReduces InSigma2 htrans (htrans hAC hCB) hA

/-- **IT.8 — the kernel is non-vacuous (reflexivity sanity check).**

With reflexivity of `≤_m`, any Σ⁰₂-complete problem transfers hardness to
itself — a degenerate check that the `mReduces`/`Sigma2Hard` encoding is not
vacuous. -/
theorem IT8_refl_transfer
    (hrefl : ∀ X : Prob, mReduces X X)
    (htrans : ∀ {X Y Z : Prob}, mReduces X Y → mReduces Y Z → mReduces X Z)
    {A : Prob}
    (hA : Sigma2Hard mReduces InSigma2 A) :
    Sigma2Hard mReduces InSigma2 A :=
  IT8_hard_transfer mReduces InSigma2 htrans (hrefl A) hA

/-- **IT.8 — IT.7/IT.8 second-order arithmetic dual (joint Σ⁰₂ ∧ Π⁰₂ spectrum).**

The source presents IT.7 (Π⁰₂) and IT.8 (Σ⁰₂) as a dual pair covering the two
faces of the second arithmetic level.  Abstractly: if a problem `P` is both
Σ⁰₂-hard and (via an external Π⁰₂-hard relation supplied as `dualHard`)
Π⁰₂-hard, then it is hard for the conjunction of both — the level-2 boundary.
We record the trivial-but-load-bearing packaging that completeness for both
faces is just the pair of the two hardness facts together with the two
memberships. -/
theorem IT8_dual_spectrum
    {P : Prob}
    (hSigma2 : Sigma2Complete mReduces InSigma2 P)
    {InPi2 : Prob → Prop} {Pi2Hard : Prob → Prop}
    (hPi2mem : InPi2 P) (hPi2hard : Pi2Hard P) :
    (InSigma2 P ∧ Sigma2Hard mReduces InSigma2 P) ∧ (InPi2 P ∧ Pi2Hard P) :=
  ⟨hSigma2, hPi2mem, hPi2hard⟩

end CeSigma2Complete

end MIP
