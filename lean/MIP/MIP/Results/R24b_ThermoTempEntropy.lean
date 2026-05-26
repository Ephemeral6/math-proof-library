/-
Result R.24b — Thermodynamic temperature-entropy analogy: which part of the
structure IS preserved, and which is NOT.

Reference: `C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md` R.24a
("温度-熵关系 (dS = dQ/T)：H_K 与 T(p,A) 在涌现力学中无 dH_K/dT 关系" — kept
at B); `C:/Users/12729/Desktop/MIP/book/appendix_F_thermodynamics.md` F.2
(Boltzmann emergent entropy `S_B = log(κ·|K|²) = log κ + 2·log|K|`) and the
dual-temperature table (`T_kin = Z·⟨Φ̇²⟩` vs `T_ent = N/|B|`);
`C:/Users/12729/Desktop/MIP/results/R_master_index.md` R.24b ("结构不保持").

**What R.24b says.** The thermodynamic analogy of emergence mechanics is
NOT fully structure-preserving.  Ohm's law (`N = Φ₀·Z`, T.8) and energy
conservation along the optimal path (R.24a, telescoping) ARE preserved.
The temperature-entropy / Clausius structure is NOT.

This file formalises both halves crisply:

* **Preserved relation (encoded as an algebraic theorem).**  The
  Boltzmann emergent entropy splits additively under the analogy map:

      S_B := log (κ · |K|²)   ⟹   S_B = log κ + 2 · log |K|          (for κ, |K| > 0).

  This is the entropy identity that the analogy preserves (F.2.1).  It is
  monotone increasing in both `κ` and `|K|` (the "phase-space volume"
  interpretation).

* **Non-preservation (encoded as a counter-identity / no-go fact).**  The
  framework carries TWO distinct temperatures — the kinetic / microcanonical
  `T_kin = Z·⟨Φ̇²⟩` and the entropic / grand-canonical `T_ent = N/|B|`.
  A single Clausius law `dS = dQ/T` would force one temperature.  We make
  the obstruction precise: the two temperatures need not agree, so any
  identity that pins `S_B` to a single `T` via `T_kin = T_ent` is FALSE in
  general — there exist admissible inputs with `T_kin ≠ T_ent`.

Both halves are pure real-arithmetic facts; no MIP opaque is committed to
(`κ, |K|, Z, ⟨Φ̇²⟩, N, |B|` enter as abstract positive reals).

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace ThermoTempEntropy

open Real

/-! ### Preserved half: the Boltzmann emergent-entropy identity -/

/-- **R.24b (preserved) — additive split of the Boltzmann emergent entropy.**

The analogy map preserves the entropy structure: for `κ > 0` and `K > 0`
the emergent entropy `S_B = log (κ · K²)` decomposes additively as
`log κ + 2 · log K` (F.2.1).  This is the relation that DOES carry over. -/
theorem R_24b_entropy_split
    (κ K : ℝ) (hκ : 0 < κ) (hK : 0 < K) :
    Real.log (κ * K ^ 2) = Real.log κ + 2 * Real.log K := by
  have hK2 : (0 : ℝ) < K ^ 2 := by positivity
  rw [Real.log_mul (ne_of_gt hκ) (ne_of_gt hK2), Real.log_pow]
  push_cast
  ring

/-- **R.24b (preserved) — entropy monotone in the combinatorial closure `κ`.**

With `|K|` held fixed, the emergent entropy `S_B = log(κ·K²)` is strictly
increasing in `κ`: raising the combinatorial closure raises the entropy
(the "phase-space volume grows" reading of F.2). -/
theorem R_24b_entropy_mono_kappa
    (κ₁ κ₂ K : ℝ) (hκ₁ : 0 < κ₁) (hK : 0 < K) (h : κ₁ < κ₂) :
    Real.log (κ₁ * K ^ 2) < Real.log (κ₂ * K ^ 2) := by
  have hK2 : (0 : ℝ) < K ^ 2 := by positivity
  have h1 : (0 : ℝ) < κ₁ * K ^ 2 := by positivity
  have hlt : κ₁ * K ^ 2 < κ₂ * K ^ 2 :=
    mul_lt_mul_of_pos_right h hK2
  exact Real.log_lt_log h1 hlt

/-- **R.24b (preserved) — entropy monotone in the knowledge size `|K|`.**

With `κ` held fixed, `S_B = log(κ·K²)` is strictly increasing in `K`. -/
theorem R_24b_entropy_mono_K
    (κ K₁ K₂ : ℝ) (hκ : 0 < κ) (hK₁ : 0 < K₁) (h : K₁ < K₂) :
    Real.log (κ * K₁ ^ 2) < Real.log (κ * K₂ ^ 2) := by
  have h1 : (0 : ℝ) < κ * K₁ ^ 2 := by positivity
  have hsq : K₁ ^ 2 < K₂ ^ 2 := by nlinarith
  have hlt : κ * K₁ ^ 2 < κ * K₂ ^ 2 := by
    have := mul_lt_mul_of_pos_left hsq hκ
    linarith
  exact Real.log_lt_log h1 hlt

/-! ### Non-preserved half: the Clausius / single-temperature structure fails

The framework carries two temperatures (appendix F dual-canonical table):

* `T_kin := Z · ⟨Φ̇²⟩`   (kinetic / microcanonical),
* `T_ent := N / |B|`     (entropic / grand-canonical).

A Clausius law `dS = dQ/T` presupposes ONE temperature.  We record the
obstruction: there is no algebraic identity forcing `T_kin = T_ent`, hence
no single-`T` thermodynamic relation can be structure-preserving in general.
-/

/-- **R.24b (non-preservation) — the two temperatures need not coincide.**

There exist admissible positive inputs `(Z, sq, N, B)` with
`T_kin := Z * sq` and `T_ent := N / B` for which `T_kin ≠ T_ent`.  Since a
Clausius relation `dS = dQ/T` requires a single temperature, this witnesses
that the temperature-entropy structure is NOT preserved by the analogy
(in contrast to the preserved entropy split above). -/
theorem R_24b_temperatures_distinct :
    ∃ (Z sq N B : ℝ), 0 < Z ∧ 0 < sq ∧ 0 < N ∧ 0 < B ∧
      Z * sq ≠ N / B := by
  -- T_kin = 1·1 = 1,  T_ent = 1/1 = 1 ... pick instead T_ent = 4/1 = 4.
  refine ⟨1, 1, 4, 1, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · norm_num
  · norm_num
  · norm_num

/-- **R.24b (non-preservation, contrapositive form) — no single-`T` Clausius
identity is universal.**

Stated as a refutation: the proposition "for all admissible inputs the
kinetic and entropic temperatures agree" is FALSE.  Any would-be Clausius
law `dS = dQ/T` that fixes a single `T` therefore cannot hold across the
framework — exactly the structure R.24b reports as not preserved. -/
theorem R_24b_no_universal_single_temperature :
    ¬ (∀ (Z sq N B : ℝ), 0 < Z → 0 < sq → 0 < N → 0 < B →
        Z * sq = N / B) := by
  intro hAll
  obtain ⟨Z, sq, N, B, hZ, hsq, hN, hB, hne⟩ := R_24b_temperatures_distinct
  exact hne (hAll Z sq N B hZ hsq hN hB)

end ThermoTempEntropy

end MIP
