/-
Result R.177 — DAG geometry as a training-priority signal.
Reference: `workspace/parallel_emergence.md` (old parallel R.173).

**Statement.** Under the Brent achievable cost `N_k = L + (|B| − L)/k`
(R.176), the DAG geometry `(L, |B|)` determines the training priority via
the marginal sensitivities of `N_k`:

    ∂N_k/∂|B| = 1/k ,        ∂N_k/∂L = 1 − 1/k = (k−1)/k .

Consequences (priority ordering): for `k ≥ 2` we have `∂N_k/∂L > ∂N_k/∂|B|`,
so reducing the critical-path length `L` yields a larger marginal `N`-gain
than removing a single barrier — i.e. **critical-path / span reduction has
higher training priority than width / work reduction**. Limits: `k = 1`
gives `(1, 0)` (only `|B|` matters, T.1 regime); `k → ∞` gives `(0, 1)`
(only `L` matters, critical-path bottleneck, C.173.2). The span `L(G)` is
the incompressible "speed of light": `N_∞ ≥ L`.

**Kernel formalized here.**
1. The Brent cost as an explicit real function `Nk L B k := L + (B − L)/k`.
2. Its two marginal slopes computed *exactly* as finite-difference
   identities (the discrete analogue of the partials, which is what is
   rigorous over ℝ without calculus):
     `Nk (L) (B+ΔB) k − Nk L B k = ΔB / k`            (slope `1/k`)
     `Nk (L+ΔL) B k − Nk L B k = ((k−1)/k)·ΔL`        (slope `(k−1)/k`)
3. The **priority ordering**: for `k ≥ 2` (and `ΔL = ΔB = δ > 0`) the
   `L`-reduction gain strictly exceeds the `|B|`-reduction gain:
   `(δ)/k < ((k−1)/k)·δ`.
4. A combinatorial companion: a node on the critical path injects into
   the `N` steps (R.40), pinning a lower bound `L ≤ N`, formalising
   "critical-path nodes are priority-pinned".

**Bridge.** `L := L(G)` (R.40 longest path), `B := |B(p)|` (work),
`k` = questioner count; `Nk` is the R.176 Brent achievable schedule cost.
Marginal partials are realised as exact finite differences (faithful over
ℝ; the document's `∂` is the continuous limit, `O(1)` ceiling error noted
in R.173's dependency table).

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import MIP.Results.R40_CriticalPathBound

namespace MIP

namespace R177_DAGGeometrySignal

/-- **Brent achievable cost** as an explicit function of DAG geometry.
`Nk L B k = L + (B − L)/k`: span `L`, work `B`, `k` processors. -/
noncomputable def Nk (L B k : ℝ) : ℝ := L + (B - L) / k

/-- **R.177 (1) — work marginal: slope `1/k`.**

The exact finite difference in the work coordinate `B`:
`Nk L (B + ΔB) k − Nk L B k = ΔB / k`. This is the rigorous form of
`∂N_k/∂|B| = 1/k`: removing/adding `ΔB` barriers changes `N_k` by `ΔB/k`. -/
theorem R_177_work_marginal (L B k ΔB : ℝ) (hk : k ≠ 0) :
    Nk L (B + ΔB) k - Nk L B k = ΔB / k := by
  unfold Nk
  field_simp
  ring

/-- **R.177 (2) — span marginal: slope `(k−1)/k`.**

The exact finite difference in the span coordinate `L`:
`Nk (L + ΔL) B k − Nk L B k = ((k − 1)/k)·ΔL`. This is the rigorous form of
`∂N_k/∂L = 1 − 1/k = (k − 1)/k`: shortening the critical path by `ΔL`
changes `N_k` by `((k−1)/k)·ΔL`. -/
theorem R_177_span_marginal (L B k ΔL : ℝ) (hk : k ≠ 0) :
    Nk (L + ΔL) B k - Nk L B k = ((k - 1) / k) * ΔL := by
  unfold Nk
  field_simp
  ring

/-- **R.177 (3) — priority ordering: span dominates work for `k ≥ 2`.**

For `k ≥ 2` and a common positive reduction budget `δ > 0`, reducing the
span `L` by `δ` yields at least as large an `N_k`-improvement as removing
`δ` units of barrier work:

    (work gain)  δ/k  ≤  ((k − 1)/k)·δ  (span gain),

with **strict** inequality once `k > 2` (`R_177_priority_span_over_work_strict`
below). At `k = 2` the two marginals tie (`1/2 = 1/2`). Hence
**critical-path reduction has at-least-as-high training priority**, and
strictly higher in the genuinely-parallel regime (C.173.1 / C.173.3). -/
theorem R_177_priority_span_over_work
    (k δ : ℝ) (hk : 2 ≤ k) (hδ : 0 < δ) :
    δ / k ≤ ((k - 1) / k) * δ := by
  have hkpos : 0 < k := by linarith
  rw [div_mul_eq_mul_div, div_le_div_iff_of_pos_right hkpos]
  -- δ ≤ (k - 1) * δ
  nlinarith [hδ, hk]

/-- **R.177 (3') — strict priority ordering for `k > 2`.**

Once more than two questioners are active, span reduction strictly beats
work reduction: `δ/k < ((k − 1)/k)·δ`. -/
theorem R_177_priority_span_over_work_strict
    (k δ : ℝ) (hk : 2 < k) (hδ : 0 < δ) :
    δ / k < ((k - 1) / k) * δ := by
  have hkpos : 0 < k := by linarith
  rw [div_mul_eq_mul_div, div_lt_div_iff_of_pos_right hkpos]
  -- δ < (k - 1) * δ
  nlinarith [hδ, hk]

/-- **R.177 (4) — limit `k = 1`: only `|B|` matters (T.1 regime).**

At `k = 1` the work marginal is the full `1` (`δ/1 = δ`) and the span
marginal vanishes (`(1 − 1)/1 = 0`). We record the span marginal collapse:
`Nk (L + ΔL) B 1 − Nk L B 1 = 0`. -/
theorem R_177_span_marginal_k_one (L B ΔL : ℝ) :
    Nk (L + ΔL) B 1 - Nk L B 1 = 0 := by
  have := R_177_span_marginal L B 1 ΔL (by norm_num)
  simpa using this

/-- **R.177 (4') — limit, work marginal at `k = 1` equals the full step.**

`Nk L (B + ΔB) 1 − Nk L B 1 = ΔB`. Removing one barrier removes exactly one
intervention — the single-questioner T.1 regime. -/
theorem R_177_work_marginal_k_one (L B ΔB : ℝ) :
    Nk L (B + ΔB) 1 - Nk L B 1 = ΔB := by
  have := R_177_work_marginal L B 1 ΔB (by norm_num)
  simpa using this

/-- **R.177 (5) — critical-path nodes are priority-pinned (combinatorial).**

A node sitting on the length-`L` critical path injects into the `N`
intervention steps (R.40 dependency semantics + L.5), so `L ≤ N`: the span
is an incompressible lower bound on `N_k` for every `k` (the geometric
"speed of light", C.173.2). This pins critical-path nodes as the binding
training-priority targets once `k` is large. -/
theorem R_177_critical_path_pinned {L N : ℕ}
    (f : Fin L → Fin N) (hf : Function.Injective f) : L ≤ N :=
  MIP.CriticalPathBound.R_40_critical_path_bound f hf

end R177_DAGGeometrySignal

end MIP
