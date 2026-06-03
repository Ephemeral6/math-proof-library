/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: For distinct agents `X ≠ Y`, `B_data p X` and `B_data p Y`
    are disjoint, and similarly across distinct problems.
  SUMMARY:
    Agent 4 proved that `b_synth` is jointly injective in `(X, p, i)`.
    Combined with the projection of every member of `B_data p X` to
    `b.s_pre.agent = X`, this forces `B_data p X ∩ B_data p Y = ∅`
    whenever `X ≠ Y` (and similarly for distinct problems). Equivalently,
    the barrier sets across distinct agents form an orthogonal
    decomposition. As a corollary, `|B_data p X ∪ B_data p Y|
    = (N p X).toNat + (N p Y).toNat` (no double counting).
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Image

namespace MIP

namespace R2_Agent9_BData_OrthogonalAcrossAgents

variable {α : Type}

/-! ## (1) Every member of `B_data p X` has `s_pre.agent = X`. -/

/-- **Agent projection.** For every `b ∈ B_data p X`, `b.s_pre.agent = X`. -/
theorem B_data_mem_s_pre_agent (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) :
    b.s_pre.agent = X := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  rw [← heq]
  rfl

/-- **Problem projection.** For every `b ∈ B_data p X`, `b.s_pre.problem = p`. -/
theorem B_data_mem_s_pre_problem (p : Problem α) (X : Agent α) (b : BarrierData α)
    (hb : b ∈ B_data p X) :
    b.s_pre.problem = p := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  rw [← heq]
  rfl

/-! ## (2) Orthogonality across distinct agents. -/

/-- **Orthogonality across agents.** For distinct agents `X ≠ Y`,
the barrier sets `B_data p X` and `B_data p Y` are disjoint. -/
theorem B_data_disjoint_of_agent_ne (p : Problem α) (X Y : Agent α)
    (hXY : X ≠ Y) :
    Disjoint (B_data p X) (B_data p Y) := by
  rw [Finset.disjoint_left]
  intro b hbX hbY
  have hX : b.s_pre.agent = X := B_data_mem_s_pre_agent p X b hbX
  have hY : b.s_pre.agent = Y := B_data_mem_s_pre_agent p Y b hbY
  exact hXY (hX.symm.trans hY)

/-- **Orthogonality (intersection form).** For distinct agents, the
intersection of barrier sets is empty. -/
theorem B_data_inter_eq_empty_of_agent_ne (p : Problem α) (X Y : Agent α)
    (hXY : X ≠ Y) :
    B_data p X ∩ B_data p Y = ∅ := by
  rw [← Finset.disjoint_iff_inter_eq_empty]
  exact B_data_disjoint_of_agent_ne p X Y hXY

/-! ## (3) Orthogonality across distinct problems. -/

/-- **Orthogonality across problems.** For distinct problems `p ≠ q`,
`B_data p X` and `B_data q X` are disjoint. -/
theorem B_data_disjoint_of_problem_ne (X : Agent α) (p q : Problem α)
    (hpq : p ≠ q) :
    Disjoint (B_data p X) (B_data q X) := by
  rw [Finset.disjoint_left]
  intro b hbp hbq
  have hp : b.s_pre.problem = p := B_data_mem_s_pre_problem p X b hbp
  have hq : b.s_pre.problem = q := B_data_mem_s_pre_problem q X b hbq
  exact hpq (hp.symm.trans hq)

/-- **Orthogonality across problems (intersection form).** -/
theorem B_data_inter_eq_empty_of_problem_ne (X : Agent α) (p q : Problem α)
    (hpq : p ≠ q) :
    B_data p X ∩ B_data q X = ∅ := by
  rw [← Finset.disjoint_iff_inter_eq_empty]
  exact B_data_disjoint_of_problem_ne X p q hpq

/-! ## (4) Cardinality of unions for distinct agents. -/

/-- **Cardinality of the union for distinct agents.** For `X ≠ Y`,
`|B_data p X ∪ B_data p Y| = (N p X).toNat + (N p Y).toNat`. -/
theorem B_data_union_card_of_agent_ne (p : Problem α) (X Y : Agent α)
    (hXY : X ≠ Y) :
    (B_data p X ∪ B_data p Y).card = (N p X).toNat + (N p Y).toNat := by
  have hDisj : Disjoint (B_data p X) (B_data p Y) :=
    B_data_disjoint_of_agent_ne p X Y hXY
  rw [Finset.card_union_of_disjoint hDisj]
  have hXcard : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hYcard : (B_data p Y).card = (N p Y).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective Y p)]
    exact Finset.card_range _
  rw [hXcard, hYcard]

/-- **Cardinality of the union for distinct problems.** -/
theorem B_data_union_card_of_problem_ne (X : Agent α) (p q : Problem α)
    (hpq : p ≠ q) :
    (B_data p X ∪ B_data q X).card = (N p X).toNat + (N q X).toNat := by
  have hDisj : Disjoint (B_data p X) (B_data q X) :=
    B_data_disjoint_of_problem_ne X p q hpq
  rw [Finset.card_union_of_disjoint hDisj]
  have hpcard : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hqcard : (B_data q X).card = (N q X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X q)]
    exact Finset.card_range _
  rw [hpcard, hqcard]

/-! ## (5) Three-way orthogonality (corollary). -/

/-- **Three-way orthogonality.** When `X`, `Y`, `Z` are pairwise distinct
agents, `|B_data p X ∪ B_data p Y ∪ B_data p Z|
= (N p X).toNat + (N p Y).toNat + (N p Z).toNat`. -/
theorem B_data_union_card_three (p : Problem α) (X Y Z : Agent α)
    (hXY : X ≠ Y) (hXZ : X ≠ Z) (hYZ : Y ≠ Z) :
    (B_data p X ∪ B_data p Y ∪ B_data p Z).card
      = (N p X).toNat + (N p Y).toNat + (N p Z).toNat := by
  -- (B_data p X ∪ B_data p Y) is disjoint from B_data p Z
  have hXYDisj : Disjoint (B_data p X) (B_data p Y) :=
    B_data_disjoint_of_agent_ne p X Y hXY
  have hXZDisj : Disjoint (B_data p X) (B_data p Z) :=
    B_data_disjoint_of_agent_ne p X Z hXZ
  have hYZDisj : Disjoint (B_data p Y) (B_data p Z) :=
    B_data_disjoint_of_agent_ne p Y Z hYZ
  have hUnionDisj : Disjoint (B_data p X ∪ B_data p Y) (B_data p Z) := by
    rw [Finset.disjoint_union_left]
    exact ⟨hXZDisj, hYZDisj⟩
  rw [Finset.card_union_of_disjoint hUnionDisj]
  rw [Finset.card_union_of_disjoint hXYDisj]
  have hXcard : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hYcard : (B_data p Y).card = (N p Y).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective Y p)]
    exact Finset.card_range _
  have hZcard : (B_data p Z).card = (N p Z).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective Z p)]
    exact Finset.card_range _
  rw [hXcard, hYcard, hZcard]

end R2_Agent9_BData_OrthogonalAcrossAgents

end MIP
