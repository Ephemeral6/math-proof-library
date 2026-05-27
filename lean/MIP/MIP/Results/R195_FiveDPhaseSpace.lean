/-
Result R.195 — Phase-space extension to 5D.
Reference: `branches/decay/workspace/new_results.md` (old decay R.156).

**Statement.** The 4D phase space `S(X) = (|K|, Z⁻¹, H_K, κ) ∈ ℝ≥0⁴`
(R.30) extends, under knowledge decay, to a 5D space

    S₅(X) = (|K|, Z⁻¹, H_K, κ, τ̄) ∈ ℝ≥0⁵ ,

with the mean half-life `τ̄(X)` as a genuinely new axis.  The decay axis is
**independent**: `τ̄` is not a function of `(|K|, Z⁻¹, H_K, κ)` — two agents
can share all four base coordinates yet differ in `τ̄` (one deeply trained,
forgetting < 10%/week; one shallow, > 50%/week), giving different
`N_decay` (R.190).

**Kernel formalized here.** The R.92-style functional-independence result
(orthogonality / projection kernel):
  (1) a `PhasePoint5` coordinate tuple with the projection onto the base 4D;
  (2) two explicit witnesses agreeing on `(|K|,Z⁻¹,H_K,κ)` but with
      distinct `τ̄`, so the base-4 projection is non-injective in `τ̄`;
  (3) hence no function `f : ℝ⁴ → ℝ` can recover `τ̄` from the base coords —
      `τ̄` is an independent dimension.

**Bridge.** `PhasePoint5` is `S₅(X)`; the two witnesses are the deep-vs-shallow
agents of R.156 step 1.  Mirrors `R92_SigmaZ_Xi_Orthogonality.lean`.
Axiom-free.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace FiveDPhaseSpace

/-- The 5D phase point `S₅(X) = (|K|, Z⁻¹, H_K, κ, τ̄)`. -/
structure PhasePoint5 where
  Kabs  : ℝ   -- |K|
  Zinv  : ℝ   -- Z⁻¹
  HK    : ℝ   -- H_K
  kappa : ℝ   -- κ
  tau   : ℝ   -- τ̄  (decay axis)

/-- Projection onto the base 4D coordinates `(|K|, Z⁻¹, H_K, κ)`. -/
def base4 (P : PhasePoint5) : ℝ × ℝ × ℝ × ℝ :=
  (P.Kabs, P.Zinv, P.HK, P.kappa)

/-- A "deep-training" agent: long half-life `τ̄ = 10`. -/
def deepAgent : PhasePoint5 :=
  { Kabs := 100, Zinv := 1, HK := 1, kappa := 1, tau := 10 }

/-- A "shallow-training" agent: same base 4D, short half-life `τ̄ = 1`. -/
def shallowAgent : PhasePoint5 :=
  { Kabs := 100, Zinv := 1, HK := 1, kappa := 1, tau := 1 }

/-- **R.195 — the two witnesses share the base-4D projection.** -/
theorem R_195_same_base4 : base4 deepAgent = base4 shallowAgent := rfl

/-- **R.195 — the two witnesses differ on the decay axis `τ̄`.** -/
theorem R_195_distinct_tau : deepAgent.tau ≠ shallowAgent.tau := by
  show (10 : ℝ) ≠ 1
  norm_num

/-- **R.195 — the base-4D projection is not injective.**

There exist two distinct phase points with identical base-4D projection.
The "extra information" distinguishing them lives precisely in `τ̄`. -/
theorem R_195_base4_not_injective :
    ∃ P Q : PhasePoint5, base4 P = base4 Q ∧ P ≠ Q := by
  refine ⟨deepAgent, shallowAgent, R_195_same_base4, ?_⟩
  intro h
  exact R_195_distinct_tau (congrArg PhasePoint5.tau h)

/-- **R.195 — `τ̄` is functionally independent of the base 4D.**

No function `f : ℝ⁴ → ℝ` can express the decay axis `τ̄` in terms of
`(|K|, Z⁻¹, H_K, κ)`: the two witnesses feed `f` the same input but
demand different outputs.  Hence the phase space must be genuinely 5D. -/
theorem R_195_tau_independent :
    ¬ ∃ f : ℝ × ℝ × ℝ × ℝ → ℝ, ∀ P : PhasePoint5, P.tau = f (base4 P) := by
  rintro ⟨f, hf⟩
  have h_deep : deepAgent.tau = f (base4 deepAgent) := hf deepAgent
  have h_shallow : shallowAgent.tau = f (base4 shallowAgent) := hf shallowAgent
  rw [R_195_same_base4] at h_deep
  -- both equal f (base4 shallowAgent), so τ̄ values coincide — contradiction.
  have : deepAgent.tau = shallowAgent.tau := by rw [h_deep, h_shallow]
  exact R_195_distinct_tau this

/-- **R.195 — `N_decay` strictly separates the two witnesses.**

Modelling the decay-cost dependence on `τ̄` by any strictly antitone
function `Ndec` (longer half-life ⇒ lower maintenance tax, R.190/R.194),
the deep agent strictly outperforms the shallow one despite identical
base coordinates — the operational consequence of the new axis. -/
theorem R_195_Ndecay_separates
    (Ndec : ℝ → ℝ)
    (h_anti : ∀ x y : ℝ, x < y → Ndec y < Ndec x) :
    Ndec deepAgent.tau < Ndec shallowAgent.tau := by
  apply h_anti
  show (1 : ℝ) < 10
  norm_num

end FiveDPhaseSpace

end MIP
