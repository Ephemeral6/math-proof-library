/-
Result R.150.a — Chinchilla degeneration of the MIP exact scaling law.

Reference: `branches/learning_mechanics/workspace/exact_scaling.md` §5.3-§5.4,
§6.6, §9.2 and `R150_upgrade_attempt.md` §6 (R.150.a, **A 条件性** under
(TM-5) + iid-data + heavy-tailed `q` + class-I positive measure + R.117
coverage/condensation timing).

**Statement interpretation used.**  Starting from the R.150 gap form
(see `R150_ExactScaling.lean`), in the coverage-transition regime the
loss excess over its floor is driven by the uncovered fraction:

    L(D) − L_∞  =  Δ_∞ · (1 − F(D)) ,        Δ_∞ := Φ̄_unc − r̄·|log κ₀| > 0 .

For a **heavy-tailed** frequency distribution `q(ω) ∝ ω^(−s)`, `s > 1`,
the Tauberian limit (§5.3) gives the uncovered fraction as a pure power
law in the data budget `D`:

    1 − F(D)  =  c_F · D^(−α_D) ,        α_D = 1 − 1/s  (§5.4).

Substituting yields the **Chinchilla power law**

    L(D) − L_∞  =  C · D^(−α_D) ,        α_D = 1 − 1/s        (★Chinchilla)

with `C = Δ_∞ · c_F`.  This is the degeneration of the MIP exact formula
to the empirically observed Chinchilla scaling, with the single data
statistic `s` (the Zipf tail index) replacing the two-parameter
`γ_κ = 2β − 1/s` ansatz.

This file formalizes the closed-form degeneration and proves:

* the **exponent identity** `α_D = 1 − 1/s` and its sign/range
  (`0 < α_D < 1` for `s > 1`);
* the **Tauberian power law** `1 − F(D) = c_F · D^(−α_D)` and its
  monotone decay in `D` (more data ⟹ smaller uncovered fraction);
* the **loss degeneration** `L(D) − L_∞ = C · D^(−α_D)` obtained by the
  gap-form substitution, with the explicit constant `C = Δ_∞ · c_F`;
* the **log-log signature** `log(L − L_∞) = log C − α_D · log D`, the
  straight line of slope `−α_D` that Chinchilla fits empirically;
* the **Heaps reduction** (§6.6): under Heaps `|K(A_D)| = c_K · D^β`
  and the compute-optimal matching `N_param^opt = c_N · |K(A_D)|`
  (R.131 superposition criticality, with `κ ≈ 1` in the far-transition
  regime), the optimal parameter count obeys `N_param^opt = c · D^β`;
* the **Chinchilla 1:1 law**: in the Heaps-linear limit `β = 1` the
  reduction collapses to the compute-optimal `D ∝ N_param` relation
  reported by Hoffmann et al. (2022).

**This file is `axiom`-free.**  The Tauberian step, the heavy-tailed `q`,
Heaps' law, and R.131 superposition criticality all enter as the explicit
hypothesis bundle defining the macroscopic power laws.
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace ChinchillaDegeneration

open Real

/-- **Chinchilla loss exponent** `α_D := 1 − 1/s` (§5.4).  `s` is the
Zipf tail index of the data frequency distribution `q(ω) ∝ ω^(−s)`. -/
noncomputable def alphaD (s : ℝ) : ℝ := 1 - 1 / s

/-- **R.150.a — exponent identity.**  `α_D = 1 − 1/s` (definitional;
recorded as the canonical statement, replacing the two-parameter
`γ_κ = 2β − 1/s` of the older Cj.50 ansatz). -/
theorem R_150a_exponent_identity (s : ℝ) : alphaD s = 1 - 1 / s := rfl

/-- **R.150.a — exponent range.**

For a genuine heavy tail `s > 1`, the Chinchilla exponent is strictly
between `0` and `1`: `0 < α_D < 1`.  (`s ≈ 1.4` for natural language
gives `α_D ≈ 0.29`, matching the empirical Chinchilla `≈ 0.28`.) -/
theorem R_150a_exponent_range (s : ℝ) (h_s : 1 < s) :
    0 < alphaD s ∧ alphaD s < 1 := by
  have hs0 : 0 < s := by linarith
  unfold alphaD
  constructor
  · -- 0 < 1 − 1/s ⟺ 1/s < 1 ⟺ 1 < s
    have h1 : 1 / s < 1 := by
      rw [div_lt_one hs0]; exact h_s
    linarith
  · -- 1 − 1/s < 1 ⟺ 0 < 1/s
    have h2 : 0 < 1 / s := by positivity
    linarith

/-- **R.150.a — Tauberian uncovered-fraction power law (§5.3-§5.4).**

For heavy-tailed `q`, the average uncovered fraction is
`1 − F(D) = c_F · D^(−α_D)`.  We record it as a `def` of the resource
budget `D`; `c_F > 0` is the `D`-independent Tauberian constant
`r̄·Γ(1 − 1/s)·c^(1/s)/s`. -/
noncomputable def uncoveredFrac (c_F α_D D : ℝ) : ℝ := c_F * D ^ (-α_D)

/-- **R.150.a — uncovered fraction decays in the data budget.**

For `c_F > 0` and `α_D > 0`, `1 − F(D) = c_F · D^(−α_D)` is strictly
decreasing in `D` on `D > 0`: more data covers more problems. -/
theorem R_150a_uncovered_decay
    (c_F α_D D₁ D₂ : ℝ) (h_cF : 0 < c_F) (h_α : 0 < α_D)
    (h_D₁ : 0 < D₁) (h_lt : D₁ < D₂) :
    uncoveredFrac c_F α_D D₂ < uncoveredFrac c_F α_D D₁ := by
  unfold uncoveredFrac
  apply mul_lt_mul_of_pos_left _ h_cF
  exact Real.rpow_lt_rpow_of_neg h_D₁ h_lt (by linarith)

/-- **R.150.a — Chinchilla loss degeneration (★Chinchilla).**

The R.150 gap form `L(D) − L_∞ = Δ_∞·(1 − F(D))` (see `R150_ExactScaling`)
combined with the Tauberian power law `1 − F(D) = c_F·D^(−α_D)` gives the
closed-form Chinchilla scaling

    L(D) − L_∞  =  C · D^(−α_D) ,        C = Δ_∞ · c_F .

Pure substitution of the bundled regime equalities. -/
theorem R_150a_loss_degeneration
    (L Linf Δinf c_F α_D D C : ℝ)
    (h_gap : L - Linf = Δinf * uncoveredFrac c_F α_D D)
    (h_C : C = Δinf * c_F) :
    L - Linf = C * D ^ (-α_D) := by
  rw [h_gap]; unfold uncoveredFrac; rw [h_C]; ring

/-- **R.150.a — log-log signature (slope `−α_D`).**

The degenerate form `L(D) − L_∞ = C·D^(−α_D)` is a straight line of
slope `−α_D` on the log-log plot:

    log (L(D) − L_∞)  =  log C  −  α_D · log D ,

the empirical Chinchilla scaling line.  Requires `C > 0`, `D > 0`. -/
theorem R_150a_loglog_signature
    (L Linf C α_D D : ℝ) (hC : 0 < C) (hD : 0 < D)
    (h_deg : L - Linf = C * D ^ (-α_D)) :
    Real.log (L - Linf) = Real.log C - α_D * Real.log D := by
  rw [h_deg, Real.log_mul (ne_of_gt hC) (by positivity), Real.log_rpow hD]
  ring

/-- **R.150.a — Heaps reduction of the compute-optimal parameter count
(§6.6).**

Under Heaps' law `|K(A_D)| = c_K · D^β` and the R.131 superposition
criticality `N_param^opt = c_N · |K(A_D)|` (`κ ≈ 1` in the
far-transition regime, so `d_eff ≈ |K|`), the optimal parameter count is

    N_param^opt  =  (c_N · c_K) · D^β .

This is the MIP derivation of the empirical compute-optimal parameter
scaling, with exponent `β` set by the data's Heaps coefficient. -/
theorem R_150a_heaps_reduction
    (c_K c_N β D Ksize Nopt : ℝ)
    (h_heaps : Ksize = c_K * D ^ β)
    (h_R131 : Nopt = c_N * Ksize) :
    Nopt = (c_N * c_K) * D ^ β := by
  rw [h_R131, h_heaps]; ring

/-- **R.150.a — Chinchilla 1:1 law (Heaps-linear limit `β = 1`).**

In the Heaps-linear limit `β = 1` (data fully spread over distinct `ω`,
Heaps degenerating to linear), the reduction collapses to the
compute-optimal one-to-one relation

    N_param^opt  =  (c_N · c_K) · D ,

i.e. `N_param ∝ D` — the Chinchilla 1:1 scaling reported by Hoffmann
et al. (2022).  This is the §6.6 statement that the empirical 1:1 law
corresponds to `β ≈ 1`. -/
theorem R_150a_chinchilla_one_to_one
    (c_K c_N D Ksize Nopt : ℝ)
    (h_heaps : Ksize = c_K * D ^ (1 : ℝ))
    (h_R131 : Nopt = c_N * Ksize) :
    Nopt = (c_N * c_K) * D := by
  rw [h_R131, h_heaps, Real.rpow_one]; ring

/-- **R.150.a — compute-allocation exponent identity (link to R.150).**

The Heaps exponent `β` for `N_param ∝ D^β` and the data-budget exponent
in the compute split `D ∝ C^b`, `N_param ∝ C^a` are tied by the budget
constraint `C = N_param · D`.  With `N_param = k_N·C^a`, `D = k_D·C^b`,
the constraint forces `a + b = 1`; consistency of the Heaps relation
`N_param = c·D^β` then reads `a = β·b`, i.e. `a = β·b` with `a + b = 1`,
giving the compute-optimal split

    a = β/(β+1),   b = 1/(β+1),   a + b = 1 .

We prove the closed-form split satisfies `a + b = 1` and `a = β·b`. -/
theorem R_150a_allocation_split
    (β : ℝ) (h_β : 0 < β) :
    let b := 1 / (β + 1)
    let a := β / (β + 1)
    a + b = 1 ∧ a = β * b := by
  have hβ1 : (0 : ℝ) < β + 1 := by linarith
  have hne : (β + 1) ≠ 0 := ne_of_gt hβ1
  refine ⟨?_, ?_⟩
  · -- β/(β+1) + 1/(β+1) = (β+1)/(β+1) = 1
    field_simp
  · -- β/(β+1) = β · (1/(β+1))
    field_simp

end ChinchillaDegeneration

end MIP
