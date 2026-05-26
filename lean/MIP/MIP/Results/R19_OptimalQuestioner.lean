/-
Result R.19 — The optimal questioner is NOT the strongest AI.

Reference: `proofs/derived/R19.md` and `proofs/derived/A_grade.md` R.19
(A 级 补反例后升级; deps A.3, D.3.2, D.1.3, 2026 derived branch).

**Statement.** In selecting a questioner (intervener), the agent of
*lowest impedance* `Z` (the best questioner, minimizing `N(p, X, Y)`) is
in general **not** the agent of *largest knowledge* `K`:

    argmin_Y Z(Y)  ≠  argmax_Y |K(Y)| .

**Counterexample (from the source).**  Take a common base model `M_0`.

* `A_RLHF` — `M_0` instruction-tuned (RLHF): knowledge unchanged
  (`|K| = |K(M_0)|`) but impedance *reduced* (`Z` small, very responsive
  to metacognitive intervention).
* `A_large` — `M_0` given much more pretraining data: knowledge *expanded*
  (`|K|` larger) but impedance *unchanged* (`Z ≈ Z(M_0)`, larger than the
  RLHF model's).

Then `Z(A_RLHF) < Z(A_large)` (so the `Z`-minimizer is `A_RLHF`) while
`|K(A_RLHF)| < |K(A_large)|` (so the `|K|`-maximizer is `A_large`).  The
two agents differ — knowledge and impedance come from independent
training mechanisms (D.1.3 / D.3.2), so the questioner-selection axis is
not the knowledge axis.

**This file is `axiom`-free.**  We posit a finite index set of agents
with two real-valued attributes `Z, Kcard : ι → ℝ` and exhibit the
concrete two-agent witness with explicit numeric values, then prove the
`Z`-minimizer is provably *not* the `Kcard`-maximizer.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace OptimalQuestioner

/-- A finite pool of candidate questioners, each carrying two real-valued
attributes:

* `Z a`     — the impedance of agent `a` (lower = better questioner);
* `Kcard a` — the size `|K(a)|` of agent `a`'s knowledge set.

Per D.1.3 / D.3.2 these are independent observables of an agent. -/
structure AgentPool (ι : Type*) where
  /-- Impedance `Z(a)`; the optimal questioner minimizes this. -/
  Z     : ι → ℝ
  /-- Knowledge-set cardinality `|K(a)|`; the strongest AI maximizes this. -/
  Kcard : ι → ℝ

variable {ι : Type*}

/-- `a` is a `Z`-minimizer in the pool (a candidate optimal questioner):
no agent has strictly smaller impedance. -/
def IsZMinimizer (pool : AgentPool ι) (a : ι) : Prop :=
  ∀ b, pool.Z a ≤ pool.Z b

/-- `a` is a `Kcard`-maximizer in the pool (a candidate "strongest AI"):
no agent has strictly larger knowledge. -/
def IsKMaximizer (pool : AgentPool ι) (a : ι) : Prop :=
  ∀ b, pool.Kcard b ≤ pool.Kcard a

/-- **R.19 — abstract separation.**

If agent `a` strictly beats `b` on impedance (`Z a < Z b`) while `b`
strictly beats `a` on knowledge (`Kcard a < Kcard b`), then a
`Z`-minimizer `a` and a `Kcard`-maximizer `b` are necessarily *distinct*
agents.  Indeed: if `a` is a `Z`-minimizer then `Z a ≤ Z b`, consistent;
and were `a = b` we would get `Z a < Z a`, absurd.  So `argmin Z` (here
`a`) and `argmax |K|` (here `b`) cannot coincide.

(Note: in a pool with three-or-more agents a different agent might tie on
both axes; the genuine `argmin Z ≠ argmax |K|` separation is exhibited
concretely on the two-agent witness pool below, where the minimizer and
maximizer are unique.) -/
theorem R_19_min_Z_ne_max_K
    (pool : AgentPool ι) (a b : ι)
    (hZ : pool.Z a < pool.Z b)
    (_hK : pool.Kcard a < pool.Kcard b)
    (_hamin : IsZMinimizer pool a)
    (_hbmax : IsKMaximizer pool b) :
    a ≠ b := by
  intro hab
  -- a = b would force Z a < Z a from hZ, impossible.
  rw [hab] at hZ
  exact lt_irrefl _ hZ

/-- **R.19 — concrete two-agent counterexample.**

`Bool`-indexed pool: `false ↦ A_RLHF`, `true ↦ A_large`.

* `Z A_RLHF = 1 < 2 = Z A_large`   (RLHF model has lower impedance);
* `Kcard A_RLHF = 1 < 2 = Kcard A_large` (large model has more knowledge).

So `A_RLHF` is the unique `Z`-minimizer and `A_large` is the unique
`Kcard`-maximizer, and they differ: the optimal questioner is not the
strongest AI. -/
def witnessPool : AgentPool Bool where
  Z     := fun a => if a then 2 else 1   -- A_large = 2, A_RLHF = 1
  Kcard := fun a => if a then 2 else 1   -- A_large = 2, A_RLHF = 1

/-- In the witness pool, `A_RLHF` (`false`) minimizes impedance. -/
theorem R_19_witness_RLHF_minimizes_Z :
    IsZMinimizer witnessPool false := by
  intro b
  simp only [witnessPool]
  cases b <;> norm_num

/-- In the witness pool, `A_large` (`true`) maximizes knowledge. -/
theorem R_19_witness_large_maximizes_K :
    IsKMaximizer witnessPool true := by
  intro b
  simp only [witnessPool]
  cases b <;> norm_num

/-- **R.19 — the witnesses are distinct agents.**

The `Z`-minimizer `A_RLHF` and the `Kcard`-maximizer `A_large` are not
the same agent: `argmin Z ≠ argmax |K|` concretely. -/
theorem R_19_minimizer_ne_maximizer :
    (false : Bool) ≠ (true : Bool) := by decide

/-- **R.19 — full counterexample.**

There exist agents `a b` (here `A_RLHF` and `A_large`) such that `a`
strictly minimizes impedance over `b` while `b` strictly maximizes
knowledge over `a`, with `a ≠ b`.  Hence the optimal questioner
(min `Z`) differs from the strongest AI (max `|K|`). -/
theorem R_19_optimal_questioner_not_strongest :
    ∃ a b : Bool,
      a ≠ b ∧
      witnessPool.Z a < witnessPool.Z b ∧
      witnessPool.Kcard a < witnessPool.Kcard b ∧
      IsZMinimizer witnessPool a ∧
      IsKMaximizer witnessPool b := by
  refine ⟨false, true, ?_, ?_, ?_, ?_, ?_⟩
  · decide
  · simp only [witnessPool]; norm_num
  · simp only [witnessPool]; norm_num
  · exact R_19_witness_RLHF_minimizes_Z
  · exact R_19_witness_large_maximizes_K

end OptimalQuestioner

end MIP
