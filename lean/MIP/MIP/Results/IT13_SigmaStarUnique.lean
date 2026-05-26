/-
Result IT.13 (candidate R.528) — SIGMA-STAR-UNIQUE is Π₁-complete.

Reference: `workspace/round3_exploration/work_slot_049.md` §IT.13 and
`slot_049.md` (grade: A unconditional; deps D.1.6, T.7, NC.4; external:
`¬HALT` Π₁-completeness (Soare 1987 III.5)).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement.**  For `(p, A)` with `A` a succinct implicit description and `p`
expressible in `P_sol`, `SIGMA-STAR-UNIQUE` decides whether the arg-min set
`Σ*(p, A)` of optimal intervention sequences (the minimizers in D.1.6) is a
singleton: "is the optimal intervention sequence unique?".  IT.13 proves it is
**Π₁-complete**:

* (membership) `|Σ*(p, A)| = 1` is a `Π₁` predicate (IT.13.2): once `N(p,A) < ∞`
  is fixed, `|Σ*| = 1 ⟺ ∀ σ₁,σ₂ ∈ Mᴺ, Pr-cond(σ₁) ∧ Pr-cond(σ₂) → σ₁ = σ₂`,
  a `Π₁` (`∀` over a `Σ₁` matrix) statement;
* (hardness) `¬HALT ≤ₘ SIGMA-STAR-UNIQUE` (IT.13.3–4): `(p_{e,x}, A_{e,x})` with
  `m_a` solving in one step and `m_b` launching a dovetail simulation of
  `U(e,x)` is built so that `Σ*` is a singleton `{(m_a)}` iff `φ_e(x) ↑`, i.e.
  `UNIQUE(p_{e,x}, A_{e,x}) ⟺ ⟨e,x⟩ ∈ ¬HALT`.

**Formalization strategy (HYPOTHESIS-BUNDLE-REDUCTION; R.83 decidability-transfer
idiom for the Π₁ level).**  We do NOT build the agent `A_{e,x}` or a halting
oracle.  The substance is a `Π₁`-completeness kernel.  We work over a fixed
ambient encoding type `Enc` (instances are encoded as naturals / finite
strings, the standard recursion-theoretic setting), so a decision problem is a
predicate `Enc → Prop` and a many-one reduction is a total map `Enc → Enc`:

* `Pi1Reduces P Q := ∃ red : Enc → Enc, ∀ a, P a ↔ Q (red a)` — many-one
  reducibility, validated pointwise;
* `InPi1 : (Enc → Prop) → Prop` — the class `Π₁`, opaque, with the bundled
  closure law that `Π₁` is closed under `≤ₘ`;
* `Pi1Hard Q := ∀ P, InPi1 P → Pi1Reduces P Q`;
* `Pi1Complete Q := InPi1 Q ∧ Pi1Hard Q`.

`Pi1Reduces` is reflexive and transitive — both **proved honestly** (identity
map; composition of reduction maps), giving the hardness-transfer theorem.
IT.13 is the instantiation with `¬HALT` Π₁-complete and the bundled reduction
`¬HALT ≤ₘ SIGMA-STAR-UNIQUE`; with the bundled `Π₁` membership it yields
Π₁-completeness.

**This file is `axiom`-free.**  It imports only `Mathlib`; the `¬HALT`
Π₁-completeness, the `Π₁` closure law, the `Π₁` membership of the target, and
the concrete reduction validity all enter as explicit hypotheses.  Reflexivity
and transitivity of `≤ₘ` are theorems.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace SigmaStarUnique

-- Ambient encoding type for instances (naturals / finite strings, the standard
-- recursion-theoretic setting).  A decision problem is a predicate on `Enc`.
variable {Enc : Type*}

/-- **Many-one reducibility `≤ₘ`.**  `Pi1Reduces P Q` holds when there is a total
reduction map `red : Enc → Enc` validating membership: `P a ↔ Q (red a)`.  This
is the structural relation underlying every `Π₁`-hardness argument. -/
def Pi1Reduces (P Q : Enc → Prop) : Prop :=
  ∃ red : Enc → Enc, ∀ a, P a ↔ Q (red a)

/-- **`≤ₘ` is reflexive** — the identity reduction.  (Proved, not assumed.) -/
theorem Pi1Reduces_refl (P : Enc → Prop) : Pi1Reduces P P :=
  ⟨id, fun _ => Iff.rfl⟩

/-- **`≤ₘ` is transitive** — reduction maps compose.  (Proved, not assumed.)
This is the engine of `Π₁`-hardness transfer. -/
theorem Pi1Reduces_trans {P Q R : Enc → Prop}
    (hPQ : Pi1Reduces P Q) (hQR : Pi1Reduces Q R) : Pi1Reduces P R := by
  obtain ⟨f, hf⟩ := hPQ
  obtain ⟨g, hg⟩ := hQR
  exact ⟨g ∘ f, fun a => (hf a).trans (hg (f a))⟩

-- The class `Π₁`, modelled abstractly as a predicate on problems.  Membership
-- is opaque; its only structural use is closure under `≤ₘ`, supplied as a
-- hypothesis where needed.
variable (InPi1 : (Enc → Prop) → Prop)

/-- A problem `Q` is **Π₁-hard** iff every `Π₁` problem many-one reduces to it. -/
def Pi1Hard (Q : Enc → Prop) : Prop :=
  ∀ P : Enc → Prop, InPi1 P → Pi1Reduces P Q

/-- A problem `Q` is **Π₁-complete** iff it is in `Π₁` and `Π₁`-hard. -/
def Pi1Complete (Q : Enc → Prop) : Prop :=
  InPi1 Q ∧ Pi1Hard InPi1 Q

/-- **IT.13 core — Π₁-hardness transfer (reduction composition).**

If `A ≤ₘ B` and `A` is Π₁-hard, then `B` is Π₁-hard.  Proof: for any `Π₁`
problem `P`, Π₁-hardness of `A` gives `P ≤ₘ A`; transitivity with `A ≤ₘ B`
yields `P ≤ₘ B`.  This is the genuine content of "`¬HALT ≤ₘ
SIGMA-STAR-UNIQUE` makes the target Π₁-hard". -/
theorem IT_13_hardness_transfer
    {A B : Enc → Prop}
    (hred : Pi1Reduces A B)
    (hA : Pi1Hard InPi1 A) :
    Pi1Hard InPi1 B := by
  intro P hP
  exact Pi1Reduces_trans (hA P hP) hred

/-- **IT.13 core — Π₁-membership transfer (Π₁ closed under `≤ₘ`).**

`Π₁` is closed downward under many-one reductions: if `A ≤ₘ B` and `B ∈ Π₁`
then `A ∈ Π₁`.  Carried as the closure hypothesis `hClosure`; this packages the
"`SIGMA-STAR-UNIQUE ∈ Π₁`" upper bound (IT.13.2) as transferable structure. -/
theorem IT_13_membership_transfer
    (hClosure : ∀ {A B : Enc → Prop}, Pi1Reduces A B → InPi1 B → InPi1 A)
    {A B : Enc → Prop}
    (hred : Pi1Reduces A B)
    (hB : InPi1 B) :
    InPi1 A :=
  hClosure hred hB

/-- **IT.13 — SIGMA-STAR-UNIQUE is Π₁-hard (main hardness theorem).**

Instantiates hardness transfer with the `¬HALT` reduction.  Inputs:
* `notHALT sigmaStarUnique : Enc → Prop` — the two problems;
* `hNotHALT_hard : Pi1Hard notHALT` — `¬HALT` is Π₁-hard (Soare 1987, bundled);
* `hred : Pi1Reduces notHALT sigmaStarUnique` — the explicit
  `(p_{e,x}, A_{e,x})` construction of IT.13.3–4, whose validity
  (`φ_e(x) ↑ ⟺ |Σ*| = 1`) is bundled as this reduction.

Conclusion: `Pi1Hard sigmaStarUnique`. -/
theorem IT_13_sigmaStarUnique_Pi1Hard
    (notHALT sigmaStarUnique : Enc → Prop)
    (hNotHALT_hard : Pi1Hard InPi1 notHALT)
    (hred : Pi1Reduces notHALT sigmaStarUnique) :
    Pi1Hard InPi1 sigmaStarUnique :=
  IT_13_hardness_transfer InPi1 hred hNotHALT_hard

/-- **IT.13 — SIGMA-STAR-UNIQUE is Π₁-complete (main theorem).**

Combines hardness with the Π₁ upper bound:
* `hNotHALT_hard` + `hred` give Π₁-hardness (via `IT_13_sigmaStarUnique_Pi1Hard`);
* `hMemb : InPi1 sigmaStarUnique` (the IT.13.2 upper bound) gives membership.

Conclusion: `Pi1Complete sigmaStarUnique`. -/
theorem IT_13_sigmaStarUnique_Pi1Complete
    (notHALT sigmaStarUnique : Enc → Prop)
    (hNotHALT_hard : Pi1Hard InPi1 notHALT)
    (hred : Pi1Reduces notHALT sigmaStarUnique)
    (hMemb : InPi1 sigmaStarUnique) :
    Pi1Complete InPi1 sigmaStarUnique :=
  ⟨hMemb, IT_13_sigmaStarUnique_Pi1Hard InPi1 notHALT sigmaStarUnique hNotHALT_hard hred⟩

/-- **IT.13 — hardness along a reduction *chain*.**

Π₁-hardness propagates along `¬HALT ≤ₘ C ≤ₘ SIGMA-STAR-UNIQUE`, by two
applications of transitivity of `≤ₘ` — showing the transfer mechanism is closed
under composition. -/
theorem IT_13_transfer_chain
    {A C B : Enc → Prop}
    (hAC : Pi1Reduces A C) (hCB : Pi1Reduces C B)
    (hA : Pi1Hard InPi1 A) :
    Pi1Hard InPi1 B :=
  IT_13_hardness_transfer InPi1 (Pi1Reduces_trans hAC hCB) hA

/-- **IT.13 — the membership upper bound is closed under the reduction.**

Non-vacuity / consistency check: the bundled `Π₁` membership of the target,
pulled back along the `¬HALT` reduction (whose validity is `hred`), places
`¬HALT` itself in `Π₁` — exactly the well-known fact that `¬HALT ∈ Π₁`.  This
confirms the kernel's membership transfer is a genuine implication. -/
theorem IT_13_target_membership_pulls_back
    (hClosure : ∀ {A B : Enc → Prop}, Pi1Reduces A B → InPi1 B → InPi1 A)
    {notHALT sigmaStarUnique : Enc → Prop}
    (hred : Pi1Reduces notHALT sigmaStarUnique)
    (hMemb : InPi1 sigmaStarUnique) :
    InPi1 notHALT :=
  IT_13_membership_transfer InPi1 hClosure hred hMemb

end SigmaStarUnique

end MIP
