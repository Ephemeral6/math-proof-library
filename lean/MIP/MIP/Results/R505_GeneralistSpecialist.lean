/-
Result R.505 — Generalist vs specialist division-of-labor tradeoff.
Reference: branches/collective/workspace/new_results.md (old collective R.146).

**Statement.** A fixed resource budget `R` is split among `k` agents.
Generalist strategy: each agent gets `R/k`, capability `m = f(R/k)`, total team
coverage mass `k·f(R/k)`.  Specialist strategy: `k_s < k` agents get `R/k_s`,
the rest get nothing, total mass `k_s·f(R/k_s)`.  Since `N_G` is monotone
non-increasing in the diversity parameter `λ = (total mass)/M_total` (R.504),
minimising `N_G` ⟺ maximising total contributed mass `g(k) := k·f(R/k)`.

Conclusion:
* `f` concave (diminishing returns, scaling-law exponent `β < 1`) ⟹ `g` is
  monotone increasing in `k` ⟹ **generalist** optimal (spread the budget);
* `f` convex (`β > 1`) ⟹ `g` decreasing ⟹ **specialist** optimal (concentrate);
* `f` linear (`β = 1`) ⟹ `g` constant ⟹ strategies equivalent.

**Kernel formalized here.** With the power-law effort model `f(R) = R^β`
(`R.95` scaling-law input), `g(k) = k · (R/k)^β = R^β · k^(1−β)` and the
comparison reduces to the sign of the exponent `1 − β`:

1. `g(k) = R^β · k^(1−β)`  (exact `rpow` algebraic identity).
2. **β < 1 (concave) ⟹ generalist:**  `k₁ ≤ k₂ ⟹ g(k₁) ≤ g(k₂)`
   (more agents ⟹ at least as much coverage; `k^(1−β)` increasing).
3. **β > 1 (convex) ⟹ specialist:**  `k₁ ≤ k₂ ⟹ g(k₂) ≤ g(k₁)`
   (`k^(1−β)` decreasing; concentrate into the fewest agents).
4. **β = 1 (linear) ⟹ equivalent:** `g` is the constant `R`.
5. **Generalist vs specialist comparison** (`k_s ≤ k`): under concavity the
   generalist mass dominates the specialist mass — the efficiency ratio
   `η = (k_s/k)^(1−β) ≤ 1`.

**Bridge.** `g(k) = k·f(R/k)` is the R.504 diversity parameter numerator;
`argmax_strategy g` minimises `N_G`.  `f = rpow β` is the R.95 power-law input.

Axiom-free.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace GeneralistSpecialist

open Real

/-- Effective team coverage mass under the power-law effort model
`f(R) = R^β`, with `k` agents each receiving budget `R/k`:

    g(k) := k · (R/k)^β . -/
noncomputable def teamMass (R β k : ℝ) : ℝ := k * (R / k) ^ β

/-! ## 1. Closed form `g(k) = R^β · k^(1−β)`. -/

/-- **R.505 (i) — closed form of the team coverage mass.**

For `R > 0`, `k > 0`:  `g(k) = k · (R/k)^β = R^β · k^(1−β)`.  This isolates the
team size into the single factor `k^(1−β)`, whose sign of exponent decides the
optimal strategy.  Pure `rpow` algebra. -/
theorem R_505_teamMass_closed_form
    (R β k : ℝ) (hR : 0 < R) (hk : 0 < k) :
    teamMass R β k = R ^ β * k ^ (1 - β) := by
  unfold teamMass
  have hRk : (0 : ℝ) < R / k := div_pos hR hk
  rw [Real.div_rpow (le_of_lt hR) (le_of_lt hk)]
  -- k * (R^β / k^β) = R^β * k^(1-β)
  rw [Real.rpow_sub hk, Real.rpow_one]
  field_simp

/-! ## 2. Concave `β < 1`: generalist optimal (`g` increasing in `k`). -/

/-- **R.505 (ii) — concave regime: more agents never reduce coverage.**

If the scaling exponent satisfies `β ≤ 1` (concave / diminishing-returns effort
function, the empirical AI regime `β ≈ 0.5`), then the team coverage mass is
monotone non-decreasing in the number of agents:

    k₁ ≤ k₂  ⟹  g(k₁) ≤ g(k₂) .

Hence the **generalist** strategy (spread the budget over as many agents as
possible) maximises coverage and therefore minimises `N_G` (R.504). -/
theorem R_505_concave_generalist
    (R β k₁ k₂ : ℝ) (hR : 0 < R) (hβ : β ≤ 1)
    (hk₁ : 0 < k₁) (hk : k₁ ≤ k₂) :
    teamMass R β k₁ ≤ teamMass R β k₂ := by
  have hk₂ : 0 < k₂ := lt_of_lt_of_le hk₁ hk
  rw [R_505_teamMass_closed_form R β k₁ hR hk₁,
      R_505_teamMass_closed_form R β k₂ hR hk₂]
  -- R^β > 0; reduce to k₁^(1-β) ≤ k₂^(1-β) with exponent 1-β ≥ 0.
  have hRβ : 0 < R ^ β := Real.rpow_pos_of_pos hR β
  apply mul_le_mul_of_nonneg_left _ (le_of_lt hRβ)
  exact Real.rpow_le_rpow (le_of_lt hk₁) hk (by linarith)

/-! ## 3. Convex `β > 1`: specialist optimal (`g` decreasing in `k`). -/

/-- **R.505 (iii) — convex regime: concentration wins.**

If `β ≥ 1` (convex / increasing-returns effort, the emergent-scaling regime),
the team coverage mass is monotone non-increasing in the number of agents:

    k₁ ≤ k₂  ⟹  g(k₂) ≤ g(k₁) .

Hence the **specialist** strategy (concentrate the budget into the fewest
agents, `k_s = 1`) maximises coverage and minimises `N_G`. -/
theorem R_505_convex_specialist
    (R β k₁ k₂ : ℝ) (hR : 0 < R) (hβ : 1 ≤ β)
    (hk₁ : 0 < k₁) (hk : k₁ ≤ k₂) :
    teamMass R β k₂ ≤ teamMass R β k₁ := by
  have hk₂ : 0 < k₂ := lt_of_lt_of_le hk₁ hk
  rw [R_505_teamMass_closed_form R β k₁ hR hk₁,
      R_505_teamMass_closed_form R β k₂ hR hk₂]
  have hRβ : 0 < R ^ β := Real.rpow_pos_of_pos hR β
  apply mul_le_mul_of_nonneg_left _ (le_of_lt hRβ)
  -- exponent 1 - β ≤ 0, so k^(1-β) is antitone in the base on positives.
  exact Real.rpow_le_rpow_of_nonpos hk₁ hk (by linarith)

/-! ## 4. Linear `β = 1`: strategies equivalent. -/

/-- **R.505 (iv) — linear regime: generalist ≡ specialist.**

When `β = 1` the effort function is linear, and the team coverage mass is the
constant `g(k) = R` independent of `k`.  Generalist and specialist strategies
deliver identical coverage. -/
theorem R_505_linear_equivalent
    (R k : ℝ) (hR : 0 < R) (hk : 0 < k) :
    teamMass R 1 k = R := by
  rw [R_505_teamMass_closed_form R 1 k hR hk]
  simp [Real.rpow_one, sub_self, Real.rpow_zero]

/-! ## 5. Generalist-vs-specialist comparison and the efficiency ratio. -/

/-- **R.505 (v) — generalist dominates specialist under concavity.**

Comparing the specialist team (`k_s` agents) against the generalist team
(`k` agents, `k_s ≤ k`) under concave effort (`β ≤ 1`):

    g(k_s) ≤ g(k) ,

i.e. the generalist coverage mass is at least the specialist mass.  This is the
exact statement that the efficiency ratio `η = g(k_s)/g(k) = (k_s/k)^(1−β) ≤ 1`
favours uniform (generalist) division of labour in the empirical regime. -/
theorem R_505_generalist_dominates
    (R β k_s k : ℝ) (hR : 0 < R) (hβ : β ≤ 1)
    (hks : 0 < k_s) (hle : k_s ≤ k) :
    teamMass R β k_s ≤ teamMass R β k :=
  R_505_concave_generalist R β k_s k hR hβ hks hle

/-- **R.505 (v′) — efficiency ratio is the power `(k_s/k)^(1−β)`.**

The generalist/specialist efficiency ratio has the closed form

    η = g(k_s) / g(k) = (k_s / k)^(1−β) ,

making explicit that `β < 1 ⟹ η ≤ 1` (generalist optimal) and
`β > 1 ⟹ η ≥ 1` (specialist optimal).  Pure `rpow` algebra. -/
theorem R_505_efficiency_ratio
    (R β k_s k : ℝ) (hR : 0 < R) (hks : 0 < k_s) (hk : 0 < k) :
    teamMass R β k_s / teamMass R β k = (k_s / k) ^ (1 - β) := by
  rw [R_505_teamMass_closed_form R β k_s hR hks,
      R_505_teamMass_closed_form R β k hR hk]
  have hRβ : (0 : ℝ) < R ^ β := Real.rpow_pos_of_pos hR β
  have hk1 : (0 : ℝ) < k ^ (1 - β) := Real.rpow_pos_of_pos hk (1 - β)
  rw [Real.div_rpow (le_of_lt hks) (le_of_lt hk)]
  field_simp

end GeneralistSpecialist

end MIP
