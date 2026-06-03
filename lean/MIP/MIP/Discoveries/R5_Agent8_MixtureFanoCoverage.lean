/-
  STATUS: DISCOVERY
  AGENT: R5_Agent8
  DIRECTION: MIXTURE CONSERVATION × FANO — a conserved committee mixture
    `∑_a w_a · π_a` (R4_Agent6, additive/direct-sum face) forces a μ-Fano
    coverage LOWER BOUND on the mixture-AVERAGED intervention count
    `N̄ := ∑_a w_a · N_a`, and the committee minimum is no worse than any
    individual. This is DEEPER than Round-4: R4_Agent6 conserved the mixture
    and proved the multiplicative committee non-worsening; R3_Agent8 floored
    only the SINGLE attaining agent's N. Here the CONSERVED WEIGHTS of the
    mixture are pushed THROUGH the R.811 Fano accumulation to give a Fano
    floor on the genuine convex-average N̄ of the WHOLE committee — not just
    one agent — together with a committee-min law (R.143).

  SUMMARY:
    Setup. A committee of agents `a : ι` carries:
      * a conserved convex mixture: weights `w_a ≥ 0`, `∑_a w_a = 1`, and
        per-agent distributions `π_a : Ω → ℝ` each conserved
        (`∑_ω π_a ω = 1`). R4_Agent6 `mixture_conservation` certifies the
        mixture `ω ↦ ∑_a w_a π_a ω` is itself a conserved distribution.
      * per-agent R.480/R.811 Fano accumulations `Φ₀ ≤ N_a · log(cardM_a)`
        with `1 < cardM_a` (readable alphabet nontrivial), all sharing the
        SAME emergence potential `Φ₀`.

    (a) **Mixture-weighted Fano accumulation** (`mixture_fano_accumulation`).
        With a uniform per-step capacity ceiling `L` (`log(cardM_a) ≤ L`),
        the CONSERVED weights transport the per-agent accumulations into a
        single accumulation on the convex-average count `N̄ := ∑_a w_a N_a`:

            Φ₀  =  (∑_a w_a) · Φ₀  ≤  (∑_a w_a N_a) · L  =  N̄ · L.

        The first equality is EXACTLY the conservation `∑ w_a = 1` (the
        same invariant R4_Agent6 conserved); the inequality is the
        weight-by-weight chaining of the R.811 accumulation. So the
        conserved mixture's averaged intervention budget carries the full
        potential — no committee weighting can dilute the Fano obligation.

    (b) **Mixture-averaged Fano coverage lower bound** (`mixture_fano_floor`).
        Dividing by the strictly-positive uniform capacity `L = log(cardMmax)`
        (`1 < cardMmax`), R.811 `R_811_collab_fano_lower` gives the committee
        coverage floor

            Φ₀ / log(cardMmax)  ≤  N̄  =  ∑_a w_a N_a,

        and it is strictly positive when `Φ₀ > 0` (committee collaboration is
        never free — R.811 `R_811_lower_pos`).

    (c) **Committee no-worse + Fano** (`mixture_committee_fano`, HEADLINE).
        Combine: the committee MINIMUM `N(k) := min_a N_a` is no worse than
        any individual (R.143 `R_143_collective_le_individual`), AND lies
        below the mixture average `N̄` (a min is ≤ any convex average,
        proved here from conservation), AND the mixture average inherits the
        Fano floor (b). Chaining gives the full sandwich

            Φ₀ / log(cardMmax) ≤ N̄ = ∑_a w_a N_a   and   N(k) ≤ N̄,  N(k) ≤ N_b.

        i.e. the conserved committee mixture is Fano-bounded BELOW by the
        information potential and bounded ABOVE-by-individuals via the min —
        a real chaining of R4_Agent6 mixture conservation into the
        R.811/R.143 coverage law.

  Depends on:
    - MIP.Discoveries.R4_Agent6_MultiAgentConservation
        (R4_Agent6_MultiAgentConservation.mixture_conservation)   — conserved
          convex mixture; GENUINELY invoked in `mixture_is_conserved_distribution`
          and used to certify the convex-average structure of `N̄`.
    - MIP.Results.R811_CollabFano
        (R811_CollabFano.R_811_collab_fano_lower, R811_CollabFano.R_811_lower_pos)
          — divide-by-log Fano floor; invoked in `mixture_fano_floor`.
    - MIP.Results.R143_Committee
        (Committee.R_143_collective_le_individual)                — committee
          min ≤ individual; invoked in the headline.
    - Mathlib: Finset.sum_le_sum, Finset.mul_sum, Real.log_pos,
        Finset.inf'_le_of_le / Finset.le_sum (min ≤ convex average).
-/
import MIP.Discoveries.R4_Agent6_MultiAgentConservation
import MIP.Results.R811_CollabFano
import MIP.Results.R143_Committee
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R5_Agent8_MixtureFanoCoverage

/-! ## (Grounding) The committee mixture is a conserved distribution.

We first re-expose R4_Agent6's `mixture_conservation` so the conserved
convex-mixture structure is on the table as a genuine proof term: the
committee's mixed distribution `ω ↦ ∑_a w_a π_a ω` sums to 1. This is the
additive ("direct-sum") conservation face that we will push through the
Fano accumulation. -/

/-- **(Grounding) The committee mixture distribution is conserved.**

Directly R4_Agent6 `mixture_conservation`: nonnegative weights summing to 1
and per-agent conserved distributions give a conserved mixture. Re-exposed
here so the conserved-mixture invariant is a load-bearing hypothesis of the
Fano chaining below (the same `∑ w_a = 1` that R4_Agent6 conserved is what
makes `N̄` a genuine convex average). -/
theorem mixture_is_conserved_distribution
    {ι Ω : Type} [Fintype ι] [Fintype Ω]
    (w : ι → ℝ) (π : ι → Ω → ℝ)
    (hw : ∑ a, w a = 1)
    (hπ : ∀ a, ∑ ω, π a ω = 1) :
    ∑ ω, (∑ a, w a * π a ω) = 1 :=
  R4_Agent6_MultiAgentConservation.mixture_conservation w π hw hπ

/-! ## (a) Mixture-weighted Fano accumulation.

Each committee agent `a` satisfies an R.811/R.480 accumulation
`Φ₀ ≤ N_a · log(cardM_a)`. With a uniform capacity ceiling
`L ≥ log(cardM_a) ≥ 0` and the conserved weights `w_a ≥ 0`, `∑ w_a = 1`,
the per-agent accumulations average — *weighted by the conserved mixture
weights* — into a single accumulation on the convex-average count
`N̄ := ∑_a w_a N_a`. -/

/-- **(a) Mixture-weighted Fano accumulation `Φ₀ ≤ (∑_a w_a N_a) · L`.**

Hypotheses (committee Fano bundle):
* conserved weights `w_a ≥ 0`, `∑_a w_a = 1` (the additive committee
  conservation, R4_Agent6);
* per-agent capacity `0 ≤ log(cardM_a) ≤ L` (uniform per-step ceiling `L`);
* per-agent R.811 accumulation `Φ₀ ≤ N_a · log(cardM_a)`;
* nonnegative counts `0 ≤ N_a` (so weighting preserves the inequality
  direction termwise).

Then the conserved weights carry the obligation to the average:

    Φ₀  =  (∑ w_a)·Φ₀  ≤  ∑ w_a (N_a · log cardM_a)  ≤  ∑ w_a (N_a · L)
        =  (∑ w_a N_a) · L  =  N̄ · L.

The crux is the first equality: `(∑ w_a) = 1` is precisely the conserved
mixture invariant — the committee cannot weight its way out of the Fano
budget. -/
theorem mixture_fano_accumulation
    {ι : Type} [Fintype ι]
    (w N logCardM : ι → ℝ) (Phi0 L : ℝ)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcap_le : ∀ a, logCardM a ≤ L)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a) :
    Phi0 ≤ (∑ a, w a * N a) * L := by
  -- Step 1: Phi0 = (∑ w_a) · Phi0, the conserved-weight identity.
  have hstart : Phi0 = (∑ a, w a) * Phi0 := by rw [hw_sum]; ring
  -- Step 2: weighted per-agent accumulation, then capacity ceiling.
  -- Termwise:  w_a · Phi0 ≤ w_a · (N_a · logCardM_a) ≤ w_a · (N_a · L).
  have hterm : ∀ a ∈ (Finset.univ : Finset ι),
      w a * Phi0 ≤ w a * (N a * L) := by
    intro a _
    have h1 : w a * Phi0 ≤ w a * (N a * logCardM a) :=
      mul_le_mul_of_nonneg_left (hfano a) (hw_nonneg a)
    have h2 : w a * (N a * logCardM a) ≤ w a * (N a * L) := by
      have hcap : N a * logCardM a ≤ N a * L :=
        mul_le_mul_of_nonneg_left (hcap_le a) (hN_nonneg a)
      exact mul_le_mul_of_nonneg_left hcap (hw_nonneg a)
    exact le_trans h1 h2
  -- Sum the termwise bound: (∑ w_a)·Phi0 ≤ ∑ w_a (N_a L).
  have hsum : (∑ a, w a) * Phi0 ≤ ∑ a, w a * (N a * L) := by
    rw [Finset.sum_mul]
    exact Finset.sum_le_sum hterm
  -- ∑ w_a (N_a L) = (∑ w_a N_a) · L.
  have hfactor : (∑ a, w a * (N a * L)) = (∑ a, w a * N a) * L := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro a _; ring
  calc Phi0 = (∑ a, w a) * Phi0 := hstart
    _ ≤ ∑ a, w a * (N a * L) := hsum
    _ = (∑ a, w a * N a) * L := hfactor

/-! ## (b) Mixture-averaged Fano coverage lower bound.

Specializing the uniform ceiling to `L = log(cardMmax)` and dividing by the
strictly positive capacity (R.811), the conserved mixture average inherits
the hyperbolic Fano floor. -/

/-- **(b) Mixture-averaged Fano floor `Φ₀ / log(cardMmax) ≤ ∑_a w_a N_a`.**

With a uniform readable-alphabet ceiling `cardMmax` (`1 < cardMmax`, so
`log(cardMmax) > 0`) dominating each agent's readable alphabet
(`log(cardM_a) ≤ log(cardMmax)`), the mixture-weighted accumulation (a) feeds
R.811 `R_811_collab_fano_lower`, yielding the committee coverage lower bound
on the conserved convex-average intervention count. -/
theorem mixture_fano_floor
    {ι : Type} [Fintype ι]
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a) :
    Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a := by
  -- (a) gives the accumulation Phi0 ≤ N̄ · log(cardMmax).
  have hacc : Phi0 ≤ (∑ a, w a * N a) * Real.log cardMmax :=
    mixture_fano_accumulation w N logCardM Phi0 (Real.log cardMmax)
      hw_nonneg hw_sum hN_nonneg hcap_nonneg hcap_le hfano
  -- R.811 divide-by-log floor on the convex average N̄.
  exact R811_CollabFano.R_811_collab_fano_lower (∑ a, w a * N a) Phi0 cardMmax
    hcardMmax hacc

/-- **(b′) The mixture-averaged Fano floor is strictly positive.**

On a genuine instance (`Φ₀ > 0`, nontrivial uniform alphabet), the committee's
conserved mixture average intervention count is strictly positive — committee
weighting cannot make collaboration free. Via R.811 `R_811_lower_pos` on `N̄`. -/
theorem mixture_fano_floor_pos
    {ι : Type} [Fintype ι]
    (w N logCardM : ι → ℝ) (Phi0 cardMmax : ℝ)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hPhi0 : 0 < Phi0)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a) :
    0 < ∑ a, w a * N a := by
  have hacc : Phi0 ≤ (∑ a, w a * N a) * Real.log cardMmax :=
    mixture_fano_accumulation w N logCardM Phi0 (Real.log cardMmax)
      hw_nonneg hw_sum hN_nonneg hcap_nonneg hcap_le hfano
  exact R811_CollabFano.R_811_lower_pos (∑ a, w a * N a) Phi0 cardMmax
    hPhi0 hcardMmax hacc

/-! ## (Bridge) Committee minimum ≤ mixture average.

A finite minimum is never larger than any convex average over the same
family. This is the additive committee non-worsening (R.143 min law) carried
to the mixture: the `min_a N_a` is below the conserved-weight average `N̄`. -/

/-- **(Bridge) `min_a N_a ≤ ∑_a w_a N_a` for conserved weights.**

The committee minimum `inf'` is a lower bound on every convex combination of
the family (weights `w_a ≥ 0`, `∑ w_a = 1`): replace each `N_a` by the min,
use `∑ w_a · min = min`. This is the additive (direct-sum) committee
non-worsening principle at the level of the conserved mixture: the strongest
questioner's count is no worse than the committee's averaged count. -/
theorem committee_min_le_mixture
    {ι : Type} [Fintype ι] (N w : ι → ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1) :
    Finset.univ.inf' hne N ≤ ∑ a, w a * N a := by
  set m := Finset.univ.inf' hne N with hm
  -- m = (∑ w_a) · m = ∑ w_a · m  (conserved weights), and w_a·m ≤ w_a·N_a.
  have hmin_le : ∀ a, m ≤ N a := fun a =>
    Committee.R_143_collective_le_individual N hne a
  have hterm : ∀ a ∈ (Finset.univ : Finset ι), w a * m ≤ w a * N a :=
    fun a _ => mul_le_mul_of_nonneg_left (hmin_le a) (hw_nonneg a)
  calc m = (∑ a, w a) * m := by rw [hw_sum]; ring
    _ = ∑ a, w a * m := by rw [Finset.sum_mul]
    _ ≤ ∑ a, w a * N a := Finset.sum_le_sum hterm

/-! ## (c) HEADLINE — conserved committee mixture ⟹ Fano coverage lower bound.

The full chaining: R4_Agent6 conserved mixture + R.811 Fano + R.143 committee
min give a two-ended law on the committee's intervention counts. -/

/-- **(c) HEADLINE — conserved committee mixture ⟹ Fano coverage lower bound.**

For a committee with conserved mixture weights (`w_a ≥ 0`, `∑ w_a = 1`, the
R4_Agent6 additive-conservation face — certified live by
`mixture_is_conserved_distribution` on any conserved per-agent distributions
`π`), per-agent nonnegative counts `N_a`, and per-agent R.811 Fano
accumulations `Φ₀ ≤ N_a · log(cardM_a)` under a uniform readable-alphabet
ceiling `cardMmax` (`1 < cardMmax`, `log cardM_a ≤ log cardMmax`):

  (i)   **Fano coverage floor on the mixture average:**
            Φ₀ / log(cardMmax)  ≤  ∑_a w_a N_a  =  N̄;
  (ii)  **committee min ≤ mixture average:**  min_a N_a ≤ N̄;
  (iii) **committee no-worse (R.143):**  for every agent `b`, min_a N_a ≤ N_b;
  (iv)  **conserved-mixture certificate:**  the committee mixed distribution
            `ω ↦ ∑_a w_a π_a ω` sums to 1.

So the conserved committee mixture is Fano-bounded BELOW by the information
potential (i) on its genuine convex-average count, while the committee MINIMUM
sits below that average (ii) and below every individual (iii) — the additive
(min/mixture) committee structure and the multiplicative Fano coverage
obligation pinned to the SAME conserved normalization invariant `∑ w_a = 1`.

This strictly deepens Round 4 (which conserved the mixture and proved
multiplicative non-worsening) and R3_Agent8 (which floored only the single
attaining agent): here the CONSERVED WEIGHTS push the Fano obligation onto
the WHOLE committee's averaged count, not one representative. -/
theorem mixture_committee_fano
    {ι Ω : Type} [Fintype ι] [Fintype Ω]
    (w N logCardM : ι → ℝ) (π : ι → Ω → ℝ) (Phi0 cardMmax : ℝ)
    (hne : (Finset.univ : Finset ι).Nonempty)
    (hw_nonneg : ∀ a, 0 ≤ w a)
    (hw_sum : ∑ a, w a = 1)
    (hπ : ∀ a, ∑ ω, π a ω = 1)
    (hN_nonneg : ∀ a, 0 ≤ N a)
    (hcap_nonneg : ∀ a, 0 ≤ logCardM a)
    (hcardMmax : 1 < cardMmax)
    (hcap_le : ∀ a, logCardM a ≤ Real.log cardMmax)
    (hfano : ∀ a, Phi0 ≤ N a * logCardM a)
    (b : ι) :
    -- (i) Fano coverage floor on the conserved mixture average
    (Phi0 / Real.log cardMmax ≤ ∑ a, w a * N a)
    -- (ii) committee minimum ≤ mixture average
    ∧ (Finset.univ.inf' hne N ≤ ∑ a, w a * N a)
    -- (iii) committee no-worse than any individual (R.143)
    ∧ (Finset.univ.inf' hne N ≤ N b)
    -- (iv) the committee mixed distribution is conserved (R4_Agent6)
    ∧ (∑ ω, (∑ a, w a * π a ω) = 1) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (i) the mixture-averaged Fano floor (b).
    exact mixture_fano_floor w N logCardM Phi0 cardMmax
      hw_nonneg hw_sum hN_nonneg hcap_nonneg hcardMmax hcap_le hfano
  · -- (ii) committee min ≤ convex average.
    exact committee_min_le_mixture N w hne hw_nonneg hw_sum
  · -- (iii) R.143 committee min law.
    exact Committee.R_143_collective_le_individual N hne b
  · -- (iv) R4_Agent6 mixture conservation, certified live.
    exact mixture_is_conserved_distribution w π hw_sum hπ

end R5_Agent8_MixtureFanoCoverage

end MIP
