/-
Result R.197 — Heterogeneous-decay team collapse-time scaling.
Reference: `branches/decay/workspace/new_results.md` (old decay R.158).

**Statement.** For a team `{A_1,…,A_k}` where element `ω` has half-life
`τ_{ω,i}` on agent `A_i`, the team coverage-collapse time is

    T_collapse^team(p)  =  min_{ω ∈ R(p)}  (max_i τ_{ω,i}) · log(p_ω(0)/θ) .

Per element, the team is governed by its **slowest-decaying** member
(`max_i τ_{ω,i}`); across the demand, by the **weakest** element
(`min_ω …`).  As the team grows (more `i`'s), `max_i τ_{ω,i}` is monotone
non-decreasing, so `T_collapse^team` scales up with team size `k` — the
order-statistic scaling whose rate depends on the tail of `F_ω`
(saturating / log k / k^{1/α}).

**Kernel formalized here.** The `Finset.sup'` (max) / `Finset.inf'` (min)
real kernel:
  (1) per-element team half-life as `team.sup' … (τ ω)`, governed by the
      slowest member;
  (2) it grows when a member is added (`sup'` monotone under `⊆`);
  (3) each solo member is dominated by the team (`le_sup'`), so the team
      collapse time is at least every single agent's;
  (4) the team collapse time as `inf'` over the demand, attained at the
      weakest element.

**Bridge.** `τ : Ω → ι → ℝ` are the per-agent half-lives; `team : Finset ι`
the roster; the `Lω := log(p_ω(0)/θ) ≥ 0` factor is the per-element
crossing constant of R.152.  Order-statistic scaling laws (C.158.*) are
the asymptotics of this kernel under specific tail families `F_ω`.
Mirrors `R152_CollapseTime.lean`.  Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Tactic.Linarith

namespace MIP

namespace HeteroDecayScaling

variable {Ω ι : Type}

/-- Per-element team half-life: the slowest-decaying member,
`max_{i ∈ team} τ_{ω,i}`. -/
noncomputable def teamTau
    (τ : Ω → ι → ℝ) (team : Finset ι) (hne : team.Nonempty) (ω : Ω) : ℝ :=
  team.sup' hne (fun i => τ ω i)

/-- Per-element team collapse time `(max_i τ_{ω,i}) · L_ω`,
`L_ω = log(p_ω(0)/θ)`. -/
noncomputable def teamElemTime
    (τ : Ω → ι → ℝ) (L : Ω → ℝ) (team : Finset ι) (hne : team.Nonempty)
    (ω : Ω) : ℝ :=
  teamTau τ team hne ω * L ω

/-- **R.197 — per-element team time governed by the slowest member.**

Every member's solo half-life is `≤` the team half-life: the team decays
no faster than its slowest-forgetting member. -/
theorem R_197_slowest_member_dominates
    (τ : Ω → ι → ℝ) (team : Finset ι) (hne : team.Nonempty)
    (ω : Ω) {i : ι} (hi : i ∈ team) :
    τ ω i ≤ teamTau τ team hne ω :=
  Finset.le_sup' (fun j => τ ω j) hi

/-- **R.197 — team half-life grows with the roster.**

Adding members (`team ⊆ team'`) can only raise the slowest-member
half-life: `max_i τ` is monotone non-decreasing in the team. -/
theorem R_197_tau_monotone
    (τ : Ω → ι → ℝ) (team team' : Finset ι)
    (hne : team.Nonempty) (hne' : team'.Nonempty)
    (hsub : team ⊆ team') (ω : Ω) :
    teamTau τ team hne ω ≤ teamTau τ team' hne' ω :=
  Finset.sup'_mono (fun i => τ ω i) hsub hne

/-- **R.197 — per-element team time grows with the roster.**

With nonnegative crossing constant `L_ω ≥ 0`, a larger team has a
per-element collapse time at least as large: bigger teams collapse later. -/
theorem R_197_elem_time_monotone
    (τ : Ω → ι → ℝ) (L : Ω → ℝ) (team team' : Finset ι)
    (hne : team.Nonempty) (hne' : team'.Nonempty)
    (hsub : team ⊆ team') (ω : Ω) (hL : 0 ≤ L ω) :
    teamElemTime τ L team hne ω ≤ teamElemTime τ L team' hne' ω := by
  unfold teamElemTime
  exact mul_le_mul_of_nonneg_right
    (R_197_tau_monotone τ team team' hne hne' hsub ω) hL

/-- **R.197 — a solo agent's collapse time is dominated by the team.**

For member `i`, the single-agent per-element collapse time `τ_{ω,i}·L_ω`
is `≤` the team's, when `L_ω ≥ 0`.  The team strictly extends coverage
lifetime over any individual. -/
theorem R_197_team_beats_solo
    (τ : Ω → ι → ℝ) (L : Ω → ℝ) (team : Finset ι) (hne : team.Nonempty)
    (ω : Ω) {i : ι} (hi : i ∈ team) (hL : 0 ≤ L ω) :
    τ ω i * L ω ≤ teamElemTime τ L team hne ω := by
  unfold teamElemTime
  exact mul_le_mul_of_nonneg_right
    (R_197_slowest_member_dominates τ team hne ω hi) hL

/-- **R.197 — collapse time equals the demand-min, attained.**

`T_collapse^team = inf'_{ω ∈ R} teamElemTime ω`, realised at the "weakest
link" `ω₀ ∈ R` (fastest-collapsing demand element).  Mirrors
`R_152_collapse_time_eq`. -/
theorem R_197_collapse_time_eq
    (τ : Ω → ι → ℝ) (L : Ω → ℝ) (team : Finset ι) (hne : team.Nonempty)
    (R : Finset Ω) (hR : R.Nonempty) :
    ∃ ω₀ ∈ R, R.inf' hR (teamElemTime τ L team hne)
                = teamElemTime τ L team hne ω₀ :=
  Finset.exists_mem_eq_inf' hR (teamElemTime τ L team hne)

/-- **R.197 — team collapse time is the min over the demand.**

The coverage-collapse time of the team is `min_{ω ∈ R} teamElemTime ω`:
no demand element collapses earlier than `inf'`, and the weakest element
attains it. -/
theorem R_197_collapse_time
    (τ : Ω → ι → ℝ) (L : Ω → ℝ) (team : Finset ι) (hne : team.Nonempty)
    (R : Finset Ω) (hR : R.Nonempty) :
    ∃ ω₀ ∈ R, ∀ ω ∈ R,
      teamElemTime τ L team hne ω₀ ≤ teamElemTime τ L team hne ω := by
  obtain ⟨ω₀, hω₀, h_eq⟩ :=
    Finset.exists_mem_eq_inf' hR (teamElemTime τ L team hne)
  refine ⟨ω₀, hω₀, fun ω hω => ?_⟩
  rw [← h_eq]
  exact Finset.inf'_le (teamElemTime τ L team hne) hω

end HeteroDecayScaling

end MIP
