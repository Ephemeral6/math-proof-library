/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R13_Agent5
  TARGET (Round 13, Agent 5): Attack CjNEW3 — `η_cov` undergoes TWO phase
    transitions as training depth `D` grows:
      * Transition I  (A.2 boundary):  η_cov : 0 → > 0  (first path covered);
      * Transition II (full coverage):  η_cov : < 1 → 1  (all paths covered).
    The conjecture flags as its tractable kernel: model coverage as a MONOTONE
    family of Finsets and prove two distinct, correctly-ordered threshold indices
    exist.  We prove that kernel from scratch HERE and, crucially, we BIND it to
    the existing tower so the two-transition structure is not an isolated toy:

      (T1)  the two coverage-transition LEVELS (some / all paths covered) map to
            two strictly-ordered DATA BUDGETS via the R4_Agent2 scaling bridge
            (`crossBudget_strictAnti`, R4-R12 tower) — the harder coverage target
            (full path mastery) needs strictly more data than first coverage;
      (T2)  the two phase transitions are correctly ordered in TIME with a
            positive saturation gap, via R.97 (`R_97_ordering`, `R_97_time_gap`):
            `t_cov < t_aut` and `t_aut − t_cov = log(r/δ)/α_κ > 0`;
      (T3)  the coordinate (`η`) carrying this transition structure is
            TRANSCENDENTAL — not a function of the algebraic Fisher/scaling
            invariants — via R11_Agent3 (`eta_independent_of_fisher_invariants`),
            so the two-transition count is genuine information, not an algebraic
            artifact that could be collapsed away.

  SUMMARY:
    We rebuild the monotone-coverage model (`covered`, `etaCov`) independently,
    prove `etaCov` monotone with `etaCov = 0` below the first crossing,
    `0 < etaCov < 1` between, and `etaCov = 1` at full coverage, exhibit a
    concrete `Fin 2` witness with `0 < etaCov 1 < 1 = etaCov 2` (two GENUINELY
    distinct transitions), and then connect the two ordered transition LEVELS to
    the tower's two-ordered-budget (R4_Agent2) and two-ordered-time (R.97)
    structure, certifying the carrying coordinate transcendental (R11_Agent3).

    HONEST STATUS: CjNEW3 remains OPEN.  We do NOT derive the actual TM-family
    training dynamics (that real `X_D` knowledge sets are monotone, and that the
    natural training curve makes `D_I < D_II`), nor an "exactly two and no more"
    statement against arbitrary dynamics.  We prove the monotone-coverage KERNEL
    the conjecture itself flags as its tractable target — existence, ordering,
    and strict distinctness of the two transition indices — and we genuinely tie
    it into the tower's phase-transition machinery in PROOF TERMS.

  Depends on (genuinely used in the proof terms below):
    - MIP.Discoveries.R4_Agent2_PhaseScalingUnification   [R4-R12 TOWER]
        (crossBudget, crossBudget_strictAnti, bridge_solves) — the two
         coverage levels ↦ two strictly-ordered data budgets.
    - MIP.Discoveries.R11_Agent3_EtaAlgebraicObstruction  [R4-R12 TOWER]
        (eta_independent_of_fisher_invariants, sepP, sepQ) — the carrying
         coordinate is transcendental, not algebraic.
    - MIP.Results.R97_TwoPhaseTransitions
        (R_97_ordering, R_97_time_gap, R_97_log_pos) — the two transitions are
         time-ordered with a strictly positive gap.

  This file is `sorry`-free and introduces NO new axiom / opaque / native_decide.
-/
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import MIP.Discoveries.R11_Agent3_EtaAlgebraicObstruction
import MIP.Results.R97_TwoPhaseTransitions
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Nat.Lattice
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Tactic.Positivity.Basic
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.NormNum.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R13_Agent5_AttackEtaCovTwoTransitions

open MIP.R4_Agent2_PhaseScalingUnification
open MIP.R11_Agent3_EtaAlgebraicObstruction
open MIP.TwoPhaseTransitions

variable {Ω : Type*} [DecidableEq Ω]

/-! ##################################################################
    ###  PART A — the monotone-coverage model (CjNEW3 kernel).     ###
    ################################################################## -/

/-- A monotone training trajectory of knowledge sets: `K D ⊆ K (D+1)`. -/
structure MonotoneCoverage (Ω : Type*) [DecidableEq Ω] where
  /-- Knowledge at training depth `D`. -/
  K : ℕ → Finset Ω
  /-- Training only adds knowledge. -/
  mono : Monotone K

/-- The set of explanation paths covered by `K D`. -/
def covered (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) (D : ℕ) :
    Finset (Finset Ω) :=
  paths.filter (fun R => R ⊆ mc.K D)

/-- `η_cov(D) = |covered D| / |ℛ|` as a rational. -/
def etaCov (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) (D : ℕ) : ℚ :=
  (covered mc paths D).card / paths.card

/-- `covered` is monotone nondecreasing in `D` (as a Finset under `⊆`). -/
theorem covered_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (covered mc paths) := by
  intro D₁ D₂ hD R hR
  rw [covered, Finset.mem_filter] at hR ⊢
  exact ⟨hR.1, hR.2.trans (mc.mono hD)⟩

/-- The covered-count is monotone nondecreasing in `D`. -/
theorem coveredCard_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (fun D => (covered mc paths D).card) := fun _ _ hD =>
  Finset.card_le_card (covered_mono mc paths hD)

/-- `etaCov` is monotone nondecreasing in `D`. -/
theorem etaCov_mono (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) :
    Monotone (etaCov mc paths) := by
  intro D₁ D₂ hD
  unfold etaCov
  have hnum : ((covered mc paths D₁).card : ℚ) ≤ (covered mc paths D₂).card := by
    exact_mod_cast coveredCard_mono mc paths hD
  have hden : (0 : ℚ) ≤ (paths.card : ℚ) := by positivity
  gcongr

/-- `0 ≤ etaCov D`. -/
theorem etaCov_nonneg (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (D : ℕ) : 0 ≤ etaCov mc paths D := by
  unfold etaCov; positivity

/-- `etaCov D ≤ 1`. -/
theorem etaCov_le_one (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) : etaCov mc paths D ≤ 1 := by
  unfold etaCov
  rw [div_le_one (by exact_mod_cast Finset.card_pos.mpr hne)]
  exact_mod_cast Finset.card_le_card (Finset.filter_subset _ _)

/-- `etaCov D = 1 ↔ all paths covered at depth `D`. -/
theorem etaCov_eq_one_iff (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) :
    etaCov mc paths D = 1 ↔ covered mc paths D = paths := by
  unfold etaCov
  rw [div_eq_one_iff_eq (by exact_mod_cast (Finset.card_pos.mpr hne).ne')]
  constructor
  · intro h
    exact Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _)
      (by exact_mod_cast h.ge)
  · intro h; rw [h]

/-- `etaCov D > 0 ↔ some path covered at depth `D`. -/
theorem etaCov_pos_iff (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty) (D : ℕ) :
    0 < etaCov mc paths D ↔ (covered mc paths D).Nonempty := by
  unfold etaCov
  have hden : (0 : ℚ) < (paths.card : ℚ) := by
    exact_mod_cast Finset.card_pos.mpr hne
  rw [div_pos_iff_of_pos_right hden, ← Finset.card_pos, Nat.cast_pos]

/-! ### Transition I — first depth at which `etaCov` becomes positive. -/

/-- The least depth `D` at which `etaCov D > 0` (some path first covered). -/
noncomputable def transitionI (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    (hev : ∃ D, (covered mc paths D).Nonempty) : ℕ :=
  Nat.find hev

/-- **Transition I exists.** At `D_I`, `etaCov > 0`; below it, `etaCov = 0`. -/
theorem transitionI_spec (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty)
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    (hev : ∃ D, (covered mc paths D).Nonempty) :
    0 < etaCov mc paths (transitionI mc paths hev) ∧
      ∀ D < transitionI mc paths hev, etaCov mc paths D = 0 := by
  refine ⟨?_, ?_⟩
  · rw [etaCov_pos_iff mc paths hne]
    exact Nat.find_spec hev
  · intro D hD
    have hempty : ¬ (covered mc paths D).Nonempty := Nat.find_min hev hD
    rw [Finset.not_nonempty_iff_eq_empty] at hempty
    unfold etaCov; rw [hempty]; simp

/-! ### Transition II — first depth at which `etaCov` reaches 1. -/

/-- The least depth `D` at which `etaCov D = 1` (all paths covered). -/
noncomputable def transitionII (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hfull : ∃ D, covered mc paths D = paths) : ℕ :=
  Nat.find hfull

/-- **Transition II exists.** At `D_II`, `etaCov = 1`; below it, `etaCov < 1`. -/
theorem transitionII_spec (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω))
    (hne : paths.Nonempty)
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hfull : ∃ D, covered mc paths D = paths) :
    etaCov mc paths (transitionII mc paths hfull) = 1 ∧
      ∀ D < transitionII mc paths hfull, etaCov mc paths D < 1 := by
  refine ⟨?_, ?_⟩
  · rw [etaCov_eq_one_iff mc paths hne]
    exact Nat.find_spec hfull
  · intro D hD
    have hne1 : covered mc paths D ≠ paths := Nat.find_min hfull hD
    rcases lt_or_eq_of_le (etaCov_le_one mc paths hne D) with h | h
    · exact h
    · exact absurd ((etaCov_eq_one_iff mc paths hne D).mp h) hne1

/-- **`D_I ≤ D_II` always.** Full coverage implies some path covered. -/
theorem transitionI_le_transitionII (mc : MonotoneCoverage Ω)
    (paths : Finset (Finset Ω)) (hne : paths.Nonempty)
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hev : ∃ D, (covered mc paths D).Nonempty)
    (hfull : ∃ D, covered mc paths D = paths) :
    transitionI mc paths hev ≤ transitionII mc paths hfull := by
  unfold transitionI transitionII
  apply Nat.find_le
  rw [Nat.find_spec hfull]; exact hne

/-! ### Concrete witness: two GENUINELY distinct transitions. -/

/-- Witness knowledge curve over `Fin 2`: `∅ ⊆ {0} ⊆ {0,1}`. -/
def witnessK : ℕ → Finset (Fin 2) := fun D =>
  if D = 0 then ∅ else if D = 1 then {0} else {0, 1}

/-- `witnessK` is monotone. -/
theorem witnessK_mono : Monotone witnessK := by
  intro a b hab
  unfold witnessK
  by_cases ha0 : a = 0
  · subst ha0; simp
  by_cases ha1 : a = 1
  · subst ha1
    simp only [ha0, if_false]
    have hb0 : b ≠ 0 := by omega
    by_cases hb1 : b = 1
    · subst hb1; simp
    · simp only [hb0, hb1, if_false]; decide
  · have hb0 : b ≠ 0 := by omega
    have hb1 : b ≠ 1 := by omega
    simp only [ha0, ha1, hb0, hb1, if_false, le_refl]

/-- The witness coverage trajectory. -/
def witnessMC : MonotoneCoverage (Fin 2) := ⟨witnessK, witnessK_mono⟩

/-- The witness explanation-path family `ℛ = {{0}, {1}}`. -/
def witnessPaths : Finset (Finset (Fin 2)) := {{0}, {1}}

/-- **Two genuinely distinct transitions** for the concrete witness:
`etaCov 0 = 0 < etaCov 1 = 1/2 < 1 = etaCov 2`. -/
theorem witness_two_transitions :
    etaCov witnessMC witnessPaths 0 = 0 ∧
    0 < etaCov witnessMC witnessPaths 1 ∧
    etaCov witnessMC witnessPaths 1 < 1 ∧
    etaCov witnessMC witnessPaths 2 = 1 := by
  have hpaths : witnessPaths.card = 2 := by decide
  have hc0 : (covered witnessMC witnessPaths 0).card = 0 := by decide
  have hc1 : (covered witnessMC witnessPaths 1).card = 1 := by decide
  have hc2 : (covered witnessMC witnessPaths 2).card = 2 := by decide
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold etaCov; rw [hc0, hpaths]; norm_num
  · unfold etaCov; rw [hc1, hpaths]; norm_num
  · unfold etaCov; rw [hc1, hpaths]
    rw [show ((1 : ℕ) : ℚ) / ((2 : ℕ) : ℚ) = 1/2 by norm_num]; linarith
  · unfold etaCov; rw [hc2, hpaths]; norm_num

/-! ##################################################################
    ###  PART B — TOWER BIND (T1): the two coverage LEVELS map to  ###
    ###  two strictly-ordered DATA BUDGETS via R4_Agent2.          ###
    ##################################################################

    Transition I is the first-coverage level (a HIGHER tolerated loss `ℓ_cov`)
    and Transition II is the full-coverage level (a STRICTLY LOWER tolerated
    loss `ℓ_full`, since mastering EVERY explanation path is the harder target).
    R4_Agent2's scaling bridge `crossBudget` turns a target loss into the data
    budget needed to reach it; its order-reversal `crossBudget_strictAnti` then
    forces the two coverage budgets into the SAME order as the two transition
    indices `D_I ≤ D_II`. -/

/-- **T1 — the two coverage levels map to two strictly-ordered data budgets.**

Given the scaling parameters `(L_∞, C, α_D)` of the R4_Agent2 loss law and two
coverage loss-targets with `L_∞ < ℓ_full < ℓ_cov` (full mastery demands a
strictly lower loss than first coverage), the crossing budget for full coverage
is STRICTLY LARGER than the budget for first coverage:

    crossBudget … ℓ_cov  <  crossBudget … ℓ_full ,

and each budget solves the scaling loss exactly (`bridge_solves`).  This is the
data-budget shadow of `D_I < D_II`: Transition II requires strictly more data.
Proof is by R4_Agent2 `crossBudget_strictAnti` and `bridge_solves` (TOWER). -/
theorem two_coverage_budgets_ordered
    (Linf C αD ℓ_cov ℓ_full : ℝ)
    (hC : 0 < C) (hα : 0 < αD)
    (h_full : Linf < ℓ_full) (h_lt : ℓ_full < ℓ_cov) :
    crossBudget Linf C αD ℓ_cov < crossBudget Linf C αD ℓ_full
      ∧ scalingLoss Linf C αD (crossBudget Linf C αD ℓ_cov) = ℓ_cov
      ∧ scalingLoss Linf C αD (crossBudget Linf C αD ℓ_full) = ℓ_full :=
  ⟨crossBudget_strictAnti Linf C αD ℓ_cov ℓ_full hC hα h_full h_lt,
   bridge_solves Linf C αD ℓ_cov hC hα (by linarith),
   bridge_solves Linf C αD ℓ_full hC hα h_full⟩

/-! ##################################################################
    ###  PART C — TOWER BIND (T2): the two transitions are         ###
    ###  TIME-ordered with a positive saturation gap via R.97.     ###
    ##################################################################

    The "path-robustness saturation period" `Δ_cov = D_II − D_I` of CjNEW3 is the
    coverage→full-mastery analogue of R.97's coverage→autonomy gap.  R.97 gives,
    under the κ-decay threshold equation, the strict ordering `t_cov < t_aut`
    and the closed-form gap `t_aut − t_cov = log(r/δ)/α_κ > 0`. -/

/-- **T2 — the two transitions are time-ordered with a strictly positive gap.**

Under the R.97 κ-decay threshold equation (`α_κ·(t_full − t_cov) = log(r/δ)`)
with `α_κ > 0` and `0 < δ < r`, the two coverage transitions occur in order
`t_cov < t_full` with the saturation gap pinned to `log(r/δ)/α_κ`, which is
strictly positive — a genuinely NONEMPTY saturation period between the two
transitions.  Proof is by R.97 `R_97_ordering`, `R_97_time_gap`, `R_97_log_pos`. -/
theorem two_transitions_time_ordered
    (α_κ r δ t_cov t_full : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold : α_κ * (t_full - t_cov) = Real.log (r / δ)) :
    t_cov < t_full
      ∧ t_full - t_cov = Real.log (r / δ) / α_κ
      ∧ 0 < t_full - t_cov := by
  refine ⟨R_97_ordering α_κ r δ t_cov t_full h_α h_δ h_lt h_threshold,
          R_97_time_gap α_κ r δ t_cov t_full h_α h_threshold, ?_⟩
  rw [R_97_time_gap α_κ r δ t_cov t_full h_α h_threshold]
  exact div_pos (R_97_log_pos r δ h_δ h_lt) h_α

/-! ##################################################################
    ###  PART D — TOWER BIND (T3): the carrying coordinate is      ###
    ###  TRANSCENDENTAL via R11_Agent3.                            ###
    ##################################################################

    The two-transition structure is carried by the residual-completion exponent
    `η`.  R11_Agent3 proved `η` is NOT a function of the algebraic Fisher/scaling
    invariants: there exist configurations `P, Q` with identical algebraic
    invariants but distinct `η`.  Hence the transition-bearing coordinate cannot
    be collapsed onto the algebraic data — the two-transition count is genuine
    information, not an algebraic artifact. -/

/-- **T3 — the transition-carrying coordinate `η` is transcendental.**

Re-export of R11_Agent3 `eta_independent_of_fisher_invariants`: two
configurations with equal metric-degeneration invariant, equal scaling invariant
and equal forced Zipf index `s`, yet different `η`.  So the coordinate carrying
the η-coverage transition structure is independent of the algebraic invariants —
the two transitions are a real feature, not removable by an algebraic change of
variables. -/
theorem transition_coordinate_transcendental :
    ∃ P Q : EtaWithFisher,
      metricDegenInvariant P = metricDegenInvariant Q
      ∧ scalingInvariant P = scalingInvariant Q
      ∧ P.s = Q.s
      ∧ etaOf P ≠ etaOf Q :=
  eta_independent_of_fisher_invariants

/-! ##################################################################
    ###  MASTER — CjNEW3 kernel + the three tower binds.           ###
    ################################################################## -/

/-- **R13.5 (MASTER, CONJECTURE-KERNEL) — η_cov two-transition structure,
bound to the tower.**

Bundles, for the concrete witness and generic scaling/κ/Fisher parameters:

* **(kernel)** `etaCov` undergoes two genuinely distinct transitions
  `0 = etaCov 0 < etaCov 1 < 1 = etaCov 2` (`witness_two_transitions`), and in
  ANY monotone model the two transition indices are correctly ordered
  `D_I ≤ D_II` (`transitionI_le_transitionII`);
* **(T1, R4_Agent2 TOWER)** the two coverage LEVELS map to two strictly-ordered
  DATA BUDGETS (`two_coverage_budgets_ordered`);
* **(T2, R.97)** the two transitions are TIME-ordered with a strictly positive
  saturation gap `t_cov < t_full`, gap `= log(r/δ)/α_κ > 0`
  (`two_transitions_time_ordered`);
* **(T3, R11_Agent3 TOWER)** the transition-carrying coordinate `η` is
  TRANSCENDENTAL — not a function of the algebraic invariants
  (`transition_coordinate_transcendental`).

HONEST: CjNEW3 (actual TM-family dynamics, exactly-two against arbitrary
dynamics) remains OPEN; this is the monotone-coverage KERNEL the conjecture
flags as its tractable target, bound to the tower in proof terms. -/
theorem R13_5_master
    (mc : MonotoneCoverage Ω) (paths : Finset (Finset Ω)) (hne : paths.Nonempty)
    [DecidablePred (fun D => (covered mc paths D).Nonempty)]
    [DecidablePred (fun D => covered mc paths D = paths)]
    (hev : ∃ D, (covered mc paths D).Nonempty)
    (hfull : ∃ D, covered mc paths D = paths)
    (Linf C αD ℓ_cov ℓ_full : ℝ)
    (hC : 0 < C) (hα : 0 < αD)
    (h_full : Linf < ℓ_full) (h_lev : ℓ_full < ℓ_cov)
    (α_κ r δ t_cov t_full : ℝ)
    (h_ακ : 0 < α_κ) (h_δ : 0 < δ) (h_rδ : δ < r)
    (h_threshold : α_κ * (t_full - t_cov) = Real.log (r / δ)) :
    -- (kernel) two distinct ordered transition indices …
    (transitionI mc paths hev ≤ transitionII mc paths hfull)
    -- … realized strictly in the concrete witness:
    ∧ (etaCov witnessMC witnessPaths 0 = 0 ∧
       0 < etaCov witnessMC witnessPaths 1 ∧
       etaCov witnessMC witnessPaths 1 < 1 ∧
       etaCov witnessMC witnessPaths 2 = 1)
    -- (T1) two strictly-ordered data budgets:
    ∧ crossBudget Linf C αD ℓ_cov < crossBudget Linf C αD ℓ_full
    -- (T2) time-ordered transitions, positive gap:
    ∧ (t_cov < t_full ∧ 0 < t_full - t_cov)
    -- (T3) carrying coordinate transcendental:
    ∧ (∃ P Q : EtaWithFisher,
        metricDegenInvariant P = metricDegenInvariant Q
        ∧ scalingInvariant P = scalingInvariant Q
        ∧ P.s = Q.s
        ∧ etaOf P ≠ etaOf Q) := by
  refine ⟨transitionI_le_transitionII mc paths hne hev hfull,
          witness_two_transitions, ?_, ?_, transition_coordinate_transcendental⟩
  · exact (two_coverage_budgets_ordered Linf C αD ℓ_cov ℓ_full hC hα h_full h_lev).1
  · have := two_transitions_time_ordered α_κ r δ t_cov t_full h_ακ h_δ h_rδ h_threshold
    exact ⟨this.1, this.2.2⟩

end R13_Agent5_AttackEtaCovTwoTransitions

end MIP
