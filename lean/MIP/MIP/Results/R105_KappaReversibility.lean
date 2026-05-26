/-
Result R.105 — κ-dimension mathematical reversibility vs physical
irreversibility (Cj.10), with the κ-entropy production sign.

Reference: `workspace/frontier_attacks.md` §R.105 (攻击 #6, Cj.10),
including the 2026-05-16 sign correction. Status: (a) A 无条件,
(b) A 无条件, (c) A on κ ∈ (0, 1/2) half-domain.

**Statement.** With the R.98 closed form `κ(t) = κ₀^{exp(-α t)}`, i.e.
`log κ(t) = log κ₀ · exp(-α t)`, the κ-trajectory splits the notion of
"reversibility" into two layers:

* **(a) mathematical reversibility** — the trajectory `t ↦ κ(t)` is
  injective (strictly monotone): any later closure value determines the
  time, so the whole history is recoverable.
* **(b) physical irreversibility (T-breaking)** — the Gompertz field
  `f(κ) = -α·κ·log κ` flips sign under time reversal `t → -t`
  (the reversed dynamics has field `+α·κ·log κ`), so the equation is
  **not** invariant under `t → -t`.
* **(c) entropy production (H-theorem, half-domain)** — for the binary
  closure entropy `S_κ = -κ·log κ - (1-κ)·log(1-κ)`, the chain rule gives
      dS_κ/dt = α·κ·log κ · log(κ/(1-κ)),
  which is `> 0` on `κ ∈ (0, 1/2)` (entropy increases) and `< 0` on
  `κ ∈ (1/2, 1)` (condensation phase). The 2026-05-16 correction: the
  H-theorem is valid only on the half-domain `κ ∈ (0, 1/2)`.

This file encodes the algebraic kernels. The R.98 closed form enters via
its `log`-linear shape (`log κ(t) = log κ₀ · exp(-α t)`); the Gompertz
field is the explicit polynomial-in-`log` expression. The entropy-rate
identity is bundled as the chain-rule premise `h_chain` (the analytic
derivative computation `dS_κ/dκ = log((1-κ)/κ)` is the standard
binary-entropy derivative, entered as a hypothesis); we prove its sign.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Order.Monotone.Basic
import Mathlib.Logic.Function.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace KappaReversibility

open Real

/-- The R.98 closed-form κ-trajectory `κ(t) = exp(log κ₀ · exp(-α t))`. -/
noncomputable def kappa (κ₀ α t : ℝ) : ℝ :=
  Real.exp (Real.log κ₀ * Real.exp (-α * t))

/-- The Gompertz field `f(κ) = -α·κ·log κ` (the RHS of `dκ/dt`). -/
noncomputable def field (α κ : ℝ) : ℝ := -α * κ * Real.log κ

/-- The time-reversed field, obtained by `t → -t` (which flips `dκ/dt`):
`f_rev(κ) = +α·κ·log κ`. -/
noncomputable def fieldRev (α κ : ℝ) : ℝ := α * κ * Real.log κ

/-- **R.105 (a) — mathematical reversibility: the κ-trajectory is injective.**

For `κ₀ ∈ (0,1)` (so `log κ₀ < 0`) and `0 < α`, the map `t ↦ κ(t)` is
strictly increasing.  Reason: `exp(-α t)` is strictly decreasing, and
multiplying by `log κ₀ < 0` flips it to strictly increasing inside the
outer (increasing) `exp`. Strict monotonicity gives injectivity, hence
left-invertibility: the entire history is recoverable from any state. -/
theorem R_105_a_strictMono
    (κ₀ α : ℝ) (h0 : 0 < κ₀) (h1 : κ₀ < 1) (hα : 0 < α) :
    StrictMono (kappa κ₀ α) := by
  have hlog : Real.log κ₀ < 0 := Real.log_neg h0 h1
  intro s t hst
  unfold kappa
  apply Real.exp_lt_exp.mpr
  -- log κ₀ * exp(-α s) < log κ₀ * exp(-α t)  since log κ₀ < 0 and exp(-α s) > exp(-α t).
  have hexp : Real.exp (-α * t) < Real.exp (-α * s) := by
    apply Real.exp_lt_exp.mpr
    have : -α * t < -α * s := by nlinarith
    linarith
  -- multiplying the strict inequality exp(-α t) < exp(-α s) by the negative log κ₀ flips it.
  have := mul_lt_mul_of_neg_left hexp hlog
  linarith [this]

/-- **R.105 (a) — injectivity (corollary).** -/
theorem R_105_a_injective
    (κ₀ α : ℝ) (h0 : 0 < κ₀) (h1 : κ₀ < 1) (hα : 0 < α) :
    Function.Injective (kappa κ₀ α) :=
  (R_105_a_strictMono κ₀ α h0 h1 hα).injective

/-- **R.105 (a) — left inverse exists (history recoverable).** -/
theorem R_105_a_hasLeftInverse
    (κ₀ α : ℝ) (h0 : 0 < κ₀) (h1 : κ₀ < 1) (hα : 0 < α) :
    ∃ r : ℝ → ℝ, Function.LeftInverse r (kappa κ₀ α) :=
  (R_105_a_injective κ₀ α h0 h1 hα).hasLeftInverse

/-- **R.105 (b) — physical irreversibility (T-breaking).**

Time reversal `t → -t` flips `dκ/dt`, sending the Gompertz field
`f(κ) = -α·κ·log κ` to `f_rev(κ) = +α·κ·log κ`. These differ for every
interior closure value `κ ∈ (0,1)` (where `log κ ≠ 0` and `κ ≠ 0`):
the dynamics is **not** invariant under time reversal. -/
theorem R_105_b_field_T_asymmetric
    (α κ : ℝ) (hα : 0 < α) (h0 : 0 < κ) (h1 : κ < 1) :
    field α κ ≠ fieldRev α κ := by
  unfold field fieldRev
  have hlog : Real.log κ < 0 := Real.log_neg h0 h1
  -- The two values are negatives of each other and nonzero, so they differ.
  have hprod : α * κ * Real.log κ < 0 := by
    have hακ : 0 < α * κ := mul_pos hα h0
    nlinarith
  intro h
  -- h : -α*κ*log κ = α*κ*log κ  ⟹  2·(α*κ*log κ) = 0  ⟹ α*κ*log κ = 0, contradiction.
  nlinarith [h, hprod]

/-- **R.105 (c) — entropy-production identity (chain rule).**

The binary closure entropy is `S_κ = -κ·log κ - (1-κ)·log(1-κ)`, with
standard derivative `dS_κ/dκ = log((1-κ)/κ) = log(1-κ) - log κ`.  Along
the Gompertz flow `dκ/dt = -α·κ·log κ`, the chain rule gives

    dS_κ/dt = (dS_κ/dκ)·(dκ/dt)
            = (log(1-κ) - log κ) · (-α·κ·log κ).

This lemma records that algebraic product (the analytic
`dS_κ/dκ = log(1-κ) - log κ` enters as the bundled premise `hdS`). -/
theorem R_105_c_entropy_rate_eq
    (α κ dSdκ dκdt dSdt : ℝ)
    (hdS  : dSdκ = Real.log (1 - κ) - Real.log κ)
    (hflow : dκdt = -α * κ * Real.log κ)
    (hchain : dSdt = dSdκ * dκdt) :
    dSdt = (Real.log (1 - κ) - Real.log κ) * (-α * κ * Real.log κ) := by
  rw [hchain, hdS, hflow]

/-- **R.105 (c) — H-theorem on the half-domain `κ ∈ (0, 1/2)`.**

On `κ ∈ (0, 1/2)` we have `log κ < 0` and `log(1-κ) > log κ` (since
`1-κ > κ`), so `log(1-κ) - log κ > 0`; together with `-α·κ·log κ > 0`
(as `α, κ > 0` and `log κ < 0`) the product is **strictly positive**:
entropy is produced, `dS_κ/dt > 0`. -/
theorem R_105_c_Htheorem_lower_half
    (α κ : ℝ) (hα : 0 < α) (h0 : 0 < κ) (hhalf : κ < 1 / 2) :
    0 < (Real.log (1 - κ) - Real.log κ) * (-α * κ * Real.log κ) := by
  have h1 : κ < 1 := by linarith
  have hlogκ : Real.log κ < 0 := Real.log_neg h0 h1
  -- 1 - κ > κ  (since κ < 1/2),  and  0 < κ < 1 - κ, so log is strictly increasing here.
  have hlt : κ < 1 - κ := by linarith
  have h1mκ_pos : 0 < 1 - κ := by linarith
  have hlogmono : Real.log κ < Real.log (1 - κ) :=
    Real.log_lt_log h0 hlt
  have hfac1 : 0 < Real.log (1 - κ) - Real.log κ := by linarith
  -- second factor: -α·κ·log κ = (α·κ)·(-log κ) > 0.
  have hfac2 : 0 < -α * κ * Real.log κ := by
    have hακ : 0 < α * κ := mul_pos hα h0
    nlinarith
  exact mul_pos hfac1 hfac2

/-- **R.105 (c) — entropy reversal on the condensation half `κ ∈ (1/2, 1)`.**

On `κ ∈ (1/2, 1)` we have `1 - κ < κ` so `log(1-κ) - log κ < 0`, while
the flow factor `-α·κ·log κ > 0` is unchanged; the product is
**strictly negative**: `dS_κ/dt < 0`. This is the 2026-05-16 correction
— the H-theorem fails on the condensation phase. -/
theorem R_105_c_entropy_decrease_upper_half
    (α κ : ℝ) (hα : 0 < α) (hhalf : 1 / 2 < κ) (h1 : κ < 1) :
    (Real.log (1 - κ) - Real.log κ) * (-α * κ * Real.log κ) < 0 := by
  have h0 : 0 < κ := by linarith
  have hlogκ : Real.log κ < 0 := Real.log_neg h0 h1
  -- 1 - κ < κ,  and 0 < 1 - κ < κ < 1, so log(1-κ) < log κ.
  have hlt : 1 - κ < κ := by linarith
  have h1mκ_pos : 0 < 1 - κ := by linarith
  have hlogmono : Real.log (1 - κ) < Real.log κ :=
    Real.log_lt_log h1mκ_pos hlt
  have hfac1 : Real.log (1 - κ) - Real.log κ < 0 := by linarith
  have hfac2 : 0 < -α * κ * Real.log κ := by
    have hακ : 0 < α * κ := mul_pos hα h0
    nlinarith
  exact mul_neg_of_neg_of_pos hfac1 hfac2

end KappaReversibility

end MIP
