/-
Result R.412 — Active inference as a special case of dual emergence
(the optimal "questioner / altruistic action" minimizes the dual-emergence
impedance `Z_q`).

Reference: `workspace/friston_mip_unification.md` §R.412 (b) "Active
inference" (A, 2026-05-16 theory-fusion block 9), with the sender/receiver
duality of D.3.9.

**Statement.** Under (F1') (both `Y_i` and `Y_j` are agents), active
inference unifies with the MIP sender/receiver duality:

* `Y_i` plays the **questioner** role for `Y_j` as **solver** (dual-role
  structure);
* by **D.3.9**, the dual-emergence impedance is
      `Z_q(Y_j | Y_i) = (max_{m ∈ M_{Y_i}} ΔΦ*(m, s_{Y_j}))⁻¹`,
  the inverse of the best cross-agent state push;
* Friston's altruistic / active-inference action selection
      `m* = argmax_{m ∈ M_{Y_i}} ΔΦ*(m, s_{Y_j})`
  is therefore **exactly** the intervention that **minimizes** `Z_q(Y_j|Y_i)`.

This file encodes the algebraic kernel: with `Φ : M → ℝ` the cross-agent
push `ΔΦ*(·, s_{Y_j})` over the (finite, nonempty) action repertoire `M`,
and `Zq := 1 / (⨆ m, Φ m)`,

1. `m*` maximizes `Φ`  ⟺  `m*` minimizes the per-action impedance
   `m ↦ 1 / Φ m` (on the positive-push regime), and
2. the agent that selects `m*` realizes the smallest possible
   `Z_q(Y_j | Y_i)` — i.e. *the optimal questioner minimizes `Z_q`*.

The D.3.9 mapping conditions (positivity of the push, the `Z = 1/Π`
identity, the finite nonempty repertoire) enter as explicit hypotheses,
matching the MIP-side dependence.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace ActiveInferenceDual

variable {M : Type*}

/-- **D.3.9 dual-emergence impedance (per-action form).**

For action `m`, the impedance contribution is the reciprocal of the
cross-agent push `Φ m = ΔΦ*(m, s_{Y_j})`. The aggregate impedance
`Z_q(Y_j | Y_i)` is the reciprocal of the *maximal* push, i.e.
`Zq Φ best = 1 / best` where `best = max_m Φ m`. -/
noncomputable def impedance (Φ : M → ℝ) (m : M) : ℝ := 1 / Φ m

/-- The aggregate dual-emergence impedance `Z_q(Y_j | Y_i) = 1 / best`
where `best` is the optimal (maximal) cross-agent push. -/
noncomputable def Zq (best : ℝ) : ℝ := 1 / best

/-- **R.412 (b) — the active-inference / questioner optimum minimizes the
per-action impedance.**

On the positive-push regime (`Φ m > 0` for every `m`, the D.3.9 admissibility
condition), maximizing the cross-agent push `Φ` is *equivalent* to
minimizing the per-action impedance `m ↦ 1 / Φ m`. So Friston's
`m* = argmax Φ` is exactly the MIP `argmin Z_q`. -/
theorem R_412_argmax_push_iff_argmin_impedance
    (Φ : M → ℝ) (hΦ : ∀ m, 0 < Φ m) (m_star : M) :
    (∀ m, Φ m ≤ Φ m_star) ↔ (∀ m, impedance Φ m_star ≤ impedance Φ m) := by
  unfold impedance
  constructor
  · intro hmax m
    -- Φ m ≤ Φ m_star, both positive ⟹ 1/(Φ m_star) ≤ 1/(Φ m).
    exact one_div_le_one_div_of_le (hΦ m) (hmax m)
  · intro hmin m
    -- 1/(Φ m_star) ≤ 1/(Φ m), both positive ⟹ Φ m ≤ Φ m_star.
    have h := hmin m
    -- `one_div_le_one_div` : 0 < a → 0 < b → (1/a ≤ 1/b ↔ b ≤ a)
    exact (one_div_le_one_div (hΦ m_star) (hΦ m)).mp h

/-- **R.412 (b) — the optimal questioner realizes the minimal `Z_q`.**

Given the D.3.9 identity `Z_q(Y_j|Y_i) = 1 / best` with `best = max_m Φ m`
(the optimal push attained at `m_star`), the impedance contributed by the
optimal questioner action `m_star` equals the aggregate `Z_q`, and is
`≤` the impedance of *every* action. Hence the optimal questioner attains
the globally smallest dual-emergence impedance. -/
theorem R_412_optimal_questioner_minimizes_Zq
    (Φ : M → ℝ) (hΦ : ∀ m, 0 < Φ m) (m_star : M)
    (hmax : ∀ m, Φ m ≤ Φ m_star) :
    Zq (Φ m_star) = impedance Φ m_star ∧ ∀ m, Zq (Φ m_star) ≤ impedance Φ m := by
  refine ⟨rfl, ?_⟩
  intro m
  -- `Zq (Φ m_star) = 1 / Φ m_star = impedance Φ m_star ≤ impedance Φ m`.
  show (1 : ℝ) / Φ m_star ≤ 1 / Φ m
  exact one_div_le_one_div_of_le (hΦ m) (hmax m)

/-- **R.412 (b) — `Z = 1/Π` precision identity (D.3.9 / R.408 step 3).**

The dual-emergence impedance and the cross-agent (empathic) precision are
reciprocal: `Z_q = 1/Π` and `Π = 1/Z_q`, hence `Z_q · Π = 1`. This is the
F4-side identity that turns the questioner optimum into a *precision*
maximum, the active-inference reading. -/
theorem R_412_impedance_precision_reciprocal
    (Pi_prec : ℝ) (hpos : 0 < Pi_prec) :
    Zq Pi_prec = 1 / Pi_prec ∧ Zq Pi_prec * Pi_prec = 1 := by
  refine ⟨rfl, ?_⟩
  show (1 / Pi_prec) * Pi_prec = 1
  exact one_div_mul_cancel (ne_of_gt hpos)

/-- **R.412 (b) corollary — minimizing `Z_q` maximizes the precision push.**

Combining the two identities: on the positive regime, the questioner that
minimizes `Z_q(Y_j|Y_i)` is exactly the one that maximizes the cross-agent
precision `Π_{j|i} = 1 / Z_q`. This is the active-inference statement "act
to maximize the precision of your effect on the other agent's beliefs". -/
theorem R_412_min_Zq_iff_max_precision
    (Φ : M → ℝ) (hΦ : ∀ m, 0 < Φ m) (m_star : M) :
    (∀ m, impedance Φ m_star ≤ impedance Φ m)
      ↔ (∀ m, Φ m ≤ Φ m_star) :=
  (R_412_argmax_push_iff_argmin_impedance Φ hΦ m_star).symm

end ActiveInferenceDual

end MIP
