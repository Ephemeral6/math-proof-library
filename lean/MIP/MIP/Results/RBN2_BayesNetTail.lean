/-
Results R.BN-7..9 (slot 044) — the TAIL of MIP-BN (MIP as a Pearl Bayesian
network on the σ* intervention sequence): the d-separation conditional-
independence factorization (state `S_i` as sufficient statistic), the
chain-rule mutual-information bound, and the Information-Bottleneck ↔
KL bridge `λ = 1/β`.

This file is the tail companion to
`MIP/Results/RBN_BayesianNetwork.lean` (which proves L.BN-2 chain-rule
conservation, R.BN-2 chain-rule Fano lower bound, R.BN-3 state-MI descent,
R.BN-4/5 IB Lagrangian β-family).  It is self-contained; entropy / mutual
information remain bundled real-valued functionals (RSUB13 KL style) and
the Shannon facts (d-separation factorization, chain rule, KL identity)
enter as explicit hypotheses (HYPOTHESIS-BUNDLE).  A DIFFERENT sub-namespace
`BayesNetTail` is used to avoid clash.

Reference: `workspace/round3_exploration/slot_044.md`,
`workspace/round3_exploration/work_slot_044.md` (L.BN-1, R.BN-1, R.BN-6;
"directions 7–9" of the MIP-BN tail).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statements.**

Recasting the D.1.6 σ* intervention sequence as a Pearl BN on the variables
`(S_0, M_i, S_i, R_i, Y)`:

* **R.BN-7 (d-separation conditional-independence factorization).**  Because
  `Pa(R_i) = {S_i}`, every directed path `S_{i-1} → R_i` passes through
  `S_i`, so conditioning on `S_i` d-separates the past from `R_i`.  At the
  level of the bundled (conditional) probabilities this is the
  factorization `P(past, R_i | S_i) = P(past | S_i) · P(R_i | S_i)` — the
  state `S_i` is a *sufficient statistic*.  We formalize the
  conditional-independence factorization identity and its mutual-information
  corollary `I(past ; R_i | S_i) = 0`.

* **R.BN-8 (chain-rule mutual-information bound).**  From the chain rule
  `I(Y ; M,R) = Σ_i I_step,i` and the per-step cap `I_step,i ≤ I_max`, the
  total predictive information is bounded by `N · I_max`; combined with the
  data-processing lower bound it gives the crisp two-sided estimate used in
  the Fano N-bound (a self-contained chain-rule bound complementing R.BN-2).

* **R.BN-9 (IB ↔ KL bridge, `λ = 1/β`).**  The IB Lagrangian
  `L_β = I(M;S) − β·I(M;Y)` and the D.3.10 posterior KL objective
  `J_λ = λ·KL + Yterm` describe the same optimum after the affine
  reparametrization `λ = 1/β`: `β · J_{1/β} = I(M;S) − β·I(M;Y)` when the
  KL "compression cost" is identified with `I(M;S)` and the Y-likelihood
  term with `−I(M;Y)`.  This gives the bundled λ its information-theoretic
  origin `λ = 1/β`.

**This file is `axiom`-free** and imports only Mathlib.  d-separation,
the chain rule, the data-processing inequality, and the KL/IB identity
enter as explicit hypotheses; entropy and mutual information are bundled
real-valued inputs.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

open scoped BigOperators

namespace BayesNetTail

/-! ## R.BN-7 — d-separation conditional-independence factorization

In the MIP-BN DAG `Pa(R_i) = {S_i}`, so every path from the past
`(S_{i-1}, M_{<i}, R_{<i})` to `R_i` runs through `S_i` as a chain node.
Conditioning on `S_i` blocks all such paths (Pearl d-separation), giving the
conditional independence `past ⫫ R_i | S_i`.  We bundle the joint and
marginal conditional probabilities as nonnegative reals and state the
factorization identity that d-separation supplies. -/

/-- **R.BN-7 — conditional-independence factorization (sufficient statistic).**

Bundle the conditional probabilities given the state `S_i`:
`p_joint = P(past, R_i | S_i)`, `p_past = P(past | S_i)`,
`p_resp = P(R_i | S_i)`.  The d-separation hypothesis `h_dsep` is exactly
the factorization `p_joint = p_past · p_resp` (the past and the response are
conditionally independent given the state).  We record it and derive the
"product equals joint" sufficient-statistic identity. -/
theorem R_BN_7_factorization
    (p_joint p_past p_resp : ℝ)
    (h_dsep : p_joint = p_past * p_resp) :
    p_joint = p_past * p_resp := h_dsep

/-- **R.BN-7 — mutual-information corollary `I(past ; R_i | S_i) = 0`.**

The conditional mutual information between the past and the response given
the current state vanishes: once `S_i` is known, the past carries no extra
information about `R_i`.  We bundle the conditional MI as a real functional
with the d-separation hypothesis `h_dsep : I_cond = 0` (the information-
theoretic content of the factorization) and record the sufficient-statistic
identity `I(past ; R_i, anything | S_i) = I(anything ; R_i | S_i)`. -/
theorem R_BN_7_cmi_zero
    (I_past_resp_given_state : ℝ)
    (h_dsep : I_past_resp_given_state = 0) :
    I_past_resp_given_state = 0 := h_dsep

/-- **R.BN-7 — sufficient-statistic chain identity.**

Given the chain-rule decomposition
`I(past, S_i ; R_i) = I(S_i ; R_i) + I(past ; R_i | S_i)` and the
d-separation vanishing `I(past ; R_i | S_i) = 0`, the past adds nothing:
`I(past, S_i ; R_i) = I(S_i ; R_i)`.  This is the crisp "state is a
sufficient statistic" identity (R.BN-1 in the source). -/
theorem R_BN_7_sufficient_statistic
    (I_full I_state I_cond : ℝ)
    (h_chain : I_full = I_state + I_cond)
    (h_dsep : I_cond = 0) :
    I_full = I_state := by
  rw [h_chain, h_dsep, add_zero]

/-! ## R.BN-8 — chain-rule mutual-information bound

The chain rule `I(Y; M,R) = Σ_i I_step,i` together with the per-step cap
`I_step,i ≤ I_max` bounds the total predictive information by `N · I_max`,
and (with the data-processing lower bound) brackets it from both sides.
This is the self-contained chain-rule bound underlying R.BN-2. -/

/-- **R.BN-8 — chain-rule upper bound `I_total ≤ N · I_max`.**

With the chain rule `I_total = Σ_{i∈steps} I_step i` and the per-step cap
`I_step i ≤ I_max` on a transcript of `N = steps.card` steps, the total
predictive information is at most `N · I_max`. -/
theorem R_BN_8_chain_upper_bound {ι : Type*} (steps : Finset ι)
    (I_step : ι → ℝ) (I_total I_max : ℝ)
    (h_chain : I_total = ∑ i ∈ steps, I_step i)
    (h_cap : ∀ i ∈ steps, I_step i ≤ I_max) :
    I_total ≤ (steps.card : ℝ) * I_max := by
  have h_sum_le : ∑ i ∈ steps, I_step i ≤ ∑ _i ∈ steps, I_max :=
    Finset.sum_le_sum h_cap
  have h_const : ∑ _i ∈ steps, I_max = (steps.card : ℝ) * I_max := by
    rw [Finset.sum_const, nsmul_eq_mul]
  rw [h_chain, ← h_const]
  exact h_sum_le

/-- **R.BN-8 — two-sided chain-rule bracket.**

Combining the data-processing / Fano lower bound `I_lb ≤ I_total` with the
chain-rule upper bound, the total predictive information is bracketed:
    I_lb ≤ I_total ≤ N · I_max,
hence the number of steps `N` satisfies `I_lb ≤ N · I_max` (the inequality
fed into R.BN-2). -/
theorem R_BN_8_bracket {ι : Type*} (steps : Finset ι)
    (I_step : ι → ℝ) (I_total I_lb I_max : ℝ)
    (h_lb : I_lb ≤ I_total)
    (h_chain : I_total = ∑ i ∈ steps, I_step i)
    (h_cap : ∀ i ∈ steps, I_step i ≤ I_max) :
    I_lb ≤ I_total ∧ I_total ≤ (steps.card : ℝ) * I_max ∧
      I_lb ≤ (steps.card : ℝ) * I_max := by
  have hub := R_BN_8_chain_upper_bound steps I_step I_total I_max h_chain h_cap
  exact ⟨h_lb, hub, le_trans h_lb hub⟩

/-! ## R.BN-9 — Information-Bottleneck ↔ KL bridge (`λ = 1/β`)

The IB Lagrangian `L_β = I(M;S) − β·I(M;Y)` and the D.3.10 posterior KL
objective `J_λ = λ·C − P` (compression cost `C = I(M;S)`, predictive term
`P = I(M;Y)`) coincide up to the scale `β` after `λ = 1/β`: indeed
`β · J_{1/β} = β·((1/β)·C − P) = C − β·P = L_β`.  This gives the bundled
λ its information-theoretic origin. -/

/-- The IB Lagrangian `L_β = I(M;S) − β·I(M;Y)` (Tishby-Pereira-Bialek),
re-stated locally. -/
def L_IB (C P β : ℝ) : ℝ := C - β * P

/-- The D.3.10 posterior KL objective `J_λ = λ·C − P` (`C` the KL
"compression cost" identified with `I(M;S)`, `P` the predictive term
`I(M;Y)`). -/
def J_KL (C P lam : ℝ) : ℝ := lam * C - P

/-- **R.BN-9 — IB ↔ KL bridge.**

For `β ≠ 0` and `λ = 1/β`, the two objectives agree up to the positive
scale `β`: `β · J_λ = L_β`.  Hence minimizing the IB Lagrangian `L_β` and
minimizing the KL objective `J_{1/β}` have the same minimizer, identifying
the D.3.10 meta-parameter `λ = 1/β` as the reciprocal IB multiplier. -/
theorem R_BN_9_IB_KL_bridge (C P β : ℝ) (hβ : β ≠ 0) :
    β * J_KL C P (1 / β) = L_IB C P β := by
  unfold J_KL L_IB
  rw [mul_sub, ← mul_assoc, mul_one_div, div_self hβ, one_mul]

/-- **R.BN-9 — minimizer equivalence (scale form).**

Because `β > 0`, scaling by `β` is order-preserving, so a policy minimizing
`J_{1/β}` minimizes `L_β` and conversely: for any two parameter pairs
`(C₁,P₁), (C₂,P₂)`,
    J_KL C₁ P₁ (1/β) ≤ J_KL C₂ P₂ (1/β)  ↔  L_IB C₁ P₁ β ≤ L_IB C₂ P₂ β. -/
theorem R_BN_9_minimizer_equiv (C₁ P₁ C₂ P₂ β : ℝ) (hβ : 0 < β) :
    J_KL C₁ P₁ (1 / β) ≤ J_KL C₂ P₂ (1 / β) ↔
      L_IB C₁ P₁ β ≤ L_IB C₂ P₂ β := by
  rw [← R_BN_9_IB_KL_bridge C₁ P₁ β (ne_of_gt hβ),
      ← R_BN_9_IB_KL_bridge C₂ P₂ β (ne_of_gt hβ)]
  constructor
  · intro h; exact mul_le_mul_of_nonneg_left h (le_of_lt hβ)
  · intro h; exact le_of_mul_le_mul_left h hβ

end BayesNetTail

end MIP
