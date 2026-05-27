/-
Result R.508 — Collective coverage under heterogeneous decay.
Reference: branches/collective/workspace/new_results.md (old collective R.149).

**Statement.** A team `{A_1,…,A_k}` each have their own exponential-decay
memory: element `ω` retained by agent `i` while
`p_{ω,i}(t) = p_{ω,i}(0)·e^{−t/τ_{ω,i}} ≥ θ`, i.e. for `t ≤ T_i(ω) :=
τ_{ω,i}·log(p_{ω,i}(0)/θ)`.  The *team* still covers `ω` as long as at least one
agent retains it, so the team forgets `ω` only at `max_i T_i(ω)`.  The whole
demand set `R(p)` is lost at the first element fully forgotten:

    T_collapse^team(p) = min_{ω ∈ R(p)} max_{i ∈ V} T_i(ω) .

**Strong robustness.** `T_collapse^team ≥ T_collapse(A_i)` for every individual
`i`: the team's memory outlasts any single member ("the team is more robust than
its best member"); equality for a clone team (R.142 / R.149 max-operator duality).

**Kernel formalized here.** Four clean pieces over finite sets / reals.

1. **Union-coverage survival.** `ω` is team-covered iff *some* agent retains it:
   `(∃ i, θ ≤ p_{ω,i}(t))`.  At time `t ≤ max_i T_i(ω)` the maximiser retains
   `ω`, so the team covers it — coverage survives per element.
2. **Per-element team collapse `= max_i T_i(ω)`** (finite max attained at the
   longest-retaining agent).
3. **Team collapse `= min_{ω} max_i T_i(ω)`** (finite min over the demand set,
   attained at the weakest-link element).
4. **Robustness lower bound** `T_collapse^team ≥ T_collapse(A_i)` for each `i`
   (min of maxes dominates min of any single column).

**Bridge.** `T_i(ω) = τ_{ω,i}·log(p_{ω,i}(0)/θ)` reuses the R.152 per-element
crossing identity; the team operators are the R.149 `min_ω max_i` structure.

Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Lattice
import Mathlib.Tactic.Linarith

namespace MIP

namespace CoverageDecayRobust

open Real

/-- Per-element, per-agent retention threshold time
`T_i(ω) = τ_{ω,i} · log(p_{ω,i}(0)/θ)`: agent `i` retains element `ω`
(mass `≥ θ`) for all `t ≤ T_i(ω)`. -/
noncomputable def retainTime (τ p₀ θ : ℝ) : ℝ := τ * Real.log (p₀ / θ)

/-! ## 1. Per-element decay crossing and union-coverage survival. -/

/-- **R.508 (i) — single-agent retention identity (R.152 reuse).**

Under exponential decay `p(t) = p₀·e^{−t/τ}`, agent retains `ω` (`p(t) ≥ θ`)
iff `t ≤ τ·log(p₀/θ)`.  Equivalently it is *lost* (`p(t) < θ`) iff
`t > retainTime`.  Standard exp/log manipulation. -/
theorem R_508_retain_iff
    (p₀ τ θ t : ℝ) (h_p₀ : 0 < p₀) (h_τ : 0 < τ) (h_θ : 0 < θ) :
    θ ≤ p₀ * Real.exp (-(t / τ)) ↔ t ≤ retainTime τ p₀ θ := by
  unfold retainTime
  rw [← not_lt, ← not_lt]
  apply not_congr
  -- p₀ e^{-t/τ} < θ ⟺ τ log(p₀/θ) < t  (R.152 decay_crossing).
  have h_p₀_ne : p₀ ≠ 0 := ne_of_gt h_p₀
  have h_θ_ne : θ ≠ 0 := ne_of_gt h_θ
  have h_p_over_θ : 0 < p₀ / θ := div_pos h_p₀ h_θ
  constructor
  · intro h
    have h1 : Real.exp (-(t / τ)) < θ / p₀ := by
      rw [lt_div_iff₀ h_p₀, mul_comm]; exact h
    have h2 : -(t / τ) < Real.log (θ / p₀) := by
      have := Real.log_lt_log (Real.exp_pos _) h1
      rwa [Real.log_exp] at this
    have h_log_swap : Real.log (θ / p₀) = -Real.log (p₀ / θ) := by
      rw [← Real.log_inv, inv_div]
    rw [h_log_swap] at h2
    have h3 : Real.log (p₀ / θ) < t / τ := by linarith
    rw [lt_div_iff₀ h_τ] at h3
    linarith
  · intro h
    have h_t_over_τ : Real.log (p₀ / θ) < t / τ := by
      rw [lt_div_iff₀ h_τ]; linarith
    have h_exp : p₀ / θ < Real.exp (t / τ) := by
      have h_exp_log : Real.exp (Real.log (p₀ / θ)) = p₀ / θ :=
        Real.exp_log h_p_over_θ
      rw [← h_exp_log]
      exact Real.exp_lt_exp.mpr h_t_over_τ
    have h_neg_exp : Real.exp (-(t / τ)) = (Real.exp (t / τ))⁻¹ := by
      rw [Real.exp_neg]
    rw [h_neg_exp, mul_inv_lt_iff₀ (Real.exp_pos _), mul_comm, ← div_lt_iff₀ h_θ]
    exact h_exp

/-- **R.508 (ii) — union-coverage survival.**

For a finite team `V`, element `ω` is *team-covered* at time `t` iff some agent
still retains it: `∃ i ∈ V, θ ≤ p_{ω,i}(t)`.  If `t` does not exceed the
longest individual retention time `T_{i₀}(ω)` for some agent `i₀ ∈ V`, then the
team covers `ω`: coverage survives as long as the *best* retainer holds.  This
is the rigorous union-survives-decay kernel. -/
theorem R_508_union_coverage_survives
    {ι : Type} (V : Finset ι)
    (τ p₀ : ι → ℝ) (θ t : ℝ)
    (h_p₀ : ∀ i ∈ V, 0 < p₀ i) (h_τ : ∀ i ∈ V, 0 < τ i) (h_θ : 0 < θ)
    (i₀ : ι) (hi₀ : i₀ ∈ V) (h_t : t ≤ retainTime (τ i₀) (p₀ i₀) θ) :
    ∃ i ∈ V, θ ≤ p₀ i * Real.exp (-(t / τ i)) := by
  refine ⟨i₀, hi₀, ?_⟩
  exact (R_508_retain_iff (p₀ i₀) (τ i₀) θ t (h_p₀ i₀ hi₀) (h_τ i₀ hi₀) h_θ).mpr h_t

/-! ## 2. Per-element team collapse time `= max_i T_i(ω)`. -/

/-- **R.508 (iii) — per-element team collapse is the max over agents.**

For a finite nonempty team, the time at which *every* agent has forgotten `ω`
(the per-element team collapse) is `max_i T_i(ω)`, attained at the
longest-retaining agent.  The team holds `ω` until its most durable member
forgets it. -/
theorem R_508_per_element_collapse
    {ι : Type} (V : Finset ι) (hV : V.Nonempty)
    (T : ι → ℝ) :
    ∃ i₀ ∈ V, V.sup' hV T = T i₀ := by
  obtain ⟨i₀, hi₀, h_max⟩ := Finset.exists_max_image V T hV
  refine ⟨i₀, hi₀, ?_⟩
  apply le_antisymm
  · exact Finset.sup'_le hV T (fun i hi => h_max i hi)
  · exact Finset.le_sup' T hi₀

/-! ## 3. Team collapse time over the demand set `= min_ω max_i T_i(ω)`. -/

/-- **R.508 (iv) — team collapse time is the min-of-max.**

For a finite nonempty demand set `R(p)` and finite nonempty team `V`, the
collective coverage collapse time is

    T_collapse^team = min_{ω ∈ R(p)} max_{i ∈ V} T_i(ω) ,

attained at the weakest-link element (smallest team-retention) and, within it,
the best retainer (largest individual retention).  Pure finite min/max. -/
theorem R_508_team_collapse_min_max
    {Ω ι : Type} (Rp : Finset Ω) (hR : Rp.Nonempty)
    (V : Finset ι) (hV : V.Nonempty)
    (T : Ω → ι → ℝ) :
    ∃ ω₀ ∈ Rp, Rp.inf' hR (fun ω => V.sup' hV (T ω))
        = V.sup' hV (T ω₀) := by
  obtain ⟨ω₀, hω₀, h_min⟩ :=
    Finset.exists_min_image Rp (fun ω => V.sup' hV (T ω)) hR
  refine ⟨ω₀, hω₀, ?_⟩
  apply le_antisymm
  · exact Finset.inf'_le _ hω₀
  · exact Finset.le_inf' hR _ (fun ω hω => h_min ω hω)

/-! ## 4. Robustness: the team outlasts any single member. -/

/-- **R.508 (v) — team memory dominates each individual's.**

For every agent `i₀ ∈ V`, the team collapse time is at least that agent's own
collapse time:

    T_collapse^team = min_ω max_j T_j(ω)  ≥  min_ω T_{i₀}(ω) = T_collapse(A_{i₀}) .

Per element, `max_j T_j(ω) ≥ T_{i₀}(ω)`; taking `min_ω` of both sides preserves
the inequality.  Hence the team is more robust to decay than its best single
member (R.149 C.149.1). -/
theorem R_508_team_dominates_individual
    {Ω ι : Type} (Rp : Finset Ω) (hR : Rp.Nonempty)
    (V : Finset ι) (hV : V.Nonempty)
    (T : Ω → ι → ℝ) (i₀ : ι) (hi₀ : i₀ ∈ V) :
    Rp.inf' hR (fun ω => T ω i₀)
      ≤ Rp.inf' hR (fun ω => V.sup' hV (T ω)) := by
  -- For each ω, T_{i₀}(ω) ≤ max_j T_j(ω); lift through `inf'`.
  apply Finset.le_inf' hR
  intro ω hω
  calc Rp.inf' hR (fun ω => T ω i₀)
      ≤ T ω i₀ := Finset.inf'_le _ hω
    _ ≤ V.sup' hV (T ω) := Finset.le_sup' (T ω) hi₀

/-- **R.508 (v′) — clone team gives no robustness gain.**

If all agents are identical on `ω` (`T ω i = c ω` for every `i`, a clone team),
the team collapse time collapses to the single-agent value
`min_ω c ω`: cloning does not extend memory (R.149 C.149.3, the decay dual of
the R.142 clone-redundancy result). -/
theorem R_508_clone_no_gain
    {Ω ι : Type} (Rp : Finset Ω) (hR : Rp.Nonempty)
    (V : Finset ι) (hV : V.Nonempty)
    (T : Ω → ι → ℝ) (c : Ω → ℝ)
    (h_clone : ∀ ω, ∀ i ∈ V, T ω i = c ω) :
    Rp.inf' hR (fun ω => V.sup' hV (T ω)) = Rp.inf' hR c := by
  -- Pointwise: sup' of the constant `c ω` over the nonempty team is `c ω`.
  have h_pt : ∀ ω, V.sup' hV (T ω) = c ω := by
    intro ω
    apply le_antisymm
    · apply Finset.sup'_le hV
      intro i hi
      exact le_of_eq (h_clone ω i hi)
    · have hj : hV.choose ∈ V := hV.choose_spec
      calc c ω = T ω hV.choose := (h_clone ω hV.choose hj).symm
        _ ≤ V.sup' hV (T ω) := Finset.le_sup' (T ω) hj
  -- The two `inf'` integrands are equal as functions, hence so are the `inf'`s.
  have h_fun : (fun ω => V.sup' hV (T ω)) = c := funext h_pt
  rw [h_fun]

end CoverageDecayRobust

end MIP
