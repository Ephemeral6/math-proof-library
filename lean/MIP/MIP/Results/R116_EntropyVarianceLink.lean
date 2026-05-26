/-
Result R.116 — `H_K`–`Var[N]` anti-correlation through the R.89
variance decomposition (`Cj.31` half-break).

Reference: `C:/Users/12729/Desktop/MIP/workspace/frontier_attacks.md` §R.116
(攻击 #13, Cj.31 H_K 与 Var[N], intuitive modeling, "B").

**Statement.** The frontier argument is: large knowledge entropy `H_K`
(uniform knowledge use) ⟹ different problems see *similar* `K(A)`-subsets
⟹ `Φ₀(p)` fluctuates little over the problem distribution ⟹ `Var[Φ₀]` is
small ⟹ (via R.89) `Var[N]` is small.  Conversely small `H_K`
(domination by part of the knowledge) ⟹ large `Var[Φ₀]` ⟹ large `Var[N]`.

The *intuitive modeling* premise — that `Var[Φ₀]` is a **decreasing**
function of `H_K` — is bundled.  The crisp, formalisable kernel is the
**monotone-link composition**:

* (R.89) `Var[N] = Z̄²·Var[Φ₀] + σ_Z²·E[Φ₀²]`, which is **increasing** in
  `Var[Φ₀]` (impedance moments held fixed, `Z̄² ≥ 0`);
* (modeling) `Var[Φ₀] = f(H_K)` with `f` non-increasing;
* hence `Var[N]` viewed as a function of `H_K` is non-increasing — the
  `H_K ↑ ⟹ Var[N] ↓` anti-correlation.

**Bundled premises.** The alignment model `Var[Φ₀] = f(H_K)` (`f`
non-increasing) and the R.89 decomposition enter as hypotheses; the specific
functional form (linear? quadratic?) stays open, matching the source's "B".

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace EntropyVarianceLink

/-- The R.89 variance of `N` as a function of the moment inputs:
`Var[N] = Z̄²·Var[Φ₀] + σ_Z²·E[Φ₀²]`. -/
def VarN (Zbar2 VarPhi σZ2 EPhi2 : ℝ) : ℝ :=
  Zbar2 * VarPhi + σZ2 * EPhi2

/-- **R.116 (a) — `Var[N]` is non-decreasing in `Var[Φ₀]`.**

With impedance moments `Z̄² ≥ 0`, `σ_Z²`, `E[Φ₀²]` held fixed, increasing the
potential-variance `Var[Φ₀]` increases `Var[N]`.  (Monotone link from the
R.89 decomposition.) -/
theorem R_116_VarN_mono_VarPhi
    (Zbar2 σZ2 EPhi2 VarPhi₁ VarPhi₂ : ℝ)
    (hZ : 0 ≤ Zbar2) (h : VarPhi₁ ≤ VarPhi₂) :
    VarN Zbar2 VarPhi₁ σZ2 EPhi2 ≤ VarN Zbar2 VarPhi₂ σZ2 EPhi2 := by
  unfold VarN
  have : Zbar2 * VarPhi₁ ≤ Zbar2 * VarPhi₂ := mul_le_mul_of_nonneg_left h hZ
  linarith

/-- **R.116 (b) — anti-correlation `H_K ↑ ⟹ Var[N] ↓` (composition).**

Bundle the alignment model `Var[Φ₀] = f(H_K)` with `f` non-increasing.
Compose with the R.89 monotonicity (a): for two entropies `H₁ ≤ H₂`,

    Var[N](H₂)  ≤  Var[N](H₁) ,

i.e. higher knowledge entropy yields *lower* emergence-cost variance. -/
theorem R_116_antimono_in_entropy
    (Zbar2 σZ2 EPhi2 : ℝ) (f : ℝ → ℝ)
    (hZ : 0 ≤ Zbar2)
    (hf_anti : ∀ a b : ℝ, a ≤ b → f b ≤ f a)
    (H₁ H₂ : ℝ) (hH : H₁ ≤ H₂) :
    VarN Zbar2 (f H₂) σZ2 EPhi2 ≤ VarN Zbar2 (f H₁) σZ2 EPhi2 := by
  have hVar : f H₂ ≤ f H₁ := hf_anti H₁ H₂ hH
  exact R_116_VarN_mono_VarPhi Zbar2 σZ2 EPhi2 (f H₂) (f H₁) hZ hVar

/-- **R.116 (c) — strict anti-correlation.**

If the entropy gap is genuine (`H₁ < H₂`), the alignment model strictly
decreasing (`a < b ⟹ f b < f a`), and the knowledge-impedance scale is
non-degenerate (`Z̄² > 0`), then `Var[N]` strictly decreases:

    Var[N](H₂) < Var[N](H₁) . -/
theorem R_116_strict_antimono
    (Zbar2 σZ2 EPhi2 : ℝ) (f : ℝ → ℝ)
    (hZ : 0 < Zbar2)
    (hf_strict : ∀ a b : ℝ, a < b → f b < f a)
    (H₁ H₂ : ℝ) (hH : H₁ < H₂) :
    VarN Zbar2 (f H₂) σZ2 EPhi2 < VarN Zbar2 (f H₁) σZ2 EPhi2 := by
  have hVar : f H₂ < f H₁ := hf_strict H₁ H₂ hH
  unfold VarN
  have : Zbar2 * f H₂ < Zbar2 * f H₁ := mul_lt_mul_of_pos_left hVar hZ
  linarith

end EntropyVarianceLink

end MIP
