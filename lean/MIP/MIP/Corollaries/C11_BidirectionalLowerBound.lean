/-
Corollary C.11 — Bidirectional emergence lower bound (orig. name
"uncertainty principle", renamed 2026-05-18).  Reference:
`corollaries/index.md` row C.11 (dep. L.6, L.7); `physical_quantities/
relations.md` §"双向涌现下界"; algebraic core in `proofs/derived/
uncertainty.md` R.69.

**Statement.** The product of the two unidirectional emergence costs is
bounded below by the squared total barrier count:

    N(p, A, H) · N(p, H, A) ≥ |B(p)|²    (for N, N* > 0).

This is the MIP "uncertainty principle": one cannot make both
directional costs small simultaneously; their product is pinned by the
intrinsic barrier complexity `|B|²`.

**Kernel formalized here.** The AM–GM/product kernel.  With
`a := |B_A|`, `h := |B_H|`, `s := |B_S|`, `|B| = a + h + s`, the L.6/L.7
lower bounds give

    N→ ≥ a + s + C·h,    N← ≥ h + s + C'·a    (C, C' ≥ 1),

and the algebraic identity

    (a+s+Ch)(h+s+C'a) − (a+h+s)² = (C'−1)a(a+s) + (C−1)h(h+s) + (CC'−1)ah

≥ 0 yields `(a+s+Ch)(h+s+C'a) ≥ |B|²`.  Composing with the L.6/L.7
bounds and nonnegativity gives `N→·N← ≥ |B|²`.

This file RE-PROVES the needed product kernel locally (it does NOT import
R.69) and then states the clean lower-bound corollary
`|B|² ≤ N→·N←` from the L.6/L.7 hypotheses.

Axiom-free (only A.1–A.4).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace Corollary_C11

/-- **C.11 product-bound algebraic identity (re-proved locally).**

    (a + s + C·h)(h + s + C'·a) − (a + h + s)²
      = (C'−1)·a·(a+s) + (C−1)·h·(h+s) + (C·C'−1)·a·h.

Pure ring identity (independent re-derivation; R.69 not imported). -/
theorem product_identity (a h s C C' : ℝ) :
    (a + s + C * h) * (h + s + C' * a) - (a + h + s) ^ 2
      = (C' - 1) * a * (a + s)
        + (C - 1) * h * (h + s)
        + (C * C' - 1) * a * h := by
  ring

/-- **C.11 product lower bound (re-proved locally).**

Under `a, h, s ≥ 0` and `C, C' ≥ 1`:
`(a + h + s)² ≤ (a + s + C·h)(h + s + C'·a)`. -/
theorem product_lower_bound
    (a h s C C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C') :
    (a + h + s) ^ 2 ≤ (a + s + C * h) * (h + s + C' * a) := by
  have hid := product_identity a h s C C'
  have ht1 : 0 ≤ (C' - 1) * a * (a + s) :=
    mul_nonneg (mul_nonneg (by linarith) ha) (by linarith)
  have ht2 : 0 ≤ (C - 1) * h * (h + s) :=
    mul_nonneg (mul_nonneg (by linarith) hh) (by linarith)
  have ht3 : 0 ≤ (C * C' - 1) * a * h := by
    have hCC' : 1 ≤ C * C' := by
      calc (1 : ℝ) = 1 * 1 := by ring
        _ ≤ C * C' := mul_le_mul hC hC' (by linarith) (by linarith)
    exact mul_nonneg (mul_nonneg (by linarith) ha) hh
  linarith

/-- **C.11 (bidirectional emergence lower bound, `|B|² ≤ N→·N←`).**

The clean corollary: given the L.6/L.7 lower bounds
* `Nfwd ≥ a + s + C·h`   (L.6),
* `Nbwd ≥ h + s + C'·a`  (L.7),
with `a, h, s ≥ 0`, `C, C' ≥ 1`, and `|B| = a + h + s`, the product of
the two directional costs dominates the squared barrier count:

    |B|² ≤ N→ · N←. -/
theorem bidirectional_lower_bound
    (a h s C C' Nfwd Nbwd B : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C')
    (hB : B = a + h + s)
    (hNf : a + s + C * h ≤ Nfwd)
    (hNb : h + s + C' * a ≤ Nbwd) :
    B ^ 2 ≤ Nfwd * Nbwd := by
  -- Step 1: |B|² ≤ (a+s+Ch)(h+s+C'a).
  have h1 : B ^ 2 ≤ (a + s + C * h) * (h + s + C' * a) := by
    rw [hB]; exact product_lower_bound a h s C C' ha hh hs hC hC'
  -- Step 2: (a+s+Ch)(h+s+C'a) ≤ Nfwd · Nbwd  (product monotone, all ≥ 0).
  have hP1 : 0 ≤ a + s + C * h := by nlinarith
  have hNb0 : 0 ≤ Nbwd := by nlinarith
  have h2 : (a + s + C * h) * (h + s + C' * a) ≤ Nfwd * Nbwd :=
    calc (a + s + C * h) * (h + s + C' * a)
        ≤ Nfwd * (h + s + C' * a) :=
          mul_le_mul_of_nonneg_right hNf (by nlinarith)
      _ ≤ Nfwd * Nbwd :=
          mul_le_mul_of_nonneg_left hNb (le_trans hP1 hNf)
  linarith

end Corollary_C11

end MIP
