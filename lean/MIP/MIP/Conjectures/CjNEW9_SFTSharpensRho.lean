/-
Conjecture Cj.NEW-9 — SFT/RLHF monotonically sharpen `ρ` (and raise `μ₀`).

Source: `~/Desktop/MIP/conjectures/index.md` lines ~604-641;
supporting derivation `workspace/mu0_measurement_theory.md` §1, §6 (P2).

Natural-language conjecture
---------------------------
Let `X_pre, X_SFT, X_RLHF` be the three training-stage products of one
base model.  The conjecture: every stage of the pipeline
(pretrain → SFT → RLHF) monotonically *sharpens* the shape of `γ_X`:
for all moderate `ε` (e.g. `ε ∈ [0.01, 0.1]`),

    ρ_{X_pre}(ε) ≥ ρ_{X_SFT}(ε) ≥ ρ_{X_RLHF}(ε)

and `μ₀` is strictly monotone increasing:

    μ₀(X_pre) < μ₀(X_SFT) < μ₀(X_RLHF) .

Mechanistic gloss (index l.618-620): SFT reshapes the base's continuous
distribution into a bimodal one (`ρ ↓`, `μ₀ ↑`); RLHF moves the "low"
peak's salvageable problems into the "high" peak (`ρ` further ↓, `μ₀`
further ↑).

Formalization choices & honest assessment
-----------------------------------------
This is an **empirical training claim**.  Settling it requires the actual
SFT/RLHF update operators and a proof that each is `ρ`-nonincreasing /
`μ₀`-increasing on the relevant distribution `P`.  The MIP knowledge
layer exposes no model of the SFT/RLHF operators or of how a training
step transforms `p_X`, so the substantive content is **out of reach**
here.

What is provable is only the *chain assembly*: IF each stage operator is
`ρ`-nonincreasing and `μ₀`-strictly-increasing, THEN the three-stage
chain is ordered.  That is mere transitivity of `≥` / `<` and is a
**noted triviality** — by the anti-strawman rule it does NOT count as
settling the conjecture.

We therefore record both, clearly labelled, and the honest VERDICT is
OPEN.

VERDICT
=======
* **OPEN.**
  - Provable (NOTED TRIVIALITY, not the conjecture): the chain-transitivity
    `CjNEW9_chain` — given per-stage monotonicity hypotheses, the
    `pre ⪰ SFT ⪰ RLHF` ordering of `ρ` and the strict `<` ordering of `μ₀`
    follow by transitivity.  This is a strawman of the real claim.
  - BLOCKED AT: proving that any concrete training operator is
    `ρ`-nonincreasing (resp. `μ₀`-increasing).
  - MISSING: a formal model of the SFT / RLHF update rule acting on the
    activation distribution `p_X` (and hence on `ρ = γ_X(ε)` and
    `μ₀ = Pr_P[p_X = 1]`).  Sub-questions (a)-(d) (base/instruct
    falsification test, stage ordering, mechanism, link to multi-task
    decay) all depend on this missing model.

No `sorry`-backed theorem asserts the conjecture itself.  This file is
`sorry`-free and `axiom`-free (no new axioms; only the ambient
Lean/Mathlib axioms).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP
namespace CjNEW9

/-- A training-stage summary: the two scalar observables of D.3.15/D.3.16
attached to a model, `ρ = γ_X(ε)` (grey-band width at the fixed band
parameter `ε`) and `μ₀` (absolutely-reliable mass).  We keep them as
abstract reals carried by each stage; we do NOT model the operator that
produces them (that is the missing piece). -/
structure StageObs where
  /-- `ρ = γ_X(ε)` at the fixed moderate band parameter. -/
  ρ : ℝ
  /-- `μ₀ = Pr_P[p_X = 1]`. -/
  μ₀ : ℝ

/-- An abstract training operator on stage observables (the *type* of
`T_SFT`, `T_RLHF`).  Its action on `(ρ, μ₀)` is unconstrained — modelling
the genuine update rule is exactly what is MISSING. -/
def TrainingOp : Type := StageObs → StageObs

/-- "`T` is `ρ`-nonincreasing": it never increases the grey-band width.
This is the per-stage hypothesis the conjecture *asserts* but which
cannot be established here for any concrete `T`. -/
def RhoNonincreasing (T : TrainingOp) : Prop :=
  ∀ s : StageObs, (T s).ρ ≤ s.ρ

/-- "`T` is `μ₀`-strictly-increasing": it strictly raises the
absolutely-reliable mass.  Again a per-stage hypothesis, not derivable
here. -/
def Mu0StrictIncreasing (T : TrainingOp) : Prop :=
  ∀ s : StageObs, s.μ₀ < (T s).μ₀

/-- **NOTED TRIVIALITY (not the conjecture).** Chain assembly: given that
both stage operators `T_SFT, T_RLHF` are `ρ`-nonincreasing and
`μ₀`-strictly-increasing, the three-stage chain
`pre → SFT = T_SFT pre → RLHF = T_RLHF SFT` is ordered:

    ρ_pre ≥ ρ_SFT ≥ ρ_RLHF      and      μ₀_pre < μ₀_SFT < μ₀_RLHF .

This is pure transitivity of `≤` / `<`; it does NOT settle Cj.NEW-9,
because its hypotheses (`RhoNonincreasing`, `Mu0StrictIncreasing`) are
precisely the unproven empirical content.  Recorded for honesty per the
anti-strawman rule. -/
theorem CjNEW9_chain
    (T_SFT T_RLHF : TrainingOp)
    (hρ_SFT : RhoNonincreasing T_SFT) (hρ_RLHF : RhoNonincreasing T_RLHF)
    (hμ_SFT : Mu0StrictIncreasing T_SFT) (hμ_RLHF : Mu0StrictIncreasing T_RLHF)
    (pre : StageObs) :
    let sft := T_SFT pre
    let rlhf := T_RLHF sft
    (rlhf.ρ ≤ sft.ρ ∧ sft.ρ ≤ pre.ρ) ∧ (pre.μ₀ < sft.μ₀ ∧ sft.μ₀ < rlhf.μ₀) := by
  intro sft rlhf
  refine ⟨⟨hρ_RLHF sft, hρ_SFT pre⟩, ⟨hμ_SFT pre, hμ_RLHF sft⟩⟩

/-- Faithful `Prop`-level statement of Cj.NEW-9 (the substantive claim).
There EXIST concrete SFT/RLHF operators that are simultaneously
`ρ`-nonincreasing and `μ₀`-strictly-increasing on every stage — i.e. the
empirical sharpening law holds with witnesses.

We do **not** prove or refute this: it is OPEN.  The statement is stated
faithfully so the verdict is auditable.  (Note: this is the existential
"the pipeline really sharpens" reading; the conjecture is about the
specific real pipeline operators, which the MIP layer does not expose.) -/
def CjNEW9_Statement : Prop :=
  ∃ (T_SFT T_RLHF : TrainingOp),
    RhoNonincreasing T_SFT ∧ RhoNonincreasing T_RLHF ∧
    Mu0StrictIncreasing T_SFT ∧ Mu0StrictIncreasing T_RLHF

/-
Why we do not discharge `CjNEW9_Statement` here.

One *could* exhibit a toy operator (e.g. `fun s => ⟨s.ρ, s.μ₀ + 1⟩`,
which trivially satisfies both predicates) and thereby make
`CjNEW9_Statement` provable.  That would be a STRAWMAN: it proves the
abstract existential, not the empirical claim about the actual SFT/RLHF
pipeline.  Per the anti-strawman rule we deliberately leave
`CjNEW9_Statement` undischarged and mark the conjecture OPEN, with the
missing ingredient being a faithful model of the real update operators.
The genuine sharpening on concrete operators is BLOCKED AT / MISSING as
documented above.
-/

end CjNEW9
end MIP
