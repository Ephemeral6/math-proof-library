# Agent 1 — Pairwise Axiom Interactions: Summary

**Goal.** Find new corollaries derivable from each pairwise combination of the four MIP axioms A.1–A.4, prioritising statements that require *both* axioms and are not already in `Corollaries/`, `Results/`, or `Theorems/`.

**Methodology.** For each combination, I first grepped the existing corpus for statements that already use both axioms in the same proof. Strikingly, **no existing `Corollaries/Cx_*.lean` file uses `Axioms.A1`** — every existing corollary that touches `N` or `Phi0` uses only A.2 (the four C-files invoking the axioms cite A.2 only; A.1 surfaces only inside `Defs/StateSequence.lean` and `Theorems/T7_Uniqueness.lean`). This made A.1-based pairwise combinations a fertile but largely untilled ground.

---

## Files produced (all compile, all zero `sorry`, all zero new `axiom`)

| File | Combination | STATUS | Headline finding |
|---|---|---|---|
| `Agent1_A1A2_Phi0Coverage.lean` | **A.1 ∧ A.2** | DISCOVERY | `Phi0 X p = 0 → ∃ R' ∈ ℛ(p), R' ⊆ K X` (the "cheap win") plus the **trichotomy under coverage**: under coverage, `N p X` is *either* `0` (Phi0 = 0) *or* a positive finite natural (Phi0 ≠ 0), never `⊤`. |
| `Agent1_A1A3_RedundantExpert.lean` | **A.1 ∧ A.3** | DISCOVERY | When `Phi0 X p = 0` (problem auto-solved by X), A.3 *still* produces a metacognitive substitute for every eligible expert — the "expert substitute is informationally redundant" redundancy theorem. Includes a specialisation to the always-true problem where Phi0 = 0 is automatic. |
| `Agent1_A1A4_Phi0Invariance.lean` | **A.1 ∧ A.4** | DISCOVERY | Phi0-zero status (and N=0 status) propagates across behaviourally-equivalent agents via A.4. Includes the cross-orbit form `Phi0 X p = 0 ↔ N p X' = 0` under a Phi0-bridge. |
| `Agent1_A1A4_SolvedClass.lean` | **A.1 ∧ A.4** | DISCOVERY | The "auto-solved class" `{ p | N p X = 0 }` coincides with the "Phi0-zero class" by A.1, and is invariant across agents sharing K and Phi0 (the A.4-bridge content). |
| `Agent1_A2A3_CoverageExpertSync.lean` | **A.2 ∧ A.3** | DISCOVERY | Both axioms target `⊆ K X`. New corollaries: a family of A.3-eligible experts whose union covers a demand gives A.2-finiteness; joint containment algebra; converse "synthetic expert from coverage" under realisability bridge. |
| `Agent1_A2A3_FiniteToSubstitute.lean` | **A.2 ∧ A.3** | DISCOVERY | The "operational interpretation of A.2 via A.3": under a demand-realisability bridge, A.2-finiteness is *equivalent* to existence of an explicit A.3 meta-substitute realising the demand. The cleanest A.2↔A.3 biconditional. |
| `Agent1_A2A4_EssentialKnowledge.lean` | **A.2 ∧ A.4** | DISCOVERY | "Doubly-blind tokens": ω ∉ K X is both A.4-inert (response invariance) *and* A.2-irrelevant (no covered demand contains it). Plus the **essentialK** definition (union of covered demands, ⊆ K X) and its emptiness criterion. Also A.2+A.4 monotonicity: K-growth widens A.2-coverage and shrinks A.4-inert-set in exact complementarity. |
| `Agent1_A3A4_ExpertCanonicalForm.lean` | **A.3 ∧ A.4** | DISCOVERY | Complements UEA (R.801): the A.3 substitute is canonical w.r.t. the A.4-equivalence class — two A.4-equivalent expert interventions share their meta-substitutes (substitute transport). Plus the `effExpert e X := expertKnowledge e ∩ K X` definition and its eligibility-iff-no-out-of-K characterisation. |
| `Agent1_A1A2A4_TrivialProblemCoverage.lean` | **A.1 ∧ A.2 (+ A.4)** | DISCOVERY | The always-true problem `p_T := fun _ => true` has *unconditional* coverage by every agent — no user input needed. The cleanest pairwise-axiom statement of the form "∀ X, ∃ R' ∈ ℛ(p), R' ⊆ K X". |

**Total: 9 DISCOVERY files, 0 OBSERVATION, 0 DEAD END.**

---

## Single most interesting result

`Agent1_A1A2_Phi0Coverage.N_trichotomy_under_coverage`:

> Under coverage (some `R' ∈ ℛ(p)` is covered by `K X`), exactly one of:
> - `Phi0 X p = 0  ∧  N p X = 0`, or
> - `Phi0 X p ≠ 0  ∧  0 < N p X < ⊤`.
>
> In other words, A.2 (coverage) removes the `N = ⊤` escape, and A.1 (Phi0 ↔ N=0 biconditional) then bivalently splits the remaining values along Phi0's zero/nonzero axis.

This is the cleanest A.1+A.2-combined characterisation. It is NOT in any existing corollary file and was not stated in the NL manuscript as far as the search detected. It strengthens C.1 (`coverage → N ≠ ⊤`) and C.2 (`N = ⊤ → ¬coverage`) into a **sharp dichotomy** of the finite values.

---

## Pairwise observations on richness

- **A.1+A.2** is unexpectedly rich — the trichotomy + the fact that no existing corollary uses A.1 left a wide-open seam. Three DISCOVERY-level statements emerged.
- **A.2+A.3** is *symmetric* in that both axioms target `⊆ K X`. This algebraic symmetry yielded a clean biconditional under a small realisability bridge. Two distinct files of substantive content.
- **A.3+A.4** is *partially saturated* — R.801 (UEA) already uses the combination heavily. The fresh angle was *canonical-form / substitute-transport*: the A.3 substitute is invariant under A.4-equivalence, not just produced by it.
- **A.2+A.4** is also partially saturated (R.815, R.813, L.F). The new ingredient: `essentialK` and the "doubly-blind tokens" formulation that explicitly conjoins both axioms' content.
- **A.1+A.3** was the *thinnest* combination. A.1 is a pure biconditional on `(N, Phi0)`; A.3 is about substitutability of expert interventions. Their natural meeting point is the trivial-problem case, where Phi0 = 0 is automatic. Found one good redundancy theorem.
- **A.1+A.4** combines the auto-solved class structure with A.4 invariance — produced two complementary files (one on the `BehavEq` propagation, one on the class-equality structure).

**Unexpectedly rich:** A.1+A.2 (because A.1 was untouched in existing corollaries).
**Unexpectedly barren:** A.1+A.3 (only the redundancy specialisation; A.1's `(N, Phi0)` biconditional and A.3's TV-bound machinery have no natural overlap except through the trivial-problem corner).

---

## File-naming and compilation

All files match `MIP/Discoveries/Agent1_*.lean`, all compiled with
```
lake env lean MIP/Discoveries/Agent1_<topic>.lean
```
from `C:\Users\12729\Desktop\Math\lean\MIP\`. All exit code 0, no warnings observed.
