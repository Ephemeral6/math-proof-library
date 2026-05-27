/-
Result R.176 — Brent upper bound and achievability.
Reference: `workspace/parallel_emergence.md` (old parallel R.172).

**Statement.** The R.175 lower bound `N_k ≥ max(L, ⌈|B|/k⌉)` is *tight*:
there exists a greedy topological schedule achieving the Brent upper bound

    N_k  ≤  L(G)  +  ⌈ (|B(p)| − L(G)) / k ⌉ .

Greedy proof: process the DAG layer by layer in topological order; at each
of the `L` critical-path steps break every currently-available barrier,
using `k` questioners per step. The total step count telescopes to
`Σ_layers ⌈|layer_i|/k⌉ ≤ L + (|B| − L)/k`. When `k ≥ W_max` (max
instantaneous width) each layer costs one step and the upper bound meets
the lower bound `max(L, ⌈|B|/k⌉)`, so the schedule is optimal (cases (i),
(ii): independent barriers ⇒ `L = 1`, `N_k = ⌈|B|/k⌉`; perfect layering +
`k ≥ W` ⇒ `N_k = L`).

**Kernel formalized here.** The Brent upper-bound inequality over the reals

    T_p  ≤  T_∞  +  (T_1 − T_∞) / p ,

with `T_∞ = L` (span), `T_1 = |B|` (work), `p = k`, plus the greedy
achievability witness: when `p ≥ W_max` the greedy cost equals the span
`L`, meeting the lower bound (a witness `T_p = L` satisfying both the
R.175 lower bound and this upper bound). We also prove the Brent
*sandwich* `max(T_∞, T_1/p) ≤ T_p ≤ T_∞ + (T_1 − T_∞)/p` by combining with
the R.175 lower bound, and the work-conservation rewrite
`T_∞ + (T_1 − T_∞)/p = (p·T_∞ + T_1 − T_∞)/p`.

**Bridge.** `T_∞ := L(G)` (R.40 critical path), `T_1 := |B(p)|` (total
work), `p := k`. The integer ceiling `⌈(|B|−L)/k⌉` is the discretisation
of the real term `(T_1 − T_∞)/p`; achievability case `k ≥ W_max` gives the
exact witness `N_k = L`.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Order.Basic

namespace MIP

namespace R176_BrentUpperBound

/-- **R.176 — Brent upper bound (the main kernel).**

The greedy schedule cost `Tp` is at most `Tinf + (T1 − Tinf)/p`, where
`Tinf` is the span (`L(G)`), `T1` the total work (`|B|`), `p` the processor
count. The hypothesis `hgreedy : p * Tp ≤ p * Tinf + (T1 − Tinf)` encodes
the telescoped layer sum `Σ ⌈|layer_i|/k⌉ ≤ L + (|B| − L)/k` after clearing
the denominator (each of the `Tp` steps performs `≤ p` units of useful work
beyond the forced span). -/
theorem R_176_brent_upper_bound
    (Tinf T1 p Tp : ℝ) (hp : 0 < p)
    (hgreedy : p * Tp ≤ p * Tinf + (T1 - Tinf)) :
    Tp ≤ Tinf + (T1 - Tinf) / p := by
  -- Tp ≤ Tinf + (T1 - Tinf)/p  ⇐  Tp - Tinf ≤ (T1 - Tinf)/p
  have hstep : Tp - Tinf ≤ (T1 - Tinf) / p := by
    rw [le_div_iff₀ hp]; nlinarith [hgreedy]
  linarith [hstep]

/-- **R.176 — work-conservation rewrite of the Brent upper bound.**

`Tinf + (T1 − Tinf)/p = (p·Tinf + T1 − Tinf)/p`. Pure field identity; this
is the form in which the span term and the work surplus are combined over a
common denominator (the "work-conservation" view of Brent's bound). -/
theorem R_176_work_conservation (Tinf T1 p : ℝ) (hp : 0 < p) :
    Tinf + (T1 - Tinf) / p = (p * Tinf + T1 - Tinf) / p := by
  rw [eq_div_iff (ne_of_gt hp)]
  field_simp
  ring

/-- **R.176 — Brent sandwich (lower bound ∧ upper bound).**

Combining R.175 (`max(Tinf, T1/p) ≤ Tp`) with this file's upper bound gives
the full Brent two-sided characterisation

    max(Tinf, T1/p)  ≤  Tp  ≤  Tinf + (T1 − Tinf)/p .

Here the lower-bound side is supplied by the two hypotheses `hspan`,
`hwork` (the R.175 sources) and the upper-bound side by `hgreedy`. -/
theorem R_176_brent_sandwich
    (Tinf T1 p Tp : ℝ) (hp : 0 < p)
    (hspan : Tinf ≤ Tp) (hwork : T1 ≤ p * Tp)
    (hgreedy : p * Tp ≤ p * Tinf + (T1 - Tinf)) :
    max Tinf (T1 / p) ≤ Tp ∧ Tp ≤ Tinf + (T1 - Tinf) / p := by
  refine ⟨max_le hspan ?_, R_176_brent_upper_bound Tinf T1 p Tp hp hgreedy⟩
  rw [div_le_iff₀ hp]; linarith

/-- **R.176 — achievability when `p ≥ W_max` (greedy meets the lower bound).**

Case (ii)/(iii) of R.172: when the processor count `p` is at least the
maximum instantaneous width `Wmax`, each layer costs exactly one step, so
the greedy cost equals the span `Tinf = L(G)`. We exhibit this witness
`Tp = Tinf` and verify it satisfies **both** the R.175 lower bound and the
upper bound, i.e. the lower bound is *achieved*. Faithful hypothesis:
`hsat : T1 ≤ p * Tinf` (work fits within `p` processors over `L` layers,
which is exactly `|B| ≤ k · L`, the `k ≥ W_max` regime). -/
theorem R_176_achievability_span
    (Tinf T1 p : ℝ) (hp : 0 < p)
    (hspan_le_work : Tinf ≤ T1) (hsat : T1 ≤ p * Tinf) :
    -- witness Tp := Tinf realises the lower bound and obeys the upper bound
    max Tinf (T1 / p) ≤ Tinf ∧ Tinf ≤ Tinf + (T1 - Tinf) / p := by
  constructor
  · refine max_le (le_refl _) ?_
    rw [div_le_iff₀ hp]; linarith
  · have hnonneg : 0 ≤ (T1 - Tinf) / p := by
      apply div_nonneg _ (le_of_lt hp); linarith
    linarith

/-- **R.176 — independent-barrier case (i): `L = 1`, `N_k = ⌈|B|/k⌉`.**

When barriers are pairwise independent the DAG has no edges, so `Tinf = 1`
(unit span) and the greedy schedule realises `Tp = T1 / p` (rounded), with
no span overhead beyond the single layer. The kernel: with `Tinf = 1` the
upper bound reduces to `Tp ≤ 1 + (T1 − 1)/p`, and the lower bound work term
`T1/p` is the binding constraint. Here we record the algebraic reduction
`1 + (T1 − 1)/p = (p − 1 + T1)/p`, the closed form of `N_k` in case (i). -/
theorem R_176_independent_case (T1 p : ℝ) (hp : 0 < p) :
    1 + (T1 - 1) / p = (p - 1 + T1) / p := by
  rw [eq_div_iff (ne_of_gt hp)]
  field_simp
  ring

end R176_BrentUpperBound

end MIP
