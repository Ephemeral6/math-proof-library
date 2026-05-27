/-
Result R.819 — Post-training isolated expert injection dilutes κ.
Reference: branches/collaboration_dynamics/results/intervention_effects.md (A-grade, audited 2026-05-27).

**Statement.**
- (a) In-dialogue: by R.815, an expert intervention does not change `K(X)`, hence does not
  change the static `κ(X)`.
- (b) Post-training (TM family): adding `Δn` new knowledge elements with net new co-occurrence
  pairs `δ`, the new density satisfies `κ(X') < κ(X)  ⟺  δ < κ(X)·Δn·(2n + Δn)`, where
  `n = |K|`.  Isolated injection contributes only the reflexive diagonal `δ = Δn`
  (D.3.7 reflexivity gives `(ω,ω)` only — `+1` per element, no cross pairs), so dilution holds
  `⟺ κ(X) > 1/(2n + Δn)` — a non-trivial knowledge base is almost always diluted.

**Kernel formalized here (pure ℝ/ℕ algebra).**
Densities `κ = c / n²` (so co-occurrence count `c = κ·n²`) and `κ' = (c + δ) / (n + Δn)²`.
1. *Threshold equivalence.*  For `n, Δn > 0`: `κ' < κ  ⟺  δ < κ·Δn·(2n + Δn)`.  Proved by
   clearing denominators (`div_lt_div_iff`) and `ring`/`nlinarith`.
2. *Isolated-injection corollary.*  With `δ = Δn` (diagonal only): `κ' < κ  ⟺  κ > 1/(2n+Δn)`,
   i.e. any base with `κ > 1/(2n+Δn)` is strictly diluted by isolated expert injection.
3. *Boundary (full integration).*  `δ = 2n·Δn + Δn = Δn·(2n+1)` for `Δn=1` (the
   "fully-integrated" element co-occurring with all `n` old elements both directions plus its
   diagonal) sits exactly at / above threshold: no dilution.  We record the `Δn = 1` boundary
   `δ = 2n + 1` giving `κ' ≥ κ` for `κ ≤ 1` (audit's `+2n+1` clarification).

**Bridge.** This is the verbatim density algebra `n²(c+δ) < c(n+Δn)² ⟺ δ < κΔn(2n+Δn)`
(intervention_effects.md R.819 proof step (b)).
Axiom-free (only A.1–A.4; this file needs none — pure real arithmetic).
-/
import MIP.Axioms
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace R819_ExpertDilution

/-! ## Part 1 — Dilution threshold equivalence

`κ = c/n²`, `κ' = (c+δ)/(n+Δn)²`.  Then `κ' < κ ⟺ δ < κ·Δn·(2n+Δn)`. -/

/-- **R.819 (threshold equivalence).**  Let `n > 0`, `Δn > 0`, co-occurrence count `c`,
density `κ := c / n²`, new pairs `δ`, and new density `κ' := (c + δ) / (n + Δn)²`.  Then
the new density is strictly smaller iff `δ` is below the dilution threshold:

    κ' < κ   ⟺   δ < κ · Δn · (2·n + Δn). -/
theorem R_819_dilution_threshold
    (n Δn c δ : ℝ) (hn : 0 < n) (hΔn : 0 < Δn)
    (κ κ' : ℝ) (hκ : κ = c / n ^ 2)
    (hκ' : κ' = (c + δ) / (n + Δn) ^ 2) :
    κ' < κ ↔ δ < κ * Δn * (2 * n + Δn) := by
  have hn2 : (0 : ℝ) < n ^ 2 := by positivity
  have hnΔ : (0 : ℝ) < (n + Δn) ^ 2 := by positivity
  -- `c = κ · n²` from `κ = c / n²`.
  have hc : c = κ * n ^ 2 := by
    rw [hκ]; field_simp
  subst hκ'
  -- `κ' < κ  ↔  c + δ < κ · (n + Δn)²`.
  rw [div_lt_iff₀ hnΔ]
  constructor
  · intro h
    nlinarith [h, hc]
  · intro h
    nlinarith [h, hc]

/-! ## Part 2 — Isolated injection corollary

Isolated injection: each new element contributes only its reflexive diagonal pair (D.3.7
reflexivity, audit clarification: `+1` per element, no cross pairs), so `δ = Δn`.  Then
dilution holds iff `κ > 1/(2n + Δn)`. -/

/-- **R.819 (isolated-injection dilution).**  With diagonal-only injection `δ = Δn`, the
density strictly drops iff `κ > 1/(2n + Δn)`: any non-trivial knowledge base is diluted. -/
theorem R_819_isolated_injection
    (n Δn c : ℝ) (hn : 0 < n) (hΔn : 0 < Δn)
    (κ κ' : ℝ) (hκ : κ = c / n ^ 2)
    (hκ' : κ' = (c + Δn) / (n + Δn) ^ 2) :
    κ' < κ ↔ κ > 1 / (2 * n + Δn) := by
  have hbase := R_819_dilution_threshold n Δn c Δn hn hΔn κ κ' hκ hκ'
  rw [hbase]
  have hpos : (0 : ℝ) < 2 * n + Δn := by linarith
  constructor
  · intro h
    -- Δn < κ·Δn·(2n+Δn)  ⟹  1 < κ·(2n+Δn)  (divide by Δn>0)  ⟹  κ > 1/(2n+Δn)
    rw [gt_iff_lt, div_lt_iff₀ hpos]
    have hkey : Δn * 1 < Δn * (κ * (2 * n + Δn)) := by nlinarith [h]
    have h2 : (1 : ℝ) < κ * (2 * n + Δn) := lt_of_mul_lt_mul_left hkey (le_of_lt hΔn)
    linarith
  · intro h
    rw [gt_iff_lt, div_lt_iff₀ hpos] at h
    nlinarith [h]

/-! ## Part 3 — Full-integration boundary (audit `+2n+1` clarification)

When a single new element (`Δn = 1`) co-occurs with all `n` old elements bidirectionally plus
its own diagonal, it contributes `δ = 2n + 1`.  At this value the new density does NOT drop
(for `κ ≤ 1`): this is the no-dilution boundary the audit contrasted with isolated `+1`. -/

/-- **R.819 (full-integration boundary, `Δn = 1`).**  With `δ = 2n + 1` (full bidirectional
integration of one new element with all `n` old ones plus its diagonal) and `κ ≤ 1`, the new
density does not strictly drop: `¬ (κ' < κ)`, i.e. no dilution.  This is the audit's `+2n+1`
clarification distinguishing isolated injection (`δ = 1`, dilutes) from full integration. -/
theorem R_819_full_integration_no_dilution
    (n c : ℝ) (hn : 0 < n)
    (κ κ' : ℝ) (hκ : κ = c / n ^ 2) (hκle : κ ≤ 1)
    (hκ' : κ' = (c + (2 * n + 1)) / (n + 1) ^ 2) :
    ¬ (κ' < κ) := by
  have hbase := R_819_dilution_threshold n 1 c (2 * n + 1) hn (by norm_num) κ κ'
    hκ hκ'
  rw [hbase, not_lt]
  -- threshold value: κ·1·(2n+1) = κ·(2n+1) ≤ 2n+1 since κ ≤ 1 and 2n+1 > 0.
  have hpos : (0 : ℝ) < 2 * n + 1 := by linarith
  nlinarith [mul_le_of_le_one_left (le_of_lt hpos) hκle]

end R819_ExpertDilution

end MIP
