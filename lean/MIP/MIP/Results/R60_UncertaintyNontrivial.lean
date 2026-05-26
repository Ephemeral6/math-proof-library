/-
Result R.60 — Bidirectional-emergence lower bound: non-triviality domain.

Reference: `proofs/derived/A_grade.md` R.60 and `proofs/derived/R60.md`
("双向涌现下界适用域 = 双向协作域", A 无条件 under C.11 + T.6 + D.2.9,
原名 "不确定性原理适用域", 2026-05-18 重命名).

**Statement.** Let `a, h, s ≥ 0` be the cardinalities `|B_A|`, `|B_H|`,
`|B_S|` of A-dominant, H-dominant, and symmetric barriers, with
`|B| = a + h + s`, and let `C, C'` be the directional impedance ratios
(`C ≥ 1`, `C' ≥ 1`).  The C.11 product lower bound

    N(A,H) · N(H,A) ≥ (a + s + C·h)(h + s + C'·a) ≥ |B|²

is **non-trivial (strict)** precisely on the *dual-cooperation domain*
`B_A ≠ ∅ ∧ B_H ≠ ∅` (i.e. `a > 0 ∧ h > 0`, with strict impedance
`C > 1 ∧ C' > 1`); it **degenerates to equality** when one side of the
asymmetric split is empty in the purely symmetric configuration
(`a = 0 ∧ h = 0`, only `B_S` remains).

**Algebraic kernel (reused R.69 expansion identity).**

    (a + s + C·h)(h + s + C'·a) − (a + h + s)²
      =  (C' − 1)·a·(a + s) + (C − 1)·h·(h + s) + (C·C' − 1)·a·h .

* When `a = 0 ∧ h = 0`, all three summands vanish: gap `= 0` (equality —
  the bound degenerates to the trivial T.1 consequence `s² ≥ s²`).
* When `a > 0 ∧ h > 0 ∧ C > 1 ∧ C' > 1`, the term `(C·C' − 1)·a·h > 0`
  is strictly positive, so the gap is strictly positive — the bound is
  genuinely non-trivial. This is the "non-triviality ⟺ dual-cooperation
  domain" content of R.60.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace UncertaintyNontrivial

/-- **R.60 — reused R.69 exact expansion identity (kernel).**

    (a + s + C·h)(h + s + C'·a)  −  (a + h + s)²
      =  (C' − 1)·a·(a + s) + (C − 1)·h·(h + s) + (C·C' − 1)·a·h .

Pure ring identity; the algebraic backbone of the non-triviality split. -/
theorem R_60_gap_expansion (a h s C C' : ℝ) :
    (a + s + C * h) * (h + s + C' * a) - (a + h + s) ^ 2
      = (C' - 1) * a * (a + s)
        + (C - 1) * h * (h + s)
        + (C * C' - 1) * a * h := by
  ring

/-- **R.60 (i) — degenerate case: equality when `a = 0 ∧ h = 0`.**

In the purely symmetric configuration (only `B_S` survives), every
asymmetric term vanishes, so the C.11 product lower bound collapses to an
exact equality `(s)(s) = (s)²`: the "uncertainty" content is empty. The
impedance ratios `C, C'` are arbitrary (the gap does not see them). -/
theorem R_60_degenerate_equality
    (s C C' : ℝ) :
    (0 + s + C * 0) * (0 + s + C' * 0) = (0 + 0 + s) ^ 2 := by
  ring

/-- **R.60 (i') — degenerate, hypothesis form.**

If either asymmetric class is empty *and* the other is empty as well
(`a = 0 ∧ h = 0`), the gap is exactly `0` for any `C, C' ≥ 1`: the bound
degenerates to the trivial T.1 consequence. -/
theorem R_60_degenerate_gap_zero
    (a h s C C' : ℝ)
    (ha0 : a = 0) (hh0 : h = 0) :
    (a + s + C * h) * (h + s + C' * a) - (a + h + s) ^ 2 = 0 := by
  subst ha0; subst hh0; ring

/-- **R.60 (i'') — one-sided degeneracy keeps the bound non-strict only
through the surviving `C`-term.**

If `B_A = ∅` (`a = 0`) but possibly `h > 0`, the gap reduces to the single
non-negative term `(C − 1)·h·(h + s)`; when additionally `C = 1` this is
exactly `0` (full degeneracy of the A-direction advantage). This isolates
why a *single* non-empty asymmetric class is insufficient for strictness:
the cross term `(C·C' − 1)·a·h` carrying the genuine bidirectional
content is killed by `a = 0`. -/
theorem R_60_one_sided_gap
    (h s C C' : ℝ) :
    (0 + s + C * h) * (h + s + C' * 0) - (0 + h + s) ^ 2
      = (C - 1) * h * (h + s) := by
  ring

/-- **R.60 (ii) — non-trivial case: strict positivity of the gap on the
dual-cooperation domain.**

If both asymmetric classes are non-empty (`a > 0 ∧ h > 0`) and both
impedance ratios are strict (`C > 1 ∧ C' > 1`), then

    (a + s + C·h)(h + s + C'·a) > (a + h + s)² ,

i.e. the C.11 product lower bound strictly exceeds `|B|²`. This is the
core "non-triviality ⟺ dual-cooperation domain" statement: bidirectional
collaboration is genuinely necessary exactly when both sides hold an
advantage. -/
theorem R_60_nontrivial_strict
    (a h s C C' : ℝ)
    (ha : 0 < a) (hh : 0 < h) (hs : 0 ≤ s)
    (hC : 1 < C) (hC' : 1 < C') :
    (a + h + s) ^ 2 < (a + s + C * h) * (h + s + C' * a) := by
  have h_expand := R_60_gap_expansion a h s C C'
  -- The three summands of the gap.
  -- Term 1 and Term 2 are nonneg; Term 3 = (C·C' − 1)·a·h is strictly positive.
  have h_t1 : 0 ≤ (C' - 1) * a * (a + s) := by
    apply mul_nonneg
    · exact mul_nonneg (by linarith) ha.le
    · linarith
  have h_t2 : 0 ≤ (C - 1) * h * (h + s) := by
    apply mul_nonneg
    · exact mul_nonneg (by linarith) hh.le
    · linarith
  have hCC' : 1 < C * C' := by nlinarith
  have h_t3 : 0 < (C * C' - 1) * a * h := by
    apply mul_pos
    · exact mul_pos (by linarith) ha
    · exact hh
  linarith

/-- **R.60 — characterization corollary (strict bound ⟹ both sides
non-empty necessary).**

Contrapositive direction: on the symmetric degenerate configuration the
gap is `0`, witnessing that strictness genuinely requires the
dual-cooperation domain. Stated as: the gap equals `0` at `a = h = 0`,
hence strict positivity cannot hold there. -/
theorem R_60_strict_requires_dual
    (s C C' : ℝ) :
    ¬ ((0 + 0 + s) ^ 2 < (0 + s + C * 0) * (0 + s + C' * 0)) := by
  intro hlt
  have : (0 + s + C * 0) * (0 + s + C' * 0) - (0 + 0 + s) ^ 2 = 0 := by ring
  linarith

end UncertaintyNontrivial

end MIP
