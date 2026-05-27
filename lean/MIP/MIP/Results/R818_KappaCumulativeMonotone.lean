/-
Result R.818 — Correction of contextual monotonicity.
Reference: branches/collaboration_dynamics/results/intervention_effects.md (A-grade, audited 2026-05-27).

**Statement.** Pointwise `κ(X | h·m) ≥ κ(X | h)` does NOT hold unconditionally: a narrowing
("focus on a single concept") metacognitive intervention `m ∈ M` can de-activate a previously
co-occurring pair `(ω₁,ω₂)`, lowering the contextual closure `κ(X | h·m) < κ(X | h)`.  The
correct monotone carrier is the *cumulative* `κ̄` (D.3.20.b), which is constructively monotone
because the history-union of realised co-occurrence pairs only grows.

**Kernel formalized here.**
1. *Counterexample to pointwise monotonicity.*  Concrete finite model `Ω = Fin 3`,
   `K = {0,1,2}` (so `|K|² = 9`).  Two contexts modelled by their realised contextual
   co-occurrence relations `R_∘(X|h)` as explicit `Finset (Fin 3 × Fin 3)`:
   `before` realises the pair `(0,1)` (plus reflexive pairs), `after := before \ {(0,1)}`
   (the narrowing intervention removes it).  Then `κ(X|h·m) < κ(X|h)` because
   `|after| < |before|`.  This refutes the unconditional pointwise inequality.
2. *Cumulative κ̄ is monotone.*  The cumulative relation is a monotone union
   `R̄_∘(X | h·…) = ⋃_{i ≤ t} (pairs realised at response i)`; appending an intervention can
   only add a response, so the union (hence `|R̄_∘| / |K|²`) never decreases.  We prove
   `κ̄(after) ≥ κ̄(before)` whenever `before ⊆ after` (union growth), via
   `Finset.card_le_card`.

**Bridge.** Step 1 is the literal narrowing counterexample (D.3.20 κh-3); step 2 is the
`Finset`-union monotonicity that makes cumulative κ̄ the correct monotone carrier (D.3.20.b κ̄-1).
Axiom-free (only A.1–A.4; this file needs none — it is a pure finite-model statement).
-/
import MIP.Axioms
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Prod
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

namespace MIP

namespace R818_KappaCumulativeMonotone

/-- Contextual closure density `κ(X | h) := |R_∘(X|h)| / |K|²` given a finite knowledge
space `K` and the realised contextual co-occurrence relation `reachSet := R_∘(X|h)`. -/
noncomputable def κctx {Ω : Type} (K : Finset Ω) (reachSet : Finset (Ω × Ω)) : ℝ :=
  reachSet.card / (K.card : ℝ) ^ 2

/-! ## Part 1 — Counterexample: pointwise `κ(X|h·m) ≥ κ(X|h)` can fail

Knowledge space `K = {0,1,2} ⊆ Fin 3`, so `|K|² = 9`.  Context `h` realises pairs
`before := {(0,0),(1,1),(2,2),(0,1)}` (reflexive diagonal + the cross pair `(0,1)`).
A narrowing intervention `m` ("answer with a single concept") de-activates `(0,1)`,
giving `after := {(0,0),(1,1),(2,2)}`.  Then `κctx K after < κctx K before`. -/

/-- The knowledge space `K = {0,1,2} ⊆ Fin 3`. -/
def Kfin : Finset (Fin 3) := {0, 1, 2}

/-- Contextual relation before the narrowing intervention: diagonal + the cross pair `(0,1)`. -/
def beforeSet : Finset (Fin 3 × Fin 3) := {(0, 0), (1, 1), (2, 2), (0, 1)}

/-- Contextual relation after the narrowing intervention `m`: the cross pair `(0,1)` is gone. -/
def afterSet : Finset (Fin 3 × Fin 3) := {(0, 0), (1, 1), (2, 2)}

/-- `|K| = 3`. -/
theorem Kfin_card : Kfin.card = 3 := by decide

/-- `|before| = 4`. -/
theorem beforeSet_card : beforeSet.card = 4 := by decide

/-- `|after| = 3`. -/
theorem afterSet_card : afterSet.card = 3 := by decide

/-- **R.818 (counterexample).**  In the finite model, the narrowing intervention strictly
lowers the pointwise contextual closure: `κ(X | h·m) < κ(X | h)`.  Concretely
`κctx Kfin afterSet = 3/9 < 4/9 = κctx Kfin beforeSet`. -/
theorem R_818_pointwise_monotone_fails :
    κctx Kfin afterSet < κctx Kfin beforeSet := by
  unfold κctx
  rw [Kfin_card, beforeSet_card, afterSet_card]
  norm_num

/-- **R.818 (counterexample, explicit witness form).**  There exist a finite knowledge space,
a "before" contextual relation and an "after" (= narrowed) contextual relation with
`κ(X | h·m) < κ(X | h)` — refuting the unconditional pointwise inequality
`κ(X | h·m) ≥ κ(X | h)`. -/
theorem R_818_exists_narrowing_counterexample :
    ∃ (K : Finset (Fin 3)) (before after : Finset (Fin 3 × Fin 3)),
      κctx K after < κctx K before := by
  exact ⟨Kfin, beforeSet, afterSet, R_818_pointwise_monotone_fails⟩

/-! ## Part 2 — Cumulative κ̄ is monotone

The cumulative contextual relation `R̄_∘(X | h)` is a union over realised responses; appending
an intervention only adds responses, so `R̄_∘` grows (`before ⊆ after`).  Hence the cumulative
density `κ̄ = |R̄_∘| / |K|²` is monotone. -/

/-- **R.818 (cumulative monotone).**  If the cumulative reachable-pair set only grows
(`before ⊆ after`, the constructive content of D.3.20.b κ̄-1), then the cumulative closure
is monotone: `κ̄(after) ≥ κ̄(before)`. -/
theorem R_818_cumulative_monotone {Ω : Type} [DecidableEq Ω]
    (K : Finset Ω) (before after : Finset (Ω × Ω))
    (hsub : before ⊆ after) :
    κctx K before ≤ κctx K after := by
  unfold κctx
  have hcard : (before.card : ℝ) ≤ (after.card : ℝ) := by
    exact_mod_cast Finset.card_le_card hsub
  have hden : (0 : ℝ) ≤ (K.card : ℝ) ^ 2 := by positivity
  exact div_le_div_of_nonneg_right hcard hden

/-- **R.818 (cumulative monotone along a chain).**  For a monotone chain of cumulative
reachable-pair sets `reach : ℕ → Finset (Ω×Ω)`, the cumulative closure `κ̄ n` is monotone
in `n`. -/
theorem R_818_cumulative_chain_monotone {Ω : Type} [DecidableEq Ω]
    (K : Finset Ω) (reach : ℕ → Finset (Ω × Ω)) (hmono : Monotone reach) :
    Monotone (fun n => κctx K (reach n)) := by
  intro a b hab
  exact R_818_cumulative_monotone K (reach a) (reach b) (hmono hab)

end R818_KappaCumulativeMonotone

end MIP
