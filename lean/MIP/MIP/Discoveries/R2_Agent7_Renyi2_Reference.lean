/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: α = 2 Renyi divergence (Hellinger / collision) with uniform
              reference.
  SUMMARY:
    The α = 2 Renyi divergence of `d` against `q` is
        D_2(d ‖ q) := log (∑_ω (d.p ω)² / q.p ω).

    Specialised to uniform `q = 1/|Ω|`:
        D_2(d ‖ uniform) = log (|Ω| · ∑_ω (d.p ω)²).

    Distribution-level analogue of Agent 3's `Σ π_S²` bracket:
        1/|Ω|  ≤  ∑_ω (d.p ω)²  ≤  1
    (lower: Cauchy-Schwarz applied to (d.p, 1); upper: each p ≤ 1 so
    p² ≤ p, hence ∑ p² ≤ ∑ p = 1). Both inequalities are proved
    directly (Agent 3's results live at the partition level).

    Consequences for `D_2(d ‖ uniform)`:

      • `Renyi2_to_uniform_nonneg`         — `D_2 ≥ 0`.
      • `Renyi2_to_uniform_le_log_card`    — `D_2 ≤ log |Ω|`.
      • `Renyi2_to_uniform_bracket`        — `0 ≤ D_2 ≤ log |Ω|`.
      • `Renyi2_to_uniform_eq_zero_iff_collision_inv`
                                            — `D_2 = 0 ⟺ ∑ p² = 1/|Ω|`.

    The "D_2 = 0 ⟺ d uniform" equality case is *not* attempted (it
    requires Cauchy-Schwarz equality case, beyond clean Mathlib reach).
    The intermediate `D_2 = 0 ⟺ ∑ (d.p ω)² = 1/|Ω|` is the algebraic
    content, equivalent to uniform by Cauchy-Schwarz, recorded as a
    separate observation.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard
import Mathlib.Algebra.Order.Chebyshev

namespace MIP

namespace R2_Agent7_Renyi2_Reference

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-- **α = 2 Renyi divergence with uniform reference (closed form).**

When `q = uniform = 1/|Ω|`, the standard form
`D_2(d ‖ q) := log (∑_ω (d.p ω)² / q.p ω)` collapses to

    D_2(d ‖ uniform)  =  log (|Ω| · ∑_ω (d.p ω)²).

We adopt this closed form as the definition, since the uniform reference
is the only case in scope and the closed form is what every consequence
uses. -/
noncomputable def Renyi2_to_uniform (d : ActivationDist Ω) : ℝ :=
  Real.log ((Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2)

/-! ### Distribution-level Σ (d.p)² bracket. -/

/-- **Upper bound `∑_ω (d.p ω)² ≤ 1`.**

Each `(d.p ω)² ≤ d.p ω` because `0 ≤ d.p ω ≤ 1` (the masses sum to 1, so
each is bounded by 1). Summing gives the bound. -/
theorem sum_p_sq_le_one (d : ActivationDist Ω) :
    ∑ ω, (d.p ω : ℝ)^2 ≤ 1 := by
  classical
  -- Each (d.p ω : ℝ) ≤ 1 since the masses sum to 1.
  have h_le_one : ∀ ω, (d.p ω : ℝ) ≤ 1 := by
    intro ω
    have h_sum : ∑ ω', (d.p ω' : ℝ) = 1 := by
      have : ((∑ ω', d.p ω' : NNReal) : ℝ) = ∑ ω', (d.p ω' : ℝ) := by
        push_cast; rfl
      rw [← this, d.normalized]; simp
    have h_le_sum : (d.p ω : ℝ) ≤ ∑ ω', (d.p ω' : ℝ) :=
      Finset.single_le_sum (f := fun ω' => (d.p ω' : ℝ))
        (fun ω' _ => (d.p ω').coe_nonneg) (Finset.mem_univ ω)
    linarith
  have h_nonneg : ∀ ω, (0 : ℝ) ≤ (d.p ω : ℝ) := fun ω => (d.p ω).coe_nonneg
  -- p² ≤ p pointwise, then sum.
  have h_sq_le : ∀ ω, ((d.p ω : ℝ))^2 ≤ (d.p ω : ℝ) := by
    intro ω
    have h0 := h_nonneg ω
    have h1 := h_le_one ω
    nlinarith [sq_nonneg (d.p ω : ℝ)]
  have h_sum_le : ∑ ω, ((d.p ω : ℝ))^2 ≤ ∑ ω, (d.p ω : ℝ) :=
    Finset.sum_le_sum (fun ω _ => h_sq_le ω)
  have h_sum : ∑ ω', (d.p ω' : ℝ) = 1 := by
    have : ((∑ ω', d.p ω' : NNReal) : ℝ) = ∑ ω', (d.p ω' : ℝ) := by
      push_cast; rfl
    rw [← this, d.normalized]; simp
  linarith

/-- **Lower bound `1/|Ω| ≤ ∑_ω (d.p ω)²` (Cauchy-Schwarz).**

`(∑ d.p ω)² ≤ |Ω| · ∑ (d.p ω)²`; LHS = 1, so `∑ (d.p ω)² ≥ 1/|Ω|`. -/
theorem sum_p_sq_ge_inv_card [Nonempty Ω] (d : ActivationDist Ω) :
    (1 : ℝ) / (Fintype.card Ω : ℝ) ≤ ∑ ω, (d.p ω : ℝ)^2 := by
  classical
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_sum : ∑ ω', (d.p ω' : ℝ) = 1 := by
    have : ((∑ ω', d.p ω' : NNReal) : ℝ) = ∑ ω', (d.p ω' : ℝ) := by
      push_cast; rfl
    rw [← this, d.normalized]; simp
  -- Cauchy-Schwarz / Chebyshev: (∑ f i)² ≤ univ.card · ∑ (f i)².
  have h_cs : (∑ ω, (d.p ω : ℝ))^2 ≤ (Finset.univ : Finset Ω).card *
                ∑ ω, ((d.p ω : ℝ))^2 :=
    sq_sum_le_card_mul_sum_sq
  rw [h_sum] at h_cs
  simp at h_cs
  -- 1 ≤ Fintype.card Ω · ∑ p²  ⟹  1 / Fintype.card Ω ≤ ∑ p².
  rw [div_le_iff₀ h_card_pos]
  linarith

/-- **Helper: `∑ (d.p ω)² > 0` for a nonempty `Ω`.**

The masses sum to 1 > 0, so some `d.p ω₀ > 0`, so `(d.p ω₀)² > 0`. -/
private lemma sum_p_sq_pos [Nonempty Ω] (d : ActivationDist Ω) :
    0 < ∑ ω, (d.p ω : ℝ)^2 := by
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_lower := sum_p_sq_ge_inv_card d
  have h_inv_pos : 0 < (1 : ℝ) / (Fintype.card Ω : ℝ) := by positivity
  linarith

/-! ### Renyi-2 bracket: `0 ≤ D_2(d ‖ uniform) ≤ log |Ω|`. -/

/-- **D_2(d ‖ uniform) ≥ 0.**

`∑ (d.p ω)² ≥ 1/|Ω|` ⟹ `|Ω| · ∑ p² ≥ 1` ⟹ `log (|Ω| · ∑ p²) ≥ log 1 = 0`. -/
theorem Renyi2_to_uniform_nonneg [Nonempty Ω] (d : ActivationDist Ω) :
    0 ≤ Renyi2_to_uniform d := by
  unfold Renyi2_to_uniform
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_lower := sum_p_sq_ge_inv_card d
  have h_mul_ge : (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 ≥ 1 := by
    have h_card_ne : (Fintype.card Ω : ℝ) ≠ 0 := ne_of_gt h_card_pos
    -- Multiply h_lower by (Fintype.card Ω : ℝ) > 0.
    have h_mul : (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ))
                  ≤ (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 :=
      mul_le_mul_of_nonneg_left h_lower (le_of_lt h_card_pos)
    have h_simp : (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ)) = 1 := by
      field_simp
    linarith
  have h_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 := by linarith
  have h_log_ge : Real.log 1 ≤
      Real.log ((Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2) :=
    Real.log_le_log (by norm_num) h_mul_ge
  rw [Real.log_one] at h_log_ge
  exact h_log_ge

/-- **D_2(d ‖ uniform) ≤ log |Ω|.**

`∑ (d.p ω)² ≤ 1` ⟹ `|Ω| · ∑ p² ≤ |Ω|` ⟹ `log (|Ω| · ∑ p²) ≤ log |Ω|`. -/
theorem Renyi2_to_uniform_le_log_card [Nonempty Ω] (d : ActivationDist Ω) :
    Renyi2_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) := by
  unfold Renyi2_to_uniform
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_upper := sum_p_sq_le_one d
  have h_pos := sum_p_sq_pos d
  have h_mul_le : (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2
                    ≤ (Fintype.card Ω : ℝ) :=
    by
      have h_mul : (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2
                    ≤ (Fintype.card Ω : ℝ) * 1 :=
        mul_le_mul_of_nonneg_left h_upper (le_of_lt h_card_pos)
      linarith
  have h_prod_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 :=
    mul_pos h_card_pos h_pos
  exact Real.log_le_log h_prod_pos h_mul_le

/-- **Bracket: `0 ≤ D_2(d ‖ uniform) ≤ log |Ω|`.** -/
theorem Renyi2_to_uniform_bracket [Nonempty Ω] (d : ActivationDist Ω) :
    0 ≤ Renyi2_to_uniform d
      ∧ Renyi2_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) :=
  ⟨Renyi2_to_uniform_nonneg d, Renyi2_to_uniform_le_log_card d⟩

/-- **D_2(d ‖ uniform) = 0 ⟺ ∑ (d.p ω)² = 1/|Ω|.**

The algebraic content: D_2 vanishes iff the collision probability hits
its Cauchy-Schwarz minimum 1/|Ω|. -/
theorem Renyi2_to_uniform_eq_zero_iff_collision_inv
    [Nonempty Ω] (d : ActivationDist Ω) :
    Renyi2_to_uniform d = 0 ↔
      ∑ ω, (d.p ω : ℝ)^2 = 1 / (Fintype.card Ω : ℝ) := by
  unfold Renyi2_to_uniform
  have h_card_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h_card_ne : (Fintype.card Ω : ℝ) ≠ 0 := ne_of_gt h_card_pos
  have h_pos := sum_p_sq_pos d
  have h_prod_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 :=
    mul_pos h_card_pos h_pos
  constructor
  · intro h_log_zero
    -- log (|Ω| · ∑ p²) = 0 ⟹ |Ω| · ∑ p² = 1 ⟹ ∑ p² = 1/|Ω|.
    have h_eq_one : (Fintype.card Ω : ℝ) * ∑ ω, (d.p ω : ℝ)^2 = 1 := by
      have := Real.log_eq_zero.mp h_log_zero
      rcases this with h | h | h
      · -- |Ω| · ∑ p² = 0, impossible since both positive.
        linarith
      · exact h
      · -- = -1, impossible since positive.
        linarith
    -- |Ω| · ∑ p² = 1 ⟹ ∑ p² = 1 / |Ω|.
    rw [eq_div_iff h_card_ne]
    linarith
  · intro h_eq
    rw [h_eq]
    have h_mul_one : (Fintype.card Ω : ℝ) * (1 / (Fintype.card Ω : ℝ)) = 1 := by
      field_simp
    rw [h_mul_one]
    exact Real.log_one

end R2_Agent7_Renyi2_Reference

end MIP
