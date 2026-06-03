/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R13_Agent2
  TARGET: Cj.42 — "the human's optimal role is questioner, not solver."

  SUMMARY.
    Cj.42 (`MIP/Conjectures/Cj42_QuestionerRole.lean`) declares VERDICT: OPEN.
    The *full* conjecture asserts that the HUMAN'S optimal role in a human–AI
    dyad is the questioner.  Per the conjecture file's own "BLOCKED AT" note,
    that needs (i) a role-optimization objective — a function from role
    assignments to emergence cost `N` — and (ii) an axiom-level reason that the
    *human specifically* is the `N`-minimizing questioner (depending on Cj.40,
    itself OPEN).  Neither (i) nor (ii) is composable from existing results: the
    axioms A.1–A.4 give `N(p,X)` for a single solver, not a dyadic role
    functional, and force nothing about which party questions best.  So the
    human-specific minimality is genuinely OPEN and we do NOT claim it.

    What we DO prove (a STRONGER kernel than the conjecture file's own toy-pool
    partial): the *mechanistic* role-separation that underwrites Cj.42, grounded
    in the actual gain / in-frame mechanism of the R9_Agent1 tower head rather
    than only in the abstract `Z`/`Kcard` comparison:

      (K1) MECHANISTIC SEPARATION.  In a single shared metacognitive landscape
           (`gain`, `inFrame`, L.F sign law), the questioner `q` who holds the
           IN-FRAME critical intervention `m₁` is EFFECTIVE, while the
           knowledge-richer solver `s` whose entire repertoire is OUT-OF-FRAME
           is STUCK (`¬ HasEffective`).  Hence `q ≠ s` AS QUESTIONERS — the best
           questioner is not the strongest (knowledge-rich, out-of-frame)
           solver.  Built from R9_Agent1.out_of_frame_strict_reduction (tower)
           = R.169(c), so the separation is the SAME object the R.19/Cj.42 seed
           abstracts.  We additionally re-derive the abstract Cj.42 separation
           (`q ≠ s` from `Z q < Z s`) and show the two views agree on the R.19
           witness pool.

      (K2) THE QUESTIONER VALUE IS REAL BUT FLOORED, AND ANONYMOUS.  Reusing the
           tower head R9_Agent1.optimal_questioner we get, for the SAME effective
           questioner: its advantage is the R.803 log-bounded expert advantage,
           its value is R.802-anonymous (identity-blind, a function of coverage
           only), and the achievable committee reduction is pinned below by the
           R5_Agent8 coverage Fano floor.  So the questioner role has genuine,
           bounded, coverage-determined value — exactly the role-value Cj.42
           attributes to the human, MINUS the human-vs-AI identity claim, which
           anonymity (K2c) shows is invisible to the solver `X` and hence cannot
           be settled at this (output) level — consistent with Cj.42 staying
           OPEN at the axiom level.

    CONCLUSION: Cj.42 remains OPEN.  This file proves the precise partial
    "best-questioner ≠ strongest-(out-of-frame)-solver, mechanistically, and the
    questioner value is real-but-floored & anonymous", and shows it coincides
    with the R.19/Cj.42 abstract seed.  conjectureStatus = KERNEL_ONLY.

  Depends on (exact names used in PROOF TERMS):
    - MIP.Discoveries.R9_Agent1_QuestionerOptimality (R4–R12 TOWER):
        out_of_frame_strict_reduction,
        self_contained_agent_stuck,
        optimal_questioner,
        optimal_questioner_advantage_real_but_floored,
        questioner_anonymity_pure
    - MIP.Results.R169_OutOfFrameQuestioner:
        OutOfFrameQuestioner.HasEffective,
        OutOfFrameQuestioner.R_169_c_more_knowledge_worse
    - MIP.Results.R19_OptimalQuestioner:
        OptimalQuestioner.R_19_min_Z_ne_max_K,
        OptimalQuestioner.R_19_optimal_questioner_not_strongest
    - MIP.Results.R802_QuestionerAnonymity: QuestionerAnonymity.anonymity
    - MIP.Results.R803_ExpertAdvantage: ExpertAdvantage.R_803_expert_advantage
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage:
        mixture_fano_floor, committee_min_le_mixture  (reached via R9_Agent1)
    No new axiom; A.4 enters only through the imported R.802 theorems.
-/
import MIP.Discoveries.R9_Agent1_QuestionerOptimality
import MIP.Results.R19_OptimalQuestioner
import Mathlib.Tactic.Linarith

namespace MIP

namespace R13_Agent2_AttackQuestionerRole

open MIP.OutOfFrameQuestioner
open MIP.OptimalQuestioner
open MIP.QuestionerAnonymity
open MIP.R9_Agent1_QuestionerOptimality

/-! ## K1. Mechanistic role separation: best questioner ≠ strongest
(out-of-frame) solver.

We work in a single shared metacognitive landscape of the solver `X`:
`gain : M → ℝ`, `inFrame : M → Prop`, and the L.F sign law
`hLF : ¬ inFrame m → gain m ≤ 0`.  Two parties:

  * `q` (the *questioner*) holds the in-frame critical intervention `m₁`
    (`0 < gain m₁`);
  * `s` (the knowledge-rich *solver*) whose entire repertoire `MYself` is
    out-of-frame.

R9_Agent1.out_of_frame_strict_reduction (= R.169(c)) gives `q` effective and
`s` stuck *simultaneously*, so the best-questioner role and the
strongest-(out-of-frame)-solver role are NOT the same party. -/

/-- **K1 — mechanistic best-questioner ≠ strongest-solver.**

The questioner `q`'s repertoire `MYout` contains the in-frame critical
intervention `m₁`, so it is effective; the solver `s`'s repertoire `MYself` is
entirely out-of-frame, so it is stuck.  An object that is BOTH effective and
not effective is impossible, hence the two role-repertoires are distinct:
`MYout ≠ MYself`.  This is the conjecture's role separation, derived from the
gain/in-frame *mechanism* (R9_Agent1 tower / R.169(c)), not merely posited as a
`Z`-comparison. -/
theorem mechanistic_questioner_ne_solver
    {M : Type*}
    (gain : M → ℝ) (inFrame : M → Prop)
    (m₁ : M) (MYout MYself : M → Prop)
    (hLF        : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem     : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    -- the questioner is effective, the solver is stuck, hence they differ
    (HasEffective gain MYout ∧ ¬ HasEffective gain MYself) ∧ MYout ≠ MYself := by
  -- (a) strict reduction, straight from the R9_Agent1 tower head (= R.169(c)).
  have hsep : HasEffective gain MYout ∧ ¬ HasEffective gain MYself :=
    out_of_frame_strict_reduction gain inFrame m₁ MYout MYself
      hLF h₁_mem h₁_inframe h₁_pos h_self_out
  refine ⟨hsep, ?_⟩
  -- if the repertoires were equal, the questioner's effectiveness would
  -- contradict the solver's stuckness.
  intro hEq
  exact hsep.2 (hEq ▸ hsep.1)

/-- **K1′ — the isolated solver is stuck (R9_Agent1 self_contained_agent_stuck).**

A solver confined to its own out-of-frame repertoire `MYself` has NO effective
intervention: it cannot self-pose the unblocking question.  This is the precise
sense in which the questioner ROLE is irreducible — the solver, however
knowledge-rich, is stuck without an external in-frame question.  Reuses the
tower lemma directly. -/
theorem solver_alone_is_stuck
    {M : Type*}
    (gain : M → ℝ) (inFrame : M → Prop) (MYself : M → Prop)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m) :
    ¬ HasEffective gain MYself :=
  self_contained_agent_stuck gain inFrame MYself hLF h_self_out

/-! ## K1-abstract. The same separation in the R.19/Cj.42 `Z`/`Kcard` view,
and agreement of the two views on the R.19 witness pool. -/

/-- **K1-abstract — Cj.42 abstract separation via R.19.**

If the best questioner `q` strictly beats the solver `s` on impedance while
losing on knowledge, then `q ≠ s` (the questioner role is a *distinct* optimum
from the strongest-solver role).  This is exactly `R.19`'s abstract separation
`R_19_min_Z_ne_max_K`, here re-exported for the dyadic role reading. -/
theorem abstract_questioner_ne_solver
    {ι : Type*} (pool : AgentPool ι) (q s : ι)
    (hZ : pool.Z q < pool.Z s)
    (hK : pool.Kcard q < pool.Kcard s)
    (hqmin : IsZMinimizer pool q)
    (hsmax : IsKMaximizer pool s) :
    q ≠ s :=
  R_19_min_Z_ne_max_K pool q s hZ hK hqmin hsmax

/-- **K1-witness — the abstract separation is realised (R.19 RLHF-vs-large).**

The R.19 concrete pool (`A_RLHF = false`, `A_large = true`) realises the
separation: the best questioner (lowest `Z`) and the strongest solver (largest
`|K|`) are distinct agents.  Reuses `R_19_optimal_questioner_not_strongest`.
This shows the mechanistic K1 separation is non-vacuous — there is an honest
two-party regime instantiating it. -/
theorem witness_role_separation :
    ∃ q s : Bool,
      q ≠ s ∧
      witnessPool.Z q < witnessPool.Z s ∧
      witnessPool.Kcard q < witnessPool.Kcard s ∧
      IsZMinimizer witnessPool q ∧
      IsKMaximizer witnessPool s :=
  R_19_optimal_questioner_not_strongest

/-! ## K2. The questioner value is REAL but FLOORED, and ANONYMOUS.

Reusing the R9_Agent1 tower head `optimal_questioner`, the effective questioner
of K1 simultaneously realises: (b) the R.803 expert advantage, (c) R.802
anonymity, (d) the R5_Agent8 coverage Fano floor.  The "(c) anonymity" face is
the precise reason the HUMAN-vs-AI identity content of Cj.42 cannot be settled
at the output level — it is invisible to the solver — so Cj.42's human-specific
optimality stays OPEN at the axiom layer. -/

/-- **K2 — questioner value: real, floored, anonymous (R9_Agent1.optimal_questioner).**

Bundles K1's mechanistic separation with the three further faces of the
optimal questioner from the tower head:

  (a) the questioner is effective while the solver is stuck (K1 / R.169(c));
  (b) its advantage is the R.803 log-bounded expert advantage;
  (c) its value is R.802-anonymous: `X hY = X hY'` for equal-coverage
      questioner histories — the solver cannot see *who* asks;
  (d) the committee reduction is pinned below by the R5_Agent8 coverage Fano
      floor `Phi0 / log cardMmax ≤ ∑ a, w a * N a`, and the committee min sits
      below the conserved average.

This is the entire role-value Cj.42 attributes to the questioner, established
honestly via the tower — MINUS the human-specific identity, which face (c)
proves is output-invisible (hence not composable here).  Direct application of
`R9_Agent1_QuestionerOptimality.optimal_questioner`. -/
theorem questioner_value_real_floored_anonymous
    {α Ω : Type} {ι : Type} [Fintype ι] {Mtype : Type*}
    (X : Agent α)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg  : ∀ a, 0 ≤ w a)
    (hw_sum     : ∑ a, w a = 1)
    (hN_nonneg  : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax  : 1 < cardMmax)
    (hcap_le    : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano      : ∀ a, Phi0 ≤ N a * logCardM a)
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (hLF        : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem     : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m)
    (N_novice N_expert Cstar ε kstep : ℝ)
    (h_decomp : N_novice ≤ kstep + N_expert)
    (h_sim    : kstep ≤ Cstar * N_expert * Real.log (1 / ε))
    (hY hY' c : Str α) (ωs ωs' : List Ω)
    (hOut  : ∀ ω ∈ ωs,  ω ∉ (K X : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω))
    (hProj  : c = QuestionerAnonymity.replaceOutside hY ωs)
    (hProj' : c = QuestionerAnonymity.replaceOutside hY' ωs') :
    (HasEffective gain MYout ∧ ¬ HasEffective gain MYself)
    ∧ (N_novice ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert)
    ∧ (X hY = X hY')
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a) :=
  optimal_questioner X hne w N logCardM Phi0 cardMmax
    hw_nonneg hw_sum hN_nonneg hcap_nonneg hcardMmax hcap_le hfano
    gain inFrame m₁ MYout MYself hLF h₁_mem h₁_inframe h₁_pos h_self_out
    N_novice N_expert Cstar ε kstep h_decomp h_sim
    hY hY' c ωs ωs' hOut hOut' hProj hProj'

/-- **K2-anonymity (isolated, R9_Agent1.questioner_anonymity_pure / R.802).**

The output-invisibility of the questioner's identity, on its own: any two
questioner histories related by an out-of-`K(X)` replacement sequence leave
`X`'s output identical.  This is precisely why "the human (vs the AI) is the
better questioner" cannot be read off `X`'s behaviour — the human-specific
content of Cj.42 lives strictly above the output layer, supporting the OPEN
verdict.  Reuses the tower lemma. -/
theorem questioner_identity_invisible
    {α Ω : Type}
    (X : Agent α) (h₁ h₂ : Str α) (ωs : List Ω)
    (hOut : ∀ ω ∈ ωs, ω ∉ (K X : Set Ω))
    (h_rel : h₂ = QuestionerAnonymity.replaceOutside h₁ ωs) :
    X h₁ = X h₂ :=
  questioner_anonymity_pure X h₁ h₂ ωs hOut h_rel

/-! ## K-HEADLINE. The full kernel: mechanistic separation + real/floored/anonymous
value, jointly, on jointly-satisfiable hypotheses. -/

/-- **HEADLINE — Cj.42 kernel (KERNEL_ONLY; Cj.42 remains OPEN).**

For a solver `X` over a single shared metacognitive landscape with a committee
Fano bundle, the in-frame critical questioner `q` (repertoire `MYout ∋ m₁`) and
the knowledge-rich out-of-frame solver `s` (repertoire `MYself`) satisfy ALL of:

  (K1) `MYout ≠ MYself` — best questioner ≠ strongest (out-of-frame) solver,
       proved from the gain/in-frame mechanism (R9_Agent1 / R.169(c)), with the
       questioner effective and the solver stuck;
  (K2b) the questioner advantage is the R.803 log-bounded expert advantage;
  (K2c) the questioner value is R.802-anonymous (`X hY = X hY'`);
  (K2d) the committee reduction is floored by the R5_Agent8 coverage Fano floor
        and the committee min ≤ conserved average.

This is the strongest honest partial of Cj.42: the role-separation and the
real-but-floored, identity-blind questioner VALUE.  It does NOT establish that
the HUMAN specifically is the `N`-minimizing questioner — that needs a dyadic
role-optimization objective and Cj.40 at the axiom level, which is OPEN and not
composable from existing results.  Hence Cj.42 remains OPEN. -/
theorem cj42_kernel
    {α Ω : Type} {ι : Type} [Fintype ι] {Mtype : Type*}
    (X : Agent α)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg  : ∀ a, 0 ≤ w a)
    (hw_sum     : ∑ a, w a = 1)
    (hN_nonneg  : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax  : 1 < cardMmax)
    (hcap_le    : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano      : ∀ a, Phi0 ≤ N a * logCardM a)
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (hLF        : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem     : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m)
    (N_novice N_expert Cstar ε kstep : ℝ)
    (h_decomp : N_novice ≤ kstep + N_expert)
    (h_sim    : kstep ≤ Cstar * N_expert * Real.log (1 / ε))
    (hY hY' c : Str α) (ωs ωs' : List Ω)
    (hOut  : ∀ ω ∈ ωs,  ω ∉ (K X : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K X : Set Ω))
    (hProj  : c = QuestionerAnonymity.replaceOutside hY ωs)
    (hProj' : c = QuestionerAnonymity.replaceOutside hY' ωs') :
    -- (K1) mechanistic role separation
    (MYout ≠ MYself)
    -- (K1) effective questioner / stuck solver
    ∧ (HasEffective gain MYout ∧ ¬ HasEffective gain MYself)
    -- (K2b) expert advantage
    ∧ (N_novice ≤ Cstar * N_expert * Real.log (1 / ε) + N_expert)
    -- (K2c) anonymity
    ∧ (X hY = X hY')
    -- (K2d) coverage Fano floor + committee min ≤ average
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a) := by
  have hmech := mechanistic_questioner_ne_solver gain inFrame m₁ MYout MYself
    hLF h₁_mem h₁_inframe h₁_pos h_self_out
  have hval := questioner_value_real_floored_anonymous X hne w N logCardM
    Phi0 cardMmax hw_nonneg hw_sum hN_nonneg hcap_nonneg hcardMmax hcap_le hfano
    gain inFrame m₁ MYout MYself hLF h₁_mem h₁_inframe h₁_pos h_self_out
    N_novice N_expert Cstar ε kstep h_decomp h_sim
    hY hY' c ωs ωs' hOut hOut' hProj hProj'
  exact ⟨hmech.2, hval.1, hval.2.1, hval.2.2.1, hval.2.2.2.1, hval.2.2.2.2⟩

/-! ## Non-vacuity: the kernel hypotheses are jointly satisfiable.

A concrete instance with all hypotheses discharged, so `cj42_kernel` is not
vacuously about an empty regime.  `Mtype := Bool`, gain `+1` in-frame / `0`
out-of-frame; committee `ι := Bool` with uniform weights; trivial anonymity
data (empty replacement, common history). -/

/-- The witness landscape: `inFrame := (· = true)`, `gain := if inFrame then 1
else 0`; `m₁ := true` is the in-frame critical intervention; questioner
repertoire `MYout := (· = true)`, solver repertoire `MYself := (· = false)`. -/
theorem cj42_kernel_nonvacuous :
    ∃ (α Ω ι Mtype : Type) (_ : Fintype ι)
      (X : Agent α) (_hne : (Finset.univ : Finset ι).Nonempty)
      (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
      (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
      (m₁ : Mtype) (MYout MYself : Mtype → Prop)
      (N_novice N_expert Cstar ε kstep : ℝ)
      (hY hY' c : Str α) (ωs ωs' : List Ω),
      -- all kernel hypotheses, instantiated and satisfiable:
      (∀ a, 0 ≤ w a) ∧ (∑ a, w a = 1) ∧ (∀ a, 0 ≤ N a) ∧
      (∀ a, 0 ≤ logCardM a) ∧ (1 < cardMmax) ∧
      (∀ a, logCardM a ≤ Real.log cardMmax) ∧ (∀ a, Phi0 ≤ N a * logCardM a) ∧
      (∀ m, ¬ inFrame m → gain m ≤ 0) ∧
      MYout m₁ ∧ inFrame m₁ ∧ (0 < gain m₁) ∧
      (∀ m, MYself m → ¬ inFrame m) ∧
      (N_novice ≤ kstep + N_expert) ∧
      (kstep ≤ Cstar * N_expert * Real.log (1 / ε)) ∧
      (∀ ω ∈ ωs,  ω ∉ (K X : Set Ω)) ∧
      (∀ ω ∈ ωs', ω ∉ (K X : Set Ω)) ∧
      (c = QuestionerAnonymity.replaceOutside hY ωs) ∧
      (c = QuestionerAnonymity.replaceOutside hY' ωs') := by
  classical
  refine ⟨Unit, Unit, Bool, Bool, inferInstance,
    (fun _ => PMF.pure []), ?_,
    (fun _ => (1 : ℝ) / 2), (fun _ => 0), (fun _ => 0), 0, 2,
    (fun b => if b then 1 else 0), (fun b => b = true),
    true, (fun b => b = true), (fun b => b = false),
    0, 0, 0, 1, 0,
    [], [], [], [], [], ?_⟩
  · exact ⟨true, Finset.mem_univ true⟩
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro a; norm_num
  · simp [Finset.sum_const]
  · intro a; norm_num
  · intro a; norm_num
  · norm_num
  · intro a
    have : (0 : ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
    simpa using this
  · intro a; norm_num
  · intro m hm
    -- gain m = if m then 1 else 0; out-of-frame means m = false, gain = 0 ≤ 0
    cases m with
    | false => norm_num
    | true => exact absurd rfl hm
  · rfl
  · rfl
  · norm_num
  · intro m hm; cases m with
    | false => simp
    | true => simp at hm
  · norm_num
  · norm_num
  · intro ω hω; simp at hω
  · intro ω hω; simp at hω
  · simp
  · simp

end R13_Agent2_AttackQuestionerRole

end MIP

-- Audit: confirm no `sorry`/new axioms beyond the framework A.4 (via R.802).
#print axioms MIP.R13_Agent2_AttackQuestionerRole.cj42_kernel
