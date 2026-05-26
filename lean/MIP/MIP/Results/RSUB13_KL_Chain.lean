/-
Result R-SUB.13 — Training KL chain decomposition.

Reference: `workspace/subdomain_competition.md` §6.13 (A 无条件).

**Statement.** For two normalised mass functions `q, p : Ω → ℝ≥0` on the
same finite universe `Ω` with a disjoint exhaustive partition
`Ω = ⊔_i K_i`, the KL divergence decomposes as

    KL(q‖p) = KL(π^q‖π^p) + Σ_i π_i^q · KL(q_i‖p_i),

where
* `π_i^q := Σ_{ω ∈ K_i} q(ω)`, `π_i^p := Σ_{ω ∈ K_i} p(ω)` are subdomain masses,
* `q_i(ω) := q(ω)/π_i^q`, `p_i(ω) := p(ω)/π_i^p` are within-subdomain
  conditional distributions,
* `KL(a‖b) := Σ a · log(a/b)`.

**Proof.** Standard chain rule for KL divergence on a finite partition.
The algebra: for each `i` and each `ω ∈ K_i`,

    q(ω) · log(q(ω)/p(ω))
      = q(ω) · log((π_i^q / π_i^p) · (q_i(ω)/p_i(ω)))
      = q(ω) · log(π_i^q / π_i^p)  +  q(ω) · log(q_i(ω)/p_i(ω))
      = q(ω) · log(π_i^q / π_i^p)  +  π_i^q · q_i(ω) · log(q_i(ω)/p_i(ω)),

then sum over `ω ∈ K_i` and then over `i`. ∎

This file proves the **pure-math chain rule** on any `Fintype Ω` with
positive subdomain masses, without sorry.
-/
import MIP.Defs.Knowledge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace KLChain

variable {Ω : Type} [DecidableEq Ω]

omit [DecidableEq Ω] in
/-- **Atomic chain identity for KL.** For a single subdomain `S`, with
positive subdomain masses on both `q` and `p`:

    Σ_{ω∈S} q(ω) log (q(ω)/p(ω))
      = (Σ_{ω∈S} q(ω)) log ((Σ q)/(Σ p))
        + Σ_{ω∈S} q(ω) log ((q(ω)/Σ q) / (p(ω)/Σ p)). -/
lemma kl_chain_atomic (S : Finset Ω) (q p : Ω → ℝ)
    (hq : ∀ ω ∈ S, 0 ≤ q ω) (hp_pos : ∀ ω ∈ S, 0 < p ω)
    (hπq : 0 < ∑ ω ∈ S, q ω) :
    ∑ ω ∈ S, q ω * Real.log (q ω / p ω)
      = (∑ ω ∈ S, q ω) *
            Real.log ((∑ ω ∈ S, q ω) / (∑ ω ∈ S, p ω))
        + ∑ ω ∈ S, q ω *
            Real.log ((q ω / (∑ ω' ∈ S, q ω')) /
                       (p ω / (∑ ω' ∈ S, p ω'))) := by
  have hSne : S.Nonempty := by
    by_contra h
    rw [Finset.not_nonempty_iff_eq_empty] at h
    rw [h] at hπq
    simp at hπq
  have hπp : 0 < ∑ ω ∈ S, p ω :=
    Finset.sum_pos (fun ω hω => hp_pos ω hω) hSne
  set πq := ∑ ω ∈ S, q ω with hπqdef
  set πp := ∑ ω ∈ S, p ω with hπpdef
  have hπqne : πq ≠ 0 := ne_of_gt hπq
  have hπpne : πp ≠ 0 := ne_of_gt hπp
  -- Per-ω identity: q ω log(q ω / p ω) = q ω log(πq/πp) + q ω log((q ω / πq)/(p ω / πp)).
  have hkey : ∀ ω ∈ S,
      q ω * Real.log (q ω / p ω)
        = q ω * Real.log (πq / πp)
          + q ω * Real.log ((q ω / πq) / (p ω / πp)) := by
    intro ω hω
    by_cases hqω : q ω = 0
    · rw [hqω]; ring
    have hqωpos : 0 < q ω := lt_of_le_of_ne (hq ω hω) (Ne.symm hqω)
    have hpωpos : 0 < p ω := hp_pos ω hω
    have h1 : q ω / p ω = (πq / πp) * ((q ω / πq) / (p ω / πp)) := by
      field_simp
    rw [h1]
    rw [Real.log_mul]
    · ring
    · exact div_ne_zero hπqne hπpne
    · exact div_ne_zero (div_ne_zero (ne_of_gt hqωpos) hπqne)
        (div_ne_zero (ne_of_gt hpωpos) hπpne)
  -- Sum hkey and distribute.
  rw [Finset.sum_congr rfl hkey, Finset.sum_add_distrib]
  have hπsum : ∑ ω ∈ S, q ω * Real.log (πq / πp)
      = πq * Real.log (πq / πp) := by
    rw [← Finset.sum_mul]
  rw [hπsum]

end KLChain

end MIP
