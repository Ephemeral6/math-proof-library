/-
Result R.139 — Three-layer collaboration-savings conservation law.

Reference: `branches/duality/workspace/new_results.md` R.139 (A 无条件,
2026-05-16 duality branch).

**Statement.** Let
* `N_self_A := Φ₀(A,p) · Z_q(A | A)` — A's self-aid emergence cost,
* `N_self_H := Φ₀(H,p) · Z_q(H | H)` — H's self-aid emergence cost,
* `N`        := `N(p, A, H)`         — H guides A,
* `N_star`   := `N(p, H, A)`         — A guides H,
* `N_bi`     := `N_bi(p, A, H)`      — bidirectional optimal,
* `Asym`     := `Asym(p, A, H)`      — cognitive asymmetry,
* `δ_AH`     := `N_self_A − N`,      `δ_HA := N_self_H − N_star`
  — external-aid gaps from R.138,
* `σ`        := `δ_AH + δ_HA`        — total collaboration savings.

Then under the algebraic premises **(R.138)** `N_self_A = N + δ_AH`,
`N_self_H = N_star + δ_HA`, and **(R.132)** `N + N_star = 2 N_bi + Asym`,

    N_self_A + N_self_H = 2 N_bi + Asym + σ .

**Proof.** Pure algebra — add the two R.138 identities, then substitute
R.132 on the right.

**This file is `axiom`-free.**  It states R.139 as a self-contained
algebraic theorem on real-valued inputs, with R.132 and R.138 entering
as explicit hypotheses (matching the MIP-side dependence).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace CollaborationSavings

/-- **R.139 — pure-algebra core.**

Three-layer conservation law: the sum of self-aid costs decomposes as
`2 N_bi + Asym + σ`, given R.138 (per-side gap) and R.132 (role
conservation). -/
theorem R_139_conservation_core
    (N_self_A N_self_H N N_star N_bi Asym δ_AH δ_HA σ : ℝ)
    (h_R138_A : N_self_A = N + δ_AH)
    (h_R138_H : N_self_H = N_star + δ_HA)
    (h_R132   : N + N_star = 2 * N_bi + Asym)
    (h_σ_def  : σ = δ_AH + δ_HA) :
    N_self_A + N_self_H = 2 * N_bi + Asym + σ := by
  rw [h_R138_A, h_R138_H]
  -- Goal: (N + δ_AH) + (N_star + δ_HA) = 2 N_bi + Asym + σ
  -- Re-associate to expose N + N_star and δ_AH + δ_HA.
  have : (N + δ_AH) + (N_star + δ_HA) = (N + N_star) + (δ_AH + δ_HA) := by ring
  rw [this, h_R132, h_σ_def]

/-- **R.139.a (collaboration-savings non-negativity).**

`σ ≥ 0` whenever both per-side gaps `δ_AH, δ_HA` are non-negative
(R.138 monotonicity: `Z_q(X|Y) ≤ Z_q(X|X)`, the "outside aid never
harms" property from D.3.9). -/
theorem R_139_a_savings_nonneg
    (δ_AH δ_HA σ : ℝ)
    (h_σ_def : σ = δ_AH + δ_HA)
    (h_δ_AH_nonneg : 0 ≤ δ_AH) (h_δ_HA_nonneg : 0 ≤ δ_HA) :
    0 ≤ σ := by
  rw [h_σ_def]; linarith

/-- **R.139.c (collaboration-value identity).**

Under `N_self_A + N_self_H > 0` (well-definedness), the "collaboration
value" `V := σ / (N_self_A + N_self_H)` satisfies the closed-form
`V = 1 - (2 N_bi + Asym) / (N_self_A + N_self_H)`. -/
theorem R_139_c_value_identity
    (N_self_A N_self_H N_bi Asym σ : ℝ)
    (h_R139 : N_self_A + N_self_H = 2 * N_bi + Asym + σ)
    (h_pos : 0 < N_self_A + N_self_H) :
    σ / (N_self_A + N_self_H) = 1 - (2 * N_bi + Asym) / (N_self_A + N_self_H) := by
  have hne : N_self_A + N_self_H ≠ 0 := ne_of_gt h_pos
  have hσ : σ = (N_self_A + N_self_H) - (2 * N_bi + Asym) := by linarith
  rw [hσ, sub_div, div_self hne]

end CollaborationSavings

end MIP
