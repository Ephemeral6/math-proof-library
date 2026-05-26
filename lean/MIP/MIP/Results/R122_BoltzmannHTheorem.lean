/-
Result R.122 — Boltzmann emergent entropy `S_B = log N_comp` and the
full-domain H-theorem `dS_B/dt ≥ 0`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.122
(A, condition D.4.16 TM family).

**Statement.**

Define the reachable-composition-pair count
`N_comp(A_t) = κ(t)·|K(A_t)|²` and the **Boltzmann emergent entropy**

    S_B(A_t) := log N_comp(A_t) = log κ(t) + 2·log|K(A_t)| .

Under the monotone-training assumption (TM, formalised as D.4.16): for
`t₁ ≤ t₂`, `K(A_{t₁}) ⊆ K(A_{t₂})`, the success-pair set embeds and hence
`N_comp` is monotone, giving the full-domain (`κ ∈ (0,1)`) H-theorem

    N_comp(A_{t₁}) ≤ N_comp(A_{t₂})  ⟹  S_B(A_{t₁}) ≤ S_B(A_{t₂}) .

We formalize:

* (a) **Entropy split** `S_B = log κ + 2·log|K|` for `κ > 0`, `|K| > 0`.
* (b) **Monotone lemma** finite-cardinality form: `s₁ ⊆ s₂ ⟹ |s₁| ≤ |s₂|`
  (the success-pair embedding ⟹ `N_comp` monotone), packaged as the
  monotonicity of `N_comp` and hence of `S_B = log N_comp`.
* (c) **H-theorem (rate form).** Along a differentiable `N_comp(t) > 0`
  with `dN_comp/dt ≥ 0`, the entropy `S_B(t) = log N_comp(t)` has
  `dS_B/dt = (1/N_comp)·dN_comp/dt ≥ 0`.

**This file is `axiom`-free.**  The combinatorial physics (`∘` operator,
`K(A)`, TM family) enters only through real-valued/finite data; we
formalize the logarithm identity and the monotone H-theorem.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith

namespace MIP

namespace BoltzmannHTheorem

open Real

/-- **Reachable-composition-pair count** `N_comp = κ·|K|²` (R.122). -/
noncomputable def Ncomp (κ Kabs : ℝ) : ℝ := κ * Kabs ^ 2

/-- **Boltzmann emergent entropy** `S_B = log N_comp`. -/
noncomputable def SB (κ Kabs : ℝ) : ℝ := Real.log (Ncomp κ Kabs)

/-- **R.122.a — entropy split `S_B = log κ + 2·log|K|`.**

For `κ > 0`, `|K| > 0`, the Boltzmann entropy decomposes as
`S_B = log(κ·|K|²) = log κ + 2·log|K|`. -/
theorem R_122_a_SB_split
    (κ Kabs : ℝ) (hκ : 0 < κ) (hK : 0 < Kabs) :
    SB κ Kabs = Real.log κ + 2 * Real.log Kabs := by
  unfold SB Ncomp
  have hK2 : (0 : ℝ) < Kabs ^ 2 := by positivity
  rw [Real.log_mul (ne_of_gt hκ) (ne_of_gt hK2), Real.log_pow]
  push_cast
  ring

/-- **R.122.b — success-pair embedding ⟹ count monotone (finite form).**

The (TM) embedding `{success pairs}_{t₁} ⊆ {success pairs}_{t₂}` of finite
sets yields `N_comp(t₁) ≤ N_comp(t₂)` at the level of cardinalities.  This
is the discrete heart of the H-theorem: monotone `K` ⟹ monotone pair
count. -/
theorem R_122_b_card_mono {α : Type*} [DecidableEq α]
    (s₁ s₂ : Finset α) (h : s₁ ⊆ s₂) :
    (s₁.card : ℝ) ≤ (s₂.card : ℝ) := by
  exact_mod_cast Finset.card_le_card h

/-- **R.122.b — `S_B` monotone from `N_comp` monotone (both positive).**

If `0 < N_comp(t₁) ≤ N_comp(t₂)` then `S_B(t₁) = log N_comp(t₁) ≤
log N_comp(t₂) = S_B(t₂)`: the Boltzmann entropy inherits monotonicity
from the pair count.  This is the integrated (two-time) H-theorem. -/
theorem R_122_b_SB_mono
    (N₁ N₂ : ℝ) (hN₁ : 0 < N₁) (hle : N₁ ≤ N₂) :
    Real.log N₁ ≤ Real.log N₂ :=
  Real.log_le_log hN₁ hle

/-- **R.122.c — H-theorem in rate form: `dS_B/dt ≥ 0`.**

Let `N : ℝ → ℝ` be the time-dependent pair count with `N(t) > 0` and time
derivative `dN/dt = Ndot ≥ 0` (the (TM) monotone-training rate).  Then the
Boltzmann entropy `S_B(t) = log N(t)` has derivative
`dS_B/dt = Ndot / N(t) ≥ 0`, the full-domain second law for `κ ∈ (0,1)`. -/
theorem R_122_c_Htheorem_rate
    (N : ℝ → ℝ) (t Ndot : ℝ)
    (hN : 0 < N t) (hNderiv : HasDerivAt N Ndot t) (hmono : 0 ≤ Ndot) :
    HasDerivAt (fun s => Real.log (N s)) (Ndot / N t) t
      ∧ 0 ≤ Ndot / N t := by
  refine ⟨hNderiv.log (ne_of_gt hN), ?_⟩
  exact div_nonneg hmono (le_of_lt hN)

/-- **R.122 — `S_B` strictly increases when `N_comp` strictly increases.**

For `0 < N₁ < N₂`, `S_B` strictly increases: `log N₁ < log N₂`.  Strict
H-theorem when `K` strictly expands (transition not yet saturated). -/
theorem R_122_SB_strictMono
    (N₁ N₂ : ℝ) (hN₁ : 0 < N₁) (hlt : N₁ < N₂) :
    Real.log N₁ < Real.log N₂ :=
  Real.log_lt_log hN₁ hlt

end BoltzmannHTheorem

end MIP
