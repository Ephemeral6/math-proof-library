/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: Three-agent extension of Cj.52 candidate uncertainty
             principle — REFUTED by the same constant-agent witness.
  SUMMARY:
    `Cj.52` (in `Conjectures/Cj52_UncertaintyPrinciple.lean`) refutes the
    specific candidate `N(X) · Var_P[N(·,X)] ≥ f > 0` via a single-agent
    constant-N witness (`Var_P[N] = 0` collapses the product to 0).

    The natural three-agent extension would be a *joint* product
    `N(A) · N(B) · N(C) · Var_P[N(·, A)] ≥ f > 0` (or any positive
    homogeneous polynomial that vanishes when one of the Var terms is
    zero). This is refuted by the same trick: a three-tuple where any
    one agent has zero variance gives a zero product.

    We formalize:
    (i)  `Cj52_three_candidate_Statement` — the three-agent product
         uncertainty principle.
    (ii) `Cj52_three_candidate_refuted` — refutation via the
         constant-variance agent (same witness as Cj.52).
    (iii)A concrete three-agent model where the refutation goes through.

    This is a clean, fully-proved REFUTATION at the three-agent level —
    the parallel of Cj.52's REFUTED verdict, lifted to the multi-agent
    setting.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

namespace MIP

namespace Agent8_ThreeAgent_Uncertainty

variable {Agent : Type*}

/-! ## (1) Three-agent model.

Each agent has its own `N · > 0` and `VarN · ≥ 0`. A "constant" agent
witnesses zero variance with positive `N`. (Mirrors `Cj52.Model`.) -/

/-- **Three-agent model.** Each agent `X` has `N X > 0` and `VarN X ≥ 0`;
a `constant` agent has `VarN = 0`. -/
structure ThreeModel (Agent : Type*) where
  N        : Agent → ℝ
  VarN     : Agent → ℝ
  hN_pos   : ∀ X, 0 < N X
  hVar_nn  : ∀ X, 0 ≤ VarN X
  constant : Agent
  hconst   : VarN constant = 0

/-! ## (2) The three-agent uncertainty principle candidate.

A natural three-agent extension: the *joint* product of N's times any
one variance is uniformly bounded below. -/

/-- **Three-agent UP candidate.** There is a uniform positive bound on
the product `N(A) · N(B) · N(C) · Var(A)` over all triples `(A, B, C)`.
(The variance of *one* agent multiplied by all three N's — capturing
"if A is uncertain, the joint cost is positive".) -/
def Cj52_three_candidate_Statement (M : ThreeModel Agent) : Prop :=
  ∃ f : ℝ, 0 < f ∧ ∀ A B C : Agent, f ≤ M.N A * M.N B * M.N C * M.VarN A

/-- **Three-agent UP candidate — REFUTED.** Pick `A = constant` (so
`Var A = 0`). Then the product is `0`, which cannot meet any positive
`f`. -/
theorem Cj52_three_candidate_refuted (M : ThreeModel Agent) :
    ¬ Cj52_three_candidate_Statement M := by
  rintro ⟨f, hf_pos, hbound⟩
  -- At triple (constant, constant, constant): VarN constant = 0
  have hprod : M.N M.constant * M.N M.constant * M.N M.constant * M.VarN M.constant = 0 := by
    rw [M.hconst, mul_zero]
  have hle : f ≤ M.N M.constant * M.N M.constant * M.N M.constant * M.VarN M.constant :=
    hbound M.constant M.constant M.constant
  rw [hprod] at hle
  linarith

/-! ## (3) Alternative formulation: ANY positional variance. -/

/-- **Three-agent UP candidate — positional variant (any of the three
agents carries the variance).** -/
def Cj52_three_candidate_anyPos (M : ThreeModel Agent) : Prop :=
  ∃ f : ℝ, 0 < f ∧ ∀ A B C : Agent,
    f ≤ M.N A * M.N B * M.N C * (M.VarN A + M.VarN B + M.VarN C)

/-- **Three-agent UP candidate (any position) — REFUTED.** Pick all
three to be the constant agent — every `VarN` term is zero. -/
theorem Cj52_three_candidate_anyPos_refuted (M : ThreeModel Agent) :
    ¬ Cj52_three_candidate_anyPos M := by
  rintro ⟨f, hf_pos, hbound⟩
  have hsum : M.VarN M.constant + M.VarN M.constant + M.VarN M.constant = 0 := by
    rw [M.hconst]; norm_num
  have hprod :
    M.N M.constant * M.N M.constant * M.N M.constant
      * (M.VarN M.constant + M.VarN M.constant + M.VarN M.constant) = 0 := by
    rw [hsum, mul_zero]
  have hle :
    f ≤ M.N M.constant * M.N M.constant * M.N M.constant
        * (M.VarN M.constant + M.VarN M.constant + M.VarN M.constant) :=
    hbound M.constant M.constant M.constant
  rw [hprod] at hle
  linarith

/-! ## (4) Concrete witness model. -/

/-- **Concrete witness.** A `Unit`-agent model where the unique agent
has `N = 1`, `VarN = 0`. -/
def constModel3 : ThreeModel Unit where
  N        := fun _ => 1
  VarN     := fun _ => 0
  hN_pos   := by intro _; norm_num
  hVar_nn  := by intro _; norm_num
  constant := ()
  hconst   := rfl

/-- **Concrete refutation, product form.** -/
theorem Cj52_three_candidate_refuted_concrete :
    ¬ Cj52_three_candidate_Statement constModel3 :=
  Cj52_three_candidate_refuted constModel3

/-- **Concrete refutation, sum form.** -/
theorem Cj52_three_candidate_anyPos_refuted_concrete :
    ¬ Cj52_three_candidate_anyPos constModel3 :=
  Cj52_three_candidate_anyPos_refuted constModel3

/-! ## (5) Sharp form. -/

/-- **Sharp form (three-agent).** The product is exactly `0` at the
constant-agent triple — there is *no* positive lower bound at all. -/
theorem Cj52_three_constant_product_zero (M : ThreeModel Agent) :
    M.N M.constant * M.N M.constant * M.N M.constant * M.VarN M.constant = 0 := by
  rw [M.hconst, mul_zero]

end Agent8_ThreeAgent_Uncertainty

end MIP
