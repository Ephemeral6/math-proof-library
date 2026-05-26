/-
Result R.80 — Geometric characterisation of grokking as a coverage crossing.

Reference: `proofs/derived/training_dynamics.md` R.80 (A, under R.79 + R.30).

**Statement.** In the 4D phase space, grokking corresponds to the
trajectory `S(t)` crossing the *coverage hypersurface*

    Π_cov  =  { S : |K| = sup_p |R(p)| } ,

the `|K|`-level set on which the emergence cost `N` jumps from `∞`
(before coverage) to finite (after coverage).

**Pure-math content.** Model the coverage coordinate by `K_t : ℝ → ℝ`
(the knowledge measure `|K(A_t)|` along the trajectory) and the threshold
by `Rsup := sup_p |R(p)|`.  Define

    covered t  :=  Rsup ≤ K_t t          (the trajectory is at/past Π_cov)
    Nfin t     :=  covered t              (emergence has become finite)

The geometric content of R.80 is then a **crossing theorem**: a
continuous trajectory that starts strictly below the coverage threshold
(`K_t t₀ < Rsup`, region I, `N = ∞`) and ends at/above it
(`Rsup ≤ K_t t₁`, region II, `N` finite) *must* cross `Π_cov`, i.e.
there is a time `t*` with `K_t t* = Rsup`.  This is the intermediate value
theorem applied to the coverage coordinate; the crossing time is the
grokking transition.

We also record the **discrete threshold structure**: under a monotone
trajectory the covered set `{t : covered t}` is an up-set, so the
transition is a single well-defined boundary (matching R.79's `t*`).

**This file is `axiom`-free.**
-/
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Order.Basic

namespace MIP

namespace GrokkingCrossing

/-- Coverage predicate: the trajectory is at or past the coverage
hypersurface `Π_cov = {|K| = Rsup}`. -/
def covered (K_t : ℝ → ℝ) (Rsup : ℝ) (t : ℝ) : Prop :=
  Rsup ≤ K_t t

/-- Indicator emergence-finiteness: `N` is finite exactly when covered
(by A.2 / R.79). -/
def Nfin (K_t : ℝ → ℝ) (Rsup : ℝ) (t : ℝ) : Prop :=
  covered K_t Rsup t

/-- **R.80 — crossing theorem (intermediate value form).**

If the coverage coordinate `K_t` is continuous on `[t₀, t₁]`, starts
*strictly below* the coverage threshold (`K_t t₀ < Rsup`) and ends at or
*above* it (`Rsup ≤ K_t t₁`), with `t₀ ≤ t₁`, then the trajectory crosses
the coverage hypersurface `Π_cov`: there exists a crossing time
`t* ∈ [t₀, t₁]` with `K_t t* = Rsup`.

This is exactly "grokking ⟺ the trajectory crosses `Π_cov`": before
`t*` the agent is in region I (`N = ∞`), after `t*` in region II
(`N` finite). -/
theorem R_80_coverage_crossing
    (K_t : ℝ → ℝ) (Rsup t₀ t₁ : ℝ)
    (h_le : t₀ ≤ t₁)
    (h_cont : ContinuousOn K_t (Set.Icc t₀ t₁))
    (h_below : K_t t₀ < Rsup)
    (h_above : Rsup ≤ K_t t₁) :
    ∃ t_star ∈ Set.Icc t₀ t₁, K_t t_star = Rsup := by
  -- `Rsup` lies in the closed interval `[K_t t₀, K_t t₁]`, so by the
  -- intermediate value theorem it is attained.
  have h_mem : Rsup ∈ Set.Icc (K_t t₀) (K_t t₁) :=
    ⟨le_of_lt h_below, h_above⟩
  have h := intermediate_value_Icc h_le h_cont
  exact h h_mem

/-- **R.80 — crossing is genuinely a transition `N=∞ → N` finite.**

The crossing time `t*` produced above separates the not-covered side from
the covered side: at `t*` coverage *holds* (`Nfin` becomes true), while
just before it failed.  We package the "covered at the crossing" fact:
at any time with `K_t t = Rsup` the emergence indicator `Nfin` is true. -/
theorem R_80_finite_at_crossing
    (K_t : ℝ → ℝ) (Rsup t_star : ℝ)
    (h_cross : K_t t_star = Rsup) :
    Nfin K_t Rsup t_star := by
  unfold Nfin covered
  rw [h_cross]

/-- **R.80 — discrete threshold structure (monotone trajectory).**

If the coverage coordinate `K_t` is monotone non-decreasing (knowledge
only grows along training), then the covered set `{t : covered t}` is an
up-set: once covered, always covered.  Hence `Π_cov` is crossed exactly
once and the "pre-emergence" region `{¬ covered}` is a down-set — the
single well-defined transition of R.79/R.80. -/
theorem R_80_covered_is_upset
    (K_t : ℝ → ℝ) (Rsup : ℝ)
    (h_mono : Monotone K_t) :
    ∀ s t, s ≤ t → covered K_t Rsup s → covered K_t Rsup t := by
  intro s t h_st h_cov_s
  unfold covered at *
  exact le_trans h_cov_s (h_mono h_st)

end GrokkingCrossing

end MIP
