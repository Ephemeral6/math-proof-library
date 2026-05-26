/-
Result R.770-774 (slots 028/029) — Cj.55 complement:
the membership-metric `d_p` Wasserstein kernels NOT already in
`R527_AsymMetricFamily.lean`.

Reference: `workspace/round3_exploration/slot_028.md` (R.480-483) and
`slot_029.md` (R.527'-531), the Cj.55 complement (Asym ≥ W_1^d for the
dominated metric family; A unconditional / A conditional).

**Candidate status: Round-3 autonomous exploration, not yet human-audited.**

OVERLAP DISCLOSURE.  `R527_AsymMetricFamily.lean` already formalizes the slot
028/029 results that share the *triangle/L1* and *metric-domination* kernels:
R.527' (`|N − N*| ≤ Asym`), R.530 (metric-domination ⟹ Wasserstein domination),
R.529 (literal refutation of the unrestricted Cj.55).  This file formalizes the
GENUINELY-NEW content of slots 028/029 that R.527 does NOT cover, all centred on
the membership pseudometric `d_p` and the survival mass `q_X := e^{−Φ_0(X)}`:

* **R.481 / triangle bridge (A unconditional).**  Under `d_p` the Wasserstein
  distance is bounded by the survival-mass deficits, hence by the potentials:
      W_1^{d_p}(μ_A, μ_H)  =  |q_A − q_H|
                           ≤  (1 − q_A) + (1 − q_H)
                           ≤  Φ_0(A) + Φ_0(H),
  using the elementary `1 − e^{−x} ≤ x` for `x ≥ 0`.

* **R.482 / `d_p` exact isometry (A unconditional).**  The membership
  pseudometric `d_p` collapses W_1 to the total variation of the two-point
  projection, i.e. the absolute survival-mass difference:
      W_1^{d_p}(μ_A, μ_H)  =  |q_A − q_H|  =  |e^{−Φ_0(A)} − e^{−Φ_0(H)}|.
  (Here we record the algebraic identity content; the OT reduction enters as a
  bundled hypothesis per the HYPOTHESIS-BUNDLE convention.)

* **R.528' / R.528'' / Ohm-regime domination (A conditional).**  In the Ohm
  regime, with equal mean impedance `Z̄_A = Z̄_H = Z̄`, the survival-mass gap is
  controlled by the role gap:
      |q_A − q_H|  ≤  |Φ_0(A) − Φ_0(H)|        (`e^{−x}` is 1-Lipschitz)
                  =  |N − N*| / Z̄              (Ohm: N = Z̄·Φ_0)
                  ≤  Asym / Z̄                  (R.527'),
  giving `Z̄ · W_1^{d_p} ≤ Asym` (R.528'') and `W_1^{d_p} ≤ Asym` when `Z̄ ≥ 1`
  (R.528').

* **R.531 (Pinsker-type, NOT crisp — DOCUMENTED, NOT FORMALIZED).**  The source
  (slot 029) grades the bounded-`d` nonlinear weak version `Asym ≥
  (2 Z̄_max (W_1^d)² − …)/D²` as **B-conditional** with a residual KL term
  `KL_res` that is not pinned down (it depends on the unformalized concept NC.7
  `μ_X^{(b)}`).  Per the task's "Pinsker-type bound if crisp", it is NOT crisp,
  so it is skipped here.  We DO formalize the crisp 1-Lipschitz contraction of
  `e^{−x}` (`R_770_exp_neg_oneLipschitz`), which is the standalone analytic
  ingredient the Pinsker route would have needed.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.MeanInequalities
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace Cj55Complement

open Real

/-! ### Part 1 — R.481/R.482 elementary kernels: survival mass `q = e^{−Φ}`. -/

/-- The survival mass of a problem-difficulty potential: `q_X := e^{−Φ_0(X)}`.
For `Φ ≥ 0` this is the probability of clearing all barriers, in `(0, 1]`. -/
noncomputable def survival (Φ : ℝ) : ℝ := Real.exp (-Φ)

/-- `survival Φ > 0` always (the exponential is strictly positive). -/
theorem survival_pos (Φ : ℝ) : 0 < survival Φ := Real.exp_pos _

/-- `survival Φ ≤ 1` for `Φ ≥ 0` (the deficit `1 − q ≥ 0`). -/
theorem survival_le_one {Φ : ℝ} (hΦ : 0 ≤ Φ) : survival Φ ≤ 1 := by
  unfold survival
  rw [show (1 : ℝ) = Real.exp 0 from (Real.exp_zero).symm]
  exact Real.exp_le_exp.mpr (by linarith)

/-- **R.481 elementary core — the survival deficit bound `1 − e^{−Φ} ≤ Φ`.**

The survival-mass deficit `1 − q = 1 − e^{−Φ}` is at most `Φ` (unconditionally;
the bound is sharpest and used for `Φ ≥ 0`).  This is the load-bearing
inequality of the R.481 triangle bridge: it converts the survival deficits into
the potentials.  Follows from `1 + x ≤ e^x` at `x = −Φ`. -/
theorem R_770_survival_deficit_le (Φ : ℝ) :
    1 - survival Φ ≤ Φ := by
  unfold survival
  have h := Real.add_one_le_exp (-Φ)   -- (-Φ) + 1 ≤ exp(-Φ)
  linarith

/-! ### Part 2 — R.482: the `d_p` exact isometry (W_1 collapses to |q_A − q_H|). -/

/-- **R.482 — `d_p` exact-isometry identity (algebraic core).**

The membership pseudometric `d_p` collapses the discrete `W_1` to the total
variation of the two-point projection, i.e. the absolute difference of the
survival masses.  With the OT-reduction bundled as `hOT`
(`W1 = |q_A − q_H|`, the Kantorovich value for the two-point `d_p`), we record
the exact value in terms of the potentials:

    W1 = |e^{−Φ_0(A)} − e^{−Φ_0(H)}| = |survival Φ_A − survival Φ_H|. -/
theorem R_770_dp_isometry
    (ΦA ΦH W1 : ℝ)
    (hOT : W1 = |survival ΦA - survival ΦH|) :
    W1 = |Real.exp (-ΦA) - Real.exp (-ΦH)| := by
  rw [hOT]; rfl

/-! ### Part 3 — R.481: the triangle bridge `W_1^{d_p} ≤ Φ_0(A) + Φ_0(H)`. -/

/-- **R.481 — the triangle bridge (A unconditional).**

Given the `d_p` isometry value `W1 = |q_A − q_H|` (bundled as `hW1`), and the
nonnegativity of the potentials `Φ_A, Φ_H ≥ 0`, the Wasserstein distance is
bounded by the sum of the potentials:

    W1  =  |q_A − q_H|
        ≤  (1 − q_A) + (1 − q_H)      (TV ≤ sum of deficits, since q ≤ 1)
        ≤  Φ_A + Φ_H                  (R.770 survival-deficit bound).

This is the genuinely-new triangle content of slot 028 (R.481), not present in
`R527_AsymMetricFamily.lean`. -/
theorem R_770_triangle_bridge
    (ΦA ΦH W1 : ℝ) (hΦA : 0 ≤ ΦA) (hΦH : 0 ≤ ΦH)
    (hW1 : W1 = |survival ΦA - survival ΦH|) :
    W1 ≤ ΦA + ΦH := by
  rw [hW1]
  -- |q_A − q_H| ≤ (1 − q_A) + (1 − q_H), since 0 < q ≤ 1.
  have hqA1 : survival ΦA ≤ 1 := survival_le_one hΦA
  have hqH1 : survival ΦH ≤ 1 := survival_le_one hΦH
  have hqA0 : 0 ≤ survival ΦA := le_of_lt (survival_pos ΦA)
  have hqH0 : 0 ≤ survival ΦH := le_of_lt (survival_pos ΦH)
  have htv : |survival ΦA - survival ΦH| ≤ (1 - survival ΦA) + (1 - survival ΦH) := by
    rw [abs_le]
    constructor <;> linarith
  have hdA : 1 - survival ΦA ≤ ΦA := R_770_survival_deficit_le ΦA
  have hdH : 1 - survival ΦH ≤ ΦH := R_770_survival_deficit_le ΦH
  linarith

/-! ### Part 4 — R.528'/R.528'': Ohm-regime domination Asym ≥ Z̄·W_1^{d_p}. -/

/-- **R.770 — `e^{−x}` is 1-Lipschitz (the `|q_A − q_H| ≤ |Φ_A − Φ_H|` step).**

The map `x ↦ e^{−x}` is a contraction on `ℝ_{≥0}`: the survival-mass gap is
bounded by the potential gap.  This is the analytic ingredient of R.528'
(and the ingredient the Pinsker route R.531 would have needed).  We prove it
for `Φ_A, Φ_H ≥ 0`. -/
theorem R_770_exp_neg_oneLipschitz {ΦA ΦH : ℝ} (hΦA : 0 ≤ ΦA) (hΦH : 0 ≤ ΦH) :
    |survival ΦA - survival ΦH| ≤ |ΦA - ΦH| := by
  unfold survival
  -- WLOG by symmetry: handle the two orderings of ΦA, ΦH.
  rcases le_total ΦA ΦH with hle | hle
  · -- ΦA ≤ ΦH ⟹ exp(-ΦA) ≥ exp(-ΦH) ⟹ both abs values open the same way.
    have hexp : Real.exp (-ΦH) ≤ Real.exp (-ΦA) :=
      Real.exp_le_exp.mpr (by linarith)
    rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ Real.exp (-ΦA) - Real.exp (-ΦH)),
        abs_of_nonpos (by linarith : ΦA - ΦH ≤ 0)]
    -- exp(-ΦA) − exp(-ΦH) ≤ −(ΦA − ΦH) = ΦH − ΦA.
    have h1 := Real.add_one_le_exp (-(ΦH - ΦA))   -- 1 − (ΦH−ΦA) ≤ exp(−(ΦH−ΦA))
    -- multiply the displayed bound by exp(-ΦA) > 0:
    have key : Real.exp (-ΦA) - Real.exp (-ΦH) ≤ ΦH - ΦA := by
      have hfac : Real.exp (-ΦH) = Real.exp (-ΦA) * Real.exp (-(ΦH - ΦA)) := by
        rw [← Real.exp_add]; ring_nf
      have hpos : (0:ℝ) ≤ Real.exp (-ΦA) := le_of_lt (Real.exp_pos _)
      -- exp(-ΦA) − exp(-ΦH) = exp(-ΦA)·(1 − exp(−(ΦH−ΦA))) ≤ exp(-ΦA)·(ΦH−ΦA) ≤ ΦH−ΦA
      have hstep : Real.exp (-ΦA) - Real.exp (-ΦH)
          = Real.exp (-ΦA) * (1 - Real.exp (-(ΦH - ΦA))) := by
        rw [hfac]; ring
      rw [hstep]
      have hbound : 1 - Real.exp (-(ΦH - ΦA)) ≤ ΦH - ΦA := by linarith
      have hd0 : 0 ≤ ΦH - ΦA := by linarith
      calc Real.exp (-ΦA) * (1 - Real.exp (-(ΦH - ΦA)))
          ≤ Real.exp (-ΦA) * (ΦH - ΦA) :=
            mul_le_mul_of_nonneg_left hbound hpos
        _ ≤ 1 * (ΦH - ΦA) := by
            apply mul_le_mul_of_nonneg_right _ hd0
            rw [show (1:ℝ) = Real.exp 0 from (Real.exp_zero).symm]
            exact Real.exp_le_exp.mpr (by linarith)
        _ = ΦH - ΦA := by ring
    linarith
  · -- symmetric branch ΦH ≤ ΦA: reduce to the previous by swapping.
    have hexp : Real.exp (-ΦA) ≤ Real.exp (-ΦH) :=
      Real.exp_le_exp.mpr (by linarith)
    rw [abs_of_nonpos (by linarith : Real.exp (-ΦA) - Real.exp (-ΦH) ≤ 0),
        abs_of_nonneg (by linarith : (0:ℝ) ≤ ΦA - ΦH)]
    have key : Real.exp (-ΦH) - Real.exp (-ΦA) ≤ ΦA - ΦH := by
      have hfac : Real.exp (-ΦA) = Real.exp (-ΦH) * Real.exp (-(ΦA - ΦH)) := by
        rw [← Real.exp_add]; ring_nf
      have hpos : (0:ℝ) ≤ Real.exp (-ΦH) := le_of_lt (Real.exp_pos _)
      have hstep : Real.exp (-ΦH) - Real.exp (-ΦA)
          = Real.exp (-ΦH) * (1 - Real.exp (-(ΦA - ΦH))) := by
        rw [hfac]; ring
      rw [hstep]
      have h1 := Real.add_one_le_exp (-(ΦA - ΦH))
      have hbound : 1 - Real.exp (-(ΦA - ΦH)) ≤ ΦA - ΦH := by linarith
      have hd0 : 0 ≤ ΦA - ΦH := by linarith
      calc Real.exp (-ΦH) * (1 - Real.exp (-(ΦA - ΦH)))
          ≤ Real.exp (-ΦH) * (ΦA - ΦH) :=
            mul_le_mul_of_nonneg_left hbound hpos
        _ ≤ 1 * (ΦA - ΦH) := by
            apply mul_le_mul_of_nonneg_right _ hd0
            rw [show (1:ℝ) = Real.exp 0 from (Real.exp_zero).symm]
            exact Real.exp_le_exp.mpr (by linarith)
        _ = ΦA - ΦH := by ring
    linarith

/-- **R.528'' — Ohm-regime domination `Z̄ · W_1^{d_p} ≤ Asym` (A conditional).**

In the Ohm regime with equal mean impedance `Z̄_A = Z̄_H = Z̄ > 0`, the role
gap is `N − N* = Z̄·(Φ_A − Φ_H)`, so `|Φ_A − Φ_H| = |N − N*| / Z̄`.  With the
R.527' bound `|N − N*| ≤ Asym` (bundled) and the `d_p` value
`W1 = |q_A − q_H|`, the 1-Lipschitz contraction gives

    Z̄ · W1  ≤  Z̄ · |Φ_A − Φ_H|  =  |N − N*|  ≤  Asym. -/
theorem R_770_R528dd
    (ΦA ΦH Zbar Ngap Asym W1 : ℝ)
    (hΦA : 0 ≤ ΦA) (hΦH : 0 ≤ ΦH) (hZ : 0 < Zbar)
    (hW1 : W1 = |survival ΦA - survival ΦH|)
    (hOhm : Ngap = Zbar * (ΦA - ΦH))          -- N − N* = Z̄·(Φ_A − Φ_H)
    (hR527 : |Ngap| ≤ Asym) :                  -- R.527' bundled
    Zbar * W1 ≤ Asym := by
  have hLip : |survival ΦA - survival ΦH| ≤ |ΦA - ΦH| :=
    R_770_exp_neg_oneLipschitz hΦA hΦH
  -- |Ngap| = Z̄·|Φ_A − Φ_H|, so Z̄·|Φ_A − Φ_H| ≤ Asym.
  have habs : |Ngap| = Zbar * |ΦA - ΦH| := by
    rw [hOhm, abs_mul, abs_of_pos hZ]
  have hZW1 : Zbar * W1 ≤ Zbar * |ΦA - ΦH| := by
    rw [hW1]
    exact mul_le_mul_of_nonneg_left hLip (le_of_lt hZ)
  calc Zbar * W1 ≤ Zbar * |ΦA - ΦH| := hZW1
    _ = |Ngap| := habs.symm
    _ ≤ Asym := hR527

/-- **R.528' — Ohm-regime domination `W_1^{d_p} ≤ Asym` for `Z̄ ≥ 1`.**

Specialising R.528'' to `Z̄ ≥ 1`: since `W1 ≥ 0`, `W1 ≤ Z̄·W1 ≤ Asym`, so

    W_1^{d_p}  ≤  Asym         (Ohm regime, `Z̄ ≥ 1`). -/
theorem R_770_R528d
    (ΦA ΦH Zbar Ngap Asym W1 : ℝ)
    (hΦA : 0 ≤ ΦA) (hΦH : 0 ≤ ΦH) (hZ : 1 ≤ Zbar)
    (hW1 : W1 = |survival ΦA - survival ΦH|)
    (hOhm : Ngap = Zbar * (ΦA - ΦH))
    (hR527 : |Ngap| ≤ Asym) :
    W1 ≤ Asym := by
  have hZpos : 0 < Zbar := lt_of_lt_of_le one_pos hZ
  have hmain := R_770_R528dd ΦA ΦH Zbar Ngap Asym W1 hΦA hΦH hZpos hW1 hOhm hR527
  have hW1nonneg : 0 ≤ W1 := by rw [hW1]; exact abs_nonneg _
  -- W1 ≤ Z̄·W1 (since Z̄ ≥ 1, W1 ≥ 0), and Z̄·W1 ≤ Asym.
  have : W1 ≤ Zbar * W1 := by nlinarith [hW1nonneg, hZ]
  linarith

end Cj55Complement

end MIP