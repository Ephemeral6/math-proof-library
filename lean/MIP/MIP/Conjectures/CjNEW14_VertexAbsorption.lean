/-
Conjecture Cj.NEW-14 — vertex absorption / catastrophic-forgetting
irreversibility on the simplex `Δ^m`.

Source: `~/Desktop/MIP/conjectures/index.md` lines ~762-794;
supporting derivation `workspace/subdomain_competition.md` §6.8, §8.2.

Natural-language conjecture
---------------------------
The training dynamics on the `m`-simplex `Δ^m` (the subdomain-mass vector
`π = (π_1,…,π_m)`) satisfy "vertex absorption": once a subdomain
attention `π_j → 0`, the natural training dynamics irreversibly pin
`π_j` at 0:

    π_j(X_t) = 0  ⟹  dπ_j/dt' = 0   for all t' ≥ t
                                     (training that does not re-cover K_j).

Geometric root of the irreversibility of catastrophic forgetting: the
`π_j = 0` boundary of the simplex is an absorbing state.  Stated formal
conditions (index l.772-778):

  (C1) the training operator `T_train : Δ^m → Δ^m` is *non-outward* on
       `∂Δ^m` — it maps the boundary face into itself;
  (C2) `π_j = 0  ⟺  ∀ ω ∈ K_j, p_X(ω; 𝒟) = 0`;
  (C3) natural training (without explicitly re-covering `K_j`) preserves
       (C2).

Formalization choices
---------------------
We model `T_train : Δ^m → Δ^m` as an arbitrary self-map of the simplex
(a discrete-time training step `X_{t+1} = T_train(X_t)`, the faithful
discrete analogue of the continuous `dπ/dt`).  The state is a point `q`
of the simplex `Simplex ι := {q : ι → ℝ | (∀ i, 0 ≤ q i) ∧ ∑ q i = 1}`.

The conjecture's hypotheses (C1)-(C3) are bundled exactly as stated:

  * (C1)+(C3) together say that `T_train` keeps the face `{q_j = 0}`
    invariant — formally `faceInvariant T j : (T q).val j = 0` whenever
    `q.val j = 0`.  This is precisely "the boundary is non-outward / the
    `π_j = 0` face is preserved", the geometric content of (C1) and (C3).
  * (C2) is the *interpretation* of `q_j = 0` as "all `ω ∈ K_j` are
    deactivated"; it is what licenses reading the conclusion as
    catastrophic forgetting, and is recorded in the doc.  The dynamical
    statement itself only needs the face invariance.

The conclusion `dπ_j/dt' = 0 ∀ t' ≥ t` becomes: `π_j` stays `0` along the
whole forward orbit, i.e. `(T_train^[n] q).val j = 0` for all `n`.

VERDICT
=======
* **PROVED** (given (C1)-(C3) as the conjecture's own stated hypotheses)
  — Theorem `CjNEW14_absorption`: if `q.val j = 0` and `T_train` keeps the
  `j`-face invariant, then every forward iterate has `j`-coordinate `0`.
  A clean invariant-set induction.  This faithfully captures the
  geometric absorption claim: the hypotheses ARE the conjecture's
  conditions (C1)/(C3), so this is not a trivial weakening.
* **OPEN** — sub-question (a): do (C1)-(C3) actually hold under SGD?
  BLOCKED AT establishing face invariance for a concrete training
  operator.  MISSING: a model of the parameter-space → simplex projection
  (the `β_i` "subdomain projection rate" of the source's
  `need_new_concept` list) from which `faceInvariant` for SGD could be
  derived.  Sub-questions (b) (MoE breaks absorption) and (c) (recovery
  cost ~ `t_cov`) are likewise OPEN, downstream of that missing model.

This file is `sorry`-free and `axiom`-free (no new axioms; only the
ambient Lean/Mathlib axioms).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Logic.Function.Iterate
import Mathlib.Tactic.Linarith

namespace MIP
namespace CjNEW14

open scoped BigOperators

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- A point of the probability simplex `Δ^m` over a finite index set `ι`:
the subdomain-mass vector `π`.  `val i = π_i`. -/
structure Simplex (ι : Type) [Fintype ι] where
  /-- The coordinate vector `π : ι → ℝ`. -/
  val : ι → ℝ
  /-- Nonnegativity `π_i ≥ 0` (simplex). -/
  nonneg : ∀ i, 0 ≤ val i
  /-- Normalisation `∑_i π_i = 1` (subdomain conservation, T.18.10). -/
  sum_one : ∑ i, val i = 1

/-- **(C1)+(C3) bundled — face invariance.**  The training operator
`T : Δ^m → Δ^m` keeps the `j`-face `{π_j = 0}` invariant: if the
`j`-coordinate of `q` is `0`, so is the `j`-coordinate of `T q`.  This is
the precise "boundary non-outward / forgetting-preserving" hypothesis. -/
def faceInvariant (T : Simplex ι → Simplex ι) (j : ι) : Prop :=
  ∀ q : Simplex ι, q.val j = 0 → (T q).val j = 0

/-- **Cj.NEW-14 vertex absorption — PROVED (given (C1)-(C3)).**

If the `j`-coordinate of `q` is `0` and the training operator `T` keeps
the `j`-face invariant (hypotheses (C1)+(C3) of the conjecture), then the
`j`-coordinate stays `0` along the entire forward orbit:

    (T^[n] q).val j = 0   for all n.

Discrete analogue of `dπ_j/dt' = 0 ∀ t' ≥ t`.  Proof: invariant-set
induction on `n`. -/
theorem CjNEW14_absorption
    (T : Simplex ι → Simplex ι) (j : ι)
    (hInv : faceInvariant T j)
    (q : Simplex ι) (hq : q.val j = 0) :
    ∀ n : ℕ, (T^[n] q).val j = 0 := by
  intro n
  induction n with
  | zero => simpa using hq
  | succ k ih =>
      -- T^[k+1] q = T (T^[k] q); apply face invariance to T^[k] q.
      rw [Function.iterate_succ_apply']
      exact hInv (T^[k] q) ih

/-- **Monotone (non-increase) corollary.**  Under absorption, the
`j`-coordinate never recovers: it is `0` at every later time, in
particular it never strictly increases above `0`.  This is the
"irreversibility" reading: `π_j` cannot be restored without leaving the
invariant face (i.e. without re-covering `K_j`). -/
theorem CjNEW14_irreversible
    (T : Simplex ι → Simplex ι) (j : ι)
    (hInv : faceInvariant T j)
    (q : Simplex ι) (hq : q.val j = 0) :
    ∀ n : ℕ, (T^[n] q).val j ≤ 0 :=
  fun n => le_of_eq (CjNEW14_absorption T j hInv q hq n)

/-- Faithful `Prop`-level statement of Cj.NEW-14: on the simplex over any
finite index set, vertex absorption holds for every training operator
satisfying the face-invariance hypothesis (C1)+(C3) and every vertex/face
starting point `q` with `q_j = 0`. -/
def CjNEW14_Statement : Prop :=
  ∀ (ι : Type) [Fintype ι] [DecidableEq ι]
    (T : Simplex ι → Simplex ι) (j : ι),
    faceInvariant T j →
    ∀ (q : Simplex ι), q.val j = 0 →
      ∀ n : ℕ, (T^[n] q).val j = 0

/-- The vertex-absorption statement holds. -/
theorem CjNEW14_Statement_holds : CjNEW14_Statement := by
  intro ι _ _ T j hInv q hq n
  exact CjNEW14_absorption T j hInv q hq n

end CjNEW14
end MIP
