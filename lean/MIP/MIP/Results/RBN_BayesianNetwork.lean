/-
Results R.BN-1..6 — MIP-BN: MIP as a Pearl Bayesian network.

Reference: `workspace/round3_exploration/slot_044.md` and
`work_slot_044.md` (direction 7, MIP-BN: σ* sequence as a Pearl-style
Bayesian network; chain-rule Fano lower bound on N; Information
Bottleneck Lagrangian β-family for the σ* policy).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statements.** Recasting the D.1.6 σ* intervention sequence as a Pearl
Bayesian network on the variables `(S_0, M_i, S_i, R_i, Y)` exposes a
chain-of-mutual-information structure.  Treating Shannon entropy and
mutual information as bundled real-valued functionals (RSUB13 KL style),
the information-theoretic results become elementary inequalities:

* **L.BN-2 (chain-rule conservation).** Total predictive information
  decomposes additively over the `n` steps:
      I(Y; M,R) = Σ_{i=1}^n I_step,i,    I_step,i ≥ 0.

* **R.BN-2 (chain-rule Fano N lower bound, flagship).** Under the D.1.8
  fault tolerance `δ`, Fano + data-processing give
  `I(Y; M,R) ≥ H(Y) − h₂(δ) − δ·log(|𝒴|−1)`; combined with the chain
  rule and the per-step cap `I_step,i ≤ I_max`, the number of steps `N`
  satisfies
      N ≥ (H(Y) − h₂(δ) − δ·log(|𝒴|−1)) / I_max
  (binary decision `|𝒴| = 2` kills the last term).  This complements the
  R.480 μ-Fano bound and is generally tighter (per-step `I` ≪ log|M|).

* **R.BN-3 (state-MI monotone descent).** Data-processing + chain rule:
      I(S_i; Y) ≤ I(S_{i-1}; Y) + I(M_i; Y | S_{i-1}),
  the information-theoretic dual of the D.4.10 `ΔΦ` step gain.

* **R.BN-4/5 (IB Lagrangian β-family).** With
  `L_IB(β) := I(M;S) − β·I(M;Y)` (Tishby Information Bottleneck), `L_IB`
  is antitone in `β` (each larger multiplier on the nonnegative
  predictive term only lowers `L_IB`), and the dominant cooperation cost
  `N(β)` is monotone non-increasing in `β`, with the optimal value of
  `L_IB` itself antitone.

**This file is `axiom`-free** and imports only Mathlib.  Fano's
inequality, the data-processing inequality, and the chain rule for
mutual information enter as explicit hypotheses (HYPOTHESIS-BUNDLE);
entropy and mutual information are bundled real-valued inputs, matching
the standard-Shannon dependence noted in the source.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

open scoped BigOperators

namespace MIPBayesNet

/-! ## L.BN-2 — chain-rule conservation of predictive information

The total mutual information between the answer `Y` and the full
intervention-response transcript equals the sum of per-step conditional
mutual informations.  Each step term is nonnegative (Shannon). -/

/-- **L.BN-2 — chain-rule conservation.**

`I_total` (the joint predictive info `I(Y; M,R)`) equals the sum of the
per-step terms `I_step i`, and each per-step term is nonnegative. -/
theorem L_BN_2_chain_rule {ι : Type*} (steps : Finset ι)
    (I_step : ι → ℝ) (I_total : ℝ)
    (h_chain : I_total = ∑ i ∈ steps, I_step i)
    (h_nonneg : ∀ i ∈ steps, 0 ≤ I_step i) :
    I_total = ∑ i ∈ steps, I_step i ∧ 0 ≤ I_total := by
  refine ⟨h_chain, ?_⟩
  rw [h_chain]
  exact Finset.sum_nonneg h_nonneg

/-! ## R.BN-2 — chain-rule Fano lower bound on N

Bundle the three standard Shannon facts as hypotheses:
* Fano:  `H(Y | Ŷ) ≤ h₂(δ) + δ·log(|𝒴|−1)`;
* DPI:   `H(Y | M,R) ≤ H(Y | Ŷ)`  (`Ŷ` is a function of `(M,R)`);
* MI def: `I(Y; M,R) = H(Y) − H(Y | M,R)`.
From these we get `I(Y; M,R) ≥ H(Y) − h₂(δ) − δ·log(|𝒴|−1)`, and then the
chain rule + per-step cap give the lower bound on `N`. -/

/-- **R.BN-2 step 1 — predictive-info lower bound from Fano + DPI.**

Combining Fano (`H_Y_given_pred ≤ h₂ + δlog`), the data-processing
inequality (`H_Y_given_MR ≤ H_Y_given_pred`), and the mutual-information
identity, the total predictive information is bounded below:
    I(Y; M,R) ≥ H(Y) − h₂(δ) − δ·log(|𝒴|−1). -/
theorem R_BN_2_predictive_info_lb
    (H_Y H_Y_given_MR H_Y_given_pred h2 δlog I_total : ℝ)
    (h_fano : H_Y_given_pred ≤ h2 + δlog)
    (h_dpi : H_Y_given_MR ≤ H_Y_given_pred)
    (h_mi : I_total = H_Y - H_Y_given_MR) :
    H_Y - h2 - δlog ≤ I_total := by
  rw [h_mi]
  linarith

/-- **R.BN-2 — chain-rule Fano lower bound on N (flagship).**

With:
* the predictive-info lower bound `H_Y − h₂ − δlog ≤ I_total`
  (from `R_BN_2_predictive_info_lb`),
* the chain rule `I_total = ∑ I_step i`,
* the per-step cap `I_step i ≤ I_max` on a transcript of `N := steps.card`
  steps,
* `0 < I_max`,
the step count `N` satisfies
    N ≥ (H(Y) − h₂(δ) − δ·log(|𝒴|−1)) / I_max. -/
theorem R_BN_2_chain_fano_lb {ι : Type*} (steps : Finset ι)
    (I_step : ι → ℝ) (I_total H_Y h2 δlog I_max : ℝ)
    (h_lb : H_Y - h2 - δlog ≤ I_total)
    (h_chain : I_total = ∑ i ∈ steps, I_step i)
    (h_cap : ∀ i ∈ steps, I_step i ≤ I_max)
    (h_Imax_pos : 0 < I_max) :
    (H_Y - h2 - δlog) / I_max ≤ (steps.card : ℝ) := by
  -- I_total ≤ N · I_max
  have h_sum_le : ∑ i ∈ steps, I_step i ≤ ∑ _i ∈ steps, I_max :=
    Finset.sum_le_sum h_cap
  have h_const : ∑ _i ∈ steps, I_max = (steps.card : ℝ) * I_max := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have h_total_le : I_total ≤ (steps.card : ℝ) * I_max := by
    rw [h_chain]; rw [h_const] at h_sum_le; exact h_sum_le
  -- chain: (H_Y − h2 − δlog) ≤ N · I_max
  have h_num_le : H_Y - h2 - δlog ≤ (steps.card : ℝ) * I_max :=
    le_trans h_lb h_total_le
  -- divide by I_max > 0
  rw [div_le_iff₀ h_Imax_pos]
  exact h_num_le

/-- **R.BN-2 (binary specialization).**

For a binary decision `|𝒴| = 2` the `δlog` term vanishes (`log(|𝒴|−1) =
log 1 = 0`), giving the clean bound `N ≥ (H(Y) − h₂(δ)) / I_max`. -/
theorem R_BN_2_chain_fano_lb_binary {ι : Type*} (steps : Finset ι)
    (I_step : ι → ℝ) (I_total H_Y h2 I_max : ℝ)
    (h_lb : H_Y - h2 ≤ I_total)
    (h_chain : I_total = ∑ i ∈ steps, I_step i)
    (h_cap : ∀ i ∈ steps, I_step i ≤ I_max)
    (h_Imax_pos : 0 < I_max) :
    (H_Y - h2) / I_max ≤ (steps.card : ℝ) := by
  have h_lb' : H_Y - h2 - 0 ≤ I_total := by linarith
  have := R_BN_2_chain_fano_lb steps I_step I_total H_Y h2 0 I_max
    h_lb' h_chain h_cap h_Imax_pos
  simpa using this

/-! ## R.BN-3 — state-mutual-information monotone descent

Data-processing inequality (`S_i` is generated from `(S_{i-1}, M_i)` via
the intervention kernel `T`) plus the chain rule for mutual information
give the per-step monotone descent bound. -/

/-- **R.BN-3 — state-MI monotone descent.**

Bundle:
* the chain-rule identity `I(S_{i-1}, M_i; Y) = I(S_{i-1};Y) + I(M_i;Y|S_{i-1})`,
* the data-processing inequality `I(S_i;Y) ≤ I(S_{i-1}, M_i; Y)`
  (`S_i` is a stochastic function of `(S_{i-1}, M_i)`).
Then
    I(S_i; Y) ≤ I(S_{i-1}; Y) + I(M_i; Y | S_{i-1}). -/
theorem R_BN_3_state_mi_descent
    (I_Si_Y I_Sim1_Mi_Y I_Sim1_Y I_Mi_Y_given_Sim1 : ℝ)
    (h_chain : I_Sim1_Mi_Y = I_Sim1_Y + I_Mi_Y_given_Sim1)
    (h_dpi : I_Si_Y ≤ I_Sim1_Mi_Y) :
    I_Si_Y ≤ I_Sim1_Y + I_Mi_Y_given_Sim1 := by
  rw [← h_chain]; exact h_dpi

/-! ## R.BN-4 / R.BN-5 — Information Bottleneck Lagrangian β-family

`L_IB(β) := I(M;S) − β·I(M;Y)` (Tishby-Pereira-Bialek).  With the
predictive term `I(M;Y) ≥ 0`, increasing `β` can only decrease `L_IB`
(antitone in β), and the dominant cooperation cost `N(β)` is monotone
non-increasing.  These are the crisp order properties of the β-family. -/

/-- The IB Lagrangian `L_IB(β) = I(M;S) − β·I(M;Y)`. -/
def L_IB (I_MS I_MY β : ℝ) : ℝ := I_MS - β * I_MY

/-- **R.BN-4 (trade-off identity).**

The IB Lagrangian splits exactly into the compression term `I(M;S)`
minus `β` times the predictive term `I(M;Y)`. -/
theorem R_BN_4_lagrangian_def (I_MS I_MY β : ℝ) :
    L_IB I_MS I_MY β = I_MS - β * I_MY := rfl

/-- **R.BN-4 (antitone in β).**

For fixed information values with `I(M;Y) ≥ 0`, the Lagrangian `L_IB` is
non-increasing in the multiplier `β`: `β₁ ≤ β₂ ⟹ L_IB(β₂) ≤ L_IB(β₁)`.
(Larger weight on the nonnegative predictive term only lowers `L_IB`.) -/
theorem R_BN_4_antitone_in_beta
    (I_MS I_MY β₁ β₂ : ℝ)
    (h_MY_nonneg : 0 ≤ I_MY) (h_β : β₁ ≤ β₂) :
    L_IB I_MS I_MY β₂ ≤ L_IB I_MS I_MY β₁ := by
  unfold L_IB
  have : β₁ * I_MY ≤ β₂ * I_MY :=
    mul_le_mul_of_nonneg_right h_β h_MY_nonneg
  linarith

/-- **R.BN-4 (strict decrease with strictly informative interventions).**

If the interventions are strictly predictive (`I(M;Y) > 0`) and the
multiplier strictly increases, the Lagrangian strictly decreases. -/
theorem R_BN_4_strict_antitone
    (I_MS I_MY β₁ β₂ : ℝ)
    (h_MY_pos : 0 < I_MY) (h_β : β₁ < β₂) :
    L_IB I_MS I_MY β₂ < L_IB I_MS I_MY β₁ := by
  unfold L_IB
  have : β₁ * I_MY < β₂ * I_MY :=
    mul_lt_mul_of_pos_right h_β h_MY_pos
  linarith

/-- **R.BN-5 (dominant cooperation cost is monotone non-increasing).**

`N(β)` is the expected step count under the β-optimal policy `σ*_β`.
Bundle its monotonicity as the hypothesis `h_mono` (higher cooperation
temperature `β` favors more task-focused, hence shorter, transcripts).
This theorem records the order endpoints: for `β₁ ≤ β₂`,
`N(β₂) ≤ N(β₁)`, and the boundary values bracket `N(β)` between `0` and
the D.1.6 cost `N_inf`. -/
theorem R_BN_5_N_beta_antitone
    (N : ℝ → ℝ) (N_inf : ℝ)
    (h_mono : ∀ β₁ β₂, β₁ ≤ β₂ → N β₂ ≤ N β₁)
    (h_zero_limit : ∀ β, 0 ≤ N β)
    (h_sup : ∀ β, N β ≤ N_inf)
    (β₁ β₂ : ℝ) (h_β : β₁ ≤ β₂) :
    N β₂ ≤ N β₁ ∧ 0 ≤ N β₂ ∧ N β₂ ≤ N_inf :=
  ⟨h_mono β₁ β₂ h_β, h_zero_limit β₂, h_sup β₂⟩

/-- **R.BN-5 (optimal Lagrangian value is antitone in β).**

Let `Lopt β := min_σ L_IB(σ, β)` be the optimal IB value at temperature
`β`, bundled as `Lopt` with a per-`β` minimizer `σ` whose information
values `I_MS, I_MY` satisfy `I_MY ≥ 0`.  Bundling the optimality
hypotheses, `Lopt` is antitone in `β`: a higher `β` re-weights the same
feasible policies toward lower Lagrangian value, so `β₁ ≤ β₂ ⟹ Lopt β₂ ≤
Lopt β₁`. -/
theorem R_BN_5_Lopt_antitone
    (Lopt : ℝ → ℝ) (I_MS I_MY : ℝ → ℝ)
    (h_MY_nonneg : ∀ β, 0 ≤ I_MY β)
    (h_opt : ∀ β, Lopt β = L_IB (I_MS β) (I_MY β) β)
    (h_feasible : ∀ β β', Lopt β ≤ L_IB (I_MS β') (I_MY β') β)
    (β₁ β₂ : ℝ) (h_β : β₁ ≤ β₂) :
    Lopt β₂ ≤ Lopt β₁ := by
  -- Evaluate the β₁-optimal policy at the larger temperature β₂.
  -- By antitonicity of L_IB in β (R.BN-4) on that fixed policy:
  --   L_IB(σ_{β₁}, β₂) ≤ L_IB(σ_{β₁}, β₁) = Lopt β₁.
  -- And Lopt β₂ ≤ L_IB(σ_{β₁}, β₂) by feasibility (β₂-min ≤ any value).
  have h1 : Lopt β₂ ≤ L_IB (I_MS β₁) (I_MY β₁) β₂ := h_feasible β₂ β₁
  have h2 : L_IB (I_MS β₁) (I_MY β₁) β₂ ≤ L_IB (I_MS β₁) (I_MY β₁) β₁ :=
    R_BN_4_antitone_in_beta (I_MS β₁) (I_MY β₁) β₁ β₂ (h_MY_nonneg β₁) h_β
  have h3 : L_IB (I_MS β₁) (I_MY β₁) β₁ = Lopt β₁ := (h_opt β₁).symm
  linarith

end MIPBayesNet

end MIP
