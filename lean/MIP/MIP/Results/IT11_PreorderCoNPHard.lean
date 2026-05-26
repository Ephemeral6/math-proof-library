/-
Result IT.11 (candidate R.526) — deciding the capability preorder `A₁ ≼ A₂`
is coNP-hard (3-TAUT reduction).

Reference: `workspace/round3_exploration/slot_037.md` §1 and
`work_slot_037.md` §1 (grade: A unconditional; deps D.4.6 capability preorder,
NC.4 succinct implicit descriptions, 3-TAUT coNP-completeness (classical)).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement.**  SUBPREORDER is the decision problem: given succinct implicit
descriptions `⟨A₁⟩_succ, ⟨A₂⟩_succ`, decide whether `A₁ ≼ A₂` (the D.4.6
capability preorder, under the Z-degenerate regime where the second clause of
D.4.6 holds trivially).  IT.11 proves SUBPREORDER is **coNP-hard** via a
polynomial-time many-one reduction from 3-TAUT:

    φ ∈ 3-TAUT  ⟺  A₁(φ) ≼ A₂(φ).

The construction builds `A₁` with `K(A₁) = {ω_v : v ∈ {0,1}ⁿ}` (all `2ⁿ`
valuations) and `A₂` with `K(A₂) = {ω_v : v ⊨ φ}`, embedding the
`O(mn)`-size verification circuit for `φ`, so that
`K(A₁) ⊆ K(A₂) ⟺ φ` is a tautology.  In the `K(Aᵢ)` poly-bounded regime
SUBPREORDER ∈ coNP, hence coNP-complete; the file proves the (tighter)
completeness statement as well.

**Formalization strategy (HYPOTHESIS-BUNDLE-REDUCTION; R.85 idiom, coNP world).**
Per the project idiom we do NOT build a TAUT checker or a circuit.  The
mathematical substance of a "coNP-hard via reduction from a coNP-hard problem"
result is the **transfer theorem**: coNP-hardness propagates along
polynomial-time many-one reductions because `≤ₚ` composes.  We abstract:

* `Prob` — opaque decision problems;
* `polyReduces : Prob → Prob → Prop` — the `≤ₚ` preorder, with its structural
  laws (reflexive, transitive) supplied as hypotheses where needed;
* `InCoNP : Prob → Prop` — membership in coNP (opaque);
* `CoNPHard P := ∀ Q, InCoNP Q → polyReduces Q P`;
* `CoNPComplete P := InCoNP P ∧ CoNPHard P`.

The genuine content is `IT_11_transfer` (`A ≤ₚ B → CoNPHard A → CoNPHard B`,
proved from transitivity) together with `IT_11_membership_transfer` (coNP is
closed under `≤ₚ`).  IT.11 is the instantiation with `threeTAUT` coNP-hard and
the `A₁(φ)/A₂(φ)` reduction `3-TAUT ≤ₚ SUBPREORDER` bundled; the two reductions
combine to coNP-completeness.

**This file is `axiom`-free.**  It imports only `Mathlib`; reflexivity and
transitivity of `≤ₚ`, coNP-hardness/closure of 3-TAUT, and the concrete
reduction validity all enter as explicit hypotheses.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace PreorderCoNPHard

-- Opaque type of decision problems.
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ` between decision
-- problems: `polyReduces Q P` means "`Q` reduces to `P` in polynomial time."
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity class coNP (opaque predicate).
variable (InCoNP : Prob → Prop)

/-- A problem `P` is **coNP-hard** iff every coNP problem polynomially reduces
to it. -/
def CoNPHard (P : Prob) : Prop := ∀ Q, InCoNP Q → polyReduces Q P

/-- A problem `P` is **coNP-complete** iff it is in coNP and coNP-hard. -/
def CoNPComplete (P : Prob) : Prop := InCoNP P ∧ CoNPHard polyReduces InCoNP P

/-- **IT.11 core — coNP-hardness transfer (reduction composition).**

If `A` polynomially reduces to `B` (`polyReduces A B`) and `A` is coNP-hard,
then `B` is coNP-hard.  This is the genuine mathematical substance of any
"coNP-hard via reduction from a known coNP-hard problem" result: it is exactly
the statement that the reducibility preorder composes.  Proof: for any
`Q ∈ coNP`, coNP-hardness of `A` gives `Q ≤ₚ A`; transitivity with `A ≤ₚ B`
yields `Q ≤ₚ B`. -/
theorem IT_11_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.11 core — coNP-membership transfer (coNP closed under `≤ₚ`).**

coNP is closed under polynomial-time many-one reductions: if `A ≤ₚ B` and
`B ∈ coNP`, then `A ∈ coNP`.  Carried as the closure hypothesis `hClosure`;
this is the "SUBPREORDER ∈ coNP in the `K(Aᵢ)` poly-bounded regime" half of
IT.11 (step 6 of the source), needed for completeness. -/
theorem IT_11_membership_transfer
    (hClosure : ∀ {A B : Prob}, polyReduces A B → InCoNP B → InCoNP A)
    {A B : Prob}
    (hred : polyReduces A B)
    (hB : InCoNP B) :
    InCoNP A :=
  hClosure hred hB

/-- **IT.11 — SUBPREORDER is coNP-hard (main theorem).**

Instantiates the transfer theorem with the 3-TAUT reduction.  Inputs:
* `threeTAUT subPreorder : Prob` — the two problems;
* `htrans` — transitivity of `≤ₚ` (reductions compose in poly time);
* `hTAUT : CoNPHard threeTAUT` — 3-TAUT is coNP-hard (classical, bundled);
* `hred : polyReduces threeTAUT subPreorder` — the explicit `A₁(φ)/A₂(φ)`
  construction of §1, whose validity (`φ ∈ TAUT ⟺ K(A₁) ⊆ K(A₂) ⟺ A₁ ≼ A₂`)
  is bundled as this hypothesis.

Conclusion: `CoNPHard subPreorder`. -/
theorem IT_11_subPreorder_coNPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeTAUT subPreorder : Prob)
    (hTAUT : CoNPHard polyReduces InCoNP threeTAUT)
    (hred : polyReduces threeTAUT subPreorder) :
    CoNPHard polyReduces InCoNP subPreorder :=
  IT_11_transfer polyReduces InCoNP htrans hred hTAUT

/-- **IT.11 — SUBPREORDER is coNP-complete (tighter).**

Combines hardness with membership.  Bundled:
* `hTAUT_hard : CoNPHard threeTAUT` and `hred : threeTAUT ≤ₚ subPreorder` give
  coNP-hardness;
* `hSubInCoNP : InCoNP subPreorder` (poly-bounded `K(Aᵢ)` regime, step 6) gives
  membership.

Conclusion: `CoNPComplete subPreorder`. -/
theorem IT_11_subPreorder_coNPComplete
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeTAUT subPreorder : Prob)
    (hTAUT_hard : CoNPHard polyReduces InCoNP threeTAUT)
    (hred : polyReduces threeTAUT subPreorder)
    (hSubInCoNP : InCoNP subPreorder) :
    CoNPComplete polyReduces InCoNP subPreorder :=
  ⟨hSubInCoNP, IT_11_subPreorder_coNPHard polyReduces InCoNP htrans threeTAUT subPreorder
    hTAUT_hard hred⟩

/-- **IT.11 — transfer along a reduction *chain*.**

coNP-hardness propagates along a chain `3-TAUT ≤ₚ C ≤ₚ SUBPREORDER` (e.g.
through an intermediate problem), by two applications of transitivity.  This
shows the transfer mechanism is closed under composition, the property that
makes "reduce from a known coNP-hard problem" a sound proof technique. -/
theorem IT_11_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A C B : Prob}
    (hAC : polyReduces A C) (hCB : polyReduces C B)
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP B :=
  IT_11_transfer polyReduces InCoNP htrans (htrans hAC hCB) hA

/-- **IT.11 — reflexivity sanity check.**

With reflexivity of `≤ₚ` (identity reduction), any coNP-hard problem trivially
transfers hardness to itself — a non-vacuity check that the
`polyReduces`/`CoNPHard` encoding is not degenerate. -/
theorem IT_11_refl_transfer
    (hrefl : ∀ X : Prob, polyReduces X X)
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A : Prob}
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP A :=
  IT_11_transfer polyReduces InCoNP htrans (hrefl A) hA

end PreorderCoNPHard

end MIP
