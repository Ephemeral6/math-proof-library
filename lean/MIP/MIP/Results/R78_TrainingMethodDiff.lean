/-
Result R.78 — Differential effects of training methods (comparison structure).

Reference: `workspace/new_results.md` R.78 (B 级; deps T.5, R.76, R.77, R.59,
R.61, D.3.3, D.3.7). Empirical/qualitative differential-effect table.

**Statement.** R.78 tabulates, for each training method, its marginal effect
on the four phase-space dimensions `(|K|, Z⁻¹, H_K, κ)`:

    method            Δ|K|   ΔZ⁻¹   ΔH_K   Δκ    dominant
    Pretraining       ↑↑↑    ↑      ↑      ↑     |K| expansion
    SFT               ↑      ↑      ↓      ↑     H_K concentrate, κ
    RLHF              →      ↑↑     ↓      ↑↑    Z⁻¹ & κ dual-engine
    Collaboration     →      ↑↑↑    →      ↑↑    Z⁻¹ (metacog-sensitive)
    Distillation      →      ↑      ↑      →     H_K up, Z up
    Chain-of-Thought  →      ↑      →      ↑↑    κ dominant (composition)

(arrows = direction & strength). The table makes concrete **ordering** claims,
e.g. collaboration training drives ΔZ⁻¹ strictly more than pretraining/SFT;
RLHF and collaboration drive Δκ strictly more than pretraining/SFT.

R.78 also derives (via R.77 partials) the **marginal-benefit** law: the κ
marginal gain `∂N/∂κ` has magnitude `N / (κ · |log κ|)`, which blows up as
`κ → 1⁻` — explaining why CoT / RLHF / collaboration are so effective in the
mid-to-late training régime.

**Pure-math kernel (this file).** Rather than a vacuous table, we encode the
algebraic comparison structure. Each method gets a real-valued marginal effect
on each dimension, bundled as hypotheses (the empirical magnitudes), and we
prove the **ordering theorems** the table asserts as strict/weak inequalities.
We also formalize the κ marginal-benefit blow-up: with `mκ κ := N / (κ·|log κ|)`
(R.77), as `κ → 1` with `N > 0` the magnitude `mκ → ∞`.

**This file is `axiom`-free.** Empirical magnitudes and the R.77 partial
formula enter only through explicit hypotheses.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Algebra.Order.LiminfLimsup
import Mathlib.Tactic.Linarith

namespace MIP

namespace TrainingMethodDiff

open Filter Topology

/-- The marginal effect of a training method on the four phase-space
dimensions `(|K|, Z⁻¹, H_K, κ)` (D.3.3 / D.3.7 coordinates). A bundle of four
reals; signs/magnitudes are supplied empirically (R.78 table). -/
structure Effect where
  dK    : ℝ   -- Δ|K|
  dZinv : ℝ   -- ΔZ⁻¹
  dHK   : ℝ   -- ΔH_K
  dκ    : ℝ   -- Δκ

/-- **R.78 — ΔZ⁻¹ ordering (collaboration is the strongest impedance engine).**

The table's central claim about the metacognition (Z⁻¹) axis: collaboration
data training (`↑↑↑`) drives ΔZ⁻¹ strictly above RLHF (`↑↑`), which in turn is
strictly above SFT (`↑`) and pretraining (`↑`). Given the empirical magnitudes
as a strict chain, the transitive ordering
`collab.dZinv > rlhf.dZinv > sft.dZinv` holds. -/
theorem R_78_Zinv_ordering
    (pretrain sft rlhf collab : Effect)
    (h1 : collab.dZinv > rlhf.dZinv)
    (h2 : rlhf.dZinv > sft.dZinv)
    (h3 : sft.dZinv ≥ pretrain.dZinv) :
    collab.dZinv > sft.dZinv ∧ collab.dZinv > pretrain.dZinv := by
  constructor
  · linarith
  · linarith

/-- **R.78 — Δκ ordering (composition engines beat the breadth engines).**

The combinatorial-ability (κ) axis: RLHF, collaboration, and CoT (`↑↑`) drive
Δκ strictly above pretraining and SFT (`↑`). From the bundled empirical
magnitudes, each composition-oriented method exceeds each breadth-oriented
method on Δκ. -/
theorem R_78_kappa_ordering
    (pretrain sft rlhf collab cot : Effect)
    (h_rlhf : rlhf.dκ > sft.dκ)
    (h_collab : collab.dκ > sft.dκ)
    (h_cot : cot.dκ > sft.dκ)
    (h_sft : sft.dκ ≥ pretrain.dκ) :
    rlhf.dκ > pretrain.dκ ∧ collab.dκ > pretrain.dκ ∧ cot.dκ > pretrain.dκ :=
  ⟨by linarith, by linarith, by linarith⟩

/-- **R.78 — dominant-effect characterization (CoT is κ-dominant).**

"Dominant effect" of a method = the dimension with the largest marginal
magnitude. For CoT the table asserts κ dominates: `Δκ` exceeds each of the
other three coordinates of its own effect vector. We record this as the
formal meaning of the "dominant" column entry. -/
theorem R_78_cot_kappa_dominant
    (cot : Effect)
    (h_dK : cot.dκ > cot.dK)
    (h_dZinv : cot.dκ > cot.dZinv)
    (h_dHK : cot.dκ > cot.dHK) :
    cot.dκ > cot.dK ∧ cot.dκ > cot.dZinv ∧ cot.dκ > cot.dHK :=
  ⟨h_dK, h_dZinv, h_dHK⟩

/-- **R.78 — pretraining is |K|-dominant.**

Symmetrically, pretraining's dominant effect is `|K|` expansion: `Δ|K|`
exceeds each other coordinate of its effect vector. -/
theorem R_78_pretrain_dK_dominant
    (pretrain : Effect)
    (h_dZinv : pretrain.dK > pretrain.dZinv)
    (h_dHK : pretrain.dK > pretrain.dHK)
    (h_dκ : pretrain.dK > pretrain.dκ) :
    pretrain.dK > pretrain.dZinv ∧ pretrain.dK > pretrain.dHK ∧
      pretrain.dK > pretrain.dκ :=
  ⟨h_dZinv, h_dHK, h_dκ⟩

/-- **R.78 — κ marginal-benefit blow-up (R.77 partial, mid/late-training law).**

By R.77, the κ marginal gain has magnitude `mκ(κ) := N / (κ · |log κ|)`. As
`κ → 1` from below (the mid-to-late training régime, `κ ∈ (0,1)`), `log κ → 0`,
so the denominator `κ · |log κ| → 0⁺` while `N > 0` is fixed; hence the
magnitude `mκ → ∞`. This is the precise content of R.78's "continuing to raise
κ has enormous marginal return near κ ≈ 1", explaining CoT/RLHF effectiveness.

Formalized via the equivalent denominator `|log κ|` on the mid-training régime
`κ ∈ (0,1)`: as `κ → 1` within `(0,1)`, `|log κ| → 0` and stays `> 0`, so
`(|log κ|)⁻¹ → ∞`, hence `N / |log κ| = N · (|log κ|)⁻¹ → ∞`. -/
theorem R_78_kappa_marginal_blowup
    (N : ℝ) (hN : 0 < N) :
    Tendsto (fun κ : ℝ => N / |Real.log κ|)
      (nhdsWithin 1 (Set.Ioo (0 : ℝ) 1)) atTop := by
  -- |log κ| → 0 as κ → 1 (log continuous at 1, log 1 = 0).
  have h_log_cont : Tendsto (fun κ : ℝ => Real.log κ) (nhds (1 : ℝ)) (nhds 0) := by
    have := (Real.continuousAt_log (one_ne_zero)).tendsto
    simpa [Real.log_one] using this
  have h_abs : Tendsto (fun κ : ℝ => |Real.log κ|) (nhds (1 : ℝ)) (nhds 0) := by
    have := (continuous_abs.tendsto (0 : ℝ)).comp h_log_cont
    simpa using this
  have h_abs' : Tendsto (fun κ : ℝ => |Real.log κ|)
      (nhdsWithin 1 (Set.Ioo (0 : ℝ) 1)) (nhds 0) :=
    h_abs.mono_left nhdsWithin_le_nhds
  -- on (0,1), log κ < 0 so |log κ| > 0: the denominator approaches 0 from above.
  have h_pos : ∀ᶠ κ in nhdsWithin (1 : ℝ) (Set.Ioo (0 : ℝ) 1), 0 < |Real.log κ| := by
    filter_upwards [self_mem_nhdsWithin] with κ hκ
    have hlog_neg : Real.log κ < 0 := Real.log_neg hκ.1 hκ.2
    exact abs_pos.mpr (ne_of_lt hlog_neg)
  -- |log κ| → 0 within the positives, hence (|log κ|)⁻¹ → atTop.
  have h_to_GT : Tendsto (fun κ : ℝ => |Real.log κ|)
      (nhdsWithin 1 (Set.Ioo (0 : ℝ) 1)) (nhdsWithin 0 (Set.Ioi 0)) :=
    tendsto_nhdsWithin_iff.mpr ⟨h_abs', h_pos⟩
  have h_inv : Tendsto (fun κ : ℝ => (|Real.log κ|)⁻¹)
      (nhdsWithin 1 (Set.Ioo (0 : ℝ) 1)) atTop :=
    tendsto_inv_nhdsGT_zero.comp h_to_GT
  -- N / |log κ| = N · (|log κ|)⁻¹ → N · (+∞) = +∞ (N > 0).
  have h_mul : Tendsto (fun κ : ℝ => N * (|Real.log κ|)⁻¹)
      (nhdsWithin 1 (Set.Ioo (0 : ℝ) 1)) atTop :=
    h_inv.const_mul_atTop hN
  simpa [div_eq_mul_inv] using h_mul

end TrainingMethodDiff

end MIP
