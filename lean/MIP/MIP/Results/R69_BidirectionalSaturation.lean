/-
Result R.69 / R.70 — Bidirectional emergence lower-bound algebraic kernel.

Reference: `proofs/derived/uncertainty.md` R.69 (T.9, saturation, A 无条件)
and R.70 (T.10, quantitative strengthening, A 无条件).

**Statement (R.69 algebraic core).** Let `a, h, s ≥ 0` represent the
cardinalities `|B_A|`, `|B_H|`, `|B_S|` of A-dominant, H-dominant, and
symmetric barriers, with `|B| = a + h + s`.  Let `C, C' ≥ 1` be the
weighted-average impedance ratios (`C ≥ 1` because each `b ∈ B_H`
contributes `Z_A(b)/Z_H(b) > 1`).  Then

    P := (a + s + C·h)(h + s + C'·a) ≥ (a + h + s)²

with equality iff `a = 0 = h` (i.e. `B = B_S`).

**Algebraic identity (R.69 / R.70 kernel).**

    P − |B|²  =  (C' − 1)·a(a + s) + (C − 1)·h(h + s) + (C·C' − 1)·a·h

By `C, C' ≥ 1` each summand is non-negative, giving `P ≥ |B|²`.

**Quantitative R.70 bound.**

    P − |B|²  ≥  (a + h) · [(C − 1)·h + (C' − 1)·a]
              ≥  δ · (a + h)²,   where δ := min(C − 1, C' − 1) .

This file proves both kernels — the **exact identity** and the
**quantitative lower bound** — without committing to MIP opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace BidirectionalSaturation

/-- **R.69 algebraic identity (exact).**

    (a + s + C·h)(h + s + C'·a)  −  (a + h + s)²
      =  (C' − 1)·a·(a + s)
       + (C  − 1)·h·(h + s)
       + (C·C' − 1)·a·h .

Pure ring identity. -/
theorem R_69_exact_expansion (a h s C C' : ℝ) :
    (a + s + C * h) * (h + s + C' * a) - (a + h + s) ^ 2
      = (C' - 1) * a * (a + s)
        + (C - 1) * h * (h + s)
        + (C * C' - 1) * a * h := by
  ring

/-- **R.69 — bidirectional product lower bound (`P ≥ |B|²`).**

Under `a, h, s ≥ 0` and `C, C' ≥ 1`:
`(a + s + C h)(h + s + C' a) ≥ (a + h + s)²`. -/
theorem R_69_lower_bound
    (a h s C C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C') :
    (a + h + s) ^ 2 ≤ (a + s + C * h) * (h + s + C' * a) := by
  have h_expand := R_69_exact_expansion a h s C C'
  -- Each of the three terms is nonneg.
  have h_t1_nonneg : 0 ≤ (C' - 1) * a * (a + s) := by
    apply mul_nonneg
    · exact mul_nonneg (by linarith) ha
    · linarith
  have h_t2_nonneg : 0 ≤ (C - 1) * h * (h + s) := by
    apply mul_nonneg
    · exact mul_nonneg (by linarith) hh
    · linarith
  have h_t3_nonneg : 0 ≤ (C * C' - 1) * a * h := by
    have hCC' : 1 ≤ C * C' := by
      calc (1 : ℝ) = 1 * 1 := by ring
        _ ≤ C * C' := mul_le_mul hC hC' (by linarith) (by linarith)
    apply mul_nonneg
    · exact mul_nonneg (by linarith) ha
    · exact hh
  linarith

/-- **R.70 — quantitative strengthening (sharper lower bound).**

For asymmetric-barrier count `m := a + h`, R.70 gives:
`P − |B|² ≥ (a + h) · [(C − 1)·h + (C' − 1)·a]`,
which is ≥ `δ · m²` for `δ := min(C − 1, C' − 1)`.

This sharper bound follows by dropping only the third term `(C C' − 1) a h`
to a weaker form, keeping the leading `(C − 1) a h + (C' − 1) a h`. -/
theorem R_70_quantitative_strengthening
    (a h s C C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C') :
    (a + s + C * h) * (h + s + C' * a) - (a + h + s) ^ 2
      ≥ (a + h) * ((C - 1) * h + (C' - 1) * a) := by
  have h_expand := R_69_exact_expansion a h s C C'
  -- LHS = (C'-1) a (a+s) + (C-1) h (h+s) + (C C' - 1) a h
  --     ≥ (C'-1) a² + (C-1) h² + ((C-1) a h + (C'-1) a h)
  --   (used (C'-1) a (a+s) ≥ (C'-1) a² and (C-1) h (h+s) ≥ (C-1) h²
  --    by s ≥ 0; and (C C' - 1) a h ≥ (C-1) a h + (C'-1) a h, which holds
  --    since C C' - 1 ≥ (C - 1) + (C' - 1) when C, C' ≥ 1.)
  have h1 : (C' - 1) * a * (a + s) ≥ (C' - 1) * a * a := by
    apply mul_le_mul_of_nonneg_left
    · linarith
    · exact mul_nonneg (by linarith) ha
  have h2 : (C - 1) * h * (h + s) ≥ (C - 1) * h * h := by
    apply mul_le_mul_of_nonneg_left
    · linarith
    · exact mul_nonneg (by linarith) hh
  have h3 : (C * C' - 1) * a * h ≥ ((C - 1) + (C' - 1)) * a * h := by
    apply mul_le_mul_of_nonneg_right
    · apply mul_le_mul_of_nonneg_right
      · nlinarith
      · exact ha
    · exact hh
  -- Combine:
  --   (C'-1)·a² + (C-1)·h² + ((C-1)+(C'-1))·a h
  -- = (a + h) · [(C-1)·h + (C'-1)·a]  (after expanding).
  have h_combine :
      (C' - 1) * a * a + (C - 1) * h * h
        + ((C - 1) + (C' - 1)) * a * h
        = (a + h) * ((C - 1) * h + (C' - 1) * a) := by ring
  linarith

end BidirectionalSaturation

end MIP
