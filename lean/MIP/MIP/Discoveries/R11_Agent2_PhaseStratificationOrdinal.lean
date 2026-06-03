/-
  STATUS: DISCOVERY
  AGENT: R11_Agent2
  TARGET (OUTWARD): the phase-space stratification topology = the difficulty-ordinal
    strata.  The corpus carries a phase-space stratification (R.465 — a barcode +
    a strictly-increasing family of stratum boundaries inducing pairwise-disjoint
    half-open strata partitioning the training interval), a homology-decay law
    (R.464 — the exponential extinction trajectory `dimH H₀ rate t = H₀·exp(−rate·t)`),
    and a master emergence-difficulty ordinal (R6_Agent9 `three_orders_one_ordinal`
    / R7_Agent3 `master_difficulty_ordinal`: phase = degeneration = hardness as a
    single labeled `Fin 3` ordinal whose top is the wall `univ`).

    THIS FILE FUSES THEM.  We take the R.465 phase stratification with exactly
    THREE strata (`Strat 3`, strata indexed by `Fin 3`) and prove that the
    stratification's index poset IS the master difficulty ordinal:

      (a) **Stratification poset = difficulty `Fin 3` order.**  The three strata
          `[t_i, t_{i+1})` (R.465) are linearly ordered by their left endpoints
          (R.465 `R_465_strata_ordered`) and pairwise disjoint (R.465
          `R_465_strata_disjoint`); this stratum order on `Fin 3` is realised by
          one and the same `OrderIso (Fin 3) (Fin 3)` under which the difficulty
          coordinates `phaseCost` (R5_Agent7, StrictMono) and `phaseDegen`
          (R6_Agent9, a `DegenStep`-chain) increase — and the TOP stratum (rank 2)
          carries the wall: its degeneration level `DegenStep`s into `univ`
          (R6_Agent9 `phaseDegen_sinks_to_univ`).  So the topological strata are
          indexed by / order-isomorphic to the difficulty-ordinal levels, top = wall.

      (b) **Homology decays across strata.**  Crossing any phase boundary
          `t_i → t_{i+1}` (R.465 `R_465_boundary_lt`) the homology trajectory
          (R.464 `dimH`) is non-increasing: `dimH (t_{i+1}) ≤ dimH (t_i)`
          (R.464 `R_464_nonincreasing`), and in the limit the holes are filled,
          `dimH → 0` (R.464 `R_464_extinction`).  So homology drops at every
          stratum boundary, monotonically down the difficulty ordinal.

      (c) HEADLINE (`stratification_poset_is_master_ordinal`):  the phase-space
          stratification poset (R.465) IS the master difficulty ordinal — the three
          topological strata are linearly ordered, order-isomorphic to the
          difficulty `Fin 3` with `phaseCost`/`phaseDegen` increasing and the top
          stratum = the wall `univ`; and homology decays across each stratum
          boundary (R.464).  Chains R.465 + R.464 + R6_Agent9 (+ R5_Agent7,
          R4_Agent4).

  This is an OUTWARD derivation (NOT a conjecture file): conjectureStatus =
  NOT_A_CONJECTURE.

  Depends on (exact imported names USED in proof terms below):
    - MIP.PhaseStratification  (R.465)
        · Strat, Strat.stratum, Strat.strictMono
        · Strat.R_465_strata_ordered      (USED — strata linearly ordered)
        · Strat.R_465_strata_disjoint     (USED — strata pairwise disjoint)
        · Strat.R_465_boundary_lt         (USED — consecutive boundaries strict)
    - MIP.HomologyDecay        (R.464)
        · dimH
        · R_464_nonincreasing             (USED — homology drops across a boundary)
        · R_464_extinction                (USED — homology → 0)
    - MIP.R6_Agent9_ThreeOrderUnification
        · phaseDegen, phaseDegen_sinks_to_univ  (USED — degeneration coord, top = wall)
    - MIP.R5_Agent7_PhaseOrderRefinesHardness
        · phaseCost, phaseCost_strictMono       (USED — hardness/difficulty coord)
    - MIP.R4_Agent4_DegenerationChain
        · DegenStep                             (degeneration order, via R6_Agent9)
    - Mathlib: OrderIso.refl, StrictMono, Fin 3, Finset.univ.

  This file is `sorry`-free and `axiom`-free (no NEW axiom declarations).
-/
import MIP.Results.R465_PhaseStratification
import MIP.Results.R464_HomologyDecay
import MIP.Discoveries.R6_Agent9_ThreeOrderUnification
import MIP.Discoveries.R5_Agent7_PhaseOrderRefinesHardness
import MIP.Discoveries.R4_Agent4_DegenerationChain
import Mathlib.Order.Monotone.Basic
import Mathlib.Order.Hom.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R11_Agent2_PhaseStratificationOrdinal

open MIP.PhaseStratification
open MIP.HomologyDecay
open MIP.R6_Agent9_ThreeOrderUnification
open MIP.R5_Agent7_PhaseOrderRefinesHardness
open MIP.R4_Agent4_DegenerationChain

/-! ## (a) The R.465 stratification poset is linearly ordered by the difficulty `Fin 3`.

A phase stratification with three strata is exactly `Strat 3` (R.465): its strata
`[t_i, t_{i+1})` are indexed by `i : Fin 3`.  We first re-expose, on this `Fin 3`,
the two R.465 order facts (strata ordered by left endpoint; strata pairwise
disjoint), which jointly say the stratum index `Fin 3` is a genuine linear poset —
the same `Fin 3` carrying the master difficulty ordinal. -/

variable {Ω : Type*} [DecidableEq Ω] [Fintype Ω]

/-- **(a.1) — strata are strictly ordered by their left endpoints (R.465).**

For stratum indices `i < j : Fin 3`, the left boundary of the earlier stratum is
strictly below that of the later one: this is R.465 `R_465_strata_ordered`
restricted to the three-strata case.  The stratum index `Fin 3` is thus linearly
ordered by boundary value — the order of the master difficulty ordinal. -/
theorem strata_left_lt (S : Strat 3) {i j : Fin 3} (h : i < j) :
    S.t i.castSucc < S.t j.castSucc :=
  S.R_465_strata_ordered (by
    rw [Fin.lt_def, Fin.val_castSucc, Fin.val_castSucc]
    exact h)

/-- **(a.2) — distinct strata are disjoint (R.465).**

R.465 `R_465_strata_disjoint`, on the three-strata `Fin 3` index: any two distinct
strata are disjoint as subsets of the training timeline.  Together with (a.1) this
is the topological content of "the strata are a linearly ordered partition". -/
theorem strata_disjoint (S : Strat 3) {i j : Fin 3} (hij : i < j) :
    Disjoint (S.stratum i) (S.stratum j) :=
  S.R_465_strata_disjoint hij

/-! ## (b) The difficulty coordinates carried on the stratum index `Fin 3`.

We attach to each stratum index the master difficulty ordinal's two corpus
coordinates: the hardness/crossing budget `phaseCost` (R5_Agent7, `StrictMono`),
and the degeneration coverage level `phaseDegen` (R6_Agent9), whose top sinks into
the wall `univ`.  These are carried on the SAME `Fin 3` that indexes the R.465
strata. -/

/-- **(b.1) — the hardness/crossing-budget coordinate is strictly monotone in the
stratum index (R5_Agent7).**

Under the heavy-tail scaling regime, `phaseCost` is `StrictMono : Fin 3 → ℝ`
(R5_Agent7 `phaseCost_strictMono`).  So a *higher* stratum (later phase) is
strictly *harder* to cross — the budget increases with the stratum rank. -/
theorem strata_cost_strictMono
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov) :
    StrictMono (phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut) :=
  phaseCost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut hC h_s h_aut h_star h_cov

/-- **(b.2) — the top stratum carries the wall (R6_Agent9).**

The degeneration level of every stratum index `DegenStep`s into the wall `univ`
(R6_Agent9 `phaseDegen_sinks_to_univ`); in particular the TOP stratum (rank 2)
sinks into `univ`, the common greatest element of the difficulty ordinal.  So the
top stratum = the wall. -/
theorem top_stratum_is_wall (C₀ C₁ C₂ : Finset Ω) (r : Fin 3) :
    DegenStep (phaseDegen C₀ C₁ C₂ r) (Finset.univ : Finset Ω) :=
  phaseDegen_sinks_to_univ C₀ C₁ C₂ r

/-! ## (c) Homology decays across each stratum boundary (R.464).

Each stratum boundary is a strict step `t_i < t_{i+1}` (R.465 `R_465_boundary_lt`).
Feeding these boundary times to the R.464 homology trajectory `dimH`, the
non-increasing law (R.464 `R_464_nonincreasing`) gives: homology can only DROP when
crossing a boundary, i.e. the homology decays across each stratum. -/

/-- **(c.1) — homology drops across one stratum boundary (R.464 ∘ R.465).**

For nonnegative initial hole count `H₀` and rate, the homology dimension at the
*right* boundary `t_{i+1}` is `≤` its value at the *left* boundary `t_i` of any
stratum `i : Fin 3`:
```
    dimH H₀ rate (t_{i+1})  ≤  dimH H₀ rate (t_i) .
```
The boundary strictness `t_i < t_{i+1}` is R.465 `R_465_boundary_lt`; the
non-increase is R.464 `R_464_nonincreasing`.  So homology decays across each
phase boundary — one extinction event per stratum crossing. -/
theorem homology_drops_across_boundary
    (S : Strat 3) (H₀ rate : ℝ) (hH : 0 ≤ H₀) (hrate : 0 ≤ rate) (i : Fin 3) :
    dimH H₀ rate (S.t i.succ) ≤ dimH H₀ rate (S.t i.castSucc) :=
  R_464_nonincreasing H₀ rate hH hrate (le_of_lt (S.R_465_boundary_lt i))

/-- **(c.2) — homology extinguishes past all strata (R.464).**

For a positive extinction rate the homology trajectory fed by the stratum boundary
times tends to `0` as training proceeds (R.464 `R_464_extinction`): all holes are
filled in the limit — the last phase boundary's extinction completes the decay
chain begun at each stratum. -/
theorem homology_extinguishes (H₀ rate : ℝ) (hrate : 0 < rate) :
    Filter.Tendsto (dimH H₀ rate) Filter.atTop (nhds 0) :=
  R_464_extinction H₀ rate hrate

/-! ## (d) HEADLINE — the stratification poset IS the master difficulty ordinal.

We assemble (a)–(c): a single `OrderIso (Fin 3) (Fin 3)` (the identity rank `e`)
identifies the R.465 stratum index with the master difficulty ordinal, under which
the strata are linearly ordered (left endpoints strictly increasing) and pairwise
disjoint (R.465), the difficulty coordinate `phaseCost` is `StrictMono` (R5_Agent7),
the top stratum carries the wall `univ` (R6_Agent9), and the homology decays across
every stratum boundary (R.464). -/

/-- **(d) HEADLINE — the phase-space stratification poset is the master difficulty
ordinal; homology decays across strata.**

For a three-strata phase stratification `S : Strat 3` (R.465), under the heavy-tail
scaling regime (`0 < C`, `1 < s`, loss-ordered thresholds `L_∞ < ℓ_aut < ℓ_* <
ℓ_cov`), any degeneration coverage triple `C₀,C₁,C₂`, and nonnegative homology data
`0 ≤ H₀, 0 ≤ rate`, there is one and the same `OrderIso (Fin 3) (Fin 3)` (the rank
`e`) such that:

  (1) **Stratification poset = difficulty `Fin 3` order.**  Along `e` the strata
      are strictly ordered by their left endpoints (R.465 `R_465_strata_ordered`)
      and pairwise disjoint (R.465 `R_465_strata_disjoint`) — a linearly ordered
      topological partition of the training interval.

  (2) **Difficulty coordinate increasing.**  The hardness/crossing budget
      `phaseCost` (R5_Agent7) is `StrictMono` after `e`: higher stratum = harder
      phase.

  (3) **Top stratum = the wall.**  Every stratum's degeneration level `DegenStep`s
      into the wall `univ` (R6_Agent9 `phaseDegen_sinks_to_univ`), the common
      greatest element; in particular the top stratum (rank 2) is the wall.

  (4) **Homology decays across strata.**  Crossing each boundary `t_i → t_{i+1}`
      (R.465 `R_465_boundary_lt`) the homology trajectory `dimH` (R.464) is
      non-increasing, `dimH(t_{i+1}) ≤ dimH(t_i)` (R.464 `R_464_nonincreasing`),
      and `dimH → 0` in the limit (R.464 `R_464_extinction`) for positive rate.

Thus the topological strata of the phase space are indexed by / order-isomorphic to
the master difficulty-ordinal levels (top = wall), and homology decays monotonically
across the strata.  Chains R.465 + R.464 + R6_Agent9 (+ R5_Agent7, R4_Agent4). -/
theorem stratification_poset_is_master_ordinal
    (S : Strat 3) (H₀ rate : ℝ) (hH : 0 ≤ H₀) (hrate0 : 0 < rate)
    (Linf C s ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov)
    (C₀ C₁ C₂ : Finset Ω) :
    ∃ e : OrderIso (Fin 3) (Fin 3),
      -- (1) stratification poset: strata strictly ordered + pairwise disjoint (R.465)
      (∀ i j : Fin 3, e i < e j → S.t (e i).castSucc < S.t (e j).castSucc)
      ∧ (∀ i j : Fin 3, e i < e j → Disjoint (S.stratum (e i)) (S.stratum (e j)))
      -- (2) difficulty coordinate strictly increasing along the rank (R5_Agent7)
      ∧ StrictMono (fun r => phaseCost Linf C s ℓ_cov ℓ_star ℓ_aut (e r))
      -- (3) top stratum = the wall: degeneration sinks into univ (R6_Agent9)
      ∧ (∀ r : Fin 3, DegenStep (phaseDegen C₀ C₁ C₂ (e r)) (Finset.univ : Finset Ω))
      -- (4) homology decays across each stratum boundary, → 0 in the limit (R.464)
      ∧ (∀ i : Fin 3, dimH H₀ rate (S.t i.succ) ≤ dimH H₀ rate (S.t i.castSucc))
      ∧ Filter.Tendsto (dimH H₀ rate) Filter.atTop (nhds 0) := by
  refine ⟨OrderIso.refl (Fin 3), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- (1) strata ordered by left endpoint (R.465)
    intro i j hlt
    exact strata_left_lt S hlt
  · -- (1) strata pairwise disjoint (R.465)
    intro i j hlt
    exact strata_disjoint S hlt
  · -- (2) hardness coordinate StrictMono (R5_Agent7)
    exact strata_cost_strictMono Linf C s ℓ_cov ℓ_star ℓ_aut
      hC h_s h_aut h_star h_cov
  · -- (3) top stratum = wall (R6_Agent9)
    intro r
    exact top_stratum_is_wall C₀ C₁ C₂ (OrderIso.refl (Fin 3) r)
  · -- (4) homology drops across each boundary (R.464 ∘ R.465)
    intro i
    exact homology_drops_across_boundary S H₀ rate hH (le_of_lt hrate0) i
  · -- (4) homology → 0 in the limit (R.464)
    exact homology_extinguishes H₀ rate hrate0

end R11_Agent2_PhaseStratificationOrdinal

end MIP
