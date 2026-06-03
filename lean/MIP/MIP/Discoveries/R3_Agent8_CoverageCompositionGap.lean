/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 8
  DIRECTION: B — R.813 (joint coverage) + R.814 (composition gap) ⟹
             joint coverage achievable but composition-gap-bounded.

  SUMMARY:
    Two-result composition giving the tight inequality on collective
    solvability at the boundary of joint coverage.

    R.813(a) (`joint_coverage_necessary`) says: a positive-probability
    collaborative solve forces a coverage witness `∃ R ⊆ K(X) ∪ K(Y)`.
    R.814 (`composition_gap_with_witness`) says: such a coverage witness
    can be present yet *both* single-agent emergence degrees are infinite
    when no single agent covers any explanation alone.

    Compose: (i) coverage is *necessary* for collaborative finiteness, and
    (ii) coverage is *insufficient* for single-agent solvability when the
    only covered derivations are cross-seam. The tight inequality:

        coverage-achievable ∧ no-single-covers ⟹ N(p,X) = N(p,Y) = ⊤

    so that *under coverage*, the only way to escape the composition gap
    is for one of the single agents to itself cover -- otherwise the
    collaboration's `N` channel reduces to cross-seam transfer, which by
    R.814(a) is single-agent-unexecutable.

    We also prove the contrapositive form: if even one single agent has
    finite `N`, then either the trap zone is broken, or coverage is
    realised "internally" by one of the agents.

  R-DEPS:
    • MIP.Results.R813_JointCoverage    (joint_coverage_necessary,
                                         SR_collab_implies_single,
                                         cover_union_of_left/right)
    • MIP.Results.R814_CompositionGap   (composition_gap, seam_no_executor,
                                         composition_gap_with_witness)
-/
import MIP.Results.R813_JointCoverage
import MIP.Results.R814_CompositionGap

namespace MIP

namespace R3_Agent8_CoverageCompositionGap

open MIP.Axioms

variable {α Ω : Type}

/-! ### Part 1 — Coverage achievable ⟹ no single agent can be ruled out.

R.813(a) packs the "coverage necessary" direction. We re-package it for
chained reasoning. -/

/-- **R.813 ⊕ R.814 — coverage witness extraction from a solving hypothesis.**

A positive-probability collaborative solve (`Solves`, with the D.1.3 bridge
`solve_gives_cover`) yields a joint-coverage witness in the union
`K(X) ∪ K(Y)`. This is R.813(a) restated as a usable lemma for the
composition-gap chain. -/
theorem coverage_from_solve
    (p : Problem α) (X Y : Agent α)
    (Solves : Prop) (hsolve : Solves)
    (solve_gives_cover : Solves →
      ∃ R' ∈ (demandFamily p : Set (Set Ω)),
        R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω) :=
  R813_JointCoverage.joint_coverage_necessary (Ω := Ω) p X Y
    Solves hsolve solve_gives_cover

/-! ### Part 2 — Tight inequality: coverage ∧ no-single-cover ⟹ both `N = ⊤`.

This is the "composition gap" closure: joint coverage is achieved (R.813a)
yet both single agents have `N = ⊤` (R.814b). The cleanly chained form. -/

/-- **R.813(a) ⊕ R.814(b) — coverage + neither-single-covers ⟹ both `N = ⊤`.**

A positive-probability collaborative solve gives a coverage witness in
`K(X) ∪ K(Y)` (R.813a). If additionally neither single agent covers an
explanation alone (the composition-gap hypotheses of R.814b), then both
single-agent emergence degrees are infinite -- *and the coverage witness
explicitly displays the gap*. The triple is the tight statement.

Stated form: there is a joint-coverage witness `R₀ ⊆ K(X) ∪ K(Y)`, *and*
`N(p,X) = ⊤ ∧ N(p,Y) = ⊤`. -/
theorem coverage_composition_gap_tight
    (p : Problem α) (X Y : Agent α)
    (Solves : Prop) (hsolve : Solves)
    (solve_gives_cover : Solves →
      ∃ R' ∈ (demandFamily p : Set (Set Ω)),
        R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω))
    (hX_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
    (hY_nocover : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) ∪ (K Y : Set Ω))
      ∧ N p X = ⊤ ∧ N p Y = ⊤ := by
  refine ⟨coverage_from_solve (Ω := Ω) p X Y Solves hsolve solve_gives_cover, ?_, ?_⟩
  · exact (R814_CompositionGap.composition_gap (Ω := Ω) p X Y hX_nocover hY_nocover).1
  · exact (R814_CompositionGap.composition_gap (Ω := Ω) p X Y hX_nocover hY_nocover).2

/-! ### Part 3 — Contrapositive: at least one single-agent finite `N` ⟹
escape from the trap zone.

The dual: if either `N(p,X) ≠ ⊤` or `N(p,Y) ≠ ⊤`, then by A.2 at least one
single agent covers; so the trap-zone composition gap (R.814b) is *not* in
effect at this configuration. We package this as the *contrapositive
tightness statement*. -/

/-- **R.814 contrapositive (one agent finite ⟹ escape composition gap).**

If at least one single agent has finite `N` (`N(p,X) ≠ ⊤` or `N(p,Y) ≠ ⊤`),
then the trap-zone composition-gap hypothesis fails: at least one of
`∃ R ⊆ K(X)` or `∃ R ⊆ K(Y)` holds. So the R.814 gap regime is incompatible
with single-agent finiteness on *either* side. -/
theorem escape_composition_gap
    (p : Problem α) (X Y : Agent α)
    (hOne : N p X ≠ ⊤ ∨ N p Y ≠ ⊤) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
      ∨ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)) := by
  rcases hOne with hX | hY
  · exact Or.inl ((Axioms.A2 (Ω := Ω) p X).mp hX)
  · exact Or.inr ((Axioms.A2 (Ω := Ω) p Y).mp hY)

/-- **R.813 ⊕ R.814 — composition-gap dichotomy under coverage.**

Given a joint-coverage witness `R₀ ⊆ K(X) ∪ K(Y)` (the R.813a precondition):
either some single agent covers (escape), or *both* single-agent `N` are `⊤`
(composition gap). No middle case at the single-agent A.2 level. -/
theorem coverage_dichotomy
    (p : Problem α) (X Y : Agent α)
    (R₀ : Set Ω) (_hR₀_mem : R₀ ∈ (demandFamily p : Set (Set Ω)))
    (_hR₀_cover : R₀ ⊆ (K X : Set Ω) ∪ (K Y : Set Ω)) :
    ((∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        ∨ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)))
      ∨ (N p X = ⊤ ∧ N p Y = ⊤) := by
  by_cases hX : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)
  · exact Or.inl (Or.inl hX)
  · by_cases hY : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K Y : Set Ω)
    · exact Or.inl (Or.inr hY)
    · exact Or.inr (R814_CompositionGap.composition_gap (Ω := Ω) p X Y hX hY)

/-! ### Part 4 — Seam carry forward: cross-seam ⟹ no single executor.

R.814(a) (`seam_no_executor`) says a cross-seam hyperedge is unexecutable by
either single agent. Composed with R.813(b) (`transfer_in_O`, the bottleneck):
if the seam token `ω*` cannot lie in `K X ∩ K Y` (no cross-transfer effective
at *any* history), the hyperedge cannot be assembled by cross-transfer either. -/

/-- **R.813(b) ⊕ R.814(a) — seam tightness.**

If a hyperedge vertex set `V` contains seam witnesses `ωx ∈ K(X) \ K(Y)` and
`ωy ∈ K(Y) \ K(X)`, then `V` is not contained in `K X` or in `K Y`. (Pure
re-statement of `seam_no_executor`; chained here as the entry point for the
R.813 transfer-bottleneck argument.) -/
theorem seam_no_single
    (X Y : Agent α) (V : Set Ω) (ωx ωy : Ω)
    (hωx_in : ωx ∈ V) (hωy_in : ωy ∈ V)
    (hωx : ωx ∈ ((K X : Set Ω) \ (K Y : Set Ω)))
    (hωy : ωy ∈ ((K Y : Set Ω) \ (K X : Set Ω))) :
    ¬ (V ⊆ (K X : Set Ω) ∨ V ⊆ (K Y : Set Ω)) :=
  R814_CompositionGap.seam_no_executor (Ω := Ω) X Y V ωx ωy
    hωx_in hωy_in hωx hωy

end R3_Agent8_CoverageCompositionGap

end MIP
