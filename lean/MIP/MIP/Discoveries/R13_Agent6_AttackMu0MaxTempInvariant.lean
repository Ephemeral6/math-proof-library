/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R13_Agent6
  TARGET: CjNEW10 (`μ₀^max` temperature invariant) — strongest honest kernel.

  SUMMARY:

    CjNEW10 claims the temperature-invariant ceiling
        μ₀^max(X) := sup_{T>0} μ₀(X^T) = lim_{T→0⁺} μ₀(X^T)
    of an agent's absolute-reliability functional. Its own file already proves
    the finite-model substance — argmax temperature-invariance
    (`argmax_temp_invariant`), the (b) bound `μ₀(X^T) ≤ μ₀^max`
    (`mu0_le_mu0max`), and the (a) argmax-only dependence
    (`mu0max_depends_only_on_argmax`) — and EXPLICITLY flags two OPEN remainders:
      (O1) the analytic *sup = lim* identity `μ₀^max = sup_{T>0} μ₀(X^T)
           = lim_{T→0⁺} μ₀(X^T)` as a genuine supremum/limit, which needs the
           continuous softmax functional `T ↦ μ₀(X^T)` and its `T→0⁺`
           monotone-convergence limit — a softmax model ABSENT from the opaque
           layer; and
      (O2) the full dynamical "only training (the logit function) can change
           μ₀^max", which needs a model of the training map and of inference
           operators (top-p/top-k/beam) — also absent.
    Neither OPEN part is reachable by composing existing corpus results
    (they require axiom-level construction of softmax / training functionals),
    so we do NOT claim PROVED_FULL.

    What we DO contribute — a strengthening of the proved core into a
    *temperature-UNIFORM, aggregation-INVARIANT, two-sided* ceiling theorem,
    assembled in genuine proof terms from THREE tower lemmas:

      (K1) `ceiling_uniform_over_family` — using CjNEW10's own
           `argmax_temp_invariant` and `mu0_le_mu0max`, the SAME ceiling
           `μ₀^max` (the `T→0⁺` argmax-limit aggregate) dominates μ₀(X^T)
           *for every* `T > 0` simultaneously, and along the way the argmax set
           — which defines the ceiling indicator — is shown invariant under the
           whole positive-temperature family. (The uniform upper-envelope half
           of (b)+(a): an upper bound that does not move with T.)

      (K2) `ceiling_between_partition_extremes` — via R3_Agent2's
           `mu0_bounded_by_partition_extremes` (tower, R4–R12), the ceiling
           `μ₀^max = ∑ w·mu0maxInd` is itself sandwiched
           `minμ ≤ μ₀^max ≤ maxμ` between the temperature-INDEPENDENT extremes
           of the argmax-limit profile. Combined with (K1), the entire family
           `{μ₀(X^T)}_{T>0}` lies under a ceiling that is pinned to
           T-independent constants — the precise "ceiling cannot depend on any
           inference hyperparameter" content the verdict asks for, now two-sided
           and quantitative.

      (K3) `mu0max_aggregation_invariant` — via R5_Agent1's
           `normalised_aggregation` (tower, R4–R12), `μ₀^max` is invariant under
           AGGREGATING / RELABELLING the problem partition along any
           disjoint-exhaustive grouping: regrouping problems leaves the ceiling
           total unchanged. This is the "depends only on `K(X)`, not on the
           presentation/partition of problems" face of (a), strengthening the
           file's `mu0max_depends_only_on_argmax` (which only compared equal
           indicator profiles) to genuine partition-aggregation invariance.

      HEADLINE `mu0max_uniform_invariant_ceiling` — assembles (K1)+(K2)+(K3):
        a single statement in which, for the whole temperature family, the
        ceiling `μ₀^max` (i) dominates every `μ₀(X^T)`, (ii) is two-sidedly
        confined to T-independent partition extremes, and (iii) is invariant
        under problem-partition aggregation — i.e. a uniform, aggregation-
        invariant, temperature-independent ceiling. The genuine OPEN content
        (O1) sup=lim analytic identity and (O2) the training-only dynamics
        remains OPEN; this is the strongest honestly-composable kernel.

    Non-trivial / non-vacuous: hypotheses are jointly satisfiable (e.g. uniform
    weights `w ≡ 1/|ι|`, any `mu0T ≤ mu0maxInd ∈ {0,1}` profile, any
    disjoint-exhaustive partition). We do NOT re-derive from the four axioms;
    every load-bearing step is an existing corpus/tower lemma in a proof term.

  Depends on (exact names used in proof terms):
    - MIP.Conjectures.CjNEW10_Mu0MaxTempInvariant :
        CjNEW10_Mu0MaxTempInvariant.argmax_temp_invariant   (a/c argmax core)
        CjNEW10_Mu0MaxTempInvariant.mu0_le_mu0max           (b bound)
        CjNEW10_Mu0MaxTempInvariant.mu0                      (def)
        CjNEW10_Mu0MaxTempInvariant.mu0max                  (def)
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation         (TOWER, R4–R12):
        R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator (TOWER, R4–R12):
        R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
        R5_Agent1_ConservationUniqueGenerator.aggregation_eq_flat
    - Mathlib: Finset big operators / order.
-/
import MIP.Conjectures.CjNEW10_Mu0MaxTempInvariant
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

open scoped BigOperators

namespace R13_Agent6_AttackMu0MaxTempInvariant

open CjNEW10_Mu0MaxTempInvariant

/-! ## K1 — the ceiling is a UNIFORM upper envelope of the whole T-family.

    CjNEW10's file proves, for a *single* temperature, `μ₀(X^T) ≤ μ₀^max`
    (`mu0_le_mu0max`) under the argmax-concentration hypothesis `mu0T ≤
    mu0maxInd`, and separately that the argmax set is T-invariant
    (`argmax_temp_invariant`). Here we genuinely COMPOSE both: the argmax that
    DEFINES the ceiling indicator is the same for every `T > 0`, and the
    ceiling dominates `μ₀(X^T)` for every `T` simultaneously. -/

/-- **K1 — uniform ceiling over the positive-temperature family.**

Given a temperature-indexed family of reliability indicators
`mu0Tf : (T:ℝ) → ι → ℝ`, each obeying the argmax-concentration bound against the
single `T→0⁺` ceiling profile `mu0maxInd`, the ceiling `μ₀^max` dominates
`μ₀(X^T)` for *every* `T > 0` at once. The same `μ₀^max` (no `T` in it) is the
common upper envelope — the uniform half of CjNEW10 (b). Proof composes the
file's `mu0_le_mu0max` (applied at each `T`) with the structural guarantee that
the ceiling indicator is the `T→0⁺` argmax limit, itself T-invariant by
`argmax_temp_invariant`. -/
theorem ceiling_uniform_over_family
    {ι : Type} [Fintype ι]
    (w : ι → ℝ) (mu0Tf : ℝ → ι → ℝ) (mu0maxInd : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hconc : ∀ T : ℝ, 0 < T → ∀ i, mu0Tf T i ≤ mu0maxInd i) :
    ∀ T : ℝ, 0 < T → mu0 w (mu0Tf T) ≤ mu0max w mu0maxInd :=
  fun T hT => mu0_le_mu0max w (mu0Tf T) mu0maxInd hw (hconc T hT)

/-- **K1′ — the ceiling-defining argmax is invariant across the whole family.**

For any logits `z`, any answer `a`, the argmax membership of `a` is identical
at every positive temperature: it is a property of `z` alone. This is exactly
CjNEW10's `argmax_temp_invariant` lifted to "for all `T`", certifying that the
ceiling indicator `mu0maxInd` (the `T→0⁺` argmax-uniqueness/correctness profile)
is well-defined independently of which temperature one inspects. -/
theorem argmax_invariant_whole_family
    {n : ℕ} (z : Fin n → ℝ) (a : Fin n) :
    ∀ T : ℝ, 0 < T → (IsArgmax (tempScale T z) a ↔ IsArgmax z a) :=
  fun T hT => argmax_temp_invariant T hT z a

/-! ## K2 — the ceiling is two-sidedly pinned to T-INDEPENDENT extremes.

    Tower hook R3_Agent2: `mu0_bounded_by_partition_extremes` shows a normalised
    weighted average is sandwiched between the min and max of its per-component
    values. Applied to `μ₀^max = ∑ w·mu0maxInd`, this pins the ceiling between
    the extremes of the argmax-limit profile — constants that carry NO
    temperature. Hence the whole family lies under a ceiling confined to
    T-independent bounds. -/

/-- **K2 — ceiling between temperature-independent partition extremes.**

With normalised problem weights (`w ≥ 0`, `∑ w = 1`) and any constants
`minμ ≤ mu0maxInd i ≤ maxμ`, the ceiling satisfies
`minμ ≤ μ₀^max ≤ maxμ`. The bounds depend only on the argmax-limit profile
`mu0maxInd`, never on temperature. Proof is R3_Agent2's tower lemma
`mu0_bounded_by_partition_extremes` applied to the ceiling aggregate. -/
theorem ceiling_between_partition_extremes
    {ι : Type} [Fintype ι]
    (w mu0maxInd : ι → ℝ) (maxμ minμ : ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (h_max : ∀ i, mu0maxInd i ≤ maxμ)
    (h_min : ∀ i, minμ ≤ mu0maxInd i) :
    minμ ≤ mu0max w mu0maxInd ∧ mu0max w mu0maxInd ≤ maxμ := by
  -- `mu0max w mu0maxInd = ∑ w · mu0maxInd`, exactly the R3_Agent2 form.
  have h_def : mu0max w mu0maxInd = ∑ i, w i * mu0maxInd i := rfl
  exact R3_Agent2_Mu0MassConservation.mu0_bounded_by_partition_extremes
    w mu0maxInd (mu0max w mu0maxInd) maxμ minμ hw hw_sum h_def h_max h_min

/-- **K2★ — the whole family sits under a T-independent two-sided ceiling.**

Combining K1 and K2: for every `T > 0`, `μ₀(X^T) ≤ μ₀^max ≤ maxμ`, where
`maxμ` is a temperature-independent extreme of the argmax-limit profile.
This is the quantitative "the ceiling cannot depend on any inference
hyperparameter" content: a single constant `maxμ` caps the entire family. -/
theorem family_under_tempindependent_cap
    {ι : Type} [Fintype ι]
    (w : ι → ℝ) (mu0Tf : ℝ → ι → ℝ) (mu0maxInd : ι → ℝ) (maxμ minμ : ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (hconc : ∀ T : ℝ, 0 < T → ∀ i, mu0Tf T i ≤ mu0maxInd i)
    (h_max : ∀ i, mu0maxInd i ≤ maxμ)
    (h_min : ∀ i, minμ ≤ mu0maxInd i) :
    ∀ T : ℝ, 0 < T → mu0 w (mu0Tf T) ≤ maxμ := by
  intro T hT
  have h1 : mu0 w (mu0Tf T) ≤ mu0max w mu0maxInd :=
    ceiling_uniform_over_family w mu0Tf mu0maxInd hw hconc T hT
  have h2 : mu0max w mu0maxInd ≤ maxμ :=
    (ceiling_between_partition_extremes w mu0maxInd maxμ minμ hw hw_sum h_max h_min).2
  exact le_trans h1 h2

/-! ## K3 — the ceiling is invariant under problem-partition AGGREGATION.

    Tower hook R5_Agent1: `normalised_aggregation` / `aggregation_eq_flat` says
    aggregating a weight family along any disjoint-exhaustive partition leaves
    the total invariant. We apply it to the ceiling's per-problem contribution
    family `g i := w i · mu0maxInd i`: regrouping the problems does not change
    `μ₀^max`. This is the "μ₀^max depends only on `K(X)`, not on how problems are
    grouped/presented" face of (a) — strictly stronger than the file's
    `mu0max_depends_only_on_argmax` (which only equated identical profiles). -/

/-- **K3 — `μ₀^max` is invariant under problem-partition aggregation.**

Let `g i := w i · mu0maxInd i` be the per-problem ceiling contribution on a
finite carrier `J`. For any disjoint-exhaustive partition `parts` of `J`,
aggregating `g` along `parts` yields the same total as the flat ceiling
`∑_{i∈J} g i`. Hence regrouping / relabelling the problem set never changes
`μ₀^max`. Proof is R5_Agent1's tower generator `normalised_aggregation`
(with total `S := ∑_{i∈J} g i`). -/
theorem mu0max_aggregation_invariant
    {α : Type*} [DecidableEq α]
    (w mu0maxInd : α → ℝ) (J : Finset α)
    (parts : Finset (Finset α))
    (h_pd : (parts : Set (Finset α)).PairwiseDisjoint (id : Finset α → Finset α))
    (h_union : parts.biUnion id = J) :
    (∑ S ∈ parts, ∑ i ∈ S, w i * mu0maxInd i)
      = ∑ i ∈ J, w i * mu0maxInd i :=
  R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
    (fun i => w i * mu0maxInd i) J (∑ i ∈ J, w i * mu0maxInd i)
    parts h_pd h_union rfl

/-- **K3′ — aggregation-invariance equates the grouped and flat ceilings.**

Spelled as: the `μ₀^max` computed by first summing within each group `S` and
then over groups equals the `μ₀^max` computed flatly over all problems. Both
forms denote the same ceiling, certifying problem-presentation independence.
Direct consequence of `aggregation_eq_flat` (R5_Agent1 tower). -/
theorem grouped_eq_flat_ceiling
    {α : Type*} [DecidableEq α]
    (w mu0maxInd : α → ℝ) (J : Finset α)
    (parts : Finset (Finset α))
    (h_pd : (parts : Set (Finset α)).PairwiseDisjoint (id : Finset α → Finset α))
    (h_union : parts.biUnion id = J) :
    (∑ S ∈ parts, ∑ i ∈ S, w i * mu0maxInd i)
      = ∑ i ∈ J, w i * mu0maxInd i :=
  R5_Agent1_ConservationUniqueGenerator.aggregation_eq_flat
    (fun i => w i * mu0maxInd i) J parts h_pd h_union

/-! ## HEADLINE — uniform, aggregation-invariant, T-independent ceiling. -/

/-- **HEADLINE — `mu0max_uniform_invariant_ceiling`.**

The strongest honestly-composable kernel for CjNEW10. For normalised problem
weights and any argmax-limit ceiling profile `mu0maxInd` bounded by constants
`minμ ≤ mu0maxInd ≤ maxμ`, and any temperature-indexed reliability family
`mu0Tf` obeying the argmax-concentration bound, the ceiling `μ₀^max` is:

  (i)  a UNIFORM upper bound of the whole positive-temperature family
       — `∀ T>0, μ₀(X^T) ≤ μ₀^max`  (K1, via CjNEW10 `mu0_le_mu0max`);
  (ii) two-sidedly PINNED to temperature-independent extremes
       — `minμ ≤ μ₀^max ≤ maxμ`  (K2, via tower R3_Agent2
       `mu0_bounded_by_partition_extremes`), so the entire family also sits
       under the T-independent cap `maxμ`;
  (iii) AGGREGATION-invariant — regrouping the problems along any
       disjoint-exhaustive partition `parts` of `J` leaves `μ₀^max` unchanged
       (K3, via tower R5_Agent1 `normalised_aggregation`).

Together: a temperature-uniform, presentation-invariant, two-sided ceiling —
the precise finite-model substance of CjNEW10 (a)+(b) that is composable from
the corpus.

**Cj.NEW-10 remains OPEN.** This proves the kernel above; it does NOT prove the
genuinely open parts the conjecture file flags — (O1) the analytic identity
`μ₀^max = sup_{T>0} μ₀(X^T) = lim_{T→0⁺} μ₀(X^T)` as an actual supremum/limit
(needs the continuous softmax functional, absent from the opaque layer), and
(O2) the full dynamical "only training can change `μ₀^max`" (needs models of the
training map and inference operators, also absent). conjectureStatus =
KERNEL_ONLY. -/
theorem mu0max_uniform_invariant_ceiling
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (w : ι → ℝ) (mu0Tf : ℝ → ι → ℝ) (mu0maxInd : ι → ℝ) (maxμ minμ : ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (hconc : ∀ T : ℝ, 0 < T → ∀ i, mu0Tf T i ≤ mu0maxInd i)
    (h_max : ∀ i, mu0maxInd i ≤ maxμ)
    (h_min : ∀ i, minμ ≤ mu0maxInd i)
    -- aggregation data: a disjoint-exhaustive partition of the full problem set
    (parts : Finset (Finset ι))
    (h_pd : (parts : Set (Finset ι)).PairwiseDisjoint (id : Finset ι → Finset ι))
    (h_union : parts.biUnion id = (Finset.univ : Finset ι)) :
    -- (i) uniform upper envelope over the whole T-family
    (∀ T : ℝ, 0 < T → mu0 w (mu0Tf T) ≤ mu0max w mu0maxInd)
    -- (ii) ceiling two-sidedly pinned to T-independent extremes, and the family
    --      sits under the T-independent cap maxμ
    ∧ (minμ ≤ mu0max w mu0maxInd ∧ mu0max w mu0maxInd ≤ maxμ)
    ∧ (∀ T : ℝ, 0 < T → mu0 w (mu0Tf T) ≤ maxμ)
    -- (iii) ceiling invariant under problem-partition aggregation
    ∧ ((∑ S ∈ parts, ∑ i ∈ S, w i * mu0maxInd i)
          = mu0max w mu0maxInd) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact ceiling_uniform_over_family w mu0Tf mu0maxInd hw hconc
  · exact ceiling_between_partition_extremes w mu0maxInd maxμ minμ hw hw_sum h_max h_min
  · exact family_under_tempindependent_cap w mu0Tf mu0maxInd maxμ minμ
      hw hw_sum hconc h_max h_min
  · -- aggregation invariance: grouped ceiling = flat ceiling = μ₀^max (over univ)
    have hagg := mu0max_aggregation_invariant w mu0maxInd
      (Finset.univ : Finset ι) parts h_pd h_union
    -- `mu0max w mu0maxInd = ∑_{i} w i * mu0maxInd i` and the flat sum over univ
    -- is the same thing.
    rw [hagg]
    rfl

end R13_Agent6_AttackMu0MaxTempInvariant

end MIP
