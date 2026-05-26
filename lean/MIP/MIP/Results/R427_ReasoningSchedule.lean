/-
Result R.427 — Reasoning schedule R → C → T (three phase boundaries).

Reference: `workspace/coe_mip_unification.md` §R.427
(B, Block 9 "理论融合", 2026-05-16).

**Statement.** The ρ-τ training phase diagram (R.114) transfers to CoE
*inference*: as the turn index `t` advances, the optimal R/T/C supply ratio
phase-switches.  With three phase-boundary times

* `t_cov` — coverage time: before it, `R(p) ⊄ K(A_t)` (coverage incomplete);
* `t_C`   — Gompertz inflection `κ(A_t) = 1/e`;
* `t_T`   — impedance threshold `Z(A_t) = Z*`,

the optimal schedule is

    Phase(t) = R    for t < t_cov          (cover the knowledge gap)
             = C    for t_cov ≤ t < t_C    (combine: κ rising fastest)
             = T    for t_C   ≤ t < t_T    (execute paths: drive Z down)
             = done for t ≥ t_T .

The crisp content is the **ordering** `t_cov < t_C < t_T`, which makes the
four phases nonempty and consecutive.  (The empirical "20–40 % gain" claim of
§R.427 is *not* formalized — it has no derivation in the source.)

**Proof.** The ordering is bundled from the timing relations `t_cov < t_C` and
`t_C < t_T` (R.105 grokking precedes Gompertz inflection precedes autonomy /
impedance threshold).  We then prove: the phase function is well-defined and
the four phases partition the timeline into consecutive nonempty intervals; in
particular each boundary lies strictly inside the previous interval, and any
time falls in exactly one phase.

**This file is `axiom`-free.**  The phase-boundary predicates are explicit
real comparisons; the timing relations enter as bundled hypotheses.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace ReasoningSchedule

/-- The four CoE inference phases. -/
inductive Phase
  | R     -- representation: cover R(p) ⊆ K
  | C     -- counterfactual: combine while κ rises (κ < 1/e)
  | T     -- transformation: drive impedance Z down
  | done
  deriving DecidableEq, Repr

open Phase

/-- The phase schedule as a function of turn `t`, given the three boundaries
`t_cov ≤ t_C ≤ t_T`.  Implements the §R.427 case split. -/
noncomputable def schedule (t_cov t_C t_T t : ℝ) : Phase :=
  if t < t_cov then R
  else if t < t_C then C
  else if t < t_T then T
  else done

/-- **R.427 — phase-boundary ordering (the crisp theorem).**

The three boundaries are strictly ordered: `t_cov < t_C < t_T`.  This is the
content of the R → C → T schedule: coverage completes before the Gompertz
inflection, which precedes the impedance threshold.  Bundled from the two
timing relations. -/
theorem R_427_ordering
    (t_cov t_C t_T : ℝ)
    (h1 : t_cov < t_C) (h2 : t_C < t_T) :
    t_cov < t_C ∧ t_C < t_T ∧ t_cov < t_T :=
  ⟨h1, h2, lt_trans h1 h2⟩

/-- **R.427 — Phase R holds exactly on the coverage interval `[−∞, t_cov)`.** -/
theorem R_427_phase_R
    (t_cov t_C t_T t : ℝ) (h : t < t_cov) :
    schedule t_cov t_C t_T t = Phase.R := by
  unfold schedule; rw [if_pos h]

/-- **R.427 — Phase C holds exactly on `[t_cov, t_C)` (the combination phase).**

Uses the boundary ordering `t_cov < t_C`. -/
theorem R_427_phase_C
    (t_cov t_C t_T t : ℝ)
    (hlo : t_cov ≤ t) (hhi : t < t_C) :
    schedule t_cov t_C t_T t = Phase.C := by
  unfold schedule
  rw [if_neg (not_lt.mpr hlo), if_pos hhi]

/-- **R.427 — Phase T holds exactly on `[t_C, t_T)` (the execution phase).** -/
theorem R_427_phase_T
    (t_cov t_C t_T t : ℝ)
    (hlo : t_C ≤ t) (hhi : t < t_T)
    (hord : t_cov ≤ t_C) :
    schedule t_cov t_C t_T t = Phase.T := by
  unfold schedule
  have hge_cov : ¬ (t < t_cov) := not_lt.mpr (le_trans hord hlo)
  rw [if_neg hge_cov, if_neg (not_lt.mpr hlo), if_pos hhi]

/-- **R.427 — Phase `done` holds exactly on `[t_T, +∞)`.** -/
theorem R_427_phase_done
    (t_cov t_C t_T t : ℝ)
    (hge : t_T ≤ t)
    (hord1 : t_cov ≤ t_C) (hord2 : t_C ≤ t_T) :
    schedule t_cov t_C t_T t = Phase.done := by
  unfold schedule
  have hge_cov : ¬ (t < t_cov) :=
    not_lt.mpr (le_trans (le_trans hord1 hord2) hge)
  have hge_C : ¬ (t < t_C) := not_lt.mpr (le_trans hord2 hge)
  rw [if_neg hge_cov, if_neg hge_C, if_neg (not_lt.mpr hge)]

/-- **R.427 — consecutiveness: each phase is nonempty under strict ordering.**

With `t_cov < t_C < t_T` every phase actually occurs — there is a turn in each.
Concretely we exhibit witnesses: a time strictly below `t_cov` is in phase R,
the time `t_cov` is in phase C, `t_C` is in phase T, and `t_T` is in `done`.
This certifies the four phases form a genuine consecutive R→C→T→done schedule
(no phase is skipped). -/
theorem R_427_phases_nonempty
    (t_cov t_C t_T : ℝ)
    (h1 : t_cov < t_C) (h2 : t_C < t_T) :
    schedule t_cov t_C t_T (t_cov - 1) = Phase.R ∧
    schedule t_cov t_C t_T t_cov = Phase.C ∧
    schedule t_cov t_C t_T t_C = Phase.T ∧
    schedule t_cov t_C t_T t_T = Phase.done := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact R_427_phase_R t_cov t_C t_T (t_cov - 1) (by linarith)
  · exact R_427_phase_C t_cov t_C t_T t_cov (le_refl _) h1
  · exact R_427_phase_T t_cov t_C t_T t_C (le_refl _) h2 (le_of_lt h1)
  · exact R_427_phase_done t_cov t_C t_T t_T (le_refl _) (le_of_lt h1) (le_of_lt h2)

end ReasoningSchedule

end MIP
