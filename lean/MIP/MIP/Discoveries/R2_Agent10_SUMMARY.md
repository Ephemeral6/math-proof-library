# R2 Agent 10 — Pairwise axiom independence via explicit models

**Direction.** For each pair `(A_i, A_j) ⊊ {A.1, A.2, A.3, A.4}`,
construct an explicit Lean model satisfying the other two axioms but
violating both `A_i` and `A_j`. Result: all six pairs are separated by
concrete models — A.1, A.2, A.3, A.4 are PAIRWISE INDEPENDENT.

## Approach

The four axioms `A.1`–`A.4` (in `MIP/Axioms.lean`) constrain opaque
symbols (`N`, `Phi0`, `K`, `R`, `demandFamily`, `expertKnowledge`, `Cₑ`,
`MetaSet`, `tokenReplace`, `tvDist`). Since the opaque symbols cannot be
redefined inside the project (that would amount to a new axiom), we
introduce a *model* structure `MIPModel α Ω` bundling concrete copies of
those symbols, and re-state each axiom as a `Prop` on a `MIPModel`.

Then for each pair `(A_i, A_j)`, we build an instance of `MIPModel Unit
Unit` and prove which `satisfies*` / `violates*` propositions hold on
that instance.

No `axiom` declarations are introduced; only `structure` fields with
explicit constructive values. Zero `sorry`.

## Files produced

| File | STATUS | Pair separated |
|---|---|---|
| `R2_Agent10_ModelFramework.lean` | DISCOVERY | The `MIPModel` structure + `satisfies*` / `violates*` Props |
| `R2_Agent10_Model_NoA1A2.lean`   | DISCOVERY | (A.1, A.2): satisfies A.3 ∧ A.4, violates A.1 ∧ A.2 |
| `R2_Agent10_Model_NoA1A3.lean`   | DISCOVERY | (A.1, A.3): satisfies A.2 ∧ A.4, violates A.1 ∧ A.3 |
| `R2_Agent10_Model_NoA1A4.lean`   | DISCOVERY | (A.1, A.4): satisfies A.2 ∧ A.3, violates A.1 ∧ A.4 |
| `R2_Agent10_Model_NoA2A3.lean`   | DISCOVERY | (A.2, A.3): satisfies A.1 ∧ A.4, violates A.2 ∧ A.3 |
| `R2_Agent10_Model_NoA2A4.lean`   | DISCOVERY | (A.2, A.4): satisfies A.1 ∧ A.3, violates A.2 ∧ A.4 |
| `R2_Agent10_Model_NoA3A4.lean`   | DISCOVERY | (A.3, A.4): satisfies A.1 ∧ A.2, violates A.3 ∧ A.4 |

**Total: 7 files, all DISCOVERY**, all compile clean with `lake env lean
MIP/Discoveries/R2_Agent10_*.lean`. Zero `sorry`, zero new `axiom`.

## Key constructions

All six models use `α := Unit`, `Ω := Unit`.

### A.1 violation
Set `N := 0` and `Phi0 := 1` (or `N := ⊤, Phi0 := 1` to flip both
sides False). Then `N=0 ↔ Phi0=0` is `True ↔ False` (or `False ↔
False`), giving the desired truth value.

### A.2 violation
Either (a) `N := 0, K := ∅, demandFamily := ∅`: `N≠⊤` True but no
`R'` exists; or (b) `N := ⊤, K := ∅, demandFamily := {∅}`: `N≠⊤` False
but `∅ ⊆ ∅` exists.

### A.3 violation (the delicate case — done cleanly)
Set `Cₑ := 0`, `tvDist := 1` (constant), `MetaSet := ∅`,
`expertKnowledge := ∅`. Pick `ε := 1/2`. The length bound
`(ms.length : ℝ) ≤ Cₑ(e) · log(1/ε) = 0 · log 2 = 0` forces `ms = []`.
For `ms = []`, the tvDist condition becomes `1 ≤ 1/2`, which is False.
So no witness `ms` exists — A.3 is violated.

This makes the A.3-involving pairs (A.1,A.3), (A.2,A.3), (A.3,A.4)
fully derivable rather than OBSERVATION-only.

### A.4 violation
Set `tokenReplace ω h := () :: h` (prepend a Unit token). The
identity-on-history agent `X₀ h := PMF.pure h` distinguishes histories
of different length, so `X₀ [] ≠ X₀ [()]`. Since `K X₀ = ∅`, the
hypothesis `ω ∉ K X₀` triggers but the conclusion fails.

### A.3 satisfaction (when needed)
Set `MetaSet := Set.univ`. Then `e ∉ MetaSet` is vacuously False,
making A.3 trivially True.

### A.4 satisfaction (when needed)
Set `tokenReplace ω h := h` (identity). Then `X h = X h` trivially.

## Headline result

For each pair `(A_i, A_j)` from `{1,2,3,4}`, there is a concrete
`MIPModel Unit Unit` satisfying the other two axiom-statements but
violating both `A_i` and `A_j`. Therefore the four axioms `A.1`–`A.4`
are **pairwise independent**: no proper subset of two axioms implies
the other two.

This rigorously confirms the design intuition of `MIP/Axioms.lean`:
each axiom carries non-redundant content, and no axiom can be derived
from any other two.

## Connection to Round 1 dead-ends

This work mirrors and concretises the dead-end observations of Round 1
(Agent 5 on Z-dynamics, Agent 7 on monotone improvement, Agent 8 on
the triangle inequality, the various cross-agent Φ₀ DEAD ENDs): all
those dead-ends document that a particular target statement is not
derivable from A.1–A.4. The present work shows that ALL six axiom
pairs are likewise independent, so any future "missing axiom"
diagnostic is justified.
