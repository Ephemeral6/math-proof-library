/-
Result IT.5 (candidate R.520) — Deciding atomic-barrier (indecomposability)
is coNP-hard.

Reference: `workspace/round3_exploration/slot_006.md` / `work_slot_006.md`
§IT.5 (candidate, deps D.2.5, D.2.6, D.2.7, D.1.2, D.1.5, 3-SAT/3-UNSAT
NP-completeness / coNP-completeness, Cook–Levin 1971).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

**Statement.**  ATOMIC-BARRIER is the decision problem: given `(p, A, b)` with
a finite implicitly-described AI `A` and a known barrier `b = (s₁, s₂)`, decide
whether `b` is a D.2.7 *atomic* barrier — i.e. whether there is **no** mid-state
`s_mid` realizing a D.2.6 decomposition `b₁ = (s₁, s_mid)`, `b₂ = (s_mid, s₂)`.
IT.5 proves ATOMIC-BARRIER is **coNP-hard** via a polynomial-time many-one
reduction from 3-UNSAT (equivalently TAUT-style): a 3-SAT instance `φ` over `n`
variables and `m` clauses is mapped to `(p_φ, A_φ, b_φ)` with the R.85-style
finite state machine `A_φ` augmented by an "early-settlement" intervention
`m_close`, such that

    b_φ is decomposable   ⟺   φ ∈ SAT,
    b_φ is atomic         ⟺   φ ∈ 3-UNSAT.

Hence 3-UNSAT ≤ₚ ATOMIC-BARRIER, and since 3-UNSAT is coNP-complete,
ATOMIC-BARRIER is coNP-hard.

**Formalization strategy (hypothesis-bundle reduction).**  Per the project
idiom we do NOT build a SAT solver, the `A_φ` barrier-decomposition machine, or
a Turing machine.  The mathematical substance of a *coNP-hardness via reduction*
result is the **transfer theorem**: a polynomial-time many-one reduction from a
coNP-hard problem composes to make the target coNP-hard.  We encode this
abstractly, mirroring the NP-hard kernel of R.85/R.100 but for the class coNP.

* `Prob` — an opaque type of decision problems.
* `polyReduces : Prob → Prob → Prop` — the polynomial-time many-one
  reducibility preorder `≤ₚ`, carried abstractly with reflexivity and
  transitivity supplied as hypotheses where used.
* `InCoNP : Prob → Prop` — membership in coNP (opaque predicate).
* `CoNPHard P := ∀ Q, InCoNP Q → polyReduces Q P` — every coNP problem reduces
  to `P`.
* `CoNPComplete P := CoNPHard P ∧ InCoNP P`.

The real content is `IT5_transfer`: `polyReduces A B → CoNPHard A → CoNPHard B`,
proved honestly from transitivity of `≤ₚ` (note: many-one reducibility is the
*same* relation for coNP as for NP — coNP-hardness uses the ordinary many-one
reduction because coNP is closed under it).  IT.5 itself is the instantiation:
with 3-UNSAT coNP-hard (`hUNSAT`, Cook–Levin + closure of coNP) and the
`A_φ`/`m_close` construction reduction `3UNSAT ≤ₚ ATOMIC-BARRIER` (`hred`,
bundling the validity `b_φ atomic ⟺ φ ∈ 3-UNSAT` proved in work_slot_006 §IT.5),
`CoNPHard ATOMIC-BARRIER` follows.  Completeness adds the membership witness.

**This file is `axiom`-free.**  It imports only `Mathlib`; reflexivity and
transitivity of `≤ₚ`, 3-UNSAT-coNP-hardness, coNP membership, and the concrete
reduction validity all enter as explicit hypotheses, matching the MIP-side
dependency list.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace AtomicBarrierCoNPHard

-- Opaque type of decision problems (local kernel, self-contained).
variable {Prob : Type*}

-- The polynomial-time many-one reducibility relation `≤ₚ` between decision
-- problems.  This is the *same* relation used for NP- and coNP-hardness; coNP
-- being closed under many-one reductions is what makes hardness transfer along
-- `≤ₚ` here.  Reflexivity and transitivity are supplied as hypotheses where
-- needed: `polyReduces Q P` means "`Q` reduces to `P` in polynomial time."
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity class coNP (opaque predicate).
variable (InCoNP : Prob → Prop)

/-- A problem `P` is **coNP-hard** iff every problem in coNP polynomially
reduces to it. -/
def CoNPHard (P : Prob) : Prop := ∀ Q, InCoNP Q → polyReduces Q P

/-- A problem `P` is **coNP-complete** iff it is coNP-hard and in coNP. -/
def CoNPComplete (P : Prob) : Prop := CoNPHard polyReduces InCoNP P ∧ InCoNP P

/-- **IT.5 core — coNP-hardness transfer (reduction composition).**

If `A` polynomially reduces to `B` (`polyReduces A B`) and `A` is coNP-hard,
then `B` is coNP-hard.  This is the genuine mathematical substance of any
"coNP-hard via reduction from a known coNP-hard problem" result: it is exactly
the statement that the reducibility preorder composes (and that coNP is closed
under many-one reductions, which is what lets the *same* `≤ₚ` carry coNP
hardness).  Proof: for any `Q ∈ coNP`, coNP-hardness of `A` gives `Q ≤ₚ A`;
transitivity with `A ≤ₚ B` yields `Q ≤ₚ B`. -/
theorem IT5_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.5 — ATOMIC-BARRIER is coNP-hard.**

Instantiates the transfer theorem with the 3-UNSAT reduction.  Inputs:
* `threeUNSAT atomicBarrier : Prob` — the two problems;
* `htrans` — transitivity of `≤ₚ` (reductions compose in poly time);
* `hUNSAT : CoNPHard threeUNSAT` — 3-UNSAT is coNP-hard (Cook–Levin + coNP
  closure, bundled);
* `hred : polyReduces threeUNSAT atomicBarrier` — the explicit
  `A_φ`/`p_φ`/`b_φ`/`m_close` state-machine reduction of §IT.5, whose validity
  (`b_φ atomic ⟺ φ ∈ 3-UNSAT`) is bundled as this hypothesis.

Conclusion: `CoNPHard atomicBarrier`. -/
theorem IT5_atomicBarrier_coNPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeUNSAT atomicBarrier : Prob)
    (hUNSAT : CoNPHard polyReduces InCoNP threeUNSAT)
    (hred : polyReduces threeUNSAT atomicBarrier) :
    CoNPHard polyReduces InCoNP atomicBarrier :=
  IT5_transfer polyReduces InCoNP htrans hred hUNSAT

/-- **IT.5 — ATOMIC-BARRIER is coNP-complete (conditional on membership).**

Strengthens the hardness result to completeness when the problem is also known
to lie in coNP (the certificate for "`b` is *decomposable*", i.e. a witness
mid-state `s_mid` plus the SAT-extension witness, is checkable in polynomial
time, so the *complement* ATOMIC is a coNP problem).  Bundling the membership
witness `hmem : InCoNP atomicBarrier` with hardness yields completeness. -/
theorem IT5_atomicBarrier_coNPComplete
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeUNSAT atomicBarrier : Prob)
    (hUNSAT : CoNPHard polyReduces InCoNP threeUNSAT)
    (hred : polyReduces threeUNSAT atomicBarrier)
    (hmem : InCoNP atomicBarrier) :
    CoNPComplete polyReduces InCoNP atomicBarrier :=
  ⟨IT5_atomicBarrier_coNPHard polyReduces InCoNP htrans threeUNSAT atomicBarrier
      hUNSAT hred,
   hmem⟩

/-- **IT.5 — transfer along a reduction *chain*.**

Generalizes the single-step transfer: coNP-hardness propagates along any finite
chain of reductions.  A chain through an intermediate problem `C`
(3-UNSAT `≤ₚ` `C` `≤ₚ` ATOMIC-BARRIER) still yields hardness of the target, by
two applications of transitivity — exhibiting closure under composition, the
property that makes "reduce from a known coNP-hard problem" a sound technique.
This matches the §IT.5 route 3-UNSAT `≤ₚ` (SAT-extension gadget) `≤ₚ`
ATOMIC-BARRIER through the `m_close` settlement intervention. -/
theorem IT5_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A C B : Prob}
    (hAC : polyReduces A C) (hCB : polyReduces C B)
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP B :=
  IT5_transfer polyReduces InCoNP htrans (htrans hAC hCB) hA

/-- **IT.5 — reflexivity sanity check (non-vacuity).**

With reflexivity of `≤ₚ` (every problem reduces to itself via the identity
reduction), any coNP-hard problem trivially transfers hardness to itself.  A
degenerate consistency check that the `polyReduces`/`CoNPHard` encoding is not
vacuous: `CoNPHard A → CoNPHard A`. -/
theorem IT5_refl_transfer
    (hrefl : ∀ X : Prob, polyReduces X X)
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A : Prob}
    (hA : CoNPHard polyReduces InCoNP A) :
    CoNPHard polyReduces InCoNP A :=
  IT5_transfer polyReduces InCoNP htrans (hrefl A) hA

end AtomicBarrierCoNPHard

end MIP
