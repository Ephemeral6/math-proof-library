/-
Conjecture Cj.40 — The human's core advantage over AI is κ (combinatorial
closure).

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.40, lines ~82, ~99, ~822;
原编号 R.52). Related: R.134 (`R134_NStarUShape.lean`) gives the *complementary*
alignment-window picture `t* = inf{t : K^M(A_t) ⊇ K^M(H)}`; R.42
(`R42_KappaMeasurable.lean`) for κ measurability; R.818
(`R818_KappaCumulativeMonotone.lean`) for the `κ := |R_∘ ∩ K²| / |K|²` model.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
The human's *core* advantage over AI is `κ`, the combinatorial-closure density
of the knowledge space (D.3.7): even as AI surpasses humans on raw capability
(knowledge-set size `|K|`, impedance `Z`, etc.), there is a regime in which the
human's `κ(H)` strictly dominates the AI's `κ(A)`, and this κ-gap is what the
human retains.  R.134 supplies the complementary alignment-window image
(`t* = inf{t : K^M(A_t) ⊇ K^M(H)}`); the **quantitative human-vs-AI κ
comparison** ("human κ > AI κ in a precise, axiom-derived sense") is the open
content.

================================================================================
FORMALIZATION CHOICES
================================================================================
Following the R.818 model, κ of an agent with knowledge space `K` (a finite
subset of `Ω`) and realised composition relation `R_∘ ⊆ K × K` is

    κ(K, R_∘) := |R_∘| / |K|²   ∈ [0, 1].

We model a two-agent pool `{H, A}` (human, AI), each carrying:
  * `Kcard : ℝ`  — capability proxy `|K|` (the "capability gap" axis);
  * `kappa : ℝ`  — combinatorial closure `κ` (the "advantage" axis).

"Human advantage = κ" is formalized as the existence of a regime (a witness
pool) where:
  (i)  the AI strictly dominates on *capability* (`Kcard A > Kcard H`) — i.e. the
       AI has "won" the raw-knowledge race; yet
  (ii) the human strictly dominates on *κ* (`kappa H > kappa A`) — the human's
       closure advantage survives the capability gap.

This is the faithful "∃ regime where κ(H) dominates the capability gap":
the κ-ordering is *opposite* to the capability ordering, so κ is a genuinely
independent advantage axis that the human keeps even after losing on capability.

================================================================================
VERDICT: OPEN.
================================================================================
PROVEN PARTIAL (sorry-free below):
  * `Cj40_kappa_separation_abstract` — the abstract separation: if the AI beats
    the human on capability while the human beats the AI on κ, the κ-maximizer
    and the capability-maximizer are *distinct* agents (the κ-advantage is not
    the capability-advantage).
  * `Cj40_witness_regime` — a concrete two-agent witness pool realising the
    regime: `Kcard A = 2 > 1 = Kcard H` (AI wins capability) but
    `kappa H = 4/9 > 1/9 = kappa A` (human wins κ), built from explicit finite
    `R_∘ ⊆ K²` relations à la R.818.

BLOCKED AT (why the full conjecture is OPEN):
The full Cj.40 asserts that the human's κ-advantage is the *core* / *defining*
advantage — i.e. a quantitative claim `κ(H) > κ(A)` that holds for the actual
human and the actual (sufficiently advanced) AI, derived from A.1–A.4.  This
needs a formal *human-vs-AI κ comparison metric* — a way to compare the closure
densities of two specific agents arising from training dynamics — which is NOT
in the axioms (A.1–A.4 say nothing about how κ of a human compares to κ of an
AI; D.3.7 only defines κ as a per-agent quantity).  R.134 gives a complementary
*alignment-window* characterisation but not the κ inequality.  Without an
axiom-level statement relating human and AI training to their κ values, the
inequality `κ(H) > κ(A)` can be *realised* (as below) but not *forced*.  Hence
OPEN, with the realisability separation proven.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

namespace MIP

namespace Cj40KappaAdvantage

/-! ## The κ model (à la R.818): `κ(K, R_∘) := |R_∘| / |K|²`. -/

/-- Combinatorial closure density `κ := |R_∘| / |K|²` for a finite knowledge
space `K` and a realised composition relation `R_∘ ⊆ K × K`. -/
noncomputable def kappaOf {Ω : Type} (K : Finset Ω) (Rcomp : Finset (Ω × Ω)) : ℝ :=
  Rcomp.card / (K.card : ℝ) ^ 2

/-! ## Abstract two-agent comparison pool.

Each agent carries a capability proxy `Kcard = |K|` and a closure density
`kappa = κ`.  These are independent observables (D.3.7 / D.1.3). -/

/-- A pool of agents, each carrying a capability proxy `Kcard` (the size of the
knowledge space, the "capability gap" axis) and a combinatorial closure `kappa`
(the conjectured "human advantage" axis). -/
structure ComparisonPool (ι : Type*) where
  /-- Capability proxy `|K(a)|`; "raw knowledge". -/
  Kcard : ι → ℝ
  /-- Combinatorial closure `κ(a)`; the conjectured human advantage. -/
  kappa : ι → ℝ

variable {ι : Type*}

/-- `a` is a capability-maximizer (a "strongest AI" on raw knowledge). -/
def IsCapMaximizer (pool : ComparisonPool ι) (a : ι) : Prop :=
  ∀ b, pool.Kcard b ≤ pool.Kcard a

/-- `a` is a κ-maximizer (the conjectured "best on the advantage axis"). -/
def IsKappaMaximizer (pool : ComparisonPool ι) (a : ι) : Prop :=
  ∀ b, pool.kappa b ≤ pool.kappa a

/-- **Cj.40 — abstract κ-separation.**

If agent `A` strictly beats `H` on capability (`Kcard H < Kcard A`) while `H`
strictly beats `A` on κ (`kappa A < kappa H`), then a capability-maximizer `A`
and a κ-maximizer `H` are necessarily *distinct* agents.  Hence the κ-advantage
(maximizing κ) is a genuinely different axis from the capability-advantage
(maximizing `|K|`): "human advantage = κ" is not reducible to a capability
claim.  (Proof: if `A = H` then `kappa A < kappa A`, absurd.) -/
theorem Cj40_kappa_separation_abstract
    (pool : ComparisonPool ι) (H A : ι)
    (_hCap : pool.Kcard H < pool.Kcard A)
    (hKappa : pool.kappa A < pool.kappa H)
    (_hAcap : IsCapMaximizer pool A)
    (_hHkappa : IsKappaMaximizer pool H) :
    A ≠ H := by
  intro hAH
  rw [hAH] at hKappa
  exact lt_irrefl _ hKappa

/-! ## Concrete witness regime.

`Bool`-indexed pool: `false ↦ H` (human), `true ↦ A` (AI).

We instantiate κ from explicit finite composition relations on `Ω = Fin 3`,
exactly as R.818 models `κ := |R_∘| / |K|²`:

* Human `H`: small knowledge `K_H = {0}`, but rich self-composition — we model a
  *dense* closure by taking `|K_H| = 3` worth of co-occurrence structure scaled
  so that `κ(H) = 4/9` (the same `before`-relation value as R.818's `4/9`).
* AI `A`: large knowledge `K_A` with `|K_A| = 2 > 1`, but *sparse* closure:
  `κ(A) = 1/9`.

To keep the κ values concrete and grounded in the `|R_∘| / |K|²` model while
making the capability ordering opposite to the κ ordering, we encode them
directly as the realised relation-cardinalities over a common `|K|² = 9` board:
`κ(H) = 4/9`, `κ(A) = 1/9`, with capability `Kcard H = 1 < 2 = Kcard A`. -/

/-- Knowledge board size used for both κ values: `|K|² = 9` (board `Fin 3`). -/
def boardSq : ℝ := 9

/-- Human's realised composition relation (4 realised pairs), à la R.818
`beforeSet`: dense closure. -/
def humanRcomp : Finset (Fin 3 × Fin 3) := {(0, 0), (1, 1), (2, 2), (0, 1)}

/-- AI's realised composition relation (1 realised pair): sparse closure. -/
def aiRcomp : Finset (Fin 3 × Fin 3) := {(0, 0)}

/-- The shared knowledge board `K = {0,1,2} ⊆ Fin 3`, so `|K| = 3`, `|K|² = 9`. -/
def Kboard : Finset (Fin 3) := {0, 1, 2}

theorem Kboard_card : Kboard.card = 3 := by decide
theorem humanRcomp_card : humanRcomp.card = 4 := by decide
theorem aiRcomp_card : aiRcomp.card = 1 := by decide

/-- `κ(H) = 4/9` from the dense human relation. -/
theorem kappa_human_val : kappaOf Kboard humanRcomp = 4 / 9 := by
  unfold kappaOf
  rw [humanRcomp_card, Kboard_card]
  norm_num

/-- `κ(A) = 1/9` from the sparse AI relation. -/
theorem kappa_ai_val : kappaOf Kboard aiRcomp = 1 / 9 := by
  unfold kappaOf
  rw [aiRcomp_card, Kboard_card]
  norm_num

/-- The witness pool: `false ↦ H`, `true ↦ A`.  Capability favors AI
(`Kcard A = 2 > 1 = Kcard H`); κ favors human (`κ H = 4/9 > 1/9 = κ A`). -/
noncomputable def witnessPool : ComparisonPool Bool where
  Kcard := fun a => if a then 2 else 1                       -- A = 2, H = 1
  kappa := fun a => if a then kappaOf Kboard aiRcomp
                         else kappaOf Kboard humanRcomp        -- A = 1/9, H = 4/9

/-- In the witness pool, the AI (`true`) is the capability-maximizer. -/
theorem witness_ai_max_cap : IsCapMaximizer witnessPool true := by
  intro b
  simp only [witnessPool]
  cases b <;> norm_num

/-- In the witness pool, the human (`false`) is the κ-maximizer. -/
theorem witness_human_max_kappa : IsKappaMaximizer witnessPool false := by
  intro b
  simp only [witnessPool]
  cases b
  · -- b = false: κ H ≤ κ H
    exact le_refl _
  · -- b = true: κ A ≤ κ H, i.e. 1/9 ≤ 4/9
    rw [kappa_human_val, kappa_ai_val]; norm_num

/-- **Cj.40 — concrete witness regime (PROVEN PARTIAL).**

There exists a two-agent regime (human `H`, AI `A`) in which:
  * the AI strictly dominates on capability: `Kcard H < Kcard A` (1 < 2);
  * the human strictly dominates on κ: `kappa A < kappa H` (1/9 < 4/9);
  * `A` is the capability-maximizer and `H` is the κ-maximizer;
  * hence `A ≠ H`: the κ-advantage axis is genuinely distinct from capability.

This *realises* "the human's advantage is κ" — the κ-ordering survives (indeed
opposes) the capability gap.  It does NOT *force* it for the actual human/AI;
see BLOCKED AT. -/
theorem Cj40_witness_regime :
    ∃ H A : Bool,
      witnessPool.Kcard H < witnessPool.Kcard A ∧   -- AI wins capability
      witnessPool.kappa A < witnessPool.kappa H ∧   -- human wins κ
      IsCapMaximizer witnessPool A ∧
      IsKappaMaximizer witnessPool H ∧
      A ≠ H := by
  refine ⟨false, true, ?_, ?_, witness_ai_max_cap, witness_human_max_kappa, by decide⟩
  · simp only [witnessPool]; norm_num
  · simp only [witnessPool]; rw [kappa_human_val, kappa_ai_val]; norm_num

/-- **Cj.40 statement (the faithful conjecture as a `Prop`).**

"Human advantage = κ": there is a comparison regime (over some index type `ι`,
with a human `H` and an AI `A`) in which the AI has won the capability race
(`Kcard H < Kcard A`) yet the human strictly dominates on κ
(`kappa A < kappa H`), with `A` the capability-maximizer and `H` the
κ-maximizer.  The κ-advantage is the human's surviving, distinct advantage. -/
def Cj40_Statement : Prop :=
  ∃ (ι : Type) (pool : ComparisonPool ι) (H A : ι),
    pool.Kcard H < pool.Kcard A ∧
    pool.kappa A < pool.kappa H ∧
    IsCapMaximizer pool A ∧
    IsKappaMaximizer pool H ∧
    A ≠ H

/-- The statement is *realisable* (witnessed by the concrete pool): this is the
proven partial content of Cj.40.  The full conjecture (the inequality holding
for the actual human and AI, forced by A.1–A.4) is OPEN — see BLOCKED AT. -/
theorem Cj40_Statement_realisable : Cj40_Statement :=
  ⟨Bool, witnessPool, false, true,
    by simp only [witnessPool]; norm_num,
    by simp only [witnessPool]; rw [kappa_human_val, kappa_ai_val]; norm_num,
    witness_ai_max_cap, witness_human_max_kappa, by decide⟩

end Cj40KappaAdvantage

end MIP
