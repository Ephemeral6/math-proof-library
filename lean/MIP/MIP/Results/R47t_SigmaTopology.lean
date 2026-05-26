/-
Result R.47t — Topology of the sublevel set Σ₀(δ) (weak form A).

Reference: `C:/Users/12729/Desktop/MIP/proofs/derived/A_grade.md`
R.47t (A 弱; deps C.6, A.1; 2026 derived branch).

**Statement (weak form).** The `N = 0` sublevel set

    Σ₀(δ)  :=  { A : Φ₀(A) ≤ δ }

(where `Φ₀(A) = -log Pr(A)` is the emergence free-energy, a continuous
function of the system `A` by A.1) enjoys the topological properties:

* **(P2) Closedness.** `Σ₀(δ)` is a closed set: it is the sublevel set
  `{x : Φ₀ x ≤ δ}` of the continuous function `Φ₀`.
* **(P1) Monotone expansion.** `δ₁ ≤ δ₂ ⟹ Σ₀(δ₁) ⊆ Σ₀(δ₂)`: relaxing the
  threshold can only enlarge the admissible set.
* **(P3) Training monotonicity.** Along the training trajectory the
  thresholds satisfy `δ_t ≤ δ_{t+1}` (flywheel, T.5), hence
  `Σ₀(δ_t) ⊆ Σ₀(δ_{t+1})` — the admissible set grows monotonically.
  This is an immediate corollary of (P1).

We model the system space `X` as an arbitrary topological space and take
`Φ₀ : X → ℝ` continuous as the bundled hypothesis (the A.1 fact that
`Φ₀ = -log Pr` is continuous in the system parameters).  `(P2)` follows
from `isClosed_le` + `continuous_const`; `(P1)/(P3)` are order facts on the
threshold.

**This file is `axiom`-free.**  Continuity of `Φ₀` enters as an explicit
hypothesis; everything else is derived.
-/
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Order.Basic

namespace MIP

namespace SigmaTopology

variable {X : Type*}

/-- The `N = 0` sublevel set `Σ₀(δ) = { A : Φ₀(A) ≤ δ }`. -/
def Sigma0 (Φ₀ : X → ℝ) (δ : ℝ) : Set X :=
  {x | Φ₀ x ≤ δ}

/-- **R.47t (P2) — `Σ₀(δ)` is closed.**

The sublevel set of the continuous emergence free-energy `Φ₀` is a closed
subset of system space.  (Continuity of `Φ₀` is the A.1 bundled
hypothesis.) -/
theorem R_47t_P2_isClosed [TopologicalSpace X]
    (Φ₀ : X → ℝ) (hΦ : Continuous Φ₀) (δ : ℝ) :
    IsClosed (Sigma0 Φ₀ δ) :=
  isClosed_le hΦ continuous_const

/-- **R.47t (P1) — monotone expansion in the threshold.**

Relaxing `δ` enlarges the sublevel set: `δ₁ ≤ δ₂ ⟹ Σ₀(δ₁) ⊆ Σ₀(δ₂)`. -/
theorem R_47t_P1_monotone
    (Φ₀ : X → ℝ) {δ₁ δ₂ : ℝ} (h : δ₁ ≤ δ₂) :
    Sigma0 Φ₀ δ₁ ⊆ Sigma0 Φ₀ δ₂ := by
  intro x hx
  -- hx : Φ₀ x ≤ δ₁, goal : Φ₀ x ≤ δ₂
  exact le_trans hx h

/-- **R.47t (P1) — as a `Monotone` statement** for the indexed family
`δ ↦ Σ₀(δ)`. -/
theorem R_47t_P1_monotone_family (Φ₀ : X → ℝ) :
    Monotone (Sigma0 Φ₀) :=
  fun _ _ h => R_47t_P1_monotone Φ₀ h

/-- **R.47t (P3) — training monotonicity.**

If the training trajectory's thresholds are non-decreasing
(`δ_t ≤ δ_{t+1}`, the flywheel hypothesis T.5), then the admissible set
grows monotonically along training: `Σ₀(δ_t) ⊆ Σ₀(δ_{t+1})`.  Direct
corollary of (P1). -/
theorem R_47t_P3_training_monotone
    (Φ₀ : X → ℝ) (δ : ℕ → ℝ) (h_flywheel : ∀ t, δ t ≤ δ (t + 1)) (t : ℕ) :
    Sigma0 Φ₀ (δ t) ⊆ Sigma0 Φ₀ (δ (t + 1)) :=
  R_47t_P1_monotone Φ₀ (h_flywheel t)

/-- **R.47t (P3) — chained training monotonicity.**

For any `s ≤ t` along a non-decreasing-threshold trajectory,
`Σ₀(δ_s) ⊆ Σ₀(δ_t)`. -/
theorem R_47t_P3_training_monotone_le
    (Φ₀ : X → ℝ) (δ : ℕ → ℝ) (h_mono : Monotone δ) {s t : ℕ} (hst : s ≤ t) :
    Sigma0 Φ₀ (δ s) ⊆ Sigma0 Φ₀ (δ t) :=
  R_47t_P1_monotone Φ₀ (h_mono hst)

/-- **R.47t — combined topological characterisation.**

The sublevel set family `δ ↦ Σ₀(δ)` of a continuous emergence
free-energy `Φ₀` is closed at every level and monotone in the threshold. -/
theorem R_47t_topology [TopologicalSpace X]
    (Φ₀ : X → ℝ) (hΦ : Continuous Φ₀) :
    (∀ δ, IsClosed (Sigma0 Φ₀ δ)) ∧ Monotone (Sigma0 Φ₀) :=
  ⟨fun δ => R_47t_P2_isClosed Φ₀ hΦ δ, R_47t_P1_monotone_family Φ₀⟩

end SigmaTopology

end MIP
