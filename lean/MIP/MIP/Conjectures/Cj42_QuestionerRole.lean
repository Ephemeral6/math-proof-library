/-
Conjecture Cj.42 — The human's optimal role is "questioner" (not solver).

Reference: `~/Desktop/MIP/conjectures/index.md` (Cj.42, lines ~84, ~99;
原编号 R.54): "人的最优角色是 questioner；依赖 Cj.40 和 E 级 R.49；R.134.a（教育
悖论）反向支持：'最强 AI 不是最好老师' 的精确化."  Seed: R.19
(`R19_OptimalQuestioner.lean`) — `argmin_Y Z(Y) ≠ argmax_Y |K(Y)|`, i.e. the
optimal questioner is NOT the strongest AI.

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
In a human–AI dyad solving problems, the human's *optimal role* is to be the
**questioner / intervener** (the one issuing metacognitive interventions that
drive the solver's emergence), rather than the solver itself.  Support: R.134.a
(education paradox) — "the strongest AI is not the best teacher" — and R.19, the
formalized seed: the best questioner (lowest impedance `Z`, minimizing the
number of interventions `N` to a solution) is in general NOT the agent of
largest knowledge `|K|`.  So the role that minimizes the joint emergence cost is
the questioner role, and it is a *distinct* optimum from "be the strongest
solver".

================================================================================
FORMALIZATION CHOICES
================================================================================
A role assignment in a dyad picks, for a fixed problem, *who questions whom*.
The objective is the emergence cost `N` of the resulting interaction: the
optimal role assignment minimizes `N`.  R.19 already formalizes the key
*separation*: the `Z`-minimizer (best questioner — fewest interventions) differs
from the `|K|`-maximizer (strongest AI).  We reuse that exact structure.

We model an agent pool with two role-relevant attributes:
  * `Z a`     — impedance of `a` *as a questioner* (lower ⇒ fewer interventions
                ⇒ better questioner);
  * `Kcard a` — knowledge size of `a` *as a solver* (larger ⇒ "stronger" solver).

The "optimal-questioner role" is the `Z`-minimizer; the "strongest-solver" is
the `|K|`-maximizer.  The conjecture's precise (R.134.a) kernel — "the strongest
AI is not the best teacher/questioner" — is that these two roles are realised by
*different* agents.  That is exactly R.19, which we re-derive here as the proven
partial, and lift to the dyadic role statement.

================================================================================
VERDICT: OPEN.
================================================================================
PROVEN PARTIAL (sorry-free below, the R.19 seed):
  * `Cj42_questioner_ne_strongest` — abstract: if some agent beats another on
    impedance while losing on knowledge, the best-questioner role and the
    strongest-solver role are distinct agents.
  * `Cj42_education_paradox` — concrete witness (the R.19 RLHF-vs-large pool):
    `Z(A_RLHF) < Z(A_large)` yet `|K(A_RLHF)| < |K(A_large)|`, so the best
    questioner (`A_RLHF`) is NOT the strongest AI (`A_large`) — "the strongest
    AI is not the best teacher", R.134.a precisified.

BLOCKED AT (why the full conjecture is OPEN):
The full Cj.42 asserts that the *human's* optimal role is questioner.  This needs
a **role-optimization objective** — a formal function from role-assignments
(who questions, who solves, in a human–AI dyad) to emergence cost `N`, together
with an axiom-level reason that the *human* (vs the AI) is the `N`-minimizing
questioner.  Neither the objective nor that human-specific minimality is in
A.1–A.4: the axioms define `N(p, X)` for a single solver, not a dyadic role
functional, and they say nothing forcing the human to be the better questioner.
This depends on Cj.40 (the κ-advantage giving the human its questioner edge),
itself OPEN.  We prove only the role *separation* (questioner ≠ strongest
solver, the R.19 seed); the human-specific optimality is OPEN.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

namespace MIP

namespace Cj42QuestionerRole

/-! ## Role-attributed agent pool (R.19 structure).

Each agent carries its impedance `Z` *as a questioner* and its knowledge size
`Kcard` *as a solver*; these are independent (D.1.3 / D.3.2). -/

/-- A pool of candidate agents, each with a questioner-role impedance `Z`
(lower = better questioner) and a solver-role knowledge size `Kcard`
(larger = stronger solver). -/
structure RolePool (ι : Type*) where
  /-- Impedance as questioner; the best questioner minimizes this. -/
  Z     : ι → ℝ
  /-- Knowledge size as solver; the strongest solver maximizes this. -/
  Kcard : ι → ℝ

variable {ι : Type*}

/-- `a` is the best questioner (a `Z`-minimizer): no agent issues fewer
interventions. -/
def IsBestQuestioner (pool : RolePool ι) (a : ι) : Prop :=
  ∀ b, pool.Z a ≤ pool.Z b

/-- `a` is the strongest solver (a `Kcard`-maximizer). -/
def IsStrongestSolver (pool : RolePool ι) (a : ι) : Prop :=
  ∀ b, pool.Kcard b ≤ pool.Kcard a

/-- **Cj.42 — questioner role ≠ strongest-solver role (R.19 seed, abstract).**

If agent `q` strictly beats `s` on questioner impedance (`Z q < Z s`) while `s`
strictly beats `q` on solver knowledge (`Kcard q < Kcard s`), then the
best-questioner role (`q`) and the strongest-solver role (`s`) are realised by
*distinct* agents.  Precisifies R.134.a: the strongest AI is not the best
teacher/questioner. -/
theorem Cj42_questioner_ne_strongest
    (pool : RolePool ι) (q s : ι)
    (hZ : pool.Z q < pool.Z s)
    (_hK : pool.Kcard q < pool.Kcard s)
    (_hqmin : IsBestQuestioner pool q)
    (_hsmax : IsStrongestSolver pool s) :
    q ≠ s := by
  intro hqs
  rw [hqs] at hZ
  exact lt_irrefl _ hZ

/-! ## Concrete education-paradox witness (R.19 RLHF-vs-large pool).

`Bool`-indexed: `false ↦ A_RLHF` (instruction-tuned, low impedance — best
questioner/teacher), `true ↦ A_large` (more pretraining — larger knowledge,
"strongest AI").  `Z A_RLHF = 1 < 2 = Z A_large`, `Kcard A_RLHF = 1 < 2 =
Kcard A_large`. -/

/-- The witness role pool: `A_RLHF = false`, `A_large = true`. -/
def witnessPool : RolePool Bool where
  Z     := fun a => if a then 2 else 1   -- A_large = 2, A_RLHF = 1
  Kcard := fun a => if a then 2 else 1   -- A_large = 2, A_RLHF = 1

/-- `A_RLHF` (`false`) is the best questioner (minimizes impedance). -/
theorem witness_RLHF_best_questioner : IsBestQuestioner witnessPool false := by
  intro b; simp only [witnessPool]; cases b <;> norm_num

/-- `A_large` (`true`) is the strongest solver (maximizes knowledge). -/
theorem witness_large_strongest_solver : IsStrongestSolver witnessPool true := by
  intro b; simp only [witnessPool]; cases b <;> norm_num

/-- **Cj.42 — education paradox (PROVEN PARTIAL).**

The best questioner (`A_RLHF`) and the strongest AI (`A_large`) are distinct:
the strongest AI is *not* the best teacher.  This is the R.134.a precisification
that "reverse-supports" Cj.42 — the optimal questioner role is not the strongest-
solver role, hence the human's value is in the (questioner) role the AI does not
optimally fill. -/
theorem Cj42_education_paradox :
    ∃ q s : Bool,
      q ≠ s ∧
      witnessPool.Z q < witnessPool.Z s ∧
      witnessPool.Kcard q < witnessPool.Kcard s ∧
      IsBestQuestioner witnessPool q ∧
      IsStrongestSolver witnessPool s := by
  refine ⟨false, true, by decide, ?_, ?_,
    witness_RLHF_best_questioner, witness_large_strongest_solver⟩
  · simp only [witnessPool]; norm_num
  · simp only [witnessPool]; norm_num

/-- **Cj.42 statement (faithful conjecture as a `Prop`).**

There is a role regime (a pool with a questioner `q` and a solver `s`) in which
the best-questioner role strictly beats the strongest-solver role on impedance
while losing on knowledge, and the two roles are distinct agents — i.e. the
optimal role (best questioner) is not "be the strongest solver".

The role *separation* is proven (witnessed below).  The OPEN content is that the
*human* is the `N`-minimizing questioner in the actual dyad — see BLOCKED AT. -/
def Cj42_Statement : Prop :=
  ∃ (ι : Type) (pool : RolePool ι) (q s : ι),
    q ≠ s ∧
    pool.Z q < pool.Z s ∧
    pool.Kcard q < pool.Kcard s ∧
    IsBestQuestioner pool q ∧
    IsStrongestSolver pool s

/-- **Cj.42 — role-separation realised (PROVEN PARTIAL).**

The statement holds for the concrete RLHF-vs-large pool: the optimal questioner
role is distinct from the strongest-solver role.  The human-specific optimality
(human = the optimal questioner) is OPEN (needs a role-optimization objective
+ Cj.40). -/
theorem Cj42_Statement_realised : Cj42_Statement :=
  ⟨Bool, witnessPool, false, true, by decide,
    by simp only [witnessPool]; norm_num,
    by simp only [witnessPool]; norm_num,
    witness_RLHF_best_questioner, witness_large_strongest_solver⟩

end Cj42QuestionerRole

end MIP
