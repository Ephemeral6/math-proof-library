/-
Result R.79 (T.14) — Grokking phase-transition condition.

Reference: `proofs/derived/training_dynamics.md` R.79 (A 无条件
under A.2 + T.5 + T.8 + D.4.7).

**Statement.** Define the coverage indicator `f(t) := Pr_p[R(p) ⊆ K(A_t)]`
over a test distribution.  By A.2, `N(p, A_t) < ∞ ⟺ R(p) ⊆ K(A_t)`.

Hence the expected emergence cost `E_p[N(p, A_t)]` has a hard
discontinuity at `t* := inf{t : f(t) = 1}`:

    f(t) < 1  ⟹  E[N(t)] = ∞ ,
    f(t) = 1  ⟹  E[N(t)] < ∞ .

In particular, the grokking transition is the first time `t*` at which
coverage becomes universal.

**Pure-math content.** Two clean ingredients:

1. **Per-problem dichotomy via A.2:** `N p X < ⊤ ⟺ ∃ R' ∈ ℛ(p), R' ⊆ K(X)`.
2. **Threshold characterisation:** if `t*` is the infimum of `{t : f t = 1}`
   and `f` is monotone non-decreasing in `t` (knowledge grows over
   training), then `f(t) < 1` for `t < t*` and `f(t) = 1` for `t ≥ t*`.

This file proves the threshold-characterisation kernel.

**This file is `axiom`-free** (apart from the project's foundational
`MIP.Axioms.A2`).
-/
import MIP.Axioms

namespace MIP

namespace Grokking

open MIP.Axioms

/-- **R.79 (i) — per-problem A.2 dichotomy.**

`N(p, X) < ⊤ ⟺ ∃ R' ∈ ℛ(p), R' ⊆ K(X)`.  This is verbatim A.2 in
finiteness form: emergence cost is finite iff some knowledge demand of
`p` is covered by the agent's knowledge. -/
theorem R_79_finite_iff_cover
    {α Ω : Type} (p : Problem α) (X : Agent α) :
    N p X ≠ ⊤
      ↔
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) :=
  A2 p X

/-- **R.79 (ii) — threshold dichotomy for a monotone coverage indicator.**

If `cov : ℕ → Prop` is monotone (`cov t → cov (t+1)`) and there exists
some `t₀` with `cov t₀`, then there is a unique threshold `t* := min {t : cov t}`
such that:
* `t < t* → ¬ cov t` ,
* `t ≥ t* → cov t` .

This captures the "first time coverage holds" structure of the grokking
threshold, abstracted to its purely combinatorial form. -/
theorem R_79_threshold_dichotomy
    (cov : ℕ → Prop) [DecidablePred cov]
    (h_mono : ∀ t, cov t → cov (t + 1))
    (h_eventually : ∃ t₀, cov t₀) :
    ∃ t_star : ℕ, cov t_star ∧
      (∀ t < t_star, ¬ cov t) ∧
      (∀ t ≥ t_star, cov t) := by
  -- t* is the minimum t with cov t (well-defined by `Nat.find` + h_eventually).
  let t_star := Nat.find h_eventually
  refine ⟨t_star, Nat.find_spec h_eventually, ?_, ?_⟩
  · intro t h_lt
    exact Nat.find_min h_eventually h_lt
  · intro t h_ge
    -- Induction on `t - t_star`: starting at t_star, apply h_mono repeatedly.
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h_ge
    clear h_ge
    induction k with
    | zero =>
      simpa using Nat.find_spec h_eventually
    | succ n ih =>
      have h_eq : t_star + (n + 1) = (t_star + n) + 1 := by ring
      rw [h_eq]
      exact h_mono _ ih

end Grokking

end MIP
