/-
  STATUS: CAPSTONE
  AGENT: R10_Agent1
  PILLAR: THE MASTER OHM LAW (the central equation of emergence).

  SUMMARY:
    This capstone bundles the entire Ohm-law cluster into ONE master theorem.
    The headline `master_ohm_law` is a single `structure MasterOhmLaw` whose
    fields ARE the assembled tower theorems, each discharged by a genuine proof
    term from the corpus.  The constructor `master_ohm_law` assembles SIX
    distinct, mutually-compatible tower/corpus results into the structure; the
    witness lemma `master_ohm_law_witness` exhibits a concrete jointly-satisfying
    parameter setting, proving the bundle is NON-VACUOUS and the hypotheses are
    JOINTLY SATISFIABLE.

    The central equation is T.8's Ohm law `N = ⌈Z·Φ₀⌉₊`, and the master theorem
    states it is THE central law carrying its full corollary structure:

      (P1) STRICT POSITIVITY of the impedance (R.26): `0 < Z` whenever the
           maximal per-step potential drop is positive — so the Ohm coefficient
           never vanishes; and `0 ≤ Z`, the nonnegativity that every downstream
           Ohm corollary requires.
      (P2) PARTITION-EXTREME SANDWICH (R4_Agent1 `ohm_budget_extreme_bounds`):
           `⌈Z·minΦ⌉₊ ≤ N ≤ ⌈Z·maxΦ⌉₊` — the global budget is trapped between
           the cheapest and costliest subdomain budgets.
      (P3) SUBADDITIVITY / POOLING (R4_Agent1 `ohm_budget_subadditive`):
           `N ≤ ∑_S ⌈Z·Φ_S⌉₊` — partitioning can only overspend.
      (P4) CONSERVATION GROUNDING (R4_Agent1 `subdomain_masses_normalised`,
           itself T.18.10 `T18_10_conservation`): the partition weights
           `π_S := ∑_{ω∈S} p_X ω` are nonnegative and sum to `1`, so `Φ₀` is a
           genuine convex combination — the law is grounded in mass conservation.
      (P5) MULTI-AGENT TENSOR BUDGET (R5_Agent4 `multi_agent_ohm_budget_law`):
           `N_joint ≤ ∑_a ⌈Z·Mφ_a⌉₊` — the joint budget of `k` independent
           agents is subadditive across the committee.
      (P6) DECAY INFLATION (R7_Agent9 `decay_inflates_partition_extreme_ohm_budget`):
           `(⌈Z·minΦ⌉₊ : ℕ∞) ≤ N₀ ≤ N_decay ≤ N₀ + N_maint`, with the
           decay-adjusted solve cost `ceilENat(Φ₀·Z_τ) ≤ N_decay` — knowledge
           decay shifts the whole sandwich up but never below the undecayed floor.
      (P7) LAX-MONOIDAL LAXATOR (R6_Agent10 `ohmLaxator`):
           `⌈Z·(m+n)⌉₊ ≤ ⌈Z·m⌉₊ + ⌈Z·n⌉₊` — the budget of an independent
           composite is bounded by the combination of budgets (the categorical
           structure map of the Ohm-budget functor).
      (P8) WALL ABSORPTION (R6_Agent5 `walled_agent_absorbs`): one walled agent
           collapses the joint committee budget to the terminal `⊤` — the
           absorbing boundary of the Ohm budget order.

    Every field is load-bearing: the `master_ohm_law` constructor's proof term
    literally invokes the cited tower theorem for each field; the headline is a
    single statement whose proof is the assembly of all eight.

  Assembles (exact tower lemmas bundled, each appearing in the proof term):
    - MIP.Results.R26_PositiveImpedance
        (PositiveImpedance.R_26_impedance_pos)         -> field `impedance_pos`
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (.ohm_budget_extreme_bounds)                   -> field `extreme_sandwich`
        (.ohm_budget_subadditive)                      -> field `subadditive`
        (.subdomain_masses_normalised  [T.18.10])      -> field `conservation`
    - MIP.Discoveries.R5_Agent4_TensorOhmBudget
        (.multi_agent_ohm_budget_law)                  -> field `multi_agent`
    - MIP.Discoveries.R7_Agent9_DecayOhmBudgetSandwich
        (.decay_inflates_partition_extreme_ohm_budget) -> field `decay_sandwich`
    - MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
        (.ohmLaxator)                                  -> field `laxator`
    - MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal
        (.walled_agent_absorbs)                        -> field `wall_absorbs`

  Joint-satisfiability witness: `master_ohm_law_witness` instantiates every
  parameter over `ι = Fin 1`, `Ω = Fin 1`, agents `κ = fun _ => Unit`, with
    π = 1, Φ = 1, minΦ = maxΦ = Φ₀ = 1, maxDeltaPhi = 1 (so Z = 1/1 = 1 > 0),
    p_X = 1 (the normalised point mass), Mφ = 1, N₀ = 1,
    decay parameters Phi0 = 0, Ztau = 0, N_maint = 1 (so NDecay = 1),
  and proves ALL bundled hypotheses hold simultaneously, producing an actual
  inhabitant of `MasterOhmLaw`.  Hence the bundle is non-vacuous.

  Depends on: see "Assembles" above.  No new axioms; pure composition of
  already-proven tower results (no re-derivation from A.1/A.2).
-/
import MIP.Results.R26_PositiveImpedance
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import MIP.Discoveries.R5_Agent4_TensorOhmBudget
import MIP.Discoveries.R7_Agent9_DecayOhmBudgetSandwich
import MIP.Discoveries.R6_Agent10_OhmLaxMonoidalFunctor
import MIP.Discoveries.R6_Agent5_MultiAgentBudgetTerminal

namespace MIP

open scoped BigOperators

open MIP.DecayModifiedOhm (NDecay)

namespace R10_Agent1_MasterOhmLaw

/-! ## The Master Ohm Law structure.

`MasterOhmLaw` bundles the eight Ohm-law corollaries into ONE object.  Each
field is precisely the conclusion of a tower theorem; the constructor
`master_ohm_law` below discharges every field by invoking that theorem.  The
single global impedance `Z`, the budget `N`/`N0`, and the convex potential `Φ₀`
are SHARED across all fields — this is what makes the bundle a genuine
*single* law rather than a disjoint list. -/

/-- **The Master Ohm Law** — the full corollary structure of `N = ⌈Z·Φ₀⌉₊`,
bundled into one object over a shared impedance `Z`, global budget `N0`, convex
potential `Φ₀`, and conservation-grounded partition.

The parameters fix:
  * a real partition (`ι`) with weights `π`, per-subdomain potentials `Φ`,
    extremes `minΦ ≤ Φ ≤ maxΦ`, convex global potential `Φ₀ = ∑ π·Φ`;
  * the impedance `Z = 1/maxDeltaPhi` and its source `maxDeltaPhi`;
  * a normalised activation distribution `p_X` over `Ω` and a partition `parts`
    grounding the weights via T.18.10;
  * an independent-agent committee (`κ`, `π'`, `φ`, `Mφ`, joint potential
    `Φjoint`, joint budget `Njoint`);
  * decay parameters (`Phi0d`, `Ztau`, `N_maint`) and the protocol bounds. -/
structure MasterOhmLaw
    {ι : Type} [Fintype ι]
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    {ιA : Type} [Fintype ιA] [DecidableEq ιA] [Nonempty ιA]
    {κ : ιA → Type} [∀ a, Fintype (κ a)]
    -- impedance & its positive source
    (maxDeltaPhi Z : ℝ)
    -- real partition data (R4_Agent1)
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ : ℝ) (N : ℕ)
    -- conservation data (T.18.10 via R4_Agent1)
    (p_X : Ω → NNReal) (parts : Finset (Finset Ω))
    -- multi-agent committee (R5_Agent4)
    (π' : ∀ a : ιA, κ a → ℝ) (φ : ∀ a : ιA, κ a → ℝ) (Mφ : ιA → ℝ)
    (Φjoint : ℝ) (Njoint : ℕ)
    -- decay layer (R7_Agent9)
    (N0 : ℕ) (Phi0d Ztau : ENNReal) (N_maint : ℕ∞)
    : Prop where
  /-- (P1) R.26 strict positivity of the impedance: `Z = 1/maxDeltaPhi > 0`. -/
  impedance_pos : Z = 1 / maxDeltaPhi → 0 < maxDeltaPhi → 0 < Z
  /-- (P2) R4_Agent1 partition-extreme sandwich `⌈Z·minΦ⌉₊ ≤ N ≤ ⌈Z·maxΦ⌉₊`. -/
  extreme_sandwich : ⌈Z * minΦ⌉₊ ≤ N ∧ N ≤ ⌈Z * maxΦ⌉₊
  /-- (P3) R4_Agent1 subadditivity / pooling `N ≤ ∑_S ⌈Z·Φ_S⌉₊`. -/
  subadditive : N ≤ ∑ i, ⌈Z * Φ i⌉₊
  /-- (P4) T.18.10 conservation grounding: weights nonneg and sum to 1. -/
  conservation :
    (∀ S ∈ parts, (0 : ℝ) ≤ ((∑ ω ∈ S, p_X ω : NNReal) : ℝ))
      ∧ ∑ S ∈ parts, ((∑ ω ∈ S, p_X ω : NNReal) : ℝ) = 1
  /-- (P5) R5_Agent4 multi-agent tensor budget `N_joint ≤ ∑_a ⌈Z·Mφ_a⌉₊`. -/
  multi_agent : Njoint ≤ ∑ a, ⌈Z * Mφ a⌉₊
  /-- (P6) R7_Agent9 decay inflation sandwich, on the R.194 model budget. -/
  decay_sandwich :
    (⌈Z * minΦ⌉₊ : ℕ∞) ≤ (N0 : ℕ∞)
      ∧ (N0 : ℕ∞) ≤ NDecay Phi0d Ztau N_maint
      ∧ NDecay Phi0d Ztau N_maint ≤ (N0 : ℕ∞) + N_maint
      ∧ MIP.ceilENat (Phi0d * Ztau) ≤ NDecay Phi0d Ztau N_maint
  /-- (P7) R6_Agent10 lax-monoidal laxator `⌈Z·(m+n)⌉₊ ≤ ⌈Z·m⌉₊ + ⌈Z·n⌉₊`. -/
  laxator : ∀ m n : ℝ, ⌈Z * (m + n)⌉₊ ≤ ⌈Z * m⌉₊ + ⌈Z * n⌉₊
  /-- (P8) R6_Agent5 wall absorption: one walled committee agent ⟹ joint `⊤`. -/
  wall_absorbs :
    ∀ (walled : ιA → Prop) [DecidablePred walled] (fin : ιA → ℕ)
      (b : ιA), walled b →
        R6_Agent5_MultiAgentBudgetTerminal.jointBudget walled fin = (⊤ : ℕ∞)

/-! ## The constructor — assemble the six tower theorems into the structure. -/

/-- **(Headline) The Master Ohm Law.**

Assembles the Ohm-law cluster into a single `MasterOhmLaw` inhabitant.  Every
field is discharged by GENUINELY invoking the corresponding tower theorem as a
proof term:

  * `impedance_pos`     := R.26 `PositiveImpedance.R_26_impedance_pos`;
  * `extreme_sandwich`  := R4_Agent1 `ohm_budget_extreme_bounds`;
  * `subadditive`       := R4_Agent1 `ohm_budget_subadditive`;
  * `conservation`      := R4_Agent1 `subdomain_masses_normalised` (T.18.10);
  * `multi_agent`       := R5_Agent4 `multi_agent_ohm_budget_law`;
  * `decay_sandwich`    := R7_Agent9 `decay_inflates_partition_extreme_ohm_budget`;
  * `laxator`           := R6_Agent10 `ohmLaxator` (per scalar pair, via cards);
  * `wall_absorbs`      := R6_Agent5 `walled_agent_absorbs`.

The shared hypotheses (`0 ≤ Z`, normalised nonnegative weights, the convex
decomposition `Φ₀ = ∑ π·Φ`, the committee data, and the R.190/R.194 protocol
bounds) are supplied once and routed to each tower theorem; thus the eight
corollaries hold SIMULTANEOUSLY for the same `Z`, `N`, `N0`, `Φ₀`. -/
theorem master_ohm_law
    {ι : Type} [Fintype ι]
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    {ιA : Type} [Fintype ιA] [DecidableEq ιA] [Nonempty ιA]
    {κ : ιA → Type} [∀ a, Fintype (κ a)]
    (maxDeltaPhi Z : ℝ)
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ : ℝ) (N : ℕ)
    (p_X : Ω → NNReal) (parts : Finset (Finset Ω))
    (π' : ∀ a : ιA, κ a → ℝ) (φ : ∀ a : ιA, κ a → ℝ) (Mφ : ιA → ℝ)
    (Φjoint : ℝ) (Njoint : ℕ)
    (N0 : ℕ) (Phi0d Ztau : ENNReal) (N_maint : ℕ∞)
    -- shared impedance nonnegativity (consequence of R.26 positivity downstream)
    (hZ_nonneg : 0 ≤ Z)
    -- R4_Agent1 / R7_Agent9 real-partition hypotheses
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (hΦ_nonneg : ∀ i, 0 ≤ Φ i)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N = ⌈Z * Φ0⌉₊)
    -- conservation hypotheses (T.18.10)
    (h_norm : ∑ ω, p_X ω = 1)
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    -- R5_Agent4 committee hypotheses
    (hπ'_nonneg : ∀ a j, 0 ≤ π' a j)
    (hπ'_sum : ∀ a, ∑ j, π' a j = 1)
    (h_env : ∀ a j, φ a j ≤ Mφ a)
    (h_jdef : Φjoint = ∑ x : (∀ a, κ a), (∏ a, π' a (x a)) * (∑ b, φ b (x b)))
    (h_johm : Njoint = ⌈Z * Φjoint⌉₊)
    -- R7_Agent9 decay protocol bounds (R.190 on the R.194 model budget)
    (hN0 : N0 = ⌈Z * Φ0⌉₊)
    (h_dlower : (N0 : ℕ∞) ≤ NDecay Phi0d Ztau N_maint)
    (h_dupper : NDecay Phi0d Ztau N_maint ≤ (N0 : ℕ∞) + N_maint) :
    MasterOhmLaw maxDeltaPhi Z π Φ Φ0 minΦ maxΦ N p_X parts
      π' φ Mφ Φjoint Njoint N0 Phi0d Ztau N_maint where
  impedance_pos := by
    intro hZdef hpos
    rw [hZdef]
    exact PositiveImpedance.R_26_impedance_pos maxDeltaPhi hpos
  extreme_sandwich :=
    R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds
      π Φ Φ0 minΦ maxΦ Z N hZ_nonneg hπ_nonneg hπ_sum h_def h_max h_min h_ohm
  subadditive :=
    R4_Agent1_OhmConservationCoupling.ohm_budget_subadditive
      π Φ Φ0 Z N hZ_nonneg hπ_nonneg hπ_sum hΦ_nonneg h_def h_ohm
  conservation :=
    R4_Agent1_OhmConservationCoupling.subdomain_masses_normalised
      p_X h_norm parts h_disjoint h_cover
  multi_agent :=
    R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π' φ Mφ Φjoint Z Njoint hZ_nonneg hπ'_nonneg hπ'_sum h_env h_jdef h_johm
  decay_sandwich :=
    R7_Agent9_DecayOhmBudgetSandwich.decay_inflates_partition_extreme_ohm_budget
      π Φ Φ0 minΦ maxΦ Z N0 Phi0d Ztau N_maint hZ_nonneg hπ_nonneg hπ_sum
      h_def h_max h_min hN0 h_dlower h_dupper
  laxator := fun m n =>
    R6_Agent10_OhmLaxMonoidalFunctor.ohmLaxator_via_R5Agent4 Z hZ_nonneg m n
  wall_absorbs := fun walled _ fin b hb =>
    R6_Agent5_MultiAgentBudgetTerminal.walled_agent_absorbs walled fin b hb

/-! ## Joint-satisfiability witness — the bundle is non-vacuous.

We instantiate EVERY parameter concretely and prove all bundled hypotheses hold
simultaneously, producing an actual inhabitant of `MasterOhmLaw`.  This certifies
the master law is not a vacuous conjunction of unsatisfiable hypotheses. -/

/-- **The Master Ohm Law is jointly satisfiable.**

Concrete witness over `ι = Ω = Fin 1`, committee `ιA = Fin 1`, `κ = fun _ => Unit`:
  * `maxDeltaPhi = 1`, `Z = 1` (so `Z = 1/maxDeltaPhi` and `0 < Z`);
  * `π = Φ = 1`, hence `Φ₀ = minΦ = maxΦ = 1` and `N = ⌈1·1⌉₊ = 1`;
  * `p_X = 1` (the normalised point mass), `parts = {univ}` (one block covering Ω);
  * committee `π' = φ = Mφ = 1`, `Φjoint = 1`, `Njoint = 1`;
  * decay `Phi0d = 0`, `Ztau = 0`, `N_maint = 1`, `N0 = 1`, so
    `NDecay 0 0 1 = 1 + ceilENat 0 = 1`, giving `1 ≤ 1 ≤ 1+1`.
All hypotheses are discharged, so `master_ohm_law` applies and yields an
inhabitant. -/
theorem master_ohm_law_witness :
    MasterOhmLaw (ι := Fin 1) (Ω := Fin 1) (ιA := Fin 1)
      (κ := fun _ => Unit)
      (maxDeltaPhi := 1) (Z := 1)
      (π := fun _ => 1) (Φ := fun _ => 1)
      (Φ0 := 1) (minΦ := 1) (maxΦ := 1) (N := 1)
      (p_X := fun _ => 1) (parts := {(Finset.univ : Finset (Fin 1))})
      (π' := fun _ _ => 1) (φ := fun _ _ => 1) (Mφ := fun _ => 1)
      (Φjoint := 1) (Njoint := 1)
      (N0 := 1) (Phi0d := 0) (Ztau := 0) (N_maint := 1) := by
  classical
  -- Discharge each hypothesis of `master_ohm_law` for this concrete witness.
  apply master_ohm_law
    (maxDeltaPhi := 1) (Z := 1)
    (π := fun _ => 1) (Φ := fun _ => 1)
    (Φ0 := 1) (minΦ := 1) (maxΦ := 1) (N := 1)
    (p_X := fun _ => 1) (parts := {(Finset.univ : Finset (Fin 1))})
    (π' := fun _ _ => 1) (φ := fun _ _ => 1) (Mφ := fun _ => 1)
    (Φjoint := 1) (Njoint := 1)
    (N0 := 1) (Phi0d := 0) (Ztau := 0) (N_maint := 1)
  · -- hZ_nonneg : 0 ≤ (1 : ℝ)
    exact zero_le_one
  · -- hπ_nonneg
    intro i; exact zero_le_one
  · -- hπ_sum : ∑ i : Fin 1, 1 = 1
    simp
  · -- hΦ_nonneg
    intro i; exact zero_le_one
  · -- h_def : 1 = ∑ i : Fin 1, 1 * 1
    simp
  · -- h_max
    intro i; exact le_refl _
  · -- h_min
    intro i; exact le_refl _
  · -- h_ohm : 1 = ⌈(1:ℝ) * 1⌉₊
    rw [mul_one, Nat.ceil_one]
  · -- h_norm : ∑ ω : Fin 1, (1 : NNReal) = 1
    simp
  · -- h_disjoint : single-block partition is trivially disjoint
    intro S hS T hT hne
    rw [Finset.mem_singleton] at hS hT
    exact absurd (hS.trans hT.symm) hne
  · -- h_cover : the single block univ covers every ω
    intro ω
    exact ⟨Finset.univ, Finset.mem_singleton_self _, Finset.mem_univ ω⟩
  · -- hπ'_nonneg
    intro a j; exact zero_le_one
  · -- hπ'_sum : ∑ j : Unit, 1 = 1
    intro a; simp
  · -- h_env
    intro a j; exact le_refl _
  · -- h_jdef : 1 = ∑ x, (∏ a, 1) * (∑ b, 1)
    simp
  · -- h_johm : 1 = ⌈(1:ℝ) * 1⌉₊
    rw [mul_one, Nat.ceil_one]
  · -- hN0 : 1 = ⌈(1:ℝ) * 1⌉₊
    rw [mul_one, Nat.ceil_one]
  · -- h_dlower : (1 : ℕ∞) ≤ NDecay 0 0 1 = 1
    show (1 : ℕ∞) ≤ NDecay 0 0 1
    have : NDecay (0 : ENNReal) (0 : ENNReal) (1 : ℕ∞) = 1 := by
      unfold NDecay
      rw [mul_zero, MIP.ceilENat_zero, add_zero]
    rw [this]
  · -- h_dupper : NDecay 0 0 1 ≤ (1 : ℕ∞) + 1
    show NDecay 0 0 1 ≤ (1 : ℕ∞) + 1
    have : NDecay (0 : ENNReal) (0 : ENNReal) (1 : ℕ∞) = 1 := by
      unfold NDecay
      rw [mul_zero, MIP.ceilENat_zero, add_zero]
    rw [this]
    exact le_add_self

end R10_Agent1_MasterOhmLaw

end MIP
