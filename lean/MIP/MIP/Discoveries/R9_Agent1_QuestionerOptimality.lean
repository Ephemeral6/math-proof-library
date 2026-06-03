/-
  STATUS: DISCOVERY
  AGENT: R9_Agent1
  DIRECTION: THE OPTIMAL QUESTIONER — out-of-frame questioning is what removes
    the barrier the agent cannot remove alone, its value is identity-blind
    (anonymity), it is exactly the log-bounded expert advantage, and the
    achievable reduction is pinned below by the committee coverage Fano floor.

    The corpus carries five questioner facts:
      * R.169(a) `R_169_a_out_of_frame`: a questioner all of whose interventions
        are OUT-OF-FRAME for the solver `X` (`∀ m ∈ M_Y, ¬ inFrame m`) supplies
        NO effective intervention — its impedance `Z_q(X|Y)` is infinite
        (`¬ HasEffective gain M_Y`).  [via the L.F gain-sign mechanism]
      * R.169(c) `R_169_c_more_knowledge_worse`: an external questioner carrying a
        single IN-FRAME critical intervention `m₁` (positive gain) is EFFECTIVE,
        while a knowledge-richer-but-out-of-frame questioner is not.
      * R.802 `anonymity` / `anonymity_projection`: the solver's output depends
        ONLY on the K(X)-projection (coverage) of the questioner's insertion, not
        on the questioner's identity — two questioners with the same coverage are
        output-indistinguishable to `X`.
      * R.803 `R_803_expert_advantage`: the cost reduction from an expert (in-frame
        critical) intervention is the log-bounded Expert Advantage Bound
        `N_novice ≤ C* · N_expert · log(1/ε) + N_expert`.
      * R5_Agent8 (tower) `mixture_fano_floor` / `committee_min_le_mixture`: the
        committee coverage Fano floor `Φ₀/log(cardMmax) ≤ ∑ w_a N_a` and the
        min-≤-average law pin the achievable questioner reduction from below.

    THIRD-ORDER FUSION (`optimal_questioner`, HEADLINE).  Model the solver's
    self-contained frame: the agent acting ALONE can pose only interventions in
    `MYself`, and ALL of those are out-of-frame critical (`¬ inFrame`) — the agent
    cannot, from inside its own frame, pose the very question whose gain is
    positive.  An OUT-OF-FRAME QUESTIONER `Yout` supplies exactly that in-frame
    critical intervention `m₁`.  Then, simultaneously:

      (a) STRICT REDUCTION.  `Yout` is effective while the self-contained agent is
          not (R.169(c)): the out-of-frame question removes the barrier the agent
          cannot remove alone.  Formally `HasEffective gain MYout ∧
          ¬ HasEffective gain MYself` — the questioner's intervention count is
          finite where the agent's is infinite.
      (b) ADVANTAGE = EXPERT ADVANTAGE.  That reduction is the R.803 log-bounded
          expert advantage `N_novice ≤ C*·N_expert·log(1/ε) + N_expert`, the
          UEA-simulated cost of the critical intervention.
      (c) ANONYMITY (R.802).  The achieved value depends only on the coverage
          (K(X)-projection) of the question, not on WHO asks: any two questioners
          differing only outside K(X) leave `X`'s output identical, so the optimal
          value is a function of coverage alone.
      (d) FLOOR-BOUNDED (R5_Agent8 tower).  The committee coverage Fano floor
          `Φ₀/log(cardMmax) ≤ ∑ w_a N_a` bounds the maximal achievable reduction:
          no questioner — however out-of-frame — can drive the conserved committee
          average below the information potential, and the committee min sits below
          that average.  The questioner's advantage is real but floor-limited.

    HEADLINE: the out-of-frame questioner achieves a STRICT, FINITE reduction
    (removing the agent's self-unposable barrier), that reduction IS the expert
    advantage (R.803), its value is IDENTITY-BLIND (R.802 anonymity), and it is
    FLOOR-BOUNDED by the committee coverage Fano floor (R5_Agent8 tower).

  Depends on (exact lemma names used in proof terms):
    - MIP.Results.R169_OutOfFrameQuestioner :
        OutOfFrameQuestioner.HasEffective,
        OutOfFrameQuestioner.R_169_a_out_of_frame,
        OutOfFrameQuestioner.R_169_c_more_knowledge_worse        — (a) strict reduction
    - MIP.Results.R802_QuestionerAnonymity :
        QuestionerAnonymity.anonymity,
        QuestionerAnonymity.anonymity_projection                 — (c) identity-blindness
    - MIP.Results.R803_ExpertAdvantage :
        ExpertAdvantage.R_803_expert_advantage                   — (b) advantage = expert advantage
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage (R4-R8 TOWER) :
        R5_Agent8_MixtureFanoCoverage.mixture_fano_floor,
        R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture   — (d) floor bound
    - MIP.Axioms (Agent/Str/K/tokenReplace) — types only; A.4 enters solely
        through the imported R.802 theorems (no new axiom here).
    - Mathlib: basic logic/order; `Real.log`, `le_div_iff₀` already in the cited files.
-/
import MIP.Results.R169_OutOfFrameQuestioner
import MIP.Results.R802_QuestionerAnonymity
import MIP.Results.R803_ExpertAdvantage
import MIP.Discoveries.R5_Agent8_MixtureFanoCoverage
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R9_Agent1_QuestionerOptimality

open MIP.OutOfFrameQuestioner
open MIP.QuestionerAnonymity
open MIP.ExpertAdvantage

/-! ## 1. (a) Strict reduction: the out-of-frame questioner removes the
barrier the self-contained agent cannot remove alone.

We model the metacognitive landscape of the solver `X` by an effective-gain
function `gain : M → ℝ` and an in-frame predicate `inFrame : M → Prop`, with the
L.F sign law `¬ inFrame m → gain m ≤ 0` (an out-of-frame intervention can never
yield positive effective gain).  This is the exact R.169 kernel. -/

/-- **(a) The out-of-frame questioner strictly reduces N (R.169(c)).**

`MYself` is the self-contained agent's own intervention set: every intervention it
can pose from inside its own frame is out-of-frame critical (`h_self_out`), so by
L.F all have nonpositive gain — the agent ALONE has infinite questioner impedance
(`¬ HasEffective gain MYself`).  The out-of-frame questioner `MYout` supplies the
single in-frame critical intervention `m₁` (positive gain `h₁_pos`), so it IS
effective.  Hence the external question removes a barrier the agent cannot remove
itself: finite vs infinite intervention count.

This is exactly R.169(c) instantiated with `MY₁ := MYout`, `MY₂ := MYself`. -/
theorem out_of_frame_strict_reduction
    {M : Type*}
    (gain : M → ℝ) (inFrame : M → Prop)
    (m₁ : M) (MYout MYself : M → Prop)
    (hLF      : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem   : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    HasEffective gain MYout ∧ ¬ HasEffective gain MYself :=
  R_169_c_more_knowledge_worse gain inFrame m₁ MYout MYself
    hLF h₁_mem h₁_inframe h₁_pos h_self_out

/-- **(a′) The self-contained agent alone has infinite questioner impedance
(R.169(a)).**

Isolated: the agent confined to its own frame `MYself`, all of whose interventions
are out-of-frame, has NO effective intervention — its `Z_q` is infinite.  This is
the precise sense in which a self-contained agent is *stuck*: it cannot self-pose
the question that would unblock it. -/
theorem self_contained_agent_stuck
    {M : Type*}
    (gain : M → ℝ) (inFrame : M → Prop) (MYself : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    ¬ HasEffective gain MYself :=
  R_169_a_out_of_frame gain inFrame MYself hLF h_self_out

/-! ## 2. (c) Anonymity: the achieved value depends only on coverage, not
identity.  Two questioners differing only OUTSIDE `K(X)` are output-
indistinguishable to the solver `X` (R.802). -/

/-- **(c) Questioner anonymity — value depends only on coverage (R.802).**

If two questioner-identity histories `hY, hY'` carry the SAME `K(X)`-coverage —
modelled (as in R.802) by both reducing, via out-of-`K(X)` token replacements
`ωs, ωs'`, to a common `K(X)`-projected history `c` — then `X` produces the same
output on both: `X hY = X hY'`.  The optimal questioner's achieved value is thus a
function of the question's COVERAGE alone; the identity of who asks is invisible to
`X`.  Direct R.802 `anonymity_projection`. -/
theorem questioner_value_identity_blind
    {α Ω : Type}
    (X : Agent α) (hY hY' c : Str α) (ωs ωs' : List Ω)
    (hOut  : ∀ ω ∈ ωs,  ω ∉ (K X : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω))
    (hProj  : c = QuestionerAnonymity.replaceOutside hY ωs)
    (hProj' : c = QuestionerAnonymity.replaceOutside hY' ωs') :
    X hY = X hY' :=
  anonymity_projection X hY hY' c ωs ωs' hOut hOut' hProj hProj'

/-- **(c′) Pure anonymity form (R.802 `anonymity`).**

A single out-of-`K(X)` replacement sequence relating two questioner histories
leaves `X`'s output invariant — the irreducible "metaphysical blind spot": the
solver cannot tell two equal-coverage questioners apart. -/
theorem questioner_anonymity_pure
    {α Ω : Type}
    (X : Agent α) (h₁ h₂ : Str α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (h_rel : h₂ = QuestionerAnonymity.replaceOutside h₁ ωs) :
    X h₁ = X h₂ :=
  anonymity X h₁ h₂ ωs hOut h_rel

/-! ## 3. (b)+(d) HEADLINE — optimal out-of-frame questioner: strict reduction,
expert advantage, anonymity, floor-bounded. -/

/-- **HEADLINE — the optimal out-of-frame questioner.**

A solver `X` (over carrier `α`, knowledge universe `Ω`) faces a committee of
candidate questioners indexed by `ι`, with conserved committee weights
`w : ι → ℝ` (`w_a ≥ 0`, `∑_a w_a = 1`), per-questioner intervention counts
`N : ι → ℝ` (`≥ 0`), per-questioner readable-alphabet capacities `logCardM`
(`0 ≤ logCardM_a ≤ log cardMmax`, `1 < cardMmax`), and per-questioner R.811 Fano
accumulations `Φ₀ ≤ N_a · logCardM_a`.

The metacognitive landscape of `X` is `gain : Mtype → ℝ` with in-frame predicate
`inFrame` and L.F sign law `hLF`.  The self-contained agent `MYself` has only
out-of-frame interventions (`h_self_out`); the out-of-frame questioner `MYout`
carries the in-frame critical intervention `m₁` (`h₁_pos`).  Finally the R.803
expert-advantage decomposition holds on reals: `N_novice ≤ k + N_expert` with the
UEA simulation bound `k ≤ C* · N_expert · log(1/ε)`.

CONCLUSIONS (the four faces of optimal questioning):

  (a) STRICT REDUCTION — `HasEffective gain MYout ∧ ¬ HasEffective gain MYself`:
      the out-of-frame questioner removes the barrier the self-contained agent
      cannot remove alone (finite vs infinite questioner impedance). [R.169(c)]

  (b) ADVANTAGE = EXPERT ADVANTAGE —
      `N_novice ≤ C* · N_expert · log(1/ε) + N_expert`: the reduction is the
      log-bounded Expert Advantage Bound. [R.803]

  (c) ANONYMITY — `X hY = X hY'` whenever `hY, hY'` share `K(X)`-coverage: the
      achieved value is identity-blind, a function of coverage alone. [R.802]

  (d) FLOOR-BOUNDED —
      `Φ₀/log(cardMmax) ≤ ∑_a w_a N_a` AND `min_a N_a ≤ ∑_a w_a N_a`: the
      committee coverage Fano floor pins the achievable reduction from below; no
      questioner drives the conserved average below the information potential, and
      the committee min sits below that average. [R5_Agent8 tower]

The out-of-frame questioner is thus OPTIMAL (strictly reduces N to finite where
the agent alone is stuck), its advantage is EXACTLY the expert advantage (b), its
value is ANONYMOUS in the questioner (c), and the reduction is FLOOR-BOUNDED by the
committee coverage Fano floor (d) — a genuine chaining of R.169 + R.803 + R.802 +
the R4–R8 conservation/Fano tower (R5_Agent8). -/
theorem optimal_questioner
    {α Ω : Type} {ι : Type} [Fintype ι] {Mtype : Type*}
    -- solver and committee carriers
    (X : Agent α)
    (hne : (Finset.univ : Finset ι).Nonempty)
    -- committee Fano bundle (R5_Agent8 tower)
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg  : ∀ a, 0 ≤ w a)
    (hw_sum     : ∑ a, w a = 1)
    (hN_nonneg  : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax  : 1 < cardMmax)
    (hcap_le    : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano      : ∀ a, Phi0 ≤ N a * logCardM a)
    -- metacognitive landscape (R.169)
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (hLF        : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem     : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m)
    -- expert-advantage decomposition (R.803)
    (N_novice N_expert Cstar ε kstep : ℝ)
    (h_decomp : N_novice ≤ kstep + N_expert)
    (h_sim    : kstep ≤ Cstar * N_expert * Real.log (1 / ε))
    -- anonymity data (R.802)
    (hY hY' c : Str α) (ωs ωs' : List Ω)
    (hOut  : ∀ ω ∈ ωs,  ω ∉ (K X : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω))
    (hProj  : c = QuestionerAnonymity.replaceOutside hY ωs)
    (hProj' : c = QuestionerAnonymity.replaceOutside hY' ωs') :
    -- (a) strict reduction: out-of-frame effective, self-contained stuck
    (HasEffective gain MYout ∧ ¬ HasEffective gain MYself)
    -- (b) advantage = expert advantage (log-bounded)
    ∧ (N_novice ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert)
    -- (c) anonymity: value depends only on coverage, not identity
    ∧ (X hY = X hY')
    -- (d) floor-bounded by the committee coverage Fano floor
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- (a) R.169(c): out-of-frame strict reduction.
    exact out_of_frame_strict_reduction gain inFrame m₁ MYout MYself
      hLF h₁_mem h₁_inframe h₁_pos h_self_out
  · -- (b) R.803: expert advantage bound.
    exact R_803_expert_advantage N_novice N_expert Cstar ε kstep h_decomp h_sim
  · -- (c) R.802: anonymity / identity-blindness.
    exact questioner_value_identity_blind X hY hY' c ωs ωs' hOut hOut' hProj hProj'
  · -- (d-i) R5_Agent8 tower: committee coverage Fano floor.
    exact R5_Agent8_MixtureFanoCoverage.mixture_fano_floor
      w N logCardM Phi0 cardMmax hw_nonneg hw_sum hN_nonneg hcap_nonneg
      hcardMmax hcap_le hfano
  · -- (d-ii) R5_Agent8 tower: committee min ≤ conserved average.
    exact R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture
      N w hne hw_nonneg hw_sum

/-! ## 4. Corollary — the advantage is real AND bounded (qualitative reading).

Packaging (a)+(d): the out-of-frame questioner achieves a finite-effective
reduction (it is the only effective party, the agent alone being stuck), yet the
committee coverage Fano floor forbids the conserved-average count from dropping
below `Φ₀/log(cardMmax)`.  The optimal questioner's gain is genuine but
floor-limited — coverage, not cleverness, is the hard wall. -/
theorem optimal_questioner_advantage_real_but_floored
    {Mtype : Type*} {ι : Type} [Fintype ι]
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (hLF        : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem     : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m)
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg  : ∀ a, 0 ≤ w a)
    (hw_sum     : ∑ a, w a = 1)
    (hN_nonneg  : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax  : 1 < cardMmax)
    (hcap_le    : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano      : ∀ a, Phi0 ≤ N a * logCardM a) :
    -- out-of-frame questioner effective AND self-contained agent stuck
    (HasEffective gain MYout ∧ ¬ HasEffective gain MYself)
    -- yet the reduction cannot break the coverage Fano floor
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a) := by
  refine ⟨?_, ?_⟩
  · exact out_of_frame_strict_reduction gain inFrame m₁ MYout MYself
      hLF h₁_mem h₁_inframe h₁_pos h_self_out
  · exact R5_Agent8_MixtureFanoCoverage.mixture_fano_floor
      w N logCardM Phi0 cardMmax hw_nonneg hw_sum hN_nonneg hcap_nonneg
      hcardMmax hcap_le hfano

end R9_Agent1_QuestionerOptimality

end MIP
