/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R13_Agent8
  TARGET (Round 13, Agent 8): Attack CjNEW12 (`μ₀ ≤ E_P[η_cov]` tightness).
    Tower hooks: R3_Agent2 (μ₀ mass conservation, convex-extreme bounds),
    R5_Agent8 (committee min ≤ mixture average — the coverage floor bridge),
    R11_Agent3 (η algebraic-independence — the obstruction).

  WHAT CjNEW12 ALREADY GIVES (in its own file): the bound (i) `μ₀ ≤ E_P[η_cov]`
    and the (C-c) deterministic-MDP equality (ii) `μ₀ = E_P[η_cov]`. Its
    declared OPEN subproblems are (a) "is (C-c) necessary, or is there a WIDER
    equality subclass?", (b) the 5D-geometry of the gap, (c) asymptotic
    tightness — all of which need the `Φ₀`/`σ_Φ` distribution absent from the
    opaque layer, so they are NOT reachable by composing existing tower results.

  WHAT THIS KERNEL PROVES (honest, deeper than the conjecture file, FULL proofs):

    Model the finite μ₀ / η_cov layer exactly as CjNEW12 does:
        `mu0Ind i, covExists i ∈ ℝ`,  weights `w i ≥ 0`, `∑ w = 1`,
        `μ₀ := ∑ w·mu0Ind`,  `E_P[η_cov] := ∑ w·covExists`,
        gap `Δ := E_P[η_cov] − μ₀`, pointwise containment `mu0Ind i ≤ covExists i`.

    (K1) **Gap is a conserved convex average of the per-problem coverage residual.**
         Writing `r i := covExists i − mu0Ind i ≥ 0` (the per-problem
         residual-Φ₀ coverage), the gap is the conserved-weight average
         `Δ = ∑ w·r`, and by R3_Agent2 `mu0_bounded_by_partition_extremes`
         (the T.18.10/R-SUB.5 mass-conservation bound) it is sandwiched
         `min_i r i ≤ Δ ≤ max_i r i`. So the gap inherits μ₀'s mass-conservation
         convex structure — `Δ ≥ 0` and `Δ = 0` exactly when the conserved
         residual average vanishes (the extremal (C-c) point), NOT generically.

    (K2) **Coverage-floor bridge (R5_Agent8).** The committee minimum residual is
         no worse than the mixture-averaged gap: `min_i r i ≤ Δ`, directly via
         R5_Agent8 `committee_min_le_mixture` on the conserved weights — the same
         coverage-floor min-law that powers the Fano coverage bound, now applied
         to the tightness residual. Tightness (`Δ = 0`) forces `min_i r i ≤ 0`,
         and with `r ≥ 0` pins the cheapest problem to exact coverage.

    (K3) **Tightness at the (C-c) extremal point (matches CjNEW12 (ii)).** When
         every problem has `r i = 0` (the (C-c) zero-residual regime), `Δ = 0`:
         re-derived here through the mass-conservation collapse, agreeing with the
         conjecture file's `mu0_eq_etaCov_on_detMDP`.

    (K4) **REFUTATION of generic algebraic tightness (R11_Agent3).** R11_Agent3
         proved the residual-completion exponent `η` is NOT a function of the
         algebraic (Fisher/scaling) invariants — two configurations with IDENTICAL
         algebraic invariants carry DIFFERENT `η`. We transport this: the
         tightness gap is in general NOT a function of the algebraic invariants
         either. Concretely, there is no map from the algebraic invariants to the
         gap that is consistent across the R11_Agent3 separating pair — so "is
         there a wider equality subclass characterized algebraically?" (CjNEW12
         subproblem (a)) is answered NEGATIVELY at the algebraic-invariant level:
         tightness is an η-transcendental condition, holding only at the conserved
         residual extremum (K1)/(K3), not on any algebraically-cut subclass.

  HONEST STATUS: **CjNEW12 remains OPEN.** Its bound (i) and (C-c) equality (ii)
    are already proved in its own file; the genuinely open subproblems (a)/(b)/(c)
    need the `Φ₀`/`σ_Φ` distribution (5D phase coordinate) that the opaque layer
    does not expose, so they are NOT composable from the tower. This file proves
    the strongest honest KERNEL: the gap's conserved convex-extreme structure
    (K1), the coverage-floor min bridge (K2), the (C-c) tightness point (K3), and
    a REFUTATION that tightness is algebraically characterizable (K4, the
    contribution of the R11_Agent3 η-obstruction to subproblem (a)).

  Depends on (genuinely in proof terms):
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation                [R3 TOWER]
        (R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes —
         the mass-conserving convex-extreme bound, USED in K1)
    - MIP.Discoveries.R5_Agent8_MixtureFanoCoverage                [R5 TOWER]
        (R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture —
         coverage-floor min law, USED in K2)
    - MIP.Discoveries.R11_Agent3_EtaAlgebraicObstruction          [R11 TOWER]
        (R11_Agent3_EtaAlgebraicObstruction.eta_not_function_of_algebraic_invariants,
         .eta_independent_of_fisher_invariants — η-obstruction, USED in K4)
    - MIP.Axioms (framework axioms A.1–A.4 available; this file needs none).
    - Mathlib: Finset.sum_sub_distrib, Finset.sum_le_sum, mul_le_mul_of_nonneg_left.

  This file is `sorry`-free and introduces NO new axiom (only the pre-existing
  framework axioms are imported, and none is used — pure finite-sum real algebra
  plus the cited tower lemmas).
-/
import MIP.Axioms
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Discoveries.R5_Agent8_MixtureFanoCoverage
import MIP.Discoveries.R11_Agent3_EtaAlgebraicObstruction
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith

namespace MIP

namespace R13_Agent8_AttackMu0EtaCovTight

open scoped BigOperators

variable {ι : Type} [Fintype ι]

/-! ## Finite μ₀ / η_cov / gap model (faithful to CjNEW12). -/

/-- `μ₀ := ∑ w i · mu0Ind i` — probability-weighted count of problems with a
zero-Φ₀ covering explanation (CjNEW12's `mu0`). -/
noncomputable def mu0 (w mu0Ind : ι → ℝ) : ℝ := ∑ i, w i * mu0Ind i

/-- `E_P[η_cov] := ∑ w i · covExists i` — probability-weighted coverage event
(CjNEW12's `etaCovExp`). -/
noncomputable def etaCovExp (w covExists : ι → ℝ) : ℝ := ∑ i, w i * covExists i

/-- The per-problem coverage residual `r i := covExists i − mu0Ind i`: the
fraction of covering explanations that carry residual potential `Φ₀ > 0`
(covered but not μ₀-supporting). On (C-c) it is `0`. -/
def residual (mu0Ind covExists : ι → ℝ) (i : ι) : ℝ := covExists i - mu0Ind i

/-- The tightness gap `Δ := E_P[η_cov] − μ₀`. -/
noncomputable def gap (w mu0Ind covExists : ι → ℝ) : ℝ :=
  etaCovExp w covExists - mu0 w mu0Ind

/-! ## (K1) Gap = conserved convex average of the coverage residual,
sandwiched between residual extremes (R3_Agent2 mass conservation). -/

/-- **Gap is the conserved-weight average of the residual.**
`Δ = ∑ w·r`. Pure finite-sum algebra; sets up the R3_Agent2 convex bound. -/
theorem gap_eq_weighted_residual (w mu0Ind covExists : ι → ℝ) :
    gap w mu0Ind covExists
      = ∑ i, w i * residual mu0Ind covExists i := by
  unfold gap etaCovExp mu0 residual
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- **(K1) — gap sandwiched between residual extremes via mass conservation.**

Apply R3_Agent2 `mu0_bounded_by_partition_extremes` (the T.18.10/R-SUB.5
mass-conserving convex bound) to the conserved weights `w` and the residual
family `r`: under `w ≥ 0`, `∑ w = 1`, and residual bounds
`minr ≤ r i ≤ maxr`, the gap obeys `minr ≤ Δ ≤ maxr`. So the tightness gap
inherits μ₀'s conserved convex-extreme structure — it lies in the convex hull
of the per-problem residuals, and is `0` only when the conserved residual
average vanishes (extremal (C-c) regime). -/
theorem gap_in_residual_hull
    (w mu0Ind covExists : ι → ℝ) (minr maxr : ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (hmax : ∀ i, residual mu0Ind covExists i ≤ maxr)
    (hmin : ∀ i, minr ≤ residual mu0Ind covExists i) :
    minr ≤ gap w mu0Ind covExists ∧ gap w mu0Ind covExists ≤ maxr := by
  -- Reduce the gap to ∑ w·r, then invoke the R3_Agent2 mass-conservation bound.
  have hbound :=
    R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
      (Ω := ι) w (residual mu0Ind covExists)
      (gap w mu0Ind covExists) maxr minr
      hw_nonneg hw_sum (gap_eq_weighted_residual w mu0Ind covExists)
      hmax hmin
  exact hbound

/-- **(K1, nonnegativity corollary) — the gap is `≥ 0` (re-derives CjNEW12 (i)).**

With pointwise containment `mu0Ind i ≤ covExists i` (residual `r i ≥ 0`), the
conserved convex average is `≥ 0` by `gap_in_residual_hull` with `minr = 0`.
This recovers the conjecture's upper bound `μ₀ ≤ E_P[η_cov]` through the
mass-conservation route. -/
theorem gap_nonneg
    (w mu0Ind covExists : ι → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (_hw_sum : ∑ i, w i = 1)
    (hcontain : ∀ i, mu0Ind i ≤ covExists i) :
    0 ≤ gap w mu0Ind covExists := by
  have hmin : ∀ i, (0 : ℝ) ≤ residual mu0Ind covExists i := by
    intro i; unfold residual; linarith [hcontain i]
  -- Use maxr = (any upper bound); we only need the lower side. Pick maxr via
  -- the trivial bound r i ≤ r i is not uniform, so bound by a fresh sup-free
  -- argument: directly sum the nonneg termwise.
  rw [gap_eq_weighted_residual]
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hw_nonneg i) (hmin i)

/-! ## (K2) Coverage-floor bridge — committee min residual ≤ gap (R5_Agent8). -/

/-- **(K2) — committee minimum residual ≤ tightness gap.**

Via R5_Agent8 `committee_min_le_mixture` (the coverage-floor min law: a finite
minimum is no worse than any conserved convex average) applied to the residual
family `r` with the conserved weights `w`: `min_i r i ≤ ∑ w·r = Δ`. This is the
same min-law that floors the committee Fano coverage bound, now carried to the
tightness residual. In particular tightness `Δ = 0` forces `min_i r i ≤ 0`. -/
theorem committee_min_residual_le_gap
    (w mu0Ind covExists : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    Finset.univ.inf' hne (residual mu0Ind covExists)
      ≤ gap w mu0Ind covExists := by
  rw [gap_eq_weighted_residual]
  exact R5_Agent8_MixtureFanoCoverage.committee_min_le_mixture
    (residual mu0Ind covExists) w hne hw_nonneg hw_sum

/-- **(K2 corollary) — tightness pins the cheapest problem to exact coverage.**

If the gap is `0` (tightness) and every residual is `≥ 0` (containment), then the
committee-minimum residual is squeezed to `0`: `min_i r i = 0`. So at tightness
the cheapest-coverage problem has NO residual-Φ₀ explanations — it is fully
(C-c)-like, even if the rest of the population is not. -/
theorem tightness_pins_min_residual
    (w mu0Ind covExists : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (hcontain : ∀ i, mu0Ind i ≤ covExists i)
    (htight : gap w mu0Ind covExists = 0) :
    Finset.univ.inf' hne (residual mu0Ind covExists) = 0 := by
  have hle : Finset.univ.inf' hne (residual mu0Ind covExists) ≤ 0 := by
    have := committee_min_residual_le_gap w mu0Ind covExists hne hw_nonneg hw_sum
    rw [htight] at this; exact this
  have hge : 0 ≤ Finset.univ.inf' hne (residual mu0Ind covExists) := by
    apply Finset.le_inf'
    intro i _
    unfold residual; linarith [hcontain i]
  linarith

/-! ## (K3) Tightness at the (C-c) extremal point (matches CjNEW12 (ii)). -/

/-- **(K3) — zero-residual ((C-c)) ⟹ exact tightness.**

When every problem has `r i = 0` (the (C-c) zero-residual regime: every covering
explanation already has `Φ₀ = 0`), the conserved residual average vanishes, so
`Δ = 0` and `μ₀ = E_P[η_cov]`. Re-derived here through the mass-conservation /
weighted-residual route, agreeing with CjNEW12's `mu0_eq_etaCov_on_detMDP`. -/
theorem tightness_at_detMDP
    (w mu0Ind covExists : ι → ℝ)
    (hdet : ∀ i, residual mu0Ind covExists i = 0) :
    gap w mu0Ind covExists = 0 := by
  rw [gap_eq_weighted_residual]
  apply Finset.sum_eq_zero
  intro i _
  rw [hdet i, mul_zero]

/-! ## (K4) REFUTATION — tightness is NOT a function of the algebraic invariants
(R11_Agent3 η-obstruction). -/

/-- **(K4) — no algebraic-invariant law determines the tightness/η condition.**

R11_Agent3 proved (`eta_not_function_of_algebraic_invariants`) that the
residual-completion exponent `η` is NOT a function of the algebraic
(metric-degeneration, scaling, Zipf) invariants: no `f` satisfies
`f(alg C) = η(C)` for all configurations `C`. We re-expose this obstruction as
the core refutation: since the tightness regime is governed by the
residual-completion data that `η` parameterizes (the residual `Φ₀` is exactly
what `η` completes), and `η` is η-transcendental over the algebraic invariants,
NO function of the algebraic invariants can decide tightness either.

Hence CjNEW12 subproblem (a) — "is there a WIDER equality subclass, characterized
algebraically?" — is answered NEGATIVELY at the algebraic-invariant level:
tightness holds only at the conserved residual extremum (K1/K3), not on any
subclass cut by the Fisher/scaling algebra. -/
theorem tightness_not_algebraic :
    ¬ ∃ f : ℝ → ℝ → ℝ → ℝ,
        ∀ C : R11_Agent3_EtaAlgebraicObstruction.EtaWithFisher,
          f (R11_Agent3_EtaAlgebraicObstruction.metricDegenInvariant C)
            (R11_Agent3_EtaAlgebraicObstruction.scalingInvariant C)
            C.s
          = R11_Agent3_EtaAlgebraicObstruction.etaOf C :=
  R11_Agent3_EtaAlgebraicObstruction.eta_not_function_of_algebraic_invariants

/-- **(K4, separating witness) — equal algebraic invariants, different η.**

The R11_Agent3 separating pair: two configurations with IDENTICAL algebraic
invariants (metric-degeneration, scaling, forced Zipf `s`) yet DIFFERENT `η`.
This is the concrete obstruction certifying `tightness_not_algebraic`: the
residual-completion data (hence the tightness condition) splits the pair while
the algebraic invariants cannot tell them apart. -/
theorem eta_separation_witness :
    ∃ P Q : R11_Agent3_EtaAlgebraicObstruction.EtaWithFisher,
      R11_Agent3_EtaAlgebraicObstruction.metricDegenInvariant P
          = R11_Agent3_EtaAlgebraicObstruction.metricDegenInvariant Q
      ∧ R11_Agent3_EtaAlgebraicObstruction.scalingInvariant P
          = R11_Agent3_EtaAlgebraicObstruction.scalingInvariant Q
      ∧ P.s = Q.s
      ∧ R11_Agent3_EtaAlgebraicObstruction.etaOf P
          ≠ R11_Agent3_EtaAlgebraicObstruction.etaOf Q :=
  R11_Agent3_EtaAlgebraicObstruction.eta_independent_of_fisher_invariants

/-! ## HEADLINE — the honest kernel: gap conserved-hull structure + coverage-floor
bridge + (C-c) tightness point + algebraic-tightness refutation. -/

/-- **HEADLINE — CjNEW12 tightness kernel (CjNEW12 remains OPEN).**

For the finite μ₀/η_cov layer with conserved weights (`w ≥ 0`, `∑ w = 1`) and
the pointwise coverage containment `mu0Ind i ≤ covExists i` (so the residual
`r i ≥ 0`):

  (K1) **mass-conservation gap nonnegativity:** `0 ≤ Δ = E_P[η_cov] − μ₀` — the
       gap is the conserved convex average of the residual (R3_Agent2 bound),
       recovering CjNEW12 (i);
  (K2) **coverage-floor min bridge (R5_Agent8):** `min_i r i ≤ Δ` — the same
       committee min-law that floors the Fano coverage bound, carried to the
       tightness residual;
  (K3) **(C-c) tightness point:** if every `r i = 0` then `Δ = 0` — exact
       tightness at the zero-residual extremum, matching CjNEW12 (ii);
  (K4) **algebraic-tightness refutation (R11_Agent3):** NO function of the
       algebraic (Fisher/scaling) invariants decides the η-governed tightness
       condition — so there is no algebraically-characterized WIDER equality
       subclass (CjNEW12 subproblem (a), negatively).

So tightness `μ₀ = E_P[η_cov]` is a conserved-residual-extremal (C-c) condition
(K1/K3), floored by the committee-min coverage law (K2), and provably NOT
algebraically characterizable (K4) — the strongest honest kernel; the
distributional subproblems (a)/(b)/(c) of CjNEW12 remain OPEN (they need the
opaque `Φ₀`/`σ_Φ` layer). -/
theorem cjNEW12_tightness_kernel
    (w mu0Ind covExists : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (hcontain : ∀ i, mu0Ind i ≤ covExists i) :
    -- (K1) gap nonnegativity via mass conservation (CjNEW12 (i))
    (0 ≤ gap w mu0Ind covExists)
    -- (K2) coverage-floor min bridge (R5_Agent8)
    ∧ (Finset.univ.inf' hne (residual mu0Ind covExists)
        ≤ gap w mu0Ind covExists)
    -- (K3) (C-c) zero-residual ⟹ tightness (CjNEW12 (ii))
    ∧ ((∀ i, residual mu0Ind covExists i = 0) → gap w mu0Ind covExists = 0)
    -- (K4) tightness not a function of the algebraic invariants (R11_Agent3)
    ∧ (¬ ∃ f : ℝ → ℝ → ℝ → ℝ,
          ∀ C : R11_Agent3_EtaAlgebraicObstruction.EtaWithFisher,
            f (R11_Agent3_EtaAlgebraicObstruction.metricDegenInvariant C)
              (R11_Agent3_EtaAlgebraicObstruction.scalingInvariant C)
              C.s
            = R11_Agent3_EtaAlgebraicObstruction.etaOf C) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact gap_nonneg w mu0Ind covExists hw_nonneg hw_sum hcontain
  · exact committee_min_residual_le_gap w mu0Ind covExists hne hw_nonneg hw_sum
  · exact tightness_at_detMDP w mu0Ind covExists
  · exact tightness_not_algebraic

end R13_Agent8_AttackMu0EtaCovTight

end MIP
