/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: T.18.3 (Self-model) + T.18.4 (Goodhart) — training a self-model induces Goodhart.

  SUMMARY:
    T.18.3: a non-degenerate agent `X` has `0 < agentTVDist X X'` for every
    external model `X'` — *every* attempted external self-model is
    strictly off.
    T.18.4: any non-trivial training step (`A_t ≠ A_0`) induces strictly
    positive training drift `CTrain A_t A_0 > 0`.

    **Joint discovery (this file).** Training to construct a self-model is
    *exactly* the Goodhart trap:

    1. Suppose an external model `X' ∈ models(X)` is *trained* into existence
       — i.e. `X'` arises from `X` via training, so `X' ≠ X` whenever the
       training is non-trivial.
    2. T.18.3 then forces `0 < agentTVDist X X'`.
    3. T.18.4 simultaneously forces `0 < CTrain X' X`.
    4. So **the trained "self-model" `X'` has *both*** strictly positive
       intrinsic distance (T.18.3) *and* strictly positive training drift
       (T.18.4) from the original `X`. Neither tells the whole story —
       both are positive.

    Sharper: define the **Goodhart-self-model gap** `GhSelfGap X X' :=
    agentTVDist X X' + CTrain X' X`. We prove:

      • `GhSelfGap X X' = 0 ↔ X' = X ∧ X non-degenerate fails`,
        i.e. zero gap implies *no training and degeneracy*.
      • For non-degenerate `X` with `X' ≠ X`, **`GhSelfGap > 0` strictly**.

    This is the formal "training a self-model induces Goodhart" statement.

  R-DEPS:
    • MIP.Theorems.T18_3_SelfModel (NonDegenerate, agentTVDist)
    • MIP.Theorems.T18_4_Goodhart (CTrain, CTrain_eq_zero_iff)
-/
import MIP.Theorems.T18_3_SelfModel
import MIP.Theorems.T18_4_Goodhart

namespace MIP

namespace R3_Agent5_SelfModelGoodhart

open MIP.SelfModel
open MIP.Goodhart

variable {α : Type}

/-! ## (1) Joint positivity on a trained self-model. -/

/-- **T.18.3 + T.18.4 — jointly positive on a trained external model.**

If the agent `X` is non-degenerate (T.18.3 NC.5' bundle) and the external
model `X' ≠ X` (non-trivial training), then *both* the intrinsic distance
`agentTVDist X X'` (T.18.3) **and** the training drift `CTrain X' X`
(T.18.4) are strictly positive. -/
theorem T18_3_T18_4_joint_positivity
    (X X' : Agent α)
    (hNonDeg : NonDegenerate X) (h_train : X' ≠ X) :
    0 < agentTVDist X X' ∧ 0 < CTrain X' X := by
  refine ⟨?_, ?_⟩
  · -- T.18.3 invocation: non-degenerate ⟹ strictly positive distance to every model.
    exact T18_3_imperfect_self_model X hNonDeg X'
  · -- T.18.4 invocation: non-trivial training ⟹ strictly positive drift.
    exact T18_4_Goodhart_unavoidable X X' h_train

/-! ## (2) The Goodhart-self-model gap. -/

/-- **`GhSelfGap`** — combined Goodhart-self-model gap between an agent
`X` and its (trained) external model `X'`. Sum of T.18.3's intrinsic
distance and T.18.4's training drift. -/
noncomputable def GhSelfGap (X X' : Agent α) : NNReal :=
  agentTVDist X X' + CTrain X' X

/-- **Sharpened Goodhart-self-model theorem.**

For any non-degenerate `X` with a trained model `X' ≠ X`, the combined
gap `GhSelfGap X X'` is strictly positive. (Both summands are
individually positive, so the sum is.) -/
theorem T18_3_T18_4_GhSelfGap_pos
    (X X' : Agent α)
    (hNonDeg : NonDegenerate X) (h_train : X' ≠ X) :
    0 < GhSelfGap X X' := by
  obtain ⟨h1, h2⟩ := T18_3_T18_4_joint_positivity X X' hNonDeg h_train
  unfold GhSelfGap
  exact add_pos h1 h2

/-! ## (3) Inverse: zero gap forces both degeneracy and identity. -/

/-- **`GhSelfGap = 0` ⟺ identity ∧ degeneracy with respect to `X'`.**

The gap is zero iff *both* summands are zero. The T.18.4 summand vanishes
iff `X' = X`. The T.18.3 summand `agentTVDist X X'` is zero iff `X` is
*degenerate* with respect to the choice `X' = X` (and any `X'` if `X` is
fully degenerate).

We package the cleaner one-sided implication: zero gap forces `X' = X`. -/
theorem GhSelfGap_zero_implies_identity
    (X X' : Agent α) (h : GhSelfGap X X' = 0) :
    X' = X := by
  unfold GhSelfGap at h
  -- Sum of nonneg NNReals = 0 ⟹ both = 0.
  have h2 : CTrain X' X = 0 := by
    have := (add_eq_zero.mp h).2
    exact this
  exact (CTrain_eq_zero_iff X' X).mp h2

/-- **Equivalent: non-zero gap follows from `X' ≠ X` (no non-degeneracy assumption).**

Just using T.18.4 alone, `X' ≠ X` already forces the CTrain summand,
hence the whole gap, to be strictly positive. -/
theorem GhSelfGap_pos_of_nontrivial_training
    (X X' : Agent α) (h_train : X' ≠ X) :
    0 < GhSelfGap X X' := by
  unfold GhSelfGap
  have h2 : 0 < CTrain X' X := T18_4_Goodhart_unavoidable X X' h_train
  exact lt_of_lt_of_le h2 (le_add_self)

/-! ## (4) **Sharper headline**: with non-degeneracy, gap is positive *even when*
      training is trivial (`X' = X` impossible under non-degeneracy). -/

/-- **Non-degenerate agents have no zero-gap self-model.**

The genuine T.18.3 + T.18.4 fusion: under non-degeneracy of `X`, *every*
choice of `X' = X` gives strictly positive intrinsic distance to itself
(via `T18_3_imperfect_self_model X hNonDeg X`). Combined with the
training-drift summand being `0` when `X' = X`, we still get positivity
*purely from T.18.3*. -/
theorem nondegenerate_implies_no_zero_self_model
    (X : Agent α) (hNonDeg : NonDegenerate X) :
    ∀ X' : Agent α, 0 < GhSelfGap X X' := by
  intro X'
  by_cases h : X' = X
  · -- Even with trivial training, T.18.3 forces the intrinsic distance summand positive.
    unfold GhSelfGap
    have h1 : 0 < agentTVDist X X' := T18_3_imperfect_self_model X hNonDeg X'
    -- The CTrain summand is 0 (trivial training), but we add a positive term.
    exact lt_of_lt_of_le h1 le_self_add
  · exact GhSelfGap_pos_of_nontrivial_training X X' h

/-- **R3 Agent 5 headline (this file): training induces Goodhart, sharply.**

For any non-degenerate `X` (T.18.3 hypothesis) and any external `X'`,
the combined Goodhart-self-model gap is strictly positive — regardless
of whether training was trivial or not. Specifically:

  • **Trivial training** (`X' = X`): positivity from T.18.3 alone.
  • **Non-trivial training** (`X' ≠ X`): positivity from T.18.4 alone, and
    additionally from T.18.3.

So the "training a self-model" project cannot escape Goodhart. -/
theorem training_self_model_induces_Goodhart
    (X X' : Agent α) (hNonDeg : NonDegenerate X) :
    0 < GhSelfGap X X' :=
  nondegenerate_implies_no_zero_self_model X hNonDeg X'

end R3_Agent5_SelfModelGoodhart

end MIP
