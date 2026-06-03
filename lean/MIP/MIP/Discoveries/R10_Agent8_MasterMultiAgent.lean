/-
  STATUS: CAPSTONE
  AGENT: R10_Agent8
  PILLAR: THE MASTER MULTI-AGENT THEOREM (committees, conservation, bounds).

  SUMMARY.  This capstone SYNTHESISES the multi-agent cluster of the tower into
  ONE master statement.  A single committee setting — a finite agent index `ι`
  carrying simultaneously a TENSOR face (independent per-agent subdomains `κ a`
  with conserved distributions `π_tensor`, additive potential `Φ(x)=∑_a φ_a(x_a)`,
  envelopes `φ_a ≤ Mφ a`, joint Ohm budget `N_joint = ⌈Z·Φ_joint⌉₊`) and a
  MIXTURE face (conserved committee weights `w`, per-agent counts `N`, capacities
  `logCardM`, mixture distributions `π_mix`, Fano accumulations `Φ₀ ≤ N_a·logCardM_a`)
  — discharges, AT ONCE, the headline conclusions of SIX tower theorems:

    * R5_Agent4  `multi_agent_ohm_budget_law`
        the tensor/mixture-conserved JOINT OHM BUDGET SUBADDITIVITY
            N_joint ≤ ∑_a ⌈Z·Mφ a⌉₊
        (grounded in R4_Agent6 tensor conservation).
    * R6_Agent5  `all_wall_is_terminal_multiagent_budget`
        the TERMINAL ALL-WALL ABSORPTION in the cost order ℕ∞: a finite floor,
        one walled agent absorbs the joint budget to ⊤, monotonicity +
        terminality, and the OOD wall bridge.
    * R5_Agent8  `mixture_committee_fano`
        the COMMITTEE FANO COVERAGE FLOOR `Φ₀/log(cardMmax) ≤ ∑_a w_a N_a`,
        with `min ≤ mixture`, committee no-worse, and the conserved-mixture
        certificate.
    * R8_Agent8  `brent_amdahl_multi_agent_intervention`
        the BRENT PARALLEL-TIME bound `max(L, N_joint/k) ≤ T_k`, the Amdahl cap
        `N_joint/T_k ≤ N_joint/L`, the envelope bound, and the ℕ Brent floor.
    * R8_Agent6  `cooperative_surplus_nonneg_xi_bounded_floored`
        the COOPERATIVE SURPLUS Xi bound: `0 ≤ σ`, `N_bi² ≤ N→·N←/(1+ξ)`,
        `N_bi ≤ Φ₀Z/δ`, and the floor-constrained optimum.
    * R9_Agent1  `optimal_questioner`
        the FLOORED QUESTIONER OPTIMALITY: strict out-of-frame reduction,
        advantage = expert advantage, anonymity, and the Fano floor bound.

  HEADLINE (`master_multi_agent`).  A single bundled `structure` whose fields are
  EXACTLY the six headline conclusions above, each field proved by invoking the
  corresponding tower theorem as a proof term.  The constructor
  `master_multi_agent` is the grand assembly: it is provable ONLY because the two
  committee faces (tensor + mixture) share the SAME finite index `ι` and the
  hypotheses are JOINTLY COMPATIBLE (the tensor-face hyps `0≤Z, 0≤π, ∑π=1, φ≤Mφ`
  and the mixture-face hyps `0≤w, ∑w=1, 0≤N, 0≤logCardM, 1<cardMmax, Fano` never
  conflict; the Brent/cooperative/questioner side-data attach freely).  A concrete
  satisfiability witness `master_multi_agent_witness` instantiates the entire
  bundle at `ι = Fin 1`, `κ = fun _ => Fin 1`, `Ω = Fin 1`, with the trivial
  one-point distributions, proving the master hypotheses are NON-VACUOUS.

  Assembles (the six tower headline lemmas bundled, all load-bearing proof terms):
    - MIP.Discoveries.R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
    - MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal.all_wall_is_terminal_multiagent_budget
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage.mixture_committee_fano
    - MIP.Discoveries.R8_Agent8_BrentParallelInterventionBound.brent_amdahl_multi_agent_intervention
    - MIP.Discoveries.R8_Agent6_CooperativeGameXiBound.cooperative_surplus_nonneg_xi_bounded_floored
    - MIP.Discoveries.R9_Agent1_QuestionerOptimality.optimal_questioner

  Zero `sorry`/`admit`; NO new axiom (framework axioms reached only transitively
  through the imported tower).
-/
import MIP.Discoveries.R5_Agent4_TensorOhmBudget
import MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal
import MIP.Discoveries.R5_Agent8_MixtureFanoCoverage
import MIP.Discoveries.R8_Agent8_BrentParallelInterventionBound
import MIP.Discoveries.R8_Agent6_CooperativeGameXiBound
import MIP.Discoveries.R9_Agent1_QuestionerOptimality

namespace MIP

open scoped BigOperators

namespace R10_Agent8_MasterMultiAgent

open MIP.R6_Agent5_MultiAgentBudgetTerminal (jointBudget allWallBudget)
open MIP.R9_Agent1_QuestionerOptimality
open MIP.OutOfFrameQuestioner

/-! ## The master bundle.

`MasterMultiAgent` packages the six tower headline conclusions as fields, over a
single committee carrier `ι` shared by the tensor and mixture faces.  Each field
is the verbatim conclusion type of the corresponding tower theorem; the
constructor lemma `master_multi_agent` discharges every field by the matching
tower proof term, which is the honest assembly. -/

/-- **The master multi-agent bundle.**  Its six fields are the headline
conclusions of R5_Agent4, R6_Agent5, R5_Agent8, R8_Agent8, R8_Agent6, R9_Agent1
respectively, over a single shared committee setting. -/
structure MasterMultiAgent
    {α Ω : Type} [Fintype Ω] {ι : Type} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)] {Mtype : Type*}
    -- tensor face (R5_Agent4 / R6_Agent5 / R8_Agent8)
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    -- mixture face (R5_Agent8 / R8_Agent6 / R9_Agent1)
    (w N logCardM : ι → ℝ) (πmix : ι → Ω → ℝ) (Phi0 cardMmax : ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    -- Brent parallel side-data (R8_Agent8)
    (k : ℕ) (Tk L : ℝ) (Lnat Tknat : ℕ)
    -- cooperative-surplus side-data (R8_Agent6)
    (δ_AH δ_HA σ Nbi Nf Nb ξ Φ₀Z δstep : ℝ)
    -- questioner side-data (R9_Agent1)
    (Xsolver : Agent α)
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (N_novice N_expert Cstar εexp kstep : ℝ)
    (hY hY' cproj : Str α) (ωs ωs' : List Ω)
    (bsel : ι) : Prop where
  /-- (1) R5_Agent4 — joint Ohm budget subadditivity (tensor conservation). -/
  ohm_subadditive : Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊
  /-- (2) R6_Agent5 — terminal all-wall absorption in ℕ∞ (T1–T4). -/
  terminal_allwall :
    (∀ (walled : ι → Prop) [DecidablePred walled], (∀ a, ¬ walled a) →
        jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) ≠ (⊤ : ℕ∞)
        ∧ (Njoint : ℕ∞) ≤ jointBudget walled (fun a => ⌈Z * Mφ a⌉₊))
    ∧ (∀ (walled : ι → Prop) [DecidablePred walled] (b : ι), walled b →
        jointBudget walled (fun a => ⌈Z * Mφ a⌉₊) = (⊤ : ℕ∞))
    ∧ ((∀ B B' : ι → ℕ∞, (∀ a, B a ≤ B' a) → (∑ a, B a) ≤ ∑ a, B' a)
        ∧ (∀ B : ι → ℕ∞, (∑ a, B a) ≤ ∑ a, (allWallBudget : ι → ℕ∞) a)
        ∧ (∑ a, (allWallBudget : ι → ℕ∞) a) = (⊤ : ℕ∞))
    ∧ (∀ {α' Ω' : Type} (p : MIP.Problem α') (Xg : MIP.Agent α'),
        MIP.R4_Agent9_ScalingSaturationWall.IsOOD (Ω := Ω') (p, Xg) →
          MIP.N p Xg = (⊤ : ℕ∞))
  /-- (3) R5_Agent8 — committee Fano coverage floor + min/mixture + certificate. -/
  fano_committee :
    (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ N bsel)
    ∧ (∑ ω, (∑ a, w a * πmix a ω) = 1)
  /-- (4) R8_Agent8 — Brent floor + Amdahl cap + envelope + ℕ Brent floor. -/
  brent_amdahl :
    (max L ((Njoint : ℝ) / (k : ℝ)) ≤ Tk)
    ∧ ((Njoint : ℝ) / Tk ≤ (Njoint : ℝ) / L)
    ∧ (Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊)
    ∧ (Lnat ≤ Tknat ∧ Njoint ≤ k * Tknat)
  /-- (5) R8_Agent6 — cooperative surplus: nonneg + Xi bound + potential cap + floor. -/
  cooperative_surplus :
    (0 ≤ σ)
    ∧ (Nbi ^ 2 ≤ Nf * Nb / (1 + ξ))
    ∧ (Nbi ≤ Φ₀Z / δstep)
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)
    ∧ (∑ ω, (∑ a, w a * πmix a ω) = 1)
  /-- (6) R9_Agent1 — floored questioner optimality: strict reduction + expert
  advantage + anonymity + Fano floor. -/
  questioner_optimal :
    (HasEffective gain MYout ∧ ¬ HasEffective gain MYself)
    ∧ (N_novice ≤ Cstar * N_expert * Real.log (1 / εexp) + N_expert)
    ∧ (Xsolver hY = Xsolver hY')
    ∧ (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)

/-! ## The grand assembly — every field discharged by its tower theorem. -/

/-- **HEADLINE — `master_multi_agent`.**

The master multi-agent theorem: under ONE jointly-compatible committee setting
(tensor face + mixture face + Brent/cooperative/questioner side-data), the six
tower headline conclusions hold SIMULTANEOUSLY.  Each field of the bundle is
discharged by the corresponding tower theorem invoked as a proof term:

  · `ohm_subadditive`     ← R5_Agent4 `multi_agent_ohm_budget_law`
  · `terminal_allwall`    ← R6_Agent5 `all_wall_is_terminal_multiagent_budget`
  · `fano_committee`      ← R5_Agent8 `mixture_committee_fano`
  · `brent_amdahl`        ← R8_Agent8 `brent_amdahl_multi_agent_intervention`
  · `cooperative_surplus` ← R8_Agent6 `cooperative_surplus_nonneg_xi_bounded_floored`
  · `questioner_optimal`  ← R9_Agent1 `optimal_questioner`

The two committee faces share the SAME finite index `ι`; the hypotheses are
jointly satisfiable (see `master_multi_agent_witness`). -/
theorem master_multi_agent
    {α Ω : Type} [Fintype Ω] {ι : Type} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    {κ : ι → Type} [∀ a, Fintype (κ a)] {Mtype : Type*}
    (π : ∀ a, κ a → ℝ) (φ : ∀ a, κ a → ℝ) (Mφ : ι → ℝ)
    (Φjoint Z : ℝ) (Njoint : ℕ)
    (w N logCardM : ι → ℝ) (πmix : ι → Ω → ℝ) (Phi0 cardMmax : ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (k : ℕ) (Tk L : ℝ) (Lnat Tknat : ℕ)
    (δ_AH δ_HA σ Nbi Nf Nb ξ Φ₀Z δstep : ℝ)
    (Xsolver : Agent α)
    (gain : Mtype → ℝ) (inFrame : Mtype → Prop)
    (m₁ : Mtype) (MYout MYself : Mtype → Prop)
    (N_novice N_expert Cstar εexp kstep : ℝ)
    (hY hY' cproj : Str α) (ωs ωs' : List Ω)
    (bsel : ι)
    -- tensor-face hypotheses (R5_Agent4 / R6_Agent5 / R8_Agent8)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ a j, 0 ≤ π a j)
    (hπ_sum : ∀ a, ∑ j, π a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_def : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π a (x a)) * (∑ b, φ b (x b)))
    (h_ohm : Njoint = ⌈Z * Φjoint⌉₊)
    -- mixture-face hypotheses (R5_Agent8 / R8_Agent6 / R9_Agent1)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hπmix : ∀ a, ∑ ω, πmix a ω = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a)
    -- Brent inputs (R8_Agent8)
    (hk : 0 < (k : ℝ))
    (hL_pos : 0 < L) (hspan : L ≤ Tk)
    (hwork : (Njoint : ℝ) ≤ (k : ℝ) * Tk)
    (f : Fin Lnat → Fin Tknat) (hf : Function.Injective f)
    (hwork_nat : Njoint ≤ k * Tknat)
    -- cooperative-surplus inputs (R8_Agent6)
    (h_σ_def : σ = δ_AH + δ_HA) (h_AH : 0 ≤ δ_AH) (h_HA : 0 ≤ δ_HA)
    (hNbi : 0 < Nbi) (hNf : 0 < Nf) (hNb : 0 < Nb)
    (hξ : 0 ≤ ξ) (hStruct : Nbi ^ 2 * (1 + ξ) ≤ Nf * Nb)
    (hδstep : 0 < δstep) (hAcc : Nbi * δstep ≤ Φ₀Z)
    -- questioner inputs (R9_Agent1)
    (hLF : ∀ m, ¬ inFrame m → gain m ≤ 0)
    (h₁_mem : MYout m₁) (h₁_inframe : inFrame m₁) (h₁_pos : 0 < gain m₁)
    (h_self_out : ∀ m, MYself m → ¬ inFrame m)
    (h_decomp : N_novice ≤ kstep + N_expert)
    (h_sim : kstep ≤ Cstar * N_expert * Real.log (1 / εexp))
    (hOut : ∀ ω ∈ ωs, ω ∉ (K Xsolver : Set Ω))
    (hOut' : ∀ ω ∈ ωs', ω ∉ (K Xsolver : Set Ω))
    (hProj : cproj = QuestionerAnonymity.replaceOutside hY ωs)
    (hProj' : cproj = QuestionerAnonymity.replaceOutside hY' ωs') :
    MasterMultiAgent (α := α) (Ω := Ω) (ι := ι) (κ := κ) (Mtype := Mtype)
      π φ Mφ Φjoint Z Njoint
      w N logCardM πmix Phi0 cardMmax hne
      k Tk L Lnat Tknat
      δ_AH δ_HA σ Nbi Nf Nb ξ Φ₀Z δstep
      Xsolver gain inFrame m₁ MYout MYself
      N_novice N_expert Cstar εexp kstep
      hY hY' cproj ωs ωs' bsel where
  -- (1) R5_Agent4
  ohm_subadditive :=
    R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm
  -- (2) R6_Agent5
  terminal_allwall :=
    R6_Agent5_MultiAgentBudgetTerminal.all_wall_is_terminal_multiagent_budget
      π φ Mφ Φjoint Z Njoint hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm
  -- (3) R5_Agent8
  fano_committee :=
    R5_Agent8_MixtureFanoCoverage.mixture_committee_fano
      w N logCardM πmix Phi0 cardMmax hne hw_nonneg hw_sum hπmix
      hN_nonneg hcap_nonneg hcardMmax hcap_le hfano bsel
  -- (4) R8_Agent8
  brent_amdahl :=
    R8_Agent8_BrentParallelInterventionBound.brent_amdahl_multi_agent_intervention
      π φ Mφ Φjoint Z Njoint k Tk L Lnat Tknat
      hZ_nonneg hπ_nonneg hπ_sum h_env h_def h_ohm
      hk hL_pos hspan hwork f hf hwork_nat
  -- (5) R8_Agent6
  cooperative_surplus :=
    R8_Agent6_CooperativeGameXiBound.cooperative_surplus_nonneg_xi_bounded_floored
      δ_AH δ_HA σ h_σ_def h_AH h_HA
      Nbi Nf Nb ξ Φ₀Z δstep hNbi hNf hNb hξ hStruct hδstep hAcc
      w N logCardM πmix Phi0 cardMmax hne hw_nonneg hw_sum hπmix
      hN_nonneg hcap_nonneg hcardMmax hcap_le hfano bsel
  -- (6) R9_Agent1
  questioner_optimal :=
    R9_Agent1_QuestionerOptimality.optimal_questioner
      Xsolver hne w N logCardM Phi0 cardMmax
      hw_nonneg hw_sum hN_nonneg hcap_nonneg hcardMmax hcap_le hfano
      gain inFrame m₁ MYout MYself hLF h₁_mem h₁_inframe h₁_pos h_self_out
      N_novice N_expert Cstar εexp kstep h_decomp h_sim
      hY hY' cproj ωs ωs' hOut hOut' hProj hProj'

/-! ## Satisfiability witness — the master hypotheses are NON-VACUOUS.

We instantiate the entire bundle at the trivial one-point committee
`ι = Fin 1`, `κ = fun _ => Fin 1`, `Ω = Fin 1`, `α = Fin 1`, with one-point
distributions (`π ≡ 1`, `w ≡ 1`, `πmix ≡ 1`), all potentials zero, `cardMmax = 2`
(so `1 < cardMmax`, `Real.log cardMmax > 0`), and `Z = 0`, `Φjoint = 0`,
`Njoint = 0`.  This proves the master hypothesis bundle is JOINTLY satisfiable,
hence `master_multi_agent` is non-vacuous. -/

/-- **Satisfiability witness for the master bundle.**  A concrete instance at the
one-point committee discharging every hypothesis of `master_multi_agent`,
certifying the bundle is non-vacuous. -/
theorem master_multi_agent_witness :
    MasterMultiAgent (α := Fin 1) (Ω := Fin 1) (ι := Fin 1)
      (κ := fun _ => Fin 1) (Mtype := Fin 1)
      (π := fun _ _ => (1 : ℝ)) (φ := fun _ _ => (0 : ℝ)) (Mφ := fun _ => (0 : ℝ))
      (Φjoint := 0) (Z := 0) (Njoint := 0)
      (w := fun _ => (1 : ℝ)) (N := fun _ => (1 : ℝ)) (logCardM := fun _ => (0 : ℝ))
      (πmix := fun _ _ => (1 : ℝ)) (Phi0 := 0) (cardMmax := 2)
      (hne := ⟨0, Finset.mem_univ 0⟩)
      (k := 1) (Tk := 1) (L := 1) (Lnat := 0) (Tknat := 1)
      (δ_AH := 0) (δ_HA := 0) (σ := 0)
      (Nbi := 1) (Nf := 2) (Nb := 2) (ξ := 0) (Φ₀Z := 1) (δstep := 1)
      (Xsolver := fun _ => PMF.pure []) (gain := fun _ => (1 : ℝ))
      (inFrame := fun _ => True)
      (m₁ := 0) (MYout := fun _ => True) (MYself := fun _ => False)
      (N_novice := 0) (N_expert := 0) (Cstar := 0) (εexp := 1) (kstep := 0)
      (hY := []) (hY' := []) (cproj := []) (ωs := []) (ωs' := [])
      (bsel := 0) := by
  have hcard2 : (1 : ℝ) < 2 := by norm_num
  have hlog2pos : 0 < Real.log 2 := Real.log_pos hcard2
  -- log (cardMmax) for cardMmax = 2 is positive; needed for the Fano floors.
  apply master_multi_agent
    (π := fun _ _ => (1 : ℝ)) (φ := fun _ _ => (0 : ℝ)) (Mφ := fun _ => (0 : ℝ))
    (Φjoint := 0) (Z := 0) (Njoint := 0)
    (w := fun _ => (1 : ℝ)) (N := fun _ => (1 : ℝ)) (logCardM := fun _ => (0 : ℝ))
    (πmix := fun _ _ => (1 : ℝ)) (Phi0 := 0) (cardMmax := 2)
    (k := 1) (Tk := 1) (L := 1) (Lnat := 0) (Tknat := 1)
    (δ_AH := 0) (δ_HA := 0) (σ := 0)
    (Nbi := 1) (Nf := 2) (Nb := 2) (ξ := 0) (Φ₀Z := 1) (δstep := 1)
    (Xsolver := fun _ => PMF.pure []) (gain := fun _ => (1 : ℝ))
    (inFrame := fun _ => True)
    (m₁ := 0) (MYout := fun _ => True) (MYself := fun _ => False)
    (N_novice := 0) (N_expert := 0) (Cstar := 0) (εexp := 1) (kstep := 0)
    (hY := []) (hY' := []) (cproj := []) (ωs := []) (ωs' := [])
    (bsel := 0)
  case hcap_le => intro a; exact Real.log_nonneg (by norm_num)
  all_goals
    first
    | exact hcard2
    | exact le_of_lt hlog2pos
    | exact Real.log_nonneg (by norm_num)
    | rfl
    | trivial
    | (exact fun x => x.elim0)
    | (exact fun a b _ => Subsingleton.elim a b)
    | norm_num

end R10_Agent8_MasterMultiAgent

end MIP
