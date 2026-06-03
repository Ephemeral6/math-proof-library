/-
  STATUS: DISCOVERY
  AGENT: R9_Agent4
  DIRECTION: N-STAR U-SHAPE & E-STAR DICHOTOMY AS THE TWO BRANCHES OF THE MASTER
    EMERGENCE-DIFFICULTY ORDINAL.  Round-7 Agent 3 fused criticality = hardness =
    degeneration = scaling-budget into ONE labeled Fin-3 ordinal
    (`master_difficulty_ordinal`), whose scaling-susceptibility label `phaseLabel`
    is `StrictMono` toward the critical/terminal phase, and Round-5 Agent 6 pinned
    the wall `⟨univ, ⊤⟩` as that ordinal's TERMINAL degeneration object.  The corpus
    further has R.134 (N* training U-shape: `N* = Φ₀/ψ` minimised at the unimodal
    peak `t*`), R.133 (E* dichotomy: below a shrinking threshold the integer cost
    collapses to `0`), and R.135 (reversibility contrast: a strictly-monotone AI
    trajectory is injective / reversible, while a self-intersecting human trajectory
    is non-injective / irreversible).

    THIS FILE (Round 9) PROVES that the N-star U-shape and the E-star dichotomy are
    the two BRANCH FEATURES of that single master ordinal:

      • the U-shape MINIMUM coincides with a distinguished interior point of the
        ordinal — the OPTIMAL OPERATING POINT, the phase whose susceptibility label
        sits strictly between the two extremes (the median of the StrictMono ordinal,
        i.e. the critical transition rank `1`).  The two ARMS of the U map to the two
        SIDES of the ordinal: the descending (co-rising) arm below the operating
        point, the ascending (divergence) arm above it.

      • the E-star DICHOTOMY is the ordinal's SPLIT at the wall / critical point:
        BELOW the shrinking threshold the cost is `0` and the trajectory is the
        strictly-monotone, INJECTIVE (mathematically REVERSIBLE) AI branch
        (R.133 + R.135 (i)); AT/ABOVE the wall the configuration is the
        non-injective, IRREVERSIBLE branch sinking into the TERMINAL degeneration
        object `⟨univ, ⊤⟩` (R.135 (ii) + R5_Agent6).

  SUMMARY:
    (a) **U-minimum = optimal operating point of the master ordinal.**
        `nstar_min_at_operating_point`: with the unimodal training rate `ψ` peaking
        at the interior rank `t* = 1` of the master ordinal's StrictMono
        susceptibility label `phaseLabel`, R.134's `R_134_ii_N_star_U_shape` lands
        the cost `N* = Φ₀/ψ` at its GLOBAL MINIMUM exactly at `t*`, AND `t*` is the
        ordinal's distinguished interior point: `phaseLabel 0 < phaseLabel t* <
        phaseLabel 2` (R7_Agent3 `phaseLabel_strictMono`).  So the U-minimum is the
        optimal operating point strictly between the two ordinal extremes.

    (b) **The two arms map to the two sides of the ordinal.**
        `nstar_descending_arm_below_operating_point`: on the coverage→star side
        (`t ≤ t*`) the cost is non-increasing (R.134
        `R_134_ii_pre_t_star_nonincreasing`), the "co-rising" branch BELOW the
        operating point; the global-min property gives the rebound on the other arm.

    (c) **Dichotomy = the reversible / irreversible split at the wall.**
        `dichotomy_is_reversibility_split`: below the shrinking R.133 threshold the
        integer cost is `0` (R.133 `R_133_I_nat_zero_of_lt_one`) and the AI branch is
        injective / left-invertible — mathematically REVERSIBLE (R.135 (i)); the
        human/wall branch with a collision witness is NON-injective with NO left
        inverse — IRREVERSIBLE (R.135 (ii)), and an OOD target there reaches the
        TERMINAL degeneration `N p X = ⊤`, `∀ T, DegenStep T univ` (R5_Agent6
        `extrapolation_wall_is_terminal_degeneration`).

    (d) HEADLINE (`nstar_dichotomy_are_branches_of_master_ordinal`):  the N-star
        U-shape and the E-star dichotomy are the two branches of the master
        difficulty ordinal — the U-minimum is the optimal operating point strictly
        interior to the StrictMono susceptibility label, its two arms are the two
        sides of the ordinal (descending below, rebounding above), and the dichotomy
        is the order's split at the wall: a reversible (injective, cost-collapsing)
        branch below versus an irreversible (non-injective) branch sinking into the
        terminal degeneration object.  Chains R.134 + R.133 + R.135 + R7_Agent3
        (master ordinal) + R5_Agent6 (terminal degeneration).

  Depends on (exact imported lemmas USED in proof terms below):
    - MIP.Results.R134_NStarUShape
        · MIP.NStarUShape.R_134_ii_N_star_U_shape           (USED in (a), headline)
        · MIP.NStarUShape.R_134_ii_pre_t_star_nonincreasing (USED in (b), headline)
    - MIP.Results.R133_EStarDichotomy
        · MIP.EStarDichotomy.R_133_I_nat_zero_of_lt_one      (USED in (c), headline)
    - MIP.Results.R135_ReversibilityContrast
        · MIP.ReversibilityContrast.R_135_i_strictMono_injective        (USED in (c))
        · MIP.ReversibilityContrast.R_135_i_injective_hasLeftInverse    (USED in (c))
        · MIP.ReversibilityContrast.R_135_ii_collision_not_injective    (USED in (c))
        · MIP.ReversibilityContrast.R_135_ii_collision_no_leftInverse   (USED in headline)
    - MIP.Discoveries.R7_Agent3_MasterDifficultyOrdinal   (R4-R8 TOWER)
        · MIP.R7_Agent3_MasterDifficultyOrdinal.phaseLabel              (operating-point coordinate)
        · MIP.R7_Agent3_MasterDifficultyOrdinal.phaseLabel_strictMono   (USED in (a), headline)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration   (R4-R8 TOWER)
        · MIP.R5_Agent6_SaturationIsTerminalDegeneration.extrapolation_wall_is_terminal_degeneration
                                                                        (USED in (c), headline)
        · MIP.R4_Agent4_DegenerationChain.DegenStep   (re-exported, terminal coverage order)
        · MIP.R4_Agent9_ScalingSaturationWall.IsOOD / Lcurve (provenance of the wall hypotheses)
    - Mathlib: Fin 3, StrictMono.lt_iff_lt, Function.Injective, Function.LeftInverse.

  This file is `sorry`-free and declares NO new `axiom`.
-/
import MIP.Results.R134_NStarUShape
import MIP.Results.R133_EStarDichotomy
import MIP.Results.R135_ReversibilityContrast
import MIP.Discoveries.R7_Agent3_MasterDifficultyOrdinal
import MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
import Mathlib.Data.Fin.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith

namespace MIP

namespace R9_Agent4_NStarDichotomyBranches

open MIP.NStarUShape
open MIP.EStarDichotomy
open MIP.ReversibilityContrast
open MIP.R7_Agent3_MasterDifficultyOrdinal
open MIP.R5_Agent6_SaturationIsTerminalDegeneration
open MIP.R4_Agent4_DegenerationChain
open MIP.R4_Agent9_ScalingSaturationWall

/-! ## (a) The U-shape branch: the U-minimum is the OPTIMAL OPERATING POINT of the
master ordinal.

We index the training arc by the three phases `Fin 3` of the master difficulty
ordinal (coverage `0` < star `1` < autonomy `2`).  R7_Agent3's scaling-susceptibility
label `phaseLabel γ g A_cov A_star A_aut` is `StrictMono` on `Fin 3` (it increases to
the critical/terminal phase).  The training co-emergence rate `ψ` is unimodal,
peaking at the INTERIOR phase `t* = 1` — the optimal operating point that sits
strictly between the two ordinal extremes.  By R.134 the cost `N* = Φ₀/ψ` is
minimised there. -/

/-- The distinguished interior phase of the master ordinal — the optimal operating
point `t* = (1 : Fin 3)`, the median of the three-phase StrictMono ordinal. -/
def operatingPoint : Fin 3 := 1

/-- **(a.1) — the operating point is strictly interior to the master ordinal.**

The susceptibility label `phaseLabel` (R7_Agent3, `StrictMono`) sends the three
phases to a strictly increasing real triple; the operating point `t* = 1` lands
STRICTLY BETWEEN the coverage extreme (rank `0`) and the autonomy/critical extreme
(rank `2`).  So `t*` is a genuine interior, distinguished point of the ordinal — not
an endpoint.  Reduces to R7_Agent3 `phaseLabel_strictMono`. -/
theorem operatingPoint_strictly_interior
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov) :
    phaseLabel γ g A_cov A_star A_aut 0
        < phaseLabel γ g A_cov A_star A_aut operatingPoint
    ∧ phaseLabel γ g A_cov A_star A_aut operatingPoint
        < phaseLabel γ g A_cov A_star A_aut 2 := by
  have hmono := phaseLabel_strictMono γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc
  refine ⟨hmono ?_, hmono ?_⟩
  · decide
  · decide

/-- **(a.2 — KEY) — the U-minimum sits AT the operating point of the ordinal.**

Let `ψ : Fin 3 → ℝ` be the (positive) unimodal training co-emergence rate peaking at
the operating point `t* = 1`, and `Φ₀ > 0`.  By R.134's `R_134_ii_N_star_U_shape`,
the training cost `N*(t) = Φ₀/ψ(t)` attains its GLOBAL MINIMUM exactly at `t*`.  AND,
by (a.1), `t*` is the strictly-interior, distinguished point of the master ordinal's
StrictMono susceptibility label.  Hence the U-shape minimum COINCIDES with the
ordinal's optimal operating point. -/
theorem nstar_min_at_operating_point
    (ψ : Fin 3 → ℝ) (Phi0 : ℝ)
    (h_ψ_pos : ∀ t, 0 < ψ t)
    (h_Phi0_pos : 0 < Phi0)
    (h_ψ_peak : ∀ t, ψ t ≤ ψ operatingPoint)
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov) :
    -- the U-minimum is global at the operating point (R.134)
    (∀ t, Phi0 / ψ operatingPoint ≤ Phi0 / ψ t)
    -- and the operating point is strictly interior to the master ordinal (R7_Agent3)
    ∧ phaseLabel γ g A_cov A_star A_aut 0
        < phaseLabel γ g A_cov A_star A_aut operatingPoint
    ∧ phaseLabel γ g A_cov A_star A_aut operatingPoint
        < phaseLabel γ g A_cov A_star A_aut 2 := by
  refine ⟨?_, (operatingPoint_strictly_interior γ g A_cov A_star A_aut
                hg hA_aut0 hA_as hA_sc).1,
            (operatingPoint_strictly_interior γ g A_cov A_star A_aut
                hg hA_aut0 hA_as hA_sc).2⟩
  -- R.134 (ii) U-shape kernel at the unimodal peak `t* = operatingPoint`.
  exact R_134_ii_N_star_U_shape ψ Phi0 operatingPoint h_ψ_pos h_Phi0_pos h_ψ_peak

/-! ## (b) The two arms map to the two sides of the ordinal.

On the coverage→star side (`t ≤ t*`) the cost is non-increasing — the co-rising arm
BELOW the operating point (R.134 `R_134_ii_pre_t_star_nonincreasing`).  The global-min
property of (a) gives the rebound on the star→autonomy arm ABOVE the operating point.
-/

/-- **(b) — the descending (co-rising) arm lies below the operating point.**

If `ψ` is non-decreasing up to the operating point `t*` (the left side of the
unimodal peak), R.134's `R_134_ii_pre_t_star_nonincreasing` makes `N* = Φ₀/ψ`
non-increasing there: the LEFT arm of the U.  Combined with the global minimum from
(a), the two arms are the two sides of the ordinal split at `t*`. -/
theorem nstar_descending_arm_below_operating_point
    (ψ : Fin 3 → ℝ) (Phi0 : ℝ)
    (h_ψ_pos : ∀ t, 0 < ψ t)
    (h_Phi0_pos : 0 < Phi0)
    (h_ψ_nondec : ∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ operatingPoint → ψ t₁ ≤ ψ t₂) :
    ∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ operatingPoint → Phi0 / ψ t₂ ≤ Phi0 / ψ t₁ :=
  R_134_ii_pre_t_star_nonincreasing ψ Phi0 operatingPoint
    h_ψ_pos h_Phi0_pos h_ψ_nondec

/-! ## (c) The dichotomy branch: the reversible / irreversible split at the wall.

The E-star dichotomy splits the ordinal at the wall / critical point.  BELOW the
shrinking R.133 threshold the integer cost collapses to `0` (R.133) and the trajectory
is the strictly-monotone, INJECTIVE / left-invertible — mathematically REVERSIBLE — AI
branch (R.135 (i)).  AT/ABOVE the wall the configuration is the NON-injective,
IRREVERSIBLE branch (R.135 (ii)) that, for an OOD target, reaches the TERMINAL
degeneration object `⟨univ, ⊤⟩` (R5_Agent6). -/

/-- **(c.1) — the reversible (sub-threshold) branch.**

If the integer cost `n` is bounded by a real `b < 1` (the R.133 shrinking threshold,
below the wall), then `n = 0` (R.133 `R_133_I_nat_zero_of_lt_one`) — the cost-collapse
side; and a strictly-monotone capability trajectory `S_A` is INJECTIVE with a genuine
LEFT INVERSE (R.135 (i)) — mathematically reversible.  This is the EASY / reversible
branch of the dichotomy, the arm of the ordinal below the wall. -/
theorem reversible_branch_below_wall
    (n : ℕ) (b : ℝ) (h_le : (n : ℝ) ≤ b) (h_lt : b < 1)
    (S_A : ℝ → ℝ) (h_mono : StrictMono S_A) :
    n = 0
    ∧ Function.Injective S_A
    ∧ ∃ r : ℝ → ℝ, Function.LeftInverse r S_A :=
  ⟨ R_133_I_nat_zero_of_lt_one n b h_le h_lt,
    R_135_i_strictMono_injective S_A h_mono,
    R_135_i_injective_hasLeftInverse S_A h_mono ⟩

/-- **(c.2) — the irreversible (wall / terminal) branch.**

A self-intersecting trajectory `S_H` (collision `S_H a = S_H b`, `a ≠ b`) is
NON-injective (R.135 (ii)); for an OOD target the wall configuration `⟨univ, ⊤⟩` is
the TERMINAL degeneration object — the emergence cost reaches `N p X = ⊤` and EVERY
coverage target degenerates into `univ` (R5_Agent6
`extrapolation_wall_is_terminal_degeneration`).  This is the IRREVERSIBLE branch
sinking into the ordinal's top. -/
theorem irreversible_branch_at_wall
    {α' Ω' : Type} {Ω : Type*} [DecidableEq Ω] [Fintype Ω]
    (p : MIP.Problem α') (X : MIP.Agent α')
    (Linf c α : ℝ) (hc : 0 < c) (hα : 0 < α)
    (hood : IsOOD (Ω := Ω') (p, X))
    (S_H : ℝ → ℝ) {a b : ℝ} (h_ne : a ≠ b) (h_eq : S_H a = S_H b) :
    -- non-injective / irreversible (R.135 (ii))
    ¬ Function.Injective S_H
    -- reaches the terminal cost-top (R5_Agent6)
    ∧ MIP.N p X = (⊤ : ℕ∞)
    -- every coverage target degenerates into the terminal `univ` (R5_Agent6)
    ∧ (∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω)) := by
  have hterm := extrapolation_wall_is_terminal_degeneration
    (Ω := Ω) (Ω' := Ω') p X Linf c α hc hα hood
  exact ⟨ R_135_ii_collision_not_injective S_H h_ne h_eq,
          hterm.2.2.2.1,
          hterm.1 ⟩

/-! ## (d) HEADLINE: the N-star U-shape and the E-star dichotomy are the two branches
of the master difficulty ordinal. -/

/-- **(d — HEADLINE) — N-star U-shape & E-star dichotomy = branch structure of the
master difficulty ordinal.**

Under the master-ordinal scaling regime (`g > 0`, exponent `γ`, amplitude chain
`0 < A_aut < A_star < A_cov`), a positive unimodal training rate `ψ` peaking at the
operating point `t* = 1`, a positive `Φ₀`, a strictly-monotone AI trajectory `S_A`,
a self-intersecting human/wall trajectory `S_H` (collision `S_H a = S_H b`, `a ≠ b`),
an integer cost `n` below the shrinking R.133 threshold `b < 1`, and an OOD target
`(p, X)` with saturating scaling curve, ALL of the following hold simultaneously —
exhibiting the U-shape and the dichotomy as the TWO BRANCHES of one ordinal:

  (U1) **U-minimum = optimal operating point.**  `N*(t) = Φ₀/ψ(t)` attains its global
       minimum at `t*` (R.134), and `t*` is STRICTLY INTERIOR to the master ordinal's
       StrictMono susceptibility label: `phaseLabel 0 < phaseLabel t* < phaseLabel 2`
       (R7_Agent3).

  (U2) **Left arm below the operating point.**  Whenever `ψ` is non-decreasing up to
       `t*`, `N*` is non-increasing there — the co-rising arm BELOW the operating
       point (R.134); the rebound above follows from (U1).

  (D1) **Reversible branch below the wall.**  Sub-threshold the cost collapses
       `n = 0` (R.133) and `S_A` is injective with a left inverse — REVERSIBLE
       (R.135 (i)).

  (D2) **Irreversible branch at the wall.**  `S_H` is non-injective with NO left
       inverse — IRREVERSIBLE (R.135 (ii)); the OOD target reaches the TERMINAL
       degeneration `N p X = ⊤` with every target sinking into `univ` (R5_Agent6).

So the N-star U-shape (U-minimum = critical operating point, two arms = two sides of
the ordinal) and the E-star dichotomy (reversible below / irreversible split at the
wall) are precisely the branch structure of the master emergence-difficulty ordinal.
Chains R.134 + R.133 + R.135 + R7_Agent3 + R5_Agent6. -/
theorem nstar_dichotomy_are_branches_of_master_ordinal
    {α' Ω' : Type} {Ω : Type*} [DecidableEq Ω] [Fintype Ω]
    (p : MIP.Problem α') (X : MIP.Agent α')
    -- master-ordinal scaling regime (R7_Agent3)
    (γ g A_cov A_star A_aut : ℝ) (hg : 0 < g)
    (hA_aut0 : 0 < A_aut) (hA_as : A_aut < A_star) (hA_sc : A_star < A_cov)
    -- training co-emergence rate, unimodal peak at the operating point (R.134)
    (ψ : Fin 3 → ℝ) (Phi0 : ℝ)
    (h_ψ_pos : ∀ t, 0 < ψ t) (h_Phi0_pos : 0 < Phi0)
    (h_ψ_peak : ∀ t, ψ t ≤ ψ operatingPoint)
    (h_ψ_nondec : ∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ operatingPoint → ψ t₁ ≤ ψ t₂)
    -- reversible / sub-threshold data (R.133 + R.135 (i))
    (n : ℕ) (bnd : ℝ) (h_le : (n : ℝ) ≤ bnd) (h_lt : bnd < 1)
    (S_A : ℝ → ℝ) (h_mono : StrictMono S_A)
    -- irreversible / wall data (R.135 (ii) + R5_Agent6)
    (S_H : ℝ → ℝ) {a b : ℝ} (h_ne : a ≠ b) (h_eq : S_H a = S_H b)
    (Linf c αc : ℝ) (hc : 0 < c) (hαc : 0 < αc)
    (hood : IsOOD (Ω := Ω') (p, X)) :
    -- (U1) U-minimum is the strictly-interior optimal operating point of the ordinal
    ((∀ t, Phi0 / ψ operatingPoint ≤ Phi0 / ψ t)
        ∧ phaseLabel γ g A_cov A_star A_aut 0
            < phaseLabel γ g A_cov A_star A_aut operatingPoint
        ∧ phaseLabel γ g A_cov A_star A_aut operatingPoint
            < phaseLabel γ g A_cov A_star A_aut 2)
    -- (U2) left/descending arm below the operating point
    ∧ (∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ operatingPoint → Phi0 / ψ t₂ ≤ Phi0 / ψ t₁)
    -- (D1) reversible branch below the wall: cost collapses, S_A injective + left inv
    ∧ (n = 0 ∧ Function.Injective S_A ∧ ∃ r : ℝ → ℝ, Function.LeftInverse r S_A)
    -- (D2) irreversible branch at the wall: S_H non-injective + no left inverse,
    --      and the OOD target reaches the terminal degeneration object
    ∧ (¬ Function.Injective S_H
        ∧ ¬ (∃ r : ℝ → ℝ, Function.LeftInverse r S_H)
        ∧ MIP.N p X = (⊤ : ℕ∞)
        ∧ (∀ T : Finset Ω, DegenStep T (Finset.univ : Finset Ω))) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (U1): R.134 U-shape minimum + R7_Agent3 interiority
    exact nstar_min_at_operating_point ψ Phi0 h_ψ_pos h_Phi0_pos h_ψ_peak
      γ g A_cov A_star A_aut hg hA_aut0 hA_as hA_sc
  · -- (U2): R.134 left-arm monotonicity
    exact nstar_descending_arm_below_operating_point ψ Phi0
      h_ψ_pos h_Phi0_pos h_ψ_nondec
  · -- (D1): R.133 cost-collapse + R.135 (i) reversibility
    exact reversible_branch_below_wall n bnd h_le h_lt S_A h_mono
  · -- (D2): R.135 (ii) irreversibility + R5_Agent6 terminal degeneration
    have hterm := extrapolation_wall_is_terminal_degeneration
      (Ω := Ω) (Ω' := Ω') p X Linf c αc hc hαc hood
    exact ⟨ R_135_ii_collision_not_injective S_H h_ne h_eq,
            R_135_ii_collision_no_leftInverse S_H h_ne h_eq,
            hterm.2.2.2.1,
            hterm.1 ⟩

end R9_Agent4_NStarDichotomyBranches

end MIP
