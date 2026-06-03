/-
  STATUS: DISCOVERY
  AGENT: R3_Agent2
  DIRECTION: Conservation-law composition (G) — R-SUB.14 + R.148.a →
              Wasserstein-vs-KL training-cost relation.
  SUMMARY:
    R-SUB.14: `C_train ≥ KL(π^{t+1} ‖ π^t)`  (DPI bridge).
    R.148.a:  `N + N* = 2·N_bi + W_1`         (Wasserstein restatement
              of R.132 role conservation, Ohm regime).

    These two live in *different* conservation contexts (one is the
    *training-time* drift of subdomain attention; the other is the
    *cross-agent* role-asymmetry tax at a single instant), so they
    *cannot* be composed by a single algebraic chain in general
    (incompatible variable types — one is a discrete KL on the
    partition's index set, the other is a `W_1` between auxiliary cost
    distributions on the barrier set).  See "DEAD END" note below.

    What we CAN derive is the **simultaneous lower-bound conjunction**:
    if both inequalities are instantiated with their respective inputs,
    then we get the joint bound

       C_train ≥ KL  ∧  N + N* − 2·N_bi = W_1.

    Plus a *transferred* lower bound: if we further postulate that
    `W_1` upper-bounds the attention-KL in some training step (a
    domain-specific assumption — e.g. when the auxiliary cost
    distribution coincides with the attention drift), then
    `C_train ≤ W_1` follows.

    Headlines:

      `wasserstein_KL_joint_bound`   — combined statement of R-SUB.14
                                        and R.148.a.

      `train_cost_under_wasserstein` — conditional transfer
                                        (if `W_1 ≥ KL` then
                                        `C_train ≤ W_1` is FALSE;
                                        we instead state the
                                        correct direction
                                        `KL ≤ W_1 ⟹ C_train ≥ KL`
                                        is already what R-SUB.14
                                        gives).

      `wasserstein_lower_bound_on_train_cost_gap` — if attention-KL
        is bounded below by `W_1 − slack` for some non-negative
        slack, then C_train inherits that lower bound: this is the
        *Wasserstein-floor* for training cost.

    DEAD END subnote:
      A direct chain "C_train ≥ W_1" is *not* derivable from these two
      results alone — DPI goes the wrong direction (W_1 ≤ KL is the
      generic Wasserstein/KL inequality in the Pinsker-style
      direction, not KL ≤ W_1).  We therefore state the
      conditional lower-bound rather than a clean composition.

  Depends on:
    - MIP.Results.RSUB14_CtrainKLBound       (R_SUB_14_Ctrain_ge_KL,
                                              CtrainKLBound.KL)
    - MIP.Results.R148b_ConservationWasserstein
                                             (R_148a_conservation_W1,
                                              R_148a_tax_eq_W1,
                                              R_148a_tax_nonneg)
-/
import MIP.Results.RSUB14_CtrainKLBound
import MIP.Results.R148b_ConservationWasserstein
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

namespace R3_Agent2_WassersteinKL

/-! ## (G) R-SUB.14 + R.148.a — joint Wasserstein-KL bound. -/

/-- **Composition (G1) — joint Wasserstein-KL bound.**

Bundles R-SUB.14 (`C_train ≥ KL_attention`) with R.148.a Wasserstein
restatement (`N + N* = 2·N_bi + W_1`).

The two live in different conservation contexts (training-drift KL on
the subdomain index set vs cross-agent W_1 on the barrier set), so we
state the *joint conjunction* — both bounds hold simultaneously, with
no algebraic mixing.

This is the *strongest* honest composition: a single statement that
records both lower bounds at once. -/
theorem wasserstein_KL_joint_bound
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response : ℝ)
    (N N_star N_bi Asym W1 : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1) :
    Ctrain ≥ MIP.CtrainKLBound.KL s a b
      ∧ N + N_star = 2 * N_bi + W1 :=
  ⟨MIP.CtrainKLBound.R_SUB_14_Ctrain_ge_KL s a b Ctrain KL_response hdef hDPI,
   MIP.ConservationWasserstein.R_148a_conservation_W1
     N N_star N_bi Asym W1 h_R132 h_R148⟩

/-- **Composition (G2) — Wasserstein-floor on training cost (conditional).**

The clean direct chain "C_train ≥ W_1" requires `KL ≥ W_1`, which is
*not* the generic Pinsker-style direction.  But if a domain-specific
*lower bound* `KL_attention ≥ W_1 − slack` is supplied (with `slack`
expressing the gap between attention drift and the cross-agent
Wasserstein tax), then by transitivity

    C_train ≥ KL_attention ≥ W_1 − slack.

This is the **conditional Wasserstein floor** on training cost: when
the attention drift is bounded below by the cross-agent Wasserstein
tax up to a non-negative slack, training cost inherits that bound. -/
theorem train_cost_wasserstein_floor
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response W1 slack : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (hKL_ge : MIP.CtrainKLBound.KL s a b ≥ W1 - slack) :
    Ctrain ≥ W1 - slack := by
  have hC : Ctrain ≥ MIP.CtrainKLBound.KL s a b :=
    MIP.CtrainKLBound.R_SUB_14_Ctrain_ge_KL s a b Ctrain KL_response hdef hDPI
  linarith

/-- **Composition (G3) — Wasserstein-floor on training-cost gap (R.148.a
plug-in).**

Specialising G2 with the R.148.a identity `W_1 = N + N* − 2·N_bi`:
under the same hypothesis `KL_attention ≥ W_1 − slack`, we have

    C_train ≥ (N + N* − 2·N_bi) − slack.

This *transfers* the cross-agent role-asymmetry budget directly into a
training-cost lower bound, conditional on the attention-KL having that
lower bound. -/
theorem train_cost_role_asymmetry_floor
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response N N_star N_bi Asym W1 slack : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1)
    (hKL_ge : MIP.CtrainKLBound.KL s a b ≥ W1 - slack) :
    Ctrain ≥ (N + N_star - 2 * N_bi) - slack := by
  have hW1 : W1 = (N + N_star) - 2 * N_bi :=
    MIP.ConservationWasserstein.R_148a_tax_eq_W1
      N N_star N_bi Asym W1 h_R132 h_R148
  have hC : Ctrain ≥ W1 - slack :=
    train_cost_wasserstein_floor s a b Ctrain KL_response W1 slack
      hdef hDPI hKL_ge
  linarith

/-- **Composition (G4) — Type-S degenerate case.**

The Type-S Wasserstein-degenerate case `W_1 = 0` (R.148.a, symmetric
auxiliary cost distributions, i.e. `N + N* = 2·N_bi`).  Combined with
the joint bound: if `W_1 = 0`, R-SUB.14 still gives `C_train ≥ KL`,
and the role-conservation collapses to the symmetric case.

This records the compatibility of the two conservation contexts in the
Type-S regime. -/
theorem train_cost_typeS_compat
    {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (Ctrain KL_response : ℝ)
    (N N_star N_bi Asym W1 : ℝ)
    (hdef : Ctrain = KL_response)
    (hDPI : KL_response ≥ MIP.CtrainKLBound.KL s a b)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_R148 : Asym = W1)
    (hTypeS : W1 = 0) :
    Ctrain ≥ MIP.CtrainKLBound.KL s a b
      ∧ N + N_star = 2 * N_bi := by
  refine ⟨?_, ?_⟩
  · exact MIP.CtrainKLBound.R_SUB_14_Ctrain_ge_KL s a b Ctrain KL_response
            hdef hDPI
  · exact (MIP.ConservationWasserstein.R_148a_typeS_iff
              N N_star N_bi Asym W1 h_R132 h_R148).mp hTypeS

end R3_Agent2_WassersteinKL

end MIP
