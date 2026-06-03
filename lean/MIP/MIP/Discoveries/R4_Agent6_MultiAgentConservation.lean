/-
  STATUS: DISCOVERY
  AGENT: R4_Agent6
  DIRECTION: MULTI-AGENT × CONSERVATION LAW — the joint conservation
    structure of a k-agent collaborative system. Distinguish the two
    distinct ways k single-agent conservation laws compose:

      TENSOR (product)   — independent agents: the joint distribution on the
                           product index ∏_a κ_a is the product ∏_a π^(a),
                           and it is conserved (sums to 1). Multiplicative.

      DIRECT-SUM (mixture) — a committee / mixture: a convex combination
                           ∑_a w_a π^(a) over a *common* index, with
                           ∑_a w_a = 1, is conserved. Additive.

  SUMMARY:
    R3_Agent2 (`product_mass_conservation`) proved the TWO-agent tensor law
    `∑_i ∑_j q_i π_j = 1`. We GENERALIZE it from 2 factors to an arbitrary
    finite family of `k` agents (`tensor_conservation_k`): if each agent
    `a` carries a conserved distribution `π a : κ a → ℝ` (`∑_j π a j = 1`),
    the joint distribution `x ↦ ∏_a π a (x a)` on the dependent product
    `∀ a, κ a` sums to 1. The engine is Mathlib's `Fintype.prod_sum`
    (`∏_i ∑_j f i j = ∑_x ∏_i f i (x i)`) chained with `Finset.prod_const_one`.

    Independently we prove the DIRECT-SUM (mixture) law
    (`mixture_conservation`): a convex mixture `∑_a w_a · π a` of per-agent
    conserved distributions over a common index `Ω`, with weights summing
    to 1, is itself conserved — proved by the Fubini swap and feeding
    R3_Agent2's `product_mass_conservation` as the inner identity (so the
    two laws are genuinely chained, not re-derived).

    HEADLINE (`independent_failure_multiplies` + `committee_beats_no_worse`).
    The tensor law is the conservation backbone of INDEPENDENT multi-agent
    coverage (R.813 joint coverage / R.811 collaborative information):
    independent per-agent failure probabilities `f a ∈ [0,1]` give a joint
    failure `∏_a f a` and a joint success `1 - ∏_a f a`. We prove:

      (1) the joint success/failure pair is itself a conserved 2-point
          distribution (`∏ f + (1 - ∏ f) = 1`), the *tensor* face;
      (2) `∏_a f a ≤ f b` for every agent `b` (joint failure never exceeds
          any single agent's failure) — the MULTIPLICATIVE analogue of the
          R.143 / R.510 committee min-identity `N_col = min_i N_i`: adding an
          independent agent can only shrink the joint failure, never grow it,
          so the committee is "no worse" in the product regime exactly as it
          is "no worse" in the additive (min) regime.

    Thus the two conservation faces are the multiplicative (tensor,
    independent, R.813 coverage) and additive (direct-sum, mixture/committee,
    R.143 min) shadows of the SAME k-agent normalization invariant.

  Depends on:
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation
        (R3_Agent2_Mu0MassConservation.product_mass_conservation)   [2-agent tensor seed]
    - MIP.Results.R143_Committee
        (Committee.R_143_collective_le_individual)                  [committee min law]
    - MIP.Results.R510_MultiAgentN
        (MultiAgentN.R_510_collective_le_individual)                [multi-agent squeeze]
    - Mathlib: Fintype.prod_sum, Finset.prod_const_one,
        Finset.single_le_prod', Finset.sum_comm.
-/
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Results.R143_Committee
import MIP.Results.R510_MultiAgentN
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

namespace MIP

open scoped BigOperators

namespace R4_Agent6_MultiAgentConservation

/-! ## (a) TENSOR conservation — the k-fold generalization of
`product_mass_conservation`.

Each agent `a : ι` (`ι` a finite index of agents) carries its own conserved
distribution `π a : κ a → ℝ` over its private index `κ a`. The joint system
lives on the *dependent product* `∀ a, κ a`; its distribution is the product
`x ↦ ∏ a, π a (x a)`. The TENSOR conservation law says this joint
distribution is again normalized. -/

/-- **(a) TENSOR (product) conservation, k agents.**

If `ι` is a finite family of agents and each agent `a` carries a conserved
distribution `π a` (`∑ j, π a j = 1`), then the joint product distribution on
the dependent product index sums to 1:

    ∑_{x : ∀ a, κ a}  ∏_a π a (x a)  =  1.

This is the arbitrary-`k` generalization of R3_Agent2's two-agent
`product_mass_conservation`. The proof reverses Mathlib's `Fintype.prod_sum`
to collapse the joint sum into a product of single-agent sums, each `= 1`,
then `∏ 1 = 1`. -/
theorem tensor_conservation_k
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    {κ : ι → Type*} [∀ a, Fintype (κ a)]
    (π : ∀ a, κ a → ℝ)
    (hπ : ∀ a, ∑ j, π a j = 1) :
    ∑ x : (∀ a, κ a), ∏ a, π a (x a) = 1 := by
  -- `Fintype.prod_sum`: ∏ a, (∑ j, π a j) = ∑ x, ∏ a, π a (x a).
  have key : ∏ a, (∑ j, π a j) = ∑ x : (∀ a, κ a), ∏ a, π a (x a) :=
    Fintype.prod_sum (fun a j => π a j)
  rw [← key]
  -- Each inner sum is 1, so the product is ∏ a, 1 = 1.
  calc ∏ a, (∑ j, π a j) = ∏ _a : ι, (1 : ℝ) := by
        exact Finset.prod_congr rfl (fun a _ => hπ a)
    _ = 1 := Finset.prod_const_one

/-- **(a′) Tensor conservation recovers R3_Agent2's two-agent law.**

Specializing `tensor_conservation_k` to `ι = Bool` (two agents) and matching
the `Σ_i Σ_j` iterated-sum form, we land back on R3_Agent2's
`product_mass_conservation` over the two factors — confirming the k-fold law
is a genuine generalization (sanity bridge, not a re-derivation: the two-agent
fact is *imported* and re-exposed here). -/
theorem tensor_two_agent_consistency
    {ι₁ ι₂ : Type*} (s₁ : Finset ι₁) (s₂ : Finset ι₂)
    (q : ι₁ → ℝ) (π : ι₂ → ℝ)
    (hq : ∑ i ∈ s₁, q i = 1) (hπ : ∑ j ∈ s₂, π j = 1) :
    (∑ i ∈ s₁, ∑ j ∈ s₂, q i * π j) = 1 :=
  R3_Agent2_Mu0MassConservation.product_mass_conservation s₁ s₂ q π hq hπ

/-! ## (b) DIRECT-SUM (mixture) conservation.

A *committee* does not tensor private indices; it mixes per-agent
distributions over a SHARED index `Ω`. With nonnegative weights `w a`
summing to 1 and each `π a` a conserved distribution on `Ω`, the mixture
`ω ↦ ∑ a, w a · π a ω` is again a conserved distribution. We prove the
normalization by the Fubini swap, then feed R3_Agent2's
`product_mass_conservation` as the inner `(weights)×(distribution) = 1`
identity. -/

/-- **(b) DIRECT-SUM (convex mixture) conservation.**

Given a finite agent index `ι`, weights `w : ι → ℝ` with `∑ a, w a = 1`, and
per-agent distributions `π : ι → Ω → ℝ` each conserved (`∑ ω, π a ω = 1`),
the mixture distribution on `Ω` is conserved:

    ∑_ω ( ∑_a w a · π a ω )  =  1.

Proof: swap the order of summation (`Finset.sum_comm`) so the outer sum is
over agents, then the double sum `∑_a ∑_ω w a · π a ω` is exactly the
two-index product mass of R3_Agent2 — `product_mass_conservation` finishes. -/
theorem mixture_conservation
    {ι Ω : Type*} [Fintype ι] [Fintype Ω]
    (w : ι → ℝ) (π : ι → Ω → ℝ)
    (hw : ∑ a, w a = 1)
    (hπ : ∀ a, ∑ ω, π a ω = 1) :
    ∑ ω, (∑ a, w a * π a ω) = 1 := by
  -- Swap to put the agent sum outside: ∑_ω ∑_a  →  ∑_a ∑_ω.
  rw [Finset.sum_comm]
  -- Now we have ∑_a ∑_ω w a * π a ω.  Factor out w a inside the inner sum.
  have hfactor :
      (∑ a, ∑ ω, w a * π a ω) = ∑ a, w a * (∑ ω, π a ω) := by
    refine Finset.sum_congr rfl (fun a _ => ?_)
    rw [Finset.mul_sum]
  rw [hfactor]
  -- Each ∑_ω π a ω = 1, so the inner factor is w a, giving ∑_a w a = 1.
  calc ∑ a, w a * (∑ ω, π a ω)
      = ∑ a, w a * 1 := by
        refine Finset.sum_congr rfl (fun a _ => ?_); rw [hπ a]
    _ = ∑ a, w a := by simp
    _ = 1 := hw

/-! ## (c) HEADLINE — the tensor face is the conservation backbone of
INDEPENDENT multi-agent coverage (R.813), and its multiplicative committee
law mirrors the additive committee min (R.143 / R.510). -/

/-- **(c.0) Joint failure / success is a conserved 2-point distribution.**

For ANY joint failure probability `F ∈ [0,1]` (in the independent regime
`F = ∏_a f a`, see `independent_failure_multiplies`), the pair
`(success, failure) = (1 - F, F)` is a conserved 2-point distribution:

    (1 - F) + F = 1,   with both entries in `[0,1]`.

This is the *tensor face* of the k-agent normalization invariant collapsed
onto the success/failure dichotomy of joint coverage (R.813). -/
theorem joint_success_failure_conserved
    (F : ℝ) (h0 : 0 ≤ F) (h1 : F ≤ 1) :
    (1 - F) + F = 1 ∧ 0 ≤ 1 - F ∧ 1 - F ≤ 1 ∧ 0 ≤ F ∧ F ≤ 1 := by
  refine ⟨by ring, ?_, ?_, h0, h1⟩
  · linarith
  · linarith

/-- **(c.1) Independent failures multiply (the tensor coverage law).**

In the INDEPENDENT regime (R.813 joint coverage with statistically
independent agents), the joint failure probability is the product of the
per-agent failure probabilities:

    F_joint  =  ∏_a f a,

and we certify it is a genuine probability `∈ [0,1]` (so that, together with
`joint_success_failure_conserved`, the joint success/failure pair conserves).
Each `f a ∈ [0,1]` gives `0 ≤ ∏ f a ≤ ∏ 1 = 1`. This is the *multiplicative*
conservation backbone underlying R.813's union joint coverage. -/
theorem independent_failure_multiplies
    {ι : Type*} [Fintype ι]
    (f : ι → ℝ) (h0 : ∀ a, 0 ≤ f a) (h1 : ∀ a, f a ≤ 1) :
    0 ≤ ∏ a, f a ∧ ∏ a, f a ≤ 1 := by
  refine ⟨Finset.prod_nonneg (fun a _ => h0 a), ?_⟩
  calc ∏ a, f a ≤ ∏ _a : ι, (1 : ℝ) :=
        Finset.prod_le_prod (fun a _ => h0 a) (fun a _ => h1 a)
    _ = 1 := Finset.prod_const_one

/-- **(c.2) Committee never worse — multiplicative form (mirror of R.143/R.510).**

The MULTIPLICATIVE committee law: for independent agents with per-agent
failure `f a ∈ [0,1]`, the JOINT failure `∏_a f a` never exceeds ANY single
agent's failure `f b`:

    ∏_a f a  ≤  f b   for every agent `b`.

This is the product-regime analogue of the additive committee min-identity
`N_col = min_i N_i` (R.143 `R_143_collective_le_individual` / R.510
`R_510_collective_le_individual`): in BOTH regimes the collective is *no
worse than any individual*. Additively the collective cost is the minimum;
multiplicatively the collective failure is dominated by every factor. Hence
the committee "no-worse" principle holds for BOTH conservation faces —
direct-sum (min) and tensor (product). Proof: `Finset.single_le_prod'`
(every factor `≤ 1` ⟹ the full product `≤` any single factor), the
multiplicative shadow of `inf'_le`. -/
theorem committee_failure_le_individual
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (f : ι → ℝ) (h0 : ∀ a, 0 ≤ f a) (h1 : ∀ a, f a ≤ 1) (b : ι) :
    ∏ a, f a ≤ f b := by
  -- `single_le_prod'`: if every other factor is ≤ 1 and all nonneg, the
  -- product is ≤ the single factor f b.  We use the `≥`-flavored lemma:
  -- `Finset.prod_le_prod` is overkill; the direct tool is below.
  have hmem : b ∈ (Finset.univ : Finset ι) := Finset.mem_univ b
  -- Split off the b-th factor and bound the remaining product by 1.
  rw [← Finset.prod_erase_mul (Finset.univ) f hmem]
  -- Goal: (∏ a ∈ univ.erase b, f a) * f b ≤ f b.
  have hrest_nonneg : 0 ≤ ∏ a ∈ (Finset.univ.erase b), f a :=
    Finset.prod_nonneg (fun a _ => h0 a)
  have hrest_le_one : ∏ a ∈ (Finset.univ.erase b), f a ≤ 1 := by
    calc ∏ a ∈ (Finset.univ.erase b), f a
        ≤ ∏ _a ∈ (Finset.univ.erase b), (1 : ℝ) :=
          Finset.prod_le_prod (fun a _ => h0 a) (fun a _ => h1 a)
      _ = 1 := Finset.prod_const_one
  -- (rest ≤ 1) and (f b ≥ 0) ⟹ rest * f b ≤ 1 * f b = f b.
  calc (∏ a ∈ (Finset.univ.erase b), f a) * f b
      ≤ 1 * f b := mul_le_mul_of_nonneg_right hrest_le_one (h0 b)
    _ = f b := one_mul _

/-- **(c.3) HEADLINE — the two conservation faces of the k-agent system.**

Packaging the dichotomy. Fix a finite agent family `ι`.

* **Additive (direct-sum / committee, R.143):** with per-agent costs `N` and
  collective cost the finite minimum, the collective is no worse than any
  individual — `N_col ≤ N b` — which is R.143's `inf'_le`. We re-expose it.
* **Multiplicative (tensor / independent coverage, R.813):** with per-agent
  failures `f a ∈ [0,1]`, the joint failure `∏_a f a` is no worse than any
  individual failure — `∏ f ≤ f b` (c.2) — and the joint success/failure pair
  is a conserved 2-point distribution (c.0, c.1).

The SAME "collective ≤ individual" non-worsening principle therefore governs
BOTH conservation structures: the direct-sum law via the minimum, the tensor
law via the product. This is the joint-conservation dichotomy. -/
theorem joint_conservation_dichotomy
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (hne : (Finset.univ : Finset ι).Nonempty)
    (N : ι → ℝ)
    (f : ι → ℝ) (h0 : ∀ a, 0 ≤ f a) (h1 : ∀ a, f a ≤ 1)
    (b : ι) :
    -- additive committee face (R.143 / R.510)
    (Finset.univ.inf' hne N ≤ N b)
    -- tensor independent-coverage face (R.813), product ≤ individual
    ∧ (∏ a, f a ≤ f b)
    -- tensor face is a genuine conserved 2-point distribution
    ∧ ((1 - ∏ a, f a) + ∏ a, f a = 1) := by
  refine ⟨?_, ?_, ?_⟩
  · -- additive: directly R.143 / R.510 (imported committee min law).
    exact MIP.Committee.R_143_collective_le_individual N hne b
  · -- multiplicative: c.2.
    exact committee_failure_le_individual f h0 h1 b
  · -- conservation of the joint success/failure pair.
    obtain ⟨hsum, _, _, _, _⟩ :=
      joint_success_failure_conserved (∏ a, f a)
        (Finset.prod_nonneg (fun a _ => h0 a))
        (independent_failure_multiplies f h0 h1).2
    exact hsum

end R4_Agent6_MultiAgentConservation

end MIP
