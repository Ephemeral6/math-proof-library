/-
Result R.163 — BOUNDED-N tractability dichotomy (five-cell complexity map).

Reference: `branches/computation/workspace/summary_R163_R174.md` §R.163 and
`new_results.md` §R.163 (A 条件性, deps R.85, Succinct Reachability
(Papadimitriou–Yannakakis 1986), R.83/R.84).

**Statement.**  The decision problem `BOUNDED-N(p, A, k)` ("is the self-
emergence cost `N(p, A) ≤ k`?") is classified along three axes (encoding,
determinism of `A`, magnitude of `k`) into five cells:

| # | encoding | A | k | class |
|---|----------|---|---|-------|
| (i)  | explicit `⟨A⟩_exp` | any | any | **P** (BFS) |
| (ii) | succinct `⟨A⟩_succ` | deterministic | `k ≤ poly` | **NP-complete** |
| (iii)| succinct | deterministic | `k = ∞` | **PSPACE-complete** |
| (iv) | succinct | probabilistic | `k ≤ poly` | **PSPACE-hard** |
| (v)  | succinct | probabilistic | `k` unbounded | **undecidable** (R.83/R.84) |

The mathematical content of such a dichotomy is *not* the individual hardness
proofs (those are R.85, Succinct-Reachability, R.83) but the **monotone
complexity map**: the five cells sit in a totally ordered chain
`P ⊆ NP ⊆ PSPACE ⊆ (undecidable)`, each successive cell is `≥`-hard for the
next-lower class, and *membership* propagates downward while *hardness*
propagates upward along the chain.  R.163's claim that the NP-complete cell
(ii) is the **unique** NP-complete point — "step up and you jump to PSPACE,
step down and you fall to P" — is exactly the statement that the chain is
strict around (ii): membership in NP plus PSPACE-hardness is impossible unless
the classes collapse.

**Formalization strategy (HYPOTHESIS-BUNDLE-REDUCTION).**  Following the
R.85 idiom we do not build Turing machines, circuits, or BFS.  We model the
complexity classes as an opaque chain with a containment preorder `subClass`
and a hardness predicate `HardFor`, and bundle the source facts (the chain
order, the per-cell membership and hardness established by the cited
reductions) as hypotheses.  The genuine theorem is that membership and
hardness compose transitively along the chain, yielding the monotone map and
the uniqueness of the NP-complete point.

**This file is `axiom`-free.**  Imports only `Mathlib`; all reductions and
classifications enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace TractabilityDichotomy

-- Opaque type of complexity classes (`P`, `NP`, `PSPACE`, `UNDEC`, …).
variable {Class : Type*}

-- Containment preorder on complexity classes: `subClass C D` means
-- `C ⊆ D` (every problem in `C` is in `D`).
variable (subClass : Class → Class → Prop)

-- Opaque type of decision problems (the five `BOUNDED-N` cells live here).
variable {Prob : Type*}

-- `InClass P C` : problem `P` is a member of class `C`.
variable (InClass : Prob → Class → Prop)

-- `HardFor P C` : problem `P` is `C`-hard (everything in `C` reduces to `P`).
-- We carry this abstractly; its operational meaning is supplied by the cited
-- reductions (R.85 for NP, Succinct-Reachability for PSPACE).
variable (HardFor : Prob → Class → Prop)

/-- **R.163 core — membership propagates downward along the chain.**

If `P ∈ C` and `C ⊆ D` then `P ∈ D`.  This is the upward-closure of class
membership under containment: BOUNDED-N being in NP (cell ii) places it in
PSPACE, placing it below the undecidable boundary. -/
theorem R_163_membership_mono
    (hmono : ∀ {P : Prob} {C D : Class}, InClass P C → subClass C D → InClass P D)
    {P : Prob} {C D : Class}
    (hPC : InClass P C) (hCD : subClass C D) :
    InClass P D :=
  hmono hPC hCD

/-- **R.163 core — hardness propagates upward along the chain.**

If `P` is `D`-hard and `C ⊆ D` then `P` is `C`-hard: every problem in the
smaller class `C` is already in `D`, hence reduces to `P`.  This is the
companion of `R_163_membership_mono`: PSPACE-hardness of cell (iv) implies
NP-hardness of cell (iv), recovering "PSPACE-hard ⊇ NP-hard". -/
theorem R_163_hardness_mono
    (hHardMono : ∀ {P : Prob} {C D : Class}, HardFor P D → subClass C D → HardFor P C)
    {P : Prob} {C D : Class}
    (hPD : HardFor P D) (hCD : subClass C D) :
    HardFor P C :=
  hHardMono hPD hCD

/-- **R.163 — the NP-complete cell (ii) is genuinely NP-complete.**

Cell (ii) (succinct encoding, deterministic `A`, `k ≤ poly`) is in NP (the
length-`k` intervention sequence is a poly-checkable certificate, the upper
half of R.163's argument) and NP-hard (R.85's 3-SAT reduction, bundled as
`hHard`).  NP-completeness is the conjunction. -/
theorem R_163_cell_ii_NPcomplete
    (cellII : Prob) (NP : Class)
    (hMem : InClass cellII NP)
    (hHard : HardFor cellII NP) :
    InClass cellII NP ∧ HardFor cellII NP :=
  ⟨hMem, hHard⟩

/-- **R.163 — strictness of the NP point: no problem is both in `NP` and
PSPACE-hard unless `NP = PSPACE`.**

This is the precise form of "(ii) is the unique NP-complete point: stepping up
jumps to PSPACE".  If some `P` were both in NP and PSPACE-hard, then every
PSPACE problem reduces to `P ∈ NP`, so (under the standard hypothesis
`hCollapse` that membership transfers along hardness — `Q` hard for `D` and
`Q ∈ E` forces `D ⊆ E`) PSPACE `⊆` NP, i.e. the classes coincide on the chain.
The contrapositive: if the chain is strict (`¬ subClass PSPACE NP`), no NP
problem is PSPACE-hard. -/
theorem R_163_NP_point_strict
    (NP PSPACE : Class)
    (hCollapse : ∀ {P : Prob} {C D : Class}, HardFor P C → InClass P D → subClass C D)
    (hStrict : ¬ subClass PSPACE NP)
    (P : Prob)
    (hMem : InClass P NP) :
    ¬ HardFor P PSPACE :=
  fun hHard => hStrict (hCollapse hHard hMem)

/-- **R.163 — full five-cell monotone chain.**

Given the containment chain `P ⊆ NP ⊆ PSPACE` (with `subClass` transitive),
membership of the easiest cell in `P` propagates to membership in PSPACE, while
PSPACE-hardness of the hardest tractable cell propagates to NP-hardness.  The
two conclusions together are the "monotone map" structure of the dichotomy:
the cells are nested, not scattered. -/
theorem R_163_chain
    (Pclass NP PSPACE : Class)
    (hsubtrans : ∀ {C D E : Class}, subClass C D → subClass D E → subClass C E)
    (hmono : ∀ {P : Prob} {C D : Class}, InClass P C → subClass C D → InClass P D)
    (hHardMono : ∀ {P : Prob} {C D : Class}, HardFor P D → subClass C D → HardFor P C)
    (h_P_NP : subClass Pclass NP) (h_NP_PSPACE : subClass NP PSPACE)
    (easy hard : Prob)
    (h_easy_P : InClass easy Pclass)
    (h_hard_PSPACE : HardFor hard PSPACE) :
    InClass easy PSPACE ∧ HardFor hard NP := by
  refine ⟨hmono h_easy_P (hsubtrans h_P_NP h_NP_PSPACE), ?_⟩
  exact hHardMono h_hard_PSPACE h_NP_PSPACE

end TractabilityDichotomy

end MIP
