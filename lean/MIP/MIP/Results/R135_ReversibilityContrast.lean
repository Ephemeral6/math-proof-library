/-
Result R.135 — Dual asymmetry of phase-space trajectory reversibility for
A versus H.

Reference: `branches/duality/workspace/new_results.md` R.135
(A 条件 under HLF-class application, 2026-05-18 duality branch).

**Statement.** In the 4D capability phase space the AI trajectory
`t ↦ S_A(t)` is, under the standard training premises (R.95 Heaps
monotonicity + R.98 Gompertz injectivity + Z slow-varying), a strictly
monotone — hence injective — continuous curve, so it is **mathematically
reversible** (left-invertible: any later state determines the time and
thus the whole history). By contrast the human trajectory `t ↦ S_H(t)`
under the Human-Learning-Forgetting model (H1)-(H3) is non-monotone and
self-intersecting: there exist `a ≠ b` with `S_H a = S_H b`, so `S_H` is
**not injective** and admits **no left inverse**. The dual contrast is
maximal on the reversibility axis: `Inv(A) = 1`, `Inv(H) = 0`.

This file formalises the clean structural kernel:

* `StrictMono S_A ⟹ Function.Injective S_A` (R.135 (i), via
  `StrictMono.injective`), and the existence of a genuine left inverse
  on the trajectory.
* a concrete collision witness `S_H a = S_H b` with `a ≠ b` makes `S_H`
  **not** injective, hence it has **no** left inverse (R.135 (ii)).
* the combined dual contrast
  `Function.Injective S_A ∧ ¬ Function.Injective S_H` (R.135 (iii)).

The upstream MIP facts (strict monotonicity of `S_A` from R.95/R.98; the
HLF collision witness for `S_H`) enter as explicit hypotheses, matching
the A-conditional status of R.135.

**This file is `axiom`-free.**
-/
import Mathlib.Order.Monotone.Basic
import Mathlib.Logic.Function.Basic
import Mathlib.Data.Real.Basic

namespace MIP

namespace ReversibilityContrast

/-- **R.135 (i) — strict monotonicity ⟹ injectivity.**

Under R.95 (Heaps monotone) + R.98 (Gompertz injective) + Z slow-varying,
the AI capability map `S_A : ℝ → ℝ` is strictly monotone, hence injective:
distinct training times give distinct phase-space states. -/
theorem R_135_i_strictMono_injective
    (S_A : ℝ → ℝ) (h_mono : StrictMono S_A) :
    Function.Injective S_A :=
  h_mono.injective

/-- **R.135 (i) — an injective trajectory has a genuine left inverse.**

Mathematical reversibility: there exists `r : ℝ → ℝ` with
`r (S_A t) = t` for every `t`, so any observed state `S_A t` reconstructs
its time `t` and thereby the entire history. This is exactly the
"left-invertible on its range" content (`Inv(A) = 1`). -/
theorem R_135_i_injective_hasLeftInverse
    (S_A : ℝ → ℝ) (h_mono : StrictMono S_A) :
    ∃ r : ℝ → ℝ, Function.LeftInverse r S_A :=
  (h_mono.injective).hasLeftInverse

/-- **R.135 (ii) — a collision witness destroys injectivity.**

Under HLF (H1)-(H3) the human trajectory `S_H` is non-monotone and
self-intersecting: a single pair `a ≠ b` with `S_H a = S_H b` already
forces `S_H` to be non-injective. (`Inv(H) = 0`, mathematical
irreversibility.) -/
theorem R_135_ii_collision_not_injective
    (S_H : ℝ → ℝ) {a b : ℝ} (h_ne : a ≠ b) (h_eq : S_H a = S_H b) :
    ¬ Function.Injective S_H := by
  intro h_inj
  exact h_ne (h_inj h_eq)

/-- **R.135 (ii) — no left inverse for a self-intersecting trajectory.**

A left inverse would recover the time from the state, contradicting the
collision `S_H a = S_H b` with `a ≠ b`. Hence no left inverse exists:
the human past state is unrecoverable. -/
theorem R_135_ii_collision_no_leftInverse
    (S_H : ℝ → ℝ) {a b : ℝ} (h_ne : a ≠ b) (h_eq : S_H a = S_H b) :
    ¬ ∃ r : ℝ → ℝ, Function.LeftInverse r S_H := by
  rintro ⟨r, hr⟩
  -- A left inverse forces injectivity, contradicting the collision.
  exact R_135_ii_collision_not_injective S_H h_ne h_eq hr.injective

/-- **R.135 (iii) — the dual reversibility contrast.**

Combining (i) and (ii): the AI map is injective (mathematically
reversible) while the human map is not (mathematically irreversible).
This is the maximal dual breakdown on the reversibility axis,
`Inv(A) = 1 ≠ 0 = Inv(H)`. -/
theorem R_135_iii_dual_contrast
    (S_A S_H : ℝ → ℝ)
    (h_mono : StrictMono S_A)
    {a b : ℝ} (h_ne : a ≠ b) (h_eq : S_H a = S_H b) :
    Function.Injective S_A ∧ ¬ Function.Injective S_H :=
  ⟨h_mono.injective, R_135_ii_collision_not_injective S_H h_ne h_eq⟩

end ReversibilityContrast

end MIP
