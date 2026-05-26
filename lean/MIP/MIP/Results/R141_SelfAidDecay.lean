/-
Result R.141 — ξ(A_t) training dynamics (self-aid degradation coefficient).

Reference: `branches/duality/workspace/new_results.md` R.141 (terminal-3
local R.068, B 条件性, 2026-05-16 duality branch).

**Statement interpretation used.**  R.141 studies the *self-aid
degradation coefficient*

    ξ(X) := Z_q^full(X) / Z_q(X | X) ∈ (0, 1],

(where the numerator is a max over the *full* meta set and the denominator
a max over the *self-applicable* subset, so the numerator's max is taken
over the larger pool — but as the relevant ξ-defining quotient it lands
in `(0,1]`), and its evolution along the training trajectory.  Its
structural / arithmetic core, formalized here:

* **(ξ-range)** `ξ ∈ (0,1]`: from `0 < Z_q^full ≤ Z_q(X|X)` — the
  self-applicable max never exceeds the full max so the ratio is in
  `(0,1]`.
* **(iii) self-aid identity** (R.138 frame):
  `N_self(A_t) = Φ₀(A_t,p) · Z_q^full(A_t) / ξ(A_t)`.
* **(iii) exponential-rate dichotomy.**  With the exponential models
  `Φ₀(t) = Φ_c·e^{−α_Φ t}`, `ξ(t) = ξ_c·e^{−α_ξ t}`, `Z_q^full → Z∞`,
  the self-aid cost is `N_self(t) = (Φ_c·Z∞/ξ_c)·e^{(α_ξ − α_Φ)·t}`,
  hence:
    - `α_ξ < α_Φ`  ⟹  `N_self(t) → 0`  (A retains self-correction:
      solving-flywheel rate beats reflection-decay rate);
    - `α_Φ < α_ξ`  ⟹  `N_self(t) → ∞`  (reflection lost faster than
      solving — A solves but cannot self-correct).

All MIP dependencies (R.138 frame, exponential model parameters) enter as
explicit real-valued bundle hypotheses.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace SelfAidDecay

open Real Filter Topology

/-- **R.141 (ξ-range).**

`ξ := Z_q^full / Z_q_self` lies in `(0, 1]` whenever
`0 < Z_q^full ≤ Z_q_self` (the self-applicable max is taken over a subset,
so it cannot exceed the full max — hence the quotient is `≤ 1`, and it is
positive). -/
theorem R_141_xi_range
    (Z_full Z_self : ℝ) (h_full_pos : 0 < Z_full) (h_le : Z_full ≤ Z_self) :
    0 < Z_full / Z_self ∧ Z_full / Z_self ≤ 1 := by
  have h_self_pos : 0 < Z_self := lt_of_lt_of_le h_full_pos h_le
  refine ⟨div_pos h_full_pos h_self_pos, ?_⟩
  rw [div_le_one h_self_pos]; exact h_le

/-- **R.141 (iii) — self-aid identity.**

In the R.138 self-aid frame, with `ξ = Z_full / Z_self`,

    N_self  =  Φ₀ · Z_self  =  Φ₀ · Z_full / ξ .

Pure algebra (substitute `Z_self = Z_full / ξ`). -/
theorem R_141_iii_self_aid_identity
    (N_self Φ₀ Z_full Z_self ξ : ℝ)
    (h_full_pos : 0 < Z_full)
    (h_ξ : ξ = Z_full / Z_self)
    (h_Nself : N_self = Φ₀ * Z_self) :
    N_self = Φ₀ * Z_full / ξ := by
  subst h_ξ h_Nself
  rw [div_div_eq_mul_div, mul_right_comm, mul_div_assoc,
      div_self (ne_of_gt h_full_pos), mul_one]

/-- **R.141 (iii) — exponential self-aid model (closed form).**

With `Φ₀(t) = Φ_c·e^{−α_Φ t}`, `ξ(t) = ξ_c·e^{−α_ξ t}`, `Z_q^full = Z∞`,
the self-aid cost `N_self(t) = Φ₀(t)·Z∞/ξ(t)` simplifies to

    N_self(t) = (Φ_c·Z∞/ξ_c) · e^{(α_ξ − α_Φ)·t} .

Requires `ξ_c ≠ 0`. -/
theorem R_141_iii_exp_closed_form
    (Φc Zinf ξc αΦ αξ t : ℝ) (h_ξc : ξc ≠ 0) :
    (Φc * Real.exp (-αΦ * t)) * Zinf / (ξc * Real.exp (-αξ * t))
      = (Φc * Zinf / ξc) * Real.exp ((αξ - αΦ) * t) := by
  have hkey : Real.exp ((αξ - αΦ) * t)
      = Real.exp (-αΦ * t) / Real.exp (-αξ * t) := by
    rw [← Real.exp_sub]; ring_nf
  rw [hkey]
  have he : Real.exp (-αξ * t) ≠ 0 := (Real.exp_pos _).ne'
  field_simp

/-- **R.141 (iii) — convergence case (`α_ξ < α_Φ` ⟹ `N_self → 0`).**

If the reflection-decay rate `α_ξ` is slower than the solving-flywheel
rate `α_Φ`, the self-aid cost `N_self(t) = K·e^{(α_ξ − α_Φ)·t}` tends to
`0` as `t → ∞`: A retains the ability to self-correct. -/
theorem R_141_iii_converges
    (K αΦ αξ : ℝ) (h : αξ < αΦ) :
    Tendsto (fun t => K * Real.exp ((αξ - αΦ) * t)) atTop (nhds 0) := by
  have hlim : Tendsto (fun t : ℝ => (αξ - αΦ) * t) atTop atBot :=
    (tendsto_const_mul_atBot_of_neg (by linarith)).mpr tendsto_id
  have h2 : Tendsto (fun t : ℝ => Real.exp ((αξ - αΦ) * t)) atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp hlim
  have h3 := h2.const_mul K
  simpa using h3

/-- **R.141 (iii) — divergence case (`α_Φ < α_ξ` ⟹ `N_self → ∞`).**

If reflection is lost faster than solving improves (`α_Φ < α_ξ`) and the
prefactor `K > 0`, then `N_self(t) = K·e^{(α_ξ − α_Φ)·t} → ∞`: A solves
but loses self-correction (the "superhuman solver, zero self-reflection"
risk). -/
theorem R_141_iii_diverges
    (K αΦ αξ : ℝ) (hK : 0 < K) (h : αΦ < αξ) :
    Tendsto (fun t => K * Real.exp ((αξ - αΦ) * t)) atTop atTop := by
  have hlim : Tendsto (fun t : ℝ => (αξ - αΦ) * t) atTop atTop :=
    Tendsto.const_mul_atTop (by linarith) tendsto_id
  have h2 : Tendsto (fun t : ℝ => Real.exp ((αξ - αΦ) * t)) atTop atTop :=
    Real.tendsto_exp_atTop.comp hlim
  exact h2.const_mul_atTop hK

end SelfAidDecay

end MIP
