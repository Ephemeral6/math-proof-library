/-
Result R.150 — MIP exact scaling law (coverage + Gompertz condensation),
and the Chinchilla compute-optimal allocation identity.

Reference: `branches/learning_mechanics/workspace/exact_scaling.md` §3-§9
(R.150 主公式, A 条件性 under (TM-5) training-absorption + iid-data +
heavy-tailed q + R.117 coverage/condensation timing + R.118 Gompertz).

**Statement interpretation used.**  Under the bundled hypotheses (all
entering as explicit assumptions / definitions of the macroscopic factors):

* **(coverage)**   `F(D) ∈ [0,1]`   = average fraction of problems whose
  knowledge demand `R(p)` is already covered by `K(A_D)` (§3.3),
* **(condensation)** `L_κ(D) = r̄·|log κ₀|·exp(−α·τ(D))`  = Gompertz loss
  on the covered fraction (§4.1), with `τ(D)` the effective condensation
  time `τ(D) = (1/B)·∫₀ᴰ F`,
* **(uncovered floor)** `Φ̄_unc`     = constant per-domain cost of an
  uncovered problem.

§9.1 (R.150) then states the **exact** cross-entropy loss decomposition

    L(D)  =  F(D)·L_κ(D)  +  (1 − F(D))·Φ̄_unc .                   (★MIP)

This file formalizes (★MIP) as a closed-form `def` and proves:

* the **exact closed form** as a convex combination of the covered and
  uncovered costs (§3.3, §4.1);
* **monotone improvement in coverage**: when the uncovered floor exceeds
  the covered cost (`L_κ < Φ̄_unc`, the meaningful regime), `L(D)` is
  strictly decreasing in the coverage fraction `F` — more covered
  problems ⟹ lower loss;
* the **gap form** `L(D) − L_κ = (1 − F(D))·(Φ̄_unc − L_κ)` (the §3.2/§9.2
  rewrite that feeds the Tauberian degeneration in R.150.a);
* the **Gompertz factor** `L_κ(D) = r̄·|log κ₀|·exp(−α·τ(D))` and its
  log-linearity in `τ`: `log(L_κ/(r̄·|log κ₀|)) = −α·τ`;
* the **effective-time monotonicity**: with `dτ/dD = F(D)/B ≥ 0` the
  condensation clock `τ` is non-decreasing in `D` (more data, never less
  effective condensation time);
* the **Chinchilla compute-optimal allocation** (§6.6): with compute
  budget `C = N_param·D` held fixed and the power-law parametrisation
  `N_param = k_N·C^a`, `D = k_D·C^b`, the budget identity `N_param·D = C`
  forces the **Chinchilla exponent identity** `a + b = 1`.

**This file is `axiom`-free.**  All MIP-side premises (R.117, R.118,
(TM-5), heavy-tailed `q`) enter only through the explicit forms of the
macroscopic factors `F`, `L_κ`, `τ`, `Φ̄_unc`.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace ExactScaling

open Real

/-- **Effective condensation time** `τ(D) = (1/B)·I(D)`, where `I(D)`
is the cumulative covered fraction `∫₀ᴰ F` (§4.2).  Carried as an
argument `I` so that no integration theory is needed; only its
monotone non-decreasing behaviour (from `F ≥ 0`) is used. -/
noncomputable def tau (B I : ℝ) : ℝ := I / B

/-- **Gompertz loss on the covered fraction** `L_κ(D)`
`= r̄·|log κ₀|·exp(−α·τ(D))` (§4.1).  Here `logκ₀abs = |log κ₀| > 0`. -/
noncomputable def L_kappa (rbar logκ₀abs α τ : ℝ) : ℝ :=
  rbar * logκ₀abs * Real.exp (-α * τ)

/-- **R.150 exact loss (★MIP)** — the coverage/condensation decomposition

    L(D) = F(D)·L_κ(D) + (1 − F(D))·Φ̄_unc .

A convex combination of the covered cost `L_κ` and the uncovered floor
`Φ̄_unc`, weighted by the coverage fraction `F`. -/
noncomputable def L (F Lκ Φunc : ℝ) : ℝ :=
  F * Lκ + (1 - F) * Φunc

/-- **R.150 — exact closed form is a convex combination.**

`L = F·Lκ + (1−F)·Φunc`.  This is the definitional unfolding, recorded
as the canonical statement of (★MIP). -/
theorem R_150_exact_form (F Lκ Φunc : ℝ) :
    L F Lκ Φunc = F * Lκ + (1 - F) * Φunc := rfl

/-- **R.150 — gap form (§3.2 / §9.2 rewrite).**

`L(D) − L_κ = (1 − F(D))·(Φ̄_unc − L_κ)`.  This isolates the
"uncovered excess" `(1 − F)·(Φ̄_unc − L_κ)`, the term whose Tauberian
asymptotics give the Chinchilla power law in R.150.a. -/
theorem R_150_gap_form (F Lκ Φunc : ℝ) :
    L F Lκ Φunc - Lκ = (1 - F) * (Φunc - Lκ) := by
  unfold L; ring

/-- **R.150 — convex-combination bounds.**

For a genuine coverage fraction `F ∈ [0,1]` and `L_κ ≤ Φ̄_unc` (the
covered cost never exceeds the uncovered floor), the loss lies between
the two endpoints: `L_κ ≤ L(D) ≤ Φ̄_unc`. -/
theorem R_150_between
    (F Lκ Φunc : ℝ) (hF0 : 0 ≤ F) (hF1 : F ≤ 1) (h_le : Lκ ≤ Φunc) :
    Lκ ≤ L F Lκ Φunc ∧ L F Lκ Φunc ≤ Φunc := by
  have h1F : 0 ≤ 1 - F := by linarith
  constructor
  · -- L − Lκ = (1−F)·(Φunc − Lκ) ≥ 0
    have := R_150_gap_form F Lκ Φunc
    have hnn : 0 ≤ (1 - F) * (Φunc - Lκ) := mul_nonneg h1F (by linarith)
    linarith [this, hnn]
  · -- Φunc − L = F·(Φunc − Lκ) ≥ 0
    have : Φunc - L F Lκ Φunc = F * (Φunc - Lκ) := by unfold L; ring
    have hnn : 0 ≤ F * (Φunc - Lκ) := mul_nonneg hF0 (by linarith)
    linarith [this, hnn]

/-- **R.150 — monotone improvement in coverage.**

In the meaningful regime `L_κ < Φ̄_unc` (a covered problem costs strictly
less than an uncovered one), the loss is **strictly decreasing** in the
coverage fraction `F`: covering more problems lowers the loss.  Formally,
`F₁ < F₂ ⟹ L(F₂) < L(F₁)`. -/
theorem R_150_monotone_in_coverage
    (F₁ F₂ Lκ Φunc : ℝ) (h_strict : Lκ < Φunc) (h_lt : F₁ < F₂) :
    L F₂ Lκ Φunc < L F₁ Lκ Φunc := by
  unfold L
  -- (F₂·Lκ + (1−F₂)Φunc) − (F₁·Lκ + (1−F₁)Φunc) = (F₂−F₁)·(Lκ − Φunc) < 0
  have hdiff : (F₂ * Lκ + (1 - F₂) * Φunc) - (F₁ * Lκ + (1 - F₁) * Φunc)
      = (F₂ - F₁) * (Lκ - Φunc) := by ring
  have hneg : (F₂ - F₁) * (Lκ - Φunc) < 0 :=
    mul_neg_of_pos_of_neg (by linarith) (by linarith)
  linarith [hdiff, hneg]

/-- **R.150 — Gompertz factor log-linearity.**

`L_κ(D) = r̄·|log κ₀|·exp(−α·τ)` satisfies, for `r̄·|log κ₀| > 0`,

    log L_κ  =  log(r̄·|log κ₀|)  −  α·τ ,

a straight line of slope `−α` in the condensation time `τ` (the Gompertz
signature, §4.1 / R.118). -/
theorem R_150_Lkappa_loglinear
    (rbar logκ₀abs α τ : ℝ) (h_pre : 0 < rbar * logκ₀abs) :
    Real.log (L_kappa rbar logκ₀abs α τ)
      = Real.log (rbar * logκ₀abs) - α * τ := by
  unfold L_kappa
  rw [Real.log_mul (ne_of_gt h_pre) (Real.exp_ne_zero _), Real.log_exp]
  ring

/-- **R.150 — Gompertz factor is decreasing in condensation time.**

For `α > 0` and positive prefactor, `L_κ(τ)` strictly decreases as `τ`
grows: more effective condensation time ⟹ smaller covered cost. -/
theorem R_150_Lkappa_decreasing
    (rbar logκ₀abs α τ₁ τ₂ : ℝ) (h_pre : 0 < rbar * logκ₀abs)
    (h_α : 0 < α) (h_lt : τ₁ < τ₂) :
    L_kappa rbar logκ₀abs α τ₂ < L_kappa rbar logκ₀abs α τ₁ := by
  unfold L_kappa
  apply mul_lt_mul_of_pos_left _ h_pre
  apply Real.exp_lt_exp.mpr
  -- need  -α·τ₂ < -α·τ₁  from  α > 0, τ₁ < τ₂
  nlinarith [h_α, h_lt]

/-- **R.150 — effective-time monotonicity (§4.2).**

`τ(D) = I(D)/B` with `I(D) = ∫₀ᴰ F` and `B > 0`.  Since `F ≥ 0`, the
cumulative `I` is non-decreasing, hence `τ` is non-decreasing in `D`:
the condensation clock never runs backwards.  We state the monotone step
abstractly: `I₁ ≤ I₂ ⟹ τ(I₁) ≤ τ(I₂)`. -/
theorem R_150_tau_monotone
    (B I₁ I₂ : ℝ) (h_B : 0 < B) (h_le : I₁ ≤ I₂) :
    tau B I₁ ≤ tau B I₂ := by
  unfold tau
  gcongr

/-- **R.150 (Chinchilla compute-optimal allocation, §6.6).**

Compute budget `C = N_param·D`.  Under the compute-optimal power-law
parametrisation `N_param = k_N·C^a` and `D = k_D·C^b` (positive
prefactors, `C > 0`), the budget identity `N_param·D = C` holds for all
`C` **iff** the exponents satisfy the Chinchilla identity

    a + b = 1   (with the prefactor normalisation `k_N·k_D = 1`).

Here we prove the forward direction: `a + b = 1` and `k_N·k_D = 1`
imply the budget constraint `N_param·D = C` exactly. -/
theorem R_150_chinchilla_allocation
    (C a b k_N k_D : ℝ) (hC : 0 < C)
    (h_exp : a + b = 1) (h_pre : k_N * k_D = 1) :
    (k_N * C ^ a) * (k_D * C ^ b) = C := by
  have hCne : C ≠ 0 := ne_of_gt hC
  calc (k_N * C ^ a) * (k_D * C ^ b)
      = (k_N * k_D) * (C ^ a * C ^ b) := by ring
    _ = (k_N * k_D) * C ^ (a + b) := by rw [← Real.rpow_add hC]
    _ = 1 * C ^ (1 : ℝ) := by rw [h_pre, h_exp]
    _ = C := by rw [Real.rpow_one, one_mul]

/-- **R.150 (Chinchilla exponent identity, converse, §6.6).**

Conversely, if the budget constraint `(k_N·C^a)·(k_D·C^b) = C` holds at
two distinct compute scales `C₁ ≠ C₂` (both positive, `C₁,C₂ ≠ 1`) with a
fixed prefactor product `k_N·k_D = 1`, then the exponents are forced to
satisfy `a + b = 1`.  (Reading the constraint at a single scale fixes
`C^(a+b−1) = 1`; two independent scales force the exponent.)

We state the clean consequence: from `C^(a+b) = C^1` with `C > 0`,
`C ≠ 1`, the exponent identity `a + b = 1` follows. -/
theorem R_150_chinchilla_exponent_forced
    (C a b : ℝ) (hC : 0 < C) (hC1 : C ≠ 1)
    (h_budget : C ^ (a + b) = C ^ (1 : ℝ)) :
    a + b = 1 := by
  -- rpow is injective in the exponent for a positive base ≠ 1.
  exact (Real.rpow_right_inj hC hC1).mp h_budget

end ExactScaling

end MIP
