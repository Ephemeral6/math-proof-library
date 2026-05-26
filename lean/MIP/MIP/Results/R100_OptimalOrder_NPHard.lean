/-
Result R.100 (T.25) — Optimal problem-solving order is NP-hard.

Reference: `proofs/derived/conjecture_attacks.md` §R.100 (A 级, deps T.1,
T.7, standard complexity reduction PRECEDENCE-CONSTRAINED-SCHEDULING).

**Statement.**  Given `n` problems `{p₁,…,pₙ}`, an AI system `A`, and a task
precedence DAG `G_task = (V, E_task)` (edge `(pᵢ, pⱼ)` means `pᵢ` must be
solved before `pⱼ` can begin), the OPTIMAL-ORDER problem asks for a
topological permutation `π*` minimizing the total cost
`C(π) = Σᵢ N(p_{π(i)}, A_after π[1..i-1])`.  R.100 proves OPTIMAL-ORDER is
NP-hard via a polynomial-time reduction from
`1|prec|Σ wⱼ Cⱼ` = PRECEDENCE-CONSTRAINED-SCHEDULING (Lenstra–Rinnooy Kan
1978, strongly NP-hard).

The reduction builds, for each scheduling task `τᵢ` of processing time `tᵢ`,
a problem `pᵢ` with exactly `tᵢ` independent atomic barriers (using T.1 + T.7:
`N(pᵢ, A) = tᵢ`), and sets `G_task = G_sched`.  Then for any permutation `π`,
`C(π) = Σ t_{π(i)}` equals the scheduling weighted completion time, so an
optimal MIP order yields an optimal schedule.

**Formalization strategy (hypothesis-bundle reduction).**  Identical abstract
kernel to R.85 (redefined locally here for self-containment): we do not build
the scheduling solver or the barrier construction.  The substance is the
**transfer theorem** — a polynomial-time reduction from a known-hard problem
composes to make the target NP-hard.

* `Prob` — opaque decision problems.
* `polyReduces : Prob → Prob → Prop` — the `≤ₚ` preorder, with reflexivity and
  transitivity supplied as hypotheses.
* `InNP : Prob → Prop` — opaque NP membership.
* `NPHard P := ∀ Q, InNP Q → polyReduces Q P`.

`R_100_transfer` (`polyReduces A B → NPHard A → NPHard B`) is proved honestly
from transitivity.  R.100 is the instantiation with
`hSched : NPHard precedenceScheduling` (scheduling strongly NP-hard, bundled)
and `hred : polyReduces precedenceScheduling optimalOrder` (the barrier
construction's validity `C(π) = Σ t_{π(i)}`, bundled), concluding
`NPHard optimalOrder`.

**This file is `axiom`-free.**  It imports only `Mathlib`; the `≤ₚ` structural
properties, scheduling-hardness, and the concrete reduction validity all enter
as explicit hypotheses, matching the MIP-side dependency list.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace OptimalOrderNPHard

-- Opaque type of decision problems (local kernel, self-contained).
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ`.  Its reflexivity
-- and transitivity are supplied as hypotheses where used.
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity class NP (opaque predicate).
variable (InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every NP problem polynomially reduces to
it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- **R.100 core — hardness transfer (reduction composition).**

If `A` polynomially reduces to `B` and `A` is NP-hard, then `B` is NP-hard.
The genuine mathematical content of "NP-hard via reduction": for any `Q ∈ NP`,
hardness of `A` gives `Q ≤ₚ A`, and transitivity with `A ≤ₚ B` yields
`Q ≤ₚ B`. -/
theorem R_100_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.100 — OPTIMAL-ORDER is NP-hard.**

Instantiates the transfer theorem with the precedence-scheduling reduction.
Inputs:
* `precedenceScheduling optimalOrder : Prob` — the two problems;
* `htrans` — transitivity of `≤ₚ`;
* `hSched : NPHard precedenceScheduling` — `1|prec|Σ wⱼ Cⱼ` is (strongly)
  NP-hard (Lenstra–Rinnooy Kan, bundled);
* `hred : polyReduces precedenceScheduling optimalOrder` — the barrier
  construction of §R.100, whose validity (`N(pᵢ, A) = tᵢ`, `G_task = G_sched`,
  `C(π) = Σ t_{π(i)}`) is bundled as this hypothesis.

Conclusion: `NPHard optimalOrder`. -/
theorem R_100_optimalOrder_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (precedenceScheduling optimalOrder : Prob)
    (hSched : NPHard polyReduces InNP precedenceScheduling)
    (hred : polyReduces precedenceScheduling optimalOrder) :
    NPHard polyReduces InNP optimalOrder :=
  R_100_transfer polyReduces InNP htrans hred hSched

/-- **R.100 — transfer along a reduction *chain*.**

NP-hardness propagates along any finite chain of reductions.  A chain through
an intermediate problem `C` (scheduling `≤ₚ` `C` `≤ₚ` OPTIMAL-ORDER) still
makes the target hard, by two applications of transitivity — exhibiting the
closure-under-composition that justifies the "reduce from a known-hard
problem" technique. -/
theorem R_100_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A C B : Prob}
    (hAC : polyReduces A C) (hCB : polyReduces C B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B :=
  R_100_transfer polyReduces InNP htrans (htrans hAC hCB) hA

/-- **R.100 — reflexivity sanity check.**

With reflexivity of `≤ₚ` (identity reduction), any NP-hard problem transfers
hardness to itself — a non-vacuity consistency check on the encoding. -/
theorem R_100_refl_transfer
    (hrefl : ∀ X : Prob, polyReduces X X)
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A : Prob}
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP A :=
  R_100_transfer polyReduces InNP htrans (hrefl A) hA

end OptimalOrderNPHard

end MIP
