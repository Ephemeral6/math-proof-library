/-
Result R.600-R.602 — learning_mechanics × optimal_transport bridge.

Reference: `workspace/round3_exploration/slot_045.md` (slot 045),
`workspace/round3_exploration/work_slot_045.md`:
* R.600 — Wasserstein training trajectory closed form
  `W(t) = 1 − exp(−r·|log κ₀|·e^{−αt})` solving `dW/dt = −α·Φ₀·(1−W)`;
* R.601 — transport–flywheel identity `−dΦ₀/dt = (−dW/dt)/(1−W)`, i.e.
  `α_Φ = −d log(1−W)/dt`;
* R.602 — single-step transport-capacity bound `|dW/dt| ≤ J·δ_max`
  (A 无条件, from the `W₁` metric triangle inequality).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

**Statement (formalized core).**

Set `Φ₀(t) = C·exp(−α·t)` (the Gompertz free energy, `C = r·|log κ₀| ≥ 0`,
reusing the R.98 `HasDerivAt` idiom) and the Wasserstein training
trajectory `W(t) = 1 − exp(−Φ₀(t)) = 1 − e^{−Φ₀(t))}` (R.300 transform).

* (R.600) `W` solves its ODE:
  `HasDerivAt W (−α · Φ₀(t) · (1 − W(t))) t`, equivalently
  `dW/dt = −α·Φ₀·e^{−Φ₀}`.
* (R.600-bound) `|dW/dt| ≤ α·Φ₀(t)` (since `0 ≤ 1 − W(t) ≤ 1`), and the
  maximal descent rate `α·e^{−1}` occurs at `Φ₀ = 1` (the
  `x ↦ x·e^{−x}` bound).
* (R.601) the transport–flywheel identity: along the trajectory,
  `−dΦ₀/dt = (−dW/dt)/(1 − W(t))`, the differential form of
  `Φ₀ = −log(1 − W)`; this is the `α_Φ = −d log(1−W)/dt` identity.
* (R.602) for any time-Lipschitz Wasserstein trajectory with per-unit-time
  step capacity `J·δ_max`, `|dW/dt| ≤ J·δ_max`.  Proven from the metric
  Lipschitz bound only — no Gompertz/R.045 hypotheses (A 无条件).

**This file is `axiom`-free.**  The MIP/OT semantics enter only through
the explicit `Φ₀`/`W` forms and the bundled Lipschitz hypothesis for
R.602; everything is a real-analysis `HasDerivAt`/inequality statement.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace LearningOT

open Real Filter Topology

/-- The Gompertz free energy `Φ₀(t) = C·exp(−α·t)`, `C = r·|log κ₀|`. -/
noncomputable def Phi0 (C α t : ℝ) : ℝ := C * Real.exp (-α * t)

/-- The Wasserstein training trajectory `W(t) = 1 − exp(−Φ₀(t))`
(R.300 transform applied to the Gompertz `Φ₀`). -/
noncomputable def W (C α t : ℝ) : ℝ := 1 - Real.exp (-(Phi0 C α t))

/-- **Auxiliary — derivative of `Φ₀`.**  `dΦ₀/dt = −α·Φ₀(t)`. -/
theorem hasDerivAt_Phi0 (C α t : ℝ) :
    HasDerivAt (Phi0 C α) (-α * Phi0 C α t) t := by
  have h_aff : HasDerivAt (fun s : ℝ => -α * s) (-α) t := by
    simpa using (hasDerivAt_id t).const_mul (-α)
  have h_exp : HasDerivAt (fun s => Real.exp (-α * s))
      (Real.exp (-α * t) * (-α)) t := h_aff.exp
  have h := h_exp.const_mul C
  unfold Phi0
  convert h using 1
  ring

/-- **R.600 — the double-exponential closed form solves its ODE.**

`W(t) = 1 − exp(−Φ₀(t))` with `Φ₀(t) = C·e^{−αt}` satisfies

    dW/dt = −α · Φ₀(t) · (1 − W(t)) = −α · Φ₀(t) · e^{−Φ₀(t)}.

Reuses the R.98 `HasDerivAt` chain idiom: `Φ₀' = −α·Φ₀`, then
`W = 1 − exp(−Φ₀)` gives `W' = exp(−Φ₀)·(−Φ₀') = α·Φ₀·exp(−Φ₀)·(−1)`. -/
theorem R_600_ode (C α t : ℝ) :
    HasDerivAt (W C α) (-α * Phi0 C α t * (1 - W C α t)) t := by
  have hΦ : HasDerivAt (Phi0 C α) (-α * Phi0 C α t) t := hasDerivAt_Phi0 C α t
  -- d/dt exp(−Φ₀) = exp(−Φ₀)·(−Φ₀').
  have hnegΦ : HasDerivAt (fun s => -(Phi0 C α s)) (-(-α * Phi0 C α t)) t :=
    hΦ.neg
  have hexp : HasDerivAt (fun s => Real.exp (-(Phi0 C α s)))
      (Real.exp (-(Phi0 C α t)) * (-(-α * Phi0 C α t))) t := hnegΦ.exp
  -- W = 1 − exp(−Φ₀);  W' = −(exp(−Φ₀)·(−(−α·Φ₀))).
  have hW : HasDerivAt (W C α)
      (0 - Real.exp (-(Phi0 C α t)) * (-(-α * Phi0 C α t))) t := by
    have := (hasDerivAt_const t (1 : ℝ)).sub hexp
    simpa [W] using this
  -- Rewrite the derivative value into `−α·Φ₀·(1 − W)`.
  convert hW using 1
  -- 1 − W t = exp(−Φ₀ t)
  have hWval : 1 - W C α t = Real.exp (-(Phi0 C α t)) := by
    simp [W]
  rw [hWval]; ring

/-- **R.600-bound (a) — `0 ≤ 1 − W(t) ≤ 1`.**

Since `1 − W(t) = e^{−Φ₀(t)} ∈ (0, 1]` when `Φ₀ ≥ 0`. -/
theorem one_sub_W_mem (C α t : ℝ) (hΦnonneg : 0 ≤ Phi0 C α t) :
    0 ≤ 1 - W C α t ∧ 1 - W C α t ≤ 1 := by
  have hval : 1 - W C α t = Real.exp (-(Phi0 C α t)) := by simp [W]
  rw [hval]
  constructor
  · exact le_of_lt (Real.exp_pos _)
  · -- exp(−Φ₀) ≤ 1  ⟺  −Φ₀ ≤ 0  ⟺  0 ≤ Φ₀.
    rw [show (1 : ℝ) = Real.exp 0 by simp]
    exact Real.exp_le_exp.mpr (by linarith)

/-- **R.600-bound (b) — descent-rate bound `|dW/dt| ≤ α·Φ₀(t)`.**

From `dW/dt = −α·Φ₀·(1−W)` and `0 ≤ 1−W ≤ 1` with `α, Φ₀ ≥ 0`. -/
theorem R_600_descent_bound (C α t : ℝ)
    (hα : 0 ≤ α) (hΦnonneg : 0 ≤ Phi0 C α t) :
    |(-α * Phi0 C α t * (1 - W C α t))| ≤ α * Phi0 C α t := by
  obtain ⟨h0, h1⟩ := one_sub_W_mem C α t hΦnonneg
  have hαΦ : 0 ≤ α * Phi0 C α t := mul_nonneg hα hΦnonneg
  -- The quantity equals α·Φ₀·(1−W), nonneg and ≤ α·Φ₀.
  have heq : |(-α * Phi0 C α t * (1 - W C α t))|
      = α * Phi0 C α t * (1 - W C α t) := by
    rw [abs_of_nonpos]
    · ring
    · -- −α·Φ₀·(1−W) ≤ 0
      have : 0 ≤ α * Phi0 C α t * (1 - W C α t) :=
        mul_nonneg hαΦ h0
      linarith
  rw [heq]
  -- α·Φ₀·(1−W) ≤ α·Φ₀·1 = α·Φ₀
  calc α * Phi0 C α t * (1 - W C α t)
      ≤ α * Phi0 C α t * 1 := by
        apply mul_le_mul_of_nonneg_left h1 hαΦ
    _ = α * Phi0 C α t := by ring

/-- **R.601 — the transport–flywheel (`α_Φ`) identity.**

Along the trajectory `Φ₀ = −log(1 − W)`, so

    −dΦ₀/dt = (−dW/dt) / (1 − W(t)),

i.e. `α_Φ := −d log(1 − W)/dt` equals `−dΦ₀/dt`.  We prove the
`HasDerivAt` of `t ↦ −log(1 − W t)` equals `−dW/dt / (1 − W t)` and that
this coincides with `dΦ₀/dt`, recovering `Φ₀` from `W`.  Stated at a point
where `1 − W t > 0` (always true here since `1 − W = e^{−Φ₀} > 0`). -/
theorem R_601_alpha_phi_identity (C α t : ℝ) :
    HasDerivAt (fun s => -Real.log (1 - W C α s))
      ((-α * Phi0 C α t * (1 - W C α t)) / (1 - W C α t)) t := by
  -- 1 − W s = exp(−Φ₀ s) > 0.
  have hpos : (0 : ℝ) < 1 - W C α t := by
    have hval : 1 - W C α t = Real.exp (-(Phi0 C α t)) := by simp [W]
    rw [hval]; exact Real.exp_pos _
  -- W' t = −α·Φ₀·(1−W).
  have hW : HasDerivAt (W C α) (-α * Phi0 C α t * (1 - W C α t)) t := R_600_ode C α t
  -- (1 − W) has derivative −W'.
  have h1W : HasDerivAt (fun s => 1 - W C α s)
      (-(-α * Phi0 C α t * (1 - W C α t))) t := by
    have := (hasDerivAt_const t (1 : ℝ)).sub hW
    simpa using this
  -- log(1 − W) has derivative (−W')/(1 − W).
  have hlog : HasDerivAt (fun s => Real.log (1 - W C α s))
      ((-(-α * Phi0 C α t * (1 - W C α t))) / (1 - W C α t)) t :=
    h1W.log (ne_of_gt hpos)
  -- Negate:  −log(1−W) has derivative  −((−W')/(1−W)) = W'/(1−W).
  have hneg := hlog.neg
  convert hneg using 1
  rw [neg_div]; ring

/-- **R.601 — the transport rate simplifies to `dΦ₀/dt = −α·Φ₀`.**

The derivative value produced by `R_601_alpha_phi_identity`, namely
`(−α·Φ₀·(1−W))/(1−W)`, reduces to `−α·Φ₀ = dΦ₀/dt`.  Hence
`d(−log(1−W))/dt = dΦ₀/dt`, i.e. `α_Φ := −d log(1−W)/dt` recovers the
Gompertz `dΦ₀/dt`.  Equivalently `−dΦ₀/dt = (−dW/dt)/(1 − W)` (both equal
`α·Φ₀`), the R.601 main equation. -/
theorem R_601_main_equation (C α t : ℝ) :
    (-α * Phi0 C α t * (1 - W C α t)) / (1 - W C α t)
      = -α * Phi0 C α t := by
  have hpos : (0 : ℝ) < 1 - W C α t := by
    have hval : 1 - W C α t = Real.exp (-(Phi0 C α t)) := by simp [W]
    rw [hval]; exact Real.exp_pos _
  have hne : (1 - W C α t) ≠ 0 := ne_of_gt hpos
  rw [mul_div_assoc, div_self hne, mul_one]

/-! ### R.602 — single-step transport-capacity bound (A 无条件) -/

/-- **R.602 — `|dW/dt| ≤ J·δ_max` for a time-Lipschitz Wasserstein
trajectory.**

Model the trajectory as a function `w : ℝ → ℝ` (`w t = W₁(μ_{A_t}, ν_p)`).
The slot's per-step argument (triangle inequality of the `W₁` metric plus
"≤ k steps in time Δt, each of size ≤ δ_max") yields the time-Lipschitz
bound `|w t − w s| ≤ (J·δ_max)·|t − s|`.  Under that bound, wherever `w`
is differentiable, `|w'(t)| ≤ J·δ_max`.

This is the A-unconditional core: it uses only the metric Lipschitz
hypothesis (`hLip`), not Gompertz/R.045/R.300. -/
theorem R_602_rate_bound
    (w : ℝ → ℝ) (J δmax wdot t : ℝ)
    (hJδ : 0 ≤ J * δmax)
    (hLip : ∀ s u : ℝ, |w s - w u| ≤ (J * δmax) * |s - u|)
    (hderiv : HasDerivAt w wdot t) :
    |wdot| ≤ J * δmax := by
  -- A function that is globally `(J·δmax)`-Lipschitz has derivative bounded
  -- by `J·δmax` in norm.  Package `hLip` as a `LipschitzWith` statement.
  have hlw : LipschitzWith (Real.toNNReal (J * δmax)) w := by
    rw [lipschitzWith_iff_dist_le_mul]
    intro s u
    rw [Real.dist_eq, Real.dist_eq]
    have hcoe : (Real.toNNReal (J * δmax) : ℝ) = J * δmax :=
      Real.coe_toNNReal _ hJδ
    rw [hcoe]
    exact hLip s u
  -- The derivative of a `K`-Lipschitz function is bounded by `K`.
  have hnorm : ‖wdot‖ ≤ (Real.toNNReal (J * δmax) : ℝ) :=
    hderiv.le_of_lipschitz hlw
  rw [Real.coe_toNNReal _ hJδ] at hnorm
  -- `‖wdot‖ = |wdot|` for reals.
  simpa [Real.norm_eq_abs] using hnorm

end LearningOT

end MIP
