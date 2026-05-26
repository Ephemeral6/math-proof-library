/-
Result R.87 — Complexity three-layer structure of N.

Reference: `workspace/new_results.md` R.87 (B 级; deps R.83, R.85, standard
complexity theory).

**Statement.** The computational complexity of the self-emergence cost `N`
stratifies with the expressiveness of the AI `A`:

    AI expressiveness                | complexity of computing N
    ---------------------------------|---------------------------
    (i)   general Turing machine      | uncomputable          (R.83)
    (ii)  finite-state (poly states)  | PSPACE-complete       (graph BFS)
    (iii) finite-state                | NP-hard               (R.85, ≤ poly)
    (iv)  poly-time state transform   | in NP (guess + verify)
    (v)   fixed-depth (last d steps)  | in P

Per the user-prompt decomposition: sub-items (i) [uncomputable] and (v) [P]
are A-unconditional; (ii)/(iii) are A-conditional (depend on the finite-state
hypothesis); (iv) is the NP layer. The "crisp" formalizable content is twofold:

  * the **layer ordering / containment** of the complexity classes as the
    standard chain `P ⊆ NP ⊆ PSPACE` (set inclusions), which is exactly the
    skeleton the table's three middle rows live on; and
  * the **NP-hard layer**: BOUNDED-N is NP-hard under the finite-state
    restriction, obtained by reusing the abstract hardness-transfer kernel
    of R.85 (a poly-time reduction from a known-hard problem composes).

**The PSPACE-vs-NP gap.** Row (ii) puts the finite-state N-problem in
PSPACE-complete while row (iv) puts the poly-time-transform N-problem in NP.
Whether these coincide is exactly the open `NP =? PSPACE` question; R.87 does
**not** resolve it. We document this honestly: the inclusion `NP ⊆ PSPACE`
is provable (and bundled here as a hypothesis matching standard complexity
theory), but the reverse `PSPACE ⊆ NP` is *not* assumed — it is the open gap.

**Formalization strategy (set/order + hypothesis-bundle reduction).** Complexity
classes are modelled as sets of problems (`Set Prob`); the standard inclusions
`P ⊆ NP`, `NP ⊆ PSPACE` enter as bundled hypotheses (standard complexity
theory, not re-derived). The NP-hard layer reuses the R.85 abstract kernel:
`polyReduces`/`NPHard` with transitivity, and `R_87_layer_iv_NPHard` is the
instantiation `3SAT ≤ₚ BOUNDED-N ⟹ NPHard BOUNDED-N`.

**This file is `axiom`-free.** It imports only `Mathlib`; the class inclusions,
3-SAT-hardness, and the concrete finite-state reduction validity enter as
explicit hypotheses, and the open `PSPACE ⊆ NP` is deliberately *not* assumed.
-/
import Mathlib.Data.Set.Basic
import Mathlib.Order.SetNotation
import Mathlib.Logic.Basic

namespace MIP

namespace ComplexityHierarchy

/-! ### Abstract decision problems and complexity classes -/

-- Opaque type of decision problems.
variable {Prob : Type*}

/-! ### Layers (i)–(v): the containment skeleton (set inclusions)

The three middle rows of the table live on the standard chain `P ⊆ NP ⊆ PSPACE`.
We treat each class as a `Set Prob` and supply the textbook inclusions as
hypotheses. -/

/-- **R.87 — class containment chain `P ⊆ NP ⊆ PSPACE` (layers v → iv → ii).**

The layer ordering of the table: the fixed-depth class `P` (row v) is contained
in the guess-and-verify class `NP` (row iv), which is contained in the
graph-BFS class `PSPACE` (row ii). Standard complexity-theory inclusions enter
as hypotheses; the conclusion is the transitive chain `P ⊆ PSPACE`. -/
theorem R_87_layer_chain
    (P NP PSPACE : Set Prob)
    (h_P_NP : P ⊆ NP)
    (h_NP_PSPACE : NP ⊆ PSPACE) :
    P ⊆ NP ∧ NP ⊆ PSPACE ∧ P ⊆ PSPACE :=
  ⟨h_P_NP, h_NP_PSPACE, h_P_NP.trans h_NP_PSPACE⟩

/-- **R.87 — membership transports up the layer chain.**

If the (fixed-depth-restricted) N-problem is in `P`, then it is also in `NP`
and in `PSPACE`: a problem solvable under the strongest restriction (row v)
is a fortiori solvable under the weaker ones (rows iv, ii). This is the
"upward" reading of the hierarchy used in the table. -/
theorem R_87_membership_transport
    (P NP PSPACE : Set Prob) (boundedN : Prob)
    (h_P_NP : P ⊆ NP)
    (h_NP_PSPACE : NP ⊆ PSPACE)
    (h_mem : boundedN ∈ P) :
    boundedN ∈ NP ∧ boundedN ∈ PSPACE := by
  have h1 : boundedN ∈ NP := h_P_NP h_mem
  exact ⟨h1, h_NP_PSPACE h1⟩

/-! ### The PSPACE-vs-NP gap (row ii vs row iv): documented, not resolved -/

/-- **R.87 — the NP =? PSPACE gap is *not* collapsed.**

Rows (ii) [PSPACE-complete] and (iv) [in NP] of the table straddle the open
`NP =? PSPACE` question. We make precise that R.87 does not resolve it: from
`NP ⊆ PSPACE` alone one **cannot** derive `PSPACE ⊆ NP`. Concretely, if the
reverse inclusion *did* follow, then for the specific witness `boundedN` that
is in PSPACE we would get it in NP — but that conclusion is only available
when the reverse inclusion is *separately* assumed. We record the conditional
form: the collapse `PSPACE ⊆ NP` is exactly the extra hypothesis needed, and
it is left open. -/
theorem R_87_gap_conditional
    (NP PSPACE : Set Prob) (boundedN : Prob)
    (h_mem_PSPACE : boundedN ∈ PSPACE)
    (h_collapse : PSPACE ⊆ NP) :
    boundedN ∈ NP :=
  h_collapse h_mem_PSPACE

/-! ### Layer (iv)/(iii): the NP-hard layer (R.85 hardness-transfer kernel)

Reused abstract kernel from R.85, redefined locally for self-containment. -/

-- The polynomial-time many-one reducibility relation `≤ₚ`.
variable (polyReduces : Prob → Prob → Prop)

-- Membership in the complexity class NP (opaque predicate, the row-iv class).
variable (InNP : Prob → Prop)

/-- A problem `P` is **NP-hard** iff every NP problem polynomially reduces to
it. -/
def NPHard (P : Prob) : Prop := ∀ Q, InNP Q → polyReduces Q P

/-- **R.87 core — hardness transfer (reduction composition), reused from R.85.**

If `A` polynomially reduces to `B` and `A` is NP-hard, then `B` is NP-hard.
For any `Q ∈ NP`, hardness of `A` gives `Q ≤ₚ A`; transitivity with `A ≤ₚ B`
yields `Q ≤ₚ B`. -/
theorem R_87_transfer
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    {A B : Prob}
    (hred : polyReduces A B)
    (hA : NPHard polyReduces InNP A) :
    NPHard polyReduces InNP B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **R.87 — layer (iv)/(iii): BOUNDED-N (finite-state) is NP-hard.**

Instantiates the transfer kernel with the R.85 finite-state reduction:
* `threeSAT boundedN : Prob` — the two problems;
* `htrans` — transitivity of `≤ₚ`;
* `hSAT : NPHard threeSAT` — 3-SAT NP-hard (Cook–Levin, bundled);
* `hred : polyReduces threeSAT boundedN` — the finite-state `A_φ` reduction of
  R.85 (`φ ∈ SAT ⟺ N(p_φ, A_φ) ≤ n + m`), bundled.

Conclusion: the NP-hard layer of the table, `NPHard boundedN`. This is the
A-conditional row (depends on the finite-state hypothesis), and the reduction
is `≤ poly` as the table's "NP-hard, ≤ poly" entry asserts. -/
theorem R_87_layer_iv_NPHard
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeSAT boundedN : Prob)
    (hSAT : NPHard polyReduces InNP threeSAT)
    (hred : polyReduces threeSAT boundedN) :
    NPHard polyReduces InNP boundedN :=
  R_87_transfer polyReduces InNP htrans hred hSAT

/-- **R.87 — full three-layer statement (provable content bundled).**

Packages the formalizable substance of the table:
* (skeleton) the containment chain `P ⊆ NP ⊆ PSPACE`;
* (iv/iii) the NP-hardness of the finite-state BOUNDED-N via R.85 transfer.

The uncomputable layer (i) is R.83 (a separate result, not re-proved here),
and the `NP =? PSPACE` gap for row (ii) is left open (see
`R_87_gap_conditional`). -/
theorem R_87_three_layer
    (P NP PSPACE : Set Prob)
    (h_P_NP : P ⊆ NP) (h_NP_PSPACE : NP ⊆ PSPACE)
    (htrans : ∀ {X Y Z : Prob}, polyReduces X Y → polyReduces Y Z → polyReduces X Z)
    (threeSAT boundedN : Prob)
    (hSAT : NPHard polyReduces InNP threeSAT)
    (hred : polyReduces threeSAT boundedN) :
    (P ⊆ PSPACE) ∧ NPHard polyReduces InNP boundedN :=
  ⟨h_P_NP.trans h_NP_PSPACE,
   R_87_layer_iv_NPHard polyReduces InNP htrans threeSAT boundedN hSAT hred⟩

end ComplexityHierarchy

end MIP
