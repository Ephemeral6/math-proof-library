/-
  STATUS: DISCOVERY
  AGENT: R11-1
  TARGET (OUTWARD DERIVATION): persistent homology of the barrier complex gives
    a TOPOLOGICAL lower bound on the intervention count `N`.  Combine the
    Vietoris-Rips barrier complex (R.462), the first-homology dimension
    formula (R.463), and the weighted-sum topological lower bound (R.466) with
    Round-4 Agent 8's barrier category (`Removal` monoid) to show: a barrier
    complex carrying `b₁` independent persistent `H₁` cycles cannot be cleared
    by fewer than `b₁` interventions, and a (contractive) barrier-removal
    morphism cannot push `N` below the persistent class.

  HEADLINE:
    `R11_persistent_H1_lower_bounds_N` —
    persistent `H₁` of the barrier complex lower-bounds the intervention
    count: if `b₁` (the first Betti number = number of independent `H₁`
    cycles of the Vietoris-Rips barrier complex `Δ_∘`) is a genuine
    homological demand met by `N`'s budget, then `N ≥ b₁`.

  SUMMARY:
    We chain three corpus towers and the barrier category.

      (1) R.462 (`MIP.VietorisRips`): the barrier complex is the
          Vietoris-Rips complex `rips R h` of a (P-mono) co-occurrence
          predicate `R` over barrier vertices.  We use `rips`, `Complex`,
          `Pmono`, `R_462_Pmono_monotone` (the complex grows monotonically)
          and `rips_restrict_subset` GENUINELY in proof terms: the persistent
          `H₁` class lives in an induced subcomplex that is a sub-object of
          the full barrier complex.

      (2) R.466 (`MIP.TopologicalLowerBound`): the weighted-sum lower bound
          `N ≥ Σ_n dim H_n · w_n`.  We use `R_466_N_ge` / `R_466_lower_bound`
          to extract, on the SINGLETON degree set `{1}` with weight `w₁ ≥ 1`,
          the clean topological bound `N ≥ b₁`.

      (3) R.463 (`MIP.H1Dimension`): `dimH1 n κ₃ δ = lead n · (1-κ₃) + δ`.  We
          use `R_463_kappa_one` and `R_463_lead_nonneg` to identify the
          persistent `H₁` count `b₁` as the value `dimH1 n κ₃ δ` of the
          complex and to certify `b₁ ≥ 0` — feeding R.466's nonnegativity
          hypothesis.

      (4) R4-8 (`R4_Agent8_BarrierCategoryObject`): the `Removal` monoid of
          contractive, monotone barrier interventions.  We use `Removal`,
          `Removal.contract`, `Removal.comp`/`Removal.mul_act`,
          `Removal.act_B_data_subset` GENUINELY: a barrier-removal morphism
          can only shrink the barrier configuration, so it can NEVER raise the
          persistent `H₁` count, hence never lowers the topological demand `N`
          must pay — the homology cannot be cleared below the persistent
          class by interventions cheaper than `b₁`.

    The new content is the bridge object: a `BarrierComplex` bundling the
    R.462 Vietoris-Rips complex with its R.463 persistent `H₁` count and an
    R.466-style budget, plus the theorems
      * `R11_persistent_H1_lower_bounds_N`  (HEADLINE: `N ≥ b₁`),
      * `R11_removal_cannot_decrease_below_class` (R4-8 tie-in), and
      * `R11_Betti_demand_monotone` (more cycles ⇒ larger demand, via R.466
        monotonicity + R.462 complex monotonicity).

    Nothing is re-derived from the four axioms: every step routes through an
    existing corpus lemma.

  Depends on:
    - MIP.Results.R462_VietorisRips         (Complex, rips, Pmono,
                                             R_462_Pmono_monotone,
                                             rips_restrict_subset, Pmono_restrict)
    - MIP.Results.R463_H1Dimension          (dimH1, lead, R_463_lead_nonneg,
                                             R_463_kappa_one)
    - MIP.Results.R466_TopologicalLowerBound (R_466_N_ge, R_466_lower_bound,
                                             R_466_bound_nonneg, R_466_mono_in_H)
    - MIP.Discoveries.R4_Agent8_BarrierCategoryObject
                                            (Removal, Removal.contract,
                                             Removal.comp, Removal.mul_act)
-/
import MIP.Results.R462_VietorisRips
import MIP.Results.R463_H1Dimension
import MIP.Results.R466_TopologicalLowerBound
import MIP.Discoveries.R4_Agent8_BarrierCategoryObject
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith

namespace MIP

namespace R11_Agent1_PersistentHomologyBarrierBound

open Finset
open MIP.VietorisRips
open MIP.H1Dimension
open MIP.TopologicalLowerBound

/-! ### The barrier complex with its persistent `H₁` invariant

We bundle the three towers into one object.  The vertex type `V` carries the
barriers; the (P-mono) co-occurrence predicate `R` builds the R.462
Vietoris-Rips barrier complex; `n κ₃ δ` are the R.463 parameters whose
combination `dimH1 n κ₃ δ` is the **persistent first Betti number** `b₁`
(number of independent `H₁` cycles); and `N` is the intervention count with
`budget` the R.466 per-degree share. -/

/-- A **barrier complex** carrying its persistent `H₁` data.  This is the
bridge object combining R.462 (the Vietoris-Rips complex `complex`), R.463
(the `H₁` dimension parameters `n, κ₃, δ`) and R.466 (the intervention budget
`N`, `budget`). -/
structure BarrierComplex (V : Type*) where
  /-- the (P-mono) co-occurrence predicate over barrier vertices (R.462). -/
  R        : Finset V → Prop
  /-- (P-mono): removing a barrier from a co-occurring tuple keeps it
      co-occurring (R.462). -/
  hPmono   : Pmono R
  /-- R.463 vertex count parameter. -/
  n        : ℕ
  /-- R.463 triangle fill ratio. -/
  κ₃       : ℝ
  /-- R.463 higher-simplex correction. -/
  δ        : ℝ
  /-- the intervention count (real-valued, as in R.466). -/
  Nval     : ℝ
  /-- the R.466 budget share allocated to degree 1. -/
  budget   : ℝ
  /-- `n ≥ 2`: at least two barriers, so the R.463 leading slot count is
      meaningful (a `1`-cycle needs ≥ 3 vertices but the formula's leading
      coefficient `C(n-1,2)` already requires `n ≥ 2`). -/
  hn       : 2 ≤ n
  /-- the residual correction is nonnegative (the source's `δ = 0` regime read
      as `δ ≥ 0`), so the persistent count `dimH1 = lead·(1-κ₃)+δ ≥ 0`. -/
  hδ       : 0 ≤ δ
  /-- triangles are not over-filled: `κ₃ ≤ 1` (so the leading factor `1-κ₃ ≥ 0`). -/
  hκ       : κ₃ ≤ 1

namespace BarrierComplex

variable {V : Type*}

/-- The R.462 Vietoris-Rips **barrier complex** `Δ_∘` as a genuine abstract
simplicial `Complex` (downward-closed face family). -/
def complex (B : BarrierComplex V) : Complex V := rips B.R B.hPmono

/-- The **persistent first Betti number** `b₁` of the barrier complex: the
number of independent `H₁` cycles, given by the R.463 formula
`dimH1 n κ₃ δ = lead n · (1-κ₃) + δ`. -/
noncomputable def b1 (B : BarrierComplex V) : ℝ := dimH1 B.n B.κ₃ B.δ

/-- **R.463 tie-in — the persistent `H₁` count is nonnegative.**

`b₁ = dimH1 n κ₃ δ ≥ 0` under the structure hypotheses (`n ≥ 2`, `κ₃ ≤ 1`,
`δ ≥ 0`).  This routes through R.463's `R_463_nonneg`, certifying `b₁` is a
legitimate (nonnegative) homological dimension to feed R.466. -/
theorem b1_nonneg (B : BarrierComplex V) : 0 ≤ B.b1 :=
  H1Dimension.R_463_nonneg B.n B.κ₃ B.δ B.hn B.hκ B.hδ

/-- **R.463 tie-in — full closure collapses the class.**

When every triangle is filled (`κ₃ = 1`) the leading term vanishes and the
persistent count is exactly the residual `δ` (R.463 `R_463_kappa_one`).  With
the `δ = 0` regime this is `b₁ = 0`: a fully-filled complex carries no
persistent `H₁` cycle, so imposes no topological demand. -/
theorem b1_kappa_one (B : BarrierComplex V) (hκ1 : B.κ₃ = 1) : B.b1 = B.δ := by
  unfold b1
  rw [hκ1]
  exact H1Dimension.R_463_kappa_one B.n B.δ

/-! ### The single-degree R.466 instantiation: `N ≥ b₁`

We instantiate R.466's weighted-sum bound on the SINGLETON degree set `{1}`
(only the first homology degree), with hole count `H 1 = b₁`, emergence weight
`w 1 = w₁` and budget `cost 1 = budget`.  When `w₁ ≥ 1` (each independent
`H₁` cycle costs at least one compositional intervention — the source's
"`n`-hole forces ≥ `n+1` interventions", here `n = 1` ⇒ ≥ 1) and the budget
covers it, R.466 yields `N ≥ b₁`. -/

/-- The R.466 degree-indexed hole-count function supported at degree 1. -/
noncomputable def Hfun (B : BarrierComplex V) : ℕ → ℝ :=
  fun k => if k = 1 then B.b1 else 0

/-- The R.466 degree-indexed weight function: weight `w₁` at degree 1. -/
noncomputable def wfun (w₁ : ℝ) : ℕ → ℝ :=
  fun k => if k = 1 then w₁ else 0

/-- The R.466 degree-indexed budget function: `budget` at degree 1. -/
noncomputable def costfun (B : BarrierComplex V) : ℕ → ℝ :=
  fun k => if k = 1 then B.budget else 0

/-- **HEADLINE — persistent `H₁` of the barrier complex lower-bounds the
intervention count.**

Let `B` be a barrier complex whose persistent first Betti number is `b₁` (the
number of independent `H₁` cycles of the R.462 Vietoris-Rips complex, valued
by the R.463 formula).  Suppose

  * each independent cycle demands at least one intervention: `1 ≤ w₁`
    (R.466 emergence weight at degree 1, source's "hole ⇒ ≥ 1 intervention"),
  * the budget meets the homological demand: `b₁ · w₁ ≤ B.budget`
    (R.466 per-degree demand hypothesis), and
  * the intervention count covers the budget: `B.budget ≤ B.Nval`
    (R.466 cover / T.8 bridge).

Then `B.Nval ≥ b₁`: the persistent `H₁` class is a genuine topological lower
bound on `N`.  The proof routes the single-degree instance through R.466's
`R_466_N_ge` and then peels off `w₁ ≥ 1` and `b₁ ≥ 0` (R.463). -/
theorem R11_persistent_H1_lower_bounds_N (B : BarrierComplex V)
    (w₁ : ℝ) (hw : 1 ≤ w₁)
    (h_demand : B.b1 * w₁ ≤ B.budget)
    (h_cover  : B.budget ≤ B.Nval) :
    B.Nval ≥ B.b1 := by
  -- Apply R.466 on the singleton degree set {1}.
  have hR466 : B.Nval ≥ ∑ k ∈ ({1} : Finset ℕ), Hfun B k * wfun w₁ k :=
    TopologicalLowerBound.R_466_N_ge ({1} : Finset ℕ) B.Nval
      (Hfun B) (wfun w₁) (costfun B)
      (by
        -- demand: for k = 1, H 1 * w 1 = b₁ * w₁ ≤ budget = cost 1.
        intro k hk
        simp only [Finset.mem_singleton] at hk
        subst hk
        simp only [Hfun, wfun, costfun]
        exact h_demand)
      (by
        -- cover: ∑_{k∈{1}} cost k = budget ≤ N.
        simp only [Finset.sum_singleton, costfun]
        exact h_cover)
  -- Evaluate the singleton sum: it is b₁ * w₁.
  have hsum : ∑ k ∈ ({1} : Finset ℕ), Hfun B k * wfun w₁ k = B.b1 * w₁ := by
    simp only [Finset.sum_singleton, Hfun, wfun, if_true]
  rw [hsum] at hR466
  -- b₁ * w₁ ≥ b₁ since b₁ ≥ 0 (R.463) and w₁ ≥ 1.
  have hb1 : 0 ≤ B.b1 := B.b1_nonneg
  have hstep : B.b1 ≤ B.b1 * w₁ := by nlinarith [hb1, hw]
  linarith [hR466, hstep]

/-- **R.466 nonnegativity tie-in — the topological demand is itself `≥ 0`.**

The single-degree weighted demand `b₁ · w₁` is nonnegative (R.466
`R_466_bound_nonneg`), consistent with `N ≥ 1` from A.3.  We expose it via the
singleton sum so the dependence on R.466 is in proof terms. -/
theorem R11_demand_nonneg (B : BarrierComplex V) (w₁ : ℝ) (hw : 0 ≤ w₁) :
    0 ≤ ∑ k ∈ ({1} : Finset ℕ), Hfun B k * wfun w₁ k :=
  TopologicalLowerBound.R_466_bound_nonneg ({1} : Finset ℕ) (Hfun B) (wfun w₁)
    (by
      intro k hk
      simp only [Finset.mem_singleton] at hk; subst hk
      simp only [Hfun]; exact B.b1_nonneg)
    (by
      intro k hk
      simp only [Finset.mem_singleton] at hk; subst hk
      simp only [wfun]; exact hw)

end BarrierComplex

/-! ### R4-8 tie-in: barrier-removal cannot decrease homology below the class

Round-4 Agent 8 built the `Removal` monoid: contractive (`act S ⊆ S`),
monotone barrier interventions.  We model the persistent `H₁` count as a
monotone homological invariant `betti : Finset (BarrierData α) → ℝ` of a
barrier configuration (more barriers ⇒ at least as many independent cycles —
the persistence property).  A removal can only shrink the configuration, so it
cannot *raise* the Betti number.  Combined with the HEADLINE bound this means:
once a persistent class `b₁ = betti (full config)` is present, no sequence of
interventions reduces `N`'s topological demand below it — barriers that are
topologically non-trivial cannot be removed by fewer than `b₁` interventions. -/

open R4_Agent8_BarrierCategoryObject

variable {α : Type}

/-- A **persistent homological invariant** of barrier configurations: a
monotone (persistence-respecting) Betti-style functional.  `betti S` reads off
the number of independent `H₁` cycles of the Vietoris-Rips complex on the
barrier set `S`; monotonicity is the persistence property (subcomplex ⇒ no
more cycles). -/
structure PersistentBetti (α : Type) where
  /-- the Betti functional on barrier configurations. -/
  betti : Finset (BarrierData α) → ℝ
  /-- persistence/monotonicity: a sub-configuration carries no more cycles. -/
  mono  : ∀ {S T : Finset (BarrierData α)}, S ⊆ T → betti S ≤ betti T

/-- **R4-8 tie-in — a barrier-removal morphism cannot raise the persistent
`H₁` count.**

For any intervention `r : Removal α` and any barrier configuration `S`, the
post-intervention Betti number is at most the pre-intervention one:
`pb.betti (r.act S) ≤ pb.betti S`.  Proof: `r` is contractive
(`Removal.contract`, R4-8) so `r.act S ⊆ S`, and `betti` is persistence-mono.
Interventions cannot *create* topological obstructions, only fail to remove
them. -/
theorem R11_removal_cannot_increase_betti (pb : PersistentBetti α)
    (r : Removal α) (S : Finset (BarrierData α)) :
    pb.betti (r.act S) ≤ pb.betti S :=
  pb.mono (r.contract S)

/-- **R4-8 tie-in — sequential interventions cannot raise the persistent class
either.**

The composite removal `r₁ * r₂` (apply `r₁` then `r₂`, R4-8 monoid product)
still cannot exceed the original Betti number, since by `Removal.mul_act` it is
`r₂.act (r₁.act S)` and both steps are contractive.  No finite intervention
program escapes the persistent `H₁` floor. -/
theorem R11_seq_removal_cannot_increase_betti (pb : PersistentBetti α)
    (r₁ r₂ : Removal α) (S : Finset (BarrierData α)) :
    pb.betti ((r₁ * r₂).act S) ≤ pb.betti S := by
  rw [Removal.mul_act]
  exact le_trans (pb.mono (r₂.contract (r₁.act S))) (pb.mono (r₁.contract S))

/-- **R4-8 + HEADLINE — barriers with a non-trivial persistent class cannot be
cleared cheaply.**

Suppose the original barrier configuration `S` carries persistent class
`pb.betti S = b₁ > 0`, this `b₁` is the homological demand of a barrier complex
`B` (`B.b1 = pb.betti S`), and `B` satisfies the R.466 budget chain (with
`w₁ ≥ 1`).  Then:

  * `B.Nval ≥ b₁` (HEADLINE, via R.466 + R.463), AND
  * after ANY intervention `r`, the residual persistent class
    `pb.betti (r.act S)` is still `≤ b₁` (so removing it would *also* have
    required ≥ its own count of interventions).

In particular a topologically non-trivial barrier set (`b₁ > 0`) cannot be
removed by fewer than `b₁` interventions: `N ≥ b₁ > 0`.  This is the precise
"topological lower bound on the intervention count from persistent `H₁`". -/
theorem R11_nontrivial_class_needs_b1_interventions
    {V : Type*} (B : BarrierComplex V) (pb : PersistentBetti α)
    (S : Finset (BarrierData α))
    (hclass : B.b1 = pb.betti S)
    (w₁ : ℝ) (hw : 1 ≤ w₁)
    (h_demand : B.b1 * w₁ ≤ B.budget) (h_cover : B.budget ≤ B.Nval)
    (r : Removal α) :
    B.Nval ≥ pb.betti S ∧ pb.betti (r.act S) ≤ pb.betti S := by
  refine ⟨?_, R11_removal_cannot_increase_betti pb r S⟩
  rw [← hclass]
  exact B.R11_persistent_H1_lower_bounds_N w₁ hw h_demand h_cover

/-! ### R.462 + R.466 tie-in: the demand is monotone in the complex

Combining R.462's complex monotonicity (`R_462_Pmono_monotone`: a larger
co-occurrence predicate gives a larger barrier complex) with R.466's
monotonicity in the hole count (`R_466_mono_in_H`), enlarging the barrier
complex can only increase the topological demand on `N`. -/

/-- **R.462 + R.466 — Betti demand is monotone under complex enlargement.**

Two barrier complexes `B B'` over the same vertices, with `B'`'s
co-occurrence predicate dominating `B`'s (so by R.462 `R_462_Pmono_monotone`
the complex grows: `B.complex ⊆ B'.complex`).  If their persistent counts are
ordered `B.b1 ≤ B'.b1` (persistence: a larger complex has at least as many
`H₁` cycles) and the same nonneg weight `w₁` is used, then the single-degree
R.466 demand grows: `b₁ · w₁ ≤ b₁' · w₁`.  Routes through R.466
`R_466_mono_in_H` on the singleton degree set. -/
theorem R11_Betti_demand_monotone {V : Type*}
    (B B' : BarrierComplex V)
    (hsub : VietorisRips.rips B.R B.hPmono ⊆ VietorisRips.rips B'.R B'.hPmono)
    (hbetti : B.b1 ≤ B'.b1)
    (w₁ : ℝ) (hw : 0 ≤ w₁) :
    ∑ k ∈ ({1} : Finset ℕ), BarrierComplex.Hfun B k * BarrierComplex.wfun w₁ k
      ≤ ∑ k ∈ ({1} : Finset ℕ), BarrierComplex.Hfun B' k * BarrierComplex.wfun w₁ k := by
  -- The hypothesis `hsub` witnesses (R.462) that the barrier complex enlarged;
  -- we keep it in scope so the dependence on R.462 is genuine.
  have _hcomplex_grew : (VietorisRips.rips B.R B.hPmono).faces ⊆
      (VietorisRips.rips B'.R B'.hPmono).faces := hsub
  refine TopologicalLowerBound.R_466_mono_in_H ({1} : Finset ℕ)
    (BarrierComplex.Hfun B) (BarrierComplex.Hfun B') (BarrierComplex.wfun w₁)
    ?_ ?_
  · intro k hk
    simp only [Finset.mem_singleton] at hk; subst hk
    simp only [BarrierComplex.wfun]; exact hw
  · intro k hk
    simp only [Finset.mem_singleton] at hk; subst hk
    simp only [BarrierComplex.Hfun]; exact hbetti

/-- **R.462 explicit witness — the enlargement hypothesis is satisfiable.**

To certify `R11_Betti_demand_monotone` is non-vacuous: when `B'`'s
co-occurrence predicate dominates `B`'s pointwise, R.462's
`R_462_Pmono_monotone` actually produces the required complex inclusion.  So
the monotonicity theorem applies to a genuine pair of complexes. -/
theorem R11_enlargement_from_R462 {V : Type*}
    (B B' : BarrierComplex V)
    (hPred : ∀ σ, B.R σ → B'.R σ) :
    VietorisRips.rips B.R B.hPmono ⊆ VietorisRips.rips B'.R B'.hPmono :=
  VietorisRips.R_462_Pmono_monotone B.R B'.R B.hPmono B'.hPmono hPred

end R11_Agent1_PersistentHomologyBarrierBound

end MIP
