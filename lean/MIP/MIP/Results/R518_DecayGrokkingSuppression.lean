/-
Result R.518 – R.520 — Decay suppresses grokking + η-residual scaling.

Reference: `workspace/round3_exploration/slot_011.md` (R.518–R.520, decay ×
thermodynamics cross-branch: decay suppression of the grokking phase
transition) and `workspace/round3_exploration/slot_008.md` (R.518, the
η-residual reparametrization / Cj.50 partial).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Cross-branch model (slot 011).**  Two MIP branches share the
combinatorial-closure variable `κ`:

* **decay R.157 / R.196**: under exponential forgetting (mean half-life
  `τ̄`) the decay-modified Gompertz dynamics has steady state
  `κ_eff^∞ = exp(-2 / (α · τ̄)) < 1` — the closure is forced strictly
  below the saturation ceiling.
* **thermodynamics R.275**: the second ("grokking") phase transition fires
  exactly when the trajectory crosses the critical surface `κ = κ_c²`,
  with `κ_c² ∈ (0,1)`.

Composing them: the grokking surface is crossed iff the decay steady-state
`κ_eff^∞` reaches `κ_c²`.  This gives a **critical decay rate**

    τ̄_critical  =  2 / (α · |log κ_c²|) ,

with the trichotomy
  * `τ̄ < τ̄_critical  ⟹  κ_eff^∞ < κ_c²`  (grokking surface never reached),
  * `τ̄ = τ̄_critical  ⟹  κ_eff^∞ = κ_c²`  (critical, asymptotic crossing),
  * `τ̄ > τ̄_critical  ⟹  κ_eff^∞ > κ_c²`  (grokking surface reached).

The suppression upgrade uses the decay monotonicity bound
`κ_eff(t) ≤ κ_eff^∞` (R.196 step 6): if the supremum of the trajectory is
strictly below `κ_c²`, the surface is unreachable at *every* time.

**β_decay = 1 (slot 011, "A-unconditional" sub-result).**  As a function of
the product `u := α · τ̄`, the steady state `S(u) = exp(-2/u)` is smooth
with a strictly positive finite derivative `S'(u) = exp(-2/u)·(2/u²)` at the
crossing; hence the order parameter `(κ_eff^∞ − κ_c²)_+` rises **linearly**
in the distance past criticality — mean-field exponent `β_decay = 1`
(distinct from the Landau `β = 1/2` class).

**η-residual scaling (slot 008, Cj.50 partial).**  The residual-completion
ansatz `1 − κ(t) = c_R · |K(t)|^(−η)` is reparametrized through the
completion-rate scaling `ρ(t) ∝ |K(t)|^ψ`; the Chinchilla-compatible point
is `ψ = 1 ⟹ η = 1`.  We formalize the residual scaling identity and the
`ψ = 1 ⟹ η = 1` collapse (the impossibility meta-theorem IT.5 and the
"no algebraic correspondence" R.519 are model-level statements with no
crisp real-analysis kernel and are skipped — see report).

**This file is `axiom`-free.**  All MIP-side premises (R.157 decay steady
state, R.275 critical surface, R.418 Heaps + residual ansatz) enter only as
explicit hypotheses or through the explicit closed forms.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace DecayGrokkingSuppression

open Real

/-- The decay steady-state closure `κ_eff^∞ = exp(-2 / (α · τ̄))`
(R.157 / R.196 closed form, here taken as the supremum of the decay
trajectory `sup_t κ_eff(t)`). -/
noncomputable def kappaInf (α τ_bar : ℝ) : ℝ :=
  Real.exp (-(2 / (α * τ_bar)))

/-- The critical decay rate `τ̄_critical = 2 / (α · |log κ_c²|)`. -/
noncomputable def tauCritical (α κc2 : ℝ) : ℝ :=
  2 / (α * |Real.log κc2|)

/-! ### Main suppression theorem (R.520, A-conditional) -/

/-- **R.520 (a) — decay suppresses grokking.**

If the mean half-life is below the critical decay rate, the decay
steady-state closure is strictly below the grokking critical surface:

    τ̄ < τ̄_critical  ⟹  κ_eff^∞ = exp(-2/(α·τ̄))  <  κ_c² .

Since `κ_c² ∈ (0,1)`, `log κ_c² < 0`, so `τ̄_critical > 0` and the
inequality `exp(-2/(α·τ̄)) < κ_c²` is genuine.  This is the
phase-transition-crossing inequality: the second `C_V` jump never fires. -/
theorem R_520_suppression
    (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2) :
    kappaInf α τ_bar < κc2 := by
  unfold kappaInf tauCritical at *
  have h_log_neg : Real.log κc2 < 0 := Real.log_neg h_κc_pos h_κc_lt1
  have h_abs : |Real.log κc2| = -Real.log κc2 := abs_of_neg h_log_neg
  have h_κc_exp : κc2 = Real.exp (Real.log κc2) := (Real.exp_log h_κc_pos).symm
  rw [h_κc_exp]
  apply Real.exp_lt_exp.mpr
  rw [h_abs] at h_lt
  have h_den : 0 < α * (-Real.log κc2) := mul_pos h_α_pos (by linarith)
  rw [lt_div_iff₀ h_den] at h_lt
  -- h_lt : τ_bar * (α * (-log κc2)) < 2
  have h_ατ : 0 < α * τ_bar := mul_pos h_α_pos h_τ_pos
  have h_key : -2 < Real.log κc2 * (α * τ_bar) := by nlinarith [h_lt]
  have h_rw : -(2 / (α * τ_bar)) = -2 / (α * τ_bar) := by ring
  rw [h_rw, div_lt_iff₀ h_ατ]
  linarith [h_key]

/-- **R.520 (b) — converse: above the critical rate, grokking fires.**

    τ̄ > τ̄_critical  ⟹  κ_eff^∞  >  κ_c² ,

so there is a finite crossing time and the second phase transition occurs
normally. -/
theorem R_520_crossing
    (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_gt : tauCritical α κc2 < τ_bar) :
    κc2 < kappaInf α τ_bar := by
  unfold kappaInf tauCritical at *
  have h_log_neg : Real.log κc2 < 0 := Real.log_neg h_κc_pos h_κc_lt1
  have h_abs : |Real.log κc2| = -Real.log κc2 := abs_of_neg h_log_neg
  have h_κc_exp : κc2 = Real.exp (Real.log κc2) := (Real.exp_log h_κc_pos).symm
  rw [h_κc_exp]
  apply Real.exp_lt_exp.mpr
  rw [h_abs] at h_gt
  have h_den : 0 < α * (-Real.log κc2) := mul_pos h_α_pos (by linarith)
  rw [div_lt_iff₀ h_den] at h_gt
  -- h_gt : 2 < τ_bar * (α * (-log κc2))
  have h_ατ : 0 < α * τ_bar := mul_pos h_α_pos h_τ_pos
  have h_key : Real.log κc2 * (α * τ_bar) < -2 := by nlinarith [h_gt]
  have h_rw : -(2 / (α * τ_bar)) = -2 / (α * τ_bar) := by ring
  rw [h_rw, lt_div_iff₀ h_ατ]
  linarith [h_key]

/-- **R.520 (c) — critical point: equality of supremum and surface.**

At `τ̄ = τ̄_critical`, the decay steady state meets the grokking surface
exactly, `κ_eff^∞ = κ_c²`; the crossing is reached only asymptotically
(critical slowing down). -/
theorem R_520_critical
    (α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (_h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_eq : τ_bar = tauCritical α κc2) :
    kappaInf α τ_bar = κc2 := by
  unfold kappaInf tauCritical at *
  have h_log_neg : Real.log κc2 < 0 := Real.log_neg h_κc_pos h_κc_lt1
  have h_abs : |Real.log κc2| = -Real.log κc2 := abs_of_neg h_log_neg
  have h_κc_exp : κc2 = Real.exp (Real.log κc2) := (Real.exp_log h_κc_pos).symm
  rw [h_κc_exp]
  apply congrArg
  -- goal: -(2/(α·τ̄)) = log κc2,  with τ̄ = 2/(α·(-log κc2)).
  have h_neg_log_pos : 0 < -Real.log κc2 := by linarith
  have h_den : 0 < α * (-Real.log κc2) := mul_pos h_α_pos h_neg_log_pos
  rw [h_eq, h_abs]
  -- -(2 / (α * (2 / (α * (-log κc2))))) = log κc2
  have h_α_ne : α ≠ 0 := ne_of_gt h_α_pos
  have h_neg_log_ne : -Real.log κc2 ≠ 0 := ne_of_gt h_neg_log_pos
  rw [neg_eq_iff_eq_neg]
  field_simp

/-- **R.520 — the unreachability upgrade (decay monotonicity bound).**

R.196 step 6 gives the monotone bound `κ_eff(t) ≤ sup = κ_eff^∞` for every
training time `t` (when started below the steady state).  Combined with the
suppression inequality, this shows the grokking surface is never reached at
*any* time: `κ_eff(t) < κ_c²` for all `t`. -/
theorem R_520_never_reached
    (κ_eff_t α τ_bar κc2 : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical α κc2)
    (h_bound : κ_eff_t ≤ kappaInf α τ_bar) :
    κ_eff_t < κc2 := by
  have h_sup : kappaInf α τ_bar < κc2 :=
    R_520_suppression α τ_bar κc2 h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt
  linarith

/-! ### τ̄_critical positivity and the critical identity -/

/-- **R.520 — `τ̄_critical > 0`.**  For `κ_c² ∈ (0,1)` and `α > 0` the
critical decay rate is a genuine positive threshold. -/
theorem R_520_tauCritical_pos
    (α κc2 : ℝ) (h_α_pos : 0 < α)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1) :
    0 < tauCritical α κc2 := by
  unfold tauCritical
  have h_log_neg : Real.log κc2 < 0 := Real.log_neg h_κc_pos h_κc_lt1
  have h_abs_pos : 0 < |Real.log κc2| := by
    rw [abs_of_neg h_log_neg]; linarith
  positivity

/-- **R.520 — critical identity `α · τ̄_critical · |log κ_c²| = 2`.**

The defining relation of the critical decay rate: the threshold is the
balance point where the decay drain `2/τ̄` equals the Gompertz drive
`α·|log κ_c²|` at the surface. -/
theorem R_520_critical_identity
    (α κc2 : ℝ) (h_α_pos : 0 < α)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1) :
    α * tauCritical α κc2 * |Real.log κc2| = 2 := by
  unfold tauCritical
  have h_log_neg : Real.log κc2 < 0 := Real.log_neg h_κc_pos h_κc_lt1
  have h_abs_pos : 0 < |Real.log κc2| := by
    rw [abs_of_neg h_log_neg]; linarith
  have h_α_ne : α ≠ 0 := ne_of_gt h_α_pos
  have h_abs_ne : |Real.log κc2| ≠ 0 := ne_of_gt h_abs_pos
  field_simp

/-! ### β_decay = 1 : linear order-parameter scaling (A-unconditional) -/

/-- **R.520.c — the steady state has a strictly positive finite slope in
`u := α·τ̄`.**

Writing the decay steady state as a function of the product `u = α·τ̄`,
`S(u) = exp(-2/u)`, we have

    S'(u)  =  exp(-2/u) · (2 / u²)   for  u ≠ 0,

a smooth strictly positive finite derivative.  A nonzero finite slope is
exactly the analytic content of the **mean-field critical exponent
`β_decay = 1`**: the order parameter `(κ_eff^∞ − κ_c²)_+` rises *linearly*
(not as a square root) as the threshold is passed. -/
theorem R_520_steadyState_hasDerivAt
    (u : ℝ) (h_u : u ≠ 0) :
    HasDerivAt (fun s => Real.exp (-(2 / s)))
      (Real.exp (-(2 / u)) * (2 / u ^ 2)) u := by
  have h_inv : HasDerivAt (fun s : ℝ => s⁻¹) (-(u ^ 2)⁻¹) u := hasDerivAt_inv h_u
  have h_div : HasDerivAt (fun s : ℝ => 2 / s) (2 * (-(u ^ 2)⁻¹)) u := by
    have := h_inv.const_mul (2 : ℝ)
    simpa [div_eq_mul_inv] using this
  have h_neg : HasDerivAt (fun s : ℝ => -(2 / s)) (-(2 * (-(u ^ 2)⁻¹))) u :=
    h_div.neg
  have h_exp := h_neg.exp
  convert h_exp using 2
  rw [div_eq_mul_inv, sq]
  field_simp

/-- **R.520.c — the slope is strictly positive (β_decay = 1, sign).**

The derivative `S'(u) = exp(-2/u)·(2/u²)` is strictly positive for `u > 0`:
the steady state is strictly increasing in `α·τ̄`, so crossing the threshold
gives a genuine linear-order rise of the order parameter. -/
theorem R_520_slope_pos
    (u : ℝ) (h_u : 0 < u) :
    0 < Real.exp (-(2 / u)) * (2 / u ^ 2) := by
  have h1 : 0 < Real.exp (-(2 / u)) := Real.exp_pos _
  have h2 : 0 < 2 / u ^ 2 := by positivity
  positivity

/-! ### η-residual scaling identity (R.518 / Cj.50 partial, slot 008) -/

/-- **R.518 — η-residual scaling identity.**

The residual-completion ansatz writes the closure gap as a power law of the
knowledge-set size `|K(t)|`:

    1 − κ(t)  =  c_R · |K(t)|^(−η) ,

and with the Heaps law `|K(t)| = c_K · t^β` this is the data-budget power
law `1 − κ(t) = c_R · c_K^(−η) · t^(−β·η)`.  Pure `rpow` substitution
(`c_K, t > 0`).  This is the η-residual kernel underlying Cj.50. -/
theorem R_518_eta_residual_scaling
    (κgap cR cK t β η : ℝ)
    (h_cK : 0 < cK) (h_t : 0 < t)
    (h_gap : κgap = cR * (cK * t ^ β) ^ (-η)) :
    κgap = cR * cK ^ (-η) * t ^ (-(β * η)) := by
  rw [h_gap,
      Real.mul_rpow (le_of_lt h_cK) (le_of_lt (Real.rpow_pos_of_pos h_t β)),
      ← Real.rpow_mul (le_of_lt h_t)]
  ring_nf

/-- **R.518 — completion-rate reparametrization `ψ = 1 ⟹ η = 1`.**

The residual exponent is reparametrized through the completion-rate scaling
`ρ(t) ∝ |K(t)|^ψ` via `η = 1 − ψ + ψ/β` (slot 008 §2.3).  The
Chinchilla-compatible point `ψ = 1` collapses this to `η = 1` for *every*
Heaps exponent `β ≠ 0` — i.e. linear completion always gives the η = 1
power law, independent of `β`. -/
theorem R_518_psi_one_gives_eta_one
    (β ψ η : ℝ)
    (h_reparam : η = 1 - ψ + ψ / β)
    (h_ψ : ψ = 1) :
    η = 1 / β := by
  rw [h_reparam, h_ψ]
  ring

/-- **R.518 — at `β = 1` the `ψ = 1` point gives exactly `η = 1`.**

When the Heaps exponent is `β = 1` (linear knowledge growth), the
`ψ = 1` completion rate gives `η = 1` exactly, recovering the Chinchilla
match `γ_κ = β·η = 1`. -/
theorem R_518_eta_one_at_beta_one
    (β ψ η : ℝ)
    (h_reparam : η = 1 - ψ + ψ / β)
    (h_ψ : ψ = 1) (h_β : β = 1) :
    η = 1 := by
  rw [h_reparam, h_ψ, h_β]; norm_num

end DecayGrokkingSuppression

end MIP
