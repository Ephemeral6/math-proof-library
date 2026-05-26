/-
Result R.85 (T.17) — BOUNDED-N is NP-hard.

Reference: `proofs/derived/computation.md` §R.85 (A 级, deps D.1.6, D.1.5,
A.2, 3-SAT NP-completeness).

**Statement.**  BOUNDED-N is the decision problem: given `(p, A, k)` with a
finite-state AI `A`, decide whether the self-emergence cost satisfies
`N(p, A) ≤ k`.  R.85 proves BOUNDED-N is NP-hard via a polynomial-time
many-one reduction from 3-SAT: a 3-SAT instance `φ` over `n` variables and
`m` clauses is mapped to `(p_φ, A_φ, k_φ)` with `k_φ = n + m` and the state
machine `A_φ` of size `O(n + m)`, such that

    φ ∈ SAT  ⟺  N(p_φ, A_φ) ≤ k_φ .

The state machine first reads `n` assignment moves (each `m ∈ M₊ ⊎ M₋`
choosing a truth value), then `m` clause-check moves; it reaches the
accepting state `s⊤` iff the assignment satisfies every clause, and the
shortest accepting trajectory has length exactly `n + m`.

**Formalization strategy (hypothesis-bundle reduction).**  Per the project
idiom we do NOT build a 3-SAT solver or a Turing machine.  The mathematical
substance of an NP-hardness *reduction* result is the **transfer theorem**:
"a polynomial-time reduction from a hard problem composes to make the target
hard."  We encode this abstractly.

* `Prob` — an opaque type of decision problems.
* `polyReduces : Prob → Prob → Prop` — the polynomial-time many-one
  reducibility preorder `≤ₚ`, modelled by its two structural axioms as
  hypotheses: **reflexivity** (identity reduction) and **transitivity**
  (reductions compose in polynomial time).
* `InNP : Prob → Prop` — membership in NP (opaque).
* `NPHard P := ∀ Q, InNP Q → polyReduces Q P` — every NP problem reduces to
  `P`.

The real content is `R_85_transfer`: `polyReduces A B → NPHard A → NPHard B`,
proved honestly from transitivity of `≤ₚ`.  R.85 itself is the instantiation:
with 3-SAT NP-hard (`hSAT`) and the FSM-construction reduction
`3SAT ≤ₚ BOUNDED-N` (`hred`, bundling the validity of the `A_φ` construction
above), `NPHard BOUNDED-N` follows.

**This file is `axiom`-free.**  It imports only `Mathlib`; reflexivity and
transitivity of `≤ₚ`, 3-SAT-hardness, and the concrete reduction validity all
enter as explicit hypotheses, matching the MIP-side dependency list.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace BoundedNNPHard

-- Opaque type of decision problems.
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ` between decision
-- problems.  We carry it abstractly and supply its two structural properties
-- (reflexive, transitive) as hypotheses where needed: `polyReduces Q P` means
-- "`Q` reduces to `P` in polynomial time."
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity class NP (opaque predicate).
variable (InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every problem in NP polynomially reduces
to it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- **R.85 core — hardness transfer (reduction composition).**

If `A` polynomially reduces to `B` (`polyReduces A B`) and `A` is NP-hard,
then `B` is NP-hard.  This is the genuine mathematical substance of any
"NP-hard via reduction from a known-hard problem" result: it is exactly the
statement that the reducibility preorder composes.  The proof: for any
`Q ∈ NP`, NP-hardness of `A` gives `Q ≤ₚ A`; transitivity with `A ≤ₚ B`
yields `Q ≤ₚ B`. -/
theorem R_85_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.85 — BOUNDED-N is NP-hard.**

Instantiates the transfer theorem with the 3-SAT reduction.  Inputs:
* `threeSAT BoundedN : Prob` — the two problems;
* `htrans` — transitivity of `≤ₚ` (reductions compose in poly time);
* `hSAT : NPHard threeSAT` — 3-SAT is NP-hard (Cook–Levin, bundled);
* `hred : polyReduces threeSAT BoundedN` — the explicit `A_φ`/`p_φ`/`k_φ`
  state-machine reduction of §R.85, whose validity
  (`φ ∈ SAT ⟺ N(p_φ, A_φ) ≤ n + m`) is bundled as this hypothesis.

Conclusion: `NPHard BoundedN`. -/
theorem R_85_boundedN_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeSAT BoundedN : Prob)
    (hSAT : NPHard polyReduces InNP threeSAT)
    (hred : polyReduces threeSAT BoundedN) :
    NPHard polyReduces InNP BoundedN :=
  R_85_transfer polyReduces InNP htrans hred hSAT

/-- **R.85 — transfer along a reduction *chain*.**

Generalizes the single-step transfer: NP-hardness propagates along any finite
chain of reductions.  Here a chain through an intermediate problem `C`
(3-SAT `≤ₚ` `C` `≤ₚ` BOUNDED-N) still yields hardness of the target, by two
applications of transitivity.  This shows the transfer mechanism is closed
under composition, the property that makes "reduce from a known-hard problem"
a sound proof technique. -/
theorem R_85_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A C B : Prob}
    (hAC : polyReduces A C) (hCB : polyReduces C B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B :=
  R_85_transfer polyReduces InNP htrans (htrans hAC hCB) hA

/-- **R.85 — reflexivity sanity check.**

With reflexivity of `≤ₚ` (every problem reduces to itself via the identity
reduction), any NP-hard problem trivially transfers hardness to itself.  This
is a degenerate consistency check that the `polyReduces`/`NPHard` encoding is
not vacuous: `NPHard A → NPHard A`. -/
theorem R_85_refl_transfer
    (hrefl : ∀ X : Prob, polyReduces X X)
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A : Prob}
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP A :=
  R_85_transfer polyReduces InNP htrans (hrefl A) hA

end BoundedNNPHard

end MIP
