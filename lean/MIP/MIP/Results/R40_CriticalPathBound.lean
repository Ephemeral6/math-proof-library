/-
Result R.40 — `N ≥ L(G)`, the critical-path (longest-path) lower bound.

Reference: `proofs/derived/R40.md` and `proofs/derived/A_grade.md` R.40
(A 级, depends on D.2.10 barrier DAG, T.1, L.5).

**Statement.** Let `G(p) = (B(p), E)` be the barrier dependency DAG and
`L(G)` its longest-path (critical-path) length. Then the number of
interventions satisfies `N(p, A) ≥ L(G)`.

**NL core.** A dependency chain `b_0 ≺ b_1 ≺ … ≺ b_{k-1}` of length `k`
forces at least `k` sequential interventions: by the DAG edge semantics
(D.2.10), `b_i` must be broken before `b_{i+1}` can even be addressed, and
by L.5 each chain link consumes at least one distinct intervention step
(adjacent links cannot be merged into a single step without contradicting
the dependency edge). Taking the longest chain gives `N ≥ L(G)`.

**Lightweight encoding (no DAG library).** We model "a dependency chain of
length `k` whose links each consume a distinct one of the `N` intervention
steps" as an *injective* function `f : Fin k → Fin N`: chain level `i` is
mapped to the intervention index `f i`, and injectivity is exactly the
"each link needs its own intervention step" property of the NL argument
(distinct links never share an intervention). The conclusion `k ≤ N` is
then the pigeonhole bound `Fintype.card (Fin k) ≤ Fintype.card (Fin N)`,
i.e. `card_le_of_injective`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Fintype.Card
import Mathlib.Logic.Function.Basic

namespace MIP

namespace CriticalPathBound

/-- **R.40 — chain-length lower bound (lightweight kernel).**

If the `k` links of a dependency chain map injectively into the `N`
intervention steps (each link consumes its own distinct intervention),
then `k ≤ N`.

Pigeonhole: an injection `Fin k → Fin N` forces
`k = Fintype.card (Fin k) ≤ Fintype.card (Fin N) = N`. -/
theorem R_40_chain_le_steps {k N : ℕ} (f : Fin k → Fin N)
    (hf : Function.Injective f) : k ≤ N := by
  have h := Fintype.card_le_of_injective f hf
  simpa using h

/-- **R.40 — critical-path lower bound `L ≤ N`.**

If the critical path has length `L` and its links inject into the `N`
intervention steps (D.2.10 dependency semantics + L.5: each link needs its
own intervention), then `L ≤ N`. This is the geometric depth lower bound:
reasoning depth `L(G)` bounds `N` from below regardless of total barrier
count `|B|`. -/
theorem R_40_critical_path_bound {L N : ℕ} (f : Fin L → Fin N)
    (hf : Function.Injective f) : L ≤ N :=
  R_40_chain_le_steps f hf

end CriticalPathBound

end MIP
