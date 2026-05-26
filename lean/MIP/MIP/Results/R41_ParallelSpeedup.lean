/-
Result R.41 — Parallel speedup is upper-bounded by the DAG average width.

Reference: `proofs/derived/R41.md` and `proofs/derived/A_grade.md` R.41
(A 级, depends on D.2.10 barrier DAG, R.13, R.40, T.1).

**Statement.** With `k` parallel questioners breaking the `|B|` barriers of
a problem, the parallel speedup is bounded by the DAG average width
`W_avg(G) = |B| / L(G)`, where `L(G)` is the critical-path length.

**Pure-math kernel.** Total barrier work is `|B|` (T.7). The critical path
has length `L(G)`, and no parallel schedule can finish faster than its
critical path (R.40 semantics): the realized parallel completion time
`parTime` satisfies `L(G) ≤ parTime`. The speedup
`speedup := |B| / parTime` is then bounded by shrinking the denominator to
its smallest admissible value `L(G)`:

    Bcard / parTime  ≤  Bcard / L(G) ,

i.e. dividing a fixed nonnegative numerator by a smaller positive
denominator increases the quotient. This is exactly
`div_le_div_of_nonneg_left` (monotonicity of `a / ·` in the denominator).

This file proves the **algebraic kernel** over the reals, with the upstream
facts (`0 < L`, `L ≤ parTime`, `0 ≤ Bcard`) entering as explicit
hypotheses, matching the MIP-side dependence on R.40 / T.7.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace ParallelSpeedup

/-- **R.41 — speedup denominator-monotonicity core.**

Given nonneg total barrier work `Bcard`, a positive critical-path length
`L`, and a parallel completion time `parTime` that cannot beat the
critical path (`L ≤ parTime`), the speedup obtained at `parTime` is at most
the ideal speedup obtained at `L`:

    Bcard / parTime  ≤  Bcard / L .

This is monotonicity of division in the denominator. -/
theorem R_41_speedup_bound
    (Bcard L parTime : ℝ)
    (hL : 0 < L) (hLp : L ≤ parTime) (hB : 0 ≤ Bcard) :
    Bcard / parTime ≤ Bcard / L :=
  div_le_div_of_nonneg_left hB hL hLp

/-- **R.41 corollary — speedup is bounded by the DAG average width.**

Define the realized parallel speedup `speedup := Bcard / parTime`. Then
`speedup ≤ Bcard / L`, where `Bcard / L = |B| / L(G) = W_avg(G)` is the DAG
average width. The bound is the hard geometric ceiling on parallel gain. -/
theorem R_41_speedup_le_avg_width
    (Bcard L parTime speedup : ℝ)
    (hL : 0 < L) (hLp : L ≤ parTime) (hB : 0 ≤ Bcard)
    (h_speedup_def : speedup = Bcard / parTime) :
    speedup ≤ Bcard / L := by
  rw [h_speedup_def]
  exact R_41_speedup_bound Bcard L parTime hL hLp hB

end ParallelSpeedup

end MIP
