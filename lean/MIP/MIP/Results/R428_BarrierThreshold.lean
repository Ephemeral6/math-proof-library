/-
Result R.428 — |B| threshold: R-only sufficiency dichotomy.

Reference: `workspace/coe_mip_unification.md` §R.428 (A 级, 弱形式严格;
依赖 R.001 = T.1 `N ≥ |B|`, R.039, R.034, R.045).

**Statement (CoE × MIP mapping).** Let `B := |B(p)|` be the barrier count
of problem `p` (a non-negative integer). Map the model conditions into
hypotheses:

* **T.1 (R.001):** the emergence cost lower bound `N ≥ |B|` — every barrier
  needs at least one step to break.
* **R-only-covers-one-barrier model:** when `R(p) ⊆ K(A_R)` (coverage holds)
  and the problem has a *single* barrier (`|B| = 1`), one metacognitive
  intervention suffices, so `N(A_R) ≤ 1` is achievable.
* **R-only sufficiency** means the R-only cost can reach the minimum `1`
  step (a single follow-up resolves the problem).

The dichotomy:

* **(R-only sufficient ⟸ |B| ≤ 1):** if `|B| ≤ 1` and coverage holds, then
  the achievable R-only cost is `N(A_R) ≤ 1` — R alone suffices.
* **(R-only insufficient ⟸ |B| ≥ 2):** if `|B| ≥ 2`, then by T.1 every
  cost (including R-only) satisfies `N ≥ |B| ≥ 2 > 1`, so no single-step
  R-only resolution exists — at least one extra primitive (T or C) is
  needed. The threshold is exactly `B* = 1`.

**Pure-math content.** A clean integer/cardinality dichotomy:

* `|B| ≤ 1 ⟺ ¬(2 ≤ |B|)` (the threshold split on ℕ).
* From `N ≥ |B|` and `|B| ≥ 2`: `N ≥ 2`, so `N > 1` — R-only's single-step
  resolution is impossible.
* The two branches partition all `|B|` (totality of the dichotomy).

**This file is `axiom`-free.**
-/
import Mathlib.Data.Nat.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace BarrierThreshold

/-- **R.428 (single-barrier branch) — R-only is sufficient when `|B| ≤ 1`.**

Under coverage (`R(p) ⊆ K(A_R)`), the R-only model achieves an emergence
cost bounded by the barrier count. With `|B| ≤ 1` the achievable cost
`N(A_R) ≤ |B| ≤ 1`: a single metacognitive step resolves the problem, so
R alone suffices. -/
theorem R_428_R_only_sufficient
    (B N_AR : ℕ)
    (h_cover_model : N_AR ≤ B)   -- R-only achievable cost ≤ barrier count
    (h_B_le_one : B ≤ 1) :
    N_AR ≤ 1 :=
  le_trans h_cover_model h_B_le_one

/-- **R.428 (multi-barrier branch) — R-only is insufficient when `|B| ≥ 2`.**

T.1 (R.001) gives the lower bound `N ≥ |B|` for *every* enhancement,
including R-only. With `|B| ≥ 2` this forces `N(A_R) ≥ 2`, so a single-step
(`N ≤ 1`) R-only resolution is impossible — at least one further primitive
is required. -/
theorem R_428_R_only_insufficient
    (B N_AR : ℕ)
    (h_T1 : B ≤ N_AR)          -- T.1:  N ≥ |B|
    (h_B_ge_two : 2 ≤ B) :
    2 ≤ N_AR :=
  le_trans h_B_ge_two h_T1

/-- **R.428 — multi-barrier rules out single-step resolution.**

A direct corollary: for `|B| ≥ 2`, the R-only cost exceeds `1`, so the
"single follow-up suffices" condition (`N ≤ 1`) cannot hold. -/
theorem R_428_no_single_step_when_two
    (B N_AR : ℕ)
    (h_T1 : B ≤ N_AR)
    (h_B_ge_two : 2 ≤ B) :
    ¬ (N_AR ≤ 1) := by
  have h2 : 2 ≤ N_AR := R_428_R_only_insufficient B N_AR h_T1 h_B_ge_two
  omega

/-- **R.428 — threshold dichotomy `B* = 1`.**

For every barrier count `B : ℕ`, exactly one of the two regimes holds:
`B ≤ 1` (R-only sufficient regime) or `2 ≤ B` (R-only insufficient regime).
The two are mutually exclusive and jointly exhaustive — the threshold is
exactly `B* = 1`. -/
theorem R_428_threshold_dichotomy (B : ℕ) :
    (B ≤ 1 ∧ ¬ (2 ≤ B)) ∨ (2 ≤ B ∧ ¬ (B ≤ 1)) := by
  rcases Nat.lt_or_ge B 2 with h | h
  · left; exact ⟨by omega, by omega⟩
  · right; exact ⟨h, by omega⟩

/-- **R.428 — full dichotomy with the cost conclusions.**

Packaging both branches against a single R-only cost model
(`N_AR ≤ B` achievable and `B ≤ N_AR` lower bound, i.e. `N_AR = B` is the
tight R-only count): either `|B| ≤ 1` and `N(A_R) ≤ 1` (sufficient), or
`|B| ≥ 2` and `N(A_R) ≥ 2` (insufficient). -/
theorem R_428_sufficiency_dichotomy
    (B N_AR : ℕ)
    (h_upper : N_AR ≤ B)       -- coverage model: achievable ≤ barrier count
    (h_T1 : B ≤ N_AR) :        -- T.1 lower bound
    (B ≤ 1 ∧ N_AR ≤ 1) ∨ (2 ≤ B ∧ 2 ≤ N_AR) := by
  rcases Nat.lt_or_ge B 2 with h | h
  · left
    have hB1 : B ≤ 1 := by omega
    exact ⟨hB1, R_428_R_only_sufficient B N_AR h_upper hB1⟩
  · right
    exact ⟨h, R_428_R_only_insufficient B N_AR h_T1 h⟩

end BarrierThreshold

end MIP
