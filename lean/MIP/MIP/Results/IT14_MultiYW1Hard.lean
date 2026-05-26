/-
Result IT.14 (candidate R.529) — BOUNDED-N-MULTI-Y is W[1]-hard under the
two-parameter `(k, r) = (step budget, questioner count)` parameterization.

Reference: `workspace/round3_exploration/work_slot_049.md` §IT.14 and
`slot_049.md` (grade: A unconditional; deps D.1.7, D.4.4 multi-questioner
generalization, NC.4; external: Multi-Colored CLIQUE W[1]-completeness
(Pietrzak 2003; Fellows et al. 2009)).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement.**  With `r` questioners `Y₁,…,Y_r` (each with its own metacognitive
intervention set `M_{Y_j}`) and a scheduling protocol `σ : [k] → [r]`,
`BOUNDED-N-MULTI-Y(p, X, {Y_j}, k)` asks whether some schedule and intervention
sequence achieves `N_multi ≤ k`.  IT.14 proves it is **W[1]-hard** under the
parameter `(k, r)`, via the FPT reduction

    Multi-Colored r-CLIQUE  ≤_FPT  BOUNDED-N-MULTI-Y  (with k = r),

mapping each colour class `V_j` to questioner `Y_j` with `M_{Y_j} = V_j`,
building solver `A_G` whose states track the chosen vertex set and whose target
predicate `p_G` fires exactly on a complete multi-coloured clique, with a
permutation-schedule lock; then
`N_multi(p_G, A_G, {Y_j}) ≤ r ⟺ G` has a multi-coloured `r`-clique, and the
reduction runs in FPT time `2^{O(r)}·poly(|V|,|E|)`.  Since Multi-Colored
CLIQUE is W[1]-complete w.r.t. `r`, the target is W[1]-hard.

**Formalization strategy (FPT-REDUCTION-TRANSFER KERNEL; R.166 idiom, W[1]
world).**  We do NOT build the solver `A_G`, the colour lock, or the
W-hierarchy.  The substance is the FPT-world hardness-transfer theorem:
W[1]-hardness propagates along FPT many-one reductions because `≤_FPT`
composes.  We abstract:

* `Prob` — parameterized decision problems;
* `fptReduces : Prob → Prob → Prop` — the `≤_FPT` preorder (reflexive,
  transitive supplied as hypotheses where needed);
* `InW1 : Prob → Prop` — membership in W[1] (opaque);
* `W1Hard P := ∀ Q, InW1 Q → fptReduces Q P`.

The genuine content is `IT_14_hardness_transfer`
(`A ≤_FPT B → W1Hard A → W1Hard B`, proved from transitivity).  IT.14 is the
instantiation with Multi-Colored CLIQUE W[1]-hard (the W[1]-complete base,
bundled) and the FPT reduction `CLIQUE ≤_FPT MULTI-Y` (validity bundled).

**This file is `axiom`-free.**  It imports only `Mathlib`; reflexivity and
transitivity of `≤_FPT`, W[1]-hardness/closure of Multi-Colored CLIQUE, and the
concrete FPT-reduction validity all enter as explicit hypotheses.
-/
import Mathlib.Logic.Basic

namespace MIP

namespace MultiYW1Hard

-- Opaque type of parameterized decision problems.
variable {Prob : Type*}

-- FPT many-one reducibility `≤_FPT`: `fptReduces Q P` means "`Q` reduces to `P`
-- by a parameterized FPT many-one reduction preserving the parameter".
variable (fptReduces : Prob → Prob → Prop)

-- Membership in the parameterized class W[1] (opaque predicate).
variable (InW1 : Prob → Prop)

/-- A problem `P` is **W[1]-hard** iff every W[1] problem FPT-reduces to it. -/
def W1Hard (P : Prob) : Prop := ∀ Q, InW1 Q → fptReduces Q P

/-- A problem `P` is **W[1]-complete** iff it is in W[1] and W[1]-hard. -/
def W1Complete (P : Prob) : Prop := InW1 P ∧ W1Hard fptReduces InW1 P

/-- **IT.14 core — W[1]-hardness transfers across an FPT reduction.**

If `A ≤_FPT B` and `A` is W[1]-hard, then `B` is W[1]-hard.  For any `Q ∈ W[1]`:
W[1]-hardness of `A` gives `Q ≤_FPT A`; compose with `A ≤_FPT B`.  This is the
W[1]-world analogue of R.166's hardness transfer and is the content of
"Multi-Colored CLIQUE `≤_FPT` BOUNDED-N-MULTI-Y makes the target W[1]-hard". -/
theorem IT_14_hardness_transfer
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    {A B : Prob}
    (hred : fptReduces A B)
    (hA : W1Hard fptReduces InW1 A) :
    W1Hard fptReduces InW1 B := by
  intro Q hQ
  exact htrans (hA Q hQ) hred

/-- **IT.14 core — W[1]-membership transfers across an FPT reduction.**

W[1] is closed under FPT reductions: if `A ≤_FPT B` and `B ∈ W[1]` then
`A ∈ W[1]`.  Carried as the closure hypothesis `hClosure`; used for the
(conjectured) completeness direction noted in IT.14.8(a). -/
theorem IT_14_membership_transfer
    (hClosure : ∀ {A B : Prob}, fptReduces A B → InW1 B → InW1 A)
    {A B : Prob}
    (hred : fptReduces A B)
    (hB : InW1 B) :
    InW1 A :=
  hClosure hred hB

/-- **IT.14 — BOUNDED-N-MULTI-Y is W[1]-hard (main theorem).**

Instantiates hardness transfer with the Multi-Colored CLIQUE reduction.
Inputs:
* `multiColoredClique multiY : Prob` — the two parameterized problems;
* `htrans` — transitivity of `≤_FPT` (FPT reductions compose);
* `hClique_hard : W1Hard multiColoredClique` — Multi-Colored CLIQUE is
  W[1]-hard (Pietrzak 2003 / Fellows et al. 2009, the W[1]-complete base,
  bundled);
* `hred : fptReduces multiColoredClique multiY` — the explicit
  `A_G / p_G / {Y_j}` construction of IT.14.1 with `k = r`, whose validity
  (`N_multi ≤ r ⟺ G` has a multi-coloured `r`-clique) and FPT running time are
  bundled as this hypothesis.

Conclusion: `W1Hard multiY`. -/
theorem IT_14_multiY_W1Hard
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    (multiColoredClique multiY : Prob)
    (hClique_hard : W1Hard fptReduces InW1 multiColoredClique)
    (hred : fptReduces multiColoredClique multiY) :
    W1Hard fptReduces InW1 multiY :=
  IT_14_hardness_transfer fptReduces InW1 htrans hred hClique_hard

/-- **IT.14 — conditional W[1]-completeness (IT.14.8(a)).**

If the conjectured reverse FPT reduction `multiY ≤_FPT multiColoredClique`
holds (closing the FPT upper bound), then together with the W[1]-membership of
Multi-Colored CLIQUE and W[1]-closure, `multiY ∈ W[1]`; combined with hardness
this yields W[1]-completeness.  Records the source's open completeness direction
as a clean conditional, exactly the R.166-style two-reduction sandwich. -/
theorem IT_14_multiY_W1Complete_of_reverse
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    (hClosure : ∀ {A B : Prob}, fptReduces A B → InW1 B → InW1 A)
    (multiColoredClique multiY : Prob)
    (hClique_hard : W1Hard fptReduces InW1 multiColoredClique)
    (hClique_mem : InW1 multiColoredClique)
    (hHardRed : fptReduces multiColoredClique multiY)
    (hRevRed : fptReduces multiY multiColoredClique) :
    W1Complete fptReduces InW1 multiY := by
  refine ⟨?_, ?_⟩
  · exact IT_14_membership_transfer fptReduces InW1 hClosure hRevRed hClique_mem
  · exact IT_14_multiY_W1Hard fptReduces InW1 htrans multiColoredClique multiY
      hClique_hard hHardRed

/-- **IT.14 — hardness along a reduction *chain*.**

W[1]-hardness propagates along `CLIQUE ≤_FPT C ≤_FPT MULTI-Y`, by two
applications of transitivity of `≤_FPT` — the closure-under-composition property
that makes "FPT-reduce from a W[1]-hard problem" a sound technique. -/
theorem IT_14_transfer_chain
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    {A C B : Prob}
    (hAC : fptReduces A C) (hCB : fptReduces C B)
    (hA : W1Hard fptReduces InW1 A) :
    W1Hard fptReduces InW1 B :=
  IT_14_hardness_transfer fptReduces InW1 htrans (htrans hAC hCB) hA

/-- **IT.14 — reflexivity sanity check.**

With reflexivity of `≤_FPT` (identity FPT reduction), any W[1]-hard problem
transfers hardness to itself — a non-vacuity check on the `fptReduces`/`W1Hard`
encoding. -/
theorem IT_14_refl_transfer
    (hrefl : ∀ X : Prob, fptReduces X X)
    (htrans : ∀ {X Y Z : Prob}, fptReduces X Y → fptReduces Y Z → fptReduces X Z)
    {A : Prob}
    (hA : W1Hard fptReduces InW1 A) :
    W1Hard fptReduces InW1 A :=
  IT_14_hardness_transfer fptReduces InW1 htrans (hrefl A) hA

end MultiYW1Hard

end MIP
