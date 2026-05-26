/-
Result R.115 — Type-II two-stage cost `N_meta + N` and the necessity of
the knowledge-expansion stage.

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.115
(攻击 #12, R.10 两阶段解法, N_meta candidate-A working definition, "B / 条件 A").

**Statement.** For a Type-II problem (`R(p) ⊄ K(A_initial)`), meta-cognitive
interventions alone are useless: D.1.5 says they cannot expand `K(A)`, so by
A.2 the emergence count is infinite (`N = ∞`) without expansion.  The
problem is solved in two stages:

* **stage 1**: `N_meta := min{ n : ∃(e₁,…,eₙ) ∈ Eⁿ, R(p) ⊆ K(A⁽ⁿ⁾) }`
  knowledge-expansion operations make `R(p) ⊆ K(A⁽ᴺᵐᵉᵗᵃ⁾)`, turning `p`
  Type-I;
* **stage 2**: the ordinary emergence cost `N := N(p, A⁽ᴺᵐᵉᵗᵃ⁾)` solves it.

The total minimal cost is the additive decomposition

    N_total = N_meta + N ,

and for a *genuine* Type-II problem (`N_meta > 0`) this strictly exceeds the
post-expansion emergence cost `N`, so meta-cognitive intervention alone
(`N_meta = 0`) cannot solve `p`.

**Bundled premise.** The existence/optimality of `N_meta` (the count of
knowledge-expanding operations over `E := Σ* \ M`) is the un-formalised
primitive; it enters as a given non-negative quantity.  We encode the
**additive-cost kernel** plus the Type-II necessity inequality.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace NMetaTwoStage

/-- Two-stage total cost: expansion stage `N_meta` plus emergence stage `N`. -/
def N_total (N_meta N : ℝ) : ℝ := N_meta + N

/-- **R.115 — additive decomposition (definitional).** -/
theorem R_115_decomposition (N_meta N : ℝ) :
    N_total N_meta N = N_meta + N := rfl

/-- **R.115 — both stages lower-bound the total.**

The two-stage total dominates each stage separately: `N ≤ N_total` (the
emergence stage alone) and `N_meta ≤ N_total` (the expansion stage alone),
given the other stage is non-negative. -/
theorem R_115_total_ge_emergence
    (N_meta N : ℝ) (h_meta : 0 ≤ N_meta) :
    N ≤ N_total N_meta N := by
  unfold N_total; linarith

theorem R_115_total_ge_meta
    (N_meta N : ℝ) (h_N : 0 ≤ N) :
    N_meta ≤ N_total N_meta N := by
  unfold N_total; linarith

/-- **R.115 — Type-II necessity (strict gap).**

For a genuine Type-II problem the expansion stage is non-trivial
(`N_meta > 0`, because `R(p) ⊄ K(A_initial)` forces real knowledge
expansion).  Then the total strictly exceeds the bare emergence cost:

    N < N_meta + N .

Contrapositively, meta-cognitive intervention alone (`N_meta = 0`) can only
match the emergence cost when no expansion is needed — i.e. it is **useless**
for genuine Type-II problems. -/
theorem R_115_typeII_strict
    (N_meta N : ℝ) (h_meta_pos : 0 < N_meta) :
    N < N_total N_meta N := by
  unfold N_total; linarith

/-- **R.115 — meta-only insufficiency, exact form.**

If one attempts to solve a Type-II problem with the expansion stage skipped
(`N_meta = 0`), the achievable total collapses to `N`; but a Type-II problem
has `R(p) ⊄ K(A_initial)`, so the unexpanded emergence cost is *not* the
finite `N` of the post-expansion agent.  We record the clean algebraic
boundary: skipping expansion gives `N_total = N` exactly, which is precisely
the (impossible) Type-I assumption. -/
theorem R_115_skip_expansion_eq
    (N : ℝ) :
    N_total 0 N = N := by
  unfold N_total; rw [zero_add]

/-- **R.115 — monotonicity in each stage.**

A more expensive expansion (`N_meta ↑`) or a harder residual Type-I problem
(`N ↑`) both increase the total, the other stage fixed. -/
theorem R_115_mono_meta
    (N_meta₁ N_meta₂ N : ℝ) (h : N_meta₁ ≤ N_meta₂) :
    N_total N_meta₁ N ≤ N_total N_meta₂ N := by
  unfold N_total; linarith

theorem R_115_mono_emergence
    (N_meta N₁ N₂ : ℝ) (h : N₁ ≤ N₂) :
    N_total N_meta N₁ ≤ N_total N_meta N₂ := by
  unfold N_total; linarith

end NMetaTwoStage

end MIP
