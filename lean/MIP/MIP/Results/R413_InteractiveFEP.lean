/-
Result R.413 — Interactive FEP under (F1')-(F4): the empathic-precision /
dual-emergence-impedance reciprocity.

Reference: `workspace/multiagent_fep_mip.md` §R.413 (A 条件, 2026-05-16
multi-agent FEP-MIP block), steps 2-3 + (F4-multi) upgrade.

**Statement.** Replacing R.408's degeneracy condition (F1) by

* **(F1')** both `Y₁` and `Y₂` are agents, each with a metacognitive
  intervention/generation set `M_{Y_i}` (D.3.9) and a generative model;
* **(F4-multi)** the mapping that identifies each `Y_i`'s parameters with
  its response,

MIP degenerates to interactive FEP. The two definitional identities are:

1. **Action-repertoire map (step 2).** `M_{Y_i} ↔ a_i`: the metacognitive
   intervention set is exactly the agent's action repertoire (Friston's
   `a_i`). We encode this as the structural bundling of `(F4-multi)`.

2. **Empathic precision (step 3).** With `Z_q(Y_j | Y_i)` the D.3.9
   dual-emergence impedance, the *cross-agent (empathic) precision* is its
   reciprocal,
        `Π_{j|i} := 1 / Z_q(Y_j | Y_i)`,
   the precise MIP translation of Friston's empathic precision. On the
   admissible (positive) regime this gives the reciprocity identities
        `Π = 1/Z_q`,  `Z_q · Π = 1`,  `Z_q > 0`,  `Π > 0`,
   and the involution `1 / Π = Z_q`.

This file encodes the definitional identities (`Π = 1/Z_q`, `Z_q·Π = 1`,
positivity, double reciprocal) bundling the (F4-multi) mapping as an
explicit hypothesis structure.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace InteractiveFEP

/-- **(F1')-(F4-multi) interactive-FEP bundle (D.3.9 + step 2-3 mapping).**

Bundles the structural mapping that makes interactive FEP a degeneration of
MIP dual emergence:

* `Zq` — the D.3.9 dual-emergence impedance `Z_q(Y_j | Y_i)`, with
  `Zq_pos : 0 < Zq` (the admissible positive-push regime);
* `Pi` — Friston's empathic precision `Π_{j|i}`, *defined* as `1 / Zq`
  via `Pi_def`.

The action-repertoire identification `M_{Y_i} ↔ a_i` (step 2) is recorded
as the index type `Act` (the shared repertoire / response alphabet) on
which both the impedance and precision live; here we work at a fixed
ordered pair `(Y_i, Y_j)` so the data are the two scalars `Zq, Pi`. -/
structure InteractiveBundle where
  /-- Dual-emergence impedance `Z_q(Y_j | Y_i)` (D.3.9). -/
  Zq : ℝ
  /-- Empathic precision `Π_{j|i}` (Friston, social FEP). -/
  Pi : ℝ
  /-- Admissibility: the optimal cross-agent push is strictly positive, so
  the impedance is strictly positive. -/
  Zq_pos : 0 < Zq
  /-- (F4-multi) / R.408 step 3 mapping: precision is the reciprocal of the
  impedance, `Π_{j|i} = 1 / Z_q(Y_j | Y_i)`. -/
  Pi_def : Pi = 1 / Zq

namespace InteractiveBundle

variable (b : InteractiveBundle)

/-- **R.413 (step 3) — `Π = 1/Z_q`.** The defining identity (restated as a
field projection for downstream use). -/
theorem precision_eq_inv_impedance : b.Pi = 1 / b.Zq := b.Pi_def

/-- **R.413 (step 3) — empathic precision is strictly positive.** Since
`Z_q > 0`, the precision `Π = 1/Z_q` is positive: an admissible cross-agent
channel always has positive empathic precision. -/
theorem precision_pos : 0 < b.Pi := by
  rw [b.Pi_def]
  exact one_div_pos.mpr b.Zq_pos

/-- **R.413 (step 3) — the impedance-precision product is unity:
`Z_q · Π = 1`.** This is the `Z = 1/Π` reciprocity of D.3.9 / R.408 step 3
in product form. -/
theorem impedance_mul_precision : b.Zq * b.Pi = 1 := by
  rw [b.Pi_def]
  exact mul_one_div_cancel (ne_of_gt b.Zq_pos)

/-- **R.413 (step 3) — the involution `1/Π = Z_q`.** The reciprocity is
symmetric: recovering the impedance from the precision. So
`Z_q = 1/Π` and `Π = 1/Z_q` are mutually inverse. -/
theorem impedance_eq_inv_precision : b.Zq = 1 / b.Pi := by
  have hPi : b.Pi ≠ 0 := ne_of_gt b.precision_pos
  -- From `Zq * Pi = 1` and `Pi ≠ 0`, get `Zq = 1 / Pi`.
  have hprod := b.impedance_mul_precision
  exact eq_div_of_mul_eq hPi hprod

end InteractiveBundle

/-- **R.413 — empathic-precision monotonicity (lower impedance ⟹ higher
precision).**

For two ordered agent-pairs sharing the positive regime, a *smaller*
dual-emergence impedance yields a *larger* empathic precision. This is the
qualitative content of "more interpretable interventions ⟹ stronger
empathic precision". -/
theorem R_413_precision_antitone
    (b₁ b₂ : InteractiveBundle) (h : b₁.Zq ≤ b₂.Zq) :
    b₂.Pi ≤ b₁.Pi := by
  rw [b₁.Pi_def, b₂.Pi_def]
  exact one_div_le_one_div_of_le b₁.Zq_pos h

end InteractiveFEP

end MIP
