/-
Result R.175 — Brent-type cluster-intervention lower bound.
Reference: `workspace/parallel_emergence.md` (old parallel R.171).

**Statement.** Let `k` parallel questioners assist a single solver on a
problem `p` whose barriers form a dependency DAG `G(p)` with longest path
(critical path) length `L(G)` and total barrier count `|B(p)|`. The minimal
cluster intervention count `N_k` satisfies the two-sided Brent lower bound

    N_k  ≥  max( L(G),  ⌈ |B(p)| / k ⌉ ).

Two independent sources: (1) the critical path cannot be parallelised —
adjacent barriers on the longest chain are forced into distinct sequential
steps (R.40 generalised), giving `N_k ≥ L`; (2) total-work amortisation —
each step breaks at most `k` of the `|B|` barriers (L.5: one intervention
per barrier), giving `N_k ≥ |B| / k`. The minimum is bounded by both.

**Kernel formalized here.** The Brent two-sided lower bound

    max(S, W / p) ≤ T_p

as a clean inequality over the reals, where `S = L(G)` (span / critical
path), `W = |B(p)|` (total work), `p = k` (processors), `T_p = N_k`.
Hypotheses: `0 < p`, the span bound `S ≤ T_p` (R.40), and the work bound
`W ≤ p · T_p` (total-work amortisation, which is `W/p ≤ T_p`). We prove the
`max` lower bound and, as a discrete companion, the ℕ work-amortisation
inequality `p * N_k ≥ |B|` ⇒ each of `L ≤ N_k` and `|B| ≤ p · N_k` ⇒
`max` form, avoiding any `⌈·/·⌉` discretisation.

**Bridge.** `S := L(G)` from R.40 (`MIP.CriticalPathBound`); `W := |B(p)|`;
`p := k`; the realised cluster cost `N_k := T_p`. The ceiling `⌈|B|/k⌉` is
the integer ceiling of the real bound `W/p`; over ℕ we carry the equivalent
edge-free statement `|B| ≤ k · N_k`.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Order.Basic
import MIP.Results.R40_CriticalPathBound

namespace MIP

namespace R175_BrentLowerBound

/-- **R.175 — work-amortisation lower bound (real form).**

If every step breaks at most `p` of the `W` units of barrier work, the
realised time `Tp` satisfies `W ≤ p · Tp`, equivalently `W / p ≤ Tp`. -/
theorem R_175_work_bound (W p Tp : ℝ) (hp : 0 < p) (hW : W ≤ p * Tp) :
    W / p ≤ Tp := by
  rw [div_le_iff₀ hp]; linarith

/-- **R.175 — Brent two-sided lower bound (the main kernel).**

`max(S, W/p) ≤ Tp`, where `S` is the span (critical-path length `L(G)`),
`W` is the total work (`|B(p)|`), and `p` the processor / questioner count.
The two hypotheses are exactly the two independent lower-bound sources:
`hspan : S ≤ Tp` (critical path, R.40) and `hwork : W ≤ p · Tp`
(total-work amortisation). -/
theorem R_175_brent_lower_bound
    (S W p Tp : ℝ) (hp : 0 < p)
    (hspan : S ≤ Tp) (hwork : W ≤ p * Tp) :
    max S (W / p) ≤ Tp :=
  max_le hspan (R_175_work_bound W p Tp hp hwork)

/-- **R.175 — limit `k → ∞`: critical path is incompressible (C.171.2).**

No matter how the work term `W/p` shrinks, the span lower bound survives:
`S ≤ Tp`. This is `le_max_left` composed with the kernel; it states that
`L(G)` is an absolute lower bound on `N_k` for every processor count. -/
theorem R_175_critical_path_incompressible
    (S W p Tp : ℝ) (hp : 0 < p)
    (hspan : S ≤ Tp) (hwork : W ≤ p * Tp) :
    S ≤ Tp :=
  le_trans (le_max_left S (W / p))
    (R_175_brent_lower_bound S W p Tp hp hspan hwork)

/-- **R.175 — discrete (ℕ) two-sided lower bound, ceiling-free.**

Over the naturals: if the critical path injects into the `Nk` steps
(R.40: `L ≤ Nk`) and the total barrier count obeys the work amortisation
`Bcard ≤ k * Nk`, then both lower bounds hold simultaneously. This is the
faithful integer Brent lower bound without invoking `⌈Bcard / k⌉`:
`⌈Bcard/k⌉ ≤ Nk ↔ Bcard ≤ k * Nk`. -/
theorem R_175_brent_lower_bound_nat
    {L Bcard k Nk : ℕ}
    (f : Fin L → Fin Nk) (hf : Function.Injective f)
    (hwork : Bcard ≤ k * Nk) :
    L ≤ Nk ∧ Bcard ≤ k * Nk :=
  ⟨MIP.CriticalPathBound.R_40_critical_path_bound f hf, hwork⟩

/-- **R.175 — discrete work bound matches the integer ceiling.**

For `0 < k`, the amortisation hypothesis `Bcard ≤ k * Nk` is *equivalent*
to the ceiling lower bound `⌈Bcard / k⌉ ≤ Nk`, so the ceiling-free form
above is faithful to the stated `N_k ≥ ⌈|B|/k⌉`. -/
theorem R_175_work_iff_ceil {Bcard k Nk : ℕ} (hk : 0 < k) :
    Bcard ≤ k * Nk ↔ (Bcard + k - 1) / k ≤ Nk := by
  rw [Nat.div_le_iff_le_mul_add_pred hk]
  -- goal: Bcard ≤ k * Nk ↔ Bcard + k - 1 ≤ Nk * k + (k - 1)
  omega

end R175_BrentLowerBound

end MIP
